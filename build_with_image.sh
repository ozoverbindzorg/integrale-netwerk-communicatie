#plantuml -o ../images/ -tsvg ./input/images-source/*.plantuml
gofsh --useFHIRVersion=4.0.1 examples/ --out input/fsh/

export IMAGE_NAME=registry.gitlab.com/headease/ozo-refererence-impl/headease-ig-builder/main:latest
docker pull $IMAGE_NAME
mkdir -p mkdir ./public
docker run --rm  -v "${PWD}/input:/workspace/input" -v "${PWD}/public:/workspace/output" -v "${PWD}/ig.ini:/workspace/ig.ini" -v "${PWD}/sushi-config.yaml:/workspace/sushi-config.yaml" $IMAGE_NAME
open public/index.html
