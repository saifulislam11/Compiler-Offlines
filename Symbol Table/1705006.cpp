#include<bits/stdc++.h>
#include <iostream>
#include <cstdlib>
#include <cstdio>
#include<fstream>
#include<sstream>
#include<string>
using namespace std;


ofstream file2;

class SymbolInfo
{
private:
    string Symbol_Name,Symbol_Type;
public:
    SymbolInfo *next;

    ///constructors

    SymbolInfo()
    {
        Symbol_Name = "";
        Symbol_Type = "";
        next=NULL;
    }
    SymbolInfo(string name,string type)
    {
        Symbol_Name=name;
        Symbol_Type=type;
        next=NULL;
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

    string get_name()
    {
        return Symbol_Name;
    }
    string get_type()
    {
        return Symbol_Type;
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
                cout<<"Found in ScopeTable# "<<this->id<<" at position "<<hash_value<<", "<<position<<endl<<endl;
                file2<<"Found in ScopeTable# "<<this->id<<" at position "<<hash_value<<", "<<position<<"\n"<<"\n";
                return temp;
            }
            temp=temp->next;
            position++;

        }
        return NULL;

    }
    ///insert
    bool Insert(string Symbol_name,string Symbol_type)
    {
        SymbolInfo *check=Look_up(Symbol_name);
        if(check != NULL)
        {
            cout<<"<"<<Symbol_name<<","<<Symbol_type<<">"<<" already exists in current ScopeTable"<<endl<<endl;
            file2<<"<"<<Symbol_name<<","<<Symbol_type<<">"<<" already exists in current ScopeTable"<<"\n"<<"\n";
            return false;
        }
        int hash_value = hashFunction(Symbol_name);
        SymbolInfo* temp = new SymbolInfo();
        temp = hash_table[hash_value];
        if(temp == NULL)
        {
            ///insert new symbol
            hash_table[hash_value]= new SymbolInfo(Symbol_name,Symbol_type);
            cout<<"Inserted in ScopeTable# "<<this->id<<" at position "<<hash_value<<", 0"<<endl<<endl;
            file2<<"Inserted in ScopeTable# "<<this->id<<" at position "<<hash_value<<", 0"<<"\n"<<"\n";
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
            prev->next=new SymbolInfo(Symbol_name,Symbol_type);
            cout<<"Inserted in ScopeTable# "<<this->id<<" at position "<<hash_value<<", "<<pos<<endl<<endl;
            file2<<"Inserted in ScopeTable# "<<this->id<<" at position "<<hash_value<<", "<<pos<<"\n"<<"\n";
            return true;
        }

    }

    ///delete
    bool  Delete(string name)
    {
        SymbolInfo* check = Look_up(name);
        if(check == NULL)
        {
            cout<<"Not found"<<endl<<endl;
            file2<<"Not found"<<"\n"<<"\n";
            return false;
        }
        int hash_value=hashFunction(name);
        SymbolInfo* temp;
        temp=hash_table[hash_value];

        if(temp->get_name()==name)
        {
            hash_table[hash_value]=temp->next;
            cout<<"Deleted entry at "<<hash_value<<", 0 from current ScopeTable"<<endl<<endl;
            file2<<"Deleted entry at "<<hash_value<<", 0 from current ScopeTable"<<"\n"<<"\n";
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
        cout<<"Deleted entry at "<<hash_value<<","<<pos<<" from current ScopeTable"<<endl<<endl;
        file2<<"Deleted entry at "<<hash_value<<","<<pos<<" from current ScopeTable"<<"\n"<<"\n";
        return true;


    }
    void Print()
    {
        cout<<"ScopeTable #"<<id<<endl;
        file2<<"ScopeTable #"<<id<<"\n";
        SymbolInfo *symbol;

        for (int i =0; i <n; i++)
        {
            cout<<i<< " --> ";
            file2<<i<< " --> ";

            symbol = hash_table[i];

            if(symbol == NULL)
            {
                cout<<endl;
                file2<<"\n";
            }

            else
            {
                ///traverse
                while (symbol != NULL)
                {
                    cout << "<" << symbol->get_name() << " : " << symbol->get_type()<< "> ";
                    file2 << "<" << symbol->get_name() << " : " << symbol->get_type()<< "> ";
                    symbol = symbol->next;
                }

                cout<<endl;
                file2<<"\n";
            }
        }
        cout<<endl<<endl;
        file2<<"\n"<<"\n";
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
            cout<<"New ScopeTable with id "<<current_id<<" created"<<endl<<endl;
            file2<<"New ScopeTable with id "<<current_id<<" created"<<"\n"<<"\n";
        }

    }
    void Exit_Scope()
    {
        if(current_id=="0")
        {
            cout<<"No Scope Table is found."<<endl<<endl;
            file2<<"No Scope Table is found."<<"\n"<<"\n";
        }

        ScopeTable *temp = current_scopetable;
        current_scopetable=current_scopetable->get_parent();
        ///current_id = current_scopetable->get_id();
        current_scopetable->next_id = current_scopetable->next_id + 1;

        cout<<"ScopeTable with id "<<this->current_id<<" removed"<<endl<<endl;
        file2<<"ScopeTable with id "<<this->current_id<<" removed"<<"\n"<<"\n";

        current_id = current_scopetable->get_id();
        delete temp;
    }
    bool Insert(string name,string type)
    {
        ///check base case
        if(current_scopetable == NULL)
        {
            Enter_Scope();
            ///cout<<"chole"<<endl;
            bool check = current_scopetable->Insert(name,type);
            return check;
        }
        else
        {
            bool check = current_scopetable->Insert(name,type);
            return check;
        }
    }
    bool Remove(string name)
    {
        ///base case
        if(current_scopetable == NULL)
        {
            cout<<"No Scope Table available"<<endl<<endl;
            file2<<"No Scope Table available"<<"\n"<<"\n";
            return false;
        }
        else
        {
            bool check = current_scopetable->Delete(name);
            if(check == false)
            {
                cout<<name<<" not found"<<endl<<endl;
                file2<<name<<" not found"<<"\n"<<"\n";
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
        cout<<"Not found"<<endl<<endl;
        file2<<"Not found"<<"\n"<<"\n";
        return NULL;
    }
    void Print_Current_ScopeTable()
    {
        ///base case
        if(current_scopetable == NULL)
        {
            cout<<"No scope table found"<<endl<<endl;
            file2<<"No scope table found"<<"\n"<<"\n";
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


int main()
{
    fstream file1;
    file1.open("input.txt");
    int n;
    string line;
    ///taking n from file
    getline(file1,line);
    istringstream iss(line);
    iss>>n;
    SymbolTable table(n);
    file2.open("output.txt");

    while(!file1.eof())
    {
        getline(file1,line);
        istringstream iss(line);
        char ch;
        iss>>ch;

        if(ch == 'I')
        {
            string symbol_name,symbol_type;
            iss>>symbol_name>>symbol_type;
            ///write file2
            cout<<ch<<" "<<symbol_name<<" "<<symbol_type<<endl<<endl;
            file2<<ch<<" "<<symbol_name<<" "<<symbol_type<<"\n"<<"\n";

            table.Insert(symbol_name,symbol_type);
            ///cout<<symbol_type<<endl;

        }
        else if( ch == 'L')
        {
            string symbol_name;
            iss>>symbol_name;
            cout<<ch<<" "<<symbol_name<<endl<<endl;
            file2<<ch<<" "<<symbol_name<<"\n"<<"\n";
            table.LookUP(symbol_name);

        }
        else if(ch == 'D')
        {
            string symbol_name;
            iss>>symbol_name;
            cout<<ch<<" "<<symbol_name<<endl<<endl;
            file2<<ch<<" "<<symbol_name<<"\n"<<"\n";
            table.Remove(symbol_name);

        }
        else if(ch == 'P')
        {
            char choice;
            iss>>choice;
            cout<<ch<<" "<<choice<<endl<<endl<<endl;
            file2<<ch<<" "<<choice<<"\n"<<"\n"<<"\n";
            if(choice == 'A')
            {
                table.Print_All_ScopeTable();
            }
            else
            {
                table.Print_Current_ScopeTable();
            }

        }
        else if(ch == 'S')
        {
            cout<<ch<<endl<<endl;
            file2<<ch<<"\n"<<"\n";
            table.Enter_Scope();

        }
        else if(ch == 'E')
        {
            cout<<ch<<endl<<endl;
            file2<<ch<<"\n"<<"\n";
            table.Exit_Scope();

        }
    }
    return 0;

}

