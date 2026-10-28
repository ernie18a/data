//+------------------------------------------------------------------+
//|Caution: If you use this EA, that's your self-responsibility.     |
//|                                                                  |
//|This EA is based Forex Fraus (for M1) which was made              |
//| by Dmitriy Zaytsev.                                              |   
//|I add limitations of position,trading Multi-currency              | 
//|                                                                  |
//|                                                        Sanada Kei|
//|                                                        2016.04.29|
//+------------------------------------------------------------------+
#property copyright "2016, Sanada Kei"
#property link        "http://www.mql4.com"
#property description "This EA is based Forex Fraus (for M1) which was made by Dmitriy Zaytsev."

extern int SL=0;
extern int TP=0;
extern bool   AllPositions=True; // Управлять всеми позициями
//+---five pairs Setting, Symbol, Max Position Numuber Start
extern string Pair1 = "EURUSD";     //Symbol
extern int Pair1_MaxPositions = 3;  //Max Position Numuber
extern string Pair2 = "EURCHF";     //Symbol
extern int Pair2_MaxPositions = 3;  //Max Position Numuber
extern string Pair3 = "EURJPY";     //Symbol
extern int Pair3_MaxPositions = 3;  //Max Position Numuber
extern string Pair4 = "CHFJPY";     //Symbol
extern int Pair4_MaxPositions = 3;  //Max Position Numuber
extern string Pair5 = "EURAUD";     //Symbol
extern int Pair5_MaxPositions = 3;  //Max Position Numuber
//+---five pairs Setting End
extern bool   ProfitTrailing = True; // Тралить только профит
extern int    TrailingStop   = 30;   // Фиксированный размер трала
extern int    TrailingStep   = 1;    // Шаг трала
extern bool   UseSound       = False;// Использовать звуковой сигнал
extern string NameFileSound="expert.wav";  // Наименование звукового файла
extern int time=0;                   //1 - включено, 0 - выключено. Mod by Sanada Kei 2016.04.29
extern int starttime= 7;
extern int stoptime = 17;
extern int mn=1;
extern int MAGIC=7777;               //Mod by Sanada Kei 2016.04.29
extern double Lots=0.1;
int err;
//+------------------------------------------------------------------+
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
     {
      for(int i=0; i<OrdersTotal(); i++)
        {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
           {
            if(AllPositions || OrderSymbol()==Symbol())
              {
               TrailingPositions();
              }
           }
        }
     }
   OpenPattern();//ⅳ・鏆瑯・褄・ ・・・湜・
  }

