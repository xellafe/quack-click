param(
    [string]$SoundPath = (Join-Path $PSScriptRoot "click.wav")
)

if (-not (Test-Path $SoundPath)) {
    Write-Host "File audio non trovato: $SoundPath" -ForegroundColor Red
    exit 1
}

Add-Type -TypeDefinition @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;

public class KeyboardClicker {
    private const int WH_KEYBOARD_LL = 13;
    private const int WM_KEYDOWN = 0x0100;
    private const int POOL_SIZE = 12;

    private static IntPtr hookId = IntPtr.Zero;
    private static HookProc hookProc;
    private static string soundFile;
    private static int aliasCounter = 0;

    public delegate IntPtr HookProc(int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("user32.dll")]
    private static extern IntPtr SetWindowsHookEx(int idHook, HookProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll")]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll")]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll")]
    private static extern IntPtr GetModuleHandle(string lpModuleName);

    [DllImport("user32.dll")]
    private static extern bool GetMessage(out MSG lpMsg, IntPtr hWnd, uint wMsgFilterMin, uint wMsgFilterMax);

    [DllImport("user32.dll")]
    private static extern bool TranslateMessage(ref MSG lpMsg);

    [DllImport("user32.dll")]
    private static extern IntPtr DispatchMessage(ref MSG lpMsg);

    [DllImport("winmm.dll", CharSet = CharSet.Auto)]
    private static extern int mciSendString(string command, System.Text.StringBuilder buffer, int bufferSize, IntPtr callback);

    [StructLayout(LayoutKind.Sequential)]
    public struct MSG {
        public IntPtr hwnd;
        public uint message;
        public IntPtr wParam;
        public IntPtr lParam;
        public uint time;
        public int pt_x;
        public int pt_y;
    }

    private static void PlaySound() {
        int id = Interlocked.Increment(ref aliasCounter) % POOL_SIZE;
        string alias = "kc" + id;
        mciSendString("close " + alias, null, 0, IntPtr.Zero);
        mciSendString("open \"" + soundFile + "\" alias " + alias, null, 0, IntPtr.Zero);
        mciSendString("play " + alias, null, 0, IntPtr.Zero);
    }

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam) {
        if (nCode >= 0 && wParam == (IntPtr)WM_KEYDOWN) {
            ThreadPool.QueueUserWorkItem(_ => {
                try { PlaySound(); } catch {}
            });
        }
        return CallNextHookEx(hookId, nCode, wParam, lParam);
    }

    public static void Start(string file) {
        soundFile = file;
        hookProc = HookCallback;
        using (var proc = Process.GetCurrentProcess())
        using (var mod = proc.MainModule) {
            hookId = SetWindowsHookEx(WH_KEYBOARD_LL, hookProc, GetModuleHandle(mod.ModuleName), 0);
        }

        MSG msg;
        while (GetMessage(out msg, IntPtr.Zero, 0, 0)) {
            TranslateMessage(ref msg);
            DispatchMessage(ref msg);
        }

        // Cleanup
        for (int i = 0; i < POOL_SIZE; i++)
            mciSendString("close kc" + i, null, 0, IntPtr.Zero);
        UnhookWindowsHookEx(hookId);
    }
}
"@

[KeyboardClicker]::Start($SoundPath)