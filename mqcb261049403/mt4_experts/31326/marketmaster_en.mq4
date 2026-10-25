//+------------------------------------------------------------------+
//|                                                Market Master.mq4 |
//|                                             Copyright 2020, YTMJ |
//|                           https://www.mql5.com/en/users/tradingg |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020,YTMJ"
#property link      "https://www.mql5.com/en/users/tradingg"
#property version   "1.4"
#property description "Attention! To work with this Expert Advisor you must add to the trusted URLs https://www.dailyfx.com/ and https://ec.forexprostools.com/"
#property description "This version expires on the 25th of December of 2020. This version can only be run in a Demo account. If you are interested in a Real account version, please contact me."
#property strict


enum ENUM_INDICATORS
  {
   ZERO,// Señal 0: Zero
   MA,// Señal 1: Sto
   PSAR,// Señal 2: PSAR
   MA_PSAR,// Señal 3: Sto+PSAR
  };


//--- Inputs
extern string     ExpertName = " ----------- Market Master EA -------------------------------------------------------------------------------------------";
extern int        Magic         = 606;      // Magic Number
extern string LR0 = "";
extern string LR1 = " ----------- Lots and Risk ---------------------------------------------------------------------------------------------------";
extern bool       Auto_Lot          = 1;       // true:Money management by balance
extern double     Risk_Multiplier   = 10;       // Risk of balance
extern double     Lots              = 0.1;      // Lot at start
extern bool       Profit_by_Percent   = 1;// true:Percent/false:Money
extern double     Loss              = 100;     // Loss
extern double     Profit            = 1;   // Profit
extern int        StopLoss  = 0;      // Stoploss for each order
extern string     IO0 = "";
extern string     IO1 = " ----------- First Order ------------------------------------------------------------------------------------------------";
extern int        TrailingStop  = 40;      // Trailing profit first order
extern int        TrailingStep  = 35;      // Trailing step first order
extern ENUM_TIMEFRAMES TimeForBars  = PERIOD_M15;// Timeframe to open orders
extern string     PO0 = "";
extern string     PO1 = " ----------- Activate Hedging Extra Orders --------------------------------------------------------------------------------";
extern bool       Open_same_signal= false;// Open orders in same signal
extern bool       Open_opposite_signal = true;// Open orders in opposite signal
extern  ENUM_INDICATORS  Ind_Method_Others = MA;
extern bool       Open_recov_system= false;//Multiplier based in TS
extern double     KLot              = 2; // Multiplier new order
extern int        Slip          = 300;   // Slippage
extern string     SS0 = " ";
extern string     SS1 = " ----------- Choose Signal to Open Orders ------------------------------------------------------------------------------";
extern string     SS2 = " ";
extern  ENUM_INDICATORS  Ind_Method = MA;
extern string     SS3 = " ";
extern string     IS1 = " ----------- Indicators to Open Orders -------------------------------------------------------------------------------";
extern string     IS2 = "";
extern string     iVOL      = "[Volumen]";
extern int        MinVol     = 3000;// Minimum volume
extern       ENUM_TIMEFRAMES     TimeFrame41     = PERIOD_CURRENT;//Timeframe
extern string     iVOLH      = "[Volumen Hedging]";
extern int        MinVolH     = 3000;// Minimum volume
extern       ENUM_TIMEFRAMES     TimeFrame42     = PERIOD_CURRENT;//Timeframe
int  Shift14         = 0;// Signal bar /current:0/previous:1
int  Shift17         = 1;// Barra señal /actual:0/anterior:1
int  Shift15         = 0;// Barra señal /actual:0/anterior:1
int  Shift18         = 1;// Barra señal /actual:0/anterior:1
extern string     IS4 = "";
extern string     MA1      = "[Stochastic]";
extern  ENUM_MA_METHOD  MAMethod4 = MODE_SMA;// Method
int  MAPrice4 = 0;//Price
extern     ENUM_TIMEFRAMES   TimeFrame4     = PERIOD_CURRENT; // Timeframe
extern int        PeriodK4     = 5;// Period K
extern int        PeriodD4     = 3;// Period D
extern int        Slowing4     = 3;// Slowing
extern int        Shift4         = 1;// Signal bar/previous:1
extern     ENUM_TIMEFRAMES   TimeFrame14     = PERIOD_CURRENT; // Timeframe
extern int        StoBuy     = 60;// Max for buy
extern int        StoSell     = 40;// Min for sell
extern string     IS5 = "";
extern string     ParabolicSAR      = "[PSAR]";
extern     ENUM_TIMEFRAMES   TimeFrame1     = PERIOD_CURRENT; // PSAR Timeframe
extern double     Step1 =        0.02;// Step
extern double     Maximum1     = 0.2;// Maximum
extern int        Shift1         = 0;// Signal bar/previous:1
extern string     iSarConfirmation = " ----------- PSAR Confirmation signal";
extern       ENUM_TIMEFRAMES  TimeFrame11     = PERIOD_CURRENT; // PSAR Timeframe
extern double     Step11 =        0.02;// Step
extern double     Maximum11     = 0.2;// Maximum
extern int        Shift11         = 1;// Signal bar/previous:1
extern string     IS7 = "";
extern string     IndName5      = "[Bull Bears]";
extern ENUM_TIMEFRAMES    TimeFrame20     = PERIOD_CURRENT; //BB Timeframe
extern int        Period20     = 14;// Period BB
extern string     IS8 = "";
extern string     IndName6      = "[ATR]";
extern ENUM_TIMEFRAMES    TimeFrame18     = PERIOD_CURRENT; //ATR Timeframe
extern int        Period18     = 14;// Period ATR
extern string     IndName7      = "[ATR Hedge]";
extern ENUM_TIMEFRAMES    TimeFrame17     = PERIOD_CURRENT; //ATR Hedge Timeframe
extern int        Period17     = 14;// Period ATR Hedge
extern string     IndName4      = "[MFI]";
extern ENUM_TIMEFRAMES    TimeFrame19     = PERIOD_CURRENT; // Timeframe
extern int        Period19     = 14;// Period
extern string HT0 = "";
extern string HT1 = " ----------- Hours for Opening Orders 00:00:00 Format -------------------------------------------------------------------------";
extern bool   ActiveBetweenHours      = 0;// Open only hours
extern string    HourToOpen       = "06:00:00";// Hour to open (00:00:00h to 23:59:59h)
extern string    HourToClose      = "18:00:00";// Hour to close (00:00:00h to 23:59:59h)
extern bool   HT1CloseOpenOrders      = 0;// true:Close orders /false:No new orders
extern string HT2 = " ----------- BREAK to not open new orders ----------- ";
extern string    HourNotToOpen       = "06:00:01";// Hour not to open (00:00:00h to 23:59:59h)
extern string    HourToOpenAgain       = "06:00:02";// Hour to open again (00:00:00h to 23:59:59h)
extern bool   HT2CloseOpenOrders      = 0;// true:Close orders /false:No new orders
extern   string   NS0="";
extern   string   NS1=" ----------- News Settings --------------------------------------------------------------------------------------------------";
enum TypeNS
  {
   INVEST=0,   // Investing.com
   DAILYFX=1,  // Dailyfx.com
  };
