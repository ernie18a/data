//+------------------------------------------------------------------+
//|                                                      Predict.mq5 |
//|                       Copyright © 2006, Ronald Verwer / ROVERCOM | 
//|                                                                  | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Ronald Verwer / ROVERCOM"
#property link ""
#property description ""
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
//---- magenta color is used as the color of the bearish indicator line
#property indicator_color1  clrMagenta
//---- indicator 1 line width is equal to 2
#property indicator_width1  2
//---- bullish indicator label display
#property indicator_label1  "Predict Sell"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- green color is used for the indicator bullish line
#property indicator_color2  clrLime
//---- indicator 2 line width is equal to 2
#property indicator_width2  2
//---- bearish indicator label display
#property indicator_label2 "Predict Buy"
//+----------------------------------------------+
//|  Bullish indicator drawing parameters        |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type3   DRAW_ARROW
//---- blue color is used as the color of the bullish line of the indicator
#property indicator_color3  clrBlue
//---- indicator 2 line width is equal to 3
#property indicator_width3  3
//---- bearish indicator label display
#property indicator_label3 "Predict Fl"
//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input int BuyLevel=56;
input int SellLevel=56;
//+----------------------------------------------+

//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
double FlBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables   
   min_rates_total=11;

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,119);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(SellBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,119);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(BuyBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(2,FlBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- indicator symbol
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- indexing elements in the buffer as time series
   ArraySetAsSeries(FlBuffer,true);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="Predict";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//---- checking for the sufficiency of bars for the calculation
   if(rates_total<min_rates_total) return(RESET);

//---- declaration of local variables
   static int Drctn1;
   int limit,bar,Drctn0=0;
   double D1,D2,Pr=0.0,Range,AvgRange;
   string Txt;

//--- calculations of the necessary amount of data to be copied and
//the limit starting index for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total; // starting index for calculation of all bars
      Drctn1=0;
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);

//---- main loop of the indicator calculation
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      SellBuffer[bar]=0.0;
      BuyBuffer[bar]=0.0;
      FlBuffer[bar]=0.0;

      AvgRange=0.0;
      for(int count=bar; count<bar+10; count++) AvgRange=AvgRange+MathAbs(High[count]-Low[count]);
      Range=AvgRange/10;
      Range/=2;

      D1=(Close[bar+1]+Close[bar+2])/2;
      D2=(Close[bar+1]+Close[bar+2]+Close[bar+3]+Close[bar+4]+Close[bar+5])/5;

      if(Close[bar+1]) Pr=((MathAbs(D1-D2)/Close[bar+1]*125.75+0.54528)*10000)/100;

      if(D1>D2 && Pr>BuyLevel)
        {
         Drctn0=+1;
         if(Drctn0!=Drctn1) BuyBuffer[bar]=Low[bar]-Range;
        }
      else if(D1<D2 && Pr>SellLevel)
        {
         Drctn0=-1;
         if(Drctn0!=Drctn1) SellBuffer[bar]=High[bar]+Range;
        }
      else if(Pr>50 && Pr<60)
        {
         Drctn0=0;
         if(Drctn1==+1) FlBuffer[bar]=Low[bar]-Range;
         else if(Drctn1==-1) FlBuffer[bar]=High[bar]+Range;
        }
      else Drctn0=0;

      if(bar) Drctn1=Drctn0;
     }
//----
   if(Drctn0==-1) Txt="Short";
   else if(Drctn0==+1) Txt="Long";
   else Txt="Flat";
   Comment("Predictions: Pr = "+DoubleToString(Pr,3)+" ; Current Signal =  "+Txt);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
