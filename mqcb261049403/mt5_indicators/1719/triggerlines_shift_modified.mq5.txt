//+------------------------------------------------------------------+ 
//|                                  Triggerlines_Shift_Modified.mq5 | 
//|                                            Copyright © 2007, XXX | 
//|                                                                  | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2007, XXX"
#property link ""
//---- Indicator version
#property version   "1.00"
//---- Indicator drawn in the main window
#property indicator_chart_window
//---- Number of indicator buffers is 2
#property indicator_buffers 2 
//---- One graphical construction used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters   |
//+-----------------------------------+
//---- The indicator is drawn as a colored cloud
#property indicator_type1   DRAW_FILLING
//---- The following colors used or the indicator
#property indicator_color1  clrDeepSkyBlue,clrDeepPink
//---- Indicator label
#property indicator_label1  "Triggerlines_Shift_Modified"

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input uint Rperiod=20;
input uint LSMA_Period=20;
//+-----------------------------------+

double Res1,Res2;
//---- Declaring integer variables of data calculation start
int  min_rates_total,lengthvar;
//---- Declaring dynamic arrays that will be further 
// used as indicator buffers
double ExtRBuffer[];
double ExtLBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(Rperiod,LSMA_Period)+1);
   lengthvar=int((Rperiod+1)/3);
   Res1=6.0/(Rperiod*(Rperiod+1.0));
   Res2=2.0/(LSMA_Period+1.0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtRBuffer,INDICATOR_DATA);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtRBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtLBuffer,INDICATOR_DATA);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtLBuffer,true);

//---- Performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);


//---- Initializations of variable for indicator short name
   string shortname="Triggerlines_Shift_Modified";
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
  //---- Check if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- Declaration of integer variables
   int limit;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
   else limit=rates_total-prev_calculated;  // starting index for the calculation of the new bars only

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(Close,true);

//---- main cycle of calculation of the indicator
   for(int bar=limit; bar>=0; bar--)
     {
      double Sum=0.0;
      for(int i=int(Rperiod); i>0; i--)
        {
         double tmp=0;
         tmp =(i-lengthvar)*Close[bar+Rperiod-i];
         Sum+=tmp;
        }

      ExtRBuffer[bar]=Sum*Res1;
      ExtLBuffer[bar]=ExtRBuffer[bar+1]+(ExtRBuffer[bar]-ExtRBuffer[bar+1])*Res2;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
