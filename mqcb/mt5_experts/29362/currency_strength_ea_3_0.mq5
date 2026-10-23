//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2022, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2022"
#property version     "3.0"
#property strict
#include <Trade\PositionInfo.mqh> CPositionInfo     m_position;
#include <Trade\Trade.mqh> CTrade trade;

enum timer
  {
   Server,  //Server Time
   GMT,     //GMT Time
   Local    //Local Time
  };
enum StepMode
  {
   inATR,   //In ATR
   inPips   //In Pips
  };
enum PType
  {
   inPercent,  //in Percent
   inCurrency //in Money
  };
input    const string Timer="//---------------- Time Settings ----------------//";
input    timer       TimeMode        = Server;        //Time Mode
input    string      StartTime       = "10:00";       // Opening Time
input    string      EndTime         = "16:00";       // End Time

input const string CStrength="//---------------- Currency Strength Settings ----------------//";
input    ENUM_TIMEFRAMES         tmf                 = PERIOD_H4; //Strength Period Calculation
input    int                     NumberOfCandles     = 55;        //Number of Candle to Calculate
input    bool                    ApplySmoothing      = true;      //Apply Smoothing
input    bool                    TriangularWeighting = true;      //Triangular Weighting
input    int                     HistoricalShift     = 0;         //Shift
input    double                  UpperLimit          = 7.2;   //Upper Limit Value
input    double                  LowerLimit          = 3.3;   //Lower Limit Value

input const string Indi="//---------------- Indicator Settings ----------------//";
input    ENUM_TIMEFRAMES         ATRTF               = PERIOD_CURRENT;    // ATR Timeframe
input    int                     ATRPeriod            = 14;    // ATR Period
input    StepMode                SLTP                 = inATR; //SLTP Type
input    double                  Stoploss            = 0.0;    // Stoploss
input    double                  Takeprofit          = 1.0;    //Takeprofit
input    int                     TrailingStop        = 30;    // Trailing Stop (in Points)
input    int                     TrailingStep        = 5;    // Trailing Step (in Points)

input const string Martingale="//---------------- Martingale Settings ----------------//";
input bool EnableAveraging = true;  //Enable Martingale
input double   Multiplier  = 1.3;   // Lot Multiplier
input StepMode PipStepMode = inATR; // PipStep Type
input double PipStep       = 0.8;   // Pip Step
input double PSM           = 2;     // Pip Step Multiplier
input int    StartPSMAfter = 2;     // Start PSM After Order Number:
input int    TPPlus        = 20;    // TP Average in Pips

input const string MM="//---------------- Money Management Settings ----------------//";
input bool Autolot = true;   //Enable AutoLot
input double Lot = 0.01;     //Constant Lot
input double RiskPercent = 0.1;     //Risk in Percent
input bool    UseTargetPercent   = true;  //Use Daily Target Percent
input PType   ProfitType  = inPercent; //Profit Close Type
input double  DailyProfit = 0.05;       //Daily Target Profit Percentage

input const string Other ="//---------------- Other Settings ----------------//";
input    int                     iMagicNumber        = 227;   // Magic Number
input    int                     iSlippage           = 3;     // Slippage
input    string                  Commentary          = "Currency Strength EA";  // Order Comment
input    string                  prefix              =""; //If have Prefix, else leave Blank
input    string                  postfix             =""; //If have Postfix, else leave Blank
input    int                     maxTradedSymbols    = 2; //Max Simultaneous Traded Symbols



string CurrencyPairs                    = "GU,UF,EU,UJ,UC,NU,AU,AN,AC,AF,AJ,CJ,FJ,EG,EA,EF,EJ,EN,EC,GF,GA,GC,GJ,GN,NJ";
double ccy_strength[8];
int    ccy_count[8], ccCP;
string ccy, CP[40],CurrencyPairs0;
string Currency[]= {"USD","EUR","GBP","CHF","CAD","AUD","JPY","NZD"};
double USD[],EUR[],GBP[],CHF[],CAD[],AUD[],JPY[],NZD[];
double Td[][8];
long chartID = 0;
#define  HR2400 (PERIOD_D1 * 60) // 86400 = 24 * 3600 = 1440 * 60
string EAName = "Currency Strength EA ";
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
int OnInit()
  {
   trade.LogLevel(LOG_LEVEL_ERRORS);
   trade.SetExpertMagicNumber(iMagicNumber);
   trade.SetDeviationInPoints(iSlippage);
   trade.SetMarginMode();
   trade.SetTypeFilling(ORDER_FILLING_FOK);

   CurrencyPairs0  = StringUpper(CurrencyPairs);
   if(CurrencyPairs0=="")
     {
      CurrencyPairs0=Symbol();
     }
   if(StringSubstr(CurrencyPairs0,StringLen(CurrencyPairs0)-1,1) != ",")
      CurrencyPairs0 = CurrencyPairs0 + ",";
   ccCP = StringFindCount(CurrencyPairs0,",");
   for(int i=0; i<40; i++)
      CP[i] = "";
   int comma1 = -1;
   for(int i=0; i<40; i++)
     {
      int comma2 = StringFind(CurrencyPairs0,",",comma1+1);
      string temp  = StringSubstr(CurrencyPairs0,comma1+1,comma2-comma1-1);
      CP[i] = ExpandCcy(temp);
      if(comma2 >= StringLen(CurrencyPairs0)-1)
         break;
      comma1 = comma2;
     }


   ArrayResize(USD,2);
   ArrayResize(EUR,2);
   ArrayResize(GBP,2);
   ArrayResize(CHF,2);
   ArrayResize(CAD,2);
   ArrayResize(AUD,2);
   ArrayResize(JPY,2);
   ArrayResize(NZD,2);

   ArrayInitialize(USD,0.0);
   ArrayInitialize(EUR,0.0);
   ArrayInitialize(GBP,0.0);
   ArrayInitialize(CHF,0.0);
   ArrayInitialize(CAD,0.0);
   ArrayInitialize(AUD,0.0);
   ArrayInitialize(JPY,0.0);
   ArrayInitialize(NZD,0.0);

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   string lookFor       = EAName;
   ObjectsDeleteAll(chartID,lookFor,-1,-1);

   return;
  }

