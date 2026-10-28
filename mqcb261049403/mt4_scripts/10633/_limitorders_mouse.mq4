//+------------------------------------------------------------------+
//| установка мышкой отложенных ордеров                              |
//|                               Copyright © 2012, Хлыстов Владимир |
//|                                                cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Хлыстов Владимир"
#property link      "cmillion@narod.ru"
#property show_inputs

//--------------------------------------------------------------------
extern int     Stoploss          = 0,     //стоплосс ордеров
               Takeprofit        = 0;     //тейкпрофит ордеров
extern double  Lot               = 0.1;   //лот
extern int     Magic             = 0;     //уникальный номер ордеров этого советника, если 0 то ведет все ордера, в том числе выставленные вручную
extern bool    comment           = true;  //выводить информацию на экран
//--------------------------------------------------------------------
int start()
{
   double SL,TP;
   double Price = NormalizeDouble(WindowPriceOnDropped(),Digits);
   string txt=StringConcatenate("Скрипт выставления Limit ордера ",DoubleToStr(Price,Digits)," старт ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   RefreshRates();
   if(Price>Ask) 
   {
      if (Takeprofit!=0) TP = NormalizeDouble(Price - Takeprofit * Point,Digits); else TP=0;
      if (Stoploss!=0)   SL = NormalizeDouble(Price + Stoploss   * Point,Digits); else SL=0;
      if (OrderSend(Symbol(),OP_SELLLIMIT,Lot,Price,0,SL,TP,"LimitOrders",Magic,0,CLR_NONE)!=-1)
           txt = StringConcatenate(txt,"\nВыставлен SELLLIMIT ",DoubleToStr(Price,Digits));
      else txt = StringConcatenate(txt,"\nОшибка ",GetLastError()," выставления SELLLIMIT ");
   }
   if(Price<Bid) 
   {
      if (Takeprofit!=0) TP = NormalizeDouble(Price + Takeprofit * Point,Digits); else TP=0;
      if (Stoploss!=0)   SL = NormalizeDouble(Price - Stoploss   * Point,Digits); else SL=0;
      if (OrderSend(Symbol(),OP_BUYLIMIT,Lot,Price,0,SL,TP,"LimitOrders",Magic,0,CLR_NONE )==-1)
           txt = StringConcatenate(txt,"\nВыставлен BUYLIMIT ",DoubleToStr(Price,Digits));
      else txt = StringConcatenate(txt,"\nОшибка ",GetLastError()," выставления BUYLIMIT ");
   }
   if (comment) Comment(txt,"\nСкрипт закончил свою работу ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   return(0);
}
//--------------------------------------------------------------------

