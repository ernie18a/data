//+------------------------------------------------------------------+
//|                                              Two iMA Formula.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.004"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot Two iMA Formula
#property indicator_label1  "Two iMA Formula"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellowGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//+------------------------------------------------------------------+
//| Enum Formula                                                     |
//+------------------------------------------------------------------+
enum ENUM_FORMULA
  {
   f_0=0,   // Fast-Slow
   f_1=1,   // Fast/Slow
   f_2=2,   // (Fast-Slow)/Slow
  };
//--- input parameters
input group             "Fast MA"
input int                  Inp_MA_Fast_ma_period      = 9;              // MA Fast: averaging period
input int                  Inp_MA_Fast_ma_shift       = 0;              // MA Fast: horizontal shift
input ENUM_MA_METHOD       Inp_MA_Fast_ma_method      = MODE_SMA;       // MA Fast: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_Fast_applied_price  = PRICE_CLOSE;    // MA Fast: type of price
input group             "Slow MA"
input int                  Inp_MA_Slow_ma_period      = 26;             // MA Slow: averaging period
input int                  Inp_MA_Slow_ma_shift       = 0;              // MA Slow: horizontal shift
input ENUM_MA_METHOD       Inp_MA_Slow_ma_method      = MODE_SMA;       // MA Slow: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_Slow_applied_price  = PRICE_CLOSE;    // MA Slow: type of price
input group             "Formula"
input ENUM_FORMULA         InpFormula                 = f_0;            // Formula:
//--- indicator buffers
double   Two_iMA_Buffer[];
double   FastBuffer[];
double   SlowBuffer[];
//---
int      handle_iMA_Fast;              // variable for storing the handle of the iMA indicator
int      handle_iMA_Slow;              // variable for storing the handle of the iMA indicator
//---
int      bars_calculated   = 0;        // we will keep the number of values in the Moving Average indicator
bool     m_init_error      = false;    // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,Two_iMA_Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,FastBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,SlowBuffer,INDICATOR_CALCULATIONS);
//--- create handle of the indicator iMA
   handle_iMA_Fast=iMA(Symbol(),Period(),Inp_MA_Fast_ma_period,Inp_MA_Fast_ma_shift,
                       Inp_MA_Fast_ma_method,Inp_MA_Fast_applied_price);
//--- if the handle is not created
   if(handle_iMA_Fast==INVALID_HANDLE)
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
   handle_iMA_Slow=iMA(Symbol(),Period(),Inp_MA_Slow_ma_period,Inp_MA_Slow_ma_shift,
                       Inp_MA_Slow_ma_method,Inp_MA_Slow_applied_price);
//--- if the handle is not created
   if(handle_iMA_Slow==INVALID_HANDLE)
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
//--- Fast
   string mode_fast;
   switch(Inp_MA_Fast_ma_method)
     {
      case MODE_EMA :
         mode_fast="EMA";
         break;
      case MODE_LWMA :
         mode_fast="LWMA";
         break;
      case MODE_SMA :
         mode_fast="SMA";
         break;
      case MODE_SMMA :
         mode_fast="SMMA";
         break;
      default :
         mode_fast="unknown mode";
     }
   string price_fast=StringSubstr(EnumToString(Inp_MA_Fast_applied_price),6,-1);
//--- Slow
   string mode_slow;
   switch(Inp_MA_Slow_ma_method)
     {
      case MODE_EMA :
         mode_slow="EMA";
         break;
      case MODE_LWMA :
         mode_slow="LWMA";
         break;
      case MODE_SMA :
         mode_slow="SMA";
         break;
      case MODE_SMMA :
         mode_slow="SMMA";
         break;
      default :
         mode_slow="unknown mode";
     }
   string price_slow=StringSubstr(EnumToString(Inp_MA_Fast_applied_price),6,-1);
