//+------------------------------------------------------------------+
//|                                     Group transfer Stop loss.mq5 |
//|                               Copyright © 022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property script_show_inputs
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
//---
CPositionInfo  m_position;                   // object of CPositionInfo class
CTrade         m_trade;                      // object of CTrade class
//--- input parameters
//--- input parameters
input double               InpStopLoss             = 1.54789;        // Stop Loss (Price)
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(Symbol());
//---
   for(int i=PositionsTotal()-1; i>=0; i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol())
           {
            double price_current = m_position.PriceCurrent();
            double price_open    = m_position.PriceOpen();
            double stop_loss     = m_position.StopLoss();
            double take_profit   = m_position.TakeProfit();
            //---
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(price_current>InpStopLoss)
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),InpStopLoss,take_profit))
                     Print(__FILE__," ",__FUNCTION__,", ERROR: ","Modify BUY ",m_position.Ticket(),
                           " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                  continue;
                 }
              }
            else
              {
               if(price_current<InpStopLoss)
                 {
                  if(!m_trade.PositionModify(m_position.Ticket(),InpStopLoss,take_profit))
                     Print(__FILE__," ",__FUNCTION__,", ERROR: ","Modify SELL ",m_position.Ticket(),
                           " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
              }
           }
  }
//+------------------------------------------------------------------+
