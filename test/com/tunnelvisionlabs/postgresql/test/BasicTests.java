/*
 *  Copyright (c) 2014 Sam Harwell, Tunnel Vision Laboratories LLC
 *  All rights reserved.
 * 
 *  The source code of this document is proprietary work, and is not licensed for
 *  distribution or use. For information about licensing, contact Sam Harwell at:
 *      sam@tunnelvisionlabs.com
 */
package com.tunnelvisionlabs.postgresql.test;

import com.tunnelvisionlabs.postgresql.PostgreSqlLexer;
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

		PostgreSqlLexer lexer = new PostgreSqlLexer(new ANTLRInputStream(input));

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
