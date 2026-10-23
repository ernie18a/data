//+------------------------------------------------------------------+
//|                                                        TANGO.mq5 |
//|                                         Copyright © 2009, MetaQL |
//|                                            mrexpertforex@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, MetaQL"
#property link "mrexpertforex@mail.ru" 
#property description "TANGO"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- three buffers are used for calculation and drawing the indicator
#property indicator_buffers 3
//---- only three plots are used
#property indicator_plots   3
//+----------------------------------------------+
//|  Bearish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- gold color is used for the indicator bearish line
#property indicator_color1  clrGold
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- bullish indicator label display
#property indicator_label1  "TANGO Att"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- blue color is used for the indicator bullish line
#property indicator_color2  clrBlue
//---- indicator 2 line width is equal to 1
#property indicator_width2  1
//---- bearish indicator label display
#property indicator_label2 "TANGO Buy"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 3 as a symbol
#property indicator_type3   DRAW_ARROW
//---- red color is used for the indicator bullish line
#property indicator_color3  clrRed
//---- indicator 2 line width is equal to 1
#property indicator_width3  1
//---- bearish indicator label display
#property indicator_label3 "TANGO Sell"

#define RESET 0 // The constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint    PeriodRSI=20;
input double  Level=20;
input uint    Length=100;
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double AttBuffer[];
double SellBuffer[];
double BuyBuffer[];
//---- Declaration of integer variables for the indicator handles
int RSI_Handle;
//---- Declaration of integer variables of data starting point
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(PeriodRSI+Length+1);

//---- getting handle of the RSI indicator
   RSI_Handle=iRSI(NULL,0,PeriodRSI,PRICE_CLOSE);
   if(RSI_Handle==INVALID_HANDLE) Print(" Failed to get handle of the RSI indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,AttBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,111);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(AttBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(BuyBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,234);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(SellBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="TANGO";
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
//---- checking for the sufficiency of bars for the calculation
   if(BarsCalculated(RSI_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables 
   int limit,bar,to_copy;
   double RSI[],RSI_1,HI_RSI,LO_RSI,RSI_2,UP,DOWN;

//--- calculations of the necessary amount of data to be copied and
//the limit starting index for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

   to_copy=int(limit+1+Length);

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(RSI,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//--- copy newly appeared data in the array
   if(CopyBuffer(RSI_Handle,0,0,to_copy,RSI)<=0) return(RESET);

//---- main loop of the indicator calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      AttBuffer[bar]=0;
      SellBuffer[bar]=0;
      BuyBuffer[bar]=0;

      RSI_1=RSI[bar];
      HI_RSI=RSI_1;
      LO_RSI=RSI_1;

      for(int kkk=0; kkk<int(Length); kkk++)
        {
         RSI_2=RSI[bar+kkk];
         //--
         if(RSI_2>HI_RSI) HI_RSI=RSI_2;
         if(RSI_2<LO_RSI) LO_RSI=RSI_2;
         //---
         if(close[bar+kkk]<close[bar] && RSI_2>=RSI_1 || close[bar+kkk]>=close[bar] && RSI_2<RSI_1)
           {
            UP=HI_RSI-((HI_RSI-LO_RSI)/100)*Level;
            //--
            if(RSI_2>=UP) BuyBuffer[bar]=low[bar];
            //---
            DOWN=LO_RSI+((HI_RSI-LO_RSI)/100)*Level;
            //--
            if(RSI_2<=DOWN) SellBuffer[bar]=high[bar];
            //--
            if(RSI_2>DOWN && RSI_2<UP) AttBuffer[bar]=close[bar];
            //---
            break;
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
