# payCalc

A simple PowerShell overtime pay calculator with double-counted overtime.

## How It Works

Every hour over **8 in a day** counts as daily OT, and every hour over **40 in the week** counts as weekly OT. Both buckets are added together, so some hours get counted in both.

### Example

| Day       | Hours | Daily OT |
|-----------|-------|----------|
| Monday    | 10    | +2.00    |
| Tuesday   | 9     | +1.00    |
| Wednesday | 8     | --       |
| Thursday  | 10.25 | +2.25    |
| Friday    | 9     | +1.00    |
| Saturday  | 3.5   | --       |
| **Total** | **49.75** | **6.25** |

At $27.50/hr:

| | Hours | Rate | Amount |
|---|---|---|---|
| Regular | 33.75 | $27.50 | $928.13 |
| Daily OT | 6.25 | $41.25 | -- |
| Weekly OT | 9.75 | $41.25 | -- |
| **Total OT** | **16.00** | $41.25 | **$660.00** |
| **Total Pay** | | | **$1,588.13** |

## Usage

**Double-click `RunPayCalc.bat`** and follow the prompts:

1. Enter your hourly rate
2. Enter hours for each day (Sunday through Saturday)
3. View your paycheck breakdown

Or run directly from PowerShell:

```powershell
.\payCalc.ps1
```

### Run Without Downloading

Paste this one-liner into any PowerShell window -- no files needed:

```powershell
$f=Join-Path $env:TEMP "payCalc.ps1";irm "https://raw.githubusercontent.com/JevonThompsonx/payCalc.bat/refs/heads/main/payCalc.ps1" -OutFile $f;powershell -ExecutionPolicy Bypass -NoProfile -File $f;Remove-Item $f -Force
```

## Requirements

- Windows with PowerShell 5.1+
- No admin privileges needed

## Files

| File | Purpose |
|------|---------|
| `payCalc.ps1` | The calculator script |
| `RunPayCalc.bat` | Double-click launcher (bypasses execution policy) |

## Logs

Session transcripts are saved to `%LOCALAPPDATA%\payCalc\Logs\` and automatically cleaned up after 30 days.

## License

MIT
