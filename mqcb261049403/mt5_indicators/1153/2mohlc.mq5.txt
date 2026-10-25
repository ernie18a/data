//+------------------------------------------------------------------+ 
//|                   2 Medians of High-Low Channels      2MoHLC.mq5 | 
//|                                   Copyright © 2010, Ilya Filatov | 
//|                                               ilya-filatov@ya.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2010, Ilya Filatov"
#property link "ilya-filatov@ya.ru"
#property description "2 Medians of High-Low Channels"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- number of indicator buffers 2
#property indicator_buffers 2 
//---- one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a colored cloud
#property indicator_type1   DRAW_FILLING
//---- the following colors are used for the indicator
#property indicator_color1  clrDeepSkyBlue,clrHotPink
//---- displaying the indicator label
#property indicator_label1  "2MoHLC"

//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input int Period1=24; //Period 1
input int Period2=48; //Period 2
input int Shift=0; //Horizontal shift of the indicator in bars 
//+-----------------------------------+

//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double Ext1Buffer[];
double Ext2Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=MathMax(Period1,Period2);
   
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,Ext1Buffer,INDICATOR_DATA);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Ext1Buffer,true);
   
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,Ext2Buffer,INDICATOR_DATA);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Ext2Buffer,true);
      
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- horizontal shift of the indicator
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"2MoHLC("+string(Period1)+","+string(Period2)+")");
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
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
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of variables with a floating point  
   double HH,LL;
//---- Declaration of integer variables
   int limit;

//---- Calculate the "limit" starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
        limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
   else limit=rates_total-prev_calculated;  // starting index for calculation of new bars only

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);   
   
//---- main cycle of calculation of the indicator
   for(int bar=limit; bar>=0; bar--)
     {
      HH=High[ArrayMaximum(High,bar,Period1)];
      LL=Low [ArrayMinimum(Low, bar,Period1)];
      Ext1Buffer[bar]=(HH+LL)/2.0;      
      //---
      HH=High[ArrayMaximum(High,bar,Period2)];
      LL=Low [ArrayMinimum(Low, bar,Period2)];
      Ext2Buffer[bar]=(HH+LL)/2.0;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
