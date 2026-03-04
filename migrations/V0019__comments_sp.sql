create or replace procedure hx_create_comment(
    p_id              bigint,
    p_post_id         bigint,
    p_content         text,
    p_parent_id       bigint default null,
    p_user_id         bigint default null,
    p_author_name     varchar default null,
    p_author_email    varchar default null,
    p_author_url      varchar default null,
    p_author_ip       inet default null
)
language plpgsql
as $$
begin
    insert into "30_comments" (
        id,
        post_id,
        parent_id,
        user_id,
        author_name,
        author_email,
        author_url,
        author_ip,
        content
    )
    values (
        p_id,
        p_post_id,
        p_parent_id,
        p_user_id,
        p_author_name,
        p_author_email,
        p_author_url,
        p_author_ip,
        p_content
    );
end;
$$;

-- call create_comment(
--     1001,
--     55,
--     'nice post!',
--     null,
--     42,
--     'john doe',
--     'john@example.com',
--     null,
--     '192.168.1.10'
-- );


create or replace procedure hx_approve_comment(
    p_comment_id bigint
)
language plpgsql
as $$
begin
    update
	"30_comments"
set
	status_id = 2,
	report_count = 0,
	updated_at = extract(epoch from now())
where
	id = p_comment_id;
end;
$$;


create or replace procedure hx_reject_comment(
    p_comment_id bigint
)
language plpgsql
as $$
begin
    update "30_comments"
    set status_id = 3,
        updated_at = extract(epoch from now())
    where id = p_comment_id;
end;
$$;


create or replace procedure hx_mark_comment_spam(
    p_comment_id bigint
)
language plpgsql
as $$
begin
    update "30_comments"
    set status_id = 4,
        updated_at = extract(epoch from now())
    where id = p_comment_id;
end;
$$;


create or replace procedure hx_delete_comment(
    p_comment_id bigint
)
language plpgsql
as $$
declare
    v_timestamp bigint;
begin
    v_timestamp := extract(epoch from now());
update
	"30_comments"
set
	status_id = 5,
	updated_at = v_timestamp,
	deleted_at = v_timestamp
where
	id = p_comment_id;
end;
$$;


create or replace procedure hx_reset_comment_pending(
    p_comment_id bigint
)
language plpgsql
as $$
begin
    update "30_comments"
    set status_id = 1,
        updated_at = extract(epoch from now())
    where id = p_comment_id;
end;
$$;


create or replace procedure hx_like_comment(
    p_comment_id bigint
)
language plpgsql
as $$
begin
    update
	"30_comments"
set
	like_count = like_count + 1,
	updated_at = extract(epoch from now())
where
	id = p_comment_id;
end;
$$;


create or replace procedure hx_dislike_comment(
    p_comment_id bigint
)
language plpgsql
as $$
begin
    update
	"30_comments"
set
	dislike_count = dislike_count + 1,
	updated_at = extract(epoch from now())
where
	id = p_comment_id;
end;
$$;


create or replace procedure hx_report_comment(
    p_comment_id bigint
)
language plpgsql
as $$
declare
    v_timestamp bigint;
    v_new_count integer;
begin
    v_timestamp := extract(epoch from now());
update
	"30_comments"
set
	report_count = report_count + 1,
	updated_at = v_timestamp
where
	id = p_comment_id
    returning report_count into	v_new_count;

if v_new_count >= 3 then
        update
	"30_comments"
set
	status_id = 4,
	updated_at = v_timestamp
where
	id = p_comment_id;
end if;
end;
$$;


create or replace procedure hx_moderate_comment(
    p_comment_id bigint,
    p_status_id smallint,
    p_moderation_reason text default null,
    p_moderated_by bigint default null
)
language plpgsql
as $$
declare
    v_timestamp bigint;
begin
    v_timestamp := extract(epoch from now());

if p_status_id = 2 then -- approved: clear reports
        update
	"30_comments"
set
	status_id = p_status_id,
	report_count = 0,
	moderation_reason = p_moderation_reason,
	moderated_by = p_moderated_by,
	moderated_at = v_timestamp,
	updated_at = v_timestamp
where
	id = p_comment_id;
else -- any other status: keep report_count as-is
    update
	"30_comments"
set
	status_id = p_status_id,
	moderation_reason = p_moderation_reason,
	moderated_by = p_moderated_by,
	moderated_at = v_timestamp,
	updated_at = v_timestamp
where
	id = p_comment_id;
end if;
end;
$$;
