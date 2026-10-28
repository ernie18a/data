//+------------------------------------------------------------------+
//|                                        CandlePatternsTest EA.mq5 |
//|                                             Copyright 2020, YTMJ |
//|                           https://www.mql5.com/en/users/tradingg |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020,YTMJ"
#property link      "https://www.mql5.com/en/users/tradingg"
#property version   "1.0"
#property strict

#include <MT4Orders.mqh>

enum ENUM_TYPE_LOTS
  {
   Porcentaje=1,    //  Percentage
   Lotes=0,  //  Same lot
  };

enum ENUM_TYPE_PROFIT_LOSS
  {
   PorcentajePL=1,    //  Percentage
   MoneyPL=0,  //  Money
  };
  
  enum ENUM_TYPE_CLOSE
  {
   Close_All=1,    //  Close per account
   Close_Pair=0,  //  Close per pair
  };


//--- Inputs
input int        Magic         = 111;      // Magic Number
input group "Order comments"
input string CommentBuy = "Buy_CandlePatternsTest EA";//Buy order comment
input string CommentSell = "Sell_CandlePatternsTest EA";//Sell order comment
input group "Type of orders"
input bool Open_Buy =  true;    // Activate buy orders
input bool Open_Sell  =  true;    // Activate sell orders
input group   "Lots and risk"
input  ENUM_TYPE_LOTS   Auto_Lot  = Porcentaje;// Type lots management
input double     Risk_Multiplier   = 10;       // Percentage of risk
input double     Lots              = 0.01;      // Same lot
input  ENUM_TYPE_PROFIT_LOSS   Profit_by_Percent   = PorcentajePL;//Type of management profit and loss
input double     Loss              = 100;     // Loss
input double     Profit            = 0.1;   // Profit
input int        StopLoss  = 0;      // Stoploss for all orders
input int        Takeprofit  = 0;      // Takeprofit for all orders
input  ENUM_TYPE_CLOSE   Close_Type  = Close_Pair;// Type of closing
input int        Slip          = 300;   // Slippage
input int        TrailingStop  = 100;      // Trailing profit first order
input int        TrailingStep  = 30;      // Trailing step first order
input ENUM_TIMEFRAMES TimeForBars  = PERIOD_CURRENT;// Time difference to open orders
input group "Extra hedging orders"
input bool       Open_same_signal= false;// Open signal orders
input bool       Open_opposite_signal = true;// Open only opposite signal orders
input double     KLot              = 2; // Multiplier new order
input group "Activate close breakeven"
input bool       Close_if_profit= false;// Close all if breakeven
input double     Orders_Close= 2;// From x extra orders
input group  "Volume first order"
input int        MinVol     = 100;// Volume minimum
input       ENUM_TIMEFRAMES     TimeFrame41     = PERIOD_CURRENT;// Volume timeframe
input group   "Volume extra orders"
input int        MinVolH     = 100;// Volume minimum extra orders
input       ENUM_TIMEFRAMES     TimeFrame42     = PERIOD_CURRENT;// Volume extra timeframe
int  Shift14         = 0;// Barra señal /actual:0/anterior:1
int  Shift17         = 1;// Barra señal /actual:0/anterior:1
int  Shift15         = 0;// Barra señal /actual:0/anterior:1
int  Shift18         = 1;// Barra señal /actual:0/anterior:1
input group  "Candle Patterns"
input bool       Candle_Main= false;// Activate first order signal
input bool       Candle_Others= false;// Activate extra orders signal
input ENUM_TIMEFRAMES    TimeFrame31     = PERIOD_CURRENT; // Timeframe candles
input int  Period31     = 12; // Period MA candles
input group  "WHEN TO TRADE"
input group  "Days to trade"
input bool Sunday    =  true;   // Sunday
input bool Monday    =  true;   // Monday
input bool Tuesday   =  true;    // Tuesday
input bool Wednesday =  true;    // Wednesday
input bool Thursday  =  true;    // Thursday
input bool Friday    =  true;   // Friday
input bool Saturday  =  true;   // Saturday
input group  "Hours for Opening Orders [00:00:00 Format]"
input bool   ActiveBetweenHours      = 0;// Open only hours
input string    HourToOpen       = "06:00:00";// Hour to open (00:00:00h to 23:59:59h)
input string    HourToClose      = "18:00:00";// Hour to close (00:00:00h to 23:59:59h)
input bool   HT1CloseOpenOrders      = 0;// true:Close orders /false:No new orders
input group  "BREAK to not open new orders"
input string    HourNotToOpen       = "06:00:01";// Hour not to open (00:00:00h to 23:59:59h)
input string    HourToOpenAgain       = "06:00:02";// Hour to open again (00:00:00h to 23:59:59h)
input bool   HT2CloseOpenOrders      = 0;// true:Close orders /false:No new orders
input group  "Do not open orders at the end and beginning of the month"
input bool   Open_After      = 0;// Activate to not open orders at the end and beginning of the month
input int DB = 0;//Number of days before
input int DA = 0;//Number of days after
input group "News Settings"
enum TypeNS
  {
   INVEST=0,   // Investing.com
   DAILYFX=1,  // Dailyfx.com
  };
//--- input parameters
input TypeNS SourceNews=INVEST;// Source for news
input bool     LowNews             = false; // Activate: Low relevance
input bool     CloseLow            = 0;// Close open orders
input int      LowIndentBefore     = 15;// Minutes before
input int      LowIndentAfter      = 15;// Minutes after
input bool     MidleNews           = false;// Activate: Medium relevance
input bool     CloseMidle          = 0;// Close open orders
input int      MidleIndentBefore   = 30;// Minutes before
input int      MidleIndentAfter    = 30;// Minutes after
input bool     HighNews            = false;// Activate: High relevance
input bool     CloseHigh           = 0;// Close open orders
input int      HighIndentBefore    = 60;// Minutes before
input int      HighIndentAfter     = 60;// Minutes after
input bool     NFPNews             = false;// Activate: Non farm payrolls NFP
input bool     CloseNFP            = 1;// Close open orders
input int      NFPIndentBefore     = 180;// Minutes before
input int      NFPIndentAfter      = 180;// Minutes after
input bool    DrawNewsLines        = false;// Draw lines
input color   LowColor             = clrGreen;// Low relevance color
input color   MidleColor           = clrBlue;// Medium relevance color
input color   HighColor            = clrRed;// High relevance color
input int     LineWidth            = 1;// Line width
input ENUM_LINE_STYLE LineStyle    = STYLE_DOT;// Style of line
input bool    OnlySymbolNews       = false;// News only from symbol
input int  GMTplus=3;     // Your Time Zone, GMT (for news)

int NomNews=0,Now=0,MinBefore=0,MinAfter=0;
string NewsArr[4][1000];
datetime LastUpd;
string ValStr;
int   Upd            = 86400;      // Period news updates in seconds
bool  Next           = false;      // Draw only the future of news line
bool  Signal         = false;      // Signals on the upcoming news
datetime TimeNews[300];
string Valuta[300],News[300],Vazn[300];

