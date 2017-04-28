/*
 * Classic example grammar, which recognizes simple arithmetic expressions like
 * "2*(3+4)". The parser generated from this grammar then computes their value.
 */
{
  var util = require('util');
  var constantSymbols = new Set(["pi", "true", "false"])
  var symbolTable = {
    PI: Math.PI,
    true: 1,
    false: 0
  };
}

start
  = a:comma {
             return {symbolTable: symbolTable, result: a}
           }

comma
  = left:assign right:(COMMA assign)* {
        return (right.length > 0) ? right[right.length - 1][1] : left;
    }

assign
  = id:ID ASSIGN a:assign {
         if (constantSymbols.has(id.toLowerCase()))
            throw "Cant override value of constant " + id.toLowerCase();
         symbolTable[id] = a;
         return a;
      }
  / conditional
  / comparison
  / function_definition

conditional
  = IF cond:comparison THEN actionsif:comparison ELSE actionselse:comparison {
    return cond ? actionsif : actionselse;
  }

comparison
  = left:additive comp:COMPARISON right:additive {
    let boolean = false;
    eval(`boolean = ${left} ${comp[1]}${comp[2]} ${right}`)
    return boolean;
  } / additive

additive
  = left:multiplicative rest:(ADDOP multiplicative)* {
       let sum = left;
       rest.forEach( (x) => {
         eval(`sum ${x[0]}= ${x[1]}`);
       });
       return sum;
    }
  / multiplicative

function_definition
  = DEFINITION LEFTPAR params:(ID (COMMA ID)*)? RIGHTPAR code:[^,\n]* {
        let params_array = [];
        if (params) {
          params_array.push(params[0])
          params[1].forEach((x) => {
            params_array.push(x[1]);
          });
        }
        return {
          params: params_array,
          code: code.join("")
        }
  }

multiplicative
  = left:primary rest:(MULOP primary)* {
      return rest.reduce((prod, [op, num])=>{ return eval(prod+op+num); },left);
    }
  / primary

primary
  = integer
  / function_call
  / id:ID { if (!symbolTable[id]) { throw id + " not defined"; } return symbolTable[id]; }
  / LEFTPAR assign:comma RIGHTPAR { return assign; }

function_call
  = id:ID LEFTPAR params:(primary (COMMA primary)*) RIGHTPAR {
      let result = undefined;
      let function_def = symbolTable[id];
      let code = "";

      if (params) {
        code += `let ${function_def.params[0]} = ${params[0]};`
        for (let i = 1; i < params[1].length; ++i)
          code += `let ${function_def.params[i]} = ${params[1][i]};`
      }

      eval(code + `result = ` + symbolTable[id].code)
      return result;
    }

integer "integer"
  = NUMBER

_ = $[ \t\n\r]*

ADDOP = PLUS / MINUS
MULOP = MULT / DIV
PLUS  = _"+"_ { return '+'; }
MINUS = _"-"_ { return '-'; }
MULT  = _"*"_ { return '*'; }
DIV   = _"/"_ { return '/'; }
COMPARISON =   _[<>=!]"="_ / _[<>]_
LEFTPAR = _"("_
RIGHTPAR = _")"_
DEFINITION = _"->"_
COMMA = _","_
IF = _"if"_
ELSE = _"else"_
THEN = _"then"_

NUMBER = _ digits:$[0-9]+ _ { return parseInt(digits, 10); }
ID = _ id:$([a-z_]i$([a-z0-9_]i*)) _ { return id; }
ASSIGN = _ '=' _
