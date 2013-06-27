# Attributierte Grammatik

## Termin
Abgabe spätestens am 8. Mai 2013, 14 Uhr.

## Angabe
Erweitern Sie den Parser aus dem letzten Beispiel mit Hilfe von `ox` um eine Symboltabelle und eine statische Analyse.
Die _hervorgehobenen_ Begriffe beziehen sich auf Kommentare in der Grammatik.

### Namen
Die folgenden Dinge haben Namen: Funktionen und Variablen.
Eine Funktion wird im _Funktionsaufruf_ verwendet und in der _Funktionsdefinition_ definiert. Verwendete Funktionen müssen nicht definiert werden <sup>3</sup> und können nicht deklariert werden. Funktionen dürfen, soweit es den Compiler betrifft, doppelt definiert werden und dürfen den gleichen Namen wie Variablen oder Labels haben; daher muss der Compiler Funktionsnamen nicht in einer Symboltabelle verwalten. Auch die Übereinstimmung der Anzahl der Argumente soll (und kann) der Compiler nicht überprüfen.
Alle Namen (`id`s), die in einer _Parameterdefinition_ oder in einer _Variablendefinition_ vorkommen, sind Variablennamen. Variablen, die in einer Parameterdefinition definiert wurden, sind in der ganzen Funktion sichtbar.
Variablen, die einer Variablendefinition definiert wurden, sind in allen folgenden Statements der unmittelbar umgebenden `Stats` sichtbar, und nirgendwo sonst. In der Definition ist die Variable noch nicht sichtbar.
Bei einer Variablenverwendung muss eine Variable oder ein Parameter mit dem Namen sichtbar sein; und zwar sieht die Verwendung bei mehreren möglichen Definitionen jeweils die nächste Definition (wo also von den `Stats` der Definition bis zur Verwendung am wenigsten Ableitungen gebraucht werden).
Zwei Parameter dürfen nicht den gleichen Namen haben.

### Typen
Die Sprache hat ein einfaches Typsystem. Der Typ einer Variable ist entweder ein int, ein Array von ints, ein Array von Arrays von ints etc. In den Testfällen werden nicht mehr als 100 Verschachtelungsebenen vorkommen.
Ein num ist ein int.
Die Operanden von `- + *` müssen beides Ints sein, und das Ergebnis ist ein Int.
Die Operanden von `< #` müssen beides Ints sein. Eine darüber hinausgehende Typprüfung braucht man bei `BTerm` und `Bool` nicht durchführen, da schon die Grammatik genau die erlaubten Kombinationen abdeckt.
Der `Term` bei einem _Arrayzugriff_ muss ein Array sein, und der Typ des Ergebnisses hat eine Verschachtelungsebene weniger. Die `Expr` bei einem _Arrayzugriff_ muss ein Int sein.
Bei einer Zuweisung muss `Lexpr` den gleichen Typ haben wie `Expr`; bei einer Variablendefinition muss `Expr` den Typ der Variable haben. Der Typ einer Variablenverwendung ist der Typ der Variablen.
Der Typ eines Funktionsaufrufs ist beim Funktionsaufruf angegeben; die Parameter des Funktionsaufrufs sollen nicht überprüft werden.

## Hinweise
Es ist empfehlenswert, die Grammatik so umzuformen, dass sie für die AG günstig ist: Fälle, die syntaktisch gleich ausschauen, aber bei den Attributierungsregeln verschieden behandelt werden müssen, sollten auf verschiedene Regeln aufgeteilt werden; umgekehrt sollten Duplizierungen, die in dem Bemühen vorgenommen wurden, Konflikte zu vermeiden, auf ihre Sinnhaftigkeit überprüft und ggf. rückgängig gemacht werden. Testen Sie Ihre Grammatikumformungen mit den Testfällen.
Offenbar übersehen viele Leute, dass attributierte Grammatiken Information auch von rechts nach links (im Ableitungsbaum) weitergeben können. Sie denken sich dann recht komplizierte Lösungen aus. Dabei reichen die von ox zur Verfügung gestellten Möglichkeiten vollkommen aus, um zu einer relativ einfachen Lösung zu kommen. Heuer sind diese Möglichkeiten zwar für das AG-Beispiel wohl nicht nötig, aber behalten Sie sie für spätere Beispiele im Hinterkopf.
Verwenden Sie keine globalen Variablen oder Funktionen mit Seiteneffekten (z.B. Funktionen, die übergebene Datenstrukturen ändern) bei der Attributberechnung! `ox` macht globale Variablen einerseits unnötig, andererseits auch fast unbenutzbar, da die Ausführungsreihenfolge der Attributberechnung nicht vollständig festgelegt ist. Bei Traversals ist die Reihenfolge festgelegt, und Sie können globale Variablen verwenden; seien Sie aber trotzdem vorsichtig.
Sie brauchen angeforderten Speicher (z. B. für Symboltabellen-Einträge oder Typinformation) nicht freigeben, die Testprogramme sind nicht so groß, dass der Speicher ausgeht (zumindest wenn Sie’s nicht übertreiben).
Das Werkzeug Torero (http://www.complang.tuwien.ac.at/torero/) ist dazu gedacht, bei der Erstellung von attributierten Grammatiken zu helfen.

## Abgabe
Zum angegebenen Termin stehen die maßgeblichen Dateien im Verzeichnis `~/abgabe/ag`. Mittels `make clean` soll man alle von Werkzeugen erzeugten Dateien löschen können und mittels `make` ein Programm namens `ag` erzeugen, das von der Standardeingabe liest. Korrekte Programme sollen akzeptiert werden, bei einem lexikalischen Fehler soll der Fehlerstatus 1 erzeugt werden, bei Syntaxfehlern der Fehlerstatus 2, bei anderen Fehlern (z.B. Verwendung eines nicht sichtbaren Namens) der Fehlerstatus 3. Die Ausgabe kann beliebig sein, auch bei korrekter Eingabe.

<hr width="20%">

<sup>3</sup>: Im Sinne von C: Die Definition einer Funktion enthält den vollständigen Code. Die Deklaration enthält nur die Informationen, die der Compiler braucht, um eine Typüberprüfung des Aufrufs durchzuführen (in C auch bekannt als Prototyp, in anderen Sprachen oft als Signatur).
