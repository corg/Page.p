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

$doctype[$hDoctypes.html5]



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
		^if(^isFileLinkable[$cssFiles.uri]){
			$sLink[<link rel="stylesheet" type="text/css" href="$cssFiles.uri" />]
			^if(def $cssFiles.condition){
				$sLink[<!--[if $cssFiles.condition]>$sLink<![endif]-->]
			}
			$result[${result}$sLink]
		}
	}
}
^if(def $sHeadStyle){
	$result[${result}<style>$sHeadStyle</style>]
	
}



@includeJs[][sLink]
^if($jsFiles > 0){
	^jsFiles.menu{
		^if(^isFileLinkable[$cssFiles.uri]){
			$sLink[<script type="text/javascript" src="$jsFiles.uri"></script>]
			^if(def $jsFiles.condition){
				$sLink[<!--[if $jsFiles.condition]>$sLink<![endif]-->]
			}
			$result[${result}$sLink]
		}
	}
}



@addStyle[sStyle]
^if(def $sStyle){
	$sStyle[^normalize[$sStyle]]
	^if(def $sHeadStyle){
		$sHeadStyle[$sHeadStyle
$sStyle]
	}{
		$sHeadStyle[$sStyle]
	}
}



@isFileLinkable[sFile]
$result(-f $cssFiles.uri || ^cssFiles.uri.left(7) eq 'http://' || ^cssFiles.uri.left(8) eq 'https://')



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



@navigationItem[hConfig][locals]
# removing query string from URI 
$sUri[^request:uri.match[\?.*][]{}]

$hConfig[^hash::create[$hConfig]]
^if(!def $hConfig.selected_class){
	$hConfig.selected_class[selected]
}

$sState[normal]

^if(def $hConfig.root){
	$tRoot[^table::create{uri
$hConfig.root}]

	^tRoot.menu{
		$sTestUri[$sUri]
		^if(^sTestUri.right(1) eq '/'){
			$sTestUri[${sTestUri}index.html]
		}
		$sTestRootUri[$tRoot.uri]
		^if(^sTestRootUri.right(1) eq '/'){
			$sTestRootUri[${sTestRootUri}index.html]
		}
		
		^if($sTestUri eq $sTestRootUri){
			$sState[current]
			^break[]
		}
	}
}

^if($sState ne 'current'){
	^if(def $hConfig.inner){
		$tInner[^table::create{uri
$hConfig.inner}]
	
		^tInner.menu{
			$sTestUri[$sUri]
			^if(^sTestUri.right(1) eq '/'){
				$sTestUri[${sTestUri}index.html]
			}
			$sTestRootUri[$tInner.uri]
			^if(^sTestRootUri.right(1) eq '/'){
				$sTestRootUri[${sTestRootUri}index.html]
			}
			
			^if($sTestUri eq $sTestRootUri){
				$sState[parent]
				^break[]
			}
		}
	}{
		^if(def $hConfig.root){
			^tRoot.menu{
				^if(^sUri.pos[$hConfig.root] == 0){
					$sState[parent]
					^break[]
				}
			}
		}
	}
}

$hTemplates[
	$.normal[
		<li class="%class%">
			<a href="%root%">%title%</a>
		</li>
	]
	$.current[
		<li class="%class% %selected_class%">
			<b class="selected">%title%</b>
		</li>
	]
	$.parent[
		<li class="%class% %selected_class%">
			<a class="selected" href="%root%">%title%</a>
		</li>
	]
]

^if($hConfig.templates is 'hash'){
	$hTemplates[^hConfig.templates.union[$hTemplates]]
}

$result[
	^hTemplates.[$sState].match[%([^^%]*)%][g]{$hConfig.[$match.1]}
]