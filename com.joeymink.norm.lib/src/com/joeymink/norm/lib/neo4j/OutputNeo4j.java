package com.joeymink.norm.lib.neo4j;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.neo4j.graphdb.DynamicLabel;
import org.neo4j.graphdb.DynamicRelationshipType;
import org.neo4j.graphdb.GraphDatabaseService;
import org.neo4j.graphdb.Node;
import org.neo4j.graphdb.Transaction;
import org.neo4j.graphdb.factory.GraphDatabaseFactory;
import org.neo4j.graphdb.index.UniqueFactory;

import com.joeymink.norm.lib.EntityType;
import com.joeymink.norm.lib.INormOutput;
import com.joeymink.norm.lib.IoConfig;
import com.joeymink.norm.lib.OutputEntity;

public class OutputNeo4j implements INormOutput {
	private GraphDatabaseService graphDb;
	private IoConfig config;
	private Map<String, EntityType> entityTypes = new HashMap<String, EntityType>();
	
	public void saveEntities(List<OutputEntity> entities) {
		if (graphDb == null)
			init();
		
        Transaction tx = graphDb.beginTx();
        try {
			// create nodes for each entity:
			Map<String, Node> nodesByName = new HashMap<String, Node>();
			for (OutputEntity entity : entities) {
				Node entityNode = getOrCreateEntityNode(entity);
				nodesByName.put(entity.name, entityNode);
			}
			
			// create relationships between the now-existing nodes:
			for (OutputEntity entity : entities) {
				Node entityNode = nodesByName.get(entity.name);
				for (String field : entity.refs.keySet()) {
					Node referencedNode = nodesByName.get(entity.refs.get(field));
					entityNode.createRelationshipTo(referencedNode, DynamicRelationshipType.withName(field));
				}
			}
			tx.success();
        } finally {
			tx.finish();
		}
	}

	/**
	 * @param entity
	 */
	private Node getOrCreateEntityNode(OutputEntity entity) {
		EntityType entityType = entityTypes.get(entity.type);
		if (entityType.hasUnique()) {
			return getOrCreateWithUniqueFactory(entity, entityType);
		}
		
		if (entity.type == null)
			System.out.println("Wha?!");
		Node entityNode = graphDb.createNode(DynamicLabel.label(entity.type));
		return addEntityFields(entityNode, entity);
	}
	
	private Node addEntityFields(Node node, OutputEntity entity) {
    	for (String fieldKey : entity.fields.keySet())
    		node.setProperty(fieldKey, entity.fields.get(fieldKey));
    	return node;
	}
	
	public Node getOrCreateWithUniqueFactory(final OutputEntity entity, EntityType entityType) {
	    UniqueFactory<Node> factory = new UniqueFactory.UniqueNodeFactory(graphDb, entity.type) {
	        @Override
	        protected void initialize(Node created, Map<String, Object> properties) {
	        	for (String key : entity.fields.keySet())
	        		created.setProperty(key, entity.fields.get(key));
	        }
	    };
	 
	    String uniqueField = entityType.unique.get(0);
	    return factory.getOrCreate(uniqueField, entity.fields.get(uniqueField));
	}

	public void setConfig(IoConfig config) {
		this.config = config;
	}
	
	private void init() {
		String dbFile = config.getProperties().get("file");
		graphDb = new GraphDatabaseFactory().newEmbeddedDatabase(dbFile==null? "./norm_db.neo4j" : dbFile);
		registerShutdownHook(graphDb);
	}
	
	/**
	 * @see http://docs.neo4j.org/chunked/stable/tutorials-java-embedded-setup.html
	 * @param graphDb
	 */
	private static void registerShutdownHook( final GraphDatabaseService graphDb )
	{
	    // Registers a shutdown hook for the Neo4j instance so that it
	    // shuts down nicely when the VM exits (even if you "Ctrl-C" the
	    // running application).
	    Runtime.getRuntime().addShutdownHook( new Thread()
	    {
	        @Override
	        public void run()
	        {
	            graphDb.shutdown();
	        }
	    } );
	}

	public void acceptEntityType(EntityType entityType) {
		entityTypes.put(entityType.name, entityType);
	}

}
