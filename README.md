# hxblog

## Migrations

Get all tables names:

```sql
SELECT tablename
FROM pg_tables
WHERE schemaname = current_schema();
```

Get all server side objects names:

```sql
SELECT proname,
       p.prokind,
       pg_get_functiondef(p.oid) AS definition
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = current_schema()
  AND proname LIKE 'hx_%'
ORDER BY proname;
```

## Partitions

Check partitions with

```sql
select
    inhrelid::regclass as partition_name
from pg_inherits
where inhparent = 'table-name'::regclass
order by 1;
```

or with boundaries

```sql
select
    relname as partition_name,
    pg_get_expr(relpartbound, oid) as partition_range
from pg_class
where relkind = 'p'
  and relname like 'metrics_03_posts_views_%'
order by relname;
```

## Security

Target is that app user should only have rights to call stored procedures.

```sql
revoke all on schema domain from public;

grant execute on all procedures in schema api to blog_app;

or

revoke all on all tables in schema public from blog_app;
grant execute on procedure hx_create_user(...) to blog_app;
```
