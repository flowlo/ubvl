# Gesamtbeispiel

## Termin
Abgabe spätestens am 19. Juni 2013, 14 Uhr.
Es gibt nur einen Nachtermin. Wenn Sie sich für ein Abschlussgespräch vor dem Nachtermin anmelden, wird für die Note nur das Ergebnis des ersten Abgabetermins berücksichtigt.


## Angabe
Erweitern Sie den Compiler aus dem vorigen Beispiel so, dass er alle statisch korrekten Programme in AMD64-Assemblercode übersetzt.  
Ein Teil der Sprache wurde schon erklärt, hier der für dieses Beispiel notwendige Zusatz:  
Der _Funktionsaufruf_ wertet alle `Expr`s aus und ruft dann die Funktion `id` auf, mit den Ergebnissen der Terme als Parameter. Der von der Funktion zurückgegebene Wert ist der Wert des Funktionsaufrufs.

### Erzeugter Code
Der erzeugte Code ruft Funktionen entsprechend den Aufrufkonventionen auf. Ansonsten gelten die gleichen Anforderungen und Einschränkungen wie im vorigen Beispiel, wobei ein Funktionsaufruf mit _n_ Parametern bei der Berechnung der Tiefe mit dem Wert _max(0, n − 1)_ (zuzüglich der maximalen Tiefe der Berechnungen der Parameter) eingeht.  
Wichtigstes Kriterium ist wie immer die Korrektheit, für gute Codeerzeugung gibt es aber wieder Sonderpunkte. Wir empfehlen, nur Optimierungen durchzuführen, die mit den verwendeten Werkzeugen einfach möglich sind.
Bei diesem Beispiel kommt es mehr auf gute Registerbelegung an als auf die Optimierung von Ausdrücken.

## Hinweise
Bei der Registerbelegung gibt es sowohl ein großes Optimierungspotential als auch ein großes Fehlerpotential, besonders im Zusammenhang mit (verschachtelten) Funktionsaufrufen.  
Eine einfache Strategie bezüglich der Parameter der aktuellen Funktion ist, sie nicht in den Argumentregistern zu lassen, sondern sie z.B. auf den Stack zu kopieren, damit man beim Berechnen der Parameter einer anderen Funktion problemlos auf sie zugreifen kann. Diese Strategie mag zwar nicht zum optimalen Code führen, aber eine gute Regel beim Programmieren lautet: "First make it work, then make it fast".

## Abgabe
Zum angegebenen Termin stehen die maßgeblichen Dateien im Verzeichnis `~/abgabe/gesamt`. Mittels `make clean` soll man alle von Werkzeugen erzeugten Dateien löschen können und mittels `make` ein Programm namens `gesamt` erzeugen, das von der Standardeingabe liest und auf die Standardausgabe ausgibt. Bei einem lexikalischen Fehler soll der Fehlerstatus 1 erzeugt werden, bei einem Syntaxfehler Fehlerstatus 2, bei anderen Fehlern der Fehlerstatus 3.
Im Fall eines Fehlers kann die Ausgabe beliebig sein. Der ausgegebene Code muss vom Assembler verarbeitet werden können.
