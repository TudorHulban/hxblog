-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 01. configuration - user roles
-- =====================================================

create table if not exists config_06_user_roles (
    id int2 generated always as identity primary key,
    role_name varchar(50) not null unique,
    description text
);

insert into config_06_user_roles (role_name, description) values
    ('admin', 'Full system access'),
    ('editor', 'Can edit and publish content'),
    ('author', 'Can write and manage own posts'),
    ('contributor', 'Can write but not publish'),
    ('subscriber', 'Basic account with read access')
on conflict (role_name) do nothing;
