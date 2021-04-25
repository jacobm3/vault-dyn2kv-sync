# vault-dyn2kv-sync
POC shell script that syncs dynamic creds to KV paths. Allows easier migration from static to dynamic credentials.

# KV Setup

```
vault secrets enable -version=2 secret
vault kv put secret/app1/db1 username=foo password=bar
```

# DB Setup

Using the Mysql plugin with the database secrets engine in this example.

```
mysql -uroot -proot <<EOF
DROP DATABASE IF EXISTS db1;
CREATE DATABASE db1;

use mysql;
DROP USER 'vault'@'%';
CREATE USER 'vault'@'%' IDENTIFIED BY 'vaultpass';
GRANT SUPER ON *.* to 'vault'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

echo "Creating db1 database"
mysql -uroot -proot <<EOF
create database if not exists db1;
USE db1;
CREATE TABLE IF NOT EXISTS tasks (
    task_id INT AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    start_date DATE,
    due_date DATE,
    status TINYINT NOT NULL,
    priority TINYINT NOT NULL,
    description TEXT,
    PRIMARY KEY (task_id)
)  ENGINE=INNODB;
CREATE TABLE IF NOT EXISTS users (
    task_id INT AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    start_date DATE,
    due_date DATE,
    status TINYINT NOT NULL,
    priority TINYINT NOT NULL,
    description TEXT,
    PRIMARY KEY (task_id)
)  ENGINE=INNODB;

```

```
echo "Enabling database secrets engine"
vault secrets enable database

echo "Writing db1 DB secrets engine config"
vault write database/config/db1 \
    plugin_name=mysql-database-plugin \
    connection_url="{{username}}:{{password}}@tcp(127.0.0.1:3306)/" \
    allowed_roles="db1-5s,db1-30s" \
    username="root" \
    password="root"

echo "Writing DB1 5s engine role"
vault write database/roles/db1-5s \
    db_name=db1 \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL ON db1.* TO '{{name}}'@'%';" \
    default_ttl="5s" \
    max_ttl="5s"

echo "Writing db1 policy"

vault policy write db1 -<<EOF
path "database/creds/db1-5s" {
  capabilities = ["read"]
}
EOF

```
