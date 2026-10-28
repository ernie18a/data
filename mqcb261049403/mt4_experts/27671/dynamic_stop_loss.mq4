//+-------------------------------------------------------------------------+
//|                                                     DynamicStopLoss.mq4 |
//|                   Copyright © 2019 by Jt, FXFledgling Forex Study Group |
//|                            https://www.facebook.com/groups/FXFledgling/ |
//+-------------------------------------------------------------------------+
#property copyright "Copyright © 2019 by Jt, FXFledgling Forex Study Group"
#property link      "https://www.facebook.com/groups/FXFledgling/"
#property version   "1.00"
#property strict
//+-------------------------------------------------------------------------+

//+-------------------------------------------------------------------------+
//| Parameter                                                               |
//+-------------------------------------------------------------------------+
extern double StopLoss         = 800  ; //Stop Loss in Points

//+-------------------------------------------------------------------------+
//| Variable                                                                |
//+-------------------------------------------------------------------------+
datetime NewCandleTime=TimeCurrent();

//+-------------------------------------------------------------------------+
//| Expert tick function                                                    |
//+-------------------------------------------------------------------------+
void OnTick()
{
      if(IsNewCandle())
      {
            bool error;
            for(int i=0; i<OrdersTotal(); i++)
            {
                  if(OrderSelect(i,SELECT_BY_POS)  && OrderSymbol()==Symbol())
                  {
                        if(OrderType()==OP_BUY)
                        {
                              error=OrderModify(OrderTicket(),OrderOpenPrice(),
                              Bid-(StopLoss*Point),OrderTakeProfit(),0,White);
                              Sleep(500); 
                        }
                        else if(OrderType()==OP_SELL)
                        {
                              error=OrderModify(OrderTicket(),OrderOpenPrice(),
                              Ask+(StopLoss*Point),OrderTakeProfit(),0,White);
                              Sleep(500);
                        }
                  }
            }      
      }
}  

//+-------------------------------------------------------------------------+
//| Check New Candle Bar                                                    |
//+-------------------------------------------------------------------------+
bool IsNewCandle()
{   
      if(NewCandleTime==iTime(Symbol(),0,0)) return false;
      else
      {
            NewCandleTime=iTime(Symbol(),0,0);
            return true;
      }
} 
