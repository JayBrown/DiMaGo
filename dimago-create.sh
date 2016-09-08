#!/bin/bash

# DiMaGo v1.4.1 (beta)
# DiMaGo ➤ Create (shell script version)
#
# Note: DiMaGo will remain in beta status until DiMaGo ➤ Verify has been scripted

LANG=en_US.UTF-8
export PATH=/usr/local/bin:$PATH
ACCOUNT=$(/usr/bin/id -un)
CURRENT_VERSION="1.41"

# check compatibility
MACOS2NO=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $2}')
if [[ "$MACOS2NO" -le 7 ]] ; then
	echo "Error! DiMaGo needs at least OS X 10.8 (Mountain Lion)"
	echo "Exiting..."
	INFO=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set userChoice to button returned of (display alert "Error! Minimum OS requirement:" & return & "OS X 10.8 (Mountain Lion)" ¬
		as critical ¬
		buttons {"Quit"} ¬
		default button 1 ¬
		giving up after 60)
end tell
EOT)
	exit
fi

# notification function
notify () {
 	if [[ "$NOTESTATUS" == "osa" ]] ; then
		/usr/bin/osascript &>/dev/null << EOT
tell application "System Events"
	display notification "$2" with title "DiMaGo [" & "$ACCOUNT" & "]" subtitle "$1"
end tell
EOT
	elif [[ "$NOTESTATUS" == "tn" ]] ; then
		"$TERMNOTE_LOC/Contents/MacOS/terminal-notifier" \
			-title "DiMaGo [$ACCOUNT]" \
			-subtitle "$1" \
			-message "$2" \
			-appIcon "$ICON_LOC" \
			>/dev/null
	fi
}

# detect/create directories
CACHE_DIR="${HOME}/Library/Caches/local.lcars.dimago"
if [[ ! -e "$CACHE_DIR" ]] ; then
	mkdir -p "$CACHE_DIR"
fi

# detect/create temp file for storing mail addresses & SKIDs of extant S/MIME public keys
CERTS_TEMP="$CACHE_DIR/certs~temp.txt"
if [[ ! -f "$CERTS_TEMP" ]] ; then
	touch "$CERTS_TEMP"
fi

# preferences
PREFS_DIR="${HOME}/Library/Preferences/"
PREFS="local.lcars.dimago"
PREFS_FILE="$PREFS_DIR/$PREFS.plist"
if [[ ! -f "$PREFS_FILE" ]] ; then
	touch "$PREFS_FILE"
	/usr/bin/defaults write "$PREFS" localIDCreate -bool NO
fi

# detect/create icon for terminal-notifier and osascript windows
ICON_LOC="$CACHE_DIR/lcars.png"
if [[ ! -f "$ICON_LOC" ]] ; then
	ICON64="iVBORw0KGgoAAAANSUhEUgAAAIwAAACMEAYAAAD+UJ19AAACYElEQVR4nOzUsW1T
URxH4fcQSyBGSPWQrDRZIGUq2IAmJWyRMgWRWCCuDAWrGDwAkjsk3F/MBm6OYlnf
19zqSj/9i/N6jKenaRpjunhXV/f30zTPNzePj/N86q9fHx4evi9j/P202/3+WO47
D2++3N4uyzS9/Xp3d319+p3W6+fncfTnqNx3Lpbl3bf/72q1+jHPp99pu91sfr4f
43DY7w+fu33n4tVLDwAul8AAGYEBMgIDZAQGyAgMkBEYICMwQEZggIzAABmBATIC
A2QEBsgIDJARGCAjMEBGYICMwAAZgQEyAgNkBAbICAyQERggIzBARmCAjMAAGYEB
MgIDZAQGyAgMkBEYICMwQEZggIzAABmBATICA2QEBsgIDJARGCAjMEBGYICMwAAZ
gQEyAgNkBAbICAyQERggIzBARmCAjMAAGYEBMgIDZAQGyAgMkBEYICMwQEZggIzA
ABmBATICA2QEBsgIDJARGCAjMEBGYICMwAAZgQEyAgNkBAbICAyQERggIzBARmCA
jMAAGYEBMgIDZAQGyAgMkBEYICMwQEZggIzAABmBATICA2QEBsgIDJARGCAjMEBG
YICMwAAZgQEyAgNkBAbICAyQERggIzBARmCAjMAAGYEBMgIDZAQGyAgMkBEYICMw
QEZggIzAABmBATICA2QEBsgIDJARGCAjMEBGYICMwAAZgQEyAgNkBAbICAyQERgg
IzBARmCAjMAAGYEBMgIDZAQGyAgMkBEYICMwQEZggIzAABmBATICA2QEBsgIDJAR
GCAjMEBGYICMwAAZgQEy/wIAAP//nmUueblZmDIAAAAASUVORK5CYII="
	echo "$ICON64" > "$CACHE_DIR/lcars.base64"
	/usr/bin/base64 -D -i "$CACHE_DIR/lcars.base64" -o "$ICON_LOC" && rm -rf "$CACHE_DIR/lcars.base64"
fi
if [[ -f "$CACHE_DIR/lcars.base64" ]] ; then
	rm -rf "$CACHE_DIR/lcars.base64"
fi

# detect/create big logo (curently unused)
ICON1024="$CACHE_DIR/lcars1024.png"
if [[ ! -f "$ICON1024" ]] ; then
	ICON64_BIG="iVBORw0KGgoAAAANSUhEUgAABAAAAAQACAYAAAB/HSuDAAA9WUlEQVR4nOzYMUpD
YRCF0ddHfK1g5G1AUtjZ5C5GsLJJZZltGLdk9vRM+1cyhY7iuXC2MDDftJ6mFfhZ
x9eX43J3u0y/fNebq/nx/iHn57cV6JX9PvNl3Xfhq20287zbJe+ndQV65bK/cDe2
N9vl8HQ4fpzOK/C9pu5HCP4jAQCoEgCAqkQAAEYCADQQAIAqAQCoSgQAYCQAQAMB
AKgSAICqRAAARgIANBAAgCoBAKhKBABgJABAAwEAqBIAgKpEAABGAgA0EACAKgEA
qEoEAGAkAEADAQCoEgCAqkQAAEYCADQQAIAqAQCoSgQAYCQAQAMBAKgSAICqRAAA
RgIANBAAgCoBAKhKBABgJABAAwEAqBIAgKpEAABGAgA0EACAKgEAqEoEAGAkAEAD
AQCoEgCAqkQAAEafAAAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo
9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnC
TKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s
2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAM
ArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91
fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzE
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA
///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEB
AAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo
9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnC
TKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s
2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAM
ArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91
fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzE
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA
///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEB
AAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo
9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnC
TKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s
2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAM
ArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91
fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzE
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA
///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEB
AAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo
9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnC
TKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s
2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAM
ArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91
fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzE
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA
///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEB
AAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8A
wIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo
9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoC
AGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnC
TKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4
DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACg
JQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s
2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIA
gE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAMArBo9G91fYnCTKzEBAAMCACgJQCA
ViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAM
CACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGgl
AgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAA
AFoCAGglAgD4BAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA///s2CEBAAAM
ArBo9G91fYnCTKzEBAAMCACgJQCAViIAgE8AwIAAAFoCAGglAgD4DgAA//8DAKFQ
WDy2NyUIAAAAAElFTkSuQmCC"
	echo "$ICON64_BIG" > "$CACHE_DIR/interim.base64"
	/usr/bin/base64 -D -i "$CACHE_DIR/interim.base64" -o "$ICON1024" && rm -rf "$CACHE_DIR/interim.base64"
