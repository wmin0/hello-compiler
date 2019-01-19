%{
  #ifndef PARSER_H
  #define PARSER_H
  #include <stdio.h>
  #include <string.h>
  #include <iostream>
  #include <stack>
  #include <map>
  #include <string>
  #include <vector>

  using namespace std;

  extern int yylex();
  extern int yyparse();
  extern FILE* yyin;
  extern FILE* yyout;
  void yyerror(char*);

  struct varAttr {
    int id;
    int dim;
  };

  varAttr findVar(const char*);
  void handleOp(const char&);
  void handleLogic(const char&);
  void printOp(const char&);

  char className[1024];

  FILE *in = NULL;
  FILE *out = NULL;

  int L = 1;
  stack<int> Lstack;
  stack<int> Wstack;
  stack<int> Bstack;

  vector<int> arrInfo;

  int CB = -1;

  int V = 2;  // 1 for Scanner
  map<string, varAttr> Vmap;
  int arrCount = 0;
  stack< map<string, varAttr> > varStack;

  int priority[128];
  stack<char> opStack;
  stack< stack<char> > opopStack;

  char* printFunc = NULL;

  void opEnd();
  void logicEnd();
%}

%union {
  int num1_val;
  int num2_val;
  char str0_val[1024];
  char str1_val[1024];
  char str2_val[1024];
  char str3_val[1024];
  char str4_val[1024];
  char str5_val[1024];
  char str6_val[1024];
  char str7_val[1024];
  char str8_val[1024];
  char str9_val[1024];
  char str10_val[1024];
  char str11_val[1024];
  char str12_val[1024];
  char str13_val[1024];
  char str14_val[1024];
  char str15_val[1024];
  char str16_val[1024];
  char str17_val[1024];
}

%token <num1_val> NUM;
%token <str0_val> LOGICAL_AND;
%token <str1_val> LOGICAL_OR;
%token <str2_val> LESS_OR_EQ;
%token <str3_val> MORE_OR_EQ;
%token <str4_val> EQ;
%token <str5_val> NOT_EQ;
%token <str6_val> INT;
%token <str7_val> IF;
%token <str8_val> ELSE;
%token <str9_val> WHILE;
%token <str10_val> BREAK;
%token <str11_val> CONTINUE;
%token <str12_val> SCAN;
%token <str13_val> PRINT;
%token <str14_val> PRINTLN;
%token <str15_val> ID;
%token <str16_val> STR;

%type <str15_val> var;

%type <num2_val> arithExpr_arr_;

%%

program: {
    fprintf(out, "\
       .import java.io.*\n\n\
       .import java.util.*\n\n\
       .class %s\n\n\
       .method void <init>()\n\
               aload #0\n\
               invokespecial void <init>() @ Object\n\
               return\n\n\
       .method public static void main(String[])\n\
       .try TRY0\n\
               new Scanner\n\
               dup\n\
               getstatic InputStream in @ System\n\
               invokespecial void <init>(InputStream) @ Scanner\n\
               astore #1\n", className);
    #ifdef Debug
      cerr << "[Debug] program" << endl; 
    #endif
  } blockStmt { 
    fprintf(out, "\
       .tryend TRY0\n\
               goto L0\n\
       .catch Exception in TRY0\n\
               astore #1\n\
               getstatic PrintStream out @ System\n\
               aload #1\n\
               invokevirtual String toString() @ Exception\n\
               invokevirtual void println(String) @ PrintStream\n\
       L0:\n\
               return\n");
    #ifdef Debug 
      cerr << "[Debug] program->blockStmt" << endl; 
    #endif
  }
  ;
blockStmt:
  '{' {
    varStack.push(Vmap);
    #ifdef Debug 
      cerr << "[Debug] blockStmt" << endl;
    #endif
  } varDecl_ stmt_ '}' {
    Vmap = varStack.top();
    varStack.pop();
    #ifdef Debug 
      cerr << "[Debug] blockStmt->{ varDecl_ stmt_ }" << endl;
    #endif
  }
  ;
