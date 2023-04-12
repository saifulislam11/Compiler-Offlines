%option noyywrap


%{
#include<stdio.h>

#include<stdlib.h>

#include<bits/stdc++.h>

#include <iostream>

#include <cstdlib>

#include <cstdio>

#include <fstream>

//FILE * logstatus= fopen("1705006_log.txt","w");

//FILE *token= fopen("1705006_token.txt","w");

using namespace std;

class SymbolInfo
{
private:
    string Symbol_Name,Symbol_Type,Declared_Type;
public:
    SymbolInfo *next;

    ///constructors

    SymbolInfo()
    {
        Symbol_Name = "";
        Symbol_Type = "";
        Declared_Type = "";
        next=NULL;
    }
    SymbolInfo(string name,string type,string d_type="")
    {
        Symbol_Name=name;
        Symbol_Type=type;
        Declared_Type = d_type;
        next=NULL;
    }
    ///getter & setter
    void set_name(string name)
    {
        Symbol_Name=name;
    }
    void set_dectype(string type)
    {
	  Declared_Type=type;
    }
    void set_type(string type)
    {
        Symbol_Type=type;
    }

    string get_name()
    {
        return Symbol_Name;
    }
    string get_type()
    {
        return Symbol_Type;
    }
    string get_dectype()
    {
	return Declared_Type;
    }
    

};


///scopetable class
class ScopeTable
{
private:
    ScopeTable* parentScope;
    SymbolInfo** hash_table;
    int n;
    string id;

public:
    int next_id;
    ScopeTable(int n)
    {
        this->n=n;
        id = "1";
        next_id = 1;
        hash_table = new SymbolInfo*[n];
        for(int k=0; k<n; k++)
        {
            hash_table[k]=0;
        }
    }
    void set_id(string id)
    {
        this->id=id;
    }
    void set_parent(ScopeTable* parentScope)
    {
        this->parentScope=parentScope;
    }
    string get_id()
    {
        return id;
    }
    ScopeTable* get_parent()
    {
        return parentScope;
    }
    ScopeTable()
    {
        n=0;
        id="";
        parentScope=NULL;
    }
    int hashFunction(string name)
    {
        long long sum_of_ascii = 0;

        ///sum of ascii
        for(int i = 0; i < name.length(); i++)
        {
            sum_of_ascii += name[i];
        }
        return sum_of_ascii % this->n;
    }
    ///lookup
    SymbolInfo* Look_up(string name)
    {

        int position=0;
        int hash_value=hashFunction(name);
        SymbolInfo* temp = new SymbolInfo();
        temp=hash_table[hash_value];


        while(temp!=NULL)
        {

            if(temp->get_name()==name)
            {
                
                return temp;
            }
            temp=temp->next;
            position++;

        }
        return NULL;

    }
    ///insert
    bool Insert(string Symbol_name,string Symbol_type,string declared_type)
    {
        SymbolInfo *check=Look_up(Symbol_name);
        if(check != NULL)
        {
            
            return false;
        }
        int hash_value = hashFunction(Symbol_name);
        SymbolInfo* temp = new SymbolInfo();
        temp = hash_table[hash_value];
        if(temp == NULL)
        {
            ///insert new symbol
            hash_table[hash_value]= new SymbolInfo(Symbol_name,Symbol_type,declared_type);
            
            return true;
        }
        ///else chain hash
        else
        {
            SymbolInfo* prev;
            int pos=0;
            while(temp!=NULL)
            {
                prev=temp;
                temp=temp->next;
                pos++;
            }
            ///set next
            prev->next=new SymbolInfo(Symbol_name,Symbol_type,declared_type);
            
            return true;
        }

    }

    ///delete
    bool  Delete(string name)
    {
        SymbolInfo* check = Look_up(name);
        if(check == NULL)
        {
            
            return false;
        }
        int hash_value=hashFunction(name);
        SymbolInfo* temp;
        temp=hash_table[hash_value];

        if(temp->get_name()==name)
        {
            hash_table[hash_value]=temp->next;
            
            return true;
        }

        ///traverse through chain
        SymbolInfo* next;
        SymbolInfo* prev;
        next=temp;
        int pos=0;
        while(next->get_name()!= name)
        {
            prev=next;
            next=next->next;
            pos++;
        }
        prev->next=next->next;
        
        return true;


    }
    void Print()
    {
        ///cout<<"ScopeTable #"<<id<<endl;
        /*fprintf(logstatus," ScopeTable #%s\n",id.c_str());
        SymbolInfo *symbol;

        for (int i =0; i <n; i++)
        {
            //cout<<i<< " --> ";
            

            symbol = hash_table[i];

            if(symbol == NULL)
            {
                //cout<<endl;
                //fprintf(logstatus,"\n");
            }
            else
            {
            	fprintf(logstatus," %d-->",i);
                ///traverse
                while (symbol != NULL)
                {
                    
                    //cout << "<" << symbol->get_name() << " : " << symbol->get_type()<< "> ";
                    fprintf(logstatus,"< %s : %s >",symbol->get_name().c_str(),symbol->get_type().c_str());
                    symbol = symbol->next;
                }

                //cout<<endl;
                fprintf(logstatus,"\n");
            }
        }
        //cout<<endl<<endl;
        fprintf(logstatus,"\n");*/
    }
    ~ScopeTable()
    {
        for(int i=0;i<n;i++)
        {
            SymbolInfo* temp;
            temp=hash_table[i];
            while(temp!=NULL)
            {
                SymbolInfo* next=temp->next;
                delete(temp);
                temp=next;

            }
        }
        delete [] hash_table;
    }
};

///class symboltable

class SymbolTable
{
public:
    ScopeTable* current_scopetable;
    int n;
    string current_id;
    SymbolTable(int n)
    {
        this->n=n;
        current_id="0";
        current_scopetable =NULL;
        //cout<<"chole";
    }
    void Enter_Scope()
    {
        int next_counter;
        ScopeTable *new_scope=new ScopeTable(n);
        if(current_scopetable == NULL)
        {
            new_scope->set_parent(NULL);
            current_scopetable = new_scope;
            next_counter = 1;
        }
        else
        {
            new_scope->set_parent(current_scopetable);
            ///cout<<"chole"<<endl;
            next_counter = current_scopetable ->next_id;
            current_scopetable=new_scope;
        }
        if(current_scopetable->get_parent() == NULL)
        {
            current_id = "1";
        }
        else{
            stringstream ss;
            ss<<next_counter;
            current_id = ss.str();
            current_id = current_scopetable->get_parent()->get_id() + "." + current_id;
        }
        current_scopetable->set_id(current_id);
        if(current_id != "1")
        {
            
        }

    }
    void Exit_Scope()
    {
        if(current_id=="0")
        {
            
        }

        ScopeTable *temp = current_scopetable;
        current_scopetable=current_scopetable->get_parent();
        ///current_id = current_scopetable->get_id();
        current_scopetable->next_id = current_scopetable->next_id + 1;

        
        current_id = current_scopetable->get_id();
        delete temp;
    }
    bool Insert(string name,string type,string d_type)
    {
        ///check base case
        if(current_scopetable == NULL)
        {
            Enter_Scope();
            ///cout<<"chole"<<endl;
            bool check = current_scopetable->Insert(name,type,d_type);
            return check;
        }
        else
        {
            bool check = current_scopetable->Insert(name,type,d_type);
            return check;
        }
    }
    bool Remove(string name)
    {
        ///base case
        if(current_scopetable == NULL)
        {
            
            return false;
        }
        else
        {
            bool check = current_scopetable->Delete(name);
            if(check == false)
            {
                //cout<<name<<" not found"<<endl<<endl;
                //file2<<name<<" not found"<<"\n"<<"\n";
            }
            return check;
        }
    }
    SymbolInfo* LookUP(string name)
    {
        ScopeTable* temp = current_scopetable;

        ///traverse through scopes
        while(temp != NULL)
        {
            SymbolInfo* check = temp->Look_up(name);
            if(check != NULL)
            {
                return check ;
            }
            temp = temp ->get_parent();
        }
        
        return NULL;
    }
    void Print_Current_ScopeTable()
    {
        ///base case
        if(current_scopetable == NULL)
        {
            
            return;
        }
        current_scopetable->Print();
    }
    void Print_All_ScopeTable()
    {
        ScopeTable *temp = current_scopetable;

        ///TRAVERSE
        while(temp != NULL)
        {
            temp->Print();
            temp=temp ->get_parent();
        }
    }
    ~SymbolTable()
    {
        ScopeTable *temp = NULL;
        while(current_scopetable != NULL)
        {
            temp = current_scopetable;
            current_scopetable = current_scopetable->get_parent();
            delete temp;
        }
    }
};


#include "y.tab.h"
using namespace std;


extern int error_count;

extern int line_count;

extern YYSTYPE yylval;

extern FILE *error;
extern FILE *logfile;
extern string current_id;

void yyerror(char *);
extern SymbolTable table;


void yyerror(char *);




extern vector<SymbolInfo*>declared_list;
extern vector<SymbolInfo*>argument_list;

extern vector<SymbolInfo*>parameters;



string Extract_string(string str){

string temp;
temp+='\"';
//cout<<x.length()<<endl;
//cout<<str.length()<<endl;	
for(int i=0;i<str.length();i++){
	//cout<<i+1<<endl;
	//cout<<x[i]<<endl;
	if(str[i]=='\\' and str[i+1]=='t') temp+='\t';
	
	//carriage return
	else if(str[i]=='\\' and str[i+1]=='\r') continue;
	else if(str[i] == '\r' and str[i-1] == '\\') continue;
	else if(str[i]=='\n' and str[i-1] == '\r') continue;
	else if(str[i]=='t' and str[i-1]=='\\') continue; 
	//not carriage return
	else if(str[i]=='\\' and str[i+1]=='\n') continue;
	else if(str[i]=='\n' and str[i-1]=='\\') continue;
	else if(str[i]=='t' and str[i-1]=='\\') continue; 
	
	else if(str[i]=='\\' and str[i+1]=='n') temp+='\n';
	
	else if(str[i]=='n' and str[i-1]=='\\') continue;

	else if(i==0 || i==str.length()-1)  continue;
	
	else if(str[i]=='\\' and str[i+1]=='v') temp+='\v';
	
	else if(str[i]=='v'  and str[i-1]=='\\') continue;
	else if( str[i]=='\"' and str[i-1]=='\\') continue;
	else if(str[i]=='\'' and str[i-1]=='\\')  continue;
	
	else if(str[i]=='\\' and str[i+1]=='\"') temp+='\"';
	
	else if(str[i]=='\\' and str[i+1]=='a') temp+='\a';
	
	else if(str[i]=='\\' and str[i+1]=='b') temp+='\b';
	
	else if(str[i]=='\\' and str[i+1]=='r') temp+='\r';
	
	else if(str[i]=='\\' and str[i+1]=='f') temp+='\f';
	
	else if(str[i]=='\\' and str[i+1]=='\\') temp+='\\';
	
	else if(str[i]=='\\' and str[i+1]=='\'') temp+='\'';
	
	//do reverse of replace
	else if(str[i]=='\"' and str[i-1]=='\\') continue;
	
	else if(str[i]=='a' and str[i-1]=='\\') continue;
	
	else if(str[i]=='b' and str[i-1]=='\\') continue;
	
	else if(str[i]=='r' and str[i-1] == '\\') continue;
	
	else if(str[i]=='f' and str[i-1]=='\\') continue;
	
	else if(str[i]=='\\' and str[i-1]=='\\') continue;
	
	else if(str[i]=='\'' and str[i-1]=='\\') continue;
	//else if(x[i]== '\n') continue;
	
	else  temp+=str[i];
	//cout<<temp[j]<<endl;
	
	}
	temp+='\"';

	temp+='\0';
	
	//cout<<"chole"<<endl;

	return temp;

}

//comment extract
string Extract_comment(string str){

string temp;
	
for(int i=0;i<str.length();i++){
	
	if(str[i]=='\\' and str[i+1]=='t') temp+='\t';
	
	//carriage return
	else if(str[i]=='\\' and str[i+1]=='\r') continue;
	else if(str[i] == '\r' and str[i+1] == '\n') continue;
	else if(str[i]=='\n' and str[i-1] == '\r') continue;
	else if(str[i] == '\n') continue;
	else if(str[i]=='t' and str[i-1]=='\\') continue; 
	//not carriage return
	else if(str[i]=='\\' and str[i+1]=='\n') continue;
	else if(str[i]=='\n' and str[i-1]=='\\') continue;
	else if(str[i]=='t' and str[i-1]=='\\') continue; 
	
	else if(str[i]=='\\' and str[i+1]=='n') temp+='\n';
	
	else if(str[i]=='n' and str[i-1]=='\\') continue;

	//else if(i==0 || i==str.length()-1)  continue;
	
	else if(str[i]=='\\' and str[i+1]=='v') temp+='\v';
	
	else if(str[i]=='v'  and str[i-1]=='\\') continue;
	else if( str[i]=='\"' and str[i-1]=='\\') continue;
	else if(str[i]=='\'' and str[i-1]=='\\')  continue;
	
	//replace
	else if(str[i]=='\\' and str[i+1]=='\"') temp+='\"';
	
	else if(str[i]=='\\' and str[i+1]=='a') temp+='\a';
	
	else if(str[i]=='\\' and str[i+1]=='b') temp+='\b';
	
	else if(str[i]=='\\' and str[i+1]=='r') temp+='\r';
	
	else if(str[i]=='\\' and str[i+1]=='f') temp+='\f';
	
	else if(str[i]=='\\' and str[i+1]=='\\') temp+='\\';
	
	else if(str[i]=='\\' and str[i+1]=='\'') temp+='\'';
	
	//do reverse of replace
	else if(str[i]=='\"' and str[i-1]=='\\') continue;
	
	else if(str[i]=='a' and str[i-1]=='\\') continue;
	
	else if(str[i]=='b' and str[i-1]=='\\') continue;
	
	else if(str[i]=='r') continue;
	
	else if(str[i]=='f' and str[i-1]=='\\') continue;
	
	else if(str[i]=='\\' and str[i-1]=='\\') continue;
	
	else if(str[i]=='\'' and str[i-1]=='\\') continue;
	//else if(x[i]== '\n') continue;
	
	else  temp+=str[i];
	//cout<<temp[j]<<endl;
	
	}

	temp+='\0';
	
	//cout<<"chole"<<endl;

	return temp;
}

int Line_Inc(string str,int line){

	//int a=0;
	
	for(int i=0;i<str.length();i++){
		//cout<<str[i]<<" ";
		if(str[i]=='\n'){
		 //cout<<i<<" ";
		 line++;
		 //cout<<"barau"<<x[i];
		 }
		
		
	
	}

	return line;

}
 

char Update_Char(char *s){
	//cout<<"chole"<<endl;
	if(s[1]=='\\'){

		if(s[2]=='n') return '\n';

		else if(s[2]=='t') return '\t';

		else if(s[2]=='a') return '\a';

		else if(s[2]=='v') return '\v';

		else if(s[2]=='0') return '\0';

		else if(s[2]=='f') return '\f';

		else if(s[2]=='r') return '\r';

		else if(s[2]=='\\') return '\\';

		else if(s[2]=='\"') return '\"';

		else if(s[2]=='b') return '\b';

	}

	return s[1];

}



%}


