package com.joeymink.norm.lib;

import java.util.HashMap;
import java.util.Map;

public class OutputEntity {
	public String name;
	public String type;
	public Map<String, String> fields = new HashMap<String, String>();
	public Map<String, String> refs = new HashMap<String, String>();
	
	public void addField(String key, String value) {
		if (value == null)
			return;
		fields.put(key, value);
	}
	
	/**
	 * Adds a reference to another entity. Note that referenced entities
	 * are expected to be sourced from the same input record.
	 * @param key
	 * @param value
	 */
	public void addRef(String key, String value) {
		if (value == null)
			return;
		refs.put(key, value);
	}
}
