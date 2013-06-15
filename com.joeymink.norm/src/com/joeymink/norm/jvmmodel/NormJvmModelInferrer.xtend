package com.joeymink.norm.jvmmodel

import com.google.inject.Inject
import org.eclipse.xtext.xbase.jvmmodel.AbstractModelInferrer
import org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder
import com.joeymink.norm.norm.NormFile
import com.joeymink.norm.norm.Normalization
import org.eclipse.xtext.naming.IQualifiedNameProvider
import java.util.List
import java.util.ArrayList
import com.joeymink.norm.norm.Unique
import com.joeymink.norm.norm.Attribute

/**
 * <p>Infers a JVM model from the source model.</p> 
 *
 * <p>The JVM model should contain all elements that would appear in the Java code 
 * which is generated from the source model. Other models link against the JVM model rather than the source model.</p>     
 */
class NormJvmModelInferrer extends AbstractModelInferrer {

    /**
     * convenience API to build and initialize JVM types and their members.
     */
	@Inject extension JvmTypesBuilder
	
	@Inject extension IQualifiedNameProvider

	/**
	 * The dispatch method {@code infer} is called for each instance of the
	 * given element's type that is contained in a resource.
	 * 
	 * @param element
	 *            the model to create one or more
	 *            {@link org.eclipse.xtext.common.types.JvmDeclaredType declared
	 *            types} from.
	 * @param acceptor
	 *            each created
	 *            {@link org.eclipse.xtext.common.types.JvmDeclaredType type}
	 *            without a container should be passed to the acceptor in order
	 *            get attached to the current resource. The acceptor's
	 *            {@link IJvmDeclaredTypeAcceptor#accept(org.eclipse.xtext.common.types.JvmDeclaredType)
	 *            accept(..)} method takes the constructed empty type for the
	 *            pre-indexing phase. This one is further initialized in the
	 *            indexing phase using the closure you pass to the returned
	 *            {@link org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor.IPostIndexingInitializing#initializeLater(org.eclipse.xtext.xbase.lib.Procedures.Procedure1)
	 *            initializeLater(..)}.
	 * @param isPreIndexingPhase
	 *            whether the method is called in a pre-indexing phase, i.e.
	 *            when the global index is not yet fully updated. You must not
	 *            rely on linking using the index if isPreIndexingPhase is
	 *            <code>true</code>.
	 */
   	def dispatch void infer(NormFile normFile, IJvmDeclaredTypeAcceptor acceptor, boolean isPreIndexingPhase) {
   		// Here you explain how your model is mapped to Java elements, by writing the actual translation code.

		if (normFile.normalizations != null) {	// Create the main method
			for (norm : normFile.normalizations)
				inferNorm(acceptor, norm)
			acceptor.accept(normFile.toClass(normFile.name + ".Main")).initializeLater [
				members += normFile.toMethod("main", normFile.newTypeRef(Void::TYPE)) [
   	    			parameters += normFile.toParameter("args", normFile.newTypeRef(typeof(String)).addArrayTypeDimension)
   	    			setStatic(true)
   	    			varArgs = true
   	    			body = [append('''
«««						try {
						// Setup input
						com.joeymink.norm.lib.IoConfig inputConfig = new com.joeymink.norm.lib.IoConfig();
						try {
							inputConfig.setConfigFor(Class.forName("«normFile.input.type.identifier»"));
						} catch (ClassNotFoundException e) { throw new RuntimeException(e); }
						java.util.Map<String, String> inputProperties = new java.util.HashMap<String, String>();
   	    				«FOR ioProp : normFile.input.properties»
							inputProperties.put("«ioProp.key»", "«ioProp.value»");
   	    				«ENDFOR»
						inputConfig.setProperties(inputProperties);
						com.joeymink.norm.lib.INormInput input;
						try {
							input = (com.joeymink.norm.lib.INormInput) inputConfig.getConfigFor().newInstance();
						} catch (InstantiationException | IllegalAccessException e) { throw new RuntimeException(e); }
						input.setConfig(inputConfig);
						
						// Setup output
						com.joeymink.norm.lib.IoConfig outputConfig = new com.joeymink.norm.lib.IoConfig();
						try {
							outputConfig.setConfigFor(Class.forName("«normFile.output.type.identifier»"));
						} catch (ClassNotFoundException e) { throw new RuntimeException(e); }
						java.util.Map<String, String> outputProperties = new java.util.HashMap<String, String>();
   	    				«FOR ioProp : normFile.output.properties»
							outputProperties.put("«ioProp.key»", "«ioProp.value»");
   	    				«ENDFOR»
						outputConfig.setProperties(outputProperties);
						com.joeymink.norm.lib.INormOutput output;
						try {
							output = (com.joeymink.norm.lib.INormOutput) outputConfig.getConfigFor().newInstance();
						} catch (InstantiationException | IllegalAccessException e) { throw new RuntimeException(e); }
						output.setConfig(outputConfig); 

						// Notify output of entity types:
						com.joeymink.norm.lib.EntityType entityType;
						«FOR entity : normFile.entities»
							entityType = new com.joeymink.norm.lib.EntityType();
							entityType.name = "«entity.name»";
							«IF entity.unique != null»
								«FOR attribute : entity.unique.attributes»
									entityType.unique.add("«attribute.name»");
								«ENDFOR»
							«ENDIF»
							output.acceptEntityType(entityType);
						«ENDFOR»
						
						// Instantiate all Entity Normalizers:
						java.util.List<com.joeymink.norm.lib.INormalization> norms = new java.util.ArrayList<com.joeymink.norm.lib.INormalization>();
						«FOR norm : normFile.normalizations»
							norms.add(new «norm.name»());
						«ENDFOR»
						
						for (com.joeymink.norm.lib.INormInputRecord inputRecord : input) {
							java.util.List<com.joeymink.norm.lib.OutputEntity> entities = new java.util.ArrayList<com.joeymink.norm.lib.OutputEntity>();
							for (com.joeymink.norm.lib.INormalization norm : norms)
								entities.add(norm.normalize(inputRecord, output));
							output.saveEntities(entities);
						}
						
«««						} catch (Throwable e) { System.out.println(e); System.exit(1); }
   	    			''')]
				]
			]
		}
   	}
   	
