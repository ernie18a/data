//+------------------------------------------------------------------+ 
//|                      Ehlers Reverse EMA                          | 
//+------------------------------------------------------------------+ 
#property description "Code by Max Michael 2023"
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  clrAqua
#property  indicator_width1  1
#property  indicator_level1  0
#property  indicator_levelcolor DarkSlateGray
#property  indicator_levelstyle STYLE_SOLID
#property  strict

extern double    Alpha = 0.1;
extern int     maxbars = 500;

double Main[], ema[], re1[2],re2[2],re3[2],re4[2],re5[2],re6[2],re7[2],re8[2];

int init()
{
   SetIndexBuffer(0,Main); SetIndexStyle(0,DRAW_LINE); SetIndexEmptyValue(0,0);
   SetIndexBuffer(1,ema ); SetIndexStyle(1,DRAW_NONE); SetIndexEmptyValue(1,0);
   IndicatorShortName("Ehlers Reverse EMA ("+string(Alpha)+")");
   if(maxbars > Bars-1) maxbars=Bars-1;
   IndicatorDigits(Digits);
   return(0);
}

void deinit() { }

int start()
{   
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=fmin(Bars-counted_bars-2,maxbars);
   double delta = 1-Alpha;
   
   for(int i=limit; i>=0; i--)
   {
       ema[i] = Alpha * Close[i]+ delta * ema[i+1];
       re1[0] = delta * ema[i] + ema[i+1];
       re2[0] = MathPow(delta,2)  * re1[0]+ re1[1]; 
       re3[0] = MathPow(delta,4)  * re2[0]+ re2[1]; 
       re4[0] = MathPow(delta,8)  * re3[0]+ re3[1]; 
       re5[0] = MathPow(delta,16) * re4[0]+ re4[1]; 
       re6[0] = MathPow(delta,32) * re5[0]+ re5[1]; 
       re7[0] = MathPow(delta,64) * re6[0]+ re6[1]; 
       re8[0] = MathPow(delta,128)* re7[0]+ re7[1]; 
       if(i>0) { re1[1]=re1[0]; re2[1]=re2[0]; re3[1]=re3[0]; re4[1]=re4[0]; re5[1]=re5[0]; re6[1]=re6[0]; re7[1]=re7[0]; }
       if(i<maxbars-75) Main[i]=ema[i] - Alpha * re8[0]; // some bars required to initialize calculation
   }
   return(0);
}
