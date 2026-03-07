-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 01. configuration - device types
-- =====================================================

create table if not exists config_03_device_types (
    id          int2 generated always as identity primary key,
    name        text not null unique,
    description text
);

insert into config_03_device_types (name, description) values
    ('desktop',    'Traditional desktop or tower computer'),
    ('laptop',     'Portable personal computer with integrated screen'),
    ('tablet',     'Touchscreen device larger than a phone'),
    ('mobile',     'Smartphone or handheld mobile device'),
    ('smart_tv',   'Internet-connected television'),
    ('console',    'Gaming console with browser capability'),
    ('wearable',   'Smartwatch or wearable device'),
    ('bot',        'Crawler, scraper, or automated agent'),
    ('unknown',    'Device type could not be determined');