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

tokens {
	EscapeStringConstant,
	UnterminatedEscapeStringConstant
}

//
// OPERATORS (§4.1.3)
//

// this rule does not allow + or - at the end of a multi-character operator
Operator
	:	(	OperatorCharacter
		|	(	'+'
			|	'-' {_input.LA(1) != '-'}?
			)+
			(	OperatorCharacter
			|	'/' {_input.LA(1) != '*'}?
			)
		|	'/' {_input.LA(1) != '*'}?
		)+
	|	// special handling for the single-character operators + and -
		[+-]
	;

/* This rule handles operators which end with + or -, and sets the token type to Operator. It is comprised of four
 * parts, in order:
 *
 *   1. A prefix, which does not contain a character from the required set which allows + or - to appear at the end of
 *      the operator.
 *   2. A character from the required set which allows + or - to appear at the end of the operator.
 *   3. An optional sub-token which takes the form of an operator which does not include a + or - at the end of the
 *      sub-token.
 *   4. A suffix sequence of + and - characters.
 */
OperatorEndingWithPlusMinus
	:	(	OperatorCharacterNotAllowPlusMinusAtEnd
		|	'-' {_input.LA(1) != '-'}?
		|	'/' {_input.LA(1) != '*'}?
		)*
		OpeartorCharacterAllowPlusMinusAtEnd
		Operator?
		(	'+'
		|	'-' {_input.LA(1) != '-'}?
		)+
		-> type(Operator)
	;

// Each of the following fragment rules omits the +, -, and / characters, which must always be handled in a special way
// by the operator rules above.

fragment
OperatorCharacter
	:	[*<>=~!@#%^&|`?]
	;

// these are the operator characters that don't count towards one ending with + or -
fragment
OperatorCharacterNotAllowPlusMinusAtEnd
	:	[*<>=+]
	;

// an operator may end with + or - if it contains one of these characters
fragment
OperatorCharacterAllowPlusMinusAtEnd
	:	[~!@#%^&|`?]
	;

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
BeginEscapeStringConstant
	:	[Ee] '\'' -> more, pushMode(EscapeStringConstantMode)
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

mode EscapeStringConstantMode;

	EndEscapeStringConstant
		:	EscapeStringText '\'' -> type(EscapeStringConstant), mode(AfterEscapeStringConstantMode)
		;

	EndUnterminatedEscapeStringConstant
		:	EscapeStringText
			// Handle a final unmatched \ character appearing at the end of the file
			'\\'?
			// Optional assertion to make sure this rule is working as intended
			{assert _input.LA(1) == EOF;}
			-> type(UnterminatedEscapeStringConstant)
		;

	fragment
	EscapeStringText
		:	(	'\'\''
			|	'\\' .
			|	~['\\]
			)*
		;

mode AfterEscapeStringConstantMode;

	AfterEscapeStringConstantMode_Whitespace
		:	Whitespace -> type(Whitespace)
		;

	AfterEscapeStringConstantMode_Newline
		:	Newline -> type(Newline), mode(AfterEscapeStringConstantWithNewlineMode)
		;

	AfterEscapeStringConstantMode_NotContinued
		:	// intentionally empty
			-> skip, popMode
		;

mode AfterEscapeStringConstantWithNewlineMode;

	AfterEscapeStringConstantWithNewlineMode_Whitespace
		:	Whitespace -> type(Whitespace)
		;

	AfterEscapeStringConstantWithNewlineMode_Newline
		:	Newline -> type(Newline)
		;

	AfterEscapeStringConstantWithNewlineMode_Continued
		:	'\'' -> more, mode(EscapeStringConstantMode)
		;

	AfterEscapeStringConstantWithNewlineMode_NotContinued
		:	// intentionally empty
			-> skip, popMode
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
