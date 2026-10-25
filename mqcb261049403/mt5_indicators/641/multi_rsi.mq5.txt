//+------------------------------------------------------------------+
//|                                                    Multi_RSI.mq5 |
//|                           Copyright © 2009,   Andrey Matvievskiy | 
//|                                                                  | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Andrey Matvievskiy"
#property link ""
#property description "Multi RSI"
//---- indicator version
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- eight buffers are used for calculation and drawing the indicator
#property indicator_buffers 8
//---- eight graphical plots are used in total
#property indicator_plots   8
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_LINE
//---- red color is used for indicator line
#property indicator_color1  Red
//---- indicator 1 line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "RSI 1"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- use orange color for the indicator line
#property indicator_color2  Orange
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator line label
#property indicator_label2 "RSI 2"
//+----------------------------------------------+
//|  Indicator 3 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_LINE
//---- use gold color for the indicator line
#property indicator_color3  Gold
//---- indicator 3 line width is equal to 1
#property indicator_width3  1
//---- displaying the indicator line label
#property indicator_label3  "RSI 3"
//+----------------------------------------------+
//|  Indicator 4 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 4 as a symbol
#property indicator_type4   DRAW_LINE
//---- lime color is used as the color of the indicator line
#property indicator_color4  Lime
//---- indicator 4 line width is equal to 1
#property indicator_width4  1
//---- displaying the indicator line label
#property indicator_label4 "RSI 4"
//+----------------------------------------------+
//|  Indicator 5 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 5 as a symbol
#property indicator_type5   DRAW_LINE
//---- aqua color is used as the color of the indicator line
#property indicator_color5  Aqua
//---- indicator 5 line width is equal to 1
#property indicator_width5  1
//---- displaying the indicator line label
#property indicator_label5  "RSI 5"
//+----------------------------------------------+
//|  Indicator 6 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 6 as a symbol
#property indicator_type6   DRAW_LINE
//---- blue color is used for the indicator line
#property indicator_color6  Blue
//---- indicator 6 line width is equal to 1
#property indicator_width6  1
//---- displaying the indicator line label
#property indicator_label6 "RSI 6"
//+----------------------------------------------+
//|  Indicator 7 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 7 as a symbol
#property indicator_type7   DRAW_LINE
//---- purple color is used as the color of the indicator line
#property indicator_color7  Purple
//---- indicator 7 line width is equal to 1
#property indicator_width7  1
//---- displaying the indicator line label
#property indicator_label7  "RSI 7"
//+----------------------------------------------+
//|  Indicator 8 drawing parameters              |
//+----------------------------------------------+
//---- drawing the indicator 8 as a symbol
#property indicator_type8   DRAW_LINE
//---- silver color is used as the color of the indicator line
#property indicator_color8  Silver
//---- indicator 8 line width is equal to 1
#property indicator_width8  1
//---- displaying the indicator line label
#property indicator_label8 "RSI 8"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1 70.0
#property indicator_level2 50.0
#property indicator_level3 30.0
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Window borders fixing parameters             |
//+----------------------------------------------+
#property indicator_minimum   0
#property indicator_maximum 100
//+----------------------------------------------+
#define RESET 0 // The constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int RSI_Period1=2;
input ENUM_APPLIED_PRICE RSI_Price1=PRICE_CLOSE;

input int RSI_Period2=4;
input ENUM_APPLIED_PRICE RSI_Price2=PRICE_CLOSE;

input int RSI_Period3=3;
input ENUM_APPLIED_PRICE RSI_Price3=PRICE_CLOSE;

input int RSI_Period4=6;
input ENUM_APPLIED_PRICE RSI_Price4=PRICE_CLOSE;

input int RSI_Period5=4;
input ENUM_APPLIED_PRICE RSI_Price5=PRICE_CLOSE;

input int RSI_Period6=8;
input ENUM_APPLIED_PRICE RSI_Price6=PRICE_CLOSE;

input int RSI_Period7=5;
input ENUM_APPLIED_PRICE RSI_Price7=PRICE_CLOSE;

