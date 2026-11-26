//+------------------------------------------------------------------+ 
//|                                                    Gator_HTF.mq5 | 
//|                               Copyright © 2011, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 4
#property indicator_buffers 4 
//---- only two plots are used
#property indicator_plots   2
//+-----------------------------------+
//| Indicator 1 drawing parameters    |
//+-----------------------------------+
//---- drawing the indicator as a four-color histogram
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the four color histogram
#property indicator_color1 Green,Red
//---- Indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is equal to 5
#property indicator_width1 5
//---- displaying the indicator label
#property indicator_label1 "Gator Upper HTF"
//+-----------------------------------+
//| Indicator 2 drawing parameters    |
//+-----------------------------------+
//---- drawing the indicator as a four-color histogram
#property indicator_type2 DRAW_COLOR_HISTOGRAM
//---- the following colors are used in the four color histogram
#property indicator_color2 Green,Red
//---- Indicator line is a solid one
#property indicator_style2 STYLE_SOLID
//---- indicator line width is equal to 5
#property indicator_width2 5
//---- displaying the indicator label
#property indicator_label2 "Gator Lower HTF"
//+-----------------------------------+
//| Declaration of constants          |
//+-----------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+-----------------------------------+
//|  Input parameters of the indicator|
//+-----------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;            // Chart period
input int                JawsPeriod=13;               // Jaws period
input int                JawsShift=8;                 // Jaws shift
input int                TeethPeriod=8;               // Teeth period
input int                TeethShift=5;                // Teeth shift
input int                LipsPeriod=5;                // Lips period
input int                LipsShift=3;                 // Lips shift
input ENUM_MA_METHOD     MAMethod=MODE_SMMA;          // Moving average method
input ENUM_APPLIED_PRICE AppliedPrice=PRICE_MEDIAN;   // Applied price
input bool ReDraw=true;                               // Repeat display of information in the empty bars
//+-----------------------------------+
//---- declaration of a variable for storing the indicator initialization result
bool Init;
double perratio;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of integer variables for the indicators handles
int Gator_Handle;
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double UpperBuffer[],ColorUpBuffer[],LowerBuffer[],ColorLoBuffer[];
//+------------------------------------------------------------------+
//|  Getting string timeframe                                        |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+    
//| Gator indicator initialization function                          | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- initialization of variables 
   perratio=PeriodSeconds(TimeFrame)/PeriodSeconds(PERIOD_CURRENT);
   min_rates_total=int(perratio*(MathMax(MathMax(JawsPeriod,TeethPeriod),LipsPeriod)+3));
   Init=true;
//---- checking correctness of the chart periods
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Gator indicator chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//---- getting handle of the Gator indicator
   Gator_Handle=iCustom(Symbol(),TimeFrame,"GatorCalc",JawsPeriod,JawsShift,TeethPeriod,TeethShift,
                        LipsPeriod,LipsShift,MAMethod,AppliedPrice,-TeethShift,-LipsShift);
   if(Gator_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the Gator indicator");
      Init=false;
      return(INIT_FAILED);
     }
//---- checking correctness of the input parameters     
   if(!CheckForInput()) Print("Indicator input parameters are incorrect. The indicator will not work!");
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,int(perratio*TeethShift));
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpperBuffer,true);
//---- set dynamic array as a color index buffer   
   SetIndexBuffer(1,ColorUpBuffer,INDICATOR_COLOR_INDEX);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorUpBuffer,true);
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,LowerBuffer,INDICATOR_DATA);
//---- performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- shifting the indicator 3 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,int(perratio*LipsShift));
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(LowerBuffer,true);
//---- set dynamic array as a color index buffer   
   SetIndexBuffer(3,ColorLoBuffer,INDICATOR_COLOR_INDEX);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ColorLoBuffer,true);
//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Gator HTF( ",GetStringTimeframe(TimeFrame)+","
                     +string(JawsPeriod)+","+string(TeethPeriod),",",string(LipsPeriod)," )");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Gator iteration function                                         | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // amount of history in bars at the current tick
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
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(Gator_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//---- declaration of integer variables
   int limit,bar;
//---- declaration of variables with a floating point  
   double Upper[1],Lower[1],UpTrend[1],LoTrend[1];
   datetime GatorTime[1];
   static uint LastCountBar;
//--- calculations of the necessary amount of data to be copied and
//----the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
      LastCountBar=rates_total;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for calculation of new bars 
//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);
//---- Main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- zero out the contents of the indicator buffers for calculation
      UpperBuffer[bar]=EMPTY_VALUE;
      LowerBuffer[bar]=EMPTY_VALUE;
      ColorUpBuffer[bar]=-1;
      ColorLoBuffer[bar]=-1;
      //--- copy newly appeared data in the array
      if(CopyTime(Symbol(),TimeFrame,time[bar],1,GatorTime)<=0) return(RESET);
      if(time[bar]>=GatorTime[0] && time[bar+1]<GatorTime[0])
        {
         LastCountBar=bar+int(perratio*(MathMax(MathMax(JawsPeriod,TeethPeriod),LipsPeriod)))+1;
         //---- copy newly appeared data into the arrays
         if(CopyBuffer(Gator_Handle,0,time[bar],1,Upper)<=0) return(RESET);
         if(CopyBuffer(Gator_Handle,1,time[bar],1,UpTrend)<=0) return(RESET);
         if(CopyBuffer(Gator_Handle,2,time[bar],1,Lower)<=0) return(RESET);
         if(CopyBuffer(Gator_Handle,3,time[bar],1,LoTrend)<=0) return(RESET);
         //---- Loading the obtained values in the indicator buffers
         UpperBuffer[bar]=Upper[0];
         LowerBuffer[bar]=Lower[0];
         //----
         ColorUpBuffer[bar]=UpTrend[0];
         ColorLoBuffer[bar]=LoTrend[0];
        }
      if(ReDraw)
         if(ColorUpBuffer[bar+1]!=-1 && ColorUpBuffer[bar]==-1)
           {
            UpperBuffer[bar]=UpperBuffer[bar+1];
            ColorUpBuffer[bar]=ColorUpBuffer[bar+1];
            //----
            LowerBuffer[bar]=LowerBuffer[bar+1];
            ColorLoBuffer[bar]=ColorLoBuffer[bar+1];
           }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Check for rules                                                  |
//| 1.JawsPeriod>TeethPeriod>LipsPeriod;                             |
//| 2.JawsShift>TeethShift>LipsShift;                                |
//| 3.JawsPeriod>JawsShift;                                          |
//| 4.TeethPeriod>TeethShift;                                        |
//| 5.LipsPeriod>LipsShift.                                          |
//+------------------------------------------------------------------+
bool CheckForInput()
  {
//--- 1
   if(JawsPeriod<=TeethPeriod || TeethPeriod<=LipsPeriod)
      return(false);
//--- 2
   if(JawsShift<=TeethShift || TeethShift<=LipsShift)
      return(false);
//--- 3
   if(JawsPeriod<=JawsShift)
      return(false);
//--- 4
   if(TeethPeriod<=TeethShift)
      return(false);
//--- 5
   if(LipsPeriod<=LipsShift)
      return(false);
//--- all right
   return(true);
  }
//+------------------------------------------------------------------+
