module lexer;

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
	div,
	plus,
	minus,
	equal,
	inte,
	prod,
	frac,
}

struct Token {
	TokenType type;
	string value;
}

class Lexer {
	string input;
	size_t col;
	Token cur;

	this(string input) {
		this.input = input;
		this.col = 0UL;
		this.buildFront();
	}

	private bool isTokenStop() const {
		return this.col >= this.input.length 
			|| this.isTokenStop(this.input[this.col]);
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
		while(this.col < this.input.length) {
			if(this.input[this.col] == ' ') {
				++this.col;
			} else if(this.input[this.col] == '\t') {
				++this.col;
			} else {
				break;
			}
			++this.col;
		}
	}

	@property bool empty() const {
		return this.col == this.input.length 
			&& this.cur.type == TokenType.empty;
	}
	
	void buildFront() {
		import std.ascii : isAlpha, isDigit;
		size_t startPos = this.col;
		if(this.col >= this.input.length) {
			this.cur = Token(TokenType.empty, "");
			return;
		}
		switch(this.input[this.col]) {
			case '0': .. case '9':
				do {
					++this.col;
				} while(this.col < this.input.length &&
						isDigit(this.input[this.col]));
				
				if(this.col >= this.input.length
						|| this.input[this.col] != '.') 
				{
					this.cur = Token(TokenType.number, 
							this.input[startPos ..  this.col]
						);
					return;
				} else if(this.col < this.input.length
						&& this.input[this.col] == '.')
				{
					do {
						++this.col;
					} while(this.col < this.input.length &&
							isDigit(this.input[this.col]));

					this.cur = Token(TokenType.number,
							this.input[startPos ..  this.col]
						);
					return;
				}
				goto default;
			case 'a': .. case 'z': case 'A': .. case 'Z':
				do {
					++col;
				} while(this.col < this.input.length && 
						isAlpha(this.input[this.col])
					);
				this.cur = Token(TokenType.name, 
						this.input[startPos ..  this.col]
					);
				return;
			case '\\':
				do {
					++this.col;
				} while(this.col < this.input.length && 
						isAlpha(this.input[this.col])
					);
				string s = this.input[startPos .. this.col];
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
				++this.col;
				this.cur = Token(TokenType.pow, "");
				return;
			case '_':
				++this.col;
				this.cur = Token(TokenType.under, "");
				return;
			case '/':
				++this.col;
				this.cur = Token(TokenType.div, "");
				return;
			case '{':
				++this.col;
				this.cur = Token(TokenType.lcurly, "");
				return;
			case '}':
				++this.col;
				this.cur = Token(TokenType.rcurly, "");
				return;
			case '[':
				++this.col;
				this.cur = Token(TokenType.lbrack, "");
				return;
			case ']':
				++this.col;
				this.cur = Token(TokenType.rbrack, "");
				return;
			case '(':
				++this.col;
				this.cur = Token(TokenType.lparen, "");
				return;
			case ')':
				++this.col;
				this.cur = Token(TokenType.rparen, "");
				return;
			case '*':
				++this.col;
				this.cur = Token(TokenType.star, "");
				return;
			case '+':
				++this.col;
				this.cur = Token(TokenType.plus, "");
				return;
			case '=':
				++this.col;
				this.cur = Token(TokenType.equal, "");
				return;
			default:
				this.cur = Token(TokenType.empty, "");
				break;
		}
	}

	@property Token front() {
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
