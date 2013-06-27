# Scanner 

## Termin
Abgabe spätestens am 17. April 2013, 14 Uhr.

## Angabe
Schreiben Sie mit `flex` einen Scanner, der Identifier, Zahlen, und folgende Schlüsselwörter unterscheiden kann: `end array of int return if then else while do var not or`. Weiters soll er auch noch folgende Lexeme erkennen: `; ( ) , : := < # [ ] - + *`  
Identifier bestehen aus Buchstaben und Ziffern, dürfen aber nicht mit Ziffern beginnen. Zahlen sind entweder Hexadezimalzahlen oder Dezimalzahlen. Hexadezimalzahlen beginnen mit `$`, gefolgt von einer oder mehr Hexadezimalziffern, wobei Hex-Ziffern sowohl groß als auch klein geschrieben sein dürfen. Dezimalzahlen bestehen aus einer oder mehr Dezimalziffern. Leerzeichen, Tabs und Newlines zwischen den Lexemen sind erlaubt und werden ignoriert, ebenso Kommentare, die mit `--` anfangen und bis zum Ende der Zeile gehen; Kommentare können also nicht geschachtelt werden). Alles andere sind lexikalische Fehler. Es soll jeweils das läangste mögliche Lexem erkannt werden, `if39` ist also ein Identifier (longest input match), `39if` ist die Zahl 39 gefolgt vom Schlüusselwort `if`.  
Der Scanner soll für jedes Lexem eine Zeile ausgeben: für Schlüsselwörter und Lexeme aus Sonderzeichen soll das Lexem ausgegeben werden, für Identifier `id` gefolgt von einem Leerzeichen und dem String des Identifiers, für Zahlen `num` gefolgt von einem Leerzeichen und der Zahl in Hexadezimaldarstellung ohne prefix oder führende Nullen. Für Leerzeichen, Tabs, Newlines und Kommentare soll nichts ausgegeben werden (auch keine Leerzeile).  
Der Scanner soll zwischen Groß- und Kleinbuchstaben unterscheiden, `End` ist also kein Schlüsselwort.

## Abgabe
Legen Sie ein Verzeichnis `~/abgabe/scanner` an, in das Sie die maßgeblichen Dateien stellen. Mittels `make clean` soll man alle von Werkzeugen erzeugten Dateien löschen können (auch den ausführbaren Scanner) und mittels `make` ein Programm namens scanner erzeugen, das von der Standardeingabe liest und auf die Standardausgabe ausgibt. Korrekte Eingaben sollen akzeptiert werden (Ausstieg mit Status 0, z. B. mit `exit(0)`), bei einem lexikalischen Fehler soll der Fehlerstatus 1 erzeugt werden. Bei einem lexikalischen Fehler darf der Scanner Beliebiges ausgeben (eine sinnvolle Fehlermeldung hilft bei der Fehlersuche).

## Hinweis
Die `lex`-Notation `$` steht für ein ein Zeilenende, auf das ein Newline folgt; zusätzlich kann auch noch das Ende der Eingabe die Zeile (und damit einen Kommentar) beenden. Am einfachsten ist es, nur zu spezifizieren, was ein Kommentar ist, und es dem longest input match zu überlassen, den Kommentar nicht zu früh abzubrechen.
