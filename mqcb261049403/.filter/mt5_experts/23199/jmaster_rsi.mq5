//+------------------------------------------------------------------+
//|                                                  jMaster RSI.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
COrderInfo     m_order;                      // pending orders object
CMoneyFixedMargin *m_money;
//+------------------------------------------------------------------+
//| Enum Lor or Risk                                                 |
//+------------------------------------------------------------------+
enum ENUM_LOT_OR_RISK
  {
   lot=0,   // Constant lot
   risk=1,  // Risk in percent for a deal
  };
//--- input parameters
input double   InpMaximumRisk          = 0.02;     // Maximum Risk in percentage
input double   InpDecreaseFactor       = 3;        // Descrease factor
input ushort   InpHistoryDays          = 60;       // History days
input int      InpDF_Engage            = 1;        // Number of consecutive losses before Decrease Factor is engaged
input bool     InpUseMoneyManagement   = true;     //
input ENUM_LOT_OR_RISK IntLotOrRisk    = lot;      // Money management: Lot OR Risk
input double   InpVolumeLorOrRisk      = 1.0;      // The value for "Money management"                      
input ENUM_TIMEFRAMES InpLongTimeFrame=PERIOD_M15; // RSI Custom Smoothing Long: timeframe
input int InpLong_ma_period            = 10;       // RSI Custom Smoothing Long: averaging period 
input ENUM_TIMEFRAMES InpShortTimeFrame=PERIOD_M5; // RSI Custom Smoothing Short: timeframe
input int InpShort_ma_period           = 4;        // RSI Custom Smoothing Short: averaging period 
input int InpLongParBuy= 25;               // Trading logic: Will Buy if RSI (Long Time Period) is above the InpLongParBuy parameter and                  
input int InpShortParBuy= 25;              //                if the RSI (Short Time Period) is below the InpShortParBuy parameter

input int InpLongParSell= 75;              //                Will Sell if RSI (Long Time Period) is bleow the InpLongParSell parameter and                  
input int InpShortParSell= 75;             //                if the RSI (Short Time Period) is above the InpShortParSell parameter

input int InpLongTrendSpread=4;           // How many bars of the InpLongTimeFrame Trend before trading allowed MIN 2

                                          // Linear Regression Channel is calculated on 4HR time period, then if the slope is greater than
// the InpLinRegTrade parameter trading will be allowed. Open trades will still be
// exited at the specified indicator regardless of this setting. This ONLY controls
// the opening of new orders.                                                
input int InpLinRegLen = 5;                 // Length of Linear Regression Channel for Trade Control
input ushort InpLinRegTrade = 40;           // Slope of Linear Regression Channel to allow trading (in pips)
input bool InpTradeTrend=true;           // Trading if Linear Regression Slope GREATER than InpLinRegTrade parameter ALWAYS SET AS TRUE
//+------------------------------------------------------------------+
//| Enum Take Profit and Stop Loss                                   |
//+------------------------------------------------------------------+
enum ENUM_TP_SL
  {
   pips=0,                 // ... by Pips Mode
   highest_lowest_range=1, // ... by Highest/Lowest of Range of Bars
   high_low_bar=2,         // ... by High/Low of Bar x
  };

input string      s2="__________________Take Profit Parameters";
input bool        InpUseTakeProfit=false;
input ENUM_TP_SL  InpTakeProfitMode=pips;

input string      s3="__________________Stop Loss Parameters";
input bool        InpUseStopLoss=false;
input ENUM_TP_SL  InpStopMode=highest_lowest_range;

input string      s4="__________________Trailing Stop Parameters";
input bool        InpUseTrail=false;
input ENUM_TP_SL  InpTrailMode=highest_lowest_range;
input ushort      InpTrailingStep=5;        // Trailing Step, in pips (1.00045-1.00055=1 pips)

input int         InpStopBar=7;

input string      s5="__________________Buy Order Parameters";
input ushort      InpTakeProfitPip_Buy = 150;
input int         InpTakeProfitBar_Buy = 0;
input ushort      InpStopPip_Buy       = 0;

input ushort      InpTrailingStopBuy=0;  // Trailing Stop BUY (min distance from price to Stop Loss, in pips
input int         InpTrailBarBuy    = 7; // Trail Bar BUY

input string      s6="__________________Sell Order Parameters";
input ushort      InpTakeProfitPip_Sell   = 150;
input int         TakeProfitBar_Sell      = 0;

input ushort      InpStopPip_Sell=0;

input ushort      InpTrailingStopSell  = 0;  // Trailing Stop SELL (min distance from price to Stop Loss, in pips
input int         InpTrailBarSell      = 7;  // Trail Bar SELL

input ulong    m_magic=166399440;// magic number
//---
ulong          m_slippage=10;                // slippage

double ExtLinRegTrade         = 0.0;
double ExtTrailingStep        = 0.0;
double ExtTakeProfitPip_Buy   = 0.0;
double ExtStopPip_Buy         = 0.0;
double ExtTrailingStopBuy     = 0.0;
double ExtTakeProfitPip_Sell  = 0.0;
double ExtStopPip_Sell        = 0.0;
double ExtTrailingStopSell    = 0.0;

