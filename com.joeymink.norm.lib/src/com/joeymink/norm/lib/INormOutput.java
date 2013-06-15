package com.joeymink.norm.lib;

import java.util.List;

public interface INormOutput {
	public void acceptEntityType(EntityType entityType);
	public void saveEntities(List<OutputEntity> entities);
	public void setConfig(IoConfig config);
}
