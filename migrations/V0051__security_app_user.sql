-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 04. security - create application user
-- =====================================================

-- 1. Create the user
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_roles WHERE rolname = 'app_user'
    ) THEN
        CREATE ROLE app_user LOGIN PASSWORD 'secure_password_here';
    END IF;
END
$$;


-- 2. Allow connecting to the database
GRANT CONNECT ON DATABASE tara_blog TO app_user;

-- 3. Allow using the schema (required for calling functions)
GRANT USAGE ON SCHEMA public TO app_user;

-- 4. Allow executing all functions and procedures in the schema
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO app_user;
GRANT EXECUTE ON ALL PROCEDURES IN SCHEMA public TO app_user;

-- 5. Ensure future functions/procedures are also executable
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT EXECUTE ON FUNCTIONS TO app_user;

