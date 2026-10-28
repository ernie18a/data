//+------------------------------------------------------------------+
//|                                                   RSI_Strike.mq5 |
//|                           Copyright © 2009,   Andrey Matvievskiy | 
//|                                                                  | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Andrey Matvievskiy"
#property link ""
#property description "RSI Strike"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- eight buffers are used for calculation and drawing the indicator
#property indicator_buffers 8
//---- 8 graphical plots are used
#property indicator_plots   8
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- Aqua color is used for the indicator
#property indicator_color1  Aqua
//---- indicator 1 line width is equal to 4
#property indicator_width1  4
//---- displaying the indicator label
#property indicator_label1  "RSI_Strike 1 Buy"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- Aqua color is used for the indicator
#property indicator_color2  Aqua
//---- indicator 2 line width is equal to 4
#property indicator_width2  4
//---- displaying the indicator label
#property indicator_label2 "RSI_Strike 1 Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//---- Silver color is used for the indicator
#property indicator_color3  Silver
//---- the indicator 3 line width is equal to 4
#property indicator_width3  4
//---- displaying the indicator label
#property indicator_label3  "RSI_Strike 2 Buy"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 4 as a symbol
#property indicator_type4   DRAW_ARROW
//---- Silver color is used for the indicator
#property indicator_color4  Silver
//---- the indicator 4 line width is equal to 4
#property indicator_width4  4
//---- displaying the indicator label
#property indicator_label4 "RSI_Strike 2 Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 5 as a symbol
#property indicator_type5   DRAW_ARROW
//---- use orange color for the indicator
#property indicator_color5  Orange
//---- 5 indicator line width is equal 4
#property indicator_width5  4
//---- displaying the indicator label
#property indicator_label5  "RSI_Strike 3 Buy"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 6 as a symbol
#property indicator_type6   DRAW_ARROW
//---- use orange color for the indicator
#property indicator_color6  Orange
//---- indicator 6 line width is equal to 4
#property indicator_width6  4
//---- displaying the indicator label
#property indicator_label6 "RSI_Strike 3 Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 7 as a symbol
#property indicator_type7   DRAW_ARROW
//---- red color is used for the indicator
#property indicator_color7  Red
//---- indicator 7 line width is equal to 4
#property indicator_width7  4
//---- displaying the indicator label
#property indicator_label7  "RSI_Strike 4 Buy"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 8 as a symbol
#property indicator_type8   DRAW_ARROW
//---- red color is used for the indicator
#property indicator_color8  Red
//---- indicator 8 line width is equal to 4
#property indicator_width8  4
//---- displaying the indicator label
#property indicator_label8 "RSI_Strike 4 Sell"
//+----------------------------------------------+
#define RESET 0 // The constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int RSI_Period1=2;
input int RSI_Period2=4;
input ENUM_APPLIED_PRICE RSI_Price1=PRICE_CLOSE;
input ENUM_APPLIED_PRICE RSI_Price2=PRICE_CLOSE;

input int RSI_Period3=3;
input int RSI_Period4=6;
input ENUM_APPLIED_PRICE RSI_Price3=PRICE_CLOSE;
input ENUM_APPLIED_PRICE RSI_Price4=PRICE_CLOSE;

input int RSI_Period5=4;
input int RSI_Period6=8;
input ENUM_APPLIED_PRICE RSI_Price5=PRICE_CLOSE;
input ENUM_APPLIED_PRICE RSI_Price6=PRICE_CLOSE;

input int RSI_Period7=5;
input int RSI_Period8=10;
input ENUM_APPLIED_PRICE RSI_Price7=PRICE_CLOSE;
input ENUM_APPLIED_PRICE RSI_Price8=PRICE_CLOSE;
//+----------------------------------------------+

