.PHONY: build
build:
	docker buildx build -t ansible-target .


.PHONY: run
run:
	docker run -d --name=ansible-target -p 20022:22 ansible-target


.PHONY: exec
exec:
	docker exec -it ansible-target /bin/bash


.PHONY: test
test:
	ssh -o StrictHostKeyChecking=accept-new -l testuser -i ./key-pair/id_rsa localhost -p 20022


.PHONY: clean
clean:
	docker rm -f ansible-target
	ssh-keygen -f ~/.ssh/known_hosts -R '[localhost]:20022'


.PHONY: cbuild
cbuild:
	docker compose build


.PHONY: crun
crun:
	docker compose up -d


.PHONY: cexecs
cexecs:
	docker compose exec -it --user testuser server /bin/bash


.PHONY: cexect
cexect:
	docker compose exec -it terminal /bin/bash


.PHONY: cclean
cclean:
	docker compose down