//--- input parameters
extern TypeNS SourceNews=INVEST;// Source for news
extern bool     LowNews             = true; // Activate: Low relevance
extern bool     CloseLow            = 0;// Close open orders
extern int      LowIndentBefore     = 15;// Minutes before
extern int      LowIndentAfter      = 15;// Minutes after
extern bool     MidleNews           = true;// Activate: Medium relevance
extern bool     CloseMidle          = 0;// Close open orders
extern int      MidleIndentBefore   = 30;// Minutes before
extern int      MidleIndentAfter    = 30;// Minutes after
extern bool     HighNews            = true;// Activate: High relevance
extern bool     CloseHigh           = 0;// Close open orders
extern int      HighIndentBefore    = 60;// Minutes before
extern int      HighIndentAfter     = 60;// Minutes after
extern bool     NFPNews             = true;// Activate: Non farm payrolls NFP
extern bool     CloseNFP            = 1;// Close open orders
extern int      NFPIndentBefore     = 180;// Minutes before
extern int      NFPIndentAfter      = 180;// Minutes after
extern bool    DrawNewsLines        = true;// Draw lines
extern color   LowColor             = clrGreen;// Low relevance color
extern color   MidleColor           = clrBlue;// Medium relevance color
extern color   HighColor            = clrRed;// High relevance color
extern int     LineWidth            = 1;// Line width
extern ENUM_LINE_STYLE LineStyle    = STYLE_DOT;// Style of line
extern bool    OnlySymbolNews       = true;// News only from symbol
extern int  GMTplus=3;     // Your Time Zone, GMT (for news)

int NomNews=0,Now=0,MinBefore=0,MinAfter=0;
string NewsArr[4][1000];
datetime LastUpd;
string ValStr;
int   Upd            = 86400;      // Period news updates in seconds
bool  Next           = false;      // Draw only the future of news line
bool  Signal         = false;      // Signals on the upcoming news
datetime TimeNews[300];
string Valuta[300],News[300],Vazn[300];

extern   string   OC1=" ----------- Orders Comments -----------------------------------------------------------------------------------------------";
extern string CommentBuy = "Buy_MarketMaster EA";
extern string CommentSell = "Sell_MarketMaster EA";

datetime expiryDate = D'2020.12.25 00:00';
//change as per your requirement
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(TimeCurrent() > expiryDate)
     {
     Alert("Expired copy. Please contact vendor.");
     }

