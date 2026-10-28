//+------------------------------------------------------------------+ 
//|                                         SymmetricDarvasBoxes.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 2 
//---- 2 plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- blue color is used as the color of the indicator line
#property indicator_color1 Blue
//---- the indicator line is a solid one
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "Upper Symmetric DarvasBoxes"

//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- blue color is used as the color of the indicator line
#property indicator_color2 Magenta
//---- the indicator line is a solid one
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width2  2
//---- displaying the indicator label
#property indicator_label2  "Lower Symmetric DarvasBoxes"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int CPeriod=5;
input int StartShift=0; //Period counting start shift
input int Shift=0; // Horizontal shift of the indicator in bars
//---+
//---- indicator buffers
double UpperBuffer[];
double LowerBuffer[];
//---- declaration of the integer variables for the start of data calculation
int start=2,StartShift_;
//+------------------------------------------------------------------+    
//| DarvasBoxes initialization function                              | 
//+------------------------------------------------------------------+  
void OnInit()
  {
   if(StartShift>=CPeriod) StartShift_=int(MathMod(StartShift,CPeriod));
   else StartShift_=StartShift;
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by AroonShift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
//---- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Upper Symmetric DarvasBoxes");
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(UpperBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,LowerBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,start);
//---- create label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Lower Symmetric DarvasBoxes");
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(LowerBuffer,true);

//---- initializations of a variable for the indicator short name
   string shortname="Symmetric DarvasBoxes";
//---- creating name for displaying if separate sub-window and in tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| DarvasBoxes iteration function                                   | 
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
//---- checking the number of bars to be enough for the calculation
   if(rates_total<start) return(0);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- declaration of local variables
   int limit,bar;
   double High,Low;
//---- declaration of static variables
   static int state,STATE;
   static double box_top,box_bottom,BOX_TOP,BOX_BUTTOM;

//---- calculations of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-start; // starting index for calculation of all bars
      BOX_TOP=high[limit+1];
      BOX_BUTTOM=low[limit+1];
      STATE=StartShift_;
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
     }

//---- restore values of the variables
   state=STATE;
   box_top=BOX_TOP;
   box_bottom=BOX_BUTTOM;

//---- main indicator calculation loop    
   for(bar=limit; bar>=0; bar--)
     {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==0)
        {
         STATE=state;
         BOX_TOP=box_top;
         BOX_BUTTOM=box_bottom;
        }

      High=high[bar];
      Low=low[bar];

      if(state<CPeriod)
        {
         if(box_top<=High) box_top=High;
         if(box_bottom>=Low) box_bottom=Low;
        }
      else
        {
         box_top=High;
         box_bottom=Low;
         state=0;
        }

      UpperBuffer[bar] = box_top;
      LowerBuffer[bar] = box_bottom;
      if(bar!=limit)state++;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
