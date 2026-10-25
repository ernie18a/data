//+------------------------------------------------------------------+
//|               Multicurrency hedge example EA (overlay hedge).mq4 |
//|                                           © 2017.06 S.Aukscionis |
//+------------------------------------------------------------------+
#property copyright    "© 2017.06 S.Aukscionis"
#property version      "1.0" 
#property description  "Multicurrency hedge example EA (overlay hedge)" 
#property strict

extern bool            TakeProfitByPoints=TRUE;//Take profit by points (true/false)
extern int             TakeProfitPoints=10;//Mutual take profit (in points)
extern bool            TakeProfitByUsd=FALSE;//Take profit by usd (true/false)
extern double          TakeProfitUsd=10.0;//Mutual take profit (in usd)
extern int             Retries=3;//Order close retries
extern ENUM_TIMEFRAMES AtrTimeFrame=PERIOD_M1;//ATR timeframe
extern int             AtrBarsBack=50000;//Bars count for caclculating ATR
extern ENUM_TIMEFRAMES CorrelationTimeFrame=PERIOD_M1;//Correlation timeframe
extern int             CorrelationBarsBack=50000;//Bars count for calculating correlation
extern int             CorrelationThreshold=90;//Correlation threshold
extern double          OverlayThreshold=100;//Overlay threshold (in points)
extern int             MaxOrders=20;//Maximum open orders
extern int             MaxSpread=10;//Maximum spread (in points)
int                    cnt,tnc;//Count variables for loops
int                    Total;//Total symbols in marketwatch
double                 Correlation;//Correlation variable
string                 Symbols[];//Array for storing symbols
string                 pair1[];//Array for storing 1st hedge pairs
string                 pair2[];//Array for storing 2nd hedge pairs
string                 posneg[];//Array for storing correlation comments
int                    magic[];//Array for storing magic numbers
double                 atrratio[];//Array for storing ATR ratios
int                    closemagic[];//Array for storing magic numbers required to close orders
int                    RecalculationDay;//Stats recalculation variable
//+------------------------------------------------------------------+
//| Expert initialization fucntion                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetMillisecondTimer(1);
   Total=SymbolsTotal(true);
   ArrayResize(Symbols,Total);
   for(cnt=Total-1;cnt>=0;cnt--)
      Symbols[cnt]=SymbolName(cnt,true);
   PrepareSymbols();
   return ( 0 );
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ArrayFree(Symbols);
   EventKillTimer();
   Comment("");
   return;
  }
//+------------------------------------------------------------------+
//| Event handling fucntion                                          |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(Hour()==1 && RecalculationDay!=Day()) PrepareSymbols();
   for(cnt=ArraySize(closemagic)-1;cnt>=0;cnt--) CloseBlock(closemagic[cnt]);
   for(cnt=ArraySize(posneg)-1;cnt>=0;cnt--) OpenBlock(pair1[cnt],pair2[cnt],posneg[cnt],magic[cnt],atrratio[cnt]);
   Comment("Total currently correlated symbol pairs = ",ArraySize(posneg),". Total open positions = ",OrdersTotal());
   return;
  }
