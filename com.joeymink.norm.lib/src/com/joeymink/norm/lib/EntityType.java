package com.joeymink.norm.lib;

import java.util.ArrayList;
import java.util.List;

public class EntityType {
	public String name;
	public List<String> unique = new ArrayList<String>();
	public boolean hasUnique() {
		return unique.size() > 0;
	}
}
