<?xml version="1.0" encoding="utf-8"?>
<!-- namespaces skal matche kildedokumentets og alle anvendte prefixes skal 
	kunne finde sig selv her -->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
	xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
	xmlns:owl="http://www.w3.org/2002/07/owl#"
	xmlns:dc="http://www.omg.org/spec/UML/20131001/UMLDC"
	xmlns:uml="http://www.omg.org/spec/UML/20131001"
	xmlns:xmi="http://www.omg.org/spec/XMI/20131001"
	xmlns:thecustomprofile="http://www.sparxsystems.com/profiles/thecustomprofile/1.0"
	xmlns:Grunddata="http://www.sparxsystems.com/profiles/Grunddata/1.0"
	xmlns:GML="http://www.sparxsystems.com/profiles/GML/1.0"
	xmlns:Plusprofil="http://www.sparxsystems.com/profiles/Plusprofil/1.0"
	xmlns:OWL="http://www.sparxsystems.com/profiles/OWL/1.0"
	xmlns:umldi="http://www.omg.org/spec/UML/20131001/UMLDI" 
	xmlns:my="http://example.com/thisdoc#" 
	xmlns:svg="http://www.w3.org/2000/svg"
	exclude-result-prefixes="xsl rdf rdfs owl dc uml xmi thecustomprofile Grunddata GML Plusprofil OWL umldi my svg">

	<!-- Specificer, at outputtet af transformationen er et html-dokument -->
	<xsl:output method="html" omit-xml-declaration="yes" indent="yes" encoding="UTF-8" />
	
	<!-- 'keys' som hjælper med at fjerne dublikater længere nede -->
	<xsl:key name="x" match="@name" use="." />
	<xsl:key name="y" match="@name" use="." />


