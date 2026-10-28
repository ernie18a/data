//+---------------------------------------------------------------------+
//|                                                          Median.mq5 | 
//|                                    Copyright © 2008, unknown author | 
//|                                                                     | 
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2008, unknown author"
#property link ""
#property description ""
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- number of indicator buffers 4
#property indicator_buffers 4 
//--- four plots are used
#property indicator_plots   4
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0                   // A constant for returning the indicator recalculation command to the terminal
#define INDICATOR_NAME "Median"   // A constant for the indicator name
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//--- the color of the indicator
#property indicator_color1  clrTeal
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  INDICATOR_NAME+" Up"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//--- the color of the indicator
#property indicator_color2  clrMediumVioletRed
//--- indicator 2 line width is equal to 2
#property indicator_width2  2
//--- displaying the indicator label
#property indicator_label2  INDICATOR_NAME+" Down"
//+----------------------------------------------+
//|  Indicator 3 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator as a colored cloud
#property indicator_type3   DRAW_FILLING
//--- the following colors are used as the indicator colors
#property indicator_color3  clrLime,clrMagenta
//--- displaying the indicator label
#property indicator_label3  INDICATOR_NAME+" Signal"
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint per=3;
input double K_ATR=2.0;
input uint Period_ATR=13;
input int Shift=0;       //Horizontal shift of the indicator in bars
//+-----------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double Ind1Buffer[];
double Ind2Buffer[];
double Ind3Buffer[];
double Ind4Buffer[];
double Pr;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Indicator buffer initialization                                  |
//+------------------------------------------------------------------+    
void IndInit(int Number,double &Buffer[],double Empty_Value,int Draw_Begin,int nShift)
  {
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(Number,PLOT_DRAW_BEGIN,Draw_Begin);
//--- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(Number,PLOT_EMPTY_VALUE,Empty_Value);
//--- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(Number,PLOT_SHIFT,nShift);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Buffer,true);
//---
  }
//+------------------------------------------------------------------+
//| Indicator buffer initialization                                  |
//+------------------------------------------------------------------+    
void IndInit1(int Number,double &Buffer[])
  {
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(Number,Buffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Buffer,true);
//---
  }
//+------------------------------------------------------------------+   
//| Osc indicator initialization function                            | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//--- initialization of variables of the start of data calculation   
   min_rates_total=int(MathMax(per,Period_ATR));
   Pr=2.0/(per+1.0);
//--- initialize indicator buffers
   IndInit(0,Ind1Buffer,0.0,min_rates_total,Shift);
   IndInit(1,Ind2Buffer,0.0,min_rates_total,Shift);
//---
   IndInit1(2,Ind3Buffer);
   IndInit1(3,Ind4Buffer);
//--- shifting the start of drawing of the indicator
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//--- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME+"(",per,",",DoubleToString(Period_ATR,2),",",Period_ATR,",",Shift,")");
//--- creating a name for displaying in a separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
  }
//+------------------------------------------------------------------+ 
//| Osc iteration function                                           | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(RESET);
//--- declaration of variables with a floating point  
   double mmin,mmax,middle,ATR;
//--- declaration of integer variables
   int bar,limit;

//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
//--- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // Starting index for calculation of all bars
      bar=limit+1;
      Ind4Buffer[bar]=(high[bar]+low[bar])/2.0;
     }
   else limit=rates_total-prev_calculated; // Starting index for the calculation of new bars 
//--- the main loop of the indicator calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ATR=0;
      for(int counter=int(Period_ATR)-1; counter>=0; counter--) ATR+=MathAbs(high[bar+counter]-low[bar+counter]);
      ATR/=Period_ATR;
      ATR*=K_ATR;
      //---
      mmax=high[ArrayMaximum(high,bar,per)];
      mmin=low[ArrayMinimum(low,bar,per)];
      middle=(mmax+mmin)/2;
      //--- loading the obtained value in the indicator buffer
      Ind1Buffer[bar]=middle+ATR;
      Ind3Buffer[bar]=middle;
      Ind2Buffer[bar]=middle-ATR;
      Ind4Buffer[bar]=middle*Pr+Ind4Buffer[bar+1]*(1-Pr);
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
