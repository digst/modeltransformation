<?xml version="1.0" encoding="utf-8"?>
<!--

XSLT gennemløber nodesets pg sender udvalgte sub-sets til uskrift i matchende templates
Diagrammet viser hvilke nodes, der sendes videre til hvilke templates - disse angiver omtrentligt linjenummer
                           l.92                                 l.116
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+          +~~~~~~~~~~~~~~~~~~~~~~~~~+
|  MATCH ALT                     | Pakke    |  PAKKE ITERATOR         +<~~~+
|  Skriv dokument start og slut  |~~~~~~~~~>+  finder underpakker     |    |Pakke
|  html, head, body              |          |                         |~~~~+
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+ Pakke    +~~~+~~~~~~~~~~~~~~~~~~~~~+
      | Pakke       +~~~~~~~~~~~~~~~~~~~~~~~~~~~+
      v             v     l.126                          l.728                     l.1015
+~~~~~+~~~~~~~~~~~~~~~~~~~~~~~~~~+          +~~~~~~~~~~~~~~~~~+ URI     +~~~~~~~~~~~~~~~~~+
|   PAKKEUDSKIVER                | Diagram  |  DIAGRAMTEGNER  |~~~~~~~~>+SUBSTRING~AFTER  |
|  Skriv pakkens indhold         |~~~~~~~~~>+  Tegn SVGdiagram|         |  Find lokalident|
|  pakkemetadata,                |          |  Klasseelementer|         +~~~~~~~~~~~~~~~~~+
|  diagrammer,                   |          |  attributter    |               l.993
|  klasseelementer,              |          |  pile           | Pil     +~~~~~~~~~~~~+
|                                |          |                 |~~~~~~~~>+ PILETEGNER |
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+          |                 |         |            |
      |                    |                +~~~~~~~~~~~~~~~~~+         +~~~~~~~~~~~~+
      |                    |                       |                                 l.1051
      |uml:Class           |  tags                 |  Hent definitioner +~~~~~~~~~~~~~~~~~~+
      |  Parameter:        +~~~~~~~~~~~~~~~~~~~+   +~~~~~~~~~~~~~~~~~~~>+ DEFS             |
      |      Begreb                            |                        | Filtre/shaders   |
      |      Klasse                            |                        | Pilespidser      |
      |      Klassifikation                    +~~~~~~~~~~~~~~~~~~+     +~~~~~~~~~~~~~~~~~~+
      v                 l.187                          l.339      |              l.487
+~~~~~+~~~~~~~~~~~~~~~~~~~~~~~~~~+ Attribut   +~~~~~~~~~~~~~+     |     +~~~~~~~~~~~~~~+
|   KLASSEUDSKRIVER              |~~~~~~~~~~~>+ ATTRIBUT    |tags +~~~~>+ METADATATABEL|
|   Skriv klasse~elementets      |            |  type,mult  |~~~~~~~~~~>+              |
|     metadata                   |            +~~~~~~~~~~~~~+      +~~~>+              |
|                                |                     l.371       |    |              |
|                                | Assoc.ende +~~~~~~~~~~~~~+ tags |    +~~~~~~~~~~~~~~+
|                                |~~~~~~~~~~~>+ ASSOC.END   |~~~~~~+         |tag
|                                |            |  target,mult|      |         v  l.715
+~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+            +~~~~~~~~~~~~~+      |    +~~~~+~~~~~~~~+
                           |   |                       l.415       |    | TABELRÆKKE  |
                           |   |  Association +~~~~~~~~~~~~~+ tags |    |             |
                           |   +~~~~~~~~~~~~~>+ ASSOCIATION |~~~~~~+    +~~~~~~~~~~~~~+
                           |                  | target      |      |
                           |                  +~~~~~~~~~~~~~+      |
                           |                           l.472       |
                           |  Klassifikations +~~~~~~~~~~~~+  tags |
                           +~~~~~~~~~~~~~~~~~>+ INDIVID    |~~~~~~~+
                                element       |            |
                                              +~~~~~~~~~~~~+

-->



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
	xmlns:FDAprofil="http://www.sparxsystems.com/profiles/FDAprofil/1.0"
	xmlns:OWL="http://www.sparxsystems.com/profiles/OWL/1.0"
	xmlns:umldi="http://www.omg.org/spec/UML/20131001/UMLDI" 
	xmlns:my="http://example.com/thisdoc#" 
	xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:xlink="https://www.w3.org/1999/xlink" 
	exclude-result-prefixes="xsl rdf rdfs owl dc uml xmi thecustomprofile Grunddata GML FDAprofil OWL umldi my svg">

	<!-- Specificer, at outputtet af transformationen er et html-dokument -->
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="UTF-8" />
	
	<!-- 'keys' som hjælper med at fjerne dublikater længere nede -->
	<xsl:key name="x" match="@name" use="." />
	<xsl:key name="y" match="@name" use="." />

	<!-- Ens anvendelse af variable sikrer, at farverne i diagrammet og i rapporten er de samme for tilsvarende elementer  -->

<xsl:variable name="klassefarve" select="'#C4C0C0'"/>
<xsl:variable name="begrebfarve" select="'#F5B7B1'"/>
<xsl:variable name="klassifikationfarve" select="'#EDBB99'"/>
<xsl:variable name="instansfarve" select="'#FAD7A0'"/>
<xsl:variable name="divfarve" select="'#CCC'"/>



<!-- match alt  -->
	<xsl:template match="/">
	<!-- templaten skriver HTML-dokumentet paa basis af modelpakken -->
	
	   
	        
	        
	<html>	   
	   <head>

        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
				<meta charset="UTF-8"/> 
        <title>Model Rapport</title>

      </head>    
		<body  style="padding: 0px; font-family: Ubuntu, sans-serif;background-color: #eee">
		<!--fang pakker og send til pakketemplates 
		 -->
			<xsl:apply-templates select="//uml:Model/packagedElement[@xmi:type='uml:Package']" mode="pakkeudskrivning"/>
			<xsl:apply-templates select="//uml:Model/packagedElement[@xmi:type='uml:Package']" mode="pakkesortering"/>
	
	</body></html>
	</xsl:template>

