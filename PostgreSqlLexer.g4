/*
 *  Copyright (c) 2014 Sam Harwell, Tunnel Vision Laboratories LLC
 *  All rights reserved.
 * 
 *  The source code of this document is proprietary work, and is not licensed for
 *  distribution or use. For information about licensing, contact Sam Harwell at:
 *      sam@tunnelvisionlabs.com
 */
lexer grammar PostgreSqlLexer;

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