int  manejadorCandles, manejadorVOL, manejadorVOLH, manejadorCMA;
double arrayCandles[], arrayVOL[], arrayVOLH[], arrayCMA[];
datetime expiryDate = D'2021.02.15 00:00';
//change as per your requirement
double Bid,Ask;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(TimeCurrent() > expiryDate)
     {
      Alert("Copy expired. Please, contact vendor/seller.");
      ExpertRemove();
     }

   if(ACCOUNT_TRADE_MODE_REAL)
     {
      Alert("Great, I am in a DEMO account.");
     }
   else
     {
      Alert("This version is only for Demo accounts. Please, contact vendor/seller.");
      ExpertRemove();
     }

   string v1=StringSubstr(_Symbol,0,3);
   string v2=StringSubstr(_Symbol,3,3);
   ValStr=v1+","+v2;

   manejadorVOL=iVolumes(Symbol(),TimeFrame41,1);
   manejadorVOLH=iVolumes(Symbol(),TimeFrame42,1);

   if(Candle_Main||Candle_Others)
      manejadorCMA= iMA(Symbol(),TimeFrame31,12,0,MODE_SMA,PRICE_CLOSE);

   ArraySetAsSeries(arrayVOL,true);
   ArraySetAsSeries(arrayVOLH,true);

   ArraySetAsSeries(arrayCMA,true);

   Comment("");
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   del("NS_");
   Comment("");
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   MqlTick last_tick;
   SymbolInfoTick(_Symbol,last_tick);
   Ask=last_tick.ask;
   Bid=last_tick.bid;
   string TextDisplay="";

   /*  Check News   */
   bool trade=true;
   string nstxt="";
   int NewsPWR=0;
   datetime nextSigTime=0;
   if(LowNews || MidleNews || HighNews || NFPNews)
     {
      if(SourceNews==0)
        {
         // Investing
         if(CheckInvestingNews(NewsPWR,nextSigTime))
           {
            trade=false;   // news time
           }
        }
      if(SourceNews==1)
        {
         //DailyFX
         if(CheckDailyFXNews(NewsPWR,nextSigTime))
           {
            trade=false;   // news time
           }
        }
     }
   if(trade)
     {

      // No News, Trade enabled
      nstxt="No News";
      if(ObjectFind(0,"NS_Label")!=-1)
        {
         ObjectDelete(0,"NS_Label");
        }

     }
   else  // waiting news , check news power
     {
      color clrT=LowColor;
      if(NewsPWR>3)
        {
         nstxt= "Waiting Non-farm Payrolls News";
         clrT = HighColor;
         if(CloseNFP)
           {
            CloseAll();
           }
        }
      else
        {
         if(NewsPWR>2)
           {
            nstxt= "Waiting High News";
            clrT = HighColor;
            if(CloseHigh)
              {
               CloseAll();
              }
           }
         else
           {
            if(NewsPWR>1)
              {
               nstxt= "Waiting Middle News";
               clrT = MidleColor;
               if(CloseMidle)
                 {
                  CloseAll();
                 }
              }
            else
              {
               nstxt= "Waiting Low News";
               clrT = LowColor;
               if(CloseLow)
                 {
                  CloseAll();
                 }
              }
           }
        }
      // Make Text Label
      if(nextSigTime>0)
        {
         nstxt=nstxt+" "+TimeToString(nextSigTime,TIME_MINUTES);
        }
      if(ObjectFind(0,"NS_Label")==-1)
        {
         string res="";
         StringConcatenate(res,nstxt,"");
         LabelCreate(res,clrT);
        }
      if(ObjectGetInteger(0,"NS_Label",OBJPROP_COLOR)!=clrT)
        {
         ObjectDelete(0,"NS_Label");
         string res="";
         StringConcatenate(res,nstxt,"");
         LabelCreate(res,clrT);
        }
     }
   nstxt="\n"+nstxt;
   /*  End Check News   */
