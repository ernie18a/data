//+------------------------------------------------------------------+
//|                                Simulator regular expressions.mq5 |
//|                              Copyright © 2016, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property description "The simulator for working with regular expressions"
#property script_show_inputs
#include <RegularExpressions\Regex.mqh>
//+------------------------------------------------------------------+
//| enum of flags of opening of the file                             |
//+------------------------------------------------------------------+
enum ENUM_FILE_FLAGS
  {
   FILE_FLAGS_READ=1,            // FILE_READ
   FILE_FLAGS_WRITE=2,           // FILE_WRITE
   FILE_FLAGS_BIN=4,             // FILE_BIN
   FILE_FLAGS_CSV=8,             // FILE_CSV
   FILE_FLAGS_TXT=16,            // FILE_TXT
   FILE_FLAGS_ANSI=32,           // FILE_ANSI
   FILE_FLAGS_UNICODE=64,        // FILE_UNICODE
   FILE_FLAGS_SHARE_READ=128,    // FILE_SHARE_READ
   FILE_FLAGS_SHARE_WRITE=256,   // FILE_SHARE_WRITE
   FILE_FLAGS_REWRITE=512,       // FILE_REWRITE
   FILE_FLAGS_COMMON=4096,       // FILE_COMMON
  };
//---
input string   file_name="all_functions.mq5";         // file name
input string   str_format="(int)(.*?)(\\(\\))";
input bool     read_line_by_line=true;                // read line by line  
input bool     read=true;           // FILE_READ   
input bool     write=false;         // FILE_WRITE
input bool     bin=false;           // FILE_BIN
input bool     csv=false;           // FILE_CSV
input bool     txt=true;            // FILE_TXT
input bool     ansi=true;           // FILE_ANSI
input bool     unicod=false;        // FILE_UNICODE
input bool     share_read=false;    // FILE_SHARE_READ
input bool     share_write=false;   // FILE_SHARE_WRITE
input bool     rewrite=false;       // FILE_REWRITE
input bool     common=false;        // FILE_COMMON
//---
int            m_handel;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   Print("format: ",str_format,", read line by line:",read_line_by_line);

   int flags=0;
   if(read)
      flags+=FILE_READ;
   if(write)
      flags+=FILE_WRITE;
   if(bin)
      flags+=FILE_BIN;
   if(csv)
      flags+=FILE_CSV;
   if(txt)
      flags+=FILE_TXT;
   if(ansi)
      flags+=FILE_ANSI;
   if(unicod)
      flags+=FILE_UNICODE;
   if(share_read)
      flags+=FILE_SHARE_READ;
   if(share_write)
      flags+=FILE_SHARE_WRITE;
   if(rewrite)
      flags+=FILE_REWRITE;
   if(common)
      flags+=FILE_COMMON;

   m_handel=FileOpen(file_name,flags);
   if(m_handel==INVALID_HANDLE)
     {
      Print("Operation FileOpen failed, error ",GetLastError());
      return;
     }
   Regex *rgx=new Regex(str_format);
   if(read_line_by_line) // read line by line
     {
      int number_lines=0;
      while(!FileIsEnding(m_handel))
        {
         string str=FileReadString(m_handel);
         number_lines++;
         MatchCollection *matches=rgx.Matches(str);
         int count=matches.Count();
         if(count>0)
           {
            string str_text="";
            for(int i=0;i<count;i++)
              {
               str_text+=IntegerToString(i)+": ";
               str_text+=matches[i].Value();
               str_text+=", ";
              }
            Print("Line number: ",number_lines,", ",str_text);
            delete matches;
           }
         else
           {
            delete matches;            // if no match is found
           }
        }
     }
   else                                // read all file in one variable
     {
      string all_text="";
      while(!FileIsEnding(m_handel))
        {
         string str=FileReadString(m_handel);
         all_text+=str;
        }
      MatchCollection *matches=rgx.Matches(all_text);
      int count=matches.Count();
      if(count>0)
        {
         string str_text="";
         for(int i=0;i<count;i++)
           {
            str_text+=IntegerToString(i)+": ";
            str_text+=matches[i].Value();
            str_text+=", ";
           }
         Print(": ",str_text);
        }
      delete matches;
     }
   FileClose(m_handel);
   delete rgx;
   Regex::ClearCache();
  }
//+------------------------------------------------------------------+
