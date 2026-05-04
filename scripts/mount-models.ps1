# mount-models.ps1 - Mount shared models partition
Write-Host "=== Mounting AI Models Partition ===" -ForegroundColor Green

$vol = Get-Volume | Where-Object { $_.FileSystemLabel -eq "MODELS" }

if (-not $vol) {
    Write-Error "MODELS volume not found. Label the NTFS partition 'MODELS' in Disk Management."
    exit 1
}

if ($vol.DriveLetter -ne "D") {
    Set-Partition -DiskNumber $vol.DiskNumber -PartitionNumber $vol.PartitionNumber -NewDriveLetter D
    Write-Host "Assigned D: to MODELS partition" -ForegroundColor Cyan
}

New-Item -ItemType Directory -Force -Path "D:\AI\Models" | Out-Null
Write-Host "✅ Models mounted at D:\AI\Models" -ForegroundColor Green