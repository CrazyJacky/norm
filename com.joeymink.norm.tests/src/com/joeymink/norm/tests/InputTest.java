package com.joeymink.norm.tests;

import org.eclipse.xtext.junit4.InjectWith;
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2;
import org.eclipselabs.xtext.utils.unittesting.XtextTest;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.joeymink.norm.NormInjectorProvider;

@RunWith(XtextRunner2.class)
@InjectWith(NormInjectorProvider.class)
public class InputTest extends XtextTest {
	@Test
	public void testEmptyInput() {
		testParserRule("input com.joeymink.^norm.tests.InputTest {}", "Input");
	}
	
	@Test
	public void testInput() {
		testParserRule("input com.joeymink.^norm.tests.InputTest { key=\"value\" }", "Input");
		testParserRule("input com.joeymink.^norm.tests.InputTest { key = \"value\" }", "Input");
		testParserRule("input com.joeymink.^norm.tests.InputTest { key1=\"value1\" key2=\"value2\" }", "Input");
	}
}
