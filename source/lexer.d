module lexer;

import tokenmodule;

class Lexer {
	string input;
	size_t column;
	size_t line;
	Token cur;

	this(string input) {
		this.input = input;
		this.column = 0UL;
		this.buildFront();
	}

	private bool isTokenStop() const {
		return this.column >= this.input.length 
			|| this.isTokenStop(this.input[this.column]);
	}

	private bool isTokenStop(const(char) c) const {
		return 
			c == ' ' || c == '\t' || c == '\n' || c == ';' || c == '(' 
			|| c == ')' || c == '{' || c == '}' || c == '&' || c == '!'
			|| c == '=' || c == '|' || c == '.' || c == '*' || c == '/'
			|| c == '%' || c == '[' || c == ']' || c == ',';
	}

	private void eatWhitespace() {
		import std.ascii : isWhite;
		while(this.column < this.input.length) {
			if(this.input[this.column] == ' ') {
				++this.column;
			} else if(this.input[this.column] == '\t') {
				++this.column;
			} else {
				break;
			}
		}
	}

	@property bool empty() const {
		return this.column == this.input.length 
			&& this.cur.type == TokenType.empty;
	}
	
	void buildFront() {
		import std.ascii : isAlpha, isDigit;
		this.eatWhitespace();
		size_t startPos = this.column;
		if(this.column >= this.input.length) {
			this.cur = Token(TokenType.empty, "");
			return;
		}
		switch(this.input[this.column]) {
			case '0': .. case '9':
				do {
					++this.column;
				} while(this.column < this.input.length &&
						isDigit(this.input[this.column]));
				
				if(this.column >= this.input.length
						|| this.input[this.column] != '.') 
				{
					this.cur = Token(TokenType.number, 
							this.input[startPos ..  this.column]
						);
					return;
				} else if(this.column < this.input.length
						&& this.input[this.column] == '.')
				{
					do {
						++this.column;
					} while(this.column < this.input.length &&
							isDigit(this.input[this.column]));

					this.cur = Token(TokenType.number,
							this.input[startPos ..  this.column]
						);
					return;
				}
				goto default;
			case 'a': .. case 'z': case 'A': .. case 'Z':
				do {
					++this.column;
				} while(this.column < this.input.length && 
						isAlpha(this.input[this.column])
					);
				this.cur = Token(TokenType.name, 
						this.input[startPos ..  this.column]
					);
				return;
			case '\\':
				do {
					++this.column;
				} while(this.column < this.input.length && 
						isAlpha(this.input[this.column])
					);
				string s = this.input[startPos .. this.column];
				if(s == "\\int") {
					this.cur = Token(TokenType.inte, "");
					return;
				} else if(s == "\\prod") {
					this.cur = Token(TokenType.prod, "");
					return;
				} else if(s == "\\frac") {
					this.cur = Token(TokenType.frac, "");
					return;
				}
				assert(false, s);
			case '^':
				++this.column;
				this.cur = Token(TokenType.pow, "");
				return;
			case ',':
				++this.column;
				this.cur = Token(TokenType.comma, "");
				return;
			case '%':
				++this.column;
				this.cur = Token(TokenType.mod, "");
				return;
			case '_':
				++this.column;
				this.cur = Token(TokenType.under, "");
				return;
			case '/':
				++this.column;
				this.cur = Token(TokenType.div, "");
				return;
			case '{':
				++this.column;
				this.cur = Token(TokenType.lcurly, "");
				return;
			case '}':
				++this.column;
				this.cur = Token(TokenType.rcurly, "");
				return;
			case '[':
				++this.column;
				this.cur = Token(TokenType.lbrack, "");
				return;
			case ']':
				++this.column;
				this.cur = Token(TokenType.rbrack, "");
				return;
			case '(':
				++this.column;
				this.cur = Token(TokenType.lparen, "");
				return;
			case ')':
				++this.column;
				this.cur = Token(TokenType.rparen, "");
				return;
			case '*':
				++this.column;
				this.cur = Token(TokenType.star, "");
				return;
			case '+':
				++this.column;
				this.cur = Token(TokenType.plus, "");
				return;
			case '=':
				++this.column;
				this.cur = Token(TokenType.equal, "");
				return;
			default:
				this.cur = Token(TokenType.empty, "");
				break;
		}
	}

	@property Token front() const {
		return this.cur;
	}

	void popFront() {
		this.buildFront();
	}
}

unittest {
	auto l = new Lexer("12379");
	assert(!l.empty);
	auto t = l.front;
	assert(t.type == TokenType.number);
	assert(t.value == "12379");
	l.popFront();
	assert(l.empty);
}

unittest {
	auto l = new Lexer("123.79");
	assert(!l.empty);
	auto t = l.front;
	assert(t.type == TokenType.number);
	assert(t.value == "123.79", t.value);
	l.popFront();
	assert(l.empty);
}

unittest {
	auto l = new Lexer("=");
	assert(!l.empty);
	auto t = l.front;
	assert(t.type == TokenType.equal);
	l.popFront();
	assert(l.empty);
}

unittest {
	auto l = new Lexer("hello");
	assert(!l.empty);
	auto t = l.front;
	assert(t.type == TokenType.name);
	assert(t.value == "hello");
	l.popFront();
	assert(l.empty);
}

unittest {
	auto l = new Lexer("=hello");
	assert(!l.empty);
	auto t = l.front;
	assert(t.type == TokenType.equal);
	l.popFront();
	assert(!l.empty);
	t = l.front;
	assert(t.type == TokenType.name);
	assert(t.value == "hello");
	l.popFront();
	assert(l.empty);
}

unittest {
	auto l = new Lexer("123.79hello");
	assert(!l.empty);
	auto t = l.front;
	assert(t.type == TokenType.number);
	assert(t.value == "123.79", t.value);
	l.popFront();
	assert(!l.empty);
	t = l.front;
	assert(t.type == TokenType.name);
	assert(t.value == "hello", t.value);
	l.popFront();
	assert(l.empty);
}

unittest {
	auto l = new Lexer("12379hello");
	assert(!l.empty);
	auto t = l.front;
	assert(t.type == TokenType.number);
	assert(t.value == "12379", t.value);
	l.popFront();
	assert(!l.empty);
	t = l.front;
	assert(t.type == TokenType.name);
	assert(t.value == "hello", t.value);
	l.popFront();
	assert(l.empty);
}

unittest {
	import std.format : format;
	auto ts = [
			TokenType.frac, 
			TokenType.lcurly, 
			TokenType.name, 
			TokenType.rcurly, 
			TokenType.lcurly, 
			TokenType.number, 
			TokenType.rcurly
		];
	auto l = new Lexer("\\frac{name}{122.3}");
	foreach(t; ts) {
		assert(!l.empty);
		assert(l.front.type == t, format("%s == %s", l.front.type, t));
		l.popFront();
	}
}
