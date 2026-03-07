create table if not exists secu_02_audit (
    id int8 primary key,
    user_id int8, -- user_id null for unidentified requests
    payload jsonb,
    operation_id int2 not null references secu_01_operations(id) on delete set null,
    ip_address inet,
    browser int2 not null references config_05_browsers(id) on delete set null,
    result bool not null
);

create index idx_secu_audit_user_ops on secu_02_audit (user_id, operation_id); 
create index idx_secu_audit_user on secu_02_audit (user_id); 
create index idx_secu_audit_op on secu_02_audit (operation_id); 

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