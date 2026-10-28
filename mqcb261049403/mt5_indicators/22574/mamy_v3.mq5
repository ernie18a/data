//+------------------------------------------------------------------+
//|                             MAMy v3(barabashkakvn's edition).mq5 |
//|                             Copyright © 2006, Victor Chebotariov |
//|                                      http://www.chebotariov.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Victor Chebotariov"
#property link      "http://www.chebotariov.com/"
#property version   "1.001"
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
//--- the MAMy plots
#property indicator_label1  "Open (Green)"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLawnGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_label2  "Close (Red)"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
input int               Inp_MA_ma_period  = 3;           // MA: averaging period 
input ENUM_MA_METHOD    Inp_MA_ma_method  = MODE_LWMA;   // MA: smoothing type
//--- indicator buffers
double MAMyOpenBuffer[];
double MAMyCloseBuffer[];
double iMA_CLOSE[];
double iMA_OPEN[];
double iMA_WEIGHTED[];
//--- variable for storing the handle of the iMA indicators
int    handle_iMA_PRICE_CLOSE;
int    handle_iMA_PRICE_OPEN;
int    handle_iMA_PRICE_WEIGHTED;
//--- we will keep the number of values in the Moving Average indicator
int    bars_calculated=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MAMyOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,MAMyCloseBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,iMA_CLOSE,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,iMA_OPEN,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,iMA_WEIGHTED,INDICATOR_CALCULATIONS);
//--- set shift 
   PlotIndexSetInteger(0,PLOT_SHIFT,0);
   PlotIndexSetInteger(1,PLOT_SHIFT,0);
//--- create handle of the indicator iMA
   handle_iMA_PRICE_CLOSE=iMA(Symbol(),Period(),Inp_MA_ma_period,0,Inp_MA_ma_method,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_PRICE_CLOSE==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_PRICE_OPEN=iMA(Symbol(),Period(),Inp_MA_ma_period,0,Inp_MA_ma_method,PRICE_OPEN);
//--- if the handle is not created 
   if(handle_iMA_PRICE_OPEN==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_PRICE_WEIGHTED=iMA(Symbol(),Period(),Inp_MA_ma_period,0,Inp_MA_ma_method,PRICE_WEIGHTED);
//--- if the handle is not created 
   if(handle_iMA_PRICE_WEIGHTED==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
/*
//--- show the symbol/timeframe the Moving Average indicator is calculated_PRICE_CLOSE for 
   short_name=StringFormat("iMA(%s/%s, %d, %d, %s, %s)",name,EnumToString(period),
                           ma_period,ma_shift,EnumToString(ma_method),EnumToString(applied_price));
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);*/
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
//--- number of values copied from the iMA indicator 
   int values_to_copy;
//--- determine the number of values calculated_PRICE_CLOSE in the indicator 
   int calculated_PRICE_CLOSE=BarsCalculated(handle_iMA_PRICE_CLOSE);
   if(calculated_PRICE_CLOSE<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated_PRICE_CLOSE,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iMA indicator changed 
//---or if it is necessary to calculated_PRICE_CLOSE the indicator for two or more bars (it means something has changed in the price history) 
   if(prev_calculated==0 || calculated_PRICE_CLOSE!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iMABuffer array is greater than the number of values in the iMA indicator for symbol/period, then we don't copy everything  
      //--- otherwise, we copy less than the size of indicator buffers 
      if(calculated_PRICE_CLOSE>rates_total)
         values_to_copy=rates_total;
      else
         values_to_copy=calculated_PRICE_CLOSE;
     }
   else
     {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate() 
      //--- for calculation not more than one bar is added 
      values_to_copy=(rates_total-prev_calculated)+1;
     }
//--- fill the iMABuffer array with values of the Moving Average indicator 
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation 
   if(!FillArrayFromBuffer(iMA_CLOSE,0,handle_iMA_PRICE_CLOSE,values_to_copy))
      return(0);
   if(!FillArrayFromBuffer(iMA_OPEN,0,handle_iMA_PRICE_OPEN,values_to_copy))
      return(0);
   if(!FillArrayFromBuffer(iMA_WEIGHTED,0,handle_iMA_PRICE_WEIGHTED,values_to_copy))
      return(0);
//--- memorize the number of values in the Moving Average indicator 
   bars_calculated=calculated_PRICE_CLOSE;
   int limit=prev_calculated-1;
   if(prev_calculated==0)
     {
      limit=1;
      MAMyOpenBuffer[0]=0.0;
      MAMyCloseBuffer[0]=0.0;
     }
   for(int i=limit;i<rates_total;i++)
     {
      MAMyCloseBuffer[i]=(iMA_CLOSE[i]-iMA_WEIGHTED[i])/**1000.0*/;
      if((iMA_CLOSE[i]<iMA_CLOSE[i-1] && iMA_WEIGHTED[i]<iMA_WEIGHTED[i-1] && iMA_CLOSE[i]<iMA_WEIGHTED[i] && iMA_WEIGHTED[i]<iMA_OPEN[i] && iMA_WEIGHTED[i-1]<iMA_OPEN[i-1] && MAMyCloseBuffer[i]<=MAMyCloseBuffer[i-1]) ||
         (iMA_CLOSE[i]>iMA_CLOSE[i-1] && iMA_WEIGHTED[i]>iMA_WEIGHTED[i-1] && iMA_CLOSE[i]>iMA_WEIGHTED[i] && iMA_WEIGHTED[i]>iMA_OPEN[i] && iMA_WEIGHTED[i-1]>iMA_OPEN[i-1] && MAMyCloseBuffer[i]>=MAMyCloseBuffer[i-1]))
        {
         MAMyOpenBuffer[i]=((iMA_WEIGHTED[i]-iMA_OPEN[i])+(iMA_CLOSE[i]-iMA_WEIGHTED[i]))/**1000.0*/;
        }
      else
         MAMyOpenBuffer[i] = 0.0;
      if(MAMyOpenBuffer[i]>= 0.0 && MAMyOpenBuffer[i] > MAMyOpenBuffer[i-1] &&
         MAMyCloseBuffer[i]<0.0 && MAMyCloseBuffer[i-1]>=0.0)
        {
         MAMyCloseBuffer[i]=0.0;
        }
      else
         MAMyCloseBuffer[i]=(iMA_CLOSE[i]-iMA_WEIGHTED[i])/**1000.0*/;
     }
//--- return the prev_calculated value for the next call 
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
      //--- quit with zero result - it means that the indicator is considered as not calculated_PRICE_CLOSE 
      return(false);
     }
//--- everything is fine 
   return(true);
  }
//+------------------------------------------------------------------+
