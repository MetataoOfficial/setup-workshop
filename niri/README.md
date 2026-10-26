# Niri WM Keybindings

The keybindings are designed around spatial layers and ergonomic muscle memory:

- **H / L (or ← / →)**: Columns (left / right)
- **J / K (or ↓ / ↑)**: Windows in column / Workspaces (up / down)
- **N / I / O / U (or Ctrl + 方向键)**: Monitors (left / up / down / right)

Navigation Anchors:

- **A**: Previous workspace
- **Y**: First workspace (Workspace 1)
- **G**: Bottom / scratch workspace (Workspace 9)
- **M**: Center current column
- **S**: Toggle column tabbed display

Application Quick Launch:

- **T / Return**: Terminal (`ghostty`)
- **W / Space**: Web browser (`firefox`)
- **E / Esc**: Editor (`neovide`)
- **F / Backspace**: File manager (`nemo`)
- **D**: Document viewer (`evince`)
- **X**: Application launcher (`xfce4-appfinder`)

---

## 1. Navigation

### Column Navigation

| Key | Action |
| :--- | :--- |
| `Mod + H` / `Mod + ←` | Focus left column |
| `Mod + L` / `Mod + →` | Focus right column |
| `Mod + Home` | Focus first column |
| `Mod + End` | Focus last column |
| `Mod + Shift + Home` | Move column to first |
| `Mod + Shift + End` | Move column to last |
| `Mod + M` | Center current column |

### Workspace & Window Vertical Navigation

| Key | Action |
| :--- | :--- |
| `Mod + J` / `Mod + ↓` | Focus window down / workspace down |
| `Mod + K` / `Mod + ↑` | Focus window up / workspace up |
| `Mod + PageDown` / `Mod + WheelDown` | Focus workspace down |
| `Mod + PageUp` / `Mod + WheelUp` | Focus workspace up |
| `Mod + A` | Return to previous workspace |
| `Mod + Y` | Jump to workspace 1 |
| `Mod + G` | Jump to workspace 9 (scratch workspace) |

### Recent Windows & Overview

| Key | Action |
| :--- | :--- |
| `Mod + Grave` / `Mod + Shift + Grave` | Toggle overview |
| `Mod + Tab` | Next recent window (scope: all) |
| `Mod + Shift + Tab` | Previous recent window (scope: all) |
| `Alt + Tab` | Next recent window (scope: workspace) |
| `Alt + Shift + Tab` | Previous recent window (scope: workspace) |
| `Alt + Grave` | Previous window of same application (`app-id`) |
| `Alt + Shift + Grave` | Next window of same application (`app-id`) |

---

## 2. Workspace Management

| Key | Action |
| :--- | :--- |
| `Mod + 1…5` | Focus workspace 1…5 |
| `Mod + Shift + 1…5` | Move current column to workspace 1…5 |
| `Mod + Shift + Y` | Move current column to workspace 1 |
| `Mod + Shift + G` | Move current column to workspace 9 |
| `Mod + Shift + J` / `Mod + Shift + ↓` | Move column to workspace down |
| `Mod + Shift + K` / `Mod + Shift + ↑` | Move column to workspace up |
| `Mod + Shift + PageDown` / `Mod + Shift + WheelDown` | Move window down |
| `Mod + Shift + PageUp` / `Mod + Shift + WheelUp` | Move window up |

---

## 3. Window & Column Management

### Basic Window Control

| Key | Action |
| :--- | :--- |
| `Mod + Shift + C` | Close focused window |
| `Mod + Mouse Middle` | Close window |
| `Mod + Z` | Maximize current column |
| `Mod + V` | Cycle preset column widths forward (`0.35 -> 0.50 -> 0.65`) |
| `Mod + Shift + V` | Cycle preset column widths backward |

### Tabbed Mode & Stacking

| Key | Action |
| :--- | :--- |
| `Mod + S` | Toggle column tabbed display (Tabs vs Vertical tile) |
| `Mod + Shift + H` / `Mod + Shift + ←` | Consume / expel window to/from left |
| `Mod + Shift + L` / `Mod + Shift + →` | Consume / expel window to/from right |
| `Mod + Comma` (`,`) | Consume window into column |
| `Mod + Period` (`.`) | Expel window from column |
| `Mod + Ctrl + J` | Move window down within column/tabs |
| `Mod + Ctrl + K` | Move window up within column/tabs |

