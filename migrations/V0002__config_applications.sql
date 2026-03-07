-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 01. configuration - applications
-- =====================================================

create table if not exists config_01_applications (
    id int2 generated always as identity primary key,
    code char(16) not null unique,
    description text not null
);

comment on table config_01_applications is 'stores application/microservices names';


insert into config_01_applications (code, description) values
('blog', 'tara blog');