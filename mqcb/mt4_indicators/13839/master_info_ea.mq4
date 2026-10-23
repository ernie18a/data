//+------------------------------------------------------------------+
//|                                             Money_Manager_EA.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Girard Matthieu"
#property link      "https://forge.mql5.io"
#property version   "1.01"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);
   GlobalVariableSet("MasIN_MMGT_EA",1);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   GlobalVariableSet("MasIN_MMGT_EA",0);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   double price=0;
   if(GlobalVariableGet("MasIN_MMGT_"+Symbol()+"_Action")==10)
     {
      int ticket=OrderSend(Symbol(),int(GlobalVariableGet("MasIN_MMGT_"+Symbol()+"_OrderProp")),GlobalVariableGet("MasIN_MMGT_"+Symbol()+"_LotSize"),GlobalVariableGet("MasIN_MMGT_"+Symbol()+"_Price"),3,0.0,0.0,"Master_Info",int(GlobalVariableGet("MasIN_MMGT_"+Symbol()+"_MAGIC")),0,clrNONE);
      if(ticket<0)
        {
         ticket=OrderSend(Symbol(),int(GlobalVariableGet("MasIN_MMGT_"+Symbol()+"_OrderProp")),GlobalVariableGet("MasIN_MMGT_"+Symbol()+"_LotSize"),GlobalVariableGet("MasIN_MMGT_"+Symbol()+"_Price"),3,double(GlobalVariableGet("MasIN_MMGT_"+Symbol()+"_SL")),double(GlobalVariableGet("MasIN_MMGT_"+Symbol()+"_TP")),"Master_Info",int(GlobalVariableGet("MasIN_MMGT_"+Symbol()+"_MAGIC")),0,clrNONE);
        }
      else
        {
         bool modifystatus=OrderModify(ticket,GlobalVariableGet("MasIN_MMGT_"+Symbol()+"_Price"),double(GlobalVariableGet("MasIN_MMGT_"+Symbol()+"_SL")),double(GlobalVariableGet("MasIN_MMGT_"+Symbol()+"_TP")),0,clrNONE);
        }
      if(ticket<0)
        {
         Alert(errortext(GetLastError()));
         GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_Action",0);
        }
      else
        {
         Alert("OrderSend placed successfully");
         GlobalVariableSet("MasIN_MMGT_"+Symbol()+"_Action",20);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string errortext(int errorcode)
  {
   string result;

   if(errorcode==128){ result="Trade timeout";}
   if(errorcode==129){ result="Invalid price";}
   if(errorcode==130){ result="Invalid stops";}
   if(errorcode==131){ result="Invalid trade volume";}
   if(errorcode==132){ result="Market is closed";}
   if(errorcode==134){ result="Not enough money";}
   if(errorcode==135){ result="Price changed";}
   if(errorcode==137){ result="Broker is busy";}
   if(errorcode==138){ result="Requote";}
   if(errorcode==139){ result="Order is locked";}
   if(errorcode==141){ result="Too many requests";}
   if(errorcode==145){ result="Modification denied because order is too close to market";}
   if(errorcode==147){ result="Expirations are denied by broker";}
   if(errorcode==148){ result="The amount of open and pending orders has reached the limit set by the broker";}
   if(errorcode==149){ result="An attempt to open an order opposite to the existing one when hedging is disabled";}
   if(errorcode==150){ result="An attempt to close an order contravening the FIFO rule";}

   return(result);
  }
//+------------------------------------------------------------------+
