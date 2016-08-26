<#
	Aurthor:		"Mahendran Somasundaram"
	Version:		0.7 (22-Aug-2016) Beta

BugFix : 

1. Small fix on error reporting still need to verifiy but its working better than earlier versions
2. Hardware Inventory now working
3. "Get details" buttion rename to "Run Script"

Upcoming bugfixes :
1. Opening output and error files after running script
2. Error reporting
3. Software Iventory
4. Completed Popup message
5. DMZ Button to input dmz password
#>
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | out-null
[System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | out-null
Add-Type -AssemblyName system.windows.forms
$msgbx = New-Object -ComObject Wscript.Shell -ErrorAction Stop

# Form configuration
$form = New-Object windows.forms.form
$form.AutoSize = $true
$form.Text = "MGI Server Utility Tool (Windows)"
$form.StartPosition = "CenterScreen"
$Ic = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")
$Form.Icon = $Ic
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox  = $false;

# Lable 
$testlable = New-Object System.Windows.Forms.RadioButton
$testlable.Top = 35
$testlable.Left = 120
$testlable.Text = "File"
$testlable.add_click({
$flbrsrlbl.Text = "File Name:"
$flbrsrbtn.Enabled = $true
})
$orlbl = New-Object System.Windows.Forms.RadioButton
$orlbl.Top = 35
$orlbl.Left = 25
$orlbl.Text = "Server Name"
$orlbl.checked = $true
$orlbl.add_click({
$flbrsrlbl.Text = "Server Name:"
$flbrsrtxt.Text = ""
$flbrsrbtn.Enabled = $false
})


# File Path Textbox
$flbrsrtxt = New-Object System.Windows.Forms.TextBox
$flbrsrtxt.Top = 5
$flbrsrtxt.Left = 80
$flbrsrtxt.width = 142



# File Path Text
$flbrsrlbl = New-Object System.Windows.Forms.Label
$flbrsrlbl.Top = 6
$flbrsrlbl.Left = 5
$flbrsrlbl.Text = "Server Name:"




# FB
$flbrsrbtn = New-Object System.Windows.Forms.Button
$flbrsrbtn.Text = "Browse"
$flbrsrbtn.Top = 4
$flbrsrbtn.Left = 225
$flbrsrbtn.width = 50
$flbrsrbtn.Enabled = $fale
$ue = "mgiadmin"
$na = "429C0br@j3t"
$secstr = New-Object -TypeName System.Security.SecureString
$na.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
$cred = new-object -typename System.Management.Automation.PSCredential `
         -argumentlist $ue, $secstr
$flbrsrbtn.add_click({$flbrsrtxt.Text = fe-ne})



#group box
$grpbxbtn =  @($Uptimebtn,$DskSpcbtn,$DSKclnBtn,$Inventorybtn)
$groupBox = New-Object System.Windows.Forms.GroupBox
$groupBox.Location = New-Object System.Drawing.Size(25,65) 
$groupBox.size = New-Object System.Drawing.Size(140,120) 
$groupBox.text = "Select a tool:" 
$groupBox.Controls.AddRange($grpbxbtn)

$grpbxbtn1 =  @($cpu,$sft)
$groupBox1 = New-Object System.Windows.Forms.GroupBox
$groupBox1.Location = New-Object System.Drawing.Size(165,65) 
$groupBox1.size = New-Object System.Drawing.Size(100,80) 
$groupBox1.text = "Inventory Options:" 
$groupBox1.Controls.AddRange($grpbxbtn1)

# Uptime checkbox
$Uptimebtn = New-Object System.Windows.Forms.RadioButton
$Uptimebtn.text = 'Uptime'
$Uptimebtn.top = 20
$Uptimebtn.Left = 20
$Uptimebtn.Checked = $true
#$Uptimebtn.Location = new-object System.Drawing.Point(30,80) 
#$Uptimebtn.size = New-Object System.Drawing.Size(10,20) 
$Uptimebtn.add_click({
$groupBox1.Enabled = $false
$CPU.checked = $false
$sft.checked = $false
$cpu.Refresh()
$sft.Refresh()
$form.Refresh()
$groupBox1.Refresh()
})
$groupBox.Controls.Add($Uptimebtn)


# Disk Space checkbox
$DskSpcbtn = New-Object System.Windows.Forms.RadioButton
$DskSpcbtn.text = 'Disk Space'
$DskSpcbtn.top = 40
$DskSpcbtn.Left = 20
#$Uptimebtn.Location = new-object System.Drawing.Point(30,100) 
#$Uptimebtn.size = New-Object System.Drawing.Size(80,20) 
$DSKSpcBtn.add_click({
$groupBox1.Enabled = $false
$cpu.checked = $false
$sft.checked = $false
$cpu.Refresh()
$sft.Refresh()
$form.Refresh()
$groupBox1.Refresh()})
$groupBox.Controls.Add($DskSpcbtn)


# Disk Cleanup checkbox
$DSKclnBtn = New-Object System.Windows.Forms.RadioButton
$DSKclnBtn.text = 'Disk Cleanup'
$DSKclnBtn.top = 60
$DSKclnBtn.Left = 20
$DSKclnBtn.add_click({
$groupBox1.Enabled = $false
$CPU.checked = $false
$sft.checked = $false
$cpu.Refresh()
$sft.Refresh()
$form.Refresh()
$groupBox1.Refresh()
})
$groupBox.Controls.Add($DSKclnBtn)


# Inventory checkbox
$Inventorybtn = New-Object System.Windows.Forms.RadioButton
$Inventorybtn.text = 'Inventory'
$Inventorybtn.top = 80
$Inventorybtn.Left = 20
$Inventorybtn.add_click({
$groupBox1.Enabled = $true
$cpu.enabled = $true
$sft.Enabled = $true
$cpu.Checked = $true
$form.Refresh()
$groupBox1.Refresh()
})
$groupBox.Controls.Add($Inventorybtn)


# Inventory Hardware checkbox
$cpu = New-Object System.Windows.Forms.RadioButton
$cpu.text = 'Hardware'
$cpu.top = 25
$cpu.Left = 10
$CPU.size = New-Object System.Drawing.Size(80,20)
$cpu.Enabled = $false
$groupBox1.Controls.Add($cpu)


# Inventory Software checkbox
$sft = New-Object System.Windows.Forms.RadioButton
$sft.text = 'Software'
$sft.top = 45
$sft.Left = 10
$sft.size = New-Object System.Drawing.Size(80,20)
$sft.Enabled = $false
$groupBox1.Controls.Add($sft)

#DMZ Credentials Button
$DMZ = New-Object System.Windows.Forms.Button
$DMZ.Text = "DMZ"
$DMZ.top = 190
$DMZ.Left = 205


# Run Button Config
$btn = New-Object System.Windows.Forms.Button
$btn.Text = "Run Script"
$btn.top = 250
$btn.Left = 15
$btn.add_click({
$form.Refresh()
create-script
})

# Exit Button Config
$xbtn = New-Object System.Windows.Forms.Button
$xbtn.Text = "Exit"
$xbtn.top = 250
$xbtn.Left = 205
$xbtn.add_click({
$form.Close()
})

# Init ProgressBar
$progressbar1 = New-Object System.Windows.Forms.ProgressBar
$progressBar1.Name = 'progressBar1'
$progressbar1.Minimum = 0
$progressbar1.Step = 1
$progressbar1.Value = 0
$ProgressBar1.Style = "Continuous"
$progressbar1.ForeColor = 'Blue'
$progressbar1.Location = new-object System.Drawing.Size(10,220)
$progressbar1.size = new-object System.Drawing.Size(270,20)

# Functions
Function fe-ne ($fd){
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
 $opf = New-Object System.Windows.Forms.OpenFileDialog
 $opf.initialDirectory = "$fd"
 $opf.ShowHelp = $true
 $opf.filter = "Server Name files (*.Txt)|*.Txt"
 $opf.ShowDialog() | Out-Null
 $opf.filename
 }
Function out-CSV {
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
 [Switch]
 ${Append},
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
 $AppendMode = $false 
 try {
  $outBuffer = $null
  if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
  {
      $PSBoundParameters['OutBuffer'] = 1
  }
  $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Export-Csv',
    [System.Management.Automation.CommandTypes]::Cmdlet)
 $scriptCmdPipeline = ''
 if ($Append) {  
  $PSBoundParameters.Remove('Append') | Out-Null    
  if ($Path) {
   if (Test-Path $Path) {
    $AppendMode = $true
    if ($Encoding.Length -eq 0) {
     $Encoding = 'ASCII'
    }
    $scriptCmdPipeline += 'ConvertTo-Csv -NoTypeInformation '
     if ( $UseCulture ) {
     $scriptCmdPipeline += ' -UseCulture '
    }
    if ( $Delimiter ) {
     $scriptCmdPipeline += " -Delimiter '$Delimiter' "
    } 
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
    }      }  } }   
 $scriptCmd = {& $wrappedCmd @PSBoundParameters }
 if ( $AppendMode ) {  $scriptCmd = $ExecutionContext.InvokeCommand.NewScriptBlock(
      $scriptCmdPipeline
    ) } 
  else {  $scriptCmd = $ExecutionContext.InvokeCommand.NewScriptBlock(
      [string]$scriptCmd    ) }
 $steppablePipeline = $scriptCmd.GetSteppablePipeline(
        $myInvocation.CommandOrigin)
 $steppablePipeline.Begin($PSCmdlet) 
 } catch {   throw }}
process
{
  try {      $steppablePipeline.Process($_)  } catch {      throw  }
}
end
{
  try {      $steppablePipeline.End()  } catch {      throw  }}
}
Function Get-UPTime{

   [CmdletBinding(SupportsShouldProcess=$true, 
                  ConfirmImpact='Medium')]
    Param
    (
        [Parameter(
                   Position=0, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [String]$ErrorLog =  "c:\tmp\UptimeError.txt",
        [String]$OutputFile = "c:\tmp\Uptimeoutput.csv",
        [String]$date = (Get-Date)
     )
 

    Begin
    {
    
    }
    Process
    {
            $progressbar1.maximum = $servers.count
           try { 
           if ( Test-Connection -ComputerName $server -Count 1 -ErrorAction stop) {
                            Write-Verbose $Server
		                    if ($server -like "*mz*")
                            {$wmi = gwmi -class Win32_OperatingSystem -computer $server -Credential $cred -ea stop -ErrorVariable $CError }

                            else {$wmi = gwmi -class Win32_OperatingSystem -computer $Server -ea stop -ErrorVariable $CError}
                            
		                    $LBTime = $wmi.ConvertToDateTime($wmi.Lastbootuptime)
		                    [TimeSpan]$uptime = New-TimeSpan $LBTime $(get-date)
                                                                     	
                            $outupt = New-Object -TypeName psobject -Property @{"ComputerName" = $Server
                             "Uptime" = "$($uptime.days) Days $($uptime.hours) Hours $($uptime.minutes) Minutes $($uptime.seconds) Seconds"
                             }
                            if ($testlable.Checked -eq $true){
                           $outupt | select ComputerName, uptime | out-Csv -Path $OutputFile -Append -NoTypeInformation  } else{                    			
		                $msgbx.Popup("$($uptime.days) Days $($uptime.hours) Hours $($uptime.minutes) Minutes $($uptime.seconds) Seconds",0,"Uptime for $Server",48+0)}
                        }
            
                }
                catch 
                {Write-Verbose "Failed processing $Server"
                $Server | Out-File $ErrorLog -Append
                }
 
                $progressbar1.PerformStep()
		if ($progressbar1.value -eq $progressbar1.Maximum){$progressbar1.ForeColor = 'Aqua'}
                $form.Refresh()
       		

    }
    End
    {
    
    }
}
Function Get-InventoryHW{
  [CmdletBinding(SupportsShouldProcess=$true, 
                  ConfirmImpact='Medium')]
    Param
    (
        # Param1 help description
        [Parameter(
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNull()]
        [String]$ErrorLog = "c:\tmp\InventoryHD Error.log",
        [String]$OutputFile = "c:\tmp\InventoryHD output.csv",
        [String]$cdrive = 'C$'

        )
Begin{

}
Process {      
$progressbar1.maximum = $servers.count  
Write-Verbose "$server"
try{


if (Test-Connection $server -Count 1 -ErrorAction stop) {

if (Test-Path "\\$server\$cdrive" -ErrorAction SilentlyContinue)

{
$ip = test-connection $server -count 1 | select ipv4address

#$outhd = gwmi -query "SELECT SystemName,Caption,VolumeName,Size,Freespace FROM win32_logicaldisk WHERE DriveType=3" -ComputerName $server -ErrorAction stop -ErrorVariable $Cerror|
#Select-Object SystemName,Caption,VolumeName, size, Freespace | select caption, size

$mem = gwmi win32_computersystem -ComputerName $server -ea Stop -ev $Cerror

$os = gwmi win32_operatingsystem -ComputerName $server -ea Stop -ev $Cerror

$bios = gwmi win32_bios -ComputerName $server -ea Stop -ev $Cerror

$Processor = gwmi win32_processor -ComputerName $server | select maxclockspeed -First 1 -ea Stop -ev $Cerror

if($mem.Model -like "Vmware *")
{
$dellomsa = "Not Installed"
$firmwarevers = "Virtual"
$firmwarename = "Virtual"
$firmwareip = "Virtual"
} 

if($mem.Model -notlike "Vmware *") {
$dell = gwmi -Namespace root\CIMv2\Dell -class Dell_SoftwareFeature -ComputerName $server | select version -ea SilentlyContinue -ev $Cerror
$dellomsa = $dell.version
$firmware1 =  gwmi -Namespace root\CIMv2\Dell -class Dell_RemoteAccessServicePort -ComputerName $server | select AccessInfo -ea SilentlyContinue -ev $Cerror
$firmwareip = $firmware1.accessinfo
$firmware2 =  gwmi -Namespace root\CIMv2\Dell -class Dell_Firmware -ComputerName $server |  Where-Object {($_.Name -like '*drac*')} | select version -ea SilentlyContinue -ev $Cerror
$firmware3 =  gwmi -Namespace root\CIMv2\Dell -class Dell_Firmware -ComputerName $server |   Where-Object {($_.Name -like '*drac*')} | select Name -ea SilentlyContinue -ev $Cerror
$firmwarevers = $firmware2.version
$firmwarename = $firmware3.name
}




 $output = [ordered]@{
'Server Name' = $Server;
'Description' = $OS.Description;
'IP Address' = $ip.ipv4address;
'Operating System' = $os.Caption;
'ServicePack Level' = $os.CSDVersion;
'Type' = if($mem.Model -like "Vmware *"){"Virtual"} else {"Physical"};
'Serial No' = $bios.SerialNumber;
'Manufacturer' = $mem.Manufacturer;
'Model' = $mem.Model;
'Processor' = $mem.NumberOfProcessors;
'Processor (GHz)' = $Processor.maxclockspeed / 1000;
'Memory (MBytes)' = $mem.TotalPhysicalMemory / 1mb;
'OMSA Version' = $dellomsa;
'iDRAC Version' = $firmwarename;
'iDrac IP Address' = $firmwareip;
'Firmware Version' = $firmwarevers
}
                            $outputobj = New-Object -TypeName psobject -Property $output                                                                              
                            export-Csv -Path "$OutputFile" -InputObject $Outputobj -NoTypeInformation -Append
}
else {
Write-Verbose "DMZ Server $server"
                                  $server,"DMZ" | Out-File $ErrorLog -Append
}
}
}
catch
{
Write-Verbose "Failed processing $server"
                                  $server,"Error" | Out-File $ErrorLog -Append
                                                                  
                                         }
}
End{
$progressbar1.PerformStep()
if ($progressbar1.value -eq $progressbar1.Maximum){$progressbar1.ForeColor = 'Aqua'}
           $form.Refresh()
}
}    
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
        [String]$Logfile = "C:\tmp\logfil_diskspace.txt",
        [String]$ds = "C:\tmp\Diskspace - Fast.csv"
       
 
        )
 Begin {
 $progressbar1.maximum = $servers.count

   }  
 process { 
        try
{
if ( Test-Connection -ComputerName $server -Count 1 -ErrorAction stop) {
Write-Verbose "Working on server $server"
if ($server -like "*mz*")
{
$dis = gwmi -query "SELECT SystemName,Caption,VolumeName,Size,Freespace FROM win32_logicaldisk WHERE DriveType=3" -ComputerName "$server" -Credential $cred -ErrorAction stop -ErrorVariable $CError|
Select-Object SystemName,Caption,VolumeName,@{Name="Size(GB)"; Expression={"{0:N2}" -f ($_.Size/1GB)}},@{Name="Freespace(GB)"; Expression={"{0:N2}" -f ($_.Freespace/1GB)}},@{Name="% Free"; Expression={"{0:N2}" -f (($_.Freespace/$_.Size)*100)}}
}

else
{$dis = gwmi -query "SELECT SystemName,Caption,VolumeName,Size,Freespace FROM win32_logicaldisk WHERE DriveType=3" -ComputerName $server -ErrorAction stop -ErrorVariable $CError|
Select-Object SystemName,Caption,VolumeName,@{Name="Size(GB)"; Expression={"{0:N2}" -f ($_.Size/1GB)}},@{Name="Freespace(GB)"; Expression={"{0:N2}" -f ($_.Freespace/1GB)}},@{Name="% Free"; Expression={"{0:N2}" -f (($_.Freespace/$_.Size)*100)}}   }

$dis | out-Csv $ds -Append -NoTypeInformation
}
}
catch
{

Write-Verbose "there was an erron on processing $server"
$server | Out-File $LogFile -Append                                                                                             
                                          }

}
End { $progressbar1.PerformStep()
		if ($progressbar1.value -eq $progressbar1.Maximum){$progressbar1.ForeColor = 'Aqua'}
                $form.Refresh()
                }
                }
Function Clean-Temp{
    [CmdletBinding(SupportsShouldProcess=$true, 
                  ConfirmImpact='Medium')]
    Param
    (
        [Parameter(
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true)]
        [string]$cdrive = 'C$',
        [string]$ddrive = 'D$',
        [string]$p1 = 'Program Files\BMC BladeLogic\RSC\',
        [string]$p2 = 'Program Files\BladeLogic\RSC\',
        [string]$p3 = 'Program Files\BMC Software\BladeLogic\RSCD\',
        [string]$p4 = 'Program Files\BMC Software\BladeLogic\8.1\RSCD\',
        [string]$t = 'temp\stage\',
        [string]$tm = 'tmp\stage\',
        [string]$log = "c:\tmp\Errorlog_diskcleanup.txt",
                $olddat = (get-date).AddMonths(-1)

        
    )

    Begin
    {
    $progressbar1.maximum = $servers.count
 
    }
    Process
    {
try {
        if (Test-connection $server -Count 1 -ea stop)
        {



# Map C drive using your ID or dmz ID
if (Test-Path "\\$server\$cdrive" -ErrorAction SilentlyContinue) 
{
ndr -Name MyDocs -PSProvider FileSystem -Root "\\$server\$cdrive " -ErrorAction Stop
ndr -Name MyDocs2 -PSProvider FileSystem -Root "\\$server\$ddrive" -ErrorAction Stop
}
else
{
ndr -Name MyDocs -PSProvider FileSystem -Root "\\$server\$cdrive" -Credential $cred -ErrorAction Stop
ndr -Name MyDocs2 -PSProvider FileSystem -Root "\\$server\$ddrive" -Credential $cred -ErrorAction Stop
}



Remove-Item -Path "MyDocs:\trace.txt" -force -ea SilentlyContinue

$p = $null
if (Test-Path "MyDocs:\$p1"){$p = "MyDocs:\$p1"}
elseif (Test-Path "MyDocs:\$p2"){$p = "MyDocs:\$p2"} 
elseif (Test-Path "MyDocs:\$p3"){$p = "MyDocs:\$p3"} 
elseif (Test-Path "MyDocs:\$p4"){$p = "MyDocs:\$p4"}
elseif (Test-Path "MyDocs2:\$p1"){$p = "MyDocs2:\$p1"}
elseif (Test-Path "MyDocs2:\$p2"){$p = "MyDocs2:\$p2"} 
elseif (Test-Path "MyDocs2:\$p3"){$p = "MyDocs2:\$p3"} 
elseif (Test-Path "MyDocs2:\$p4"){$p = "MyDocs2:\$p4"}
if (!($p -eq $null))
{
$p
Write-Verbose "working on Server $server"
ls "$p\Transactions" | where {$_.PSIsContainer -and $_.Name -ne "log" -and $_.Name -ne "Database" -and $_.Name -ne "events" -and $_.Name -ne "locks"}| Remove-Item -Recurse -Force
Remove-Item "$p\tmp\Trace.txt" -Force -ea SilentlyContinue

}

ls "MyDocs:\$t" -Recurse -Force -ea SilentlyContinue | Remove-Item -force -recurse 
ls "MyDocs:\$tm" -Recurse -Force -ea SilentlyContinue | Remove-Item -force -recurse

# Removing map drive
rdr -Name MyDocs
rdr -Name MyDocs2
}




}
catch {
Write-Verbose "Failed processing $server"
$server | Out-File $log -Append
}
    }
    End
    {
    $progressbar1.PerformStep()
	if ($progressbar1.value -eq $progressbar1.Maximum){$progressbar1.ForeColor = 'Aqua'}
    $form.Refresh()
    }
}
Function create-script{
    begin  
    {
    $progressbar1.ForeColor = 'Blue'
    $progressbar1.Value = 0
    Remove-Item "C:\tmp\UptimeError.txt" -Force -ea SilentlyContinue
    Remove-Item "C:\tmp\UptimeOutput.csv" -Force -ea SilentlyContinue
        if (!(Test-Path "c:\tmp\"))
        {
        New-Item "c:\tmp" -type directory
        }
        if ($testlable.checked -eq $true)
        {
          $servers = gc $flbrsrtxt.Text
                       
        }
        else 
        {
            $servers = $flbrsrtxt.Text
        }
        
        }
 process {

if ($Uptimebtn.checked -eq $true){
foreach ($Server in $Servers)
{ Get-UPTime -Verbose}
if ($testlable.Checked -eq $true){
Invoke-Item "c:\tmp\Uptimeoutput.csv"
}
}

elseif 
($DskSpcbtn.checked -eq $true){
Remove-Item -Path "C:\tmp\Diskspace - Fast_old.csv" -Force -ea SilentlyContinue
Rename-Item -Path "C:\tmp\Diskspace - Fast.csv" -NewName "C:\tmp\Diskspace - Fast_old.csv" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\tmp\logfil_diskspace.txt" -Force -ea SilentlyContinue
foreach ($server in $Servers)
{Get-hdetails -Verbose}
if ($testlable.Checked -eq $true){
Invoke-Item "C:\tmp\Diskspace - Fast.csv"

}
}

elseif ($DSKclnBtn.checked -eq $true)
{
foreach ($Server in $Servers)
{
Remove-Item -Path "c:\tmp\Errorlog_diskcleanup.txt" -Force -ea SilentlyContinue
Clean-Temp -Verbose}
}

elseif ($Inventorybtn.checked -eq $true -and $cpu.Checked -eq $true)
{
$ErrorLog = "c:\tmp\InventoryHD Error.log"
$OutputFile = "c:\tmp\InventoryHD output.csv"
Remove-Item -Path "$OutputFile" -Force -ea SilentlyContinue
Remove-Item -Path "$ErrorLog" -Force -ea SilentlyContinue
foreach ($Server in $Servers)
{
Get-InventoryHW -Verbose
}
Invoke-item $OutputFile
}

else{$msgbx.Popup("Please select a '.CSV File' or Type a ComputerName",0,"Hey!",48+0)}
}

}

# Adding contents to form
$form.controls.Add($btn)
$form.controls.Add($DMZ)
$form.Controls.Add($flbrsrbtn)
$form.controls.Add($flbrsrtxt)
$form.controls.Add($flbrsrlbl)
$form.controls.Add($xbtn)
$form.controls.Add($testlable)
$form.controls.Add($orlbl)
$form.controls.Add($progressbar1)
$Form.Controls.Add($groupBox)
$Form.Controls.Add($groupBox1)
$Form.Add_Shown({$Form.Activate()})
$form.ShowDialog()
