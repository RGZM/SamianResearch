<!--- Postgresql extension:
create extension cube;
create extension earthdistance;
select (point(-0.1277,51.5073) <@> point(-74.006,40.7144)) as distance;

note: convert to kilometers via *0.621371192
--->

<cfparam name="distance" default = "">
<cfparam name="site" default = "">
<cfparam name="selectpottername" default = "">
<cfparam name="selectdie" default = "">

<cfparam name="selectMinimumNumberOfFinds" default = "">

<cfparam name="selectProductioncentre" default = "">

<cfparam name="selectDensity" default = "">
<cfparam name="temppots" default = "">
<cfparam name="tempdies" default = "">

<cfparam name="ExpectedToSite" default = "">
<cfparam name="ExpectedFromSite" default = "">

<cfparam name="StatisticalValue" default = "">
<cfparam name="ChiSquareFromSite" default = "">
<cfparam name="ChiSquareToSite" default = "">
<cfparam name="StatisticalSignificant" default = "">

<cfparam name="coordinate1" default = "0.00">
<cfparam name="coordinate2" default = "0.00">
<cfparam name="subcoordinate1" default = "0.00">
<cfparam name="subcoordinate2" default = "0.00">

<cfset coordinate1="#JavaCast("double", coordinate1)#">
<cfset coordinate2="#JavaCast("double", coordinate2)#">
<cfset subcoordinate1="#JavaCast("double", subcoordinate1)#">
<cfset subcoordinate2="#JavaCast("double", subcoordinate2)#">


<cfset distancesarray=arraynew(1)>



<cfif selectdie EQ "select die">
	<cfinclude template= "ErrorMessageMissingSelectDie.cfm">
</cfif>

<cfquery name = "NumberOfDiesPotter" datasource ="IPS">
SELECT COUNT(*) AS tempdies FROM (select pottername, die
from tbldie
where pottername = '#selectPottername#'
AND die NOT LIKE '%- %'
AND die NOT LIKE '%or%') AS tmp;
</cfquery>

<cfquery name = "NumberOfPotsPotter" datasource ="IPS">
SELECT COUNT(*) AS AllExportedPotsThisPotter FROM (select pottername, die
from tbldistribution
where pottername = '#selectPottername#'
AND die NOT LIKE '%- %'
AND die NOT LIKE '%or%') AS tmp
;
</cfquery>

<cfoutput query="NumberOfPotsPotter">
<cfset tmpAllExportedPotsThisPotter = "#AllExportedPotsThisPotter#">
</cfoutput>

<cfquery name = "GetAllExport" datasource ="IPS">
SELECT COUNT(*) AS TotalExport FROM (select productioncentre, site, pottername, die
from tbldistribution
WHERE 0 = 0
AND productioncentre NOT LIKE '%'  || site || '%'
AND productioncentre LIKE '%#selectProductioncentre#%'
AND coordinate1 IS NOT NULL
AND coordinate1 <> 0
AND coordinate2 IS NOT NULL
AND coordinate2 <> 0
AND site NOT LIKE '%?%'
AND site NOT LIKE '%,%'
AND site <> 'Unknown'
) x1;
</cfquery>

<cfoutput query="GetAllExport">
<cfset tmpTotalExport = "#TotalExport#">
</cfoutput>


<cfquery name = "TotalNumberOfPotsFromSite" datasource ="IPS">
SELECT site, SUM(sumsite) AS totalpotsfromthissite FROM 
(
SELECT DISTINCT productioncentre, site, number, SUM(number) AS sumsite
FROM tbldistribution
WHERE site IN (SELECT DISTINCT  site
FROM tbldistribution
WHERE pottername = '#selectPottername#'

AND site NOT LIKE '%?%'
AND site NOT LIKE '%,%'
AND site <> 'Unknown'
GROUP BY site)
<!--- next line to skip the problem of LaGrauf products in kilnsite Rheinzabern, resulting in far too high site quantities --->
AND productioncentre NOT LIKE '%'  || site || '%' 
<!--- next line to filter on pots from this specific kilnsite on specific site in order to get e.g. All Pots From Arezzo in Augst --->
AND productioncentre LIKE '%#selectProductioncentre#%'
GROUP BY productioncentre, site, number
ORDER BY site

)
q1

GROUP BY site

;
</cfquery>



