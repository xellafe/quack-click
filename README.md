# keyboard-clicker

Script PowerShell che riproduce un suono custom ad ogni pressione di tasto. Zero dipendenze, solo Windows 11 (o 10).

## Struttura

```
keyboard-clicker/
├── click.wav            # il tuo suono custom
├── keyboard-click.ps1   # script principale
├── install.ps1          # bootstrap (scarica ed esegue)
└── README.md
```

## One-liner

Apri PowerShell ed esegui:

```powershell
irm https://raw.githubusercontent.com/TUO-USERNAME/keyboard-clicker/main/install.ps1 | iex
```

Questo scarica lo script e il file audio in `%TEMP%\keyboard-clicker\` e lancia tutto in background (finestra nascosta).

## Esecuzione manuale

```powershell
# Con il suono nella stessa cartella
.\keyboard-click.ps1

# Con un suono diverso
.\keyboard-click.ps1 -SoundPath "C:\percorso\altro-suono.wav"
```

## Stop

```powershell
# Da PowerShell
Get-Process powershell | Where-Object { $_.MainWindowTitle -eq "" } | Stop-Process

# Oppure da Task Manager: termina il processo "powershell" senza finestra
```

## Note

- Usa le API Win32 `SetWindowsHookEx` (low-level keyboard hook)
- Il file `.wav` deve essere in formato PCM WAV (non MP3)
- Nessuna dipendenza esterna: solo PowerShell + .NET integrato
