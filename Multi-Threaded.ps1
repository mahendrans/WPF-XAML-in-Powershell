$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$Global:syncHash = [hashtable]::Synchronized(@{})
$newRunspace =[runspacefactory]::CreateRunspace()
$newRunspace.ApartmentState = "STA"
$newRunspace.ThreadOptions = "ReuseThread"
$newRunspace.Open()
$newRunspace.SessionStateProxy.SetVariable("syncHash",$syncHash)
# Load WPF assembly if necessary
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
$psCmd = [PowerShell]::Create().AddScript({
$inputXML = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApplication1;assembly=WpfApplication1"
        mc:Ignorable="d"
        Title="MGI Utility Tools Windows" Height="380.801" Width="627.742">
    <Grid Margin="0,0,-8,-66">
        <Grid.RowDefinitions>
            <RowDefinition/>
        </Grid.RowDefinitions>
        <Button x:Name="Run_Script_btn" Content="Run Script" HorizontalAlignment="Left" Margin="28,306,0,0" VerticalAlignment="Top" Width="75"/>
        <TextBox x:Name="filename_txtbox" HorizontalAlignment="Left" Height="28" Text="$env:computername" Margin="101,70,0,0" VerticalAlignment="Top" Width="116"/>
        <Button x:Name="browse_btn" Content="Browse" HorizontalAlignment="Left" Height="28" Margin="224,69,0,0" VerticalAlignment="Top" Width="52" IsEnabled="False"/>
        <TextBlock x:Name="Caption_txtBlock" HorizontalAlignment="Left" Height="28" Margin="10,70,0,0" TextWrapping="Wrap" Text="Server Name" VerticalAlignment="Top" Width="84" FontSize="14" TextAlignment="Right"/>
        <RadioButton x:Name="server_rbtn" Content="Server Name" HorizontalAlignment="Left" Margin="41,109,0,0" VerticalAlignment="Top" IsChecked="True"/>
        <RadioButton x:Name="File_rbtn" Content="File" HorizontalAlignment="Left" Margin="176,109,0,0" VerticalAlignment="Top" IsChecked="False"/>
        <ProgressBar x:Name="progress_bar" HorizontalAlignment="Left" Height="30" Margin="28,249,0,0" VerticalAlignment="Top" Width="235"/>
        <Button x:Name="Exit_btn" Content="Exit" HorizontalAlignment="Left" Margin="188,306,0,0" VerticalAlignment="Top" Width="75"/>
        <GroupBox x:Name="groupBox_radiobtn" Header="Select Tools" HorizontalAlignment="Left" Height="101" Margin="28,135,0,0" VerticalAlignment="Top" Width="114">
            <Grid HorizontalAlignment="Left" Height="101" VerticalAlignment="Top"
		  Width="104" Margin="0,0,-2,-22">
                <RadioButton x:Name="Uptime_rbtn" Content="Uptime" HorizontalAlignment="Left" Margin="5,3,0,0" VerticalAlignment="Top" IsChecked="True"/>
                <RadioButton x:Name="Diskspc_rbtn" Content="Disk Space" HorizontalAlignment="Left" Margin="5,23,0,0" VerticalAlignment="Top" IsChecked="False"/>
                <RadioButton x:Name="DiskCln_rbtn" Content="Disk Cleanup" HorizontalAlignment="Left" Margin="5,43,0,0" VerticalAlignment="Top" IsChecked="False"/>
                <RadioButton x:Name="Inventory_rbtn" Content="Inventory" HorizontalAlignment="Left" Margin="5,63,0,0" VerticalAlignment="Top" IsChecked="False"/>
            </Grid>
        </GroupBox>
        <GroupBox x:Name="groupBox_invoption" Header="Inventory Option" Height="74" Margin="147,137,365,0" VerticalAlignment="Top" IsEnabled="False">
            <Grid HorizontalAlignment="Left" Height="91" VerticalAlignment="Top"
		  Width="141" Margin="0,0,-45,-39">
                <RadioButton x:Name="inventory_HW" Content="Hardware" HorizontalAlignment="Left" IsChecked="False" Margin="5,5,0,0" VerticalAlignment="Top"/>
                <RadioButton x:Name="inventory_SW" Content="Software" HorizontalAlignment="Left" IsChecked="False" Margin="5,25,0,0" VerticalAlignment="Top"/>
            </Grid>
        </GroupBox>
        <Image x:Name="image" HorizontalAlignment="Center" Height="60" Margin="30,9,340,0" VerticalAlignment="Top" Width="288" Source="$1\windowsteam.png"/>
        <TextBox x:Name="out_textBox" HorizontalAlignment="Left" Height="318" Margin="299,10,0,0" Text="Log Window" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto" 
         AcceptsReturn="True" VerticalAlignment="Top" Width="323" Background="Black" Foreground="#FF00FD00" FontSize="12" IsReadOnly="True" ForceCursor="True"/>
    </Grid>
</Window>
"@       
 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    
    $syncHash.Window=[Windows.Markup.XamlReader]::Load( $reader )

    [xml]$XAML = $xaml
        $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | %{
        #Find all of the form types and add them as members to the synchash
        $syncHash.Add($_.Name,$syncHash.Window.FindName($_.Name) ) }


    $Script:JobCleanup = [hashtable]::Synchronized(@{})
    $Script:Jobs = [system.collections.arraylist]::Synchronized((New-Object System.Collections.ArrayList))

    #region Background runspace to clean up jobs
    $jobCleanup.Flag = $True
    $newRunspace =[runspacefactory]::CreateRunspace()
    $newRunspace.ApartmentState = "STA"
    $newRunspace.ThreadOptions = "ReuseThread"          
    $newRunspace.Open()        
    $newRunspace.SessionStateProxy.SetVariable("jobCleanup",$jobCleanup)     
    $newRunspace.SessionStateProxy.SetVariable("jobs",$jobs) 
    $jobCleanup.PowerShell = [PowerShell]::Create().AddScript({
        #Routine to handle completed runspaces
        Do {    
            Foreach($runspace in $jobs) {            
                If ($runspace.Runspace.isCompleted) {
                    [void]$runspace.powershell.EndInvoke($runspace.Runspace)
                    $runspace.powershell.dispose()
                    $runspace.Runspace = $null
                    $runspace.powershell = $null               
                } 
            }
            #Clean out unused runspace jobs
            $temphash = $jobs.clone()
            $temphash | Where {
                $_.runspace -eq $Null
            } | ForEach {
                $jobs.remove($_)
            }        
            Start-Sleep -Seconds 1     
        } while ($jobCleanup.Flag)
    })
    $jobCleanup.PowerShell.Runspace = $newRunspace
    $jobCleanup.Thread = $jobCleanup.PowerShell.BeginInvoke()  
    #endregion Background runspace to clean up jobs
    
    
    #region Flie browser 
    Function fe-ne ($fd){
 [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Win32.OpenFileDialog") | Out-Null
 $opf = New-Object Microsoft.Win32.OpenFileDialog
 $opf.initialDirectory = "$fd"
 $opf.filter = "Server Name files (*.Txt)|*.Txt"
 $opf.ShowDialog() | Out-Null
 $opf.filename
 $synchash.filename_txtbox.Text = $opf.filename
 }
    $syncHash.browse_btn.add_click({fe-ne})
    #endregion Flie browser

    #region Single server and multiple server text file selection
    
    $synchash.File_rbtn.add_click({
    $syncHash.Caption_txtBlock.Text = "File Name"
    $syncHash.browse_btn.IsEnabled = $True
    $synchash.filename_txtbox.Text = ""
    })

    $synchash.server_rbtn.add_click({
    $syncHash.Caption_txtBlock.Text = "Server Name"
    $syncHash.browse_btn.IsEnabled = $false
    $synchash.filename_txtbox.Text = ""
    })

    #endregion Single server and multiple server text file selection

    #region radio button controls
    $synchash.Uptime_rbtn.add_click({$synchash.inventory_HW.Ischecked = $false; $synchash.inventory_SW.Ischecked = $false; $synchash.groupBox_invoption.IsEnabled = $false})
    $syncHash.DiskCln_rbtn.add_click({$synchash.inventory_HW.Ischecked = $false; $synchash.inventory_SW.Ischecked = $false; $synchash.groupBox_invoption.IsEnabled = $false})
    $synchash.Diskspc_rbtn.add_click({$synchash.inventory_HW.Ischecked = $false; $synchash.inventory_SW.Ischecked = $false; $synchash.groupBox_invoption.IsEnabled = $false})
    $syncHash.Inventory_rbtn.add_click({$synchash.inventory_HW.Ischecked = $true;$synchash.groupBox_invoption.IsEnabled = $true})
    #endregion radio button controls

    
    #region run button
    $synchash.Run_Script_btn.add_click(
    
    {   $Hash = [hashtable]::Synchronized(@{})  
        $Hash.filename_txtbox = $SyncHash.filename_txtbox.Text
        $Hash.File_rbtn = $syncHash.File_rbtn.IsChecked
        $Hash.server_rbtn = $syncHash.server_rbtn.IsChecked
        $Hash.progress_bar = $syncHash.progress_bar
        $Hash.Uptime_rbtn = $syncHash.Uptime_rbtn.IsChecked
        $Hash.Diskspc_rbtn = $syncHash.Diskspc_rbtn.IsChecked
        $Hash.DiskCln_rbtn = $syncHash.DiskCln_rbtn.IsChecked
        $Hash.Inventory_HW = $syncHash.inventory_HW.IsChecked
        $Hash.Inventory_SW = $syncHash.inventory_SW.IsChecked 
        $Hash.out_textBox = $SyncHash.out_textBox     
        #region Boe's Additions
        $newRunspace =[runspacefactory]::CreateRunspace()
        $newRunspace.ApartmentState = "STA"
        $newRunspace.ThreadOptions = "ReuseThread"          
        $newRunspace.Open()
        $newRunspace.SessionStateProxy.SetVariable("SyncHash",$SyncHash) 
        $newRunspace.SessionStateProxy.SetVariable("Hash",$Hash) 
        $PowerShell = [PowerShell]::Create().AddScript({
Function Update-Window {
        Param (
            $Control,
            $Property,
            $Value,
            [switch]$AppendContent
        )

        # This is kind of a hack, there may be a better way to do this
        If ($Property -eq "Close") {
            $syncHash.Window.Dispatcher.invoke("Normal",[action]{$syncHash.Window.Close()})
            Return
        }

        # This updates the control based on the parameters passed to the function
        $syncHash.$Control.Dispatcher.Invoke("Normal",[action]{
            # This bit is only really meaningful for the TextBox control, which might be useful for logging progress steps
            If ($PSBoundParameters['AppendContent']) {
                $syncHash.$Control.AppendText($Value)
            } Else {
                $syncHash.$Control.$Property = $Value
            }
        })
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
            
           try { 
           if ( Test-Connection -ComputerName $server -Count 1 -ErrorAction stop) {
                            update-window -Control out_textBox -Property text -Value ("$Server"+"`r`n") -AppendContent
                                                       
		                    if ($server -like "*mz*")
                            {$wmi = gwmi -class Win32_OperatingSystem -computer $server -Credential $cred -ea stop -ErrorVariable $CError }

                            else {$wmi = gwmi -class Win32_OperatingSystem -computer $Server -ea stop -ErrorVariable $CError}
                            
		                    $LBTime = $wmi.ConvertToDateTime($wmi.Lastbootuptime)
		                    [TimeSpan]$uptime = New-TimeSpan $LBTime $(get-date)
                                                                     	
                            $outupt = New-Object -TypeName psobject -Property @{"ComputerName" = $Server
                             "Uptime" = "$($uptime.days) Days $($uptime.hours) Hours $($uptime.minutes) Minutes $($uptime.seconds) Seconds"
                             }
                            if ($Hash.File_rbtn -eq $true){
                           $outupt | select ComputerName, uptime | out-Csv -Path $OutputFile -Append -NoTypeInformation  } else{                    			
		                $msgbx.Popup("$($uptime.days) Days $($uptime.hours) Hours $($uptime.minutes) Minutes $($uptime.seconds) Seconds",0,"Uptime for $Server",48+0)}
                        }
            
                }
                catch 
                {
                update-window -Control out_textBox -Property text -Value ("Failed processing $Server"+"`r`n") -AppendContent
                $Server | Out-File $ErrorLog -Append
                }
 
                
               
       		

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
update-window -Control out_textBox -Property text -Value ("$Server"+"`r`n") -AppendContent
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
update-window -Control out_textBox -Property text -Value ("$Server Invalid Credentials"+"`r`n") -AppendContent
                                  $server,"Invalide Credentials" | Out-File $ErrorLog -Append
}
}
}
catch
{
update-window -Control out_textBox -Property text -Value ("Unable to access $Server"+"`r`n") -AppendContent
                                  $server,"Error" | Out-File $ErrorLog -Append
                                                                  
                                         }
}
End{

}
}
Function Get-Diskspc{
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
        [String]$ds = "C:\tmp\Diskspace - Fast.csv",
        [String]$cdrive = 'C$'
       
 
        )
 Begin {

   }  
 process { 
        try
{
if ( Test-Connection -ComputerName $server -Count 1 -ErrorAction stop) {
if (Test-Path "\\$server\$cdrive" -ErrorAction SilentlyContinue){
update-window -Control out_textBox -Property text -Value ("$Server"+"`r`n") -AppendContent
$dis = gwmi -query "SELECT SystemName,Caption,VolumeName,Size,Freespace FROM win32_logicaldisk WHERE DriveType=3" -ComputerName $server -ErrorAction stop -ErrorVariable $CError|
Select-Object SystemName,Caption,VolumeName,@{Name="Size(GB)"; Expression={"{0:N2}" -f ($_.Size/1GB)}},@{Name="Freespace(GB)"; Expression={"{0:N2}" -f ($_.Freespace/1GB)}},@{Name="% Free"; Expression={"{0:N2}" -f (($_.Freespace/$_.Size)*100)}}   
$dis | out-Csv $ds -Append -NoTypeInformation
}
else {
update-window -Control out_textBox -Property text -Value ("$Server Invalid Credentials"+"`r`n") -AppendContent
                                  $server,"Invalide Credentials" | Out-File $Logfile -Append
}

}
}
catch
{

Write-Verbose "there was an erron on processing $server"
$server | Out-File $LogFile -Append                                                                                             
                                          }

}
End {}
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
    }
    Process
    {
try {
        if (Test-connection $server -Count 1 -ea stop)
        {



# Map C drive using your login ID
if (Test-Path "\\$server\$cdrive" -ErrorAction SilentlyContinue) 
{
ndr -Name MyDocs -PSProvider FileSystem -Root "\\$server\$cdrive " -ErrorAction Stop
ndr -Name MyDocs2 -PSProvider FileSystem -Root "\\$server\$ddrive" -ErrorAction Stop
update-window -Control out_textBox -Property text -Value ("$Server"+"`r`n") -AppendContent
}
else
{
update-window -Control out_textBox -Property text -Value ("$Server Invalid Credentials"+"`r`n") -AppendContent
                                  $server,"Invalide Credentials" | Out-File $log -Append
}



Remove-Item -Path "MyDocs:\trace.txt" -force -ea SilentlyContinue
ls "MyDocs:\$t" -Recurse -Force -ea SilentlyContinue | Remove-Item -force -recurse 
ls "MyDocs:\$tm" -Recurse -Force -ea SilentlyContinue | Remove-Item -force -recurse
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
ls "$p\Transactions" | where {$_.PSIsContainer -and $_.Name -ne "log" -and $_.Name -ne "Database" -and $_.Name -ne "events" -and $_.Name -ne "locks"}| Remove-Item -Recurse -Force
Remove-Item "$p\tmp\Trace.txt" -Force -ea SilentlyContinue

}


# Removing map drive
rdr -Name MyDocs
rdr -Name MyDocs2
}




}
catch {
update-window -Control out_textBox -Property text -Value ("Unable to access $Server"+"`r`n") -AppendContent
"Unable to access $server" | Out-File $log -Append
}
    }
    End
    {
    
    }
}