//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double CrossUp1[];
double CrossDown1[];
double CrossUp2[];
double CrossDown2[];
double CrossUp3[];
double CrossDown3[];
double CrossUp4[];
double CrossDown4[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of integer variables for the indicators handles
int RSI_Handle[8];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=MathMax(RSI_Period1,MathMax(RSI_Period2,MathMax(RSI_Period3,MathMax(RSI_Period4,
                           MathMax(RSI_Period5,MathMax(RSI_Period6,MathMax(RSI_Period7,RSI_Period8)))))))+1;

//---- getting handle of the iRSI 1 indicator
   RSI_Handle[0]=iRSI(NULL,0,RSI_Period1,RSI_Price1);
   if(RSI_Handle[0]==INVALID_HANDLE){Print(" Failed to get handle of the iRSI 1 indicator"); return(1); }
//---- getting handle of the iRSI 2 indicator
   RSI_Handle[1]=iRSI(NULL,0,RSI_Period2,RSI_Price2);
   if(RSI_Handle[1]==INVALID_HANDLE){Print(" Failed to get handle of the iRSI 2 indicator"); return(1); }
//---- getting handle of the iRSI 3 indicator
   RSI_Handle[2]=iRSI(NULL,0,RSI_Period3,RSI_Price3);
   if(RSI_Handle[2]==INVALID_HANDLE){Print(" Failed to get handle of the iRSI 3 indicator"); return(1); }
//---- getting handle of the iRSI 4 indicator
   RSI_Handle[3]=iRSI(NULL,0,RSI_Period4,RSI_Price4);
   if(RSI_Handle[3]==INVALID_HANDLE){Print(" Failed to get handle of the iRSI 4 indicator"); return(1); }
//---- getting handle of the iRSI 5 indicator
   RSI_Handle[4]=iRSI(NULL,0,RSI_Period5,RSI_Price5);
   if(RSI_Handle[4]==INVALID_HANDLE){Print(" Failed to get handle of the iRSI 5 indicator"); return(1); }
//---- getting handle of the iRSI 6 indicator
   RSI_Handle[5]=iRSI(NULL,0,RSI_Period6,RSI_Price6);
   if(RSI_Handle[5]==INVALID_HANDLE){Print(" Failed to get handle of the iRSI 6 indicator"); return(1); }
//---- getting handle of the iRSI 7 indicator
   RSI_Handle[6]=iRSI(NULL,0,RSI_Period7,RSI_Price7);
   if(RSI_Handle[6]==INVALID_HANDLE){Print(" Failed to get handle of the iRSI 7 indicator"); return(1); }
//---- getting handle of the iRSI 8 indicator
   RSI_Handle[7]=iRSI(NULL,0,RSI_Period8,RSI_Price8);
   if(RSI_Handle[7]==INVALID_HANDLE){Print(" Failed to get handle of the iRSI 8 indicator"); return(1); }

//---- set CrossUp1[] dynamic array as an indicator buffer
   SetIndexBuffer(0,CrossUp1,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,233);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(CrossUp1,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set CrossDown1[] dynamic array as an indicator buffer
   SetIndexBuffer(1,CrossDown1,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,234);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(CrossDown1,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- set CrossUp2[] dynamic array as an indicator buffer
   SetIndexBuffer(2,CrossUp2,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,233);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(CrossUp2,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- set CrossDown2[] dynamic array as an indicator buffer
   SetIndexBuffer(3,CrossDown2,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,234);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(CrossDown2,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//---- set CrossUp3[] dynamic array as an indicator buffer
   SetIndexBuffer(4,CrossUp3,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 5
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(4,PLOT_ARROW,233);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(CrossUp3,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);

//---- set CrossDown3[] dynamic array as an indicator buffer
   SetIndexBuffer(5,CrossDown3,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 6
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(5,PLOT_ARROW,234);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(CrossDown3,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);

//---- set CrossUp4[] dynamic array as an indicator buffer
   SetIndexBuffer(6,CrossUp4,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 7
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(6,PLOT_ARROW,233);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(CrossUp4,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,0);

//---- set CrossDown4[] dynamic array as an indicator buffer
   SetIndexBuffer(7,CrossDown4,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 8
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(7,PLOT_ARROW,234);
//---- indexing elements in the buffer as timeseries
   ArraySetAsSeries(CrossDown4,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,0);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="RSI_Strike";
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
   int to_copy,limit,bar;
   double Range,AvgRange;
   double RSI1[],RSI2[],RSI3[],RSI4[],RSI5[],RSI6[],RSI7[],RSI8[];

//---- calculations of the necessary amount of data to be copied
//---- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

   to_copy=limit+2;
//--- copy newly appeared data in the arrays
   if(CopyBuffer(RSI_Handle[0],0,0,to_copy,RSI1)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[1],0,0,to_copy,RSI2)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[2],0,0,to_copy,RSI3)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[3],0,0,to_copy,RSI4)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[4],0,0,to_copy,RSI5)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[5],0,0,to_copy,RSI6)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[6],0,0,to_copy,RSI7)<=0) return(RESET);
   if(CopyBuffer(RSI_Handle[7],0,0,to_copy,RSI8)<=0) return(RESET);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(RSI1,true);
   ArraySetAsSeries(RSI2,true);
   ArraySetAsSeries(RSI3,true);
   ArraySetAsSeries(RSI4,true);
   ArraySetAsSeries(RSI5,true);
   ArraySetAsSeries(RSI6,true);
   ArraySetAsSeries(RSI7,true);
   ArraySetAsSeries(RSI8,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      AvgRange=0.0;
      for(int count=bar; count<=bar+9; count++) AvgRange+=MathAbs(high[count]-low[count]);
      Range=AvgRange/10;

      CrossUp1[bar]=0.0;
      CrossDown1[bar]=0.0;
      CrossUp2[bar]=0.0;
      CrossDown2[bar]=0.0;
      CrossUp3[bar]=0.0;
      CrossDown3[bar]=0.0;
      CrossUp4[bar]=0.0;
      CrossDown4[bar]=0.0;

      if(RSI1[bar]>RSI2[bar] && RSI1[bar+1]<RSI2[bar+1]) CrossUp1[bar]=low[bar]-Range*0.2;
      else  if(RSI1[bar]<RSI2[bar] && RSI1[bar+1]>RSI2[bar+1]) CrossDown1[bar]=high[bar]+Range*0.2;

      if(RSI3[bar]>RSI4[bar] && RSI3[bar+1]<RSI4[bar+1]) CrossUp2[bar]=low[bar]-Range*0.4;
      else  if(RSI3[bar]<RSI4[bar] && RSI3[bar+1]>RSI4[bar+1]) CrossDown2[bar]=high[bar]+Range*0.4;

      if(RSI5[bar]>RSI6[bar] && RSI5[bar+1]<RSI6[bar+1]) CrossUp3[bar]=low[bar]-Range*0.6;
      else  if(RSI5[bar]<RSI6[bar] && RSI5[bar+1]>RSI6[bar+1]) CrossDown3[bar]=high[bar]+Range*0.6;

      if(RSI7[bar]>RSI8[bar] && RSI7[bar+1]<RSI8[bar+1]) CrossUp4[bar]=low[bar]-Range*0.8;
      else  if(RSI7[bar]<RSI8[bar] && RSI7[bar+1]>RSI8[bar+1]) CrossDown4[bar]=high[bar]+Range*0.8;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
