all:
	../Darser/darser -i grammar.yaml -a source/ast.d \
		-p source/parser.d \
		-v source/visitor.d \
		-e source/exception.d
