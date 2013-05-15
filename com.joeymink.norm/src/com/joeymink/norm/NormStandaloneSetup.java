
package com.joeymink.norm;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class NormStandaloneSetup extends NormStandaloneSetupGenerated{

	public static void doSetup() {
		new NormStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}

