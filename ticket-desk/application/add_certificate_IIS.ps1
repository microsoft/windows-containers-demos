Remove-IISSite -Name "Default Web Site" -confirm:$false

$certPath = "C:\mnt\secrets-store\..data\MY_CERT"  
$certPass = $Env:MY_CERT_PASSWORD

  
$pfx = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2  
$pfx.Import($certPath,$certPass,"Exportable,PersistKeySet")   
$store = New-Object System.Security.Cryptography.X509Certificates.X509Store("WebHosting","LocalMachine")   
$store.Open("ReadWrite")  
$store.Add($pfx)   
$store.Close()   
$certThumbprint = $pfx.Thumbprint

New-IISSite -Name "TicketCenter" -BindingInformation "*:443:" -PhysicalPath "C:\inetpub\wwwroot" -CertificateThumbPrint $certThumbprint -CertStoreLocation "Cert:\LocalMachine\Webhosting" -Protocol https

#New-IISSiteBinding -Name "Default Web Site" -BindingInformation "*:443:" -CertificateThumbPrint $certThumbprint -CertStoreLocation "Cert:\LocalMachine\Webhosting" -Protocol https