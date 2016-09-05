![DiMaGo-platform-macos](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![DiMaGo-code-shell](https://img.shields.io/badge/code-shell-yellow.svg)
[![DiMaGo-depend-coreutils](https://img.shields.io/badge/dependency-coreutils%208.25-green.svg)](https://www.gnu.org/software/coreutils)
[![DiMaGo-depend-tnote](https://img.shields.io/badge/dependency-terminal--notifier%201.6.3-green.svg)](https://github.com/alloy/terminal-notifier)
[![DiMaGo-license](http://img.shields.io/badge/license-MIT+-blue.svg)](https://github.com/JayBrown/DiMaGo/blob/master/license.md)

# DiMaGo <img src="https://github.com/JayBrown/DiMaGo/blob/master/img/jb-img.png" height="20px"/>
**macOS workflows and shell scripts to create disk images (DMGs and sparsebundles) with special focus on InfoSec, namely using S/MIME encryption**

In essence, **DiMaGo** facilitates the rebirth of the [**PGPdisk** of olde](https://en.wikipedia.org/wiki/PGPDisk), only with S/MIME instead of PGP/GPG encryption.

If you encrypt a DMG or sparsebundle with a public S/MIME key, only a user in possession of the private key will be able to access the image contents. This is great against wordlist attacks, or for hiding content e.g. in the cloud without the use of other tools like **Boxcryptor** or **Cryptomator**. You can also use multiple S/MIME keys, if more than one person needs to have access to the image contents.

As with S/MIME-encrypted email messages, if an S/MIME certificate used to encrypt a disk image expires, you will still be able to open the encrypted volume, as long as you do not delete the expired certificate from your keychain.

S/MIME protection of images will not help you if you're compelled to reveal the contents of your computer. In these cases, once you've provided authorities with the macOS login password, your keychains are unlocked (at least with default settings), and so are your encrypted volumes, once an agent clicks on them, whether you have activated password or S/MIME encryption. (DiMaGo also stores disk image passwords in your keychain for auto-open.) You can easily evade this problem if you create a disk image encrypted with both S/MIME and a password, but on a *different* Mac. The keychain on this master Macintosh will then contain the S/MIME certificate chain and the passphrase. Then all you need to do is copy the disk image (e.g. a sparsebundle) to your main Mac (slave Macintosh), where you will only use the passphrase to mount the encrypted volume. Just be sure that you do not store the disk image password in the keychain of your slave Macintosh, because that would defeat the purpose.

Such a master-slave setup is also great for corporate settings, if e.g. a system administrator wants to provide employees with an encrypted read-write sparsebundle; in most cases the passphrase is only known to the employee, which he has to type in himself, but the admin will still have a recovery option using the admin S/MIME key on his own computer.

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
* creates two types of disk images, read-only DMGs or read/write sparsebundles, from a source folder
* asks user for disk image's volume name and basename
* asks user for sparsebundle's virtual volume size (default: 5 GB; minimum: 1 GB)
* creates unencrypted or encrypted disk images
* encrypts with AES-256 (**more secure**) or AES-128 (**less secure**)
* encrypts using a passphrase (**less secure**)
* encrypts using public S/MIME key(s) available in the user's keychains (**more secure**)
* encrypts using both passphrase and public S/MIME keys (**less secure**)
* encrypts using multiple public S/MIME keys for collaboration scenarios, e.g. with sparsebundles in the cloud
* ignores expired S/MIME certificates
* ignores S/MIME-compatible CA certificates (end entities only)
* generates strong random passphrases using `openssl` in addition to manual passphrase input
* codesigns the disk images after creation, including sparsebundles (CSC required)
* codesigns existing unsigned disk images (CSC required)
* re-codesigns existing codesigned disk images (CSC required)
* generates a SHA-2 256-bit checksum (DMGs only)
* automatically splits DMGs larger than 200 MB while retaining the original disk image file (`gsplit` required)
* creates its own DiMaGo keychain in the userspace, accessible via macOS **Keychain Access**
* stores UUIDs, passwords, SHA-256 checksums, S/MIME information (email addresses & SKIDs) in discrete DiMaGo keychain entries

## Planned Functionality (this might take a while)
* write email addresses and SKIDs of existing valid public S/MIME keys to preferences, with option to rescan
* if there are no S/MIME identities in the user's keychains, use `openssl` to create an S/MIME certificate, and store it in the login.keychain for local encryption operations
* preferences for image creation: volume icon, background image etc. (DMGs only)
* **second workflow/script to verify and trust certificates used to codesign**
* research `hdiutil` options `-cacert`, and `-certificate` plus `-recover`
* **third workflow/script to convert existing disk images**

## General Notes
* You can get trusted one-year S/MIME certificates for free at [Comodo](https://www.comodo.com/home/email-security/free-email-certificate.php) or using the [Volksverschlüsselung](https://volksverschluesselung.de), but you can also self-issue an S/MIME certificate, either with macOS **Keychain Access** or third-party CAs like **[xca](https://sourceforge.net/projects/xca/)**.
* When self-issuing/signing S/MIME certificates, make sure that the leaf certificate contains a **Subject Key Identifier** (SKID); otherwise it will not be compatible with `hdiutil` and **DiMaGo**.
* Self-signed or self-issued certificates will not be deemed "trusted" by the powers that be (incl. macOS), but the major advantage is that (as with PGP/GPG) you can simply ignore the powers that be. There is no third party involved: only the sender and the recipient(s) need to trust each other, and trust each other's certificates, and they only need to do it once. So self-signed certificates are (like PGP/GPG) *always* the better option. (They don't even need to include a valid email address, unless you actually want to use them for email message signing and protection as well.)
* If you have received an email signed with a public S/MIME key, it is stored in your keychain automatically (trusted certificates) or after you manually set the trust (self-issued/signed certificates), and then you can encrypt a disk image using that public key.
* To codesign a DMG or sparsebundle, you need a Code Signing Certificate (CSC), which you can get as an Apple Developer or issue yourself using **Keychain Access** or third-party CAs like the above-mentioned **xca**.
* **DiMaGo** only uses native macOS command line programs. Further options are available with `gsplit` (segment large DMGs) and `terminal-notifier` (extended notifications).
* Cross-platform compatibility hasn't been tested. Encrypted macOS images can be opened/mounted on Windows (using e.g. **7-zip**) and on Linux systems, but whether this also works with S/MIME-encrypted images remains to be seen.
