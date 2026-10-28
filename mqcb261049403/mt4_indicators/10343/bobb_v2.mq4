//+------------------------------------------------------------------+
//|                                                      BOBB_v2.mq4 |
//|                                         Based On Bollinger Bands |
//|                                                   mg@downspin.de |
//+------------------------------------------------------------------+
#property copyright "Copyright @ 2011, downspin"
#property link      "mg@downspin.de"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 DodgerBlue
#property indicator_color2 Red
#property indicator_color3 Orange
#property indicator_level2 0

extern int    BandsPeriod=20;
extern double BandsDeviations=1.0;
extern int MA_Period=9;

double val[],
       MA[],
       dev[];

int init(){
  SetIndexStyle(0,DRAW_LINE); SetIndexBuffer(0,val);
  SetIndexStyle(1,DRAW_LINE); SetIndexBuffer(1,MA);
  SetIndexStyle(2,DRAW_LINE); SetIndexBuffer(2,dev);
  return(0);
}

int deinit(){return(0);}

int start(){
  double sum,ma;
  
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+BandsPeriod-1;
  
  for(int i=limit;i>=0;i--){
    ma=iMA(NULL,0,BandsPeriod,0,MODE_SMA,PRICE_CLOSE,i);
    sum=0.0;
    for(int k=i+BandsPeriod-1;k>=i;k--) sum+=MathPow(Close[k]-ma,2);
    dev[i]=BandsDeviations*MathSqrt(sum/BandsPeriod)/Point;
    val[i]=(Close[i]-ma)/Point;
    MA[i]=val[i]/MA_Period;
    for(int o=1;o<MA_Period;o++) MA[i]+=val[i+o]/MA_Period;
  }
  return(0);
}

