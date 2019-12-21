Function Get-GELocation
{
	<#	
	.NOTES
	===========================================================================
	 Created on:   	12/17/2019 
	 Created by:   	Bradley Wyatt - The Lazy Administrator   
	 Version Info:  1.0.0
	===========================================================================
	.Synopsis
       Gets Global Entry Interview locations based on state(s)
	.DESCRIPTION
		Shows all Global Entry locations in one or more state(s).
	.PARAMETER State
		Specifies which state or states you want to view global entry interview locations for
	
	.EXAMPLE 
        Shows all sites in Illinois and Indiana

		Get-GELocation -State IL, Indiana
	.EXAMPLE
		Shows all sites in Illinois
        
        Get-GELocation -State IL
#>
	Param (
		[parameter(Mandatory = $true, Position = 0)]
		[System.Array]$State
	)
	
	$all = Invoke-restmethod -uri "https://ttp.cbp.dhs.gov/schedulerapi/locations/?temporary=false&inviteOnly=false&operational=true&serviceName=Global%20Entry"
	
	$StateHash = @{
		"AL" = "Alabama"
		"AK" = "Alaska"
		"AZ" = "Arizona"
		"AR" = "Arkansas"
		"CA" = "California"
		"CO" = "Colorado"
		"CT" = "Connecticut"
		"DE" = "Deleware"
		"FL" = "Florida"
		"GA" = "Georgia"
		"HI" = "Hawaii"
		"ID" = "Idaho"
		"IL" = "Illinois"
		"IN" = "Indiana"
		"IA" = "Iowa"
		"KS" = "Kansas"
		"KY" = "Kentucky"
		"LA" = "Louisiana"
		"ME" = "Maine"
		"MD" = "Maryland"
		"MA" = "Massachusetts"
		"MI" = "Michigan"
		"MN" = "Minnesota"
		"MS" = "Mississippi"
		"MO" = "Missouri"
		"MT" = "Montana"
		"NE" = "Nebraska"
		"NV" = "Nevada"
		"NH" = "New Hampshire"
		"NJ" = "New Jersey"
		"NM" = "New Mexico"
		"NY" = "New York"
		"NC" = "North Carolina"
		"ND" = "North Dakota"
		"OH" = "Ohio"
		"OK" = "Oklahoma"
		"OR" = "Oregon"
		"PA" = "Pennsylvania"
		"RI" = "Rhode Island"
		"SC" = "South Carolina"
		"SD" = "South Dakota"
		"TN" = "Tennessee"
		"TX" = "Texas"
		"UT" = "Utah"
		"VT" = "Vermont"
		"VA" = "Virgina"
		"WA" = "Washington"
		"WV" = "West Virgina"
		"WI" = "Wisconsin"
		"WY" = "Wyoming"
	}
	foreach ($Item in $State)
	{
		If ($Item.Length -gt 2)
		{
			$stateabbreviation = $StateHash.keys | Where-Object { $StateHash["$_"] -eq $Item }
			$all | Where-object { $_.State -eq $stateabbreviation }
		}
		else
		{
			$all | Where-object { $_.State -eq $Item }
		}
	}
}


