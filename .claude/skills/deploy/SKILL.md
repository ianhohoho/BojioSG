---
name: deploy
description: Run backend tests, deploy to Fly.io, and verify both local and remote endpoints
disable-model-invocation: true
allowed-tools: Bash
---

Deploy the backend to Fly.io with full test coverage:

1. Run the unit test suite: `cd backend && source venv/bin/activate && python -m pytest tests/ -v`
2. If tests fail, stop and report — do NOT deploy
3. Deploy: `cd backend && fly deploy --local-only`
4. Run smoke tests against local: `cd backend && source venv/bin/activate && python test_remote.py http://localhost:8000`
5. Run smoke tests against production: `cd backend && source venv/bin/activate && python test_remote.py https://bojiosg-api.fly.dev`
6. Report: unit test count, deploy status, local smoke results, production smoke results
