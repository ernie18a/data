//+------------------------------------------------------------------+
//|                     MACD Stochastic(barabashkakvn's edition).mq5 |
//|                                                          Mikhail |
//|                                        http://www.landofcash.net |
//+------------------------------------------------------------------+
#property copyright "Mikhail"
#property link      "http://www.landofcash.net"
#property version   "1.002"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input int            Inp_fast_ema_period     = 12;          // MACD: period for Fast average calculation 
input int            Inp_slow_ema_period     = 26;          // MACD: period for Slow average calculation 
input int            Inp_signal_period       = 9;           // MACD: period for their difference averaging 
input bool           Inp_use_Stoch           = false;       // Use Stochastic
input int            Inp_bars_to_check_Stoch = 5;           // Bars to check Stochastic   
input int            InpKperiod              = 5;           // STO: K-period (number of bars for calculations) 
input int            InpDperiod              = 3;           // STO: D-period (period of first smoothing) 
input int            Inp_slowing             = 3;           // STO: final smoothing 
input ENUM_MA_METHOD Inp_ma_method           = MODE_SMA;    // STO: type of smoothing 
input ENUM_STO_PRICE Inp_price_field         = STO_LOWHIGH; // STO: stochastic calculation method 
input double         InpLots                 = 0.1;         // Lots
input ushort         InpStopLoss             = 100;         // Stop Loss (in pips)
input ushort         InpTakeProfit           = 100;         // Take Profit (in pips)
input ushort         InpTrailingStop         = 0;           // Trailing Stop (in pips)
input ushort         InpTrailingStep         = 5;           // Trailing Step (in pips)
input int            InpMaxPositions         = 5;           // Max positions
input ushort         InpNoLossStop           = 1;           // No Loss stop (in pips)
input ushort         InpWhenSetNoLossStop    = 25;          // When set "No Loss stop" (in pips)
input datetime       InpStartPeriod_1=D'2017.10.10 08:15';  // Start period #1 (only hours and minutes are valid)
input datetime       InpEndPeriod_1=D'2017.10.10 08:35';    // End period #1 (only hours and minutes are valid)
input datetime       InpStartPeriod_2=D'2017.10.10 13:45';  // Start period #2 (only hours and minutes are valid)
input datetime       InpEndPeriod_2=D'2017.10.10 14:42';    // End period #2 (only hours and minutes are valid) 
input datetime       InpStartPeriod_3=D'2017.10.10 22:15';  // Start period #3 (only hours and minutes are valid)
input datetime       InpEndPeriod_3=D'2017.10.10 22:45';    // End period #3 (only hours and minutes are valid)
//---
string         _ver=MQLInfoString(MQL_PROGRAM_NAME);
ulong          m_magic=8889;                 // magic number
ulong          m_slippage=10;                // slippage
datetime       _lastRun=0;
datetime       _lastTimeOpenBar_0=0;
bool           _isFirstTick=false;
//---
double ExtStopLoss=0.0;
double ExtTakeProfit=0.0;
double ExtTrailingStop=0.0;
double ExtTrailingStep=0.0;
double ExtNoLossStop=0.0;
double ExtWhenSetNoLossStop=0.0;

int    handle_iMACD;                         // variable for storing the handle of the iMACD indicator 
int    handle_iStochastic;                   // variable for storing the handle of the iStochastic indicator 

ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
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

   ExtStopLoss=InpStopLoss*m_adjusted_point;
   ExtTakeProfit=InpTakeProfit*m_adjusted_point;
   ExtTrailingStop=InpTrailingStop*m_adjusted_point;
   ExtTrailingStep=InpTrailingStep*m_adjusted_point;
   ExtNoLossStop=InpNoLossStop*m_adjusted_point;
   ExtWhenSetNoLossStop=InpWhenSetNoLossStop*m_adjusted_point;

//--- create handle of the indicator iMACD
   handle_iMACD=iMACD(m_symbol.Name(),Period(),Inp_fast_ema_period,Inp_slow_ema_period,Inp_signal_period,PRICE_CLOSE);
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
//--- create handle of the indicator iStochastic
   handle_iStochastic=iStochastic(m_symbol.Name(),Period(),InpKperiod,InpDperiod,Inp_slowing,Inp_ma_method,Inp_price_field);