WHITESPACE [ \t\f\r\v]+

DIGIT [0-9]

LETTER [a-zA-Z]

NEWLINE [\n]

ALPHANUMERIC [^\f\r\v\n\'\a]

STRING \"([^"\\\n]|\\(.|\r?\n))*\"

COMMENT "/*"([^*]|("*"[^/]))*"*/"

SINGLE_LINE_COMMENT "//"([^\n]|\\(.|\r?\n))*


CHAR [a-zA-Z\\n]

%%
{WHITESPACE}	{}


{NEWLINE}	{ line_count++;
	          
                }


"if"		{ SymbolInfo *s= new  SymbolInfo(yytext,"IF");
			yylval.symbolinfo=s;
			return IF;
		}


"else"		{ SymbolInfo *s= new  SymbolInfo(yytext,"ELSE");
			yylval.symbolinfo=s;
			return ELSE;
		}


"break"		{ SymbolInfo *s= new  SymbolInfo(yytext,"BREAK");
			yylval.symbolinfo=s;
			return BREAK;
		}


"while"		{ SymbolInfo *s= new  SymbolInfo(yytext,"WHILE");
			yylval.symbolinfo=s;
			return WHILE;
		}


"for"		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"FOR");
			yylval.symbolinfo=s;
			return FOR;
		}


