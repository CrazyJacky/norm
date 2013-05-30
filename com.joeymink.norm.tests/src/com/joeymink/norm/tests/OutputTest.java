package com.joeymink.norm.tests;

import org.eclipse.xtext.junit4.InjectWith;
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2;
import org.eclipselabs.xtext.utils.unittesting.XtextTest;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.joeymink.norm.NormInjectorProvider;

@RunWith(XtextRunner2.class)
@InjectWith(NormInjectorProvider.class)
public class OutputTest extends XtextTest {
	@Test
	public void testEmptyOutput() {
		testParserRule("output com.joeymink.^norm.tests.OutputTest {}", "Output");
	}
	
	@Test
	public void testOutput() {
		testParserRule("output com.joeymink.^norm.tests.OutputTest { key=\"value\" }", "Output");
		testParserRule("output com.joeymink.^norm.tests.OutputTest { key = \"value\" }", "Output");
		testParserRule("output com.joeymink.^norm.tests.OutputTest { key1=\"value1\" key2=\"value2\" }", "Output");
	}
}