fi

# create ICNS file for volume icon (currently unused)
ICNS_LOC="$CACHE_DIR/lcars.icns"
if [[ ! -f "$ICNS_LOC" ]] ; then
	ICONSET_DIR="$CACHE_DIR/lcars.iconset"
	mkdir -p "$ICONSET_DIR"
	/usr/bin/sips -z 16 16     "$ICON1024" --out "$ICONSET_DIR/icon_16x16.png" &>/dev/null
	/usr/bin/sips -z 32 32     "$ICON1024" --out "$ICONSET_DIR/icon_16x16@2x.png" &>/dev/null
	/usr/bin/sips -z 32 32     "$ICON1024" --out "$ICONSET_DIR/icon_32x32.png" &>/dev/null
	/usr/bin/sips -z 64 64     "$ICON1024" --out "$ICONSET_DIR/icon_32x32@2x.png" &>/dev/null
	/usr/bin/sips -z 128 128   "$ICON1024" --out "$ICONSET_DIR/icon_128x128.png" &>/dev/null
	/usr/bin/sips -z 256 256   "$ICON1024" --out "$ICONSET_DIR/icon_128x128@2x.png" &>/dev/null
	/usr/bin/sips -z 256 256   "$ICON1024" --out "$ICONSET_DIR/icon_256x256.png" &>/dev/null
	/usr/bin/sips -z 512 512   "$ICON1024" --out "$ICONSET_DIR/icon_256x256@2x.png" &>/dev/null
	/usr/bin/sips -z 512 512   "$ICON1024" --out "$ICONSET_DIR/icon_512x512.png" &>/dev/null
	cp "$ICON1024" "$ICONSET_DIR/icon_512x512@2x.png"
	/usr/bin/iconutil -c icns "$ICONSET_DIR"
	rm -rf "$ICONSET_DIR"
fi

# look for terminal-notifier
TERMNOTE_LOC=$(/usr/bin/mdfind "kMDItemCFBundleIdentifier == 'nl.superalloy.oss.terminal-notifier'" 2>/dev/null | /usr/bin/awk 'NR==1')
if [[ "$TERMNOTE_LOC" == "" ]] ; then
	NOTESTATUS="osa"
else
	NOTESTATUS="tn"
fi

# look for DiMaGo keychain & create if necessary
CHAIN_INFO=$(/usr/bin/security show-keychain-info DiMaGo.keychain 2>&1)
if [[ "$CHAIN_INFO" == *"could not be found." ]] ; then
	notify "Creating DiMaGo keychain…" "Please confirm with a password!"
	/usr/bin/security create-keychain -P DiMaGo.keychain && /usr/bin/security list-keychains -d user -s login.keychain DiMaGo.keychain && /usr/bin/security set-keychain-settings -u DiMaGo.keychain
fi

# first run: DiMaGo local S/MIME identity creation
LOCAL_ID=$(/usr/bin/defaults read "$PREFS" localIDCreate 2>/dev/null)
if [[ "$LOCAL_ID" != "1" ]] ; then

	notify "Please wait! Generating…" "DiMaGo local S/MIME identity"

	NK_TEMP="$CACHE_DIR/newkey~temp"
	if [[ ! -e "$NK_TEMP" ]] ; then
		mkdir -p "$NK_TEMP"
	else
		rm -rf "$NK_TEMP/"*
	fi
	touch "$NK_TEMP/dimago.cnf"
	echo -n "" > "$NK_TEMP/dimago.cnf"
	LK_PW=$(/usr/bin/openssl rand -base64 47 | /usr/bin/tr -d /=+ | /usr/bin/cut -c -32)
	/usr/bin/security add-generic-password -U -D "application password" -l "DiMaGo Base Identity pkpw" -s "DiMaGo Base Identity pkpw" -a "$ACCOUNT" -w "$LK_PW" login.keychain
	/usr/bin/openssl genrsa -des3 -passout pass:$LK_PW -out "$NK_TEMP/dimago.key" 4096
	RANDSTR=$(/bin/date +%s | /usr/bin/shasum -a 256 | /usr/bin/base64 | /usr/bin/head -c 16 | /usr/bin/tr '[:upper:]' '[:lower:]' | xargs)
	NC_ADDR="$RANDSTR@dimago.local"
	NC_COMMON="DiMaGo Base Identity [$RANDSTR]"

	LEAF_CONF="[req]
prompt=no
distinguished_name=req_dn
x509_extensions=x509_exts
string_mask=utf8only

[req_dn]
commonName=$NC_COMMON
emailAddress=$NC_ADDR

[x509_exts]
subjectKeyIdentifier=hash
basicConstraints=critical, CA:FALSE
keyUsage=critical, digitalSignature, keyEncipherment
extendedKeyUsage=emailProtection"

	echo "$LEAF_CONF" >> "$NK_TEMP/dimago.cnf"
	/usr/bin/openssl req -x509 -days 7300 -config "$NK_TEMP/dimago.cnf" -new -key "$NK_TEMP/dimago.key" -passin pass:$LK_PW -sha512 -set_serial 47 -out "$NK_TEMP/dimago.pem" -outform PEM
	EXPORT_PW=$(/usr/bin/openssl rand -base64 47 | /usr/bin/tr -d /=+ | /usr/bin/cut -c -32)
	/usr/bin/security add-generic-password -U -D "application password" -l "DiMaGo Base Identity expw" -s "DiMaGo Base Identity expw" -a "$ACCOUNT" -w "$EXPORT_PW" login.keychain
	/usr/bin/openssl pkcs12 -export -passout pass:$EXPORT_PW -out "$NK_TEMP/dimago.p12" -inkey "$NK_TEMP/dimago.key" -passin pass:$LK_PW -in "$NK_TEMP/dimago.pem"
	/usr/bin/security import "$NK_TEMP/dimago.p12" -f pkcs12 -P "$EXPORT_PW" -k login.keychain
	/usr/bin/security add-trusted-cert -r trustRoot -k login.keychain "$NK_TEMP/dimago.pem"

	notify "Created S/MIME certificate" "$NC_ADDR"

	rm -rf "$NK_TEMP"

	/usr/bin/defaults write "$PREFS" localIDCreate -bool YES
	/usr/bin/defaults write "$PREFS" localID "$NC_ADDR"
fi

