//+------------------------------------------------------------------+
//| установка мышкой рыночных ордеров                                |
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
   int n;
   double SL,TP;
   double Price = NormalizeDouble(WindowPriceOnDropped(),Digits);
   string txt=StringConcatenate("Скрипт выставления рыночного ордера, старт ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   double MAXLOTMARGIN = AccountFreeMargin()/MarketInfo(Symbol(),MODE_MARGINREQUIRED);
   if (Lot>MAXLOTMARGIN) txt=StringConcatenate(txt,"\nНедостаточно средств для открытия ",DoubleToStr(Lot,2)," лота, максимум возможен ",DoubleToStr(MAXLOTMARGIN,2)," лот");
   else
   {
      while(true)
      {
         RefreshRates();
         if(Price>Ask) 
         {
            if (Takeprofit!=0) TP = NormalizeDouble(Ask + Takeprofit * Point,Digits); else TP=0;
            if (Stoploss!=0)   SL = NormalizeDouble(Ask - Stoploss   * Point,Digits); else SL=0;
            if (OrderSend(Symbol(),OP_BUY,Lot,NormalizeDouble(Ask,Digits),0,SL,TP,"StopOrders",Magic,0,CLR_NONE)!=-1)
                 {txt = StringConcatenate(txt,"\nВыставлен BUY ",DoubleToStr(Ask,Digits));break;}
            else txt = StringConcatenate(txt,"\nОшибка ",GetLastError()," выставления BUY ");
         }
         if(Price<Bid) 
         {
            if (Takeprofit!=0) TP = NormalizeDouble(Bid - Takeprofit * Point,Digits); else TP=0;
            if (Stoploss!=0)   SL = NormalizeDouble(Bid + Stoploss   * Point,Digits); else SL=0;
            if (OrderSend(Symbol(),OP_SELL,Lot,NormalizeDouble(Bid,Digits),0,SL,TP,"StopOrders",Magic,0,CLR_NONE)!=-1)
                 {txt = StringConcatenate(txt,"\nВыставлен SELL ",DoubleToStr(Bid,Digits));break;}
            else txt = StringConcatenate(txt,"\nОшибка ",GetLastError()," выставления SELL ");
         }
         if (comment) Comment("Попытка ",n," ",txt);
         n++;
         if (n>10) break;
      }
   }
   if (comment) Comment(txt,"\nСкрипт закончил свою работу ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
   return(0);
}
//--------------------------------------------------------------------