"do"		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"DO");
			yylval.symbolinfo=s;
			return DO;
		}


"case"		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CASE");
			yylval.symbolinfo=s;
			return CASE;
		}


"switch"		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"SWITCH");
			yylval.symbolinfo=s;
			return SWITCH;
		}


"default"		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"DEFAULT");
			yylval.symbolinfo=s;
			return DEFAULT;
		}


"continue"		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CONTINUE");
			yylval.symbolinfo=s;
			return CONTINUE;
		}


"int"		{ SymbolInfo *s= new  SymbolInfo(yytext, "INT");
			yylval.symbolinfo= s;
			return INT;
		}


"float"		{ SymbolInfo *s= new  SymbolInfo(yytext,"FLOAT");
			yylval.symbolinfo=s;
			return FLOAT;
		}


"void"		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"VOID");
			yylval.symbolinfo=s;
			return VOID;
		}


"return"	{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RETURN");
			yylval.symbolinfo=s;
			return RETURN;
		}


"char"		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CHAR");
			yylval.symbolinfo=s;
			return CHAR;
		}


"double"	{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"DOUBLE");
			yylval.symbolinfo=s;
			return DOUBLE;
		}
"println"	{	return PRINTLN;
		}


{DIGIT}+	{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CONST_INT");
			yylval.symbolinfo=s;
			return CONST_INT;
		}


