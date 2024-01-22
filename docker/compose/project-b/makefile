
RUN_ARGS:= $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(RUN_ARGS):;@:)

SHELL:= /bin/bash

MAKEFLAGS += --silent

# functions

define checkArgs =
@[ -z "$(RUN_ARGS)" ] && echo Please provide arg && exit 1
endef

# targets
.PHONY: default
default: 
	-@$(call checkArgs);

shared:
	-@$(call checkArgs);

.PHONY: git
git:
	./maketools/git.sh $(RUN_ARGS)

.PHONY: docker-base
docker-base:
	./maketools/docker.sh

.PHONY: docker
docker: docker-base
ifeq ($(findstring prune,$(RUN_ARGS)),prune)
	-@($(MAKE) -s docker-compose-prune)
else ifeq ($(findstring ps,$(RUN_ARGS)),ps)
	-@($(MAKE) -s docker-compose-ps)
else ifeq ($(findstring upd,$(RUN_ARGS)),upd)
	-@($(MAKE) -s docker-compose-upd $(RUN_ARGS)) 
else ifeq ($(findstring sh,$(RUN_ARGS)),sh)
	-@($(MAKE) -s docker-compose-sh $(RUN_ARGS)) 
endif


.PHONY: docker-compose-prune
docker-compose-prune: 
	-@(. ./maketools/log.sh; log "INFO" "[TARGET: docker-compose-prune]")
	-@(docker stop $(shell docker ps -aq) &>/dev/null || true)
	-@(docker system prune -a -f  &>/dev/null)
#	-@(docker rmi $(shell docker images --filter "dangling=true" -q --no-trunc))
	-@(docker rm -f $(shell docker container ls -a -q) &>/dev/null)
#	-@(docker image prune -f  &>/dev/null)
	-@(docker volume rm $(shell docker volume ls -q) &>/dev/null || true)

.PHONY: docker-compose-ps
docker-compose-ps: 
	-@(. ./maketools/log.sh; log "INFO" "[TARGET: docker-compose-ps]")
	-@(docker-compose ps)
	-@(. ./maketools/log.sh; log "SEPARATOR"; )

.PHONY: docker-compose-upd 
docker-compose-upd: 
	-@(. ./maketools/log.sh; log "INFO" "[TARGET: docker-compose-upa]")
	-@(docker-compose up -d --no-deps --build `echo $(RUN_ARGS) | sed 's/upd//'`)
	-@(. ./maketools/log.sh; log "SEPARATOR"; )

.PHONY: docker-compose-sh 
docker-compose-sh: 
	-@(. ./maketools/log.sh; log "INFO" "[TARGET: docker-compose-sh]")
	-@(docker-compose exec `echo $(RUN_ARGS) | sed 's/^.* //g'` /bin/bash)
	-@(. ./maketools/log.sh; log "SEPARATOR"; )
