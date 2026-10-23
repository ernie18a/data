//+------------------------------------------------------------------+
//|                                                      r_Gator.mq5 |
//|                                         Copyright © 2006, Rosych | 
//|                                                   rosych@mail.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Rosych"
#property link "rosych@mail.ru"
#property description "An analogue of Alligator with a smaller delay of signals"
//--- Indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//----three buffers are used for calculation of drawing of the indicator
#property indicator_buffers 3
//--- three plots are used
#property indicator_plots   3
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//--- red color is used as the color of the indicator line
#property indicator_color1  clrRed
//--- indicator 1 line width is equal to 2
#property indicator_width1  2
//--- displaying the indicator label
#property indicator_label1  "r_Gator Fast"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 2 as a line
#property indicator_type2   DRAW_LINE
//--- green color is used as the color of the indicator line
#property indicator_color2  clrGreen
//--- indicator 2 line width is equal to 2
#property indicator_width2  2
//--- displaying the indicator label
#property indicator_label2 "r_Gator Buy"
//+----------------------------------------------+
//|  Indicator 3 drawing parameters              |
//+----------------------------------------------+
//--- drawing indicator 3 as a line
#property indicator_type3   DRAW_LINE
//---- blue color is used for the indicator line
#property indicator_color3  clrBlue
//--- indicator 3 line width is equal to 2
#property indicator_width3  2
//--- displaying the indicator label
#property indicator_label3 "r_Gator Buy"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint period1=5;    // Fast MA period 
input uint period2=8;    // Medium MA period
input uint period3=13;   // Slow MA period
input int  Shift1=0;     // Horizontal shift of the fast MA in bars
input int  Shift2=0;     // Horizontal shift of the medium MA in bars
input int  Shift3=0;     // Horizontal shift of the slow MA in bars
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double Buffer1[],Buffer2[],Buffer3[];
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//--- declaration of integer variables for the indicators handles
int MA_Handle[3][4][7]; //[MA index][averaging method][price-1]
//+-------------------------------------------------------------------+
//|  Arrays of objects for creating multidimensional arrays of objects|
//+-------------------------------------------------------------------+  
class CArray
  {
public: double    Array[];
  };
//+------------------------------------------------------------------+
//| Creating an array of objects                                     |
//+------------------------------------------------------------------+
CArray Arr[3][4][7];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of global variables   
   min_rates_total=int(MathMax(period1,MathMax(period2,period3)));

   uint MAPeriod[3];
   MAPeriod[0]=period1;
   MAPeriod[1]=period2;
   MAPeriod[2]=period3;

//--- Getting indicator handles
   for(int i=0; i<3; i++)
      for(int k=0; k<4; k++)
         for(int r=0; r<7; r++)
           {
            MA_Handle[i][k][r]=iMA(NULL,0,MAPeriod[i],0,ENUM_MA_METHOD(k),r+1);
            if(MA_Handle[i][k][r]==INVALID_HANDLE)
              {
               Print(" Failed to get the handle of iMA");
               return(INIT_FAILED);
              }
           }

//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,Buffer1,INDICATOR_DATA);
//--- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Buffer1,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- shifting the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift1);

//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(1,Buffer2,INDICATOR_DATA);
//--- shifting the starting point of calculation of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Buffer2,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
//--- shifting the indicator 1 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift2);

//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(2,Buffer3,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Buffer3,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
//--- shifting the indicator 1 horizontally
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift3);

//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for the data window and the label for sub-windows 
   string short_name="r_Gator";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- initialization end
   return(INIT_SUCCEEDED);
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
//--- checking if the number of bars is enough for the calculation
   for(int i=0; i<3; i++)
      for(int k=0; k<4; k++)
         for(int r=0; r<7; r++)
            if(BarsCalculated(MA_Handle[i][k][r])<rates_total) return(RESET);

   if(rates_total<min_rates_total) return(RESET);

//--- declarations of local variables 
   int limit,to_copy;

//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total;   // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // Starting index for the calculation of new bars

//--- indexing elements in arrays as in timeseries 
   for(int i=0; i<3; i++)
      for(int k=0; k<4; k++)
         for(int r=0; r<7; r++)
            ArraySetAsSeries(Arr[i][k][r].Array,true);

//---   
   to_copy=limit+1;
//--- copy newly appeared data in the arrays
   for(int i=0; i<3; i++)
      for(int k=0; k<4; k++)
         for(int r=0; r<7; r++)
            if(CopyBuffer(MA_Handle[i][k][r],0,0,to_copy,Arr[i][k][r].Array)<=0) return(RESET);

//--- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Buffer1[bar]=0.0; for(int k=0; k<4; k++) for(int r=0; r<7; r++) Buffer1[bar]+=Arr[0][k][r].Array[bar]; Buffer1[bar]/=28;
      Buffer2[bar]=0.0; for(int k=0; k<4; k++) for(int r=0; r<7; r++) Buffer2[bar]+=Arr[1][k][r].Array[bar]; Buffer2[bar]/=28;
      Buffer3[bar]=0.0; for(int k=0; k<4; k++) for(int r=0; r<7; r++) Buffer3[bar]+=Arr[2][k][r].Array[bar]; Buffer3[bar]/=28;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