\'({LETTER}{1}|(\\[\\abfnrtv]))\'		{ 
  			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CONST_CHAR");
			yylval.symbolinfo=s;
			return CONST_CHAR;
		}


{SINGLE_LINE_COMMENT}		{ 
	/*fprintf( logstatus,"Line no. %d: TOKEN <COMMENT> lexeme %s found\n\n", line_count,yytext);

				line_count=Line_Inc(yytext,line_count);*/
	
			}


{COMMENT}			{ 

		//fprintf( logstatus,"Line no. %d: TOKEN <COMMENT> lexeme %s found\n\n", line_count,yytext);

				line_count=Line_Inc(yytext,line_count);
				}


"+"|"-"		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ADDOP");
			yylval.symbolinfo=s;
			return ADDOP;
			
		}


"*"|"/"|"%"	{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"MULOP");
			yylval.symbolinfo=s;
			return MULOP;
			
		}


"++"		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"INCOP");
			yylval.symbolinfo=s;
			return INCOP;
		}
"--"		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"DECOP");
			yylval.symbolinfo=s;
			return DECOP;
		}


"<"|"<="|">"|">="|"=="|"!="      { SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RELOP");
			yylval.symbolinfo=s;
			return RELOP;
		}


"="   		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ASSIGNOP");
			yylval.symbolinfo=s;
			return ASSIGNOP;
		}


