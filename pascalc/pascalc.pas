program DynamicCalculatorBecauseStaticCalculatorIsBoring;

uses Math, SysUtils;

const
    A = 3; // this is the accuration for decimal points output, change if you need more precision value.
    PossibleInput: Set of Char = ['=', 'd', 'c', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '-', '*', '/', '^', '.', '(', ')']; // lists all the possible input on the program
    Numbers: Set of Char = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']; // lists all the possible input on the program that is considered a number
    Operators: Set Of Char = ['+', '-', '*', '/', '^', '.']; // lists all the possible input on the program that is considered an operator, but in most cases, "." is not really an operator but its fine.

var
    {  variables that are mostly used globally.  }
    i: Integer; // for looping.
    isDone: Boolean; // for chekcing if input is finished.
    finalResultStr: String; // for storing the value of final result, changes everytime because it's used as a parameter in a recursive manner in the "Parse" procedure.

    {  variables that are mostly used in the "Input" procedure.  }
    InputOPcount, InputCPcount : Integer; // Counts how many "Open Parentheses('(')"; and "Closed Parentheses(')')" in a given input.
    InputIsDone, InputIsInputDecimal: Boolean; // Checks for finised doing input; and for checking if a number is decimal or not.
    InputExpressionStr, InputErrorMessage: String; // For storing the value of user's input which once finished will be preserved unlike finalResultStr; and for storing value when user input results in an error.
    InputInputChar, InputLastInputtedChar, InputIsDoneChecker: Char; // for getting the value of user's input; for storing the value of last user's input; and for getting the value on line x.

    {  variables that are mostly used in the "Parse" procedure.  }
    ParseIndexOfFirstOP, ParseIndexOfFirstCP, ParseIndexOfLastCP, ParseLoopNumber, ParseAmountOfOPBeforeFirstCP: Integer;// stores the value of first occuring "("; stores the value of first occuring ")"; stores the value of last occuring ")"; stores the value of how many times "Parse" procedure has been looped; and stores the amount of "(" before first occuring ")".
    ParseExpressionParsed, ParseToCalc: String; // stores the value of parsed expression when theres more than 2 "("s before the first ")" in an equation; and stores the value of parsed expression thats going to be calculated.
    ParseCalcResult: Double; // stores the value of the parsed expression that previously has been calculated.

    {  variables that are mostly used in the "Calc" procedure.  }
    CalcEqCurrently, CalcToCalcInCalc: String; // stores string that we will manipulate to give us the answer, just like ParseExpressionParsed, but instead of parsing parentheses, we are parsing math operations on 2 numbers based on the operation priority (PEMDAS); and for storing the 2 numbers and operators to get calculated. 
    CalcOperatorPriority: Char; // stores the char of the operator based on priority (priority 1: ^, priority 2: * or /, priority 3: + or /)
    CalcResult, CalcCalcInCalcResult: Double; // stores the value to be shown on the final output; and stores the value from the operation of "CalcInCalc(CalcToCalcInCalc)"
    CalcOperatorPriorityIndexLower, CalcOperatorPriorityIndex, CalcOperatorPriorityIndexUpper, CalcNumberOfOperators: Integer; // stores the index of the operator before the main priority operator; stores the index of the main priority operator; stores the index of the operator after the main priority operator; and stores how much operators there is in "CalcEqCurrently".

