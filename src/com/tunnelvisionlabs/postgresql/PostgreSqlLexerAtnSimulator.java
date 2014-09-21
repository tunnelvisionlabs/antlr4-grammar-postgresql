/*
 * [The "MIT license"]
 * Copyright © 2014 Sam Harwell, Tunnel Vision Laboratories, LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * 1. The above copyright notice and this permission notice shall be included in
 *    all copies or substantial portions of the Software.
 * 2. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *    THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 *    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 *    DEALINGS IN THE SOFTWARE.
 * 3. Except as contained in this notice, the name of Tunnel Vision
 *    Laboratories, LLC. shall not be used in advertising or otherwise to
 *    promote the sale, use or other dealings in this Software without prior
 *    written authorization from Tunnel Vision Laboratories, LLC.
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
