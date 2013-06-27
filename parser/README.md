# Parser

## Termin
Abgabe spätestens am 24. April 2013, 14 Uhr.

## Angabe
Gegeben ist die Grammatik (in `yacc`/`bison`-artiger EBNF):

````
Program: { Funcdef ’;’ }
       ;

Funcdef: id ’(’ Pars ’)’ Stats end /* Funktionsdefinition */
       ;

Pars: [ { Vardef ’,’ } Vardef ] /* Parameterdefinition */
    ;

Vardef: id ’:’ Type
      ;

Type: { array of } int
    ;

Stats: { Stat ’;’ }
     ;

Stat: return Expr
    | if Bool then Stats [ else Stats ] end
    | while Bool do Stats end
    | var Vardef ’:=’ Expr /* Variablendefinition */
    | Lexpr ’:=’ Expr /* Zuweisung */
    | Term
    ;

Bool: Bterm { or Bterm }
    ;

Bterm: ’(’ Bool ’)’
     | not Bterm
     | Expr ( ’<’ | ’#’ ) Expr
     ;

Lexpr: id /* schreibender Variablenzugriff */
     | Term ’[’ Expr ’]’ /* schreibender Arrayzugriff */
     ;

Expr: Term { ’-’ Term }
    | Term { ’+’ Term }
    | Term { ’*’ Term }
    ;

Term: ’(’ Expr ’)’
    | num
    | Term ’[’ Expr ’]’ /* lesender Arrayzugriff */
    | id /* Variablenverwendung */
    | id ’(’ [ { Expr ’,’ } Expr ] ’)’ ’:’ Type /* Funktionsaufruf */
    ;
````

Schreiben Sie einen Parser für diese Sprache mit `flex` und `yacc`/`bison`. Die Lexeme sind die gleichen wie im Scanner-Beispiel (`id` steht für einen Identifier, `num` für eine Zahl). Das Startsymbol ist `Program`.

## Abgabe
Zum angegebenen Termin stehen im Verzeichnis `~/abgabe/parser` die maßgeblichen Dateien. Mittels `make clean` soll man alle von Werkzeugen erzeugten Dateien löschen können und mittels `make` ein Programm namens `parser` erzeugen, das von der Standardeingabe liest. Korrekte Programme sollen akzeptiert werden (Ausstieg mit Status 0, z.B. mit `exit(0)`), bei einem lexikalischen Fehler soll der Fehlerstatus 1 erzeugt werden, bei Syntaxfehlern der Fehlerstatus 2. Das Programm darf auch etwas ausgeben (auch bei korrekter Eingabe), z.B. damit Sie sich beim Debugging leichter tun.

## Hinweis
Die Verwendung von Präzedenzdeklarationen von `yacc` kann leicht zu Fehlern führen, die man nicht so schnell bemerkt (bei dieser Grammatik sind sie sowieso sinnlos). Konflikte in der Grammatik sollten Sie durch Umformen
der Grammatik beseitigen; yacc löst den Konflikt zwar, aber nicht unbedingt in der von Ihnen gewünschten Art.
Links- oder Rechtsrekursion? Also: Soll das rekursive Vorkommen eines Nonterminals als erstes (links) oder als letztes (rechts) auf der rechten Seite der Regel stehen? Bei `yacc`/`bison` und anderen LR-basierten Parsergeneratoren funktioniert beides. Sie sollten sich daher in erster Linie danach richten, was leichter geht, z.B. weil es Konflikte vermeidet oder weil es einfachere Attributierungsregeln erlaubt. Z. B. kann man mittels Linksrekursion bei der Subtraktion einen Parse-Baum erzeugen, der auch dem Auswertungsbaum entspricht. Sollte es keine anderen Gründe geben, kann man der Linksrekur-
sion den Vorzug geben, weil sie mit einer konstanten Tiefe des Parser-Stacks auskommt.
