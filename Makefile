#	Makefile for EQL

default:
	ocamlbuild src/run.native

run:
	./run.native

clean: 
	rm -f run.native
	rm -r _build

repl:
	OCAMLRUNPARAM=b dune exec bin/repl.exe

test:
	OCAMLRUNPARAM=b dune exec test/main.exe

build:
	dune build
	
zip:
	rm -f eql.zip
	zip -r eql.zip . -x@exclude.lst