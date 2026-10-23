//+------------------------------------------------------------------+
//|                                                 HLPeak_Trend.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  MODIFICATION                                                    |
//+------------------------------------------------------------------+
// 2025-07-01 Issue: Different view when chart refreshed.
// Fixes: 
// 1. "limit=rates_total-prev_calculated-1;" modifed to "limit=rates_total-prev_calculated;"
//    Original code is to avoid error of "array out of range".
// 2. Added code on the main loop "if (i>=Bars)  continue;" to avoid "array out of range" error.
//
// 2025-02-02 Issue: (same as above)
// Modification to fix:
// 1. Modified variables removing "static" attribute.
//    flagDir,refTop,refBot - These variables is always initialized from previous bar of
//                            each related index buffer on every tick event.
// 2. Added index buffer "bufDir" to hold previous direction signal.
// Note: The current modication may lock/unlock the signal.
//       The final bar signal (Up/Down) is calculated on each bar's last tick value.
//       In your EA, you can use the first event signal changed and ignore the lock/unlock signal
//          to use as entry criteria.
//       Or on new bar event, take the previous bar signal as your entry criteria.

#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.02"
#property strict

#property description "High/Low Peak Trend" 
#property description "Developed by CoolByte 2025."
#property description "WARNING: Use this software at your own risk."
#property description "The creator of this indicator cannot be held responsible for any damage or loss."

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 clrDodgerBlue           // top Up (thin line)
#property indicator_color2 clrTomato               // bot Dn (thin line)
#property indicator_color3 clrDodgerBlue           // bot Up (thick line)
#property indicator_color4 clrTomato               // top dn (thick line)
#property indicator_color5 clrDodgerBlue           // strong Up (histogram)
#property indicator_color6 clrTomato               // strong dn (histogram)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input int            inpPeriod         = 8;        // Period
input double         inpMultiplier     = 3.0;      // Multiplier
input bool           inpShowShade      = true;     // Show Shade

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double bufTop[];
double bufBot[];
double bufUp[];
double bufDn[];
double bufSUp[];
double bufSDn[];
double bufDir[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   int drawShade = DRAW_NONE;    if (inpShowShade) drawShade = DRAW_HISTOGRAM;
    
   IndicatorBuffers(7);  
   int k = -1;
   k++;	SetIndexBuffer(k,bufTop);  SetIndexStyle(k,DRAW_LINE,STYLE_SOLID,1);         
         SetIndexLabel (k,"Top");
   k++;	SetIndexBuffer(k,bufBot);  SetIndexStyle(k,DRAW_LINE,STYLE_SOLID,1);         
         SetIndexLabel (k,"Bot");
   k++;	SetIndexBuffer(k,bufUp);   SetIndexStyle(k,DRAW_LINE,STYLE_SOLID,2);         
         SetIndexLabel (k,"Up");
   k++;	SetIndexBuffer(k,bufDn);   SetIndexStyle(k,DRAW_LINE,STYLE_SOLID,2);         
         SetIndexLabel (k,"Down");
   k++;	SetIndexBuffer(k,bufSUp);  SetIndexStyle(k,drawShade,STYLE_DOT,1);         
         SetIndexLabel (k,"Strong Up");   
   k++;	SetIndexBuffer(k,bufSDn);  SetIndexStyle(k,drawShade,STYLE_DOT,1);         
         SetIndexLabel (k,"Strong Down");
   k++;	SetIndexBuffer(k,bufDir);  SetIndexStyle(k,DRAW_NONE,STYLE_SOLID,1);         
   
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
   int limit, i;
   limit=rates_total-prev_calculated;
   
   int flagDir   = 0;
   double refTop = 0.0;
   double refBot = 0.0;
   
   for (i = limit; i >= 0; i--) 
   {
      if (i>=(Bars-1))  continue;
      
      //-- initialize from previous bar
      flagDir = bufDir[i+1];  if (flagDir==EMPTY_VALUE)  flagDir = 0;
      refTop  = bufTop[i+1];  if (refTop==EMPTY_VALUE)   refTop = 0.0;
      refBot  = bufBot[i+1];  if (refBot==EMPTY_VALUE)   refBot = 0.0;
      
      double maHi = iMA(NULL,0,inpPeriod,0,MODE_SMMA,PRICE_HIGH,i);
      double maWt = iMA(NULL,0,inpPeriod,0,MODE_LWMA,PRICE_WEIGHTED,i);
      double maLo = iMA(NULL,0,inpPeriod,0,MODE_SMMA,PRICE_LOW,i);
          
      if (maWt>maHi && flagDir<=0)   // up flag
      {
         flagDir = 1;
      }
      if (maWt<maLo && flagDir>=0)   // down flag
      {
         flagDir = -1;
      }
      double atr = iATR(NULL, 0, inpPeriod, i);
      double midHL = (High[i]+Low[i])/2;
      double atr_top = midHL+(inpMultiplier*atr);
      double atr_bot = midHL-(inpMultiplier*atr);
      if (flagDir>=0)            // up
      {
         if (refTop==0.0)  refTop = High[i];
         refTop = MathMax(refTop,High[i]);
         
         if (refBot==0.0)  refBot = atr_bot;
         refBot = MathMax(refBot,atr_bot);
      }
      if (flagDir<=0)            // down
      {
         if (refTop==0.0)  refTop = atr_top;
         refTop = MathMin(refTop,atr_top);
         
         if (refBot==0.0)  refBot = Low[i];
         refBot = MathMin(refBot,Low[i]);
      }
      bufTop[i]   = refTop;
      bufBot[i]   = refBot;
      bufUp[i]    = EMPTY_VALUE;
      bufDn[i]    = EMPTY_VALUE;
      bufSUp[i]   = EMPTY_VALUE;
      bufSDn[i]   = EMPTY_VALUE;
      if (flagDir>0)  
      {
         bufUp[i] = refBot;
         if (maWt>maHi)          // strong up
         {
            bufSUp[i] = MathMax(Low[i],refBot);
            bufSDn[i] = MathMin(Low[i],refBot);;
         }
      }
      if (flagDir<0)  
      {  
         bufDn[i] = refTop;
         if (maWt<maLo)          // strong down
         {
            bufSUp[i] = MathMin(High[i],refTop);
            bufSDn[i] = MathMax(High[i],refTop);
         }
      }
      bufDir[i] = flagDir;       // save calculated dir
   }   
   return(rates_total);
}