int okbuy,oksell;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenPattern()
  {
   double op,sl,tp;
   double WPRur=iWPR(Symbol(),0,360,0);
   if(WPRur<-99.9) {okbuy=1;}
   if(WPRur>-99.9 && okbuy==1)
     {
      okbuy=0;
      if(timecontrol()==1)
        {
        //I'd like to make below code more easy to maintenance. by Sanada Kei
        if(Symbol()==Pair1 && ChPos(Pair1,Pair1_MaxPositions))
         {
         op=Ask;if(SL>0){sl=Ask-SL*Point*mn;}if(TP>0){tp=Ask+TP*Point*mn;}
         err=OrderSend(Symbol(),OP_BUY,Lots,NormalizeDouble(op,Digits),3,NormalizeDouble(sl,Digits),NormalizeDouble(tp,Digits),"",MAGIC,0,Blue);
         if(err<0){Print("OrderSend()-OP_BUY.  op "+op+" sl "+sl+" tp "+tp+" "+GetLastError());}
         }
         if(Symbol()==Pair2 && ChPos(Pair2,Pair2_MaxPositions))
         {
         op=Ask;if(SL>0){sl=Ask-SL*Point*mn;}if(TP>0){tp=Ask+TP*Point*mn;}
         err=OrderSend(Symbol(),OP_BUY,Lots,NormalizeDouble(op,Digits),3,NormalizeDouble(sl,Digits),NormalizeDouble(tp,Digits),"",MAGIC,0,Blue);
         if(err<0){Print("OrderSend()-OP_BUY.  op "+op+" sl "+sl+" tp "+tp+" "+GetLastError());}
         }
         if(Symbol()== Pair3 && ChPos(Pair3,Pair3_MaxPositions))
         {
         op=Ask;if(SL>0){sl=Ask-SL*Point*mn;}if(TP>0){tp=Ask+TP*Point*mn;}
         err=OrderSend(Symbol(),OP_BUY,Lots,NormalizeDouble(op,Digits),3,NormalizeDouble(sl,Digits),NormalizeDouble(tp,Digits),"",MAGIC,0,Blue);
         if(err<0){Print("OrderSend()-OP_BUY.  op "+op+" sl "+sl+" tp "+tp+" "+GetLastError());}
         }
         if(Symbol()== Pair4 && ChPos(Pair4,Pair4_MaxPositions))
         {
         op=Ask;if(SL>0){sl=Ask-SL*Point*mn;}if(TP>0){tp=Ask+TP*Point*mn;}
         err=OrderSend(Symbol(),OP_BUY,Lots,NormalizeDouble(op,Digits),3,NormalizeDouble(sl,Digits),NormalizeDouble(tp,Digits),"",MAGIC,0,Blue);
         if(err<0){Print("OrderSend()-OP_BUY.  op "+op+" sl "+sl+" tp "+tp+" "+GetLastError());}
         }
         if(Symbol()== Pair5 && ChPos(Pair5,Pair5_MaxPositions))
         {
         op=Ask;if(SL>0){sl=Ask-SL*Point*mn;}if(TP>0){tp=Ask+TP*Point*mn;}
         err=OrderSend(Symbol(),OP_BUY,Lots,NormalizeDouble(op,Digits),3,NormalizeDouble(sl,Digits),NormalizeDouble(tp,Digits),"",MAGIC,0,Blue);
         if(err<0){Print("OrderSend()-OP_BUY.  op "+op+" sl "+sl+" tp "+tp+" "+GetLastError());}
         }
        }
      CloseAllPos(0);
     }

   if(WPRur>-0.1) {oksell=1;}
   if(WPRur<-0.1 && oksell==1)
     {
      oksell=0;
      if(timecontrol()==1)
        {
         if(Symbol()== Pair1 && ChPos(Pair1,Pair1_MaxPositions))
         {
         op=Bid;if(SL>0){sl=Bid+SL*Point*mn;}if(TP>0){tp=Bid-TP*Point*mn;}
         err=OrderSend(Symbol(),OP_SELL,Lots,NormalizeDouble(op,Digits),3,NormalizeDouble(sl,Digits),NormalizeDouble(tp,Digits),"",MAGIC,0,Red);
         if(err<0){Print("OrderSend()-OP_SELL.  op "+op+" sl "+sl+" tp "+tp+" "+GetLastError());}
         }
         if(Symbol()== Pair2 && ChPos(Pair2,Pair2_MaxPositions))
         {
         op=Bid;if(SL>0){sl=Bid+SL*Point*mn;}if(TP>0){tp=Bid-TP*Point*mn;}
         err=OrderSend(Symbol(),OP_SELL,Lots,NormalizeDouble(op,Digits),3,NormalizeDouble(sl,Digits),NormalizeDouble(tp,Digits),"",MAGIC,0,Red);
         if(err<0){Print("OrderSend()-OP_SELL.  op "+op+" sl "+sl+" tp "+tp+" "+GetLastError());}
         }
         if(Symbol()== Pair3 && ChPos(Pair3,Pair3_MaxPositions))
         {
         op=Bid;if(SL>0){sl=Bid+SL*Point*mn;}if(TP>0){tp=Bid-TP*Point*mn;}
         err=OrderSend(Symbol(),OP_SELL,Lots,NormalizeDouble(op,Digits),3,NormalizeDouble(sl,Digits),NormalizeDouble(tp,Digits),"",MAGIC,0,Red);
         if(err<0){Print("OrderSend()-OP_SELL.  op "+op+" sl "+sl+" tp "+tp+" "+GetLastError());}
         }
         if(Symbol()== Pair4 && ChPos(Pair4,Pair4_MaxPositions))
         {
         op=Bid;if(SL>0){sl=Bid+SL*Point*mn;}if(TP>0){tp=Bid-TP*Point*mn;}
         err=OrderSend(Symbol(),OP_SELL,Lots,NormalizeDouble(op,Digits),3,NormalizeDouble(sl,Digits),NormalizeDouble(tp,Digits),"",MAGIC,0,Red);
         if(err<0){Print("OrderSend()-OP_SELL.  op "+op+" sl "+sl+" tp "+tp+" "+GetLastError());}
         }
         if(Symbol()== Pair5 && ChPos(Pair5,Pair5_MaxPositions))
         {
         op=Bid;if(SL>0){sl=Bid+SL*Point*mn;}if(TP>0){tp=Bid-TP*Point*mn;}
         err=OrderSend(Symbol(),OP_SELL,Lots,NormalizeDouble(op,Digits),3,NormalizeDouble(sl,Digits),NormalizeDouble(tp,Digits),"",MAGIC,0,Red);
         if(err<0){Print("OrderSend()-OP_SELL.  op "+op+" sl "+sl+" tp "+tp+" "+GetLastError());}
         }
        }
      CloseAllPos(1);
     }
  }
