/*
 * Classic example grammar, which recognizes simple arithmetic expressions like
 * "2*(3+4)". The parser generated from this grammar then computes their value.
 */
{
  var Parser = this;

  var util = require('util');
  var constantSymbols = new Set(["pi", "true", "false"])
  Parser.symbolTable = Parser.symbolTable || {
    PI: Math.PI,
    true: 1,
    false: 0
  };
  var calcEval = function(input){
    let PEG = require('./arithmetics.js');
    PEG.symbolTable = Parser.symbolTable;
    let result = PEG.parse(input /*, symbolTable */);
    //console.log(util.inspect(result));
    return result;
  };
}

start
  = a:comma {
             console.log(Parser.symbolTable);
             return a;
           }

comma
  = left:assign right:(COMMA assign)* {
        return (right.length > 0) ? right[right.length - 1][1] : left;
    }

assign
  = id:ID ASSIGN a:assign {
         if (constantSymbols.has(id.toLowerCase()))
            throw "Cant override value of constant " + id.toLowerCase();
         Parser.symbolTable[id] = a;
         return a;
      }
  / conditional
  / comparison
  / function_definition

conditional
  = IF cond:comparison THEN actionsif:comma ELSE actionselse:comma {
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
  = DEFINITION LEFTPAR params:(ID (COMMA ID)*)? RIGHTPAR code:$[^,\n]* {
        let params_array = [];
        if (params) {
          params_array.push(params[0])
          params[1].forEach((x) => {
            params_array.push(x[1]);
          });
        }
        console.log(params_array);
        console.log(code);
        return {
          params: params_array,
          code: code
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
  / id:ID { if (!Parser.symbolTable[id]) { throw id + " not defined"; } return Parser.symbolTable[id]; }
  / LEFTPAR assign:comma RIGHTPAR { return assign; }

function_call
  = id:ID LEFTPAR params:params RIGHTPAR {
      let result = 0;
      console.log(params);
      console.log(Parser.symbolTable);
      let function_def = Parser.symbolTable[id];
      let code = "";

      if (params.length > 0) {
        for (let i = 0; i < params.length; ++i) {
          console.log(code);
          code += `${function_def.params[i]} = ${params[i]},\n`
        }
      }

      code += Parser.symbolTable[id].code;
      return calcEval(code);
    }

params = r:(assign COMMA)* p1:assign? {
           if (!p1) return [];
           let params = (r.map(([p,_]) => p)).concat([ p1 ]);
           //console.log(params);
           return params;
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
COMMA = _","_ { return ','; }
IF = _"if"_
ELSE = _"else"_
THEN = _"then"_

NUMBER = _ digits:$[0-9]+ _ { return parseInt(digits, 10); }
ID = _ id:$([a-z_]i$([a-z0-9_]i*)) _ { return id; }
ASSIGN = _ '=' _