<!-- match alt  -->
	<xsl:template match="/">
	<!-- templaten skriver HTML-dokumentet p&#229; basis af modelpakken -->
	
	   
	        
	        
	<html>
	
		<body  style="padding: 0px; font-family: Ubuntu, sans-serif;">
		<!--fang pakker og send til pakketemplate -->
		<xsl:apply-templates select="//uml:Model/packagedElement[@xmi:type='uml:Package']"/>
	</body></html>
	</xsl:template>
	
	<!-- Pakkens template, som styrer target-dokumentetes struktur -->
	<xsl:template match="//uml:Model/packagedElement[@xmi:type='uml:Package']">
	
		
		<!-- indsæt modelpakkens navn -->
		<h1>Model:<xsl:value-of select="./@name" /></h1>
		
		<!-- skriv pakkens egenskaber/tags -->
		<!-- find det entry i profileringsblokken, som matcher modelpakkens (current node) id  og send til tabelbygger templaten-->
		<!-- fang alle modeltyper (vocab, ap, kerne, am) -->
		<xsl:apply-templates select="//Plusprofil:*[@base_Package=current()/@xmi:id]" />		
		<!-- Kør diagram-template -->
		<xsl:apply-templates select="/xmi:XMI/uml:Model/umldi:Diagram" /> 
		
		<!-- <xsl:value-of select="//Plusprofil:*[@base_Package=current()/@xmi:id]" /> -->
		<h2>Klasser:</h2>
		
		<!-- fang alle ikke-klassifikations-Klasse-elementer og send dem til en matchende template -->
		<xsl:for-each select="//Plusprofil:OwlClass[not(@subClassOf='http://www.w3.org/2004/02/skos/core#Concept')]">
			<xsl:apply-templates select="//packagedElement[@xmi:id=current()/@base_Class]" />
		</xsl:for-each>
		
		<h2>Klassifikationer:</h2>
		<!-- fang alle klassifikations-Klasse-elementer  -->
		<xsl:for-each select="//Plusprofil:OwlClass[@subClassOf='http://www.w3.org/2004/02/skos/core#Concept']">
			<!-- Lav en gul kasse -->
			<div class="klassifikationskasse" style="background-color: palegoldenrod;border: 1px solid palegoldenrod;border-radius: 5px;padding: .5em .5em;margin: 1.5em;"><h3>Klassifikation:</h3>
				<!-- Kald klasse-templaten -->
				<xsl:apply-templates select="//packagedElement[@xmi:id=current()/@base_Class]" />
				<!-- hent klassifikationselementer -->		
				<h4>Elementer:</h4>
				<!-- fang individer med b&#229;de rdf:type og med rdfs:type 
				Kald individ-templaten-->
				<xsl:apply-templates select="//packagedElement/ownedAttribute[@name='rdf:type' or @name='rdfs:type']/type[@xmi:idref=current()/@base_Class]/../.." /> 
			</div>
		</xsl:for-each>
	
	</xsl:template>
	
		
	<!-- template som fanger klasser  og skriver klasse-elementer -->
	 <xsl:template match="packagedElement[@xmi:type='uml:Class']">
			<!-- Lav anker som diagrammet kan ramme ned i rapporten -->
		<!-- Nogle elementer har # i id andre har ikke - derfor må vi finde teksten efter '#' eller sidste '/' -->
		<xsl:variable name="elementRef" select="//Plusprofil:OwlClass[@base_Class=current()/@xmi:id]/@URI"/> 
 		<xsl:variable name="ankertext"> 
			<xsl:choose>
				<xsl:when test="contains($elementRef, '#')">
					<xsl:value-of select="substring-after($elementRef,'#')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="substring-after-last">
						<xsl:with-param name="string" select="$elementRef" />
						<xsl:with-param name="delimiter" select="'/'" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable> 
		<div id="{$ankertext}" class="klassekasse" style="background-color: #B0DAF9;border: 1px solid #B0DAF9;border-radius: 5px;padding: .5em .5em;margin: 1.5em;">
	 		<!-- en lysebl&#229; boks med klassenavn og alias -->
			<div class="klassenavne" style="background-color: #4FCAFC;border: 1px solid #4FCAFC;clip-path: polygon(5% 0%, 100% 0%, 95% 100%, 0% 100%);padding: .5em 2em;margin: 1.5em;color: #FFF;display: inline-block;">
				<span class="klassenavn" style="color:#FFF;"><h2>
				<!-- hvis der er : i klassenavnet, skriv efter-delen, ellers skriv hele navnet -->
				<xsl:choose>
					<xsl:when test="(contains(./@name, ':'))"><xsl:value-of select="substring-after(./@name,':')" /></xsl:when>
					<xsl:otherwise><xsl:value-of select="./@name" /></xsl:otherwise>
				</xsl:choose>
				</h2></span>
				<!-- hvis der er alias -->	
				<xsl:if test="//element[@xmi:idref=current()/@xmi:id]/properties/@alias">
					<span class="klassealias" style="color: #1d83cf;float: right;">(<xsl:value-of select="//element[@xmi:idref=current()/@xmi:id]/properties/@alias" />)</span>
				</xsl:if>
			</div>
			<!-- find det entry i profileringsblokken, som matcher klassens (current node) id  og send til tabelbygger templaten-->		
			<xsl:apply-templates select="//Plusprofil:OwlClass[@base_Class=current()/@xmi:id]" /> 
			
			<!--  hvis klassen har properties så:-->
			<xsl:if test="count(ownedAttribute) > 0">
				<!-- skriv en mørkegrå kasse -->
				<div class="egenskaber" style="background-color: #ccc;border: 1px solid #ccc;border-radius: 10px;padding: .5em 1em;margin: .5em;">
					<h3>Egenskaber:</h3>
					<!-- hvis der er attributter -->
					<xsl:if test="count(ownedAttribute[not(@association)]) > 0">
						<!-- s&#229; skriv en lysegr&#229; kasse -->
						<div class="datatypeegenskaber" style="background-color: #eee;border: 1px solid #eee;border-radius: 10px;padding: .5em 1em;margin: .5em;">
						<h4>Datatype-egenskaber:</h4>
						<!-- datatype-egenskaber er de ownedAttributes som ikke har en @association - send til matchende template -->
						<xsl:apply-templates select="ownedAttribute[not(@association)]"> 
							<!-- sorter p&#229; navn -->
							<xsl:sort select="@name" />
						</xsl:apply-templates>
						</div>
					</xsl:if>
					<!-- Hvis der er associationer -->
					<xsl:if test="count(ownedAttribute[(@association)]) > 0">
						<!-- S&#229; skriv endnu en lysegr&#229; kasse -->
						<div class="objektegenskaber" style="background-color: #eee;border: 1px solid #eee;border-radius: 10px;padding: .5em 1em;margin: .5em;">
						<h4>Objekt-egenskaber:</h4>
						<!-- datatype-egenskaber er de ownedAttributes som har en @association - send til matchende template -->
						 <xsl:apply-templates select="ownedAttribute[@association]">
							<xsl:sort select="@name" />
						</xsl:apply-templates> 
						</div>
					</xsl:if>
				</div>
			</xsl:if>
		</div>
	</xsl:template>	
	
	<!-- Template som udskriver attributter -->	
	<xsl:template 	match="ownedAttribute[not(@association)]">
		<div>
			<!-- overskrift med attributtens navn -->
			<h5>
				<span class="egenskabsnavn" style="border: 2px #1D83CF;border-style: hidden hidden dashed dashed;border-radius: 5px;padding: .3em .6em;margin: .2em;background-color:darkseagreen;">
					<!--  hvis der er et : i navnet s&#229; skriv ergerfølgelsen, eller skriv hele navnet-->
					<xsl:choose>
			  			<xsl:when test="(contains(./@name, ':'))"><xsl:value-of select="substring-after(./@name,':')" /></xsl:when>
			 			<xsl:otherwise><xsl:value-of select="./@name" /></xsl:otherwise>
					</xsl:choose>
				</span>
				<!-- hvis der er et alias s&#229; tilføj det i overskriften -->
				<xsl:if test="//attribute[@xmi:idref=current()/@xmi:id]/style/@value">
					<span class="egenskabsalias">(<xsl:value-of select="//attribute[@xmi:idref=current()/@xmi:id]/style/@value" />)</span>
				</xsl:if>
			</h5>
			<div style="margin-left:.5em;">
				<!-- skriv datatypen -->
				<div style="margin-bottom:.5em;">Type: <span class="typedesignation" style="font-size: 75%;font-style:italic;font-weight: bold;"><xsl:value-of select="//*[@xmi:id=current()/type/@xmi:idref]/@name" /> </span></div>
				
				<!-- skriv multiplicitet -->
				<div style="margin-bottom:.5em;">Multiplicitet: <span class="multiplicitet" style="font-size: 75%;font-style:italic;">[<xsl:value-of select="./lowerValue/@value" />..<xsl:value-of select="./upperValue/@value" />]</span></div>
				
				<!-- kald tabelbygger-templaten med attributtens profilentry -->
				<xsl:apply-templates select="//Plusprofil:DatatypeProperty[@base_Property=current()/@xmi:id]" />
			</div>
		</div>
	</xsl:template>
	
	<!-- template, som udskriver associationsender (object properties) -->
	<xsl:template match="ownedAttribute[@association]">
		<div>
			<!-- overskrift med associationsendens navn -->
			<h5>
				<span class="egenskabsnavn" style="border: 2px #1D83CF;border-style: hidden hidden dashed dashed;border-radius: 5px;padding: .3em .6em;margin: .2em;background-color:darkseagreen;">	
					<!--  hvis der er et : i navnet s&#229; skriv ergerfølgelsen, eller skriv hele navnet-->
					<xsl:choose>
		  				<xsl:when test="(contains(./@name, ':'))"><xsl:value-of select="substring-after(./@name,':')" /></xsl:when>
		 				<xsl:otherwise><xsl:value-of select="./@name" /></xsl:otherwise>
					</xsl:choose>
				</span>
				<!-- hvis der er et alias s&#229; tilføj det i overskriften 
				xmi:XMI/xmi:Extension/connectors/connector/target/style/value 
				<style value="Union=0;Derived=0;AllowDuplicates=0;Owned=0;Navigable=Navigable;alias=konteringsadresse;"/>
				asd 
				
				path: //target[xmi:idref=current()/type/@xmi:idref]/style/@value
				-->
		<!-- 		<xsl:if test="(contains(//ownedElement[@modelElement=current()/@xmi:id]/@text, '('))"> 
					<span class="egenskabsalias">(<xsl:value-of select="substring-after(substring-before(//ownedElement[@modelElement=current()/@xmi:id]/@text,')'),'(')" />)</span>
				</xsl:if>
				  -->
				  <xsl:variable name="val" select="//target[@xmi:idref=current()/type/@xmi:idref]/style/@value"/>
					 <span class="egenskabsalias">(<xsl:value-of select="substring-before(substring-after($val,'alias='),';')" />)</span>
			</h5>
			<div style="margin-left:.5em;">
				<div style="margin-bottom:.5em;">	
					<!-- skriv typen - dvs den associerede klasse -->
					Type: <span class="typedesignation" style="font-size: 75%;font-style:italic;font-weight: bold;">
					<!--  hvis der er et : i navnet s&#229; skriv ergerfølgelsen, eller skriv hele navnet-->
					<xsl:choose>
			  			<xsl:when test="(contains(//packagedElement[@xmi:id=current()/type/@xmi:idref]/@name, ':'))"><xsl:value-of select="substring-after(//packagedElement[@xmi:id=current()/type/@xmi:idref]/@name,':')" /></xsl:when>
			 			<xsl:otherwise><xsl:value-of select="//packagedElement[@xmi:id=current()/type/@xmi:idref]/@name" /></xsl:otherwise>
					</xsl:choose>
					</span>
				</div>
				<!-- skriv multiplicitet -->	
				<div style="margin-bottom:.5em;">
					Multiplicitet: <span class="multiplicitet" style="font-size: 75%;font-style:italic;">[<xsl:value-of select="./lowerValue/@value" />..<xsl:value-of select="./upperValue/@value" />]</span>
					
					<!-- kald tabelbygger-templaten med attributtens profilentry -->
					<xsl:apply-templates select="//Plusprofil:ObjectProperty[@base_Property=current()/@xmi:id]" />
				</div>
			</div>
		</div>
		</xsl:template>
		
	<!-- individ-templaten - bruges kun i klassifikationer-->
	<xsl:template  match="packagedElement/packagedElement[@xmi:type='uml:InstanceSpecification']">
		<div  class="klassifikationselement" style="background-color: goldenrod;border: 1px solid goldenrod;border-radius: 5px;padding: .25em .25em;margin: 1em 1em 1em 4em;">
			<h3><span class="instansnavn">	<!-- individer har ikke aliasser -->
				<xsl:choose>
					<xsl:when test="(contains(./@name, ':'))"><xsl:value-of select="substring-after(./@name,':')" /></xsl:when>
					<xsl:otherwise><xsl:value-of select="./@name" /></xsl:otherwise>
				</xsl:choose>
			</span></h3>
			<!-- Hent individdets profil-entry og kald tabelskriveren -->
			<xsl:apply-templates select="//Plusprofil:Individual[@base_Element=current()/@xmi:id or @base_InstanceSpecification=current()/@xmi:id]" />
		</div>
	</xsl:template>
		
		
	<!-- template som skriver en tabel med tagged values for pakker, klasser, attributter og associationsender -->	
	<xsl:template match="//Plusprofil:*">	
		<div class="beskrivelsesoverskrift" style="font-weight:bold;">Beskrivelse:</div>
			<!-- tabel med modelpakkens tags -->
			<table style="border-collapse: collapse;width:60%;margin-bottom: 1em;">	
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'URI'" />
					<xsl:with-param name="value" select = "@URI" />
				</xsl:call-template>
				<!-- Klasser -->
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'foretrukken term p&#229; dansk'" /><xsl:with-param name="value" select = "@prefLabel__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'foretrukken term p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@prefLabel__en_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'accepteret term p&#229; dansk'" />
					<xsl:with-param name="value" select = "@altLabel__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'accepteret term p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@altLabel__en_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'frar&#229;det term p&#229; dansk'" />
					<xsl:with-param name="value" select = "@deprecatedLabel__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'frar&#229;det term p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@deprecatedLabel__en_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'definition p&#229; dansk'" />
					<xsl:with-param name="value" select = "@definition__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'definition p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@definition__en_" />
				</xsl:call-template>
				
				<!-- klasser og modeller -->
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'betegnelse p&#229; dansk'" />
					<xsl:with-param name="value" select = "@label__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'betegnelse p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@label__en_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'kommentar p&#229; dansk'" />
					<xsl:with-param name="value" select = "@comment__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'anvendelsesnote p&#229; dansk'" />
					<xsl:with-param name="value" select = "@applicationNote__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'kommentar p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@comment__en_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'anvendelsesnote p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@applicationNote__en_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'eksempel p&#229; dansk'" />
					<xsl:with-param name="value" select = "@example__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'eksempel p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@example__en_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'anvendelsesnote p&#229; dansk'" />
					<xsl:with-param name="value" select = "@applicationNote__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'anvendelsesnote p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@applicationNote__en_" />
				</xsl:call-template>
				
				<!-- modeller -->
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'namespace'" />
					<xsl:with-param name="value" select = "@namespace" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'namespacePrefix'" />
					<xsl:with-param name="value" select = "@namespacePrefix" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'Modelejer'" />
					<xsl:with-param name="value" select = "@publisher" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'emne'" />
					<xsl:with-param name="value" select = "@theme" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'seneste opdateringsdata'" />
					<xsl:with-param name="value" select = "@modified" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'versionsnummer'" />
					<xsl:with-param name="value" select = "@versionInfo" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'godkendelsesstatus'" />
					<xsl:with-param name="value" select = "@approvalStatus" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'modelstatus'" />
					<xsl:with-param name="value" select = "@modelStatus" />
				</xsl:call-template>
				
				<!-- klasser og modeller -->
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'juridisk kilde'" />
					<xsl:with-param name="value" select = "@legalSource" />
				</xsl:call-template>
				
				<!-- klasser -->
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'kilde'" />
					<xsl:with-param name="value" select = "@source" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'was derived from'" />
					<xsl:with-param name="value" select = "@wasDerivedFrom" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'sub class of'" />
					<xsl:with-param name="value" select = "@subClassOf" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'equivalent class'" />
					<xsl:with-param name="value" select = "@equivalentClass" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'is defined by'" />
					<xsl:with-param name="value" select = "@isDefinedBy" />
				</xsl:call-template>
				
				<!-- Properties -->
				<!-- <xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'functional property'" />
					<xsl:with-param name="value" select = "@functionalProperty" />
				</xsl:call-template>
				 -->
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'r&#230;kkevidde'" />
					<xsl:with-param name="value" select = "@range" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'dom&#230;ne'" />
					<xsl:with-param name="value" select = "@domain" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'sub property of'" />
					<xsl:with-param name="value" select = "@subPropertyOf" />
				</xsl:call-template>
				
				<xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'equivalent property'" />
					<xsl:with-param name="value" select = "@eguivalientProperty" />
				</xsl:call-template>
				
				<!-- Object Properties -->
				 <!-- <xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'inverseFunctionalProperty'" />
					<xsl:with-param name="value" select = "@inverseFunctionalProperty" />
				</xsl:call-template>
				-->
				 <!-- <xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'transitiveProperty'" />
					<xsl:with-param name="value" select = "@transitiveProperty" />
				</xsl:call-template>
				-->
				 <!-- <xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'inverseOf'" />
					<xsl:with-param name="value" select = "@inverseOf" />
				</xsl:call-template>
				-->
				<!-- <xsl:call-template name="tableLine">
					<xsl:with-param name="text" select = "'symmetricProperty'" />
					<xsl:with-param name="value" select = "@symmetricProperty" />
				</xsl:call-template>
				-->
			</table>
	</xsl:template>
	
	
	<xsl:template name="tableLine">
	 	<xsl:param name = "text" />
	 	<xsl:param name = "value" />
	 	<xsl:if test="($value!='') and ($value!='$ea_notes=')">
	 	
	 	<tr>
				<td style="border: 1px solid #6f6f6f;"><xsl:value-of select="$text" /></td>
				<td style="border: 1px solid #6f6f6f;"><xsl:value-of select="$value" /></td>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<!-- tegn et diagram -->
	<xsl:template match="xmi:XMI/uml:Model/umldi:Diagram">
	
		<!-- beregn diagrammets bredde -->
		<xsl:variable name="bredde">
			<xsl:for-each select="ownedElement">
				<xsl:sort select="./bounds/@x + ./bounds/@width" data-type="number" order="descending"/>
				<xsl:if test="position()=1">
					 <xsl:value-of select="./bounds/@x + ./bounds/@width"/>
			 	</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		
		<!-- beregn diagrammets højde -->
		<xsl:variable name="hoejde"> 
			 <xsl:for-each select="ownedElement">
				<xsl:sort select="./bounds/@y + ./bounds/@height" data-type="number" order="descending"/>
				<xsl:if test="position()=1">
					<xsl:value-of select="./bounds/@y + ./bounds/@height"/>
			 	</xsl:if>
			</xsl:for-each>
		</xsl:variable>		
		
		<!-- Skriv diagrammets navn -->
		<h1>Diagram:<xsl:value-of select="/xmi:XMI/xmi:Extension/diagrams/diagram[@xmi:id=current()/@xmi:id]/properties/@name" /></h1>
		
		<!-- tegn diagram vha svg--> 
		<svg contentscripttype="text/ecmascript"  viewBox="0 0 {$bredde} {$hoejde +6}" contentstyletype="text/css" id="svg4155" preserveAspectRatio="xMidYMid meet" version="1.1" width="90%" >
			
			<!-- loop over alle klasseelementer -->		
			<xsl:for-each select="//ownedElement[@xmi:type='umldi:UMLClassifierShape' or @xmi:type='umldi:UMLCompartmentableShape']">
				<!-- Lav link til ned i rapporten -->
				<!-- Nogle elementer har # i id andre har ikke - derfor må vi finde teksten efter '#' eller sidste '/' -->
				<xsl:variable name="elementRef" select="//Plusprofil:OwlClass[@base_Class=current()/@modelElement]/@URI"/> 
		 		<xsl:variable name="linktext"> 
					<xsl:choose>
						<xsl:when test="contains($elementRef, '#')">
							<xsl:value-of select="substring-after($elementRef,'#')"/>
						</xsl:when>
						<xsl:otherwise>
							<!-- vi bruger en rekurserende template - nederst i dokumentet - til at kante os ind på den sidste skrøstreg -->
							<xsl:call-template name="substring-after-last">
								<xsl:with-param name="string" select="$elementRef" />
								<xsl:with-param name="delimiter" select="'/'" />
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable> 
				<xsl:variable name="fyldfarve"> 
				<xsl:choose>
					<xsl:when test="contains(//Plusprofil:OwlClass[@base_Class=current()/@modelElement]/@subClassOf,'http://www.w3.org/2004/02/skos/core#Concept')">
								<xsl:value-of select="'#a5681aff'"/>
					</xsl:when>
					<xsl:otherwise>
							<xsl:value-of  select="'#b7c4c8'"/>
					</xsl:otherwise>
				</xsl:choose>
				</xsl:variable>
				<!-- en gruppe, som indeholder et klasse-element og dets indhold - placeret ift umldi koordinaterne-->

				<g transform="translate({./bounds/@x} {./bounds/@y})">
					<!-- link til et sted i rapporten -->
					<a href="#{$linktext}">
						<!-- klassens kasse -->

						
						<!-- <rect id="{@xmi:id}" class="classcontainer" height="{./bounds/@height}" width="{./bounds/@width}" rx="5"  ry="5" fill-opacity="1" stroke-width="1" style="fill:#b7c4c8;fill-opacity:1;stroke:#000000;stroke-width:1.06500006;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;filter:url(#Graa)"> -->
						<rect id="{@xmi:id}" class="classcontainer" height="{./bounds/@height}" width="{./bounds/@width}" rx="5"  ry="5" fill-opacity="1" stroke-width="1" style="fill:{$fyldfarve};fill-opacity:1;stroke:#000000;stroke-width:1.06500006;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;filter:url(#Graa)">
							<!-- mouse-over text -->
							<title><xsl:value-of select="//Plusprofil:OwlClass[@base_Class=current()/@modelElement]/@definition__da_"/></title>
						</rect>
					</a>
					<!-- klassens tværstreg -  -->
					<line x1="5" y1="25" x2="{./bounds/@width -5}" y2="25" stroke="darkgrey" />
					<!-- klassenavn - elegant placeret i midten vha text-anchor og klassebredden delt med to. Fontstørrelse altid problematisk -->
					<text text-anchor="middle"  x="{./bounds/@width div 2}" y="18" font-size="9.5" font-weight="bold" id="text4261" fill="black"  style="font-weight:bold;stroke:none">
						<!-- gymnastik som kan fjernt prefix fra klassenavn - hvis det findes --> 
						<xsl:variable name="klassenavn" select="/xmi:XMI/uml:Model/packagedElement/packagedElement[@xmi:id=current()/@modelElement]/@name"/>
						<!-- <xsl:choose> 
							<xsl:when test="(contains($klassenavn, ':'))"><xsl:value-of select="substring-after($klassenavn,':')" /></xsl:when>
							<xsl:otherwise> -->
								<xsl:value-of select="$klassenavn" />
							<!-- </xsl:otherwise>
						</xsl:choose>  -->
					</text>
					<text transform="translate(11 26)">
						<xsl:for-each select="/xmi:XMI/uml:Model/packagedElement/packagedElement[@xmi:id=current()/@modelElement]/ownedAttribute[not(@association)]">
						
						<!-- increase dy for hvert loop -->
							<tspan x="0" y="{position() * 14}" font-size="10" id="text4261" fill="black">
								<xsl:value-of select="./@name" />
						
					</tspan>
						</xsl:for-each> 
					</text>
					
					

					<xsl:if  test="contains(//Plusprofil:OwlClass[@base_Class=current()/@modelElement]/@subClassOf,'http://www.w3.org/2004/02/skos/core#Concept')">
						<use x="-50" y="-45" transform="scale(0.45)"   href="#klassifikationsikon"/>
					</xsl:if>
					
				</g>
				
			</xsl:for-each>
			<!-- pile -->
			<xsl:for-each select="//ownedElement[@xmi:type='umldi:UMLEdge']">
			
				<!-- lav en variabel indeholdende pathëns d-værdi (linjepunkter) baseret på XMI-dokumentets waypoints -->
				<xsl:variable name="dString">
					<xsl:call-template name="pathfinder">
						<xsl:with-param name="counter" select="1"/>
						<xsl:with-param name="points" select="current()/waypoint"/>
						<xsl:with-param name="PdString" select="'M '"/>
					</xsl:call-template>
				</xsl:variable>
				<!-- tegn pilen -->
				<path fill="none" stroke="black" d="{$dString}" />	
							
							
			</xsl:for-each>
	<!-- Hent en masse styling -->
	<xsl:call-template name="indsaet_definitioner"/>
	
		</svg>
	</xsl:template>	
	
