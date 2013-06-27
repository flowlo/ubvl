# Assembler B

## Termin
Abgabe spätestens am 10. April 2013, 14 Uhr.

## Angabe
Gegeben ist folgende C-Funktion:

```c
#include <stddef.h>
size_t asmb(char *s, size_t n)
{
  size_t c=0;
  size_t i;
  for (i=0; i<n; i++) {
    if (s[i]==’ ’)
      c++;
  }
  return c;
}
````

Schreiben Sie diese Funktion in Assembler unter Verwendung von `pcmpeqb`.
Sie dürfen dabei annehmen, dass hinter dem letzten Zeichen von `s` noch 16 Bytes zugreifbar sind.
Für besonders effiziente Lösungen (gemessen an der Anzahl der _ausgeführten_ Maschinenbefehle; wird ein Befehl _n_ mal ausgeführt, zählt er _n_-fach) gibt es Bonuspunkte.

## Hinweis
Beachten Sie, dass Sie nur dann Punkte bekommen, wenn Ihre Version korrekt ist, also bei jeder zulässigen Eingabe das gleiche Resultat liefert wie das Original. Dadurch können Sie viel mehr verlieren als Sie durch Optimierung gewinnen können, also optimieren Sie im Zweifelsfall lieber weniger als mehr.
Die Vertrautheit mit dem Assembler müssen Sie beim Gespräch am Ende des Semesters beweisen, indem Sie Fragen zum abgegebenen Code beantworten.

## Abgabe
Zum angegebenen Termin stehen im Verzeichnis `~/abgabe/asmb` die maßgeblichen Dateien. Mittels `make clean` soll man alle von Werkzeugen erzeugten Dateien löschen können und `make` soll eine Datei `asmb.o` erzeugen. Diese Datei soll nur die Funktion `asmb` enthalten, keinesfalls main. Diese Funktion soll den Aufrufkonventionen gehorchen und wird bei der Prüfung der abgegebenen Programme mit C-Code zusammengebunden.
