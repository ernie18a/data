//+------------------------------------------------------------------+
//|                               Copyright © 2012, Vladimir Hlystov |
//|                                                cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Vladimir Hlystov"
#property link      "cmillion@narod.ru"
#property show_inputs

//--------------------------------------------------------------------
extern int     Stoploss          = 0,     //
               Takeprofit        = 0;     //
extern double  Lot               = 0.1;   //
extern int     Magic             = 0;     //
extern bool    comment           = true;  //display information on screen
//--------------------------------------------------------------------
int start()
{
   double SL,TP;
   double Price = NormalizeDouble(WindowPriceOnDropped(),Digits);
   string txt=StringConcatenate("Stop the script issuing a warrant ",DoubleToStr(Price,Digits)," старт ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   RefreshRates();
   if(Price>Ask) 
   {
      if (Takeprofit!=0) TP = NormalizeDouble(Price + Takeprofit * Point,Digits); else TP=0;
      if (Stoploss!=0)   SL = NormalizeDouble(Price - Stoploss   * Point,Digits); else SL=0;
      if (OrderSend(Symbol(),OP_BUYSTOP,Lot,Price,0,SL,TP,"StopOrders",Magic,0,CLR_NONE)!=-1)
           txt = StringConcatenate(txt,"\nSet BUYSTOP ",DoubleToStr(Price,Digits));
      else txt = StringConcatenate(txt,"\nError ",GetLastError()," BUYSTOP ");
   }
   if(Price<Bid) 
   {
      if (Takeprofit!=0) TP = NormalizeDouble(Price - Takeprofit * Point,Digits); else TP=0;
      if (Stoploss!=0)   SL = NormalizeDouble(Price + Stoploss   * Point,Digits); else SL=0;
      if (OrderSend(Symbol(),OP_SELLSTOP,Lot,Price,0,SL,TP,"StopOrders",Magic,0,CLR_NONE)==-1)
           txt = StringConcatenate(txt,"\nSet SELLSTOP ",DoubleToStr(Price,Digits));
      else txt = StringConcatenate(txt,"\nError ",GetLastError()," SELLSTOP ");
   }
   if (comment) Comment(txt,"\nThe script has finished its work ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   return(0);
}
//--------------------------------------------------------------------

)," выставления SELLSTOP ");
   }
   if (comment) Comment(txt,"\nСкрипт закончил свою работу ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   return(0);
}
//--------------------------------------------------------------------