varDecl_:
  varDecl varDecl_ { 
    #ifdef Debug 
      //cerr << "[Debug] varDecl_->varDecl varDecl_" << endl; 
    #endif
  }
  | { 
    #ifdef Debug
      //cerr << "[Debug] varDecl_->$(empty)" << endl;
    #endif
  }
  ;
stmt_:
  stmt stmt_ { 
    #ifdef Debug
      //cerr << "[Debug] stmt_->stmt stmt_" << endl;
    #endif
  }
  | { 
    #ifdef Debug
      //cerr << "[Debug] stmt_->$(empty)" << endl;
    #endif
  }
  ;
varDecl:
  INT /*{
    arrCount = 0;
    #ifdef Debug
      cerr << "[Debug] varDecl->INT(" << $1 << ")" << endl;
      cerr << "[Debug] arrCount: " << arrCount << endl;
    #endif
  }*/ arr_ ID {
    varAttr tmp;
    if (arrCount != 0) {
      fprintf(out, "\
               multianewarray int");
      for (int i = 0; i < arrCount; ++i) {
        fprintf(out, "[]");
      }
      fprintf(out, " %d-d\n\
               astore #%d\n", arrCount, V);
    }
    tmp.dim = arrCount;
    tmp.id = V++;
    Vmap[$3] = tmp;
    #ifdef Debug
      cerr << "[Debug] varDecl->INT(" << $1 << ") arr_ ID(" << $3 << ")" << endl;
      cerr << "[Debug] arrCount: " << arrCount << endl;
      cerr << "[Debug] map: " << V - 1 << ", " << $3 << endl;
    #endif
  } ids_ ';' {
    arrCount = 0;
    arrInfo.clear();
    #ifdef Debug
      cerr << "[Debug] varDecl->INT(" << $1 << ") arr_ ID(" << $3 << ") ids_ ;" << endl;
    #endif
  }
  ;
arr_:
  arr arr_ { 
    #ifdef Debug
      //cerr << "[Debug] arr_->arr arr_" << endl;
    #endif
  }
  | { 
    #ifdef Debug
      //cerr << "[Debug] arr_->$(empty)" << endl;
    #endif
  }
  ;
arr:
  '[' NUM ']' { 
    #ifdef Debug
      cerr << "[Debug] arr->[ NUM(" << $2 << ") ]" << endl;
      cerr << "[Debug] arrCount: " << arrCount + 1 << endl;
    #endif
    arrInfo.push_back($2);
    fprintf(out, "\
               ldc %d\n", $2);
    ++arrCount;
  }
  ;
ids_:
  ids ids_ { 
    #ifdef Debug
      //cerr << "[Debug] ids_->ids ids_" << endl;
    #endif
  }
  | { 
    #ifdef Debug
      //cerr << "[Debug] ids_->$(empty)" << endl;
    #endif
  }
  ;
ids:
  ',' ID {
    varAttr tmp;
    if (arrCount != 0) {
      for (int i = 0; i < arrInfo.size(); ++i) {
        fprintf(out, "\
               ldc %d\n", arrInfo[i]);
      }
      fprintf(out, "\
               multianewarray int");
      for (int i = 0; i < arrCount; ++i) {
        fprintf(out, "[]");
      }
      fprintf(out, " %d-d\n\
               astore #%d\n", arrCount, V);
    }
    tmp.dim = arrCount;
    tmp.id = V++;
    Vmap[$2] = tmp;
    #ifdef Debug
      cerr << "[Debug] ids->, ID(" << $2 << ")" << endl;
      cerr << "[Debug] map: " << V - 1 << ", " << $2 << endl;
      cerr << "[Debug] dim: " << tmp.dim << endl;
    #endif
  }
  ;
vars_:
  vars_ ',' vars { 
    #ifdef Debug
      //cerr << "[Debug] vars_->vars vars_" << endl;
    #endif
  }
  | { 
    #ifdef Debug
      //cerr << "[Debug] vars_->$(empty)" << endl;
    #endif
  }
  ;