<xsl:template mode="forSVG" match="/xmi:XMI/uml:Model/packagedElement/packagedElement/ownedAttribute[not(@association)]" >
	
</xsl:template>	


  
  <!-- template som rekurserende bygger d-værdi til paths til associationer -->
  <xsl:template name="pathfinder">
		<xsl:param name="counter"/>
		<xsl:param name="points"/>
		<xsl:param name="PdString"/>
		
		<xsl:choose>
		<xsl:when test="$counter &lt; count($points)">
		
			<xsl:call-template name="pathfinder">
				<xsl:with-param name="counter" select="$counter + 1"/>
				<xsl:with-param name="points" select="$points"/>
				<xsl:with-param name="PdString" select="concat($PdString, $points[$counter]/@x, ', ', $points[$counter]/@y, ' ' )"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
		
			<xsl:value-of select="concat($PdString, $points[$counter]/@x, ', ', $points[$counter]/@y)" />
		</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
  
	<!-- Hjælper, som finder tekst efter sidste forekomst af et tegn i en streng -->
	<xsl:template name="substring-after-last">
	    <xsl:param name="string" />
	    <xsl:param name="delimiter" />
	    <xsl:choose>
	    	<xsl:when test="contains($string, $delimiter)">
	    		<xsl:call-template name="substring-after-last">
	          		<xsl:with-param name="string" select="substring-after($string, $delimiter)" />
	          		<xsl:with-param name="delimiter" select="$delimiter" />
	        	</xsl:call-template>
	      	</xsl:when>
	    	<xsl:otherwise><xsl:value-of select="$string" /></xsl:otherwise>
    	</xsl:choose>
  </xsl:template>
  
