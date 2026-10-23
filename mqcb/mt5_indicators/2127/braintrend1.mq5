//+------------------------------------------------------------------+
//|                                                  BrainTrend1.mq4 |
//|                               Copyright © 2005, BrainTrading Inc |
//|                                      http://www.braintrading.com |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2005, BrainTrading Inc."
//---- link to the website of the author
#property link      "http://www.braintrading.com/"
//---- Indicator Version Number
#property version   "1.00"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator in the main window
#property indicator_chart_window 
//----five buffers are used for calculation and drawing the indicator
#property indicator_buffers 5
//---- only one plot is used
#property indicator_plots   1
//---- color candlesticks are used as an indicator
#property indicator_type1   DRAW_COLOR_CANDLES
//---- displaying labels of the indicator
#property indicator_label1  "Flat; UpTend; DownTrend;"

//+----------------------------------------------+
//| Input parameters of the indicator            |
//+----------------------------------------------+
input int ATR_Period=7; //Period of ATR 
input int STO_Period=9; //Period of Stochastic
input ENUM_MA_METHOD MA_Method = MODE_SMA; //Method of averaging
input ENUM_STO_PRICE STO_Price = STO_LOWHIGH; //Method of prices calculation 
//+----------------------------------------------+

//---- declaration of dynamic arrays that further 
// will be used as indicator buffers
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorsBuffer[];
//---
double d;
int p,x1,x2,P_,StartBars;
int ATR_Handle,STO_Handle;
//---
color ExtColor[3]={CLR_NONE,Blue,Red};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- initialization of global variables 
   d=2.3;
   x1 = 53;
   x2 = 47;
   StartBars=MathMax(ATR_Period,STO_Period)+2;
//---- getting handle of the ATR indicator
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)Print(" Failed to get handle of the ATR indicator");
//---- getting handle of the Stochastic indicator
   STO_Handle=iStochastic(NULL,0,STO_Period,STO_Period,1,MA_Method,STO_Price);
   if(STO_Handle==INVALID_HANDLE)Print(" Failed to get handle of the Stochastic indicator");
   
//---- converting dynamic arrays into indicator buffers
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- turning a dynamic array into a color index buffer   
   SetIndexBuffer(4,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,StartBars);
//---- indexation of elements in buffers as in timeseries   
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorsBuffer,true);
//--- set colors quantity 3 for the color buffer
   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,3);
//--- set colors for the color buffer
   for(int i=0; i<3; i++)
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,i,ExtColor[i]);
//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and for the label of sub-windows 
   string short_name="BrainTrend1";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
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
   if(BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(STO_Handle)<rates_total
      || rates_total<StartBars)
      return(0);

//---- declaration of local variables 
   int to_copy,limit,bar;
   double value2[],Range[],range,val1,val2,val3;

//--- calculations of the necessary amount of data to be copied and
//----the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      to_copy=rates_total; // calculated number of all bars
      limit=rates_total-StartBars; // starting number for calculation of all bars
     }
   else
     {
      to_copy=rates_total-prev_calculated+1; // calculated number of new bars
      limit=rates_total-prev_calculated; // starting number for calculation of new bars
     }

//---- copy the newly appeared data into the Range[] and value2[] arrays
   if(CopyBuffer(ATR_Handle,0,0,to_copy,Range)<=0) return(0);
   if(CopyBuffer(STO_Handle,0,0,to_copy,value2)<=0) return(0);

//---- indexing elements in arrays, as in timeseries  
   ArraySetAsSeries(Range,true);
   ArraySetAsSeries(value2,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- restore values of the variables
   p=P_;

//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0; bar--)
     {
      //---- memorize values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==0)
         P_=p;

      range= Range[bar]/d;
      val1 = 0.0;
      val2 = 0.0;
      ExtOpenBuffer[bar]=0.0;
      ExtHighBuffer[bar]=0.0;
      ExtLowBuffer[bar]=0.0;
      ExtCloseBuffer[bar]=0.0;
      ExtColorsBuffer[bar]=0;

      val3=MathAbs(close[bar]-close[bar+2]);
      if(value2[bar] < x2 && val3 > range) p = 1;
      if(value2[bar] > x1 && val3 > range) p = 2;

      if(val3<=range) continue;

      if(value2[bar]<x2 && (p==1 || p==0))
        {
         ExtOpenBuffer[bar]=open[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtColorsBuffer[bar]=2;
        }
      if(value2[bar]>x1 && (p==2 || p==0))
        {
         ExtOpenBuffer[bar]=open[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtColorsBuffer[bar]=1;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
