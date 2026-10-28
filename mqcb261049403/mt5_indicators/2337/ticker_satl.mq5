//+------------------------------------------------------------------+ 
//|                                                  Ticker_SATL.mq5 | 
//|                             Copyright © 20107, mandorr@gmail.com | 
//|                                                mandorr@gmail.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2007, mandorr@gmail.com"
#property link "mandorr@gmail.com"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window 
//--- number of indicator buffers is 2
#property indicator_buffers 2 
//--- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//---- the following colors are used as the indicator colors
#property indicator_color1  clrDodgerBlue,clrLightSalmon
//--- displaying the indicator label
#property indicator_label1  "Ticker_SATL"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
//--- declaration of integer variables of data starting point
int  min_rates_total,SATLPeriod;
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double ExtABuffer[];
double ExtBBuffer[];
//--- declaration and initialization of an array for the coefficient of the digital filter
double SATLTable[]=
  {
   +0.0982862174, +0.0975682269, +0.0961401078, +0.0940230544, +0.0912437090, +0.0878391006, +0.0838544303,
   +0.0793406350, +0.0743569346, +0.0689666682, +0.0632381578, +0.0572428925, +0.0510534242, +0.0447468229,
   +0.0383959950, +0.0320735368, +0.0258537721, +0.0198005183, +0.0139807863, +0.0084512448, +0.0032639979,
   -0.0015350359, -0.0059060082, -0.0098190256, -0.0132507215, -0.0161875265, -0.0186164872, -0.0205446727,
   -0.0219739146, -0.0229204861, -0.0234080863, -0.0234566315, -0.0231017777, -0.0223796900, -0.0213300463,
   -0.0199924534, -0.0184126992, -0.0166377699, -0.0147139428, -0.0126796776, -0.0105938331, -0.0084736770,
   -0.0063841850, -0.0043466731, -0.0023956944, -0.0005535180, +0.0011421469, +0.0026845693, +0.0040471369,
   +0.0052380201, +0.0062194591, +0.0070340085, +0.0076266453, +0.0080376628, +0.0083037666, +0.0083694798,
   +0.0082901022, +0.0080741359, +0.0077543820, +0.0073260526, +0.0068163569, +0.0062325477, +0.0056078229,
   +0.0049516078, +0.0161380976
   };
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   SATLPeriod=ArraySize(SATLTable);
   min_rates_total=SATLPeriod;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtABuffer,INDICATOR_DATA);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtBBuffer,INDICATOR_DATA);
//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"Ticker_SATL");
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- initialization end
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const int begin,          // number of beginning of reliable counting of bars
                const double &price[])    // a price array for indicator calculation
  { 
//--- checking if the number of bars is enough for the calculation
   if(rates_total<SATLPeriod-1+begin) return(0);
//--- declarations of local variables 
   int first,bar,iii;
   double SATL;
//--- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=SATLPeriod-1+begin; // starting index for the calculation of all bars
      //--- increase the position of the data start by 'begin' bars as a result of the calculation using data of another indicator
      if(begin>0) PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,begin+SATLPeriod);
     }
   else first=prev_calculated-1; // Starting index for the calculation of new bars
//--- main calculation loop of the indicator
   for(bar=first; bar<rates_total; bar++)
     {
      ExtABuffer[bar]=price[bar];
      //--- formula for calculation of the digital filter
      SATL=0.0;
      for(iii=0; iii<SATLPeriod; iii++) SATL+=SATLTable[iii] *price[bar-iii];
      //--- initialization of the cell of the indicator buffer by the obtained value of SATL
      ExtBBuffer[bar]=SATL;
     } 
//---    
   return(rates_total);
  }
//+------------------------------------------------------------------+
