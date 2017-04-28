### Aceptar Tarea

* [Aceptar asignación de la tarea]()

### Forma de trabajo

* Use su portátil o su cuenta en c9 para llevar a cabo los objetivos planteados.
* Esta práctica se divide en objetivos o hitos:  indique al profesor  cuando ha terminado y suba los enlaces a los repos y despliegues.

### Reglas

```
start               -> comma
comma               -> assign (',' assign)*
assign              -> id '=' assign / conditional / comparison / function_definition
conditional         -> IF comparison THEN comparison ELSE comparison
comparison          -> additive COMPARISON additive / additive
additive            -> multiplicative (ADDOP multiplicative)*
multiplicative      -> primary (MULOP primary)*
function_definition -> '->' '(' (ID (',' ID)*)? ')' [,^\n]*
primary             -> integer / function_call / ID / '(' comma ')'
function_call       -> ID '(' (primary (',' primary)*)? ')'
```

### Descripción

Este es el PEG de partida::

```
start
  = assign

assign
  = ID ASSIGN additive
  / additive

additive
  = multiplicative (ADDOP multiplicative)*
  / multiplicative

multiplicative
  = primary (MULOP primary)*
  / primary

primary
  = integer
  / ID
  / LEFTPAR assign RIGHTPAR

integer "integer"
  = NUMBER

_ = $[ \t\n\r]*

ADDOP = PLUS / MINUS
MULOP = MULT / DIV
PLUS = _"+"_
MINUS = _"-"_
MULT = _"*"_
DIV = _"/"_
LEFTPAR = _"("_
RIGHTPAR = _")"_
NUMBER = _ $[0-9]+ _
ID = _ $([a-z_]i$([a-z0-9_]i*)) _
ASSIGN = _ '=' _
```

### Hitos

1. Añada múltiples expresiones separadas por comas:  `2*3, 4+5+2, 8-1`
3. Añada los operadores de comparación: `a = 4, b = a < 5, c = a >= 4, d = a ==  4`
  - Cualquier número distinto de cero se considera verdadero
  - El cero es falso
4. Añada constantes `true` y `false` a su lenguaje que se asimilan a los valores 0 y 1. Dado que son constantes no pueden ser modificadas.
  - Ejemplo:  `a = true, c = (5 < 5) == false`
  - Esta operación debería dar un error o no efectuarse:  `true = 0`
5. Añada expresiones condicionales:  `d = if 2<a then b else c`  
6. Añada funciones y llamadas a funciones
7. Modifique las pruebas para que comprueben el buen funcionamiento de su código
8. Su fichero `README.md` debe contener su gramática final.
2. Modifique las pruebas para que comprueben el buen funcionamiento de su código
4. Modifique las pruebas para que funcionen

### Recursos

* [PEGs](https://casianorodriguezleon.gitbooks.io/ull-esit-1617/content/apuntes/pegjs/PEGS.html)
* [Repo con una solución a un lenguaje similar](https://github.com/ULL-ESIT-PL-1617/pegjs-calc-assign)
* [Mocha](https://casianorodriguezleon.gitbooks.io/ull-esit-1617/content/apuntes/pruebas/mocha.html)
* [Chai](https://casianorodriguezleon.gitbooks.io/ull-esit-1617/content/apuntes/pruebas/chai.html)
* [Covering](https://casianorodriguezleon.gitbooks.io/ull-esit-1617/content/apuntes/pruebas/covering.html)
* [Blanket](https://casianorodriguezleon.gitbooks.io/ull-esit-1617/content/apuntes/pruebas/blanket.html)
* [Repo con la solución](https://github.com/ULL-ESIT-PL-1617/solution-evalua-pdr)
