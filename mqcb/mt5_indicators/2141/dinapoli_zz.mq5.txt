//+------------------------------------------------------------------+
//|                                                  Dinapoli_ZZ.mq5 |
//|                                     Copyright © 2005, CrazyChart |
//+------------------------------------------------------------------+
//--- copyright
#property copyright "Copyright © 2005, CrazyChart"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- one buffer is used for calculation and drawing of the indicator
#property indicator_buffers 1
//--- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Dinapoli_ZZ indicator drawing parameters    |
//+----------------------------------------------+
//--- drawing the indicator 1 as a section
#property indicator_type1   DRAW_SECTION
//--- DarkOrange color is used as the color of the bullish line of the indicator
#property indicator_color1  clrDarkOrange
//--- the line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- display of the indicator bullish label
#property indicator_label1  "Dinapoli_ZZ"
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint barn=300;
input uint Length=6;
input int Shift=0;   // Horizontal shift of the indicator in bars
//+----------------------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double ZZBuffer[];
//--- declaration of integer variables for the start of data calculation
int min_rates_total,Barn;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of data calculation start
   min_rates_total=int(Length);
   Barn=int(barn);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,ZZBuffer,INDICATOR_DATA);
//--- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shifting the starting point of the indicator drawing by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ZZBuffer,true);
//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Dinapoli_ZZ(",Length,", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double& High[],     // price array of price maximums for the indicator calculation
                const double& Low[],      // price array of price minimums for the indicator calculation
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- declarations of local variables 
   int bar,limit,Swing,Swing_n,uzl,i,zu,zd,mv;
   double LL,HH,BH,BL;
   double Uzel[10000][3];
//---
   Swing_n=0;
   Swing=0;
   uzl=0;
   BH =High[barn];
   BL=Low[barn];
   zu=int(barn);
   zd=int(barn);
   limit=MathMin(Barn,rates_total);
   ArrayInitialize(Uzel,0.0);
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
//--- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      LL=+10000000;
      HH=-10000000;
      for(i=bar+int(Length); i>bar; i--)
        {
         if(Low[i]< LL) LL=Low[i];
         if(High[i]>HH) HH=High[i];
        }
      if(Low[bar]<LL && High[bar]>HH)
        {
         Swing=2;
         if(Swing_n==+1) zu=bar+1;
         if(Swing_n==-1) zd=bar+1;
        }
      else
        {
         if(Low[bar]<LL) Swing=-1;
         if(High[bar]>HH) Swing=+1;
        }
      if(Swing!=Swing_n && Swing_n)
        {
         if(Swing==2)
           {
            Swing=-Swing_n;
            BH=High[bar];
            BL=Low[bar];
           }
         uzl++;
         if(Swing==+1)
           {
            Uzel[uzl][1]=zd;
            Uzel[uzl][2]=BL;
           }
         if(Swing==-1)
           {
            Uzel[uzl][1]=zu;
            Uzel[uzl][2]=BH;
           }
         BH=High[bar];
         BL=Low[bar];
        }
      if(Swing==+1 && High[bar]>=BH)
        {
         BH=High[bar];
         zu=bar;
        }
      if(Swing==-1 && Low[bar]<=BL)
        {
         BL=Low[bar];
         zd=bar;
        }
      Swing_n=Swing;
      ZZBuffer[bar]=0.0;
     }
   for(bar=1; bar<=uzl && !IsStopped(); bar++)
     {
      mv=int(StringToInteger(DoubleToString(Uzel[bar][1],0)));
      ZZBuffer[mv]=Uzel[bar][2];
     }
//--- shifting the starting point of the indicator drawing by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rates_total-limit);
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
