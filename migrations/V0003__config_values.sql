-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 01. configuration - values
-- =====================================================

create table if not exists config_02_values (
    config_key text not null unique,
    config_value text
);

create or replace function get_config_values()
returns table (
    config_key text,
    config_value text
)
language plpgsql
as 
$$
begin
return query
    select t.config_key, t.config_value from config_02_values t;
end;
$$;

insert into config_02_values (config_key, config_value) values
    ('blog-listens', '9000' ),
    ('blog-title', 'DevBlog' ),
    ('posts-per-page', '5'),
    ('allow-comments', 'true'),
    ('maintenance-mode', 'false'),
    ('maintenance-message', 'site under maintenance'),
    ('email-batch-size', '20' ),
    ('email-system-address', 'system@taraworks.eu'),
    ('email-smtp-host', 'localhost'),
    ('email-smtp-port', '1025');