{  PHASE 3 (the hard part): Actually calculating the previously parsed equations (fun fact: JavaScript has an automated way of doing this, using the same name for the method, which is "Calc()" and doesnt require phase 2 in any way shape or form, crazy isn't it?)  }
procedure Calc(eq: String);
    {  function used to do math operations on 2 numbers  }
    function CalcInCalc(op: String; a,b: Double): Double;
    begin // the example given will have a = 2, and b = 3
        case op of
            '^': begin
                CalcInCalc := Power(a, b);  // input: 2^3; Power(a, b) = 8.
            end;
            '*': begin
                CalcInCalc := a * b; // input: 2*3; a * b = 6.
            end;
            '/': begin
                CalcInCalc := a / b; // input: 2/3; a / b = 0.666...(A times) .
            end;
            '+': begin
                CalcInCalc := a + b; // input: 2+3; a + b = 5.
            end;
            '-': begin
                CalcInCalc := a - b; // input: 2-3; a - b = -1.
            end;
        end;
    end;
    begin
        {  change the value to their default 0 value to avoid misuse of value from previous recursion  }
        CalcEqCurrently := ''; 
        CalcNumberOfOperators := 0;
        CalcOperatorPriority := #0;
        CalcOperatorPriorityIndex := 0;
        CalcOperatorPriorityIndexLower := 0;
        CalcOperatorPriorityIndexUpper := 0;

        {  prune the parentheses for calculating (if theres any)  } 
        if Pos('(', eq) > 0 then CalcEqCurrently := Copy(eq, 2, Length(eq) - 2) 
        else CalcEqCurrently := eq;

        {  find all instance of operators in the equation  }
        for i := 1 to Length(CalcEqCurrently) do
        begin
            if (CalcEqCurrently[i] in Operators) and not (CalcEqCurrently[i] = '.') then 
            begin 
                Inc(CalcNumberOfOperators); // add 1 to the number of operator occurences
                {  make ^ the priority operator and save the index if either the current priority is either empty or not "^"  }
                {  the reason all of the logic has the not logic including themself is that we want to check from left to right, if we exclude themself from the not logic, then if theres another instance of the same operator then the priority operator will switch to them instead, which is not what we wanted.  }
                if ((CalcOperatorPriority = #0) or not (CalcOperatorPriority in ['^'])) and (CalcEqCurrently[i] = '^') then 
                begin
                    CalcOperatorPriority := '^';
                    CalcOperatorPriorityIndex := i;
                end
                {  make * the priority operator and save the index if either the current priority is either empty or not "*, /, or ^"  }
                else if ((CalcOperatorPriority = #0) or not (CalcOperatorPriority in ['*', '/', '^'])) and (CalcEqCurrently[i] = '*') then 
                begin
                    CalcOperatorPriority := '*';
                    CalcOperatorPriorityIndex := i;
                end
                {  make / the priority operator and save the index if either the current priority is either empty or not "*, /, or ^"  }
                else if ((CalcOperatorPriority = #0) or not (CalcOperatorPriority in ['*', '/', '^'])) and (CalcEqCurrently[i] = '/') then 
                begin
                    CalcOperatorPriority := '/';
                    CalcOperatorPriorityIndex := i;
                end
                {  make + the priority operator and save the index if either the current priority is either empty or not "+, -, *, /, or ^"  }
                else if ((CalcOperatorPriority = #0) or not (CalcOperatorPriority in ['+', '-', '*', '/', '^'])) and (CalcEqCurrently[i] = '+') then 
                begin 
                    CalcOperatorPriority := '+';
                    CalcOperatorPriorityIndex := i;
                end
                {  make + the priority operator and save the index if either the current priority is either empty or not "+, -, *, /, or ^"  }
                else if ((CalcOperatorPriority = #0) or not (CalcOperatorPriority in ['+', '-', '*', '/', '^'])) and (CalcEqCurrently[i] = '-') then 
                begin
                    if i = 1 then continue; // we dont want the index 1 "-" to be the operator priority else it will brick.
                    CalcOperatorPriority := '-';   
                    CalcOperatorPriorityIndex := i;   
                end;  
            end;
        end;
        {  when there are more than 1 operators, it means that the equation is not simple enough (because we cant just do a+b+c+..., we would need infinite memory to map out all the possible permutations of operations), hence why we are trying to get all equations to only have 1 operators.  }
        if CalcNumberOfOperators > 1 then
        begin
        // calc priority
        // replace calceqcurrently pf that with tresutl
        // calc(calceqcurrently)

        {  to find the a part of CalcInCalc, we need to find the number between our operator priority and the operator before that, hence we do count down, count down to 2 because we dont want index 1 '-' to result in the '-' itself getting pruned.  }
            for i := CalcOperatorPriorityIndex - 1 downto 2 do
            begin
                {  this is the function to find the operator before the operator priority.  }
                if (CalcEqCurrently[i] in Operators) and not (CalcEqCurrently[i] = '.') then 
                begin
                    CalcOperatorPriorityIndexLower := i + 1; // sets the index to 1 after that operator.
                    break;
                end;
            end;
            if CalcOperatorPriorityIndexLower = 0 then CalcOperatorPriorityIndexLower := 1; // when no operator is found, then set the number's lower limit to 1, it means that the number's length is between 1 and (the index of our operator priority - 1).
        
        {  to find the b part of CalcInCalc, we need to find the number between our operator priority and the max length of the equation, hence we do count up, counting up to max length of the equation starting from our operator priority index + 2 because if we do + 1, if after the operator priority theres a - (e.g. 5*-2) then the number will be between the index of * and 1 before '-', which is none, which will brick the code.  }
            for i := (CalcOperatorPriorityIndex + 2) to Length(CalcEqCurrently) do
            begin
                {  this is the function to find the operator before the operator priority.  }
                if (CalcEqCurrently[i] in Operators) and not (CalcEqCurrently[i] = '.') then 
                begin
                    CalcOperatorPriorityIndexUpper := i - 1; // sets the index to 1 before that operator.
                    break;
                end;
            end;
            if CalcOperatorPriorityIndexUpper = 0 then CalcOperatorPriorityIndexUpper := Length(CalcEqCurrently); // when no operator is found, set the number's upper limit to max length, it means that the number's length is between (the index of our operator + 1) and max length of the equation.
            {  lets try and break up this monstrous variable apart:  
            "CalcInCalc" is a function that wants 3 parameters; parameter 1 being the operator, whilst parameter 2 and 3 is the two numbers that we want to operate on
            -parameter 1: CalcEqCurrently[CalcOperatorPriorityIndex]
            > this just takes the priority operation from the input equation via its index; for example: (5+2-7*4/2) will have the index of operation priority be 6, hence CalcEqCurrently[6] will be the same thing as '*'.
            -parameter 2: StrToFloat(Copy(CalcEqCurrently, CalcOperatorPriorityIndexLower, CalcOperatorPriorityIndex - CalcOperatorPriorityIndexLower))
            > this converts part of our pruned equation to float, the equation is pruned from the (CalcOperatorPriorityIndexLower), with the length of (CalcOperatorPriorityIndex - CalcOperatorPriorityIndexLower), lets take the previous example: (5+2-7*4/2); the index of (CalcOperatorPriorityIndexLower) is 5, hence this parameter will be the same as (StrToFloat(Copy((5+2-7*4/2), 5, 6 - 5))) = StrToFloat(Copy(5+2-7*4/2), 5, 1) = StrToFloat(7)
            -parameter 3: StrToFloat(Copy(CalcEqCurrently, CalcOperatorPriorityIndex + 1, CalcOperatorPriorityIndexUpper - CalcOperatorPriorityIndex))
            same logic as parameter 2, but instead of pruning from bottom to priority operator, we prune from priority operator to top. using the previous example, (CalcOperatorPriorityIndexUpper) will be 7, hence this parameter will be the same thing as (StrToFloat(Copy((5+2-7*4/2), 6 + 1, 7 - 6))) = (StrToFloat(Copy(5+2-7*4/2, 7, 1))) = (StrToFloat(4))
            }
            CalcCalcInCalcResult := CalcInCalc(CalcEqCurrently[CalcOperatorPriorityIndex], StrToFloat(Copy(CalcEqCurrently, CalcOperatorPriorityIndexLower, CalcOperatorPriorityIndex - CalcOperatorPriorityIndexLower)), StrToFloat(Copy(CalcEqCurrently, CalcOperatorPriorityIndex + 1, CalcOperatorPriorityIndexUpper - CalcOperatorPriorityIndex))); // holy yap bro can you sybau ts pmo icl.
            CalcToCalcInCalc := Copy(CalcEqCurrently, CalcOperatorPriorityIndexLower, CalcOperatorPriorityIndexUpper - CalcOperatorPriorityIndexLower + 1); // this grabs the part that need to be pruned on the original equation.
            Insert(FloatToStr(CalcCalcInCalcResult), CalcEqCurrently, Pos(CalcToCalcInCalc, CalcEqCurrently)); // insert the result from "CalcInCalc" to before "CalcToCalcInCalc".
            Delete(CalcEqCurrently, Pos(CalcToCalcInCalc, CalcEqCurrently), Length(CalcToCalcInCalc)); // deletes the CalcToCalcInCalc part from the input equation.
            Calc(CalcEqCurrently); // recurse the Calc() function again using the parameter of the equation post-delete, until theres only 1 operation left in the entire equation.
        end
        {  only 1 operator means that the equation is on its simplest form (e.g. 10-4), this way we can just manually calculate that by setting the "CalcResult" to whatever operator is needed, just like the function "CalcInCalc".  }
        else if (CalcNumberOfOperators = 1) then
        begin
            {  sometimes the one operator is found on the first index (e.g. -27), this is already the base form, hence why we just set the "CalcResult" to that.  }
            if Pos('-', CalcEqCurrently) = 1 then 
            begin
                CalcResult := StrToFloat(CalcEqCurrently);
                Exit;
            end;
            case CalcOperatorPriority of
            {  this part is self explanatory;  lets take '^' as an example
            - We are trying to set CalcResult to the value of a (operation) b
            power(a,b) takes 2 params; a being base and b being exponent
            - parameter 1: StrToFloat(Copy(CalcEqCurrently, 1, Pos('^', CalcEqCurrently) - 1))
            > this prunes from the leftmost character until 1 before the operation index, so for example 53^275, parameter 1 will be 53
            - parameter 2: StrToFloat(Copy(CalcEqCurrently, Pos('^', CalcEqCurrently) + 1, Length(CalcEqCurrently) - Pos('^', CalcEqCurrently)))
            > this prunes from the 1 over the operation index until the max length, so with parameter 1's example, the second parameter will be 275
            
            all the 4 other operations follow the same logic, with the only thing differing them are the operations itself.}
            '^': CalcResult := power(StrToFloat(Copy(CalcEqCurrently, 1, Pos('^', CalcEqCurrently) - 1)), StrToFloat(Copy(CalcEqCurrently, Pos('^', CalcEqCurrently) + 1, Length(CalcEqCurrently) - Pos('^', CalcEqCurrently))));
            '*': CalcResult := StrToFloat(Copy(CalcEqCurrently, 1, Pos('*', CalcEqCurrently) - 1)) * StrToFloat(Copy(CalcEqCurrently, Pos('*', CalcEqCurrently) + 1, Length(CalcEqCurrently) - Pos('*', CalcEqCurrently)));
            '/': CalcResult := StrToFloat(Copy(CalcEqCurrently, 1, Pos('/', CalcEqCurrently) - 1)) / StrToFloat(Copy(CalcEqCurrently, Pos('/', CalcEqCurrently) + 1, Length(CalcEqCurrently) - Pos('/', CalcEqCurrently)));
            '+': CalcResult := StrToFloat(Copy(CalcEqCurrently, 1, Pos('+', CalcEqCurrently) - 1)) + StrToFloat(Copy(CalcEqCurrently, Pos('+', CalcEqCurrently) + 1, Length(CalcEqCurrently) - Pos('+', CalcEqCurrently)));
            '-': CalcResult := StrToFloat(Copy(CalcEqCurrently, 1, Pos('-', CalcEqCurrently) - 1)) - StrToFloat(Copy(CalcEqCurrently, Pos('-', CalcEqCurrently) + 1, Length(CalcEqCurrently) - Pos('-', CalcEqCurrently)));
            end;
        end
        {  no operators means that the equation is only on its 1 number form (e.g. 5) and cannot be simplified furthermore.  }
        else if CalcNumberOfOperators = 0 then CalcResult := StrToFloat(CalcEqCurrently); 
    end;
{  END OF PHASE 3  }

{  PHASE 2: Parse user's equation input from the very deepest (of parentheses)  }
procedure Parse(eq: String); // this procedure grabs the parameter of eq, which will then be assigned to "finalResultStr"
    begin
        ParseIndexOfFirstOP := 0;  // stores the index of the first occuring "(".
        ParseIndexOfFirstCP := 0; // stores the index of the first occuring ")".
        ParseIndexOfLastCP := 0; // stores the inxed of the last occuring "(".
        ParseAmountOfOPBeforeFirstCP := 0; // stores the number of times "(" shows up before the first ")" shows up (will be important later).

        {  shows how much iteration of this procedure  }
        writeln;
        writeln('loop number: ', ParseLoopNumber);
        ParseLoopNumber := ParseLoopNumber + 1;

        {  finds parentheses along the entire equation  }
        for i := 1 to Length(eq) do
        begin
            if (eq[i] = '(') and (ParseIndexOfFirstOP < 1) then ParseIndexOfFirstOP := i; // store the index for first occuring "(".
            if (eq[i] = '(') and (ParseIndexOfLastCP = 0) then Inc(ParseAmountOfOPBeforeFirstCP); // adds amount of "(" to the variable if ")" hasn't been found yet.

            if (eq[i] = ')') and (ParseIndexOfFirstCP < 1) then ParseIndexOfFirstCP := i; // store the index for first occuring ")".
            if (eq[i] = ')') and (ParseIndexOfLastCP < i) then ParseIndexOfLastCP := i; // store the index for last occuring ")".
        end;
        
        {  checks if theres no more parentheses in the equation, which will call the Calc() procedure and end the program  }
        if (ParseIndexOfFirstOP = 0) then // notice that we only need to check the first "(" instead of checking for both "(" and ")" because on the input, its already illegal to exit the loop because of the line TBA to TBA.
            begin
                CalcResult := 0; // change the value to 0 because it might be diluted by usage of previous recursion.
                Calc(finalResultStr); // calls Calc() with "finalResultStr" as its parameter for getting the final answer
                writeln('hasil dari (', InputExpressionStr, ') adalah: ', CalcResult:0:3); // prints the final answer
                Exit;
            end;
        {  checks for if the amount of "(" is >= 2 or not, that way we can check if we already dug deep enough, if its >= 2 it means theres still deeper parentheses to go for  }
        if not (ParseAmountOfOPBeforeFirstCP < 2) then
        begin
            ParseExpressionParsed := Copy(eq, ParseIndexOfFirstOP + 1, ParseIndexOfLastCP - ParseIndexOfFirstOP - 1); // parse the outer parentheses whilst ditching the parentheses also to dig deeper, example below:
            writeln('equation before parse: ', eq); // ((2+3)*(4-(5/(2+3))))^2; this is our input.
            writeln('equation after parse: ', ParseExpressionParsed); // (2+3)*(4-(5/(2+3)); notice that we cut all the outer parts of the outer parentheses, hence only grabbing the inner part for deeper finding.
            Parse(ParseExpressionParsed); // recurse the parsed expression inside this procedure to dig deeper parentheses. Notice on the example how after the parsing the expression wont go to this block of code anymore because the amount of "(" before ")" is 1, hence is < 2, hence is not what we want in this block of code.
        end
        {  checks for if the amount of "(" is < 2 or not, if true that means that we have dug deep enough for doing calculations  }
        else if (ParseAmountOfOPBeforeFirstCP < 2) then
        begin
            writeln('equation before: ', eq); // this is the example input, which is the continuation of last part: (2+3)*(4-(5/(2+3))
            ParseToCalc := Copy(eq, ParseIndexOfFirstOP, ParseIndexOfFirstCP - ParseIndexOfFirstOP + 1); // parse the outer parentheses whilst keeping the parentheses, notice that the parsing method is different from the ones from before, its because we already found the deepest parentheses, hence we only need to find the pair for our first "(", which is the first occuring ")", keeping the parentheses is important because we need to replace the entire part of that parentheses with the result after calculating, see example below:
            writeln('ready to calculate: ', ParseToCalc); // (2+3); output
            CalcResult := 0; // change the value to 0 because it might be diluted by usage of previous recursion.
            Calc(ParseToCalc); // calls Calc() to calculate the parsed deepest equation, in this example Calc() will calculate 2 + 3, which sets CalcResult to 5.
            ParseCalcResult := CalcResult; // sets the result to be printed out; notice that we set the result not to the original parse variable, because it is needed to replace it on the original equation by the resulting value.
            writeln('result: ', ParseCalcResult:0:A); // 5.A; output, A is the accuracy set in the CONST.
            Insert(FloatToStr(ParseCalcResult), finalResultStr, Pos(ParseToCalc, finalResultStr)); // (5(2+3)*(4-(5/(2+3))))^2; inserts the result (5) to the front of the parsed equation.
            //writeln(finalResultStr); //decomment to see how the equation looks like after Insert.
            Delete(finalResultStr, Pos(ParseToCalc, finalResultStr), Length(ParseToCalc)); // (5*(4-(5/(2+3))))^2; deletes the parsed equation (2+3 is now gone), now the entire equation is simpler.
            //writeln(finalResultStr); //decomment to see how the equation looks like after Delete.
            Parse(finalResultStr); // recurse again using the result as a parameter to find yet another deepest parentheses on the equation, until theres none left.
        end;
    end;
{  END OF PHASE 2  }

{  PHASE 1: Getting user's input  }
procedure Input;
    begin
        while not InputIsDone do // InputIsDone is initialized in the "start of program" block code.
        begin
            writeln; writeln; writeln; writeln; writeln; writeln; writeln; writeln; writeln; writeln; writeln; // clrscr because using CRT breaks the output
            writeln(InputErrorMessage); // on first iteration, this will be empty.

            {get user's input (char by char)}
            writeln('possible inputs: 0-9, "+", "-", "*", "/", "^", "."');
            writeln('"=" (untuk cetak hasil), "d" (untuk delete index terakhir), "c" (untuk clear ekspresi)'); writeln; // special inputs
            writeln('ekspresi: ', InputExpressionStr);
            write('input: '); ReadLn(InputInputChar);

            {  checks for if the input is one of the special inputs  }
            if InputInputChar = '=' then // for when input is finished.
            begin
                {  check if the equation is empty  }
                if Length(InputExpressionStr) = 0 then
                begin
                    InputErrorMessage := 'CALCULATION ERROR: ekspresi tidak boleh kosong';
                    break;
                end;
                {  check if "(" and ")" is imbalanced  }
                if not (InputOPcount = InputCPcount) then
                begin
                    InputErrorMessage := 'CALCULATION ERROR: jumlah "(" tidak sama dengan jumlah ")"';
                    break;
                end;
                {  check if the equation ends with an operator  }
                if (InputLastInputtedChar in Operators) then
                begin
                    InputErrorMessage := 'CALCULATION ERROR: ekspresi tidak boleh diakhiri oleh operator dan titik desimal';
                    break;
                end;
                InputIsDone := true; // when all checks is false, this line will be executed, then leave the while loop.
            end
            else if InputInputChar = 'd' then // for when user want to delete the last inputted character.
            begin
                {  check if the expression is empty  }
                if Length(InputExpressionStr) = 0 then 
                begin
                    InputErrorMessage := 'INPUT ERROR: ekspresi sudah kosong';
                    break;
                end;

                {  checks for if last input was important to someone  }
                if InputExpressionStr[Length(InputExpressionStr)] = '.' then InputIsInputDecimal := false; 
                if InputExpressionStr[Length(InputExpressionStr)] = '(' then Dec(InputOPcount);
                if InputExpressionStr[Length(InputExpressionStr)] = ')' then Dec(InputCPcount);

                InputExpressionStr := Copy(InputExpressionStr, 1, (Length(InputExpressionStr) - 1)); // this cuts the last part of InputExpressionStr

                {  change the user's last input to the last index of InputExpressionStr after being cut  }
                if Length(InputExpressionStr) > 0 then InputLastInputtedChar := InputExpressionStr[Length(InputExpressionStr)]
                else InputLastInputtedChar := #0; // no value for user's last input if the char being cut is the last of the expression.
            end
            else if InputInputChar = 'c' then // for when user wants to clear the expression, also reset all important variables to their 0 value.
            begin 
                InputLastInputtedChar := #0; 
                InputExpressionStr := ''; 
                InputOPcount := 0; 
                InputCPcount := 0; 
                InputIsInputDecimal := true;
            end
            
            {  when user's input is not a special character, check for edge cases  }
            else
            begin
                {  check for illegal input  }
                if not (InputInputChar in PossibleInput) then 
                begin
                    InputErrorMessage := 'INPUT ERROR: illegal input';
                    break;
                end;
                {  check if first input is part of operators but not -  }
                if (InputExpressionStr = '') and (InputInputChar in Operators) and not (InputInputChar = '-') then
                begin
                    InputErrorMessage := 'INPUT ERROR: index pertama tidak boleh operasi perhitungan';
                    break;
                end;
                {  check if user's input is double operators  }
                if (InputInputChar in Operators) and (InputLastInputtedChar in Operators) then
                begin
                    InputErrorMessage := 'INPUT ERROR: operator tidak boleh diikuti oleh operator lagi';
                    break;
                end;
                {  check for making sure number is not followed by "("   }
                if (InputInputChar = '(') and (InputLastInputtedChar in Numbers) then
                begin
                    InputErrorMessage := 'INPUT ERROR: angka tidak boleh diikuti tanda "(" (jika ingin, tulis x * (...))';
                    break;
                end; 
                {  check if users's input are parentheses and is valid or not  }
                if (InputInputChar = '(') then Inc(InputOPcount);
                if (InputInputChar = ')') and (InputOPcount <= InputCPcount) then
                begin
                    InputErrorMessage := 'INPUT ERROR: terlalu banyak ")" dibandingkan "("';
                    break;
                end;
                if (InputInputChar = ')') then Inc(InputCPcount);
                {  check for making sure parentheses is not empty  }
                if (InputInputChar = ')') and (InputLastInputtedChar = '(') then
                begin
                    InputErrorMessage := 'INPUT ERROR: operasi di dalam tanda kurung tidak boleh kosong';
                    break;
                end; 
                {  check if a number has multiple decimal points  }
                if InputIsInputDecimal and (InputInputChar = '.') then
                begin
                    InputErrorMessage := 'INPUT ERROR: bilangan tidak boleh memiliki dua titik desimal';
                    break;
                end;

                if InputInputChar = '.' then InputIsInputDecimal := true; // make that number decimal if user's input is '.'.

                {  changing "InputIsInputDecimal" to false  }
                if not (Length(InputExpressionStr) = 0) then // when it's not the first input, after using an operator, the number is now different from the last number, hence we need to change the 'InputIsInputDecimal' to false, but only change to false after user has inputted a number after the operator
                begin
                    if ((InputLastInputtedChar in Operators) and not (InputLastInputtedChar = '.') and (InputInputChar in Numbers)) then InputIsInputDecimal := false;
                end
                else // when it's the first input, its much shorter because we dont need to check for last user's input, change to false if the input is number.
                begin 
                    if InputInputChar in Numbers then InputIsInputDecimal := false; 
                end;

                InputLastInputtedChar := InputInputChar; // stores the char of user's current input to "InputLastInputtedChar" for the next iteration.
                InputErrorMessage := ''; // clears the error message when all edge cases is false.
                InputExpressionStr := InputExpressionStr + InputInputChar; // add user's current input to the expression.
            end;
        end;


        {  confirmation to exit the input loop  }
        if InputIsDone then
        begin
            write('Selesai menghitung? (y/n) '); readln(InputIsDoneChecker);
            if InputIsDoneChecker = 'y' then 
            begin
                isDone := true;
                InputIsDone := true;
            end
            else InputIsDone := false;
        end;
    end;
{  END OF PHASE 1  }

{  Start of Program  }
begin
    {  initialize the value for the "Input" procedure because error if not, why not initialize inside the procedure? because the value will reset everytime someone gives an error output, which is not what we want.  }
    InputIsDone := false; 
    InputLastInputtedChar := #0; 
    InputExpressionStr := ''; 
    InputOPcount := 0; 
    InputCPcount := 0; 
    InputIsInputDecimal := true;

    ParseLoopNumber := 0; // initialize the value for the "Parse" procedure because the procedure gets called through recursion, and we dont want to reset the loop number.
    isDone := false; // initialize for making the loop start first
    while not isDone do Input; // trigger PHASE 1 (line TBA)
    //InputExpressionStr := '-5^(2-4)';
    writeln('Input equation: ', InputExpressionStr); // prints the output for phase 1
    finalResultStr := InputExpressionStr; // sets value of the final result for phase 2
    Parse(InputExpressionStr); // trigger PHASE 2 (line TBA)
    
end.
// ~A.R.A. 40124136 1DC01
