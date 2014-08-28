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
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.atn.ATN;
import org.antlr.v4.runtime.atn.LexerATNSimulator;
import org.antlr.v4.runtime.atn.PredictionContextCache;
import org.antlr.v4.runtime.dfa.DFA;
import org.antlr.v4.runtime.dfa.DFAState;
import org.antlr.v4.runtime.misc.Interval;
import org.antlr.v4.runtime.misc.NotNull;

/**
 * @author Sam Harwell
 */
public class PostgreSqlLexerAtnSimulator extends LexerATNSimulator {

	public PostgreSqlLexerAtnSimulator(Lexer lexer, @NotNull ATN atn, @NotNull DFA[] decisionToDFA, @NotNull PredictionContextCache sharedContextCache) {
		super(lexer, atn, decisionToDFA, sharedContextCache);
	}

	@Override
	protected int execATN(CharStream input, DFAState ds0) {
		// This works around bug #688 in the ANTLR 4 runtime where zero-length
		// tokens are not recognized.
		if (ds0.isAcceptState) {
			captureSimState(prevAccept, new InputWithFixedIndex(input.index() - 1), ds0);
		}

		return super.execATN(input, ds0);
	}

	private static final class InputWithFixedIndex implements CharStream {
		private final int _index;

		public InputWithFixedIndex(int index) {
			this._index = index;
		}

		@Override
		public int index() {
			return _index;
		}

		@Override
		public String getText(Interval interval) {
			throw new UnsupportedOperationException("Not supported.");
		}

		@Override
		public void consume() {
			throw new UnsupportedOperationException("Not supported.");
		}

		@Override
		public int LA(int i) {
			throw new UnsupportedOperationException("Not supported.");
		}

		@Override
		public int mark() {
			throw new UnsupportedOperationException("Not supported.");
		}

		@Override
		public void release(int marker) {
			throw new UnsupportedOperationException("Not supported.");
		}

		@Override
		public void seek(int index) {
			throw new UnsupportedOperationException("Not supported.");
		}

		@Override
		public int size() {
			throw new UnsupportedOperationException("Not supported.");
		}

		@Override
		public String getSourceName() {
			throw new UnsupportedOperationException("Not supported.");
		}
	}
}
