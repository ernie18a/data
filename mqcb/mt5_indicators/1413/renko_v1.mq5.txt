//+------------------------------------------------------------------+
//|                                                     Renko_v1.mq5 |
//|                           Copyright © 2005, TrendLaboratory Ltd. |
//|                                       E-mail: igorad2004@list.ru |
//|                                            Many Thanks To Konkop |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, TrendLaboratory Ltd."
#property link      "E-mail: igorad2004@list.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- DodgerBlue color is used as the color of the bullish line of the indicator
#property indicator_color1  clrDodgerBlue
//---- line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- displaying of the bullish label of the indicator
#property indicator_label1  "Upper Renko"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- Magenta color is used for the indicator bearish line
#property indicator_color2  clrMagenta
//---- the indicator 2 line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying of the bearish label of the indicator
#property indicator_label2  "Lower Renko"
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint PeriodATR=10;
input double Katr=1.00;
input int Shift=0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double UpBuffer[];
double DnBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(PeriodATR);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 1 by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(UpBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point for drawing indicator 2 by min_rates_total+1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(DnBuffer,true);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Renko(",PeriodATR,", ",DoubleToString(Katr,4),", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &Open[],
                const double& High[],     // price array of maximums of price for the calculation of indicator
                const double& Low[],      // price array of minimums of price for the calculation of indicator
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   int limit;
   double Up,Dn,Brick,AvgRange,dK,ATR;
   static double Up_,Dn_,Brick_;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
      Up_=High[limit];
      Dn_=Low[limit];
      Brick_=Katr*(High[limit]-Low[limit]);
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars

//---- indexing elements in arrays as timeseries
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);

//---- restoring the values of the variables
   Up=Up_;
   Dn=Dn_;
   Brick=Brick_;

//---- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      AvgRange=0;
      for(int iii=int(PeriodATR-1); iii>=0; iii--)
        {
         dK=1;
         AvgRange+=dK*MathAbs(High[bar+iii]-Low[bar+iii]);
        }
      ATR=AvgRange/PeriodATR;

      if(Close[bar]>Up+Brick)
        {
         if(Brick) Up+=MathRound((Close[bar]-Up)/Brick)*Brick;
         Brick=Katr*ATR;
         Dn=Up-Brick;
        }

      if(Close[bar]<Dn-Brick)
        {
         if(Brick) Dn-=MathRound((Dn-Close[bar])/Brick)*Brick;
         Brick=Katr*ATR;
         Up=Dn+Brick;
        }

      UpBuffer[bar]=Up;
      DnBuffer[bar]=Dn;

      //---- saving values of variables
      if(bar)
        {
         Up_=Up;
         Dn_=Dn;
         Brick_=Brick;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
