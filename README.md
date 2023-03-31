# xcode-arch

A utility to switch running architecture of Xcode on M1 mac.

> **Warning**
>
> Xcode is no longer supported under Rosetta since 14.3 and this tool will come to EOL.
>
> Also, this tool will do nothing with Xcode 14.3.
>
> See: https://developer.apple.com/documentation/xcode-release-notes/xcode-14_3-release-notes#Deprecations

## Motivation
Currently, there is no way to toggle `Open using Rosetta` option other than in Finder.

| off | on |
| --- | --- |
| ![Rosetta off](https://user-images.githubusercontent.com/4150060/169258686-fad51e79-1813-4d11-85e9-138863c2a536.png) | ![Rosetta on](https://user-images.githubusercontent.com/4150060/169259715-06c70b38-42bd-4f3b-9d22-048393789055.png) |

This provides a command-line tool to set on/off or toggle `Open using Rosetta` option.

## Installation
### Homebrew(recommended)
```sh
brew install 417-72KI/tap/xcode-arch
```

### Mint
```sh
mint install 417-72KI/xcode-arch@0.1.0
```

## Usage

```sh
$ xcode-arch -p
arm64 # `Open using Rosetta` is off
$ xcode-arch -c
Set x86_64 for /Applications/Xcode.app
$ xcode-arch -p
x86_64 # `Open using Rosetta` is on
$ xcode-arch -u
Set arm64 for /Applications/Xcode.app
$ xcode-arch -p
arm64 # `Open using Rosetta` is off
```

You can switch / print with specific Xcode path by using `DEVELOPER_DIR`.

```sh
$ DEVELOPER_DIR=/Applications/Xcode-13.2.1.app xcode-arch -c
`/Applications/Xcode-13.2.1.app` is running with x86_64
```

## Requirements
- macOS 12.0+
- Xcode 13.3+ (Swift 5.6+)