"&&"|"||"	{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LOGICOP");
			yylval.symbolinfo=s;
			return LOGICOP;
		}





"!"		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"NOT");
			yylval.symbolinfo=s;
			return NOT;
			
		}


"("		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LPAREN");
			yylval.symbolinfo=s;
			return LPAREN;
		  	
		}


")"		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RPAREN");
			yylval.symbolinfo=s;
			return RPAREN;
		}


"{"		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LCURL");
			yylval.symbolinfo=s;
			return LCURL;
		}


"}"		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RCURL");
			yylval.symbolinfo=s;
			return RCURL;
		}


"["		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"LTHIRD");
			yylval.symbolinfo=s;
			return LTHIRD;
			
		}


"]"		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"RTHIRD");
			yylval.symbolinfo=s;
			return RTHIRD;
			
		}


","		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"COMMA");
			yylval.symbolinfo=s;
			return COMMA;
		}


";"		{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"SEMICOLON");
			yylval.symbolinfo=s;
			return SEMICOLON;
		}


({LETTER}|_)({LETTER}|{DIGIT}|_)*	{ SymbolInfo *s= new  SymbolInfo(yytext, (char *)"ID");
			yylval.symbolinfo=s;
			return ID;
		}


{DIGIT}({LETTER}|{DIGIT}|_)*	{ 
			fprintf(error,"Error at Line %d:  Invalid  Identifier %s \n",line_count,yytext);

			error_count++;
				}


