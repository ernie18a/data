//+------------------------------------------------------------------+
//|                                                    LeManStop.mq5 |
//|                                         Copyright © 2009, LeMan. |
//|                                                 b-market@mail.ru |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2009, LeMan."
//---- link to the website of the author
#property link      "b-market@mail.ru"
//---- indicator version number
#property version   "1.00"
#property description ""
//---- indicator version number
#property version   "1.10"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- four buffers are used for the indicator calculation and drawing
#property indicator_buffers 4
//---- only four plots are used
#property indicator_plots   4
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- LimeGreen color is used for the indicator
#property indicator_color1  LimeGreen
//---- indicator 1 width is equal to 3
#property indicator_width1  3
//---- displaying of the bullish label of the indicator
#property indicator_label1  "Lower LeManStop"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- deep pink color is used for the indicator
#property indicator_color2  DeepPink
//---- indicator 2 width is equal to 3
#property indicator_width2  3
//---- displaying of the bearish label of the indicator
#property indicator_label2 "Upper LeManStop"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//---- LimeGreen color is used for the indicator
#property indicator_color3  LimeGreen
//---- indicator 3 width is equal to 2
#property indicator_width3  2
//---- displaying of the bullish label of the indicator
#property indicator_label3  "LeManStop Buy"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator 4 as a symbol
#property indicator_type4   DRAW_ARROW
//---- deep pink color is used for the indicator
#property indicator_color4  DeepPink
//---- indicator 4 width is equal to 2
#property indicator_width4  2
//---- displaying of the bearish label of the indicator
#property indicator_label4 "LeManStop Sell"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal

//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint per=24;
input uint coef=4;
input uint fastEMA = 9;
input uint slowEMA = 18;
input int Shift=0; //horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double BuyBuffer[],SellBuffer[];
double UpBuffer[],DnBuffer[];
//---- Declaration of integer variables of data starting point
int  min_rates_total;
//---- Declaration of integer variables for the indicator handles
int SEMA_Handle,FEMA_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of variables    
   min_rates_total=int(per+3);

//---- Getting handle of the FastEMA indicator
   FEMA_Handle=iMA(NULL,0,fastEMA,0,MODE_EMA,PRICE_CLOSE);
   if(FEMA_Handle==INVALID_HANDLE) Print(" Failed to get handle of the FastEMA indicator");

//---- getting handle of the SlowEma indicator
   SEMA_Handle=iMA(NULL,0,slowEMA,0,MODE_EMA,PRICE_CLOSE);
   if(SEMA_Handle==INVALID_HANDLE) Print(" Failed to get handle of the SlowEma indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,158);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(UpBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 2 drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,158);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(DnBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,SellBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 3 drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,163);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(SellBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(3,BuyBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator 4 drawing
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(3,PLOT_ARROW,163);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(BuyBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   IndicatorSetString(INDICATOR_SHORTNAME,"LeManStop");
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate
(const int rates_total,
 const int prev_calculated,
 const datetime &Time[],
 const double &Open[],
 const double &High[],
 const double &Low[],
 const double &Close[],
 const long &Tick_Volume[],
 const long &Volume[],
 const int &Spread[]
 )
  {
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(FEMA_Handle)<rates_total
      || BarsCalculated(SEMA_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,bar,to_copy,Counter;
   double fEMA[],sEMA[],EMA0,EMA1,Stop,PreStop,Sum,res;

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(fEMA,true);
   ArraySetAsSeries(sEMA,true);

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for the calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for the calculation of new bars
//----
   to_copy=limit+2;
//---- copy newly appeared data into the arrays
   if(CopyBuffer(FEMA_Handle,MAIN_LINE,0,to_copy,fEMA)<=0) return(RESET);
   if(CopyBuffer(SEMA_Handle,MAIN_LINE,0,to_copy,sEMA)<=0) return(RESET);

//---- first calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      DnBuffer[bar]=0;
      UpBuffer[bar]=0;
      EMA0=fEMA[bar]-sEMA[bar];
      EMA1=fEMA[bar+1]-sEMA[bar+1];

      PreStop=UpBuffer[bar+1]+DnBuffer[bar+1];
      Sum=0;
      Counter=0;

      if(EMA0>0)
        {
         for(int kkk=0; kkk<=int(per); kkk++)
           {
            Sum+=Close[bar+kkk]-Low[bar+kkk];
            Counter++;
           }

         res=coef*Sum;
         if(Counter) Stop=Close[bar]-res/Counter;
         else Stop=Open[bar]-res;

         if(Stop<PreStop && EMA1>0) Stop=PreStop;
         UpBuffer[bar]=Stop;
        }

      if(EMA0<0)
        {
         for(int kkk=0; kkk<=int(per); kkk++)
           {
            Sum=High[bar+kkk]-Close[bar+kkk]+Sum;
            Counter++;
           }

         res=coef*Sum;
         if(Counter) Stop=Close[bar+1]+res/Counter;
         else Stop=Open[bar+1]+res;

         if(Stop>PreStop && EMA1<0) Stop=PreStop;
         DnBuffer[bar]=Stop;
        }
     }

//---- recalculation of the starting index for calculation of all bars
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation     
      limit--;

//---- second calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- zero out the contents of the indicator buffers for the calculation
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;

      if(UpBuffer[bar+1]>0.0&&DnBuffer[bar]>0.0) BuyBuffer [bar]=DnBuffer[bar];
      if(DnBuffer[bar+1]>0.0&&UpBuffer[bar]>0.0) SellBuffer[bar]=UpBuffer[bar];
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
