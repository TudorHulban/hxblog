-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 01. configuration - browser types
-- =====================================================

create table if not exists config_05_browsers (
    id          int2 generated always as identity primary key,
    name        text not null unique,
    description text
);

insert into config_05_browsers (name, description) values
    ('chrome',          'Google Chrome'),
    ('firefox',         'Mozilla Firefox'),
    ('safari',          'Apple Safari'),
    ('edge',            'Microsoft Edge (Chromium-based)'),
    ('opera',           'Opera Browser'),
    ('samsung',         'Samsung Internet Browser'),
    ('brave',           'Brave Browser'),
    ('ie',              'Internet Explorer (legacy)'),
    ('webview',         'Embedded WebView (in-app browser)'),
    ('curl',            'curl or wget — likely automated'),
    ('unknown',         'Browser could not be determined');