//+------------------------------------------------------------------+
//|                                                  RJT Matches.mq5 |
//|                            Copyright 2015, Rafael Jimenez Tocino |
//|               http://www.tradingrafa.com/indicadores/rjt_matches |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Rafael Jimenez Tocino"
#property link      "http://www.tradingrafa.com/indicadores/rjt_matches"
#property description "We recommend adjust the body and head size of the matches for better visualization."
#property version   "2.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   5
//--- drawing objects properties
#property indicator_label1  "match1"
#property indicator_label2  "match2"
#property indicator_label3  "match3"
#property indicator_label4  "headred"
#property indicator_label5  "headgreen"
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_ARROW
#property indicator_type5   DRAW_ARROW
#property indicator_color1  clrWhite
#property indicator_color2  clrWhite
#property indicator_color3  clrWhite
#property indicator_color4  clrRed
#property indicator_color5  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_style2  STYLE_SOLID
#property indicator_style3  STYLE_SOLID
#property indicator_style4  STYLE_SOLID
#property indicator_style5  STYLE_SOLID
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  1
#property indicator_width5  1
//--- buffers
double         LineBuffer1[];
double         LineBuffer2[];
double         LineBuffer3[];
double         LineBuffer4[];
double         LineBuffer5[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,LineBuffer1,INDICATOR_DATA); // body of match 1
   SetIndexBuffer(1,LineBuffer2,INDICATOR_DATA); // body of match 2
   SetIndexBuffer(2,LineBuffer3,INDICATOR_DATA); // body of match 3
   SetIndexBuffer(3,LineBuffer4,INDICATOR_DATA); // matchstick heads in red
   SetIndexBuffer(4,LineBuffer5,INDICATOR_DATA); // matchstick heads in green
//--- matchstick heads
   PlotIndexSetInteger(3,PLOT_ARROW,159);
   PlotIndexSetInteger(4,PLOT_ARROW,159);
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
//---
   int i,c=0,p=0;
   for(i=1; i<rates_total; i++)
     {
      //--- the color of matchstick heads
      if(close[i]>open[i-1])
        {
         LineBuffer4[i]=EMPTY_VALUE;
         LineBuffer5[i]=close[i];
           } else {
         LineBuffer4[i]=close[i];
         LineBuffer5[i]=EMPTY_VALUE;
        }
      //--- the body of matches
      switch(p)
        {
         case 0:
            LineBuffer1[i]=open[i];
            LineBuffer2[i]=EMPTY_VALUE;
            LineBuffer3[i]=close[i];
            break;
         case 1:
            LineBuffer1[i]=close[i];
            LineBuffer2[i]=open[i];
            LineBuffer3[i]=EMPTY_VALUE;
            break;
         case 2:
            LineBuffer1[i]=EMPTY_VALUE;
            LineBuffer2[i]=close[i];
            LineBuffer3[i]=open[i];
            break;
        }
      p++; p=p==3?0:p;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("RJT Matches - Finished");
  }
//+------------------------------------------------------------------+
