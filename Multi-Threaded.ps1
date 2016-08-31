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
        Title="MGI Utility Tools Windows" Height="389.716" Width="297.872">
    <Grid Margin="0,0,-8,-66">
        <Grid.RowDefinitions>
            <RowDefinition/>
        </Grid.RowDefinitions>
        <Button x:Name="Run_Script_btn" Content="Run Script" HorizontalAlignment="Left" Margin="28,306,0,0" VerticalAlignment="Top" Width="75"/>
        <TextBox x:Name="filename_txtbox" HorizontalAlignment="Left" Height="28" Margin="101,70,0,0" VerticalAlignment="Top" Width="116"/>
        <Button x:Name="browse_btn" Content="Browse" HorizontalAlignment="Left" Height="28" Margin="224,69,0,0" VerticalAlignment="Top" Width="52"/>
        <TextBlock x:Name="Caption_txtBlock" HorizontalAlignment="Left" Height="28" Margin="10,70,0,0" TextWrapping="Wrap" Text="Server Name" VerticalAlignment="Top" Width="84" FontSize="14" TextAlignment="Right"/>
        <RadioButton x:Name="server_rbtn" Content="Server Name" HorizontalAlignment="Left" Margin="41,109,0,0" VerticalAlignment="Top" IsChecked="True"/>
        <RadioButton x:Name="File_rbtn" Content="File" HorizontalAlignment="Left" Margin="176,109,0,0" VerticalAlignment="Top"/>
        <ProgressBar x:Name="progress_bar" HorizontalAlignment="Left" Height="30" Margin="28,249,0,0" VerticalAlignment="Top" Width="235"/>
        <Button x:Name="Exit_btn" Content="Exit" HorizontalAlignment="Left" Margin="188,306,0,0" VerticalAlignment="Top" Width="75"/>
        <GroupBox x:Name="groupBox_radiobtn" Header="Select Tools" HorizontalAlignment="Left" Height="101" Margin="28,135,0,0" VerticalAlignment="Top" Width="114">
            <Grid HorizontalAlignment="Left" Height="101" VerticalAlignment="Top"
		  Width="104" Margin="0,0,-2,-22">
                <RadioButton x:Name="Uptime_rbtn" Content="Uptime" HorizontalAlignment="Left" Margin="5,3,0,0" VerticalAlignment="Top" IsChecked="True"/>
                <RadioButton x:Name="Diskspc_rbtn" Content="Disk Space" HorizontalAlignment="Left" Margin="5,23,0,0" VerticalAlignment="Top"/>
                <RadioButton x:Name="DiskCln_rbtn" Content="Disk Cleanup" HorizontalAlignment="Left" Margin="5,43,0,0" VerticalAlignment="Top"/>
                <RadioButton x:Name="Iventory_rbtn" Content="Inventory" HorizontalAlignment="Left" Margin="5,63,0,0" VerticalAlignment="Top"/>
            </Grid>
        </GroupBox>
        <GroupBox x:Name="groupBox_invoption" Header="Inventory Option" Height="74" Margin="147,137,35,0" VerticalAlignment="Top" IsEnabled="False">
            <Grid HorizontalAlignment="Left" Height="91" VerticalAlignment="Top"
		  Width="104" Margin="0,0,-2,-12">
                <CheckBox x:Name="CheckBox_HW" Content="Hardware" HorizontalAlignment="Left" Margin="5,5,0,0" VerticalAlignment="Top"/>
                <CheckBox x:Name="CheckBox_SW" Content="Software" HorizontalAlignment="Left" Margin="5,25,0,0" VerticalAlignment="Top"/>
            </Grid>
        </GroupBox>
        <Image x:Name="image" HorizontalAlignment="Center" Height="60" Margin="0,4,0,0" VerticalAlignment="Top" Width="288" Source="$scriptPath\image.png"/>
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
        $syncHash.Add($_.Name,$syncHash.Window.FindName($_.Name) )

    }

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

    $syncHash.button.Add_Click({
        #Start-Job -Name Sleeping -ScriptBlock {start-sleep 5}
        #while ((Get-Job Sleeping).State -eq 'Running'){
            $x+= "."
        #region Boe's Additions
        $newRunspace =[runspacefactory]::CreateRunspace()
        $newRunspace.ApartmentState = "STA"
        $newRunspace.ThreadOptions = "ReuseThread"          
        $newRunspace.Open()
        $newRunspace.SessionStateProxy.SetVariable("SyncHash",$SyncHash) 
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
            $syncHash.Window.Dispatcher.invoke([action]{$syncHash.Window.Close()},"Normal")
            Return
        }

        # This updates the control based on the parameters passed to the function
        $syncHash.$Control.Dispatcher.Invoke([action]{
            # This bit is only really meaningful for the TextBox control, which might be useful for logging progress steps
            If ($PSBoundParameters['AppendContent']) {
                $syncHash.$Control.AppendText($Value)
            } Else {
                $syncHash.$Control.$Property = $Value
            }
        }, "Normal")
    }                        
Update-Window -Control StarttextBlock -Property ForeGround -Value White                                                       
start-sleep -Milliseconds 850
$x += 1..15000000
update-window -Control ProgressBar -Property Value -Value 25

update-window -Control TextBox -property text -value $x -AppendContent
Update-Window -Control ProcesstextBlock -Property ForeGround -Value White                                                       
start-sleep -Milliseconds 850
update-window -Control ProgressBar -Property Value -Value 50

Update-Window -Control FiltertextBlock -Property ForeGround -Value White                                                       
start-sleep -Milliseconds 500
update-window -Control ProgressBar -Property Value -Value 75

Update-Window -Control DonetextBlock -Property ForeGround -Value White                                                       
start-sleep -Milliseconds 200
update-window -Control ProgressBar -Property Value -Value 100
        })
        $PowerShell.Runspace = $newRunspace
        [void]$Jobs.Add((
            [pscustomobject]@{
                PowerShell = $PowerShell
                Runspace = $PowerShell.BeginInvoke()
            }
        ))
    })

    #region Window Close 
    $syncHash.Window.Add_Closed({
        Write-Verbose 'Halt runspace cleanup job processing'
        $jobCleanup.Flag = $False

        #Stop all runspaces
        $jobCleanup.PowerShell.Dispose()      
    })
    #endregion Window Close 
    #endregion Boe's Additions

    #$x.Host.Runspace.Events.GenerateEvent( "TestClicked", $x.test, $null, "test event")

    #$syncHash.Window.Activate()
    $syncHash.Window.ShowDialog() | Out-Null
    $syncHash.Error = $Error
})
$psCmd.Runspace = $newRunspace
$data = $psCmd.BeginInvoke()