vars:
  var {
    varAttr tmp = findVar($1);
    if (tmp.dim == 0) {
      fprintf(out, "\
               aload #1\n\
               invokevirtual int nextInt() @ Scanner\n\
               istore #%d\n", tmp.id);
    } else {
      fprintf(out, "\
               aload #1\n\
               invokevirtual int nextInt() @ Scanner\n\
               iastore\n");
    }
    #ifdef Debug
      //cerr << "[Debug] vars->, var(" << $2 << ")" << endl;
      cerr << "[Debug] Scan to: " << tmp.id << endl;
    #endif
  }
  ;
var:
  ID {
    varAttr tmp = findVar($1);
    if (tmp.dim != 0) {
      fprintf(out, "\
               aload #%d\n", tmp.id);
    }
    #ifdef Debug
      cerr << "[Debug] id: " << tmp.id
           << " dim: " << tmp.dim << endl;
    #endif
  } arithExpr_arr_ {
    strcpy($$, $1);
    #ifdef Debug
      //cerr << "[Debug] var->ID(" << $1 << ") arithExpr_arr_" << endl;
    #endif
  }
  ;
arithExpr_arr_:
  arithExpr_arr_ {
    if ($1 != 0) {
      fprintf(out, "\
               aaload\n");
    }
    #ifdef Debug
      //cerr << "[Debug] arithExpr_arr_->arithExpr_arr arithExpr_arr_" << endl;
      //cerr << "[Debug] opStack.empty(): " << opStack.empty() << endl;
    #endif
  } arithExpr_arr {
    $$ = 1;
  }
  | {
    $$ = 0;
    #ifdef Debug
      //cerr << "[Debug] arithExpr_arr_->$(empty)" << endl;
    #endif
  }
  ;
arithExpr_arr:
  '[' {
    opopStack.push(opStack);
    while (!opStack.empty()) {
      opStack.pop();
    }
  } arithExpr ']' {
    opEnd();
    opStack = opopStack.top();
    opopStack.pop();
    #ifdef Debug
      //cerr << "[Debug] arithExpr_arr->[ arithExpr ]" << endl;
      //cerr << "[Debug] opStack.empty(): " << opStack.empty() << endl;
    #endif
  }
  ;
