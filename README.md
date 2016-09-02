![DiMaGo-platform-macos](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![DiMaGo-code-shell](https://img.shields.io/badge/code-shell-yellow.svg)
[![DiMaGo-depend-coreutils](https://img.shields.io/badge/dependency-coreutils%208.25-green.svg)](https://www.gnu.org/software/coreutils)
[![DiMaGo-depend-tnote](https://img.shields.io/badge/dependency-terminal--notifier%201.6.3-green.svg)](https://github.com/alloy/terminal-notifier)
[![DiMaGo-license](http://img.shields.io/badge/license-MIT+-blue.svg)](https://github.com/JayBrown/DiMaGo/blob/master/license.md)

# DiMaGo <img src="https://github.com/JayBrown/DiMaGo/blob/master/img/jb-img.png" height="20px"/>
**macOS workflows and shell scripts to create disk images (DMGs and sparsebundles) with special focus on InfoSec, namely using S/MIME encryption**

If you encrypt a DMG or sparsebundle with a public S/MIME key, only a user in possession of the private key will be able to access the image contents. This is great against wordlist attacks, or for hiding content e.g. in the cloud without the use of other tools like **Boxcryptor** or **Cryptomator**. You can also use multiple S/MIME keys, if more than one person needs to have access to the image contents.

In essence, **DiMaGo** is the rebirth of the [**PGPdisk** of olde](https://en.wikipedia.org/wiki/PGPDisk), only with S/MIME instead of PGP/GPG encryption.

## Current status
Beta: it works (apparently), but it will remain in beta status until the DiMaGo verification script/workflow has been created

## Prerequisites
Install using [Homebrew](http://brew.sh) with `brew install <software-name>` (or with a similar manager)

* [coreutils](https://www.gnu.org/software/coreutils) [Note: DiMaGo uses **GNU split** to segment DMGs]
* [terminal-notifier](https://github.com/alloy/terminal-notifier) [optional]

You need to have Spotlight enabled for `mdfind` to locate the terminal-notifier.app on your volume; if you don't install terminal-notifier, or if you have deactivated Spotlight, the DiMaGo scripts will call notifications via AppleScript instead

Because DiMaGo uses the macOS Notification Center, the minimum Mac OS requirement is **OS X 10.8 (Mountain Lion)**.

## Installation & Usage
* [Download the latest DMG](https://github.com/JayBrown/DiMaGo/releases) and open

### Workflows
* Double-click on the workflow file to install
* If you encounter problems, open it with Automator and save/install from there
* Standard Finder integration in the Services menu

### Shell script [optional]
* Move the script to `/usr/local/bin`
* In your shell enter `chmod +x /usr/local/bin/dimago-create.sh`
* Run the script with `dimago-create.sh /path/to/target`

Only necessary if for some reason you want to run this from the shell or another shell script.

## Functionality
* creates read-only DMGs or read/write sparsebundles from a source folder
* encrypts with AES-256 or AES-128
* encrypts using a password
* encrypts using public S/MIME keys available in the user's keychains
* encrypts using both password and public S/MIME keys (**less secure**)
* encrypts using multiple public S/MIME keys for collaboration scenarios
* ignores expired S/MIME certificates
* ignores S/MIME-compatible CA certificates (end entities only)
* generates strong random passwords using `openssl` in addition to manual password input
* codesigns the images after creation
* codesigns existing unsigned images
* re-codesigns existing codesigned images
* generates a SHA-2 256-bit checksum
* automatically splits DMGs larger than 200 MB, if the user has installed `gsplit` while keeping the original image file
* creates its own DiMaGo keychain in the userspace, accessible via macOS **Keychain Access**
* stores UUIDs, passwords, SHA-256 checksums, S/MIME information (email addresses & SKIDs) in discrete DiMaGo keychain entries

## Planned Functionality
* preferences for image creation: volume icon, background image etc. (DMGs only)
* **second workflow/script to verify and trust certificates used to codesign**
* write valid public S/MIME keys to preferences, with option to rescan

## General Notes
* **DiMaGo** only uses native macOS command line programs. Further options are available with `gsplit` (segment large DMGs) and `terminal-notifier` (extended notifications).
* To codesign a DMG or sparsebundle, you need a Code Signing Certificate (CSC), which you can get as an Apple Developer or issue yourself using **Keychain Access** or third-party applications like **[xca](https://sourceforge.net/projects/xca/)**
* Cross-platform compatibility hasn't been tested. Encrypted macOS images can be opened/mounted on Windows (using e.g. **7-zip**) and on Linux systems, but whether this also works with S/MIME-encrypted images remains to be seen.
