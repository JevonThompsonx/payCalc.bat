<#
.SYNOPSIS
    Interactive Overtime Pay Calculator with Double-Counting

.DESCRIPTION
    Calculates weekly pay with both daily overtime (hours over 8/day)
    and weekly overtime (hours over 40/week) counted separately.
    Both OT buckets are summed together, so some hours may be counted
    in both daily and weekly OT (intentional double-counting policy).

.EXAMPLE
    .\payCalc.ps1
    (Interactive -- prompts for hourly rate and daily hours)

.NOTES
    Version: 1.1.0
    Date:    2026-02-08
    Exit Codes: 0=Success, 2=Invalid input / fatal error

    Changelog:
        1.0.0 - Initial release
        1.1.0 - Fixed PS 5.1 compatibility (inline if expressions, reserved $input variable),
                 added negative regular-hours guard, added transcript logging with rotation
#>

#region Configuration
$ErrorActionPreference = "Stop"

$LogDir = Join-Path $env:LOCALAPPDATA "payCalc\Logs"
if (-not (Test-Path $LogDir)) { New-Item -Path $LogDir -ItemType Directory -Force | Out-Null }
$LogPath = Join-Path $LogDir "payCalc_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Log rotation -- keep only last 30 days
Get-ChildItem $LogDir -Filter "payCalc_*.log" -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } |
    Remove-Item -Force -ErrorAction SilentlyContinue
#endregion

#region Functions
function Get-DecimalInput {
    param(
        [string]$Prompt,
        [double]$Min = 0,
        [double]$Max = 24
    )

    while ($true) {
        $rawInput = Read-Host $Prompt
        try {
            $value = [double]$rawInput
            if ($value -lt $Min -or $value -gt $Max) {
                Write-Host "  Invalid: must be between $Min and $Max" -ForegroundColor Red
                continue
            }
            return $value
        }
        catch {
            Write-Host "  Invalid: enter a number (decimals OK, e.g., 4.25)" -ForegroundColor Red
        }
    }
}
#endregion

#region Main
try {
    Start-Transcript -Path $LogPath -Force | Out-Null

    Write-Host "`n=== OVERTIME PAY CALCULATOR ===" -ForegroundColor Cyan
    Write-Host "Daily OT = hours over 8/day | Weekly OT = hours over 40/week"
    Write-Host "Both are counted (double-counting)" -ForegroundColor Yellow
    Write-Host ""

    # Get hourly rate
    $hourlyRate = Get-DecimalInput -Prompt "Enter hourly rate (e.g., 27.50)" -Min 0.01 -Max 999
    $otRate = $hourlyRate * 1.5

    # Get daily hours
    $days = @("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday")
    $hours = @()

    Write-Host "`nEnter hours for each day:" -ForegroundColor Cyan
    foreach ($day in $days) {
        $h = Get-DecimalInput -Prompt "  $day"
        $hours += $h
    }

    # Calculate daily overtime
    Write-Host "`n--- DAILY BREAKDOWN ---" -ForegroundColor Cyan
    $dailyOT = 0
    $totalHours = 0

    for ($i = 0; $i -lt 7; $i++) {
        $h = $hours[$i]
        $totalHours += $h
        $dayOT = [Math]::Max([double]0, $h - 8)
        $dailyOT += $dayOT

        if ($dayOT -gt 0) {
            $color = "Yellow"
            $otText = " (+$($dayOT.ToString('F2')) OT)"
        }
        else {
            $color = "Gray"
            $otText = ""
        }
        Write-Host ("{0,-10} {1,6:F2} hours{2}" -f $days[$i], $h, $otText) -ForegroundColor $color
    }

    # Calculate weekly overtime
    $weeklyOT = [Math]::Max([double]0, $totalHours - 40)

    # Total overtime (double counted)
    $totalOT = $dailyOT + $weeklyOT
    $regularHours = [Math]::Max([double]0, $totalHours - $totalOT)

    # Calculate pay
    $regularPay = $regularHours * $hourlyRate
    $otPay = $totalOT * $otRate
    $totalPay = $regularPay + $otPay

    # Display results
    Write-Host "`n--- OVERTIME CALCULATION ---" -ForegroundColor Cyan
    Write-Host ("Total Hours Worked:     {0,6:F2}" -f $totalHours) -ForegroundColor White
    Write-Host ("Daily OT (over 8/day):  {0,6:F2} hours" -f $dailyOT) -ForegroundColor Yellow
    Write-Host ("Weekly OT (over 40):    {0,6:F2} hours" -f $weeklyOT) -ForegroundColor Yellow
    Write-Host ("Total OT (double count):{0,6:F2} hours" -f $totalOT) -ForegroundColor Green
    Write-Host ("Regular Hours:          {0,6:F2} hours" -f $regularHours) -ForegroundColor Gray

    Write-Host "`n--- PAYCHECK ---" -ForegroundColor Cyan
    Write-Host ("Regular Pay:  {0,6:F2} hrs x `${1:F2} = `${2,9:F2}" -f $regularHours, $hourlyRate, $regularPay) -ForegroundColor White
    Write-Host ("Overtime Pay: {0,6:F2} hrs x `${1:F2} = `${2,9:F2}" -f $totalOT, $otRate, $otPay) -ForegroundColor Yellow
    Write-Host ("-----------------------------------------") -ForegroundColor Gray
    Write-Host ("TOTAL PAYCHECK:                 `${0,9:F2}" -f $totalPay) -ForegroundColor Green -BackgroundColor Black

    Write-Host ""
    Stop-Transcript -ErrorAction SilentlyContinue
    exit 0
}
catch {
    Write-Host "`nFATAL ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Red
    Stop-Transcript -ErrorAction SilentlyContinue
    exit 2
}
#endregion
