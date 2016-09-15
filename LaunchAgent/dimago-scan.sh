#!/bin/bash

# DiMaGo
# dimago-scan.sh v1.0.1

LANG=en_US.UTF-8
export PATH=/usr/local/bin:$PATH

PREFS="local.lcars.dimago"

ACCOUNT=$(/usr/bin/id -un)
if [[ "$ACCOUNT" == "root" ]] ; then
	MAIN_ACCOUNT=$(/usr/bin/defaults read "$PREFS" userAccount 2>/dev/null)
	if [[ "$MAIN_ACCOUNT" != "root" ]] ; then
		echo "Process running with root privileges"
		echo "Exiting..."
		exit 1
	fi
fi

FIRST_RUN=$(/usr/bin/defaults read "$PREFS" localIDCreate 2>/dev/null)
if [[ "$FIRST_RUN" != "1" ]] ; then
	echo "DiMaGo Base Identity creation record not found"
	echo "Please run the main DiMaGo workflow first"
	echo "Exiting..."
	exit 1
fi

CACHE_DIR="${HOME}/Library/Caches/local.lcars.dimago"
DB_LOC="$CACHE_DIR/DiMaGo.db"
if [[ ! -f "$DB_LOC" ]] ; then
	echo "DiMaGo database not found"
	echo "Please run the main DiMaGo workflow first"
	echo "Exiting..."
	exit 1
fi

LOGLOC="${HOME}/Library/Logs/DiMaGoScanner.log"
if [[ ! -f "$LOGLOC" ]] ; then
	echo "Creating log file..."
	touch "$LOGLOC"
else
	echo "Log file detected"
fi

CURRENT_DATE=$(/bin/date)
echo "DiMaGo [$ACCOUNT] automated scan: starting..."
echo "$CURRENT_DATE"
/usr/bin/logger -i -s -t DiMaGoScanner "DiMaGo [$ACCOUNT] automated scan: starting..." 2>> "$LOGLOC"

CURRENT_YEAR=$(/bin/date +%Y)

# scan for valid public S/MIME keys
POSIX_DATE=$(/bin/date +%s)
echo "POSIX: $POSIX_DATE"
echo "Scanning for valid public S/MIME keys..."
/usr/bin/defaults write "$PREFS" pkScan "$POSIX_DATE"
DIMAGO_LADDR=$(/usr/bin/defaults read local.lcars.dimago localID 2>/dev/null)
if [[ "$DIMAGO_LADDR" == "" ]] ; then
	echo "No DiMaGo Base Identity address detected"
	echo "Please try again by using the main DiMaGo workflow"
	echo "Exiting..."
	exit 1
fi
/usr/bin/sqlite3 "$DB_LOC" "DELETE FROM PublicKeys WHERE ROWID > -1;"
ALL_CERTS=$(/usr/bin/security find-certificate -a -p)
RECORD=""
echo "$ALL_CERTS" | while IFS= read -r LINE
do
	RECORD="$RECORD
$LINE"
	if [[ $(echo "$RECORD" | /usr/bin/grep "END CERTIFICATE") != "" ]] ; then
		RECORD=$(echo "$RECORD" | /usr/bin/sed '1d')
		PURPOSE_ALL=$(echo "$RECORD" | /usr/bin/openssl x509 -inform PEM -noout -purpose)
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
		CERT_MAIL=$(echo "$RECORD" | /usr/bin/openssl x509 -inform PEM -noout -email)
		if [[ "$CERT_MAIL" == "" ]] ; then
			RECORD=""
			continue
		elif [[ "$CERT_MAIL" != *"@"*"."* ]] ; then
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
		else
			UNTIL=$(echo "$RECORD" | /usr/bin/openssl x509 -inform PEM -noout -enddate 2>/dev/null | /usr/bin/awk -F"=" '{print $2}')
			if [[ "$UNTIL" == "" ]] ; then
				EXP_DATE=""
			else
				YEAR=$(echo "$UNTIL" | /usr/bin/awk '{print $4}' | xargs)
				if [[ "$YEAR" == "$CURRENT_YEAR" ]] ; then
					MONTH=$(echo "$UNTIL" | /usr/bin/awk '{print $1}' | xargs)
					DAY=$(echo "$UNTIL" | /usr/bin/awk '{print $2}' | xargs)
					EXP_DATE="$DAY $MONTH $YEAR"
					echo "Public key of $CERT_MAIL will expire this year: $EXP_DATE"
				else
					EXP_DATE=""
				fi
			fi
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
		echo "Found $CERT_CN with address $CERT_MAIL and SKID $SKID"
		/usr/bin/sqlite3 "$DB_LOC" "insert into PublicKeys (address,name,skid,expires) values (\"$CERT_MAIL\",\"$CERT_CN\",\"$SKID\",\"$EXP_DATE\");"
		RECORD=""
	fi
