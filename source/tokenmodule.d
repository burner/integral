module tokenmodule;

import visitor;

enum TokenType {
	empty,
	number,
	name,
	pow,
	lparen,
	rparen,
	lcurly,
	under,
	rcurly,
	lbrack,
	rbrack,
	star,
	sum,
	infty,
	div,
	plus,
	mod,
	minus,
	equal,
	comma,
	inte,
	prod,
	frac,
}

struct Token {
	TokenType type;
	string value;

	void visit(Visitor vis) {
	}

	void visit(Visitor vis) const {
	}
}
