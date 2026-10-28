//+------------------------------------------------------------------+
//|                                                     RKD.mq5      |
//|                          Copyright 2010,bigsea QQ:806935610      |
//|                          http://waihuiea.5d6d.com                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010,Bigsea QQ:806935610"
#property link      "http://waihuiea.5d6d.com"
#property version   "1.00"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   4
//---- plot RSV
#property indicator_label1  "RSV"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//---- plot K
#property indicator_label2  "K"
#property indicator_type2   DRAW_LINE
#property indicator_color2  DeepSkyBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//---- plot D
#property indicator_label3  "D"
#property indicator_type3   DRAW_LINE
#property indicator_color3  Blue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1 30
#property indicator_level2 50
#property indicator_level3 70
//---- input parameters
input int       KDPeriod=30;
input int       M1=3;
input int       M2=6;

//---- buffers
double RsvBuffer[],RSV[],K[],D[];
double MaxHigh=0,MinLow=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- name for DataWindow and indicator subwindow label
   string short_name;
   short_name="KD("+IntegerToString(KDPeriod)+","+IntegerToString(M1)+","+IntegerToString(M2)+") "+"Author:BigSea QQ:806935610";

   SetIndexBuffer(0,RSV,INDICATOR_DATA);
   SetIndexBuffer(1,K,INDICATOR_DATA);
   SetIndexBuffer(2,D,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,2);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);

   return(0);
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
//--- check for bars count
   if(rates_total<KDPeriod-1)
      return(0);// not enough bars for calculation

   int    counted_bars=rates_total;
   int bars=Bars(_Symbol,_Period);
   if(bars<=KDPeriod) return(0);
//----
   int limit;
   if(prev_calculated==0) limit=0;
   else                   limit=prev_calculated-1;
   for(int i=rates_total-1;i>=limit;i--)
     {
      MaxHigh=Highest(high,KDPeriod,i);
      MinLow=Lowest(low,KDPeriod,i);

      RSV[i]=(close[i]-MinLow)/(MaxHigh-MinLow)*100;

     }
   Dsma(RSV,K,M1,prev_calculated);
   Dsma(K,D,M2,prev_calculated);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Simple Moving Average                                            |
//+------------------------------------------------------------------+
void Dsma(double &ArrPara1[],double &ArrPara2[],int MA_Period,int barsCnted)
  {
   double sum=0;
   int bars=Bars(_Symbol,_Period);
   int i,limit;
//--- first calculation or number of bars was changed
   if(barsCnted==0)// first calculation
     {
      limit=MA_Period;
      //--- set empty value for first limit bars
      for(i=limit-MA_Period;i<limit;i++) ArrPara2[i]=0.0;
      //--- calculate first visible value
      double firstValue=0;
      for(i=limit-MA_Period;i<limit;i++)
         firstValue+=ArrPara1[i];
      firstValue/=MA_Period;
      ArrPara2[limit-1]=firstValue;
     }
   else limit=barsCnted-1;
//--- main loop
   for(i=limit;i<bars;i++)
      ArrPara2[i]=ArrPara2[i-1]+(ArrPara1[i]-ArrPara1[i-MA_Period])/MA_Period;
  }
//+------------------------------------------------------------------+
//| get highest value for range                                      |
//+------------------------------------------------------------------+
double Highest(const double&array[],int range,int fromIndex)
  {
   double res=0;
//---
   res=array[fromIndex];
   for(int i=fromIndex;i>fromIndex-range && i>=0;i--)
     {
      if(res<array[i]) res=array[i];
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
//| get lowest value for range                                       |
//+------------------------------------------------------------------+
double Lowest(const double&array[],int range,int fromIndex)
  {
   double res=0;
//---
   res=array[fromIndex];
   for(int i=fromIndex;i>fromIndex-range && i>=0;i--)
     {
      if(res>array[i]) res=array[i];
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
