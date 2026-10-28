//+------------------------------------------------------------------+
//|                     EURUSD breakout(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, TraderSeven/Matt Kennel"
#property link      "TraderSeven@gmx.net"
#property version   "1.001"

#define MODE_LOW 1
#define MODE_HIGH 2
//            \\|//             +-+-+-+-+-+-+-+-+-+-+-+             \\|// 
//           ( o o )            |T|r|a|d|e|r|S|e|v|e|n|            ( o o )
//    ~~~~oOOo~(_)~oOOo~~~~     +-+-+-+-+-+-+-+-+-+-+-+     ~~~~oOOo~(_)~oOOo~~~~
// Run on EUR/USD M15 
// If there was a small range during the EU session then there is a trading opportunity during the US session.
//
//----------------------- USER INPUT
//
// --- Numerous programming problems fixed by Matt Kennel ("Doctor Chaos"), now executes trades
//     Not yet profitable.  
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
///+------------------------------------------------------------------+
//| Enum hours                                                       |
//+------------------------------------------------------------------+
enum ENUM_HOURS
  {
   hour_00  =0,   // 00
   hour_01  =1,   // 01
   hour_02  =2,   // 02
   hour_03  =3,   // 03
   hour_04  =4,   // 04
   hour_05  =5,   // 05
   hour_06  =6,   // 06
   hour_07  =7,   // 07
   hour_08  =8,   // 08
   hour_09  =9,   // 09
   hour_10  =10,  // 10
   hour_11  =11,  // 11
   hour_12  =12,  // 12
   hour_13  =13,  // 13
   hour_14  =14,  // 14
   hour_15  =15,  // 15
   hour_16  =16,  // 16
   hour_17  =17,  // 17
   hour_18  =18,  // 18
   hour_19  =19,  // 19
   hour_20  =20,  // 20
   hour_21  =21,  // 21
   hour_22  =22,  // 22
   hour_23  =23,  // 23
  };
//--- input parameters
input ENUM_HOURS  Start_hour_EU_session= hour_05;
input ENUM_HOURS  Start_hour_US_session= hour_02;
input ENUM_HOURS  End_hour_US_session  = hour_16;
input ushort      InpSmallEUSessionPips= 72;       // Small EU Session (in pips)
input bool        Trade_on_Monday      = false;    // Trade on Monday
input double      InpLots              = 1.0;      // Lots
input ushort      InpStopLoss          = 12;       // Stop Loss (in pips)
input ushort      InpTakeProfit        = 15;       // Take Profit (in pips)
//---
ulong             m_magic=671194510;               // magic number
ulong             m_slippage=30;                   // slippage
double            ExtSmallEUSessionPips=0.0;
double            ExtStopLoss=0.0;
double            ExtTakeProfit=0.0;
double            m_adjusted_point;                // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   RefreshRates();
   m_symbol.Refresh();

   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtSmallEUSessionPips   =  InpSmallEUSessionPips   *  m_adjusted_point;
   ExtStopLoss             =  InpStopLoss             *  m_adjusted_point;
   ExtTakeProfit           =  InpTakeProfit           *  m_adjusted_point;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   bool TradeDayOK=(str1.day_of_week>=1) && (str1.day_of_week<=5); // M-F, not sat or sun.
   if((str1.day_of_week==1) && (Trade_on_Monday==false))
      TradeDayOK=false;
   if(!TradeDayOK)
      return;
//---
   static double TopRange=0.0,LowRange=0.0;
   static bool bought=false,sold=false,small_session=false,session_found=false;
//--- static variables will be retained over calls. 
   if(str1.hour==0)
     {
      // reset for a new day at midnight. 
      TopRange=0;
      LowRange=0;
      bought=false; // we allow only one buy and one sell per day. 
      sold=false;
      session_found=false;
     }