$msgbx = New-Object -ComObject Wscript.Shell -ErrorAction Stop

   update-window -Control out_textBox -Property text -Value ""
   Update-Window -Control progress_bar -Property Foreground -Value "Red"
   Update-Window -Control progress_bar -Property value -Value 0
    Remove-Item "C:\tmp\UptimeError.txt" -Force -ea SilentlyContinue
    Remove-Item "C:\tmp\UptimeOutput.csv" -Force -ea SilentlyContinue
        if (!(Test-Path "c:\tmp\"))
        {
        New-Item "c:\tmp" -type directory
        }

    
if($Hash.File_rbtn -eq $True){$servers = gc $Hash.filename_txtbox}else{$servers = $Hash.filename_txtbox}
$Hash.progress_max = $servers.count
$Count = 0 
if ($Hash.Uptime_rbtn -eq $true){ 
foreach ($Server in $Servers)
{
$Count ++ 
Get-UPTime
update-window -Control Progress_bar -Property Value -Value "$(($Count/$Servers.Count)*100)"
}
update-window -Control Progress_bar -Property Foreground -Value "Green"
if ($Hash.File_rbtn -eq $true){Invoke-Item "c:\tmp\Uptimeoutput.csv"}}
elseif ($Hash.Diskspc_rbtn -eq $true){
foreach ($Server in $Servers){
$Count ++
Get-Diskspc
update-window -Control Progress_bar -Property Value -Value "$(($Count/$Servers.Count)*100)"
}
update-window -Control Progress_bar -Property Foreground -Value "Green"
if ($Hash.File_rbtn -eq $true){Invoke-Item "C:\tmp\Diskspace - Fast.csv"}
}
elseif ($Hash.DiskCln_rbtn -eq $true){
foreach ($Server in $Servers){
$Count ++
Clean-Temp
update-window -Control Progress_bar -Property Value -Value "$(($Count/$Servers.Count)*100)"
}
update-window -Control Progress_bar -Property Foreground -Value "Green"
if ($Hash.File_rbtn -eq $true){Invoke-Item "c:\tmp\Errorlog_diskcleanup.txt"}

}
elseif ($Hash.Inventory_HW){
foreach ($Server in $Servers){
$Count ++
Get-InventoryHW
update-window -Control Progress_bar -Property Value -Value "$(($Count/$Servers.Count)*100)"
}
update-window -Control Progress_bar -Property Foreground -Value "Green"
if ($Hash.File_rbtn -eq $true){Invoke-Item "c:\tmp\InventoryHD output.csv"}
}
elseif ($Hash.Inventory_SW){$Count ++

update-window -Control Progress_bar -Property Value -Value "$(($Count/$Servers.Count)*100)"}
        })
        $PowerShell.Runspace = $newRunspace
        [void]$Jobs.Add((
            [pscustomobject]@{
                PowerShell = $PowerShell
                Runspace = $PowerShell.BeginInvoke()
            }
        ))
    }

    )

    #endregion run button


    #region Drag n Drop Control
    $syncHash.Window.AllowDrop = $true

    $syncHash.Window.add_drop({$1 = $_.Data.GetFileDropList()
    if($1 -like "*.txt"){$syncHash.filename_txtbox.Text = $1
    $syncHash.File_rbtn.IsChecked = $True
    $synchash.Caption_txtBlock.Text = "File Name"
    $syncHash.browse_btn.IsEnabled = $True}
    })

    #endregion Drag n Drop Control
    
    #region Window Close 
    
    $syncHash.Exit_btn.add_click({
    $syncHash.Window.Close()}
    )
    $syncHash.Window.Add_Closed({
        Write-Verbose 'Halt runspace cleanup job processing'
        $jobCleanup.Flag = $False

        #Stop all runspaces
        $jobCleanup.PowerShell.Dispose()      
    })
    #endregion Window Close 
   

   

    #$syncHash.Window.Activate()
    $syncHash.Window.ShowDialog() | Out-Null
    $syncHash.Error = $Error
})
$psCmd.Runspace = $newRunspace
$data = $psCmd.BeginInvoke()
$scriptpath
Do
      {
         Start-Sleep 5
         
      } until ($data.IsCompleted -eq $true)


