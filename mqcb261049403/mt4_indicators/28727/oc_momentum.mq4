//+------------------------------------------------------------------+
//|                                                  OC Momentum.mq4 |
//|                                                    Jan Opocensky |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Jan Opocensky"
#property link      ""
#property version   "R060520"
#property strict
#property indicator_separate_window
#property indicator_buffers    4 
#property indicator_color1     Black
#property indicator_color2     Green
#property indicator_color3     Red
#property indicator_color4     Blue
//+------------------------------------------------------------------+
#property indicator_level1     0.00
#property indicator_levelcolor     Black
#property indicator_levelwidth     1
//+------------------------------------------------------------------+
double MomentumIndex[]; 
double UPPER_histogram[];
double LOWER_histogram[];
double MomentumIndexAverage[]; 
//+------------------------------------------------------------------+
int i;
double ActualPoint;
input int OC_Candles=3; // OC_Candles
input int Start_Candle=0; // Start_Candle, first calculated, 0 = actual
input int Candles=300; // Candles
input int Average_Period = 20; // Average_Period
input int Histogram_Width = 2; // Histogram_Width
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping ------------------
   IndicatorBuffers(1);
   SetIndexBuffer(0,MomentumIndex);
   SetIndexStyle(0,DRAW_LINE,EMPTY,2);
      
   IndicatorBuffers(2);
   SetIndexBuffer(1,UPPER_histogram);
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,Histogram_Width);
   
   IndicatorBuffers(3);
   SetIndexBuffer(2,LOWER_histogram);
   SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,Histogram_Width);
   
   IndicatorBuffers(4);
   SetIndexBuffer(3,MomentumIndexAverage);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,2);
   
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
//
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
if (Point()<0.000001) {ActualPoint=0.000001;}
else {ActualPoint=Point();} //

for (i=Start_Candle;i<Candles;i++)
{
   
   MomentumIndex[i]=(Close[i]-Open[i+OC_Candles])/ActualPoint; //
   if (Close[i]>Open[i+OC_Candles]) {UPPER_histogram[i] = (Close[i]-Open[i+OC_Candles])/ActualPoint ;} //
   if (Close[i]<Open[i+OC_Candles]) {LOWER_histogram[i] = (Close[i]-Open[i+OC_Candles])/ActualPoint ;} //
//---------------------------------------   
}    
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// 
//
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
for (i=1;i<Candles;i++)
{
//---------------------------------------   
   double Momentum_Suma=0;
   for (int a=i;a<i+Average_Period;a++)
   {
   Momentum_Suma= Momentum_Suma+//
  ((Close[a]-Open[a+OC_Candles])/ActualPoint)
   ;
   }   
   MomentumIndexAverage[i]=Momentum_Suma/Average_Period;
//---------------------------------------    
}    
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// 
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
//+------------------------------------------------------------------+                  
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
//+------------------------------------------------------------------+                  
  {
//---
   
  }
//+------------------------------------------------------------------+


