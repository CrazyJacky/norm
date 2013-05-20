package com.joeymink.norm.jvmmodel

import com.google.inject.Inject
import org.eclipse.xtext.xbase.jvmmodel.AbstractModelInferrer
import org.eclipse.xtext.xbase.jvmmodel.IJvmDeclaredTypeAcceptor
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder
import com.joeymink.norm.norm.NormFile
import org.eclipse.xtext.common.types.JvmDeclaredType
import com.joeymink.norm.norm.Entity
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
			acceptor.accept(normFile.toClass(normFile.name)).initializeLater [
				members += normFile.toMethod("main", normFile.newTypeRef(Void::TYPE)) [
   	    			parameters += normFile.toParameter("args", normFile.newTypeRef(typeof(String)).addArrayTypeDimension)
   	    			setStatic(true)
   	    			varArgs = true
				]
			]
		}

		for (e : normFile.entities) {	// for each Entity e defined in the DSL:
			// Declare the class name for the Entity's Java twin
			acceptor.accept(e.toClass(e.name)).initializeLater [
				// For each Attribute a defined in Entity e:
				for (a : e.attributes.attributes) {
					createProperty(e, a)
				}
			]
   		}
   	}
   	
   	def protected createProperty(JvmDeclaredType inferredType, Entity entity, Attribute attribute) {
   		var privateField = '_' + attribute.name
   		inferredType.members += entity.toField(privateField, newTypeRef(entity, typeof(String)))
   		inferredType.members += entity.toGetter(attribute.name, privateField, newTypeRef(entity, typeof(String)))
   	}
}