//Закрываем все позиции по типу
int CloseAllPos(int type)
  {
   int buy=1; int sell=1;
   int i,b=0;

   if(type==1)
     {
      while(buy==1)
        {
         buy=0;
         for(i=0;i<OrdersTotal();i++)
           {
            if(true==OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
              {
               if(OrderType()==OP_BUY && OrderSymbol()==Symbol())
                 {buy=1;if(OrderClose(OrderTicket(),OrderLots(),Bid,3,Violet)){};}
                 }else{buy=0;
              }
           }
         if(buy==0){return(0);}
        }
     }
   if(type==0)
     {
      while(sell==1)
        {
         sell=0;
         for(i=0;i<OrdersTotal();i++)
           {
            if(true==OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
              {
               if(OrderType()==OP_SELL && OrderSymbol()==Symbol())
                 {sell=1;if(OrderClose(OrderTicket(),OrderLots(),Ask,3,Violet)){}; }
                 }else{sell=0;
              }
           }
         if(sell==0){return(0);}
        }
     }
   return(0);
  }
//+---ADD by Sanada Kei 2016.04.29----
bool ChPos(string psn_symbol,int MaxPosition)//Check the position number
  {
   int i;int col;
   for(i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false){return(false);}
      if(OrderSymbol()== psn_symbol && OrderMagicNumber()==MAGIC){col++;}
         if(col >= MaxPosition){return(false);}
     }
   return(true);
  }
//+---ADD by Sanada Kei 2016.04.29----
//Ограничение по времени
int timecontrol()
  {
   if(((Hour()>=0 && Hour()<=stoptime-1) || (Hour()>=starttime && Hour()<=23)) && starttime>stoptime)
     {
      return(1);
     }
   if((Hour()>=starttime && Hour()<=stoptime-1) && starttime<stoptime)
     {
      return(1);
     }

   if(time==0){ return(1);}

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingPositions()
  {
   double pBid,pAsk,pp;

   pp=MarketInfo(OrderSymbol(),MODE_POINT);
   if(OrderType()==OP_BUY)
     {
      pBid=MarketInfo(OrderSymbol(),MODE_BID);
      if(!ProfitTrailing || (pBid-OrderOpenPrice())>TrailingStop*pp)
        {
         if(OrderStopLoss()<pBid-(TrailingStop+TrailingStep-1)*pp)
           {
            ModifyStopLoss(pBid-TrailingStop*pp);
            return;
           }
        }
     }
   if(OrderType()==OP_SELL)
     {
      pAsk=MarketInfo(OrderSymbol(),MODE_ASK);
      if(!ProfitTrailing || OrderOpenPrice()-pAsk>TrailingStop*pp)
        {
         if(OrderStopLoss()>pAsk+(TrailingStop+TrailingStep-1)*pp || OrderStopLoss()==0)
           {
            ModifyStopLoss(pAsk+TrailingStop*pp);
            return;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Перенос уровня StopLoss                                          |
//| Параметры:                                                       |
//|   ldStopLoss - уровень StopLoss                                  |
//+------------------------------------------------------------------+
void ModifyStopLoss(double ldStopLoss)
  {
   bool fm;

   fm=OrderModify(OrderTicket(),OrderOpenPrice(),ldStopLoss,OrderTakeProfit(),0,CLR_NONE);
   if(fm && UseSound) PlaySound(NameFileSound);
  }
//+------------------------------------------------------------------+