//--- if the handle is not created 
   if(handle_iStochastic==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iStochastic indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
   if(InpNoLossStop>=InpWhenSetNoLossStop)
     {
      Print("\"No Loss stop\" can not be >= \"When set \"No Loss stop\"\"");
      return(INIT_PARAMETERS_INCORRECT);
     }
   Print(_ver+" Started at "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES));
   Comment(_ver+" Started at "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES));
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(TimeCurrent()-_lastRun>PeriodSeconds())
     {
      _lastRun=iTime(0);
      Print("BarOpen:"+TimeToString(_lastRun,TIME_DATE|TIME_SECONDS)+" Current time:"+TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
      _isFirstTick=true;
     }
   else
      _isFirstTick=false;

   ENUM_POSITION_TYPE needOpenType=-1;
   int positions_number=CalculateAllPositions();
   if(positions_number>0)
      Trailing();

   if(positions_number<InpMaxPositions && _lastTimeOpenBar_0<iTime(0))
     {
      needOpenType=NeedOpenType();
      if(needOpenType==POSITION_TYPE_BUY || needOpenType==POSITION_TYPE_SELL)
         if(!RefreshRates())
            return;
      if(needOpenType==POSITION_TYPE_BUY)
        {
         if(isGoodTime(InpStartPeriod_1,InpEndPeriod_1) || 
            isGoodTime(InpStartPeriod_2,InpEndPeriod_2) || 
            isGoodTime(InpStartPeriod_3,InpEndPeriod_3))
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Ask()-ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Ask()+ExtTakeProfit;
            if(OpenBuy(sl,tp))
               _lastTimeOpenBar_0=iTime(0);
           }
        }
      if(needOpenType==POSITION_TYPE_SELL)
        {
         if(isGoodTime(InpStartPeriod_1,InpEndPeriod_1) || 
            isGoodTime(InpStartPeriod_2,InpEndPeriod_2) || 
            isGoodTime(InpStartPeriod_3,InpEndPeriod_3))
           {
            double sl=(InpStopLoss==0)?0.0:m_symbol.Bid()+ExtStopLoss;
            double tp=(InpTakeProfit==0)?0.0:m_symbol.Bid()-ExtTakeProfit;
            if(OpenSell(sl,tp))
               _lastTimeOpenBar_0=iTime(0);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Check Stochastic                                                 |
//+------------------------------------------------------------------+
bool CheckStoch(ENUM_POSITION_TYPE PositionType)
  {
   double mainCurrent   = iStochasticGet(MAIN_LINE,0);
   double signalCurrent = iStochasticGet(SIGNAL_LINE,0);
   double main=0.0;
   double signal=0.0;
   if(signalCurrent<mainCurrent && PositionType==POSITION_TYPE_BUY)
     {
      for(int i=1;i<Inp_bars_to_check_Stoch;i++)
        {
         main  = iStochasticGet(MAIN_LINE,i);
         signal= iStochasticGet(SIGNAL_LINE,i);
        }
      if(signal>main)
         return (true);
     }
//---
   if(signalCurrent>mainCurrent && PositionType==POSITION_TYPE_SELL)
     {
      for(int i=1;i<Inp_bars_to_check_Stoch;i++)
        {
         main  = iStochasticGet(MAIN_LINE,i);
         signal= iStochasticGet(SIGNAL_LINE,i);
        }
      if(signal<main)
         return (true);
     }
//---
   return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_POSITION_TYPE NeedOpenType()
  {
   double macdMain=iMACDGet(MAIN_LINE,0);
   double macdSignal=iMACDGet(SIGNAL_LINE,0);
   double macdMainPrev=iMACDGet(MAIN_LINE,1);
   double macdSignalPrev=iMACDGet(SIGNAL_LINE,1);
   if(macdMain>macdSignal && macdMainPrev<=macdSignalPrev && macdMain<0 && macdMainPrev<0)
     {
      if(!Inp_use_Stoch || CheckStoch(POSITION_TYPE_BUY))
         return(POSITION_TYPE_BUY);
     }
   if(macdMain<macdSignal && macdMainPrev>=macdSignalPrev && macdMain>0 && macdMainPrev>0)
     {
      if(!Inp_use_Stoch || CheckStoch(POSITION_TYPE_SELL))
         return(POSITION_TYPE_SELL);
     }
   return (-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isGoodTime(datetime startAllowedDayTime,datetime endAllowedDayTime)
  {
   bool goodDay=true;
   bool goodTime=false;
   bool goodMinute=true;
   MqlDateTime str_current;
   MqlDateTime str_start;
   MqlDateTime str_end;
   TimeToStruct(TimeCurrent(),str_current);
   TimeToStruct(startAllowedDayTime,str_start);
   TimeToStruct(endAllowedDayTime,str_end);
   if(goodDay)
     {
      //if hour greater or less STRICT!!!
      if(str_current.hour>str_start.hour && str_current.hour<str_end.hour)
         goodTime=true;
      //if Hour is equal to Start hour then compare start minute
      if(str_current.hour==str_start.hour)
        {
         goodTime=true;
         if(str_current.min>=str_start.min)
            goodMinute=goodMinute && true;
         else
            goodMinute=goodMinute && false;
        }
      //if Hour is equal to End hour then compare end minute
      if(str_current.hour==str_end.hour)
        {
         goodTime=true;
         if(str_current.min<=str_end.min)
            goodMinute=goodMinute && true;
         else
            goodMinute=goodMinute && false;
        }
     }
   if(!(goodDay && goodTime && goodMinute) && _isFirstTick)
     {
      Print("GoodTime false. TimeCurrent:"+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES)
            +" _startAllowedDayTime:"+TimeToString(startAllowedDayTime,TIME_DATE|TIME_MINUTES)
            +" _endAllowedDayTime"+TimeToString(endAllowedDayTime,TIME_DATE|TIME_MINUTES)
            +" goodDay:"+goodDay+" goodTime:"+goodTime);
     }
   return (goodDay&&goodTime&&goodMinute);
  }
//+------------------------------------------------------------------+
//| Trailing                                                         |
//+------------------------------------------------------------------+
void Trailing()
  {
   if(ExtTrailingStop==0)
      return;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtWhenSetNoLossStop)
                 {
                  double sl=m_position.StopLoss()+ExtTrailingStop;
                  if(m_position.PriceCurrent()-ExtTrailingStep-ExtTrailingStop>sl && sl>m_position.PriceOpen()+ExtNoLossStop)
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(sl),
                        m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtWhenSetNoLossStop)
                 {
                  if(m_position.StopLoss()!=0.0)
                    {
                     double sl=m_position.StopLoss()-ExtTrailingStop;
                     if(m_position.PriceCurrent()+ExtTrailingStep+ExtTrailingStop<sl && sl<m_position.PriceOpen()-ExtNoLossStop)
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(sl),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
                  else
                    {
                     double sl=m_position.PriceOpen()-ExtNoLossStop;
                     if(m_position.PriceCurrent()+ExtWhenSetNoLossStop<sl)
                        if(!m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(sl),
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
                 }
              }

           }
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
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
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
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0;
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0) time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
//| Calculate all positions                                          |
//+------------------------------------------------------------------+
int CalculateAllPositions()
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;
//---
   return(total);
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
//| Get value of buffers for the iStochastic                         |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iStochasticGet(const int buffer,const int index)
  {
   double Stochastic[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iStochasticBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iStochastic,buffer,index,1,Stochastic)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iStochastic indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(Stochastic[0]);
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
         if(m_trade.Buy(InpLots,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
               return(false);
              }
            else
              {
               Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
               return(true);
              }
           }
         else
           {
            Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
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
         if(m_trade.Sell(InpLots,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
               return(false);
              }
            else
              {
               Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
               return(true);
              }
           }
         else
           {
            Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
            return(false);
           }
        }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResult(CTrade &trade,CSymbolInfo &symbol)
  {
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result: "+trade.ResultRetcodeDescription());
   Print("deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("current bid price: "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("current ask price: "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("broker comment: "+trade.ResultComment());
   DebugBreak();
  }
//+------------------------------------------------------------------+