//+------------------------------------------------------------------+
//| Look for correlations of symbols, write data into arrays         |
//+------------------------------------------------------------------+
void PrepareSymbols()
  {
   ArrayFree(pair1); ArrayFree(pair2); ArrayFree(posneg); ArrayFree(magic); ArrayFree(atrratio);
   for(cnt=Total-1;cnt>=0;cnt--)
      for(tnc=Total-1;tnc>=0;tnc--)
         if(Symbols[cnt]!=Symbols[tnc])
           {
            Correlation=Correlation(Symbols[cnt],Symbols[tnc],CorrelationTimeFrame,CorrelationBarsBack);
            if((Correlation<100 && Correlation>CorrelationThreshold) || (Correlation>-100 && Correlation<-CorrelationThreshold))
              {
               ArrayResize(pair1,ArraySize(pair1)+1);
               ArrayResize(pair2,ArraySize(pair2)+1);
               ArrayResize(posneg,ArraySize(posneg)+1);
               ArrayResize(magic,ArraySize(magic)+1);
               ArrayResize(atrratio,ArraySize(atrratio)+1);
               pair1[ArraySize(pair1)-1]=Symbols[cnt];
               pair2[ArraySize(pair2)-1]=Symbols[tnc];
               if(Correlation>CorrelationThreshold) posneg[ArraySize(posneg)-1]="positive";
               if(Correlation<-CorrelationThreshold) posneg[ArraySize(posneg)-1]="negative";
               magic[ArraySize(magic)-1]=StrToInteger(StringConcatenate(cnt,tnc));
               atrratio[ArraySize(atrratio)-1]=CalcAtrRatio(Symbols[cnt],Symbols[tnc]);
              }
           }
   for(cnt=ArraySize(posneg)-1;cnt>=0;cnt--)
      for(tnc=ArraySize(posneg)-1;tnc>=0;tnc--)
         if(pair1[cnt]==pair2[tnc] || pair1[cnt]==NULL || pair2[cnt]==NULL || posneg[cnt]==NULL || magic[cnt]==0 || atrratio[cnt]==0)
           {
            ArrayCopy(pair1,pair1,cnt,cnt+1,WHOLE_ARRAY); ArrayResize(pair1,ArraySize(pair1)-1);
            ArrayCopy(pair2,pair2,cnt,cnt+1,WHOLE_ARRAY); ArrayResize(pair2,ArraySize(pair2)-1);
            ArrayCopy(posneg,posneg,cnt,cnt+1,WHOLE_ARRAY); ArrayResize(posneg,ArraySize(posneg)-1);
            ArrayCopy(magic,magic,cnt,cnt+1,WHOLE_ARRAY); ArrayResize(magic,ArraySize(magic)-1);
            ArrayCopy(atrratio,atrratio,cnt,cnt+1,WHOLE_ARRAY); ArrayResize(atrratio,ArraySize(atrratio)-1);
            break;
           }
   ArrayFree(closemagic);
   ArrayResize(closemagic,ArraySize(magic));
   ArrayCopy(closemagic,magic,0,0,WHOLE_ARRAY);
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
     {
      int Count=0;
      if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)){}
      for(tnc=ArraySize(closemagic)-1;tnc>=0;tnc--)
         if(OrderMagicNumber()==closemagic[tnc])
            Count++;
      if(Count==0)
        {
         ArrayResize(closemagic,ArraySize(closemagic)+1);
         closemagic[ArraySize(closemagic)-1]=OrderMagicNumber();
        }
     }
   RecalculationDay=Day();
  }
//+------------------------------------------------------------------+
//| Close open positions                                             |
//+------------------------------------------------------------------+
void CloseBlock(int MagicNo)
  {
   if(TakeProfitByPoints && GetFloatingPoints(MagicNo)>=TakeProfitPoints) CloseBothOrders(MagicNo);
   if(TakeProfitByUsd && GetFloatingUsd(MagicNo)>=TakeProfitUsd) CloseBothOrders(MagicNo);
  }
