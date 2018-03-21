all: build

build:
	docker build -t docker.io/lsstsqre/ec2-snapshot:latest .
