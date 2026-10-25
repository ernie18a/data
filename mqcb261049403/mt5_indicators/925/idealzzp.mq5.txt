//+------------------------------------------------------------------+
//|                                                     IdealZZP.mq5 |
//+------------------------------------------------------------------+
#property copyright "TheXpert"
#property link      "https://www.mql5.com/ru/users/thexpert"
#property version   "1.00"
#property indicator_chart_window

input double ChannelPercent=0.1; // Minimum price percent in a ray
// attention! when used, this option can lead to incorrect visualization of last ZZ ray at 0 bar
// incorrect visualization will be redrawn when new bar appears
// use it carefully and don't expect complete correctness
// never(!) use this indicator values from 0 bar in your automated strategies.

// never(!) use this option if this indicator is used in automated strategy.
// if used, this option can lead to incorrect extremum parsing in your EA

bool DrawZeroBar=false;

#property indicator_plots 4
#property indicator_buffers 5
#property indicator_label1  "Ideal ZZ"
#property indicator_type1   DRAW_ZIGZAG
#property indicator_color1  clrGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

// all the other buffer are fake and shouldn't paint.
// but they should be accessible, thus they are drawn as plot data

#property indicator_label2  "Ideal ZZ"
#property indicator_type2   DRAW_NONE
#property indicator_color2  clrNONE
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "Ideal ZZ"
#property indicator_type3   DRAW_NONE
#property indicator_color3  clrNONE
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#property indicator_label4  "Ideal ZZ"
#property indicator_type4   DRAW_NONE
#property indicator_color4  clrNONE
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

double Maxs[];
double Mins[];

double Direction[];

double MaxTime[];
double MinTime[];

string symbol;

#define UP 0.0001
#define DN -0.0001
#define NONE 0

bool Inited;
datetime LastTime;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   SetIndexBuffer(0,Maxs,INDICATOR_DATA);
   SetIndexBuffer(1,Mins,INDICATOR_DATA);
   SetIndexBuffer(2,MinTime,INDICATOR_DATA);
   SetIndexBuffer(3,MaxTime,INDICATOR_DATA);
   SetIndexBuffer(4,Direction,INDICATOR_DATA);

   Inited=false;
   LastTime=0;

   ArraySetAsSeries(Maxs,true);
   ArraySetAsSeries(Mins,true);
   ArraySetAsSeries(Direction,true);
   ArraySetAsSeries(MaxTime,true);
   ArraySetAsSeries(MinTime,true);

   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int bars,
                const int counted,
                const datetime &T[],
                const double &O[],
                const double &H[],
                const double &L[],
                const double &C[],
                const long &TV[],
                const long &V[],
                const int &S[])
  {
   if(!Inited)
     {
      ArrayInitialize(Mins,EMPTY_VALUE);
      ArrayInitialize(Maxs,EMPTY_VALUE);
      ArrayInitialize(MinTime,EMPTY_VALUE);
      ArrayInitialize(MaxTime,EMPTY_VALUE);
      ArrayInitialize(Direction,EMPTY_VALUE);
     }

   ArraySetAsSeries(T,true);
   ArraySetAsSeries(O,true);
   ArraySetAsSeries(H,true);
   ArraySetAsSeries(L,true);
   ArraySetAsSeries(C,true);

   int ToCount=(int)MathMin(bars-1,bars-MathMax(counted,0));

// DON'T fix to >= 0. For the 0 bar the logic is in DrawZeroBar block
   for(int i=ToCount;(i>0) && !IsStopped(); i--)
     {
      if(i<bars-1)
        {
         MinTime[i] = MinTime[i + 1];
         MaxTime[i] = MaxTime[i + 1];
         Direction[i]=Direction[i+1];
         Maxs[i] = EMPTY_VALUE;
         Mins[i] = EMPTY_VALUE;
        }

      if(C[i]<O[i])
        {
         CheckPrice(i,H[i],T,H,L);
         CheckPrice(i,L[i],T,H,L);
        }
      else
        {
         CheckPrice(i,L[i],T,H,L);
         CheckPrice(i,H[i],T,H,L);
        }
     }

   if(DrawZeroBar)
     {
      if(LastTime!=T[0])
        {
         LastTime=T[0];

         MinTime[0] = MinTime[1];
         MaxTime[0] = MaxTime[1];
         Direction[0]=Direction[1];
         Maxs[0] = EMPTY_VALUE;
         Mins[0] = EMPTY_VALUE;
        }
      CheckPrice(0,C[0],T,H,L);
     }
   else
     {
      Maxs[0] = EMPTY_VALUE;
      Mins[0] = EMPTY_VALUE;
     }

   return(bars);
  }
//+------------------------------------------------------------------+
//| CheckPrice                                                       |
//+------------------------------------------------------------------+
void CheckPrice(int offset,double p,const datetime &T[],const double &H[],const double &L[])
  {
   if(!Inited)
     {
      CheckInit(offset,p,T);
      Inited=true;
     }
   else
     {
      if(Direction[offset]==UP) CheckUp(offset,p,T,H);
      else if(Direction[offset]==DN) CheckDn(offset,p,T,L);
     }
  }
//+------------------------------------------------------------------+
//| CheckInit                                                        |
//+------------------------------------------------------------------+
void CheckInit(int offset,double c,const datetime &T[])
  {
   MaxTime[offset] = (double)T[offset];
   MinTime[offset] = (double)T[offset];
   Maxs[offset] = c;
   Mins[offset] = c;
   Direction[offset]=UP;
  }
//+------------------------------------------------------------------+
//| CheckUp                                                          |
//+------------------------------------------------------------------+
void CheckUp(int offset,double c,const datetime &T[],const double &H[])
  {
   int lastOffset=ArrayBsearch(T,(datetime)MaxTime[offset]);
   if(Maxs[lastOffset]==EMPTY_VALUE)
     {
      Maxs[lastOffset]=H[lastOffset];
     }

   if(c>Maxs[lastOffset])
     {
      Maxs[lastOffset]=EMPTY_VALUE;
      Maxs[offset]=c;
      MaxTime[offset]=(double)T[offset];
      lastOffset=offset;
     }

   if(Maxs[lastOffset]/c>1.0+ChannelPercent/100.0)
     {
      Direction[offset]=DN;
      Mins[offset]=c;
      MinTime[offset]=(double)T[offset];
     }
  }
//+------------------------------------------------------------------+
//| CheckDn                                                          |
//+------------------------------------------------------------------+
void CheckDn(int offset,double c,const datetime &T[],const double &L[])
  {
   int lastOffset=ArrayBsearch(T,(datetime)MinTime[offset]);
   if(Mins[lastOffset]==EMPTY_VALUE)
     {
      Mins[lastOffset]=L[lastOffset];
     }

   if(c<Mins[lastOffset])
     {
      Mins[lastOffset]=EMPTY_VALUE;
      Mins[offset]=c;
      MinTime[offset]=(double)T[offset];
      lastOffset=offset;
     }

   if(c/Mins[lastOffset]>1.0+ChannelPercent/100.0)
     {
      Direction[offset]=UP;
      Maxs[offset]=c;
      MaxTime[offset]=(double)T[offset];
     }
  }
//+------------------------------------------------------------------+
