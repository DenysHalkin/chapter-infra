#!/bin/bash

cat <<'EOF' >> /etc/ecs/ecs.config
ECS_CLUSTER=${cluster_name}
ECS_LOGLEVEL=info
ECS_CONTAINER_INSTANCE_TAGS=${common_tags}
ECS_ENABLE_TASK_IAM_ROLE=true
EOF