//+------------------------------------------------------------------+
void OnTick(void)
  {
   createBackground(EAName+"Background");
   createObject(EAName+"USD","USD: "+DoubleToString(USD[0],1),20,40,16,clrRed);
   createObject(EAName+"EUR","EUR: "+DoubleToString(EUR[0],1),20,70,16,clrYellow);
   createObject(EAName+"AUD","AUD: "+DoubleToString(AUD[0],1),20,100,16,clrGreen);
   createObject(EAName+"GBP","GBP: "+DoubleToString(GBP[0],1),20,130,16,clrBlueViolet);
   createObject(EAName+"CHF","CHF: "+DoubleToString(CHF[0],1),20,160,16,clrGoldenrod);
   createObject(EAName+"JPY","JPY: "+DoubleToString(JPY[0],1),20,190,16,clrViolet);
   createObject(EAName+"NZD","NZD: "+DoubleToString(NZD[0],1),20,220,16,clrOrange);
   createObject(EAName+"CAD","CAD: "+DoubleToString(CAD[0],1),20,250,16,clrWhiteSmoke);

   Strength();

//Target Profit
   bool closeProfit = false, closeLoss = false;
   double Target = ProfitToday()+FloatingProfit();
   double Percent = (100*Target)/(AccountInfoDouble(ACCOUNT_BALANCE));
   double maxDD = (100*FloatingProfit())/(AccountInfoDouble(ACCOUNT_BALANCE));

   int countSym = 0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(PositionGetTicket(i))
        {
         if(PositionGetInteger(POSITION_MAGIC)==iMagicNumber)
           {
            countSym++;
            if(IsMarketOpen(PositionGetSymbol(i),false))
              {
               Trailing(PositionGetSymbol(i));
               if(EnableAveraging)
                  Martin(PositionGetSymbol(i));
              }
           }
        }
     }

   switch(ProfitType)
     {
      case inPercent:
        {
         if(Percent >= DailyProfit)
            closeProfit = true;
         break;
        }
      case inCurrency:
        {
         if(Target >= DailyProfit)
            closeProfit = true;
         break;
        }
     }

   if(UseTargetPercent)
     {
      if(closeProfit)
        {
         closeAllPositions();
         if(!countSym)
           {
            closeProfit = false;
           }
        }
     }
   else
      closeProfit = false;


   Signal();


   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsMarketOpen(const string symb, const bool debug = false)
  {
   datetime from = NULL;
   datetime to = NULL;
   datetime serverTime = TimeTradeServer();

// Get the day of the week
   MqlDateTime dt;
   TimeToStruct(serverTime,dt);
   const ENUM_DAY_OF_WEEK day_of_week = (ENUM_DAY_OF_WEEK) dt.day_of_week;

// Get the time component of the current datetime
   const int time = (int) MathMod(serverTime,HR2400);

   if(debug)
      PrintFormat("%s(%s): Checking %s", __FUNCTION__, symb, EnumToString(day_of_week));

// Brokers split some symbols between multiple sessions.
// One broker splits forex between two sessions (Tues thru Thurs on different session).
// 2 sessions (0,1,2) should cover most cases.
   int session=2;
   while(session > -1)
     {
      if(SymbolInfoSessionTrade(symb,day_of_week,session,from,to))
        {
         if(debug)
            PrintFormat("%s(%s): Checking %d>=%d && %d<=%d",
                        __FUNCTION__,
                        symb,
                        time,
                        from,
                        time,
                        to);
         if(time >=from && time <= to)
           {
            if(debug)
               PrintFormat("%s Market is open", __FUNCTION__);
            return true;
           }
        }
      session--;
     }
   if(debug)
      PrintFormat("%s Market not open", __FUNCTION__);
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double FloatingProfit()
  {
   double   tFloating = 0.0;
   int      tOrder  = PositionsTotal();
   for(int i=tOrder-1; i>=0; i--)
     {
      if(PositionGetTicket(i)) // selects the position by index for further access to its properties
        {
         if(PositionGetInteger(POSITION_MAGIC)==iMagicNumber)
           {
            tFloating   += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP) + AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED);
           }
        }
     }

   return(tFloating);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ProfitToday()
  {
   HistorySelect(0,TimeCurrent());
   int      tOrderHis   = HistoryDealsTotal();
   string   strToday    = TimeToString(TimeCurrent(), TIME_DATE);
   ulong ticket = 0;
   double   tFloating = 0.0;

   for(int i=tOrderHis-1; i>=0; i--)
     {
      if((ticket=HistoryDealGetTicket(i))>0)
        {
         datetime time  =(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
         string symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         ulong magic = HistoryDealGetInteger(ticket,DEAL_MAGIC);
         double profit = HistoryDealGetDouble(ticket,DEAL_PROFIT);
         double swap = HistoryDealGetDouble(ticket,DEAL_SWAP);
         double commission = HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         if(magic == iMagicNumber && StringFind(TimeToString(time, TIME_DATE), strToday, 0) == 0)
           {
            tFloating   += profit + swap + commission;
           }
        }
     }
   return(tFloating);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void closeAllPositions()
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(PositionGetTicket(i)) // selects the position by index for further access to its properties
         if(PositionGetInteger(POSITION_MAGIC)==iMagicNumber)
           {
            trade.PositionClose(PositionGetTicket(i),-1);
            Print("Target Reached");
           }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double History(string symb)
  {
   HistorySelect(0,TimeCurrent());
   int      tOrderHis   = HistoryDealsTotal();
   string   strToday    = TimeToString(TimeCurrent(), TIME_DATE);
   ulong ticket = 0;

   for(int i=tOrderHis-1; i>=0; i--)
     {
      if((ticket=HistoryDealGetTicket(i))>0)
        {
         datetime time  =(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
         string symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         ulong magic = HistoryDealGetInteger(ticket,DEAL_MAGIC);
         if(symbol == symb)
           {
            if(magic == iMagicNumber && StringFind(TimeToString(time, TIME_DATE), strToday, 0) == 0)
              {
               return(true);
              }
           }
        }
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Signal()
  {
   if((USD[0] > (UpperLimit) && JPY[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"USDJPY"+postfix);
     }
   if((USD[0] < (LowerLimit) && JPY[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"USDJPY"+postfix);
     }
   if((USD[0] > (UpperLimit) && CAD[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"USDCAD"+postfix);
     }
   if((USD[0] < (LowerLimit) && CAD[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"USDCAD"+postfix);
     }
   if((AUD[0] > (UpperLimit) && USD[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"AUDUSD"+postfix);
     }
   if((AUD[0] < (LowerLimit) && USD[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"AUDUSD"+postfix);
     }
   if((USD[0] > (UpperLimit) && CHF[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"USDCHF"+postfix);
     }
   if((USD[0] < (LowerLimit) && CHF[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"USDCHF"+postfix);
     }
   if((GBP[0] > (UpperLimit) && USD[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"GBPUSD"+postfix);
     }
   if((GBP[0] < (LowerLimit) && USD[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"GBPUSD"+postfix);
     }
   if((EUR[0] > (UpperLimit) && USD[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"EURUSD"+postfix);
     }
   if((EUR[0] < (LowerLimit) && USD[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"EURUSD"+postfix);
     }
   if((NZD[0] > (UpperLimit) && USD[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"NZDUSD"+postfix);
     }
   if((NZD[0] < (LowerLimit) && USD[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"NZDUSD"+postfix);
     }
   if((EUR[0] > (UpperLimit) && JPY[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"EURJPY"+postfix);
     }
   if((EUR[0] < (LowerLimit) && JPY[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"EURJPY"+postfix);
     }
   if((EUR[0] > (UpperLimit) && CAD[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"EURCAD"+postfix);
     }
   if((EUR[0] < (LowerLimit) && CAD[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"EURCAD"+postfix);
     }
   if((EUR[0] > (UpperLimit) && GBP[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"EURGBP"+postfix);
     }
   if((EUR[0] < (LowerLimit) && GBP[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"EURGBP"+postfix);
     }
   if((EUR[0] > (UpperLimit) && CHF[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"EURCHF"+postfix);
     }
   if((EUR[0] < (LowerLimit) && CHF[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"EURCHF"+postfix);
     }
   if((EUR[0] > (UpperLimit) && AUD[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"EURAUD"+postfix);
     }
   if((EUR[0] < (LowerLimit) && AUD[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"EURAUD"+postfix);
     }
   if((EUR[0] > (UpperLimit) && NZD[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"EURNZD"+postfix);
     }
   if((EUR[0] < (LowerLimit) && NZD[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"EURNZD"+postfix);
     }
   if((AUD[0] > (UpperLimit) && NZD[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"AUDNZD"+postfix);
     }
   if((AUD[0] < (LowerLimit) && NZD[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"AUDNZD"+postfix);
     }
   if((AUD[0] > (UpperLimit) && CAD[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"AUDCAD"+postfix);
     }
   if((AUD[0] < (LowerLimit) && CAD[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"AUDCAD"+postfix);
     }
   if((AUD[0] > (UpperLimit) && CHF[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"AUDCHF"+postfix);
     }
   if((AUD[0] < (LowerLimit) && CHF[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"AUDCHF"+postfix);
     }
   if((AUD[0] > (UpperLimit) && JPY[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"AUDJPY"+postfix);
     }
   if((AUD[0] < (LowerLimit) && JPY[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"AUDJPY"+postfix);
     }
   if((CHF[0] > (UpperLimit) && JPY[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"CHFJPY"+postfix);
     }
   if((CHF[0] < (LowerLimit) && JPY[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"CHFJPY"+postfix);
     }
   if((GBP[0] > (UpperLimit) && CHF[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"GBPCHF"+postfix);
     }
   if((GBP[0] < (LowerLimit) && CHF[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"GBPCHF"+postfix);
     }
   if((GBP[0] > (UpperLimit) && AUD[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"GBPAUD"+postfix);
     }
   if((GBP[0] < (LowerLimit) && AUD[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"GBPAUD"+postfix);
     }
   if((GBP[0] > (UpperLimit) && CAD[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"GBPCAD"+postfix);
     }
   if((GBP[0] < (LowerLimit) && CAD[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"GBPCAD"+postfix);
     }
   if((GBP[0] > (UpperLimit) && JPY[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"GBPJPY"+postfix);
     }
   if((GBP[0] < (LowerLimit) && JPY[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"GBPJPY"+postfix);
     }
   if((CAD[0] > (UpperLimit) && JPY[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"CADJPY"+postfix);
     }
   if((CAD[0] < (LowerLimit) && JPY[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"CADJPY"+postfix);
     }
   if((NZD[0] > (UpperLimit) && JPY[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"NZDJPY"+postfix);
     }
   if((NZD[0] < (LowerLimit) && JPY[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"NZDJPY"+postfix);
     }
   if((GBP[0] > (UpperLimit) && NZD[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"GBPNZD"+postfix);
     }
   if((GBP[0] < (LowerLimit) && NZD[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"GBPNZD"+postfix);
     }
   if((CAD[0] > (UpperLimit) && CHF[0] < (LowerLimit)))
     {
      Trade("Buy",prefix+"CADCHF"+postfix);
     }
   if((CAD[0] < (LowerLimit) && CHF[0] > (UpperLimit)))
     {
      Trade("Sell",prefix+"CADCHF"+postfix);
     }

   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trade(string sig, string symb)
  {
   if(!Refresh(symb))
      return;

   double ask = SymbolInfoDouble(symb,SYMBOL_ASK);
   double bid = SymbolInfoDouble(symb,SYMBOL_BID);
   double point = SymbolInfoDouble(symb, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symb,SYMBOL_DIGITS);

   double SLbuy = 0, TPbuy = 0, SLsell = 0, TPsell = 0;
   double atrPips = NormalizeDouble(ATR(symb,1),digits);

   if(SLTP == inATR)
     {
      if(Stoploss > 0)
        {
         SLbuy = NormalizeDouble(ask - Stoploss*atrPips,digits);
         SLsell = NormalizeDouble(bid + Stoploss*atrPips,digits);
        }
      if(Takeprofit > 0)
        {
         TPbuy = NormalizeDouble(ask + Takeprofit*atrPips,digits);
         TPsell = NormalizeDouble(bid - Takeprofit*atrPips,digits);
        }
     }
   else
      if(SLTP == inPips)
        {
         if(Stoploss > 0)
           {
            SLbuy = NormalizeDouble(ask - Stoploss*point,digits);      // Stop Loss specified
            SLsell = NormalizeDouble(bid + Stoploss*point,digits);      // Stop Loss specified
           }
         if(Takeprofit > 0)
           {
            TPbuy = NormalizeDouble(ask + Takeprofit*point,digits);    // Take Profit specified
            TPsell = NormalizeDouble(bid - Takeprofit*point,digits);    // Take Profit specified
           }
        }

   int countOpen = 0, countSym = 0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(PositionGetTicket(i)) // selects the position by index for further access to its properties
        {
         if(PositionGetInteger(POSITION_MAGIC)==iMagicNumber)
            countSym++;
         if(PositionGetString(POSITION_SYMBOL)==symb)
           {
            countOpen++;
           }
        }
     }

   if(Times())
      if(countSym < maxTradedSymbols)
         if(IsMarketOpen(symb,false))
            if(!History(symb))
               if(!countOpen)
                 {
                  if(sig == "Buy")
                    {
                     if(CheckMoneyForTrade(symb,LotAuto(symb),ORDER_TYPE_BUY) && CheckVolumeValue(symb,LotAuto(symb)))
                        trade.Buy(LotAuto(symb),symb,ask,SLbuy,TPbuy,Commentary);
                    }

                  else
                     if(sig == "Sell")
                       {
                        if(CheckMoneyForTrade(symb,LotAuto(symb),ORDER_TYPE_SELL) && CheckVolumeValue(symb,LotAuto(symb)))
                           trade.Sell(LotAuto(symb),symb,bid,SLsell,TPsell,Commentary);
                       }
                 }

   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createBackground(string name)
  {
   ObjectCreate(chartID, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(chartID, name, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(chartID, name, OBJPROP_YDISTANCE, 20);
   ObjectSetInteger(chartID, name, OBJPROP_XSIZE, 120);
   ObjectSetInteger(chartID, name, OBJPROP_YSIZE, 280);
   ObjectSetInteger(chartID, name, OBJPROP_BGCOLOR, clrBlack);
   ObjectSetInteger(chartID, name, OBJPROP_BORDER_COLOR, clrWhiteSmoke);
   ObjectSetInteger(chartID, name, OBJPROP_BORDER_TYPE, BORDER_RAISED);
   ObjectSetInteger(chartID, name, OBJPROP_WIDTH, 0);
   ObjectSetInteger(chartID, name, OBJPROP_BACK, false);
   ObjectSetInteger(chartID, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chartID, name, OBJPROP_HIDDEN, true);
   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createObject(string name,string text,int x,int y,int size, int clr)
  {
   ObjectCreate(chartID,name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(chartID,name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(chartID,name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chartID,name, OBJPROP_YDISTANCE, y);
   ObjectSetString(chartID,name,OBJPROP_TEXT, text);
   ObjectSetInteger(chartID,name,OBJPROP_FONTSIZE,size);
   ObjectSetInteger(chartID,name,OBJPROP_COLOR,clr);

   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Strength()
  {
   int t1,t2 = 0;
   ArrayResize(Td,8);
   ArrayInitialize(ccy_strength,0.0);
   ArrayInitialize(ccy_count,0);

   for(int i=0; i<40; i++)
     {
      int hi_bar, lo_bar;
      double curr_bid, candle_high, candle_low, bid_ratio;
      double CandleSum = NumberOfCandles*(NumberOfCandles+1)/2;
      curr_bid     = SymbolInfoDouble(CP[i],SYMBOL_BID);
      if(curr_bid == 0)
         curr_bid = iClose(CP[i],tmf,HistoricalShift);
      if(ApplySmoothing)
        {
         bid_ratio = 0;
         for(int k=1; k<=NumberOfCandles; k++)
           {
            hi_bar       = iHighest(CP[i],tmf,MODE_HIGH,k,HistoricalShift);
            lo_bar       = iLowest(CP[i],tmf,MODE_LOW,k,HistoricalShift);
            candle_high  = iHigh(CP[i],tmf,hi_bar);
            candle_low   = iLow(CP[i],tmf,lo_bar);
            if(TriangularWeighting)
               bid_ratio    += DivZero(curr_bid - candle_low, candle_high - candle_low) * (NumberOfCandles+1-k)/CandleSum;
            else
               bid_ratio    += DivZero(curr_bid - candle_low, candle_high - candle_low) / NumberOfCandles;
           }
        }
      else
        {
         hi_bar       = iHighest(CP[i],tmf,MODE_HIGH,NumberOfCandles,HistoricalShift);
         lo_bar       = iLowest(CP[i],tmf,MODE_LOW,NumberOfCandles,HistoricalShift);
         candle_high  = iHigh(CP[i],tmf,hi_bar);
         candle_low   = iLow(CP[i],tmf,lo_bar);
         bid_ratio    = DivZero(curr_bid - candle_low, candle_high - candle_low);
        }

      /*
            double day_high     = SymbolInfoDouble(CP[i],SYMBOL_BIDHIGH);
            double day_low      = SymbolInfoDouble(CP[i],SYMBOL_BIDLOW);
            double curr_bid     = SymbolInfoDouble(CP[i],SYMBOL_BID);
            double bid_ratio    = DivZero(curr_bid - day_low, day_high - day_low);
        */

      double ind_strength = 0;
      if(bid_ratio >= 0.97)
         ind_strength = 9;
      else
         if(bid_ratio >= 0.90)
            ind_strength = 8;
         else
            if(bid_ratio >= 0.75)
               ind_strength = 7;
            else
               if(bid_ratio >= 0.60)
                  ind_strength = 6;
               else
                  if(bid_ratio >= 0.50)
                     ind_strength = 5;
                  else
                     if(bid_ratio >= 0.40)
                        ind_strength = 4;
                     else
                        if(bid_ratio >= 0.25)
                           ind_strength = 3;
                        else
                           if(bid_ratio >= 0.10)
                              ind_strength = 2;
                           else
                              if(bid_ratio >= 0.03)
                                 ind_strength = 1;

      string temp = StringSubstr(CP[i],0,3);
      for(int j=0; j<=7; j++)
        {
         if(Currency[j] == temp)
           {
            ccy_strength[j] += ind_strength;
            ccy_count[j]    += 1;
            break;
           }
        }

      temp = StringSubstr(CP[i],3,3);
      for(int j=0; j<=7; j++)
        {
         if(Currency[j] == temp)
           {
            ccy_strength[j] += 9 - ind_strength;
            ccy_count[j]    += 1;
            break;
           }
        }
     }
   t1=0;
   while(t1<=7)
     {
      Td[t1][0]=DivZero(ccy_strength[t1],ccy_count[t1]);
      Td[t1][1]=t1;
      t1++;
     }
   USD[0]=Td[0][0];
   EUR[0]=Td[1][0];
   GBP[0]=Td[2][0];
   CHF[0]=Td[3][0];
   CAD[0]=Td[4][0];
   AUD[0]=Td[5][0];
   JPY[0]=Td[6][0];
   NZD[0]=Td[7][0];

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double DivZero(double n, double d)
//+------------------------------------------------------------------+
// Divides N by D, and returns 0 if the denominator (D) = 0
// Usage:   double x = DivZero(y,z)  sets x = y/z
  {
   if(d == 0)
      return(0);
   else
      return(n/d);
  }
//************************************************************************************************/
//*                                                                                              */
//************************************************************************************************/
bool CheckVolumeValue(string symbol, double volume)
  {
   double min_volume=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
      return(false);

   double max_volume=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
      return(false);

   double volume_step=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
      return(false);

   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb,double lots,ENUM_ORDER_TYPE type)
  {
//--- Getting the opening price
   MqlTick mqltick;
   SymbolInfoTick(symb,mqltick);
   double price=mqltick.ask;
   if(type==ORDER_TYPE_SELL)
      price=mqltick.bid;
//--- values of the required and free margin
   double margin,free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
//--- call of the checking function
   if(!OrderCalcMargin(type,symb,lots,price,margin))
     {
      //--- something went wrong, report and return false
      return(false);
     }
//--- if there are insufficient funds to perform the operation
   if(margin>free_margin)
     {
      //--- report the error and return false
      return(false);
     }
//--- checking successful
   return(true);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Times()
  {
   string now;
   switch(TimeMode)
     {
      case Server:
        {
         now = TimeToString(TimeCurrent(),TIME_MINUTES);
         break;
        }
      case GMT:
        {
         now = TimeToString(TimeGMT(),TIME_MINUTES);
         break;
        }
      case Local:
        {
         now = TimeToString(TimeLocal(),TIME_MINUTES);
         break;
        }
     }

   if(StartTime < EndTime)
      if((now < StartTime)||(now >= EndTime))
         return (false);

   if(StartTime > EndTime)
      if((now < EndTime)||(now >= StartTime))
         return (false);


   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trailing(string symb)
  {
   double ask = SymbolInfoDouble(symb,SYMBOL_ASK);
   double bid = SymbolInfoDouble(symb,SYMBOL_BID);
   double points = SymbolInfoDouble(symb,SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symb,SYMBOL_DIGITS);

   int b=0,s=0;
   ulong TicketB=0,TicketS=0;
   double TPb = 0,SLb = 0, OPb = 0;
   double TPs = 0,SLs = 0, OPs = 0;
   double StopLevel =((int)SymbolInfoInteger(symb,SYMBOL_TRADE_STOPS_LEVEL))*points;
   double TStop = TrailingStop * points + StopLevel;
   double TStep = TrailingStep * points + StopLevel;


   for(int i=PositionsTotal()-1; i>=0; i--)
      if(PositionGetTicket(i)) // selects the position by index for further access to its properties
         if(PositionGetString(POSITION_SYMBOL)==symb)
            if(PositionGetInteger(POSITION_MAGIC)==iMagicNumber)
              {
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                 {
                  b++;
                  TicketB=PositionGetInteger(POSITION_TICKET);
                  TPb = PositionGetDouble(POSITION_TP);
                  SLb = PositionGetDouble(POSITION_SL);
                  OPb = PositionGetDouble(POSITION_PRICE_OPEN);
                 }
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                 {
                  s++;
                  TicketS=PositionGetInteger(POSITION_TICKET);
                  TPs =  PositionGetDouble(POSITION_TP);
                  SLs = PositionGetDouble(POSITION_SL);
                  OPs = PositionGetDouble(POSITION_PRICE_OPEN);
                 }
              }
//---
   if(b == 1)
     {
      if(bid - OPb > TStop + TStep && (SLb < OPb || SLb == 0))
        {
         if(trade.PositionModify(TicketB,NormalizeDouble(bid - TStop,digits), TPb))
            Print(symb+" Trailing 1 Success");
         else
            Print(symb+" Trailing 1 Failed "+IntegerToString(GetLastError()));
        }
      if(SLb!=0 && SLb > OPb  && bid - SLb > TStop + TStep)
        {
         if(trade.PositionModify(TicketB,NormalizeDouble(bid - TStop,digits), TPb))
            Print(symb+" Trailing 2 Success");
         else
            Print(symb+" Trailing 2 Failed "+IntegerToString(GetLastError()));
        }
     }

   if(s == 1)
     {
      if(OPs - ask > TStop + TStep && (SLs > OPs || SLs == 0))
        {
         if(trade.PositionModify(TicketS,NormalizeDouble(ask + TStop,digits), TPs))
            Print(symb+" Trailing 1 Success");
         else
            Print(symb+" Trailing 1 Failed "+IntegerToString(GetLastError()));
        }
      if(SLs!=0 && SLs<OPs && SLs - ask > TStop + TStep)
        {
         if(trade.PositionModify(TicketS,NormalizeDouble(ask + TStop,digits), TPs))
            Print(symb+" Trailing 2 Success");
         else
            Print(symb+" Trailing 2 Failed "+IntegerToString(GetLastError()));
        }
     }

   ResetLastError();
   return;
  }
//+------------------------------------------------------------------+
bool Refresh(string symbol)
  {
   if(SymbolInfoDouble(symbol,SYMBOL_ASK) == 0 || SymbolInfoDouble(symbol,SYMBOL_BID) == 0)
      return(false);

//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
double ATR(string symb, int index)
  {
   double arr[];
   ArraySetAsSeries(arr, true);
   int handle = iATR(symb,ATRTF,ATRPeriod);
   int copied = CopyBuffer(handle, 0, index, 7, arr);

   return (arr[index]);
  }
//+------------------------------------------------------------------+
void Martin(string symb)
  {
   double ask = SymbolInfoDouble(symb,SYMBOL_ASK);
   double bid = SymbolInfoDouble(symb,SYMBOL_BID);
   double point = SymbolInfoDouble(symb, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(symb,SYMBOL_DIGITS);

   if(digits == 3 || digits == 5)
      point = 10*point;
   else
      point = point;

   double
   BuyPriceMax=0,BuyPriceMin=0,BuyPriceMaxLot=0,BuyPriceMinLot=0,
   SelPriceMin=0,SelPriceMax=0,SelPriceMinLot=0,SelPriceMaxLot=0;

   ulong
   BuyPriceMaxTic=0,BuyPriceMinTic=0,SelPriceMaxTic=0,SelPriceMinTic=0;

   ulong tkb= 0,tks=0;

   double
   opPrice=0,lt=0,tpb=0,tps=0, slb=0,sls=0;

   int OpenPos = 0, b = 0, s = 0;
   for(int k=PositionsTotal()-1; k>=0; k--)
     {
      if(PositionGetTicket(k))
        {
         if(PositionGetString(POSITION_SYMBOL)==symb)
           {
            if(PositionGetInteger(POSITION_MAGIC)==iMagicNumber)
              {
               OpenPos++;
               opPrice=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),digits);
               lt=NormalizeDouble(PositionGetDouble(POSITION_VOLUME),2);
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                 {
                  b++;
                  tpb = NormalizeDouble(PositionGetDouble(POSITION_TP),digits);
                  slb = NormalizeDouble(PositionGetDouble(POSITION_SL),digits);
                  tkb = PositionGetInteger(POSITION_TICKET);
                  if(opPrice>BuyPriceMax || BuyPriceMax==0)
                    {
                     BuyPriceMax    = opPrice;
                     BuyPriceMaxLot = lt;
                     BuyPriceMaxTic = tkb;
                    }
                  if(opPrice<BuyPriceMin || BuyPriceMin==0)
                    {
                     BuyPriceMin    = opPrice;
                     BuyPriceMinLot = lt;
                     BuyPriceMinTic = tkb;
                    }
                 }
               // ===
               else
                  if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                    {
                     s++;
                     tps = NormalizeDouble(PositionGetDouble(POSITION_TP),digits);
                     sls = NormalizeDouble(PositionGetDouble(POSITION_SL),digits);
                     tks = PositionGetInteger(POSITION_TICKET);
                     if(opPrice>SelPriceMax || SelPriceMax==0)
                       {
                        SelPriceMax    = opPrice;
                        SelPriceMaxLot = lt;
                        SelPriceMaxTic = tks;
                       }
                     if(opPrice<SelPriceMin || SelPriceMin==0)
                       {
                        SelPriceMin    = opPrice;
                        SelPriceMinLot = lt;
                        SelPriceMinTic = tks;
                       }
                    }
              }
           }
        }
     }

   double nn=0,bb=0;
   double factb=0.0;
   for(int ui=PositionsTotal()-1; ui>=0; ui--)
     {
      if(PositionGetTicket(ui))
        {
         if(PositionGetString(POSITION_SYMBOL)==symb)
           {
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY && PositionGetInteger(POSITION_MAGIC)==iMagicNumber)
              {
               double op=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),digits);
               double llot=NormalizeDouble(PositionGetDouble(POSITION_VOLUME),2);
               double itog=op*llot;
               bb=bb+itog;
               nn=nn+llot;
               factb=bb/nn;
              }
           }
        }
     }
   double nnn=0,bbb=0;
   double facts=0.0;
   for(int usi=PositionsTotal()-1; usi>=0; usi--)
     {
      if(PositionGetTicket(usi))
        {
         if(PositionGetString(POSITION_SYMBOL)==symb)
           {
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && PositionGetInteger(POSITION_MAGIC)==iMagicNumber)
              {
               double ops=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),digits);
               double llots=NormalizeDouble(PositionGetDouble(POSITION_VOLUME),2);
               double itogs=ops*llots;
               bbb=bbb+itogs;
               nnn=nnn+llots;
               facts=bbb/nnn;
              }
           }
        }
     }

   double PStep = 0;
   double atrPips = NormalizeDouble(ATR(symb,1),digits);
   if(PipStepMode == inATR)
     {
      PStep = PipStep * atrPips;
     }
   else
      if(PipStepMode == inPips)
        {
         PStep = PipStep * point;
        }

   if(OpenPos >= StartPSMAfter)
      PStep = PStep * PSM * (OpenPos - StartPSMAfter + 1);
   else
      PStep = PStep;


   double nextLot = NormalizeDouble(LastOrderLot(symb)*Multiplier,2);


   if(b > 0)
     {
      if(BuyPriceMin - ask >= PStep)
        {
         if(CheckMoneyForTrade(symb,nextLot,ORDER_TYPE_BUY) && CheckVolumeValue(symb,nextLot))
           {
            if(trade.Buy(nextLot,symb,ask,0,0,Commentary))
               Print(symb+" Averaging Success");
            else
               Print(symb+" Averaging Failed "+IntegerToString(GetLastError()));
           }
        }
     }
   if(s > 0)
     {
      if(bid - SelPriceMax >= PStep)
        {
         if(CheckMoneyForTrade(symb,nextLot,ORDER_TYPE_SELL) && CheckVolumeValue(symb,nextLot))
           {
            if(trade.Sell(nextLot,symb,bid,0,0,Commentary))
               Print(symb+" Averaging Success");
            else
               Print(symb+" Averaging Failed "+IntegerToString(GetLastError()));
           }
        }
     }

   double CORR = 0;
   CORR = NormalizeDouble(TPPlus * point,digits);

   for(int uui=PositionsTotal()-1; uui>=0; uui--)
     {
      if(PositionGetTicket(uui))
        {
         if(PositionGetString(POSITION_SYMBOL)==symb)
           {
            if(b>=2 && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY && PositionGetInteger(POSITION_MAGIC)==iMagicNumber)
              {
               if(!compareDoubles(symb,PositionGetDouble(POSITION_TP),factb+CORR))
                 {
                  if(trade.PositionModify(PositionGetInteger(POSITION_TICKET),slb,factb+CORR))
                     Print(symb+" Modify TP Average Success");
                  else
                     Print(symb+" Modify TP Average Failed "+IntegerToString(GetLastError()));
                 }
              }
            if(s>=2 && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && PositionGetInteger(POSITION_MAGIC)==iMagicNumber)
              {
               if(!compareDoubles(symb,PositionGetDouble(POSITION_TP),facts-CORR))
                 {
                  if(trade.PositionModify(PositionGetInteger(POSITION_TICKET),sls,facts-CORR))
                     Print(symb+" Modify TP Average Success");
                  else
                     Print(symb+" Modify TP Average Failed "+IntegerToString(GetLastError()));
                 }
              }
           }
        }
     }
   return;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LastOrderLot(string symb)
  {
   long lastOrderTime  = 0;
   double lot = 9999;
   double  firstlot = 0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(PositionGetTicket(i)) // selects the position by index for further access to its properties
        {
         if(PositionGetString(POSITION_SYMBOL)==symb)
            if(PositionGetInteger(POSITION_MAGIC)==iMagicNumber)
               if(PositionGetInteger(POSITION_TIME) > lastOrderTime)
                 {
                  lastOrderTime = PositionGetInteger(POSITION_TIME);
                  firstlot = PositionGetDouble(POSITION_VOLUME);
                 }
               else
                  continue;
        }
      else
         continue;
     }

   return (firstlot);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool compareDoubles(string symb, double val1, double val2)
  {
   int digits = (int)SymbolInfoInteger(symb,SYMBOL_DIGITS);
   if(NormalizeDouble(val1 - val2,digits-1)==0)
      return (true);

   return(false);
  }
//+------------------------------------------------------------------+
double LotAuto(string symb)
  {
   double lotvalue = 0;
   double Margin = AccountInfoDouble(ACCOUNT_BALANCE);

   if(Autolot)
      lotvalue = MathMin(MathMax((MathRound((Margin*RiskPercent/100/1000) / SymbolInfoDouble(symb,SYMBOL_VOLUME_STEP))*SymbolInfoDouble(symb,SYMBOL_VOLUME_STEP)),SymbolInfoDouble(symb,SYMBOL_VOLUME_MIN)),SymbolInfoDouble(symb,SYMBOL_VOLUME_MAX));
   else
      lotvalue = NormalizeDouble(Lot,2);

   return (lotvalue);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int StringFindCount(string str, string str2)
//+------------------------------------------------------------------+
// Returns the number of occurrences of STR2 in STR
// Usage:   int x = StringFindCount("ABCDEFGHIJKABACABB","AB")   returns x = 3
  {
   int c = 0;
   for(int i=0; i<StringLen(str); i++)
      if(StringSubstr(str,i,StringLen(str2)) == str2)
         c++;
   return(c);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringUpper(string str)
//+------------------------------------------------------------------+
// Converts any lowercase characters in a string to uppercase
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "THE QUICK BROWN FOX"
  {
   string outstr = "";
   string lower  = "abcdefghijklmnopqrstuvwxyz";
   string upper  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
   for(int i=0; i<StringLen(str); i++)
     {
      int t1 = StringFind(lower,StringSubstr(str,i,1),0);
      if(t1 >=0)
         outstr = outstr + StringSubstr(upper,t1,1);
      else
         outstr = outstr + StringSubstr(str,i,1);
     }
   return(outstr);
  }

//+------------------------------------------------------------------+
string StringLower(string str)
//+------------------------------------------------------------------+
// Converts any uppercase characters in a string to lowercase
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "the quick brown fox"
  {
   string outstr = "";
   string lower  = "abcdefghijklmnopqrstuvwxyz";
   string upper  = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
   for(int i=0; i<StringLen(str); i++)
     {
      int t1 = StringFind(upper,StringSubstr(str,i,1),0);
      if(t1 >=0)
         outstr = outstr + StringSubstr(lower,t1,1);
      else
         outstr = outstr + StringSubstr(str,i,1);
     }
   return(outstr);
  }

//+------------------------------------------------------------------+
string StringTrim(string str)
//+------------------------------------------------------------------+
// Removes all spaces (leading, traing embedded) from a string
// Usage:    string x=StringUpper("The Quick Brown Fox")  returns x = "TheQuickBrownFox"
  {
   string outstr = "";
   for(int i=0; i<StringLen(str); i++)
     {
      if(StringSubstr(str,i,1) != " ")
         outstr = outstr + StringSubstr(str,i,1);
     }
   return(outstr);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ExpandCcy(string str)
//+------------------------------------------------------------------+
  {
   str = StringTrim(StringUpper(str));
   if(StringLen(str) < 1 || StringLen(str) > 2)
      return(str);
   string str2 = "";
   for(int i=0; i<StringLen(str); i++)
     {
      string s1 = StringSubstr(str,i,1);
      if(s1 == "A")
         str2 = str2 + "AUD";
      else
         if(s1 == "C")
            str2 = str2 + "CAD";
         else
            if(s1 == "E")
               str2 = str2 + "EUR";
            else
               if(s1 == "F")
                  str2 = str2 + "CHF";
               else
                  if(s1 == "G")
                     str2 = str2 + "GBP";
                  else
                     if(s1 == "J")
                        str2 = str2 + "JPY";
                     else
                        if(s1 == "N")
                           str2 = str2 + "NZD";
                        else
                           if(s1 == "U")
                              str2 = str2 + "USD";
                           else
                              if(s1 == "H")
                                 str2 = str2 + "HKD";
                              else
                                 if(s1 == "S")
                                    str2 = str2 + "SGD";
                                 else
                                    if(s1 == "Z")
                                       str2 = str2 + "ZAR";
     }
   return(str2);
  }
//+------------------------------------------------------------------+
