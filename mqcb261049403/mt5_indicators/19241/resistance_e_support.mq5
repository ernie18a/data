//+------------------------------------------------------------------+
//|                                         Resistance & Support.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.001"
#property description "Resistance & Support" 

#property indicator_chart_window 
#property indicator_buffers 4
#property indicator_plots   2
//--- plots 
#property indicator_label1  "Resistance" 
#property indicator_type1   DRAW_ARROW 
#property indicator_color1  clrLime 
#property indicator_width1  1 
#property indicator_label2  "Support" 
#property indicator_type2   DRAW_ARROW 
#property indicator_color2  clrMagenta 
#property indicator_width2  1 
//--- input параметры 
input uchar    InpArrowCode=159;      // arrow code (Wingdings font's symbol codes)
//--- An indicator buffers for the plot 
double         ResistanceBuffer[];
double         SupportBuffer[];
double         FractalsUpBuffer[];
double         FractalsDownBuffer[];
//--- Fractals handles 
int            handle_iFractals;             // variable for storing the handle of the iFractals indicator 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ResistanceBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,SupportBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,FractalsUpBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,FractalsDownBuffer,INDICATOR_CALCULATIONS);
//--- Define the symbol code for drawing in PLOT_ARROW 
   PlotIndexSetInteger(0,PLOT_ARROW,InpArrowCode);
   PlotIndexSetInteger(1,PLOT_ARROW,InpArrowCode);
//--- Set the vertical shift of arrows in pixels 
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-5);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,5);
//--- Set as an empty value 0 
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- set accuracy 
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- create handle of the indicator iFractals
   handle_iFractals=iFractals(Symbol(),Period());
//--- if the handle is not created 
   if(handle_iFractals==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iFractals indicator for the symbol %s/%s, error code %d",
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
//--- check for minimum rates count; minimum rates count for Fractals: 5
   if(rates_total<5)
      return(0);
//---
   int calculated_Fractals=BarsCalculated(handle_iFractals);
   if(calculated_Fractals!=rates_total)
      return(0);
//--- number of values copied from the iFractals indicator 
   int values_to_copy=-1;
//--- if it is the first start of calculation of the indicator
   if(prev_calculated==0)
      values_to_copy=rates_total;
   else
     {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate() 
      //--- for calculation not more than one bar is added 
      //--- value "+5" - because of the feature of drawing fractals
      values_to_copy=(rates_total-prev_calculated)+5;
     }
//--- fill the FractalsUpBuffer and FractalsDownBuffer arrays with values from the Fractals indicator 
//--- if FillFractalsArraysFromBuffers returns false, it means the information is nor ready yet, quit operation 
   if(!FillFractalsArraysFromBuffers(FractalsUpBuffer,FractalsDownBuffer,handle_iFractals,values_to_copy))
      return(0);
//---
   int limit=(prev_calculated==0)?0:(rates_total-prev_calculated)-5;
   limit=(limit<0)?0:limit;

   static double prev_fractals_up=EMPTY_VALUE;
   static double prev_fractals_down=EMPTY_VALUE;

   for(int i=limit;i<rates_total;i++)
     {
      if(FractalsUpBuffer[i]!=EMPTY_VALUE)
         prev_fractals_up=FractalsUpBuffer[i];
      ResistanceBuffer[i]=prev_fractals_up;
      //---
      if(FractalsDownBuffer[i]!=EMPTY_VALUE)
         prev_fractals_down=FractalsDownBuffer[i];
      SupportBuffer[i]=prev_fractals_down;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+ 
//| Filling indicator buffers from the iFractals indicator           | 
//+------------------------------------------------------------------+ 
bool FillFractalsArraysFromBuffers(double &up_arrows[],// indicator buffer for up arrows 
                                   double &down_arrows[],      // indicator buffer for down arrows 
                                   int ind_handle,             // handle of the iFractals indicator 
                                   int amount                  // number of copied values 
                                   )
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the FractalUpBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(ind_handle,0,0,amount,up_arrows)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iFractals indicator to the FractalUpBuffer array, error code %d",
                  GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
//--- fill a part of the FractalDownBuffer array with values from the indicator buffer that has index 1 
   if(CopyBuffer(ind_handle,1,0,amount,down_arrows)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iFractals indicator to the FractalDownBuffer array, error code %d",
                  GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
//--- everything is fine 
   return(true);
  }
//+------------------------------------------------------------------+