//--- it may be a good idea to also avoid NFP days, first thursday in any month. 
   if((!session_found) && (str1.hour==Start_hour_US_session))
     {
      //--- first time through, compute EU session highs and lows.
      TopRange=iHighest(m_symbol.Name(),Period(),MODE_HIGH,24,1); // 24 M15 bars during EU session
      LowRange=iLowest(m_symbol.Name(),Period(),MODE_LOW,24,1);  // 24 M15 bars during EU session
      //---
      if(TopRange<=0.0 || LowRange<=0.0)
         return;
      //---
      if((TopRange-LowRange)<=ExtSmallEUSessionPips)
         small_session=true;
      else
         small_session=false;
      session_found=true;
      string text=(small_session)?"true":"false";
      Print("Identified new EU session + ["+
            DoubleToString(LowRange,m_symbol.Digits())+","+
            DoubleToString(TopRange,m_symbol.Digits())+"]"+
            " DayOfYear()="+IntegerToString(str1.day_of_year)+" small? "+text);
     }
   if(session_found && small_session && 
      (str1.hour>=Start_hour_US_session) && (str1.hour<End_hour_US_session)) // Within US session hours?
     {
      //--- Calculate EU session range
      //---  Print("Am in US session... small_session, bought, sold = " + small_session+bought+sold); 
      //---  Print("TopRange = "+ TopRange + "LowRange = " + LowRange); 
      int h=str1.hour;
      int m=str1.min;
      if(h>Start_hour_EU_session+5 && h<Start_hour_EU_session+10)
        {//--- at least one US session bar should be completed
         //--- Print("Could be buying/selling..."+h+":"+m); 
         double low=iLow(1);
         double high=iHigh(1);
         //---
         if(low==0.0 || high==0.0)
            return;
         //---
         if(!RefreshRates())
            return;
         if((!bought) && (low>(TopRange+Point()*3)))
           {
            if(OpenBuy(m_symbol.Ask()-ExtStopLoss,m_symbol.Ask()+ExtTakeProfit))
               bought=true;
           }
         if((!sold) && (high<(LowRange-Point()*3)))
           {
            if(OpenSell(m_symbol.Bid()+ExtStopLoss,m_symbol.Bid()-ExtTakeProfit))
               sold=true;
           }
        } // end if in 2nd US time. 
     }// end if small session
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
      return(false);
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
// double min_volume=m_symbol.LotsMin();
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
// double max_volume=m_symbol.LotsMax();
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
// double volume_step=m_symbol.LotsStep();
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                     volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(string symbol,int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iLowest(string symbol,
               ENUM_TIMEFRAMES timeframe,
               int type,
               int count=WHOLE_ARRAY,
               int start=0)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   if(start<0)
      return(-1.0);
   if(count<=0)
      count=Bars(symbol,timeframe);
   if(type==MODE_LOW)
     {
      double Low[];
      CopyLow(symbol,timeframe,start,count,Low);
      int index_min=ArrayMinimum(Low,0,WHOLE_ARRAY);
      return(Low[index_min]);
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iHighest(string symbol,
                ENUM_TIMEFRAMES timeframe,
                int type,
                int count=WHOLE_ARRAY,
                int start=0)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   if(start<0)
      return(-1.0);
   if(count<=0)
      count=Bars(symbol,timeframe);
   if(type==MODE_HIGH)
     {
      double High[];
      CopyHigh(symbol,timeframe,start,count,High);
      int index_max=ArrayMaximum(High,0,WHOLE_ARRAY);
      return(High[index_max]);
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+ 
//| Get the High for specified bar index                             | 
//+------------------------------------------------------------------+ 
double iHigh(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   double High[1];
   double high=0.0;
   int copied=CopyHigh(symbol,timeframe,index,1,High);
   if(copied>0)
      high=High[0];
   return(high);
  }
//+------------------------------------------------------------------+ 
//| Get Low for specified bar index                                  | 
//+------------------------------------------------------------------+ 
double iLow(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   double Low[1];
   double low=0.0;
   int copied=CopyLow(symbol,timeframe,index,1,Low);
   if(copied>0)
      low=Low[0];
   return(low);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
bool OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Buy(InpLots,m_symbol.Name(),m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(false);
              }
            else
              {
               Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(true);
              }
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            return(false);
           }
        }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
bool OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Sell(InpLots,m_symbol.Name(),m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(false);
              }
            else
              {
               Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               return(true);
              }
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            return(false);
           }
        }
//---
   return(false);
  }
//+------------------------------------------------------------------+
