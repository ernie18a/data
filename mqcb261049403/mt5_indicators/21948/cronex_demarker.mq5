//+------------------------------------------------------------------+
//|                     Cronex DeMarker(barabashkakvn's edition).mq5 |
//|                                        Copyright © 2007, Cronex. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2007, Cronex"
#property  link      "https://www.metaquotes.net/"
#property version   "1.000"
#include <MovingAverages.mqh>
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- the iDeMarker plot
#property indicator_label1  "iDeMarker"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLightSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- the Fast MA plot
#property indicator_label2  "Fast MA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLawnGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- the Slow MA plot
#property indicator_label3  "Slow MA"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrViolet
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- horizontal levels in the indicator window 
#property indicator_level1  0.3 
#property indicator_level2  0.7 
//--- input parameters
input int   Inp_DeMarker_ma_period  = 14;    // DeMarker: period of moving average 
input int   Inp_FastMA              = 14;    // Fast MA
input int   Inp_SlowMA              = 25;    // Slow MA
//--- indicator buffers
double         iDeMarkerBuffer[];
double         iDeMarkerBufferMA1[];
double         iDeMarkerBufferMA2[];
//--- variable for storing the handle of the iDeMarker indicator 
int    handle;
//--- we will keep the number of values in the DeMarker indicator 
int    bars_calculated=0;
//---
int weightfast,weightslow;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- assignment of array to indicator buffers
   SetIndexBuffer(0,iDeMarkerBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,iDeMarkerBufferMA1,INDICATOR_DATA);
   SetIndexBuffer(2,iDeMarkerBufferMA2,INDICATOR_DATA);
//--- create handle of the indicator 
   handle=iDeMarker(Symbol(),Period(),Inp_DeMarker_ma_period);
//--- if the handle is not created 
   if(handle==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iDeMarker indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,
                      "DeM("+IntegerToString(Inp_DeMarker_ma_period)+
                      ","+IntegerToString(Inp_FastMA)+
                      ","+IntegerToString(Inp_SlowMA)+")");
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
//--- number of values copied from the iDeMarker indicator 
   int values_to_copy;
//--- determine the number of values calculated in the indicator 
   int calculated=BarsCalculated(handle);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iDeMarker indicator changed 
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history) 
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iDeMarkerBuffer array is greater than the number of values in the iDeMarker indicator for symbol/period, then we don't copy everything  
      //--- otherwise, we copy less than the size of indicator buffers 
      if(calculated>rates_total) values_to_copy=rates_total;
      else                       values_to_copy=calculated;
     }
   else
     {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate() 
      //--- for calculation not more than one bar is added 
      values_to_copy=(rates_total-prev_calculated)+1;
     }
//--- fill the iDeMarkerBuffer array with values of the DeMarker indicator 
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation 
   if(!FillArrayFromBuffer(iDeMarkerBuffer,handle,values_to_copy)) return(0);
//--- memorize the number of values in the DeMarker indicator 
   bars_calculated=calculated;
//---
   LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,Inp_FastMA,iDeMarkerBuffer,iDeMarkerBufferMA1,weightfast);
   LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,Inp_SlowMA,iDeMarkerBuffer,iDeMarkerBufferMA2,weightslow);
//--- return the prev_calculated value for the next call 
   return(rates_total);
  }
//+------------------------------------------------------------------+ 
//| Filling indicator buffers from the iDeMarker indicator           | 
//+------------------------------------------------------------------+ 
bool FillArrayFromBuffer(double &values[],  // indicator buffer for DeMarker values 
                         int ind_handle,    // handle of the iDeMarker indicator 
                         int amount         // number of copied values 
                         )
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the iDeMarkerBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(ind_handle,0,0,amount,values)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iDeMarker indicator, error code %d",GetLastError());
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
