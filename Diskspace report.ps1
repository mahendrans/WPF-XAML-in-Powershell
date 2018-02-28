Function Get-hdetails{
    [CmdletBinding(SupportsShouldProcess=$true, 
                  ConfirmImpact='Medium')]
   
   
   Param
    (
        # Param1 help description
        [Parameter(
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [String[]]$server = $env:COMPUTERNAME,
        [String]$Logfile = "C:\temp1\logfil.txt",
        [String]$CORP = "\\tmnams2317\e$\ScriptShare\Diskspace - Fast.csv",
        [String]$TRANS = "\\imnatms6784\e$\ScriptShare\Diskspace - Fast.csv"
      $domain = "ad\ahd0"
      $Passw222 = "Passw$222"
 $cred = new-object -typename System.Management.Automation.PSCredential `
         -argumentlist $domain, $Passw222
        )
        
        function out-CSV {
[CmdletBinding(DefaultParameterSetName='Delimiter',
  SupportsShouldProcess=$true, ConfirmImpact='Medium')]
param(
 [Parameter(Mandatory=$true, ValueFromPipeline=$true,
           ValueFromPipelineByPropertyName=$true)]
 [System.Management.Automation.PSObject]
 ${InputObject},

 [Parameter(Mandatory=$true, Position=0)]
 [Alias('PSPath')]
 [System.String]
 ${Path},
 
 #region -Append (added by Dmitry Sotnikov)
 [Switch]
 ${Append},
 #endregion 

 [Switch]
 ${Force},

 [Switch]
 ${NoClobber},

 [ValidateSet('Unicode','UTF7','UTF8','ASCII','UTF32',
                  'BigEndianUnicode','Default','OEM')]
 [System.String]
 ${Encoding},

 [Parameter(ParameterSetName='Delimiter', Position=1)]
 [ValidateNotNull()]
 [System.Char]
 ${Delimiter},

 [Parameter(ParameterSetName='UseCulture')]
 [Switch]
 ${UseCulture},

 [Alias('NTI')]
 [Switch]
 ${NoTypeInformation})

begin
{
 # This variable will tell us whether we actually need to append
 # to existing file
 $AppendMode = $false
 
 try {
  $outBuffer = $null
  if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
  {
      $PSBoundParameters['OutBuffer'] = 1
  }
  $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Export-Csv',
    [System.Management.Automation.CommandTypes]::Cmdlet)
        
        
 #String variable to become the target command line
 $scriptCmdPipeline = ''

 # Add new parameter handling
 #region Dmitry: Process and remove the Append parameter if it is present
 if ($Append) {
  
  $PSBoundParameters.Remove('Append') | Out-Null
    
  if ($Path) {
   if (Test-Path $Path) {        
    # Need to construct new command line
    $AppendMode = $true
    
    if ($Encoding.Length -eq 0) {
     # ASCII is default encoding for Export-CSV
     $Encoding = 'ASCII'
    }
    
    # For Append we use ConvertTo-CSV instead of Export
    $scriptCmdPipeline += 'ConvertTo-Csv -NoTypeInformation '
    
    # Inherit other CSV convertion parameters
    if ( $UseCulture ) {
     $scriptCmdPipeline += ' -UseCulture '
    }
    if ( $Delimiter ) {
     $scriptCmdPipeline += " -Delimiter '$Delimiter' "
    } 
    
    # Skip the first line (the one with the property names) 
    $scriptCmdPipeline += ' | Foreach-Object {$start=$true}'
    $scriptCmdPipeline += '{if ($start) {$start=$false} else {$_}} '
    
    # Add file output
    $scriptCmdPipeline += " | Out-File -FilePath '$Path'"
    $scriptCmdPipeline += " -Encoding '$Encoding' -Append "
    
    if ($Force) {
     $scriptCmdPipeline += ' -Force'
    }

    if ($NoClobber) {
     $scriptCmdPipeline += ' -NoClobber'
    }   
   }
  }
 } 
  

  
 $scriptCmd = {& $wrappedCmd @PSBoundParameters }
 
 if ( $AppendMode ) {
  # redefine command line
  $scriptCmd = $ExecutionContext.InvokeCommand.NewScriptBlock(
      $scriptCmdPipeline
    )
 } else {
  # execute Export-CSV as we got it because
  # either -Append is missing or file does not exist
  $scriptCmd = $ExecutionContext.InvokeCommand.NewScriptBlock(
      [string]$scriptCmd
    )
 }

 # standard pipeline initialization
 $steppablePipeline = $scriptCmd.GetSteppablePipeline(
        $myInvocation.CommandOrigin)
 $steppablePipeline.Begin($PSCmdlet)
 
 } catch {
   throw
 }
    
}

process
{
  try {
      $steppablePipeline.Process($_)
  } catch {
      throw
  }
}

end
{
  try {
      $steppablePipeline.End()
  } catch {
      throw
  }
}
<#

.ForwardHelpTargetName Export-Csv
.ForwardHelpCategory Cmdlet

#>

}

        
        try
       
        
{
"Working on server $server"
gwmi -query "SELECT SystemName,Caption,VolumeName,Size,Freespace FROM win32_logicaldisk WHERE DriveType=3" -ComputerName $server -ErrorAction stop -ErrorVariable $CError|
Select-Object SystemName,Caption,VolumeName,
@{Name="Size(GB)"; Expression={"{0:N2}" -f ($_.Size/1GB)}},
@{Name="Freespace(GB)"; Expression={"{0:N2}" -f ($_.Freespace/1GB)}},
@{Name="% Free"; Expression={"{0:N2}" -f (($_.Freespace/$_.Size)*100)}} | out-Csv $CORP -Append -NoTypeInformation

gwmi -query "SELECT SystemName,Caption,VolumeName,Size,Freespace FROM win32_logicaldisk WHERE DriveType=3" -ComputerName $server -ErrorAction stop -ErrorVariable $CError|
Select-Object SystemName,Caption,VolumeName,
@{Name="Size(GB)"; Expression={"{0:N2}" -f ($_.Size/1GB)}},
@{Name="Freespace(GB)"; Expression={"{0:N2}" -f ($_.Freespace/1GB)}},
@{Name="% Free"; Expression={"{0:N2}" -f (($_.Freespace/$_.Size)*100)}} | out-Csv $TRANS -Append -NoTypeInformation
}

catch
{

write-host "there was an erron on processing $server"

                                  $date | Out-File $LogFile -Append  
                                  $server | Out-File $LogFile -Append 
                                  $CError | out-file $LogFile -Append
                                                                  
                                          }



}

Get-hdetails
