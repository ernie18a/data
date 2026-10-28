//+------------------------------------------------------------------+
//|                                                 WPRSI signal.mq4 |
//|                                         Copyright © 2009, gumgum |
//|                                           1967policmen@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, gumgum"
//---- link to the website of the author
#property link      "1967policmen@gmail.com"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- magenta color is used for the bearish indicator
#property indicator_color1  Magenta
//---- indicator 1 line width is equal to 4
#property indicator_width1  4
//---- displaying the indicator label
#property indicator_label1  "WPRSI signal Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a label
#property indicator_type2   DRAW_ARROW
//---- lime color is used as the color of the bullish indicator
#property indicator_color2  Lime
//---- indicator 2 line width is equal to 4
#property indicator_width2  4
//---- displaying the indicator label
#property indicator_label2 "WPRSI signal Buy"
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int WPRSI_period=27;
input int filterUP=10;
input int filterDN=10;
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//---
int WPR_Handle,RSI_Handle;
int min_rates_total,FilterMax;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of variables of the start of data calculation 
   FilterMax=2+MathMax(filterUP,filterDN);
   min_rates_total=WPRSI_period+FilterMax;

//---- getting handle of the WPR indicator
   WPR_Handle=iWPR(NULL,0,WPRSI_period);
   if(WPR_Handle==INVALID_HANDLE) Print(" Failed to get handle of the WPR indicator");

//---- getting handle of the Stochastic indicator
   RSI_Handle=iRSI(NULL,0,WPRSI_period,PRICE_CLOSE);
   if(RSI_Handle==INVALID_HANDLE)Print(" Failed to get handle of the RSI indicator");

//---- set SellBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(SellBuffer,true);

//---- set BuyBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(BuyBuffer,true);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="WPRSI signal";
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
   if(BarsCalculated(WPR_Handle)<rates_total
      || BarsCalculated(RSI_Handle)<rates_total
      || rates_total<min_rates_total)
      return(0);

//---- declaration of local variables 
   int to_copy,limit,bar;
   double WPR[],RSI[];

//---- calculations of the necessary amount of data to be copied
//---- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // calculated number of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
     }

//--- copy newly appeared data in the arrays  
   to_copy=limit+1;
   if(CopyBuffer(RSI_Handle,0,0,to_copy,RSI)<=0) return(0);
   to_copy+=FilterMax;
   if(CopyBuffer(WPR_Handle,0,0,to_copy,WPR)<=0) return(0);

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(WPR,true);
   ArraySetAsSeries(RSI,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0; bar--)
     {
      BuyBuffer[bar]=EMPTY_VALUE;
      SellBuffer[bar]=EMPTY_VALUE;

      if(WPR[bar]>-20 && WPR[bar+1]<-20 && RSI[bar]>50)
        {
         double z=0;
         for(int k=2;k<=filterUP+2;k++) if(WPR[bar+k]>-20) z=1;

         if(z==0) BuyBuffer[bar]=low[bar]-(high[bar]-low[bar])/2;
        }

      if(WPR[bar+1]>-80 && WPR[bar]<-80 && RSI[bar]<50)
        {
         double h=0;
         for(int c=2;c<=filterDN+2;c++) if(WPR[bar+c]<-80) h=1;

         if(h==0) SellBuffer[bar]=high[bar]+(high[bar]-low[bar])/2;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
