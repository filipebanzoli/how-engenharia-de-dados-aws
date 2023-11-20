module.docker_image.docker_image.this: Still creating... [19m0s elapsed]
module.docker_image.docker_image.this: Still creating... [19m10s elapsed]
module.docker_image.docker_image.this: Still creating... [19m20s elapsed]
╷
│ Error: local-exec provisioner error
│
│   with null_resource.transactional_database_setup,
│   on main.tf line 113, in resource "null_resource" "transactional_database_setup":
│  113:   provisioner "local-exec" {
│
│ Error running command 'psql -h
│ transactional.cyiq4kbmfc2d.us-west-2.rds.amazonaws.com -p 5432 -U     
│ postgres -d transactional -f
│ ./sources/transactional_database/prepare_database/terraform_prepare_database.sql
│ -v user=fake_data_app -v password='ukPOzl6Q!sKYpFQq'': exit status    
│ 127. Output: /bin/sh: 1: psql: not found
│
╵
╷
│ Error: executor failed running [/bin/sh -c pip install --no-cache-dir -r requirements.txt]: exit code: 1
│
│
│
│   with module.docker_image.docker_image.this,
│   on .terraform/modules/docker_image/modules/docker-build/main.tf line 12, in resource "docker_image" "this":
│   12: resource "docker_image" "this" {
│