stmt:
  var '=' arithExpr ';' {
    opEnd();
    varAttr tmp = findVar($1);
    if (tmp.dim == 0) {
      fprintf(out, "\
               istore #%d\n", tmp.id);
    } else {
      fprintf(out, "\
               iastore\n");
    }
    #ifdef Debug
      cerr << "[Debug] stmt->var(" << $1 << ") = arithExpr;" << endl;
      cerr << "[Debug] opStack.empty(): " << opStack.empty() << endl;
    #endif
  }
  | IF '(' {
    CB = -1;
  } logicExpr ')' {
    logicEnd();
    Lstack.push(L);
    fprintf(out, "\
               ifeq L%d\n", L++);
    #ifdef Debug
      cerr << "[Debug] stmt->IF(" << $1 << ") ( logicExpr )" << endl;
    #endif
  } dangleElse
  | WHILE {
    Wstack.push(L);
    fprintf(out, "\
       L%d:\n", L++);
    #ifdef Debug
      cerr << "[Debug] stmt->WHILE(" << $1 << ")" << endl;
    #endif

  } '(' {
    CB = -1;
  } logicExpr ')' {
    logicEnd();

    Wstack.push(L);
    fprintf(out, "\
               ifeq L%d\n", L++);
    #ifdef Debug
      cerr << "[Debug] stmt->WHILE(" << $1 << ") ( logicExpr )" << endl;
    #endif
  } blockStmt {
    int tmp = Wstack.top();
    Wstack.pop();
    fprintf(out, "\
               goto L%d\n\
       L%d:\n", Wstack.top(), tmp);
    Wstack.pop();
    #ifdef Debug
      cerr << "[Debug] stmt->WHILE(" << $1 << ") ( logicExpr ) blockStmt" << endl;
    #endif
  }
  | BREAK ';' { 
    fprintf(out, "\
               goto L%d\n", Wstack.top());
    #ifdef Debug
      cerr << "[Debug] stmt->BREAK(" << $1 << ") ;" << endl;
    #endif
  }
  | CONTINUE ';' {
    int tmp = Wstack.top();
    Wstack.pop();
    fprintf(out, "\
               goto L%d\n", Wstack.top());
    Wstack.push(tmp);
    #ifdef Debug
      cerr << "[Debug] stmt->CONTINUE(" << $1 << ") ;" << endl;
    #endif
  }
  | SCAN {
    #ifdef Debug
      cerr << "[Debug] stmt->SCAN(" << $1 << ")" << endl;
    #endif
  } '(' vars vars_ ')' ';' { 
    #ifdef Debug
      //cerr << "[Debug] stmt->SCAN(" << $1 << ") ( var vars_ ) ;" << endl;
    #endif
  }
  | PRINT {
    printFunc = "print";
    fprintf(out, "\
               getstatic PrintStream out @ System\n");
    #ifdef Debug
      cerr << "[Debug] stmt->PRINT(" << $1 << ")" << endl;
    #endif
  } '(' printableExpr printableExprs_ ')' ';' { 
    #ifdef Debug
      //cerr << "[Debug] stmt->PRINT(" << $1 << ") ( printableExpr printableExprs_ ) ;" << endl;
    #endif
  }
  | PRINTLN {
    printFunc = "print";
    fprintf(out, "\
               getstatic PrintStream out @ System\n");
    #ifdef Debug
      cerr << "[Debug] stmt->PRINTLN(" << $1 << ")" << endl;
    #endif
  } '(' printableExpr printableExprs_ ')' ';' {
    fprintf(out, "\
               getstatic PrintStream out @ System\n\
               ldc \"\"\n\
               invokevirtual void println(String) @ PrintStream\n");
    #ifdef Debug
      //cerr << "[Debug] stmt->PRINTLN(" << $1 << ") ( printableExpr printableExprs_ ) ;" << endl;
    #endif
  }
  | blockStmt { 
    #ifdef Debug
      //cerr << "[Debug] stmt->blockStmt" << endl;
    #endif
  }
  ;

dangleElse:
  blockStmt {
    fprintf(out, "\
       L%d:\n", Lstack.top());
    Lstack.pop();
    #ifdef Debug
      //cerr << "[Debug] stmt->IF(" << $1 << ") ( logicExpr ) blockStmt" << endl;
    #endif
  }
  | blockStmt ELSE {
    fprintf(out, "\
               goto L%d\n\
       L%d:\n", L, Lstack.top());
    Lstack.pop();
    Lstack.push(L++);
    #ifdef Debug
      //cerr << "[Debug] stmt->IF(" << $1 << ") ( logicExpr ) blockStmt ELSE" << endl;
    #endif
  } blockStmt {
    fprintf(out, "\
       L%d:\n", Lstack.top());
    Lstack.pop();
    #ifdef Debug
      //cerr << "[Debug] stmt->IF(" << $1 << ") ( logicExpr ) blockStmt ELSE(" << $6 << ") blockStmt" << endl;
    #endif

  }
  ;


printableExprs_:
  printableExprs printableExprs_ { 
    #ifdef Debug
      //cerr << "[Debug] printableExprs_->printableExprs printableExprs_" << endl;
    #endif
  }
  | { 
    #ifdef Debug
      //cerr << "[Debug] printableExprs_->$(empty)" << endl;
    #endif
  }
  ;
printableExprs:
  ',' {
    fprintf(out, "\
               getstatic PrintStream out @ System\n");
    #ifdef Debug
      cerr << "[Debug] printableExprs->," << endl;
    #endif
  } printableExpr { 
    #ifdef Debug
      //cerr << "[Debug] printableExprs->, printableExpr" << endl;
    #endif
  }
  ;
