@USE
page.p



@auto[]
$oPage[^page::init[]]

^oPage.setDoctype[html5]



@main[]
^oPage.build[]



@body[]
^pageContent[]



@sampleMenu[]
^oPage.navigationItem[
	$.root[/]
	$.inner[/inner.html]
	$.title[Home]
	$.templates[
		$.normal[<big><a href="%root%">%title%</a></big>]
		$.current[<big><b>%title%</b></big>]
		$.parent[<big><a href="%root%"><b>%title%</b></a></big>]
	]
]
^oPage.navigationItem[
	$.root[/inner.html]
	$.title[Inner]
]