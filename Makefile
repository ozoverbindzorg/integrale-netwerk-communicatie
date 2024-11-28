update-examples:
	gofsh --useFHIRVersion=4.0.1 examples/ --out input/fsh/


IMAGE_NAME ?= "registry.gitlab.com/headease/ozo-refererence-impl/headease-ig-builder/main:latest"
build:
	docker pull "${IMAGE_NAME}"
	mkdir -p mkdir ./public
	docker run --rm  -v "${PWD}/input:/workspace/input" -v "${PWD}/public:/workspace/output" -v "${PWD}/ig.ini:/workspace/ig.ini" -v "${PWD}/sushi-config.yaml:/workspace/sushi-config.yaml" "${IMAGE_NAME}"
