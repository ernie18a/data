//+------------------------------------------------------------------+
//|                                                AMA Histogram.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.001"
#property indicator_separate_window
#property indicator_buffers 2 
#property indicator_plots   1 
//--- plot iAMA 
#property indicator_label1  "iAMA" 
#property indicator_type1   DRAW_HISTOGRAM 
#property indicator_color1  clrBlueViolet 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
//+------------------------------------------------------------------+ 
//| Enumeration of the methods of handle creation                    | 
//+------------------------------------------------------------------+ 
//--- input parameters 
input int                  ama_period=15;             // period of calculation 
input int                  fast_ma_period=2;          // period of fast MA 
input int                  slow_ma_period=30;         // period of slow MA 
input int                  ama_shift=0;               // horizontal shift 
input ENUM_APPLIED_PRICE   applied_price=PRICE_CLOSE; // type of price 
//--- indicator buffers
double         iAMABuffer[];
double         iAMABufferTemp[];
//--- variable for storing the handle of the iAMA indicator 
int    handle;
//--- variable for storing 
string name=Symbol();
//--- name of the indicator on a chart 
string short_name;
//--- we will keep the number of values in the Adaptive Moving Average indicator 
int    bars_calculated=0;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping 
   SetIndexBuffer(0,iAMABuffer,INDICATOR_DATA);
   SetIndexBuffer(1,iAMABufferTemp,INDICATOR_CALCULATIONS);
//--- set shift 
   PlotIndexSetInteger(0,PLOT_SHIFT,ama_shift);
//--- determine the symbol the indicator is drawn for 
   name=Symbol();
//--- delete spaces to the right and to the left 
   StringTrimRight(name);
   StringTrimLeft(name);
//--- if it results in zero length of the 'name' string 
   if(StringLen(name)==0)
     {
      //--- take the symbol of the chart the indicator is attached to 
      name=_Symbol;
     }
//--- create handle of the indicator 
   handle=iAMA(name,Period(),ama_period,fast_ma_period,slow_ma_period,ama_shift,applied_price);
//--- if the handle is not created 
   if(handle==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iAMA indicator for the symbol %s/%s, error code %d",
                  name,
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- show the symbol/timeframe the Adaptive Moving Average indicator is calculated for 
   short_name=StringFormat("AMA Histogram (%d,%d,%d)",ama_period,fast_ma_period,slow_ma_period);
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
//--- number of values copied from the iAMA indicator 
   int values_to_copy;
//--- determine the number of values calculated in the indicator 
   int calculated=BarsCalculated(handle);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iAMA indicator changed 
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history) 
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iAMABuffer array is greater than the number of values in the iAMA indicator for symbol/period, then we don't copy everything  
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
//--- fill the arrays with values of the Adaptive Moving Average indicator 
//--- if FillArraysFromBuffer returns false, it means the information is nor ready yet, quit operation 
   if(!FillArrayFromBuffer(iAMABufferTemp,ama_shift,handle,values_to_copy))
      return(0);
//--- memorize the number of values in the Adaptive Moving Average indicator 
   bars_calculated=calculated;
   int limit=prev_calculated-1;
   if(limit<0)
      limit=0;
   for(int i=limit;i<rates_total;i++)
      iAMABuffer[i]=close[i]-iAMABufferTemp[i];
//--- return the prev_calculated value for the next call 
   return(rates_total);
  }
//+------------------------------------------------------------------+ 
//| Filling indicator buffer from the iAMA indicator                 | 
//+------------------------------------------------------------------+ 
bool FillArrayFromBuffer(double &ama_buffer[],  // indicator buffer of the AMA line 
                         int a_shift,           // shift of the AMA line 
                         int ind_handle,        // handle of the iAMA indicator 
                         int amount             // number of copied values 
                         )
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the iAMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(ind_handle,0,-a_shift,amount,ama_buffer)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iAMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
//--- everything is fine 
   return(true);
  }
//+------------------------------------------------------------------+