<cfquery name="getCoordinatesAndQuantities" datasource ="IPS">
SELECT pottername, <cfif selectdie NEQ "">die, </cfif> site, coordinate1, coordinate2, SUM(summevonnumber) AS totalpotsofthispotterfromsite FROM (
SELECT DISTINCT productioncentre, pottername, <cfif selectdie NEQ "">die, </cfif> site, coordinate1, coordinate2, SUM(number) AS summevonnumber
FROM tbldistribution
WHERE 0 = 0
AND productioncentre NOT LIKE '%'  || site || '%'
AND coordinate1 IS NOT NULL
AND coordinate1 <> 0
AND coordinate2 IS NOT NULL
AND coordinate2 <> 0
AND site NOT LIKE '%?%'
AND site NOT LIKE '%,%'
AND site <> 'Unknown'

GROUP BY productioncentre, pottername, <cfif selectdie NEQ "">die, </cfif> site, coordinate1, coordinate2, number
) q1

WHERE 


<cfif selectpottername NEQ "">
pottername = '#selectpottername#'
</cfif>

<cfif selectdie NEQ "">
AND die = '#selectdie#'
</cfif>

GROUP BY pottername, <cfif selectdie NEQ "">die, </cfif> site, coordinate1, coordinate2
ORDER BY site
;
</cfquery>

<cfoutput>
<cfset NumberOfFromSites = "#getCoordinatesAndQuantities.RecordCount#">
</cfoutput>

 
<cfquery dbtype="query" name="detail">
	SELECT site AS ToSite, coordinate1 AS subcoordinate1, coordinate2 AS subcoordinate2, totalpotsofthispotterfromsite
	FROM getCoordinatesAndQuantities
	where 
	<cfif selectpottername NEQ "">
	pottername = '#selectpottername#'
	</cfif>
	<cfif selectdie NEQ "">
	AND die = '#selectdie#'
	</cfif>
	ORDER BY site
</cfquery>
 
<cfset counterdistances = 0>
 
 
 
 <head>
	<style type="text/css">
		body {
			background-image: url(/ips/Grijs.gif);
		}
		.asholder
			{
				position: relative;
		}
		.unterstrich {text-decoration: underline;}
			.ueberstrich {text-decoration: overline;}
			
			.durchstrich {text-decoration: line-through;}
			.blinken {text-decoration: blink;}
			.ohneunterstrich {text-decoration: none;}
		@font-face {
			font-family: 'Samian5Book';
			src: url('/IPS/fontdownload/Samian5.ttf') format('truetype');
			unicode-range: U+E000-F8FF;
		}
		Input { font-family : Tahome,serif }
			 .normalinputfont {
			font-family : Tahoma;
			font-size : 12pt;
		}
			 .smallnormalfont {
			font-family : Tahoma;
			font-size : 10pt;
		}
			 .Sigillata {
			font-family : Samian5;
			font-size : 14pt;
		}
		a { font-family : Samian5,serif }
			 .normalfont {
			font-family : Tahoma,serif;
			font-size : 12pt;
		}
			 .smallfont {
			font-family : Tahoma,serif;
			font-size : 8pt;
		}
			 .Sigillata {
			font-family : Samian5;
			font-size : 14pt;
		}
			.unterstrich {text-decoration: underline;}
			.ueberstrich {text-decoration: overline;}
			.durchstrich {text-decoration: line-through;}
			.blinken {text-decoration: blink;}
			.ohneunterstrich {text-decoration: none;}
		Select { font-family : Tahoma, Samian5,serif }
			 .normalSelectfont {
			font-family : Tahoma, Arial;
			font-size : 12pt;
		}
			 .Sigillata {
			font-family : Samian5;
			font-size : 14pt;
		}
		Option { font-family : Tahoma, Samian5,serif }

			 .normaloptionfont {
			font-family : Tahoma,serif;
			font-size : 12pt;
		}
			 .Sigillata {
			font-family : Samian5;
			font-size : 14pt;
		}
		H1 { font-family : Tahoma,serif }

			 .normalh1font {
			font-family : Tahoma;
			font-size : 12pt;
			color : DarkSlateGray
		}
		TD { font-family : Tahmoma,serif }

			 .normalfont {
			font-family : Tahoma,serif;
			font-size : 12pt;
			}
	</style>

		<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css" />
		<link rel="stylesheet" href="css/leaflet.css" />
		<link rel="stylesheet" href="css/L.Control.ZoomBox.css">
		<link rel="stylesheet" href="css/L.Control.ZoomMin.css" media="screen">
		<link rel="stylesheet" href="easyPrint.css"/>
		
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>Trading Distribution Nodes of <cfoutput>#selectPottername#</cfoutput><i></title>
		
</head>

 
 <html>
 <body>
 
<table width="100%">
	<tr>
	<td>
<h1 class="normalh1font">Samian Research</h1>

