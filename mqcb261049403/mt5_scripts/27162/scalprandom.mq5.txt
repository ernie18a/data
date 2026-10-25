#property copyright           "Mokara"
#property link                "https://www.mql5.com/en/users/mokara"
#property description         "Scalp Random"
#property version             "1.0"
#property script_show_inputs  true
#define MAGIC 999

input double rTP = 5;      //Take Profit Ratio
input double rSL = 10;     //Stop Loss Ratio
input double vol = 0.1;    //Volume
input int spread = 100;   //Maximum Spread

enum TRADE
{
   BUY = 0,
   SELL = 1
};

void OnStart()
{
   MqlTradeRequest tReq = {0};
   MqlTradeResult tRes = {0};
   int t = -1, i = 0, d, s;
   double p;
   string n;
   
   MathSrand(GetTickCount());
   i = MathRand()%SymbolsTotal(true);
   
   while(i < SymbolsTotal(true))
   {      
      n = SymbolName(i, true);
      s = SymbolInfoInteger(n, SYMBOL_SPREAD);      
      if(s > spread)
      {
         i++;
         continue;
      }
      else
      {
         break;
      }
   }
   
   if(s > spread)
   {
      Alert("ERROR: high spread. try again." );
      return;
   }
   
    
   p = SymbolInfoDouble(n, SYMBOL_POINT);
   d = SymbolInfoInteger(n, SYMBOL_DIGITS);
   
   ZeroMemory(tReq);
   ZeroMemory(tRes);
   tReq.symbol = n;
   tReq.volume = vol;
   tReq.action = TRADE_ACTION_DEAL;
   tReq.deviation = 5;
   tReq.magic = MAGIC;
   
   MathSrand(GetTickCount());
   Sleep(MathRand()%50);
   t = int(MathRand() % 2);
   switch(t)
   {
      case BUY: 
         tReq.type = ORDER_TYPE_BUY; 
         tReq.price = SymbolInfoDouble(n, SYMBOL_ASK); 
         tReq.tp = tReq.price + NormalizeDouble(s * p * rTP, d);
         tReq.sl = tReq.price - NormalizeDouble(s* p * rSL, d);
         break;
      case SELL: 
         tReq.type = ORDER_TYPE_SELL; 
         tReq.price = SymbolInfoDouble(n, SYMBOL_BID); 
         tReq.tp = tReq.price - NormalizeDouble(s * p * rTP, d);
         tReq.sl = tReq.price + NormalizeDouble(s* p * rSL, d);
         break;
   }
   
   if(!OrderSend(tReq, tRes))
   {
      Print("ERROR: order send. Error Code: " + GetLastError());         
      return;     
   }
}