### Dimension Fine-tuning

| Key | Action |
| :--- | :--- |
| `Mod + [` | Decrease column width (`-15%`) |
| `Mod + ]` | Increase column width (`+15%`) |
| `Mod + -` | Decrease window height (`-15%`) |
| `Mod + =` | Increase window height (`+15%`) |

---

## 4. Applications

| Key | Application | Command |
| :--- | :--- | :--- |
| `Mod + Return` / `Mod + T` | Terminal | `ghostty` |
| `Mod + Space` / `Mod + W` | Web Browser | `firefox` |
| `Mod + Esc` / `Mod + E` | Editor | `neovide` |
| `Mod + Backspace` / `Mod + F` | File Manager | `nemo` |
| `Mod + D` | Document Viewer | `evince` |
| `Mod + X` | App Finder / Launcher | `xfce4-appfinder` |

---

## 5. Multi-monitor

### Focus Monitor

| Key | Action |
| :--- | :--- |
| `Mod + N` / `Mod + Ctrl + N` / `Mod + Ctrl + ←` | Focus monitor left |
| `Mod + I` / `Mod + Ctrl + I` / `Mod + Ctrl + ↑` | Focus monitor up |
| `Mod + O` / `Mod + Ctrl + O` / `Mod + Ctrl + ↓` | Focus monitor down |
| `Mod + U` / `Mod + Ctrl + U` / `Mod + Ctrl + →` | Focus monitor right |

### Move Column to Monitor

| Key | Action |
| :--- | :--- |
| `Mod + Shift + N` / `Mod + Shift + Ctrl + N` / `Mod + Shift + Ctrl + ←` | Move column to monitor left |
| `Mod + Shift + I` / `Mod + Shift + Ctrl + I` / `Mod + Shift + Ctrl + ↑` | Move column to monitor up |
| `Mod + Shift + O` / `Mod + Shift + Ctrl + O` / `Mod + Shift + Ctrl + ↓` | Move column to monitor down |
| `Mod + Shift + U` / `Mod + Shift + Ctrl + U` / `Mod + Shift + Ctrl + →` | Move column to monitor right |

---

## 6. System & Hardware

| Key | Action | Command / Target |
| :--- | :--- | :--- |
| `Print` | Interactive Screenshot | `screenshot` |
| `Ctrl + Print` | Screenshot current screen | `screenshot-screen` |
| `Alt + Print` | Screenshot current window | `screenshot-window` |
| `XF86AudioRaiseVolume` | Volume +3% | `pactl set-sink-volume @DEFAULT_SINK@ +3%` |
| `XF86AudioLowerVolume` | Volume -3% | `pactl set-sink-volume @DEFAULT_SINK@ -3%` |
| `XF86AudioMute` | Toggle audio mute | `pactl set-sink-mute @DEFAULT_SINK@ toggle` |
| `XF86AudioMicMute` | Toggle mic mute | `pactl set-source-mute @DEFAULT_SOURCE@ toggle` |
| `XF86MonBrightnessUp` | Brightness +3% | `brightnessctl set 3%+` |
| `XF86MonBrightnessDown` | Brightness -3% | `brightnessctl set 3%-` |
| `Mod + P` | Hotkey overlay | `show-hotkey-overlay` |
| `Mod + Ctrl + B` | Lock screen & power off displays | `gtklock` + `power-off-monitors` |
| `Mod + Ctrl + Shift + B` | Suspend system | `systemctl suspend` |
| `Mod + Ctrl + R` | Reload config (with transition) | `reload-config` |
| `Mod + Ctrl + Q` | Quit Niri session | `quit` |

---

## Scratch Workspace Note

Workspace **9** serves as the scratch workspace:

- `Mod + G`: Jump directly to scratch workspace.
- `Mod + Shift + G`: Send current focused column to scratch workspace.

