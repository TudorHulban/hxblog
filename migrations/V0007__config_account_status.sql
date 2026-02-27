-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 01. configuration - account status
-- =====================================================

create table if not exists "05_config_account_statuses" (
    id smallserial primary key,
    status_name varchar(50) not null unique,
    description text
);

insert into "05_config_account_statuses" (status_name, description) values
    ('active', 'Full system access'),
    ('inactive', 'Can edit and publish content'),
    ('suspended', 'Can write and manage own posts'),
    ('pending', 'Can write but not publish')
on conflict (status_name) do nothing;
