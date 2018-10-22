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
	exclude-result-prefixes="xsl rdf rdfs owl dc uml xmi thecustomprofile Grunddata GML Plusprofil OWL umldi my">

	<!-- Specificer, at outputtet af transformationen er et html-dokument -->
	<xsl:output method="html" omit-xml-declaration="yes" indent="yes" encoding="UTF-8"/>
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
	<div class="klassekasse" style="background-color: #B0DAF9;border: 1px solid #B0DAF9;border-radius: 5px;padding: .5em .5em;margin: 1.5em;">
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
		
		<!--  hvis klassen har properties s&#229;:-->
		<xsl:if test="count(ownedAttribute) > 0">
			<!-- skriv en mørkegr&#229; kasse -->
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
	
</xsl:stylesheet>
