-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 02. users subscribed to newsletter and campaigns
-- =====================================================

create table if not exists users_newsletters (
    user_id int8 references users(id) primary key,

    subscribed_at int8 not null,
    unsubscribed_at int8,

    categories int8[],
    frequency_days int2,
    last_sent int8,

    updated_at int8
);

create table if not exists users_newsletters_campaigns (
    id int8 primary key,
    title text NOT NULL,
    subject text NOT NULL,
    content text NOT NULL,

    target_categories int8[],
    scheduled_at int8,

    recipient_count int8 DEFAULT 0,
    updated_at int8
);