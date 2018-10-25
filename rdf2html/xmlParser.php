<?php

if(isset($_POST['inputfile'])){
    $inputfile = urldecode($_POST['inputfile']); 
}
if(isset($_POST['sheet'])){
    $sheet = $_POST['sheet'];
}

$url_ssl = substr($inputfile, 0, 19);
$url = substr($inputfile, 0, 18);

if($url_ssl == 'https://data.gov.dk'){
    // Load local XML file
    $xml = new DOMDocument;
    $xml->load('../'.substr($inputfile, 20));
}else if($url == 'http://data.gov.dk'){
    // Load local XML file
    $xml = new DOMDocument;
    $xml->load('../'.substr($inputfile, 19));
}else{
    // Load external XML file
    $xml = new DOMDocument;
    $xml->load($inputfile);
}

// Load XSL file
$xsl = new DOMDocument;
$xsl->load($sheet);

// Configure the transformer
$proc = new XSLTProcessor;

// Attach the xsl rules
$proc->importStyleSheet($xsl);

echo $proc->transformToXML($xml);
?>