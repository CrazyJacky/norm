package com.joeymink.norm.jvmmodel

import com.google.inject.Inject
import org.eclipse.xtext.xbase.jvmmodel.AbstractModelInferrer
import org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder
import com.joeymink.norm.norm.NormFile
import com.joeymink.norm.norm.Normalization
import org.eclipse.xtext.naming.IQualifiedNameProvider

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
						try {
						// Setup input
						com.joeymink.norm.lib.IoConfig inputConfig = new com.joeymink.norm.lib.IoConfig();
						inputConfig.setConfigFor(Class.forName("«normFile.input.type.identifier»"));
						java.util.Map<String, String> inputProperties = new java.util.HashMap<String, String>();
   	    				«FOR ioProp : normFile.input.properties»
							inputProperties.put("«ioProp.key»", "«ioProp.value»");
   	    				«ENDFOR»
						inputConfig.setProperties(inputProperties);
						com.joeymink.norm.lib.INormInput input = (com.joeymink.norm.lib.INormInput) inputConfig.getConfigFor().newInstance();
						input.setConfig(inputConfig);
						
						// Setup output
						com.joeymink.norm.lib.IoConfig outputConfig = new com.joeymink.norm.lib.IoConfig();
						outputConfig.setConfigFor(Class.forName("«normFile.output.type.identifier»"));
						java.util.Map<String, String> outputProperties = new java.util.HashMap<String, String>();
   	    				«FOR ioProp : normFile.output.properties»
							outputProperties.put("«ioProp.key»", "«ioProp.value»");
   	    				«ENDFOR»
						outputConfig.setProperties(outputProperties);
						com.joeymink.norm.lib.INormOutput output = (com.joeymink.norm.lib.INormOutput) outputConfig.getConfigFor().newInstance();
						output.setConfig(outputConfig); 
						
						// Instantiate all Entity Normalizers:
						java.util.List<com.joeymink.norm.lib.INormalization> norms = new java.util.ArrayList<com.joeymink.norm.lib.INormalization>();
						«FOR norm : normFile.normalizations»
							norms.add(new «norm.name»());
						«ENDFOR»
						
						for (com.joeymink.norm.lib.INormInputRecord inputRecord : input) {
							for (com.joeymink.norm.lib.INormalization norm : norms)
								norm.normalize(inputRecord, output);
						}
						
						} catch (Throwable e) { System.out.println(e); System.exit(1); }
   	    			''')]
				]
			]
		}
   	}
   	
   	def protected inferNorm(IJvmDeclaredTypeAcceptor acceptor, Normalization norm) {
   		acceptor.accept(norm.toClass(norm.fullyQualifiedName)).initializeLater [
			superTypes += newTypeRef(norm, 'com.joeymink.norm.lib.INormalization')
			members += norm.toMethod("normalize", norm.newTypeRef(Void::TYPE)) [
				parameters += norm.toParameter("inputRecord", newTypeRef(norm, 'com.joeymink.norm.lib.INormInputRecord'))
				parameters += norm.toParameter("output", newTypeRef(norm, 'com.joeymink.norm.lib.INormOutput'))
    			body = [append('''
					com.joeymink.norm.lib.OutputEntity entity = new com.joeymink.norm.lib.OutputEntity();
					entity.name = "«norm.entity_type.name»";
					«FOR mapping : norm.mappings»
						entity.fields.put("«mapping.attribute.name»", inputRecord.getField("«mapping.field»"));
					«ENDFOR»
					output.saveEntity(entity);
    			''')]
			]
		]
   	}
}

