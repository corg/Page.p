@CLASS
page



@init[]
$bodyClass[^table::create{class}]
$hDoctypes[
	$.xhtml1strict[<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">]
	$.html5[<!DOCTYPE html>]
]
^clearCssFiles[]
^clearJsFiles[]



@clearCssFiles[]
$cssFiles[^table::create{uri	condition}]



@clearJsFiles[]
$jsFiles[^table::create{uri	condition}]



@setDoctype[sDoctype]
^if(def $hDoctypes.[$sDoctype]){
	$doctype[$hDoctypes.[$sDoctype]]
}
^if($sDoctype eq 'xhtml1strict'){
	^setDefaultXmlns[]
}


@setDefaultXmlns[]
$xmlns[http://www.w3.org/1999/xhtml]


@build[]
^applyContent[]
^if(^isModeXml[]){
	^buildXml[]
}{
	^buildHtml[]
}


@buildXml[][xDoc]
$xDoc[^xmlContent[]]
$response:content-type[
	$.value[text/xml]
	$.charset[$response:charset]
]
$response:body[^xDoc.string[]]



@buildHtml[]
$response:body[^if(def $doctype){$doctype}
<html^if(def $xmlns){ xmlns="$xmlns"}>
<head>
	<meta http-equiv="Content-Type" content="text/html^; charset=UTF-8" />
	^if($self.emulateIe7){
		<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
	}
	<title>$title</title>
	^includeCss[]
	^includeJs[]
#	$sHeadAddon
</head>
<body^if(def $bodyId){ id="$bodyId"}^if($bodyClass > 0){ class="^bodyClassString[]"}^if(def $bodyOnLoad){ onload="$bodyOnLoad"}>
	$body
#	$sBodyAddon
# test comment
</body>
</html>]




@includeCss[][sLink]
^if($cssFiles > 0){
	^cssFiles.menu{
		^if(-f $cssFiles.uri){
			$sLink[<link rel="stylesheet" type="text/css" href="$cssFiles.uri" />]
			^if(def $cssFiles.condition){
				$sLink[<!--[if $cssFiles.condition]>$sLink<![endif]-->]
			}
			$result[${result}$sLink]
		}
	}
}



@includeJs[][sLink]
^if($jsFiles > 0){
	^jsFiles.menu{
		^if(-f $jsFiles.uri){
			$sLink[<script type="text/javascript" src="$jsFiles.uri"></script>]
			^if(def $jsFiles.condition){
				$sLink[<!--[if $jsFiles.condition]>$sLink<![endif]-->]
			}
			$result[${result}$sLink]
		}
	}
}



@bodyClassString[][_t]
$_t[^table::create{class}]
^bodyClass.menu{
	^if(!^_t.locate[class;$bodyClass.class]){
		^_t.append{$bodyClass.class}
	}
}
^if($_t > 0){
	$result[^_t.menu{$_t.class}[ ]]
}



@applyContent[][xDoc]
$body[^MAIN:body[]]
^if(def $template && !^isModeXml[]){
	$xDoc[^xmlContent[]]
	^MAIN:oFilm.parseFilmLinks[$xDoc]
	^if(def $save){^xDoc.save[$save]}
	$xDoc[^xDoc.transform[${templatesPath}$template]]
	$body[^xDoc.string[
		$.method[html]
		$.indent[yes]
	]]
	$body[^body.replace[^table::create{from	to
&amp^;	&}]]
}



@xmlContent[]
$result[^xdoc::create{<?xml version="1.0" encoding="utf-8"?>
<document>
	^body.replace[^table::create{from	to
&	&amp^;}]
</document>}]



@normalize[s]
$result[^s.match[[\n|\t]][g]{}]



@isModeXml[]
$result($form:mode eq 'xml')



@isDeveloper[][locals]
$tDeveloperIps[^table::load[$MAIN:DATA_DIR/developer_ips.cfg]]
$result(false)
^if($tDeveloperIps){
	^if(^tDeveloperIps.locate[address;$env:REMOTE_ADDR] && ^tDeveloperIps.address.match[^^^taint[regex][$tDeveloperIps.address]^$]){
		$result(true)
	} 
}


@isModePreview[][locals]
$result($form:mode eq 'preview' && ^isDeveloper[])