<!--  en masse styling -->
<xsl:template  name="indsaet_definitioner">		
			
	<defs xmlns="http://www.w3.org/2000/svg" id="defs2">
    <filter xmlns="http://www.w3.org/2000/svg" id="Graa" style="color-interpolation-filters:sRGB;" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape" inkscape:label="Bloom" inkscape:menu="Bevels" inkscape:menu-tooltip="Soft, cushion-like bevel with matte highlights">
      <feFlood flood-opacity="0.498039" flood-color="rgb(0,0,0)" result="flood" id="feFlood885"></feFlood>
      <feComposite in="flood" in2="SourceGraphic" operator="in" result="composite1" id="feComposite887"></feComposite>
      <feGaussianBlur in="composite1" stdDeviation="3" result="blur" id="feGaussianBlur889"></feGaussianBlur>
      <feOffset dx="3" dy="3" result="offset" id="feOffset891"></feOffset>
      <feComposite in="SourceGraphic" in2="offset" operator="over" result="fbSourceGraphic" id="feComposite893"></feComposite>
      <feColorMatrix result="fbSourceGraphicAlpha" in="fbSourceGraphic" values="0 0 0 -1 0 0 0 0 -1 0 0 0 0 -1 0 0 0 0 1 0" id="feColorMatrix4727"></feColorMatrix>
      <feGaussianBlur id="feGaussianBlur4729" result="result1" in="fbSourceGraphicAlpha" stdDeviation="2.2"></feGaussianBlur>
      <feSpecularLighting id="feSpecularLighting4731" result="result0" specularExponent="18.1" specularConstant="2" surfaceScale="5">
