//+------------------------------------------------------------------+
//|                                                  MA AO Arrow.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2
//--- plot BUY
#property indicator_label1  "BUY"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrCornflowerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot SELL
#property indicator_label2  "SELL"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrLightSalmon
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input group             "MA"
input int                  Inp_MA_ma_period        = 36;             // MA: averaging period
input int                  Inp_MA_ma_shift         = 0;              // MA: horizontal shift
input ENUM_MA_METHOD       Inp_MA_ma_method        = MODE_SMA;       // MA: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_applied_price    = PRICE_CLOSE;    // MA: type of price
input group             "Arrows"
input uchar                Inp_BUY_Arrow_Code      = 241;            // Arrow 'BUY': code (font Wingdings)
input int                  Inp_BUY_Arrow_Shift     = 10;             // Arrow 'BUY': vertical shift in pixel
input uchar                Inp_SELL_Arrow_Code     = 242;            // Arrow 'SELL': code (font Wingdings)
input int                  Inp_SELL_Arrow_Shift    = 10;             // Arrow 'SELL': vertical shift in pixel
//--- indicator buffers
double   BUYBuffer[];
double   SELLBuffer[];
double   iMABuffer[];
double   iAOBuffer[];
//---
int      handle_iMA;                   // variable for storing the handle of the iMA indicator
int      handle_iAO;                   // variable for storing the handle of the iAO indicator
//---
int      bars_calculated   = 0;        // we will keep the number of values in the Moving Averages Convergence/Divergence indicator
bool     m_init_error      = false;    // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BUYBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,SELLBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,iMABuffer,INDICATOR_DATA);
   SetIndexBuffer(3,iAOBuffer,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,Inp_BUY_Arrow_Code);
   PlotIndexSetInteger(1,PLOT_ARROW,Inp_SELL_Arrow_Code);
//--- set the vertical shift of arrows in pixels
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,Inp_BUY_Arrow_Shift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-Inp_SELL_Arrow_Shift);
//--- an empty value for plotting, for which there is no drawing
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- create handle of the indicator iMA
   handle_iMA=iMA(Symbol(),Period(),Inp_MA_ma_period,Inp_MA_ma_shift,
                  Inp_MA_ma_method,Inp_MA_applied_price);
//--- if the handle is not created
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator ('Fast') for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early
      m_init_error=true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iAO
   handle_iAO=iAO(Symbol(),Period());
//--- if the handle is not created
   if(handle_iAO==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iAO indicator for the symbol %s/%s, error code %d",
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
   if(rates_total<4)
      return(0);
//--- number of values copied from the iMA indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated_ma=BarsCalculated(handle_iMA);
   if(calculated_ma<=0)
     {
      PrintFormat("BarsCalculated(handle_iMA) returned %d, error code %d",calculated_ma,GetLastError());
      return(0);
     }
   int calculated_ao=BarsCalculated(handle_iAO);
   if(calculated_ao<=0)
     {
      PrintFormat("BarsCalculated(handle_iMA_Medium) returned %d, error code %d",calculated_ao,GetLastError());
      return(0);
     }
//---
   if(calculated_ma!=calculated_ao)
     {
      PrintFormat("BarsCalculated(handle_iMA) returned %d, BarsCalculated(handle_iAO) returned %d",calculated_ma,calculated_ao);
      return(0);
     }
   int calculated=calculated_ma;
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
   if(!FillArrayFromBuffer(iMABuffer,Inp_MA_ma_shift,handle_iMA,values_to_copy))
      return(0);
//--- fill the iAOBuffer array with values from the Awesome Oscillator indicator
//--- if FillArraysFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArraysFromBuffer(iAOBuffer,handle_iAO,values_to_copy))
      return(0);
//--- memorize the number of values in the Moving Average indicator
   bars_calculated=calculated;
//--- main loop
   int limit=rates_total-values_to_copy;
   if(limit<3)
      limit=3;
   for(int i=limit; i<rates_total; i++)
     {
      BUYBuffer[i]=0.0;
      SELLBuffer[i]=0.0;
      //--- Buy Signal
      if(iAOBuffer[i-1]>0.0 && iAOBuffer[i-2]>0.0 && iAOBuffer[i-3]>0.0)
         if(iAOBuffer[i-1]>iAOBuffer[i-2] && iAOBuffer[i-2]<iAOBuffer[i-3])
            if(low[i]>iMABuffer[i])
              {
               BUYBuffer[i]=low[i];
               continue;
              }
      //--- Sell Signal
      if(iAOBuffer[i-1]<0.0 && iAOBuffer[i-2]<0.0 && iAOBuffer[i-3]<0.0)
         if(iAOBuffer[i-1]<iAOBuffer[i-2] && iAOBuffer[i-2]>iAOBuffer[i-3])
            if(high[i]<iMABuffer[i])
              {
               SELLBuffer[i]=high[i];
               continue;
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
//| Filling indicator buffers from the iAO indicator                 |
//+------------------------------------------------------------------+
bool FillArraysFromBuffer(double &values[],        // indicator buffer of Awesome Oscillator values
                          int ind_handle,          // handle of the iAO indicator
                          int amount               // number of copied values
                         )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iAOBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,0,amount,values)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iAO indicator, error code %d",GetLastError());
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
   if(handle_iMA!=INVALID_HANDLE)
      IndicatorRelease(handle_iMA);
   if(handle_iAO!=INVALID_HANDLE)
      IndicatorRelease(handle_iAO);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
