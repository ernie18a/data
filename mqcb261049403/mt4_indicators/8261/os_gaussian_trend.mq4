//+------------------------------------------------------------------+
//|                                          One Side Gaussian trend |
//|                                                           mladen |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 clrOrangeRed
#property indicator_color2 clrGreen
#property indicator_color3 clrOrangeRed
#property indicator_color4 clrGreen
#property indicator_color5 clrOrangeRed
#property indicator_color6 clrGreen
#property indicator_color7 clrOrangeRed
#property indicator_color8 clrGreen
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2
#property indicator_width7 2
#property indicator_width8 2

#property indicator_maximum 4
#property indicator_minimum 0

//
//
//
//
//

#import "OneSideGaussianLibrary.ex4"
void   BuffersInit();
double Smooth(int version,int price,int i);
#import

//
//
//
//
//

extern string _            = "parameters";
extern int    SRPeriod     = 40;
extern int    SRSmoothType = 5;
extern int    MASmoothType = 5;
extern int    MAPrice      = PRICE_CLOSE;

//
//
//
//
//

double buffer1[];
double buffer2[];
double buffer3[];
double buffer4[];
double buffer5[];
double buffer6[];
double buffer7[];
double buffer8[];
string IndicatorFileName;
bool   calculating = false;
bool   gettingBars = false;

//
//
//
//
//

int    frames[4];
int    periods[]={PERIOD_M1,PERIOD_M5,PERIOD_M15,PERIOD_M30,PERIOD_H1,PERIOD_H4,PERIOD_D1,PERIOD_W1,PERIOD_MN1,-1,-1,-1,-1};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
  {
   SetIndexBuffer(0,buffer1);
   SetIndexBuffer(1,buffer2);
   SetIndexBuffer(2,buffer3);

//
//
//
//
//

   SRSmoothType = MathMax(MathMin(SRSmoothType,7),0);
   MASmoothType = MathMax(MathMin(MASmoothType,7),0);
   if(_=="calculate")
     {
      BuffersInit(); calculating=true;
      return(0);
     }
   if(_=="gettingBars")
     {
      gettingBars=true;
      return(0);
     }

//
//
//
//
//

   SetIndexBuffer(3,buffer4);
   SetIndexBuffer(4,buffer5);
   SetIndexBuffer(5,buffer6);
   SetIndexBuffer(6,buffer7);
   SetIndexBuffer(7,buffer8);
   IndicatorShortName("OS Gaussian trend("+SRPeriod+","+SRSmoothType+","+MASmoothType+")");
   IndicatorDigits(0);
   IndicatorFileName=WindowExpertName();

   int begin=0;
   while(periods[begin]<Period()) begin++;
   frames[0] = periods[begin+0];
   frames[1] = periods[begin+1];
   frames[2] = periods[begin+2];
   frames[3] = periods[begin+3];

//
//
//
//
//

   for(int i=0; i<8; i++)
     {
      SetIndexStyle(i,DRAW_HISTOGRAM);
      string TimeFrameStr="";
      switch(frames[i/2])
        {
         case PERIOD_M1:  TimeFrameStr="(M1)";      break;
         case PERIOD_M5:  TimeFrameStr="(M5)";      break;
         case PERIOD_M15: TimeFrameStr="(M15)";     break;
         case PERIOD_M30: TimeFrameStr="(M30)";     break;
         case PERIOD_H1:  TimeFrameStr="(H1)";      break;
         case PERIOD_H4:  TimeFrameStr="(H4)";      break;
         case PERIOD_D1:  TimeFrameStr="(Dayly)";   break;
         case PERIOD_W1:  TimeFrameStr="(Weekly)";  break;
         case PERIOD_MN1: TimeFrameStr="(Monthly)"; break;
        }

      if((i%2)==0)
         SetIndexLabel(i,"OS trend "+TimeFrameStr+" down");
      else  SetIndexLabel(i,"OS trend "+TimeFrameStr+" up");
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
  {
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit-=SRPeriod;
//
//
//
//
//

   if(gettingBars) { buffer1[0]=limit; return(0); }
   if(calculating)
     {
      for(i=limit; i>=0; i--)
        {
         buffer2[i] = Smooth(SRSmoothType,PRICE_LOW, i);
         buffer3[i] = Smooth(SRSmoothType,PRICE_HIGH,i);
         double support    = buffer2[ArrayMinimum(buffer2,SRPeriod,i)];
         double resistance = buffer3[ArrayMaximum(buffer3,SRPeriod,i)];
         double median     = (support+resistance)/2;
         double average    = Smooth(MASmoothType,MAPrice,i);

         buffer1[i]=0;
         if(median > average) buffer1[i] =  1;
         if(median < average) buffer1[i] = -1;
        }
      return(0);
     }

//
//
//
//
//

   if(frames[0]>-1) CalculateIt(limit,4,frames[0],buffer1,buffer2);
   if(frames[1]>-1) CalculateIt(limit,3,frames[1],buffer3,buffer4);
   if(frames[2]>-1) CalculateIt(limit,2,frames[2],buffer5,buffer6);
   if(frames[3]>-1) CalculateIt(limit,1,frames[3],buffer7,buffer8);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void CalculateIt(int limit,int value,int timeFrame,double &bufferu[],double &bufferd[])
  {
   int shifp=EMPTY_VALUE;

   limit=MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,IndicatorFileName,"gettingBars",0,0)*timeFrame/Period()));
   limit-=SRPeriod;
//
//
//
//
//

   for(int i=limit; i>=0; i--)
     {
      bufferu[i] = bufferu[i+1];
      bufferd[i] = bufferd[i+1];

      int shift= iBarShift(NULL,timeFrame,Time[i]);
      if(shift == shifp) continue;

      double trend=iCustom(NULL,timeFrame,IndicatorFileName,"calculate",SRPeriod,SRSmoothType,MASmoothType,MAPrice,0,shift);

      if(trend>0) { bufferu[i] = value; bufferd[i] = EMPTY_VALUE; }
      if(trend<0) { bufferd[i] = value; bufferu[i] = EMPTY_VALUE; }
      shifp=shift;
     }
  }
//+------------------------------------------------------------------+
