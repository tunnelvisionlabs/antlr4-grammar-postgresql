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
package com.tunnelvisionlabs.postgresql.test;

import com.tunnelvisionlabs.postgresql.PostgreSqlLexer;
import com.tunnelvisionlabs.postgresql.PostgreSqlLexerUtils;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.Token;
import org.junit.Assert;
import org.junit.Test;

/**
 * @author Sam Harwell
 */
public class BasicTests {

	@Test
	public void TestSampleInputs() throws IOException {
		String input = loadSample("information_schema.sql", "UTF-8");

		PostgreSqlLexer lexer = PostgreSqlLexerUtils.createLexer(new ANTLRInputStream(input));

		CommonTokenStream tokens = new CommonTokenStream(lexer);
		tokens.fill();

		Token previousToken = null;
		for (Token token : tokens.getTokens()) {
			if (previousToken != null) {
				Assert.assertEquals(previousToken.getStopIndex() + 1, token.getStartIndex());
			}

			Assert.assertNotEquals(PostgreSqlLexer.ErrorCharacter, token.getType());
			previousToken = token;
		}

		Assert.assertEquals(Lexer.DEFAULT_MODE, lexer._mode);
		Assert.assertTrue(lexer._modeStack.isEmpty());
	}

	protected String loadSample(String fileName, String encoding) throws IOException
	{
		if ( fileName==null ) {
			return null;
		}

		String fullFileName = "samples/" + fileName;
		int size = 1024 * 1024;
		InputStreamReader isr;
		InputStream fis = getClass().getClassLoader().getResourceAsStream(fullFileName);
		if ( encoding!=null ) {
			isr = new InputStreamReader(fis, encoding);
		}
		else {
			isr = new InputStreamReader(fis);
		}
		try {
			char[] data = new char[size];
			int n = isr.read(data);
			return new String(data, 0, n);
		}
		finally {
			isr.close();
		}
	}

}
