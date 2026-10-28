//+------------------------------------------------------------------+
//|                                                  eaBreakeven.mq5 |
//|                                                  A.Lopatin© 2018 |
//|                                              diver.stv@gmail.com |
//+------------------------------------------------------------------+
#property copyright "A.Lopatin© 2018"
#property link      "diver.stv@gmail.com"
#property version   "1.01"

#include <Trade\Trade.mqh>

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input int    Breakeven           = 15;           //Breakeven in points
input int    Distance            = 5;            //Breakeven distance in points from open price of position
input int    MagicNumber         = 16112017;     //Magic number
input bool   EnableSound         = true;         //Enable/disable playing sound when breakeven set
input string SoundFile           = "alert1.wav"; //Sound file name
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+

void OnTick()
  {
   DoBreakeven();
  }
//+---------------------------------------------------------------------------+
//| DoBreakeven() - the function moves stop-loss at breakeven price           |
//| return type: void                                                         |
//+---------------------------------------------------------------------------+
void DoBreakeven()
  {
//If Breakeven is negative, then disable breakeven function
   if(Breakeven<0)
      return;

   MqlTick latest_price;

   uint total=PositionsTotal();
//Loop for positions
   for(uint i=0; i<total; i++)
     {
      ulong ticket=PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {

         string position_symbol=PositionGetString(POSITION_SYMBOL);
         CTrade trade_modify;
         trade_modify.SetTypeFillingBySymbol(position_symbol);
         if((PositionGetInteger(POSITION_MAGIC)==MagicNumber || MagicNumber==0))
           {
            double stoploss=PositionGetDouble(POSITION_SL);
            double price_open=PositionGetDouble(POSITION_PRICE_OPEN);
            double point=SymbolInfoDouble(position_symbol,SYMBOL_POINT);
            int digits=SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);
            //--- Get last quotes and print error in Experts tab when error returns
            if(!SymbolInfoTick(position_symbol,latest_price))
              {
               Print("DoModify(): SymbolInfoTick() error of",position_symbol," error code: ",GetLastError());
               continue;
              }
            double new_stoploss=0.0,stop_level=SymbolInfoInteger(position_symbol,SYMBOL_TRADE_STOPS_LEVEL)*point;

            new_stoploss=0.0;
            //---- Long position
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
              {
               new_stoploss=price_open+Distance*point;
               //--- Move stop-loss at breakven price + Distance, if position profit greater than Breakeven points
               if(latest_price.bid-price_open>=Breakeven*point && new_stoploss-stoploss>=point && latest_price.bid-new_stoploss>stop_level)
                 {
                  if(!trade_modify.PositionModify(PositionGetInteger(POSITION_TICKET),NormalizeDouble(new_stoploss,digits),PositionGetDouble(POSITION_TP)))
                     Print(GetLastError());
                  else if(EnableSound)
                     PlaySound(SoundFile);

                 }
              }
            //--- Short position
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
              {
               new_stoploss=price_open-Distance*point;
               //---- Move stop-loss at breakven price + Distance, if position profit greater than Breakeven points
               if(price_open-latest_price.ask>=Breakeven*point && (stoploss-new_stoploss>=point || stoploss<point) && new_stoploss-latest_price.ask>stop_level)
                 {
                  if(!trade_modify.PositionModify(PositionGetInteger(POSITION_TICKET),NormalizeDouble(new_stoploss,digits),PositionGetDouble(POSITION_TP)))
                     Print(GetLastError());
                  else if(EnableSound)
                     PlaySound(SoundFile);
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