printableExpr:
  STR {
    fprintf(out, "\
               ldc \"%s\"\n\
               invokevirtual void %s(String) @ PrintStream\n", $1, printFunc);
    #ifdef Debug
      cerr << "[Debug] printableExpr->STR(" << $1 << ")" << endl;
    #endif
  }
  | arithExpr {
    opEnd();
    fprintf(out, "\
               invokevirtual void %s(int) @ PrintStream\n", printFunc);
    #ifdef Debug
      cerr << "[Debug] printableExpr->arithExpr" << endl;
    #endif
  }
  ;
arithExpr:
  arithExpr '+' {
    handleOp('+');
    #ifdef Debug
      cerr << "[Debug] arithExpr->arithExpr +" << endl;
    #endif
  } arithExpr {
    #ifdef Debug
      //cerr << "[Debug] arithExpr->arithExpr + arithExpr" << endl;
    #endif
  }
  | arithExpr '-' {
    handleOp('-');
    #ifdef Debug
      cerr << "[Debug] arithExpr->arithExpr -" << endl;
    #endif
  } arithExpr {
    #ifdef Debug
      //cerr << "[Debug] arithExpr->arithExpr - arithExpr" << endl;
    #endif
  }
  | arithExpr '*' {
    handleOp('*');
    #ifdef Debug
      cerr << "[Debug] arithExpr->arithExpr *" << endl;
    #endif
  } arithExpr {
    #ifdef Debug
      //cerr << "[Debug] arithExpr->arithExpr * arithExpr" << endl;
    #endif
  }
  | arithExpr '/' {
    handleOp('/');
    #ifdef Debug
      cerr << "[Debug] arithExpr->arithExpr /" << endl;
    #endif
  } arithExpr {
    #ifdef Debug
      //cerr << "[Debug] arithExpr->arithExpr / arithExpr" << endl;
    #endif
  }
  | '+' arithExpr { 
    #ifdef Debug
      cerr << "[Debug] arithExpr->+ arithExpr" << endl;
    #endif
  }
  | '-' arithExpr {
    fprintf(out, "\
               ineg\n");
    #ifdef Debug
      cerr << "[Debug] arithExpr->- arithExpr" << endl;
    #endif
  }
  | var {
    varAttr tmp = findVar($1);
    if (tmp.dim == 0) {
      fprintf(out, "\
               iload #%d\n", tmp.id);
    } else {
      fprintf(out, "\
               iaload\n");
    }
    #ifdef Debug
      cerr << "[Debug] arithExpr->var" << endl;
    #endif
  }
  | NUM {
    fprintf(out, "\
               ldc %d\n", $1);
    #ifdef Debug
      cerr << "[Debug] arithExpr->NUM(" << $1 << ")" << endl;
    #endif
  }
  | '(' {
    opStack.push('(');
  } arithExpr ')' {
    while (opStack.top() != '(') {
      printOp(opStack.top());
      opStack.pop();
    }
    opStack.pop();
    #ifdef Debug
      cerr << "[Debug] arithExpr->( arithExpr )" << endl;
    #endif
  }
  ;
