//+------------------------------------------------------------------+
//| OrderSell Scripts   by ***NicoMax***                             |
//|                                                                  |
//| Set a New Order Sell with Predefined Lots,SL,TP                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
 {
 int ticket,iSlipPage,iSLPips,iTPPips;
  double dStopLoss, dTakeProfit,dLots;
  string sText,sArrow;
  
  iSLPips=100;        //Stop Loss in Pips
  iTPPips=150;        //Take Profit in Pips
  dLots=0.5;           //Amount of Lots
  iSlipPage=1;
  sText="My Order";  //Order Text
  sArrow=CLR_NONE;   //Order Arrow Color
  
  dStopLoss=Ask+NormalizeDouble(iSLPips*Point,MarketInfo(Symbol(),MODE_DIGITS));
  dTakeProfit=Bid - NormalizeDouble(iTPPips*Point,MarketInfo(Symbol(),MODE_DIGITS));
  ticket=OrderSend(Symbol(),OP_SELL,dLots, Bid,iSlipPage,dStopLoss, dTakeProfit,sText,000,0,sArrow);
     if(ticket<0)
       {
        Print("OrderSend failed with error #",GetLastError());
       }

  }
//+------------------------------------------------------------------+