   	def protected inferNorm(IJvmDeclaredTypeAcceptor acceptor, Normalization norm) {
   		acceptor.accept(norm.toClass(norm.fullyQualifiedName)).initializeLater [
			superTypes += newTypeRef(norm, 'com.joeymink.norm.lib.INormalization')
			members += norm.toMethod("normalize", norm.newTypeRef('com.joeymink.norm.lib.OutputEntity')) [
				parameters += norm.toParameter("inputRecord", newTypeRef(norm, 'com.joeymink.norm.lib.INormInputRecord'))
				parameters += norm.toParameter("output", newTypeRef(norm, 'com.joeymink.norm.lib.INormOutput'))
    			body = [append('''
					com.joeymink.norm.lib.OutputEntity entity = new com.joeymink.norm.lib.OutputEntity();
					entity.name = "«norm.name»";
					entity.type = "«norm.entity_type.name»";
					// For each column in the CSV input, for example:
					«FOR mapping : norm.mappings»
						«IF mapping.normalizedEntity != null»
							entity.addRef("«mapping.attribute.name»", "«mapping.normalizedEntity.name»");
						«ELSE»
							entity.addField("«mapping.attribute.name»", inputRecord.getField("«mapping.field»"));
						«ENDIF»
					«ENDFOR»
					return entity;
    			''')]
			]
		]
   	}
   	
   	def protected List<String> extractUniqueList(Unique unique) {
   		var list = new ArrayList<String>()
   		for (Attribute attribute : unique.attributes)
   			list.add(attribute.name);
   		return list;
   	}
}

