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
            <RowDefinition Height="417"/>
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
        <TextBox x:Name="out_textBox" HorizontalAlignment="Left" Height="318" Margin="299,10,0,0" Text="Log Window" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto" 
         AcceptsReturn="True" VerticalAlignment="Top" Width="323" Background="Black" Foreground="#FF00FD00" FontSize="12" IsReadOnly="True" ForceCursor="True"/>
        <Label x:Name="label" Content="Windows" HorizontalAlignment="Left" Margin="75,16,0,0" VerticalAlignment="Top" FontSize="26" FontWeight="Bold" Foreground="#FFE65700" FontFamily="Calibri"/>
        <Label x:Name="label1" Content="team" HorizontalAlignment="Left" Margin="178,16,0,0" VerticalAlignment="Top" FontSize="26" FontFamily="Calibri" FontWeight="Bold"/>
        <Label x:Name="label2" Content="W" HorizontalAlignment="Left" Margin="42,11,0,0" VerticalAlignment="Top" FontSize="30" FontFamily="Marlett" Foreground="#FF15AAF3"/>
    </Grid>
</Window>