//--- Formula
   string mode_formula;
   switch(InpFormula)
     {
      case f_0 :
         mode_formula="Fast-Slow";
         PlotIndexSetString(0,PLOT_LABEL,"Fast-Slow");
         break;
      case f_1 :
         mode_formula="Fast/Slow";
         PlotIndexSetString(0,PLOT_LABEL,"Fast/Slow");
         break;
      default :
         mode_formula="(Fast-Slow)/Slow";
         PlotIndexSetString(0,PLOT_LABEL,"(Fast-Slow)/Slow");
     }
//--- name for indicator subwindow label
   string short_name=StringFormat("Two iMA Formula(%d,%d,%s,%s)(%d,%d,%s,%s)(%s)",
                                  Inp_MA_Fast_ma_period,Inp_MA_Fast_ma_shift,mode_fast,price_fast,
                                  Inp_MA_Slow_ma_period,Inp_MA_Slow_ma_shift,mode_slow,price_slow,
                                  EnumToString(InpFormula));
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
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
   if(m_init_error)
      return(0);
//--- number of values copied from the iMA indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated_fast=BarsCalculated(handle_iMA_Fast);
   if(calculated_fast<=0)
     {
      PrintFormat("BarsCalculated(handle_iMA_Fast) returned %d, error code %d",calculated_fast,GetLastError());
      return(0);
     }
   int calculated_slow=BarsCalculated(handle_iMA_Slow);
   if(calculated_slow<=0)
     {
      PrintFormat("BarsCalculated(handle_iMA_Slow) returned %d, error code %d",calculated_slow,GetLastError());
      return(0);
     }
   if(calculated_fast!=calculated_slow)
     {
      PrintFormat("BarsCalculated(handle_iMA_Fast) returned %d, BarsCalculated(handle_iMA_Slow) returned %d",calculated_fast,calculated_slow);
      return(0);
     }
   int calculated=calculated_fast;
//--- if it is the first start of calculation of the indicator or if the number of values in the iMA indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iMABuffer array is greater than the number of values in the iMA indicator for symbol/period, then we don't copy everything
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
   if(!FillArrayFromBuffer(FastBuffer,Inp_MA_Fast_ma_shift,handle_iMA_Fast,values_to_copy))
      return(0);
   if(!FillArrayFromBuffer(SlowBuffer,Inp_MA_Slow_ma_shift,handle_iMA_Slow,values_to_copy))
      return(0);
//--- memorize the number of values in the Moving Average indicator
   bars_calculated=calculated;
//--- main loop
   int limit=prev_calculated-1;
   if(prev_calculated==0)
      limit=0;
   for(int i=limit; i<rates_total; i++)
     {
      switch(InpFormula)
        {
         case f_0 :
            Two_iMA_Buffer[i]=FastBuffer[i]-SlowBuffer[i];
            break;
         case f_1 :
           {
            if(SlowBuffer[i]>0.0)
               Two_iMA_Buffer[i]=FastBuffer[i]/SlowBuffer[i];
            else
               Two_iMA_Buffer[i]=0.0;
           }
         break;
         default :
           {
            if(SlowBuffer[i]>0.0)
               Two_iMA_Buffer[i]=(FastBuffer[i]-SlowBuffer[i])/SlowBuffer[i];
            else
               Two_iMA_Buffer[i]=0.0;
           }
        }
     }
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
   Print(__FUNCTION__,", IN");
   int windows_total=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
   for(int i=windows_total-1; i>=0; i--)
     {
      for(int j=ChartIndicatorsTotal(0,i)-1; j>=0; j--)
        {
         string name=ChartIndicatorName(0,i,j);
         Print("windows #:",i,", indicator short name '",name,"'");
         if(name=="MA("+IntegerToString(Inp_MA_Fast_ma_period)+")" || name=="MA("+IntegerToString(Inp_MA_Slow_ma_period)+")")
            ChartIndicatorDelete(0,i,name);
        }
     }
//---
   if(handle_iMA_Fast!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA_Fast);
   if(handle_iMA_Slow!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA_Slow);
  }
//+------------------------------------------------------------------+
