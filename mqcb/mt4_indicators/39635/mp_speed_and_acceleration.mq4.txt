//+------------------------------------------------------------------+
//|                                       Speed_and_Acceleration.mq4 |
//+------------------------------------------------------------------+
//|                                 price speed and acceleration.mq4 |
//|                               Copyright © 2011, Andrea Salvatore |
//|                                          http://www.pimpmyea.com |
//|										Modified by: fx.padbravo@gmail.com  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Andrea Salvatore/fx.PadBravo@gmail.com"
#property link      "http://www.pimpmyea.com"
#property description "Speed calculated with Hull Moving Average procedure HMA formula"
#property description "R=(2*MA_Fast)-MA_Slow"
#property description "Try using for the avg_period the square of period"
#property strict

#property indicator_separate_window
#property  indicator_buffers 7
#property  indicator_color1  DarkOrange
#property  indicator_color2  DarkCyan
#property  indicator_color3  clrAliceBlue
#property  indicator_color4  clrLightCoral
#property  indicator_color5  clrNONE
#property  indicator_color6  clrNONE
#property  indicator_color7  clrNONE

#property  indicator_width1  1
#property  indicator_width2  1
#property  indicator_width3  1
#property  indicator_width4  1

//---- indicator buffers

extern int period=7;
extern bool show_raw_data=false;
extern bool Use_Hull_Avg=true;
extern bool Use_Absolutes=false;
extern int  avg_period=21;
//extern int	max_bars=500;

int limit;
double speed[],acceleration[],accelerationAVG[],speedAVG[],speedAVG_Fast[],speedAVG_Slow[],speedAVG_Hull[];
double Mul_Speed=10.0,Mul_Accel=100.0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   if(show_raw_data)
     {
      SetIndexStyle(0,DRAW_LINE);
      SetIndexStyle(1,DRAW_LINE);
     }
   else
     {
      SetIndexStyle(0,DRAW_NONE);
      SetIndexStyle(1,DRAW_NONE);
     }

   SetIndexBuffer(0,speed);
   SetIndexBuffer(1,acceleration);
   SetIndexBuffer(2,accelerationAVG);
   SetIndexBuffer(3,speedAVG);
   SetIndexBuffer(4,speedAVG_Slow);
   SetIndexBuffer(5,speedAVG_Fast);
   SetIndexBuffer(6,speedAVG_Hull);

   SetIndexLabel(0,"speed");
   SetIndexLabel(1,"acceleration");
   SetIndexLabel(2,"AVG acceler");
   SetIndexLabel(3,"AVG speed");
   SetIndexLabel(4,"AVG speed Slow");
   SetIndexLabel(5,"AVG speed Fast");
   SetIndexLabel(6,"AVG speed Hull");

	/*
   if(StringSubstr(Symbol(),3,3)=="JPY")
     {
      Mul_Speed=1000.0;
      Mul_Accel=1.0;
     }
   else
     {
      Mul_Speed=1000.0;
      Mul_Accel=1.0;
     }
   */  
   Mul_Accel=1;
   Mul_Speed=1;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted(),i;
//----

   if(counted_bars>0)
      counted_bars--;
   limit=Bars-counted_bars;
   //if(limit>max_bars)limit=max_bars;

   for(i=0; i<limit; i++)
     {
      //speed[i]=(iClose(_Symbol,0,i)-iClose(_Symbol,0,i+period))*Mul_Speed;
      if(Use_Absolutes)
         speed[i]=MathAbs(((iOpen(_Symbol,0,i)-iOpen(_Symbol,0,i+period))+(iClose(_Symbol,0,i)-iClose(_Symbol,0,i+period)))/2);
      if(!Use_Absolutes)
         speed[i]=(((iOpen(_Symbol,0,i)-iOpen(_Symbol,0,i+period))+(iClose(_Symbol,0,i)-iClose(_Symbol,0,i+period)))/2);
     }

   for(i=0; i<limit-period; i++)
     {
      acceleration[i]=(speed[i]-speed[i+period])*Mul_Accel;
     }


   for(i=0; i<limit; i++)
     {
      if(Use_Hull_Avg)
        {
         speedAVG_Slow[i]=iMAOnArray(speed,0,avg_period,0,MODE_EMA,i);
         speedAVG_Fast[i]=iMAOnArray(speed,0,avg_period/2,0,MODE_EMA,i);
         speedAVG_Hull[i]=((2*speedAVG_Fast[i])-speedAVG_Slow[i])*.96;
         //speedAVG[i]=((2*speedAVG_Slow[i])-speedAVG_Fast[i])*.96;
        }
      if(!Use_Hull_Avg)
        {
         speedAVG[i]=iMAOnArray(speed,0,avg_period,0,MODE_EMA,i);
        }
     }
   if(Use_Hull_Avg)
     {
      for(i=0; i<limit-period; i++)
        {
          {speedAVG[i]=iMAOnArray(speedAVG_Hull,0,(int)MathSqrt(avg_period),0,MODE_EMA,i);}
        }
     }

   for(i=0; i<limit-period; i++)
     {
      //accelerationAVG[i]=iMAOnArray(acceleration,0,avg_period,0,MODE_EMA,i);
      if(Use_Absolutes)
         accelerationAVG[i]=MathAbs((speedAVG[i]-speedAVG[i+period])*Mul_Accel);
      if(!Use_Absolutes)
         accelerationAVG[i]=((speedAVG[i]-speedAVG[i+period])*Mul_Accel);
     }

//----
   return(0);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