//+------------------------------------------------------------------+
//| Open positions                                                   |
//+------------------------------------------------------------------+
void OpenBlock(string Pair1,string Pair2,string PosNeg,int MagicNo,double AdrRatio)
  {
   if(GetOrderCount(Pair1,MagicNo)!=0 || GetOrderCount(Pair2,MagicNo)!=0) return;

   string Action="";
   double Lots=Lots();
   double ScaledLots=NormalizeDouble(Lots*AdrRatio,2);
   double BaseLots=NormalizeDouble(Lots,2);

   double CurRangeHigh=0,CurRangeLow=0,CurRangeCenter=0;
   double SubRangeHigh=0,SubRangeLow=0,SubRangeCenter=0,SubClose=0;
   double PipsRatio;
   int PeriodRange=400;
   double dPoint=MarketInfo(Pair1,MODE_POINT);

   CurRangeHigh=iHigh(Pair1,0,iHighest(Pair1,0,MODE_HIGH,PeriodRange,0));
   CurRangeLow=iLow(Pair1,0,iLowest(Pair1,0,MODE_LOW,PeriodRange,0));
   CurRangeCenter=(CurRangeHigh+CurRangeLow)*0.5;

   if(PosNeg=="positive")
     {
      SubRangeHigh=iHigh(Pair2,0,iHighest(Pair2,0,MODE_HIGH,PeriodRange,0));
      SubRangeLow=iLow(Pair2,0,iLowest(Pair2,0,MODE_LOW,PeriodRange,0));
     }
   if(PosNeg=="negative")
     {
      SubRangeHigh=iLow(Pair2,0,iLowest(Pair2,0,MODE_LOW,PeriodRange,0));
      SubRangeLow=iHigh(Pair2,0,iHighest(Pair2,0,MODE_HIGH,PeriodRange,0));
     }
   SubRangeCenter=(SubRangeHigh+SubRangeLow)*0.5;
   PipsRatio=(CurRangeHigh-CurRangeLow)/(SubRangeHigh-SubRangeLow);
   double CloseMain=iClose(Pair1,0,0);
   SubClose=iClose(Pair2,0,0)-SubRangeCenter;
   double CloseSub=CurRangeCenter+SubClose*PipsRatio;
   double HedgeRange=(CloseMain-CloseSub)/dPoint;

   if(HedgeRange<-OverlayThreshold && PosNeg=="positive") Action="B1S2";//BUY MAIN SELL SUB
   else if(HedgeRange<-OverlayThreshold && PosNeg=="negative") Action="B1B2"; //BUY MAIN BUY SUB
   else if(HedgeRange>OverlayThreshold && PosNeg=="positive") Action="S1B2";//SELL MAIN BUY SUB
   else if(HedgeRange>OverlayThreshold && PosNeg=="negative") Action="S1S2";//SELL MAIN SELL SUB

   if(Action=="B1S2")
     {
      if(OrdersTotal()<MaxOrders && AccountMargin()<AccountFreeMargin())
         if(MarketInfo(Pair1,MODE_SPREAD)<MaxSpread && MarketInfo(Pair2,MODE_SPREAD)<MaxSpread)
           {
            if(GetOrderCount(Pair1,MagicNo)==0)
               SendBuy("B1S2",Pair1,ScaledLots,MagicNo);
            if(GetOrderCount(Pair1,MagicNo)==1 && GetOrderCount(Pair2,MagicNo)==0)
               SendSell("B1S2",Pair2,BaseLots,MagicNo);
           }
     }
   else if(Action=="S1B2")
     {
      if(OrdersTotal()<MaxOrders && AccountMargin()<AccountFreeMargin())
         if(MarketInfo(Pair1,MODE_SPREAD)<MaxSpread && MarketInfo(Pair2,MODE_SPREAD)<MaxSpread)
           {
            if(GetOrderCount(Pair2,MagicNo)==0)
               SendBuy("S1B2",Pair2,BaseLots,MagicNo);
            if(GetOrderCount(Pair2,MagicNo)==1 && GetOrderCount(Pair1,MagicNo)==0)
               SendSell("S1B2",Pair1,ScaledLots,MagicNo);
           }
     }
   else if(Action=="B1B2")
     {
      if(OrdersTotal()<MaxOrders && AccountMargin()<AccountFreeMargin())
         if(MarketInfo(Pair1,MODE_SPREAD)<MaxSpread && MarketInfo(Pair2,MODE_SPREAD)<MaxSpread)
           {
            if(GetOrderCount(Pair1,MagicNo)==0)
               SendBuy("B1B2",Pair1,ScaledLots,MagicNo);
            if(GetOrderCount(Pair1,MagicNo)==1 && GetOrderCount(Pair2,MagicNo)==0)
               SendBuy("B1B2",Pair2,BaseLots,MagicNo);
           }
     }
   else if(Action=="S1S2")
     {
      if(OrdersTotal()<MaxOrders && AccountMargin()<AccountFreeMargin())
         if(MarketInfo(Pair1,MODE_SPREAD)<MaxSpread && MarketInfo(Pair2,MODE_SPREAD)<MaxSpread)
           {
            if(GetOrderCount(Pair1,MagicNo)==0)
               SendSell("S1S2",Pair1,ScaledLots,MagicNo);
            if(GetOrderCount(Pair1,MagicNo)==1 && GetOrderCount(Pair2,MagicNo)==0)
               SendSell("S1S2",Pair2,BaseLots,MagicNo);
           }
     }
  }
