//+------------------------------------------------------------------+
//|                           HarVesteR(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property copyright "FORTRADER.RU"
#property link      "http://FORTRADER.RU"
#property version   "1.001"
//---
#define MODE_LOW 1
#define MODE_HIGH 2
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input string x="MACD Settings:";             // MACD Settings
input int      FastEMA           = 12;       // MACD: period for Fast average calculation 
input int      SlowEMA           = 24;       // MACD: period for Slow average calculation
input int      SignalEMA         = 9;        // MACD: period for their difference averaging
input int      InpNumberBarsMACD = 6;        // Number of bars MACD (only >= 1)
input string x1="MA Settings:";              // MA Settings
input int      SMA1              = 50;       // MA #1: averaging period 
input int      SMA2              = 100;      // MA #2: averaging period 
input ushort   InpMinIndentation = 10;       // Minimal indentation (in pips)
input int      InpNumberBarsSL   = 6;        // Number of bars Stop loss (only >= 1)
input string x2="ADX Settings:";             // ADX Settings
input bool     InpADXenable      = false;    // ADX enable: true -> use adx, false -> const "60"
input double   InpBuyLevelADX    = 50;       // Buy Level ADX (use only if "ADX enable == true")
input double   InpSellLevelADX   = 50;       // Sell Level ADX (use only if "ADX enable == true")
input int      periodADX         = 14;       // ADX period
input string x3="Trade Settings:";           // Trade Settings
input int      pprofitum         = 2;        // Half-of-position closing ratio (only >= 2)
input double   Lots              = 1.0;      // Lots
//---
ulong    m_magic=330069188;                  // magic number
ulong    m_slippage=30;                      // slippage
double   ExtMinIndentation=0.0;
int      handle_iMACD;                       // variable for storing the handle of the iMACD indicator 
int      handle_iMA_1;                       // variable for storing the handle of the iMA indicator 
int      handle_iMA_2;                       // variable for storing the handle of the iMA indicator 
int      handle_iADX;                        // variable for storing the handle of the iADX indicator 
double   m_adjusted_point;                   // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpNumberBarsMACD<1)
     {
      Print("The \"Number of bars MACD\" can not be less than one");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpNumberBarsSL<1)
     {
      Print("The \"Number of bars Stop loss\" can not be less than one");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(pprofitum<2)
     {
      Print("The \"Half-of-position closing ratio\" can not be less than two");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   if(Lots<=0.0)
     {
      Print("The \"Lots\" can't be smaller or equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(!CheckVolumeValue(Lots,err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
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

   ExtMinIndentation=InpMinIndentation*m_adjusted_point;
//--- create handle of the indicator iMACD
   handle_iMACD=iMACD(m_symbol.Name(),Period(),FastEMA,SlowEMA,SignalEMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_1=iMA(m_symbol.Name(),Period(),SMA1,0,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_1==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_2=iMA(m_symbol.Name(),Period(),SMA2,0,MODE_SMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_2==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iADX
   handle_iADX=iADX(m_symbol.Name(),Period(),periodADX);
//--- if the handle is not created 
   if(handle_iADX==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iADX indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
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

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
//---
   int count_buys=0;
   int count_sells=0;
   bool okbuy=false;
   bool oksell=false;
   CalculatePositions(count_buys,count_sells);
//--- obtaining data from indicators
   double macd    = iMACDGet(MAIN_LINE,1);
   double sma1_1  = iMAGet(handle_iMA_1,1);
   double sma2_1  = iMAGet(handle_iMA_2,1);
   double adx     = 0.0;
   if(macd==0.0 || sma1_1==0.0 || sma2_1==0.0)
     {
      PrevBars=iTime(1);
      return;
     }
   if(!RefreshRates())
     {
      PrevBars=iTime(1);
      return;
     }
//---
   double close_1=iClose(1);
   if(close_1==0.0)
     {
      PrevBars=iTime(1);
      return;
     }
   if(close_1<sma2_1)
      okbuy=true;
   if(close_1>sma2_1)
      oksell=true;

   bool adxbuy=false;
   bool adxsell=false;
   if(InpADXenable)
     {
      adx=iADXGet(MAIN_LINE,0);
      if(adx==0.0)
        {
         PrevBars=iTime(1);
         return;
        }
      if(adx>InpBuyLevelADX)
         adxbuy=true;
      if(adx>InpSellLevelADX)
         adxsell=true;
     }
   else //adx=60;
     {
      if(adx>60)
         adxbuy=true;
      if(adx<60)
         adxsell=true;
     }

   if(close_1+ExtMinIndentation>sma1_1 && close_1+ExtMinIndentation>sma2_1 && macd>0 && count_buys==0)
     {
      bool macd_main_negative=false;
      double arr_macd[];
      if(!iMACDGet(MAIN_LINE,1,InpNumberBarsMACD,arr_macd))
        {
         PrevBars=iTime(1);
         return;
        }
      int min=ArrayMinimum(arr_macd);
      if(arr_macd[min]<0.0)
         macd_main_negative=true;
      if(macd_main_negative && adxbuy && okbuy)
        {
         double stoploss=iLowest(m_symbol.Name(),Period(),MODE_LOW,InpNumberBarsSL,1);
         if(stoploss==0.0)
           {
            PrevBars=iTime(1);
            return;
           }
         m_trade.Buy(Lots,m_symbol.Name(),m_symbol.Ask(),stoploss);
         return;
        }
     }
   if(close_1-ExtMinIndentation<sma1_1 && close_1-ExtMinIndentation<sma2_1 && macd<0 && count_sells==0)
     {
      bool macd_main_positive=false;
      double arr_macd[];
      if(!iMACDGet(MAIN_LINE,1,InpNumberBarsMACD,arr_macd))
        {
         PrevBars=iTime(1);
         return;
        }
      int max=ArrayMaximum(arr_macd);
      if(arr_macd[max]>0.0)
         macd_main_positive=true;
      if(macd_main_positive && adxsell && oksell)
        {
         double stoploss=iHighest(m_symbol.Name(),Period(),MODE_HIGH,InpNumberBarsSL,1);
         if(stoploss==0.0)
           {
            PrevBars=iTime(1);
            return;
           }
         m_trade.Sell(Lots,m_symbol.Name(),m_symbol.Bid(),stoploss);
         return;
        }
     }
//---
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               double target=m_position.PriceOpen()+MathAbs(m_position.PriceOpen()-m_position.StopLoss())*(double)pprofitum;
               if(close_1>target && m_position.PriceOpen()!=m_position.StopLoss())
                 {
                  // The target is set at the level "Stop loss" * "Half-of-position closing ratio". 
                  // When the target is reached, half of the position is closed and Stoploss is transferred to the breakeven.
                  if(m_position.Volume()>=m_symbol.LotsMin()*2.0)
                    {
                     double lot=LotCheck(m_position.Volume()/2.0);
                     if(lot!=0.0)
                       {
                        m_trade.PositionClosePartial(m_position.Ticket(),lot);
                        m_trade.PositionModify(m_position.Ticket(),m_position.PriceOpen(),m_position.TakeProfit());
                        continue;
                       }
                    }
                 }
               if(m_position.PriceOpen()==m_position.StopLoss())
                  if(sma1_1>close_1-ExtMinIndentation)
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     DebugBreak();
                    }
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               double target=m_position.PriceOpen()-MathAbs(m_position.PriceOpen()-m_position.StopLoss())*(double)pprofitum;
               if(close_1<target && m_position.PriceOpen()!=m_position.StopLoss())
                 {
                  // The target is set at the level "Stop loss" * "Half-of-position closing ratio". 
                  // When the target is reached, half of the position is closed and Stoploss is transferred to the breakeven.
                  if(m_position.Volume()>=m_symbol.LotsMin()*2.0)
                    {
                     double lot=LotCheck(m_position.Volume()/2.0);
                     if(lot!=0.0)
                       {
                        m_trade.PositionClosePartial(m_position.Ticket(),lot);
                        m_trade.PositionModify(m_position.Ticket(),m_position.PriceOpen(),m_position.TakeProfit());
                        continue;
                       }
                    }
                 }
               if(m_position.PriceOpen()==m_position.StopLoss())
                  if(sma1_1<close_1-ExtMinIndentation)
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     DebugBreak();
                    }
              }
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
bool RefreshRates()
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
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=m_symbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=m_symbol.LotsStep();
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=m_symbol.LotsMin();
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=m_symbol.LotsMax();
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+ 
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0;
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0) time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
//| Calculate positions Buy and Sell                                 |
//+------------------------------------------------------------------+
void CalculatePositions(int &count_buys,int &count_sells)
  {
   count_buys=0.0;
   count_sells=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               count_buys++;

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               count_sells++;
           }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMACD                               |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iMACDGet(const int buffer,const int index)
  {
   double MACD[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMACD,buffer,index,1,MACD)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MACD[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMACD                               |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
bool iMACDGet(const int buffer,int start_pos,int count,double &arr_buffer[])
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index 
   int result=CopyBuffer(handle_iMACD,buffer,start_pos,count,arr_buffer);
   if(result<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      return(false);
     }
   if(result<count)
     {
      //--- if copied less
      PrintFormat("It was ordered %d, received only %d",count,result);
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(int handle_iMA,const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+ 
//| Get Close for specified bar index                                | 
//+------------------------------------------------------------------+ 
double iClose(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   double Close[1];
   double close=0;
   int copied=CopyClose(symbol,timeframe,index,1,Close);
   if(copied>0) close=Close[0];
   return(close);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iADX                                |
//|  the buffer numbers are the following:                           |
//|    0 - MAIN_LINE, 1 - PLUSDI_LINE, 2 - MINUSDI_LINE              |
//+------------------------------------------------------------------+
double iADXGet(const int buffer,const int index)
  {
   double ADX[];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iADXBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iADX,buffer,index,1,ADX)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iADX indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(ADX[index]);
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
      return(0.0);
   if(count<=0)
      count=Bars(symbol,timeframe);
   double Low[];
   int result=CopyLow(symbol,timeframe,start,count,Low);
   if(result==-1)
      return(0.0);
   if(count!=WHOLE_ARRAY && result<count)
      return(0.0);
   if(type==MODE_LOW)
     {
      int min=ArrayMinimum(Low);
      return(Low[min]);
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
      return(0.0);
   if(count<=0)
      count=Bars(symbol,timeframe);
   double High[];
   int result=CopyHigh(symbol,timeframe,start,count,High);
   if(result==-1)
      return(0.0);
   if(count!=WHOLE_ARRAY && result<count)
      return(0.0);
   if(type==MODE_HIGH)
     {
      int max=ArrayMaximum(High);
      return(High[max]);
     }
//---
   return(0.0);
  }
//+------------------------------------------------------------------+