<!-- template som rekursivt finder underpakker - sender pakkken med indhold til udskrivning og sender underpakker tilbage hertil-->
	<xsl:template match="//packagedElement[@xmi:type='uml:Package']" mode="pakkesortering">
		<xsl:apply-templates select="packagedElement[@xmi:type='uml:Package']" mode="pakkeudskrivning"/>
		<xsl:apply-templates select="packagedElement[@xmi:type='uml:Package']"  mode="pakkesortering"/>
	</xsl:template>



	<!-- Pakkens template, som styrer target-dokumentetes struktur -->

	<xsl:template match="//packagedElement[@xmi:type='uml:Package']" mode="pakkeudskrivning">
		
		<!-- find pakketype -->
		<xsl:variable name="packageType" select="local-name(//FDAprofil:*[@base_Package=current()/@xmi:id])" /> 
			
		<!-- indsæt modelpakkens stereotype og navn -->
		<h1>Model:
		<xsl:if test="//FDAprofil:*[@base_Package=current()/@xmi:id]"> 
			&#171;  <xsl:value-of select="local-name(//FDAprofil:*[@base_Package=current()/@xmi:id])" />	&#187; 
		</xsl:if>
		<xsl:value-of select="./@name" />
		</h1>
		
		<!-- skriv pakkens egenskaber/tags -->
		<!-- find det entry i profileringsblokken, som matcher modelpakkens (current node) id  og send til tabelbygger templaten-->
		<!-- fang alle modeltyper (vocab, ap, kerne, am) -->
		<xsl:apply-templates select="//FDAprofil:*[@base_Package=current()/@xmi:id]" />		
	
	

		<!-- Kør diagram-template på diagrammer som indikerer denne pakke som ejer-->
				<xsl:apply-templates select="//umldi:Diagram[@modelElement=current()/@xmi:id]" /> 
	
		<!-- Start kassebyggertemplaten med hhv begreber, klasser og klassifikationer -->
	
		<!-- find begreber i pakken - alle klasseelementer, som har stereotype Concept sendes til template med parameter Begreb-->
		<xsl:for-each select="packagedElement[@xmi:type='uml:Class']">
			<xsl:if test="//FDAprofil:Concept[@base_Element=current()/@xmi:id or @base_Class=current()/@xmi:id]" >
				<xsl:apply-templates select="current()" >
					<xsl:with-param name="elementslags" select = "'Begreb'" />
					<xsl:with-param name="packageType" select = "$packageType" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>

<!-- find klasser i pakken - alle klasseelementer, som har stereotype ModelElement og som ikke er i en klasifikationsmodel sendes til template med parameter Klasse -->
		<xsl:for-each select="packagedElement[@xmi:type='uml:Class']">
			<xsl:if test="(//FDAprofil:ModelElement[@base_Element=current()/@xmi:id or @base_Class=current()/@xmi:id]) and ($packageType != 'ClassificationModel')" >
				<xsl:apply-templates select="current()" >
				 	<xsl:with-param name="elementslags" select = "'Klasse'" />
					<xsl:with-param name="packageType" select = "$packageType" />
				</xsl:apply-templates>
			</xsl:if>
		</xsl:for-each>


<!--find klassifikationer i pakken -->
<!-- vælger både klasser som er tagget som underklasser af SKOSConcept (plusprofil) og klasser som er i ClassificationModel pakker  (FDAprofil) -->	
<!-- kunne evt udvies med klasser som er modelleret som underklasser til en concept-klasse -->
	<xsl:for-each select="packagedElement[@xmi:type='uml:Class']">
		<xsl:if test="(//FDAprofil:OwlClass[@subClassOf='http://www.w3.org/2004/02/skos/core#Concept']) or ($packageType = 'ClassificationModel')">
			<xsl:apply-templates select="current()" >
					<xsl:with-param name="elementslags" select = "'Klassifikation'" />
						<xsl:with-param name="packageType" select = "$packageType" />
			</xsl:apply-templates>
		</xsl:if>
	</xsl:for-each>