//Print(MQLInfoInteger(MQL_TRADE_ALLOWED),"   ",trade);
   if((MQLInfoInteger(MQL_TRADE_ALLOWED) || MQLInfoInteger(MQL_TRADE_ALLOWED)==1) && trade)
     {
      // No news and Trade Allowed
      int total=OrdersTotal();
      int r=0;
      //RefreshRates();

      CopyBuffer(manejadorVOL,1,0,1,arrayVOL);
      CopyBuffer(manejadorVOLH,1,0,1,arrayVOLH);

      CopyBuffer(manejadorCMA,0,0,50,arrayCMA);


      double BuCa=1, BeCa=1;
      if(Candle_Main)
        {
         BuCa=BuCan();
         BeCa=BeCan();
        }

      //+------------------------------------------------------------------+
      //|           OPEN_OPPOSITE                                          |
      //+------------------------------------------------------------------+

      double BuCao=1, BeCao=1;
      if(Candle_Others)
        {
         BuCao= BuCan();
         BeCao= BeCan();
        }

      double slb=0, sls=0;

      if(StopLoss>0)
         slb=NormalizeDouble(Ask-StopLoss*Point(),Digits());

      if(StopLoss>0)
         sls=NormalizeDouble(Bid+StopLoss*Point(),Digits());

      double tpb=0, tps=0;

      if(Takeprofit>0)
         tpb=NormalizeDouble(Ask+Takeprofit*Point(),Digits());

      if(Takeprofit>0)
         tps=NormalizeDouble(Bid-Takeprofit*Point(),Digits());

      if((!Profit_by_Percent)&&(!Close_Type)&&(CountTrades()>0 && AllProfit()< -Loss))
         CloseAll();

      if((!Profit_by_Percent)&&(!Close_Type)&&(CountTrades()>1 && AllProfit()> Profit))
         CloseAll();

      if((Profit_by_Percent)&&(!Close_Type)&&(CountTrades()>1)&&((AllProfit() /  AccountInfoDouble(ACCOUNT_EQUITY)) * 100 > Profit))
         CloseAll();

      if((Profit_by_Percent)&&(!Close_Type)&&(CountTrades()>0)&&((AllProfit() / AccountInfoDouble(ACCOUNT_EQUITY)) * 100 < -Loss))
         CloseAll();

      if((!Profit_by_Percent)&&(Close_Type)&&(CountTrades()>0 && AccountInfoDouble(ACCOUNT_PROFIT)< -Loss))
         CloseAllPairs();

      if((!Profit_by_Percent)&&(Close_Type)&&(CountTrades()>1 && AccountInfoDouble(ACCOUNT_PROFIT)> Profit))
         CloseAllPairs();

      if((Profit_by_Percent)&&(Close_Type)&&(CountTrades()>1)&&((AccountInfoDouble(ACCOUNT_PROFIT) / AccountInfoDouble(ACCOUNT_EQUITY)) * 100 > Profit))
         CloseAllPairs();

      if((Profit_by_Percent)&&(Close_Type)&&(CountTrades()>0)&&((AccountInfoDouble(ACCOUNT_PROFIT) / AccountInfoDouble(ACCOUNT_EQUITY)) * 100 < -Loss))
         CloseAllPairs();

      if(CountTrades()<1 && CountOrders()>0)
         DelOrder();

      if((CountTrades()>=1 && CountTrades()<2)&&TrailingStop>0)
         Trailing();

      if((ActiveBetweenHours)&&(HT1CloseOpenOrders)&&(TimeCurrent())>=StringToTime(HourToClose))
         CloseAll();

      if((ActiveBetweenHours)&&(HT2CloseOpenOrders)&&(TimeCurrent()>=StringToTime(HourNotToOpen) && TimeCurrent()<StringToTime(HourToOpenAgain)))
         CloseAll();

      datetime LocalTime=TimeCurrent();
      MqlDateTime tm;
      TimeToStruct(LocalTime,tm);
      int DayOfWeek = tm.day_of_week;
      int MonthOfYear = tm.mon;
      int DayOfMonth = tm.day;

      //+------------------------------------------------------------------+
      //|           NORMAL_SIGNAL                                          |
      //+------------------------------------------------------------------+
      if((!Open_After)||((Open_After)&&(((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==1))||((DayOfMonth>=1+DA)&&(DayOfMonth<=28-DB)&&(MonthOfYear==2))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==3))||((DayOfMonth>=1+DA)&&(DayOfMonth<=30-DB)&&(MonthOfYear==4))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==5))||((DayOfMonth>=1+DA)&&(DayOfMonth<=30-DB)&&(MonthOfYear==6))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==7))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==8))||((DayOfMonth>=1+DA)&&(DayOfMonth<=30-DB)&&(MonthOfYear==9))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==10))||((DayOfMonth>=1+DA)&&(DayOfMonth<=30-DB)&&(MonthOfYear==11))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==12)))))
         if(Candle_Main)
            if(((DayOfWeek==1)&&(Monday==true))||((DayOfWeek==2)&&(Tuesday==true))||((DayOfWeek==3)&&(Wednesday==true))||((DayOfWeek==4)&&(Thursday==true))||((DayOfWeek==5)&&(Friday==true))||((DayOfWeek==6)&&(Saturday==true))||((DayOfWeek==0)&&(Sunday==true)))
               if(((ActiveBetweenHours)&&((TimeCurrent())>=StringToTime(HourToOpen))&&((TimeCurrent())<StringToTime(HourNotToOpen)))||((ActiveBetweenHours)&&((TimeCurrent())>=StringToTime(HourToOpenAgain))&&((TimeCurrent())<StringToTime(HourToClose)))||(!ActiveBetweenHours))
                  if(CountTrades()<1)
                     if(OrdersHistoryTotal()<2)
                        if(iVolume(Symbol(),TimeFrame41,1)>MinVol)
                           if((BuCa>0)&&(Open_Buy))
                             {
                              OrderSend(Symbol(),OP_BUY,Lot(),Ask,Slip,slb,tpb,CommentBuy,Magic,0,Blue);
                             }
                           else
                              if((BeCa>0)&&(Open_Sell))
                                {
                                 OrderSend(Symbol(),OP_SELL,Lot(),Bid,Slip,sls,tps,CommentSell,Magic,0,Red);
                                }

      if((!Open_After)||((Open_After)&&(((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==1))||((DayOfMonth>=1+DA)&&(DayOfMonth<=28-DB)&&(MonthOfYear==2))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==3))||((DayOfMonth>=1+DA)&&(DayOfMonth<=30-DB)&&(MonthOfYear==4))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==5))||((DayOfMonth>=1+DA)&&(DayOfMonth<=30-DB)&&(MonthOfYear==6))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==7))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==8))||((DayOfMonth>=1+DA)&&(DayOfMonth<=30-DB)&&(MonthOfYear==9))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==10))||((DayOfMonth>=1+DA)&&(DayOfMonth<=30-DB)&&(MonthOfYear==11))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==12)))))
         if(Candle_Main)
            if(((DayOfWeek==1)&&(Monday==true))||((DayOfWeek==2)&&(Tuesday==true))||((DayOfWeek==3)&&(Wednesday==true))||((DayOfWeek==4)&&(Thursday==true))||((DayOfWeek==5)&&(Friday==true))||((DayOfWeek==6)&&(Saturday==true))||((DayOfWeek==0)&&(Sunday==true)))
               if(((ActiveBetweenHours)&&((TimeCurrent())>=StringToTime(HourToOpen))&&((TimeCurrent())<StringToTime(HourNotToOpen)))||((ActiveBetweenHours)&&((TimeCurrent())>=StringToTime(HourToOpenAgain))&&((TimeCurrent())<StringToTime(HourToClose)))||(!ActiveBetweenHours))
                  if(OrdersHistoryTotal()>1)
                     if(CountTrades()<1)
                        if(iVolume(Symbol(),TimeFrame41,1)>MinVol)
                           if((BuCa>0)&&(Open_Buy))
                             {
                              OpenNewBuy();
                              return;
                             }

      if((!Open_After)||((Open_After)&&(((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==1))||((DayOfMonth>=1+DA)&&(DayOfMonth<=28-DB)&&(MonthOfYear==2))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==3))||((DayOfMonth>=1+DA)&&(DayOfMonth<=30-DB)&&(MonthOfYear==4))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==5))||((DayOfMonth>=1+DA)&&(DayOfMonth<=30-DB)&&(MonthOfYear==6))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==7))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==8))||((DayOfMonth>=1+DA)&&(DayOfMonth<=30-DB)&&(MonthOfYear==9))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==10))||((DayOfMonth>=1+DA)&&(DayOfMonth<=30-DB)&&(MonthOfYear==11))||((DayOfMonth>=1+DA)&&(DayOfMonth<=31-DB)&&(MonthOfYear==12)))))
         if(Candle_Main)
            if(((DayOfWeek==1)&&(Monday==true))||((DayOfWeek==2)&&(Tuesday==true))||((DayOfWeek==3)&&(Wednesday==true))||((DayOfWeek==4)&&(Thursday==true))||((DayOfWeek==5)&&(Friday==true))||((DayOfWeek==6)&&(Saturday==true))||((DayOfWeek==0)&&(Sunday==true)))
               if(((ActiveBetweenHours)&&((TimeCurrent())>=StringToTime(HourToOpen))&&((TimeCurrent())<StringToTime(HourNotToOpen)))||((ActiveBetweenHours)&&((TimeCurrent())>=StringToTime(HourToOpenAgain))&&((TimeCurrent())<StringToTime(HourToClose)))||(!ActiveBetweenHours))
                  if(OrdersHistoryTotal()>1)
                     if(CountTrades()<1)
                        if(iVolume(Symbol(),TimeFrame41,1)>MinVol)
                           if((BeCa>0)&&(Open_Sell))
                             {
                              OpenNewSell();
                              return;
                             }


      if(Candle_Others)
         if(Open_opposite_signal)
            if(CountTrades()>0)
               if(iVolume(Symbol(),TimeFrame42,1)>MinVolH)
                  if((BuCao>0)&&(Open_Buy))
                     if(AllProfit()<0)
                       {
                        OpenOpBuy();
                        return;
                       }
                     else
                        if(AllProfit()>0)
                           if(Close_if_profit)
                              CloseProfitTotal();

      if(Candle_Others)
         if(Open_opposite_signal)
            if(CountTrades()>0)
               if(iVolume(Symbol(),TimeFrame42,1)>MinVolH)
                  if((BeCao>0)&&(Open_Sell))
                     if(AllProfit()<0)
                       {
                        OpenOpSell();
                        return;
                       }
                     else
                        if(AllProfit()>0)
                           if(Close_if_profit)
                              CloseProfitTotal();

      if(Candle_Others)
         if(Open_same_signal)
            if(CountTrades()>0)
               if(iVolume(Symbol(),TimeFrame42,1)>MinVolH)
                  if((BuCao>0)&&(Open_Sell))
                     if(AllProfit()<0)
                       {
                        OpenConBuy();
                        return;
                       }
                     else
                        if(AllProfit()>0)
                           if(Close_if_profit)
                              CloseProfitTotal();

      if(Candle_Others)
         if(Open_same_signal)
            if(CountTrades()>0)
               if(iVolume(Symbol(),TimeFrame42,1)>MinVolH)
                  if((BeCao>0)&&(Open_Buy))
                     if(AllProfit()<0)
                       {
                        OpenConSell();
                        return;
                       }
                     else
                        if(AllProfit()>0)
                           if(Close_if_profit)
                              CloseProfitTotal();




      TextDisplay=TextDisplay+nstxt;
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      Comment(
         "Expert Advisor","\n",
         "===================","\n",
         "Candles EA Test","\n",
         "===================","\n","\n",
         "Account Balance: ", AccountInfoDouble(ACCOUNT_BALANCE),"\n",
         "Profit at Symbol : ",AllProfit(),"\n","\n",
         "Time: ", TimeCurrent(),"\n",
         "Check News : ",TextDisplay,"\n","\n",
         "SPREAD:","\n",
         double(SymbolInfoInteger(Symbol(),SYMBOL_SPREAD))/10,"\n"
      );
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trailing()
  {
   bool mod;
   double sl=0;
   double trsl=TrailingStop;
   double trst=TrailingStep;

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
           {
            if(OrderType()==OP_BUY)
              {
               if(Bid-OrderOpenPrice()>(MODE_SPREAD+trsl)*_Point)
                 {
                  sl=NormalizeDouble(Bid-trst*_Point,_Digits);
                  if(OrderStopLoss()<sl)
                    {
                     Print("SL: ",sl, " TP: ",OrderTakeProfit());
                     mod=OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,Yellow);
                     return;
                    }
                 }
              }
            if(OrderType()==OP_SELL)
              {
               if(OrderOpenPrice()-Ask>(MODE_SPREAD+trsl)*_Point)
                 {
                  sl=NormalizeDouble(Ask+trst*_Point,_Digits);
                  if(OrderStopLoss()>sl || (OrderStopLoss()==0))
                    {
                     Print("SL: ",sl, " TP: ",OrderTakeProfit());
                     mod=OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,Yellow);
                     return;
                    }
                 }
              }
           }
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountTrades()
  {
   int counts=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
           {
            if(OrderType()<=1)
               counts++;
           }
        }
     }
   return(counts);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll(int ot=-1)
  {
   bool cl;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
           {
            if(OrderType()==0 && (ot==0 || ot==-1))
              {
               //RefreshRates();
               cl=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,_Digits),Slip,White);
              }
            if(OrderType()==1 && (ot==1 || ot==-1))
              {
               //RefreshRates();
               cl=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,_Digits),Slip,White);
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAllPairs(int ot=-1)
  {
   bool cl;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderType()==0 && (ot==0 || ot==-1))
           {
            //RefreshRates();
            cl=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,_Digits),Slip,White);
           }
         if(OrderType()==1 && (ot==1 || ot==-1))
           {
            //RefreshRates();
            cl=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,_Digits),Slip,White);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Profit of all orders by order type                               |
