//+------------------------------------------------------------------+
//|                                                  RSI_Scanner.mq4 |
//|                                                           TR4DEX |
//|                                           https://www.tr4dex.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright © 2017, TR4DEX"
#property link        "https://www.tr4dex.com"
#property description "RSI Scanner"
#property version     "1.0"
#property strict
#property indicator_chart_window

extern ENUM_TIMEFRAMES TimeFrame       = PERIOD_H4; //Timeframe to use for RSI
input  int             RSI_HIGH        = 70;        //RSI high used for alert
input  int             RSI_LOW         = 30;        //RSI low used for alert
input  bool            UseAlert        = true;      //Show pop up alert
input  bool            UseNotification = true;      //Send alert to phone

double   RSI;
string   SYMBOL;
string   arrSymbols[];
datetime LastBarTime = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   bool status = GetSymbols();
   if(!status)
      {
      Alert("No symbols found.");
      return(1);
      }
   else
      {
      Comment("Running...");
      return(0);
      }
  }
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+  
int deinit()
  {
   ObjectsDeleteAll();
   return(0);
  }
  
//+------------------------------------------------------------------+
//| OnTick                                                           |
//+------------------------------------------------------------------+
void start()
  {  
   if(LastBarTime!=Time[0])
      {
      for(int i=ArraySize(arrSymbols)-1;i>=0;i--)
        {
         SYMBOL = arrSymbols[i];
         RSI    = iRSI(SYMBOL,TimeFrame,14,PRICE_CLOSE,0);
         if(RSI>=RSI_HIGH)
            {
            if(UseAlert)
               Alert("RSI HIGH: "+SYMBOL+" | RSI: "+DoubleToStr(RSI,0)+" | Timeframe: "+IntegerToString(TimeFrame));
            if(UseNotification)
               SendNotification("RSI HIGH: "+SYMBOL+" | RSI: "+DoubleToStr(RSI,0)+" | Timeframe: "+IntegerToString(TimeFrame));
            }
         if(RSI<=RSI_LOW)
            {
            if(UseAlert)
               Alert("RSI LOW: "+SYMBOL+" | RSI: "+DoubleToStr(RSI,0)+" | Timeframe: "+IntegerToString(TimeFrame));
            if(UseNotification)
               SendNotification("RSI LOW: "+SYMBOL+" | RSI: "+DoubleToStr(RSI,0)+" | Timeframe: "+IntegerToString(TimeFrame));
            }
        }
       LastBarTime = Time[0];
      }
  }
  
//+------------------------------------------------------------------+
//|Get Symbols                                                       |
//+------------------------------------------------------------------+
bool GetSymbols()
  {
   ArrayResize(arrSymbols, SymbolsTotal(true));
   for(int j=0;j<=SymbolsTotal(true)-1;j++)
      { 
       arrSymbols[j]=SymbolName(j,true);
      }
   if(ArraySize(arrSymbols)>0)
     {
      //Comment("Symbols Loaded: "+IntegerToString(ArraySize(arrSymbols)));
      return true;
     }
   else
      return false;
  }
//+------------------------------------------------------------------+
