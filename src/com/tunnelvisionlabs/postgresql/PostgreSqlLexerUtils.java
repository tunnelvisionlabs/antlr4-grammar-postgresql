/*
 *  Copyright (c) 2014 Sam Harwell, Tunnel Vision Laboratories LLC
 *  All rights reserved.
 * 
 *  The source code of this document is proprietary work, and is not licensed for
 *  distribution or use. For information about licensing, contact Sam Harwell at:
 *      sam@tunnelvisionlabs.com
 */
package com.tunnelvisionlabs.postgresql;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.atn.LexerATNSimulator;

/**
 * @author Sam Harwell
 */
public class PostgreSqlLexerUtils {

	public static PostgreSqlLexer createLexer(CharStream input) {
		PostgreSqlLexer lexer = new PostgreSqlLexer(input);

		// Use the custom LexerATNSimulator to work around known bugs
		LexerATNSimulator interpreter = lexer.getInterpreter();
		interpreter = new PostgreSqlLexerAtnSimulator(lexer, interpreter.atn, interpreter.decisionToDFA, interpreter.getSharedContextCache());
		lexer.setInterpreter(interpreter);

		return lexer;
	}

	private PostgreSqlLexerUtils() {
	}
}
