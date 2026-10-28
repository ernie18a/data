//+------------------------------------------------------------------+
//|                                                Kalman filter.mq4 |
//|                              Copyright © 2006, iziogas@mail.com. |
//|                            Copyright © 2022,fx.padbravo@gmail.com|
//+------------------------------------------------------------------+
#property copyright "iziogas@mail.com"
//----
#property indicator_separate_window
#property strict
//#property indicator_minimum  -100 
//#property indicator_maximum  100 
//--- display two horizontal levels in a separate indicator window 
//#property indicator_level1 -20
//#property indicator_level2 20 

#property indicator_buffers 5
#property indicator_plots 5
#property indicator_color1 clrNONE
#property indicator_label1 "KalmanUP"
#property indicator_color2 clrNONE
#property indicator_label2 "KalmanDN"
#property indicator_color3 clrNONE
#property indicator_label3 "KalmanTOT"
#property indicator_color4 Turquoise
#property indicator_label4 "Speed"
#property indicator_color5 clrBeige
#property indicator_label5 "SpeedAVG"

//---- indicator parameters
//Mode description
// 0: Close
// 1: Open
// 2: High
// 3: Low
// 4: Median   (H+L/2)
// 5: Typical  (H+L+C/3)
// 6: Weighted (H+L+C+C/4)
extern ENUM_APPLIED_PRICE Mode=PRICE_OPEN;
extern double K=1;
extern double Sharpness=1;
extern int    draw_begin=500;
extern int	  SigPeriodAVG=6;
extern int	  SigShiftAVG=0;	
//---- indicator buffers
double ExtMapBufferUp[];
double ExtMapBufferDown[];
double ExtKalman[];
double ExtSpeed[];
double ExtSpeedAvg[];

//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorDigits((int)MarketInfo(Symbol(),MODE_DIGITS));
   
//---- drawing settings
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBufferUp,INDICATOR_CALCULATIONS);
   SetIndexBuffer(1,ExtMapBufferDown,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,ExtKalman,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtSpeed,INDICATOR_DATA);
   SetIndexBuffer(4,ExtSpeedAvg,INDICATOR_DATA);

   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);

   SetIndexDrawBegin(0,draw_begin);
   SetIndexDrawBegin(1,draw_begin);
   SetIndexDrawBegin(2,draw_begin);
   SetIndexDrawBegin(3,draw_begin);
   SetIndexDrawBegin(4,draw_begin);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iValue(int mode,int shift)
  {
   switch(mode)
     {
      case PRICE_CLOSE:
         return(iClose(NULL,0,shift));
      case PRICE_OPEN:
         return(iOpen(NULL,0,shift));
      case PRICE_HIGH:
         return(iHigh(NULL,0,shift));
      case PRICE_LOW:
         return(iLow(NULL,0,shift));
      case PRICE_MEDIAN:
         return((iHigh(NULL,0,shift)+iLow(NULL,0,shift))/2);
      case PRICE_TYPICAL:
         return((iHigh(NULL,0,shift)+iLow(NULL,0,shift)+iClose(NULL,0,shift))/3);
      case PRICE_WEIGHTED:
         return((iHigh(NULL,0,shift)+iLow(NULL,0,shift)+iClose(NULL,0,shift)+iClose(NULL,0,shift))/4);
      default:
         return(0);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   if(Bars<=draw_begin)
      return(0);
//----
   int i;
//----
   double Velocity=0;
   double Distance=0;
   double Error=0;
   double value=iValue(Mode,draw_begin+1);
//----
   for(i=draw_begin; i>=0; i--)
     {
      Distance=iValue(Mode,i)-value;
      Error=value+Distance*MathSqrt(Sharpness*K/100);
      Velocity=Velocity+Distance*K/100;
      value=Error+Velocity;
      //color lines
      ExtKalman[i]=value;
      ExtSpeed[i]=Velocity;
      ExtSpeedAvg[i]=iMAOnArray(ExtSpeed,0,SigPeriodAVG,SigShiftAVG,MODE_EMA,i);
      //ExtSpeed[i]=Velocity;
      
      if(Velocity>0)
        {
         ExtMapBufferUp[i]=value;
         //ExtMapBufferUp[i] = S;
         ExtMapBufferDown[i]=EMPTY_VALUE;
         //----
         if(ExtMapBufferUp[i+1]==EMPTY_VALUE)
            ExtMapBufferUp[i+1]=ExtMapBufferDown[i+1];
        }
      else
        {
         ExtMapBufferUp[i]=EMPTY_VALUE;
         ExtMapBufferDown[i]=value;
         //ExtMapBufferDown[i] = S;
         if(ExtMapBufferDown[i+1]==EMPTY_VALUE)
            ExtMapBufferDown[i+1]=ExtMapBufferUp[i+1];
        }
     }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+
