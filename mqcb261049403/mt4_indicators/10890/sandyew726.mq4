//+------------------------------------------------------------------+
//|                                                  SandyEw7-26.mq4 |
//|                                          Copyright 2012, Owner89 |
//|                                            southtrader@yandex.ru |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2012-2015, owner89 - southtrader."

#property link        "www.mql5.com/ru/users/owner"
#property link        "www.mql4.com/ru/users/owner89"

#property description "сборщик тиков для обновленного терминала"
#property description "запись производится в файл с именем символа - tickSymbol1.hst"
#property description "версия 7-24 для 509 серии терминала"
#property description "\n"
#property description "чтобы продолжить запись после незапланированного отключения терминала"
#property description "удалить глоб.переменную Symbol eW (F3)"

#property description "\n"
#property description "southtrader@yandex.ru"

#property strict

#import "user32.dll"
	int  RegisterWindowMessageA (string lpString); 
	int  PostMessageA           (int hWnd,int Msg,int wParam,int lParam);
	
	
#define WM_COMMAND                     0x0111

#include <stdlib.mqh>
 

#property indicator_chart_window

  extern string tick_digits                 = "from chart";  
            int digit;
            
           bool tick_time_local        =               false;
         string    symbol_name         = "default";
           bool tick_chart_update      =                true;


            int error                  =                  -1;
            int hand1e                 =                  -1;
          ulong fpos                   =                  -1;
         double ask;
         double bid;   
           
         string symbol;
            int MT4InternalMsg;
       datetime t;  
       datetime time;
            int hwnd;
            
           bool initw, update = false;
           bool flag = true;
         string gvar;                   
         string fp;     
         string sn; 
                                                 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators  
gvar = (Symbol()+"eW");
     
if(GlobalVariableCheck(gvar) == false)
  {
  initw = true;
  GlobalVariableSet(gvar,1.0);   
  }
  else{
  Print("out: second copy");
  initw = false;
  flag = false;
  return(INIT_FAILED);
  }
//----
symbol = Symbol();

if(tick_digits == "from chart")
  {
  digit  = (int)MarketInfo(symbol, MODE_DIGITS) ;
  }
  else{
  digit  = (int)StringToInteger(tick_digits);
  }
  
if(symbol_name == "default")
  {
  sn = StringConcatenate("tick", symbol) ;
  fp = StringConcatenate(sn, 1,  ".hst") ;
  }
  else{
  sn = symbol_name ;
  fp = StringConcatenate(symbol_name, 1, ".hst") ;  
  }

hand1e = FileOpenHistory(fp, FILE_BIN|FILE_READ);
 error = GetLastError();
 
if( (hand1e<0) || (error == 4103))
  {
  hand1e = FileOpenHistory(fp,FILE_BIN|FILE_READ|FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_ANSI);
   error = GetLastError();
  if(hand1e<0)
    {
    Print("out: error(",error,"): ",ErrorDescription(error));
    flag = false;
    }
    else{
    update = false;
    
    int unused[13];
    ArrayInitialize(unused,0);
    
	 FileWriteInteger(hand1e, 400, LONG_VALUE); 			 
	 FileWriteString (hand1e, "(C)opyright 2003, MetaQuotes Software Corp.", 64);				 
	 FileWriteString (hand1e, sn, 12); 
	 FileWriteInteger(hand1e, 1, LONG_VALUE);	 
	 FileWriteInteger(hand1e, digit, LONG_VALUE);		 
	 FileWriteInteger(hand1e, 0, LONG_VALUE);		  
	 FileWriteInteger(hand1e, 0, LONG_VALUE);		 
	 FileWriteArray  (hand1e, unused, 0, 13);
	 FileFlush       (hand1e);
	 
	 if(FileSeek(hand1e, 0, SEEK_END) == false)
	   { 
	   error = GetLastError();
	   Print("out: error(",error,"): ",ErrorDescription(error));
	   flag = false;
	   }
	   else{
	   fpos = FileTell(hand1e);  
	   }
    }
  }
  else{
  FileClose(hand1e);
  hand1e = FileOpenHistory(fp,FILE_BIN|FILE_READ|FILE_WRITE|FILE_SHARE_WRITE|FILE_SHARE_READ|FILE_ANSI);
   error = GetLastError();
  if(hand1e<0)
    {
    Print("out: error(",error,"): ",ErrorDescription(error));
    flag = false;
    }
    else{
	 update = true;
	 
	 if(FileSeek(hand1e, -44, SEEK_END) == false)
	   { 
	   error = GetLastError();
	   Print("out: error(",error,"): ",ErrorDescription(error));
	   flag = false;
	   }
	   else{	 
	   t = FileReadInteger(hand1e,LONG_VALUE);
	   }	 
	 if(FileSeek(hand1e, 0, SEEK_END) == false)
	   { 
	   error = GetLastError();
	   Print("out: error(",error,"): ",ErrorDescription(error));
	   flag = false;
	   }
	   else{
	   fpos = FileTell(hand1e);   
      }
    }  
  }