input int RSI_Period8=10;
input ENUM_APPLIED_PRICE RSI_Price8=PRICE_CLOSE;
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double Buffer5[];
double Buffer6[];
double Buffer7[];
double Buffer8[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of integer variables for the indicators handles
int RSI_Handle[8];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=MathMax(RSI_Period1,MathMax(RSI_Period2,MathMax(RSI_Period3,MathMax(RSI_Period4,
                           MathMax(RSI_Period5,MathMax(RSI_Period6,MathMax(RSI_Period7,RSI_Period8)))))))+1;

//---- getting handle of the iRSI 1 indicator
   RSI_Handle[0]=iRSI(NULL,0,RSI_Period1,RSI_Price1);
   if(RSI_Handle[0]==INVALID_HANDLE) { Print(" Failed to get handle of the iRSI 1 indicator"); return(1);}
//---- getting handle of the iRSI 2 indicator
   RSI_Handle[1]=iRSI(NULL,0,RSI_Period2,RSI_Price2);
   if(RSI_Handle[1]==INVALID_HANDLE) { Print(" Failed to get handle of the iRSI 2 indicator"); return(1);}
//---- getting handle of the iRSI 3 indicator
   RSI_Handle[2]=iRSI(NULL,0,RSI_Period3,RSI_Price3);
   if(RSI_Handle[2]==INVALID_HANDLE) { Print(" Failed to get handle of the iRSI 3 indicator"); return(1);}
//---- getting handle of the iRSI 4 indicator
   RSI_Handle[3]=iRSI(NULL,0,RSI_Period4,RSI_Price4);
   if(RSI_Handle[3]==INVALID_HANDLE) { Print(" Failed to get handle of the iRSI 4 indicator"); return(1);}
//---- getting handle of the iRSI 5 indicator
   RSI_Handle[4]=iRSI(NULL,0,RSI_Period5,RSI_Price5);
   if(RSI_Handle[4]==INVALID_HANDLE) { Print(" Failed to get handle of the iRSI 5 indicator"); return(1);}
//---- getting handle of the iRSI 6 indicator
   RSI_Handle[5]=iRSI(NULL,0,RSI_Period6,RSI_Price6);
   if(RSI_Handle[5]==INVALID_HANDLE) { Print(" Failed to get handle of the iRSI 6 indicator"); return(1);}
//---- getting handle of the iRSI 7 indicator
   RSI_Handle[6]=iRSI(NULL,0,RSI_Period7,RSI_Price7);
   if(RSI_Handle[6]==INVALID_HANDLE) { Print(" Failed to get handle of the iRSI 7 indicator"); return(1);}
//---- getting handle of the iRSI 8 indicator
   RSI_Handle[7]=iRSI(NULL,0,RSI_Period8,RSI_Price8);
   if(RSI_Handle[7]==INVALID_HANDLE) { Print(" Failed to get handle of the iRSI 8 indicator"); return(1);}

//---- set Buffer1[] dynamic array as an indicator buffer
   SetIndexBuffer(0,Buffer1,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,RSI_Period1);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,233);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(Buffer1,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set Buffer2[] dynamic array as an indicator buffer
   SetIndexBuffer(1,Buffer2,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,RSI_Period2);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,234);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(Buffer2,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- set Buffer3[] dynamic array as an indicator buffer
   SetIndexBuffer(2,Buffer3,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,RSI_Period3);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,233);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(Buffer3,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- set Buffer4[] dynamic array as an indicator buffer
   SetIndexBuffer(3,Buffer4,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,RSI_Period4);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,234);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(Buffer4,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//---- set Buffer5[] dynamic array as an indicator buffer
   SetIndexBuffer(4,Buffer5,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 5
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,RSI_Period5);
//---- indicator symbol
   PlotIndexSetInteger(4,PLOT_ARROW,233);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(Buffer5,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);

//---- set Buffer6[] dynamic array as an indicator buffer
   SetIndexBuffer(5,Buffer6,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 6
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,RSI_Period6);
//---- indicator symbol
   PlotIndexSetInteger(5,PLOT_ARROW,234);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(Buffer6,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);

//---- set Buffer7[] dynamic array as an indicator buffer
   SetIndexBuffer(6,Buffer7,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 7
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,RSI_Period7);
//---- indicator symbol
   PlotIndexSetInteger(6,PLOT_ARROW,233);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(Buffer7,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,0);

//---- set Buffer8[] dynamic array as an indicator buffer
   SetIndexBuffer(7,Buffer8,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 8
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,RSI_Period8);
//---- indicator symbol
   PlotIndexSetInteger(7,PLOT_ARROW,234);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(Buffer8,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,0);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for tooltips 
   string short_name="Multi RSI";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
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
   for(int numb=0; numb<8; numb++) if(BarsCalculated(RSI_Handle[numb])<rates_total) return(RESET);
   if(rates_total<min_rates_total) return(RESET);

//---- declarations of local variables 
   int to_copy;

//---- calculations of the necessary amount of data to be copied
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      to_copy=rates_total-1;                   // starting index for calculation of all bars
   else to_copy=rates_total-prev_calculated+1; // starting index for calculation of new bars
   
//--- copy newly appeared data in the arrays
   if(CopyBuffer(RSI_Handle[0],0,0,to_copy,Buffer1)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[1],0,0,to_copy,Buffer2)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[2],0,0,to_copy,Buffer3)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[3],0,0,to_copy,Buffer4)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[4],0,0,to_copy,Buffer5)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[5],0,0,to_copy,Buffer6)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[6],0,0,to_copy,Buffer7)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[7],0,0,to_copy,Buffer8)<=0) return(RESET);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
