//+------------------------------------------------------------------+
//|                                                    RSI Arrow.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.002"
#property description "The indicator draws the \"Arrow Up\" object when"
#property description "the RSI crosses up the \"Level Up\" level" 
#property description "and draws \"Arrow Down\" object when" 
#property description "the RSI crosses down the \"Level Down\" level" 
#property indicator_chart_window 
#property indicator_buffers 3
#property indicator_plots   2 
//--- plot Arrows 
#property indicator_label1  "RSI Arrow UP" 
#property indicator_type1   DRAW_ARROW 
#property indicator_color1  clrBlue 
#property indicator_width1  1 
#property indicator_label2  "RSI Arrow DOWN" 
#property indicator_type2   DRAW_ARROW 
#property indicator_color2  clrRed 
#property indicator_width2  1 
//--- input parameters
sinput string  _0_="*-*-*-*-*-*";   // Arrows parameters
input double   InpLevelUP=70.0;     // Level Up
input ushort   InpCodeUP=241;       // Symbol code Up
input double   InpLevelDOWN=30.0;   // Level Down
input ushort   InpCodeDOWN=242;     // Symbol code Down
sinput string  _1_="*-*-*-*-*-*";   // RSI parameters
input int                  ma_period=14;                 // period of averaging 
input ENUM_APPLIED_PRICE   applied_price=PRICE_CLOSE;    // type of price 
//--- indicator buffer 
double         ArrowsBufferUP[];
double         ArrowsBufferDOWN[];
double         iRSIBuffer[];
//--- variable for storing the handle of the iRSI indicator 
int    handle;
//--- we will keep the number of values in the Relative Strength Index indicator 
int    bars_calculated=0;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping 
   SetIndexBuffer(0,ArrowsBufferUP,INDICATOR_DATA);
   SetIndexBuffer(1,ArrowsBufferDOWN,INDICATOR_DATA);
   SetIndexBuffer(2,iRSIBuffer,INDICATOR_CALCULATIONS);
//--- Define the symbol code for drawing in PLOT_ARROW 
   PlotIndexSetInteger(0,PLOT_ARROW,InpCodeUP);
   PlotIndexSetInteger(1,PLOT_ARROW,InpCodeDOWN);
//--- Set the vertical shift of arrows in pixels 
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-5);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,5);
//--- Set as an empty value 0 
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//--- create handle of the indicator 
   handle=iRSI(Symbol(),Period(),ma_period,applied_price);
//--- if the handle is not created 
   if(handle==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- show the symbol/timeframe the Relative Strength Index indicator is calculated for 
   string short_name=StringFormat("RSI Arrow(%s/%s, %d, %d)",Symbol(),EnumToString(Period()),
                                  ma_period,applied_price);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- normal initialization of the indicator 
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
//--- number of values copied from the iRSI indicator 
   int values_to_copy;
//--- determine the number of values calculated in the indicator 
   int calculated=BarsCalculated(handle);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iRSI indicator changed 
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history) 
   int limit=0;
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
      limit=rates_total-values_to_copy;
     }
//--- fill the array with values of the iRSI indicator 
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation 
   if(!FillArrayFromBuffer(iRSIBuffer,handle,values_to_copy))
      return(0);
//---
   for(int i=limit;i<rates_total;i++)
     {
      if(iRSIBuffer[i]>InpLevelUP)
         ArrowsBufferUP[i]=high[i];
      else
         ArrowsBufferUP[i]=0.0;

      if(iRSIBuffer[i]<InpLevelDOWN)
         ArrowsBufferDOWN[i]=low[i];
      else
         ArrowsBufferDOWN[i]=0.0;
     }
//--- memorize the number of values in the Relative Strength Index indicator 
   bars_calculated=calculated;
//--- return the prev_calculated value for the next call 
   return(rates_total);
  }
//+------------------------------------------------------------------+ 
//| Filling indicator buffers from the iRSI indicator                | 
//+------------------------------------------------------------------+ 
bool FillArrayFromBuffer(double &rsi_buffer[],  // indicator buffer of Relative Strength Index values 
                         int ind_handle,        // handle of the iRSI indicator 
                         int amount             // number of copied values 
                         )
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the iRSIBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(ind_handle,0,0,amount,rsi_buffer)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d",GetLastError());
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
//--- clear the chart after deleting the indicator 
   Comment("");
  }
//+------------------------------------------------------------------+
