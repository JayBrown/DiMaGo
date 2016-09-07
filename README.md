![DiMaGo-platform-macos](https://img.shields.io/badge/platform-macOS-lightgrey.svg)
![DiMaGo-code-shell](https://img.shields.io/badge/code-shell-yellow.svg)
[![DiMaGo-depend-tnote](https://img.shields.io/badge/dependency-terminal--notifier%201.6.3-green.svg)](https://github.com/alloy/terminal-notifier)
[![DiMaGo-license](http://img.shields.io/badge/license-MIT+-blue.svg)](https://github.com/JayBrown/DiMaGo/blob/master/license.md)

# DiMaGo <img src="https://github.com/JayBrown/DiMaGo/blob/master/img/jb-img.png" height="20px"/>
**macOS workflows and shell scripts to create disk images (DMGs and sparsebundles) with special focus on InfoSec, namely using S/MIME encryption**

In essence, **DiMaGo** facilitates the rebirth of the [**PGPdisk** of olde](https://en.wikipedia.org/wiki/PGPDisk) for macOS, only with S/MIME instead of PGP/GPG encryption.

If you encrypt a DMG or sparsebundle with a public S/MIME key, only a user in possession of the corresponding private key will be able to access the disk image contents. In most cases this is a better solution than password-based encryption, which is prone to dictionary attacks (**Spartan** et al.). It's also great for hiding content e.g. in the cloud, without the need for specialized cloud encryption tools like [**Cryptomator**](https://github.com/cryptomator/cryptomator), which only works locally, or [**Boxcryptor**](https://www.boxcryptor.com), which is not free for group access to encrypted content. With DiMaGo you can also use multiple S/MIME keys, if more than one person needs to have access to the disk image contents—perfect for team work. And if (nation state) hackers get a hold of your cloud password, at least your data will still be safe.

As with S/MIME-encrypted email messages, after an S/MIME certificate used to encrypt a disk image has expired, you will still be able to mount the encrypted volume, as long as you do not delete the expired certificate from your keychain.

S/MIME protection of disk images will not help you if you're compelled to reveal the contents of your computer. In these cases, once you've provided authorities with the macOS login password, your keychains are unlocked (at least with macOS default settings), and so are your encrypted volumes, once an agent clicks on them, either because the public S/MIME encryption key is still in your login keychain, or because you have chosen to store the disk image passphrase in your DiMaGo keychain. You can easily evade this problem if you create a disk image encrypted with both S/MIME and a password, but on a *different* Mac. On this master Macintosh you can store the S/MIME certificate chain and (optionally) the passphrase in your DiMaGo keychain. Then all you need to do is copy the disk image sans certificate to your main Mac (slave Macintosh), where you are only to use the passphrase to mount the encrypted volume. Just be sure that you do not store the disk image password in the keychain of your slave Macintosh, because that would defeat the purpose.

Such a master–slave setup is also great for corporate settings, e.g. if a system administrator wants to provide employees with an encrypted read-write sparsebundle; in most cases the passphrase is only known to the employee, which he has to type in himself, but the admin will still have a recovery option using the admin S/MIME key on his own computer. In an alternate approach for a corporate setting the admin can also create an S/MIME certificate chain for the employee, and keep a copy for himself.

## Current status
Beta: it works (apparently), but it will remain in beta status until the DiMaGo verification script/workflow has been created

## Prerequisites for full functionality [optional]
* [terminal-notifier](https://github.com/alloy/terminal-notifier)

Install using [Homebrew](http://brew.sh) with `brew install terminal-notifier` (or with a similar manager)

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
* creates two types of disk images, read-only DMGs or read/write growable sparsebundles, from a source folder
* asks user for disk image's volume name and basename
* asks user for sparsebundle's virtual volume size (default: 5 GB; min.: 1 GB; max.: approx. 8 EB)
* creates unencrypted or encrypted disk images
* encrypts with AES-128 (**less secure**) or AES-256 (**more secure**)
* encrypts using a passphrase (**less secure**)
* encrypts using public S/MIME key(s) available in the user's keychains (**more secure**)
* encrypts using both passphrase and public S/MIME keys (**less secure**, but preferable for specific scenarios)
* encrypts using multiple public S/MIME keys, e.g. for collaboration scenarios (team sparsebundles in the cloud etc.)
* ignores expired S/MIME certificates
* ignores S/MIME-compatible CA certificates (end entities only)
* creates 4096-bit self-signed root S/MIME identity (**DiMaGo Base Identity**) on first run using a random virtual email address
* generates strong random passphrases in addition to manual passphrase (dual) input
* asks whether the user also wants to store the encryption passphrase in the disk image's keychain entry
* codesigns the disk images after creation, including sparsebundles (CSC required)
* codesigns existing unsigned disk images (CSC required)
* re-codesigns existing codesigned disk images (CSC required)
* generates a SHA-2 256-bit checksum (DMGs only)
* writes DMG checksum to a CMS file which is signed with the local DiMaGo Base Identity
* creates a shell command file to auto-verify a DMG's checksum using the information stored in the CMS file
* automatically splits DMGs larger than 200 MB while retaining the original disk image file (CSCs are removed when using the `split` command)
* writes checksums of all DMG segments to a CMS file which is signed with the local DiMaGo Base Identity
* creates a shell command file to automatically (a) verify the segment checksums using the information stored in the CMS file, and (b) concat the segments
* creates its own DiMaGo keychain in the userspace, accessible via macOS **Keychain Access**
* stores UUIDs, SHA-256 checksums, S/MIME information (email addresses & SKIDs), and (optionally) passwords in discrete DiMaGo keychain entries

## Planned Functionality (this might take a while)
* write email addresses and SKIDs of existing valid public S/MIME keys to preferences, with option to rescan
* preferences for disk image creation: volume icon, background image etc. (DMGs only)
* **second workflow/script to verify and trust certificates used to codesign**
* research `hdiutil` options `-cacert`, and `-certificate` plus `-recover`
* **third workflow/script to convert existing disk images**

## General Notes
* You can get trusted S/MIME certificates for free at [Comodo](https://www.comodo.com/home/email-security/free-email-certificate.php) (valid for one year) or using the [Volksverschlüsselung](https://volksverschluesselung.de) (valid for at least two years), but you can also self-issue an S/MIME certificate, either with macOS **Keychain Access**, with third-party CAs like **[xca](https://sourceforge.net/projects/xca/)**, or using the command line with `openssl`.
* When self-issuing/signing S/MIME certificates, make sure that the leaf certificate contains a **Subject Key Identifier** (SKID); otherwise it will not be compatible with `hdiutil` and **DiMaGo**.
* Self-signed or self-issued certificates will not be deemed "trusted" by the powers that be (incl. macOS), but the major advantage is that (as with PGP/GPG) you can simply ignore the powers that be. There is no third party involved: only the sender and the recipient(s) need to trust each other, and trust each other's certificates, and they only need to do it once. So self-signed certificates are (like PGP/GPG) *always* the better option. (They don't even need to include a valid email address, unless you actually want to use them for email message signing and protection as well.)
* If you have received an email signed with a public S/MIME key, it is stored as valid in your keychain automatically (trusted certificates) or after you manually set the trust in your Mail client (self-issued/signed certificates), and then you can encrypt a disk image using that public key.
* To codesign a DMG or sparsebundle, you need a Code Signing Certificate (CSC), which you can get as an Apple Developer or issue yourself using **Keychain Access** or third-party CAs like the above-mentioned **xca**.
* **DiMaGo** only uses native macOS command line programs; a further option is available with `terminal-notifier` (extended notifications).
* Cross-platform compatibility has only been tested on Windows. **7-zip** can only open unencrypted DMGs. **HFSExplorer** can open encrypted DMGs and sparsebundles, but is currently not compatible with S/MIME-encrypted disk images. Mounting including write access for sparsebundles is not possible. Linux and BSD compatibility has not been tested.

## Bugs
* When using more than 1 (one) public S/MIME key (SKID), `hdiutil` produces an error message: `__NSArrayM object 0x############# overreleased while already deallocating; break on objc_overrelease_during_dealloc_error to debug`; however, the disk image is still created
* When using more than 9 (nine) SKIDs to encrypt a disk image (password or no password), `hdiutil` crashes with multiple instances of the above stderr; then the disk image is *not* created

This is sadly *not* a **DiMaGo** bug, which I would be able to fix, but apparently due to bad Objective-C coding on **Apple**'s part.

## Acknowledgments
* The idea for this worklflow/script came from reading [**Erik Antonsson**'s Caltech article](http://design.caltech.edu/erik/Misc/encrypted_virtual_disk.html) on public key encryption of sparseimages
* Thank you to the hackers who brought us the [Dropbox mega breach](http://thehackernews.com/2016/08/dropbox-data-breach.html) which started me thinking in the first place