<!-- elevation her har effekt for farvemætning af kasser azimuth styrer lysvinklen -->
        <feDistantLight id="feDistantLight4733" azimuth="225" elevation="40"></feDistantLight>
      </feSpecularLighting>
      <feComposite in2="fbSourceGraphicAlpha" id="feComposite4735" result="result6" operator="in"></feComposite>
      <feMorphology id="feMorphology4737" radius="5.7" operator="dilate"></feMorphology>
      <feGaussianBlur id="feGaussianBlur4739" result="result11" stdDeviation="5.7"></feGaussianBlur>
      <feDiffuseLighting id="feDiffuseLighting4741" surfaceScale="5" result="result3" diffuseConstant="2" in="result1">
<!-- Her giver ændring af elevation blødere kanter -->
        <feDistantLight id="feDistantLight4743" elevation="50" azimuth="225"></feDistantLight>
      </feDiffuseLighting>
      <feBlend in2="fbSourceGraphic" id="feBlend4745" result="result7" mode="multiply" in="result3"></feBlend>
      <feComposite in2="fbSourceGraphicAlpha" id="feComposite4747" in="result7" operator="in" result="result91"></feComposite>
      <feBlend in2="result91" id="feBlend4749" result="result9" mode="lighten" in="result6"></feBlend>
      <feComposite in2="result9" id="feComposite4751" in="result11"></feComposite>
    </filter>
          
        <filter xmlns="http://www.w3.org/2000/svg" id="GraaOrig" style="color-interpolation-filters:sRGB;" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape" inkscape:label="Bloom" inkscape:menu="Bevels" inkscape:menu-tooltip="Soft, cushion-like bevel with matte highlights">
      <feFlood flood-opacity="0.498039" flood-color="rgb(0,0,0)" result="flood" id="feFlood885"></feFlood>
      <feComposite in="flood" in2="SourceGraphic" operator="in" result="composite1" id="feComposite887"></feComposite>
      <feGaussianBlur in="composite1" stdDeviation="3" result="blur" id="feGaussianBlur889"></feGaussianBlur>
      <feOffset dx="3" dy="3" result="offset" id="feOffset891"></feOffset>
      <feComposite in="SourceGraphic" in2="offset" operator="over" result="fbSourceGraphic" id="feComposite893"></feComposite>
      <feColorMatrix result="fbSourceGraphicAlpha" in="fbSourceGraphic" values="0 0 0 -1 0 0 0 0 -1 0 0 0 0 -1 0 0 0 0 1 0" id="feColorMatrix4727"></feColorMatrix>
      <feGaussianBlur id="feGaussianBlur4729" result="result1" in="fbSourceGraphicAlpha" stdDeviation="2.2"></feGaussianBlur>
      <feSpecularLighting id="feSpecularLighting4731" result="result0" specularExponent="18.1" specularConstant="2" surfaceScale="5">
        <feDistantLight id="feDistantLight4733" azimuth="225" elevation="24"></feDistantLight>
      </feSpecularLighting>
      <feComposite in2="fbSourceGraphicAlpha" id="feComposite4735" result="result6" operator="in"></feComposite>
      <feMorphology id="feMorphology4737" radius="5.7" operator="dilate"></feMorphology>
      <feGaussianBlur id="feGaussianBlur4739" result="result11" stdDeviation="5.7"></feGaussianBlur>
      <feDiffuseLighting id="feDiffuseLighting4741" surfaceScale="5" result="result3" diffuseConstant="2" in="result1">
        <feDistantLight id="feDistantLight4743" elevation="25" azimuth="225"></feDistantLight>
      </feDiffuseLighting>
      <feBlend in2="fbSourceGraphic" id="feBlend4745" result="result7" mode="multiply" in="result3"></feBlend>
      <feComposite in2="fbSourceGraphicAlpha" id="feComposite4747" in="result7" operator="in" result="result91"></feComposite>
      <feBlend in2="result91" id="feBlend4749" result="result9" mode="lighten" in="result6"></feBlend>
      <feComposite in2="result9" id="feComposite4751" in="result11"></feComposite>
    </filter>
    
    <g id="klassifikationsikon">
     
    <g
       id="g821"
       style="stroke-width:2;stroke-miterlimit:4;stroke-dasharray:none;stroke:#000000;stroke-opacity:1">
      <path
         
         id="path815"
         d="m 81.517206,115.25672 v 31.00326 h 7.483546"
         style="fill:none;stroke:#000000;stroke-width:1.8;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;stroke-miterlimit:4;stroke-dasharray:none" />
      <path
         
         id="path817"
         d="m 81.784475,127.28385 h 6.949008"
         style="fill:none;stroke:#000000;stroke-width:1.8;stroke-linecap:butt;stroke-linejoin:miter;stroke-opacity:1;stroke-miterlimit:4;stroke-dasharray:none" />
    </g>
    <rect
       style="fill:#f3c518;fill-opacity:1;stroke:#000000;stroke-width:2.5;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
       id="rect823"
       width="24"
       height="12"
       x="88.466217"
       y="121" />
    <rect
       y="140"
       x="88.466217"
       height="12"
       width="24"
       id="rect825"
       style="fill:#f3c518;fill-opacity:1;stroke:#000000;stroke-width:2.5;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1" />
    <path
       style="fill:#f3c518;fill-opacity:1;stroke:none;stroke-width:1.79999995;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1"
       id="path827"

       d="m 78.38406,115.8439 a 7.216279,6.4198437 0 0 1 -3.345722,-8.57374 7.216279,6.4198437 0 0 1 9.63493,-2.98275 7.216279,6.4198437 0 0 1 3.359845,8.56937 7.216279,6.4198437 0 0 1 -9.630005,2.99531 l 3.130316,-5.78439 z" />
  </g>
  </defs>
  
  </xsl:template>
	
</xsl:stylesheet>