if(tick_chart_update == true)
  {
  if(MT4InternalMsg == 0)  
	 {
	 MT4InternalMsg = RegisterWindowMessageA("MetaTrader4_Internal_Message"); 
    }   
  }  
//----
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
if(initw == true)
  {
  GlobalVariableDel(gvar);  
  }
if(hand1e >0)
  {
  FileClose(hand1e);
  }
error = UninitializeReason(); 
string temp;
 
switch(error)
      {
      case 0: temp = "REASON_independently"; break;
      case 1: temp = "REASON_REMOVE"; break;
      case 2: temp = "REASON_RECOMPILE"; break;
      case 3: temp = "REASON_CHARTCHANGE"; break;
      case 4: temp = "REASON_CHARTCLOSE"; break;
      case 5: temp = "REASON_PARAMETERS"; break;
      case 6: temp = "REASON_ACCOUNT"; break;
      }
Print(StringConcatenate("out: ",temp));      
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {  
//----
if(flag == true)
  {
  if(tick_time_local == true)
    {
    time = TimeLocal();
    }
    else{
    time = TimeCurrent();
    }
    
  if(t < time)
    { 
	 t = time; 
    }
    else{ 
	 t ++; //(iTime(Symbol(),PERIOD_M1,0)-iTime(Symbol(),PERIOD_M1,1));
    }   

    if(FileSeek(hand1e, fpos, SEEK_SET) == false)
	   { 
	   error = GetLastError();
	   Print("out: error(",error,"): ",ErrorDescription(error));
	   flag = false;
	   return(0);
	   }
	   else{
	   bid = NormalizeDouble(MarketInfo(symbol, MODE_BID),digit);
	   ask = NormalizeDouble(MarketInfo(symbol, MODE_ASK),digit);
 
      
      FileWriteInteger(hand1e, (int)t,   LONG_VALUE);		 
		FileWriteDouble (hand1e,  bid, DOUBLE_VALUE);          
		FileWriteDouble (hand1e,  bid, DOUBLE_VALUE);		 
		FileWriteDouble (hand1e,  ask, DOUBLE_VALUE);	 
		FileWriteDouble (hand1e,  ask, DOUBLE_VALUE);				 
		FileWriteDouble (hand1e, time, DOUBLE_VALUE);
			 		
      FileFlush      (hand1e);  

      fpos = FileTell (hand1e);
      
      if(tick_chart_update == true)
        {
		  hwnd = WindowHandle(sn, 1);
        if(PostMessageA(hwnd, WM_COMMAND, 0x822c, 0) == false)
          {
          hwnd = 0;
          return(0);
          }
          PostMessageA(hwnd, MT4InternalMsg, 2, 1);             
          }     	     
           
      } 
  }
//----
   return(0);
  }
//+------------------------------------------------------------------+