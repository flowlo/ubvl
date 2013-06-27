# Codeerzeugung B

## Termin
Abgabe spätestens am 5. Juni 2013, 14 Uhr.

## Angabe
Erweitern Sie den Compiler aus dem vorigen Beispiel so, dass er folgende Untermenge der statisch korrekten Programme in AMD64-Assemblercode übersetzt: Alle Programme, in denen der Parser keinen Funktionsaufruf ableitet. Programme, die statisch korrekt sind, aber dieser Einschränkung nicht entsprechen, werden bei diesem Beispiel nicht als Testeingaben vorkommen.  
Ein Teil der Sprache wurde schon erklärt, hier der für dieses Beispiel notwendige Zusatz:  
Bools werden nach der Kontrollflussmethode ausgewertet.  
`<` und `#` vergleichen die beiden Ausdrücke als vorzeichenbehaftete Zahlen, wobei `#` auf Ungleichheit prüft (ungleich ergibt ”wahr“, gleich ”falsch“). not hat seine übliche Bedeutung.  
or wertet den ersten `Bterm` aus. Ist das Ergebnis ”wahr“, ist der gesamte Ausdruck ”wahr“. Ist das Ergebnis ”falsch“, dann wird der nächste Ausdruck ausgewertet, usw. Wenn auch der letzte Ausdruck ausgewertet wird, ist sein Ergebnis das Ergebnis des `Bool`.  
Eine `if`-Anweisung wertet zunächst `Bool` aus. Ist das Ergebnis ”wahr“, wird der `then`-Zweig ausgeführt, sonst der `else`-Zweig, falls vorhanden, bzw. nichts.  
Eine `while`-Anweisung wertet `Bool` aus. Ist das Ergebnis ”wahr“, werden die `Stats` zwischen `do` und `end` ausgeführt und danach die `while`-Anweisung von vorne begonnen. Wenn `Bool` ”falsch“ ist, passiert nichts.  
Bei einer Zuweisung wird `Expr` ausgewertet und das Resultat in die Variable bzw. in die vom Arrayzugriff bestimmte Adresse geschrieben.  
Die Variablendefinition speichert den Wert von `Expr` unter dem Namen der Variable.  
Eine `Term`-Anweisung wertet den `Term` aus und macht mit dem Ergebnis nichts (in diesem Beispiel gibt es keine Funktionsaufrufe, daher macht diese Anweisung hier gar nichts).

### Erzeugter Code
Es gelten die gleichen Anforderungen und Einschränkungen wie im vorigen Beispiel.

### Hinweis
Es bringt nichts, für `iburg` Bäume zu bauen, die mehr als eine einfache Anweisung oder einen Vergleich umfassen: die Möglichkeit, durch die Baumgrammatik Knoten zusammenzufassen und so zu optimieren, kann nur auf der Ebene von Ausdrücken und einfachen Anweisungen genutzt werden (ausser man würde die Zwischendarstellung in einer Weise umformen, die zuviel Aufwand für diese LVA ist).  
Auf höherer Ebene ist einfacher, für jede einfache Anweisung einen Baum zu bauen und dann in einem Traversal für jeden dieser Bäume den Labeler und den Reducer aufzurufen.

### Abgabe
Zum angegebenen Termin stehen die maßgeblichen Dateien im Verzeichnis `~/abgabe/codeb`. Mittels `make clean` soll man alle von Werkzeugen erzeugten Dateien löschen können und mittels `make` ein Programm namens codeb erzeugen, das von der Standardeingabe liest und den generierten Code auf die Standardausgabe ausgibt. Bei einem lexikalischen Fehler soll der Fehlerstatus 1 erzeugt werden, bei einem Syntaxfehler Fehlerstatus 2, bei anderen Fehlern der Fehlerstatus 3. Im Fall eines Fehlers darf die Ausgabe beliebig sein.
