#	Makefile for EQL

default:
	ocamlbuild src/run.native

run:
	./run.native

clean: 
	rm -f run.native
	rm -r _build