Function Get-GESchedule
{
	<#	
	.NOTES
	===========================================================================
	 Created on:   	12/17/2019 
	 Created by:   	Bradley Wyatt - The Lazy Administrator   
	 Version Info:  1.0.0
	===========================================================================
	.Synopsis
       Gets upcoming Global Entry Interview openings at different locations
	.DESCRIPTION
		Gets upcoming Global Entry Interview openings. Can show results between dates, by site ID(s), by State(s) and can filter the amount of results shown per site
	.PARAMETER ID
		Gets Global Entry interview availability based on site ID. Can dsiplay site ID's by running Get-GELocation
	.PARAMETER State
		Gets Global Entry interview availablity for all sites in a given state or states.
	.PARAMETER ResultsPerSite
		Specifies the max amount of available interview slots to show per Global Entry site
	.PARAMETER StartDate
		Only show Global Entry availablity starting from a specific date. Must be formatted as yyyy-MM-dd
	.PARAMETER EndDate
		Shows Global Entry availablity from either the startdate to the enddate, or if no startdate is specified it will show all availablity from today to enddate. Must be formatted as yyyy-MM-dd
	.EXAMPLE 
        Shows all available interviews for all sites in Illinois, Wisconsin and Indiana

		Get-GESchedule -State IL,Wisconsin,IN
	.EXAMPLE
		Shows all available interviews for all sites in Illinois from December 18 2019 to March 8 2020
        
        Get-GESchedule -State Illinois -StartDate 2019-12-19 -EndDate 2020-03-08
	.EXAMPLE
		Shows all available interviews for all sites in Illinois from December 18 2019 to March 8 2020. Limit results to 2 items per site and sort by city
		
		Get-GESchedule -State Illinois -StartDate 2019-12-19 -EndDate 2020-03-08 -ResultsPerSite 2 | Sort-Object City
	.EXAMPLE 
		Get first 2 available Global Entry interviews at Chicago OHare International Airport
		
		Get-GESchedule -ID 5183 -ResultsPerSite 2
#>
	[CmdletBinding(DefaultParameterSetName = 'ByState')]
	Param (
		[parameter(Mandatory = $true, ParameterSetName = 'ByID', HelpMessage = "Please enter the site ID or ID's of the Global Entry interview locations", Position = 0)]
		[System.Array]$ID,
		[parameter(Mandatory = $true, HelpMessage = "Please enter the state or states you want to view available Global Entry Interviews for", ParameterSetName = 'ByState', Position = 1)]
		[System.Array]$State,
		[parameter(Mandatory = $false, Position = 2)]
		[System.Int32]$ResultsPerSite,
		[parameter(Mandatory = $false, Position = 3)]
		[System.String]$StartDate,
		[parameter(Mandatory = $false, Position = 4)]
		[System.String]$EndDate
	)
	
	Begin
	{
		[System.Array]$Stateresults = @()
		
		$StateHash = @{
			"AL" = "Alabama"
			"AK" = "Alaska"
			"AZ" = "Arizona"
			"AR" = "Arkansas"
			"CA" = "California"
			"CO" = "Colorado"
			"CT" = "Connecticut"
			"DE" = "Deleware"
			"FL" = "Florida"
			"GA" = "Georgia"
			"HI" = "Hawaii"
			"ID" = "Idaho"
			"IL" = "Illinois"
			"IN" = "Indiana"
			"IA" = "Iowa"
			"KS" = "Kansas"
			"KY" = "Kentucky"
			"LA" = "Louisiana"
			"ME" = "Maine"
			"MD" = "Maryland"
			"MA" = "Massachusetts"
			"MI" = "Michigan"
			"MN" = "Minnesota"
			"MS" = "Mississippi"
			"MO" = "Missouri"
			"MT" = "Montana"
			"NE" = "Nebraska"
			"NV" = "Nevada"
			"NH" = "New Hampshire"
			"NJ" = "New Jersey"
			"NM" = "New Mexico"
			"NY" = "New York"
			"NC" = "North Carolina"
			"ND" = "North Dakota"
			"OH" = "Ohio"
			"OK" = "Oklahoma"
			"OR" = "Oregon"
			"PA" = "Pennsylvania"
			"RI" = "Rhode Island"
			"SC" = "South Carolina"
			"SD" = "South Dakota"
			"TN" = "Tennessee"
			"TX" = "Texas"
			"UT" = "Utah"
			"VT" = "Vermont"
			"VA" = "Virgina"
			"WA" = "Washington"
			"WV" = "West Virgina"
			"WI" = "Wisconsin"
			"WY" = "Wyoming"
		}
	}
	Process
	{
		If ($State)
		{
			foreach ($Item in $State)
			{
				$all = Invoke-restmethod -uri "https://ttp.cbp.dhs.gov/schedulerapi/locations/?temporary=false&inviteOnly=false&operational=true&serviceName=Global%20Entry"
				
				If ($Item.Length -gt [int32]2)
				{
					$stateabbreviation = $StateHash.keys | Where-Object { $StateHash["$_"] -eq $Item }
					$Stateresults += $all | Where-object { $_.State -eq $stateabbreviation }
				}
				else
				{
					$Stateresults += $all | Where-object { $_.State -eq $Item }
				}
			}
		}
		If ($ID)
		{
			foreach ($Item in $ID)
			{
				$all = Invoke-restmethod -uri "https://ttp.cbp.dhs.gov/schedulerapi/locations/?temporary=false&inviteOnly=false&operational=true&serviceName=Global%20Entry"
				
				$Stateresults += $all | Where-object { $_.ID -eq $Item }
			}
		}
		foreach ($Stateresult in $Stateresults)
		{
			If (($StartDate.Length -gt 0) -and ($EndDate.Length -gt 0) -and ($ResultsPerSite -eq [int32]0))
			{
				$concatenateStartString = [System.String]::Concat($StartDate, "T00:00:00")
				$concatenateEndString = [System.String]::Concat($EndDate, "T23:59:59")
				$d = Invoke-RestMethod -Uri "https://ttp.cbp.dhs.gov/schedulerapi/locations/$($Stateresult.id)/slots?orderBy=soonest&startTimestamp=$concatenateStartString&endTimestamp=$concatenateEndString"
				$d | Where-Object { $_.active -gt 0 } | Select-Object @{ Name = 'locationId'; Expression = { $Stateresult.id } }, timestamp, @{ Name = 'Active'; Expression = { "True" } }, duration, @{ Name = 'City'; Expression = { $Stateresult.city } }, @{ Name = 'Name'; Expression = { $Stateresult.Name } }, @{ Name = 'State'; Expression = { $Stateresult.State } }
			}
			ElseIf (($StartDate.Length -gt 0) -and ($EndDate.Length -gt 0) -and ($ResultsPerSite.Length -gt 0))
			{
				$concatenateStartString = [System.String]::Concat($StartDate, "T00:00:00")
				$concatenateEndString = [System.String]::Concat($EndDate, "T23:59:59")
				$d = Invoke-RestMethod -Uri "https://ttp.cbp.dhs.gov/schedulerapi/locations/$($Stateresult.id)/slots?orderBy=soonest&startTimestamp=$concatenateStartString&endTimestamp=$concatenateEndString"
				$d | Where-Object { $_.active -gt 0 } | Select-Object -First $ResultsPerSite | Select-Object @{ Name = 'locationId'; Expression = { $Stateresult.id } }, timestamp, @{ Name = 'Active'; Expression = { "True" } }, duration, @{ Name = 'City'; Expression = { $Stateresult.city } }, @{ Name = 'Name'; Expression = { $Stateresult.Name } }, @{ Name = 'State'; Expression = { $Stateresult.State } }
				
			}
			ElseIf (($StartDate.Length -gt 0) -and (!$EndDate) -and ($ResultsPerSite -gt 0))
			{
				[System.DateTime]$StartEnd = $StartDate
				$CusEndDate = $StartEnd.ToString("yyyy-MM-dd")
				$concatenateEndString = [System.String]::Concat($CusEndDate, "T23:59:59")
				
				$concatenateStartString = [System.String]::Concat($StartDate, "T00:00:00")
				$d = Invoke-RestMethod -Uri "https://ttp.cbp.dhs.gov/schedulerapi/locations/$($Stateresult.id)/slots?orderBy=soonest&startTimestamp=$concatenateStartString&endTimestamp=$concatenateEndString"
				$d | Where-Object { $_.active -gt 0 } | Select-Object -First $ResultsPerSite | Select-Object @{ Name = 'locationId'; Expression = { $Stateresult.id } }, timestamp, @{ Name = 'Active'; Expression = { "True" } }, duration, @{ Name = 'City'; Expression = { $Stateresult.city } }, @{ Name = 'Name'; Expression = { $Stateresult.Name } }, @{ Name = 'State'; Expression = { $Stateresult.State } }
			}
			ElseIf (($StartDate.Length -gt 0) -and (!$EndDate) -and ($ResultsPerSite -eq 0))
			{				
				[System.DateTime]$StartEnd = $StartDate
				$CusEndDate = $StartEnd.ToString("yyyy-MM-dd")
				$concatenateEndString = [System.String]::Concat($CusEndDate, "T23:59:59")
				
				$concatenateStartString = [System.String]::Concat($StartDate, "T00:00:00")
				$d = Invoke-RestMethod -Uri "https://ttp.cbp.dhs.gov/schedulerapi/locations/$($Stateresult.id)/slots?orderBy=soonest&startTimestamp=$concatenateStartString&endTimestamp=$concatenateEndString"
				$d | Where-Object { $_.active -gt 0 } | Select-Object @{ Name = 'locationId'; Expression = { $Stateresult.id } }, timestamp, @{ Name = 'Active'; Expression = { "True" } }, duration, @{ Name = 'City'; Expression = { $Stateresult.city } }, @{ Name = 'Name'; Expression = { $Stateresult.Name } }, @{ Name = 'State'; Expression = { $Stateresult.State } }
			}
			ElseIf (($EndDate.Length -gt 0) -and (!$StartDate) -and ($ResultsPerSite -gt 0))
			{
				$today = Get-Date -Format "yyy-MM-dd"
				$concatenateStartString = [System.String]::Concat($today, "T00:00:00")
				
				$concatenateEndString = [System.String]::Concat($EndDate, "T23:59:59")
				$d = Invoke-RestMethod -Uri "https://ttp.cbp.dhs.gov/schedulerapi/locations/$($Stateresult.id)/slots?orderBy=soonest&startTimestamp=$concatenateStartString&endTimestamp=$concatenateEndString"
				$d | Where-Object { $_.active -gt 0 } | Select-Object -First $ResultsPerSite | Select-Object @{ Name = 'locationId'; Expression = { $Stateresult.id } }, timestamp, @{ Name = 'Active'; Expression = { "True" } }, duration, @{ Name = 'City'; Expression = { $Stateresult.city } }, @{ Name = 'Name'; Expression = { $Stateresult.Name } }, @{ Name = 'State'; Expression = { $Stateresult.State } }
			}
			ElseIf ((!$StartDate) -and ($EndDate.Length -gt 0) -and ($ResultsPerSite -eq 0))
			{
				$today = Get-Date -Format "yyy-MM-dd"
				$concatenateStartString = [System.String]::Concat($today, "T00:00:00")
				
				$concatenateEndString = [System.String]::Concat($EndDate, "T23:59:59")
				$d = Invoke-RestMethod -Uri "https://ttp.cbp.dhs.gov/schedulerapi/locations/$($Stateresult.id)/slots?orderBy=soonest&startTimestamp=$concatenateStartString&endTimestamp=$concatenateEndString"
				$d | Where-Object { $_.active -gt 0 } | Select-Object @{ Name = 'locationId'; Expression = { $Stateresult.id } }, timestamp, @{ Name = 'Active'; Expression = { "True" } }, duration, @{ Name = 'City'; Expression = { $Stateresult.city } }, @{ Name = 'Name'; Expression = { $Stateresult.Name } }, @{ Name = 'State'; Expression = { $Stateresult.State } }
			}
			Elseif ((!$EndDate) -and (!$StartDate) -and ($ResultsPerSite -gt 0))
			{
				$V = Invoke-RestMethod -URI "https://ttp.cbp.dhs.gov/schedulerapi/slots?orderBy=soonest&locationId=$($Stateresult.id)"
				$v | Select-Object -First $ResultsPerSite | Select-Object locationid, starttimestamp, endtimestamp, active, duration, @{ Name = 'City'; Expression = { $Stateresult.city } }, @{ Name = 'Name'; Expression = { $Stateresult.Name } }, @{ Name = 'State'; Expression = { $Stateresult.State } }
			}
			Else
			{
				$V = Invoke-RestMethod -URI "https://ttp.cbp.dhs.gov/schedulerapi/slots?orderBy=soonest&locationId=$($Stateresult.id)"
				$v | Select-Object locationid, starttimestamp, endtimestamp, active, duration, @{ Name = 'City'; Expression = { $Stateresult.city } }, @{ Name = 'Name'; Expression = { $Stateresult.Name } }, @{ Name = 'State'; Expression = { $Stateresult.State } }
			}
		}
	}
}