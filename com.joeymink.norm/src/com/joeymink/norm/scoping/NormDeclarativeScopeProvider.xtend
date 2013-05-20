/*
 * generated by Xtext
 */
package com.joeymink.norm.scoping;

import org.eclipse.emf.ecore.EReference;
import org.eclipse.xtext.scoping.IScope;
import org.eclipse.xtext.scoping.Scopes;
import com.joeymink.norm.norm.Mapping
import com.joeymink.norm.norm.Normalization

/**
 * This class contains custom scoping description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation/latest/xtext.html#scoping
 * on how and when to use it 
 *
 */
public class NormDeclarativeScopeProvider extends MyAbstractDeclarativeScopeProvider {
	def IScope scope_Mapping_attribute(Mapping mapping, EReference attributeRef) {
		Scopes::scopeFor((mapping.eContainer as Normalization).entity_type.attributes.attributes)
	}
}
