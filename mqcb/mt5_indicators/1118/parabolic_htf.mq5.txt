//+------------------------------------------------------------------+
//|                                                Parabolic_HTF.mq5 |
//|                             Copyright © 2012,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "3Parabolic System"
//--- indicator version number
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- 4 buffers are used for calculation and drawing the indicator
#property indicator_buffers 4
//--- 4 plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//--- drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//--- red color is used for the indicator
#property indicator_color1  Red
//--- indicator 1 width is equal to 1
#property indicator_width1  1
//--- displaying the indicator label
#property indicator_label1  "Lower Parabolic"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//--- dawing the indicator 2 as a line
#property indicator_type2   DRAW_LINE
//--- blue color is used for the indicator
#property indicator_color2  Blue
//--- indicator 2 width is equal to 1
#property indicator_width2  1
//--- displaying the indicator label
#property indicator_label2 "Upper Parabolic"
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//--- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//--- magenta color is used for the indicator
#property indicator_color3  Magenta
//--- indicator 3 width is equal to 4
#property indicator_width3  4
//--- displaying the indicator label
#property indicator_label3  "Parabolic Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//--- drawing the indicator 4 as a symbol
#property indicator_type4   DRAW_ARROW
//--- lime color is used for the indicator
#property indicator_color4  Lime
//--- indicator 4 width is equal to 4
#property indicator_width4  4
//--- displaying the indicator label
#property indicator_label4 "Parabolic Buy"
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // The constant for getting the command for the indicator recalculation back to the terminal

//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H6; //iSAR indicator chart period
input double Step=0.02;    // iSAR step
input double Maximum=0.2;  // iSAR maximum
//+----------------------------------------------+

//--- declaration of dynamic arrays that
// will be used as indicator buffers
double UpSarBuffer[],DnSarBuffer[],SellBuffer[],BuyBuffer[];
//--- declaration of a variable for storing the indicator initialization result
bool Init;
string Symbol_;
//--- declaration of integer variables for the indicators handles
int SAR_Handle;
//--- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Init=true;
//--- checking correctness of the chart periods
   if(TimeFrame<Period())
     {
      Print("iSAR chart period cannot be less than the current chart period");
      Init=false;
      return(INIT_FAILED);
     }
//--- initialization of variables    
   min_rates_total=3;
   Symbol_=Symbol();
//--- getting handle of the iSAR indicator
   SAR_Handle=iSAR(Symbol_,TimeFrame,Step,Maximum);
   if(SAR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the iSAR indicator");
      Init=false;
      return(INIT_FAILED);
     }
//--- set UpSarBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,UpSarBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(UpSarBuffer,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- set DnSarBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,DnSarBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(DnSarBuffer,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- set SellBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(2,SellBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,108);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SellBuffer,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- set BuyBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(3,BuyBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,108);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(BuyBuffer,true);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for the data window and the label for sub-windows
   string short_name="Parabolic HTF";
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
   if(BarsCalculated(SAR_Handle)<min_rates_total || rates_total<min_rates_total || !Init) return(RESET);
   if(BarsCalculated(SAR_Handle)<Bars(Symbol(),TimeFrame)) return(prev_calculated);
//--- declaration of local variables 
   double iSar[1],iOpen[1];
   int limit,bar;
   datetime iTime[1];
   static uint LastCountBar;
//--- calculations of the necessary amount of data to be copied
//--- and the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-2; // starting index for calculation of all bars
      LastCountBar=limit;
     }
   else limit=int(LastCountBar)+rates_total-prev_calculated; // starting index for calculation of new bars 
//--- indexing elements in arrays as timeseries  
   ArraySetAsSeries(time,true);
//--- main cycle of calculation of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- zero out the contents of the indicator buffers for calculation
      UpSarBuffer[bar]=EMPTY_VALUE;
      DnSarBuffer[bar]=EMPTY_VALUE;
      BuyBuffer[bar]=EMPTY_VALUE;
      SellBuffer[bar]=EMPTY_VALUE;
      iSar[0]=0.0;
      //--- copy newly appeared data in the iTime array
      if(CopyTime(Symbol_,TimeFrame,time[bar],1,iTime)<=0) return(RESET);
      if(time[bar]>=iTime[0] && time[bar+1]<iTime[0])
        {
         //--- copy newly appeared data in the array
         if(CopyBuffer(SAR_Handle,0,time[bar],1,iSar)<=0) return(RESET);
         if(CopyOpen(Symbol_,TimeFrame,time[bar],1,iOpen)<=0) return(RESET);
         //---
         if(iOpen[0]<iSar[0])
           {
            SellBuffer[bar]=iSar[0];
            UpSarBuffer[bar]=iSar[0];
           }
         else
           {
            BuyBuffer[bar]=iSar[0];
            DnSarBuffer[bar]=iSar[0];
           }
         LastCountBar=bar;
        }
      //---
      if(!iSar[0])
        {
         UpSarBuffer[bar]=UpSarBuffer[bar+1];
         DnSarBuffer[bar]=DnSarBuffer[bar+1];
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
