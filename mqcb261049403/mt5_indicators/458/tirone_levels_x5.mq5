//+------------------------------------------------------------------+
//|                                             Tirone Levels_X5.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "5 Tirone Levels"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers 5
#property indicator_buffers 5 
//---- only 5 plots are used 
#property indicator_plots   5

//+---------------------------------------------+
//|  Parameters of the indicator levels drawing |
//+---------------------------------------------+
//---- drawing Tirone levels as lines
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
//---- selecting Tirone levels colors
#property indicator_color1  Green
#property indicator_color2  Lime
#property indicator_color3  Gold
#property indicator_color4  Red
#property indicator_color5  Brown
//---- Tirone levels are dot-dash curves
#property indicator_style1 STYLE_DASHDOTDOT
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_style5 STYLE_DASHDOTDOT
//---- Tirone levels width is equal to 1
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  1
#property indicator_width4  1
#property indicator_width5  1
//---- displaying Tirone levels labels
#property indicator_label1  "Upper Tirone Level"
#property indicator_label2  "Upper/Middle Tirone Level"
#property indicator_label3  "Middle Tirone Level"
#property indicator_label4  "Lower/Middle Tirone Level"
#property indicator_label5  "Lower Tirone Level"

//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int TirPeriod=15;  //Period of the indicator
input int Shift=0;       //Horizontal shift of the indicator in bars
//+-----------------------------------+

//---- declaration of dynamic arrays that
// will be used as Tirone levels indicator buffers
double ExtLineBuffer1[],ExtLineBuffer2[],
ExtLineBuffer3[],ExtLineBuffer4[],ExtLineBuffer5[];

//---- Declaration of the Tirone levels proportion variable
double quotient;

//---- Declaration of the integer variables for the start of data calculation
int StartBars;
//+------------------------------------------------------------------+   
//| Tirone Levels indicator initialization function                  | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   StartBars=TirPeriod+1;

//---- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLineBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,ExtLineBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,ExtLineBuffer5,INDICATOR_DATA);
//---- set the position, from which the Tirone levels drawing starts
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,StartBars);
//---- create labels to display in Data Window
   PlotIndexSetString(0,PLOT_LABEL,"Upper Tirone Level");
   PlotIndexSetString(1,PLOT_LABEL,"Upper/Middle Tirone Level");
   PlotIndexSetString(2,PLOT_LABEL,"Middle Tirone Level");
   PlotIndexSetString(3,PLOT_LABEL,"Lower/Middle Tirone Level");
   PlotIndexSetString(4,PLOT_LABEL,"Lower Tirone Level");
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- horizontal shift of the indicator
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"5 Tirone Levels(",string(TirPeriod),")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| Tirone Levels iteration function                                 | 
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
//---- checking the number of bars to be enough for the calculation
   if(rates_total<StartBars) return(0);

//---- declaration of variables with a floating point  
   double Hhigh,Llow,AdjMean,Upper,UpMiddle,LoMiddle,Lower;
//---- declaration of integer variables
   int first,bar;

//---- calculate the first starting index for loop of bars recalculation and variables initialization
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=StartBars; // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- main calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      Hhigh=high[iHighest(high,TirPeriod,bar)];
      Llow=low[iLowest(low,TirPeriod,bar)];
      //----
      AdjMean=(Hhigh+Llow+close[bar])/3.0;
      Upper=AdjMean+(Hhigh-Llow);
      UpMiddle = 2 * AdjMean - Llow;
      LoMiddle = 2 * AdjMean - Hhigh;
      Lower=AdjMean -(Hhigh-Llow);
      //----
      ExtLineBuffer1[bar] = Upper;
      ExtLineBuffer2[bar] = UpMiddle;
      ExtLineBuffer3[bar] = AdjMean;
      ExtLineBuffer4[bar] = LoMiddle;
      ExtLineBuffer5[bar] = Lower;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  searching index of the highest bar                              |
//+------------------------------------------------------------------+
int iHighest(const double &array[], // array for searching for maximum element index
             int count,             // the number of the array elements for searching (from a current bar to the index descending) 
             int startPos)          // the index of the initial bar (shift relative to a current bar), from which the searching starts
  {
//----
   int index=startPos;

//---- checking correctness of the initial index
   if(startPos<0)
     {
      Print("Bad value in the iHighest function, startPos = ",startPos);
      return(0);
     }

//---- checking correctness of startPos value
   if(startPos-count<0) count=startPos;

   double max=array[startPos];

//---- searching for an index
   for(int i=startPos; i>startPos-count; i--)
     {
      if(array[i]>max)
        {
         index=i;
         max=array[i];
        }
     }
//---- returning of the greatest bar index
   return(index);
  }
//+------------------------------------------------------------------+
//|  searching index of the lowest bar                               |
//+------------------------------------------------------------------+
int iLowest(const double &array[], // array for searching for minimum element index
            int count,            // the number of the array elements for searching (from a current bar to the index descending) 
            int startPos)         // the index of the initial bar (shift relative to a current bar), from which the searching starts
  {
//----
   int index=startPos;

//---- checking correctness of the initial index
   if(startPos<0)
     {
      Print("Bad value in the iLowest function, startPos = ",startPos);
      return(0);
     }

//---- checking correctness of startPos value
   if(startPos-count<0)
      count=startPos;

   double min=array[startPos];

//---- searching for an index
   for(int i=startPos; i>startPos-count; i--)
     {
      if(array[i]<min)
        {
         index=i;
         min=array[i];
        }
     }
//---- returning of the lowest bar index
   return(index);
  }
//+------------------------------------------------------------------+