# check for update
NEWEST_VERSION=$(/usr/bin/curl --silent https://api.github.com/repos/JayBrown/DiMaGo/releases/latest | /usr/bin/awk '/tag_name/ {print $2}' | xargs)
if [[ "$NEWEST_VERSION" == "" ]] ; then
	NEWEST_VERSION="0"
fi
NEWEST_VERSION=${NEWEST_VERSION//,}
if (( $(echo "$NEWEST_VERSION > $CURRENT_VERSION" | /usr/bin/bc -l) )) ; then
	notify "Update available" "DiMaGo v$NEWEST_VERSION"
	/usr/bin/open "https://github.com/JayBrown/DiMaGo/releases/latest"
fi

for FILEPATH in "$1" # ALT: "$@"
do

TARGET_NAME=$(/usr/bin/basename "$FILEPATH")

if [[ "$FILEPATH" == *".dmg" ]] || [[ "$FILEPATH" == *".sparsebundle" ]] || [[ "$FILEPATH" == *".sparseimage" ]] ; then # codesign or re-codesign disk image

	# check for codesigning certificates in the user's keychains
	notify "Please wait! Searching…" "Code signing certificates"
	CERTS=$(/usr/bin/security find-identity -v -p codesigning | /usr/bin/awk '{print substr($0, index($0,$3))}' | /usr/bin/sed -e '$d' -e 's/^"//' -e 's/"$//')
	if [[ "$CERTS" != "" ]] ; then
		CS_ABLE="true"
		CS_COUNT=$(echo "$CERTS" | /usr/bin/wc -l | xargs)
		if [[ ($CS_COUNT>1) ]] ; then
			CS_MULTI="true"
		else
			CS_MULTI="false"
		fi
	else
		CS_ABLE="false"
	fi

	if [[ "$CS_ABLE" == "false" ]] ; then
		notify "Error" "No codesigning certificates detected"
		exit
	fi

	# check for existing disk image code signature
	CS_TEST=$(/usr/bin/codesign -dvvvv "$FILEPATH" 2>&1)
	if [[ "$CS_TEST" == *"is not signed at all" ]] ; then
		SIGN_INFO="codesign"
		PREV_INFO="not codesigned"
	else
		SIGN_INFO="re-codesign"
		PREV_SIG=$(echo "$CS_TEST" | /usr/bin/grep "Authority=" | /usr/bin/head -1 | /usr/bin/awk -F= '{print substr($0, index($0,$2))}')
		PREV_INFO="$PREV_SIG"
	fi

	# ask user to (re)codesign DMG (only if the keychain contains CSCs)
	if [[ "$CS_MULTI" == "false" ]] ; then
		CERT_TEXT="your identity '$CERTS'"
	elif [[ "$CS_MULTI" == "true" ]] ; then
		CERT_TEXT="one of your identities"
	fi
	DIALOG_TXT="File: $TARGET_NAME
Leaf: $PREV_INFO

Do you want to use $CERT_TEXT to $SIGN_INFO the disk image?"
	CS_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.dimago:lcars.png"
	set theEncryption to button returned of (display dialog "$DIALOG_TXT" ¬
		buttons {"No", "Yes"} ¬
		default button 2 ¬
		with title "DiMaGo" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theEncryption
EOT)
	if [[ "$CS_CHOICE" == "Yes" ]] ; then # use only CSC in keychain
		if [[ "$CS_MULTI" == "false" ]] ; then
			if [[ "$SIGN_INFO" == "codesign" ]] ; then
				CS_RESULT=$(/usr/bin/codesign -s "$CERTS" -v "$FILEPATH" 2>&1)
			elif [[ "$SIGN_INFO" == "re-codesign" ]] ; then
				CS_RESULT=$(/usr/bin/codesign -f -s "$CERTS" -v "$FILEPATH" 2>&1)
			fi
		elif [[ "$CS_MULTI" == "true" ]] ; then # select CSC from list
			CERT_CHOICE=$(/usr/bin/osascript << EOT
tell application "System Events"
	activate
	set theList to {}
	set theItems to paragraphs of "$CERTS"
	repeat with anItem in theItems
		set theList to theList & {(anItem) as string}
	end repeat
	set AppleScript's text item delimiters to return & linefeed
	set theResult to choose from list theList with prompt "Choose your codesigning identity." with title "DiMaGo" OK button name "Select" cancel button name "Cancel" without multiple selections allowed
	return the result as string
	set AppleScript's text item delimiters to ""
end tell
theResult
EOT)
			if [[ "$CERT_CHOICE" != "" ]] && [[ "$CERT_CHOICE" != "false" ]] ; then
				if [[ "$SIGN_INFO" == "codesign" ]] ; then
					CS_RESULT=$(/usr/bin/codesign -s "$CERT_CHOICE" -v "$FILEPATH" 2>&1)
				elif [[ "$SIGN_INFO" == "re-codesign" ]] ; then
					CS_RESULT=$(/usr/bin/codesign -f -s "$CERT_CHOICE" -v "$FILEPATH" 2>&1)
				fi
			else
				exit # ALT: continue
			fi
		fi
		CS_NOTIFY=$(echo "$CS_RESULT" | /usr/bin/tail -n 1 | /usr/bin/awk -F": " '{print substr($0, index($0,$2))}')
		if [[ "$CS_NOTIFY" == "" ]] ; then
			CS_NOTIFY="Error"
		fi
		notify "Image: $SIGN_INFO" "$CS_NOTIFY"
	else
		exit # ALT: continue
	fi

else # create disk image with DiMaGo

	# check if target is not a directory, or is a bundle
	if [[ ! -d "$FILEPATH" ]] ; then
		notify "Error: target is not a directory" "$TARGET_NAME"
		exit # ALT: continue
	fi
	PATH_TYPE=$(/usr/bin/mdls -name kMDItemContentTypeTree "$FILEPATH" | /usr/bin/grep -e "bundle")
	if [[ "$PATH_TYPE" != "" ]] ; then
		notify "Error: target is a bundle" "$TARGET_NAME"
		exit # ALT: continue
	fi

	echo -n "" > "$CERTS_TEMP"

	# remove .DS_Store file
	if [[ -f "$FILEPATH/.DS_Store" ]] ; then
		rm -rf "$FILEPATH/.DS_Store"
	fi

	# check for codesigning certificates in the user's keychains
	notify "Please wait! Searching…" "Code signing certificates"
	CERTS=$(/usr/bin/security find-identity -v -p codesigning | /usr/bin/awk '{print substr($0, index($0,$3))}' | /usr/bin/sed -e '$d' -e 's/^"//' -e 's/"$//')
	if [[ "$CERTS" != "" ]] ; then
		CS_ABLE="true"
		CS_COUNT=$(echo "$CERTS" | /usr/bin/wc -l | xargs)
		if [[ ($CS_COUNT>1) ]] ; then
			CS_MULTI="true"
		else
			CS_MULTI="false"
		fi
	else
		CS_ABLE="false"
	fi

	# select disk image type: dmg (read-only) or sparsebundle
	TYPE_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.dimago:lcars.png"
	set theType to button returned of (display dialog "Choose the type of disk image to create from \"$TARGET_NAME\". Sparsebundles are best for dynamic storage and collaboration, DMGs for file distribution." ¬
		buttons {"Cancel", "Read-Write Sparsebundle", "Read-Only DMG"} ¬
		default button 3 ¬
		with title "DiMaGo" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theType
EOT)
	if [[ "$TYPE_CHOICE" == "Read-Only DMG" ]] ; then
		TYPE="dmg"
	elif [[ "$TYPE_CHOICE" == "Read-Write Sparsebundle" ]] ; then
		TYPE="sparsebundle"
	else
		TYPE=""
		exit # ALT: continue
	fi

	# input volume name
	VOL_NAME=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.dimago:lcars.png"
	set theVolumeName to text returned of (display dialog "Enter the volume name that will be displayed after you mount the disk image." ¬
		default answer "$TARGET_NAME" ¬
		buttons {"Cancel", "Enter"} ¬
		default button 2 ¬
		with title "DiMaGo" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theVolumeName
EOT)
	if [[ "$VOL_NAME" == "" ]] || [[ "$VOL_NAME" == "false" ]] ; then
		exit # ALT: continue
	fi

	# set maximum sparsebundle size in GB
	if [[ "$TYPE" == "sparsebundle" ]] ; then
		MAX_SIZE=""
		BREAKER=""
		SIZE_RETURN=""
		until [[ "$SIZE_RETURN" == "true" ]]
		do
			SIZE_INPUT=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.dimago:lcars.png"
	set theMaximumSize to text returned of (display dialog "Enter the maximum volume size for the sparsebundle in gigabyte (integers only). The default maximum size is 5 GB." & return & return & "Please note that the disk image will grow as you add content, and the initial size will be much smaller." ¬
		default answer "5" ¬
		buttons {"Cancel", "Enter"} ¬
		default button 2 ¬
		with title "DiMaGo" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theMaximumSize
EOT)
			if [[ "$SIZE_INPUT" == "false" ]] || [[ "$SIZE_INPUT" == "" ]] ; then
				BREAKER="true"
				SIZE_RETURN="true"
				break
			fi
			case $SIZE_INPUT in
				'' | '0' | *.* | *,* | */* | *+* | *-* | *'*'* | *.*.* | *[!0-9]*) notify "False input: $SIZE_INPUT" "Only integers of at least 1" && continue ;;
				*) SIZE_RETURN="true" && MAX_SIZE="$SIZE_INPUT" && continue ;;
			esac
		done
	fi
	if [[ "$BREAKER" == "true" ]] ; then
		exit # ALT: continue
	fi

	# choose encryption
	ENCRYPT_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.dimago:lcars.png"
	set theEncryption to button returned of (display dialog "Do you want to encrypt the disk image?" ¬
		buttons {"No", "AES-128", "AES-256"} ¬
		default button 3 ¬
		with title "DiMaGo" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theEncryption
EOT)
	if [[ "$ENCRYPT_CHOICE" == "No" ]] ; then
		ENCRYPT="false"
	elif [[ "$ENCRYPT_CHOICE" == "AES-128" ]] || [[ "$ENCRYPT_CHOICE" == "AES-256" ]] ; then
		ENCRYPT="true"
	else
		ENCRYPT=""
		exit # ALT: continue
	fi

	# choose encryption method
	if [[ "$ENCRYPT" == "true" ]] ; then
		ENCRYPT_METHOD=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.dimago:lcars.png"
	set theEncryption to button returned of (display dialog "Choose your encryption method." ¬
		buttons {"Password Only", "Password & Public Key", "Public Key Only"} ¬
		default button 3 ¬
		with title "DiMaGo" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theEncryption
EOT)
		if [[ "$ENCRYPT_METHOD" == "Password Only" ]] ; then
			METHOD="pw"
		elif [[ "$ENCRYPT_METHOD" == "Public Key Only" ]] ; then
			METHOD="key"
		elif [[ "$ENCRYPT_METHOD" == "Password & Public Key" ]] ; then
			METHOD="all"
		else
			METHOD=""
			exit # ALT: continue
		fi
	fi

	if [[ "$ENCRYPT" == "true" ]] && [[ "$METHOD" != "pw" ]] && [[ "$METHOD" != "" ]] ; then

		# search for valid S/MIME keys
		notify "Please wait! Searching…" "Valid public S/MIME keys"
		DIMAGO_LADDR=$(/usr/bin/defaults read "$PREFS" localID)
		ALL_CERTS=$(/usr/bin/security find-certificate -a -p 2>/dev/null)
		RECORD=""
		echo "$ALL_CERTS" | while IFS= read -r LINE
		do
			RECORD="$RECORD
$LINE"
			if [[ $(echo "$RECORD" | /usr/bin/grep "END CERTIFICATE") != "" ]] ; then
				RECORD=$(echo "$RECORD" | /usr/bin/sed '1d')
				PURPOSE_ALL=$(echo "$RECORD" | /usr/bin/openssl x509 -inform PEM -noout -purpose 2>/dev/null)
				PURPOSE_CA=$(echo "$PURPOSE_ALL" | /usr/bin/grep "S/MIME encryption CA" | /usr/bin/awk -F: '{print $2}' | xargs)
				if [[ "$PURPOSE_CA" == "Yes" ]] ; then
					RECORD=""
					continue
				fi
				PURPOSE=$(echo "$PURPOSE_ALL" | /usr/bin/grep "S/MIME encryption" | /usr/bin/awk -F: '{print $2}' | xargs)
				if [[ "$PURPOSE" == "No" ]] ; then
					RECORD=""
					continue
				fi
				CERT_MAIL=$(echo "$RECORD" | /usr/bin/openssl x509 -inform PEM -noout -email 2>/dev/null)
				if [[ "$CERT_MAIL" == "" ]] ; then
					RECORD=""
					continue
				elif [[ "$CERT_MAIL" == *"@dimago.local" ]] ; then
					if [[ "$CERT_MAIL" != "$DIMAGO_LADDR" ]] ; then
						RECORD=""
						continue
					fi
				fi
				EXPIRES=$(echo "$RECORD" | /usr/bin/openssl x509 -inform PEM -checkend 3600)
				if [[ "$EXPIRES" == "Certificate will expire" ]] ; then
					RECORD=""
					continue
				fi
				SKID=$(echo "$RECORD" | /usr/bin/openssl x509 -inform PEM -noout -text | /usr/bin/grep -A1 "Subject Key Identifier" | /usr/bin/tail -1 | xargs | /usr/bin/sed s/://g)
				if [[ "$SKID" == "" ]] ; then
					RECORD=""
					continue
				fi
				if [[ "$CERT_MAIL" == "$DIMAGO_LADDR" ]] ; then
					CERT_CN="$ACCOUNT"
				else
					CERT_CN=$(echo "$RECORD" | /usr/bin/openssl x509 -inform PEM -noout -subject | /usr/bin/sed -n '/^subject/s/^.*CN=//p' | /usr/bin/awk -F"/emailAddress=" '{print $1}')
					if [[ "$CERT_CN" == "" ]] ; then
						CERT_CN="n/a"
					fi
				fi
				echo "$CERT_MAIL [$CERT_CN]:::$SKID" >> "$CERTS_TEMP"
				RECORD=""
			fi
		done
		CERT_DIGEST=$(/bin/cat "$CERTS_TEMP" | /usr/bin/sort -f)
		if [[ "$CERT_DIGEST" == "" ]] ; then
			KEY_RETURN="false"
		else
			KEY_RETURN="true"

			# select email address(es) to encrypt disk image
			ALL_SMIME=$(echo "$CERT_DIGEST" | /usr/bin/awk -F":::" '{print $1}')
			KEY_ADDR=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theList to {}
	set theItems to paragraphs of "$ALL_SMIME"
	repeat with anItem in theItems
		set theList to theList & {(anItem) as string}
	end repeat
	set AppleScript's text item delimiters to return & linefeed
	set theResult to choose from list theList with prompt "Choose the email address(es). The public key(s) will be used to encrypt the disk image." with title "DiMaGo" OK button name "Select" cancel button name "Cancel" with multiple selections allowed
	set AppleScript's text item delimiters to ""
end tell
theResult
EOT)
			if [[ "$KEY_ADDR" == "" ]] || [[ "$KEY_ADDR" == "false" ]] ; then
				exit # ALT: continue
			else
				KEY_RETURN="true"
				SKID_ROW=""
				ENCRYPT_INFO=""
				for ADDRESS in $(echo "$KEY_ADDR" | /usr/bin/grep -Eo '[^ ]*@[^ ]*')
				do
					FINAL_SKID=$(echo "$CERT_DIGEST" | /usr/bin/grep "$ADDRESS" | /usr/bin/awk -F":::" '{print $2}')
					SKID_ROW="$SKID_ROW$FINAL_SKID,"
					ENCRYPT_INFO="$ENCRYPT_INFO$ADDRESS
$FINAL_SKID
"
				done
				SKID_ROW=$(echo "$SKID_ROW" | /usr/bin/sed 's/,*$//g')
				echo "$SKID_ROW"
			fi
		fi
	fi

	# choose random password or input manually (double input)
	if [[ "$ENCRYPT" == "true" ]] && [[ "$METHOD" != "key" ]] && [[ "$METHOD" != "" ]] ; then
		PW_RETURN="false"
		until [[ "$PW_RETURN" == "true" ]]
		do
			# first input or choose random
			PW_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.dimago:lcars.png"
	set {thePassword, theButton} to {text returned, button returned} of (display dialog "Enter the encryption passphrase for the disk image, or choose to create a random passphrase." ¬
		with hidden answer ¬
		default answer "" ¬
		buttons {"Random", "Enter"} ¬
		default button 2 ¬
		with title "DiMaGo" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
thePassword & "@DELIM@" & theButton
EOT)
			BUTTON=$(echo "$PW_CHOICE" | /usr/bin/awk -F"@DELIM@" '{print $2}')
			if [[ "$BUTTON" == "Random" ]] ; then # create random password
				PW_GEN="true"
				PASSPHRASE=$(/usr/bin/openssl rand -base64 47 | /usr/bin/tr -d /=+ | /usr/bin/cut -c -32)
				PW_RETURN="true"
				continue
			fi
			FIRST_PW=$(echo "$PW_CHOICE" | /usr/bin/awk -F"@DELIM@" '{print $1}')
			if [[ "$BUTTON" == "Enter" ]] && [[ "$FIRST_PW" == "" ]] ; then
				notify "Input error" "No passphrase"
				continue
			fi

			# input a second time
			SECOND_PW=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.dimago:lcars.png"
	set thePassword to text returned of (display dialog "Enter the encryption password again." ¬
		with hidden answer ¬
		default answer "" ¬
		buttons {"Enter"} ¬
		default button 1 ¬
		with title "DiMaGo" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
thePassword
EOT)
			if [[ "$SECOND_PW" == "" ]] ; then
				notify "Input error" "No passphrase"
				continue
			fi
			if [[ "$SECOND_PW" == "$FIRST_PW" ]] ; then
				PASSPHRASE="$SECOND_PW"
				PW_RETURN="true"
				continue
			else
				notify "Input error" "Passphrases don't match"
				continue
			fi
		done
	fi

	# enter image basename
	TARGET_PARENT=$(/usr/bin/dirname "$FILEPATH")
	OV_RETURN=""
	BREAKER=""
	until [[ "$OV_RETURN" == "true" ]]
	do
		DMG_NAME=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.dimago:lcars.png"
	set theBaseName to text returned of (display dialog "Enter the disk image's basename." ¬
		default answer "$TARGET_NAME.$TYPE" ¬
		buttons {"Cancel", "Enter"} ¬
		default button 2 ¬
		with title "DiMaGo" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theBaseName
EOT)
		if [[ "$DMG_NAME" == "" ]] || [[ "$DMG_NAME" == "false" ]] ; then
			BREAKER="true"
			OV_RETURN="true"
			break
		fi
		if [[ "$DMG_NAME" != *".$TYPE" ]] ; then
			DMG_NAME="$DMG_NAME.$TYPE"
		fi
		if [[ -f "$TARGET_PARENT/$DMG_NAME" ]] ; then
			OV_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.dimago:lcars.png"
	set theOverwrite to button returned of (display dialog "A disk image named $DMG_NAME already exists in your destination folder. Do you want to replace it with the one you're creating, or do you want to rename the new disk image? " ¬
		buttons {"Cancel", "Rename", "Replace"} ¬
		with title "DiMaGo" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theOverwrite
EOT)
			if [[ "$OV_CHOICE" == "Replace" ]] ; then
				OV_RETURN="true"
			elif [[ "$OV_CHOICE" == "Rename" ]] ; then
				OV_RETURN=""
			else
				BREAKER="true"
				OV_RETURN="true"
			fi
		else
			OV_RETURN="true"
		fi
	done
	if [[ "$BREAKER" == "true" ]] ; then
		exit # ALT: continue
	fi

	# create DMG or sparsebundle
	notify "Please wait!" "Generating disk image…"
	if [[ "$TYPE" == "dmg" ]] ; then
		if [[ "$ENCRYPT" == "false" ]] ; then
			CREATE=$(/usr/bin/hdiutil create -srcfolder "$FILEPATH" -volname "$VOL_NAME" -layout GPTSPUD -fs HFS+ -fsargs "-c c=64,a=16,e=16" -nospotlight -format UDBZ -ov "$TARGET_PARENT/$DMG_NAME" 2>&1)
		elif [[ "$ENCRYPT" == "true" ]] ; then
			if [[ "$METHOD" == "pw" ]] ; then
				CREATE=$(echo -n "$PASSPHRASE" | /usr/bin/hdiutil create -srcfolder "$FILEPATH" -volname "$VOL_NAME" -layout GPTSPUD -fs HFS+ -fsargs "-c c=64,a=16,e=16" -nospotlight -format UDBZ -encryption "$ENCRYPT_CHOICE" -stdinpass -ov "$TARGET_PARENT/$DMG_NAME" 2>&1)
			elif [[ "$METHOD" == "key" ]] ; then
				CREATE=$(/usr/bin/hdiutil create -srcfolder "$FILEPATH" -volname "$VOL_NAME" -layout GPTSPUD -fs HFS+ -fsargs "-c c=64,a=16,e=16" -nospotlight -format UDBZ -encryption "$ENCRYPT_CHOICE" -pubkey "$SKID_ROW" -ov "$TARGET_PARENT/$DMG_NAME" 2>&1)
			elif [[ "$METHOD" == "all" ]] ; then
				CREATE=$(echo -n "$PASSPHRASE" | /usr/bin/hdiutil create -srcfolder "$FILEPATH" -volname "$VOL_NAME" -layout GPTSPUD -fs HFS+ -fsargs "-c c=64,a=16,e=16" -nospotlight -format UDBZ -encryption "$ENCRYPT_CHOICE" -stdinpass -pubkey "$SKID_ROW" -ov "$TARGET_PARENT/$DMG_NAME" 2>&1)
			fi
		fi
	elif [[ "$TYPE" == "sparsebundle" ]] ; then
		if [[ "$ENCRYPT" == "false" ]] ; then
			CREATE=$(/usr/bin/hdiutil create -srcfolder "$FILEPATH" -volname "$VOL_NAME" -layout GPTSPUD -fs HFS+J -format UDSB -size "$MAX_SIZE"g -ov "$TARGET_PARENT/$DMG_NAME" 2>&1)
		elif [[ "$ENCRYPT" == "true" ]] ; then
			if [[ "$METHOD" == "pw" ]] ; then
				CREATE=$(echo -n "$PASSPHRASE" | /usr/bin/hdiutil create -srcfolder "$FILEPATH" -volname "$VOL_NAME" -layout GPTSPUD -fs HFS+J -format UDSB -size "$MAX_SIZE"g -encryption "$ENCRYPT_CHOICE" -stdinpass -ov "$TARGET_PARENT/$DMG_NAME" 2>&1)
			elif [[ "$METHOD" == "key" ]] ; then
				CREATE=$(/usr/bin/hdiutil create -srcfolder "$FILEPATH" -volname "$VOL_NAME" -layout GPTSPUD -fs HFS+J -format UDSB -size "$MAX_SIZE"g -encryption "$ENCRYPT_CHOICE" -pubkey "$SKID_ROW" -ov "$TARGET_PARENT/$DMG_NAME" 2>&1)
			elif [[ "$METHOD" == "all" ]] ; then
				CREATE=$(echo -n "$PASSPHRASE" | /usr/bin/hdiutil create -srcfolder "$FILEPATH" -volname "$VOL_NAME" -layout GPTSPUD -fs HFS+J -format UDSB -size "$MAX_SIZE"g -encryption "$ENCRYPT_CHOICE" -stdinpass -pubkey "$SKID_ROW" -ov "$TARGET_PARENT/$DMG_NAME" 2>&1)
			fi
		fi
	fi

	# creation successful?
	echo "$CREATE"
	if [[ $(echo "$CREATE" | /usr/bin/grep "hdiutil: create failed") != "" ]] ; then
		notify "Error creating disk image" "$DMG_NAME"
		exit # ALT: continue
	elif [[ $(echo "$CREATE" | /usr/bin/grep "Certificate not found") != "" ]] ; then
		notify "Error: certificate not found" "$MAIL_ADDR"
		exit # ALT: continue
	elif [[ $(echo "$CREATE" | /usr/bin/grep "hdiutil:") != "" ]] ; then
		notify "Internal error" "$DMG_NAME"
		exit # ALT: continue
	else
		notify "Image created" "$DMG_NAME"
	fi

	# read UUID
	if [[ "$METHOD" == "pw" ]] || [[ "$METHOD" == "all" ]] ; then
		DMG_DUMP=$(echo -n "$PASSPHRASE" | /usr/bin/hdiutil isencrypted "$TARGET_PARENT/$DMG_NAME" 2>&1)
	elif [[ "$METHOD" == "key" ]] ; then
		DMG_DUMP=$(/usr/bin/hdiutil isencrypted "$TARGET_PARENT/$DMG_NAME" 2>&1)
	fi
	UUID=$(echo "$DMG_DUMP" | /usr/bin/grep "uuid:" | /usr/bin/awk -F": " '{print $2}')
	if [[ "$UUID" == "" ]] ; then
		UUID="$ACCOUNT"
		UUID_INFO="n/a"
	else
		UUID_INFO="$UUID"
	fi

	# calculcate checksum (only for DMGs)
	if [[ "$TYPE" == "dmg" ]] ; then
		FILESUM=$(/usr/bin/shasum -a 256 "$TARGET_PARENT/$DMG_NAME" | /usr/bin/awk '{print $1}')
	else
		FILESUM="n/a"
	fi

	# set comment string
	if [[ "$ENCRYPT_INFO" == "" ]] ; then
		ENCRYPT_INFO="none"
	fi
	COMMENT="UUID:
$UUID_INFO

SHA-256:
$FILESUM

Public encryption keys:
$ENCRYPT_INFO"

	# ask what to do with the passphrase
	if [[ "$METHOD" == "pw" ]] || [[ "$METHOD" == "all" ]] ; then
		if [[ "$PW_GEN" == "true" ]] ; then
			PW_STORE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.dimago:lcars.png"
	set thePasswordStore to button returned of (display dialog "DiMaGo will now store the encryption information in your DiMaGo keychain. What do you want to do with your randomly generated passphrase?" ¬
		buttons {"Copy to Clipboard", "Store in Keychain"} ¬
		with title "DiMaGo" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
thePasswordStore
EOT)
		else
			PW_STORE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.dimago:lcars.png"
	set thePasswordStore to button returned of (display dialog "DiMaGo will now store the encryption information in your DiMaGo keychain. What do you want to do with your passphrase?" ¬
		buttons {"Nothing", "Copy to Clipboard", "Store in Keychain"} ¬
		with title "DiMaGo" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
thePasswordStore
EOT)
		fi
	fi

	# add to DiMaGo keychain entry: UUID && password (optional) && public key(s) && SHA2 checksum (DMGs only)
	if [[ "$METHOD" == "pw" ]] ; then
		if [[ "$PW_STORE" == "Store in Keychain" ]] ; then
			/usr/bin/security add-generic-password -U -D "disk image password" -l "$DMG_NAME" -s "$DMG_NAME" -a "$UUID" -j "$COMMENT" -T /System/Library/PrivateFrameworks/DiskImages.framework/Versions/A/Resources/diskimages-helper -w "$PASSPHRASE" DiMaGo.keychain
		else
			/usr/bin/security add-generic-password -U -D "disk image password" -l "$DMG_NAME" -s "$DMG_NAME" -a "$ACCOUNT" -j "$COMMENT" DiMaGo.keychain
		fi
		if [[ "$PW_STORE" != "Nothing" ]] ; then
			echo "$PASSPHRASE" | /usr/bin/pbcopy
		fi
	elif [[ "$METHOD" == "all" ]] ; then
		if [[ "$PW_STORE" == "Store in Keychain" ]] ; then
			/usr/bin/security add-generic-password -U -D "disk image password" -l "$DMG_NAME" -s "$DMG_NAME" -a "$UUID" -j "$COMMENT" -T /System/Library/PrivateFrameworks/DiskImages.framework/Versions/A/Resources/diskimages-helper -w "$PASSPHRASE" DiMaGo.keychain
		else
			/usr/bin/security add-generic-password -U -D "disk image password" -l "$DMG_NAME" -s "$DMG_NAME" -a "$ACCOUNT" -j "$COMMENT" DiMaGo.keychain
		fi
		if [[ "$PW_STORE" != "Nothing" ]] ; then
			echo "$PASSPHRASE" | /usr/bin/pbcopy
		fi
	elif [[ "$METHOD" == "key" ]] ; then
		/usr/bin/security add-generic-password -U -D "disk image password" -l "$DMG_NAME" -s "$DMG_NAME" -a "$ACCOUNT" -j "$COMMENT" DiMaGo.keychain
	fi

	# ask user to codesign DMG (only if the keychain contains CSCs)
	# NOTE: when using split to segment DMGs, the code signing signature is lost
	if [[ "$CS_ABLE" == "true" ]] ; then
		if [[ "$CS_MULTI" == "false" ]] ; then
			CERT_TEXT="use your identity $CERTS"
		elif [[ "$CS_MULTI" == "true" ]] ; then
			CERT_TEXT="use one of your identities"
		else
			CERT_TEXT=""
		fi
		DIALOG_TXT="Do you want to $CERT_TEXT to codesign the disk image $DMG_NAME?"
		CS_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.dimago:lcars.png"
	set theEncryption to button returned of (display dialog "$DIALOG_TXT" ¬
		buttons {"No", "Yes"} ¬
		default button 2 ¬
		with title "DiMaGo" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theEncryption
EOT)
		if [[ "$CS_CHOICE" == "Yes" ]] ; then # codesign DMG
			if [[ "$CS_MULTI" == "true" ]] ; then # select CSC from list
				CERT_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theList to {}
	set theItems to paragraphs of "$CERTS"
	repeat with anItem in theItems
		set theList to theList & {(anItem) as string}
	end repeat
	set AppleScript's text item delimiters to return & linefeed
	set theResult to choose from list theList with prompt "Choose your codesigning identity." with title "DiMaGo" OK button name "Select" cancel button name "Cancel" without multiple selections allowed
	return the result as string
	set AppleScript's text item delimiters to ""
end tell
theResult
EOT)
				if [[ "$CERT_CHOICE" != "" ]] && [[ "$CERT_CHOICE" != "false" ]] ; then
					sleep 1 # sometimes hdiutil isn't fast enough, and codesign will not receive the disk image basename
					CS_RESULT=$(/usr/bin/codesign -s "$CERT_CHOICE" -v "$TARGET_PARENT/$DMG_NAME" 2>&1)
					CS_STATUS="true"
				else
					CS_STATUS="false"
				fi
			elif [[ "$CS_MULTI" == "false" ]] ; then # use only CSC in keychain
				sleep 1 # sometimes hdiutil isn't fast enough, and codesign will not receive the disk image basename
				CS_RESULT=$(/usr/bin/codesign -s "$CERTS" -v "$TARGET_PARENT/$DMG_NAME" 2>&1)
				CS_STATUS="true"
			fi
		else
			CS_STATUS="false"
		fi
		if [[ "$CS_STATUS" == "true" ]] ; then
			CS_NOTIFY=$(echo "$CS_RESULT" | /usr/bin/tail -n 1 | /usr/bin/awk -F": " '{print substr($0, index($0,$2))}')
			if [[ "$CS_NOTIFY" == "" ]] ; then
				CS_NOTIFY="Error"
			fi
			notify "Image: codesign" "$CS_NOTIFY"
		fi
	fi

	if [[ "$TYPE" == "dmg" ]] ; then # sparsebundles can't be segmented; they need to archived first

		# calculate DMG's file size
		BYTES=$(/usr/bin/stat -f%z "$TARGET_PARENT/$DMG_NAME")
		MEGABYTES=$(/usr/bin/bc -l <<< "scale=6; $BYTES/1000000")
		if (( $(echo "$MEGABYTES < 1" | /usr/bin/bc -l) )) ; then
			DMG_SIZE="0$MEGABYTES"
		else
			DMG_SIZE="$MEGABYTES"
		fi

		# segment DMG with native split command, if larger than 200 MB
		if (( $(echo "$DMG_SIZE > 200" | /usr/bin/bc -l) )) ; then
			SEG_DIR_NAME="${DMG_NAME//.dmg}"
			SEG_DIR="$TARGET_PARENT/$SEG_DIR_NAME~segments"
			mkdir -p "$SEG_DIR"
			notify "Segmenting DMG" "Size is greater than 200 MB"
			SEGMENTING=$(/usr/bin/split -b 200m -a 3 "$TARGET_PARENT/$DMG_NAME" "$SEG_DIR/$DMG_NAME".)
			echo "$SEGMENTING"
			if [[ "$SEGMENTING" != "" ]] ; then
				notify "DMG segmentation error" "$DMG_NAME"
				echo "$SEGMENTING"
				exit # ALT: continue
			else
				SEG="true"
			fi
			# change file suffixes
			COUNT=0
			cd "$SEG_DIR" && for SEGMENT in "$DMG_NAME".[a-z][a-z][a-z]
			do
				if [[ "$COUNT" == ? ]] ; then
					SUFFIX="00$COUNT"
				elif [[ "$COUNT" == ?? ]] ; then
					SUFFIX="0$COUNT"
				elif [[ "$COUNT" == ??? ]] ; then
					SUFFIX="$COUNT"
				fi
				NEW_SEGMENT="$DMG_NAME.$SUFFIX"
				mv "$SEGMENT" "$NEW_SEGMENT"
				(( COUNT++ ))
			done
			cd /

			# alternate hdiutil commands for splitting:
			# only for "pw" method: (echo "$PASSPHRASE"; echo "$PASSPHRASE") | /usr/bin/hdiutil segment -o "$SEG_DIR/$DMG_NAME" -segmentSize 200M "$TARGET_PARENT/$DMG_NAME"
			# only for non-encrypted dmg: /usr/bin/hdiutil segment -o "$SEG_DIR/$DMG_NAME" -segmentSize 200M "$TARGET_PARENT/$DMG_NAME"
			# on DMGs encrypted with a public key ("key" & "all" method) hdiutil's segment option can only be used, if at least one of the public keys derives from a certificate with the private key in the user's keychain

		else
			SEG="false"
		fi

		# read DiMaGo base identity SKID from preferences
		DIMAGO_LSKID=$(/usr/bin/defaults read "$PREFS" localSKID 2>/dev/null)
		if [[ "$DIMAGO_LSKID" == "" ]] ; then
			DIMAGO_LADDR=$(/usr/bin/defaults read "$PREFS" localID 2>/dev/null)
			if [[ "$DIMAGO_LADDR" == "" ]] ; then
				exit # ALT: continue
			fi
			DIMAGO_LSKID=$(/usr/bin/security find-certificate -e "$DIMAGO_LADDR" | /usr/bin/grep "hpky" | /usr/bin/awk '{print $1;}' | /usr/bin/sed 's/^.*x//')
			/usr/bin/defaults write "$PREFS" localSKID "$DIMAGO_LSKID"
		fi

		if [[ "$SEG" == "true" ]] ; then # generate checksums for segments, write to CMS and create verify & join command

			HASH_INFO=""
			cd "$SEG_DIR" && for SEGMENT in *
			do
				SEGSUM=$(/usr/bin/openssl dgst -sha256 "$SEGMENT")
				HASH_INFO="$HASH_INFO
$SEGSUM"
			done
			cd /
			touch "$SEG_DIR/$SEG_DIR_NAME.sha256.txt"
			HASH_INFO=$(echo "$HASH_INFO" | /usr/bin/tail -n +2)
			echo "$HASH_INFO" > "$SEG_DIR/$SEG_DIR_NAME.sha256.txt"

			/usr/bin/security cms -S -i "$SEG_DIR/$SEG_DIR_NAME.sha256.txt" -Z "$DIMAGO_LSKID" -G -H SHA256 -P -o "$SEG_DIR/$SEG_DIR_NAME~segments.sha256.cms"
			rm -rf "$SEG_DIR/$SEG_DIR_NAME.sha256.txt"

			CMD_LOC="$SEG_DIR/$DMG_NAME.join.command"
			touch "$CMD_LOC"

			VER_FUNC=$(/bin/cat << 'EOT'
#!/bin/bash
DIR="$( cd "$( /usr/bin/dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Accessing: $DIR"
if [ ! -f "$DIR/"*"~segments.sha256.cms" ] ; then
	echo "Error: CMS is missing!"
	echo "Exiting..."
else
	echo "Found CMS file"
	echo "Verifying with signature..."
	DIGEST=$(/usr/bin/security cms -D -i "$DIR/"*"~segments.sha256.cms" 2>&1)
	if [ "$(echo "$DIGEST" | /usr/bin/grep "security: ")" != "" ] ; then
		VERIFY="false"
		echo "$DIGEST"
		echo "Result: CMS corrupted"
	else
		echo "Verification done. OK."
		echo "Verifying checksums..."
		VERIFY="true"
		while IFS= read -r RECORD
		do
			echo ""
			NAME=$(echo "$RECORD" | rev | /usr/bin/awk -F= '{print $2}' | rev | sed -n 's/.*(//;s/).*//p')
			SEGNO=$(echo "$NAME" | rev | /usr/bin/awk -F. '{print $1}' | rev)
			FULLPATH="$DIR/$NAME"
			echo "*** SEGMENT $SEGNO ***"
			if [ ! -f "$DIR/$NAME" ] ; then
				VERIFY="false"
				FULLPATH="n/a"
				HASH1=$(echo "$RECORD" | rev | /usr/bin/awk -F= '{print $1}' | rev | xargs)
				HASH2="checksum n/a"
				RESULT="file missing"
			else
				HASH1=$(echo "$RECORD" | rev | /usr/bin/awk -F= '{print $1}' | rev | xargs)
				HASH2=$(/usr/bin/shasum -a 256 "$DIR/$NAME" | /usr/bin/awk '{print $1}')
				if [ "$HASH2" != "$HASH1" ] ; then
					VERIFY="false"
					RESULT="checksum mismatch"
				else
					RESULT="OK"
				fi
			fi
			echo "Filename: $NAME"
			echo "Path: $FULLPATH"
			echo "Hash (CMS): $HASH1"
			echo "Hash (cmd): $HASH2"
			echo "Result: $RESULT"
		done <<< "$(echo -e "$DIGEST")"
	fi
	echo ""
	if [ "$VERIFY" == "false" ] ; then
		echo "Verification done. There were errors!"
		echo "Exiting..."
	elif [ "$VERIFY" == "true" ] ; then
		echo "Verification done. All OK."
		echo "Joining segments with cat..."
		echo ""
		DEST_NAME=$(echo "$NAME" | rev | /usr/bin/awk -F. '{print substr($0, index($0,$2))}' | rev)
		CONCAT=$(/bin/cat "$DIR/$DEST_NAME."??? > "$DIR/$DEST_NAME")
		if [ "$CONCAT" != "" ] ; then
			echo "$CONCAT"
			echo "Possible error joining segments!"
			echo "Exiting..."
		else
			echo "Finished joining segments: $DEST_NAME"
			echo "Note: disk image code signing signatures are lost when using the split command."
		fi
	fi
fi
EOT)
			echo "$VER_FUNC" > "$CMD_LOC"
			/bin/chmod u+x "$CMD_LOC"
			notify "DMG segmentation complete" "$DMG_NAME"

		elif [[ "$SEG" == "false" ]] ; then # write checksum for DMG to CMS and create verify command

			cd "$TARGET_PARENT"
			HASH_INFO=$(/usr/bin/openssl dgst -sha256 "$DMG_NAME")
			cd /
			touch "$TARGET_PARENT/$DMG_NAME.sha256.txt"
			echo "$HASH_INFO" > "$TARGET_PARENT/$DMG_NAME.sha256.txt"

			/usr/bin/security cms -S -i "$TARGET_PARENT/$DMG_NAME.sha256.txt" -Z "$DIMAGO_LSKID" -G -H SHA256 -P -o "$TARGET_PARENT/$DMG_NAME.sha256.cms"
			rm -rf "$TARGET_PARENT/$DMG_NAME.sha256.txt"

			CMD_LOC="$TARGET_PARENT/$DMG_NAME.verify.command"
			touch "$CMD_LOC"

			VER_FUNC=$(/bin/cat << 'EOT'
#!/bin/bash
DIR="$( cd "$( /usr/bin/dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "Accessing: $DIR"
if [ ! -f "$DIR/"*".sha256.cms" ] ; then
	echo "Error: CMS is missing!"
	echo "Exiting..."
else
	echo "Found CMS file"
	echo "Verifying with signature..."
	DIGEST=$(/usr/bin/security cms -D -i "$DIR/"*".sha256.cms" 2>&1)
	if [ "$(echo "$DIGEST" | /usr/bin/grep "security: ")" != "" ] ; then
		VERIFY="false"
		echo "$DIGEST"
		echo "Result: CMS corrupted"
	else
		echo "Verification done. OK."
		echo "Verifying checksum..."
		NAME=$(echo "$DIGEST" | rev | /usr/bin/awk -F= '{print $2}' | rev | sed -n 's/.*(//;s/).*//p')
		FULLPATH="$DIR/$NAME"
		if [ ! -f "$DIR/$NAME" ] ; then
			VERIFY="false"
			FULLPATH="n/a"
			HASH1=$(echo "$DIGEST" | rev | /usr/bin/awk -F= '{print $1}' | rev | xargs)
			HASH2="checksum n/a"
			RESULT="file missing"
		else
			HASH1=$(echo "$DIGEST" | rev | /usr/bin/awk -F= '{print $1}' | rev | xargs)
			HASH2=$(/usr/bin/shasum -a 256 "$DIR/$NAME" | /usr/bin/awk '{print $1}')
			if [ "$HASH2" != "$HASH1" ] ; then
				VERIFY="false"
				RESULT="checksum mismatch"
			else
				VERIFY="true"
				RESULT="OK"
			fi
		fi
		echo "Filename: $NAME"
		echo "Path: $FULLPATH"
		echo "Hash (CMS): $HASH1"
		echo "Hash (cmd): $HASH2"
		echo "Result: $RESULT"
	fi
	if [ "$VERIFY" == "false" ] ; then
		echo "Error! Exiting..."
	elif [ "$VERIFY" == "true" ] ; then
		echo "Verifications done. All OK."
	fi
fi
EOT)

			echo "$VER_FUNC" > "$CMD_LOC"
			/bin/chmod u+x "$CMD_LOC"
		fi
	fi
fi

done

exit # ALT: [delete]
