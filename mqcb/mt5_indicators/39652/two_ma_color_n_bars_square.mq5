//+------------------------------------------------------------------+
//|                                   Two MA Color N Bars Square.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_separate_window
#property indicator_minimum 1
#property indicator_maximum 4
#property indicator_buffers 6
#property indicator_plots   2
//--- plot MA 0
#property indicator_label1  "MA 0"
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  clrYellowGreen,clrBlue,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot MA 1
#property indicator_label2  "MA 1"
#property indicator_type2   DRAW_COLOR_ARROW
#property indicator_color2  clrYellowGreen,clrBlue,clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input group             "MA 0"
input int                  Inp_MA_0_ma_period      = 12;          // MA 0: averaging period
input int                  Inp_MA_0_ma_shift       = 0;           // MA 0: horizontal shift
input ENUM_MA_METHOD       Inp_MA_0_ma_method      = MODE_SMA;    // MA 0: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_0_applied_price  = PRICE_CLOSE; // MA 0: type of price
input uchar                Inp_MA_0_trend_n_bars   = 3;           // MA 0: trend N Bars
input group             "MA 1"
input int                  Inp_MA_1_ma_period      = 36;          // MA 1: averaging period
input int                  Inp_MA_1_ma_shift       = 0;           // MA 1: horizontal shift
input ENUM_MA_METHOD       Inp_MA_1_ma_method      = MODE_SMA;    // MA 1: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_1_applied_price  = PRICE_CLOSE; // MA 1: type of price
input uchar                Inp_MA_1_trend_n_bars   = 5;           // MA 1: trend N Bars
//--- indicator buffers
double   MA_0_Buffer[];
double   MA_0_Colors[];
double   MA_1_Buffer[];
double   MA_1_Colors[];
double   iMA_0_Buffer[];
double   iMA_1_Buffer[];
//---
int      handle_iMA_0;                          // variable for storing the handle of the iMA indicator
int      handle_iMA_1;                          // variable for storing the handle of the iMA indicator
int      bars_calculated   = 0;                 // we will keep the number of values in the Moving Average indicator
int      m_min_bars        = 0;
bool     m_init_error      = false;             // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MA_0_Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,MA_0_Colors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,MA_1_Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,MA_1_Colors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,iMA_0_Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,iMA_1_Buffer,INDICATOR_CALCULATIONS);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- set maximum and minimum for subwindow
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,3);
//--- set shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Inp_MA_0_ma_shift);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,110);
   PlotIndexSetInteger(1,PLOT_ARROW,110);
//--- create handle of the indicator iMA
   handle_iMA_0=iMA(Symbol(),Period(),Inp_MA_0_ma_period,Inp_MA_0_ma_shift,
                    Inp_MA_0_ma_method,Inp_MA_0_applied_price);
//--- if the handle is not created
   if(handle_iMA_0==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator ('0') for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iMA
   handle_iMA_1=iMA(Symbol(),Period(),Inp_MA_1_ma_period,Inp_MA_1_ma_shift,
                    Inp_MA_1_ma_method,Inp_MA_1_applied_price);
//--- if the handle is not created
   if(handle_iMA_1==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator ('1') for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- show the symbol/timeframe the Moving Average indicator is calculated for
   string plot_0_label=StringFormat("MA 0(%d, %d, %s, %s, %d)",
                                    Inp_MA_0_ma_period, Inp_MA_0_ma_shift,StringSubstr(EnumToString(Inp_MA_0_ma_method),5,-1),
                                    StringSubstr(EnumToString(Inp_MA_0_applied_price),6,-1),Inp_MA_0_trend_n_bars);
   string plot_1_label=StringFormat("MA 1(%d, %d, %s, %s, %d)",
                                    Inp_MA_1_ma_period, Inp_MA_1_ma_shift,StringSubstr(EnumToString(Inp_MA_1_ma_method),5,-1),
                                    StringSubstr(EnumToString(Inp_MA_1_applied_price),6,-1),Inp_MA_1_trend_n_bars);
   PlotIndexSetString(0,PLOT_LABEL,plot_0_label);
   PlotIndexSetString(1,PLOT_LABEL,plot_1_label);
//---
   m_min_bars=Inp_MA_0_ma_period+Inp_MA_0_ma_shift+Inp_MA_0_trend_n_bars;
   if(m_min_bars<Inp_MA_1_ma_period+Inp_MA_1_ma_shift+Inp_MA_1_trend_n_bars)
      m_min_bars=Inp_MA_1_ma_period+Inp_MA_1_ma_shift+Inp_MA_1_trend_n_bars;
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
   if(rates_total<=m_min_bars)
      return(0);
//---
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated_0=BarsCalculated(handle_iMA_0);
   if(calculated_0<=0)
     {
      PrintFormat("BarsCalculated(handle_iMA_0) returned %d, error code %d",calculated_0,GetLastError());
      return(0);
     }
   int calculated_1=BarsCalculated(handle_iMA_1);
   if(calculated_1<=0)
     {
      PrintFormat("BarsCalculated(handle_iMA_1) returned %d, error code %d",calculated_1,GetLastError());
      return(0);
     }
   if(calculated_0!=calculated_1)
     {
      PrintFormat("BarsCalculated(handle_iMA_0) returned %d, BarsCalculated(handle_iMA_1) returned %d",calculated_0,calculated_1);
      return(0);
     }
   int calculated=calculated_0;
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
   if(!FillArrayFromBuffer(iMA_0_Buffer,Inp_MA_0_ma_shift,handle_iMA_0,values_to_copy))
      return(0);
   if(!FillArrayFromBuffer(iMA_1_Buffer,Inp_MA_1_ma_shift,handle_iMA_1,values_to_copy))
      return(0);
//--- memorize the number of values in the Moving Average indicator
   bars_calculated=calculated;
//--- main loop
   int limit=prev_calculated-1;
   if(prev_calculated==0)
     {
      limit=m_min_bars;
      for(int i=0; i<limit; i++)
        {
         MA_0_Colors[i]=0.0;
         MA_1_Colors[i]=0.0;
        }
     }
   for(int i=limit; i<rates_total; i++)
     {
      MA_0_Buffer[i]=1.0;
      MA_1_Buffer[i]=2.0;
      //--- MA 0
      int trend_0=0;
      for(int j=i-Inp_MA_0_trend_n_bars; j<i; j++)
        {
         if(iMA_0_Buffer[j]<iMA_0_Buffer[j+1])
            trend_0++;
         else
            trend_0--;
        }
      if(trend_0==Inp_MA_0_trend_n_bars)
         MA_0_Colors[i]=1;
      else
         if(-trend_0==Inp_MA_0_trend_n_bars)
            MA_0_Colors[i]=2;
         else
            MA_0_Colors[i]=0;
      //--- MA 1
      int trend_1=0;
      for(int j=i-Inp_MA_1_trend_n_bars; j<i; j++)
        {
         if(iMA_1_Buffer[j]<iMA_1_Buffer[j+1])
            trend_1++;
         else
            trend_1--;
        }
      if(trend_1==Inp_MA_1_trend_n_bars)
         MA_1_Colors[i]=1;
      else
         if(-trend_1==Inp_MA_1_trend_n_bars)
            MA_1_Colors[i]=2;
         else
            MA_1_Colors[i]=0;
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
   if(handle_iMA_0!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA_0);
  }
//+------------------------------------------------------------------+
