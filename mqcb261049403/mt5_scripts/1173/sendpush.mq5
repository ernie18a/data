//+------------------------------------------------------------------+
//|                                                     SendPush.mq5 |
//|                           Copyright © 2012,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+  
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
#property description "Script to send PUSH-notification to smartphone."
//---- номер версии скрипта
#property version   "1.2" 
//---- показывать входные параметры
#property script_show_inputs
//+----------------------------------------------+
//| ВХОДНЫЕ ПАРАМЕТРЫ СКРИПТА                    |
//+----------------------------------------------+
input string  PushText="Checking connection!";  //Text of PUSH-notification
//+----------------------------------------------+

//+------------------------------------------------------------------+ 
//| start function                                                   |
//+------------------------------------------------------------------+
void OnStart()
  {
//----
   if(!SendNotification(PushText))
     {
      Print("Failed to send PUSH-notification to smartphone!!!");

      switch(GetLastError())
        {
         case ERR_NOTIFICATION_SEND_FAILED       : Print("Failed to send notification!"); break;
         case ERR_NOTIFICATION_WRONG_PARAMETER   : Print("Invalid parameter of notification sending - empty string!"); break;
         case ERR_NOTIFICATION_WRONG_SETTINGS    : Print("Incorrect notification settings in the terminal (ID is not specified or the permission is not exhibited!)"); break;
         case ERR_NOTIFICATION_TOO_FREQUENT      : Print("Too often sending of notifications!"); break;
         default                                 : Print("Unknown error!");
        }

      ResetLastError();
     }
   else Print("PUSH-уведомление отправлено на смартфон!!!");
//----
  }
//+------------------------------------------------------------------+
