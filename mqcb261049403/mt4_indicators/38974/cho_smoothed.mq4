//+------------------------------------------------------------------+
//|                                                 CHO_smoothed.mq4 |
//+------------------------------------------------------------------+
#property description "MT4 Code by  Max Michael 2022"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 DeepSkyBlue
#property indicator_color2 Black
#property indicator_color3 Red
#property strict

//---- input parameters
extern int            SlowPeriod = 10;
extern int            FastPeriod = 3;
extern int             SmoothPer = 5; // <= 1 'not used'
input ENUM_MA_METHOD  SmoothMode = MODE_EMA;
extern int               maxbars = 1000;

//---- buffers
double CHO[], AD[], SM[];

int init()
{
   string name="Chaikin Oscillator("+string(SlowPeriod)+","+string(FastPeriod)+","+string(SmoothPer)+")";
   SetIndexBuffer(0,CHO); SetIndexStyle(0,DRAW_LINE); SetIndexEmptyValue(0,0.0); SetIndexLabel(0,name); 
   SetIndexBuffer(1,AD);  SetIndexStyle(1,DRAW_NONE); SetIndexEmptyValue(1,0.0); SetIndexLabel(1,"");
   SetIndexBuffer(2,SM);  SetIndexStyle(2,DRAW_LINE); SetIndexEmptyValue(2,0.0); SetIndexLabel(2,"");
   IndicatorShortName(name);
   return(0);
}

int deinit() { return(0); }

int start()
{
   int counted_bars=IndicatorCounted(), i;
   if (counted_bars<0) return(-1);
   int limit = Bars-counted_bars-1; //= 0 on live bar
   if (limit > 0) limit=Bars-1;  //refresh on new bar
   if (limit > maxbars) limit=maxbars;
   
   //for (int i=limit; i>=0; i--) AD[i]=iAD(NULL,0,i); //alternative AD function
   for (i=limit; i>=0; i--) AD[i]= AD[i+1] + AD(High[i],Low[i],Close[i],Volume[i]);  
   for (i=limit-SlowPeriod; i>=0; i--)
   {
         CHO[i]=iMAOnArray(AD,0,FastPeriod,0,MODE_SMA,i) - iMAOnArray(AD,0,SlowPeriod,0,MODE_SMA,i);
   }
   if(SmoothPer > 1)
   for (    i=limit-SlowPeriod; i>=0; i--)
   {
         SM[i]=iMAOnArray(CHO,0,SmoothPer,0,SmoothMode,i);
   }   
   return(0);
}

//+------------------------------------------------------------------+
//| calculate AD                                                     |
//+------------------------------------------------------------------+
double AD(double high, double low, double close, long volume)
{
   double res=0;
   if(high!=low) res=(2*close-high-low)/(high-low)*volume;
   return(res);
}
