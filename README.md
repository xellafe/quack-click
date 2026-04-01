# quack-clicker

A PowerShell script that plays a "QUACK" sound on every key press, perfect for trolling your "friends".

## Structure

```
keyboard-clicker/
├── click.wav            # your custom sound
├── keyboard-click.ps1   # main script
├── install.ps1          # bootstrapper (downloads and runs)
└── README.md
```

## One-liner

Open PowerShell and run:

```powershell
irm https://raw.githubusercontent.com/xellafe/quack-click/main/install.ps1 | iex
```

For a shorter version:

```powershell
irm https://bit.ly/quack-click | iex
```

This command downloads the script and the audio file to `%TEMP%\keyboard-clicker\` and starts the process in background.

After the installation completes, `install.ps1` closes the current PowerShell window automatically.

## Manual execution

```powershell
# If the sound file is in the same folder
.\keyboard-click.ps1

# With a different sound
.\keyboard-click.ps1 -SoundPath "C:\path\to\another-sound.wav"
```

## Stop

```powershell
# From PowerShell
Get-Process powershell | Where-Object { $_.MainWindowTitle -eq "" } | Stop-Process

# Or from Task Manager: end the windowless "powershell" process
```

## Notes

- Uses the Win32 `SetWindowsHookEx` API (low-level keyboard hook)
- The `.wav` file must be in PCM WAV format (not MP3)
