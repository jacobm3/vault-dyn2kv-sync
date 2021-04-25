# vault-dyn2kv-sync
POC shell script that syncs dynamic creds to KV paths. Allows easier migration from static to dynamic credentials.

# KV Setup

```
vault secrets enable -version=2 secret
vault kv put secret/app1/db1-5s username=foo password=bar
```
