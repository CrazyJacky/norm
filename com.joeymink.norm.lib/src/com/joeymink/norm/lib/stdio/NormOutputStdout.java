package com.joeymink.norm.lib.stdio;

import com.joeymink.norm.lib.INormOutput;
import com.joeymink.norm.lib.OutputEntity;

public class NormOutputStdout implements INormOutput {

	public void saveEntity(OutputEntity entity) {
		System.out.print(entity.name + " --");
		for (String key : entity.fields.keySet())
			System.out.print(" " + key + ":" + entity.fields.get(key));
		System.out.println();
	}

}
