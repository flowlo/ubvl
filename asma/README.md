# Assembler A

## Termin
Abgabe spätestens am 20. März 2013, 14 Uhr.

## Angabe
Gegeben ist folgende C-Funktion:

```c
int asma(char *s) {
    int c = 0;
    int i;
    
    for (i = 0; i < 16; i++)
        if (s[i] == ' ')
            c++;
    
    return c;
}
```

Schreiben Sie diese Funktion in Assembler unter Verwendung von `pcmpeqb`. Zusätzlich dürften die Befehle `popcnt` und `pmovmskb` <sup>2</sup> nutzlich sein. Dabei zählt der Befehl `POPCNT r/m64, reg64` die Anzahl der Bits im Quelloperanden und speichert sie im Zieloperanden.  
Am einfachsten tun Sie sich dabei wahrscheinlich, wenn Sie eine einfache C-Funktion wie

```c
void asma(unsigned long x[])
{
    return 1;
}
```

mit z. B. `gcc -O -S` in Assembler ubersetzen und sie dann verändern. Dann stimmt schon das ganze Drumherum. Die Originalfunktion auf diese Weise zu übersetzen ist auch recht lehrreich, aber vor allem, um zu sehen, wie man es nicht machen soll.

## Hinweis
Beachten Sie, dass Sie nur dann Punkte bekommen, wenn Ihre Version `pcmpeqb` verwendet und korrekt ist, also bei gleicher (zulässiger) Eingabe das gleiche Resultat liefert wie das Original.  
Zum Assemblieren und Linken verwendet man am besten `gcc`, der Compiler-Treiber kümmert sich dann um die richtigen Optionen für `as` und `ld`.

## Abgabe
Zum angegebenen Termin stehen im Verzeichnis `~/abgabe/asma` die maßgeblichen Dateien. Mittels `make clean` soll man alle von Werkzeugen erzeugten
Dateien löschen können und `make` soll eine Datei `asma.o` erzeugen. Diese Datei soll nur die Funktion `asma` enthalten, keinesfalls `main`. Diese Funktion soll den Aufrufkonventionen gehorchen und wird bei der Prüfung der abgegebenen Programme mit C-Code zusammengebunden.

<hr width="20%">

<sup>2</sup>: Wenn Sie eine ältere Version unseres AMD64-Handbuchs benutzen: Die AT&T-Syntax ist `PMOVMSKB xmm, reg32`.
