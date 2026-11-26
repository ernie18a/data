//+------------------------------------------------------------------+
//|                              MFCS Currency Correlation Chart.mq5 |
//|                                 Copyright 2011, Mansukh Patidar. |
//|                                   mansukh.patidar _AT_ gmail.com |
//|                                          http://www.mpatidar.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, Mansukh Patidar."
#property link      "http://www.mpatidar.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_separate_window
//---
#property indicator_color1 clrDodgerBlue, clrOrangeRed, clrSilver
#property indicator_label1  "MFCS Currency Correlation Chart"
#property indicator_type1   DRAW_COLOR_BARS
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//---
#property indicator_buffers 5
#property indicator_plots   1
//---
double         CCChartBuffer1[];
double         CCChartBuffer2[];
double         CCChartBuffer3[];
double         CCChartBuffer4[];
double         ColorBarsColor[];
//--- we will keep the number of values in the Stochastic Oscillator indicator
int    bars_calculated=0;
//--- indicator input parameters
input string symbol = "GBPUSD";
input bool inverted = false;
input bool monochrome= false;
input bool  show_bid = true;
input color bid_color= clrSilver;
input bool  show_ask = false;
input color ask_color= clrRed;
//--- input parameters
int      STC_Period=5;
int      STC_Slowing=3;
int      STC_D=3;
int      STCHandle;

string ask_line_id = "";
string bid_line_id = "";
string inv_warning = "";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,CCChartBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,CCChartBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,CCChartBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,CCChartBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,ColorBarsColor,INDICATOR_COLOR_INDEX);

   IndicatorSetInteger(INDICATOR_DIGITS,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
   string label="MFCS Currency Correlation Chart("+symbol+")";

   if(inverted)
      label=label+" - INVERTED";
   IndicatorSetString(INDICATOR_SHORTNAME,label);

   STCHandle=iStochastic(symbol,Period(),STC_Period,STC_D,STC_Slowing,MODE_EMA,STO_LOWHIGH);
   bars_calculated=0;

   ask_line_id = symbol + "_ask_line_id_" + IntegerToString(MathRand());
   bid_line_id = symbol + "_bid_line_id_" + IntegerToString(MathRand());
   inv_warning = "MFCS CC-" + symbol + IntegerToString(MathRand()) +""+ IntegerToString(MathRand());

   if(inverted)
     {
      double chart_max_price=ChartGetDouble(0,CHART_PRICE_MAX,ChartWindowFind());
      //--- create object Label
      ObjectCreate(0,inv_warning,OBJ_LABEL,ChartWindowFind(),TimeCurrent(),chart_max_price);

      ObjectSetInteger(0,inv_warning,OBJPROP_XDISTANCE,20);
      ObjectSetInteger(0,inv_warning,OBJPROP_YDISTANCE,20);

      //--- set color of the text
      ObjectSetInteger(0,inv_warning,OBJPROP_COLOR,clrRed);
      //--- set text for the Label object
      ObjectSetString(0,inv_warning,OBJPROP_TEXT,"INVERTED");
      //--- set text font
      ObjectSetString(0,inv_warning,OBJPROP_FONT,"Arial");
      //--- set font size
      ObjectSetInteger(0,inv_warning,OBJPROP_FONTSIZE,18);
      //--- forbid the selection of the object by mouse
      ObjectSetInteger(0,inv_warning,OBJPROP_SELECTABLE,false);
     }

//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0,ask_line_id);
   ObjectDelete(0,bid_line_id);
   ObjectDelete(0,inv_warning);
   IndicatorRelease(STCHandle);

  }
//+------------------------------------------------------------------+
//| DisplayBidAskLines                                               |
//+------------------------------------------------------------------+
void DisplayBidAskLines()
  {
   MqlTick tick;
   SymbolInfoTick(symbol,tick);

   if(inverted)
     {
      tick.ask = 1 / tick.ask;
      tick.bid = 1 / tick.bid;
     }

   if(show_ask)
     {
      if(ObjectFind(0,ask_line_id)<0)
         ObjectCreate(0,ask_line_id,OBJ_HLINE,ChartWindowFind(),TimeCurrent(),tick.ask);
      ObjectSetDouble(0,ask_line_id,OBJPROP_PRICE,tick.ask);
      ObjectSetInteger(0,ask_line_id,OBJPROP_COLOR,ask_color);
     }

   if(show_bid)
     {
      if(ObjectFind(0,bid_line_id)<0)
         ObjectCreate(0,bid_line_id,OBJ_HLINE,ChartWindowFind(),TimeCurrent(),tick.bid);
      ObjectSetDouble(0,bid_line_id,OBJPROP_PRICE,tick.bid);
      ObjectSetInteger(0,bid_line_id,OBJPROP_COLOR,bid_color);
     }
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

//--- check for data
   if(rates_total<STC_Period)
      return(0);

//--- calculate how many bars need to be recalculated
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0)
      to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      //--- last value is always copied
      to_copy++;
     }

   int limit,i;

//--- first calculation or number of bars was changed
   if(prev_calculated<STC_Period)
      limit=STC_Period;
   else
      limit=prev_calculated-1;


   MqlRates rates[1];
   DisplayBidAskLines();

   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      int buffer_index=i;
      rates[0].close= 0;
      rates[0].open = 0;
      rates[0].low  = 0;
      rates[0].high = 0;

      int copied=CopyRates(symbol,Period(),rates_total-buffer_index-1,1,rates);

      if(copied && (rates[0].open>0.0))
        {

         if(inverted)
           {
            if(rates[0].open!=0)
               rates[0].open=1/rates[0].open;
            if(rates[0].high!=0)
               rates[0].high = 1 / rates[0].high;
            if(rates[0].low != 0)
               rates[0].low=1/rates[0].low;
            if(rates[0].close!=0)
               rates[0].close=1/rates[0].close;
           }

         CCChartBuffer1[buffer_index] = rates[0].open;
         CCChartBuffer2[buffer_index] = rates[0].high;
         CCChartBuffer3[buffer_index] = rates[0].low;
         CCChartBuffer4[buffer_index] = rates[0].close;

         if(monochrome)
            ColorBarsColor[i]=2;
         else if(rates[0].open>rates[0].close)
            ColorBarsColor[i]=1;
         else
            ColorBarsColor[i]=0;
        }

     }
//--- return the prev_calculated value for the next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
