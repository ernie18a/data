//+------------------------------------------------------------------+
//|                    e-Smart_Trailing(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property version   "1.00"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
//---
input    ushort   TrailingStop = 30;         // TrailingStop
input    ushort   TrailingStep = 5;          // TrailingStep
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
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
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol())
           {
            if(m_position.Profit()<0.0)
               break;
            //---
            long digits=SymbolInfoInteger(m_position.Symbol(),SYMBOL_DIGITS);
            double point=SymbolInfoDouble(m_position.Symbol(),SYMBOL_POINT);
            //--- tuning for 3 or 5 digits
            int digits_adjust=1;
            if(digits==3 || digits==5)
               digits_adjust=10;
            double m_adjusted_point=point*digits_adjust;
            //---
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.PriceCurrent()-(TrailingStop+TrailingStep)*m_adjusted_point>m_position.StopLoss())
                 {
                  //--- save Magic Number for the position
                  m_trade.SetExpertMagicNumber(m_position.Magic());
                  m_trade.PositionModify(m_position.Ticket(),
                                         m_position.PriceCurrent()-TrailingStop*m_adjusted_point,
                                         m_position.TakeProfit());
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               double sl=0.0;
               if(m_position.StopLoss()>0)
                 {
                  if(m_position.PriceCurrent()+(TrailingStop+TrailingStep)*m_adjusted_point<m_position.StopLoss())
                    {
                     sl=m_position.PriceCurrent()+TrailingStop*m_adjusted_point;
                     //--- save Magic Number for the position
                     m_trade.SetExpertMagicNumber(m_position.Magic());
                     m_trade.PositionModify(m_position.Ticket(),sl,m_position.TakeProfit());
                    }
                 }
               else
                 {
                  sl=m_position.PriceCurrent()+TrailingStop*m_adjusted_point;
                  //--- save Magic Number for the position
                  m_trade.SetExpertMagicNumber(m_position.Magic());
                  m_trade.PositionModify(m_position.Ticket(),sl,m_position.TakeProfit());
                 }
              }
           }
  }
//+------------------------------------------------------------------+
