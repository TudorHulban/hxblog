-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 01. configuration - os types
-- =====================================================

create table if not exists config_04_operating_systems (
    id          int2 generated always as identity primary key,
    name        varchar(50) not null unique,
    description varchar(255)
);

insert into config_04_operating_systems (name, description) values
    ('windows_11',    'Microsoft Windows 11'),
    ('windows_10',    'Microsoft Windows 10'),
    ('windows_legacy','Microsoft Windows 7/8/8.1'),
    ('macos',         'Apple macOS (desktop)'),
    ('ios',           'Apple iOS (iPhone/iPad)'),
    ('android',       'Google Android'),
    ('linux',         'Linux desktop distributions'),
    ('chrome_os',     'Google ChromeOS'),
    ('ubuntu',        'Ubuntu Linux'),
    ('unknown',       'OS could not be determined');