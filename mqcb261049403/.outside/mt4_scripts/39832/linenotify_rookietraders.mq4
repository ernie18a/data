//+------------------------------------------------------------------+
//|                                                   LineNotify.mq4 |
//|                                Copyright 2022, RookieTraders.com |
//|                                    https://www.RookieTraders.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, RookieTraders.com"
#property link      "https://www.RookieTraders.com"
#property version   "1.00"
#property strict

string Line_Token = "---PutYourTokenHere--" ;

//--- Don't forget to put URL https://notify-api.line.me/api/notify to MT4/MT5 Allow webrequest listed url

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   string LineMessage = "Put Your Message Here" ;
   LineNotify(Line_Token,LineMessage);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LineNotify(string token,string Message)
  {
   int ErrorCode;
   string RequestMethod = "POST";
   string Line_Notify_URL = "https://notify-api.line.me/api/notify"; // put this url to MT4/MT5 Allow webrequest listed url
   string headers,  messagestring ;
   char msgData[],result[];
   string result_headers ;
   int timeout = 10000 ;
   
   //---- Create Header -----
   headers="Content-Type: application/x-www-form-urlencoded\r\n"  ;
   headers+="Authorization: Bearer "+token+"\r\n";
   
   //------ Create Message Char Array---
   messagestring = "message="+Message ;
   StringToCharArray(messagestring,msgData,0,WHOLE_ARRAY,CP_UTF8);
   ArrayResize(msgData,ArraySize(msgData)-1);
   
   //--- Send HTTP Request ------- 
   int res = WebRequest(RequestMethod, Line_Notify_URL, headers, timeout, msgData, result, result_headers);
   if(res==-1)
     {
      ErrorCode = GetLastError();
      Print("WebRequest Error:",ErrorCode) ;
      if(ErrorCode==4060)
        {
         Alert("Add the address '"+Line_Notify_URL+"' in the list of allowed URLs on tab 'Expert Advisors' ") ;
        }
     }
   else
      Print("Server response: ", CharArrayToString(result)) ;
     
  }


