//+------------------------------------------------------------------+ 
//|                                            Fine_Fractals_MTF.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//--- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0                            // the constant for getting the command for the indicator recalculation back to the terminal
#define INDICATOR_NAME "Fine_Fractals MTF" // the constant for the indicator name
//+----------------------------------------------+
//|  Upper indicator drawing parameters          |
//+----------------------------------------------+
//--- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//--- magenta color is used for the indicator
#property indicator_color1  Magenta
//--- indicator 1 line width is equal to 1
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  "Up "+INDICATOR_NAME
//+----------------------------------------------+
//|  Lower indicator drawing parameters          |
//+----------------------------------------------+
//--- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//--- blue color is used for the indicator
#property indicator_color2  Blue
//--- indicator 2 line width is equal to 1
#property indicator_width2  1
//--- displaying the indicator label
#property indicator_label2 "Down "+INDICATOR_NAME
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;// Chart period
input bool Fine=true;                     // Sensibility 
input bool FlatShift=true;                // Shift
input int  UpLable=164;                   // Upper fractal symbol code
input int  DnLable=164;                   // Lower fractal symbol code
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double HighBuffer[];
double LowBuffer[];
//--- declaration of global variables
bool   Init;
//--- declaration of the integer variables for the start of data calculation
int min_rates_total,LimitShift;
//--- declaration of integer variables for the indicators handles
int FRA_Handle;
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
   Init=true;
//--- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Fine_Fractals indicator chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//--- initialization of variables 
   double timeratio=PeriodSeconds(TimeFrame)/PeriodSeconds(PERIOD_CURRENT);
   min_rates_total=int(5*timeratio);
   LimitShift=int(4*timeratio);
//--- getting handle of the Fine_Fractals indicator
   FRA_Handle=iCustom(NULL,TimeFrame,"Fine_Fractals",Fine,FlatShift);
   if(FRA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the Fine_Fractals indicator");
      return(INIT_FAILED);
     }
//--- set HighBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,HighBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,UpLable);
//--- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(HighBuffer,true);
//--- set LowBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,LowBuffer,INDICATOR_DATA);
//--- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//--- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,DnLable);
//--- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(LowBuffer,true);
//--- creating a name for displaying in a separate sub-window and in a tooltip
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",Symbol(),StringSubstr(EnumToString(_Period),7,-1),")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+--------------------------------------------------------------------+    
//| Searching for the first extremum according to its time series value| 
//+--------------------------------------------------------------------+  
int FindMax(double Velue,int start,int end,const double &Array[])
  {
//---
   for(int bar=start; bar>=end; bar--) if(Array[bar]>=Velue)return(bar);
//---
   return(ArrayMaximum(Array,end,start-end));
  }
//+--------------------------------------------------------------------+    
//| Searching for the first extremum according to its time series value| 
//+--------------------------------------------------------------------+  
int FindMin(double Velue,int start,int end,const double &Array[])
  {
//---
   for(int bar=start; bar>=end; bar--) if(Array[bar]<=Velue)return(bar);
//---
   return(ArrayMinimum(Array,end,start-end));
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
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
   if(rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(FRA_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- declarations of local variables 
   double UpFrac[1],DnFrac[1];
   int limit,bar;
   datetime FracTime[1];
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1;            // starting index for calculation of all bars
     }
   else limit=LimitShift+rates_total-prev_calculated; // starting index for calculation of new bars 
//--- indexing elements in arrays as time series  
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- zero out the contents of the indicator buffers for calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      LowBuffer[bar]=0.0;
      HighBuffer[bar]=0.0;
     }
//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- copy newly appeared data in the arrays
      if(CopyTime(NULL,TimeFrame,time[bar],1,FracTime)<=0) return(RESET);
      if(time[bar]>=FracTime[0] && time[bar+1]<FracTime[0])
        {
         //--- copy newly appeared data in the arrays
         if(CopyBuffer(FRA_Handle,0,time[bar],1,UpFrac)<=0) return(RESET);
         if(CopyBuffer(FRA_Handle,1,time[bar],1,DnFrac)<=0) return(RESET);
         //---
         if(UpFrac[0]!=EMPTY_VALUE&&UpFrac[0]) HighBuffer[FindMax(UpFrac[0],bar,0,high)]=UpFrac[0];
         if(DnFrac[0]!=EMPTY_VALUE&&DnFrac[0]) LowBuffer[FindMin(DnFrac[0],bar,0,low)]=DnFrac[0];
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