</xsl:template>
	
		
	<!-- template som fanger Class-elementer  og skriver begreber, klasser, klassifikationsklasser og -elementer -->
	 <xsl:template match="//packagedElement[@xmi:type='uml:Class']">

			<xsl:param name = "elementslags" />
 			<xsl:param name = "packageType" />


			<!-- Lav anker som fra diagrammet kan rammes nede i rapporten -->
			<!-- Nogle elementer har # i id andre har ikke - derfor må vi finde teksten efter '#' eller sidste '/' -->
			<!-- evt noget andet,hvis ikke formelle urier -->
	
			<!-- find elementets reference til rapporten:
			Først, find værddien af URI-tagget -->
		
		<xsl:variable name="elementRef" select="//FDAprofil:*[@base_Element=current()/@xmi:id or @base_Class=current()/@xmi:id]/@URI"/>
			
		<xsl:variable name="ankertext"> 
			<xsl:choose> 	<!--Hvis uri eksisterer findes enten text efter # eller efter sidste / -->	
					<xsl:when test="$elementRef">
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
					</xsl:when>
					<!-- Hvis Uri ikke eksisterer bruges klassenavnet -->
					<xsl:otherwise>
						<xsl:value-of select="./@name"/>
					</xsl:otherwise>
			</xsl:choose>
		</xsl:variable> 
		<!-- farven på klassenavnet fastsættes -->
		<xsl:variable name="labelfarve"> 
			<xsl:choose>
				<xsl:when test="($elementslags='Begreb')">
						<xsl:value-of select="$begrebfarve"/>
				</xsl:when>
				<xsl:when test="($elementslags='Klasse')">
						<xsl:value-of select="$klassefarve"/>
				</xsl:when>
				<xsl:when test="($elementslags='Klassifikation')">
						<xsl:value-of select="$klassifikationfarve"/>
				</xsl:when>
				<xsl:otherwise>
						<xsl:value-of select="'green'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable> 
		
		<!-- en klasses div -->
		<div id="{$ankertext}" class="{$elementslags}" style="background-color: {$divfarve};border: none;border-radius: 5px;padding: .5em .5em;margin: 1.5em;">
	 		<h3><span style="font-weight: normal;"><xsl:value-of select="$elementslags"/>:</span>
			<!-- en boks med klassenavn og alias -->
			<div class="klassenavne" style="background-color: {$labelfarve};border: 1px solid {$labelfarve};border-radius: 10px;padding: .5em .7em;margin: .5em;color: #FFF;display: inline-block;">
				<span class="klassenavn" style="color:#FFF;">
				
						<!-- hvis der er : i klassenavnet, skriv efter-delen, ellers skriv hele navnet -->
						<xsl:choose>
							<xsl:when test="(contains(./@name, ':'))">
								<xsl:value-of select="substring-after(./@name,':')" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="./@name" />
							</xsl:otherwise>
						</xsl:choose>
					
				</span>
				<!-- hvis der er alias (findes i vendor  extension)-->
				<xsl:if test="//element[@xmi:idref=current()/@xmi:id]/properties/@alias">
					<span class="klassealias" style="color: #1d83cf;font-size: smaller;margin-left: .6em;font-weight: normal;">(<xsl:value-of select="//element[@xmi:idref=current()/@xmi:id]/properties/@alias" />)</span>
				</xsl:if>
				
			</div>
						<!-- Hvis der er modelleret en overklasse-->
						<xsl:if test="./generalization">
							<span style="font-weight:normal;"> Specialisering af </span>
							<div class="overklasse" style="background-color: {$labelfarve};border: 1px solid {$labelfarve};border-radius: 10px;padding: .5em .7em;margin: .5em;color: #FFF;display: inline-block;">
								 <xsl:value-of select="//packagedElement[@xmi:id=current()/generalization/@general]/@name" />
							</div>
						</xsl:if>
			</h3>



			<!-- find det entry i profileringsblokken, som matcher klassens (current node) id  og send til tabelbygger templaten-->		
			<xsl:apply-templates select="//FDAprofil:*[@base_Class=current()/@xmi:id or @base_Element=current()/@xmi:id]" /> 
			
			<!--  hvis klassen har properties  -->
			<xsl:if test="count(ownedAttribute) > 0">
				<!-- skriv en kasse -->
				
				<div class="egenskaber" style="background-color: #ccc;border: 1px solid #ccc;border-radius: 10px;padding: .5em 1em;margin: .5em;">
							<div class="beskrivelsesoverskrift" style="font-weight:bold;margin:.2em">Egenskaber:</div>
							<!-- hvis der er attributter -->
							<xsl:if test="count(ownedAttribute[not(@association)]) > 0">
								<!-- s&#229; skriv en lysegr&#229; kasse -->
								<div class="datatypeegenskaber" style="background-color: #eee;border: 1px solid #eee;border-radius: 10px;padding: .5em 1em;margin: .5em;">
									<div class="beskrivelsesoverskrift" style="font-weight:bold;text-decoration: underline;margin:.2em">Datatype-egenskaber:</div>
									<!-- datatype-egenskaber er de ownedAttributes som ikke har en @association - send til matchende template -->
									<xsl:apply-templates select="ownedAttribute[not(@association)]"> 
										<!-- sorter p&#229; navn -->
										<xsl:sort select="@name" />
									</xsl:apply-templates>
								</div>
							</xsl:if>
							<!-- Hvis der er associationsender (objProp er de ownedAttributes som har en @association og @name)-->
							<xsl:if test="count(ownedAttribute[(@association) and (@name)]) > 0">
								<!-- S&#229; skriv endnu en lysegr&#229; kasse -->
								<div class="objektegenskaber" style="background-color: #eee;border: 1px solid #eee;border-radius: 10px;padding: .5em 1em;margin: .5em;">
									<div class="beskrivelsesoverskrift" style="font-weight:bold;text-decoration: underline;margin:.2em">Objekt-egenskaber:</div>
									<!-- object-egenskaber er de ownedAttributes som har en @association - send til matchende template -->
						 			<xsl:apply-templates select="ownedAttribute[@association and (@name)]">
										<xsl:sort select="@name" />
									</xsl:apply-templates> 
								</div>
							</xsl:if>
							<!-- Hvis der er associationer uden ender (ownedAttributes som har en @association men ikke @name)-->
							<xsl:if test="count(ownedAttribute[(@association) and not(@name)]) > 0">
								<!-- S&#229; skriv endnu en lysegr&#229; kasse -->
								<div class="objektegenskaber" style="background-color: #eee;border: 1px solid #eee;border-radius: 10px;padding: .5em 1em;margin: .5em;">
									<div class="beskrivelsesoverskrift" style="font-weight:bold;text-decoration: underline;margin:.2em">Associationer:</div>
									<!-- send til matchende template -->
						 			<xsl:apply-templates select="ownedAttribute[@association and not(@name)]">
										<xsl:sort select="@name" />
									</xsl:apply-templates> 
								</div>
							</xsl:if>
				</div>
			</xsl:if>
			<!-- test om der findes elementer som peger på klassen med 'type' (plusprofil) ELLER om vi er i en klassifikationspakke med instanser
			Enumerationer er ikke understøttet -->
			<xsl:if  test="(//packagedElement/ownedAttribute[@name='rdf:type' or @name='rdfs:type']/type[@xmi:idref=current()/@xmi:id]) or (($packageType = 'ClassificationModel') and ../packagedElement[@xmi:type='uml:InstanceSpecification']) ">
				<div class="elementer" style="background-color: #ccc;border: 1px solid #ccc;border-radius: 10px;padding: .5em 1em;margin: .5em;">
					<div class="elementeroverskrift" style="font-weight:bold;margin:.2em">Elementer:</div>
					<!-- fang individer med baade rdf:type og med rdfs:type OG (|) fang instanser i samme pakke
					Kald individ-templaten-->
					<!-- Man kunne gøre noget for, at også individer fik ankertekst, så de kunne nås fra diagrammet -->
					<xsl:apply-templates select="//packagedElement/ownedAttribute[@name='rdf:type' or @name='rdfs:type']/type[@xmi:idref=current()/@xmi:id]/../.. | ../packagedElement[@xmi:type='uml:InstanceSpecification']" /> 
				</div>
			</xsl:if>

						
		
		</div>
	</xsl:template>	
	
	<!-- Template som udskriver attributter -->	
	<xsl:template 	match="ownedAttribute[not(@association)]">
		<div class="attributgruppe" style="margin: 1em 1.2em;">
		
			<!-- overskrift med attributtens navn -->
			<h4>
				<span class="egenskabsnavn" style="border: 4px ridge;border-radius: 7px;padding: .3em .6em;margin: .2em .2em .2em -.5em;background-color:#ddd;">
					<!--  hvis der er et : i navnet s&#229; skriv ergerfølgelsen, eller skriv hele navnet-->
					<xsl:choose>
			  			<xsl:when test="(contains(./@name, ':'))"><xsl:value-of select="substring-after(./@name,':')" /></xsl:when>
			 			<xsl:otherwise><xsl:value-of select="./@name" /></xsl:otherwise>
					</xsl:choose>
				
				<!-- hvis der er et alias s&#229; tilføj det i overskriften -->
				<xsl:if test="//attribute[@xmi:idref=current()/@xmi:id]/style/@value">
					(<xsl:value-of select="//attribute[@xmi:idref=current()/@xmi:id]/style/@value" />)
				</xsl:if>
				</span>
			</h4>
			<div style="margin-left:.5em;">
				<!-- skriv datatypen -->
				<div style="margin-bottom:.5em;">Type: <span class="typedesignation" style="font-size: 75%;font-style:italic;font-weight: bold;"><xsl:value-of select="//*[@xmi:id=current()/type/@xmi:idref]/@name" /> </span></div>
				
				<!-- skriv multiplicitet -->
				<div style="margin-bottom:.5em;">Multiplicitet: <span class="multiplicitet" style="font-size: 75%;font-style:italic;">[<xsl:value-of select="./lowerValue/@value" />..<xsl:value-of select="./upperValue/@value" />]</span></div>
				
				<!-- kald tabelbygger-templaten med attributtens profilentry -->
				<xsl:apply-templates select="//FDAprofil:ModelElement[@base_Element=current()/@xmi:id]" />
			</div>
		</div>
	</xsl:template>
	
	<!-- template, som udskriver associationsender (object properties) -->
	<xsl:template match="ownedAttribute[@association and (@name)]">
		<div class="associationsendegruppe" style="margin: 1em 1.2em;">
		
			<!-- overskrift med associationsendens navn -->
			<h4>
				<span class="egenskabsnavn" style="border: 4px ridge;border-radius: 7px;padding: .3em .6em;margin: .2em .2em .2em -.5em;background-color:#ddd;">	
					<!--  hvis der er et : i navnet s&#229; skriv efterfølgelsen, eller skriv hele navnet-->
					<xsl:choose>
		  				<xsl:when test="(contains(./@name, ':'))"><xsl:value-of select="substring-after(./@name,':')" /></xsl:when>
		 				<xsl:otherwise><xsl:value-of select="./@name" /></xsl:otherwise>
					</xsl:choose>
				

					<!-- find egenskabens aliasnavn - hvis det findes - og skriv det -->
				  <xsl:variable name="val" select="//target[@xmi:idref=current()/type/@xmi:idref]/style/@value"/>
					<xsl:if test="(contains($val, 'alias='))"> 
					 (<xsl:value-of select="substring-before(substring-after($val,'alias='),';')" />)
					</xsl:if>
				</span>

			</h4>
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
				</div>
					<!-- kald tabelbygger-templaten med attributtens profilentry -->
					<xsl:apply-templates select="//FDAprofil:ModelElement[@base_Element=current()/@xmi:id]" />
				
			</div>
		</div>
	</xsl:template>

			<!-- template, som udskriver associationer (som ikke har associationsender (object properties)) -->
	<xsl:template match="ownedAttribute[@association and not(@name)]">
		<div class="associationsgruppe" style="margin: 1em 1.2em;">
			<!-- overskrift med associationen og dens klasser -->
					<h4>
					<!-- skariv afsenderklasens navn -->
						<span class="afsenderklassenavn" style="color:#777">
							<xsl:value-of select="./../@name" />
							<!-- og dens alias -->
						<xsl:if test="//element[@xmi:idref=current()/../@xmi:id]/properties/@alias">
								<span class="egenskabsalias">&#8194;(<xsl:value-of select="//element[@xmi:idref=current()/../@xmi:id]/properties/@alias" />)</span>
						</xsl:if>
						&#8194;&#8680;&#8194;
						</span>
						<span class="associationsnavn" style="border: 4px ridge;border-radius: 7px;padding: .3em .6em;margin: .2em;background-color:#ddd;">
							<!--  hvis der er et : i navnet saa skriv efterfølgelsen, eller skriv hele navnet-->
							<xsl:choose>
								<xsl:when test="(contains(//packagedElement[@xmi:id=current()/@association]/@name, ':'))">
									<xsl:value-of select="substring-after(//packagedElement[@xmi:id=current()/@association]/@name,':')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="//packagedElement[@xmi:id=current()/@association]/@name" />
								</xsl:otherwise>
							</xsl:choose>
						

						<!-- find egenskabens aliasnavn og skriv det -->
						<xsl:if test="contains(//connector[@xmi:idref=current()/@association]/style/@value, 'alias=')">
							<xsl:variable name="val" select="//connector[@xmi:idref=current()/@association]/style/@value"/>
							&#8194;(<xsl:value-of select="substring-before(substring-after($val,'alias='),';')" />)
						</xsl:if>
						</span>
						<!-- skriv modtagerklassens navn -->
						<span class="modtagerklassenavn" style="color:#777">&#8194;&#8680;&#8194;<xsl:value-of select="//packagedElement[@xmi:id=current()/type/@xmi:idref]/@name" />
					
					<!-- og dens alias -->
						<xsl:if test="//element[@xmi:idref=current()/type/@xmi:idref]/properties/@alias">
								<span class="modtageralias">&#8194;(<xsl:value-of select="//element[@xmi:idref=current()/type/@xmi:idref]/properties/@alias" />)</span>
						</xsl:if>
					</span>

				<xsl:if test="./lowerValue">
					<span class="multiplicitet" style="font-size: 75%;font-style:italic;">&#8194;&#8194;&#8194;&#8194;Multiplicitet:  [<xsl:value-of select="./lowerValue/@value" />..<xsl:value-of select="./upperValue/@value" />]</span>
				</xsl:if>
				</h4>
			<div style="margin-left:.5em;">
				
				<!-- skriv multiplicitet -->	
				<div style="margin-bottom:.5em;">
					<span id="gem" style="display:none">fyld</span>
					<!-- kald tabelbygger-templaten med attributtens profilentry -->
					<xsl:apply-templates select="//FDAprofil:ModelElement[@base_Element=current()/@association]" />
				</div>
			</div>
		</div>
		</xsl:template>
		
	<!-- individ-templaten - bruges kun i klassifikationer-->
	<xsl:template  match="packagedElement/packagedElement[@xmi:type='uml:InstanceSpecification']">
		<div  class="klassifikationselement" style="background-color: {$instansfarve};border: 1px solid {$instansfarve};border-radius: 5px;padding: .25em .25em;margin: 1em 1em 1em 4em;">
			<h3><span class="instansnavn">	<!-- individer har ikke aliasser -->
				<xsl:choose>
					<xsl:when test="(contains(./@name, ':'))"><xsl:value-of select="substring-after(./@name,':')" /></xsl:when>
					<xsl:otherwise><xsl:value-of select="./@name" /></xsl:otherwise>
				</xsl:choose>
			</span></h3>
			<!-- Hent individdets profil-entry og kald tabelskriveren -->
			<xsl:apply-templates select="//FDAprofil:ModelElement[@base_Element=current()/@xmi:id or @base_InstanceSpecification=current()/@xmi:id]" />
		</div>
	</xsl:template>
		
		
	<!-- template som skriver en tabel med tagged values for pakker, klasser, attributter associationer og associationsender -->	
	<xsl:template match="//FDAprofil:*">	
	<div class="beskrivelse" style="margin-left:1em">
		<div class="beskrivelsesoverskrift" style="font-weight:bold;margin:.2em">Beskrivelse:</div>
			<!-- tabel med modelpakkens tags -->
			<table style="border-collapse: collapse;width:60%;margin-bottom: 1em;">	
			<tr id="result_tr" style="display: none;"><td>123</td><td>123</td></tr>
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'URI'" />
					<xsl:with-param name="value" select = "@URI" />
				</xsl:call-template>
				<!-- Klasser -->
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'foretrukken term p&#229; dansk'" />
					<xsl:with-param name="value" select = "@prefLabel__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'foretrukken term p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@prefLabel__en_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'accepteret term p&#229; dansk'" />
					<xsl:with-param name="value" select = "@altLabel__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'accepteret term p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@altLabel__en_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'frar&#229;det term p&#229; dansk'" />
					<xsl:with-param name="value" select = "@deprecatedLabel__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'frar&#229;det term p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@deprecatedLabel__en_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'definition p&#229; dansk'" />
					<xsl:with-param name="value" select = "@definition__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'definition p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@definition__en_" />
				</xsl:call-template>
				
				<!-- klasser og modeller -->
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'betegnelse p&#229; dansk'" />
					<xsl:with-param name="value" select = "@label__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'betegnelse p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@label__en_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'kommentar p&#229; dansk'" />
					<xsl:with-param name="value" select = "@comment__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'anvendelsesnote p&#229; dansk'" />
					<xsl:with-param name="value" select = "@applicationNote__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'kommentar p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@comment__en_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'anvendelsesnote p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@applicationNote__en_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'eksempel p&#229; dansk'" />
					<xsl:with-param name="value" select = "@example__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'eksempel p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@example__en_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'anvendelsesnote p&#229; dansk'" />
					<xsl:with-param name="value" select = "@applicationNote__da_" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'anvendelsesnote p&#229; engelsk'" />
					<xsl:with-param name="value" select = "@applicationNote__en_" />
				</xsl:call-template>
				
				<!-- modeller -->
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'namespace'" />
					<xsl:with-param name="value" select = "@namespace" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'namespacePrefix'" />
					<xsl:with-param name="value" select = "@namespacePrefix" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'Modelejer'" />
					<xsl:with-param name="value" select = "@publisher" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'emne'" />
					<xsl:with-param name="value" select = "@theme" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'seneste opdateringsdato'" />
					<xsl:with-param name="value" select = "@modified" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'versionsnummer'" />
					<xsl:with-param name="value" select = "@versionInfo" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'godkendelsesstatus'" />
					<xsl:with-param name="value" select = "@approvalStatus" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'modelstatus'" />
					<xsl:with-param name="value" select = "@modelStatus" />
				</xsl:call-template>
				
				<!-- klasser og modeller -->
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'juridisk kilde'" />
					<xsl:with-param name="value" select = "@legalSource" />
				</xsl:call-template>
				
				<!-- klasser -->
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'kilde'" />
					<xsl:with-param name="value" select = "@source" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'was derived from'" />
					<xsl:with-param name="value" select = "@wasDerivedFrom" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'sub class of'" />
					<xsl:with-param name="value" select = "@subClassOf" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'equivalent class'" />
					<xsl:with-param name="value" select = "@equivalentClass" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'is defined by'" />
					<xsl:with-param name="value" select = "@isDefinedBy" />
				</xsl:call-template>
				
				<!-- Properties -->
				<!-- <xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'functional property'" />
					<xsl:with-param name="value" select = "@functionalProperty" />
				</xsl:call-template>
				 -->
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'r&#230;kkevidde'" />
					<xsl:with-param name="value" select = "@range" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'dom&#230;ne'" />
					<xsl:with-param name="value" select = "@domain" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'sub property of'" />
					<xsl:with-param name="value" select = "@subPropertyOf" />
				</xsl:call-template>
				
				<xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'equivalent property'" />
					<xsl:with-param name="value" select = "@eguivalientProperty" />
				</xsl:call-template>
				
				<!-- Object Properties -->
				 <!-- <xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'inverseFunctionalProperty'" />
					<xsl:with-param name="value" select = "@inverseFunctionalProperty" />
				</xsl:call-template>
				-->
				 <!-- <xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'transitiveProperty'" />
					<xsl:with-param name="value" select = "@transitiveProperty" />
				</xsl:call-template>
				-->
				 <!-- <xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'inverseOf'" />
					<xsl:with-param name="value" select = "@inverseOf" />
				</xsl:call-template>
				-->
				<!-- <xsl:call-template name="tableRow">
					<xsl:with-param name="text" select = "'symmetricProperty'" />
					<xsl:with-param name="value" select = "@symmetricProperty" />
				</xsl:call-template>
				-->
			</table>
			</div>
	</xsl:template>
	
	
	<xsl:template name="tableRow">
	 	<xsl:param name = "text" />
	 	<xsl:param name = "value" />
	 	<xsl:if test="($value!='') and ($value!='$ea_notes=') and ($value!='Type=Date;')">
	 	
	 	<tr>
				<td style="border: 1px solid #bbb;"><xsl:value-of select="$text" /></td>
				<td style="border: 1px solid #bbb;"><xsl:value-of select="$value" /></td>
			</tr>
		</xsl:if>
	</xsl:template>
	
	<!-- tegn et diagram -->
	<xsl:template match="//umldi:Diagram">
	
		<!-- beregn diagrammets bredde -->
		<!-- diagrammer med få elementer skaleres op og får meget store elementer -workaround kunn være at placere en mindre usynlig ting langt mod højre...
		eller lave en max på bredde og højde -->
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
		<h2>Diagram:<xsl:value-of select="/xmi:XMI/xmi:Extension/diagrams/diagram[@xmi:id=current()/@xmi:id]/properties/@name" /></h2>

		<!-- tegn diagram vha svg--> 
		<svg contentscripttype="text/ecmascript"  viewBox="0 0 {$bredde +6} {$hoejde +6}" contentstyletype="text/css" id="svg4155" preserveAspectRatio="xMidYMid meet" version="1.1" width="90%" >
			
			<!-- loop over alle klasseelementer i diagrammet-->		
			<xsl:for-each select="./ownedElement[@xmi:type='umldi:UMLClassifierShape' or @xmi:type='umldi:UMLCompartmentableShape']">
			
				<!-- lav variabel, der bekendtgør kasseslags - klassifkasse, klassekasse, begrebskasse
				- brug den til at styre tværsteg, ornamenter, farver, html:class -->


	
			
			<!-- detekter kassetype, skriv variabel -->
			<xsl:variable name="kassetype"> 
				<xsl:choose>
				<!-- hvis kassen er en klassifikationskasse-->
					<xsl:when test="(//packagedElement[@xmi:id=current()/@modelElement]/@xmi:type = 'uml:Class') and (contains( //FDAprofil:ModelElement[@base_Class=current()/@modelElement]/@subClassOf,'http://www.w3.org/2004/02/skos/core#Concept') or (local-name(//FDAprofil:*[@base_Package=//packagedElement[@xmi:id=current()/@modelElement]/../@xmi:id]) = 'ClassificationModel'))">
								<xsl:value-of select="'klassifikationskasse'"/>
					</xsl:when>
					<!-- hvis kassen er en begrebskasse-->
					<xsl:when test="local-name(//*[@base_Element=current()/@modelElement])='Concept'">
								<xsl:value-of select="'begrebskasse'"/>
					</xsl:when>
					<!-- hvis kassen er en instans-->
					<xsl:when test="//packagedElement[@xmi:id=current()/@modelElement]/@xmi:type='uml:InstanceSpecification'">
								<xsl:value-of select="'instans'"/>
					</xsl:when>
					<!-- så må det være en UMLklasse-->
						<xsl:otherwise>
							<xsl:value-of  select="'UMLklasse'"/>
					</xsl:otherwise>
				</xsl:choose>

				</xsl:variable>
	<!-- Lav link til ned i rapporten -->
