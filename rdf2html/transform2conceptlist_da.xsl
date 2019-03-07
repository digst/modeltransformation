<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
xmlns:owl="http://www.w3.org/2002/07/owl#"
xmlns:dc="http://purl.org/dc/elements/1.1/"
xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
xmlns:dct="http://purl.org/dc/terms/"
xmlns:dcterms="http://purl.org/dc/terms/" 
xmlns:uml="http://www.omg.org/spec/UML/20110701" 
xmlns:xmi="http://www.omg.org/spec/XMI/20110701" 
xmlns:thecustomprofile="http://www.sparxsystems.com/profiles/thecustomprofile/1.0" 
xmlns:Grunddata="http://www.sparxsystems.com/profiles/Grunddata/1.0" 
xmlns:GML="http://www.sparxsystems.com/profiles/GML/1.0"            
xmlns:vann="http://purl.org/vocab/vann/"
xmlns:dcat="http://www.w3.org/ns/dcat#"
xmlns:adms="http://www.w3.org/ns/adms#"
xmlns:frbr="http://purl.org/vocab/frbr/core#"
xmlns:cv="http://data.europa.eu/m8g/"
xmlns:voag="http://voag.linkedmodel.org/schema/voag#" 
xmlns:voaf="http://purl.org/vocommons/voaf#"
xmlns:cc="http://www.sparxsystems.com/profiles/GML/1.0"
xmlns:foaf="http://xmlns.com/foaf/0.1/"  
xmlns:vs="http://www.w3.org/2003/06/sw-vocab-status/ns#"
xmlns:mdl="https://data.gov.dk/model/core/modelling#"
xmlns:skos="http://www.w3.org/2004/02/skos/core#" 
xmlns:dadk="http://data.gov.dk/model/vocabular/modelcat#"  >
<xsl:output method="html"/>

<!--
==================================================================================================================================================================================
XSL STYLESHEET FOR TRANFORMING RDF/XML TO HTML
==================================================================================================================================================================================
-->
 
<xsl:template match="rdf:RDF">
	<HTML>
		<HEAD>

			<TITLE>HTML-visning</TITLE>
			<link rel="stylesheet" type="text/css" href="htmltransform.css"/>
		</HEAD>
	    <BODY>
		<small><p><i>
		NOTE: Bemærk at dette er en formateret HTML-visning af en RDF-ontologi. Denne visning er udarbejdet i formidlingsøjemed og er ikke udtømmende. Se den originale RDF/XML-fil for det fulde informationsindhold.<br/>
		NOTE: Please note that this is formattet HTML view of an RDF ontology. This view has been made available for dissemination purposes and is not exhaustive. Please refer to the original RDF/XML-file for the complete information.  </i></p>
		</small>
		
<!-- Show model type and status in box-->
<div class="status">
	<div><span>
	   Concept List
	   <xsl:if test="owl:Ontology/adms:status|rdf:Description/adms:status">
		- <xsl:value-of select="owl:Ontology/adms:status|rdf:Description/adms:status"/>		
		</xsl:if>		   
	</span></div>
</div>



<!-- Show model meta data of application profiles-->
<xsl:for-each select="//rdf:type[@rdf:resource='https://data.gov.dk/model/core/modelling#ApplicationProfile' ]/..|
					  //rdf:type[@rdf:resource='https://data.gov.dk/model/core/modelling#Vocabulary' ]/..|
					  //rdf:type[@rdf:resource='https://data.gov.dk/model/core/modelling#ConceptModel' ]/..|
					  //rdf:type[@rdf:resource='http://www.w3.org/2004/02/skos/core#ConceptScheme' ]/..|
					  voaf:Vocabulary|
					  owl:Ontology">