int    handle_iCustomLong;                   // variable for storing the handle of the iCustom indicator 
int    handle_iCustomShort;                  // variable for storing the handle of the iCustom indicator 
double m_adjusted_point;                     // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Testing Control only
   if(InpLongTimeFrame!=PERIOD_M5 && InpLongTimeFrame!=PERIOD_M15 &&
      InpLongTimeFrame!=PERIOD_M30 && InpLongTimeFrame!=PERIOD_H1 &&
      InpLongTimeFrame!=PERIOD_H4 && InpLongTimeFrame!=PERIOD_D1)
      Print("ERROR: \"RSI Custom Smoothing Long: timeframe\" can only be M5, M15, M30, H1, H4 or D1");
   if(InpShortTimeFrame!=PERIOD_M5 && InpShortTimeFrame!=PERIOD_M15 &&
      InpShortTimeFrame!=PERIOD_M30 && InpShortTimeFrame!=PERIOD_H1 &&
      InpShortTimeFrame!=PERIOD_H4 && InpShortTimeFrame!=PERIOD_D1)
      Print("ERROR: \"RSI Custom Smoothing Short: timeframe\" can only be M5, M15, M30, H1, H4 or D1");
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();
//---
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtLinRegTrade         = InpLinRegTrade         * m_adjusted_point;
   ExtTrailingStep        = InpTrailingStep        * m_adjusted_point;
   ExtTakeProfitPip_Buy   = InpTakeProfitPip_Buy   * m_adjusted_point;
   ExtStopPip_Buy         = InpStopPip_Buy         * m_adjusted_point;
   ExtTrailingStopBuy     = InpTrailingStopBuy     * m_adjusted_point;
   ExtTakeProfitPip_Sell  = InpTakeProfitPip_Sell  * m_adjusted_point;
   ExtStopPip_Sell        = InpStopPip_Sell        * m_adjusted_point;
   ExtTrailingStopSell    = InpTrailingStopSell    * m_adjusted_point;
//--- check the input parameter "Lots"
   string err_text="";
   if(IntLotOrRisk==lot)
     {
      if(!CheckVolumeValue(InpVolumeLorOrRisk,err_text))
        {
         //--- when testing, we will only output to the log about incorrect input parameters
         if(MQLInfoInteger(MQL_TESTER))
           {
            Print(__FUNCTION__,", ERROR: ",err_text);
            return(INIT_FAILED);
           }
         else // if the Expert Advisor is run on the chart, tell the user about the error
           {
            Alert(__FUNCTION__,", ERROR: ",err_text);
            return(INIT_PARAMETERS_INCORRECT);
           }
        }
     }
   else
     {
      if(m_money!=NULL)
         delete m_money;
      m_money=new CMoneyFixedMargin;
      if(m_money!=NULL)
        {
         if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
            return(INIT_FAILED);
         m_money.Percent(InpVolumeLorOrRisk);
        }
      else
        {
         Print(__FUNCTION__,", ERROR: Object CMoneyFixedMargin is NULL");
         return(INIT_FAILED);
        }
     }
//--- create handle of the indicator iCustom
   handle_iCustomLong=iCustom(m_symbol.Name(),InpLongTimeFrame,"RSI Custom Smoothing",
                              InpLong_ma_period,clrDodgerBlue,1,InpLongParBuy,InpLongParSell);
