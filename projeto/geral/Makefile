update_ecr_image_insert_fake_data:
	terraform taint module.docker_image.null_resource.sam_metadata_docker_registry_image
	terraform taint module.docker_image.docker_registry_image.this
	terraform taint module.docker_image.docker_image.this
	terraform apply
