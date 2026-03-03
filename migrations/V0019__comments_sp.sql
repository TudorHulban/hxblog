CREATE OR REPLACE PROCEDURE create_comment(
    p_id              bigint,
    p_post_id         bigint,
    p_content         text,
    p_parent_id       bigint DEFAULT NULL,
    p_user_id         bigint DEFAULT NULL,
    p_author_name     varchar DEFAULT NULL,
    p_author_email    varchar DEFAULT NULL,
    p_author_url      varchar DEFAULT NULL,
    p_author_ip       inet DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO "30_comments" (
        id,
        post_id,
        parent_id,
        user_id,
        author_name,
        author_email,
        author_url,
        author_ip,
        content
    )
    VALUES (
        p_id,
        p_post_id,
        p_parent_id,
        p_user_id,
        p_author_name,
        p_author_email,
        p_author_url,
        p_author_ip,
        p_content
    );
END;
$$;

-- CALL create_comment(
--     1001,
--     55,
--     'Nice post!',
--     NULL,
--     42,
--     'John Doe',
--     'john@example.com',
--     NULL,
--     '192.168.1.10'
-- );
