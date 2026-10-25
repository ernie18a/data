//+------------------------------------------------------------------+
//|                                         Cam_H2_H5_Historical.mq5 |
//|                                          Copyright © 2005, MrPip |
//|                                                                  |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2005, MrPip"
//---- link to the website of the author
#property link      ""
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- number of indicator buffers 9
#property indicator_buffers 9
//---- 9 graphical plots are used in total
#property indicator_plots   9
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- Teal color is used for the indicator line
#property indicator_color1 clrTeal
//---- the indicator line width
#property indicator_width1  2
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- displaying the indicator label
#property indicator_label1  " Camarilla +0.55"
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- Blue color is used for the indicator line
#property indicator_color2 clrBlue
//---- the indicator line width
#property indicator_width2  1
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_DASHDOTDOT
//---- displaying the indicator label
#property indicator_label2  " Camarilla +0.2750"
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type3   DRAW_LINE
//---- Magenta color is used as the color of the indicator line
#property indicator_color3 clrMagenta
//---- the indicator line width
#property indicator_width3  1
//---- the indicator line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- displaying the indicator label
#property indicator_label3  " Camarilla +0.183333"
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type4   DRAW_LINE
//---- Blue color is used for the indicator line
#property indicator_color4 clrBlue
//---- the indicator line width
#property indicator_width4  1
//---- the indicator line is a continuous curve
#property indicator_style4  STYLE_DASHDOTDOT
//---- displaying the indicator label
#property indicator_label4  " Camarilla +0.091667"
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type5   DRAW_LINE
//---- Orange color is used as the color of the indicator line
#property indicator_color5 clrOrange
//---- the indicator line width
#property indicator_width5  3
//---- the indicator line is a continuous curve
#property indicator_style5  STYLE_SOLID
//---- displaying the indicator label
#property indicator_label5  " Camarilla Pivot"
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type6   DRAW_LINE
//---- Blue color is used for the indicator line
#property indicator_color6 clrBlue
//---- the indicator line width
#property indicator_width6  1
//---- the indicator line is a continuous curve
#property indicator_style6  STYLE_DASHDOTDOT
//---- displaying the indicator label
#property indicator_label6  " Camarilla -0.091667"
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type7   DRAW_LINE
//---- Magenta color is used as the color of the indicator line
#property indicator_color7 clrMagenta
//---- the indicator line width
#property indicator_width7  1
//---- the indicator line is a continuous curve
#property indicator_style7  STYLE_SOLID
//---- displaying the indicator label
#property indicator_label7  " Camarilla -0.183333"
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type8   DRAW_LINE
//---- Blue color is used for the indicator line
#property indicator_color8 clrBlue
//---- the indicator line width
#property indicator_width8  1
//---- the indicator line is a continuous curve
#property indicator_style8  STYLE_DASHDOTDOT
//---- displaying the indicator label
#property indicator_label8  " Camarilla -0.2750"
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type9   DRAW_LINE
//---- Teal color is used for the indicator line
#property indicator_color9 clrTeal
//---- the indicator line width
#property indicator_width9  2
//---- the indicator line is a continuous curve
#property indicator_style9  STYLE_SOLID
//---- displaying the indicator label
#property indicator_label9  " Camarilla -0.55"
//+-----------------------------------+
//|  declaration of constants         |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input double PD4=0.55;
input double PD3=0.2750;
input double PD2=0.183333;
input double PD1=0.091667;
input double MD1=0.091667;
input double MD2=0.183333;
input double MD3=0.2750;
input double MD4=0.55;