//--- if the handle is not created 
   if(handle_iCustomLong==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(InpLongTimeFrame),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iCustom
   handle_iCustomShort=iCustom(m_symbol.Name(),InpShortTimeFrame,"RSI Custom Smoothing",
                               InpShort_ma_period,clrCrimson,1,InpShortParBuy,InpShortParSell);
//--- if the handle is not created 
   if(handle_iCustomShort==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCustom indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(InpShortTimeFrame),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(m_money!=NULL)
      delete m_money;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
   if(!RefreshRates())
     {
      PrevBars=0;
      return;
     }
//--- Testing Control only
   if(InpLongTimeFrame!=PERIOD_M5 && InpLongTimeFrame!=PERIOD_M15 &&
      InpLongTimeFrame!=PERIOD_M30 && InpLongTimeFrame!=PERIOD_H1 &&
      InpLongTimeFrame!=PERIOD_H4 && InpLongTimeFrame!=PERIOD_D1)
      return;
   if(InpShortTimeFrame!=PERIOD_M5 && InpShortTimeFrame!=PERIOD_M15 &&
      InpShortTimeFrame!=PERIOD_M30 && InpShortTimeFrame!=PERIOD_H1 &&
      InpShortTimeFrame!=PERIOD_H4 && InpShortTimeFrame!=PERIOD_D1)
      return;
//--- check Freeze and Stops levels
/*
   Type of order/position  |  Activation price  |  Check
   ------------------------|--------------------|--------------------------------------------
   Buy Limit order         |  Ask               |  Ask-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy Stop order          |  Ask	            |  OpenPrice-Ask  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Limit order        |  Bid	            |  OpenPrice-Bid  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Stop order	      |  Bid	            |  Bid-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy position            |  Bid	            |  TakeProfit-Bid >= SYMBOL_TRADE_FREEZE_LEVEL 
                           |                    |  Bid-StopLoss   >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell position           |  Ask	            |  Ask-TakeProfit >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  StopLoss-Ask   >= SYMBOL_TRADE_FREEZE_LEVEL
                           
   Buying is done at the Ask price                 |  Selling is done at the Bid price
   ------------------------------------------------|----------------------------------
   TakeProfit        >= Bid                        |  TakeProfit        <= Ask
   StopLoss          <= Bid	                     |  StopLoss          >= Ask
   TakeProfit - Bid  >= SYMBOL_TRADE_STOPS_LEVEL   |  Ask - TakeProfit  >= SYMBOL_TRADE_STOPS_LEVEL
   Bid - StopLoss    >= SYMBOL_TRADE_STOPS_LEVEL   |  StopLoss - Ask    >= SYMBOL_TRADE_STOPS_LEVEL
*/
   if(!RefreshRates() || !m_symbol.Refresh())
     {
      PrevBars=0;
      return;
     }
//--- FreezeLevel -> for pending order and modification
   double freeze_level=m_symbol.FreezeLevel()*m_symbol.Point();
   if(freeze_level==0.0)
      freeze_level=(m_symbol.Ask()-m_symbol.Bid())*3.0;
   freeze_level*=1.1;
//--- StopsLevel -> for TakeProfit and StopLoss
   double stop_level=m_symbol.StopsLevel()*m_symbol.Point();
   if(stop_level==0.0)
      stop_level=(m_symbol.Ask()-m_symbol.Bid())*3.0;
   stop_level*=1.1;

   if(freeze_level<=0.0 || stop_level<=0.0)
     {
      PrevBars=0;
      return;
     }
//--- Check & Move Trailing Stops
   if(InpUseTrail)
     {
      double level=(freeze_level>stop_level)?freeze_level:stop_level;
      if(InpTrailMode==pips)
         TrailingPips(level);
      if(InpTrailMode==highest_lowest_range)
         TrailingHighestLowest(level);
      if(InpTrailMode==high_low_bar)
         TrailingHighLow(level);
     }
//--- Develope Linear Regression Channel
   double a=0.0,b=0.0,c=0.0,
   sumy=0.0,sumx=0.0,sumxy=0.0,sumx2=0.0,
   h=0.0,l=0.0,
   LR_Slope=0.0,LR_Width=0.0;

   double LR_line[],Sup_line[],Res_line[];
   MqlRates rates_h4[];
   ArrayResize(LR_line,InpLinRegLen);
   ArrayInitialize(LR_line,0.0);

   ArrayResize(Sup_line,InpLinRegLen);
   ArrayInitialize(Sup_line,0.0);

   ArrayResize(Res_line,InpLinRegLen);
   ArrayInitialize(Res_line,0.0);

   ArraySetAsSeries(LR_line,true);
   ArraySetAsSeries(Sup_line,true);
   ArraySetAsSeries(Res_line,true);
   ArraySetAsSeries(rates_h4,true);

   if(CopyRates(m_symbol.Name(),PERIOD_H4,0,InpLinRegLen,rates_h4)!=InpLinRegLen)
      return;

   for(int i=0; i<InpLinRegLen; i++)
     {
      sumy+=rates_h4[i].close;
      sumxy+=rates_h4[i].close*i;
      sumx+=i;
      sumx2+=i*i;
     }

   c=sumx2*InpLinRegLen-sumx*sumx;

   if(c==0.0)
     {
      Alert("Error in linear regression!");
      return;
     }
//--- Line equation    
   b=(sumxy*InpLinRegLen-sumx*sumy)/c;
   a=(sumy-sumx*b)/InpLinRegLen;
//--- Linear regression line in buffer
   for(int x=0;x<InpLinRegLen;x++)
      LR_line[x]=a+b*x;

   for(int x=0;x<InpLinRegLen;x++)
     {
      if(rates_h4[x].high-LR_line[x]>h)
         h=rates_h4[x].high-LR_line[x];
      if(LR_line[x]-rates_h4[x].low>l)
         l=LR_line[x]-rates_h4[x].low;
     }

//--- Drawing support - resistance lines   
   if(h>l)
     {
      for(int x=0;x<InpLinRegLen;x++)
        {
         Sup_line[x]=a-h+b*x;
         Res_line[x]=a+h+b*x;
        }
     }
   else
     {
      for(int x=0;x<InpLinRegLen;x++)
        {
         Sup_line[x]=a-l+b*x;
         Res_line[x]=a+l+b*x;
        }
     }
   LR_Slope = MathAbs(LR_line[0] - LR_line[InpLinRegLen-1]);
   LR_Width = Res_line[0] - Sup_line[0];
   Print(" LR Slope = ",DoubleToString(LR_Slope,m_symbol.Digits()),
         " LR Channel Width = ",DoubleToString(LR_Width,m_symbol.Digits()));
//--- Trading conditions      

   double rsi_long[],rsi_short[];
   ArraySetAsSeries(rsi_long,true);
   ArraySetAsSeries(rsi_short,true);

   int buffer=0,start_pos=0,count=(InpLongTrendSpread<2)?2:InpLongTrendSpread+1;

   if(!iGetArray(handle_iCustomLong,buffer,start_pos,count,rsi_long) || 
      !iGetArray(handle_iCustomShort,buffer,start_pos,count,rsi_short))
      return;

   bool cBuy=false,cSell=false,cExitBuy=false,cExitSell=false;

   if(InpTradeTrend)
     {
      cSell  = (int)rsi_long[1] < InpLongParSell && (int)rsi_short[1] > InpShortParSell && rsi_long[1] < rsi_long[InpLongTrendSpread] && rsi_short[1] < rsi_short[2];
      cBuy   = (int)rsi_long[1] > InpLongParBuy && (int)rsi_short[1] < InpShortParBuy && rsi_long[1] > rsi_long[InpLongTrendSpread] && rsi_short[1] > rsi_short[2];

      cExitBuy  = cSell;
      cExitSell = cBuy;
     }
//--- calculate open orders by current symbol
   if(!IsPositionExists())
     {
      if(LR_Slope>ExtLinRegTrade)
        {
         if(cBuy)
            OpenPosition(POSITION_TYPE_BUY);
         else if(cSell)
            OpenPosition(POSITION_TYPE_SELL);
        }
     }
   else
     {
      if(cExitBuy)
         ClosePositions(POSITION_TYPE_BUY);
      if(cExitSell)
         ClosePositions(POSITION_TYPE_SELL);
     }
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the position volume                     |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем меньше минимально допустимого SYMBOL_VOLUME_MIN=%.2f",min_volume);
      else
         error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем больше максимально допустимого SYMBOL_VOLUME_MAX=%.2f",max_volume);
      else
         error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем не кратен минимальному шагу SYMBOL_VOLUME_STEP=%.2f, ближайший правильный объем %.2f",
                                        volume_step,ratio*volume_step);
      else
         error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                        volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+
//| Compare doubles                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2,int digits)
  {
   digits--;
   if(digits<0)
      digits=0;
   if(NormalizeDouble(number1-number2,digits)==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| Trailing                                                         |
//|   InpTrailingStop: min distance from price to Stop Loss          |
//+------------------------------------------------------------------+
void TrailingPips(const double stop_level)
  {
/*
     Buying is done at the Ask price                 |  Selling is done at the Bid price
   ------------------------------------------------|----------------------------------
   TakeProfit        >= Bid                        |  TakeProfit        <= Ask
   StopLoss          <= Bid	                     |  StopLoss          >= Ask
   TakeProfit - Bid  >= SYMBOL_TRADE_STOPS_LEVEL   |  Ask - TakeProfit  >= SYMBOL_TRADE_STOPS_LEVEL
   Bid - StopLoss    >= SYMBOL_TRADE_STOPS_LEVEL   |  StopLoss - Ask    >= SYMBOL_TRADE_STOPS_LEVEL
*/
   if(InpTrailingStopBuy==0 && InpTrailingStopSell==0)
      return;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY && ExtTrailingStopBuy>0.0)
              {
               if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStopBuy+ExtTrailingStep)
                  if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStopBuy+ExtTrailingStep))
                     if(ExtTrailingStopBuy>=stop_level)
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStopBuy),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        RefreshRates();
                        m_position.SelectByIndex(i);
                        PrintResultModify(m_trade,m_symbol,m_position);
                        continue;
                       }
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL && ExtTrailingStopSell>0.0)
              {
               if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStopSell+ExtTrailingStep)
                  if((m_position.StopLoss()>(m_position.PriceCurrent()+(ExtTrailingStopSell+ExtTrailingStep))) || 
                     (m_position.StopLoss()==0))
                     if(ExtTrailingStopSell>=stop_level)
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStopSell),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        RefreshRates();
                        m_position.SelectByIndex(i);
                        PrintResultModify(m_trade,m_symbol,m_position);
                       }
              }

           }
  }
