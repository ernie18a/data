//+------------------------------------------------------------------+
//|                                             RSI_MAonRSI_Dual.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot RSI Fast
#property indicator_label1  "RSI Fast"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot RSI Slow
#property indicator_label2  "RSI Slow"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLime
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input group             "RSI"
input int                  Inp_RSI_Fast_ma_period  = 5;              // RSI Fast: averaging period
input int                  Inp_RSI_Slow_ma_period  = 15;             // RSI Slow: averaging period
input ENUM_APPLIED_PRICE   Inp_RSI_applied_price   = PRICE_CLOSE;    // RSI: type of price
input color                Inp_RSI_Level_Color     = clrDimGray;     // RSI: Color line Levels
input double               Inp_RSI_Level_Down      = 25.0;           // RSI: Level Down
input double               Inp_RSI_Level_Middle    = 50.0;           // RSI: Level Middle
input double               Inp_RSI_Level_Up        = 75.0;           // RSI: Level Up
input group             "MA"
input int                  Inp_MA_ma_period        = 6;              // MA: averaging period
input ENUM_MA_METHOD       Inp_MA_ma_method        = MODE_SMA;       // MA: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_applied_price    = PRICE_CLOSE;    // MA: type of price
//--- indicator buffers
double   MAonRSI_Fast_Buffer[];
double   MAonRSI_Slow_Buffer[];
//---
int      handle_iMAOnRSI_Fast;            // variable for storing the handle of the iRSI indicator
int      handle_iMAOnRSI_Slow;            // variable for storing the handle of the iRSI indicator
int      handle_iRSI_Fast;                // variable for storing the handle of the iRSI indicator
int      handle_iRSI_Slow;                // variable for storing the handle of the iRSI indicator
int      bars_calculated      = 0;        // we will keep the number of values in the Relative Strength Index indicator
bool     m_init_error         = false;    // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MAonRSI_Fast_Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,MAonRSI_Slow_Buffer,INDICATOR_DATA);
//--- custom parameters
   IndicatorSetInteger(INDICATOR_LEVELS,3);
//---
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,Inp_RSI_Level_Color);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,Inp_RSI_Level_Color);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,Inp_RSI_Level_Color);
//---
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASH);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASH);
//---
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,Inp_RSI_Level_Down);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,Inp_RSI_Level_Middle);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,Inp_RSI_Level_Up);
//--- set maximum and minimum for subwindow
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,100);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI_MAonRSI_Dual("+IntegerToString(Inp_RSI_Fast_ma_period)+","+IntegerToString(Inp_RSI_Slow_ma_period)+")");
//--- create handle of the indicator iRSI
   handle_iRSI_Fast=iRSI(Symbol(),Period(),Inp_RSI_Fast_ma_period,Inp_RSI_applied_price);
//--- if the handle is not created
   if(handle_iRSI_Fast==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iRSI ('Fast') indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iRSI
   handle_iRSI_Slow=iRSI(Symbol(),Period(),Inp_RSI_Slow_ma_period,Inp_RSI_applied_price);
//--- if the handle is not created
   if(handle_iRSI_Slow==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iRSI ('Slow') indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iMA
   handle_iMAOnRSI_Fast=iMA(Symbol(),Period(),Inp_MA_ma_period,0,
                            Inp_MA_ma_method,handle_iRSI_Fast);
//--- if the handle is not created
   if(handle_iMAOnRSI_Fast==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA ('Fast') indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iMA
   handle_iMAOnRSI_Slow=iMA(Symbol(),Period(),Inp_MA_ma_period,0,
                            Inp_MA_ma_method,handle_iRSI_Slow);
//--- if the handle is not created
   if(handle_iMAOnRSI_Slow==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA ('Slow') indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   if(m_init_error)
      return(0);
//--- number of values copied from the iRSI indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated_ma_on_rsi_fast=BarsCalculated(handle_iMAOnRSI_Fast);
   if(calculated_ma_on_rsi_fast<=0)
     {
      PrintFormat("BarsCalculated(handle_iMAOnRSI_Fast) returned %d, error code %d",calculated_ma_on_rsi_fast,GetLastError());
      return(0);
     }
   int calculated_ma_on_rsi_slow=BarsCalculated(handle_iMAOnRSI_Slow);
   if(calculated_ma_on_rsi_slow<=0)
     {
      PrintFormat("BarsCalculated(handle_iMAOnRSI_Slow) returned %d, error code %d",calculated_ma_on_rsi_slow,GetLastError());
      return(0);
     }
   if(calculated_ma_on_rsi_fast!=calculated_ma_on_rsi_slow)
     {
      PrintFormat("BarsCalculated(handle_iMAOnRSI_Fast) returned %d, BarsCalculated(handle_iMAOnRSI_Slow) returned %d",calculated_ma_on_rsi_fast,calculated_ma_on_rsi_slow);
      return(0);
     }
   int calculated=calculated_ma_on_rsi_fast;
//--- if it is the first start of calculation of the indicator or if the number of values in indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iRSIBuffer array is greater than the number of values in the iRSI indicator for symbol/period, then we don't copy everything
      //--- otherwise, we copy less than the size of indicator buffers
      if(calculated>rates_total)
         values_to_copy=rates_total;
      else
         values_to_copy=calculated;
     }
   else
     {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate()
      //--- for calculation not more than one bar is added
      values_to_copy=(rates_total-prev_calculated)+1;
     }
//--- fill the iMABuffer array with values of the Moving Average indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(MAonRSI_Fast_Buffer,0,handle_iMAOnRSI_Fast,values_to_copy))
      return(0);
//--- fill the iMABuffer array with values of the Moving Average indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(MAonRSI_Slow_Buffer,0,handle_iMAOnRSI_Slow,values_to_copy))
      return(0);
//--- memorize the number of values in the Relative Strength Index indicator
   bars_calculated=calculated;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the MA indicator                  |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &values[],   // indicator buffer of Moving Average values
                         int shift,          // shift
                         int ind_handle,     // handle of the iMA indicator
                         int amount          // number of copied values
                        )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,-shift,amount,values)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
//--- everything is fine
   return(true);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(handle_iMAOnRSI_Fast!=INVALID_HANDLE)
      IndicatorRelease(handle_iMAOnRSI_Fast);
   if(handle_iMAOnRSI_Slow!=INVALID_HANDLE)
      IndicatorRelease(handle_iMAOnRSI_Slow);
   if(handle_iRSI_Fast!=INVALID_HANDLE)
      IndicatorRelease(handle_iRSI_Fast);
   if(handle_iRSI_Slow!=INVALID_HANDLE)
      IndicatorRelease(handle_iRSI_Slow);
  }
//+------------------------------------------------------------------+
