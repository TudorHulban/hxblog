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
