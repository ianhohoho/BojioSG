import json
import os
import urllib.request

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError, jwk, jwt
from sqlalchemy.orm import Session

from database import get_db
from models import User

security = HTTPBearer()
optional_security = HTTPBearer(auto_error=False)

# Cache for JWKS keys
_jwks_cache: dict | None = None


def _get_jwt_secret() -> str:
    return os.getenv("SUPABASE_JWT_SECRET", "super-secret-jwt-token-with-at-least-32-characters-long")


def _get_jwks() -> dict:
    """Fetch and cache JWKS from Supabase."""
    global _jwks_cache
    if _jwks_cache is not None:
        return _jwks_cache

    supabase_url = os.getenv("NEXT_PUBLIC_SUPABASE_URL") or os.getenv("SUPABASE_URL", "")
    if not supabase_url:
        return {}

    try:
        req = urllib.request.Request(f"{supabase_url}/auth/v1/.well-known/jwks.json")
        resp = urllib.request.urlopen(req, timeout=5)
        _jwks_cache = json.loads(resp.read())
        return _jwks_cache
    except Exception:
        return {}


def _get_or_create_user(db: Session, supabase_uid: str, email: str | None = None, name: str | None = None) -> User:
    """Look up user by supabase_uid, auto-create if not found."""
    user = db.query(User).filter(User.supabase_uid == supabase_uid).first()
    if user:
        return user

    # Auto-provision new user
    nickname = name or (email.split("@")[0] if email else None)
    user = User(
        supabase_uid=supabase_uid,
        email=email,
        nickname=nickname,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def _verify_supabase_token(token: str) -> dict:
    """Verify a Supabase JWT and return the payload."""
    try:
        header = jwt.get_unverified_header(token)
        alg = header.get("alg", "HS256")

        if alg == "ES256":
            kid = header.get("kid")
            jwks = _get_jwks()
            key_data = None
            for k in jwks.get("keys", []):
                if k.get("kid") == kid:
                    key_data = k
                    break
            if not key_data:
                raise JWTError("No matching key found in JWKS")
            key = jwk.construct(key_data, algorithm="ES256")
            payload = jwt.decode(
                token, key, algorithms=["ES256"], options={"verify_aud": False}
            )
        else:
            payload = jwt.decode(
                token, _get_jwt_secret(), algorithms=["HS256"], options={"verify_aud": False}
            )

        return payload
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )


def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
) -> User:
    payload = _verify_supabase_token(credentials.credentials)
    supabase_uid = payload.get("sub")
    if not supabase_uid:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token: missing sub claim",
            headers={"WWW-Authenticate": "Bearer"},
        )

    email = payload.get("email")
    user_metadata = payload.get("user_metadata", {})
    name = user_metadata.get("full_name") or user_metadata.get("name")

    return _get_or_create_user(db, supabase_uid, email=email, name=name)


def get_optional_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(optional_security),
    db: Session = Depends(get_db),
) -> User | None:
    if credentials is None:
        return None
    try:
        payload = _verify_supabase_token(credentials.credentials)
        supabase_uid = payload.get("sub")
        if not supabase_uid:
            return None
        email = payload.get("email")
        user_metadata = payload.get("user_metadata", {})
        name = user_metadata.get("full_name") or user_metadata.get("name")
        return _get_or_create_user(db, supabase_uid, email=email, name=name)
    except HTTPException:
        return None
