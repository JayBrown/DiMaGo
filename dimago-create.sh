#!/bin/bash

# DiMaGo v1.0.2 (beta)
# DiMaGo ➤ Create (shell script version)
#
# Note: DiMaGo will remain in beta status until DiMaGo ➤ Verify has been scripted

LANG=en_US.UTF-8
export PATH=/usr/local/bin:$PATH
ACCOUNT=$(/usr/bin/id -un)
CURRENT_VERSION="1.02"

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
		/usr/bin/osascript -e 'display notification "$2" with title "DiMaGo [$ACCOUNT]" subtitle "$1"' &>/dev/null
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
if [[ ! -e "$CERTS_TEMP" ]] ; then
	touch "$CERTS_TEMP"
fi

# preferences (currently unused)
PREFS_DIR="${HOME}/Library/Preferences/"
PREFS="local.lcars.dimago"
PREFS_FILE="$PREFS_DIR/$PREFS.plist"
if [[ ! -e "$PREFS_FILE" ]] ; then
	touch "$PREFS_FILE"
fi

# detect/create icon for terminal-notifier and osascript windows
ICON_LOC="$CACHE_DIR/lcars.png"
if [[ ! -e "$ICON_LOC" ]] ; then
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
if [[ -e "$CACHE_DIR/lcars.base64" ]] ; then
	rm -rf "$CACHE_DIR/lcars.base64"
fi

# detect/create big logo (curently unused)
ICON1024="$CACHE_DIR/lcars1024.png"
if [[ ! -e "$ICON1024" ]] ; then
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
if [[ ! -e "$ICNS_LOC" ]] ; then
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

for FILEPATH in "$1"
do

TARGET_NAME=$(/usr/bin/basename "$FILEPATH")

if [[ "$FILEPATH" == *".dmg" ]] || [[ "$FILEPATH" == *".sparsebundle" ]] || [[ "$FILEPATH" == *".sparseimage" ]] ; then # codesign or re-codesign image

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

	# check for existing image code signature
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

Do you want to use $CERT_TEXT to $SIGN_INFO the image?"
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

