# homebrew-infimount

Homebrew tap for [Infimount](https://github.com/infimount/infimount).

## Install

### Linux (Formula)

```bash
brew tap infimount/infimount
brew install infimount
```

### macOS (Cask)

```bash
brew tap infimount/infimount
brew install --cask infimount
```

## Upgrade

### Linux (Formula)

```bash
brew update
brew upgrade infimount
```

### macOS (Cask)

```bash
brew update
brew upgrade --cask infimount
```

## Uninstall

### Linux (Formula)

```bash
brew uninstall infimount
```

### macOS (Cask)

```bash
brew uninstall --cask infimount
```

## Notes

- Linux install uses `Formula/infimount.rb`.
- macOS install uses `Casks/infimount.rb`.
- Formula/cask versions should be updated from GitHub releases.
- Security: pin `sha256` from release checksums before publishing updates.
