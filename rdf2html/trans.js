	//Hent URL-parametre 
	var params={};window.location.search.replace(/[?&]+([^=&]+)=([^&]*)/gi,function(str,key,value){params[key] = value;});

	$(document).ready(function() {
		if(params.model){	displayResult();}
	})
	
	function displayResult()
	{		
			console.log("22")
				$.post("xmlParser.php", {inputfile: params.model,sheet: params.sheet}, 
					function(data, status){
						$("#resultatdiv").empty();
						//indsæt resultat i dokument
						$("#resultatdiv").html(data);
						
					}, "html");		   
	}

