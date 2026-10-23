//+------------------------------------------------------------------+
//|                                  script_cm_open_2_stoporders.mq4 |
//|                                Copyright 2016, cmillion@narod.ru |
//|                                               http://cmillion.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, cmillion@narod.ru"
#property link      "http://cmillion.ru"
#property version   "1.00"
#property strict
#property show_inputs
#property description "Скрипт открытия противоположных стоп ордеров в указанное время"
#property description "После срабатывания одного, второй удаляется"
/*--------------------------------------------------------------------
В определенное время(задаётся в параметрах) выставляются 
два отложенных ордера байстоп и селстоп на расстоянии в пунктах (задается в 
параметрах) от текущей цены, с TP и SL в пунктах (задается в параметрах). 
После срабатывания одного из ордеров, противоположный удаляется.
Далее скрипт заканчивает свою работу.
//--------------------------------------------------------------------*/
extern int      level          = 10,       //расстояние от текущей цены до ордеров
stoploss       = 50,       //уровень выставления SL, если 0, то SL не выставляется
takeprofit     = 50,       //уровень выставления TP, если 0, то TP не выставляется
Magic          = 0;        //уникальный номер ордера
extern double   Lot            = 0.1;      //объем ордеров
extern datetime TimeSet=D'2016.01.06 01:08'; //Время выставления ордеров, если текущее время больше установленного, то выставляются сразу
int slippage=3;
double STOPLEVEL;
//--------------------------------------------------------------------
void OnStart()
  {
   if(Digits==3 || Digits==5) {level*=10;stoploss*=10;takeprofit*=10;slippage*=10;}
   while(TimeCurrent()<TimeSet)
     {
      if(IsStopped()) {Comment("принудительное закрытие скрипта ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));return;}
      Sleep(1000);
      Comment(TimeToStr(TimeCurrent(),TIME_SECONDS),"\nСкрипт открытия противоположных стоп ордеров в ",
              TimeToStr(TimeSet,TIME_DATE|TIME_SECONDS),"\n",WindowExpertName(),"\n",
              "До выставления позиций осталось ",TimeToStr(TimeSet-TimeCurrent(),TIME_SECONDS));
     }
//---
   string txt=NULL;
   RefreshRates();
   STOPLEVEL=MarketInfo(Symbol(),MODE_STOPLEVEL);
   if(level<STOPLEVEL) level=(int)STOPLEVEL;
   double SL,TP,Price=NormalizeDouble(Ask+level*Point,Digits);
   if(takeprofit!=0)
     {
      if(takeprofit<STOPLEVEL) TP=NormalizeDouble(Price+STOPLEVEL*Point,Digits);
      else  TP=NormalizeDouble(Price+takeprofit*Point,Digits);
     }
   else TP=0;
   if(stoploss!=0)
     {
      if(stoploss<STOPLEVEL) SL=NormalizeDouble(Price-STOPLEVEL*Point,Digits);
      else  SL=NormalizeDouble(Price-stoploss*Point,Digits);
     }
   else SL=0;
   if(OrderSend(Symbol(),OP_BUYSTOP,Lot,Price,slippage,SL,TP,NULL,Magic,0,clrBlue)!=-1)
      txt=StringConcatenate(txt,"Ордер BUYSTOP успешно выставлен ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),"\n");
   else txt=StringConcatenate(txt,"\nError ",GetLastError(),"  OPENORDER BUYSTOP     Ask =",DoubleToStr(Ask,Digits),
      "   Price =",DoubleToStr(Price,Digits)," (",NormalizeDouble((Price-Ask)/Point,0),")  SL =",DoubleToStr(SL,Digits),
      " (",NormalizeDouble((Price-SL)/Point,0),")  TP=",DoubleToStr(TP,Digits)," (",NormalizeDouble((TP-Price)/Point,0),")  STOPLEVEL=",STOPLEVEL,"\n");

   Price=NormalizeDouble(Bid-level*Point,Digits);
   if(takeprofit!=0)
     {
      if(takeprofit<STOPLEVEL) TP=NormalizeDouble(Price-STOPLEVEL*Point,Digits);
      else  TP=NormalizeDouble(Price-takeprofit*Point,Digits);
     }
   else TP=0;
   if(stoploss!=0)
     {
      if(stoploss<STOPLEVEL) SL=NormalizeDouble(Price+STOPLEVEL*Point,Digits);
      else  SL=NormalizeDouble(Price+stoploss*Point,Digits);
     }
   else SL=0;
   if(OrderSend(Symbol(),OP_SELLSTOP,Lot,Price,slippage,SL,TP,NULL,Magic,0,clrRed)!=-1)
      txt=StringConcatenate(txt,"Ордер SELLSTOP успешно выставлен ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS),"\n");
   else txt=StringConcatenate(txt,"\nError ",GetLastError(),"  OPENORDER SELLSTOP     Bid =",DoubleToStr(Bid,Digits),
      "   Price =",DoubleToStr(Price,Digits)," (",NormalizeDouble((Bid-Price)/Point,0),")  SL =",DoubleToStr(SL,Digits),
      " (",NormalizeDouble((SL-Price)/Point,0),")  TP=",DoubleToStr(TP,Digits)," (",NormalizeDouble((Price-TP)/Point,0),")  STOPLEVEL=",STOPLEVEL,"\n");
   Comment(txt);

//---
   while(true)
     {
      if(IsStopped()) {Comment("принудительное закрытие скрипта ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));return;}
      int TicketB=0,TicketS=0,OT,j;
      for(j=OrdersTotal(); j>=0; j--)
        {
         if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES))
           {
            OT=OrderType();
            if(OrderSymbol()==Symbol() && OT>1 && OrderMagicNumber()==Magic)
              {
               if(OT==OP_BUYSTOP) TicketB=OrderTicket();
               if(OT==OP_SELLSTOP) TicketS=OrderTicket();
              }
           }
        }
      if(TicketB>0 && TicketS==0) if(OrderDelete(TicketB)) break;
      if(TicketS>0 && TicketB==0) if(OrderDelete(TicketS)) break;
      if(TicketS==0 && TicketB==0) break;
      Comment("Скрипт открытия противоположных стоп ордеров\n",WindowExpertName(),"\n",txt,
              "Ждем открытия одного из ордеров ",TimeToStr(TimeCurrent(),TIME_SECONDS));
      Sleep(1000);
     }
   Comment("Скрипт \"",WindowExpertName(),"\" закончил свою работу ",TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS));
  }
//--------------------------------------------------------------------
