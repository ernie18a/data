//+------------------------------------------------------------------+
//|                                                   Const Tick.mq4 |
//|                      Copyright © 2008, Victor Nicolaev aka Vinin |
//|                                            e-mail: vinin@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Victor Nicolaev aka Vinin"
#property link      "e-mail: vinin@mail.ru"


#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 clrWhite
#property indicator_color2 clrRed
#property indicator_color3 clrRed
#property indicator_color4 clrWhite
#property indicator_color5 clrYellow

extern int CountTick=100;

//---- buffers
double _Open[];
double _High[];
double _Low[];
double _Close[];
double _CountBar[];
double _Volume[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   int i;
   IndicatorBuffers(6);
   for(i=0;i<4;i++)
      SetIndexStyle(i,DRAW_LINE);
   SetIndexStyle(4,DRAW_NONE);
//---
   SetIndexBuffer(0,_Open);
   SetIndexBuffer(1,_High);
   SetIndexBuffer(2,_Low);
   SetIndexBuffer(3,_Close);
   SetIndexBuffer(4,_CountBar);
   SetIndexBuffer(5,_Volume);
//---
   SetIndexLabel(0,"Open");
   SetIndexLabel(1,"High");
   SetIndexLabel(2,"Low");
   SetIndexLabel(3,"Close");

   return(0);
  }//int init() 
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
   int i;
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit-=2;
   for(i=limit;i>=0;i--)
     {
      _Volume[i]=_Volume[i+1]+Volume[i];
      _Close[i]=Close[i];
      _Open[i]=_Open[i+1];
      _High[i]=MathMax(High[i],_High[i+1]);
      _Low[i]=MathMin(Low[i],_Low[i+1]);
      _CountBar[i]=_CountBar[i+1]+1;
      CheckWeek(i);
      CheckBar(i);
      CheckTick(i);
     }
   return(0);
  }// int start()
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckTick(int pos)
  {
   if(Volume[pos]>=CountTick)
     {
      _CountBar[pos]=0;
      _Open[pos]   = Open[pos];
      _High[pos]   = High[pos];
      _Low[pos]    = Low[pos];
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckBar(int pos)
  {
   int tmp0=Ostatok(_Volume[pos+0],CountTick);
   int tmp1=Ostatok(_Volume[pos+1],CountTick);
   if(tmp0<tmp1)
     {
      if(tmp0>CountTick-tmp1)
        {
         _CountBar[pos]=0;
         _Open[pos]   = Open[pos];
         _High[pos]   = High[pos];
         _Low[pos]    = Low[pos];
        }
      else
        {
         _CountBar[pos+1]=0;
         _Open[pos+1]   = Open[pos+1];
         _High[pos+1]   = High[pos+1];
         _Low[pos+1]    = Low[pos+1];
         _CountBar[pos]=_CountBar[pos+1]+1;
         _Open[pos]   = _Open[pos+1];
         _High[pos]   = MathMax(High[pos],_High[pos+1]);
         _Low[pos]    = MathMin(Low[pos],_Low[pos+1]);
        }
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckWeek(int pos)
  {
   if(TimeDayOfWeek(Time[pos+1])>TimeDayOfWeek(Time[pos+0]))
     {
      _Volume[pos]=Volume[pos];
      _CountBar[pos]=0;
      _Open[pos]   = Open[pos];
      _High[pos]   = High[pos];
      _Low[pos]    = Low[pos];
      return(true);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Ostatok(double Value1,double Value2)
  {
   double tmp=NormalizeDouble(Value1/Value2,0);
   if(tmp*Value2>Value1) tmp--;
   return(Value1-tmp*Value2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RedRaw(int pos)
  {

  }
//+------------------------------------------------------------------+