//+------------------------------------------------------------------+
//| Calculate average true range ratio                               |
//+------------------------------------------------------------------+
double CalcAtrRatio(string Pair1,string Pair2)
  {
   int Count=0; double Sum1=0,Sum2=0,Atr1=0,Atr2=0,AtrRatio=0;
   for(int j=1;j<=AtrBarsBack;j++)
     {
      if(iHigh(Pair1,AtrTimeFrame,j)!=0 && iLow(Pair1,AtrTimeFrame,j)!=0 && MarketInfo(Pair1,MODE_POINT)!=0
         && iHigh(Pair2,AtrTimeFrame,j)!=0 && iLow(Pair2,AtrTimeFrame,j)!=0 && MarketInfo(Pair2,MODE_POINT)!=0)
        {
         Sum1+=(iHigh(Pair1,AtrTimeFrame,j)-iLow(Pair1,AtrTimeFrame,j))/MarketInfo(Pair1,MODE_POINT);
         Sum2+=(iHigh(Pair2,AtrTimeFrame,j)-iLow(Pair2,AtrTimeFrame,j))/MarketInfo(Pair2,MODE_POINT);
         Count++;
        }
     }
   if(Count!=0)
     {
      Atr1=Sum1/Count;
      Atr2=Sum2/Count;
     }
   if(Atr1!=0) AtrRatio=Atr2/Atr1;
   return(AtrRatio);
  }
//+------------------------------------------------------------------+
//| Send buy order                                                   |
//+------------------------------------------------------------------+
int SendBuy(string action,string Pair,double Lots,int MagicNo)
  {
   string CommentStr=action;
   for(int i=Retries;i>0;i--)
     {
      double Price=MarketInfo(Pair,MODE_ASK);
      int Ticket=OrderSend(Pair,OP_BUY,Lots,Price,3,0,0,CommentStr,MagicNo,0,Blue);
      if(Ticket>0) return(Ticket);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Send sell order                                                  |
//+------------------------------------------------------------------+
int SendSell(string action,string Pair,double Lots,int MagicNo)
  {
   string CommentStr=action;
   for(int i=Retries;i>0;i--)
     {
      double Price=MarketInfo(Pair,MODE_BID);
      int Ticket=OrderSend(Pair,OP_SELL,Lots,Price,3,0,0,CommentStr,MagicNo,0,Red);
      if(Ticket>0) return(Ticket);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Count orders for particular symbol                               |
//+------------------------------------------------------------------+
int GetOrderCount(string Pair,int MagicNo)
  {
   int Count=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Pair && OrderMagicNumber()==MagicNo) Count++;
     }
   return(Count);
  }
//+------------------------------------------------------------------+
//| Get current profit/loss (in points)                              |
//+------------------------------------------------------------------+
int GetFloatingPoints(int MagicNo)
  {
   double Lots=Lots();
   int TotalPoints=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderMagicNumber()==MagicNo)
         TotalPoints+=(int)((OrderProfit()+OrderCommission()+OrderSwap())/Lots/SymbolInfoDouble(OrderSymbol(),SYMBOL_TRADE_TICK_VALUE));
     }
   return(TotalPoints);
  }