//+------------------------------------------------------------------+
//| Trailing Highest Lowest                                          |
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingHighestLowest(const double stop_level)
  {
/*
     Buying is done at the Ask price                 |  Selling is done at the Bid price
   ------------------------------------------------|----------------------------------
   TakeProfit        >= Bid                        |  TakeProfit        <= Ask
   StopLoss          <= Bid	                     |  StopLoss          >= Ask
   TakeProfit - Bid  >= SYMBOL_TRADE_STOPS_LEVEL   |  Ask - TakeProfit  >= SYMBOL_TRADE_STOPS_LEVEL
   Bid - StopLoss    >= SYMBOL_TRADE_STOPS_LEVEL   |  StopLoss - Ask    >= SYMBOL_TRADE_STOPS_LEVEL
*/
   if(InpTrailBarBuy==0 && InpTrailBarSell==0)
      return;
   int lowest  = -1;
   double low  = 0.0;
   int highest = -1;
   double high = 0.0;
   if(InpTrailBarBuy==0)
     {
      lowest=iLowest(m_symbol.Name(),Period(),MODE_LOW,InpTrailBarBuy,0);
      if(lowest==-1)
         return;
      low=iLow(m_symbol.Name(),Period(),lowest);
      if(low==0.0)
         return;
     }
   if(InpTrailBarSell==0)
     {
      highest=iHighest(m_symbol.Name(),Period(),MODE_HIGH,InpTrailBarSell,0);
      if(highest==-1)
         return;
      high=iHigh(m_symbol.Name(),Period(),highest);
      if(high==0.0)
         return;
     }
/*
   __________BUY__________ | __________SELL__________
                           |
   _ _ _ _ Price Current   |     _ _ _ _ Price Open
                           |
   _ _ _ _ low             |     _ _ _ _ Stop Loss 
                           |
   _ _ _ _ Stop Loss       |     _ _ _ _ high
                           |
   _ _ _ _ Price Open      |     _ _ _ _ Price Current

*/
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY && InpTrailBarBuy>0)
              {
               if(m_position.PriceCurrent()>m_position.PriceOpen() && m_position.PriceCurrent()-low>=stop_level)
                  if(low>m_position.PriceOpen())
                     if(low>m_position.StopLoss() && !CompareDoubles(low,m_position.StopLoss(),m_symbol.Digits()))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(low),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        RefreshRates();
                        m_position.SelectByIndex(i);
                        PrintResultModify(m_trade,m_symbol,m_position);
                        continue;
                       }
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL && InpTrailBarSell>0)
              {
               if(m_position.PriceOpen()>m_position.PriceCurrent() && high-m_position.PriceCurrent()>=stop_level)
                  if(high<m_position.PriceOpen())
                     if((high<m_position.StopLoss() && !CompareDoubles(high,m_position.StopLoss(),m_symbol.Digits())) || 
                        (m_position.StopLoss()==0))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(high),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        RefreshRates();
                        m_position.SelectByIndex(i);
                        PrintResultModify(m_trade,m_symbol,m_position);
                       }
              }

           }
  }
