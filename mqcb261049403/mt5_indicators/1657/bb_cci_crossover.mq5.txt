//+------------------------------------------------------------------+
//|                                             BB_CCI_CrossOver.mq5 |
//|                            Copyright © 2009, Daniel Vieira Costa |
//|                             http://www.seilatrader.blogspot.com/ |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2009, Daniel Vieira Costa"
//---- link to the website of the author
#property link      "http://www.seilatrader.blogspot.com/"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- magenta color is used as the color of the bearish indicator line
#property indicator_color1  clrMagenta
//---- indicator 1 line width is equal to 4
#property indicator_width1  4
//---- displaying of the bullish label of the indicator
#property indicator_label1  "BB_CCI_CrossOver Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a symbol
#property indicator_type2   DRAW_ARROW
//---- green color is used as the color of the bullish line of the indicator
#property indicator_color2  clrLime
//---- thickness of the indicator 2 line is equal to 4
#property indicator_width2  4
//---- displaying of the bearish label of the indicator
#property indicator_label2 "BB_CCI_CrossOver Buy"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // The constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input int    CCI_Period    = 21;
input double NivelCCI_MIN  = -80;
input double NivelCCI_MAX  = +80;
input int    MM_Period     = 14;
input int    BB_Period     = 21;
input double BB_Desvio     = 2.0;
input uint   PIP_DesvioMAX = 10;
input uint   PIP_DesvioMIN = 10;
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//---
double dPIP_DesvioMAX,dPIP_DesvioMIN;
int CCI_Handle,ATR_Handle,BB_Handle,min_rates_total;
//+------------------------------------------------------------------+
// CMoving_Average class description                                 |
//+------------------------------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables 
   min_rates_total=int(MathMax(MathMax(CCI_Period,BB_Period),10));
   dPIP_DesvioMAX=PIP_DesvioMAX*_Point;
   dPIP_DesvioMIN=PIP_DesvioMIN*_Point;
//---- получение хендла индикатора CCI
   CCI_Handle=iCCI(NULL,0,CCI_Period,PRICE_WEIGHTED);
   if(ATR_Handle==INVALID_HANDLE)Print(" Failed to get handle of the CCI indicator");
//---- getting handle of the Bands indicator
   BB_Handle=iBands(NULL,0,BB_Period,0,BB_Desvio,PRICE_WEIGHTED);
   if(ATR_Handle==INVALID_HANDLE)Print(" Failed to get handle of the Bands indicator");
//---- getting handle of the ATR indicator
   ATR_Handle=iATR(NULL,0,10);
   if(ATR_Handle==INVALID_HANDLE)Print(" Failed to get handle of the ATR indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SellBuffer,true);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 2 drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(BuyBuffer,true);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- data window name and subwindow label 
   string short_name="BB_CCI_CrossOver";
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
//---- checking for the sufficiency of the number of bars for the calculation
   if(BarsCalculated(CCI_Handle)<rates_total
      || BarsCalculated(BB_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables 
   int to_copy,limit,bar,maxbar;
   double range,MM,UpBB[],DnBB[],CCI[],ATR[];
   
   maxbar=rates_total-1-CCI_Period;

//---- calculations of the necessary amount of data to be copied and
//the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=maxbar;  // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(CCI_Handle,0,0,to_copy,CCI)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   if(CopyBuffer(BB_Handle,UPPER_BAND,0,to_copy,UpBB)<=0) return(RESET);
   if(CopyBuffer(BB_Handle,LOWER_BAND,0,to_copy,DnBB)<=0) return(RESET);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(CCI,true);
   ArraySetAsSeries(UpBB,true);
   ArraySetAsSeries(DnBB,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- declaration of the CMoving_Average class variables from the SmoothAlgorithms.mqh file 
   static CMoving_Average EMA;

//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      range=ATR[bar]*3/8;
      MM=EMA.EMASeries(maxbar,prev_calculated,rates_total,MM_Period,CCI[bar],bar,true);

      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;

      if(CCI[bar]>NivelCCI_MAX)
        {
         if(CCI[bar]<MM)
           {
            if(high[bar]<=UpBB[bar])
              {
               if(high[bar+1]>high[bar]) if(UpBB[bar]-high[bar]<=dPIP_DesvioMAX) SellBuffer[bar]=high[bar]+range;
              }
            else if(high[bar]>=UpBB[bar]) if(high[bar+1]>high[bar]) SellBuffer[bar]=high[bar]+range;
           }
        }

      if(CCI[bar]<NivelCCI_MIN)
        {
         if(CCI[bar]>MM)
           {
            if(low[bar]>=DnBB[bar])
              {
               if(low[bar+1]<low[bar]) if(low[bar]-DnBB[bar]<=dPIP_DesvioMIN) BuyBuffer[bar]=low[bar]-range;
              }
            else if(low[bar]<=DnBB[bar]) if(low[bar+1]<low[bar]) BuyBuffer[bar]=low[bar]-range;
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
