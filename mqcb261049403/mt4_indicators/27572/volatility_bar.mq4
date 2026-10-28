//+------------------------------------------------------------------+
//|                                               volatility_Bar.mq4 |
//|                                       Copyright 2019, Martingeil |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Martingeil"
#property version   "1.00"
#property strict
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 clrBlue
#property indicator_color2 clrLime
#property indicator_color3 clrRed
#property indicator_color4 clrYellow
#property indicator_maximum  1
#property indicator_minimum -1
#property indicator_level1  0
#property indicator_levelcolor clrBlueViolet
//--- input 
input int    bar   = 6;    // количество баров для расчета - 6
input int    koef  = 50;   // коэффициент деления диапазона свечи
input double level = 0.75; // уровень волатильности средней линии
//---
double Trend1[],Trend2[];
double Flat1[],Flat2[];
double B1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- 
   string short_name="volatility_Bar";
//--- 
   IndicatorBuffers(5);
   SetIndexBuffer(0,Trend1);
   SetIndexStyle (0, DRAW_ARROW, 0, 0);
   SetIndexArrow(0,110);
   SetIndexBuffer(1,Trend2);
   SetIndexStyle (1, DRAW_ARROW, 0, 0);
   SetIndexArrow(1,110);
 
   SetIndexBuffer(2,Flat1);
   SetIndexStyle (2, DRAW_ARROW, 0, 0);
   SetIndexArrow(2,110);
   SetIndexBuffer(3,Flat2);
   SetIndexStyle (3, DRAW_ARROW, 0, 0); 
   SetIndexArrow(3,110);
    
   SetIndexBuffer(4,B1);
   SetIndexStyle(4,DRAW_NONE);    
//---
   IndicatorShortName(short_name);
   SetIndexLabel(0,"blue_arrow 0-buffer");
   SetIndexLabel(1,"lime_arrow 1-buffer");
   SetIndexLabel(2,"red_arrow 2-buffer");
   SetIndexLabel(3,"Yellow_arrow 3-buffer");
//---
   SetIndexDrawBegin(0,20);
   SetIndexDrawBegin(1,20);
   SetIndexDrawBegin(2,20);
   SetIndexDrawBegin(3,20);   
   IndicatorDigits(1);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],
                const double &close[],const long &tick_volume[],const long &volume[],const int &spread[])
  {
//---
   int bar_h,bar_l; 
   double hi,lo; int i, limit = rates_total - prev_calculated - bar; if(limit < 0) {limit = 0;};

   for( i = limit; i>= 0; i--){
      bar_h = ArrayMaximum(high,bar,i);   bar_l = ArrayMinimum(low,bar,i);
      
      if(bar_h>=0) hi  = high[bar_h];  else hi  = 0;
      if(bar_l>=0) lo  = low[bar_l];   else lo  = 0; 
      B1[i] = (hi-lo)/_Point/koef; };

   limit = rates_total - prev_calculated - 16; if(limit <= 0) {limit = 1;};
   for( i = limit - 1; i >= 0; i-- ){   
      if(SP1(i) > level){
         if(SP1(i) > SP1(i+1)) Trend1[i] =  0.1;  else Trend1[i] = EMPTY_VALUE;
         if(SP1(i) < SP1(i+1)) Trend2[i] =  0.1;  else Trend2[i] = EMPTY_VALUE;}
      if(SP1(i) < level){
         if(SP1(i) < SP1(i+1)) Flat1[i]  =  -0.1;  else Flat1[i]  = EMPTY_VALUE;
         if(SP1(i) > SP1(i+1)) Flat2[i]  =  -0.1;  else Flat2[i]  = EMPTY_VALUE;}}; 
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
double SP1(int i) { double res =
  0.363644232288*B1[i]+0.319961361319*B1[i+1]+0.2429021537279*B1[i+2]+0.1499479402208*B1[i+3]+0.0606476023757*B1[i+4]
 -0.00876136797274*B1[i+5]-0.0492967601969*B1[i+6]-0.0606402244647*B1[i+7]-0.0496978153976*B1[i+8]-0.02724932305397*B1[i+9]-0.00400372352396*B1[i+10]
 +0.01244416185618*B1[i+11]+0.01927941647120*B1[i+12]+0.01821767237980*B1[i+13]+0.01598780862402*B1[i+14]-0.00338313465225*B1[i+15];  
  return(res);}
  
  
  
  
  
  
  
  
  
  
  
  