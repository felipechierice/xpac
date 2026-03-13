# xpac - Cross-Distro Package Manager

**Version: 0.2.0**

`xpac` is a unified package management wrapper that provides consistent commands across different Linux distributions and environments like FreeBSD or Termux. Manage packages and check system status with the same intuitive commands, regardless of the underlying OS.

## Quick Start

```bash
git clone https://github.com/byomess/xpac.git
cd xpac && ./install.sh

xpac install vim git       # Install packages
xpac search firefox        # Search for packages
xpac update-upgrade        # Update & upgrade everything
xpac sysinfo               # Show system information
xpac top -s mem -n 5       # Top 5 processes by memory
xpac                       # No args = update-upgrade
```

## Features

- **Unified Commands** — Same interface for `apt`, `dnf`, `pacman`, `yum`, `zypper`, `pkg`, and `yay`.
- **Cross-System** — Works across Debian, Fedora, Arch, openSUSE, FreeBSD, Termux, and more.
- **System Utilities** — Built-in commands for disk, memory, CPU, network, top processes, and more.
- **Auto Dependency Handling** — Detects missing tools and offers to install them automatically.
- **Internal Packages** — Bundled setup/teardown scripts for tools not in standard repos (Oh My Zsh, xcb, etc.).

## Supported Package Managers

| Package Manager | Distributions |
|-----------------|---------------|
| **APT** | Debian, Ubuntu, Linux Mint, Pop!_OS, etc. |
| **DNF** | Fedora, RHEL 8+, CentOS Stream 8+, etc. |
| **Pacman** | Arch Linux, Manjaro, EndeavourOS, etc. |
| **Yay** | Arch Linux AUR helper (used over Pacman if installed) |
| **YUM** | RHEL 7, CentOS 7, older Fedora |
| **Zypper** | openSUSE, SUSE Linux Enterprise |
| **Pkg** | FreeBSD, GhostBSD, Termux (Android) |

## Installation

```bash
git clone https://github.com/byomess/xpac.git
cd xpac
./install.sh
```

- **Without `sudo`**: installs to `~/.local/bin` and `~/.local/share` (user-space). The script adds `~/.local/bin` to your `PATH` if needed.
- **With `sudo`**: installs to `/usr/local/bin` and `/usr/local/share` (system-wide).

## Usage

### Package Management

| Command | Aliases | Description |
|---------|---------|-------------|
| `xpac install <pkg...>` | `i`, `add` | Install package(s) |
| `xpac remove <pkg...>` | `rm`, `del` | Remove package(s) |
| `xpac purge <pkg...>` | `pu`, `p` | Remove package(s) and config files |
| `xpac search <query>` | `s`, `find`, `f` | Search available packages |
| `xpac search-installed <query>` | `si` | Search installed packages |
| `xpac update` | `ud` | Update package list |
| `xpac upgrade` | `ug` | Upgrade all packages |
| `xpac update-upgrade` | `uu` | Update list + upgrade all (default action) |
| `xpac list` | `ls`, `l` | List all available packages |
| `xpac list-installed` | `li` | List installed packages |
| `xpac list-files <pkg>` | `lf` | List files owned by a package |
| `xpac list-commands <pkg>` | `lc` | List binaries provided by a package |
| `xpac show <pkg>` | `sh`, `info`, `inf` | Show package details |
| `xpac clean-cache` | `cc` | Clean package manager cache |
| `xpac autoremove` | `ar` | Remove unused dependencies |

### System Utilities

| Command | Aliases | Description |
|---------|---------|-------------|
| `xpac sysinfo` | | Distro, kernel, architecture, hostname, uptime |
| `xpac disk` | `df` | Disk usage for mounted filesystems |
| `xpac memory` | `mem` | RAM and swap usage |
| `xpac cpuinfo` | `cpu` | CPU model, core count, load average |
| `xpac ip` | `net` | IP addresses for active interfaces |
| `xpac ping` | | Network connectivity test (pings 8.8.8.8) |
| `xpac top [opts]` | | Top processes (see options below) |
| `xpac governors` | `gov` | CPU frequency scaling governors |
| `xpac update-mirrors` | `mirrors` | Update pacman mirrorlist via reflector (Arch only) |

#### `top` Options

| Option | Description |
|--------|-------------|
| `-s <key>` | Sort by: `cpu` (default), `mem`, `pid`, `user`, `start_time`, `time` |
| `-n <num>` | Number of processes to show (default: 10) |
| `-f <pattern>` | Filter by command name (case-insensitive) |

```bash
xpac top                     # Top 10 by CPU
xpac top -s mem -n 5         # Top 5 by memory
xpac top -f firefox          # Filter by 'firefox'
xpac top -s pid -f sshd      # Sort by PID, filter by 'sshd'
```

### Other

| Command | Aliases |
|---------|---------|
| `xpac --help` | `-h`, `help`, `h` |
| `xpac --version` | `-v`, `version`, `v` |

## Internal Packages

`xpac` supports "internal packages" — bundled setup/teardown scripts for tools not available through standard package managers. When installing or removing, `xpac` automatically dispatches to the internal script if one exists.

| Package | Description |
|---------|-------------|
| `omz` | [Oh My Zsh](https://ohmyz.sh/) — Zsh configuration framework |
| `xcb` | [xcb](https://github.com/byomess/xcb) — clipboard utility wrapper |
| `lazymux` | [Lazymux](https://github.com/Gameye98/Lazymux) — Termux tool installer |

```bash
xpac install omz       # Installs Oh My Zsh via its setup script
xpac remove omz        # Uninstalls Oh My Zsh via its teardown script
xpac install vim omz   # Mix: vim via package manager, omz via internal script
```

## Uninstallation

```bash
cd xpac
./uninstall.sh          # user-space install
sudo ./uninstall.sh     # system-wide install
```

Removes the `xpac` binary, data directory, and any PATH modifications made during installation.

## Contributing

Contributions are welcome! Fork the repo, make changes, and submit a pull request.

If you find a bug or have a suggestion, open an issue on [GitHub Issues](https://github.com/byomess/xpac/issues).

## License

[MIT License](LICENSE)
