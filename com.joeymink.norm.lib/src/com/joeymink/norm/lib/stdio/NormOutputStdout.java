package com.joeymink.norm.lib.stdio;

import java.util.List;

import com.joeymink.norm.lib.EntityType;
import com.joeymink.norm.lib.INormOutput;
import com.joeymink.norm.lib.IoConfig;
import com.joeymink.norm.lib.OutputEntity;

public class NormOutputStdout implements INormOutput {

	public void saveEntities(List<OutputEntity> entities) {
		for (OutputEntity entity : entities) {
			System.out.print(entity.name + " --");
			for (String key : entity.fields.keySet())
				System.out.print(" " + key + ":" + entity.fields.get(key));
			for (String key : entity.refs.keySet())
				System.out.print(" " + key + "->" + entity.refs.get(key));
			System.out.println();
		}
	}

	public void setConfig(IoConfig config) {
		// No configuration necessary for this impl
	}

	public void acceptEntityType(EntityType entityType) {
		// TODO Auto-generated method stub
		
	}

}