//if(IsDemo())
//  {
//   Alert("Great. I am in a Demo account.");
//  }
//else
//  {
//   Alert("This version can only run in a Demo Account. Please contact vendor.");
//   ExpertRemove();
//  }

   string v1=StringSubstr(_Symbol,0,3);
   string v2=StringSubstr(_Symbol,3,3);
   ValStr=v1+","+v2;

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
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trailing()
  {
   bool mod;
   double sl=0;

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic)
           {
            if(OrderType()==OP_BUY)
              {
               if(Bid-OrderOpenPrice()>(MODE_SPREAD+TrailingStop)*_Point)
                 {
                  sl=NormalizeDouble(Bid-TrailingStep*_Point,_Digits);
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
               if(OrderOpenPrice()-Ask>(MODE_SPREAD+TrailingStop)*_Point)
                 {
                  sl=NormalizeDouble(Ask+TrailingStep*_Point,_Digits);
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
               RefreshRates();
               cl=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Bid,_Digits),Slip,White);
              }
            if(OrderType()==1 && (ot==1 || ot==-1))
              {
               RefreshRates();
               cl=OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(Ask,_Digits),Slip,White);
              }
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
   double LotStep=MarketInfo(Symbol(),MODE_LOTSTEP),LotSize=0;
   double MinimumLot=MarketInfo(NULL,MODE_MINLOT);
   double MaximumLot=MarketInfo(NULL,MODE_MAXLOT);

   if(!Auto_Lot)
     {
      lot=Lots;
     }

   else
      if(Auto_Lot)
        {
         if(LotStep==0.1)
           {
            lot=NormalizeDouble(((AccountBalance()*Risk_Multiplier)/100)/1000,1);
           }
         else
            if(LotStep==0.01)
              {
               lot=NormalizeDouble(((AccountBalance()*Risk_Multiplier)/100)/1000,2);
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
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
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
         LabelCreate(StringConcatenate(nstxt),clrT);
        }
      if(ObjectGetInteger(0,"NS_Label",OBJPROP_COLOR)!=clrT)
        {
         ObjectDelete(0,"NS_Label");
         LabelCreate(StringConcatenate(nstxt),clrT);
        }
     }
   nstxt="\n"+nstxt;
   /*  End Check News   */

   if(IsTradeAllowed() && trade)
     {
      // No news and Trade Allowed
      int total=OrdersTotal();
      int r=0;
      RefreshRates();

      double MA8 = iStochastic(NULL,TimeFrame4,PeriodK4,PeriodD4,Slowing4,MAMethod4,MAPrice4,0,0);
      double MA18 = iStochastic(NULL,TimeFrame4,PeriodK4,PeriodD4,Slowing4,MAMethod4,MAPrice4,1,0);
      double MA8B = iStochastic(NULL,TimeFrame14,PeriodK4,PeriodD4,Slowing4,MAMethod4,MAPrice4,0,0);
      double MA18S = iStochastic(NULL,TimeFrame14,PeriodK4,PeriodD4,Slowing4,MAMethod4,MAPrice4,1,0);
      double MA8pr = iStochastic(NULL,TimeFrame4,PeriodK4,PeriodD4,Slowing4,MAMethod4,MAPrice4,0,1);
      double MA18pr = iStochastic(NULL,TimeFrame4,PeriodK4,PeriodD4,Slowing4,MAMethod4,MAPrice4,1,1);

      double PSAR1 = iSAR(NULL,TimeFrame1,Step1,Maximum1,Shift1);
      double PSAR2 = iSAR(NULL,TimeFrame11,Step11,Maximum11,Shift11);

      double pos1pre = iBearsPower(NULL,TimeFrame20,Period20,PRICE_WEIGHTED,0);
      double pos2cur = iBullsPower(NULL,TimeFrame20,Period20,PRICE_WEIGHTED,0);

      double AD = iMFI(NULL,TimeFrame19,Period19,0);
      double AD1 = iMFI(NULL,TimeFrame19,Period19,1);

      double ATR = iATR(NULL,TimeFrame18,Period18,0);
      double ATR1 = iATR(NULL,TimeFrame18,Period18,1);

      double ATRH = iATR(NULL,TimeFrame17,Period17,0);
      double ATR1H = iATR(NULL,TimeFrame17,Period17,1);

      double slb=0;
      double sls=0;

      if(StopLoss>0)
         slb=NormalizeDouble(Ask-StopLoss*Point,Digits);

      if(StopLoss>0)
         sls=NormalizeDouble(Bid+StopLoss*Point,Digits);

      if((!Profit_by_Percent) &&(CountTrades()>1 && AllProfit()< -Loss))
         CloseAll();

      if((!Profit_by_Percent)&&(CountTrades()>1 && AllProfit()>Profit))
         CloseAll();

      if((Profit_by_Percent)&&(CountTrades()>1)&&((AccountProfit() / AccountEquity()) * 100 > Profit))
         CloseAll();

      if((Profit_by_Percent)&&(CountTrades()>1)&&((AccountProfit() / AccountEquity()) * 100 < -Loss))
         CloseAll();

      if(CountTrades()<1 && CountOrders()>0)
         DelOrder();

      if((CountTrades()>=1 && CountTrades()<2)&& TrailingStop>0)
         Trailing();

      if((ActiveBetweenHours)&&(HT1CloseOpenOrders)&&(TimeCurrent())>=StrToTime(HourToClose))
         CloseAll();

      if((ActiveBetweenHours)&&(HT2CloseOpenOrders)&&(TimeCurrent())>=StrToTime(HourNotToOpen))
         CloseAll();

      //+------------------------------------------------------------------+
      //|                  ZERO                                            |
      //+------------------------------------------------------------------+

      if(Ind_Method==ZERO)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpen))&&((TimeCurrent())<StrToTime(HourNotToOpen)))
            if(CountTrades()<1)
               if(OrdersHistoryTotal()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0))
                       {
                        int open=OrderSend(Symbol(),OP_BUY,Lot(),Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                       }
                     else
                        if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0))
                          {
                           int open=OrderSend(Symbol(),OP_SELL,Lot(),Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                          }

      if(Ind_Method==ZERO)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpenAgain))&&((TimeCurrent())<StrToTime(HourToClose)))
            if(CountTrades()<1)
               if(OrdersHistoryTotal()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0))
                       {
                        int open=OrderSend(Symbol(),OP_BUY,Lot(),Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                       }
                     else
                        if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0))
                          {
                           int open=OrderSend(Symbol(),OP_SELL,Lot(),Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                          }

      if(Ind_Method==ZERO)
         if(!ActiveBetweenHours)
            if(CountTrades()<1)
               if(OrdersHistoryTotal()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0))
                       {
                        int open=OrderSend(Symbol(),OP_BUY,Lot(),Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                       }
                     else
                        if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0))
                          {
                           int open=OrderSend(Symbol(),OP_SELL,Lot(),Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                          }

      if(Ind_Method==ZERO)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpenAgain))&&((TimeCurrent())<StrToTime(HourToClose)))
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0))
                       {
                        OpenNewBuy();
                        return;
                       }

      if(Ind_Method==ZERO)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpenAgain))&&((TimeCurrent())<StrToTime(HourToClose)))
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0))
                       {
                        OpenNewSell();
                        return;
                       }

      if(Ind_Method==ZERO)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpen))&&((TimeCurrent())<StrToTime(HourNotToOpen)))
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0))
                       {
                        OpenNewBuy();
                        return;
                       }

      if(Ind_Method==ZERO)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpen))&&((TimeCurrent())<StrToTime(HourNotToOpen)))
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0))
                       {
                        OpenNewSell();
                        return;
                       }

      if(Ind_Method==ZERO)
         if(!ActiveBetweenHours)
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0))
                       {
                        OpenNewBuy();
                        return;
                       }

      if(Ind_Method==ZERO)
         if(!ActiveBetweenHours)
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0))
                       {
                        OpenNewSell();
                        return;
                       }

      if(Ind_Method_Others==ZERO)
         if(Open_opposite_signal)
            if(CountTrades()>0)
               if(iVolume(NULL,TimeFrame42,1)>MinVolH)
                  if((ATRH>ATR1H)&&(AD>AD1)&&(pos1pre>0))
                     if(AccountEquity()<AccountBalance())
                       {
                        OpenOpBuy();
                        return;
                       }

      if(Ind_Method_Others==ZERO)
         if(Open_opposite_signal)
            if(CountTrades()>0)
               if(iVolume(NULL,TimeFrame42,1)>MinVolH)
                  if((ATRH>ATR1H)&&(AD<AD1)&&(pos2cur<0))
                     if(AccountEquity()<AccountBalance())
                       {
                        OpenOpSell();
                        return;
                       }

      if(Ind_Method_Others==ZERO)
         if(Open_same_signal)
            if(CountTrades()>0)
               if(iVolume(NULL,TimeFrame42,1)>MinVolH)
                  if((ATRH>ATR1H)&&(AD>AD1)&&(pos1pre>0))
                     if(AccountEquity()<AccountBalance())
                       {
                        OpenConBuy();
                        return;
                       }

      if(Ind_Method_Others==ZERO)
         if(Open_same_signal)
            if(CountTrades()>0)
               if(iVolume(NULL,TimeFrame42,1)>MinVolH)
                  if((ATRH>ATR1H)&&(AD<AD1)&&(pos2cur<0))
                     if(AccountEquity()<AccountBalance())
                       {
                        OpenConSell();
                        return;
                       }


      //+------------------------------------------------------------------+
      //|             PSAR                                                 |
      //+------------------------------------------------------------------+


      if(Ind_Method==PSAR)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpen))&&((TimeCurrent())<StrToTime(HourNotToOpen)))
            if(CountTrades()<1)
               if(OrdersHistoryTotal()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(Ask>PSAR1)&&(Ask>PSAR2))
                       {
                        int open=OrderSend(Symbol(),OP_BUY,Lot(),Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                       }
                     else
                        if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(Bid<PSAR1)&&(Bid<PSAR2))
                          {
                           int open=OrderSend(Symbol(),OP_SELL,Lot(),Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                          }

      if(Ind_Method==PSAR)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpenAgain))&&((TimeCurrent())<StrToTime(HourToClose)))
            if(CountTrades()<1)
               if(OrdersHistoryTotal()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(Ask>PSAR1)&&(Ask>PSAR2))
                       {
                        int open=OrderSend(Symbol(),OP_BUY,Lot(),Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                       }
                     else
                        if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(Bid<PSAR1)&&(Bid<PSAR2))
                          {
                           int open=OrderSend(Symbol(),OP_SELL,Lot(),Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                          }

      if(Ind_Method==PSAR)
         if(!ActiveBetweenHours)
            if(CountTrades()<1)
               if(OrdersHistoryTotal()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(Ask>PSAR1)&&(Ask>PSAR2))
                       {
                        int open=OrderSend(Symbol(),OP_BUY,Lot(),Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                       }
                     else
                        if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(Bid<PSAR1)&&(Bid<PSAR2))
                          {
                           int open=OrderSend(Symbol(),OP_SELL,Lot(),Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                          }

      if(Ind_Method==PSAR)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpenAgain))&&((TimeCurrent())<StrToTime(HourToClose)))
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(Ask>PSAR1)&&(Ask>PSAR2))
                       {
                        OpenNewBuy();
                        return;
                       }

      if(Ind_Method==PSAR)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpenAgain))&&((TimeCurrent())<StrToTime(HourToClose)))
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(Bid<PSAR1)&&(Bid<PSAR2))
                       {
                        OpenNewSell();
                        return;
                       }

      if(Ind_Method==PSAR)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpen))&&((TimeCurrent())<StrToTime(HourNotToOpen)))
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(Ask>PSAR1)&&(Ask>PSAR2))
                       {
                        OpenNewBuy();
                        return;
                       }

      if(Ind_Method==PSAR)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpen))&&((TimeCurrent())<StrToTime(HourNotToOpen)))
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(Bid<PSAR1)&&(Bid<PSAR2))
                       {
                        OpenNewSell();
                        return;
                       }

      if(Ind_Method==PSAR)
         if(!ActiveBetweenHours)
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(Ask>PSAR1)&&(Ask>PSAR2))
                       {
                        OpenNewBuy();
                        return;
                       }

      if(Ind_Method==PSAR)
         if(!ActiveBetweenHours)
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(Bid<PSAR1)&&(Bid<PSAR2))
                       {
                        OpenNewSell();
                        return;
                       }

      if(Ind_Method_Others==PSAR)
         if(Open_opposite_signal)
            if(CountTrades()>0)
               if(iVolume(NULL,TimeFrame42,1)>MinVolH)
                  if((ATRH>ATR1H)&&(AD>AD1)&&(pos1pre>0)&&(Ask>PSAR1)&&(Ask>PSAR2))
                     if(AccountEquity()<AccountBalance())
                       {
                        OpenOpBuy();
                        return;
                       }

      if(Ind_Method_Others==PSAR)
         if(Open_opposite_signal)
            if(CountTrades()>0)
               if(iVolume(NULL,TimeFrame42,1)>MinVolH)
                  if((ATRH>ATR1H)&&(AD<AD1)&&(pos2cur<0)&&(Bid<PSAR1)&&(Bid<PSAR2))
                     if(AccountEquity()<AccountBalance())
                       {
                        OpenOpSell();
                        return;
                       }

      if(Ind_Method_Others==PSAR)
         if(Open_same_signal)
            if(CountTrades()>0)
               if(iVolume(NULL,TimeFrame42,1)>MinVolH)
                  if((ATRH>ATR1H)&&(AD>AD1)&&(pos1pre>0)&&(Ask>PSAR1)&&(Ask>PSAR2))
                     if(AccountEquity()<AccountBalance())
                       {
                        OpenConBuy();
                        return;
                       }

      if(Ind_Method_Others==PSAR)
         if(Open_same_signal)
            if(CountTrades()>0)
               if(iVolume(NULL,TimeFrame42,1)>MinVolH)
                  if((ATRH>ATR1H)&&(AD<AD1)&&(pos2cur<0)&&(Bid<PSAR1)&&(Bid<PSAR2))
                     if(AccountEquity()<AccountBalance())
                       {
                        OpenConSell();
                        return;
                       }


      //+------------------------------------------------------------------+
      //|             MA                                                   |
      //+------------------------------------------------------------------+

      if(Ind_Method==MA)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpen))&&((TimeCurrent())<StrToTime(HourNotToOpen)))
            if(CountTrades()<1)
               if(OrdersHistoryTotal()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(MA8B<StoBuy)&&(MA8>MA18)&&(MA8>MA8pr))
                       {
                        int open=OrderSend(Symbol(),OP_BUY,Lot(),Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                       }
                     else
                        if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(MA18S>StoSell)&&(MA8<MA18)&&(MA18<MA18pr))
                          {
                           int open=OrderSend(Symbol(),OP_SELL,Lot(),Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                          }

      if(Ind_Method==MA)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpenAgain))&&((TimeCurrent())<StrToTime(HourToClose)))
            if(CountTrades()<1)
               if(OrdersHistoryTotal()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(MA8B<StoBuy)&&(MA8>MA18)&&(MA8>MA8pr))
                       {
                        int open=OrderSend(Symbol(),OP_BUY,Lot(),Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                       }
                     else
                        if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(MA18S>StoSell)&&(MA8<MA18)&&(MA18<MA18pr))
                          {
                           int open=OrderSend(Symbol(),OP_SELL,Lot(),Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                          }

      if(Ind_Method==MA)
         if(!ActiveBetweenHours)
            if(CountTrades()<1)
               if(OrdersHistoryTotal()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(MA8B<StoBuy)&&(MA8>MA18)&&(MA8>MA8pr))
                       {
                        int open=OrderSend(Symbol(),OP_BUY,Lot(),Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                       }
                     else
                        if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(MA18S>StoSell)&&(MA8<MA18)&&(MA18<MA18pr))
                          {
                           int open=OrderSend(Symbol(),OP_SELL,Lot(),Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                          }

      if(Ind_Method==MA)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpenAgain))&&((TimeCurrent())<StrToTime(HourToClose)))
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(MA8B<StoBuy)&&(MA8>MA18)&&(MA8>MA8pr))
                       {
                        OpenNewBuy();
                        return;
                       }

      if(Ind_Method==MA)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpenAgain))&&((TimeCurrent())<StrToTime(HourToClose)))
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(MA18S>StoSell)&&(MA8<MA18)&&(MA18<MA18pr))
                       {
                        OpenNewSell();
                        return;
                       }

      if(Ind_Method==MA)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpen))&&((TimeCurrent())<StrToTime(HourNotToOpen)))
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(MA8B<StoBuy)&&(MA8>MA18)&&(MA8>MA8pr))
                       {
                        OpenNewBuy();
                        return;
                       }

      if(Ind_Method==MA)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpen))&&((TimeCurrent())<StrToTime(HourNotToOpen)))
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(MA18S>StoSell)&&(MA8<MA18)&&(MA18<MA18pr))
                       {
                        OpenNewSell();
                        return;
                       }

      if(Ind_Method==MA)
         if(!ActiveBetweenHours)
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(MA8B<StoBuy)&&(MA8>MA18)&&(MA8>MA8pr))
                       {
                        OpenNewBuy();
                        return;
                       }

      if(Ind_Method==MA)
         if(!ActiveBetweenHours)
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(MA18S>StoSell)&&(MA8<MA18)&&(MA18<MA18pr))
                       {
                        OpenNewSell();
                        return;
                       }

      if(Ind_Method_Others==MA)
         if(Open_opposite_signal)
            if(CountTrades()>0)
               if(iVolume(NULL,TimeFrame42,1)>MinVolH)
                  if((ATRH>ATR1H)&&(AD>AD1)&&(pos1pre>0)&&(MA8B<StoBuy)&&(MA8>MA18)&&(MA8>MA8pr))
                     if(AccountEquity()<AccountBalance())
                       {
                        OpenOpBuy();
                        return;
                       }

      if(Ind_Method_Others==MA)
         if(Open_opposite_signal)
            if(CountTrades()>0)
               if(iVolume(NULL,TimeFrame42,1)>MinVolH)
                  if((ATRH>ATR1H)&&(AD<AD1)&&(pos2cur<0)&&(MA18S>StoSell)&&(MA8<MA18)&&(MA18<MA18pr))
                     if(AccountEquity()<AccountBalance())
                       {
                        OpenOpSell();
                        return;
                       }

      if(Ind_Method_Others==MA)
         if(Open_same_signal)
            if(CountTrades()>0)
               if(iVolume(NULL,TimeFrame42,1)>MinVolH)
                  if((ATRH>ATR1H)&&(AD>AD1)&&(pos1pre>0)&&(MA8B<StoBuy)&&(MA8>MA18)&&(MA8>MA8pr))
                     if(AccountEquity()<AccountBalance())
                       {
                        OpenConBuy();
                        return;
                       }

      if(Ind_Method_Others==MA)
         if(Open_same_signal)
            if(CountTrades()>0)
               if(iVolume(NULL,TimeFrame42,1)>MinVolH)
                  if((ATRH>ATR1H)&&(AD<AD1)&&(pos2cur<0)&&(MA18S>StoSell)&&(MA8<MA18)&&(MA18<MA18pr))
                     if(AccountEquity()<AccountBalance())
                       {
                        OpenConSell();
                        return;
                       }


      //+------------------------------------------------------------------+
      //|             MA_PSAR                                              |
      //+------------------------------------------------------------------+

      if(Ind_Method==MA_PSAR)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpen))&&((TimeCurrent())<StrToTime(HourNotToOpen)))
            if(CountTrades()<1)
               if(OrdersHistoryTotal()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(Ask>PSAR1)&&(Ask>PSAR2)&&(MA8B<StoBuy)&&(MA8>MA18)&&(MA8>MA8pr))
                       {
                        int open=OrderSend(Symbol(),OP_BUY,Lot(),Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                       }
                     else
                        if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(Bid<PSAR1)&&(Bid<PSAR2)&&(MA18S>StoSell)&&(MA8<MA18)&&(MA18<MA18pr))
                          {
                           int open=OrderSend(Symbol(),OP_SELL,Lot(),Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                          }

      if(Ind_Method==MA_PSAR)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpenAgain))&&((TimeCurrent())<StrToTime(HourToClose)))
            if(CountTrades()<1)
               if(OrdersHistoryTotal()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(Ask>PSAR1)&&(Ask>PSAR2)&&(MA8B<StoBuy)&&(MA8>MA18)&&(MA8>MA8pr))
                       {
                        int open=OrderSend(Symbol(),OP_BUY,Lot(),Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                       }
                     else
                        if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(Bid<PSAR1)&&(Bid<PSAR2)&&(MA18S>StoSell)&&(MA8<MA18)&&(MA18<MA18pr))
                          {
                           int open=OrderSend(Symbol(),OP_SELL,Lot(),Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                          }

      if(Ind_Method==MA_PSAR)
         if(!ActiveBetweenHours)
            if(CountTrades()<1)
               if(OrdersHistoryTotal()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(Ask>PSAR1)&&(Ask>PSAR2)&&(MA8B<StoBuy)&&(MA8>MA18)&&(MA8>MA8pr))
                       {
                        int open=OrderSend(Symbol(),OP_BUY,Lot(),Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                       }
                     else
                        if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(Bid<PSAR1)&&(Bid<PSAR2)&&(MA18S>StoSell)&&(MA8<MA18)&&(MA18<MA18pr))
                          {
                           int open=OrderSend(Symbol(),OP_SELL,Lot(),Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                          }

      if(Ind_Method==MA_PSAR)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpenAgain))&&((TimeCurrent())<StrToTime(HourToClose)))
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(Ask>PSAR1)&&(Ask>PSAR2)&&(MA8B<StoBuy)&&(MA8>MA18)&&(MA8>MA8pr))
                       {
                        OpenNewBuy();
                        return;
                       }

      if(Ind_Method==MA_PSAR)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpenAgain))&&((TimeCurrent())<StrToTime(HourToClose)))
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(Bid<PSAR1)&&(Bid<PSAR2)&&(MA18S>StoSell)&&(MA8<MA18)&&(MA18<MA18pr))
                       {
                        OpenNewSell();
                        return;
                       }

      if(Ind_Method==MA_PSAR)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpen))&&((TimeCurrent())<StrToTime(HourNotToOpen)))
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(Ask>PSAR1)&&(Ask>PSAR2)&&(MA8B<StoBuy)&&(MA8>MA18)&&(MA8>MA8pr))
                       {
                        OpenNewBuy();
                        return;
                       }

      if(Ind_Method==MA_PSAR)
         if((ActiveBetweenHours)&&((TimeCurrent())>=StrToTime(HourToOpen))&&((TimeCurrent())<StrToTime(HourNotToOpen)))
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(Bid<PSAR1)&&(Bid<PSAR2)&&(MA18S>StoSell)&&(MA8<MA18)&&(MA18<MA18pr))
                       {
                        OpenNewSell();
                        return;
                       }

      if(Ind_Method==MA_PSAR)
         if(!ActiveBetweenHours)
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD>AD1)&&(pos1pre>0)&&(Ask>PSAR1)&&(Ask>PSAR2)&&(MA8B<StoBuy)&&(MA8>MA18)&&(MA8>MA8pr))
                       {
                        OpenNewBuy();
                        return;
                       }

      if(Ind_Method==MA_PSAR)
         if(!ActiveBetweenHours)
            if(OrdersHistoryTotal()>0)
               if(CountTrades()<1)
                  if(iVolume(NULL,TimeFrame41,1)>MinVol)
                     if((ATR>ATR1)&&(AD<AD1)&&(pos2cur<0)&&(Bid<PSAR1)&&(Bid<PSAR2)&&(MA18S>StoSell)&&(MA8<MA18)&&(MA18<MA18pr))
                       {
                        OpenNewSell();
                        return;
                       }

      if(Ind_Method_Others==MA_PSAR)
         if(Open_opposite_signal)
            if(CountTrades()>0)
               if(iVolume(NULL,TimeFrame42,1)>MinVolH)
                  if((ATRH>ATR1H)&&(AD>AD1)&&(pos1pre>0)&&(Ask>PSAR1)&&(Ask>PSAR2)&&(MA8B<StoBuy)&&(MA8>MA18)&&(MA8>MA8pr))
                     if(AccountEquity()<AccountBalance())
                       {
                        OpenOpBuy();
                        return;
                       }

      if(Ind_Method_Others==MA_PSAR)
         if(Open_opposite_signal)
            if(CountTrades()>0)
               if(iVolume(NULL,TimeFrame42,1)>MinVolH)
                  if((ATRH>ATR1H)&&(AD<AD1)&&(pos2cur<0)&&(Bid<PSAR1)&&(Bid<PSAR2)&&(MA18S>StoSell)&&(MA8<MA18)&&(MA18<MA18pr))
                     if(AccountEquity()<AccountBalance())
                       {
                        OpenOpSell();
                        return;
                       }

      if(Ind_Method_Others==MA_PSAR)
         if(Open_same_signal)
            if(CountTrades()>0)
               if(iVolume(NULL,TimeFrame42,1)>MinVolH)
                  if((ATRH>ATR1H)&&(AD>AD1)&&(pos1pre>0)&&(Ask>PSAR1)&&(Ask>PSAR2)&&(MA8B<StoBuy)&&(MA8>MA18)&&(MA8>MA8pr))
                     if(AccountEquity()<AccountBalance())
                       {
                        OpenConBuy();
                        return;
                       }

      if(Ind_Method_Others==MA_PSAR)
         if(Open_same_signal)
            if(CountTrades()>0)
               if(iVolume(NULL,TimeFrame42,1)>MinVolH)
                  if((ATRH>ATR1H)&&(AD<AD1)&&(pos2cur<0)&&(Bid<PSAR1)&&(Bid<PSAR2)&&(MA18S>StoSell)&&(MA8<MA18)&&(MA18<MA18pr))
                     if(AccountEquity()<AccountBalance())
                       {
                        OpenConSell();
                        return;
                       }



      TextDisplay=TextDisplay+nstxt;
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      Comment(
         "Expert Advisor","\n",
         "===================","\n",
         "Market Master EA","\n",
         "===================","\n","\n",
         "UP Strength: ",pos1pre,"\n",
         "DN Strength: ",pos2cur,"\n","\n",
         "Account Balance: ", AccountBalance(),"\n",
         "Profit at Symbol : ",AllProfit(),"\n","\n",
         "Time: ", TimeCurrent(),"\n",
         "Check News : ",TextDisplay,"\n","\n",
         "SPREAD:","\n",
         MarketInfo(Symbol(),MODE_SPREAD)/10,"\n"
      );
     }
   return;
  }
