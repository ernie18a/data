//+------------------------------------------------------------------+
//|                                                Arrows&Curves.mq5 |
//|                 Copyright © 2007, Victor G. Lukashuck aka lukas1 |
//|                                                    lukas1@ngs.ru |
//+------------------------------------------------------------------+
//---- 
#property copyright "Copyright © 2007, Victor G. Lukashuck aka lukas1"
//---- URL
#property link      "lukas1@ngs.ru"
//---- version
#property version   "1.00"
//---- plot indicator in a separate window
#property indicator_chart_window 
//---- 8 indicator buffers are used
#property indicator_buffers 8
//---- 8 graphic plots are used
#property indicator_plots   8
//+----------------------------------------------+
//|  Bearish indicator plot settings             |
//+----------------------------------------------+
//---- draw as an arrow
#property indicator_type1   DRAW_ARROW
//---- arrow color
#property indicator_color1  Magenta
//---- arrow width
#property indicator_width1  4
//---- label
#property indicator_label1  "Sell"
//+----------------------------------------------+
//|  Bullish indicator plot settings             |
//+----------------------------------------------+
//---- draw as an arrow
#property indicator_type2   DRAW_ARROW
//---- arrow color
#property indicator_color2  Lime
//---- arrow width
#property indicator_width2  4
//---- label
#property indicator_label2 "Buy"
//+----------------------------------------------+
//|  Bearish indicator plot settings             |
//+----------------------------------------------+
//---- draw as an arrow
#property indicator_type3   DRAW_ARROW
//---- arrow color
#property indicator_color3  Magenta
//---- arrow width
#property indicator_width3  4
//---- label
#property indicator_label3  "SellStop"
//+----------------------------------------------+
//|  Bullish indicator plot settings             |
//+----------------------------------------------+
//---- draw as an arrow
#property indicator_type4   DRAW_ARROW
//---- arrow color
#property indicator_color4  Lime
//---- arrow width
#property indicator_width4  4
//---- label
#property indicator_label4 "BuyStop"
//+--------------------------------------------+
//|  indicator levels                          |
//+--------------------------------------------+
//---- draw as a line
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
#property indicator_type8   DRAW_LINE
//---- 4 color are used
#property indicator_color5  Orange
#property indicator_color6  MediumSeaGreen
#property indicator_color7  MediumSeaGreen
#property indicator_color8  Orange
//---- line style for Bollinger Bands
#property indicator_style5 STYLE_DASHDOTDOT
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_style7 STYLE_DASHDOTDOT
#property indicator_style8 STYLE_DASHDOTDOT
//---- line width for Bollinger Bands
#property indicator_width5  1
#property indicator_width6  1
#property indicator_width7  1
#property indicator_width8  1
//---- labels for Bollinger Bands
#property indicator_label5  "BUY from here"
#property indicator_label6  "BuyStop"
#property indicator_label7  "SellStop"
#property indicator_label8  "SELL from here"

//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input int SSP     = 20;   //reversal period
input int Channel = 0;    //Channel 
input int Ch_Stop = 30;   //Stop Channel
input int relay   = 10;   //shift
//+----------------------------------------------+

//---- declaration of dynamic arrays, used as indicator buffers
double BuyBuffer[];
double SellBuffer[];
double HBuffer[];
double LBuffer[];
double HSBuffer[];
double LSBuffer[];
double BuyStopBuffer[],SellStopBuffer[];
//---
int StartBars;
bool uptrend_,old_,uptrend2_,old2_;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- initialization of global variables
   StartBars=SSP+1+relay;

//---- set SellBuffer[] array as indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- set plot draw begin
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- set label
   PlotIndexSetString(0,PLOT_LABEL,"Sell");
//---- set arrow char code
   PlotIndexSetInteger(0,PLOT_ARROW,108);
//---- set indexing as timeseries
   ArraySetAsSeries(SellBuffer,true);
//---- set empty value as 0
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set BuyBuffer[] array as indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- set plot draw begin
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//---- set label
   PlotIndexSetString(1,PLOT_LABEL,"Buy");
//---- set arrow char code
   PlotIndexSetInteger(1,PLOT_ARROW,108);
//---- set indexing as timeseries
   ArraySetAsSeries(BuyBuffer,true);
//---- set empty value as 0
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- set SellStopBuffer[] array as indicator buffer
   SetIndexBuffer(2,SellStopBuffer,INDICATOR_DATA);
//---- set plot draw begin
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBars);
//---- set label 
   PlotIndexSetString(2,PLOT_LABEL,"SellStop");
//---- set arrow char code
   PlotIndexSetInteger(2,PLOT_ARROW,251);
//---- set indexing as timeseries
   ArraySetAsSeries(SellStopBuffer,true);
//---- set empty value as 0
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

//---- set BuyStopBuffer[] array as indicator buffer
   SetIndexBuffer(3,BuyStopBuffer,INDICATOR_DATA);
//---- set plot draw begin
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,StartBars);
//---- set label
   PlotIndexSetString(3,PLOT_LABEL,"BuyStop");
//---- set arrow char code
   PlotIndexSetInteger(3,PLOT_ARROW,251);
//---- set indexing as timeseries
   ArraySetAsSeries(BuyStopBuffer,true);
//---- set empty value as 0
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);

