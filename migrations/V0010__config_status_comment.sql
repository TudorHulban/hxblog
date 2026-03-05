-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 01. configuration - comment status
-- =====================================================

create table if not exists config_09_comment_statuses (
    id int2 generated always as identity primary key,
    comment_name varchar(50) not null unique,
    description text
);

insert into config_09_comment_statuses (comment_name, description) values
    ('pending',  'Comment submitted and awaiting moderation; not visible to readers'),
    ('approved', 'Comment approved by moderators and visible to readers'),
    ('rejected', 'Comment reviewed and not approved; not visible to readers'),
    ('spam',     'Comment flagged as spam; not visible to readers'),
    ('trash',    'Comment deleted or moved to trash; not visible to readers')
on conflict (comment_name) do nothing;