//+------------------------------------------------------------------+
//| Trailing High Low                                                |
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingHighLow(const double stop_level)
  {
/*
     Buying is done at the Ask price                 |  Selling is done at the Bid price
   ------------------------------------------------|----------------------------------
   TakeProfit        >= Bid                        |  TakeProfit        <= Ask
   StopLoss          <= Bid	                     |  StopLoss          >= Ask
   TakeProfit - Bid  >= SYMBOL_TRADE_STOPS_LEVEL   |  Ask - TakeProfit  >= SYMBOL_TRADE_STOPS_LEVEL
   Bid - StopLoss    >= SYMBOL_TRADE_STOPS_LEVEL   |  StopLoss - Ask    >= SYMBOL_TRADE_STOPS_LEVEL
*/
   if(InpTrailBarBuy==0 && InpTrailBarSell==0)
      return;
   double low=0.0;
   double high=0.0;
   if(InpTrailBarBuy==0)
     {
      low=iLow(m_symbol.Name(),Period(),InpTrailBarBuy);
      if(low==0.0)
         return;
     }
   if(InpTrailBarSell==0)
     {
      high=iHigh(m_symbol.Name(),Period(),InpTrailBarSell);
      if(high==0.0)
         return;
     }
/*
   __________BUY__________ | __________SELL__________
                           |
   _ _ _ _ Price Current   |     _ _ _ _ Price Open
                           |
   _ _ _ _ low             |     _ _ _ _ Stop Loss 
                           |
   _ _ _ _ Stop Loss       |     _ _ _ _ high
                           |
   _ _ _ _ Price Open      |     _ _ _ _ Price Current

*/
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY && InpTrailBarBuy>0)
              {
               if(m_position.PriceCurrent()>m_position.PriceOpen() && m_position.PriceCurrent()-low>=stop_level)
                  if(low>m_position.PriceOpen())
                     if(low>m_position.StopLoss() && !CompareDoubles(low,m_position.StopLoss(),m_symbol.Digits()))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(low),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        RefreshRates();
                        m_position.SelectByIndex(i);
                        PrintResultModify(m_trade,m_symbol,m_position);
                        continue;
                       }
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL && InpTrailBarSell>0)
              {
               if(m_position.PriceOpen()>m_position.PriceCurrent() && high-m_position.PriceCurrent()>=stop_level)
                  if(high<m_position.PriceOpen())
                     if((high<m_position.StopLoss() && !CompareDoubles(high,m_position.StopLoss(),m_symbol.Digits())) || 
                        (m_position.StopLoss()==0))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(high),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                        RefreshRates();
                        m_position.SelectByIndex(i);
                        PrintResultModify(m_trade,m_symbol,m_position);
                       }
              }

           }
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultModify(CTrade &trade,CSymbolInfo &symbol,CPositionInfo &position)
  {
   Print("File: ",__FILE__,", symbol: ",m_symbol.Name());
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result as a string: "+trade.ResultRetcodeDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("Order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("Current bid price: "+DoubleToString(symbol.Bid(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("Current ask price: "+DoubleToString(symbol.Ask(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("Broker comment: "+trade.ResultComment());
   Print("Freeze Level: "+DoubleToString(m_symbol.FreezeLevel(),0),", Stops Level: "+DoubleToString(m_symbol.StopsLevel(),0));
   Print("Price of position opening: "+DoubleToString(position.PriceOpen(),symbol.Digits()));
   Print("Price of position's Stop Loss: "+DoubleToString(position.StopLoss(),symbol.Digits()));
   Print("Price of position's Take Profit: "+DoubleToString(position.TakeProfit(),symbol.Digits()));
   Print("Current price by position: "+DoubleToString(position.PriceCurrent(),symbol.Digits()));
  }
//+------------------------------------------------------------------+
//| Get value of buffers                                             |
//+------------------------------------------------------------------+
double iGetArray(const int handle,const int buffer,const int start_pos,const int count,double &arr_buffer[])
  {
   bool result=true;
   if(!ArrayIsDynamic(arr_buffer))
     {
      Print("This a no dynamic array!");
      return(false);
     }
   ArrayFree(arr_buffer);
//--- reset error code 
   ResetLastError();
//--- fill a part of the iBands array with values from the indicator buffer
   int copied=CopyBuffer(handle,buffer,start_pos,count,arr_buffer);
   if(copied!=count)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
   return(result);
  }
//+------------------------------------------------------------------+
//| Is position exists                                               |
//+------------------------------------------------------------------+
bool IsPositionExists(void)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Open position                                                    |
//+------------------------------------------------------------------+
void OpenPosition(const ENUM_POSITION_TYPE pos_type)
  {
//--- check Freeze and Stops levels
/*
   Type of order/position  |  Activation price  |  Check
   ------------------------|--------------------|--------------------------------------------
   Buy Limit order         |  Ask               |  Ask-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy Stop order          |  Ask	            |  OpenPrice-Ask  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Limit order        |  Bid	            |  OpenPrice-Bid  >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell Stop order	      |  Bid	            |  Bid-OpenPrice  >= SYMBOL_TRADE_FREEZE_LEVEL
   Buy position            |  Bid	            |  TakeProfit-Bid >= SYMBOL_TRADE_FREEZE_LEVEL 
                           |                    |  Bid-StopLoss   >= SYMBOL_TRADE_FREEZE_LEVEL
   Sell position           |  Ask	            |  Ask-TakeProfit >= SYMBOL_TRADE_FREEZE_LEVEL
                           |                    |  StopLoss-Ask   >= SYMBOL_TRADE_FREEZE_LEVEL
                           
   Buying is done at the Ask price                 |  Selling is done at the Bid price
   ------------------------------------------------|----------------------------------
   TakeProfit        >= Bid                        |  TakeProfit        <= Ask
   StopLoss          <= Bid	                     |  StopLoss          >= Ask
   TakeProfit - Bid  >= SYMBOL_TRADE_STOPS_LEVEL   |  Ask - TakeProfit  >= SYMBOL_TRADE_STOPS_LEVEL
   Bid - StopLoss    >= SYMBOL_TRADE_STOPS_LEVEL   |  StopLoss - Ask    >= SYMBOL_TRADE_STOPS_LEVEL
*/
   if(!RefreshRates() || !m_symbol.Refresh())
      return;
//--- FreezeLevel -> for pending order and modification
   double freeze_level=m_symbol.FreezeLevel()*m_symbol.Point();
   if(freeze_level==0.0)
      freeze_level=(m_symbol.Ask()-m_symbol.Bid())*3.0;
   freeze_level*=1.1;
//--- StopsLevel -> for TakeProfit and StopLoss
   double stop_level=m_symbol.StopsLevel()*m_symbol.Point();
   if(stop_level==0.0)
      stop_level=(m_symbol.Ask()-m_symbol.Bid())*3.0;
   stop_level*=1.1;

   if(freeze_level<=0.0 || stop_level<=0.0)
      return;
//---
   if(pos_type==POSITION_TYPE_BUY)
     {
      double price=m_symbol.Ask();
      double sl=0.0,tp=0.0;
      GetSLTP(pos_type,sl,tp);
      if(((sl!=0 && price-sl>=stop_level) || sl==0.0) && ((tp!=0 && tp-price>=stop_level) || tp==0.0))
        {
         OpenBuy(sl,tp);
         return;
        }
     }
   if(pos_type==POSITION_TYPE_SELL)
     {
      double price=m_symbol.Bid();
      double sl=0.0,tp=0.0;
      GetSLTP(pos_type,sl,tp);
      if(((sl!=0 && sl-price>=stop_level) || sl==0.0) && ((tp!=0 && price-tp>=stop_level) || tp==0.0))
        {
         OpenSell(sl,tp);
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//| Get Stop Loss and Take Profit                                    |
//+------------------------------------------------------------------+
void GetSLTP(const ENUM_POSITION_TYPE pos_type,double &sl,double tp)
  {
   sl=0.0; tp=0.0;

   if(InpUseStopLoss)
     {
      //--- ... by Pips Mode
      if(InpStopMode==pips)
        {
         if(pos_type==POSITION_TYPE_BUY)
           {
            double price=m_symbol.Ask();
            sl=(InpStopPip_Buy==0)?0.0:price-ExtStopPip_Buy;
           }
         if(pos_type==POSITION_TYPE_SELL)
           {
            double price=m_symbol.Bid();
            sl=(InpStopPip_Sell==0)?0.0:price+ExtStopPip_Sell;
           }
        }
      //--- ... by Highest/Lowest of Range of Bars
      if(InpStopMode==highest_lowest_range)
        {
         int lowest  = -1;
         double low  = 0.0;
         int highest = -1;
         double high = 0.0;

         lowest=iLowest(m_symbol.Name(),InpLongTimeFrame,MODE_LOW,InpStopBar,0);
         if(lowest==-1)
            return;
         low=iLow(m_symbol.Name(),InpLongTimeFrame,lowest);
         if(low==0.0)
            return;

         highest=iHighest(m_symbol.Name(),InpLongTimeFrame,MODE_HIGH,InpStopBar,0);
         if(highest==-1)
            return;
         high=iHigh(m_symbol.Name(),InpLongTimeFrame,highest);
         if(high==0.0)
            return;

         if(pos_type==POSITION_TYPE_BUY)
            sl=low;
         if(pos_type==POSITION_TYPE_SELL)
            sl=high;
        }
      //--- ... by High/Low of Bar x
      if(InpStopMode==high_low_bar)
        {
         double low  = 0.0;
         double high = 0.0;

         low=iLow(m_symbol.Name(),InpLongTimeFrame,InpStopBar);
         if(low==0.0)
            return;

         high=iHigh(m_symbol.Name(),InpLongTimeFrame,InpStopBar);
         if(high==0.0)
            return;

         if(pos_type==POSITION_TYPE_BUY)
            sl=low;
         if(pos_type==POSITION_TYPE_SELL)
            sl=high;
        }
     }
   if(InpUseTakeProfit)
     {
      //--- ... by Pips Mode
      if(InpStopMode==pips)
        {
         if(pos_type==POSITION_TYPE_BUY)
           {
            double price=m_symbol.Ask();
            tp=(InpTakeProfitPip_Buy==0)?0.0:price+ExtTakeProfitPip_Buy;
           }
         if(pos_type==POSITION_TYPE_SELL)
           {
            double price=m_symbol.Bid();
            tp=(InpTakeProfitPip_Sell==0)?0.0:price-ExtTakeProfitPip_Sell;
           }
        }
      //--- ... by Highest/Lowest of Range of Bars
      if(InpStopMode==highest_lowest_range)
        {
         int lowest  = -1;
         double low  = 0.0;
         int highest = -1;
         double high = 0.0;

         lowest=iLowest(m_symbol.Name(),InpLongTimeFrame,MODE_LOW,InpStopBar,0);
         if(lowest==-1)
            return;
         low=iLow(m_symbol.Name(),InpLongTimeFrame,lowest);
         if(low==0.0)
            return;

         highest=iHighest(m_symbol.Name(),InpLongTimeFrame,MODE_HIGH,InpStopBar,0);
         if(highest==-1)
            return;
         high=iHigh(m_symbol.Name(),InpLongTimeFrame,highest);
         if(high==0.0)
            return;

         if(pos_type==POSITION_TYPE_BUY)
            tp=high;
         if(pos_type==POSITION_TYPE_SELL)
            tp=low;
        }
      //--- ... by High/Low of Bar x
      if(InpStopMode==high_low_bar)
        {
         double low  = 0.0;
         double high = 0.0;

         low=iLow(m_symbol.Name(),InpLongTimeFrame,InpStopBar);
         if(low==0.0)
            return;

         high=iHigh(m_symbol.Name(),InpLongTimeFrame,InpStopBar);
         if(high==0.0)
            return;

         if(pos_type==POSITION_TYPE_BUY)
            tp=high;
         if(pos_type==POSITION_TYPE_SELL)
            tp=low;
        }
     }
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double long_lot=0.0;
   if(InpUseMoneyManagement)
     {
      if(IntLotOrRisk==risk)
        {
         long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
         Print("sl=",DoubleToString(sl,m_symbol.Digits()),
               ", CheckOpenLong: ",DoubleToString(long_lot,2),
               ", Balance: ",    DoubleToString(m_account.Balance(),2),
               ", Equity: ",     DoubleToString(m_account.Equity(),2),
               ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
         if(long_lot==0.0)
           {
            Print(__FUNCTION__,", ERROR: method CheckOpenLong returned the value of \"0.0\"");
            return;
           }
        }
      else if(IntLotOrRisk==lot)
         long_lot=InpVolumeLorOrRisk;
      else
         return;
     }
   else
      long_lot=TradeSizeOptimized();
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check= m_account.FreeMarginCheck(m_symbol.Name(),ORDER_TYPE_BUY,long_lot,m_symbol.Ask());
   double margin_check     = m_account.MarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,long_lot,m_symbol.Bid());
   if(free_margin_check>margin_check)
     {
      if(m_trade.Buy(long_lot,m_symbol.Name(),m_symbol.Ask(),sl,tp))
        {
         if(m_trade.ResultDeal()==0)
           {
            if(m_trade.ResultRetcode()==10009)
              {
               //m_waiting_transaction=true;  // "true" -> it's forbidden to trade, we expect a transaction
               //m_waiting_order_ticket=m_trade.ResultOrder();
              }
            Print("#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
         else
           {
            if(m_trade.ResultRetcode()==10009)
              {
               //m_waiting_transaction=true;  // "true" -> it's forbidden to trade, we expect a transaction
               //m_waiting_order_ticket=m_trade.ResultOrder();
              }
            Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         PrintResultTrade(m_trade,m_symbol);
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CAccountInfo::FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double short_lot=0.0;
   if(InpUseMoneyManagement)
     {
      if(IntLotOrRisk==risk)
        {
         short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
         Print("sl=",DoubleToString(sl,m_symbol.Digits()),
               ", CheckOpenLong: ",DoubleToString(short_lot,2),
               ", Balance: ",    DoubleToString(m_account.Balance(),2),
               ", Equity: ",     DoubleToString(m_account.Equity(),2),
               ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
         if(short_lot==0.0)
           {
            Print(__FUNCTION__,", ERROR: method CheckOpenShort returned the value of \"0.0\"");
            return;
           }
        }
      else if(IntLotOrRisk==lot)
         short_lot=InpVolumeLorOrRisk;
      else
         return;
     }
   else
      short_lot=TradeSizeOptimized();
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double free_margin_check= m_account.FreeMarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,short_lot,m_symbol.Bid());
   double margin_check     = m_account.MarginCheck(m_symbol.Name(),ORDER_TYPE_SELL,short_lot,m_symbol.Bid());
   if(free_margin_check>margin_check)
     {
      if(m_trade.Sell(short_lot,m_symbol.Name(),m_symbol.Bid(),sl,tp))
        {
         if(m_trade.ResultDeal()==0)
           {
            if(m_trade.ResultRetcode()==10009)
              {
               //m_waiting_transaction=true;  // "true" -> it's forbidden to trade, we expect a transaction
               //m_waiting_order_ticket=m_trade.ResultOrder();
              }
            Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
         else
           {
            if(m_trade.ResultRetcode()==10009)
              {
               //m_waiting_transaction=true;  // "true" -> it's forbidden to trade, we expect a transaction
               //m_waiting_order_ticket=m_trade.ResultOrder();
              }
            Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
               ", description of result: ",m_trade.ResultRetcodeDescription());
         PrintResultTrade(m_trade,m_symbol);
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CAccountInfo::FreeMarginCheck returned the value ",DoubleToString(free_margin_check,2));
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double TradeSizeOptimized(void)
  {
   double price=m_symbol.Ask();
   double margin=0.0;
//--- select lot size
   margin=m_account.MarginCheck(m_symbol.Name(),ORDER_TYPE_BUY,1.0,price);
   if(margin<=0.0 || margin==EMPTY_VALUE)
      return(0.0);
   double lot=NormalizeDouble(m_account.FreeMargin()*InpMaximumRisk/margin,2);
//--- calculate number of losses orders without a break
   if(InpDecreaseFactor>0)
     {
      //--- select history for access
      datetime time=TimeTradeServer();
      HistorySelect(time-InpHistoryDays*60*60*24,time+60*60*24);
      //---
      int    deals=HistoryDealsTotal();   // total history deals
      int    losses=0;                    // number of losses orders without a break

      for(int i=deals-1;i>=0;i--)
        {
         ulong ticket=HistoryDealGetTicket(i);
         if(ticket==0)
           {
            Print("HistoryDealGetTicket failed, no trade history");
            break;
           }
         //--- check symbol
         if(HistoryDealGetString(ticket,DEAL_SYMBOL)!=m_symbol.Name())
            continue;
         //--- check Expert Magic number
         if(HistoryDealGetInteger(ticket,DEAL_MAGIC)!=m_magic)
            continue;
         //--- check profit
         double profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
         if(profit>0.0)
            break;
         if(profit<0.0)
            losses++;
        }
      //---
      if(losses>1)
         lot=NormalizeDouble(lot-lot*losses/InpDecreaseFactor,1);
     }
//--- normalize and check limits
   double stepvol=m_symbol.LotsStep();
   lot=stepvol*NormalizeDouble(lot/stepvol,0);

   double minvol=m_symbol.LotsMin();
   if(lot<minvol)
      lot=minvol;

   double maxvol=m_symbol.LotsMax();
   if(lot>maxvol)
      lot=maxvol;
//--- return trading volume
   return(lot);
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultTrade(CTrade &trade,CSymbolInfo &symbol)
  {
   Print("File: ",__FILE__,", symbol: ",m_symbol.Name());
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result as a string: "+trade.ResultRetcodeDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("Order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("Current bid price: "+DoubleToString(symbol.Bid(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("Current ask price: "+DoubleToString(symbol.Ask(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("Broker comment: "+trade.ResultComment());
   Print("Freeze Level: "+DoubleToString(m_symbol.FreezeLevel(),0),", Stops Level: "+DoubleToString(m_symbol.StopsLevel(),0));
  }
//+------------------------------------------------------------------+
