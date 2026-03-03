-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 01. configuration - post status
-- =====================================================

create table if not exists "05_config_post_statuses"(
    id smallserial primary key,
    status_name varchar(50) not null unique,
    description text
);

insert into "05_config_post_statuses" (status_name, description) values
    ('draft', 'Work in progress, not visible to readers'),
    ('pending_review', 'Awaiting editorial approval'),
    ('scheduled', 'Will be published at a future date'),
    ('published', 'Visible to all readers'),
    ('trash', 'Soft-deleted, can be restored')
on conflict (status_name) do nothing;
