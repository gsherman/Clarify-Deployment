param( [string] $resourceConfigName, [string] $directiveFile ) 

#source other scripts
. .\DovetailCommonFunctions.ps1


$formNumberArray = Get-Content $directiveFile | grep "\-F" | %{ $_.Split(' ')[2]; }
$formVersionArray = Get-Content $directiveFile | grep "\-F" | %{ $_.Split(' ')[4]; }
   
$ClarifyApplication = create-clarify-application; 
$ClarifySession = create-clarify-session $ClarifyApplication; 

	$dataSet = new-object FChoice.Foundation.Clarify.ClarifyDataSet($ClarifySession)

	$userObjid = $ClarifySession.UserId;
		
	$rcGeneric = $dataSet.CreateGeneric("rc_config")
	$rcGeneric.AppendFilter("name", "Equals", $resourceConfigName)
	$rcGeneric.Query();

	if ($rcGeneric.Rows.Count -eq 0){
   $rc = $rcGeneric.AddNew();
   $rc["name"] = $resourceConfigName;      
	}else{
		$rc = $rcGeneric.Rows[0];
	}
	
	
  $rc.RelateById($userObjid,"rc_config2user"); 
  $rc.Update(); 


	
	for ($i=0; $i -le $formNumberArray.length - 1; $i++)
	{
		$form = $dataSet.CreateGeneric("window_db")
		$form.AppendFilter("id", "Equals", [System.Convert]::ToInt32($formNumberArray[$i]))
		$form.AppendFilter("ver_customer", "Equals", [System.Convert]::ToString($formVersionArray[$i]))
		$form.Query();
		if ($form.Rows.Count -eq 0){
			Write-Host unable to find form $formNumberArray[$i] $formVersionArray[$i]
		}else{
			$row = $form.Rows[0];
			$rc.RelateById($row["objid"],"rc_config2window_db"); 
			$rc.Update(); 
		}
			
	}