<h2 class="normalh2font">Corpvs Vasorvm Arretinorvm
<br>
Names on Terra Sigillata</h2>
	<h2 class="normalh2font">Trading Distribution Nodes of <i><cfoutput>#selectPottername#</cfoutput></i></h2>

	</td>
<td valign="top" halign="right">
 <div align="right"><a class="normalfont" style="text-decoration : none" href="/IPS/Home/SearchHelp.htm"><font size=-1>Help</font></a>&nbsp;&nbsp;<a class="normalfont" style="text-decoration : none" href="/IPS/Home/Glossary.htm"><font size=-1>Glossary</font></a>&nbsp;&nbsp;
 <cfif SESSION.Auth.user_access_level NEQ "Guest">
  <a class="normalfont" style="text-decoration : none" href="/IPS/act_logout.cfm"><font size=-1>Logout</font></a>
  <cfelse>
  <a class="normalfont" style="text-decoration : none" href="/IPS/LoginSearch.cfm"><font size=-1>Login</font></a>
  </cfif>
  </div></td>
	</tr>
</table>

<cfif IsDefined ("StatsOutput")>
	<table>
</cfif>
 
 <cfset RecordFromWhichLoopStarts = 1>
 
 <cfloop query = "getCoordinatesAndQuantities">
 
 <cfset RecordFromWhichLoopStarts = RecordFromWhichLoopStarts+1>
 
	<cfif IsDefined ("StatsOutput")>
		<tr>
		<td  valign="top">
	</cfif>
			<cfoutput>
				<cfif IsDefined ("StatsOutput")>
					#site# (#totalpotsofthispotterfromsite#) Recno #RecordFromWhichLoopStarts#
				</cfif>
			<cfset FromSite = "#site#">
			<cfset FromSiteNumberOfPotsFromThisPotter = #totalpotsofthispotterfromsite#>
			</cfoutput>
			
			<cfquery dbtype="query" name="GetAllPotsFromFromSite">
			SELECT totalpotsfromthissite AS AllPotsFromFromSite
			FROM TotalNumberOfPotsFromSite
			WHERE site = '#site#';
			</cfquery>
			
			<cfoutput query="GetAllPotsFromFromSite">
				<cfset tmpAllPotsFromFromSite = "#AllPotsFromFromSite#">
			</cfoutput>
			
			<cfoutput> 
				<cfset ExpectedFromSite = (#tmpAllPotsFromFromSite#*#tmpAllExportedPotsThisPotter#)/#tmpTotalExport#>
				


				<cfif #ExpectedFromSite# GT 1 AND #ExpectedToSite# GT 1 AND #tmpAllPotsFromFromSite# GT #ExpectedFromSite#>
					<cfset tmpRelevantValueFromSite = "red">
				<cfelse>
					<cfset tmpRelevantValueFromSite = "black">
				</cfif>
			</cfoutput>


			<cfoutput>
				 <cfset tmpcoordinate1 = #coordinate1#>
				 <cfset tmpcoordinate2 = #coordinate2#>

			</cfoutput>
			
			

	<cfif IsDefined ("StatsOutput")>
		</td>
		<td valign="top">
	</cfif>
		<cfloop query="detail" STARTROW = #RecordFromWhichLoopStarts#>
				
				

					<cfoutput>

						<cfset ToSite = #site#>
						<cfset ToSiteNumberOfPots = #TotalPotsOfThisPotterFromSite#>
					
					
						<cfset PercentageFromFromSite = (#FromSiteNumberOfPotsFromThisPotter#/#tmpAllPotsFromFromSite#*100)>
						

						
							<cfquery dbtype="query" name="LookupPercentageToSite">
							SELECT totalpotsfromthissite
							FROM TotalNumberOfPotsFromSite
							WHERE site = '#ToSite#';
							</cfquery>
							
							<cfloop query = "LookupPercentageToSite">
							<cfset tmpToSiteTotalNumberOfPots = "#totalpotsfromthissite#">
							</cfloop>
											
							<cfset PercentageFromToSite = (#ToSiteNumberOfPots#/#tmpToSiteTotalNumberOfPots#*100)>
						
							<cfset ExpectedToSite = (#tmpToSiteTotalNumberOfPots#*#tmpAllExportedPotsThisPotter#)/#tmpTotalExport#>
							
							<cfif #ExpectedFromSite# GTE 1 AND #ExpectedToSite# GTE 1 AND #ToSiteNumberOfPots# GT #ExpectedToSite#>
								<cfset tmpRelevantValueColor = "red">
							<cfelse>
								<cfset tmpRelevantValueColor = "black">
							</cfif>
						
						<cfif IsDefined ("StatsOutput")>
							&nbsp;&nbsp;&nbsp;#FromSite#
							#FromSiteNumberOfPotsFromThisPotter# out of #tmpAllPotsFromFromSite# (= #NumberFormat(PercentageFromFromSite, 99.99)#%)
							Expected: <font color = "#tmpRelevantValueFromSite#">#NumberFormat(ExpectedFromSite, 99.99)#</font>
							-
							#ToSite# (<font color = "#tmpRelevantValueColor#">#ToSiteNumberOfPots#</font> 
							out of #tmpToSiteTotalNumberOfPots#)
							(=#NumberFormat(PercentageFromToSite, 99.99)#%) 
							Expected: <font color = "#tmpRelevantValueColor#">#NumberFormat(ExpectedToSite, 99.99)#</font>
							;
						</cfif>
						
					</cfoutput>

				
				
				
				<cfquery name="straightPostgreSQL" datasource="IPS">
				select (point(#subcoordinate1#, #subcoordinate2#) <@> point(#tmpcoordinate1#, #tmpcoordinate2#)) as distance;
				</cfquery>

				<cfoutput query = "straightPostgreSQL">
					<cfset kmdistance =  #distance#*1.609344>
					<cfif IsDefined ("StatsOutput")>
						#NumberFormat(kmdistance, 99.99)# km
					</cfif>
				</cfoutput>

<!--- log(x)/log(2) ist equivalent von log base 2 of x --->
				<cfoutput>
					<cfif kmdistance EQ 0.00>
						<cfset kmdistance = 0.01>
					</cfif>
<!--- dies fuer die Log2 Variant 
					<cfset StatisticalValue = ((log(#FromSiteNumberOfPotsFromThisPotter#)/log(2))+((log(#ToSiteNumberOfPots#))/log(2))) /#kmdistance#>
--->
<!--- hier die klassische Variante --->
					<cfif selectOutputMethod EQ "Percentages">
						<cfset StatisticalValue = (#PercentageFromFromSite#+#PercentageFromToSite#) /#kmdistance#>
						<cfset StatisticalSignificant = "yes">
					</cfif>

					<cfif selectOutputMethod EQ "Absolute Frequencies">
						<cfset StatisticalValue = (#FromSiteNumberOfPotsFromThisPotter#+#ToSiteNumberOfPots#) /#kmdistance#>
						<cfset StatisticalSignificant = "yes">
					</cfif>
					
					<cfif selectOutputMethod EQ "Chi Square">
						<cfset StatisticalValue = (#ExpectedFromSite#+#ExpectedToSite#) /#kmdistance#>
						<cfset StatisticalSignificant = "yes">
					</cfif>

					<cfif IsDefined ("StatsOutput")>
						Statistical value: 
						<cfif selectOutputMethod EQ "Chi Square" AND StatisticalValue GT #selectDensityValue#>
							<font color = "red">
							<cfset StatisticalSignificant = "yes">
						</cfif>
						<cfif selectOutputMethod EQ "Chi Square" AND StatisticalValue LTE #selectDensityValue#>
							<font color = "black">
							<cfset StatisticalSignificant = "no">
						</cfif>
						#NumberFormat(StatisticalValue, 99.99)#
						<cfif selectOutputMethod EQ "Chi Square" AND StatisticalValue GT #selectDensityValue#>
							</font>
						</cfif>
					</cfif>
				</cfoutput>
				
				<cfoutput>

				<cfset NewArray=arraynew(1)> 
				<cfset arrayAppend(NewArray, [
				"#FromSite#",
				#FromSiteNumberOfPotsFromThisPotter#,
				#subcoordinate1#,
				#subcoordinate2#,
				"#ToSite#",
				#ToSiteNumberOfPots#,
				#tmpcoordinate1#,
				#tmpcoordinate2#,
				#NumberFormat(kmdistance, 99.99)#,
				#StatisticalValue#,
				#counterdistances#,
				#tmpAllPotsFromFromSite#,
				#tmpToSiteTotalNumberOfPots#,
				"#StatisticalSignificant#"
				])>
				
				<cfset arrayAppend(distancesarray, NewArray, true)>
	<!---		
				<cfset arrayAppend(distancesarray, "#FromSite#">
				<cfset arrayAppend(distancesarray, "#ToSite#">
				<cfset arrayAppend(distancesarray, "#NumberFormat(kmdistance, 99.99)#">
				<cfset arrayAppend(distancesarray, "#counterdistances#">
	--->	
				<cfset counterdistances = #counterdistances#+1>
				
				</cfoutput>
			
			</cfloop>

	<cfif IsDefined ("StatsOutput")>			
		</td>
		</tr>
	</cfif>


</cfloop>

<cfif IsDefined ("StatsOutput")>
</table>
</cfif>
 
 <!---
<cfset defaultCacheProps = StructNew()>
<cfset cacheRegionNew("TestRegion", #defaultCacheProps#, true)>
<cfset defaultCacheProps.MAXELEMENTSINMEMORY = "15000">
 <cfdump var=#cacheGetProperties('TestRegion')# keys = "15000">
 --->
 <!---
<cfdump var = #distancesarray#>
--->
<!---
<cfscript>
WriteDump(#distancesarray#)
</cfscript>
--->
 
 
 		<div id="map" style="width: 100%; height: 900px"></div>
	
	

		<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
		<script src="js/leaflet.js"></script>
		<script src="js/TileLayer.Grayscale.js"></script>
		<script src="js/L.Control.ZoomMin.js"></script>
		<script src="js/L.Control.ZoomBox.js"></script>
		<script src="js/jQuery.print.js"></script>
		<script src="js/leaflet.easyPrint.js"></script>
		<script src="js/l.ellipse.js"></script>
 
 	<script>

		<cfinclude template="js/mapleafletjs_1.js">
		<cfinclude template="js/mapleafleticons.js">
		

<!---
<cfloop index="Counter" from=1 to="#counterdistances#"> 
    <cfoutput>
	<cfif distancesarray[Counter][10] LT 1>
	
					L.marker([#distancesarray[Counter][8]#, #distancesarray[Counter][7]#], {icon: grayIcon}).addTo(map).bindPopup("<b>#distancesarray[Counter][1]#</b><br>(#distancesarray[Counter][7]#; #distancesarray[Counter][8]#).");
	</cfif>
	</cfoutput>
</cfloop>
--->
<cfloop query = "getCoordinatesAndQuantities">
    <cfoutput>
	L.marker([#coordinate2#, #coordinate1#], {icon: grayIcon3}).addTo(map).bindPopup("<b>#site#</b><br>(#totalpotsofthispotterfromsite#).");
    </cfoutput> 
</cfloop>

<cfloop index="Counter" from=1 to="#counterdistances#"> 
    <cfoutput> 
		<cfif distancesarray[Counter][10] GTE #selectDensityValue# 
			AND distancesarray[Counter][10] LT 10 
			AND distancesarray[Counter][12] GT #selectMinimumNumberOfFinds#
			AND distancesarray[Counter][13] GT #selectMinimumNumberOfFinds#
			AND distancesarray[Counter][14] EQ "yes">
					var pointA = new L.LatLng(#distancesarray[Counter][8]#, #distancesarray[Counter][7]#);
					var pointB = new L.LatLng(#distancesarray[Counter][4]#, #distancesarray[Counter][3]#);
					var pointList = [pointA, pointB];

					<cfset lineweight = #distancesarray[Counter][10]#*2>
<!---
					<cfset lineweight = (2*round(#distancesarray[Counter][10]#))>
--->
					<cfset opacityweight = ((1/(#distancesarray[Counter][10]#)*50))>
					var firstpolyline = new L.polyline(pointList, {
					color: 'blue',
					weight: #lineweight#,
					opacity: #opacityweight#
					});
					firstpolyline.addTo(map);
				L.marker([#distancesarray[Counter][8]#, #distancesarray[Counter][7]#], {icon: orangeIcon}).addTo(map).bindPopup("<b>#distancesarray[Counter][1]#</b><br>(#distancesarray[Counter][7]#; #distancesarray[Counter][8]#<br> #distancesarray[Counter][13]# / #distancesarray[Counter][12]#).");
				L.marker([#distancesarray[Counter][4]#, #distancesarray[Counter][3]#], {icon: orangeIcon}).addTo(map).bindPopup("<b>#distancesarray[Counter][5]#</b><br>(#distancesarray[Counter][7]#; #distancesarray[Counter][8]#<br> #distancesarray[Counter][13]# / #distancesarray[Counter][12]#).");
		</cfif>
    </cfoutput> 
</cfloop> 



				
		<cfinclude template="ProvinzGrenzenPolylines.cfm">
		<cfinclude template="js/mapleafletjs_2.js">

	</script>
	
  <cfoutput>#counterdistances#</cfoutput> Distances calculated for: <i><cfoutput>#selectPottername#</cfoutput></i>, with <cfoutput query="NumberOfDiesPotter">#tempdies#</cfoutput> dies and <cfoutput query="NumberOfPotsPotter">#AllExportedPotsThisPotter#</cfoutput> pots.
  Statistical Density Value: <cfoutput>#selectDensityValue#</cfoutput>


 
</body>
</html>