-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 03. posts logic
-- =====================================================

create or replace procedure create_post(
    p_id                int8,
    p_author_id         int8,
    p_title             text,
    p_excerpt           text,
    p_content           text,
    p_status_id         int2,
    p_scheduled_at      int8,
    p_published_at      int8,
    p_visible_until     int8,
    p_featured_image_id int8,
    p_meta_title        text,
    p_meta_description  text,
    p_meta_keywords     text[],
    p_canonical_url     text,
    p_og_image          text,
    p_allow_comments    boolean,
    p_is_featured       boolean,
    p_is_sticky         boolean,
    p_password_hint     text
)
language plpgsql
SECURITY DEFINER
as $$
begin
    -- lock down search path to prevent privilege escalation
    SET LOCAL search_path = public, pg_catalog;

    insert into posts (
        id, author_id, title, excerpt, content, status_id,
        scheduled_at, published_at, visible_until,
        featured_image_id,
        meta_title, meta_description, meta_keywords,
        canonical_url, og_image,
        allow_comments, is_featured, is_sticky, password_hint,
        updated_at
    )
    values (
        p_id, p_author_id, p_title, p_excerpt, p_content, p_status_id,
        p_scheduled_at, p_published_at, p_visible_until,
        p_featured_image_id,
        p_meta_title, p_meta_description, p_meta_keywords,
        p_canonical_url, p_og_image,
        p_allow_comments, p_is_featured, p_is_sticky, p_password_hint,
        extract(epoch from now())::int8
    );
end;
$$;


create or replace function get_post(p_id int8)
returns table (
    id int8,
    author_id int8,
    title text,
    excerpt text,
    content text,
    status_id int2,
    scheduled_at int8,
    published_at int8,
    visible_until int8,
    featured_image_id int8,
    meta_title text,
    meta_description text,
    meta_keywords text[],
    canonical_url text,
    og_image text,
    allow_comments boolean,
    is_featured boolean,
    is_sticky boolean,
    password_hint text,
    updated_at int8,
    deleted_at int8
)
language plpgsql
SECURITY DEFINER
as $$
begin
    -- lock down search path to prevent privilege escalation
    SET LOCAL search_path = public, pg_catalog;

    return query
    select
        id,
        author_id,
        title,
        excerpt,
        content,
        status_id,
        scheduled_at,
        published_at,
        visible_until,
        featured_image_id,
        meta_title,
        meta_description,
        meta_keywords,
        canonical_url,
        og_image,
        allow_comments,
        is_featured,
        is_sticky,
        password_hint,
        updated_at,
        deleted_at
    from posts
    where id = p_id;
end;
$$;


create or replace procedure update_post(
    p_id                int8,
    p_title             text,
    p_excerpt           text,
    p_content           text,
    p_status_id         int2,
    p_scheduled_at      int8,
    p_published_at      int8,
    p_visible_until     int8,
    p_featured_image_id int8,
    p_meta_title        text,
    p_meta_description  text,
    p_meta_keywords     text[],
    p_canonical_url     text,
    p_og_image          text,
    p_allow_comments    boolean,
    p_is_featured       boolean,
    p_is_sticky         boolean,
    p_password_hint     text
)
language plpgsql
SECURITY DEFINER
as $$
begin
    -- lock down search path to prevent privilege escalation
    SET LOCAL search_path = public, pg_catalog;

    update posts
    set
        title             = p_title,
        excerpt           = p_excerpt,
        content           = p_content,
        status_id         = p_status_id,
        scheduled_at      = p_scheduled_at,
        published_at      = p_published_at,
        visible_until     = p_visible_until,
        featured_image_id = p_featured_image_id,
        meta_title        = p_meta_title,
        meta_description  = p_meta_description,
        meta_keywords     = p_meta_keywords,
        canonical_url     = p_canonical_url,
        og_image          = p_og_image,
        allow_comments    = p_allow_comments,
        is_featured       = p_is_featured,
        is_sticky         = p_is_sticky,
        password_hint     = p_password_hint,
        updated_at        = extract(epoch from now())::int8
    where id = p_id;
end;
$$;

create or replace procedure delete_post(p_id int8)
language plpgsql
as $$
begin
    -- lock down search path to prevent privilege escalation
    SET LOCAL search_path = public, pg_catalog;

    update posts
    set deleted_at = extract(epoch from now())::int8
    where id = p_id;
end;
$$;

create or replace procedure destroy_post(p_id int8)
language plpgsql
SECURITY DEFINER
as $$
begin
    -- lock down search path to prevent privilege escalation
    SET LOCAL search_path = public, pg_catalog;

    delete from posts
    where id = p_id;
end;
$$;