else # create image with DiMaGo

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

	# select image type: dmg (read-only) or sparsebundle
	TYPE_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.dimago:lcars.png"
	set theType to button returned of (display dialog "Choose the type of image to create from \"$TARGET_NAME\". Sparsebundles are best for dynamic storage and collaboration, DMGs for file distribution." ¬
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
	set theVolumeName to text returned of (display dialog "Enter the volume name that will be displayed after you open the image file." ¬
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
		# BREAKER="" # ALT: for workflow only
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
				exit # ALT: BREAKER="true" && break
			fi
			case $SIZE_INPUT in
				'' | '0' | *.* | *,* | */* | *+* | *-* | *'*'* | *.*.* | *[!0-9]*) notify "Error: false input \"$SIZE_INPUT\"" "Only integers of at least 1" && continue ;;
				*) SIZE_RETURN="true" && MAX_SIZE="$SIZE_INPUT" && continue ;;
			esac
		done
	fi

	# ALT: only for workflow
	# if [[ "$BREAKER" == "true" ]] ; then
	#	continue
	# fi

	# choose encryption
	ENCRYPT_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.dimago:lcars.png"
	set theEncryption to button returned of (display dialog "Do you want to encrypt the image?" ¬
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
		notify "Please wait! Searching…" "Valid S/MIME certificates"
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
				echo "$CERT_MAIL:::$SKID" >> "$CERTS_TEMP"
				RECORD=""
			fi
		done
		CERT_DIGEST=$(/bin/cat "$CERTS_TEMP" | /usr/bin/sort -f)
		if [[ "$CERT_DIGEST" == "" ]] ; then
			KEY_RETURN="false"
		else
			KEY_RETURN="true"

			# select email address(es) to encrypt image
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
	set theResult to choose from list theList with prompt "Choose the email address(es). The public key(s) will be used to encrypt the image." with title "DiMaGo" OK button name "Select" cancel button name "Cancel" with multiple selections allowed
	set AppleScript's text item delimiters to ""
end tell
theResult
EOT)
			if [[ "$KEY_ADDR" == "" ]] || [[ "$KEY_ADDR" == "false" ]] ; then
				exit # ALT: continue
			else
				KEY_RETURN="true"
				KEY_ROW=$(echo "$KEY_ADDR" | /usr/bin/awk '{gsub(", "," "); print}')
				SKID_ROW=""
				ENCRYPT_INFO=""
				for ADDRESS in $KEY_ROW
				do
					FINAL_SKID=$(echo "$CERT_DIGEST" | /usr/bin/grep "$ADDRESS" | /usr/bin/awk -F":::" '{print $2}')
					SKID_ROW="$SKID_ROW$FINAL_SKID,"
					ENCRYPT_INFO="$ENCRYPT_INFO$ADDRESS
$FINAL_SKID
"
				done
				SKID_ROW=$(echo "$SKID_ROW" | /usr/bin/sed 's/,*$//g')
			fi
		fi
	fi
	if [[ "$KEY_RETURN" == "false" ]] && [[ "$ENCRYPT" == "key" ]] ; then
		notify "Error: S/MIME" "No valid public keys"
		exit # ALT: continue
	fi
	if [[ "$KEY_RETURN" == "false" ]] && [[ "$ENCRYPT" == "all" ]] ; then
		notify "Missing S/MIME" "Using password only!"
		ENCRYPT="pw"
	fi

	# choose password
	if [[ "$ENCRYPT" == "true" ]] && [[ "$METHOD" != "key" ]] && [[ "$METHOD" != "" ]] ; then
		PW_CHOICE=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.dimago:lcars.png"
	set {thePassword, theButton} to {text returned, button returned} of (display dialog "Enter the encryption password for the image, or choose to create a random password. The password will be stored in your DiMaGo keychain." ¬
		with hidden answer ¬
		default answer "" ¬
		buttons {"Cancel", "Random", "Enter"} ¬
		default button 3 ¬
		with title "DiMaGo" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
thePassword & "@DELIM@" & theButton
EOT)
		if [[ "$PW_CHOICE" == "" ]] || [[ "$PW_CHOICE" == "false" ]] || [[ "$PW_CHOICE" == "@DELIM@" ]] ; then
			exit # ALT: continue
		fi
		PASSPHRASE=$(echo "$PW_CHOICE" | /usr/bin/awk -F"@DELIM@" '{print $1}')
		BUTTON=$(echo "$PW_CHOICE" | /usr/bin/awk -F"@DELIM@" '{print $2}')
		if [[ "$BUTTON" == "Random" ]] ; then # create random password
			PASSPHRASE=$(/usr/bin/openssl rand -base64 47 | /usr/bin/tr -d /=+ | /usr/bin/cut -c -32)
		elif [[ "$BUTTON" == "Enter" ]] && [[ "$PASSPHRASE" == "" ]] ; then
			exit # ALT: continue
		fi
	fi

	# enter image filename
	DMG_NAME=$(/usr/bin/osascript 2>/dev/null << EOT
tell application "System Events"
	activate
	set theLogoPath to ((path to library folder from user domain) as text) & "Caches:local.lcars.dimago:lcars.png"
	set theVolumeName to text returned of (display dialog "Enter the image's filename." ¬
		default answer "$TARGET_NAME.$TYPE" ¬
		buttons {"Cancel", "Enter"} ¬
		default button 2 ¬
		with title "DiMaGo" ¬
		with icon file theLogoPath ¬
		giving up after 180)
end tell
theVolumeName
EOT)
	if [[ "$DMG_NAME" == "" ]] || [[ "$DMG_NAME" == "false" ]] ; then
		exit # ALT: continue
	fi
	if [[ "$DMG_NAME" != *".$TYPE" ]] ; then
		DMG_NAME="$DMG_NAME.$TYPE"
	fi

	# create DMG or sparsebundle
	TARGET_PARENT=$(/usr/bin/dirname "$FILEPATH")
	if [[ "$TYPE" == "dmg" ]] ; then
		if [[ "$ENCRYPT" == "false" ]] ; then
			CREATE=$(/usr/bin/hdiutil create -srcfolder "$FILEPATH" -volname "$VOL_NAME" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -nospotlight -format UDBZ -ov "$TARGET_PARENT/$DMG_NAME" 2>&1)
		elif [[ "$ENCRYPT" == "true" ]] ; then
			if [[ "$METHOD" == "pw" ]] ; then
				CREATE=$(echo -n "$PASSPHRASE" | /usr/bin/hdiutil create -srcfolder "$FILEPATH" -volname "$VOL_NAME" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -nospotlight -format UDBZ -encryption "$ENCRYPT_CHOICE" -stdinpass -ov "$TARGET_PARENT/$DMG_NAME" 2>&1)
			elif [[ "$METHOD" == "key" ]] ; then
				CREATE=$(/usr/bin/hdiutil create -srcfolder "$FILEPATH" -volname "$VOL_NAME" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -nospotlight -format UDBZ -encryption "$ENCRYPT_CHOICE" -pubkey "$SKID_ROW" -ov "$TARGET_PARENT/$DMG_NAME" 2>&1)
			elif [[ "$METHOD" == "all" ]] ; then
				CREATE=$(echo -n "$PASSPHRASE" | /usr/bin/hdiutil create -srcfolder "$FILEPATH" -volname "$VOL_NAME" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -nospotlight -format UDBZ -encryption "$ENCRYPT_CHOICE" -stdinpass -pubkey "$SKID_ROW" -ov "$TARGET_PARENT/$DMG_NAME" 2>&1)
			fi
		fi
	elif [[ "$TYPE" == "sparsebundle" ]] ; then
		if [[ "$ENCRYPT" == "false" ]] ; then
			CREATE=$(/usr/bin/hdiutil create -srcfolder "$FILEPATH" -volname "$VOL_NAME" -fs HFS+J -format UDSB -size "$MAX_SIZE"g -ov "$TARGET_PARENT/$DMG_NAME" 2>&1)
		elif [[ "$ENCRYPT" == "true" ]] ; then
			if [[ "$METHOD" == "pw" ]] ; then
				CREATE=$(echo -n "$PASSPHRASE" | /usr/bin/hdiutil create -srcfolder "$FILEPATH" -volname "$VOL_NAME" -fs HFS+J -format UDSB -size "$MAX_SIZE"g -encryption "$ENCRYPT_CHOICE" -stdinpass -ov "$TARGET_PARENT/$DMG_NAME" 2>&1)
			elif [[ "$METHOD" == "key" ]] ; then
				CREATE=$(/usr/bin/hdiutil create -srcfolder "$FILEPATH" -volname "$VOL_NAME" -fs HFS+J -format UDSB -size "$MAX_SIZE"g -encryption "$ENCRYPT_CHOICE" -pubkey "$SKID_ROW" -ov "$TARGET_PARENT/$DMG_NAME" 2>&1)
			elif [[ "$METHOD" == "all" ]] ; then
				CREATE=$(echo -n "$PASSPHRASE" | /usr/bin/hdiutil create -srcfolder "$FILEPATH" -volname "$VOL_NAME" -fs HFS+J -format UDSB -size "$MAX_SIZE"g -encryption "$ENCRYPT_CHOICE" -stdinpass -pubkey "$SKID_ROW" -ov "$TARGET_PARENT/$DMG_NAME" 2>&1)
			fi
		fi
	fi

	# creation successful?
	echo "$CREATE"
	if [[ $(echo "$CREATE" | /usr/bin/grep "hdiutil: create failed") != "" ]] ; then
		notify "Error creating image" "$DMG_NAME"
		exit # ALT: continue
	elif [[ $(echo "$CREATE" | /usr/bin/grep "Certificate not found") != "" ]] ; then
		notify "Error: certificate not found" "$MAIL_ADDR"
		exit # ALT: continue
	elif [[ $(echo "$CREATE" | /usr/bin/grep "hdiutil:") != "" ]] ; then
		notify "Internal error" "$DMG_NAME"
		exit # ALT: continue
	else
		notify "Image created" "$DMG_NAME"
		if [[ "$METHOD" == "pw" ]] || [[ "$METHOD" == "all" ]] ; then
			echo "$PASSPHRASE" | /usr/bin/pbcopy
		fi
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
	COMMENT="SHA-256:
$FILESUM

Public encryption keys:
$ENCRYPT_INFO"

	# add UUID and password or public key(s) or SHA2 checksum to DiMaGo keychain entry
	if [[ "$METHOD" == "pw" ]] ; then
		/usr/bin/security add-generic-password -U -D "disk image password" -l "$DMG_NAME" -s "$DMG_NAME" -a "$UUID" -j "$COMMENT" -T /System/Library/PrivateFrameworks/DiskImages.framework/Versions/A/Resources/diskimages-helper -T /usr/bin/security -w "$PASSPHRASE" DiMaGo.keychain
	elif [[ "$METHOD" == "all" ]] ; then
		/usr/bin/security add-generic-password -U -D "disk image password" -l "$DMG_NAME" -s "$DMG_NAME" -a "$UUID" -j "$COMMENT" -T /System/Library/PrivateFrameworks/DiskImages.framework/Versions/A/Resources/diskimages-helper -T /usr/bin/security -w "$PASSPHRASE" DiMaGo.keychain
	elif [[ "$METHOD" == "key" ]] ; then
		/usr/bin/security add-generic-password -U -D "disk image password" -l "$DMG_NAME" -s "$DMG_NAME" -a "$UUID" -j "$COMMENT" -T /System/Library/PrivateFrameworks/DiskImages.framework/Versions/A/Resources/diskimages-helper -T /usr/bin/security DiMaGo.keychain
	fi

	# ask user to codesign DMG (only if the keychain contains CSCs)
	if [[ "$CS_ABLE" == "true" ]] ; then
		if [[ "$CS_MULTI" == "false" ]] ; then
			CERT_TEXT="use your identity '$CERTS'"
		elif [[ "$CS_MULTI" == "true" ]] ; then
			CERT_TEXT="use one of your identities"
		else
			CERT_TEXT=""
		fi
		DIALOG_TXT="Do you want to $CERT_TEXT to codesign the image $DMG_NAME?"
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
					CS_RESULT=$(/usr/bin/codesign -s "$CERT_CHOICE" -v "$TARGET_PARENT/$DMG_NAME" 2>&1)
					CS_STATUS="true"
				else
					CS_STATUS="false"
				fi
			elif [[ "$CS_MULTI" == "false" ]] ; then # use only CSC in keychain
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
		# check for GNU split (because the macOS BSD version sucks balls, and because hdiutil's segment option doesn't really help here; see below)
		GSPLIT=$(which gsplit 2>&1)
		if [[ "$GSPLIT" != "/"*"/gsplit" ]] ; then # gsplit not there; your loss
			exit # ALT: continue
		fi

		# calculate DMG's file size
		BYTES=$(/usr/bin/stat -f%z "$TARGET_PARENT/$DMG_NAME")
		MEGABYTES=$(/usr/bin/bc -l <<< "scale=6; $BYTES/1000000")
		if [[ ($MEGABYTES<1) ]] ; then
			DMG_SIZE="0$MEGABYTES"
		else
			DMG_SIZE="$MEGABYTES"
		fi

		# segment DMG with GNU split, if larger than 200 MB
		if [[ ($DMG_SIZE>200) ]] ; then
			SEG_DIR_NAME="${DMG_NAME//.dmg}"
			SEG_DIR="$TARGET_PARENT/$SEG_DIR_NAME~segments"
			mkdir -p "$SEG_DIR"
			notify "Segmenting DMG" "Size is greater than 200 MB"
			SEGMENTING=$("$GSPLIT" -a 3 -d -b 200M "$TARGET_PARENT/$DMG_NAME" "$SEG_DIR/$DMG_NAME".)
			echo "$SEGMENTING"
			if [[ "$SEGMENTING" != "" ]] ; then
				notify "DMG segmentation error" "$DMG_NAME"
			else
				notify "DMG segmentation complete" "$DMG_NAME"
			fi

			# alternate hdiutil commands for splitting:
			# only for "pw" method: (echo "$PASSPHRASE"; echo "$PASSPHRASE") | /usr/bin/hdiutil segment -o "$SEG_DIR/$DMG_NAME" -segmentSize 200M "$TARGET_PARENT/$DMG_NAME"
			# only for non-encrypted dmg: /usr/bin/hdiutil segment -o "$SEG_DIR/$DMG_NAME" -segmentSize 200M "$TARGET_PARENT/$DMG_NAME"
			# on DMGs encrypted with a public key ("key" & "all" method) hdiutil's segment option can only be used, if at least one of the public keys derives from a certificate with the private key in the user's keychain

		fi
	fi

fi

done

exit # ALT: [delete]