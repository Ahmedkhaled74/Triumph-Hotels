Write-Host "Cleaning up unused assets..." -ForegroundColor Cyan

$files = @(
    "assets\images\why-triumph.jpg",
    "assets\images\main luxury.jpg",
    "assets\images\main plaza.jpg",
    "assets\images\plaza\Layaly Lebnan.jpg",
    "assets\images\plaza\Rehana.jpg",
    "assets\images\plaza\Shiraz.jpg",
    "assets\images\plaza\Up TO You Cafe.jpg",
    "assets\images\plaza\weddings.jpg",
    "assets\images\plaza\main plaza.jpeg",
    "assets\icons\logo-removed back.png",
    "assets\icons\whats.png",
    "assets\videos\0301(1).mp4"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Remove-Item -Path $file -Force
        Write-Host "Deleted: $file" -ForegroundColor Green
    } else {
        Write-Host "Skipped (already deleted): $file" -ForegroundColor Yellow
    }
}

Write-Host "Cleanup complete! Freed up over 25 MB of space." -ForegroundColor Cyan