//+------------------------------------------------------------------+
void OpenOpSell()
  {
   double sls=0;
   if(StopLoss>0)
      sls=NormalizeDouble(Bid+StopLoss*Point,Digits);
   double klot=1;
   double Klot=1;
   if(Open_recov_system)
      if(klot>1)
         Klot=Klot*klot;

   if(!Open_recov_system)
      if(KLot>0)
         klot=KLot;

   if(Open_recov_system)
     {
      for(int i=OrdersTotal(); i>=0; i--)
         if(OrderSelect(i-1,SELECT_BY_POS,MODE_TRADES))
            if(OrderSymbol()==Symbol())
               if(IsNewCandle())
                  if(OrderMagicNumber()==Magic)
                    {
                     if(OrderType()==OP_BUY)
                        if(OrderOpenPrice()-Ask>TrailingStop*_Point)
                           if(((OrderOpenPrice()-Ask)>1*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*_Point))
                              int r= OrderSend(Symbol(),OP_SELL,Lot()*4,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                           else
                              if(((OrderOpenPrice()-Ask)>TrailingStop*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*2*_Point))
                                 int r= OrderSend(Symbol(),OP_SELL,Lot()*7,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                              else
                                 if(((OrderOpenPrice()-Ask)>TrailingStop*2*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*3*_Point))
                                    int r= OrderSend(Symbol(),OP_SELL,Lot()*10,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                                 else
                                    if(((OrderOpenPrice()-Ask)>TrailingStop*3*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*4*_Point))
                                       int r= OrderSend(Symbol(),OP_SELL,Lot()*14,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                                    else
                                       if(((OrderOpenPrice()-Ask)>TrailingStop*4*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*5*_Point))
                                          int r= OrderSend(Symbol(),OP_SELL,Lot()*17,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                                       else
                                          if(((OrderOpenPrice()-Ask)>TrailingStop*5*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*6*_Point))
                                             int r= OrderSend(Symbol(),OP_SELL,Lot()*20,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                                          else
                                             if(((OrderOpenPrice()-Ask)>TrailingStop*6*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*7*_Point))
                                                int r= OrderSend(Symbol(),OP_SELL,Lot()*24,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                                             else
                                                if(((OrderOpenPrice()-Ask)>TrailingStop*7*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*8*_Point))
                                                   int r= OrderSend(Symbol(),OP_SELL,Lot()*27,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                                                else
                                                   if(((OrderOpenPrice()-Ask)>TrailingStop*8*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*9*_Point))
                                                      int r= OrderSend(Symbol(),OP_SELL,Lot()*30,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                                                   else
                                                      if(((OrderOpenPrice()-Ask)>TrailingStop*9*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*10*_Point))
                                                         int r= OrderSend(Symbol(),OP_SELL,Lot()*34,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                                                      else
                                                         if(((OrderOpenPrice()-Ask)>TrailingStop*10*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*11*_Point))
                                                            int r= OrderSend(Symbol(),OP_SELL,Lot()*37,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                                                         else
                                                            if(((OrderOpenPrice()-Ask)>TrailingStop*11*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*12*_Point))
                                                               int r= OrderSend(Symbol(),OP_SELL,Lot()*40,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                    }
     }
   else
      if(!Open_recov_system)
         for(int i=OrdersTotal(); i>=0; i--)
            if(OrderSelect(i-1,SELECT_BY_POS,MODE_TRADES))
               if(OrderSymbol()==Symbol())
                  if(IsNewCandle())
                     if(OrderMagicNumber()==Magic)
                       {
                        if(OrderType()==OP_BUY)
                          {
                           int r= OrderSend(Symbol(),OP_SELL,Lot()*klot,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
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
      slb=NormalizeDouble(Ask-StopLoss*Point,Digits);
   double klot=1;
   double Klot=1;

   if(Open_recov_system)
      if(klot>1)
         Klot=Klot*klot;

   if(!Open_recov_system)
      if(KLot>0)
         klot=KLot;

   if(Open_recov_system)
     {
      for(int i=OrdersTotal(); i>=0; i--)
         if(OrderSelect(i-1,SELECT_BY_POS,MODE_TRADES))
            if(OrderSymbol()==Symbol())
               if(IsNewCandle())
                  if(OrderMagicNumber()==Magic)
                    {
                     if(OrderType()==OP_SELL)
                        if(Bid - OrderOpenPrice()>TrailingStop*_Point)
                           if((Bid-(OrderOpenPrice())>1*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*_Point))
                              int  r= OrderSend(Symbol(),OP_BUY,Lot()*4,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                           else
                              if((Bid-(OrderOpenPrice())>TrailingStop*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*2*_Point))
                                 int  r= OrderSend(Symbol(),OP_BUY,Lot()*7,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                              else
                                 if((Bid-(OrderOpenPrice())>TrailingStop*2*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*3*_Point))
                                    int  r= OrderSend(Symbol(),OP_BUY,Lot()*10,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                                 else
                                    if((Bid-(OrderOpenPrice())>TrailingStop*3*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*4*_Point))
                                       int  r= OrderSend(Symbol(),OP_BUY,Lot()*14,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                                    else
                                       if((Bid-(OrderOpenPrice())>TrailingStop*4*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*5*_Point))
                                          int  r= OrderSend(Symbol(),OP_BUY,Lot()*17,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                                       else
                                          if((Bid-(OrderOpenPrice())>TrailingStop*5*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*6*_Point))
                                             int  r= OrderSend(Symbol(),OP_BUY,Lot()*20,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                                          else
                                             if((Bid-(OrderOpenPrice())>TrailingStop*6*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*7*_Point))
                                                int  r= OrderSend(Symbol(),OP_BUY,Lot()*24,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                                             else
                                                if((Bid-(OrderOpenPrice())>TrailingStop*7*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*8*_Point))
                                                   int  r= OrderSend(Symbol(),OP_BUY,Lot()*27,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                                                else
                                                   if((Bid-(OrderOpenPrice())>TrailingStop*8*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*9*_Point))
                                                      int  r= OrderSend(Symbol(),OP_BUY,Lot()*30,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                                                   else
                                                      if((Bid-(OrderOpenPrice())>TrailingStop*9*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*10*_Point))
                                                         int  r= OrderSend(Symbol(),OP_BUY,Lot()*34,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                                                      else
                                                         if((Bid-(OrderOpenPrice())>TrailingStop*10*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*11*_Point))
                                                            int  r= OrderSend(Symbol(),OP_BUY,Lot()*37,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                                                         else
                                                            if((Bid-(OrderOpenPrice())>TrailingStop*11*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*12*_Point))
                                                               int  r= OrderSend(Symbol(),OP_BUY,Lot()*40,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                    }
     }
   else
      if(!Open_recov_system)
         for(int i=OrdersTotal(); i>=0; i--)
            if(OrderSelect(i-1,SELECT_BY_POS,MODE_TRADES))
               if(OrderSymbol()==Symbol())
                  if(IsNewCandle())
                     if(OrderMagicNumber()==Magic)
                       {
                        if(OrderType()==OP_SELL)
                          {
                           int  r= OrderSend(Symbol(),OP_BUY,Lot()*klot,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
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
      sls=NormalizeDouble(Bid+StopLoss*Point,Digits);
   double klot=1;
   double Klot=1;
   if(Open_recov_system)
      if(klot>1)
         Klot=Klot*klot;

   if(!Open_recov_system)
      if(KLot>0)
         klot=KLot;

   if(Open_recov_system)
     {
      for(int i=OrdersTotal(); i>=0; i--)
         if(OrderSelect(i-1, SELECT_BY_POS,MODE_TRADES))
            if(OrderSymbol()==Symbol())
               if(IsNewCandle())
                  if(OrderMagicNumber()==Magic)
                    {
                     if((Bid - OrderOpenPrice()>TrailingStop*_Point)||(OrderOpenPrice()-Ask>TrailingStop*_Point))
                        if(((Bid-(OrderOpenPrice())>1*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*_Point))||(((OrderOpenPrice()-Ask)>1*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*_Point)))
                           int r= OrderSend(Symbol(),OP_SELL,Lot()*4,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                        else
                           if(((Bid-(OrderOpenPrice())>TrailingStop*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*2*_Point))||(((OrderOpenPrice()-Ask)>TrailingStop*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*2*_Point)))
                              int r= OrderSend(Symbol(),OP_SELL,Lot()*7,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                           else
                              if(((Bid-(OrderOpenPrice())>TrailingStop*2*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*3*_Point))||(((OrderOpenPrice()-Ask)>TrailingStop*2*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*3*_Point)))
                                 int r= OrderSend(Symbol(),OP_SELL,Lot()*10,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                              else
                                 if(((Bid-(OrderOpenPrice())>TrailingStop*3*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*4*_Point))||(((OrderOpenPrice()-Ask)>TrailingStop*3*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*4*_Point)))
                                    int r= OrderSend(Symbol(),OP_SELL,Lot()*14,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                                 else
                                    if(((Bid-(OrderOpenPrice())>TrailingStop*4*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*5*_Point))||(((OrderOpenPrice()-Ask)>TrailingStop*4*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*5*_Point)))
                                       int r= OrderSend(Symbol(),OP_SELL,Lot()*17,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                                    else
                                       if(((Bid-(OrderOpenPrice())>TrailingStop*5*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*6*_Point))||(((OrderOpenPrice()-Ask)>TrailingStop*5*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*6*_Point)))
                                          int r= OrderSend(Symbol(),OP_SELL,Lot()*20,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                                       else
                                          if(((Bid-(OrderOpenPrice())>TrailingStop*6*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*7*_Point))||(((OrderOpenPrice()-Ask)>TrailingStop*6*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*7*_Point)))
                                             int r= OrderSend(Symbol(),OP_SELL,Lot()*24,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                                          else
                                             if(((Bid-(OrderOpenPrice())>TrailingStop*7*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*8*_Point))||(((OrderOpenPrice()-Ask)>TrailingStop*7*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*8*_Point)))
                                                int r= OrderSend(Symbol(),OP_SELL,Lot()*27,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                                             else
                                                if(((Bid-(OrderOpenPrice())>TrailingStop*8*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*9*_Point))||(((OrderOpenPrice()-Ask)>TrailingStop*8*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*9*_Point)))
                                                   int r= OrderSend(Symbol(),OP_SELL,Lot()*30,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                                                else
                                                   if(((Bid-(OrderOpenPrice())>TrailingStop*9*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*10*_Point))||(((OrderOpenPrice()-Ask)>TrailingStop*9*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*10*_Point)))
                                                      int r= OrderSend(Symbol(),OP_SELL,Lot()*34,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                                                   else
                                                      if(((Bid-(OrderOpenPrice())>TrailingStop*10*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*11*_Point))||(((OrderOpenPrice()-Ask)>TrailingStop*10*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*11*_Point)))
                                                         int r= OrderSend(Symbol(),OP_SELL,Lot()*37,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                                                      else
                                                         if(((Bid-(OrderOpenPrice())>TrailingStop*11*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*12*_Point))||(((OrderOpenPrice()-Ask)>TrailingStop*11*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*12*_Point)))
                                                            int r= OrderSend(Symbol(),OP_SELL,Lot()*40,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
                    }
     }
   else
      if(!Open_recov_system)
         for(int i=OrdersTotal(); i>=0; i--)
            if(OrderSelect(i-1, SELECT_BY_POS,MODE_TRADES))
               if(OrderSymbol()==Symbol())
                  if(OrderMagicNumber()==Magic)
                     if(IsNewCandle())
                       {
                        int r= OrderSend(Symbol(),OP_SELL,Lot()*klot,Bid,Slip,sls,0,CommentSell,Magic,0,Red);
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
      slb=NormalizeDouble(Ask-StopLoss*Point,Digits);
   double klot=1;
   double Klot=1;
   if(Open_recov_system)
      if(klot>1)
         Klot=Klot*klot;

   if(!Open_recov_system)
      if(KLot>0)
         klot=KLot;

   if(Open_recov_system)
     {
      for(int i=OrdersTotal(); i>=0; i--)
         if(OrderSelect(i-1, SELECT_BY_POS,MODE_TRADES))
            if(OrderSymbol()==Symbol())
               if(IsNewCandle())
                  if(OrderMagicNumber()==Magic)
                    {
                     if((OrderOpenPrice()-Ask>TrailingStop*_Point)||(Bid - OrderOpenPrice()>TrailingStop*_Point))
                        if((((OrderOpenPrice()-Ask)>1*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*_Point))||((Bid-(OrderOpenPrice())>1*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*_Point)))
                           int  r= OrderSend(Symbol(),OP_BUY,Lot()*4,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                        else
                           if((((OrderOpenPrice()-Ask)>TrailingStop*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*2*_Point))||((Bid-(OrderOpenPrice())>TrailingStop*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*2*_Point)))
                              int  r= OrderSend(Symbol(),OP_BUY,Lot()*7,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                           else
                              if((((OrderOpenPrice()-Ask)>TrailingStop*2*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*3*_Point))||((Bid-(OrderOpenPrice())>TrailingStop*2*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*3*_Point)))
                                 int  r= OrderSend(Symbol(),OP_BUY,Lot()*10,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                              else
                                 if((((OrderOpenPrice()-Ask)>TrailingStop*3*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*4*_Point))||((Bid-(OrderOpenPrice())>TrailingStop*3*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*4*_Point)))
                                    int  r= OrderSend(Symbol(),OP_BUY,Lot()*14,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                                 else
                                    if((((OrderOpenPrice()-Ask)>TrailingStop*4*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*5*_Point))||((Bid-(OrderOpenPrice())>TrailingStop*4*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*5*_Point)))
                                       int  r= OrderSend(Symbol(),OP_BUY,Lot()*17,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                                    else
                                       if((((OrderOpenPrice()-Ask)>TrailingStop*5*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*6*_Point))||((Bid-(OrderOpenPrice())>TrailingStop*5*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*6*_Point)))
                                          int  r= OrderSend(Symbol(),OP_BUY,Lot()*20,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                                       else
                                          if((((OrderOpenPrice()-Ask)>TrailingStop*6*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*7*_Point))||((Bid-(OrderOpenPrice())>TrailingStop*6*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*7*_Point)))
                                             int  r= OrderSend(Symbol(),OP_BUY,Lot()*24,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                                          else
                                             if((((OrderOpenPrice()-Ask)>TrailingStop*7*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*8*_Point))||((Bid-(OrderOpenPrice())>TrailingStop*7*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*8*_Point)))
                                                int  r= OrderSend(Symbol(),OP_BUY,Lot()*27,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                                             else
                                                if((((OrderOpenPrice()-Ask)>TrailingStop*8*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*9*_Point))||((Bid-(OrderOpenPrice())>TrailingStop*8*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*9*_Point)))
                                                   int  r= OrderSend(Symbol(),OP_BUY,Lot()*30,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                                                else
                                                   if((((OrderOpenPrice()-Ask)>TrailingStop*9*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*10*_Point))||((Bid-(OrderOpenPrice())>TrailingStop*9*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*10*_Point)))
                                                      int  r= OrderSend(Symbol(),OP_BUY,Lot()*34,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                                                   else
                                                      if((((OrderOpenPrice()-Ask)>TrailingStop*10*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*11*_Point))||((Bid-(OrderOpenPrice())>TrailingStop*10*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*11*_Point)))
                                                         int  r= OrderSend(Symbol(),OP_BUY,Lot()*37,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                                                      else
                                                         if((((OrderOpenPrice()-Ask)>TrailingStop*11*_Point)&&((OrderOpenPrice()-Ask)<TrailingStop*12*_Point))||((Bid-(OrderOpenPrice())>TrailingStop*11*_Point) && (Bid-(OrderOpenPrice())<TrailingStop*12*_Point)))
                                                            int  r= OrderSend(Symbol(),OP_BUY,Lot()*40,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
                    }
     }
   else
      if(!Open_recov_system)
         for(int i=OrdersTotal(); i>=0; i--)
            if(OrderSelect(i-1, SELECT_BY_POS,MODE_TRADES))
               if(OrderSymbol()==Symbol())
                  if(OrderMagicNumber()==Magic)
                     if(IsNewCandle())
                       {
                        int  r= OrderSend(Symbol(),OP_BUY,Lot()*klot,Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
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
      sls=NormalizeDouble(Bid+StopLoss*Point,Digits);

   for(int i=OrdersHistoryTotal(); i>=0; i--)
      if(OrderSelect(i-1, SELECT_BY_POS,MODE_HISTORY))
         if(OrderSymbol()==Symbol())
            if(OrderMagicNumber()==Magic)
               if(CountTrades()<1)
                 {
                  if(IsNewCandle())
                    {
                     int r= OrderSend(Symbol(),OP_SELL,Lot(),Bid,Slip,sls,0,CommentSell,Magic,0,Red);
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
      slb=NormalizeDouble(Ask-StopLoss*Point,Digits);

   for(int i=OrdersHistoryTotal(); i>=0; i--)
      if(OrderSelect(i-1, SELECT_BY_POS,MODE_HISTORY))
         if(OrderSymbol()==Symbol())
            if(OrderMagicNumber()==Magic)
               if(CountTrades()<1)
                 {
                  if(IsNewCandle())
                    {
                     int  r= OrderSend(Symbol(),OP_BUY,Lot(),Ask,Slip,slb,0,CommentBuy,Magic,0,Blue);
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

   string cookie=NULL,headers;
   char post[],result[];
   string TXT="";
   int res;
//--- to work with the server, you must add the URL "https://www.google.com/finance"
//--- the list of allowed URL (Main menu-> Tools-> Settings tab "Advisors"):
   string google_url="https://ec.forexprostools.com/?columns=exc_currency,exc_importance&importance=1,2,3&calType=week&timeZone=15&lang=1";
//---
   ResetLastError();
//--- download html-pages
   int timeout=5000; //--- timeout less than 1,000 (1 sec.) is insufficient at a low speed of the Internet
   res=WebRequest("GET",google_url,cookie,NULL,timeout,post,0,result,headers);
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
      int filehandle=FileOpen("news-log.html",FILE_WRITE|FILE_BIN);
      //--- проверка ошибки
      if(filehandle!=INVALID_HANDLE)
        {
         //---save the contents of the array result [] in file
         FileWriteArray(filehandle,result,0,ArraySize(result));
         //--- close file
         FileClose(filehandle);

         int filehandle2=FileOpen("news-log.html",FILE_READ|FILE_BIN);
         TXT=FileReadString(filehandle2,ArraySize(result));
         FileClose(filehandle2);
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
   string time=StringConcatenate(StringSubstr(s,0,4),".",StringSubstr(s,5,2),".",StringSubstr(s,8,2)," ",StringSubstr(s,11,2),":",StringSubstr(s,14,4));
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
   for(int n=ObjectsTotal()-1; n>=0; n--)
     {
      string Obj_Name=ObjectName(n);
      if(StringFind(Obj_Name,name,0)!=-1)
        {
         ObjectDelete(Obj_Name);
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
      WindowRedraw();
      //---Draw a line on the chart news--------------------------------------------
      if(DrawNewsLines)
        {
         for(int i=0; i<NomNews; i++)
           {
            string Name=StringSubstr("NS_"+TimeToStr(TimeNewsFunck(i),TIME_MINUTES)+"_"+NewsArr[1][i]+"_"+NewsArr[3][i],0,63);
            if(NewsArr[3][i]!="")
               if(ObjectFind(Name)==0)
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
               ObjectCreate(0,Name,OBJ_VLINE,0,TimeNewsFunck(i),0);
               ObjectSet(Name,OBJPROP_COLOR,clrf);
               ObjectSet(Name,OBJPROP_STYLE,LineStyle);
               ObjectSetInteger(0,Name,OBJPROP_WIDTH,LineWidth);
               ObjectSetInteger(0,Name,OBJPROP_BACK,true);
              }
           }
        }
      //---------------event Processing------------------------------------
      int ii;
      CheckNews=false;
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
   datetime NowTimeD1=Time[0];
   datetime LastSunday=NowTimeD1-TimeDayOfWeek(NowTimeD1)*86399;
   int DayFile=TimeDay(LastSunday);
   if(DayFile<10)
      DF="0"+(string)DayFile;
   else
      DF=(string)DayFile;
   int MonthFile=TimeMonth(LastSunday);
   if(MonthFile<10)
      MF="0"+(string)MonthFile;
   else
      MF=(string)MonthFile;
   int YearFile=TimeYear(LastSunday);
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
         TimeNews[startStr]=StrToTime((string)YearFile+"."+month+"."+StringSubstr(data,8,2)+" "+time)+ChasPoyasServera*3600;
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
      if(Time[0]-LastUpd>=Upd)
        {
         Print("News DailyFX Loading...");
         UpdateDFX();
         LastUpd=Time[0];
        }
      WindowRedraw();
      //---Draw a line on the chart news--------------------------------------------
      if(DrawNewsLines)
        {
         for(int i=0; i<NomNews; i++)
           {
            string Lname=StringSubstr("NS_"+TimeToStr(TimeNews[i],TIME_MINUTES)+"_"+News[i],0,63);
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
               ObjectSet(Lname,OBJPROP_COLOR,clrf);
               ObjectSet(Lname,OBJPROP_STYLE,LineStyle);
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
