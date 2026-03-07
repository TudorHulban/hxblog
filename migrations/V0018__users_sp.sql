-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 02. users logic
-- =====================================================

create or replace procedure hx_create_user(
    in p_id int8,
    in p_email citext,
    in p_username text,
    in p_password_hash text,
    in p_first_name text default null,
    in p_last_name text default null,
    in p_bio text default null,
    in p_avatar_url text default null,
    in p_role_id smallint default null,
    in p_status_id smallint default null,
    in p_two_factor_enabled boolean default false
)
language plpgsql
SECURITY DEFINER
as $$
begin
    -- lock down search path to prevent privilege escalation
    SET LOCAL search_path = public, pg_catalog;

    -- required field validation
    if p_id is null then
        raise exception 'id cannot be null';
    end if;

    if p_email is null then
        raise exception 'email cannot be null';
    end if;

    if p_username is null then
        raise exception 'username cannot be null';
    end if;

    if p_password_hash is null then
        raise exception 'password_hash cannot be null';
    end if;

    insert into users (
        id,
        email,
        username,
        password_hash,
        first_name,
        last_name,
        bio,
        avatar_url,
        role_id,
        status_id,
        two_factor_enabled
    )
    values (
        p_id,
        p_email,
        p_username,
        p_password_hash,
        p_first_name,
        p_last_name,
        p_bio,
        p_avatar_url,
        p_role_id,
        p_status_id,
        coalesce(p_two_factor_enabled, false)
    );

exception
    when unique_violation then
        raise exception
            using message = 'user with same email or username already exists';
    when foreign_key_violation then
        raise exception
            using message = 'invalid role_id or status_id';
end;
$$;

-- test

-- call hx_create_user(
--     1700077770005000100::int8,                         -- p_id
--     'auditor_branch@sys.io'::varchar(255),              -- p_email
--     'auditor_branch'::varchar(50),                      -- p_username
--     '$2a$10$nqUHcOLeF/5gIrQP8kAai.hfOAmrvDaLf5tGC2AbQPsD4drs8E5yS'::varchar(255), -- p_password_hash
--     'Auditor'::varchar(100),                            -- p_first_name
--     'Branch'::varchar(100),                             -- p_last_name
--     'Auditor level branch account'::text,               -- p_bio
--     null::varchar(500),                                 -- p_avatar_url
--     2::smallint,                                        -- p_role_id
--     1::smallint,                                        -- p_status_id
--     false::boolean                                      -- p_two_factor_enabled
-- );


create or replace procedure hx_email_verification_started(
    in p_id int8,
    in p_email_verification_token uuid,
    in p_email_verification_sent_at int8
)
language plpgsql
SECURITY DEFINER
as $$
declare
    v_rows_updated integer;
begin
    -- lock down search path to prevent privilege escalation
    SET LOCAL search_path = public, pg_catalog;

    if p_id is null then
        raise exception 'id cannot be null';
    end if;

    if p_email_verification_token is null then
        raise exception 'email_verification_token cannot be null';
    end if;

    if p_email_verification_sent_at is null then
        raise exception 'email_verification_sent_at cannot be null';
    end if;

    update users
    set
        email_verification_token = p_email_verification_token,
        email_verification_sent_at = p_email_verification_sent_at,
        updated_at = p_email_verification_sent_at
    where id = p_id
      and deleted_at is null;

    get diagnostics v_rows_updated = row_count;

    if v_rows_updated = 0 then
        raise exception 'user not found or deleted';
    end if;
end;
$$;


create or replace procedure hx_email_now_verified(
    in p_id int8,
    in p_email_verified boolean,
    in p_email_verified_at int8
)
language plpgsql
SECURITY DEFINER
as $$
declare
    v_rows_updated integer;
begin
    -- lock down search path to prevent privilege escalation
    SET LOCAL search_path = public, pg_catalog;

    if p_id is null then
        raise exception 'id cannot be null';
    end if;

    if p_email_verified is null then
        raise exception 'email_verified cannot be null';
    end if;

    if p_email_verified = true and p_email_verified_at is null then
        raise exception 'email_verified_at required when verifying email';
    end if;

    update users
    set
        email_verified = p_email_verified,
        email_verified_at = p_email_verified_at,
        email_verification_token = null,
        updated_at = p_email_verified_at
    where id = p_id
      and deleted_at is null;

    get diagnostics v_rows_updated = row_count;

    if v_rows_updated = 0 then
        raise exception 'user not found or deleted';
    end if;
end;
$$;


create or replace procedure hx_enable_two_factor(
    in p_id int8,
    in p_two_factor_enabled boolean,
    in p_two_factor_secret text,
    in p_updated_at int8
)
language plpgsql
SECURITY DEFINER
as $$
declare
    v_rows_updated integer;
begin
    -- lock down search path to prevent privilege escalation
    SET LOCAL search_path = public, pg_catalog;

    if p_id is null then
        raise exception 'id cannot be null';
    end if;

    if p_two_factor_enabled is null then
        raise exception 'two_factor_enabled cannot be null';
    end if;

    if p_two_factor_enabled = true and p_two_factor_secret is null then
        raise exception 'two_factor_secret required when enabling two factor';
    end if;

    update users
    set
        two_factor_enabled = p_two_factor_enabled,
        two_factor_secret = p_two_factor_secret,
        updated_at = p_updated_at
    where id = p_id
      and deleted_at is null;

    get diagnostics v_rows_updated = row_count;

    if v_rows_updated = 0 then
        raise exception 'user not found or deleted';
    end if;
end;
$$;


create or replace procedure hx_login(
    in p_id int8,
    in p_last_login_at int8,
    in p_last_login_ip inet
)
language plpgsql
SECURITY DEFINER
as $$
declare
    v_rows_updated integer;
begin
    -- lock down search path to prevent privilege escalation
    SET LOCAL search_path = public, pg_catalog;

    if p_id is null then
        raise exception 'id cannot be null';
    end if;

    if p_last_login_at is null then
        raise exception 'last_login_at cannot be null';
    end if;

    update users
    set
        last_login_at = p_last_login_at,
        last_login_ip = p_last_login_ip,
        login_counts_today = login_counts_today + 1,
        updated_at = p_last_login_at
    where id = p_id
      and deleted_at is null;

    get diagnostics v_rows_updated = row_count;

    if v_rows_updated = 0 then
        raise exception 'user not found or deleted';
    end if;
end;
$$;


create or replace procedure hx_reset_daily_login_counts()
language plpgsql
SECURITY DEFINER
as $$
begin
    -- lock down search path to prevent privilege escalation
    SET LOCAL search_path = public, pg_catalog;

    update users
    set
        login_counts_today = 0
    where deleted_at is null
      and login_counts_today <> 0;
end;
$$;

create or replace procedure hx_reset_daily_login_counts()
language plpgsql
SECURITY DEFINER
as $$
begin
    -- lock down search path to prevent privilege escalation
    SET LOCAL search_path = public, pg_catalog;

    update users
    set login_counts_today = 0
    where deleted_at is null
      and login_counts_today <> 0;
end;
$$;

-- do $$
-- begin
--     if not exists (
--         select 1
--         from cron.job
--         where jobname = 'reset-daily-login-counts'
--     ) then
--         perform cron.schedule(
--             'reset-daily-login-counts',
--             '0 0 * * *',
--             'call sp_reset_daily_login_counts();'
--         );
--     end if;
-- end;
-- $$;