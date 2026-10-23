//+------------------------------------------------------------------+
//|                                                        iBeta.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Integer"
#property link      "https://www.mql5.com/en/users/integer"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Label1
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//+------------------------------------------------------------------+
//| Calculated values                                                |
//+------------------------------------------------------------------+
enum m1
  {
   Covariation=0,
   Symbol1Beta=1,
   Symbol2Beta=2,
   Correlation=3
  };
//+------------------------------------------------------------------+
//| Calculation mode                                                 |
//+------------------------------------------------------------------+
enum m2
  {
   Price=0,
   ROC=1,
   ROC_Percents=2
  };
//--- input parameters
input int     Periods=14;       // Period in bars
input string  Symbol1="EURUSD"; // Symbol 1
input string  Symbol2="GBPUSD"; // Symbol 2
input m1     Mode1=Symbol1Beta; // Calculated value
//--- Mode 1: 0 - covariation, 1 - symbol 1 Beta, 2 - symbol 2 Beta, 3 - correlation
input ENUM_APPLIED_PRICE     Price=PRICE_CLOSE;
//--- Price: 0 - Close, 1 - Open, 2 - High, 3 - Low, 4 - Median, 5 - Typical, 6 - Weighted
input m2     Mode2=ROC_Percents; // Mode 
//--- Mode 1: 0 - Price, 1 - ROC from Price, 2 - ROC% from Price

MqlRates r1[1];
MqlRates r2[1];

double p1[];
double p2[];

double p12[1];
double p22[1];

//--- indicator buffers
double         Label1Buffer[];

int ma1h;
int ma2h;
int ma1h2;
int ma2h2;

double x,y,z1,z2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ArrayResize(p1,Periods+1);
   ArrayResize(p2,Periods+1);
//--- indicator buffers mapping
   SetIndexBuffer(0,Label1Buffer,INDICATOR_DATA);

   ma1h=iMA(Symbol1,PERIOD_CURRENT,1,0,MODE_SMA,Price);
   ma2h=iMA(Symbol2,PERIOD_CURRENT,1,0,MODE_SMA,Price);

   ma1h2=iMA(Symbol1,PERIOD_CURRENT,Periods,0,MODE_SMA,Price);
   ma2h2=iMA(Symbol2,PERIOD_CURRENT,Periods,0,MODE_SMA,Price);

   if(ma1h==INVALID_HANDLE || ma2h==INVALID_HANDLE || ma1h2==INVALID_HANDLE || ma2h2==INVALID_HANDLE)
     {
      Alert("Failed to download МА, relaunch the indicator");
      return(1);
     }

   switch(Mode1)
     {
      case 0:
         IndicatorSetString(INDICATOR_SHORTNAME,Symbol1+" "+Symbol2+" covariation");
         PlotIndexSetString(0,PLOT_LABEL,Symbol1+" "+Symbol2+" covariation");
         break;
      case 1:
         IndicatorSetString(INDICATOR_SHORTNAME,"Beta of "+Symbol1+" with "+Symbol2);
         PlotIndexSetString(0,PLOT_LABEL,"Beta of "+Symbol1+" with "+Symbol2);
         break;
      case 2:
         IndicatorSetString(INDICATOR_SHORTNAME,"Beta of "+Symbol2+" with "+Symbol1);
         PlotIndexSetString(0,PLOT_LABEL,"Beta of "+Symbol2+" with "+Symbol1);
         break;
      case 3:
         IndicatorSetString(INDICATOR_SHORTNAME,Symbol1+" "+Symbol2+" correlation");
         PlotIndexSetString(0,PLOT_LABEL,Symbol1+" "+Symbol2+" correlation");
         break;
     }
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   static bool error=true;
   int start;
   if(prev_calculated==0)
     {
      error=true;
     }
   if(error)
     {
      start=0;
      int b1=Bars(Symbol1,PERIOD_CURRENT);
      int b2=Bars(Symbol2,PERIOD_CURRENT);
      if(b1==0 || b2==0)
        {
         Comment("Waiting for data upload...");
         return(0);
        }
      if(CopyRates(Symbol1,PERIOD_CURRENT,b1-1,1,r1)==-1 ||
         CopyRates(Symbol2,PERIOD_CURRENT,b2-1,1,r2)==-1)
        {
         Comment("Waiting for data upload...");
         return(0);
        }
      for(int i=0;i<rates_total;i++)
        {
         if(time[i]>r1[0].time && time[i]>r2[0].time)
           {
            start=i+Periods+1;
            break;
           }
        }
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,start);
      Comment("");
      error=false;
     }
   else
     {
      start=prev_calculated-1;
     }
   for(int i=start;i<rates_total;i++)
     {
      if(CopyBuffer(ma1h,0,time[i],Periods+1,p1)==-1 ||
         CopyBuffer(ma2h,0,time[i],Periods+1,p2)==-1 ||
         CopyBuffer(ma1h2,0,time[i],1,p12)==-1 ||
         CopyBuffer(ma2h2,0,time[i],1,p22)==-1)
        {
         error=true;
         return(0);
        }

      double aver1=p12[0];
      double aver2=p22[0];

      double cov=0;
      double d1=0;
      double d2=0;
      switch(Mode2)
        {
         case 0:
            for(int j=1;j<=Periods;j++)
              {
               x=p1[j];
               y=p2[j];
               z1=(x-aver1);
               z2=(y-aver2);
               cov+=z1*z2;
               d1+=z1*z1;
               d2+=z2*z2;
              }
            break;
         case 1:
            for(int j=1;j<=Periods;j++)
              {
               x=p1[j]-p1[j-1];
               y=p2[j]-p2[j-1];
               z1=(x-aver1);
               z2=(y-aver2);
               cov+=z1*z2;
               d1+=z1*z1;
               d2+=z2*z2;
              }
            break;
         case 2:
            for(int j=1;j<=Periods;j++)
              {
               x=(p1[j]-p1[j-1])/p1[j-1];
               y=(p2[j]-p2[j-1])/p2[j-1];
               z1=(x-aver1);
               z2=(y-aver2);
               cov+=z1*z2;
               d1+=z1*z1;
               d2+=z2*z2;
              }
            break;

        }

      cov/=Periods;
      d1=MathSqrt(d1/Periods);
      d2=MathSqrt(d2/Periods);
      switch(Mode1)
        {
         case 0:
            Label1Buffer[i]=cov;
            break;
         case 1:
            Label1Buffer[i]=cov/(d2);
            break;
         case 2:
            Label1Buffer[i]=cov/(d1);
            break;
         case 3:
            Label1Buffer[i]=cov/(d1*d2);
            break;
        }

     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
