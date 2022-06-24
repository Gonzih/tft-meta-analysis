include ./Makefile.DOCKER
include ./Makefile.CACHE
include ./Makefile.GIT

JULIA := env $(shell cat .env) julia

pluto:
	cd notebooks && $(JULIA) scripts/pluto.jl

scrape:
	cd notebooks && $(JULIA) scripts/scrape.jl

export:
	cd notebooks && $(JULIA) scripts/export.jl

export-notebooks:
	cd notebooks && $(JULIA) scripts/export_notebooks.jl

server:
	cd notebooks && $(JULIA) scripts/server.jl

setup-julia:
	yes | sudo pip install jill
	jill install --confirm