//---- set arrays as indicator buffers
   SetIndexBuffer(4,HBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,HSBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,LSBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,LBuffer,INDICATOR_DATA);
//---- set plot draw begin
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,StartBars);
//---- set labels
   PlotIndexSetString(4,PLOT_LABEL,"BUY from here");
   PlotIndexSetString(5,PLOT_LABEL,"BuyStop");
   PlotIndexSetString(6,PLOT_LABEL,"SellStop");
   PlotIndexSetString(7,PLOT_LABEL,"SELL from here");
//---- set empty value as 0
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,0);
//---- set indexing as timeseries
   ArraySetAsSeries(HBuffer,true);
   ArraySetAsSeries(HSBuffer,true);
   ArraySetAsSeries(LSBuffer,true);
   ArraySetAsSeries(LBuffer,true);
//---- set precision
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- indicator short name
   string short_name="Arrows&Curves";
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
//---- checking of bars
   if(rates_total<StartBars) return(0);

//---- declaration of local variables
   int limit,bar;
   double High,Low,smin,smax,smin2,smax2,Close;
   static bool uptrend,old,uptrend2,old2;

//---- calculate starting bar index (limit)
   if(prev_calculated>rates_total || prev_calculated<=0)// at first call
     {
      limit=rates_total-StartBars; // starting bar index
     }
   else
     {
      limit=rates_total-prev_calculated; // starting bar index
     }

//---- set indexing as timeseries
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- restore the values
   uptrend=uptrend_;
   uptrend2=uptrend2_;
   old=old_;
   old2=old2_;

//---- main loop
   for(bar=limit; bar>=0; bar--)
     {
      //---- save the variable values
      if(rates_total!=prev_calculated && bar==0)
        {
         uptrend_=uptrend;
         uptrend2_=uptrend2;
         old_=old;
         old2_=old2;
        }

      Close= close[bar];
      High = high[iHighest(high,SSP,bar+relay)];
      Low  = low [iLowest (low, SSP,bar+relay)];
      smax = High -(Low-High)*Channel/ 100;           // smax
      smin = Low+(High-Low)*Channel / 100;            // smin
      smax2= High -(High-Low)*(Channel+Ch_Stop)/ 100; // smax
      smin2= Low+(High-Low)*(Channel+Ch_Stop) / 100;  // smin
      BuyBuffer[bar]=0;
      SellBuffer[bar]=0;
      BuyStopBuffer[bar]=0;
      SellStopBuffer[bar]=0;
      //----
      if(Close<smin && Close<smax && uptrend2==true && bar!=0) uptrend=false;
      if( Close > smax  && Close > smin   && uptrend2 == false && bar!=0 ) uptrend  = true;
      if((Close > smax2 || Close > smin2) && uptrend  == false && bar!=0 ) uptrend2 = false;
      if((Close<smin2 || Close<smax2) && uptrend==true && bar!=0) uptrend2=true;
      //---- the second signal doesn't switch the "uptrend" mode
      //---- but used
      if(close[bar]<smin && close[bar]<smax && uptrend2==false && bar!=0)
        {
         SellBuffer[bar]=Low;
         uptrend2=true;
        }
      //---- the second signal doesn't switch the "uptrend" mode
      //---- but used
      if(Close>smax && Close>smin && uptrend2==true && bar!=0)
        {
         BuyBuffer[bar]=High;
         uptrend2=false;
        }
      //----
      if(uptrend != old && uptrend == false) SellBuffer[bar] = Low;
      if(uptrend != old && uptrend == true ) BuyBuffer[bar] = High;
      //----
      if(uptrend2 != old2 && uptrend2 == true ) BuyStopBuffer[bar] = smax2;
      if(uptrend2 != old2 && uptrend2 == false) SellStopBuffer[bar] = smin2;
      //----
      old=uptrend;
      old2=uptrend2;
      //----
      HBuffer[bar]=smax;
      LBuffer[bar]=smin;
      HSBuffer[bar]=smax2;
      LSBuffer[bar]=smin2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  searching index of the highest bar                              |
//+------------------------------------------------------------------+
int iHighest(const double &array[],// array for the search
             int count,            // number of elements
             int startPos          // starting bar index
             )
  {
//----
   int index=startPos;

//---- check starting index for correctness
   if(startPos<0)
     {
      Print("Incorrect starting position in iHighest, startPos = ",startPos);
      return(0);
     }

   double max=array[startPos];

//---- search for the index
   for(int i=startPos; i<startPos+count; i++)
     {
      if(array[i]>max)
        {
         index=i;
         max=array[i];
        }
     }
//---- return the highest element index
   return(index);
  }
//+------------------------------------------------------------------+
//|  searching index of the lowest bar                               |
//+------------------------------------------------------------------+
int iLowest(const double &array[],  // array for the search
            int count,              // number of elements
            int startPos            // starting bar index
            )
  {
//----
   int index=startPos;

//---- check starting index for correctness
   if(startPos<0)
     {
      Print("Incorrect starting position in iLowest, startPos = ",startPos);
      return(0);
     }

   double min=array[startPos];

//---- search for the lowest element
   for(int i=startPos; i<startPos+count; i++)
     {
      if(array[i]<min)
        {
         index=i;
         min=array[i];
        }
     }
//---- return the lowest element index
   return(index);
  }
//+------------------------------------------------------------------+