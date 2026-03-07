-- =====================================================
-- database: hxblog
-- postgresql 18+
--
-- 04. security - audit
-- =====================================================

create table if not exists secu_02_audit (
    id int8 not null,
    day_date date not null,
    user_id int8, -- user_id null for unidentified requests
    payload jsonb,
    operation_id int2 not null references secu_01_operations(id) on delete set null,
    ip_address inet,
    browser int2 not null references config_05_browsers(id) on delete set null,
    result bool not null
)
partition by range (day_date);

create index idx_secu_audit_user_ops on secu_02_audit (user_id, operation_id); 
create index idx_secu_audit_user on secu_02_audit (user_id); 
create index idx_secu_audit_op on secu_02_audit (operation_id); 


-- call it by select create_post_views_partitions(30);
create or replace function create_audit_partitions(days_ahead int)
returns void
language plpgsql
as $$
declare
    d date := current_date;
    i int;
    part_name text;
begin
    for i in 0..days_ahead loop
        part_name := 'secu_02_audit' || to_char(d + i, 'yyyymmdd');

        execute format(
            'create table if not exists %I
             partition of secu_02_audit
             for values from (%L) to (%L);',
            part_name,
            d + i,
            d + i + 1
        );
    end loop;
end;
$$;

create or replace procedure create_audit(
    p_id int8,
    p_user_id int8,
    p_payload jsonb,
    p_operation_id int2,
    p_ip_address inet,
    p_result bool
)
language plpgsql
as $$
begin
    insert into secu_02_audit (
    id,
	user_id,
	payload,
	operation_id,
	ip_address,
	result
)
values (
p_id,
p_user_id,
p_payload,
p_operation_id,
p_ip_address,
p_result
);
end;
$$;