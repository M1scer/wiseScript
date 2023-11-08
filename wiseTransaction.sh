#!/bin/bash

########### Variablen ###########
# Einstellungen -> API Token
apiToken="xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx"
# Name des Empfängers
recipientFullName="Vorname Nachname"
# IBAN des Empfängers
recipientIBAN="DE123456789123456789"
# Währung Empfänger (ISO Bezeichnung)
recipientCurrency="EUR"
# Währung Quellkonto (ISO Bezeichnung)
sourceCurrency="CHF"
# Überweisungsbetrag (In der Währung des Quellkonto)
amount=$1
# Verwendungszweck
reference="Dauerauftrag in höhe von (${amount} CHF)"

########### Eigene ID auslesen ##############
# Befehl abschicken
ownProfile=$(curl -s -X GET https://api.transferwise.com/v1/profiles \
     -H "Authorization: Bearer ${apiToken}")

ownProfileId=$( jq -r '.[0]|[.id]|@tsv' <<< "${ownProfile}" )  # [0] = personal, [1] = business

########### Empfänger erstellen ##############
# Erstelle json_string für den POST Befehl
json_string="{
\"currency\": \"${recipientCurrency}\",
\"type\": \"IBAN\",
\"profile\": ${ownProfileId},
\"ownedByCustomer\": false,
\"accountHolderName\": \"${recipientFullName}\",
\"details\": {
  \"legalType\": \"PRIVATE\",
  \"IBAN\": \"${recipientIBAN}\"
  }
}"

# Befehl abschicken
recipient=$(curl -s -X POST https://api.transferwise.com/v1/accounts \
     -H "Authorization: Bearer ${apiToken}" \
     -H "Content-Type: application/json" \
     -d "${json_string}")

########### Angebot erstellen ##############
# Erstelle json_string für den POST Befehl
json_string="{
\"sourceCurrency\": \"${sourceCurrency}\",
\"targetCurrency\": \"${recipientCurrency}\",
\"sourceAmount\": ${amount},
\"targetAccount\": $( jq -r '.id' <<< "${recipient}" ),
\"paymentMetadata\": {
  \"transferNature\": \"MOVING_MONEY_BETWEEN_OWN_ACCOUNTS\"
  }
}"

# Befehl abschicken
quote=$(curl -s -X POST https://api.transferwise.com/v3/profiles/${ownProfileId}/quotes \
     -H "Authorization: Bearer ${apiToken}" \
     -H "Content-Type: application/json" \
     -d "${json_string}")


########### Transfer erstellen ##############
# Erstelle json_string für den POST Befehl
json_string="{
\"targetAccount\": $( jq -r '.id' <<< "${recipient}" ),
\"quoteUuid\": \"$( jq -r '.id' <<< "${quote}" )\",
\"customerTransactionId\": \"$(uuidgen)\",
\"details\": {
  \"reference\": \"${reference}\",
  \"transferPurpose\": \"verification.transfers.purpose.pay.bills\",
  \"transferPurposeSubTransferPurpose\": \"verification.sub.transfers.purpose.pay.interpretation.service\",
  \"sourceOfFunds\": \"verification.source.of.funds.other\"
  }
}"

# Befehl abschicken
transaction=$(curl -s -X POST https://api.transferwise.com/v1/transfers \
     -H "Authorization: Bearer ${apiToken}" \
     -H "Content-Type: application/json" \
     -d "${json_string}")
echo "[$(date +'%d-%m-%Y %H:%M:%S')]: Wise Transfer erstellt: ${amount} ${sourceCurrency} an ${recipientFullName} (${recipientCurrency}) - \"${reference}\""
