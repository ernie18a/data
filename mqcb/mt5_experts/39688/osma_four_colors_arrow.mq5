//+------------------------------------------------------------------+
//|                                       OsMA Four Colors Arrow.mq5 |
//|                              Copyright © 2021, Vladimir Karputov |
//|                     https://www.mql5.com/ru/market/product/43161 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Vladimir Karputov"
#property link      "https://www.mql5.com/ru/market/product/43161"
#property version   "1.000"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2
//--- plot Buy
#property indicator_label1  "Buy"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Sell
#property indicator_label2  "Sell"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input group             "OsMA"
input int                  Inp_OsMA_fast_ema_period   = 12;          // OsMA: period for Fast Moving Average
input int                  Inp_OsMA_slow_ema_period   = 26;          // OsMA: period for Slow Moving Average
input int                  Inp_OsMA_signal_period     = 9;           // OsMA: averaging period for their difference
input ENUM_APPLIED_PRICE   Inp_OsMA_applied_price     = PRICE_CLOSE; // OsMA: type of price
input group             "Arrows"
input uchar                InpBuyArrowCode            = 228;         // Arrow Buy: code (font Wingdings)
input int                  InpBuyArrowShift           = 10;          // Arrow Buy: vertical shift in pixel
input uchar                InpSellArrowCode           = 230;         // Arrow Sell: code (font Wingdings)
input int                  InpSellArrowShift          = 10;          // Arrow Sell: vertical shift in pixel
//--- indicator buffers
double   BuyBuffer[];
double   SellBuffer[];
double   OsMABuffer[];
double   OsMAColors[];
//---
int      handle_iOsMA;              // variable for storing the handle of the iOsMA indicator
int      bars_calculated   = 0;     // we will keep the number of values in the Moving Average indicator
bool     m_init_error      = false; // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- forced initialization of variables
   m_init_error               = false;    // error on InInit
//--- indicator buffers mapping
   SetIndexBuffer(0,BuyBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,SellBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,OsMABuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,OsMAColors,INDICATOR_CALCULATIONS);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits()+2);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Inp_OsMA_slow_ema_period+Inp_OsMA_signal_period-2);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"OsMA Four Colors Arrow("+string(Inp_OsMA_fast_ema_period)+","+string(Inp_OsMA_slow_ema_period)+","+string(Inp_OsMA_signal_period)+")");
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,InpBuyArrowCode);
   PlotIndexSetInteger(1,PLOT_ARROW,InpSellArrowCode);
//--- set the vertical shift of arrows in pixels
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,InpBuyArrowShift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-InpSellArrowShift);
//--- an empty value for plotting, for which there is no drawing
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- create handle of the indicator iOsMA
   handle_iOsMA=iOsMA(Symbol(),Period(),Inp_OsMA_fast_ema_period,
                      Inp_OsMA_slow_ema_period,Inp_OsMA_signal_period,Inp_OsMA_applied_price);
//--- if the handle is not created
   if(handle_iOsMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create a handle of iOsMA for the pair %s/%s, error code is %d",
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
//--- number of values copied from the iTriX indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated=BarsCalculated(handle_iOsMA);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iOsMA indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the OsMABuffer array is greater than the number of values in the iOsMA indicator for symbol/period, then we don't copy everything
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
//--- fill the arrays with values of the iOsMA indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(OsMABuffer,handle_iOsMA,values_to_copy))
      return(0);
//--- memorize the number of values in the Moving Average of Oscillator indicator
   bars_calculated=calculated;
//--- main loop
   int limit=prev_calculated-1;
   if(prev_calculated==0)
     {
      limit=1;
      OsMAColors[0]=0.0;
     }
   for(int i=limit; i<rates_total; i++)
     {
      OsMAColors[i]=0.0;
      BuyBuffer[i]=EMPTY_VALUE;
      SellBuffer[i]=EMPTY_VALUE;
      /*
       'OsMA' > previous OsMA && 'OsMA' < 0.0 -> 'Color'=1.0
       'OsMA' > previous OsMA && 'OsMA' > 0.0 -> 'Color'=2.0
       'OsMA' < previous OsMA && 'OsMA' > 0.0 -> 'Color'=3.0
       'OsMA' < previous OsMA && 'OsMA' < 0.0 -> 'Color'=4.0
      */
      if(OsMABuffer[i]>OsMABuffer[i-1] && OsMABuffer[i]<0.0)
        {
         OsMAColors[i]=1.0;
         if(OsMAColors[i-1]==4.0)
            BuyBuffer[i]=low[i];
        }
      else
        {
         if(OsMABuffer[i]>OsMABuffer[i-1] && OsMABuffer[i]>0.0)
           {
            OsMAColors[i]=2.0;
           }
         else
           {
            if(OsMABuffer[i]<OsMABuffer[i-1] && OsMABuffer[i]>0.0)
              {
               OsMAColors[i]=3.0;
               if(OsMAColors[i-1]==2.0)
                  SellBuffer[i]=high[i];
              }
            else
              {
               if(OsMABuffer[i]<OsMABuffer[i-1] && OsMABuffer[i]<0.0)
                  OsMAColors[i]=4.0;
              }
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the iTriX indicator               |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &trix_buffer[], // indicator buffer of values of Triple Exponential Moving Averages Oscillator
                         int ind_handle,        // handle of the iTriX indicator
                         int amount             // number of copied values
                        )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iTriXBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,0,amount,trix_buffer)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iTriX indicator, error code %d",GetLastError());
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
   if(handle_iOsMA!=INVALID_HANDLE)
      IndicatorRelease(handle_iOsMA);
  }
//+------------------------------------------------------------------+