input int GMTshift=0;
input int iShift=0; // horizontal shift of the indicator in bars
//+-----------------------------------+
double prev_high;
double prev_low;
double prev_close;
double cur_day;
double prev_day;
double day_high;
double day_low;
double range;
double P,H2,H3,H4,H5,L2,L3,L4,L5;
//---- Declaration of integer variables of data starting point
int min_rates_total,Shift,GMTshift3600;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double IndBuffer0[],IndBuffer1[],IndBuffer2[],IndBuffer3[],IndBuffer4[],IndBuffer5[],IndBuffer6[],IndBuffer7[],IndBuffer8[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- checking correctness of the chart periods
   if(Period()>PERIOD_H8)
     {
      Print("Период графика для индикатора Cam_H2_H5_Historical не может быть больше периода H8");
      return;
     }
//---- Initialization of variables of data calculation starting point
   Shift=iShift+1;
   GMTshift3600=GMTshift*3600;
   min_rates_total=1+3+GMTshift3600;

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(0,IndBuffer0,INDICATOR_DATA);
   SetIndexBuffer(1,IndBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,IndBuffer2,INDICATOR_DATA);
   SetIndexBuffer(3,IndBuffer3,INDICATOR_DATA);
   SetIndexBuffer(4,IndBuffer4,INDICATOR_DATA);
   SetIndexBuffer(5,IndBuffer5,INDICATOR_DATA);
   SetIndexBuffer(6,IndBuffer6,INDICATOR_DATA);
   SetIndexBuffer(7,IndBuffer7,INDICATOR_DATA);
   SetIndexBuffer(8,IndBuffer8,INDICATOR_DATA);

//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- indexing the elements in buffers as in timeseries   
   ArraySetAsSeries(IndBuffer0,true);
   ArraySetAsSeries(IndBuffer1,true);
   ArraySetAsSeries(IndBuffer2,true);
   ArraySetAsSeries(IndBuffer3,true);
   ArraySetAsSeries(IndBuffer4,true);
   ArraySetAsSeries(IndBuffer5,true);
   ArraySetAsSeries(IndBuffer6,true);
   ArraySetAsSeries(IndBuffer7,true);
   ArraySetAsSeries(IndBuffer8,true);

//---- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(5,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(6,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(7,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(8,PLOT_SHIFT,Shift);

//---- data window name and subwindow label 
   IndicatorSetString(INDICATOR_SHORTNAME,"Cam_H2_H5_Historical");
//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double& High[],     // price array of maximums of price for the calculation of indicator
                const double& Low[],      // price array of minimums of price for the calculation of indicator
                const double &Close[],
                const long &Tick_volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
//---- 
   if(rates_total<min_rates_total || Period()>PERIOD_H8) return(RESET);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(Time,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Close,true);

   int limit=rates_total-prev_calculated; // starting number for the calculation of new bars 

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting number for calculation of all bars
      day_low=Low[limit];
      day_high=High[limit];
     }

   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      MqlDateTime tm;
      TimeToStruct(Time[bar],tm);

      if(tm.day_of_week==SUNDAY) cur_day=prev_day;
      else
        {
         MqlDateTime tmX;
         TimeToStruct(Time[bar]-GMTshift3600,tmX);
         cur_day=tmX.day;
        }

      if(prev_day!=cur_day)
        {
         prev_close=Close[bar+1];
         prev_high=day_high;
         prev_low=day_low;
         day_high=High[bar];
         day_low =Low[bar];
         P=(prev_high+prev_low+prev_close)/3;

         range=prev_high-prev_low;
         H5=prev_close*prev_high/prev_low;
         L5=prev_close-(H5-prev_close);

         H4=prev_close+range*PD4;
         H3=prev_close+range*PD3;
         H2=prev_close+range*PD2;

         L4=prev_close-range*MD4;
         L3=prev_close-range*MD3;
         L2=prev_close-range*MD2;

         prev_day=cur_day;
        
         IndBuffer0[bar+2]=EMPTY_VALUE;
         IndBuffer1[bar+2]=EMPTY_VALUE;
         IndBuffer2[bar+2]=EMPTY_VALUE;
         IndBuffer3[bar+2]=EMPTY_VALUE;
         IndBuffer4[bar+2]=EMPTY_VALUE;
         IndBuffer5[bar+2]=EMPTY_VALUE;
         IndBuffer6[bar+2]=EMPTY_VALUE;
         IndBuffer7[bar+2]=EMPTY_VALUE;
         IndBuffer8[bar+2]=EMPTY_VALUE;
        }

      if(High[bar]>day_high) day_high=High[bar];
      if(Low[bar]<day_low) day_low=Low[bar];

      IndBuffer0[bar]=IndBuffer0[bar+1]=H5;
      IndBuffer1[bar]=IndBuffer1[bar+1]=H4;
      IndBuffer2[bar]=IndBuffer2[bar+1]=H3;
      IndBuffer3[bar]=IndBuffer3[bar+1]=H2;
      IndBuffer4[bar]=IndBuffer4[bar+1]=P;
      IndBuffer5[bar]=IndBuffer5[bar+1]=L2;
      IndBuffer6[bar]=IndBuffer6[bar+1]=L3;
      IndBuffer7[bar]=IndBuffer7[bar+1]=L4;
      IndBuffer8[bar]=IndBuffer8[bar+1]=L5;
     }
//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+
