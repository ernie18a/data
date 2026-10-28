//+------------------------------------------------------------------+
//|                                           MACD Four Colors 2.mq5 |
//|                              Copyright © 2020, Vladimir Karputov |
//|                     https://www.mql5.com/ru/market/product/43161 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2020, Vladimir Karputov"
#property link      "https://www.mql5.com/ru/market/product/43161"
#property version   "2.000"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot MACD
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrSilver,clrRed,clrBlue,clrOrange,clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3
//--- plot Signal
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_DOT
#property indicator_width2  1
//+------------------------------------------------------------------+
//| Enum Color Scheme                                                |
//+------------------------------------------------------------------+
enum COLOR_SCHEME
  {
   old_scheme=0,  // Old
   new_scheme=1,  // New
  };
//--- input parameters
input group             "MACD"
input int                  Inp_MACD_fast_ema_period= 12;          // MACD: period for Fast average calculation
input int                  Inp_MACD_slow_ema_period= 26;          // MACD: period for Slow average calculation
input int                  Inp_MACD_signal_period  = 9;           // MACD: period for their difference averaging
input ENUM_APPLIED_PRICE   Inp_MACD_applied_price  = PRICE_CLOSE; // MACD: type of price
input COLOR_SCHEME         InpColorSheme           = new_scheme;  // Color Scheme:
//--- indicator buffers
double   MACDBuffer[];
double   MACDColors[];
double   SignalBuffer[];
//---
int      handle_iMACD;        // variable for storing the handle of the iMACD indicator
int      bars_calculated=0;   // we will keep the number of values in the Moving Averages Convergence/Divergence indicator
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MACDBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,MACDColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,SignalBuffer,INDICATOR_DATA);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,Inp_MACD_signal_period-1);
//--- name for indicator subwindow label
   string color_scheme=(InpColorSheme==old_scheme)?"Old":"New";
   string short_name=StringFormat("MACD(%d,%d,%d) cheme %s",Inp_MACD_fast_ema_period,Inp_MACD_slow_ema_period,Inp_MACD_signal_period,color_scheme);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- create handle of the indicator iMACD
   handle_iMACD=iMACD(Symbol(),Period(),Inp_MACD_fast_ema_period,Inp_MACD_slow_ema_period,
                      Inp_MACD_signal_period,Inp_MACD_applied_price);
//--- if the handle is not created
   if(handle_iMACD==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      return(INIT_FAILED);
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
//--- number of values copied from the iMACD indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated=BarsCalculated(handle_iMACD);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iMACD indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the MACDBuffer array is greater than the number of values in the iMACD indicator for symbol/period, then we don't copy everything
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
//--- fill the arrays with values of the iMACD indicator
//--- if FillArraysFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArraysFromBuffers(MACDBuffer,SignalBuffer,handle_iMACD,values_to_copy))
      return(0);
//--- memorize the number of values in the Moving Averages indicator Convergence/Divergence
   bars_calculated=calculated;
//--- main loop
   int limit=prev_calculated-1;
   if(prev_calculated==0)
     {
      limit=0;
      if(InpColorSheme==new_scheme)
        {
         MACDColors[0]=0.0;
         limit=1;
        }
     }
   for(int i=limit; i<rates_total; i++)
     {
      MACDColors[i]=0.0;
      if(InpColorSheme==old_scheme)
        {
         if(MACDBuffer[i]>SignalBuffer[i] && MACDBuffer[i]<0.0)
            MACDColors[i]=1.0;
         else
            if(MACDBuffer[i]>SignalBuffer[i] && MACDBuffer[i]>0.0)
               MACDColors[i]=2.0;
            else
               if(MACDBuffer[i]<SignalBuffer[i] && MACDBuffer[i]>0.0)
                  MACDColors[i]=3.0;
               else
                  if(MACDBuffer[i]<SignalBuffer[i] && MACDBuffer[i]<0.0)
                     MACDColors[i]=4.0;
        }
      else
        {
         /*
          'MACD' > previous MACD && 'MACD' < 0.0 -> 'Color'=1.0
          'MACD' > previous MACD && 'MACD' > 0.0 -> 'Color'=2.0
          'MACD' < previous MACD && 'MACD' > 0.0 -> 'Color'=3.0
          'MACD' < previous MACD && 'MACD' < 0.0 -> 'Color'=4.0
         */
         if(InpColorSheme==new_scheme)
           {
            if(MACDBuffer[i]>MACDBuffer[i-1] && MACDBuffer[i]<0.0)
               MACDColors[i]=1.0;
            else
               if(MACDBuffer[i]>MACDBuffer[i-1] && MACDBuffer[i]>0.0)
                  MACDColors[i]=2.0;
               else
                  if(MACDBuffer[i]<MACDBuffer[i-1] && MACDBuffer[i]>0.0)
                     MACDColors[i]=3.0;
                  else
                     if(MACDBuffer[i]<MACDBuffer[i-1] && MACDBuffer[i]<0.0)
                        MACDColors[i]=4.0;
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the iMACD indicator               |
//+------------------------------------------------------------------+
bool FillArraysFromBuffers(double &macd_buffer[],    // indicator buffer of MACD values
                           double &signal_buffer[],  // indicator buffer of the signal line of MACD
                           int ind_handle,           // handle of the iMACD indicator
                           int amount                // number of copied values
                          )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,0,amount,macd_buffer)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
//--- fill a part of the SignalBuffer array with values from the indicator buffer that has index 1
   if(CopyBuffer(ind_handle,1,0,amount,signal_buffer)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
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
   if(handle_iMACD!=INVALID_HANDLE)
      IndicatorRelease(handle_iMACD);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
