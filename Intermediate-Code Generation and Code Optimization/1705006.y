%{
#include<iostream>
#include<cstdio>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include<sstream>
#include<bits/stdc++.h>
#include <fstream>
using namespace std;

FILE * logfile= fopen("1705006_log.txt","w");

FILE *error= fopen("1705006_error.txt","w");

//------------------symbol table -------------------------//

string tostring(int i)
{
	ostringstream temp;
	temp<<i;
	return temp.str();
}
class SymbolInfo
{
private:
    string Symbol_Name,Symbol_Type,Declared_Type;
public:
    SymbolInfo *next;
    //---------------further add-----------------//
    string arr_size;
    string code;
    string id_value;
    vector<string> func_vars;
    
    //------------------additional members for function ----------------//
    vector<string>parameter_name;
    vector<string>parameter_type;
    string return_type;
    bool isDefined;
    bool isDeclared;
    //-------------------end -----------------------------//

    ///constructors

    SymbolInfo()
    {
        Symbol_Name = "";
        Symbol_Type = "";
        Declared_Type = "";
        return_type="";
		code="";
		id_value="";
		arr_size="";
        isDefined=false;
        isDeclared = false;
        next=NULL;
        parameter_name.clear();
		parameter_type.clear();
		func_vars.clear();
	
	
    }
    SymbolInfo(string name,string type,string d_type="")
    {
        Symbol_Name=name;
        Symbol_Type=type;
        Declared_Type = d_type;
        return_type="";
		code="";
		id_value="";
		arr_size="";
        isDefined=false;
        isDeclared = false;
        next=NULL;
        parameter_name.clear();
		parameter_type.clear();
		func_vars.clear();
    }
    ///getter & setter
    void set_name(string name)
    {
        Symbol_Name=name;
    }
    void set_type(string type)
    {
        Symbol_Type=type;
    }
    //-----------set declared type----------//
    void set_declaredtype(string type)
    {
	Declared_Type=type;
    }
	//-------------adding function variable -------//
	void add_variable(string name)
	{
		func_vars.push_back(name);
	}
	//------------clear parameters -----------//
	void CleanUp(){
		parameter_name.clear();
		parameter_type.clear();
	}
    
    
    
    //---------------parameter add -----------//
    void add_parameters(string name,string type)
    {
	parameter_name.push_back(name);
	parameter_type.push_back(type);
    }

    string get_name()
    {
        return Symbol_Name;
    }
    string get_type()
    {
        return Symbol_Type;
    }
    string get_declaredtype()
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
            SymbolInfo *temp = new SymbolInfo();
	    temp->set_name(Symbol_name);
	    temp->set_type(Symbol_type);
	    temp->set_declaredtype(declared_type);
            hash_table[hash_value]=temp;
            //hash_table[hash_value]= new SymbolInfo(Symbol_name,Symbol_type,declared_type);
            
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
            SymbolInfo *temp = new SymbolInfo();
	    temp->set_name(Symbol_name);
	    temp->set_type(Symbol_type);
	    temp->set_declaredtype(declared_type);
            
            prev->next=temp;
            //prev->next=new SymbolInfo(Symbol_name,Symbol_type,declared_type);
            
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
        
        fprintf(logfile,"ScopeTable # %s\n",id.c_str());
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
            	fprintf(logfile," %d -->",i);
                ///traverse
                while (symbol != NULL)
                {
                    
                    //cout << "<" << symbol->get_name() << " : " << symbol->get_type()<< "> ";
                    fprintf(logfile," < %s , %s >",symbol->get_name().c_str(),symbol->get_type().c_str());
                    symbol = symbol->next;
                }

                //cout<<endl;
                fprintf(logfile,"\n");
            }
        }
        //cout<<endl<<endl;
        fprintf(logfile,"\n");
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
            current_id = current_scopetable->get_parent()->get_id() + "_" + current_id;
        }
        current_scopetable->set_id(current_id);
        
        
        if(current_id != "1")
        {
            //fprintf(logfile,"\n New ScopeTable with id %s created\n",this->current_id.c_str());
        }

    }
    void Exit_Scope()
    {
        if(current_id=="0")
        {
            
        }
        //fprintf(logfile,"ScopeTable with id %s removed\n",this->current_id.c_str());

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
    SymbolInfo* current_Lookup(string name)
    {
	if(current_scopetable != NULL)
	{
		return current_scopetable->Look_up(name);
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
        fprintf(logfile,"\n\n");
        while(temp != NULL)
        {
            temp->Print();
            temp=temp ->get_parent();
        }
    }
    string get_current_id(){
	return current_scopetable->get_id();

    }
    string get_next_id(){
	/*int next_counter;
	if(current_scopetable == NULL)
        {
            next_counter = 1;
            
        }
        else
        {
            next_counter = current_scopetable ->next_id;
        }
	if(current_scopetable->get_parent() == NULL)
        {
            return "1";
            
        }
        else{
            stringstream ss;
            ss<<next_counter;
            return current_scopetable->get_parent()->get_id() + "_" + ss.str();
        }*/
        int next;
        next = current_scopetable ->next_id;
        stringstream ss;
        ss<<next;
        
        return current_id+"_"+ss.str();
    }
    string searchID(string name)
	{
		ScopeTable *temp;

        temp=current_scopetable;

        while(temp)
        {
            SymbolInfo* s=temp->Look_up(name);
            if(s!=NULL)
            {
                return temp->get_id();
            }
            temp=temp->get_parent();
        }
        return "";

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
//-----------------------end of symbol table -----------------------//


using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
FILE *fp;


int line_count=1;
int error_count=0;
int error_check = 0;
int func_syntex_error = 0;

SymbolTable table(30);





string ret_Type="";
int array_size=0;
void yyerror(const char *s)
{
	fprintf(error,"Error at line %d: %s\n\n",line_count,s);
	fprintf(logfile,"Error at line %d: %s\n\n",line_count,s);
	error_count++;
}
//---------------all variable vectors declaration--------//
vector<string>var_declaredList;
vector<string>func_var_declaredList;
vector<pair<string,string> >arr_var_declaredList;
vector<string>optional_list;
//--------------end vectors--------------//

//------------label counts-------------//
int label_count = 0;
int check_count = 0;
//--------------end of count------------//
string current_function_name="";
void optimization(FILE *asmcode);


//-----------additional function---------------//
char *newTemp()
{
	char *temp= new char[4];
	strcpy(temp,"t");
	char temp2[3];
	sprintf(temp2,"%d", check_count);              //------------temporary reg--------------//
	check_count++;
	strcat(temp,temp2);
	return temp;
}
char *newLabel()
{
	char *label= new char[4];
	strcpy(label,"L");
	char temp[3];
	sprintf(temp,"%d", label_count);             //------------label count -----------------//
	label_count++;
	strcat(label,temp);
	return label;
}


//vector for function declaration

vector<SymbolInfo*>argument_list;

vector<SymbolInfo*>parameters;

vector<SymbolInfo*>declared_list;
%}

%token IF ELSE FOR WHILE DO BREAK INT FLOAT CHAR DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE CONST_INT CONST_FLOAT CONST_CHAR ADDOP MULOP INCOP ASSIGNOP NOT DECOP LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON STRING ID PRINTLN

%left ADDOP 
%left MULOP
%right ASSIGNOP 
%right NOT
%nonassoc THAN
%nonassoc ELSE
%nonassoc RELOP 
%nonassoc LOGICOP
%union
{
        SymbolInfo* symbolinfo;
		
}



%%

start : program
	{
		//write your code in this block in all the tempmilar blocks below
		//fprintf(logfile,"Line %d: start : program \n\n",line_count-1);
		if(error_count == 0){
			string asmcodes = "";
			asmcodes +=".MODEL SMALL\n.STACK 100H\n.DATA\n";
			for(int i = 0;i<var_declaredList.size();i++){
				asmcodes+=var_declaredList[i]+" dw ?\n";

			}
			for(int i =0;i<arr_var_declaredList.size();i++){
				asmcodes+=arr_var_declaredList[i].first+" dw "+arr_var_declaredList[i].second+" dup(?)\n";
			}
			$<symbolinfo>1->code=asmcodes+".CODE\n"+$<symbolinfo>1->code;        //print proc
			$<symbolinfo>1->code=$<symbolinfo>1->code+"PRINT PROC \n\
	PUSH AX \n\
    PUSH BX \n\
    PUSH CX \n\
    PUSH DX  \n\
    CMP AX,0 \n\ 
    JGE END_IF1 \n\ 
    PUSH AX \n\
    MOV DL,'-' \n\ 
    MOV AH,2 \n\
    INT 21H \n\ 
    POP AX \n\ 
    NEG AX \n\ 
    END_IF1: \n\ 
    XOR CX,CX \n\ 
    MOV BX,10 \n\ 
    REPEAT: \n\
    XOR DX,DX \n\ 
    IDIV BX \n\
    PUSH DX \n\
    INC CX \n\
    OR AX,AX \n\ 
    JNE REPEAT \n\
    MOV AH,2 \n\ 
    PRINT_LOOP: \n\ 
    POP DX \n\ 
    ADD DL,30H \n\
    INT 21H \n\
    LOOP PRINT_LOOP \n\ 
    MOV AH,2\n\
    MOV DL,10\n\
    INT 21H\n\
    MOV DL,13\n\
    INT 21H\n\
    POP DX \n\ 
    POP CX \n\
    POP BX \n\ 
    POP AX \n\
    ret \n\
PRINT ENDP \n\
END MAIN\n";
	FILE* asmcode= fopen("code.asm","w");
	 
	fprintf(asmcode,"%s",$<symbolinfo>1->code.c_str());
	fclose(asmcode);
	asmcode= fopen("code.asm","r");
	optimization(asmcode);                    //optimize
		}
	}
	;

program : program unit {fprintf(logfile,"Line %d: program : program unit\n\n",line_count);
			fprintf(logfile,"%s%s",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>2->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+$<symbolinfo>2->get_name());
			$<symbolinfo>$->code=$<symbolinfo>1->code+$<symbolinfo>2->code;
			}
	| unit{
		fprintf(logfile,"Line %d: program : unit\n\n",line_count);
		fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
		$<symbolinfo>$=new SymbolInfo();
		$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
		$<symbolinfo>$->code=$<symbolinfo>1->code;
	      }
	;
	
unit : var_declaration {
			fprintf(logfile,"Line %d: unit : var_declaration\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"\n");
			func_var_declaredList.clear();
			$<symbolinfo>$->code=$<symbolinfo>1->code;
			}
     | func_declaration {
			fprintf(logfile,"Line %d: unit : func_declaration\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str());
			$<symbolinfo>$=new SymbolInfo(); 
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"\n");
			$<symbolinfo>$->code=$<symbolinfo>1->code;
			}
     | func_definition {
			fprintf(logfile,"Line %d: unit : func_definition\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str());
			$<symbolinfo>$=new SymbolInfo(); 
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"\n");
			$<symbolinfo>$->code=$<symbolinfo>1->code;
			}
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
			fprintf(logfile,"Line %d: func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n\n",line_count);
			table.Enter_Scope();
			table.Exit_Scope();
			fprintf(logfile,"%s %s(%s);\n\n",$<symbolinfo>1->get_name().c_str(),
			$<symbolinfo>2->get_name().c_str(),$<symbolinfo>4->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			
			SymbolInfo* temp = table.LookUP($<symbolinfo>2->get_name());
			if(temp == NULL)                 //if null insert
			{
				table.Insert($<symbolinfo>2->get_name(),"ID","function");
				temp = table.LookUP($<symbolinfo>2->get_name());
				
				int count=0;
				while(count<parameters.size())
				{
					temp->add_parameters(parameters[count]->get_name(),parameters[count]->get_declaredtype());
					count++;
				}
				parameters.clear();
				
				temp->return_type=$<symbolinfo>1->get_name();
				temp->isDeclared = true;
			}
			else
			{
				int size = temp->parameter_name.size();
				if(size!=parameters.size())                    //parameter size not matching
				{
					error_count++;
					fprintf(error,"Error at line %d: Invalid number of parameters.\n\n",line_count);
					fprintf(logfile,"Error at line %d: Invalid number of parameters.\n\n",line_count);
				}
				if(temp->return_type!=$<symbolinfo>1->get_name())              //return type not matching
				{
					error_count++;
					fprintf(error,"Error at line %d: Return type Mismatch.\n\n",line_count);
					fprintf(logfile,"Error at line %d: Return type Mismatch.\n\n",line_count);
				}
				if(size==parameters.size())
				{
					int count=0;
					while(count<parameters.size())
					{
						if(temp->parameter_type[count]!=parameters[count]->get_declaredtype())       //parameter type not matching
						{
							error_count++;
							fprintf(error,"Error at line %d: Parameter type Mismatch.\n\n",line_count);
							fprintf(logfile,"Error at line %d: Parameter type Mismatch.\n\n",line_count);	
							break;
						}
						count++;
					}
					
				}
				parameters.clear();
			}

			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+" "+$<symbolinfo>2->get_name()+"("+$<symbolinfo>4->get_name()+");");
			}
		| type_specifier ID LPAREN RPAREN SEMICOLON { 
			table.Enter_Scope();
			table.Exit_Scope();
			fprintf(logfile,"Line %d: func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n\n",line_count);
			fprintf(logfile,"%s %s();\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>2->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			SymbolInfo* temp=table.LookUP($<symbolinfo>2->get_name());
			if(temp==NULL)
			{
				table.Insert($<symbolinfo>2->get_name(),"ID","function");
				temp=table.LookUP($<symbolinfo>2->get_name());
				temp->return_type=$<symbolinfo>1->get_name();
				temp->isDeclared = true;
			}
			else
			{
				if(temp->return_type!=$<symbolinfo>1->get_name())
				{
					error_count++;
					fprintf(error,"Error at line %d: Return type Mismatch.\n\n",line_count);
					fprintf(logfile,"Error at line %d: Return type Mismatch.\n\n",line_count);
				}
				if(temp->parameter_name.size()!=0)
				{
					error_count++;
					fprintf(error,"Error at line %d: Invalid number of parameters.\n\n",line_count);
					fprintf(logfile,"Error at line %d: Invalid number of parameters.\n\n",line_count);
				}
			}
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+" "+$<symbolinfo>2->get_name()+"();");
			}
		| type_specifier ID LPAREN RPAREN error {
			//error_count++;                      //syntex error
			
		}
		| type_specifier ID LPAREN parameter_list RPAREN error	{
			//error_count++;                      //syntex error
			
		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN{
			SymbolInfo *temp = table.LookUP($<symbolinfo>2->get_name());
			ret_Type=$<symbolinfo>1->get_name();
			if(temp == NULL)
			{
				table.Insert($<symbolinfo>2->get_name(),"ID","function");
				temp = table.LookUP($<symbolinfo>2->get_name());
				temp->return_type = $<symbolinfo>1->get_name();
				temp->isDefined = true;
				int count = 0;
				while(count<parameters.size())
				{
					temp->add_parameters(parameters[count]->get_name() +table.get_next_id(),parameters[count]->get_declaredtype());
					
					count++;
				}
				
				for(int i=0;i<parameters.size();i++)
				{
					if(temp->parameter_name[i] == "" || parameters[i]->get_name() == "")
					{
						error_count++;
						fprintf(error,"Error at line %d: Missing of parameter's name\n\n",line_count);
						fprintf(logfile,"Error at line %d: Missing of parameter's name\n\n",line_count);
						break;
					}
				}
			
			}
			else if(temp->isDefined == true)
			{
				error_count++;
				fprintf(error,"Error at line %d: Multiple defination of function %s\n\n",
				line_count,$<symbolinfo>2->get_name().c_str());
				fprintf(logfile,"Error at line %d: Multiple defination of function %s\n\n",
				line_count,$<symbolinfo>2->get_name().c_str());
			}
			else if(temp->isDefined == false && temp->return_type == "")
			{
				error_count++;
				fprintf(error,"Error at line %d: Multiple declaration of %s\n\n",          
				line_count,$<symbolinfo>2->get_name().c_str());
				fprintf(logfile,"Error at line %d: Multiple declaration of %s\n\n",
				line_count,$<symbolinfo>2->get_name().c_str());
				temp->isDefined = false;
			}
			
			else if(temp->isDefined==false)
			{
				
				
				if(temp->return_type!=$<symbolinfo>1->get_name())
				{	if(func_syntex_error == 0){
						error_count++;
						fprintf(error,"Error at line %d: Return Type Mismatch with function declaration in function %s \n\n",line_count,$<symbolinfo>2->get_name().c_str());
						fprintf(logfile,"Error at line %d: Return Type Mismatch with function declaration in function %s \n\n",line_count,$<symbolinfo>2->get_name().c_str());
					}
					else{
						func_syntex_error == 0;
					}

				}
				if(temp->parameter_name.size()!=parameters.size())
				{
					
					error_count++;
					fprintf(error,"Error at line %d: Total number of arguments mismatch with declaration in function %s \n\n",line_count,$<symbolinfo>2->get_name().c_str());
					fprintf(logfile,"Error at line %d: Total number of arguments mismatch with declaration in function %s \n\n",line_count,$<symbolinfo>2->get_name().c_str());
				}
				if(temp->parameter_name.size()==parameters.size())
				{
					
					for(int i=0;i<parameters.size();i++)
					{
						if(temp->parameter_type[i] != parameters[i]->get_declaredtype())
						{
							error_count++;
							fprintf(error,"Error at line %d: Parameter Type Mismatch\n\n",line_count);
							fprintf(logfile,"Error at line %d: Parameter Type Mismatch\n\n",line_count);
							break;
						}
					}
					for(int i=0;i<parameters.size();i++)
					{
						if(temp->parameter_name[i] == "" || parameters[i]->get_name() == "")
						{
							error_count++;
							fprintf(error,"Error at line %d: Missing of parameter's name\n\n",line_count);
							fprintf(logfile,"Error at line %d: Missing of parameter's name\n\n",line_count);
							break;
						}
					}
				}
				
				temp->isDefined = true;
				temp ->CleanUp();
				int k = 0;
				while(k<parameters.size()){
					temp->add_parameters(parameters[k]->get_name()+table.get_next_id(),parameters[k]->get_declaredtype());
					k++;
				}
				
			}
			current_function_name=$<symbolinfo>2->get_name();
			var_declaredList.push_back(current_function_name+"_return");


			
} compound_statement {
			/*if(ret_Type!=$<symbolinfo>1->get_name())
			{
				
				if(func_syntex_error == 0){
					error_count++;
					fprintf(error,"Error at line %d: Return Type Mismatch \n\n",line_count);
					fprintf(logfile,"Error at line %d: Return Type Mismatch \n\n",line_count);
				}
				else{
					func_syntex_error == 0;
				}
			}*/
			//ret_Type="void";
			fprintf(logfile,"Line %d: func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n\n",line_count);
			fprintf(logfile,"%s %s(%s)%s\n\n",$<symbolinfo>1->get_name().c_str(),
			$<symbolinfo>2->get_name().c_str(),$<symbolinfo>4->get_name().c_str(),$<symbolinfo>7->get_name().c_str());
			
			$<symbolinfo>$=new SymbolInfo(); 
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+" "+$<symbolinfo>2->get_name()+"("
			+$<symbolinfo>4->get_name()+")"+$<symbolinfo>7->get_name());
			$<symbolinfo>$->code=";line -->"+ tostring(line_count)+"\n"+$<symbolinfo>2->get_name()+" PROC\n";
			if($<symbolinfo>2->get_name()=="main"){
				$<symbolinfo>$->code=$<symbolinfo>$->code+"\tMOV AX,@DATA\n\tMOV DS,AX \n"+$<symbolinfo>7->code+"Return"+current_function_name+":\n\tMOV AH,4CH\n\tINT 21H\n";
			}
			else{
				//SymbolInfo *temp=table.LookUP($<symbolinfo>2->get_name()); 

				
										
				string asmcodes=$<symbolinfo>$->code+"\tPUSH AX\n\tPUSH BX \n\tPUSH CX \n\tPUSH DX\n";
				
				
				asmcodes+=$<symbolinfo>7->code+"Return"+current_function_name+":\n";
				
				
				asmcodes+="\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tret\n";
				$<symbolinfo>$->code=asmcodes+$<symbolinfo>2->get_name()+" ENDP\n";
			}
			}
		| type_specifier ID LPAREN RPAREN{
			
		  	SymbolInfo *temp = table.LookUP($<symbolinfo>2->get_name());
			if(temp == NULL)
			{
				table.Insert($<symbolinfo>2->get_name(),"ID","function");
				temp =table.LookUP($<symbolinfo>2->get_name());
				temp->return_type=$<symbolinfo>1->get_name();
				temp->isDefined = true;
			}
			else if(temp->isDefined == false)
			{
				if(temp->return_type!=$<symbolinfo>1->get_name())
				{
					if(func_syntex_error == 0){
						error_count++;
						fprintf(error,"Error at line %d: Return Type Mismatch. \n\n",line_count);
						fprintf(logfile,"Error at line %d: Return Type Mismatch. \n\n",line_count);
					}
					else{
						func_syntex_error == 0;
					}
				}
				if(temp->parameter_name.size()!=0)
				{
					error_count++;
					fprintf(error,"Error at line %d: Total number of arguments mismatch with declaration in function %s \n\n",line_count,$<symbolinfo>2->get_name().c_str());
					fprintf(logfile,"Error at line %d: Total number of arguments mismatch with declaration in function %s \n\n",line_count,$<symbolinfo>2->get_name().c_str());
				}
				temp->isDefined=true;
			}
			else if(temp->isDefined==true)
			{
				error_count++;
				fprintf(error,"Error at line %d: Multiple defination of function %s\n\n",
				line_count,$<symbolinfo>2->get_name().c_str());
				fprintf(logfile,"Error at line %d: Multiple defination of function %s\n\n",
				line_count,$<symbolinfo>2->get_name().c_str());
			}
			current_function_name=$<symbolinfo>2->get_name();
			var_declaredList.push_back(current_function_name+"_return");



		 
		} compound_statement {
			/*if(ret_Type!=$<symbolinfo>1->get_name())
			{
				
				if(func_syntex_error == 0){
					error_count++;
					fprintf(error,"Error at line %d: Return Type Mismatch.... \n\n",line_count);
					fprintf(logfile,"Error at line %d: Return Type Mismatch.... \n\n",line_count);
				}
				else{
					func_syntex_error == 0;
				}
				
			}*/
			//ret_Type="void";
			fprintf(logfile,"Line %d: func_definition : type_specifier ID LPAREN RPAREN compound_statement\n\n",line_count);
			fprintf(logfile,"%s %s()%s\n\n",$<symbolinfo>1->get_name().c_str(),
			$<symbolinfo>2->get_name().c_str(),$<symbolinfo>6->get_name().c_str()); 
			
			$<symbolinfo>$=new SymbolInfo();

			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+" "+$<symbolinfo>2->get_name()+"()"+$<symbolinfo>6->get_name());
			$<symbolinfo>$->code=";line -->"+ tostring(line_count)+"\n"+$<symbolinfo>2->get_name()+" PROC\n";
			if($<symbolinfo>2->get_name()=="main"){
				$<symbolinfo>$->code=$<symbolinfo>$->code+"\tMOV AX,@DATA\n\tMOV DS,AX \n"+$<symbolinfo>6->code+"Return"+current_function_name+":\n\tMOV AH,4CH\n\tINT 21H\n";
			}
			else{
				SymbolInfo *temp=table.LookUP($<symbolinfo>2->get_name()); 

				
									
				string asmcodes=$<symbolinfo>$->code+"\tPUSH AX\n\tPUSH BX \n\tPUSH CX \n\tPUSH DX\n";
				
				asmcodes+=$<symbolinfo>6->code+"Return"+current_function_name+":\n";
				

				asmcodes+="\tPOP DX\n\tPOP CX\n\tPOP BX\n\tPOP AX\n\tret\n";
				$<symbolinfo>$->code=asmcodes+$<symbolinfo>2->get_name()+" ENDP\n";
			}
			}
		
 		;				


parameter_list  : parameter_list COMMA type_specifier ID {
			fprintf(logfile,"Line %d: parameter_list : parameter_list COMMA type_specifier ID\n\n",line_count);
			fprintf(logfile,"%s,%s %s\n\n",$<symbolinfo>1->get_name().c_str(),
			$<symbolinfo>3->get_name().c_str(),$<symbolinfo>4->get_name().c_str()); 
			
			$<symbolinfo>$=new SymbolInfo();
			SymbolInfo *temp = new SymbolInfo();
			temp->set_name($<symbolinfo>4->get_name());
			temp->set_type("ID");
			temp->set_declaredtype($<symbolinfo>3->get_name());
			for(int i=0;i<parameters.size();i++)
			{
				if($<symbolinfo>4->get_name()==parameters[i]->get_name())
				{
				error_count++;
				fprintf(error,"Error at line %d: Multiple Declaration of %s in parameter\n\n",line_count,$<symbolinfo>4->get_name().c_str());
				fprintf(logfile,"Error at line %d: Multiple Declaration of %s in parameter\n\n",line_count,$<symbolinfo>4->get_name().c_str());
				}
			}
			
			parameters.push_back(temp);
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+","+$<symbolinfo>3->get_name()+" "+$<symbolinfo>4->get_name());
			}
		| parameter_list COMMA type_specifier {
			fprintf(logfile,"Line %d: parameter_list : parameter_list COMMA type_specifier\n\n",line_count);
			fprintf(logfile,"%s,%s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>3->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			SymbolInfo *temp = new SymbolInfo();
			temp->set_name("");
			temp->set_type("ID");
			temp->set_declaredtype($<symbolinfo>3->get_name());
			parameters.push_back(temp);
			
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+","+$<symbolinfo>3->get_name());
			}
 		| type_specifier ID {
			fprintf(logfile,"Line %d: parameter_list : type_specifier ID\n\n",line_count);
			fprintf(logfile,"%s  %s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>2->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			SymbolInfo *temp=new SymbolInfo();
			temp->set_name($<symbolinfo>2->get_name());
			temp->set_type("ID");
			temp->set_declaredtype($<symbolinfo>1->get_name());
			parameters.push_back(temp);
			
			
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+" "+$<symbolinfo>2->get_name());
			}
		| type_specifier { 
			fprintf(logfile,"Line %d: parameter_list : type_specifier\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			SymbolInfo *temp=new SymbolInfo();
			temp->set_name($<symbolinfo>1->get_name());
			
			
			parameters.push_back(temp);
			//table.Enter_Scope();
			
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			}
		| type_specifier error ADDOP{
			
			//fprintf(error,"Error at line %d : syntex error\n\n",line_count);
			//error_count++;
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
			fprintf(error,"Error at line %d: 1th parameter's name not given in function definition of var\n\n",line_count);
			fprintf(logfile,"Error at line %d: 1th parameter's name not given in function definition of var\n\n",line_count);
			func_syntex_error = 1;
			/*$<symbolinfo>$=new SymbolInfo();
			SymbolInfo *temp=new SymbolInfo();
			temp->set_name($<symbolinfo>1->get_name());
			
			
			parameters.push_back(temp);*/
			
			error_count++;
		}
		| type_specifier error {
			
			//fprintf(error,"Error at line %d : syntex error\n\n",line_count);
			//error_count++;
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
			fprintf(error,"Error at line %d: 1th parameter's name not given in function definition of var\n\n",line_count);
			fprintf(logfile,"Error at line %d: 1th parameter's name not given in function definition of var\n\n",line_count);
			func_syntex_error = 1;
			/*$<symbolinfo>$=new SymbolInfo();
			SymbolInfo *temp=new SymbolInfo();
			temp->set_name($<symbolinfo>1->get_name());
			
			
			parameters.push_back(temp);*/
			
			error_count++;
		}
		| error{
		
		}
		
			
 		;

 		
compound_statement : LCURL{
			table.Enter_Scope();
			int count = 0;
			
			while(count<parameters.size())
			{
				table.Insert(parameters[count]->get_name(),"ID",parameters[count]->get_declaredtype());
				var_declaredList.push_back(parameters[count]->get_name()+table.get_current_id());
				count++;
			}
			parameters.clear();

} statements RCURL {
			
			fprintf(logfile,"Line %d: compound_statement : LCURL statements RCURL\n\n",line_count);
			fprintf(logfile,"{\n%s\n}\n",$<symbolinfo>3->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_name("{\n"+$<symbolinfo>3->get_name()+"\n}");
			$<symbolinfo>$->code=$<symbolinfo>3->code;
			table.Print_All_ScopeTable();
			table.Exit_Scope();
			}
 		    | LCURL RCURL {
			table.Enter_Scope();
			int count=0;
			while(count<parameters.size())
			{
				table.Insert(parameters[count]->get_name(),"ID",parameters[count]->get_declaredtype());
				var_declaredList.push_back(parameters[count]->get_name()+table.get_current_id());
				count++;
			}
			
			parameters.clear();
			fprintf(logfile,"Line %d: compound_statement : LCURL RCURL\n\n",line_count);
			fprintf(logfile,"{}\n\n"); 
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_name("{}");
			table.Print_All_ScopeTable();
			table.Exit_Scope();
			}
 		    ;

var_declaration : type_specifier declaration_list SEMICOLON {
			fprintf(logfile,"Line %d: var_declaration : type_specifier declaration_list SEMICOLON\n\n",line_count);
			
			$<symbolinfo>$=new SymbolInfo();
			if($<symbolinfo>1->get_name()!="void")
			{
				int count=0;
				
				while(count<declared_list.size())
				{
					SymbolInfo *temp=table.current_Lookup(declared_list[count]->get_name());
					if(temp)
					{
						error_count++;
						fprintf(error,"Error at line %d: Multiple Declaration of %s\n\n",
						line_count,declared_list[count]->get_name().c_str());
						fprintf(logfile,"Error at line %d: Multiple Declaration of %s\n\n",
						line_count,declared_list[count]->get_name().c_str());
						 
					} 
		       			else
				   	{
						if(declared_list[count]->get_type()=="ARRAY_ID")                    //array type declaration
						{
							declared_list[count]->set_type("ID");
							table.Insert(declared_list[count]->get_name(),declared_list[count]->get_type(),
							$<symbolinfo>1->get_name()+"array");
							//array var
							arr_var_declaredList.push_back(make_pair(declared_list[count]->get_name()+table.get_current_id(),declared_list[count]->arr_size));
						}
						else if(declared_list[count]->get_type()=="ID")             ///normal declaration
						{
							table.Insert(declared_list[count]->get_name(),declared_list[count]->get_type(),
							$<symbolinfo>1->get_name());
							var_declaredList.push_back(declared_list[count]->get_name()+table.get_current_id());
							func_var_declaredList.push_back(declared_list[count]->get_name()+table.get_current_id());
						}
					}
					count++;
				}
			
			}
			else if($<symbolinfo>1->get_name()=="void")
			{
				error_count++;
				fprintf(error,"Error at line %d: Variable type can not be void\n\n",line_count);
				fprintf(logfile,"Error at line %d: Variable type can not be void\n\n",line_count);
			}
			fprintf(logfile,"%s %s;\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>2->get_name().c_str()); 
			declared_list.clear();
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+" "+$<symbolinfo>2->get_name()+";");
			}
		|	type_specifier declaration_list error	{
				//error_count++;
		}
 		 ;
 		 
type_specifier	: INT {
			fprintf(logfile,"Line %d: type_specifier : INT\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			}
 		| FLOAT {
			fprintf(logfile,"Line %d: type_specifier : FLOAT\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			}
 		| VOID {
			fprintf(logfile,"Line %d: type_specifier : VOID\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			}
 		;
 		
declaration_list : declaration_list COMMA ID { 
			fprintf(logfile,"Line %d: declaration_list : declaration_list COMMA ID\n\n",line_count);
			fprintf(logfile,"%s,%s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>3->get_name().c_str());
			$<symbolinfo>$=new SymbolInfo(); 
			SymbolInfo *temp=new SymbolInfo();
			temp->set_name($<symbolinfo>3->get_name());
			temp->set_type("ID");                                 //adding vars to declaration list (normal)
			temp->set_declaredtype("");
			declared_list.push_back(temp);
			
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+","+$<symbolinfo>3->get_name());
			}
 		  | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
			fprintf(logfile,"Line %d: declaration_list : declaration_list COMMA ID LTHIRD CONST_INT RTHIRD\n\n",line_count);
			fprintf(logfile,"%s,%s[%s]\n\n",$<symbolinfo>1->get_name().c_str(),
			$<symbolinfo>3->get_name().c_str(),$<symbolinfo>5->get_name().c_str());
			 
			$<symbolinfo>$=new SymbolInfo();
			SymbolInfo *temp=new SymbolInfo();                                 ////adding vars to declaration list (array)
			temp->set_name($<symbolinfo>3->get_name());
			temp->set_type("ARRAY_ID");
			temp->set_declaredtype("");
			temp->arr_size=$<symbolinfo>5->get_name();
			declared_list.push_back(temp);
			
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+","+$<symbolinfo>3->get_name()+"["+$<symbolinfo>5->get_name()+"]");
			}
 		  | ID {
			fprintf(logfile,"Line %d: declaration_list : ID\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str());
			$<symbolinfo>$=new SymbolInfo(); 
			SymbolInfo *temp=new SymbolInfo();
			temp->set_name($<symbolinfo>1->get_name());
			temp->set_type("ID");
			temp->set_declaredtype("");
			declared_list.push_back(temp);
			
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			}
 		  | ID LTHIRD CONST_INT RTHIRD {
			fprintf(logfile,"Line %d: declaration_list : ID LTHIRD CONST_INT RTHIRD\n\n",line_count);
			fprintf(logfile,"%s[%s]\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>3->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			
			//TAKING ARRAY SIZE
			stringstream temp_string($<symbolinfo>3->get_name());
			
			int to_int;
			temp_string >> to_int; 
			array_size = to_int;
			SymbolInfo *temp=new SymbolInfo();
			temp->set_name($<symbolinfo>1->get_name());
			temp->set_type("ARRAY_ID");
			
			temp->set_declaredtype("");
			temp->arr_size=$<symbolinfo>3->get_name();
			declared_list.push_back(temp);
			
			
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"["+$<symbolinfo>3->get_name()+"]");
			}
		  | ID ADDOP error ID{
		  	//error_count++;
		  	fprintf(logfile,"Line %d: declaration_list : ID\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str());
			$<symbolinfo>$=new SymbolInfo(); 
			SymbolInfo *temp=new SymbolInfo();
			temp->set_name($<symbolinfo>1->get_name());
			temp->set_type("ID");
			temp->set_declaredtype("");
			declared_list.push_back(temp);
			
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
		  	
		  
		  }
		  /*| error {
		  	//error_count++;
		  }*/
 		  ;
 		  
statements : statement { 
			fprintf(logfile,"Line %d: statements : statement\n\n",line_count);
			fprintf(logfile,"%s\n\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			$<symbolinfo>$->code=$<symbolinfo>1->code;
			}
	   | statements statement { 
			fprintf(logfile,"Line %d: statements : statements statement\n\n",line_count);
			fprintf(logfile,"%s\n%s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>2->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"\n"+$<symbolinfo>2->get_name());
			$<symbolinfo>$->code=$<symbolinfo>1->code+$<symbolinfo>2->code;
			}
	   
	   ;
	   
statement : var_declaration {
			fprintf(logfile,"Line %d: statement : var_declaration\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			}
	  | expression_statement {
			fprintf(logfile,"Line %d: statement : expression_statement\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str());
			$<symbolinfo>$=new SymbolInfo(); 
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			$<symbolinfo>$->code=$<symbolinfo>1->code;
			}
	  | compound_statement {
			fprintf(logfile,"Line %d: statement : compound_statement\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str());
			$<symbolinfo>$=new SymbolInfo(); 
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			$<symbolinfo>$->code=$<symbolinfo>1->code;
			}
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement  { 
			fprintf(logfile,"Line %d: statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n\n",line_count);
			fprintf(logfile,"for(%s%s%s)\n%s\n\n",$<symbolinfo>3->get_name().c_str(),
			$<symbolinfo>4->get_name().c_str(),$<symbolinfo>5->get_name().c_str(),$<symbolinfo>7->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			if($<symbolinfo>3->get_declaredtype()=="void")
			{
				error_count++;
				fprintf(error,"Error at line %d: Type Mismatch\n\n",line_count);
				fprintf(logfile,"Error at line %d: Type Mismatch\n\n",line_count);
			}
			else{
				//SEND loop CODE
				string asmcodes=$<symbolinfo>3->code;
				char *label1=newLabel();
				char *label2=newLabel();
				asmcodes+=string(label1)+":\n";
				asmcodes+=$<symbolinfo>4->code;
				asmcodes+="\tMOV AX,"+$<symbolinfo>4->id_value+"\n";
				asmcodes+="\tCMP AX,0\n";
				asmcodes+="\tJE "+string(label2)+"\n";
				asmcodes+=$<symbolinfo>7->code;
				asmcodes+=$<symbolinfo>5->code;
				asmcodes+="\tJMP "+string(label1)+"\n";
				asmcodes+=string(label2)+": \n";
				$<symbolinfo>$->code=";line -->"+tostring(line_count)+"\n"+asmcodes;
			}
			$<symbolinfo>$->set_name("for ("+$<symbolinfo>3->get_name()+$<symbolinfo>4->get_name()
			+$<symbolinfo>5->get_name()+")\n"+$<symbolinfo>7->get_name());
			}	
	  | IF LPAREN expression RPAREN statement %prec THAN {                       ///ambiguity resolved
			fprintf(logfile,"Line %d: statement : IF LPAREN expression RPAREN statement\n\n",line_count);
			fprintf(logfile,"if(%s)\n%s\n\n",$<symbolinfo>3->get_name().c_str(),$<symbolinfo>5->get_name().c_str());
			$<symbolinfo>$=new SymbolInfo(); 
			if($<symbolinfo>3->get_declaredtype()=="void")
			{
				error_count++;
				fprintf(error,"Error at line %d: Type Mismatch\n\n",line_count);
				fprintf(logfile,"Error at line %d: Type Mismatch\n\n",line_count);
			}
			else{
				//SEND CODES
				string asmcodes=$<symbolinfo>3->code;
				char *label1=newLabel();
				asmcodes+="\tMOV AX,"+$<symbolinfo>3->id_value+"\n";
				asmcodes+="\tCMP AX,0\n";
				asmcodes+="\tJE "+string(label1)+"\n";
				asmcodes+=$<symbolinfo>5->code;
				asmcodes+=string(label1)+":\n";
				$<symbolinfo>$->code=";line -->"+tostring(line_count)+"\n"+asmcodes;
			}
			$<symbolinfo>$->set_name("if ("+$<symbolinfo>3->get_name()+")\n"+$<symbolinfo>5->get_name());
			}	
	  | IF LPAREN expression RPAREN statement ELSE statement {
			fprintf(logfile,"Line %d: statement : IF LPAREN expression RPAREN statement ELSE statement\n\n",line_count);
			fprintf(logfile,"if(%s)\n%s\n else\n%s\n\n",$<symbolinfo>3->get_name().c_str(),
			$<symbolinfo>5->get_name().c_str(),$<symbolinfo>7->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			if($<symbolinfo>3->get_declaredtype()=="void")
			{
				error_count++;
				fprintf(error,"Error at line %d: Type Mismatch\n\n",line_count);
				fprintf(logfile,"Error at line %d: Type Mismatch\n\n",line_count);
			}
			else{
				string asmcodes=$<symbolinfo>3->code;
				char *label1=newLabel();
				char *label2=newLabel();
				asmcodes+="\tMOV AX,"+$<symbolinfo>3->id_value+"\n";
				asmcodes+="\tCMP AX,0\n";
				asmcodes+="\tJE "+string(label1)+"\n";
				asmcodes+=$<symbolinfo>5->code;
				asmcodes+="\tJMP "+string(label2)+"\n";
				asmcodes+=string(label1)+":\n";
				asmcodes+=$<symbolinfo>7->code;
				asmcodes+=string(label2)+":\n";
				$<symbolinfo>$->code=";line -->"+tostring(line_count)+"\n"+asmcodes;
			}
			$<symbolinfo>$->set_name("if ("+$<symbolinfo>3->get_name()+")\n"+
			$<symbolinfo>5->get_name()+"\n else\n"+$<symbolinfo>7->get_name());
			}	
	  | WHILE LPAREN expression RPAREN statement  { 
			fprintf(logfile,"Line %d: statement : WHILE LPAREN expression RPAREN statement\n\n",line_count);
			fprintf(logfile,"while(%s)\n%s\n\n",$<symbolinfo>3->get_name().c_str(),$<symbolinfo>5->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			if($<symbolinfo>3->get_declaredtype()=="void")
			{
				error_count++;
				fprintf(error,"Error at line %d: Type Mismatch\n\n",line_count);
				fprintf(logfile,"Error at line %d: Type Mismatch\n\n",line_count);
			}
			else{
				//SEND CODES
				string asmcodes="";
				char *label1=newLabel();
				char *label2=newLabel();
				asmcodes+=string(label1)+":\n";
				asmcodes+=$<symbolinfo>3->code;
				asmcodes+="\tMOV AX,"+$<symbolinfo>3->id_value+"\n";
				asmcodes+="\tCMP AX,0\n";
				asmcodes+="\tJE "+string(label2)+"\n";
				asmcodes+=$<symbolinfo>5->code;
				asmcodes+="\tJMP "+string(label1)+"\n";
				asmcodes+=string(label2)+":\n";
				$<symbolinfo>$->code=";line -->"+tostring(line_count)+"\n"+asmcodes;
			}
			$<symbolinfo>$->set_name("while ("+$<symbolinfo>3->get_name()+")\n"+$<symbolinfo>5->get_name());
			}	
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
			fprintf(logfile,"Line %d: statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n\n",line_count);
			fprintf(logfile,"\nprintf(%s);\n\n",$<symbolinfo>3->get_name().c_str()); 
			SymbolInfo *temp = table.LookUP($<symbolinfo>3->get_name());
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_name("\nprintln("+$<symbolinfo>3->get_name()+");");
			string asmcodes="";
			if(table.searchID($<symbolinfo>3->get_name())=="")
			{
				error_count++;
				fprintf(error,"Error at line %d: Undeclared variable %s\n\n",line_count,$<symbolinfo>3->get_name().c_str());
				fprintf(logfile,"Error at line %d: Undeclared variable %s\n\n",line_count,$<symbolinfo>3->get_name().c_str());
			}
			else{
											
				asmcodes+="\tMOV AX,"+$<symbolinfo>3->get_name()+table.searchID($<symbolinfo>3->get_name());
				asmcodes+="\n\tCALL PRINT\n";
			}
			$<symbolinfo>$->code=";line -->"+tostring(line_count)+"\n"+asmcodes;
			
			
			}
	  | RETURN expression SEMICOLON {
			fprintf(logfile,"Line %d: statement : RETURN expression SEMICOLON\n\n",line_count);
			fprintf(logfile,"return %s;\n\n\n",$<symbolinfo>2->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			if($<symbolinfo>2->get_declaredtype()=="void")
			{
				error_count++;
				fprintf(error,"Error at line %d: Type Mismatch\n\n",line_count);
				fprintf(logfile,"Error at line %d: Type Mismatch\n\n",line_count);
			}
			else{
				string asmcodes=$<symbolinfo>2->code;
			    	asmcodes+="\tMOV AX,"+$<symbolinfo>2->id_value+"\n";
				asmcodes+="\tMOV "+current_function_name+"_return,AX\n";
			    	asmcodes+="\tJMP Return"+current_function_name+"\n";
				$<symbolinfo>$->code=";line -->"+tostring(line_count)+"\n"+asmcodes;
			}
			//ret_Type=$<symbolinfo>2->get_declaredtype();
			$<symbolinfo>$->set_name("return "+$<symbolinfo>2->get_name()+";");
			}
		| RETURN expression error	{
			//error_count++;
		}
		| PRINTLN LPAREN ID RPAREN error	{
			//error_count++;
		}
		
	  ;
	  
expression_statement 	: SEMICOLON	{
			fprintf(logfile,"Line %d: expression_statement : SEMICOLON\n\n",line_count);
			fprintf(logfile,";\n\n"); 
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_name(";");
			}		
			| expression SEMICOLON {
			fprintf(logfile,"Line %d: expression_statement : expression SEMICOLON\n\n",line_count);
			$<symbolinfo>$=new SymbolInfo();
			fprintf(logfile,"%s;\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+";");
			$<symbolinfo>$->code=$<symbolinfo>1->code;
			$<symbolinfo>$->id_value=$<symbolinfo>1->id_value;
			
			}
			| error	{
				//error_count++;
			}
			| expression error	{
				//error_count++;
			}
			;
	  
variable : ID 	{ 
			fprintf(logfile,"Line %d: variable : ID\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str());
			$<symbolinfo>$=new SymbolInfo();
			SymbolInfo* temp = table.LookUP($<symbolinfo>1->get_name());
			if(temp == NULL)
			{
				error_count++;
				fprintf(error,"Error at line %d: Undeclared Variable %s\n\n",line_count,$<symbolinfo>1->get_name().c_str());
				fprintf(logfile,"Error at line %d: Undeclared Variable %s\n\n",line_count,$<symbolinfo>1->get_name().c_str());
			}
			else if(temp)
			{
				$<symbolinfo>$->set_declaredtype(temp->get_declaredtype());
				string id_val=table.searchID($<symbolinfo>1->get_name());
				
				$<symbolinfo>$->id_value=$<symbolinfo>1->get_name()+id_val;
				if(temp->get_declaredtype()=="intarray" || temp->get_declaredtype()=="floatarray")
				{
					//$<symbolinfo>1->set_name("error");
					//but no error count
					
				
				}
			}
			else if(temp != NULL){
			
				$<symbolinfo>$->set_declaredtype(temp->get_declaredtype());
			}
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			$<symbolinfo>$->set_type("notarray");
			}	
	 | ID LTHIRD expression RTHIRD { 
			fprintf(logfile,"Line %d: variable : ID LTHIRD expression RTHIRD\n\n",line_count);
			fprintf(logfile,"%s[%s]\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>3->get_name().c_str());
		    $<symbolinfo>$=new SymbolInfo();

			SymbolInfo* temp = table.LookUP($<symbolinfo>1->get_name());
			if(temp==NULL)
			{
				error_count++;
				fprintf(error,"Error at line %d: Undeclared Variable: %s\n",line_count,$<symbolinfo>1->get_name().c_str());
				fprintf(logfile,"Error at line %d: Undeclared Variable: %s\n",line_count,$<symbolinfo>1->get_name().c_str());
			}
			else if(temp)
			{
				
				if($<symbolinfo>3->get_declaredtype()!="int")
				{
					error_count++;
					fprintf(error,"Error at line %d: Expression inside third brackets not an integer  \n\n",line_count);
					fprintf(logfile,"Error at line %d: Expression inside third brackets not an integer  \n\n",line_count);
					string id_val=table.searchID($<symbolinfo>1->get_name());
				
					$<symbolinfo>$->id_value=$<symbolinfo>1->get_name()+id_val;
				}
				if(temp->get_declaredtype()=="intarray")
				{
					$<symbolinfo>1->set_declaredtype("int");
				}
				else if(temp->get_declaredtype()=="floatarray")
				{
					$<symbolinfo>1->set_declaredtype("float");
				}
			        else if(temp->get_declaredtype()!="intarray" && temp->get_declaredtype()!="floatarray")
				{
					error_count++;
					fprintf(error,"Error at line %d: %s is not an Array  \n\n",
					line_count,temp->get_name().c_str());
					fprintf(logfile,"Error at line %d: %s is not an Array  \n\n",
					line_count,temp->get_name().c_str());
				}
				$<symbolinfo>$->set_declaredtype($<symbolinfo>1->get_declaredtype());
				string asmcodes="";
				asmcodes+=$<symbolinfo>3->code;
				asmcodes+="\tMOV BX, "+$<symbolinfo>3->id_value+"\n";
				asmcodes+="\tADD BX,BX\n";
				string id_val=table.searchID($<symbolinfo>1->get_name());
				
				$<symbolinfo>$->id_value=$<symbolinfo>1->get_name()+id_val;
				$<symbolinfo>$->code=";line -->"+tostring(line_count)+"\n"+asmcodes;
				
			}
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"["+$<symbolinfo>3->get_name()+"]");
			$<symbolinfo>$->set_type("array");
			}
	 ;
	
	 
expression : logic_expression	{ 
			fprintf(logfile,"Line %d: expression : logic expression\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_declaredtype($<symbolinfo>1->get_declaredtype());
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			$<symbolinfo>$->code=";line -->"+tostring(line_count)+"\n"+$<symbolinfo>1->code;
			$<symbolinfo>$->id_value=$<symbolinfo>1->id_value;
			}
	   | variable ASSIGNOP logic_expression { 
			fprintf(logfile,"Line %d: expression : variable ASSIGNOP logic_expression\n\n",line_count);
			fprintf(logfile,"%s=%s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>3->get_name().c_str());
			$<symbolinfo>$=new SymbolInfo(); 
			
			
			if($<symbolinfo>3->get_declaredtype()=="void")
			{
				error_count++;
				fprintf(error,"Error at line %d: Void function used in expression  \n\n",line_count);
				fprintf(logfile,"Error at line %d: Void function used in expression  \n\n",line_count);
			    	$<symbolinfo>$->set_declaredtype("int");
			}
			//error recovery for float b = 2;
			else if($<symbolinfo>3->get_declaredtype()=="int" && $<symbolinfo>1->get_declaredtype()=="float")
			{
				//type cast
				//simply skip
			}
			
			else if($<symbolinfo>1->get_declaredtype()!="")
			{
				
				
				if($<symbolinfo>1->get_declaredtype()!=$<symbolinfo>3->get_declaredtype())
				{
					error_count++;
					if($<symbolinfo>1->get_declaredtype()=="intarray" || $<symbolinfo>1->get_declaredtype()=="floatarray")
					{
						fprintf(error,"Error at line %d: Type Mismatch,%s is an araay \n\n",line_count,$<symbolinfo>1->get_name().c_str());
						fprintf(logfile,"Error at line %d: Type Mismatch,%s is an araay \n\n",line_count,$<symbolinfo>1->get_name().c_str());
					
					
					}
					else{
						fprintf(error,"Error at line %d: Type mismatch  \n\n",line_count);
						fprintf(logfile,"Error at line %d: Type mismatch  \n\n",line_count);
					}
					
				}
				else{
						string asmcodes=$<symbolinfo>1->code;
						char *temp = newTemp();
						if($<symbolinfo>1->get_type() != "notarray")
						{
						     asmcodes+="\tMOV " + string(temp) + ",BX\n";
						}
						asmcodes+=$<symbolinfo>3->code;
						asmcodes+="\tMOV AX,"+$<symbolinfo>3->id_value+"\n";
						if($<symbolinfo>1->get_type()=="notarray"){
													
													
							asmcodes+="\tMOV "+$<symbolinfo>1->id_value+",AX\n";
						}
						else{
							asmcodes+="\tMOV BX," + string(temp) + "\n";
							asmcodes+="\tMOV "+$<symbolinfo>1->id_value+"[BX],AX\n";
							
							var_declaredList.push_back(string(temp));
							optional_list.push_back(string(temp));
						}
						$<symbolinfo>$->code=";line -->"+tostring(line_count)+"\n"+asmcodes;

						$<symbolinfo>$->id_value=$<symbolinfo>1->id_value;
					}
			}
			


			$<symbolinfo>$->set_declaredtype($<symbolinfo>1->get_declaredtype());
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"="+$<symbolinfo>3->get_name());
			}	
	   ;
			
logic_expression : rel_expression { 
			fprintf(logfile,"Line %d: logic_expression : rel_expression\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_declaredtype($<symbolinfo>1->get_declaredtype());
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			$<symbolinfo>$->code=$<symbolinfo>1->code;
			$<symbolinfo>$->id_value=$<symbolinfo>1->id_value;
			}	
		 | rel_expression LOGICOP rel_expression { 
			fprintf(logfile,"Line %d: logic_expression : rel_expression LOGICOP rel_expression\n\n",line_count);
			fprintf(logfile,"%s%s%s\n\n",$<symbolinfo>1->get_name().c_str(),
			$<symbolinfo>2->get_name().c_str(),$<symbolinfo>3->get_name().c_str());
			 
			$<symbolinfo>$=new SymbolInfo();
			if($<symbolinfo>1->get_declaredtype()=="void" || $<symbolinfo>3->get_declaredtype()=="void")
			{
					error_count++;
					fprintf(error,"Error at line %d:  Void function used in expression  \n\n",line_count);
					fprintf(logfile,"Error at line %d:  Void function used in expression  \n\n",line_count);
					$<symbolinfo>$->set_declaredtype("int");
			}
			else{
				string asmcodes=$<symbolinfo>1->code;
				asmcodes+=$<symbolinfo>3->code;
				char *label1=newLabel();
				char *label2=newLabel();
				char *label3=newLabel();
				char *t=newTemp();
				if($<symbolinfo>2->get_name()=="&&"){
					asmcodes+="\tMOV AX,"+$<symbolinfo>1->id_value+"\n";
					asmcodes+="\tCMP AX,0\n";
					asmcodes+="\tJE "+string(label2)+"\n";
			        	asmcodes+="\tMOV AX,"+$<symbolinfo>3->id_value+"\n";
			        	asmcodes+="\tCMP AX,0\n";
		            		asmcodes+="\tJE "+string(label2)+"\n";
					asmcodes+=string(label1)+":\n";
				   	asmcodes+="\tMOV "+string(t)+",1\n";
	                		asmcodes+="\tJMP "+string(label3)+"\n";
			        	asmcodes+=string(label2)+":\n";
		            		asmcodes+="\tMOV "+string(t)+",0\n";
		            		asmcodes+=string(label3)+":\n";
				}
				else if($<symbolinfo>2->get_name()=="||"){
					asmcodes+="\tMOV AX,"+$<symbolinfo>1->id_value+"\n";
					asmcodes+="\tCMP AX,0\n";
					asmcodes+="\tJNE "+string(label2)+"\n";
					asmcodes+="\tMOV AX,"+$<symbolinfo>3->id_value+"\n";
					asmcodes+="\tCMP AX,0\n";
					asmcodes+="\tJNE "+string(label2)+"\n";
		            		asmcodes+=string(label1)+":\n";
                    			asmcodes+="\tMOV "+string(t)+",0\n";
					asmcodes+="\tJMP "+string(label3)+"\n";
		            		asmcodes+=string(label2)+":\n";
			        	asmcodes+="\tMOV "+string(t)+",1\n";
					asmcodes+=string(label3)+":\n";
				}
				$<symbolinfo>$->code=asmcodes;
				$<symbolinfo>$->id_value=string(t);
				var_declaredList.push_back(string(t));
				optional_list.push_back(string(t));

			}
			$<symbolinfo>$->set_declaredtype("int");
		
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+$<symbolinfo>2->get_name()+$<symbolinfo>3->get_name());
			}	
		 ;
			
rel_expression	: simple_expression {
			fprintf(logfile,"Line %d: rel_expression : simple_expression\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_declaredtype($<symbolinfo>1->get_declaredtype());
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			$<symbolinfo>$->code=$<symbolinfo>1->code;
			$<symbolinfo>$->id_value=$<symbolinfo>1->id_value;
			}
		| simple_expression RELOP simple_expression { 
			fprintf(logfile,"Line %d: rel_expression : simple_expression RELOP simple_expression\n\n",line_count);
			fprintf(logfile,"%s%s%s\n\n",$<symbolinfo>1->get_name().c_str(),
			$<symbolinfo>2->get_name().c_str(),$<symbolinfo>3->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			if($<symbolinfo>1->get_declaredtype()=="void" || $<symbolinfo>3->get_declaredtype()=="void"){
					error_count++;
					fprintf(error,"Error at line %d: Void function used in expression  \n\n",line_count);
					fprintf(logfile,"Error at line %d: Void function used in expression  \n\n",line_count);
					$<symbolinfo>$->set_declaredtype("int");
			}
			else{
				string asmcodes=$<symbolinfo>1->code;
				asmcodes+=$<symbolinfo>3->code;
				char *label1=newLabel();
				char *label2=newLabel();
				
				char *t=newTemp();
				asmcodes+="\tMOV AX,"+$<symbolinfo>1->id_value+"\n";
				asmcodes+="\tCMP AX,"+$<symbolinfo>3->id_value+"\n";
				if($<symbolinfo>2->get_name()=="<"){
					asmcodes+="\tJL "+string(label1)+"\n";

				}
				else if($<symbolinfo>2->get_name()==">"){
					asmcodes+="\tJG "+string(label1)+"\n";

				}
				else if($<symbolinfo>2->get_name()=="<="){
					asmcodes+="\tJLE "+string(label1)+"\n";

				}
				else if($<symbolinfo>2->get_name()==">="){
					asmcodes+="\tJGE "+string(label1)+"\n";

				}
				else if($<symbolinfo>2->get_name()=="=="){
					asmcodes+="\tJE "+string(label1)+"\n";

				}
				else if($<symbolinfo>2->get_name()=="!="){
					asmcodes+="\tJNE "+string(label1)+"\n";
				}
				asmcodes+="\tMOV "+string(t)+",0\n";
				asmcodes+="\tJMP "+string(label2)+"\n";
				asmcodes+=string(label1)+":\n";
				asmcodes+="\tMOV "+string(t)+",1\n";
				asmcodes+=string(label2)+":\n";
				$<symbolinfo>$->code=asmcodes;
				$<symbolinfo>$->id_value=string(t);
				var_declaredList.push_back(string(t));
				optional_list.push_back(string(t));

			}
			$<symbolinfo>$->set_declaredtype("int");
			
		
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+$<symbolinfo>2->get_name()+$<symbolinfo>3->get_name());
			}	
		;
				
simple_expression : term { 
			fprintf(logfile,"Line %d: simple_expression : term\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_declaredtype($<symbolinfo>1->get_declaredtype());
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			$<symbolinfo>$->code=$<symbolinfo>1->code;
			$<symbolinfo>$->id_value=$<symbolinfo>1->id_value;
			}
		  | simple_expression ADDOP term { 
			fprintf(logfile,"Line %d: simple_expression : simple_expression ADDOP term\n\n",line_count);
			fprintf(logfile,"%s%s%s\n\n",$<symbolinfo>1->get_name().c_str(),
			$<symbolinfo>2->get_name().c_str(),$<symbolinfo>3->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			if($<symbolinfo>1->get_declaredtype()=="float" || $<symbolinfo>3->get_declaredtype()=="float")
			{
				$<symbolinfo>$->set_declaredtype("float");
				string asmcodes=$<symbolinfo>1->code+$<symbolinfo>3->code;

				asmcodes+="\tMOV AX,"+$<symbolinfo>1->id_value+"\n";
				char *temp=newTemp();
				if($<symbolinfo>2->get_name()=="+"){
					asmcodes+="\tADD AX,"+$<symbolinfo>3->id_value+"\n";
				}
				else{
					asmcodes+="\tSUB AX,"+$<symbolinfo>3->id_value+"\n";

				}
				asmcodes+="\tMOV "+string(temp)+",AX\n";
				$<symbolinfo>$->code=asmcodes;
				$<symbolinfo>$->id_value=string(temp);
				var_declaredList.push_back(string(temp));
				optional_list.push_back(string(temp));
			}
			else if($<symbolinfo>1->get_declaredtype()=="int" && $<symbolinfo>3->get_declaredtype()=="int"){
					$<symbolinfo>$->set_declaredtype("int");
					string asmcodes=$<symbolinfo>1->code+$<symbolinfo>3->code;

					asmcodes+="\tMOV AX,"+$<symbolinfo>1->id_value+"\n";
					char *temp=newTemp();
					if($<symbolinfo>2->get_name()=="+"){
						asmcodes+="\tADD AX,"+$<symbolinfo>3->id_value+"\n";
					}
					else{
						asmcodes+="\tSUB AX,"+$<symbolinfo>3->id_value+"\n";

					}
					asmcodes+="\tMOV "+string(temp)+",AX\n";
					$<symbolinfo>$->code=asmcodes;
					$<symbolinfo>$->id_value=string(temp);
					var_declaredList.push_back(string(temp));
					optional_list.push_back(string(temp));
			}
			else if($<symbolinfo>1->get_declaredtype()=="void" || $<symbolinfo>3->get_declaredtype()=="void"){
					error_count++;
					fprintf(error,"Error at line %d:  Void function used in expression  \n\n",line_count);
					fprintf(logfile,"Error at line %d:  Void function used in expression  \n\n",line_count);
					$<symbolinfo>$->set_declaredtype("int");
			}
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+$<symbolinfo>2->get_name()+$<symbolinfo>3->get_name());
			}
		  ;
					
term :	unary_expression {
			fprintf(logfile,"Line %d: term : unary_expression\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo(); 
			$<symbolinfo>$->set_declaredtype($<symbolinfo>1->get_declaredtype());
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			$<symbolinfo>$->code=$<symbolinfo>1->code;
			$<symbolinfo>$->id_value=$<symbolinfo>1->id_value;
			}
     |  term MULOP unary_expression { 
			fprintf(logfile,"Line %d: term : term MULOP unary_expression\n\n",line_count);
			fprintf(logfile,"%s%s%s\n\n",$<symbolinfo>1->get_name().c_str(),
			$<symbolinfo>2->get_name().c_str(),$<symbolinfo>3->get_name().c_str());
			$<symbolinfo>$=new SymbolInfo();
			
			//check divisible by zero
			
			if($<symbolinfo>2->get_name()=="*"){
				if($<symbolinfo>1->get_declaredtype()=="float"||$<symbolinfo>3->get_declaredtype()=="float"){
					$<symbolinfo>$->set_declaredtype("float");
				}
				else if($<symbolinfo>1->get_declaredtype()=="int" && $<symbolinfo>3->get_declaredtype()=="int"){
					$<symbolinfo>$->set_declaredtype("int");
				}
				string asmcodes=$<symbolinfo>1->code+$<symbolinfo>3->code;
				char *temp=newTemp();
				asmcodes+="\tMOV AX,"+$<symbolinfo>1->id_value+"\n";
				asmcodes+="\tMOV BX,"+$<symbolinfo>3->id_value+"\n";             //mul operation
				asmcodes+="\tIMUL BX\n";
				asmcodes+="\tMOV "+string(temp)+",AX\n";
				$<symbolinfo>$->code=asmcodes;
				$<symbolinfo>$->id_value=string(temp);
				var_declaredList.push_back(string(temp));
				optional_list.push_back(string(temp));
				
			}
			
			else if($<symbolinfo>2->get_name()=="/"){
 				if($<symbolinfo>1->get_declaredtype()=="float"||$<symbolinfo>3->get_declaredtype()=="float"){
					$<symbolinfo>$->set_declaredtype("float"); 
				}
				else if($<symbolinfo>1->get_declaredtype()=="int" && $<symbolinfo>3->get_declaredtype()=="int"){
					$<symbolinfo>$->set_declaredtype("int");
				}
				string asmcodes=$<symbolinfo>1->code+$<symbolinfo>3->code;
				char *temp=newTemp();
				asmcodes+="\tMOV AX,"+$<symbolinfo>1->id_value+"\n";
				asmcodes+="\tMOV BX,"+$<symbolinfo>3->id_value+"\n";
				asmcodes+="\tXOR DX,DX\n";
				asmcodes+="\tIDIV BX\n";
				asmcodes+="\tMOV "+string(temp)+",AX\n";
				$<symbolinfo>$->code=asmcodes;
				$<symbolinfo>$->id_value=string(temp);
				var_declaredList.push_back(string(temp));
				optional_list.push_back(string(temp));
				//check divisible by zero
			
				if($<symbolinfo>3->get_name()=="0"){
					fprintf(error,"Error at line %d: divide by Zero  \n\n",line_count);
					fprintf(logfile,"Error at line %d: divide by Zero  \n\n",line_count);
					error_count++;
				
				}
			}
			else if($<symbolinfo>2->get_name()=="%"){
				 //check divisible by zero
				 if($<symbolinfo>3->get_name()=="0"){
					fprintf(error,"Error at line %d: Modulus by Zero  \n\n",line_count);
					fprintf(logfile,"Error at line %d: Modulus by Zero  \n\n",line_count);
					error_count++;
				
				 }
				 else if($<symbolinfo>1->get_declaredtype()!="int" ||$<symbolinfo>3->get_declaredtype()!="int"){
					error_count++;
					fprintf(error,"Error at line %d: Non-Integer operand on modulus operator  \n\n",line_count);
					fprintf(logfile,"Error at line %d: Non-Integer operand on modulus operator  \n\n",line_count);
				 } 
				 $<symbolinfo>$->set_declaredtype("int");
				string asmcodes=$<symbolinfo>1->code+$<symbolinfo>3->code;
				char *temp=newTemp();
				asmcodes+="\tMOV AX,"+$<symbolinfo>1->id_value+"\n";
				asmcodes+="\tMOV BX,"+$<symbolinfo>3->id_value+"\n";
				asmcodes+="\tMOV DX,0\n";
				asmcodes+="\tIDIV BX\n";
				asmcodes+="\tMOV "+string(temp)+",DX\n";
				$<symbolinfo>$->code=";line -->"+tostring(line_count)+"\n"+asmcodes;
				$<symbolinfo>$->id_value=string(temp);
				var_declaredList.push_back(string(temp));
				optional_list.push_back(string(temp));
					 
				$<symbolinfo>$->set_declaredtype("int");
			}
			else if($<symbolinfo>1->get_declaredtype()=="void" || $<symbolinfo>3->get_declaredtype().c_str() == "void"){
					error_count++;
					fprintf(error,"Error at line %d: Void function used in expression \n\n",line_count);
					fprintf(logfile,"Error at line %d: Void function used in expression  \n\n",line_count);
					$<symbolinfo>$->set_declaredtype("int");
			}
			//fprintf(logfile,"%s  \n\n",$<symbolinfo>3->get_declaredtype().c_str());
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+$<symbolinfo>2->get_name()+$<symbolinfo>3->get_name());
			}
     ;


unary_expression : ADDOP unary_expression  {
			fprintf(logfile,"Line %d: unary_expression : ADDOP unary_expression\n\n",line_count);
			fprintf(logfile,"%s%s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>2->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo(); 
			if($<symbolinfo>2->get_declaredtype()=="void")
			{
				error_count++;
				fprintf(error,"Error at line %d: Void function used in expression\n\n",line_count);
				fprintf(logfile,"Error at line %d: Void function used in expression\n\n",line_count);
				$<symbolinfo>$->set_declaredtype("int");
			}else
			{
				string asmcodes=$<symbolinfo>2->code;               
				if($<symbolinfo>1->get_name()=="-"){
					asmcodes+="\tMOV AX,"+$<symbolinfo>2->id_value+"\n";          //negation
					asmcodes+="\tNEG AX\n";
					asmcodes+="\tMOV "+$<symbolinfo>2->id_value+",AX\n";

				}
				$<symbolinfo>$->code=asmcodes;
				$<symbolinfo>$->id_value=$<symbolinfo>2->id_value;
				$<symbolinfo>$->set_declaredtype($<symbolinfo>2->get_declaredtype());
			}
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+$<symbolinfo>2->get_name());
			}
		 | NOT unary_expression {
			fprintf(logfile,"Line %d: unary_expression : NOT unary expression\n\n",line_count);
			fprintf(logfile,"!%s\n\n",$<symbolinfo>2->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo(); 
			if($<symbolinfo>2->get_declaredtype()=="void")
			{
				error_count++;
				fprintf(error,"Error at line %d: Void function used in expression\n\n",line_count);
				fprintf(logfile,"Error at line %d: Void function used in expression\n\n",line_count);
				$<symbolinfo>$->set_declaredtype("int");
			}else
			{
				string asmcodes=$<symbolinfo>2->code;
				
				asmcodes+="\tMOV AX,"+$<symbolinfo>2->id_value+"\n";
				asmcodes+="\tNOT AX\n";
				asmcodes+="\tMOV "+$<symbolinfo>2->id_value+",AX\n";
				$<symbolinfo>$->code=asmcodes;
				$<symbolinfo>$->id_value=$<symbolinfo>2->id_value;
				$<symbolinfo>$->set_declaredtype("int");
			}
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+$<symbolinfo>2->get_name());
			}
		 | factor { 
			fprintf(logfile,"Line %d: unary_expression : factor\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str());
			$<symbolinfo>$=new SymbolInfo(); 
			$<symbolinfo>$->set_declaredtype($<symbolinfo>1->get_declaredtype()); 
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			$<symbolinfo>$->code=$<symbolinfo>1->code;
			$<symbolinfo>$->id_value=$<symbolinfo>1->id_value;
			}
		 ;
	
factor	: variable {
			fprintf(logfile,"Line %d: factor : variable\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo(); 
			$<symbolinfo>$->set_declaredtype($<symbolinfo>1->get_declaredtype());
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			string asmcodes=$<symbolinfo>1->code;
			if($<symbolinfo>1->get_type()=="array"){                //checking [] array type
				char *temp=newTemp();
				asmcodes+="\tMOV AX,"+$<symbolinfo>1->id_value+"[BX]\n";
				asmcodes+="\tMOV "+string(temp)+",AX\n";
				var_declaredList.push_back(string(temp));
				optional_list.push_back(string(temp));
				$<symbolinfo>$->id_value=string(temp);

			}
			else if($<symbolinfo>1->get_type()=="notarray"){
				$<symbolinfo>$->id_value=$<symbolinfo>1->id_value;

			}

			$<symbolinfo>$->code=asmcodes;
			}
	| ID LPAREN argument_list RPAREN  { 
			fprintf(logfile,"Line %d: factor : ID LPAREN argument_list RPAREN\n\n",line_count);
			//fprintf(logfile,"%s(%s)\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>3->get_name().c_str()); 
			
			int check = 0;
			$<symbolinfo>$=new SymbolInfo(); 
			SymbolInfo* temp=table.LookUP($<symbolinfo>1->get_name());
			for(int i=0;i<func_var_declaredList.size();i++){
				temp->add_variable(func_var_declaredList[i]);
			}
			func_var_declaredList.clear();
			if(temp==NULL)
			{
				check = 1;
				error_count++;
				fprintf(error,"Error at line %d: Undeclared Function %s \n\n",line_count,$<symbolinfo>1->get_name().c_str());
				fprintf(logfile,"Error at line %d : Undeclared Function %s \n\n",line_count,$<symbolinfo>1->get_name().c_str());
				//$<symbolinfo>3->set_name("error");
				//fprintf(logfile,"%s(error)\n\n",$<symbolinfo>1->get_name().c_str());
				$<symbolinfo>$->set_declaredtype("int"); 
			}
			else if(temp->parameter_name.size()==0 && temp->return_type=="" && temp->parameter_type.size()==0)
			{
				check = 1;
				error_count++;
				fprintf(error,"Error at line %d: Not A Function \n\n",line_count);
				fprintf(logfile,"Error at line %d: Not A Function \n\n",line_count);
				//$<symbolinfo>3->set_name("error");
				//fprintf(logfile,"%s(error)\n\n",$<symbolinfo>1->get_name().c_str());
				$<symbolinfo>$->set_declaredtype("int");
			}
			else 
			{
				if(temp->isDefined==false && temp->isDeclared == false)
				{
					check = 1;
					error_count++;
					fprintf(error,"Error at line %d: Undefined Function \n\n",line_count);
					fprintf(logfile,"Error at line %d: Undefined Function \n\n",line_count);
					//$<symbolinfo>3->set_name("error");
					//fprintf(logfile,"%s(error)\n\n",$<symbolinfo>1->get_name().c_str());
					$<symbolinfo>$->set_declaredtype("int");
				}
				
			    	int size=temp->parameter_name.size();
				$<symbolinfo>$->set_declaredtype(temp->return_type);
				
				if(size==argument_list.size())
				{
					string asmcodes=$<symbolinfo>3->code;
					for(int i = 0;i<temp->parameter_name.size();i++)
					{
						asmcodes+="\tPUSH "+temp->parameter_name[i]+"\n";       //push parameter
					}
					for(int i = 0;i<temp->func_vars.size();i++)
					{
						asmcodes+="\tPUSH "+temp->func_vars[i]+"\n";       //push function vars
					}
					for(int i = 0;i<optional_list.size();i++)
					{
						asmcodes+="\tPUSH "+optional_list[i]+"\n";       //push function vars
					}
					
					
					int count=0;
					while(count<argument_list.size())
					{
						asmcodes+="\tMOV AX,"+argument_list[count]->id_value+"\n";
						asmcodes+="\tMOV "+temp->parameter_name[count]+",AX\n";
						if(temp->parameter_type[count]!=argument_list[count]->get_declaredtype())
						{
							error_count++;
							check = 1;
							
							if(argument_list[count]->get_declaredtype()=="intarray" || 
							argument_list[count]->get_declaredtype()=="floatarray")
							{
								fprintf(error,"Error at line %d: Type Mismatch,%s is an araay \n\n",
								line_count,argument_list[count]->get_name().c_str());
								fprintf(logfile,"Error at line %d: Type Mismatch,%s is an araay \n\n",
								line_count,argument_list[count]->get_name().c_str());
							
							
							}
							else{
								fprintf(error,"Error at line %d: %dth argument mismatch in function %s \n\n",line_count,count+1,$<symbolinfo>1->get_name().c_str());
								fprintf(logfile,"Error at line %d: %dth argument mismatch in function %s \n\n",line_count,count+1,$<symbolinfo>1->get_name().c_str());
							}
							//$<symbolinfo>3->set_name("error");
							//fprintf(logfile,"%s(error)\n\n",$<symbolinfo>1->get_name().c_str());
							break;
						}
						count++;
					}
					asmcodes+="\tCALL "+$<symbolinfo>1->get_name()+"\n";
					for(int i = optional_list.size()-1;i>=0;i--)
					{
						asmcodes+="\tPOP "+optional_list[i]+"\n";              //poping from list
					}
					for(int i = temp->func_vars.size()-1;i>=0;i--)
					{
						asmcodes+="\tPOP "+temp->func_vars[i]+"\n";              //poping from list
					}
					for(int i = temp->parameter_name.size()-1;i>=0;i--)
					{
						asmcodes+="\tPOP "+temp->parameter_name[i]+"\n";              //poping from list
					}
					asmcodes+="\tMOV AX,"+$<symbolinfo>1->get_name()+"_return\n";
					char *temp=newTemp();
					asmcodes+="\tMOV "+string(temp)+",AX\n";
					$<symbolinfo>$->code=asmcodes;
					$<symbolinfo>$->id_value=string(temp);
					var_declaredList.push_back(string(temp));
					optional_list.push_back(string(temp));
				}
				else
				{
					check = 1;
					error_count++;
					fprintf(error,"Error at line %d:  Total number of arguments mismatch in function %s\n\n",
					line_count,$<symbolinfo>1->get_name().c_str());
					fprintf(logfile,"Error at line %d:  Total number of arguments mismatch in function %s\n\n",
					line_count,$<symbolinfo>1->get_name().c_str());
					//$<symbolinfo>3->set_name("error");
					//fprintf(logfile,"%s(error)\n\n",$<symbolinfo>1->get_name().c_str());
					
				}
			
			}
			
			fprintf(logfile,"%s(%s)\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>3->get_name().c_str()); 
			
			argument_list.clear();
			
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"("+$<symbolinfo>3->get_name()+")");
			}
	| LPAREN expression RPAREN {
			fprintf(logfile,"Line %d: factor : LPAREN expression RPAREN\n\n",line_count);
			fprintf(logfile,"(%s)\n\n",$<symbolinfo>2->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo(); 
			$<symbolinfo>$->set_declaredtype($<symbolinfo>2->get_declaredtype());
			$<symbolinfo>$->set_name("("+$<symbolinfo>2->get_name()+")");
			$<symbolinfo>$->code=$<symbolinfo>2->code;
			$<symbolinfo>$->id_value=$<symbolinfo>2->id_value;
			}
	| CONST_INT  {
			fprintf(logfile,"Line %d: factor : CONST_INT\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str());
			$<symbolinfo>$=new SymbolInfo();  
			$<symbolinfo>$->set_declaredtype("int");
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			char *t=newTemp();
			string asmcodes="\tMOV "+string(t)+","+$<symbolinfo>1->get_name()+"\n";
			$<symbolinfo>$->code=asmcodes;
			$<symbolinfo>$->id_value=string(t);
			var_declaredList.push_back(string(t));
			optional_list.push_back(string(t));
		
			}
	| CONST_FLOAT  { 
			fprintf(logfile,"Line %d: factor : CONST_FLOAT\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo(); 
			$<symbolinfo>$->set_declaredtype("float");
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			char *t=newTemp();
			string asmcodes="\tMOV "+string(t)+","+$<symbolinfo>1->get_name()+"\n";
			$<symbolinfo>$->code=asmcodes;
			$<symbolinfo>$->id_value=string(t);
			var_declaredList.push_back(string(t));
			optional_list.push_back(string(t));
			}
	| variable INCOP {
			fprintf(logfile,"Line %d: factor : variable INCOP\n\n",line_count);
			fprintf(logfile,"%s++\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo(); 
			$<symbolinfo>$->set_declaredtype($<symbolinfo>1->get_declaredtype());
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"++");
			string asmcodes="";
			char *t=newTemp();
			if($<symbolinfo>1->get_type()=="array"){
				asmcodes+="\tMOV AX,"+$<symbolinfo>1->id_value+"[BX]\n";
				asmcodes+="\tMOV "+string(t)+",AX\n";
				asmcodes+="\tMOV AX,"+$<symbolinfo>1->id_value+"[BX]\n";
				asmcodes+="\tINC AX\n";
				asmcodes+="\tMOV "+$<symbolinfo>1->id_value+"[BX],AX\n";
			}
			else{
				asmcodes+="\tMOV AX,"+$<symbolinfo>1->id_value+"\n";
				asmcodes+="\tMOV "+string(t)+",AX\n";
				asmcodes+="\tINC "+$<symbolinfo>1->id_value+"\n";
			}
			var_declaredList.push_back(string(t));
			optional_list.push_back(string(t));
			$<symbolinfo>$->code=asmcodes;
			$<symbolinfo>$->id_value=string(t);
			}
	| variable DECOP {
			fprintf(logfile,"Line %d: factor : variable DECOP\n\n",line_count);
			fprintf(logfile,"%s--\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_declaredtype($<symbolinfo>1->get_declaredtype());
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+"--");
			string asmcodes="";
			char *t=newTemp();
			if($<symbolinfo>1->get_type()=="array"){
				asmcodes+="\tMOV AX,"+$<symbolinfo>1->id_value+"[BX]\n";
				asmcodes+="\tMOV "+string(t)+",AX\n";
				asmcodes+="\tMOV AX,"+$<symbolinfo>1->id_value+"[BX]\n";
				asmcodes+="\tDEC AX\n";
				asmcodes+="\tMOV "+$<symbolinfo>1->id_value+"[BX],AX\n";
			}
			else{
				asmcodes+="\tMOV AX,"+$<symbolinfo>1->id_value+"\n";
				asmcodes+="\tMOV "+string(t)+",AX\n";
				asmcodes+="\tDEC "+$<symbolinfo>1->id_value+"\n";
			}
			var_declaredList.push_back(string(t));
			optional_list.push_back(string(t));
			$<symbolinfo>$->code=asmcodes;
			$<symbolinfo>$->id_value=string(t);
			}
	/*| factor error {
			error_count++;
			/*$<symbolinfo>$=new SymbolInfo(); 
			$<symbolinfo>$->set_declaredtype($<symbolinfo>1->get_declaredtype());
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			//fprintf(error,"Error Line %d: syntex error\n",line_count);
	
			}*/
			
	;
	
argument_list : arguments  { 
			fprintf(logfile,"Line %d: argument_list : arguments\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			$<symbolinfo>$->code=$<symbolinfo>1->code;
			}
		|       { 
			fprintf(logfile,"Line %d: argument_list : \n\n",line_count);
			$<symbolinfo>$=new SymbolInfo();
			$<symbolinfo>$->set_name("");
			}
		;
	
arguments : arguments COMMA logic_expression { 
			fprintf(logfile,"Line %d: arguments : arguments COMMA logic_expression\n\n",line_count);
			fprintf(logfile,"%s,%s\n\n",$<symbolinfo>1->get_name().c_str(),$<symbolinfo>3->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			argument_list.push_back($<symbolinfo>3);
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name()+","+$<symbolinfo>3->get_name());
			$<symbolinfo>$->code=$<symbolinfo>1->code+$<symbolinfo>3->code;
			}
	      | logic_expression{
			fprintf(logfile,"Line %d: arguments : logic_expression\n\n",line_count);
			fprintf(logfile,"%s\n\n",$<symbolinfo>1->get_name().c_str()); 
			$<symbolinfo>$=new SymbolInfo();
			
			argument_list.push_back($<symbolinfo>1);
		
			$<symbolinfo>$->set_name($<symbolinfo>1->get_name());
			$<symbolinfo>$->code=$<symbolinfo>1->code;
			}
	      ;
 

%%

void optimization(FILE *asmcode){
	bool flag=false;
	FILE* optcode= fopen("optimized_code.asm","w");
	char*  line;
    	size_t len = 0;
    	ssize_t read;
	vector<string>collections;
	while ((read = getline(&line, &len, asmcode)) != -1){	
		if(string(line)!=""){	
		   collections.push_back(string(line));}
	}
	int sizes=collections.size();
	int flags[sizes];
	for(int i=0;i<sizes;i++) 
		flags[i]=1;
	for(int i=0;i<sizes-1;i++){
		if(collections[i].size()!=collections[i+1].size()){
			flag=false;
		}
		else{
		//if matches
			string source1="";
			string source2="";
			string destination1="";
			string destination2="";
			vector<string>tokens1;
			vector<string>tokens2;
			vector<string>tokens3;
			vector<string>tokens4;
			istringstream check1(collections[i]);
			string in;
			while(getline(check1,in,' ')){
				tokens1.push_back(in);
			}
			istringstream check3(collections[i+1]);
			while(getline(check3,in,' ')){
				tokens3.push_back(in);
			}
			if(tokens1[0]=="	MOV"&&tokens3[0]=="	MOV"){
				istringstream check2(tokens1[1]);
				while(getline(check2,in,',')){
					tokens2.push_back(in);
				}
				
				istringstream check4(tokens3[1]);
				while(getline(check4,in,',')){
					tokens4.push_back(in);
				}
				source1=tokens2[1];
				source2=tokens4[1];           //saving back the source
				destination1=tokens2[0];       //saving back the dest
				destination2=tokens4[0];
				
				
				int n1=source1.length();
				int n2=source2.length();
				int n3=destination1.length();
				int n4=destination2.length();
				char arr1[n1+1];
				char arr2[n2+1];
				char arr3[n3+1];
				char arr4[n4+1];
				char arr5[n1+1];
				char arr6[n2+1];
				strcpy(arr1,source1.c_str());
				strcpy(arr2,source2.c_str());
				strcpy(arr3,destination1.c_str());
				strcpy(arr4,destination2.c_str());
				for(int k=0,j=0;k<=n1;k++){
					if(arr1[k]=='\n') continue;
					arr5[j++]=arr1[k];
				}
				for(int k=0,i=0;k<=n2;k++){
					if(arr2[k]=='\n') continue;
					arr6[i++]=arr2[k];
				}
				
				if(strcmp(arr5,arr4)==0 && strcmp(arr6,arr3)==0){
				        //check if matching for further optimization
				        //if(source1==destination2 && source2==destination1){ 
					flag=true;      
					//return true;
					
				}
				else 
				{
					flag=false;
				}
			}
			else
			{
				flag=false;
			}
		}

		if(flag==true){
			flags[i+1]=0;
		}
	}
	for(int i=0;i<sizes;i++){
		if(flags[i]==1)
		fprintf(optcode,"%s",collections[i].c_str());
	}

	fclose(asmcode);
	fclose(optcode);
	if (line){
	   free(line);
	}

}

int main(int argc,char *argv[])
{

	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		return 0;
	}
	yyin=fp;
	
	table.Enter_Scope();
	yyparse();
	
	//fprintf(logfile," Symbol Table : \n\n");
	table.Print_All_ScopeTable();
	fprintf(logfile,"Total Lines : %d \n\n",line_count-1);
	fprintf(logfile,"Total Errors : %d \n\n",error_count);
	//fprintf(error,"Total Errors : %d \n\n",error_count);

	fclose(fp);
	fclose(logfile);
	fclose(error);

	return 0;
}


