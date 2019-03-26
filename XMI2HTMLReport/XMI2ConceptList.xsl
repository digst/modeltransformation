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
	xmlns:xlink="https://www.w3.org/1999/xlink" 
	exclude-result-prefixes="xsl rdf rdfs owl dc uml xmi thecustomprofile Grunddata GML Plusprofil OWL umldi my svg">

	<!-- Specificer, at outputtet af transformationen er et html-dokument -->
	<xsl:output method="html" omit-xml-declaration="yes" indent="yes" encoding="UTF-8" />
	
	<!-- 'keys' som hjælper med at fjerne dublikater længere nede -->
	<xsl:key name="x" match="@name" use="." />
	<xsl:key name="y" match="@name" use="." />

<xsl:variable name="klassefarve" select="'#C4C0C0'"/>
<xsl:variable name="begrebfarve" select="'#F5B7B1'"/>
<xsl:variable name="klassifikationfarve" select="'#EDBB99'"/>
<xsl:variable name="instansfarve" select="'#FAD7A0'"/>
<xsl:variable name="divfarve" select="'#CCC'"/>



<!-- match alt  -->
	<xsl:template match="/">
	<!-- templaten skriver HTML-dokumentet p&#229; basis af modelpakken -->
	
	   
	        
	        
	<html>
	
		<body  style="padding: 0px; font-family: Ubuntu, sans-serif;background-color: #eee">
		<!--fang pakker og send til pakketemplate -->
		<xsl:apply-templates select="//uml:Model/packagedElement[@xmi:type='uml:Package']"/>
	</body></html>
	</xsl:template>
	<!-- Her skal udvikles for at tage højde for underpakker -->
	<!-- Pakkens template, som styrer target-dokumentetes struktur -->
	<xsl:template match="//uml:Model/packagedElement[@xmi:type='uml:Package']">
	
		
		<!-- indsæt modelpakkens navn -->
		<h1>Model:<xsl:value-of select="./@name" /></h1>
		
		<!-- skriv pakkens egenskaber/tags -->
		<!-- find det entry i profileringsblokken, som matcher modelpakkens (current node) id  og send til tabelbygger templaten-->
		<!-- fang alle modeltyper (vocab, ap, kerne, am) -->
	
	

	
	<!-- Start kassebyggertemplaten med hhv begreber, klasser og klassifikationer -->
		<!-- <xsl:value-of select="//Plusprofil:*[@base_Package=current()/@xmi:id]" /> -->
		<!-- hvis der er begreber i pakken -->
	<xsl:if test="//Plusprofil:RdfsResource[not(@subClassOf='http://www.w3.org/2004/02/skos/core#Concept')]">
				<h2>Begreber:</h2>
            <table style="border-collapse: collapse;width:80%;margin-bottom: 1em;">
                <tr><th>Accepteret Term</th><th>Alternative termer</th><th>Definition</th><th>Kommentar</th><th>Kilde</th></tr>
			<xsl:for-each select="//Plusprofil:RdfsResource[not(@subClassOf='http://www.w3.org/2004/02/skos/core#Concept')]">
			<xsl:apply-templates select="//packagedElement[@xmi:id=current()/@base_Element]" >
		 <xsl:with-param name="elementslags" select = "'Begreb'" />
			</xsl:apply-templates>

		</xsl:for-each>
     </table>
	</xsl:if>

	</xsl:template>
	
		
	<!-- template som fanger klasser  og skriver klasse-elementer, klassifikationselementer  og begrebselementer-->
	 <xsl:template match="packagedElement[@xmi:type='uml:Class']">

			 <xsl:param name = "elementslags" />


        <tr>
            <td style="border: 1px solid #bbb;">
            						<!-- hvis der er : i klassenavnet, skriv efter-delen, ellers skriv hele navnet -->
						<xsl:choose>
							<xsl:when test="(contains(./@name, ':'))">
								<xsl:value-of select="substring-after(./@name,':')" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="./@name" />
							</xsl:otherwise>
						</xsl:choose>
                        <xsl:if test="//element[@xmi:idref=current()/@xmi:id]/properties/@alias">
					<span class="klassealias" style="color: #1d83cf;font-size: smaller;margin-left: .6em;font-weight: normal;">(<xsl:value-of select="//element[@xmi:idref=current()/@xmi:id]/properties/@alias" />)</span>
				</xsl:if>
            </td>
            <td style="border: 1px solid #bbb;">
             <xsl:value-of select="//Plusprofil:RdfsResource[@base_Element=current()/@xmi:id]/@altLabel__da_"/>  
            </td>
            <td style="border: 1px solid #bbb;">
                <xsl:value-of select="//Plusprofil:RdfsResource[@base_Element=current()/@xmi:id]/@definition__da_"/>
            </td>
            <td style="border: 1px solid #bbb;">
             <xsl:value-of select="//Plusprofil:RdfsResource[@base_Element=current()/@xmi:id]/@comment__da_"/> 
            </td>
            <td style="border: 1px solid #bbb;">
             <xsl:value-of select="//Plusprofil:RdfsResource[@base_Element=current()/@xmi:id]/@source"/>  
            </td>
        </tr>
        
	<xsl:for-each  select="./ownedAttribute[(@association) and not(@name)]">
        <tr  style="background-color:#ddd;font-size: smaller;">    
			<td style="border: 1px solid #bbb;padding-left: 1em;">
                <span style="font-style: italic;">					
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
				<!-- skriv modtagerklassens navn -->
                </span>
				&#8194;&#8680;&#8194;<xsl:value-of select="//packagedElement[@xmi:id=current()/type/@xmi:idref]/@name" />
				<!-- og dens alias -->
						<xsl:if test="//element[@xmi:idref=current()/type/@xmi:idref]/properties/@alias">
								<span class="modtageralias">&#8194;(<xsl:value-of select="//element[@xmi:idref=current()/type/@xmi:idref]/properties/@alias" />)</span>
						</xsl:if>
				<!-- skriv multiplicitet  -->		
				<xsl:if test="./lowerValue">
					<span class="multiplicitet" style="font-size: 75%;font-style:italic;">&#8194;&#8194;&#8194;&#8194;Multiplicitet:  [<xsl:value-of select="./lowerValue/@value" />..<xsl:value-of select="./upperValue/@value" />]</span>
				</xsl:if>
				
			</td>
            <td style="border: 1px solid #bbb;">
             <xsl:value-of select="//Plusprofil:RdfsResource[@base_Element=current()/@association]/@altLabel__da_"/>  
            </td>
            <td style="border: 1px solid #bbb;">
                <xsl:value-of select="//Plusprofil:RdfsResource[@base_Element=current()/@association]/@definition__da_"/>
            </td>
            <td style="border: 1px solid #bbb;">
             <xsl:value-of select="//Plusprofil:RdfsResource[@base_Element=current()/@association]/@comment__da_"/> 
            </td>
            <td style="border: 1px solid #bbb;">
             <xsl:value-of select="//Plusprofil:RdfsResource[@base_Element=current()/@association]/@source"/>  
            </td>
		</tr>
		</xsl:for-each>



	</xsl:template>	

</xsl:stylesheet>

