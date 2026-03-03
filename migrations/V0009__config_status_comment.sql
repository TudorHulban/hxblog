-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 01. configuration - comment status
-- =====================================================

create table if not exists "06_config_comment_statuses"(
    id smallserial primary key,
    comment_name varchar(50) not null unique,
    description text
);

insert into "06_config_comment_statuses" (comment_name, description) values
    ('pending',  'Comment submitted and awaiting moderation; not visible to readers'),
    ('approved', 'Comment approved by moderators and visible to readers'),
    ('rejected', 'Comment reviewed and not approved; not visible to readers'),
    ('spam',     'Comment flagged as spam; not visible to readers'),
    ('trash',    'Comment deleted or moved to trash; not visible to readers')
on conflict (comment_name) do nothing;