logicExpr:
  logicExpr LOGICAL_OR {
    if (CB != -1) {
      fprintf(out, "\
       L%d:\n", CB);
    }
    CB = L++;
    handleLogic('|');
    Bstack.push(CB);
    CB = -1;
    #ifdef Debug
      cerr << "[Debug] logicExpr->logicExpr LOGICAL_OR(" << $2 << ") logicExpr" << endl;
    #endif
  } logicExpr {
    if (CB != -1) {
      fprintf(out, "\
       L%d:\n", CB);
    }
    CB = Bstack.top();
    Bstack.pop();
    fprintf(out, "\
       L%d:\n", CB);
    CB = -1;
  }
  | logicExpr LOGICAL_AND {
    if (CB != -1) {
      fprintf(out, "\
       L%d:\n", CB);
    }
    CB = L++;
    handleLogic('&');
    #ifdef Debug
      cerr << "[Debug] logicExpr->logicExpr LOGICAL_AND(" << $2 << ") logicExpr" << endl;
    #endif
  } logicExpr
  | '!' {
    if (CB != -1) {
      Bstack.push(CB);
    }
    CB = -1;
  } logicExpr {
    if (CB != -1) {
      fprintf(out, "\
       L%d:\n", CB);
    }
    if (Bstack.empty()) {
      CB = -1;
    } else {
      CB = Bstack.top();
      Bstack.pop();
    }
    handleLogic('!');
    #ifdef Debug
      cerr << "[Debug] logicExpr->! logicExpr" << endl;
    #endif
  }
  | arithExpr {
    opEnd();
  } '>' arithExpr {
    opEnd();
    fprintf(out, "\
               if_icmpgt L%d\n\
               ldc 0\n\
               goto L%d\n\
       L%d:\n\
               ldc 1\n\
       L%d:\n", L, L + 1, L, L + 1);
    L += 2;
    #ifdef Debug
      cerr << "[Debug] logicExpr->arithExpr > arithExpr" << endl;
    #endif
  }
  | arithExpr {
    opEnd();
  } MORE_OR_EQ arithExpr {
    opEnd();
    fprintf(out, "\
               if_icmpge L%d\n\
               ldc 0\n\
               goto L%d\n\
       L%d:\n\
               ldc 1\n\
       L%d:\n", L, L + 1, L, L + 1);
    L += 2;
    #ifdef Debug
      //cerr << "[Debug] logicExpr->arithExpr MORE_OR_EQ(" << $2 << ") arithExpr" << endl;
    #endif
  }
  | arithExpr {
    opEnd();
  } '<' arithExpr { 
    opEnd();
    fprintf(out, "\
               if_icmplt L%d\n\
               ldc 0\n\
               goto L%d\n\
       L%d:\n\
               ldc 1\n\
       L%d:\n", L, L + 1, L, L + 1);
    L += 2;
    #ifdef Debug
      cerr << "[Debug] logicExpr->arithExpr < arithExpr" << endl;
    #endif
  }
  | arithExpr {
    opEnd();
  } LESS_OR_EQ arithExpr { 
    opEnd();
    fprintf(out, "\
               if_icmple L%d\n\
               ldc 0\n\
               goto L%d\n\
       L%d:\n\
               ldc 1\n\
       L%d:\n", L, L + 1, L, L + 1);
    L += 2;
    #ifdef Debug
      //cerr << "[Debug] logicExpr->arithExpr LESS_OR_EQ(" << $2 << ") arithExpr" << endl;
    #endif
  }
  | arithExpr {
    opEnd();
  } EQ arithExpr {
    opEnd();
    fprintf(out, "\
               if_icmpeq L%d\n\
               ldc 0\n\
               goto L%d\n\
       L%d:\n\
               ldc 1\n\
       L%d:\n", L, L + 1, L, L + 1);
    L += 2;
    #ifdef Debug
      //cerr << "[Debug] logicExpr->arithExpr EQ(" << $2 << ") arithExpr" << endl;
    #endif
  }
  | arithExpr {
    opEnd();
  } NOT_EQ arithExpr { 
    opEnd();
    fprintf(out, "\
               if_icmpne L%d\n\
               ldc 0\n\
               goto L%d\n\
       L%d:\n\
               ldc 1\n\
       L%d:\n", L, L + 1, L, L + 1);
    L += 2;
    #ifdef Debug
      //cerr << "[Debug] logicExpr->arithExpr NOT_EQ(" << $2 << ") arithExpr" << endl;
    #endif
  }
  | '[' {
    if (CB != -1) {
      Bstack.push(CB);
    }
    CB = -1;
    #ifdef Debug
      //cerr << "[Debug] logicExpr->[" << endl;
      //cerr << "[Debug] logicStack.size(): " << logicStack.size() << endl;
    #endif
  } logicExpr ']' {
    if (CB != -1) {
      fprintf(out, "\
       L%d:\n", CB);
    }
    if (Bstack.empty()) {
      CB = -1;
    } else {
      CB = Bstack.top();
      Bstack.pop();
    }
    #ifdef Debug
      cerr << "[Debug] logicExpr->[ logicExpr ]" << endl;
    #endif
  }
  ;
