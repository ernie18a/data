//+------------------------------------------------------------------+
//|                                          EtridButtonExcemple.mq5 |
//|                                            Copyright 2024, Etrid |
//|                              https://www.mql5.com/ru/users/etrid |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Etrid"
#property link      "https://www.mql5.com/ru/users/etrid"
#property version   "1.00"
//---
bool draw = true;
string btnCloseAllPositions = "BtnCloseAllPositions";
//---
int x = 10;
int y = 30;
int btnHeight = 200;
int btnWidth = 50;
int btnFontSize = 12;
string btnText = "Close all positions";
//---
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   ObjectCreate(0, btnCloseAllPositions, OBJ_BUTTON, 0, 0, 0);
//---
return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
   ObjectDelete(0, btnCloseAllPositions);
}
//+------------------------------------------------------------------+
//| Expert Event function                                            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // идентификатор события   
                  const long& lparam,   // параметр события типа long 
                  const double& dparam, // параметр события типа double 
                  const string& sparam  // параметр события типа string 
)
{
   string symbol = "ALLSYMBOLS";
   
   if(ObjectGetInteger(0, btnCloseAllPositions, OBJPROP_STATE) == true)
   {
      ClosePositions(symbol);
      if(GetPositionsTotal(symbol) == 0)
      {
         ObjectSetInteger(0, btnCloseAllPositions, OBJPROP_STATE, 0, false);
      }
   }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---
   Draw();
}
//+------------------------------------------------------------------+
//| Expert Start function                                            |
//+------------------------------------------------------------------+
void Draw()
{
   if(draw)
   {
      ObjectSetInteger(0, btnCloseAllPositions, OBJPROP_XDISTANCE, x); 
      ObjectSetInteger(0, btnCloseAllPositions, OBJPROP_YDISTANCE, y); 
      ObjectSetInteger(0, btnCloseAllPositions, OBJPROP_XSIZE, btnHeight); 
      ObjectSetInteger(0, btnCloseAllPositions, OBJPROP_YSIZE ,btnWidth);
      ObjectSetInteger(0, btnCloseAllPositions, OBJPROP_FONTSIZE, btnFontSize);
      ObjectSetInteger(0, btnCloseAllPositions, OBJPROP_BGCOLOR, clrOrange); 
      ObjectSetString(0, btnCloseAllPositions, OBJPROP_TEXT, btnText);
      
      draw = false;
   }
}
//+------------------------------------------------------------------+
//| Get total positions by symbol                                    |
//+------------------------------------------------------------------+
int GetPositionsTotal(string symbol)
{
   int count = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      PositionGetTicket(i);
      if(PositionGetString(POSITION_SYMBOL) == symbol || symbol == "ALLSYMBOLS")
      {
         count++;
      }
   }
   return count;
}
//+------------------------------------------------------------------+
//| close positions by symbol                                        |
//+------------------------------------------------------------------+
void ClosePositions(string symbol)
{
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionGetString(POSITION_SYMBOL) == symbol || symbol == "ALLSYMBOLS")
      {
         ClosePosition(ticket);
      }
   }
}
//+------------------------------------------------------------------+
//| Close position                                                   |
//+------------------------------------------------------------------+
void ClosePosition(ulong ticket)
 {
   MqlTradeRequest request= {};
   MqlTradeResult  result= {};

   ZeroMemory(request);
   ZeroMemory(result);

   PositionSelectByTicket(ticket);
   string symbol = PositionGetString(POSITION_SYMBOL);
   double volume = PositionGetDouble(POSITION_VOLUME);

   request.action     =  TRADE_ACTION_DEAL;            // actyion type
   request.position   =  ticket;                       // position ticket
   request.symbol     =  symbol;                       // symbol
   request.volume     =  volume;                       // volume
   request.deviation  =  5;                            // deviation
   request.magic      =  OrderGetInteger(ORDER_MAGIC); // MagicNumber position

//---
   if(PositionGetInteger(POSITION_TYPE)  ==  ORDER_TYPE_BUY)
   {
      request.price  =  SymbolInfoDouble(symbol,SYMBOL_BID);
      request.type   =  ORDER_TYPE_SELL;
   }
   else
   {
      request.price  =  SymbolInfoDouble(symbol,SYMBOL_ASK);
      request.type   =  ORDER_TYPE_BUY;
   }
//---
   OrderSend(request,result);
}