//+------------------------------------------------------------------+
//|                                              Fractals On OBV.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.001"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot OBV
#property indicator_label1  "OBV"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Fractal Up
#property indicator_label2  "Fractal Up"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Fractal Down
#property indicator_label3  "Fractal Down"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- input parameters
input group             "OBV"
input ENUM_APPLIED_VOLUME  Inp_OBV_applied_volume        = VOLUME_TICK;    // OBV: volume type for calculation
//--- indicator buffers
double   OBVBuffer[];
double   Fractal_Up_Buffer[];
double   Fractal_Down_Buffer[];
//---
int      handle_iOBV;                           // variable for storing the handle of the iOBV indicator
int      bars_calculated            = 0;        // we will keep the number of values in the On Balance Volume indicator
bool     m_init_error               = false;    // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,OBVBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,Fractal_Up_Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,Fractal_Down_Buffer,INDICATOR_DATA);
//--- set indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(1,PLOT_ARROW,217);
   PlotIndexSetInteger(2,PLOT_ARROW,218);
//--- arrow shifts when drawing
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,-10);
//--- sets drawing line empty value
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- create handle of the iOBV indicator
   handle_iOBV=iOBV(Symbol(),Period(),Inp_OBV_applied_volume);
//--- if the handle is not created
   if(handle_iOBV==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iOBV indicator for the symbol %s/%s, error code %d",
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
//---
   if(m_init_error)
      return(0);
   if(rates_total<5)
      return(0);
//--- number of values copied from the iOBV indicator
   int values_to_copy;
//--- determine the number of values calculated in the indicator
   int calculated=BarsCalculated(handle_iOBV);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iOBV indicator changed
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iOBVBuffer array is greater than the number of values in the iOBV indicator for symbol/period, then we don't copy everything
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
//--- fill the arrays with values of the iOBV indicator
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if(!FillArrayFromBuffer(OBVBuffer,handle_iOBV,values_to_copy))
      return(0);
//--- memorize the number of values in the On Balance Volume indicator
   bars_calculated=calculated;
//--- Fractals
   int start;
//--- clean up arrays
   if(prev_calculated<7)
     {
      start=2;
      ArrayInitialize(Fractal_Up_Buffer,EMPTY_VALUE);
      ArrayInitialize(Fractal_Down_Buffer,EMPTY_VALUE);
     }
   else
      start=rates_total-5;
//--- main cycle of calculations
   for(int i=start; i<rates_total-3 && !IsStopped(); i++)
     {
      //--- Upper Fractal
      if(OBVBuffer[i]>OBVBuffer[i+1] && OBVBuffer[i]>OBVBuffer[i+2] && OBVBuffer[i]>=OBVBuffer[i-1] && OBVBuffer[i]>=OBVBuffer[i-2])
         Fractal_Up_Buffer[i]=OBVBuffer[i];
      else
         Fractal_Up_Buffer[i]=EMPTY_VALUE;
      //--- Lower Fractal
      if(OBVBuffer[i]<OBVBuffer[i+1] && OBVBuffer[i]<OBVBuffer[i+2] && OBVBuffer[i]<=OBVBuffer[i-1] && OBVBuffer[i]<=OBVBuffer[i-2])
         Fractal_Down_Buffer[i]=OBVBuffer[i];
      else
         Fractal_Down_Buffer[i]=EMPTY_VALUE;
     }
//---
   for(int i=rates_total-3; i<rates_total; i++)
     {
      Fractal_Up_Buffer[i]=EMPTY_VALUE;
      Fractal_Down_Buffer[i]=EMPTY_VALUE;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Filling indicator buffers from the iOBV indicator                |
//+------------------------------------------------------------------+
bool FillArrayFromBuffer(double &obv_buffer[],  // indicator buffer of OBV values
                         int ind_handle,        // handle of the iOBV indicator
                         int amount             // number of copied values
                        )
  {
//--- reset error code
   ResetLastError();
//--- fill a part of the iOBVBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,0,amount,obv_buffer)<0)
     {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iOBV indicator, error code %d",GetLastError());
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
   if(handle_iOBV!=INVALID_HANDLE)
      IndicatorRelease(handle_iOBV);
  }
//+------------------------------------------------------------------+
