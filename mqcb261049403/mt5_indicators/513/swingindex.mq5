//+---------------------------------------------------------------------+
//|                                                      SwingIndex.mq5 | 
//|                                Copyright © 2011,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+
//| For the indicator to work, place the file SmoothAlgorithms.mqh      |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- gold color is used for the indicator line
#property indicator_color1 Gold
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "SwingIndex"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input double T=30000; // Scaling ratio
input int Shift=0;    // Horizontal shift of the indicator in bars
//---- declaration of a dynamic array that further 
//---- will be used as an indicator buffer
double SWINGINDEX[];
//---- declaration of the integer variables for the start of data calculation
int StartBars=1;
//+------------------------------------------------------------------+   
//| SwingIndex indicator initialization function                     | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- set SWINGINDEX[] dynamic array as an indicator buffer
   SetIndexBuffer(0,SWINGINDEX,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"SwingIndex( ",DoubleToString(T,2)," )");
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| SwingIndex iteration function                                    | 
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
   double O,O1,C,C1,H,L,K,TR,SH1,SI,ER,R;
//---- declaration of integer variables and getting calculated bars
   int first,bar;
//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
      first=1;                                           // starting index for calculation of all bars
   else first=prev_calculated-1;                         // starting index for calculation of new bars
//---- main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      O=open[bar];
      O1=open[bar-1];
      C=close[bar];
      C1=close[bar-1];
      H=high[bar];
      L=low[bar];

      K=MathMax(MathAbs(H-C1),MathAbs(L-C1));
      TR=MathMax(MathMax(MathAbs(H-C1),MathAbs(L-C1)),MathAbs(H-L));

      ER=0;
      if(C1 > H) ER = MathAbs(H - C1);
      if(C1 < L) ER = MathAbs(L - C1);

      SH1=MathAbs(C1-O1);
      R=TR-0.5*ER+0.25*SH1;
      SI=0;
      if (R!=0) SI=50*((C-C1)+0.5*(C-O)+0.25*(C1-O1))*(K/T)/R;
      SWINGINDEX[bar]=SI;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
