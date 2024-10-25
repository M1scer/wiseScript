# Wise unterstützt inzwischen Daueraufträge von CHF nach EUR. Script wird daher nicht mehr benötigt.

# wiseScript
Script um eine Transaktion über die Wise API auszuführen.


## Beschreibung
Das Script erstellt eine neue Zahlung über die API. In meinem Fall wird das einmal im Monat als Cronjob auf meinem Server ausgeführt um einen Dauerauftrag ausführen zu können.
Auf Wise ist es nämlich nicht möglich CHF Daueraufträge zu erstellen.

## How-To
- Im ersten Teil des Scriptes die Variablen entsprechend den eigenen Bedürfnissen anpassen. Dazu Kommentare im Script beachten.
- Script ausführbar machen -> `chmod +x`
- Ausführen und Betrag mitgeben: `.wiseTransaction.sh 2000` -> Erstellt einen 2000 CHF Auftrag.

## Vorraussetzung
- Linux System (keine Ahnung ob das auch mit Windows laufen würde)
- `curl`, `jq`, `uuid-runtime` müssen installiert sein.
