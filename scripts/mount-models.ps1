# mount-models.ps1 - Mount shared models partition with robust checks
Write-Host "=== Mounting AI Models Partition ===" -ForegroundColor Green

# Admin check
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[ERROR] Run as Administrator!" -ForegroundColor Red
    exit 1
}

$vol = Get-Volume | Where-Object { $_.FileSystemLabel -eq "MODELS" }

if (-not $vol) {
    Write-Host "[ERROR] MODELS volume not found!" -ForegroundColor Red
    Write-Host "   → Open Disk Management and label the NTFS partition 'MODELS'" -ForegroundColor Yellow
    exit 1
}

try {
    if ($vol.DriveLetter -ne "D") {
        if ($vol.DriveLetter) {
            # Remove existing letter first if needed
            Get-Partition -DriveLetter $vol.DriveLetter | Remove-PartitionAccessPath -AccessPath "$($vol.DriveLetter):\" -ErrorAction SilentlyContinue
        }
        Set-Partition -DiskNumber $vol.DiskNumber -PartitionNumber $vol.PartitionNumber -NewDriveLetter D -ErrorAction Stop
        Write-Host "✅ Assigned D: to MODELS partition" -ForegroundColor Green
    } else {
        Write-Host "✅ MODELS already mounted as D:" -ForegroundColor Green
    }

    New-Item -ItemType Directory -Force -Path "D:\AI\Models" | Out-Null
    Write-Host "✅ Models ready at D:\AI\Models" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Mount failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
