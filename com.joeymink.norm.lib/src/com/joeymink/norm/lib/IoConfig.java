package com.joeymink.norm.lib;

import java.util.Map;

/**
 * Stores the configuration for an INormInput or
 * an INormOutput
 * @author walk_n_wind
 *
 */
@SuppressWarnings("rawtypes")
public class IoConfig {
	private Class configFor;
	private Map<String, String> properties;

	public Class getConfigFor() {
		return configFor;
	}
	public void setConfigFor(Class configFor) {
		this.configFor = configFor;
	}
	public Map<String, String> getProperties() {
		return properties;
	}
	public void setProperties(Map<String, String> properties) {
		this.properties = properties;
	}
}
