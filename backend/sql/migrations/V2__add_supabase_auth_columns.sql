-- Add Supabase Auth columns to users table
ALTER TABLE users ADD COLUMN supabase_uid UUID UNIQUE;
ALTER TABLE users ADD COLUMN email VARCHAR;
ALTER TABLE users ALTER COLUMN password_hash DROP NOT NULL;
ALTER TABLE users ALTER COLUMN username DROP NOT NULL;
CREATE INDEX idx_users_supabase_uid ON users(supabase_uid);