<h1>BEGREBSLISTE til: <xsl:call-template name="modellabel"/>
</h1>
<!--
Download serialisering: <a href="">RDF/XML</a>&#160; <a href="">TTL</a>&#160; <a href="">XMI</a> -->
<hr/>

	<!-- Show model metadata-->
			<h2>METADATA:</h2>
			<xsl:for-each select="rdfs:comment[@xml:lang='da']"><p><xsl:value-of select="."/></p></xsl:for-each> 
			<div class="table">
				<dl>
				<dt>Namespace:</dt><dd><xsl:value-of select="@rdf:about"/></dd>	
				<xsl:if test="vann:preferredNamespacePrefix">
				<dt>Namespaceprefix:</dt><dd><xsl:value-of select="vann:preferredNamespacePrefix"/></dd>
				</xsl:if>
				<dt>Modelnavn:</dt>
				<dd>	
				<xsl:call-template name="modellabel"> </xsl:call-template> 
				</dd>			 
				<dt>Modeludstiller:</dt><dd><xsl:for-each select="dct:publisher"> <xsl:value-of select="."/></xsl:for-each></dd> 
				<dt>Modelansvarlig:</dt><dd><xsl:for-each select="frbr:responsibleEntity"> <xsl:value-of select="."/></xsl:for-each></dd> 	
				<dt>Versionsnummer:</dt><dd><xsl:value-of select="owl:versionInfo"/></dd>
				<dt>Seneste opdateringsdato:</dt><dd><xsl:value-of select="dct:modified"/></dd>
				<dt>Modelstatus:</dt><dd><xsl:value-of select="adms:status"/> &#160;<xsl:value-of select="adms:status/@rdf:resource"/></dd>
			<xsl:if test="voag:hasApprovalStatus"><dt>Godkendelsesstatus:</dt><dd><xsl:value-of select="voag:hasApprovalStatus"/>&#160;<xsl:value-of select="voag:hasApprovalStatus/@rdf:resource"/></dd></xsl:if>
			<xsl:for-each select="dct:theme"><dt>Forretningsområde:</dt><dd><xsl:value-of select="."/></dd> </xsl:for-each>	 
			<xsl:if test="cv:hasLegalResource"><dt>Juridisk kilde:</dt><dd><xsl:for-each select="cv:hasLegalResource"> <xsl:value-of select="."/>; </xsl:for-each></dd></xsl:if>
			<xsl:if test="dct:source"><dt>Kilde:</dt><dd><xsl:for-each select="dct:source"> <xsl:value-of select="."/>; </xsl:for-each></dd></xsl:if>	
			<xsl:if test="dct:language"><dt>Sprog:</dt><dd><xsl:for-each select="dct:language"> <xsl:value-of select="."/>; </xsl:for-each></dd></xsl:if>			
				</dl>
			</div>


</xsl:for-each>

 
<!--Show Concepts  -->	
		<h2>BEGREBER (rdfs:resource):</h2>		
		<table>
		<xsl:call-template name="listheader"/> 		

		<!--Show Classes  -->	
		<xsl:if test="rdfs:Class|owl:Class|rdf:Description/rdf:type[@rdf:resource='http://www.w3.org/2002/07/owl#Class']">
		<xsl:for-each select="rdfs:Class|owl:Class">
					<xsl:call-template name="listcontent"/> 		
	   </xsl:for-each>
<!--Show Classes that have been specified as rdf:Description -->	
		<xsl:for-each select="rdf:Description">
			<xsl:if test="descendant::rdf:type[@rdf:resource='http://www.w3.org/2002/07/owl#Class']">
					<xsl:call-template name="listcontent"/> 	
			</xsl:if>
	   </xsl:for-each>		   
	   </xsl:if>
	   
<!--Show Properties  -->
<!--Show Properties that have been specified as rdf:Property/owl:AnnotationProperty/owl:ObjectProperty/owl:DatatypeProperty-->	
		<xsl:if test="rdf:Property|owl:AnnotationProperty|owl:ObjectProperty|owl:DatatypeProperty|rdf:Description/rdf:type[@rdf:resource='http://www.w3.org/2002/07/owl#ObjectProperty']">
		<xsl:for-each select="rdf:Property|owl:AnnotationProperty|owl:ObjectProperty|owl:DatatypeProperty">
					<xsl:call-template name="listcontent"/> 
	   </xsl:for-each>	
<!--Show Classes that have been specified as rdf:Description -->	
		<xsl:for-each select="rdf:Description">
			<xsl:if test="descendant::rdf:type[@rdf:resource='http://www.w3.org/2002/07/owl#ObjectProperty']|descendant::rdf:type[@rdf:resource='http://www.w3.org/2002/07/owl#AnnotationProperty']">
					<xsl:call-template name="listcontent"/> 
			</xsl:if>
	   </xsl:for-each>			   
	   
	   </xsl:if>
		

	<!--Show SKOS COLLECTION  -->
			<xsl:if test="rdf:Description/rdf:type[@rdf:resource='http://www.w3.org/2004/02/skos/core#Collection']|skos:Collection">	
			<xsl:for-each select="rdf:Description">
			<xsl:if test="rdf:type[@rdf:resource='http://www.w3.org/2004/02/skos/core#Collection']"> 
					<xsl:call-template name="listcontent"/> 
			</xsl:if>				
		   </xsl:for-each>	
			<xsl:for-each select="skos:Collection">
					<xsl:call-template name="listcontent"/> 		
		   </xsl:for-each>		   
		   </xsl:if>  	   
	  
	<!--Show SKOS CONCEPT INSTANCES  -->
			<xsl:if test="skos:Concept|rdf:Description/rdf:type[@rdf:resource='http://www.w3.org/2004/02/skos/core#Concept']">	
			<xsl:for-each select="rdf:Description">
			<xsl:if test="rdf:type[@rdf:resource='http://www.w3.org/2004/02/skos/core#Concept']"> 
					<xsl:call-template name="listcontent"/> 	
			</xsl:if>				
		   </xsl:for-each>	
			<xsl:for-each select="skos:Concept">
					<xsl:call-template name="listcontent"/> 				
		   </xsl:for-each>		   
		   </xsl:if>


	   	</table>	


	   </BODY>
    </HTML>
