# Keep Awake for Omarchy

Keep Awake is an Omarchy Quattro bar widget that temporarily prevents the
machine from suspending when the laptop lid is closed. The display turns off
when the lid closes and wakes again when it opens.

The default timer is two hours. When the timer ends, normal lid behavior is
restored. By default, the machine suspends if the lid is still closed, which
helps avoid draining the battery overnight.

## Install

```bash
omarchy plugin add https://github.com/zendarc147/omarchy-keep-awake.git --enable --yes
```

If another local plugin already uses the `zen.nightmode` ID, remove or back it
up outside `~/.config/omarchy/plugins/` before installing this repository.

## Usage

The `󰤄` icon is dim while Keep Awake is off. While active, it lights up and
shows the remaining time.

| Gesture | Action |
| --- | --- |
| Left click | Toggle the default two-hour timer |
| Right click | Add 30 minutes, or start a 30-minute timer when inactive |
| Middle click | Turn Keep Awake off |
| Mouse wheel | Add or remove the configured adjustment step |

Hover the icon to see the current state, remaining time, lid state, and the
left- and right-click shortcuts.

## Settings

The widget exposes these settings through Omarchy:

- `duration`: timer started by left click; default `2h`
- `stepMinutes`: right-click and mouse-wheel adjustment; default `30`
- `showRemaining`: show the countdown next to the icon; default `true`
- `suspendAtEnd`: suspend when time expires and the lid is closed; default `true`

## Command line

The widget calls `bin/nightmode`, which can also be run directly:

```text
nightmode                     Start the default two-hour timer
nightmode 90                  Start a 90-minute timer
nightmode 45m | 3h | 1h30    Start a custom timer
nightmode toggle [duration]   Start when inactive, otherwise stop
nightmode extend +30m         Extend the timer
nightmode extend -15m         Shorten the timer
nightmode off                 Stop immediately
nightmode status              Print the current state
nightmode state               Print JSON state for the widget
nightmode --no-suspend 2h     Do not suspend when the timer ends
```

## Requirements and behavior

- Omarchy Quattro with `omarchy-shell`
- Hyprland and its `hyprctl` command
- systemd/logind with `systemd-inhibit` and `systemctl`
- A Linux laptop exposing lid state through `/proc/acpi/button/lid/`
- `notify-send`, `awk`, `date`, `realpath`, `setsid`, and standard shell tools

The plugin makes no network requests, downloads nothing, installs no packages,
and needs no `sudo` or `pkexec` access. It holds a logind
`handle-lid-switch` inhibitor only while its timer is active. It does not
change system configuration files or permanently alter the system's lid policy.

Keep Awake controls lid-triggered suspension. Other idle, lock-screen, or
power-management policies configured on the machine still apply.

## Remove

```bash
omarchy plugin remove zen.nightmode --yes
```

Removal deletes the installed plugin checkout. If a timer is active, turn it
off before removal so the lid inhibitor is released cleanly:

```bash
~/.config/omarchy/plugins/zen.nightmode/bin/nightmode off
```

## License

[MIT](LICENSE)
