-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 01. configuration - values
-- =====================================================

create table if not exists "02_config_values" (
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
    select t.config_key, t.config_value from "02_config_values" t;
end;
$$;

insert into "02_config_values" (config_key, config_value) values
    ('port-blog', '9000' ),
    ('email-batch-size', '20' ),
    ('email-system-address', 'system@taraworks.eu'),
    ('email-smtp-host', 'localhost'),
    ('email-smtp-port', '1025');