//+------------------------------------------------------------------+
//| Get current profit/ loss                                         |
//+------------------------------------------------------------------+
double GetFloatingUsd(int MagicNo)
  {
   double TotalUsd=0;
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderMagicNumber()==MagicNo)
         TotalUsd+=(OrderProfit()+OrderCommission()+OrderSwap());
     }
   return(TotalUsd);
  }
//+------------------------------------------------------------------+
//| Close hedge                                                      |
//+------------------------------------------------------------------+
void CloseBothOrders(int MagicNo)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderMagicNumber()==MagicNo)
        {
         if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
         if(OrderType()==OP_BUY) for(int j=Retries; j>0; j--)
            if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,clrNONE)) break;
         if(OrderType()==OP_SELL) for(int j=Retries; j>0; j--)
            if(OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,clrNONE)) break;
        }
     }
  }
//+------------------------------------------------------------------+
//| Calculate position volume                                        |
//+------------------------------------------------------------------+
double Lots()
  {
   double maximumRisk=0.1;
   int lotsDigits=(int)-MathLog10(MarketInfo("EURUSD",MODE_MINLOT));
   double lots=NormalizeDouble(AccountFreeMargin()*maximumRisk/(500000.0/AccountLeverage()),lotsDigits);
   if(lots>MarketInfo("EURUSD",MODE_MAXLOT))
      lots=MarketInfo("EURUSD",MODE_MAXLOT);
   if(lots<MarketInfo("EURUSD",MODE_MINLOT))
      lots=MarketInfo("EURUSD",MODE_MINLOT);
   return(lots);
  }
//+------------------------------------------------------------------+
//| Calculate correlation								                     |
//+------------------------------------------------------------------+
double Correlation(string Symbol1,string Symbol2,ENUM_TIMEFRAMES TimeFrame,int barsBack)
  {
   datetime closeTime1=iTime(Symbol1,TimeFrame,0),
   closeTime2=iTime(Symbol2,TimeFrame,0),
   closeTime=MathMin(closeTime1,closeTime2);
   int shift1=iBarShift(Symbol1,TimeFrame,closeTime),
   shift2=iBarShift(Symbol2,TimeFrame,closeTime);
   double Co,close1[],close2[];

   ArrayCopySeries(close1,MODE_CLOSE,Symbol1,TimeFrame);
   ArrayCopySeries(close2,MODE_CLOSE,Symbol2,TimeFrame);

   int bars=MathMin(ArraySize(close1)-shift1,ArraySize(close2)-shift2);
   if(barsBack>0) bars=barsBack;
   Co=100*CorrelationFunction(close1,close2,shift1,shift2,bars);

   return(Co);
  }
//+------------------------------------------------------------------+
//| Correlation between two arrays of prices				               |
//+------------------------------------------------------------------+
double CorrelationFunction(double &x[],double &y[],int x_shift=0,int y_shift=0,int count=-1)
  {
   int n=MathMin(ArraySize(x)-x_shift,ArraySize(y)-y_shift);
   if(n>count && count>0) n=count;
   if(n<2) return(-2);

   double sum_sq_x=0,sum_sq_y=0,sum_coproduct=0,mean_x=x[x_shift],mean_y=y[y_shift];

   for(int i=0; i<n; i++)
     {
      double sweep=i/(i+1.0),
      delta_x=x[i+x_shift]-mean_x,
      delta_y=y[i+y_shift]-mean_y;

      sum_sq_x+=delta_x*delta_x*sweep;
      sum_sq_y+=delta_y*delta_y*sweep;
      sum_coproduct+=delta_x*delta_y*sweep;
      mean_x+=delta_x/(i+1.0);
      mean_y+=delta_y/(i+1.0);
     }

   double pop_sd_x=MathSqrt(sum_sq_x/n),
   pop_sd_y=MathSqrt(sum_sq_y/n),
   cov_x_y=sum_coproduct/n;

   if(pop_sd_x*pop_sd_y!=0.0) return(cov_x_y/(pop_sd_x*pop_sd_y));

   return(-3);
  }
//+------------------------------------------------------------------+
