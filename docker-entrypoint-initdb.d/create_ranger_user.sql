DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = 'rangeradmin') THEN

      CREATE ROLE rangeradmin LOGIN PASSWORD 'your_strong_password' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION VALID UNTIL 'infinity';
   END IF;
END
$do$;