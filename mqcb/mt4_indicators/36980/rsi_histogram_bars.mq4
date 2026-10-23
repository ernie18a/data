//+--------------------------------------------------------------+
//|                                       RSI histogram bars.mq4 |
//+--------------------------------------------------------------+
#property description "Code by Max Michael 2021"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_width1 4
#property indicator_color2 Red
#property indicator_width2 4
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_color5 Blue
#property indicator_color6 Orange
#property strict

extern int         Fast_RSI = 8;
extern int         Slow_RSI = 55;
extern int    Smooth_Length = 8;
extern int    Smooth_Method = 0;  // 0=SMA 1=EMA 2=SMMA 3=LWMA
extern int          MaxBars = 1000;

double histo_up[], histo_dn[], fastRSI[], slowRSI[], smoothF[], smoothS[];

int init()
{
   SetIndexBuffer(0,histo_up);SetIndexStyle(0,DRAW_HISTOGRAM); 
   SetIndexBuffer(1,histo_dn);SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,fastRSI); SetIndexStyle(2,DRAW_NONE); SetIndexLabel(2,"");
   SetIndexBuffer(3,slowRSI); SetIndexStyle(3,DRAW_NONE); SetIndexLabel(3,"");
   SetIndexBuffer(4,smoothF); SetIndexStyle(4,DRAW_NONE); SetIndexLabel(4,"");
   SetIndexBuffer(5,smoothS); SetIndexStyle(5,DRAW_NONE); SetIndexLabel(5,"");
   IndicatorShortName("RSI histogram bars");
   return(0);
}

int deinit() { return(0); }

int start()
{   
   int CountedBars=IndicatorCounted();
   if (CountedBars<0) return(-1);
   int limit = Bars-CountedBars-1;
   if (limit > MaxBars) limit=MathMin(MaxBars,Bars-1);

   int i=limit;
   while(i>=0) { fastRSI[i]=iRSI(NULL, 0, Fast_RSI, PRICE_CLOSE,i); i--; } 

   i=limit;
   while(i>=0) { slowRSI[i]=iRSI(NULL, 0, Slow_RSI, PRICE_CLOSE, i); i--; } 
    
   i=limit;
   while(i>=0) { smoothF[i]=iMAOnArray(fastRSI, 0, Smooth_Length, 0, Smooth_Method, i);  i--; }  

   i=limit;
   while(i>=0) { smoothS[i]=iMAOnArray(slowRSI, 0, Smooth_Length, 0, Smooth_Method, i);  i--; }  
   
   i=limit;
   while(i>=0)
   {
      if (smoothF[i] > smoothS[i]) { histo_up[i]=smoothF[i]-smoothS[i]; histo_dn[i]=0; }
      else                         { histo_dn[i]=smoothF[i]-smoothS[i]; histo_up[i]=0; }
      i--;
   }  
   return(0);
}
