//+------------------------------------------------------------------+
//|                                                        i-sig.mq4 |
//|                                Copyright © 2005, 3172552 & KimIV |
//|                                              http://www.kimiv.ru |
//+------------------------------------------------------------------+
//--- Copyright
#property copyright "Copyright © 2005, 3172552 & KimIV"
//--- a link to the website of the author
#property link      "http://www.kimiv.ru"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window 
//--- two buffers are used for the indicator calculation and drawing
#property indicator_buffers 2
//--- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//| Parameters of drawing a bearish indicator    |
//+----------------------------------------------+
//--- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//--- pink is used for the color of the bearish indicator line
#property indicator_color1  clrMagenta
//--- indicator 1 line width is equal to 4
#property indicator_width1  4
//--- display of the indicator bullish label
#property indicator_label1  "i-sig Sell"
//+----------------------------------------------+
//| Parameters of drawing a bullish indicator    |
//+----------------------------------------------+
//--- drawing the indicator 2 as a symbol
#property indicator_type2   DRAW_ARROW
//---- green color is used as the color of the indicator bullish line
#property indicator_color2  clrLime
//---- indicator 2 line width is equal to 4
#property indicator_width2  4
//--- display of the bearish indicator label
#property indicator_label2 "i-sig Buy"
//+----------------------------------------------+
//| declaration of constants                     |
//+----------------------------------------------+
#define RESET 0
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint bd =7;   // Last bar body lenght 
input uint bdd=40;  // Body lenght for double top/buttom bars 
input uint sd =11;  // Shadow difference for fractal bars 
input uint sdd=6;   // Shadow difference for double tops/buttoms bars 
//+----------------------------------------------+
//--- declaration of dynamic arrays that
//--- will be used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//---
double sd_Point,bd_Point,sdd_Point,bdd_Point;
//--- declaration of integer variables for the indicators handles
int ATR_Handle;
//--- declaration of integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- initialization of global variables 
   int ATR_Period=15;
   min_rates_total=int(MathMax(ATR_Period,5));
//--- Getting the handle of the ATR indicator
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the ATR indicator");
      return(INIT_FAILED);
     }
//--- initialization of constants     
   sd_Point=sd*_Point;
   bd_Point=bd*_Point;
   sdd_Point=sdd*_Point;
   bdd_Point=bdd*_Point;
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,115);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SellBuffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- shifting the starting point of the indicator 2 drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,115);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(BuyBuffer,true);
//--- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for the data window and the label for sub-windows 
   string short_name="i-sig";
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
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- declarations of local variables 
   int to_copy,limit,bar;
   double ATR[];
//--- Calculations of the necessary number of copied data and limit starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }
   to_copy=limit+1;
//---- copy newly appeared data in the ATR[] array
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- apply timeseries indexing to array elements  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--- main calculation loop of the indicator
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      bool bc1=false,bc2=false,bc3=false;
      bool sc1=false,sc2=false,sc3=false;
      //--- just unconfirmed fractal with last bar White
      bc1=((low[bar+3]-low[bar+2])>sd_Point
           && (low[bar+4]-low[bar+2])>sd_Point
           && (low[bar+1]-low[bar+2])>sd_Point
           && (close[bar+1]-open[bar+1])>bd_Point);
      //--- just unconfirmed frsctal with last bar Black
      sc1=((high[bar+2]-high[bar+3])>sd_Point
           && (high[bar+2]-high[bar+4])>sd_Point
           && (high[bar+2]-high[bar+1])>sd_Point
           && (open[bar+1]-close[bar+1])>bd_Point);
      //--- double buttom fractal
      bc2=((low[bar+4]-low[bar+2])>sd_Point
           && (low[bar+5]-low[bar+2])>sd_Point
           && (low[bar+1]-low[bar+2])>sd_Point
           && (close[bar+1]-open[bar+1])>bd_Point
           && (MathAbs(low[bar+3]-low[bar+2]))<sdd_Point);
      //--- double top fractal
      sc2=((high[bar+2]-high[bar+4])>sd_Point
           && (high[bar+2]-high[bar+5])>sd_Point
           && (high[bar+2]-high[bar+1])>sd_Point
           && (open[bar+1]-close[bar+1])>bd_Point
           && (MathAbs(high[bar+3]-high[bar+2]))<sdd_Point);
      //--- long bars double buttom fractal
      bc3=((low[bar+3]-low[bar+2])>sd_Point
           && (low[bar+4]-low[bar+2])>sd_Point
           && (MathAbs(low[bar+1]-low[bar+2]))<sdd_Point
           && (close[bar+1]-open[bar+1])>bdd_Point
           && (open[bar+2]-close[bar+2])>bdd_Point);
      //--- long bars double top fractal
      sc3=((high[bar+2]-high[bar+3])>sd_Point
           && (high[bar+2]-high[bar+4])>sd_Point
           && (MathAbs(high[bar+2]-high[bar+1]))<sdd_Point
           && (open[bar+1]-close[bar+1])>bdd_Point
           && (close[bar+2]-open[bar+2])>bdd_Point);
      if(bc1 || bc2 || bc3) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
      if(sc1 || sc2 || sc3) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