%%
int main(int argv, char** args) {
  in = fopen(args[1], "r");
  out = fopen(args[2], "w");
  if (!in) {
    cout << "open fail";
    return 0;
  }
  priority['+'] = priority['-'] = 1;
  priority['*'] = priority['/'] = 2;
  priority['('] = priority[')'] = 0;

  priority['&'] = priority['|'] = 1;
  priority['!'] = 2;
  priority['['] = priority[']'] = 0;

  int count = 0;
  if (argv < 4) {
    for (; count < strlen(args[1]); ++count) {
      if (args[1][count] == '.') {
        break;
      }
    }
    strncpy(className, args[1], count);
  } else {
    strncpy(className, args[3], strlen(args[3]));
  }
  if (!out) {
    out = stdout;
  }
  yyout = fopen("/dev/null", "w");
  yyin = in;
  
  do {
    yyparse();
  } while (!feof(yyin));
  //fprintf(out, "Pass\n");
}

void yyerror(char *s) { 
  #ifdef Debug
    cerr << "EEK, parse error!  Message: " << s << endl;
  #endif
  fprintf(out, "Fail\n");
  exit(0);
}

varAttr findVar(const char* s) {
  map<string, varAttr>::iterator it = Vmap.find(s);
  if (it == Vmap.end()) {
    fprintf(out, "Use wrong ID: %s\n", s);
    exit(0);
  }
  return it->second;
}

void handleOp(const char& c) {
  #ifdef Debug
    cerr << "[Debug] handling: " << c << endl;
    cerr << "[Debug] opStack.size(): " << opStack.size() << endl;
  #endif
  if (!opStack.empty() && priority[opStack.top()] >= priority[c]) {
    printOp(opStack.top());
    opStack.pop();
  }
  opStack.push(c);
}

void handleLogic(const char& c) {
  #ifdef Debug
    cerr << "[Debug] handling: " << c << endl;
    //cerr << "[Debug] logicStack.size(): " << logicStack.size() << endl;
  #endif
  printOp(c);
}

void printOp(const char& c) {
  switch (c) {
    case '+':
      fprintf(out, "\
               iadd\n");
      break;
    case '-':
      fprintf(out, "\
               isub\n");
      break;
    case '*':
      fprintf(out, "\
               imul\n");
      break;
    case '/':
      fprintf(out, "\
               idiv\n");
      break;
    case '&':
      fprintf(out, "\
               ifne L%d\n\
               ldc 0\n\
               goto L%d\n\
       L%d:\n", L, CB, L);
      ++L;
      break;
    case '|':
      fprintf(out, "\
               ifeq L%d\n\
               ldc 1\n\
               goto L%d\n\
       L%d:\n", L, CB, L);
      ++L;
      break;
    case '!':
      fprintf(out, "\
               ifeq L%d\n\
               ldc 0\n\
               goto L%d\n\
       L%d:\n\
               ldc 1\n\
       L%d:\n", L, L + 1, L, L + 1);
      L += 2;
      break;
  }
}

void opEnd() {
  #ifdef Debug
    cerr << "[Debug] opEnd()" << endl;
  #endif
  while (!opStack.empty()) {
    printOp(opStack.top());
    opStack.pop();
  }
}

void logicEnd() {
  #ifdef Debug
    cerr << "[Debug] logicEnd()" << endl;
  #endif
  if (CB != -1) {
    fprintf(out, "\
       L%d:\n", CB);
  }
  while (!Bstack.empty()) {
    fprintf(out, "\
       L%d:\n", Bstack.top());
    Bstack.pop();
  }
}
#endif
