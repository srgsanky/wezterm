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

