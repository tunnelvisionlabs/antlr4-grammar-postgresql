/*
 *  Copyright (c) 2014 Sam Harwell, Tunnel Vision Laboratories LLC
 *  All rights reserved.
 * 
 *  The source code of this document is proprietary work, and is not licensed for
 *  distribution or use. For information about licensing, contact Sam Harwell at:
 *      sam@tunnelvisionlabs.com
 */
lexer grammar PostgreSqlLexer;

@members {
/* This field stores the tags which are used to detect the end of a dollar-quoted string literal.
 */
private final Deque<String> _tags = new ArrayDeque<String>();
}

//
// CONSTANTS (§4.1.2)
//

// String Constants (§4.1.2.1)
StringConstant
	:	UnterminatedStringConstant '\''
	;

UnterminatedStringConstant
	:	'\''
		(	'\'\''
		|	~'\''
		)*
	;

// String Constants with C-style Escapes (§4.1.2.2)
EscapeStringConstant
	:	UnterminatedEscapeStringConstant '\''
	;

// TODO: handle this with a lexer mode so they appear in the same manner as String Constants
UnterminatedEscapeStringConstant
	:	[Ee] '\''
		(	'\'\''
		|	// Bizarre rule for line-continuations, where continuations do not require duplication of the [Ee] prefix.
			'\'' Whitespace? (Newline Whitespace?)+ '\''
		|	'\\\''
		|	'\\' (~'\'' | EOF)
		|	~['\\]
		)*
	;

// String Constants with Unicode Escapes (§4.1.2.3)
//
//   Note that escape sequences are never checked as part of this token due to the ability of users to change the escape
//   character with a UESCAPE clause following the Unicode string constant.
//
// TODO: these rules assume '' is still a valid escape sequence within a Unicode string constant.
UnicodeEscapeStringConstant
	:	UnterminatedUnicodeEscapeStringConstant '\''
	;

UnterminatedUnicodeEscapeStringConstant
	:	[Uu] '&' UnterminatedStringConstant
	;

// Dollar-quoted String Constants (§4.1.2.4)
BeginDollarStringConstant
	:	'$' Tag? '$' {_tags.push(getText());}
		-> pushMode(DollarQuotedStringMode)
	;

// Bit-strings Constants (§4.1.2.5)
BinaryStringConstant
	:	UnterminatedBinaryStringConstant '\''
	;

UnterminatedBinaryStringConstant
	:	[Bb] '\'' [01]*
	;

InvalidBinaryStringConstant
	:	InvalidUnterminatedBinaryStringConstant '\''
	;

InvalidUnterminatedBinaryStringConstant
	:	[Bb] UnterminatedStringConstant
	;

HexadecimalStringConstant
	:	UnterminatedHexadecimalStringConstant '\''
	;

UnterminatedHexadecimalStringConstant
	:	[Xx] '\'' [0-9a-fA-F]*
	;

InvalidHexadecimalStringConstant
	:	InvalidUnterminatedHexadecimalStringConstant '\''
	;

InvalidUnterminatedHexadecimalStringConstant
	:	[Xx] UnterminatedStringConstant
	;

// Numeric Constants (§4.1.2.6)
Integral
	:	Digits
	;

Numeric
	:	Digits '.' Digits? ([Ee] [+-]? Digits)?
	|	'.' Digits ([Ee] [+-]? Digits)?
	|	Digits [Ee] [+-]? Digits
	;

fragment
Digits
	:	[0-9]+
	;

//
// WHITESPACE (§4.1?)
//

Whitespace
	:	[ \t]+
	;

Newline
	:	'\r' '\n'?
	|	'\n'
	;

//
// COMMENTS (§4.1.5)
//

LineComment
	:	'--' ~[\r\n]*
	;

BlockComment
	:	'/*'
		(	'/'* BlockComment
		|	~[/*]
		|	'/'+ ~[/*]
		|	'*'+ ~[/*]
		)*
		'*'*
		'*/'
	;

UnterminatedBlockComment
	:	'/*'
		(	'/'* BlockComment
		|	// these characters are not part of special sequences in a block comment
			~[/*]
		|	// handle / or * characters which are not part of /* or */ and do not appear at the end of the file
			(	'/'+ ~[/*]
			|	'*'+ ~[/*]
			)
		)*
		// Handle the case of / or * characters at the end of the file, or a nested unterminated block comment
		(	'/'+
		|	'*'+
		|	'/'* UnterminatedBlockComment
		)?
		// Optional assertion to make sure this rule is working as intended
		{assert _input.LA(1) == EOF;}
	;

//
// ERROR
//

// Any character which does not match one of the above rules will appear in the token stream as an ErrorCharacter token.
// This ensures the lexer itself will never encounter a syntax error, so all error handling may be performed by the
// parser.
ErrorCharacter
	:	.
	;

mode DollarQuotedStringMode;

	Text
		:	~'$'+
		|	// this alternative improves the efficiency of handling $ characters within a dollar-quoted string which are
			// not part of the ending tag.
			'$' ~'$'*
		;

	EndDollarStringConstant
		:	'$' Tag? '$' {getText().equals(_tags.peek())}?
			{_tags.pop()}
			-> popMode
		;
