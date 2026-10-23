//+------------------------------------------------------------------+
//|                                                      ColorZZ.mq5 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Yurich"
#property link      "https://www.mql5.com/ru/users/yurich"
#property version   "1.00"
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 	3
#property indicator_plots 		1
#property indicator_label1  	"Color ZZ"
#property indicator_type1		DRAW_COLOR_ZIGZAG
#property indicator_color1  	clrRed,clrGold,clrLime,clrAqua,clrBlue
#property indicator_style1  	STYLE_SOLID
#property indicator_width1  	2
//+------------------------------------------------------------------+
input int Depth=300; // Minimum points in a ray
//+------------------------------------------------------------------+
double zzH[],zzL[],zzC[];
double fibo[]={0.382,0.618,1.0,1.618};
double levels[];
double depth,cd;
int last,direction,cnt,prev;
//+------------------------------------------------------------------+
void OnInit()
  {
   SetIndexBuffer(0,zzH,INDICATOR_DATA);
   SetIndexBuffer(1,zzL,INDICATOR_DATA);
   SetIndexBuffer(2,zzC,INDICATOR_COLOR_INDEX);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   depth=Depth*_Point;
   cd=0;
   direction=1;
   last=prev=0;
   cnt=ArraySize(fibo);
   ArrayResize(levels,cnt);
  }
//+------------------------------------------------------------------+
#define SetLevels(_d) for(int _i=0;_i<cnt;_i++) levels[_i]=_d*fibo[_i]
//+------------------------------------------------------------------+
int OnCalculate(const int total,
					 const int calculated,
					 const datetime &time[],
					 const double &open[],
					 const double &high[],
					 const double &low[],
					 const double &close[],
					 const long &tick[],
					 const long &real[],
					 const int &spread[])
  {
   if(calculated==0) cd=prev=last=0; 
   for(int i=calculated>0?calculated-1:0; i<total-1; i++)
     {
      bool set=false;
      double ld=cd;
      zzL[i]=0;
      zzH[i]=0;
      //---
      if(direction>0)
        {
         if(high[i]>zzH[last])
           {
            cd=high[i]-zzL[prev];
            zzH[last]=0;
            zzH[i]=high[i];
            if(low[i]<high[last]-depth)
              {
               if(open[i]<close[i])
                 {
                  zzH[last]=high[last];
                  cd=high[last]-low[i];
                  ld=high[last]-low[prev];
                  SetLevels(ld);
                  zzC[i]=SetColor(cd);
                  prev=i;
                 }
               else
                 {
                  direction=-1;
                  zzC[i]=SetColor(cd);
                  SetLevels(cd);
                  prev=i;
                 }
               zzL[i]=low[i];
              }
            else zzC[i]=SetColor(cd);
            last=i;
            set=true;
           }
         if(low[i]<zzH[last]-depth && (!set || open[i]>close[i]))
           {
            zzL[i]=low[i];
            if(high[i]>zzL[i]+depth && open[i]<close[i])
              {
               zzH[i]=high[i];
               cd=high[last]-low[i];
               ld=high[last]-low[prev];
               SetLevels(ld);
               zzC[i]=SetColor(cd);
               SetLevels(cd);
               prev=i;
              }
            else
              {
               direction=-1;
               if(!set)
                 {
                  cd=high[last]-low[i];
                  ld=high[last]-low[prev];
                  SetLevels(ld);
                  zzC[i]=SetColor(cd);
                  cd=ld;
                 }
               else SetLevels(cd);
               prev=last;
              }
            last=i;
           }
        }
      else   //direction<0
        {
         if(low[i]<zzL[last])
           {
            cd=zzH[prev]-low[i];
            zzL[last]=0;
            zzL[i]=low[i];
            if(high[i]>low[last]+depth)
              {
               if(open[i]>close[i])
                 {
                  zzL[last]=low[last];
                  cd=high[i]-zzL[last];
                  ld=high[prev]-low[last];
                  SetLevels(ld);
                  zzC[i]=SetColor(cd);
                  SetLevels(cd);
                  prev=i;
                 }
               else
                 {
                  direction=1;
                  zzC[i]=SetColor(cd);
                  SetLevels(cd);
                  prev=i;
                 }
               zzH[i]=high[i];
              }
            else zzC[i]=SetColor(cd);
            last=i;
            set=true;
           }
         if(high[i]>zzL[last]+depth && (!set || open[i]<close[i]))
           {
            zzH[i]=high[i];
            if(low[i]<zzH[i]-depth && open[i]>close[i])
              {
               zzL[i]=low[i];
               cd=high[i]-low[last];
               ld=high[prev]-low[last];
               SetLevels(ld);
               zzC[i]=SetColor(cd);
               SetLevels(cd);
               prev=i;
              }
            else
              {
               direction=1;
               if(!set)
                 {
                  cd=high[i]-low[last];
                  ld=high[prev]-low[last];
                  SetLevels(ld);
                  zzC[i]=SetColor(cd);
                  cd=ld;
                 }
               else SetLevels(cd);
               prev=last;
              }
            last=i;
           }
        }
     }
//----
   zzH[total-1]=0;
   zzL[total-1]=0;
   return(total);
  }
//+------------------------------------------------------------------+
int SetColor(double d)
  {
   int i;
   for(i=0; i<cnt; i++)
      if(d<=levels[i]) return(i);
   return(i);
  }
//+------------------------------------------------------------------+