done

# scan for valid S/MIME identities
POSIX_DATE=$(/bin/date +%s)
echo "POSIX: $POSIX_DATE"
echo "Scanning for valid S/MIME identities..."
/usr/bin/defaults write "$PREFS" idScan "$POSIX_DATE"
/usr/bin/sqlite3 "$DB_LOC" "DELETE FROM Identities WHERE ROWID > -1;"
ID_LIST=$(/usr/bin/security find-identity -v -p smime)
echo "$ID_LIST" | while IFS= read -r IDENT
do
	HASH=$(echo "$IDENT" | /usr/bin/awk '{print $2}')
	NAME=$(echo "$IDENT" | /usr/bin/awk -F\" '{print $2}')
	ALL_CERTS=$(/usr/bin/security find-certificate -c "$NAME" -a -p -Z)
	COLLECT="false"
	RECORD=""
	echo "$ALL_CERTS" | while IFS= read -r LINE
	do
		SHAGREP=$(echo "$LINE" | /usr/bin/grep "SHA-1 hash:")
		if [[ "$SHAGREP" != "" ]] ; then
			CURRENT_HASH=$(echo "$SHAGREP" | /usr/bin/awk -F": " '{print $2}')
			if [[ "$CURRENT_HASH" == "$HASH" ]] ; then
				COLLECT="true"
			else
				COLLECT="false"
			fi
		fi
		if [[ "$COLLECT" == "true" ]] ; then
			RECORD="$RECORD
$LINE"
			if [[ $(echo "$RECORD" | /usr/bin/grep "END CERTIFICATE") != "" ]] ; then
				RECORD=$(echo "$RECORD" | /usr/bin/sed '2d')
				CERT_MAIL=$(echo "$RECORD" | /usr/bin/openssl x509 -inform PEM -noout -email)
				if [[ "$CERT_MAIL" == "" ]] ; then
					RECORD=""
					continue
				elif [[ "$CERT_MAIL" != *"@"*"."* ]] ; then
					RECORD=""
					continue
				fi
				PURPOSE_ALL=$(echo "$RECORD" | /usr/bin/openssl x509 -inform PEM -noout -purpose)
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
				EXPIRES=$(echo "$RECORD" | /usr/bin/openssl x509 -inform PEM -checkend 3600)
				if [[ "$EXPIRES" == "Certificate will expire" ]] ; then
					RECORD=""
					continue
				else
					UNTIL=$(echo "$RECORD" | /usr/bin/openssl x509 -inform PEM -noout -enddate 2>/dev/null | /usr/bin/awk -F"=" '{print $2}')
					if [[ "$UNTIL" == "" ]] ; then
						EXP_DATE=""
					else
						YEAR=$(echo "$UNTIL" | /usr/bin/awk '{print $4}' | xargs)
						if [[ "$YEAR" == "$CURRENT_YEAR" ]] ; then
							MONTH=$(echo "$UNTIL" | /usr/bin/awk '{print $1}' | xargs)
							DAY=$(echo "$UNTIL" | /usr/bin/awk '{print $2}' | xargs)
							EXP_DATE="$DAY $MONTH $YEAR"
							echo "Identity for $CERT_MAIL will expire this year: $EXP_DATE"
						else
							EXP_DATE=""
						fi
					fi
				fi
				SKID=$(echo "$RECORD" | /usr/bin/openssl x509 -inform PEM -noout -text | /usr/bin/grep -A1 "Subject Key Identifier" | /usr/bin/tail -1 | xargs | /usr/bin/sed s/://g)
				if [[ "$SKID" == "" ]] ; then
					RECORD=""
					continue
				fi
				if [[ "$NAME" == "DiMaGo Base Identity"* ]] ; then
					NAME="$ACCOUNT"
				else
					if [[ "$NAME" == "" ]] ; then
						NAME="n/a"
					fi
				fi
				echo "Found $NAME with address $CERT_MAIL and SKID $SKID"
				/usr/bin/sqlite3 "$DB_LOC" "insert into Identities (address,name,skid,expires) values (\"$CERT_MAIL\",\"$NAME\",\"$SKID\",\"$EXP_DATE\");"
				RECORD=""
			fi
		fi
	done
done

CURRENT_DATE=$(/bin/date)
echo "DiMaGo [$ACCOUNT] automated scan: finished"
echo "$CURRENT_DATE"
/usr/bin/logger -i -s -t DiMaGoScanner "DiMaGo [$ACCOUNT] automated scan: finished" 2>> "$LOGLOC"

exit
