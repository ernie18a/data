//+------------------------------------------------------------------+
//|                                             Cronex T RSI BBS.mq5 |
//|                                        Copyright © 2017, Cronex. |
//|                                Sergii Kozin sergagame1@gmail.com |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2017, Cronex"
#property  link      "https://www.metaquotes.net/"

#property  indicator_separate_window
#property indicator_buffers 7
#property indicator_plots 7
#property indicator_color1 DarkOrange
#property indicator_color2 SteelBlue


#property indicator_width1 2

// Level lines   
#property indicator_level1  10
#property indicator_level2 -10

// Input variables
input int RSIPeriod = 16;
input double TCurvature = 0.618;

double RSITArray[];
double RSIArray[];

double e1,e2,e3,e4,e5,e6;
double c1,c2,c3,c4;
double n,w1,w2,b2,b3;

int RSIHandle0;
int RSIHandle1;
int RSIHandle2;
int RSIHandle3;

double RSIBuffer0[];
double RSIBuffer1[]; 
double RSIBuffer2[]; 
double RSIBuffer3[];  

int OnInit()
{
   SetIndexBuffer(0, RSITArray, INDICATOR_DATA);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   SetIndexBuffer(1, RSIArray, INDICATOR_DATA);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
  
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);   
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   
   PlotIndexSetString(0, PLOT_LABEL, "RSI T");
   PlotIndexSetString(1, PLOT_LABEL, "RSI");

   IndicatorSetInteger(INDICATOR_DIGITS, (int)SymbolInfoInteger(NULL, SYMBOL_DIGITS));
   IndicatorSetString(INDICATOR_SHORTNAME, "Cronex T RSI BBS (" + IntegerToString(RSIPeriod) + ")");
   
   //reset variables 
   e1 = 0.0; e2 = 0.0; e3 = 0.0; e4 = 0.0; e5 = 0.0; e6 = 0.0;
   c1 = 0.0; c2 = 0.0; c3 = 0.0; c4 = 0.0;
   n = 0.0;
   w1 = 0.0; w2 = 0.0;
   b2 = 0.0; b3 = 0.0;
   //
   b2 = TCurvature * TCurvature;
   b3 = b2 * TCurvature;
   c1 = -b3;
   c2 = (3 * (b2 + b3));
   c3 = -3 * (2 * b2 + TCurvature + b3);
   c4 = (1 + 3 * TCurvature + b3 + 3 * b2);
   n = (double)RSIPeriod;
  
   if (n < 1) {
      n=1;
   }
   n = 1 + 0.5 * (n - 1);
   w1 = 2 / (n + 1);
   w2 = 1 - w1;
   
   RSIHandle0 = iRSI(NULL, 0, RSIPeriod + 4 * 0 , PRICE_WEIGHTED);
   RSIHandle1 = iRSI(NULL, 0, RSIPeriod + 4 * 1 , PRICE_WEIGHTED);
   RSIHandle2 = iRSI(NULL, 0, RSIPeriod + 4 * 2 , PRICE_WEIGHTED);
   RSIHandle3 = iRSI(NULL, 0, RSIPeriod + 4 * 3 , PRICE_WEIGHTED);

   return(0); 
}

int OnCalculate(
   const int rates_total,
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
   int to_calc = rates_total - prev_calculated;
   CopyBuffer(RSIHandle0, 0, 0, to_calc, RSIBuffer0);
   CopyBuffer(RSIHandle1, 0, 0, to_calc, RSIBuffer1);
   CopyBuffer(RSIHandle2, 0, 0, to_calc, RSIBuffer2);
   CopyBuffer(RSIHandle3, 0, 0, to_calc, RSIBuffer3);
   
   int i, c;   
   for (i= 0; i < to_calc; i++) {  
      c = prev_calculated + i;    
      RSIArray[c] = (RSIBuffer0[i] + RSIBuffer1[i] + RSIBuffer2[i] + RSIBuffer3[i]) / 4 - 50;           
      if (RSIArray[c] <=100 && RSIArray[c] >= -100) {
         e1 = w1 * RSIArray[c] + w2 * e1;         
         e2 = w1 * e1 + w2 * e2;
         e3 = w1 * e2 + w2 * e3;
         e4 = w1 * e3 + w2 * e4;
         e5 = w1 * e4 + w2 * e5;
         e6 = w1 * e5 + w2 * e6;
         RSITArray[c] = c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3;
      } else {
         RSIArray[c] = 0.0;
         RSITArray[c] = 0.0;         
      }
   }
    
   return(rates_total);
}