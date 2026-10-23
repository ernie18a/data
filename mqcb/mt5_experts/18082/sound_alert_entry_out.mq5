//+------------------------------------------------------------------+
//|                                        Sound Alert Entry Out.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.002"
//---
enum ENUM_SOUNDS
  {
   alert       = 0,  // alert 
   alert2      = 1,  // alert2
   connect     = 2,  // connect 
   disconnect  = 3,  // disconnect
   email       = 4,  // email
   expert      = 5,  // expert 
   news        = 6,  // news
   ok          = 7,  // ok 
   request     = 8,  // request
   stops       = 9,  // stops 
   tick        = 10, // tick
   timeout     = 11, // timeout
   wait        = 12, // wait
  };
//---
input ENUM_SOUNDS sound=alert2;
input bool        notification=false;
//---
string filename="";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   switch(sound)
     {
      case 0:filename="alert.wav";break;
      case 1:filename="alert2.wav";break;
      case 2:filename="connect .wav";break;
      case 3:filename="disconnect.wav";break;
      case 4:filename="email.wav";break;
      case 5:filename="expert.wav";break;
      case 6:filename="news.wav";break;
      case 7:filename="ok.wav";break;
      case 8:filename="request.wav";break;
      case 9:filename="stops.wav";break;
      case 10:filename="tick.wav";break;
      case 11:filename="timeout.wav";break;
      case 12:filename="wait.wav";break;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long     deal_entry=0;
      long     deal_type=0;
      double   deal_volume=0.0;
      string   deal_symbol="NON";
      double   deal_profit=0.0;
      if(HistoryDealSelect(trans.deal))
        {
         deal_entry  =HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_type   =HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_volume =HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_symbol =HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_profit =HistoryDealGetDouble(trans.deal,DEAL_PROFIT);
        }
      else
         return;

      if(deal_entry!=DEAL_ENTRY_IN)
        {
         PlaySound(filename);
         if(notification)
           {
            string text="deal #"+IntegerToString(trans.deal);
            string str_type="NON";
            if(deal_type==DEAL_TYPE_BUY)
               str_type=" buy ";
            else if(deal_type==DEAL_TYPE_SELL)
               str_type=" sell ";
            text=text+str_type+DoubleToString(deal_volume,2)+" "+deal_symbol+
                 ", profit: "+DoubleToString(deal_profit,2)+" "+AccountInfoString(ACCOUNT_CURRENCY);
            SendNotification(text);
           }
        }
     }
  }
//+------------------------------------------------------------------+
