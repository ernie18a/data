//+------------------------------------------------------------------+ 
//|                                                          CMx.mq5 | 
//|                                       Copyright © 2005, Alexandr | 
//|                                              beluck[at]gmail.com | 
//+------------------------------------------------------------------+ 
//--- copyright
#property copyright "Copyright © 2005, Alexandr"
//--- a link to the website of the author
#property link      ""
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window
//--- one buffer is used for calculation and drawing of the indicator
#property indicator_buffers 1
//--- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//--- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//--- LimeGreen color is used as the color of the bullish line of the indicator
#property indicator_color1  clrLimeGreen
//--- the line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- display of the indicator bullish label
#property indicator_label1  "CMx"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input int    F=12;
input double k=1.682;
input double L_adx=18;
input int    Shift=0;            // Horizontal shift of the indicator in bars
input double Level1=+423.6;      // Level 1
input double Level2=+261.8;      // Level 2
input double Level3=+161.8;      // Level 3
input double Level4=+61.8;       // Level 4
input double Level5=0.0;         // Level 5
input double Level6=-61.8;       // Level 6
input double Level7=-161.8;      // Level 7
input double Level8=-261.8;      // Level 8
input double Level9=-423.6;      // Level 9
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double IndBuffer[];
//---
double L_adxk;
//--- declaration of integer variables for the indicators handles
int MA1_Handle,MA2_Handle,Ind_Handle,ADX_Handle,CCI_Handle;
//--- declaration of integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- initialization of variables of data calculation start
   int Fk=int(MathRound(MathAbs(F*k)));
   min_rates_total=int(MathMax(F,Fk));
   if(F>0) min_rates_total*=2;
//--- 
   if(F<0)
     {
      //--- getting the handle of the iMA 1 indicator
      MA1_Handle=iMA(Symbol(),PERIOD_CURRENT,-F,0,MODE_EMA,PRICE_CLOSE);
      if(MA1_Handle==INVALID_HANDLE)
        {
         Print("Failed to get the handle of iMA 1");
         return(INIT_FAILED);
        }
      //--- getting the handle of the iMA 2 indicator
      MA2_Handle=iMA(Symbol(),PERIOD_CURRENT,Fk,0,MODE_EMA,PRICE_CLOSE);
      if(MA2_Handle==INVALID_HANDLE)
        {
         Print("Failed to get the handle of iMA 2");
         return(INIT_FAILED);
        }
     }
   else if(F>0)
     {
      L_adxk=L_adx*k;
      //--- getting the handle of CMx
      Ind_Handle=iCustom(Symbol(),PERIOD_CURRENT,"CMx",-F,k,L_adx,0);
      if(Ind_Handle==INVALID_HANDLE)
        {
         Print(" Failed to get the handle of CMx");
         return(INIT_FAILED);
        }
      //--- getting handle of the iCCI indicator
      CCI_Handle=iCCI(Symbol(),PERIOD_CURRENT,Fk,Ind_Handle);
      if(CCI_Handle==INVALID_HANDLE)
        {
         Print("Failed to get handle of the iCCI indicator");
         return(INIT_FAILED);
        }
      //--- getting the handle of the iADX indicator
      ADX_Handle=iADX(Symbol(),PERIOD_CURRENT,F);
      if(ADX_Handle==INVALID_HANDLE)
        {
         Print("Failed to get the handle of the iADX indicator");
         return(INIT_FAILED);
        }
     }
   else
     {
      Print("Indicator period cannot be less than one!");
      return(INIT_FAILED);
     }
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- shifting the indicator horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shifting the starting point of the indicator drawing by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);
//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"CMx(",F,", ",DoubleToString(k,4),", ",DoubleToString(L_adx,2),", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- the number of the indicator 9 horizontal levels   
   IndicatorSetInteger(INDICATOR_LEVELS,9);
//--- values of the indicator horizontal levels   
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,Level1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,Level2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,Level3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,Level4);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,4,Level5);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,5,Level6);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,6,Level7);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,7,Level8);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,8,Level9);
//--- gray and magenta colors are used for horizontal levels lines  
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,3,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,4,clrGray);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,5,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,6,clrBlue);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,7,clrMagenta);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,8,clrBlue);
//--- Short dot-dash is used for the horizontal level line  
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,3,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,4,STYLE_DASH);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,5,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,6,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,7,STYLE_DASHDOTDOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,8,STYLE_DASHDOTDOT);
//--- initialization end
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of price maximums for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(RESET);

   if(F<0)
     {
      if(BarsCalculated(MA1_Handle)<rates_total
         || BarsCalculated(MA2_Handle)<rates_total) return(RESET);
     }
   else
     {
      if(BarsCalculated(Ind_Handle)<rates_total
         || BarsCalculated(ADX_Handle)<rates_total
         || BarsCalculated(CCI_Handle)<rates_total) return(RESET);
     }
//--- declarations of local variables 
   int to_copy,limit,bar;
//--- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-1-min_rates_total; // starting index for the calculation of all bars
     }
   else limit=rates_total-prev_calculated; // Starting index for the calculation of new bars
//---   
   to_copy=limit+1;

   if(F<0)
     {
      double Ma1[],Ma2[];
      //--- apply timeseries indexing to array elements  
      ArraySetAsSeries(Ma1,true);
      ArraySetAsSeries(Ma2,true);
      //--- copy the newly appeared data to buffer
      if(CopyBuffer(MA1_Handle,0,0,to_copy,Ma1)<=0) return(RESET);
      if(CopyBuffer(MA2_Handle,0,0,to_copy,Ma2)<=0) return(RESET);
      //--- main indicator calculation loop
      for(bar=limit; bar>=0 && !IsStopped(); bar--) IndBuffer[bar]=Ma1[bar]-Ma2[bar];
     }
   else
     {
      double CCI[],ADX[];
      //--- apply timeseries indexing to array elements  
      ArraySetAsSeries(CCI,true);
      ArraySetAsSeries(ADX,true);
      //--- copy the newly appeared data to buffer
      if(CopyBuffer(CCI_Handle,0,0,to_copy,CCI)<=0) return(RESET);
      if(CopyBuffer(ADX_Handle,0,0,to_copy,ADX)<=0) return(RESET);
      //--- main indicator calculation loop
      for(bar=limit; bar>=0 && !IsStopped(); bar--) IndBuffer[bar]=CCI[bar]*ADX[bar]/L_adxk;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