//+------------------------------------------------------------------+
double AllProfit(int ot=-1)
  {
   double pr=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
           {
            if(OrderType()==0 && (ot==0 || ot==-1))
              {
               pr+=OrderProfit()+OrderCommission()+OrderSwap();
              }

            if(OrderType()==1 && (ot==1 || ot==-1))
              {
               pr+=OrderProfit()+OrderCommission()+OrderSwap();
              }
           }
        }
     }
   return(pr);
  }
//+------------------------------------------------------------------+
//| Counting orders by type                                          |
//+------------------------------------------------------------------+
int CountOrders(int type=-1)
  {
   int count=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
           {
            if(OrderType()==type || type==-1)
               count++;
           }
        }
     }
   return(count);
  }
//+------------------------------------------------------------------+
//| Delete pending orders                                            |
//+------------------------------------------------------------------+
void DelOrder(int type=-1)
  {
   bool del;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
           {
            if(OrderType()==type || type==-1)
               del=OrderDelete(OrderTicket());
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Lot()
  {
   double lot=Lots;
   double LotStep=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP),LotSize=0;
   double MinimumLot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   double MaximumLot=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);

   if(!Auto_Lot)
     {
      lot=Lots;
     }

   else
      if(Auto_Lot)
        {
         if(LotStep==0.1)
           {
            lot=NormalizeDouble(((AccountInfoDouble(ACCOUNT_BALANCE)*Risk_Multiplier)/100)/1000,1);
           }
         else
            if(LotStep==0.01)
              {
               lot=NormalizeDouble(((AccountInfoDouble(ACCOUNT_BALANCE)*Risk_Multiplier)/100)/1000,2);
              }
        }

   if(lot>MaximumLot)
     {
      lot=MaximumLot;
     }

   if(lot<MinimumLot)
     {
      lot=MinimumLot;
     }


     {
      if(LotStep==0.1)
        {
         if(CountTrades()>0)
            if(KLot>0)
              {
               lot=NormalizeDouble(lot*(CountTrades()),1);
              }
        }
      else
         if(LotStep==0.01)
           {
            if(CountTrades()>0)
               if(KLot>0)
                 {
                  lot=NormalizeDouble(lot*(CountTrades()),2);
                 }
           }
     }

   return(lot);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseProfitTotal()
  {
   for(int i=OrdersTotal(); i>=0; i--)
      if(OrderSelect(i-1,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol())
            if(IsNewCandle())
               if(OrderMagicNumber()==Magic)
                  if(AllProfit()>0)
                     if(CountTrades()>Orders_Close)
                        CloseAll();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenOpSell()
  {

   double sls=0;
   if(StopLoss>0)
      sls=NormalizeDouble(Bid+StopLoss*Point(),Digits());

   double tps=0;
   if(Takeprofit>0)
      tps=NormalizeDouble(Bid-Takeprofit*Point(),Digits());

   double klot=1;

   if(KLot>0)
      klot=KLot;

   for(int i=OrdersTotal(); i>=0; i--)
      if(OrderSelect(i-1,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol())
            if(IsNewCandle())
               if(OrderMagicNumber()==Magic)
                 {
                  if(OrderType()==OP_BUY)
                    {
                     OrderSend(Symbol(),OP_SELL,Lot()*klot,Bid,Slip,sls,tps,CommentSell,Magic,0,Red);
                    }
                 }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenOpBuy()
  {

   double slb=0;
   if(StopLoss>0)
      slb=NormalizeDouble(Ask-StopLoss*Point(),Digits());

   double tpb=0;
   if(Takeprofit>0)
      tpb=NormalizeDouble(Ask+Takeprofit*Point(),Digits());

   double klot=1;

   if(KLot>0)
      klot=KLot;


   for(int i=OrdersTotal(); i>=0; i--)
      if(OrderSelect(i-1,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol())
            if(IsNewCandle())
               if(OrderMagicNumber()==Magic)
                 {
                  if(OrderType()==OP_SELL)
                    {
                     OrderSend(Symbol(),OP_BUY,Lot()*klot,Ask,Slip,slb,tpb,CommentBuy,Magic,0,Blue);
                    }
                 }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenConSell()
  {

   double sls=0;
   if(StopLoss>0)
      sls=NormalizeDouble(Bid+StopLoss*Point(),Digits());

   double tps=0;
   if(Takeprofit>0)
      tps=NormalizeDouble(Bid-Takeprofit*Point(),Digits());

   double klot=1;

   if(KLot>0)
      klot=KLot;

   for(int i=OrdersTotal(); i>=0; i--)
      if(OrderSelect(i-1, SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol())
            if(OrderMagicNumber()==Magic)
               if(IsNewCandle())
                 {
                  OrderSend(Symbol(),OP_SELL,Lot()*klot,Bid,Slip,sls,tps,CommentSell,Magic,0,Red);
                 }
   return;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenConBuy()
  {

   double slb=0;
   if(StopLoss>0)
      slb=NormalizeDouble(Ask-StopLoss*Point(),Digits());

   double tpb=0;
   if(Takeprofit>0)
      tpb=NormalizeDouble(Ask+Takeprofit*Point(),Digits());

   double klot=1;

      if(KLot>0)
         klot=KLot;

         for(int i=OrdersTotal(); i>=0; i--)
            if(OrderSelect(i-1, SELECT_BY_POS,MODE_TRADES))
               if(OrderSymbol()==Symbol())
                  if(OrderMagicNumber()==Magic)
                     if(IsNewCandle())
                       {
                        OrderSend(Symbol(),OP_BUY,Lot()*klot,Ask,Slip,slb,tpb,CommentBuy,Magic,0,Blue);
                       }
   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenNewSell()
  {

   double sls=0;

   if(StopLoss>0)
      sls=NormalizeDouble(Bid+StopLoss*Point(),Digits());

   double tps=0;
   if(Takeprofit>0)
      tps=NormalizeDouble(Bid-Takeprofit*Point(),Digits());

   for(int i=OrdersHistoryTotal(); i>=0; i--)
      if(OrderSelect(i-1, SELECT_BY_POS,MODE_HISTORY))
         if(OrderSymbol()==Symbol())
            if(OrderMagicNumber()==Magic)
               if(CountTrades()<1)
                 {
                  if(IsNewCandle())
                    {
                     OrderSend(Symbol(),OP_SELL,Lot(),Bid,Slip,sls,tps,CommentSell,Magic,0,Red);
                    }
                 }
   return;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenNewBuy()
  {

   double slb=0;

   if(StopLoss>0)
      slb=NormalizeDouble(Ask-StopLoss*Point(),Digits());

   double tpb=0;
   if(Takeprofit>0)
      tpb=NormalizeDouble(Ask+Takeprofit*Point(),Digits());

   for(int i=OrdersHistoryTotal(); i>=0; i--)
      if(OrderSelect(i-1, SELECT_BY_POS,MODE_HISTORY))
         if(OrderSymbol()==Symbol())
            if(OrderMagicNumber()==Magic)
               if(CountTrades()<1)
                 {
                  if(IsNewCandle())
                    {
                     OrderSend(Symbol(),OP_BUY,Lot(),Ask,Slip,slb,tpb,CommentBuy,Magic,0,Blue);
                    }
                 }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewCandle()
  {
   static datetime t_bar=iTime(_Symbol,TimeForBars,0);
   datetime time=iTime(_Symbol,TimeForBars,0);
//---
   if(t_bar==time)
      return false;
   t_bar=time;
//---
   return true;
  }


//+------------------------------------------------------------------+
string ReadCBOE()
  {
   string cookie=NULL,headers="";
   string headersCons="";
   char post[],result[];
   char resultado[],data[];
   string TXT="";
   int res;
//--- to work with the server, you must add the URL "https://www.google.com/finance"
//--- the list of allowed URL (Main menu-> Tools-> Settings tab "Advisors"):
   string google_url="https://ec.forexprostools.com/?columns=exc_currency,exc_importance&importance=1,2,3&calType=week&timeZone=15&lang=1";
//---
   ResetLastError();
//--- download html-pages
   int timeout=5000; //--- timeout less than 1,000 (1 sec.) is insufficient at a low speed of the Internet
//  int res=WebRequest(METODO,"https://api.binance.com/"+"api/v1/trades"+"?symbol="+SIMBOLO,headersCons,10000,data,resultado,headersResp);
   res=WebRequest("GET",google_url,cookie,NULL,timeout,post,0,result,headers);
//res=WebRequest("GET",google_url,headersCons,timeout,post,result,headers);
//--- error checking
   if(res==-1)
     {
      Print("WebRequest error, err.code  =",GetLastError());
      MessageBox("You must add the address 'https://ec.forexprostools.com/' in the list of allowed URL tab 'Advisors' "," Error ",MB_ICONINFORMATION);
      //--- You must add the address ' "+ google url"' in the list of allowed URL tab 'Advisors' "," Error "
     }
   else
     {
      //--- successful download
      //PrintFormat("File successfully downloaded, the file size in bytes  =%d.",ArraySize(result));
      //--- save the data in the file
      int filehandle=FileOpen("news-log.txt",FILE_WRITE|FILE_TXT);
      //--- проверка ошибки
      if(filehandle!=INVALID_HANDLE)
        {
         string finaltt= CharArrayToString(result);
         //---save the contents of the array result [] in file
         FileWrite(filehandle,finaltt);
         //--- close file
         FileClose(filehandle);


         TXT=finaltt;

        }
      else
        {
         Print("Error in FileOpen. Error code =",GetLastError());
        }
     }

   return(TXT);
  }
//+------------------------------------------------------------------+
datetime TimeNewsFunck(int nomf)
  {
   string s=NewsArr[0][nomf];
   string pretime="";
   StringConcatenate(pretime,StringSubstr(s,0,4),".",StringSubstr(s,5,2),".",StringSubstr(s,8,2)," ",StringSubstr(s,11,2),":",StringSubstr(s,14,4));
   string time=pretime;
   return((datetime)(StringToTime(time) + GMTplus*3600));
  }
//////////////////////////////////////////////////////////////////////////////////
void UpdateNews()
  {
   string TEXT=ReadCBOE();
   int sh = StringFind(TEXT,"pageStartAt>")+12;
   int sh2= StringFind(TEXT,"</tbody>");
   TEXT=StringSubstr(TEXT,sh,sh2-sh);


   sh=0;
   while(!IsStopped())
     {
      sh = StringFind(TEXT,"event_timestamp",sh)+17;
      sh2= StringFind(TEXT,"onclick",sh)-2;
      if(sh<17 || sh2<0)
         break;
      NewsArr[0][NomNews]=StringSubstr(TEXT,sh,sh2-sh);

      sh = StringFind(TEXT,"flagCur",sh)+10;
      sh2= sh+3;
      if(sh<10 || sh2<3)
         break;
      NewsArr[1][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      if(OnlySymbolNews && StringFind(ValStr,NewsArr[1][NomNews])<0)
         continue;

      sh = StringFind(TEXT,"title",sh)+7;
      sh2= StringFind(TEXT,"Volatility",sh)-1;
      if(sh<7 || sh2<0)
         break;
      NewsArr[2][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      if(StringFind(NewsArr[2][NomNews],"High")>=0 && !HighNews)
         continue;
      if(StringFind(NewsArr[2][NomNews],"Moderate")>=0 && !MidleNews)
         continue;
      if(StringFind(NewsArr[2][NomNews],"Low")>=0 && !LowNews)
         continue;

      sh=StringFind(TEXT,"left event",sh)+12;
      int sh1=StringFind(TEXT,"Speaks",sh);
      sh2=StringFind(TEXT,"<",sh);
      if(sh<12 || sh2<0)
         break;
      if(sh1<0 || sh1>sh2)
         NewsArr[3][NomNews]=StringSubstr(TEXT,sh,sh2-sh);
      else
         NewsArr[3][NomNews]=StringSubstr(TEXT,sh,sh1-sh);

      NomNews++;
      if(NomNews==300)
         break;
     }
  }
//+------------------------------------------------------------------+
int del(string name) // Спец. ф-ия deinit()
  {
   for(int n=ObjectsTotal(0)-1; n>=0; n--)
     {
      string Obj_Name=ObjectName(0,n);
      if(StringFind(Obj_Name,name,0)!=-1)
        {
         ObjectDelete(0,Obj_Name);
        }
     }
   return 0;                                      // Выход из deinit()
  }
//+------------------------------------------------------------------+
bool CheckInvestingNews(int &pwr,datetime &mintime)
  {

   bool CheckNews=false;
   pwr=0;
   int maxPower=0;
   if(LowNews || MidleNews || HighNews || NFPNews)
     {
      if(TimeCurrent()-LastUpd>=Upd)
        {
         Print("Investing.com News Loading...");
         UpdateNews();
         LastUpd=TimeCurrent();
         Comment("");
        }
      ChartRedraw(0);
      //---Draw a line on the chart news--------------------------------------------
      if(DrawNewsLines)
        {
         for(int i=0; i<NomNews; i++)
           {
            string Name=StringSubstr("NS_"+TimeToString(TimeNewsFunck(i),TIME_MINUTES)+"_"+NewsArr[1][i]+"_"+NewsArr[3][i],0,63);
            if(NewsArr[3][i]!="")
               if(ObjectFind(0,Name)==0)
                  continue;
            if(OnlySymbolNews && StringFind(ValStr,NewsArr[1][i])<0)
               continue;
            if(TimeNewsFunck(i)<TimeCurrent() && Next)
               continue;

            color clrf=clrNONE;
            if(HighNews && StringFind(NewsArr[2][i],"High")>=0)
               clrf=HighColor;
            if(MidleNews && StringFind(NewsArr[2][i],"Moderate")>=0)
               clrf=MidleColor;
            if(LowNews && StringFind(NewsArr[2][i],"Low")>=0)
               clrf=LowColor;

            if(clrf==clrNONE)
               continue;

            if(NewsArr[3][i]!="")
              {
               //Print("KJKJKKJJ");
               ObjectCreate(0,Name,OBJ_VLINE,0,TimeNewsFunck(i),0);
               ObjectSetInteger(0,Name,OBJPROP_COLOR,clrf);
               ObjectSetInteger(0,Name,OBJPROP_STYLE,LineStyle);
               ObjectSetInteger(0,Name,OBJPROP_WIDTH,LineWidth);
               ObjectSetInteger(0,Name,OBJPROP_BACK,true);
              }
           }
        }
      //---------------event Processing------------------------------------
      int ii;
      CheckNews=false;

      //Print("NomNews ",NomNews);
      for(ii=0; ii<NomNews; ii++)
        {
         int power=0;
         if(HighNews && StringFind(NewsArr[2][ii],"High")>=0)
           {
            power=3;
            MinBefore=HighIndentBefore;
            MinAfter=HighIndentAfter;
           }
         if(MidleNews && StringFind(NewsArr[2][ii],"Moderate")>=0)
           {
            power=2;
            MinBefore=MidleIndentBefore;
            MinAfter=MidleIndentAfter;
           }
         if(LowNews && StringFind(NewsArr[2][ii],"Low")>=0)
           {
            power=1;
            MinBefore=LowIndentBefore;
            MinAfter=LowIndentAfter;
           }
         if(NFPNews && StringFind(NewsArr[3][ii],"Nonfarm Payrolls")>=0)
           {
            power=4;
            MinBefore=NFPIndentBefore;
            MinAfter=NFPIndentAfter;
           }
         if(power==0)
            continue;

         if(TimeCurrent()+MinBefore*60>TimeNewsFunck(ii) && TimeCurrent()-MinAfter*60<TimeNewsFunck(ii) && (!OnlySymbolNews || (OnlySymbolNews && StringFind(ValStr,NewsArr[1][ii])>=0)))
           {
            if(power>maxPower)
              {
               maxPower=power;
               mintime=TimeNewsFunck(ii);
              }
           }
         else
           {
            CheckNews=false;
           }
        }
      if(maxPower>0)
        {
         CheckNews=true;
        }
     }
   pwr=maxPower;
//Print(CheckNews);
   return(CheckNews);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LabelCreate(const string text="Label",const color clr=clrRed)
  {
   long x_distance;
   long y_distance;
   long chart_ID=0;
   string name="NS_Label";
   int sub_window=0;
   ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER;
   string font="Arial";
   int font_size=28;
   double angle=0.0;
   ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER;
   bool back=false;
   bool selection=false;
   bool hidden=true;
   long z_order=0;
//--- определим размеры окна
   ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance);
   ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,y_distance);
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,(int)(x_distance/2.7));
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,(int)(y_distance/1.5));
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateDFX()
  {
   string DF="";
   string MF="";
   int DeltaGMT=GMTplus; // 0 -(TimeGMTOffset()/60/60)-DeltaTime;
   int ChasPoyasServera=DeltaGMT;
   datetime NowTimeD1=iTime(Symbol(),PERIOD_CURRENT,0);
   datetime LastSunday=NowTimeD1-TimeDayOfWeekMQL4(NowTimeD1)*86399;
   int DayFile=TimeDayMQL4(LastSunday);
   if(DayFile<10)
      DF="0"+(string)DayFile;
   else
      DF=(string)DayFile;
   int MonthFile=TimeMonthMQL4(LastSunday);
   if(MonthFile<10)
      MF="0"+(string)MonthFile;
   else
      MF=(string)MonthFile;
   int YearFile=TimeYearMQL4(LastSunday);
   string DateFile=MF+"-"+DF+"-"+(string)YearFile;
   string FileName= DateFile+"_dfx.csv";
   int handle;

   if(!FileIsExist(FileName))
     {
      string url="https://www.dailyfx.com/files/Calendar-"+DateFile+".csv";
      string cookie=NULL,headers;
      char post[],result[];
      string TXT="";
      int res;
      string text="";
      ResetLastError();
      int timeout=5000;
      res=WebRequest("GET",url,cookie,NULL,timeout,post,0,result,headers);
      if(res==-1)
        {
         Print("WebRequest error, err.code  =",GetLastError());
         MessageBox("You must add the address 'https://www.dailyfx.com/' in the list of allowed URL tab 'Advisors' "," Error ",MB_ICONINFORMATION);
        }
      else
        {
         int filehandle=FileOpen(FileName,FILE_WRITE|FILE_BIN);
         if(filehandle!=INVALID_HANDLE)
           {
            FileWriteArray(filehandle,result,0,ArraySize(result));
            FileClose(filehandle);
           }
         else
           {
            Print("Error in FileOpen. Error code =",GetLastError());
           }
        }
     }
   handle=FileOpen(FileName,FILE_READ|FILE_CSV);
   string data,time,month,valuta;
   int startStr=0;
   if(handle!=INVALID_HANDLE)
     {
      while(!FileIsEnding(handle))
        {
         int str_size=FileReadInteger(handle,INT_VALUE);
         string str=FileReadString(handle,str_size);
         string value[10];
         int k=StringSplit(str,StringGetCharacter(",",0),value);
         data = value[0];
         time = value[1];
         if(time=="")
           {
            continue;
           }
         month=StringSubstr(data,4,3);
         if(month=="Jan")
            month="01";
         if(month=="Feb")
            month="02";
         if(month=="Mar")
            month="03";
         if(month=="Apr")
            month="04";
         if(month=="May")
            month="05";
         if(month=="Jun")
            month="06";
         if(month=="Jul")
            month="07";
         if(month=="Aug")
            month="08";
         if(month=="Sep")
            month="09";
         if(month=="Oct")
            month="10";
         if(month=="Nov")
            month="11";
         if(month=="Dec")
            month="12";
         TimeNews[startStr]=StringToTime((string)YearFile+"."+month+"."+StringSubstr(data,8,2)+" "+time)+ChasPoyasServera*3600;
         valuta=value[3];
         if(valuta=="eur" ||valuta=="EUR")
            Valuta[startStr]="EUR";
         if(valuta=="usd" ||valuta=="USD")
            Valuta[startStr]="USD";
         if(valuta=="jpy" ||valuta=="JPY")
            Valuta[startStr]="JPY";
         if(valuta=="gbp" ||valuta=="GBP")
            Valuta[startStr]="GBP";
         if(valuta=="chf" ||valuta=="CHF")
            Valuta[startStr]="CHF";
         if(valuta=="cad" ||valuta=="CAD")
            Valuta[startStr]="CAD";
         if(valuta=="aud" ||valuta=="AUD")
            Valuta[startStr]="AUD";
         if(valuta=="nzd" ||valuta=="NZD")
            Valuta[startStr]="NZD";
         News[startStr]=value[4];
         News[startStr]=StringSubstr(News[startStr],0,60);
         Vazn[startStr]=value[5];
         if(Vazn[startStr]!="High" && Vazn[startStr]!="HIGH" && Vazn[startStr]!="Medium" && Vazn[startStr]!="MEDIUM" && Vazn[startStr]!="MED" && Vazn[startStr]!="Low" && Vazn[startStr]!="LOW")
            Vazn[startStr]=FileReadString(handle);
         startStr++;
        }
     }
   else
     {
      PrintFormat("Error in FileOpen = %s. Error code= %d",FileName,GetLastError());
     }
   NomNews=startStr-1;
   FileClose(handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckDailyFXNews(int &pwr,datetime &mintime)
  {

   bool CheckNews=false;
   pwr=0;
   int maxPower=0;
   color clrf=clrNONE;
   mintime=0;
   if(LowNews || MidleNews || HighNews || NFPNews)
     {
      if(iTime(Symbol(),PERIOD_CURRENT,0)-LastUpd>=Upd)
        {
         Print("News DailyFX Loading...");
         UpdateDFX();
         LastUpd=iTime(Symbol(),PERIOD_CURRENT,0);
        }
      ChartRedraw(0);
      //---Draw a line on the chart news--------------------------------------------
      if(DrawNewsLines)
        {
         for(int i=0; i<NomNews; i++)
           {
            string Lname=StringSubstr("NS_"+TimeToString(TimeNews[i],TIME_MINUTES)+"_"+News[i],0,63);
            if(News[i]!="")
               if(ObjectFind(0,Lname)==0)
                 {
                  continue;
                 }
            if(TimeNews[i]<TimeCurrent() && Next)
              {
               continue;
              }
            if((Vazn[i]=="High" || Vazn[i]=="HIGH") && HighNews==false)
              {
               continue;
              }
            if((Vazn[i]=="Medium" || Vazn[i]=="MEDIUM" || Vazn[i]=="MED") && MidleNews==false)
              {
               continue;
              }
            if((Vazn[i]=="Low" || Vazn[i]=="LOW") && LowNews==false)
              {
               continue;
              }
            if(Vazn[i]=="High" || Vazn[i]=="HIGH")
              {
               clrf=HighColor;
              }
            if(Vazn[i]=="Medium" || Vazn[i]=="MEDIUM" || Vazn[i]=="MED")
              {
               clrf=MidleColor;
              }
            if(Vazn[i]=="Low" || Vazn[i]=="LOW")
              {
               clrf=LowColor;
              }
            if(News[i]!="" && ObjectFind(0,Lname)<0)
              {
               if(OnlySymbolNews && (Valuta[i]!=StringSubstr(_Symbol,0,3) && Valuta[i]!=StringSubstr(_Symbol,3,3)))
                 {
                  continue;
                 }
               ObjectCreate(0,Lname,OBJ_VLINE,0,TimeNews[i],0);
               ObjectSetInteger(0,Lname,OBJPROP_COLOR,clrf);
               ObjectSetInteger(0,Lname,OBJPROP_STYLE,LineStyle);
               ObjectSetInteger(0,Lname,OBJPROP_WIDTH,LineWidth);
               ObjectSetInteger(0,Lname,OBJPROP_BACK,true);
              }
           }
        }
      //---------------event Processing------------------------------------
      for(int i=0; i<NomNews; i++)
        {
         int power=0;
         if(HighNews && (Vazn[i]=="High" || Vazn[i]=="HIGH"))
           {
            power=3;
            MinBefore=HighIndentBefore;
            MinAfter=HighIndentAfter;
           }
         if(MidleNews && (Vazn[i]=="Medium" || Vazn[i]=="MEDIUM" || Vazn[i]=="MED"))
           {
            power=2;
            MinBefore=MidleIndentBefore;
            MinAfter=MidleIndentAfter;
           }
         if(LowNews && (Vazn[i]=="Low" || Vazn[i]=="LOW"))
           {
            power=1;
            MinBefore=LowIndentBefore;
            MinAfter=LowIndentAfter;
           }
         if(NFPNews && StringFind(News[i],"Non-farm Payrolls")>=0)
           {
            power=4;
            MinBefore=NFPIndentBefore;
            MinAfter=NFPIndentAfter;
           }
         if(power==0)
            continue;

         if(TimeCurrent()+MinBefore*60>TimeNews[i] && TimeCurrent()-MinAfter*60<TimeNews[i] && (!OnlySymbolNews || (OnlySymbolNews && (StringSubstr(Symbol(),0,3)==Valuta[i] || StringSubstr(Symbol(),3,3)==Valuta[i]))))
           {
            if(power>maxPower)
              {
               maxPower=power;
               mintime=TimeNews[i];
              }
           }
         else
           {
            CheckNews=false;
           }
        }
      if(maxPower>0)
        {
         CheckNews=true;
        }
     }
   pwr=maxPower;
   return(CheckNews);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Open(int ind)
  {
   double candle_open=iOpen(Symbol(),TimeFrame31, ind);

///--- return open
   return(candle_open);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  High(int ind)
  {
   double candle_high=iHigh(Symbol(),TimeFrame31, ind);

///--- return high
   return(candle_high);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  Low(int ind)
  {
   double candle_low=iLow(Symbol(),TimeFrame31, ind);

///--- return low
   return(candle_low);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Close(int ind)
  {
   double candle_close=iClose(Symbol(),TimeFrame31, ind);

///--- return close
   return(candle_close);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CloseAvg(int ind)
  {
   double candle_clavg= arrayCMA[ind];

///--- return close average 
   return(candle_clavg);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double   MidPoint(int ind)
  {
   double candle_mid= 0.5*(High(ind)+Low(ind));

///--- return midpoint
   return(candle_mid);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MidOpenClose(int ind)
  {
   double candle_midoc= 0.5*(Open(ind)+Close(ind));

///--- return midopenclose 
   return(candle_midoc);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  AvgBody(int ind)
  {
   double candle_body=0;
///--- calculate the averaged size of the candle's body
   for(int i=ind; i<ind+Period31; i++)
     {
      candle_body+=MathAbs(Open(i)-Close(i));
     }
   candle_body=candle_body/Period31;
///--- return body size
   return(candle_body);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int BeCan()
  {
//--- 3 Black Crows
   if((Open(3)-Close(3)>AvgBody(1)) && // long black
      (Open(2)-Close(2)>AvgBody(1)) &&
      (Open(1)-Close(1)>AvgBody(1)) &&
      (MidPoint(2)<MidPoint(3))     && // lower midpoints
      (MidPoint(1)<MidPoint(2)))
      return(1);
//--- Dark cloud cover
   if((Close(2)-Open(2)>AvgBody(1)) && // long white
      (Close(1)<Close(2))           && // close within previous body
      (Close(1)>Open(2))            &&
      (MidOpenClose(2)>CloseAvg(1)) && // uptrend
      (Open(1)>High(2)))               // open at new high
      return(1);
//--- Evening Doji
   if((Close(3)-Open(3)>AvgBody(1)) &&
      (AvgBody(2)<AvgBody(1)*0.1)   &&
      (Close(2)>Close(3))           &&
      (Open(2)>Open(3))             &&
      (Open(1)<Close(2))            &&
      (Close(1)<Close(2)))
      return(1);
//--- Bearish Engulfing
   if((Open(2)<Close(2))            &&
      (Open(1)-Close(1)>AvgBody(1)) &&
      (Close(1)<Open(2))            &&
      (MidOpenClose(2)>CloseAvg(2)) &&
      (Open(1)>Close(2)))
      return(1);
//--- Evening Star
   if((Close(3)-Open(3)>AvgBody(1))              &&
      (MathAbs(Close(2)-Open(2))<AvgBody(1)*0.5) &&
      (Close(2)>Close(3))                        &&
      (Open(2)>Open(3))                          &&
      (Close(1)<MidOpenClose(3)))
      return(1);
////--- Hanging man
//   if((MidPoint(1)>CloseAvg(2))                                 && // up trend
//      (MathMin(Open(1),Close(1)>(High(1)-(High(1)-Low(1))/3.0)) && // body in upper 1/3
//       (Close(1)>Close(2)) && (Open(1)>Open(2))))                   // body gap
//      return(1);
//--- Bearish Harami
   if((Close(1)<Open(1))              && // black day
      ((Close(2)-Open(2))>AvgBody(1)) && // long white
      ((Close(1)>Open(2))             &&
       (Open(1)<Close(2)))             && // engulfment
      (MidPoint(2)>CloseAvg(2)))         // up trend
      return(1);
//--- Bearish MeetingLines
   if((Close(2)-Open(2)>AvgBody(1))                && // long white
      ((Open(1)-Close(1))>AvgBody(1))              && // long black
      (MathAbs(Close(1)-Close(2))<0.1*AvgBody(1)))    // doji close
      return(1);
   else
      return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int BuCan()
  {
//--- 3 White Soldiers
   if((Close(3)-Open(3)>AvgBody(1)) && // long white
      (Close(2)-Open(2)>AvgBody(1)) &&
      (Close(1)-Open(1)>AvgBody(1)) &&
      (MidPoint(2)>MidPoint(3))     && // higher midpoints
      (MidPoint(1)>MidPoint(2)))
      return(1);
//--- Piercing Line
   if((Close(1)-Open(1)>AvgBody(1)) && // long white
      (Open(2)-Close(2)>AvgBody(1)) && // long black
      (Close(2)>Close(1))           && // close inside previous body
      (Close(1)<Open(2))            &&
      (MidOpenClose(2)<CloseAvg(2)) && // downtrend
      (Open(1)<Low(2)))                // close inside previous body
      return(1);
//--- Morning Doji
   if((Open(3)-Close(3)>AvgBody(1)) &&
      (AvgBody(2)<AvgBody(1)*0.1)   &&
      (Close(2)<Close(3))           &&
      (Open(2)<Open(3))             &&
      (Open(1)>Close(2))            &&
      (Close(1)>Close(2)))
      return(1);
//--- Bullish Engulfing
   if((Open(2)>Close(2))            &&
      (Close(1)-Open(1)>AvgBody(1)) &&
      (Close(1)>Open(2))            &&
      (MidOpenClose(2)<CloseAvg(2)) &&
      (Open(1)<Close(2)))
      return(1);
//--- Morning Star
   if((Open(3)-Close(3)>AvgBody(1))              &&
      (MathAbs(Close(2)-Open(2))<AvgBody(1)*0.5) &&
      (Close(2)<Close(3))                        &&
      (Open(2)<Open(3))                          &&
      (Close(1)>MidOpenClose(3)))
      return(1);
//--- Hammer
   //if((MidPoint(1)<CloseAvg(2))                                  && // down trend
   //   (MathMin(Open(1),Close(1))>(High(1)-(High(1)-Low(1))/3.0)) && // body in upper 1/3
   //   (Close(1)<Close(2)) && (Open(1)<Open(2)))                     // body gap
   //   return(1);
//--- Bullish Harami
   if((Close(1)>Open(1))              && // white day
      ((Open(2)-Close(2))>AvgBody(1)) && // long black
      ((Close(1)<Open(2))             &&
       (Open(1)>Close(2)))             && // engulfment
      (MidPoint(2)<CloseAvg(2)))         // down trend
      return(1);
//--- Bullish MeetingLines
   if((Open(2)-Close(2)>AvgBody(1))             && // long black
      ((Close(1)-Open(1))>AvgBody(1))           && // long white
      (MathAbs(Close(1)-Close(2))<0.1*AvgBody(1))) // doji close
      return(1);
   else
      return(0);
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
int TimeDayOfWeekMQL4(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_week);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDayMQL4(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeMonthMQL4(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.mon);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeYearMQL4(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.year);
  }