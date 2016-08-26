#ERASE ALL THIS AND PUT XAML BELOW between the @" "@
$inputXML = @"
<Window x:Class="WpfApplication1.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApplication1"
        mc:Ignorable="d"
        Title="MGI Utility Tools Windows" Height="389.716" Width="297.872" Icon="C:\Users\Mahendran\Desktop\logo.png">
    <Grid Margin="0,0,-8,-66">
        <Grid.RowDefinitions>
            <RowDefinition/>
        </Grid.RowDefinitions>
        <Button x:Name="Run_Script_btn" Content="Run Script" HorizontalAlignment="Left" Margin="28,306,0,0" VerticalAlignment="Top" Width="75"/>
        <TextBox x:Name="filename_txtbox" HorizontalAlignment="Left" Height="28" Margin="101,70,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="116"/>
        <Button x:Name="browse_btn" Content="Browse" HorizontalAlignment="Left" Height="28" Margin="224,69,0,0" VerticalAlignment="Top" Width="52"/>
        <TextBlock x:Name="Caption_txtBlock" HorizontalAlignment="Left" Height="28" Margin="10,70,0,0" TextWrapping="Wrap" Text="Server Name" VerticalAlignment="Top" Width="84" FontSize="14" TextAlignment="Right"/>
        <RadioButton x:Name="server_rbtn" Content="Server Name" HorizontalAlignment="Left" Margin="41,109,0,0" VerticalAlignment="Top" IsChecked="True"/>
        <RadioButton x:Name="File_rbtn" Content="File" HorizontalAlignment="Left" Margin="176,109,0,0" VerticalAlignment="Top"/>
        <ProgressBar HorizontalAlignment="Left" Height="30" Margin="28,249,0,0" VerticalAlignment="Top" Width="235"/>
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
        <Image x:Name="image" HorizontalAlignment="Center" Height="60" Margin="0,4,0,0" VerticalAlignment="Top" Width="288" Source="C:\Users\Mahendran\Desktop\image.png"/>
    </Grid>
</Window>
"@       
 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
  try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."}
 
#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================
 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}
 
Get-FormVariables
 
#===========================================================================
# Actually make the objects work
#===========================================================================
 
Function Get-DiskInfo {
param($computername =$env:COMPUTERNAME)
 
Get-WMIObject Win32_logicaldisk -ComputerName $computername | Select-Object @{Name='ComputerName';Ex={$computername}},`
                                                                    @{Name=‘Drive Letter‘;Expression={$_.DeviceID}},`
                                                                    @{Name=‘Drive Label’;Expression={$_.VolumeName}},`
                                                                    @{Name=‘Size(MB)’;Expression={[int]($_.Size / 1MB)}},`
                                                                    @{Name=‘FreeSpace%’;Expression={[math]::Round($_.FreeSpace / $_.Size,2)*100}}
                                                                 }
 
$WPFtextBox.Text = $env:COMPUTERNAME
 
$WPFbutton.Add_Click({
$WPFlistView.Items.Clear()
start-sleep -Milliseconds 840
Get-DiskInfo -computername $WPFtextBox.Text | % {$WPFlistView.AddChild($_)}
})
#Sample entry of how to add data to a field
 
#$vmpicklistView.items.Add([pscustomobject]@{'VMName'=($_).Name;Status=$_.Status;Other="Yes"})
 
#===========================================================================
# Shows the form
#===========================================================================
write-host "To show the form, run the following" -ForegroundColor Cyan
$Form.ShowDialog() | out-null