{DIGIT}*\.{DIGIT}*(E[-+]?{DIGIT}+)?|{DIGIT}*E[-+]?{DIGIT}+                 { 
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"CONST_FLOAT");
			yylval.symbolinfo=s;
			return CONST_FLOAT;
		}


{DIGIT}*([\.]+{DIGIT}*)+[\.]*{DIGIT}*		{ 
			fprintf(error,"Error at Line %d: Too many decimal point %s \n",line_count,yytext);

			error_count++;
		}


\'{ALPHANUMERIC}{2,}\'	{ fprintf(error,"Error at Line %d: Multi Character constant error %s\n",line_count,yytext);

			error_count++;
			}


(\'{ALPHANUMERIC}*)|(\'\\\')		{ fprintf(error,"Error at Line %d: Unterminated Character %s\n\n", line_count,yytext);

			error_count++;
			}


\'\'			{ fprintf(error,"Error at Line %d: Empty Character %s\n\n", line_count,yytext);
			  fprintf(logfile,"Error at Line %d: Empty Character %s\n\n", line_count,yytext);

			error_count++;
			}


.			{ fprintf(error,"Error at Line %d: Unrecognized Character %s\n\n",line_count,yytext);
			  fprintf(logfile,"Error at Line %d: Unrecognized Character %s\n\n",line_count,yytext);

			error_count++;
			}


"/*"([^*]|("*"[^/]))*[^"*/"]	{ fprintf(error,"Error at Line %d: Unterminated Comment %s\n\n", line_count,Extract_comment(yytext).c_str());
			          fprintf(logfile,"Error at Line %d: Unterminated Comment %s\n\n", line_count,Extract_comment(yytext).c_str());
				//cout<<line_count<<endl;
				//cout<<yytext<<endl;
				line_count=Line_Inc(yytext,line_count);
				
				//cout<<line_count<<endl;
			error_count++;
			}


{DIGIT}+[\.]?{DIGIT}*[E][-+]?{DIGIT}+\.{DIGIT}*	{ fprintf(error,"Error at Line %d: Ill formed number %s \n\n",line_count,yytext);
					          fprintf(logfile,"Error at Line %d: Ill formed number %s \n\n",line_count,yytext);

					error_count++;
					}







{STRING}    			{
			line_count=Line_Inc(yytext,line_count);
			SymbolInfo *s= new  SymbolInfo(yytext, (char *)"STRING");
			yylval.symbolinfo=s;
			
			return STRING;

				//cout<<"chole"<<endl;
				}


\"([^\"\n]*([\\]([\r])?[\n])*|([\\][\"])*)*		{
 	
				fprintf(error,"Error at Line %d: Unterminated string %s\n\n", line_count,yytext);
				fprintf(logfile,"Error at Line %d: Unterminated string %s\n\n", line_count,yytext);

				line_count=Line_Inc(yytext,line_count);

			error_count++;
			}




%%

/*int main(int argc,char *argv[]){

	if(argc!=2){

		printf("ERROR.TRY AGAIN\n");

		return 0;
	}
	//cout<<"chole"<<endl;

	
	FILE *fin=fopen(argv[1],"r");

	if(fin==NULL){

		printf("Cannot open The file\n");

		return 0;
	}
	fprintf(logstatus,"\n");




	yyin= fin;
	yylex();

	fclose(yyin);
	table.Print_All_ScopeTable();
	fprintf(logstatus,"\nTotal Lines : %d\nTotal Errors : %d\n\n",line_count,error_count);


	fclose(token);

	fclose(logstatus);

	return 0;

}*/
			
