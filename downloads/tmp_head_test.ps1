try {
  $u = 'https://1drv.ms/f/c/3f95a286c2fabb4d/Ek27-sKGopUggD9oAAAAAAABhAJxoEGCvv-SUNno17kEgA?e=KizCPc&download=1'
  $h = Invoke-WebRequest -Method Head -Uri $u -MaximumRedirection 10 -ErrorAction Stop
  Write-Host $h.Headers['Content-Type']
} catch {
  Write-Host $_.Exception.Message
}
