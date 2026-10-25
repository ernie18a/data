//+------------------------------------------------------------------+
//|                                       MACD Four Colors Arrow.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.001"
#property description "New color Scheme"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   2
//--- plot MACD above zero
#property indicator_label1  "MACD above zero"
#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  clrBlue,clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot MACD below zero
#property indicator_label2  "MACD below zero"
#property indicator_type2   DRAW_COLOR_ARROW
#property indicator_color2  clrRed,clrYellow
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input group             "MACD"
input int                  Inp_MACD_fast_ema_period= 12;          // MACD: period for Fast average calculation
input int                  Inp_MACD_slow_ema_period= 26;          // MACD: period for Slow average calculation
input int                  Inp_MACD_signal_period  = 9;           // MACD: period for their difference averaging
input ENUM_APPLIED_PRICE   Inp_MACD_applied_price  = PRICE_CLOSE; // MACD: type of price
input group             "Arrows"
input uchar                InpAboveArrowCode       = 246;         // Arrow 'Above': code (font Wingdings)
input int                  InpAboveArrowShift      = 10;          // Arrow 'Above': vertical shift in pixel
input uchar                InpBelowArrowCode       = 248;         // Arrow 'Below': code (font Wingdings)
input int                  InpBelowArrowShift      = 10;          // Arrow 'Below': vertical shift in pixel
//--- indicator buffers
double   MACDAboveZeroBuffer[];
double   MACDAboveZeroColors[];
double   MACDBelowZeroBuffer[];
double   MACDBelowZeroColors[];
double   MACDBuffer[];
//---
int      handle_iMACD;              // variable for storing the handle of the iMACD indicator
int      bars_calculated   = 0;     // we will keep the number of values in the Moving Averages Convergence/Divergence indicator
bool     m_init_error      = false; // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MACDAboveZeroBuffer);
   SetIndexBuffer(1,MACDAboveZeroColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,MACDBelowZeroBuffer);
   SetIndexBuffer(3,MACDBelowZeroColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,MACDBuffer,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,InpAboveArrowCode);
   PlotIndexSetInteger(1,PLOT_ARROW,InpBelowArrowCode);
//--- set the vertical shift of arrows in pixels
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,InpAboveArrowShift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-InpBelowArrowShift);
//--- an empty value for plotting, for which there is no drawing
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,Inp_MACD_signal_period-1);
//--- name for indicator subwindow label
   string short_name=StringFormat("MACD Four Colors Arrow(%d,%d,%d)",Inp_MACD_fast_ema_period,Inp_MACD_slow_ema_period,Inp_MACD_signal_period);
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
   if(m_init_error)
      return(0);
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
   if(!FillArraysFromBuffers(MACDBuffer,handle_iMACD,values_to_copy))
      return(0);
//--- memorize the number of values in the Moving Averages indicator Convergence/Divergence
   bars_calculated=calculated;
//--- main loop
   int limit=prev_calculated-1;
   if(prev_calculated==0)
     {
      MACDAboveZeroBuffer[0]=0.0;
      MACDAboveZeroColors[0]=0.0;
      MACDBelowZeroBuffer[0]=0.0;
      MACDBelowZeroColors[0]=0.0;
      limit=1;
     }
   for(int i=limit; i<rates_total; i++)
     {
      MACDAboveZeroBuffer[i]=0.0;
      MACDAboveZeroColors[i]=0.0;
      MACDBelowZeroBuffer[i]=0.0;
      MACDBelowZeroColors[i]=0.0;
      /*
       clrSilver,clrRed,clrBlue,clrOrange,clrYellow
       'MACD' > previous MACD && 'MACD' < 0.0 -> 'Color'=1.0
       'MACD' > previous MACD && 'MACD' > 0.0 -> 'Color'=2.0
       'MACD' < previous MACD && 'MACD' > 0.0 -> 'Color'=3.0
       'MACD' < previous MACD && 'MACD' < 0.0 -> 'Color'=4.0
       //--- plot MACD above zero
      #property indicator_label1  "MACD above zero"
      #property indicator_type1   DRAW_COLOR_ARROW
      #property indicator_color1  clrBlue,clrOrange
      #property indicator_style1  STYLE_SOLID
      #property indicator_width1  1
      //--- plot MACD below zero
      #property indicator_label2  "MACD below zero"
      #property indicator_type2   DRAW_COLOR_ARROW
      #property indicator_color2  clrRed,clrYellow
      #property indicator_style2  STYLE_SOLID
      #property indicator_width2  1
      */
      if(MACDBuffer[i]>MACDBuffer[i-1] && MACDBuffer[i]<0.0)
        {
         //MACDColors[i]=1.0;
         MACDBelowZeroBuffer[i]=high[i];
         MACDBelowZeroColors[i]=0.0;
        }
      else
        {
         if(MACDBuffer[i]>MACDBuffer[i-1] && MACDBuffer[i]>0.0)
           {
            //MACDColors[i]=2.0;
            MACDAboveZeroBuffer[i]=low[i];
            MACDAboveZeroColors[i]=0.0;
           }
         else
           {
            if(MACDBuffer[i]<MACDBuffer[i-1] && MACDBuffer[i]>0.0)
              {
               //MACDColors[i]=3.0;
               MACDAboveZeroBuffer[i]=low[i];
               MACDAboveZeroColors[i]=1.0;
              }
            else
              {
               if(MACDBuffer[i]<MACDBuffer[i-1] && MACDBuffer[i]<0.0)
                 {
                  //MACDColors[i]=4.0;
                  MACDBelowZeroBuffer[i]=high[i];
                  MACDBelowZeroColors[i]=1.0;
                 }
              }
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