</xsl:template>


<xsl:template name="listheader">
		<tr><th>Foretrukken term (da)</th><th>Accepteret term (da)</th><th>Frarådet term (da)</th><th>Definition (da)</th><th>Eksempel (da)</th><th>Kommentar (da)</th><th>Juridisk kilde</th><th>Kilde</th><th>Tilhører modellens emneområde</th></tr>
</xsl:template>


<xsl:template name="listcontent">
		<tr>
		<td><xsl:call-template name="resourcelabel"/></td>
		<td><xsl:for-each select="skos:altLabel[@xml:lang='da']"><xsl:value-of select="."/>;</xsl:for-each></td>
		<td><xsl:for-each select="mdl:deprecatedLabel[@xml:lang='da']"><xsl:value-of select="."/>;</xsl:for-each></td>			
		<td><xsl:value-of select="skos:definition[@xml:lang='da']|mdl:applicationNote/skos:definition[@xml:lang='da']"/></td>
		<td><xsl:for-each select="skos:example[@xml:lang='da']"><xsl:value-of select="."/>;</xsl:for-each></td>
		<td><xsl:for-each select="rdfs:comment[@xml:lang='da']"><xsl:value-of select="."/>;</xsl:for-each></td>
		<td><xsl:for-each select="cv:hasLegalResource"><xsl:value-of select="."/>;</xsl:for-each></td>
		<td><xsl:for-each select="dct:source"><xsl:value-of select="."/>;</xsl:for-each></td>
		<td></td>
		</tr>
</xsl:template>


<!--Show resource label  -->			 
<xsl:template name="resourcelabel">
		   <xsl:choose>
			 <xsl:when test="skos:prefLabel"><xsl:apply-templates select="skos:prefLabel"/></xsl:when>	
			 <xsl:when test="mdl:applicationNote/skos:prefLabel"><xsl:apply-templates select="mdl:applicationNote/skos:prefLabel"/></xsl:when>			 
			<xsl:otherwise>		
			 <xsl:if test="rdfs:label"><xsl:apply-templates select="rdfs:label"/></xsl:if>			
			</xsl:otherwise>							 
		   </xsl:choose>	
</xsl:template>


<xsl:template match="skos:prefLabel">				
		   <xsl:choose>
			 <xsl:when test="@xml:lang!=''">							 							
				<xsl:if test="@xml:lang='da'"><xsl:value-of select="."/></xsl:if>	
					   <xsl:choose>
						 <xsl:when test="../rdfs:label[@xml:lang!='']">
						 <xsl:if test="../rdfs:label[@xml:lang='da']"><xsl:value-of select="../rdfs:label[@xml:lang='da']"/></xsl:if>	</xsl:when>						 
						 <xsl:otherwise>	
						 <xsl:if test="../rdfs:label"><xsl:value-of select="../rdfs:label[@xml:lang='da']"/></xsl:if>								
						</xsl:otherwise>			 
					   </xsl:choose>
			 </xsl:when>						   
			 <xsl:otherwise>	
				<xsl:value-of select="."/>		 
			</xsl:otherwise>							 
		   </xsl:choose>
</xsl:template>	


<xsl:template match="rdfs:label">				
		   <xsl:choose>
			 <xsl:when test="@xml:lang!=''">							 								
				<xsl:if test="@xml:lang='da'"><xsl:value-of select="."/></xsl:if>	
			 </xsl:when>						   
			 <xsl:otherwise>		 
			</xsl:otherwise>							 
		   </xsl:choose>
</xsl:template>	

<xsl:template name="modellabel">

		   <xsl:choose>
			 <xsl:when test="rdfs:label">	
				 <xsl:for-each select="rdfs:label[@xml:lang='da']"> <xsl:value-of select="."/>&#160;</xsl:for-each> 
				 <xsl:for-each select="rdfs:label[@xml:lang='en']"><i>(<xsl:value-of select="."/>)</i></xsl:for-each>				
			 </xsl:when>	
			<xsl:when test="dcterms:title|dc:title|dct:title">				 
				 <xsl:for-each select="dcterms:title[@xml:lang='da']"> <xsl:value-of select="."/>&#160;</xsl:for-each> 
				 <xsl:for-each select="dcterms:title[@xml:lang='en']"><i>(<xsl:value-of select="."/>)</i></xsl:for-each>				 
				</xsl:when>
			<xsl:otherwise></xsl:otherwise>							 
		   </xsl:choose>	
</xsl:template>

					  
</xsl:stylesheet>
