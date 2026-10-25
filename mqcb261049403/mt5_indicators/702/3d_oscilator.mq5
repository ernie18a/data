//+------------------------------------------------------------------+
//|                                                 3D_Oscilator.mq5 |
//+------------------------------------------------------------------+
//--- author of the indicator
#property copyright "Author - Luis Damiani. Nikolay Kositsin - Conversion only"
//--- link to the website of the author
#property link      ""
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in a separate window
#property indicator_separate_window 
//--- 4 buffers are used for calculation and drawing the indicator
#property indicator_buffers 4
//--- 4 plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Indicator 1 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator 1 as a line
#property indicator_type1   DRAW_LINE
//--- cornflowerblue color is used for the indicator line
#property indicator_color1  CornflowerBlue
//--- indicator 1 line width is equal to 1
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  "3D Oscillator"
//+----------------------------------------------+
//|  Indicator 2 drawing parameters              |
//+----------------------------------------------+
//--- drawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//--- use orange color for the indicator line
#property indicator_color2  Orange
//--- indicator 2 line width is equal to 1
#property indicator_width2  1
//--- displaying the indicator label
#property indicator_label2 "Signal line"
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//--- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//--- magenta color is used for the indicator bearish line
#property indicator_color3  Magenta
//--- the indicator 3 line width is equal to 4
#property indicator_width3  4
//--- displaying the indicator label
#property indicator_label3  "Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//--- drawing the indicator 4 as a symbol
#property indicator_type4   DRAW_ARROW
//--- lime color is used as the color of the bullish indicator line
#property indicator_color4  Lime
//--- the indicator 4 line width is equal to 4
#property indicator_width4  4
//--- displaying the indicator label
#property indicator_label4 "Buy"
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int D1RSIPer=13;
input int D2StochPer=8;
input int D3tunnelPer=8;
input double hot=0.4;
input int sigsmooth=4;
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double BuyBuffer[];
double SellBuffer[];
double IndBuffer[],SigBuffer[];
//---
double sk,sk2;
int ss,StartBars,RSI_Handle,CCI_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of global variables
   ss=sigsmooth;
   if(ss<2) ss=2;
   sk = 2.0 / (ss + 1.0);
   sk2=2.0/(ss*0.8+1.0);
   StartBars=int(D1RSIPer+D2StochPer+D2StochPer+hot+sigsmooth);
//--- get indicator's handle
   RSI_Handle=iRSI(NULL,0,D1RSIPer,PRICE_CLOSE);
   if(RSI_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iRSI indicator");
      return(INIT_FAILED);
     }
//--- get indicator's handle
   CCI_Handle=iCCI(NULL,0,D3tunnelPer,PRICE_TYPICAL);
   if(CCI_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iCCI indicator");
      return(INIT_FAILED);
     }
//--- set IndBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//--- create a label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"3D Oscillator");
//--- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(IndBuffer,true);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//--- set SigBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,SigBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//--- create a label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Signal line");
//--- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(SigBuffer,true);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//--- set SellBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(2,SellBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBars);
//--- create a label to display in DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Sell");
//--- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//--- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(SellBuffer,true);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//--- set BuyBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(3,BuyBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,StartBars);
//--- create a label to display in DataWindow
   PlotIndexSetString(3,PLOT_LABEL,"Signal line1Buy");
//--- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//--- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(BuyBuffer,true);
//--- restriction to draw empty values for the indicator
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for the data window and for the label of sub-windows 
   string short_name="3D Oscillator";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---
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
//--- checking the number of bars to be enough for the calculation
   if(BarsCalculated(RSI_Handle)<rates_total
      || BarsCalculated(CCI_Handle)<rates_total
      || rates_total<StartBars) return(0);
//--- declarations of local variables 
   int to_copy,limit,bar;
   double rsi,maxrsi,minrsi,storsi,E3D,RSI[],CCI[],rangrsi;
//--- calculations of the necessary amount of data to be copied
//--- and the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      to_copy=rates_total;           // calculated number of all bars
      limit=rates_total-StartBars-1; // starting index for calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
      to_copy=limit+D2StochPer+3;        // calculated number of all bars
     }
//--- indexing elements in arrays as time series  
   ArraySetAsSeries(RSI,true);
   ArraySetAsSeries(CCI,true);
//--- copy newly appeared data in the arrays
   if(CopyBuffer(RSI_Handle,0,0,to_copy,RSI)<=0) return(0);
   if(CopyBuffer(CCI_Handle,0,0,to_copy,CCI)<=0) return(0);
//--- main indicator calculation loop
   for(bar=limit; bar>=0; bar--)
     {
      rsi=RSI[bar];
      maxrsi=rsi;
      minrsi=rsi;
      //---
      for(int iii=bar+D2StochPer; iii>=bar; iii--)
        {
         rsi=RSI[iii];
         if(rsi>maxrsi) maxrsi=rsi;
         if(rsi<minrsi) minrsi=rsi;
        }
      //---
      rangrsi=maxrsi-minrsi;
      if(rangrsi==0) storsi=0.0;
      else storsi=(rsi-minrsi)/((maxrsi-minrsi)*200)-100;
      E3D=hot*CCI[bar]+(1.0-hot)*storsi;
      //---
      IndBuffer[bar]=sk*E3D+(1.0-sk)*IndBuffer[bar+1];
      SigBuffer[bar]=sk2*IndBuffer[bar+1]+(1.0-sk2)*SigBuffer[bar+1];
      //---
      BuyBuffer [bar]=0.0;
      SellBuffer[bar]=0.0;
      //---
      if(IndBuffer[bar]>SigBuffer[bar] && IndBuffer[bar+1]<SigBuffer[bar+1]) BuyBuffer [bar]=SigBuffer[bar]-15;
      if(IndBuffer[bar]<SigBuffer[bar] && IndBuffer[bar+1]>SigBuffer[bar+1]) SellBuffer[bar]=SigBuffer[bar]+15;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
