# srgsanky's wezterm configuration

<https://wezfurlong.org/wezterm/index.html>

## Installation

### Mac

```bash
# https://formulae.brew.sh/cask/wezterm
brew install --cask wezterm

# Install nerd font
brew install font-meslo-lg-nerd-font
```

## Clone the configuration

```bash
mkdir -p ~/.config/
git clone https://github.com/srgsanky/wezterm ~/.config/wezterm
```

## Set title alias

Add the following alias to your `~/.bashrc` or `~/.zshrc` to be able to set the title of the tab.

```bash
# For Mac
alias set-tab-title="wezterm cli set-tab-title"

# For Ubuntu or any other Linux where flatpak is used
alias set-tab-title="flatpak run org.wezfurlong.wezterm cli set-tab-title"
```

## Pane management

| Pane creation                                    | Keybinding sequence 1         | Keybinding sequence 2 |
| ------------------------------------------------ | ----------------------------- | --------------------- |
| Create vertical split pane                       | `CTRL + a`                    | `%`                   |
|                                                  | `CTRL + a`                    | `v`                   |
| Create horizontal split pane                     | `CTRL + a`                    | `"`                   |
|                                                  | `CTRL + a`                    | `s`                   |
|                                                  |                               |                       |
| **Navigation**                                   |                               |                       |
| Move across panes                                | `CTRL + SHIFT + <arrow keys>` |                       |
| Show character hints (a,s,d,f etc) to focus pane | `CTRL + a`                    | `CTRL + 8`            |
| Show number hints (1, 2, 3, etc) to focus pane   | `CTRL + a`                    | `CTRL + 9`            |
|                                                  |                               |                       |
| **Resize**                                       |                               |                       |
| Modify width                                     | `CTRL + a`                    | `h/l`                 |
| Modify height                                    | `CTRL + a`                    | `j/k`                 |
| Zoom the pane                                    | `CTRL + a`                    | `z`                   |