<!-- find elementets reference til rapporten -->
				<xsl:variable name="elementRef" select="//FDAprofil:*[@base_Element=current()/@modelElement]/@URI"/>


			<!-- Nogle elementer har # i id andre har ikke - derfor må vi finde teksten efter '#' eller sidste '/' -->
				



	<xsl:variable name="linktext"> 
			<xsl:choose> 	<!--Hvis uri eksisterer findes enten text efter # eller efter sidste / -->	
					<xsl:when test="$elementRef">
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
					</xsl:when>
					<!-- Hvis Uri ikke eksisterer bruges klassenavnet -->
					<xsl:otherwise>
						<xsl:value-of select="//*[@xmi:id=current()/@modelElement]/@name"/>
					</xsl:otherwise>
			</xsl:choose>
		</xsl:variable> 



					<!-- find en god farve til kasserne -->
				<xsl:variable name="fyldfarve"> 
				<xsl:choose>
				<!-- hvis kassen er en klassifikationskasse-->
					<xsl:when test="$kassetype='klassifikationskasse'">
								<xsl:value-of select="$klassifikationfarve"/>
					</xsl:when>
					<!-- hvis kassen er en begrebskasse-->
					<xsl:when test="$kassetype='begrebskasse'">
								<xsl:value-of select="$begrebfarve"/>
					</xsl:when>
					<!-- hvis kassen er en instans-->
					<xsl:when test="$kassetype='instans'">
								<xsl:value-of select="$instansfarve"/>
					</xsl:when>
						<!-- så må det være en UMLklasse-->
					<xsl:otherwise>
							<xsl:value-of  select="$klassefarve"/>

					</xsl:otherwise>
				</xsl:choose>
				</xsl:variable>
					<!-- find ud af, hvor høj navnets område skal være -->
				<xsl:variable name="navnehoejde"> 
				<xsl:choose>
				<!-- hvis kassen er en klasse-->
					<xsl:when test="$kassetype='UMLklasse' or $kassetype='klassifikationskasse'">
								<xsl:value-of select="'15'"/>
					</xsl:when>
					<!-- ellers-->
					<xsl:otherwise>
							<xsl:value-of  select="./bounds/@height -5"/>

					</xsl:otherwise>
				</xsl:choose>
				</xsl:variable>
				
				<!-- find elementets definition -->
				<xsl:variable name="titlestring" select="//FDAprofil:*[@base_Element=current()/@modelElement]/@definition__da_"/>
					
				<!-- en gruppe, som indeholder et klasse-element og dets indhold - placeret ift umldi koordinaterne-->

				<g transform="translate({./bounds/@x} {./bounds/@y})">
					<!-- link til et sted i rapporten -->
					<a href="#{$linktext}">
						<!-- klassens kasse -->

						
						<!-- <rect id="{@xmi:id}" class="classcontainer" height="{./bounds/@height}" width="{./bounds/@width}" rx="5"  ry="5" fill-opacity="1" stroke-width="1" style="fill:#b7c4c8;fill-opacity:1;stroke:#000000;stroke-width:1.06500006;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;filter:url(#Graa)"> -->
						<rect id="{@xmi:id}" class="classcontainer" onmouseover="this.style.filter = 'url(#diskret-neutral)'" onmousedown="this.style.filter = 'url(#diskret-depressed)'" onmouseout="this.style.filter = 'url(#diskret)'" height="{./bounds/@height}" width="{./bounds/@width}" rx="5"  ry="5" fill-opacity="1" stroke-width="1" style="fill:{$fyldfarve};fill-opacity:1;stroke:#000000;stroke-width:1.06500006;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4;stroke-dasharray:none;stroke-dashoffset:0;stroke-opacity:1;filter:url(#diskret)">
							<!-- mouse-over text -->
							<title><xsl:value-of select="$titlestring"/></title>
						</rect>
					</a>
					<!-- klassens tværstreg -  -->
					<xsl:if test="$kassetype='UMLklasse'  or $kassetype='klassifikationskasse'">
					<line x1="5" y1="25" x2="{./bounds/@width -5}" y2="25" stroke="darkgrey" />
					</xsl:if>
					<!-- klassenavn - elegant placeret i midten og med wrapped text vha et foreignObject, som indlejrer en html div - horisontal og vertikal centrering vha flexbox-->
					<a href="#{$linktext}">
					<foreignObject x="5" y="4" height="{$navnehoejde}" width="{./bounds/@width -5}">
						<div onmouseover="this.parentElement.parentElement.parentElement.firstChild.firstChild.style.filter = 'url(#diskret-neutral)'" onmouseout="this.parentElement.parentElement.parentElement.firstChild.firstChild.style.filter= 'url(#diskret)'" style="display:flex;   align-items: center;   justify-content: center;height:100%;width:95%"  title="{$titlestring}">
						<div onmouseover="this.parentElement.parentElement.parentElement.parentElement.firstChild.firstChild.style.filter = 'url(#diskret-neutral)'" onmouseout="this.parentElement.parentElement.parentElement.parentElement.firstChild.firstChild.style.filter = 'url(#diskret)'" style="font-size:9.5;font-weight:bold;stroke:none;text-align: center;    line-height: 10px;" title="{$titlestring}">
		
						<!-- gymnastik som kan fjerne et prefix fra klassenavn - hvis det findes --> 
						<xsl:variable name="klassenavn" select="//packagedElement[@xmi:id=current()/@modelElement]/@name"/>
						<!-- <xsl:choose> 
							<xsl:when test="(contains($klassenavn, ':'))"><xsl:value-of select="substring-after($klassenavn,':')" /></xsl:when>
							<xsl:otherwise> -->
								<xsl:value-of select="$klassenavn" />
							<!-- </xsl:otherwise>
						</xsl:choose>  -->
						</div></div>
					</foreignObject></a>
					<!-- skriv attributter -->
					<text transform="translate(11 26)">
						<xsl:for-each select="//packagedElement[@xmi:id=current()/@modelElement]/ownedAttribute[not(@association)]">
						
						<!-- increase dy for hvert loop -->
							<tspan x="0" y="{position() * 14}" font-size="10" fill="black">
								<xsl:value-of select="./@name" />
						
					</tspan>
						</xsl:for-each> 
					</text>
					
					

					<xsl:if  test="$kassetype='klassifikationskasse'">
						<use x="-50" y="-45" transform="scale(0.45)"   href="#klassifikationsikon"/>
					</xsl:if>
					
				</g>
				
			</xsl:for-each>
			<!-- pile -->
			<xsl:for-each select="./ownedElement[@xmi:type='umldi:UMLEdge']">
			
				<!-- lav en variabel indeholdende path-ens d-værdi (linjepunkter) baseret på XMI-dokumentets waypoints -->
				<xsl:variable name="dString">
					<xsl:call-template name="pathfinder">
						<xsl:with-param name="counter" select="1"/>
						<xsl:with-param name="points" select="current()/waypoint"/>
						<xsl:with-param name="PdString" select="'M '"/>
					</xsl:call-template>
				</xsl:variable>
		<!-- tegn pilen -->
				<!--vælg pilespids -->
				<xsl:choose>
					<xsl:when test="(//*[@xmi:id=current()/@modelElement]/@xmi:type='uml:Generalization')">
									<path fill="none" stroke="black" d="{$dString}" style="marker-end:url(#EmptyTriangleInL)"/>
					</xsl:when>
					<xsl:when test="(//*[@association=current()/@modelElement]/@aggregation='shared')">
									<path fill="none" stroke="black" d="{$dString}" style="marker-end:url(#EmptyDiamondLend)"/>
					</xsl:when>
					<xsl:when test="(//*[@association=current()/@modelElement]/@aggregation='composite')">
									<path fill="none" stroke="black" d="{$dString}" style="marker-end:url(#DiamondL)"/>
					</xsl:when>
					<xsl:otherwise>
								<path fill="none" stroke="black" d="{$dString}" style="marker-end:url(#Arrow2Mend)"/>
					
					</xsl:otherwise>
				</xsl:choose>

		
					<!-- associationsnavne -->
					<xsl:for-each select="./ownedElement[@xmi:type='umldi:UMLNameLabel']">
						<text x="{./bounds/@x - 2}" y="{./bounds/@y + 8}" font-size="9" ><xsl:value-of select="./@text"/></text>
					</xsl:for-each>						
					<!-- associationsender -->
					<xsl:for-each select="./ownedElement[@xmi:type='umldi:UMLAssociationEndLabel']">
						<text x="{./bounds/@x - 2}" y="{./bounds/@y + 8}" font-size="9" ><xsl:value-of select="./@text"/></text>
					</xsl:for-each>		
					<!-- multipliciteter -->
					<xsl:for-each select="./ownedElement[@xmi:type='umldi:UMLMultiplicityLabel']">
						<text x="{./bounds/@x - 1}" y="{./bounds/@y+12}" font-size="12" ><xsl:value-of select="./@text"/></text>
					</xsl:for-each>		
				
			</xsl:for-each>
			<!-- notefelt - ikke i brug
			
			<xsl:for-each select="./ownedElement[@xmi:type='umldi:UMLShape']">
				<xsl:variable name="linjer">
					  <xsl:call-template name="allSpaces">
  						<xsl:with-param name="chopString" select="//ownedComment['xmi:id=current()/@modelElement']/@body"/> -->
  						<!-- <xsl:with-param name="resultString" select=" concat(' ',' ')"/> -->
  					<!--	</xsl:call-template>
				</xsl:variable>
					<g x="{./bounds/@x}" y="{./bounds/@y}">
						<rect  rx="5" ry="5" height="{./bounds/@height}" width="{./bounds/@width}" style="fill:#ffffff;fill-opacity:1;stroke:#000000;stroke-width:1.06500006;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:4;"/> -->
						 <!-- <foreignObject x="7" y="15" width="{./bounds/@width}" height="{./bounds/@height}">
						<div style="white-space:nowrap"><xsl:value-of select="translate(translate(//ownedComment['xmi:id=current()/@modelElement']/@body, ' ','&#160;'),'&#xA;','hat')"></xsl:value-of></div>
						</foreignObject> -->
						<!-- <xsl:value-of select="$linjer" />
					</g>
				</xsl:for-each>	
				-->

	<!-- Hent en masse styling -->
	<xsl:call-template name="indsaet_definitioner"/>
	
		</svg>
	</xsl:template>	
	<!-- ? -->
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
  
  
  <!-- template til at opsplitte namespaceboxen 
  <xsl:template name="allSpaces">
  	<xsl:param name="chopString"/>
  	<xsl:param name="resultString"/>
  	<xsl:choose>
  		<xsl:when test="contains($chopString, '&#xA;')">
  			<xsl:call-template name="allSpaces">
  				<xsl:with-param name="chopString" select="substring-after($chopString, '&#xA;')"/>
  				<text><xsl:value-of select="substring-before($chopString, '&#xA;')"/></text> -->
  				<!-- <xsl:with-param name="resultString" select="concat($resultString,'&lt;text&gt;',substring-before($chopString, '&#xA;'),'&lt;/text&gt;')"/> -->
  		<!-- 	</xsl:call-template>
  		</xsl:when>
  		<xsl:otherwise>
  			<xsl:value-of select="concat($resultString, $chopString)"/>
  		</xsl:otherwise>
  	
  	</xsl:choose>
  </xsl:template> -->
  
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
        <feDistantLight id="feDistantLight4743" elevation="40" azimuth="225"></feDistantLight>
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
     <filter

       style="color-interpolation-filters:sRGB;"
       id="diskret">
      <feColorMatrix
         result="result2"
         type="luminanceToAlpha"
         in="SourceGraphic"
         id="feColorMatrix1263" />
      <feSpecularLighting
         specularConstant="0.5"
         surfaceScale="-15"
         specularExponent="10"
         result="result10"
         id="feSpecularLighting1267">
        <feDistantLight
           elevation="20"
           azimuth="225"
           id="feDistantLight1265" />
      </feSpecularLighting>
      <feDiffuseLighting
         diffuseConstant="0.5"
         surfaceScale="15"
         id="feDiffuseLighting1271">
        <feDistantLight
           azimuth="225"
           elevation="4"
           id="feDistantLight1269" />
				</feDiffuseLighting>
      <feComposite
         result="result11"
         in2="result10"
         operator="arithmetic"
         k2="0.5"
         k3="0.5"
         id="feComposite1273" />
	    <feComposite
         in="result11"
         result="result9"
         operator="arithmetic"
         k2="1"
         k3="1"
         in2="SourceGraphic"
         id="feComposite1275" />
      <feComposite
         in2="SourceGraphic"
         operator="in"
         in="result9"
         id="feComposite1277"
         result="fbSourceGraphic" />
      <feColorMatrix
         result="fbSourceGraphicAlpha"
         in="fbSourceGraphic"
         values="0 0 0 -1 0 0 0 0 -1 0 0 0 0 -1 0 0 0 0 1 0"
         id="feColorMatrix1281" />
      <feFlood
         id="feFlood1283"
         flood-opacity="0.498039"
         flood-color="rgb(0,0,0)"
         result="flood"
         in="fbSourceGraphic" />
      <feComposite
         in2="fbSourceGraphic"
         id="feComposite1285"
         in="flood"
         operator="in"
         result="composite1" />
      <feGaussianBlur
         id="feGaussianBlur1287"
         in="composite1"
         stdDeviation="1"
         result="blur" />
      <feOffset
         id="feOffset1289"
         dx="1"
         dy="1"
         result="offset" />
      <feComposite
         in2="offset"
         id="feComposite1291"
         in="fbSourceGraphic"
         operator="over"
         result="composite2" />
    </filter>
		<filter

       style="color-interpolation-filters:sRGB;"
       id="diskret-depressed">
      <feColorMatrix
         result="result2"
         type="luminanceToAlpha"
         in="SourceGraphic"
         id="feColorMatrix1263" />
      <feSpecularLighting
         specularConstant="0.5"
         surfaceScale="-15"
         specularExponent="10"
         result="result10"
         id="feSpecularLighting1267">
        <feDistantLight
           elevation="20"
           azimuth="225"
           id="feDistantLight1265" />
      </feSpecularLighting>
      <feDiffuseLighting
         diffuseConstant="0.5"
         surfaceScale="0"
         id="feDiffuseLighting1271">
        <feDistantLight
           azimuth="225"
           elevation="0"
           id="feDistantLight1270" />
					 
      </feDiffuseLighting>
      <feComposite
         result="result11"
         in2="result10"
         operator="arithmetic"
         k2="0.5"
         k3="0.5"
         id="feComposite1272" />
				 			 <animate xlink:href="#feComposite12" id="anim-ddd" attributeName="k2" from="0.4" to="1.5" dur="1s" fill="freeze" repeatCount="indefinite"></animate>
  
      <feComposite
         in="result11"
         result="result9"
         operator="arithmetic"
         k2="1"
         k3="1"
         in2="SourceGraphic"
         id="feComposite1275" />
      <feComposite
         in2="SourceGraphic"
         operator="in"
         in="result9"
         id="feComposite1277"
         result="fbSourceGraphic" />
      <feColorMatrix
         result="fbSourceGraphicAlpha"
         in="fbSourceGraphic"
         values="0 0 0 -1 0 0 0 0 -1 0 0 0 0 -1 0 0 0 0 1 0"
         id="feColorMatrix1281" />
      <feFlood
         id="feFlood1283"
         flood-opacity="0.498039"
         flood-color="rgb(0,0,0)"
         result="flood"
         in="fbSourceGraphic" />
      <feComposite
         in2="fbSourceGraphic"
         id="feComposite1285"
         in="flood"
         operator="in"
         result="composite1" />
      <feGaussianBlur
         id="feGaussianBlur1287"
         in="composite1"
         stdDeviation="1"
         result="blur" />
      <feOffset
         id="feOffset1289"
         dx="-1"
         dy="-1"
         result="offset" />
      <feComposite
         in2="offset"
         id="feComposite1291"
         in="fbSourceGraphic"
         operator="over"
         result="composite2" />
    </filter>
	<filter

       style="color-interpolation-filters:sRGB;"
       id="diskret-neutral">
      <feColorMatrix
         result="result2"
         type="luminanceToAlpha"
         in="SourceGraphic"
         id="feColorMatrix1263" />
      <feSpecularLighting
         specularConstant="0.5"
         surfaceScale="-15"
         specularExponent="10"
         result="result10"
         id="feSpecularLighting1267">
        <feDistantLight
           elevation="20"
           azimuth="225"
           id="feDistantLight1265" />
      </feSpecularLighting>
      <feDiffuseLighting
         diffuseConstant="0.5"
         surfaceScale="0"
         id="feDiffuseLighting1271">
        <feDistantLight
           azimuth="225"
           elevation="0"
           id="feDistantLight1270" />
					 
      </feDiffuseLighting>
      <feComposite
         result="result11"
         in2="result10"
         operator="arithmetic"
         k2="0.5"
         k3="0.5"
         id="feComposite1272" />
				 			 <animate xlink:href="#feComposite12" id="anim-ddd" attributeName="k2" from="0.4" to="1.5" dur="1s" fill="freeze" repeatCount="indefinite"></animate>
  
      <feComposite
         in="result11"
         result="result9"
         operator="arithmetic"
         k2="1"
         k3="1"
         in2="SourceGraphic"
         id="feComposite1275" />
      <feComposite
         in2="SourceGraphic"
         operator="in"
         in="result9"
         id="feComposite1277"
         result="fbSourceGraphic" />
      <feColorMatrix
         result="fbSourceGraphicAlpha"
         in="fbSourceGraphic"
         values="0 0 0 -1 0 0 0 0 -1 0 0 0 0 -1 0 0 0 0 1 0"
         id="feColorMatrix1281" />
      <feFlood
         id="feFlood1283"
         flood-opacity="0.498039"
         flood-color="rgb(0,0,0)"
         result="flood"
         in="fbSourceGraphic" />
      <feComposite
         in2="fbSourceGraphic"
         id="feComposite1285"
         in="flood"
         operator="in"
         result="composite1" />
      <feGaussianBlur
         id="feGaussianBlur1287"
         in="composite1"
         stdDeviation="0"
         result="blur" />
      <feOffset
         id="feOffset1289"
         dx="0"
         dy="0"
         result="offset" />
      <feComposite
         in2="offset"
         id="feComposite1291"
         in="fbSourceGraphic"
         operator="over"
         result="composite2" />
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
  
  <!-- pilespidser -->
      <marker
       orient="auto"
       refY="0.0"
       refX="0.0"
       id="Arrow2Mend"
       style="overflow:visible;"
       >
      <path
         id="path846"
         style="fill-rule:evenodd;stroke-width:0.625;stroke-linejoin:round;stroke:#000000;stroke-opacity:1;fill:#000000;fill-opacity:1"
         d="M 5.77,0.0 L -2.88,5.0 M -2.88,-5.0 L 5.77,0.0 "
         transform="scale(1.6) rotate(0) translate(-5.77,0)" />
    </marker>
		<marker
       orient="auto"
       refY="0.0"
       refX="0.0"
       id="EmptyTriangleInL"
       style="overflow:visible">
       <path
         id="path968"
         d="M 5.77,0.0 L -2.88,5.0 L -2.88,-5.0 L 5.77,0.0 z "
         style="fill-rule:evenodd;fill:#ffffff;stroke:#000000;stroke-width:1pt;stroke-opacity:1"
         transform="scale(-1.2,-1) rotate(180) translate(-6,0)" />
    </marker>
		    <marker
       orient="auto"
       refY="0.0"
       refX="0.0"
       id="EmptyDiamondLend"
       style="overflow:visible">
      <path
         id="path941"
         d="M 0,-7.0710768 L -7.0710894,0 L 0,7.0710589 L 7.0710462,0 L 0,-7.0710768 z "
         style="fill-rule:evenodd;fill:#ffffff;stroke:#000000;stroke-width:1pt;stroke-opacity:1"
         transform="scale(1.2,0.8) translate(-7,0)" />
    </marker>
		 <marker
       orient="auto"
       refY="0.0"
       refX="0.0"
       id="DiamondL"
       style="overflow:visible">
      <path
         id="path896"
         d="M 0,-7.0710768 L -7.0710894,0 L 0,7.0710589 L 7.0710462,0 L 0,-7.0710768 z "
         style="fill-rule:evenodd;stroke:#000000;stroke-width:1pt;stroke-opacity:1;fill:#000000;fill-opacity:1"
         transform="scale(1.2,0.8) translate(-7,0)" />
    </marker>
  </defs>
  
  </xsl:template>
	
</xsl:stylesheet>

