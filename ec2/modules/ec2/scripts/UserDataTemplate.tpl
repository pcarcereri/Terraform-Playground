<powershell>

$Username = "${Username}"
$Password = "${Password}"
$Group = "administrators"

# Create a user account to interact with WinRM
net user $Username $Password /add /y 
net localgroup $Group $Username /add

winrm quickconfig -q
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="300"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

netsh advfirewall firewall add rule name="WinRM 5985" protocol=TCP dir=in localport=5985 action=allow
netsh advfirewall firewall add rule name="WinRM 5986" protocol=TCP dir=in localport=5986 action=allow

net stop winrm
sc.exe config winrm start=auto
net start winrm

</powershell></powershell>