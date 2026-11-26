//+------------------------------------------------------------------+
//|                                Peak_Lines_by_Price_Histogram.mq5 |
//|                                           Copyright 2015, fxborg |
//|                                  http://blog.livedoor.jp/fxborg/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, fxborg"
#property link      "http://blog.livedoor.jp/fxborg/"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 32
#property indicator_plots   8
#property indicator_type1 DRAW_ARROW
#property indicator_type2 DRAW_ARROW
#property indicator_type3 DRAW_ARROW
#property indicator_type4 DRAW_ARROW
#property indicator_type5 DRAW_ARROW
#property indicator_type6 DRAW_ARROW
#property indicator_type7 DRAW_ARROW
#property indicator_type8 DRAW_ARROW
//---
#property indicator_color1 Gold
#property indicator_color2 Gold
#property indicator_color3 Red
#property indicator_color4 Red
#property indicator_color5 Magenta
#property indicator_color6 Magenta
#property indicator_color7 DeepSkyBlue
#property indicator_color8 DeepSkyBlue
#property indicator_label1 "1st Peek daily"
#property indicator_label2 "2nd Peek daily"
#property indicator_label3 "1st Peek short"
#property indicator_label4 "2nd Peek short"
#property indicator_label5 "1st Peek medium"
#property indicator_label6 "2nd Peek medium"
#property indicator_label7 "1st Peek long"
#property indicator_label8 "2nd Peek long"
//---
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 1
#property indicator_width8 1
#property indicator_style1 STYLE_DASH
#property indicator_style2 STYLE_DASH
#property indicator_style3 STYLE_DASH
#property indicator_style4 STYLE_DASH
#property indicator_style5 STYLE_DASH
#property indicator_style6 STYLE_DASH
#property indicator_style7 STYLE_DASH
#property indicator_style8 STYLE_DASH
//--- input parameters
input double InpBinRange=2.5;       // Bin range of price histogram
input  int InpCalcTime=4;           // Calculation Time(hour)
input  int InpShortTermPeriod =3;   // Short term period(day)
input  int InpMediumTermPeriod=7;   // Medium term period(day)
input  int InpLongTermPeriod =26;   // Long term period(day)
input bool InpUsingVolumeWeight=true;   // Using TickVolume
//---
int PivotHour=4;                    // Pivot period (hour) 
//---
int d1_period=24*12;   // for 5min
int st_period = InpShortTermPeriod*24*12;   // for 5min
int mt_period = InpMediumTermPeriod*24;     // for 1h
int lt_period = InpLongTermPeriod*24;       // for 1h
//---
int zoom_out_factor=8;
//---
double Day1Buffer[];
double Short1Buffer[];
double Medium1Buffer[];
double Long1Buffer[];
double Day2Buffer[];
double Short2Buffer[];
double Medium2Buffer[];
double Long2Buffer[];
//---
double D1Buffer[];
double D2Buffer[];
double D3Buffer[];
double D4Buffer[];
double S1Buffer[];
double S2Buffer[];
double S3Buffer[];
double S4Buffer[];
double M1Buffer[];
double M2Buffer[];
double M3Buffer[];
double M4Buffer[];
double M5Buffer[];
double M6Buffer[];
double M7Buffer[];
double M8Buffer[];
double L1Buffer[];
double L2Buffer[];
double L3Buffer[];
double L4Buffer[];
double L5Buffer[];
double L6Buffer[];
double L7Buffer[];
double L8Buffer[];
//---
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_total=1+InpLongTermPeriod*PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
//---- indicator buffers mapping
//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,Day1Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,Day2Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,Short1Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,Short2Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,Medium1Buffer,INDICATOR_DATA);
   SetIndexBuffer(5,Medium2Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,Long1Buffer,INDICATOR_DATA);
   SetIndexBuffer(7,Long2Buffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_ARROW,158);
   PlotIndexSetInteger(1,PLOT_ARROW,158);
   PlotIndexSetInteger(2,PLOT_ARROW,158);
   PlotIndexSetInteger(3,PLOT_ARROW,158);
   PlotIndexSetInteger(4,PLOT_ARROW,158);
   PlotIndexSetInteger(5,PLOT_ARROW,158);
   PlotIndexSetInteger(6,PLOT_ARROW,158);
   PlotIndexSetInteger(7,PLOT_ARROW,158);
   SetIndexBuffer(8,D1Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,D2Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,D3Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,D4Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,S1Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,S2Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,S3Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(15,S4Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(16,M1Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(17,M2Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(18,M3Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(19,M4Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(20,M5Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(21,M6Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(22,M7Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(23,M8Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(24,L1Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(25,L2Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(26,L3Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(27,L4Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(28,L5Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(29,L6Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(30,L7Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(31,L8Buffer,INDICATOR_CALCULATIONS);
//---
   PlotIndexSetInteger(0,PLOT_SHIFT,1);
   PlotIndexSetInteger(1,PLOT_SHIFT,1);
   PlotIndexSetInteger(2,PLOT_SHIFT,1);
   PlotIndexSetInteger(3,PLOT_SHIFT,1);
   PlotIndexSetInteger(4,PLOT_SHIFT,1);
   PlotIndexSetInteger(5,PLOT_SHIFT,1);
   PlotIndexSetInteger(6,PLOT_SHIFT,1);
   PlotIndexSetInteger(7,PLOT_SHIFT,1);
//---
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(7,PLOT_DRAW_BEGIN,min_rates_total);
//---
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,0);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Peak Lines");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
   return(INIT_SUCCEEDED);
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
//---
   int i,first;
//--- check for bars count
   if(rates_total<=min_rates_total)
      return(0);
//---
   first=min_rates_total-1;
   if(first+1<prev_calculated) first=prev_calculated-2;
//---- Main calculation loop of the indicator
   for(i=first; i<rates_total && !IsStopped(); i++)
     {
      MqlDateTime tm0,tm1;
      TimeToStruct(time[i],tm0);
      TimeToStruct(time[i-1],tm1);
      bool is_update=false;
      if(!tm0.hour != tm0.hour && tm0.hour == InpCalcTime && tm0.hour == InpCalcTime)
        {
         int d1_peaks[];
         int st_peaks[];
         int mt_peaks[];
         int lt_peaks[];
         bool ok=calc_ds_peaks(d1_peaks,st_peaks,time[i]);
         ok=ok && calc_ml_peaks(lt_peaks,mt_peaks,time[i]);
         if(ok)
           {
            int d1_sz=ArraySize(d1_peaks);
            if(d1_sz>0)D1Buffer[i]=d1_peaks[0]*_Point; else D1Buffer[i]=0;
            if(d1_sz>1)D2Buffer[i]=d1_peaks[1]*_Point; else D2Buffer[i]=0;
            if(d1_sz>2)D3Buffer[i]=d1_peaks[2]*_Point; else D3Buffer[i]=0;
            if(d1_sz>3)D4Buffer[i]=d1_peaks[3]*_Point; else D4Buffer[i]=0;
            int st_sz=ArraySize(st_peaks);
            if(st_sz>0)S1Buffer[i]=st_peaks[0]*_Point; else S1Buffer[i]=0;
            if(st_sz>1)S2Buffer[i]=st_peaks[1]*_Point; else S2Buffer[i]=0;
            if(st_sz>2)S3Buffer[i]=st_peaks[2]*_Point; else S3Buffer[i]=0;
            if(st_sz>3)S4Buffer[i]=st_peaks[3]*_Point; else S4Buffer[i]=0;
            int mt_sz=ArraySize(mt_peaks);
            if(mt_sz>0)M1Buffer[i]=mt_peaks[0]*_Point; else M1Buffer[i]=0;
            if(mt_sz>1)M2Buffer[i]=mt_peaks[1]*_Point; else M2Buffer[i]=0;
            if(mt_sz>2)M3Buffer[i]=mt_peaks[2]*_Point; else M3Buffer[i]=0;
            if(mt_sz>3)M4Buffer[i]=mt_peaks[3]*_Point; else M4Buffer[i]=0;
            if(mt_sz>4)M5Buffer[i]=mt_peaks[4]*_Point; else M5Buffer[i]=0;
            if(mt_sz>5)M6Buffer[i]=mt_peaks[5]*_Point; else M6Buffer[i]=0;
            if(mt_sz>6)M7Buffer[i]=mt_peaks[6]*_Point; else M7Buffer[i]=0;
            if(mt_sz>7)M8Buffer[i]=mt_peaks[7]*_Point; else M8Buffer[i]=0;
            int lt_sz=ArraySize(lt_peaks);
            if(lt_sz>0)L1Buffer[i]=lt_peaks[0]*_Point; else L1Buffer[i]=0;
            if(lt_sz>1)L2Buffer[i]=lt_peaks[1]*_Point; else L2Buffer[i]=0;
            if(lt_sz>2)L3Buffer[i]=lt_peaks[2]*_Point; else L3Buffer[i]=0;
            if(lt_sz>3)L4Buffer[i]=lt_peaks[3]*_Point; else L4Buffer[i]=0;
            if(lt_sz>4)L5Buffer[i]=lt_peaks[4]*_Point; else L5Buffer[i]=0;
            if(lt_sz>5)L6Buffer[i]=lt_peaks[5]*_Point; else L6Buffer[i]=0;
            if(lt_sz>6)L7Buffer[i]=lt_peaks[6]*_Point; else L7Buffer[i]=0;
            if(lt_sz>7)L8Buffer[i]=lt_peaks[7]*_Point; else L8Buffer[i]=0;
            is_update=true;
           }
        }
      if(!is_update)
        {
         D1Buffer[i]=0;  D2Buffer[i]=0;  D3Buffer[i]=0;  D4Buffer[i]=0;
         S1Buffer[i]=0;  S2Buffer[i]=0;  S3Buffer[i]=0;  S4Buffer[i]=0;
         M1Buffer[i]=0;  M2Buffer[i]=0;  M3Buffer[i]=0;  M4Buffer[i]=0;
         M5Buffer[i]=0;  M6Buffer[i]=0;  M7Buffer[i]=0;  M8Buffer[i]=0;
         L1Buffer[i]=0;  L2Buffer[i]=0;  L3Buffer[i]=0;  L4Buffer[i]=0;
         L5Buffer[i]=0;  L6Buffer[i]=0;  L7Buffer[i]=0;  L8Buffer[i]=0;
        }
     }
//---
   for(i=first; i<rates_total && !IsStopped(); i++)
     {
      //--- pivot point 
      double h[];
      double l[];
      double c[];
      CopyHigh(Symbol(),PERIOD_H1,time[i],PivotHour,h);
      CopyLow(Symbol(),PERIOD_H1,time[i],PivotHour,l);
      CopyClose(Symbol(),PERIOD_H1,time[i],1,c);
      double hi=h[ArrayMaximum(h)];
      double lo=l[ArrayMinimum(l)];
      double cl=c[0];
      //---
      double pp=(cl+hi+lo)/3;
      double s1=pp*2-hi;
      double r1=pp*2-lo;
      double s2 = pp - (r1-s1);
      double r2 =(pp -s1)+r1;
      //---
      set_1d_peeks(s2,r2,i);
      set_st_peeks(s2,r2,i);
      set_mt_peeks(s2,r2,i);
      set_lt_peeks(s2,r2,i);
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| set 1 day peak                                                   |
//+------------------------------------------------------------------+
void set_1d_peeks(double s2,double r2,int i)
  {
   int d1cnt=0;
//--- 1day peek line is important 
   if(D1Buffer[i]>0) Day1Buffer[i]=D1Buffer[i]; else Day1Buffer[i]=Day1Buffer[i-1];
   d1cnt++;
//---
   if(s2<=D2Buffer[i] && D2Buffer[i]<=r2)
     {
      if(d1cnt==0) Day1Buffer[i]=D2Buffer[i];  else Day2Buffer[i]=D2Buffer[i];
      d1cnt++;
     }
   if(d1cnt<2 && s2<=D3Buffer[i] && D3Buffer[i]<=r2)
     {
      if(d1cnt==0) Day1Buffer[i]=D3Buffer[i];  else Day2Buffer[i]=D3Buffer[i];
      d1cnt++;
     }
   if(d1cnt<2 && s2<=D4Buffer[i] && D4Buffer[i]<=r2)
     {
      if(d1cnt==0) Day1Buffer[i]=D4Buffer[i];  else Day2Buffer[i]=D4Buffer[i];
      d1cnt++;
     }
   if(d1cnt<2)Day2Buffer[i]=Day2Buffer[i-1];
  }
//+------------------------------------------------------------------+
//| set short term peak                                              |
//+------------------------------------------------------------------+
void set_st_peeks(double s2,double r2,int i)
  {
//---
   int s_cnt=0;
//--- 1day peak lines
   if(s2<=S1Buffer[i] && S1Buffer[i]<=r2)
     {
      Short1Buffer[i]=S1Buffer[i];
      s_cnt++;
     }
   if(s2<=S2Buffer[i] && S2Buffer[i]<=r2)
     {
      if(s_cnt==0) Short1Buffer[i]=S2Buffer[i]; else Short2Buffer[i]=S2Buffer[i];
      s_cnt++;
     }
   if(s_cnt<2 && s2<=S3Buffer[i] && S3Buffer[i]<=r2)
     {
      if(s_cnt==0) Short1Buffer[i]=S3Buffer[i]; else Short2Buffer[i]=S3Buffer[i];
      s_cnt++;
     }
   if(s_cnt<2 && s2<=S4Buffer[i] && S4Buffer[i]<=r2)
     {
      if(s_cnt==0) Short1Buffer[i]=S4Buffer[i]; else Short2Buffer[i]=S4Buffer[i];
      s_cnt++;
     }
   if(s_cnt<1)Short1Buffer[i] = Short1Buffer[i-1];
   if(s_cnt<2)Short2Buffer[i] = Short2Buffer[i-1];
  }
//+------------------------------------------------------------------+
//| set medium term peak                                             |
//+------------------------------------------------------------------+
void set_mt_peeks(double s2,double r2,int i)
  {
   int m_cnt=0;
   if(s2<=M1Buffer[i] && M1Buffer[i]<=r2)
     {
      Medium1Buffer[i]=M1Buffer[i];
      m_cnt++;
     }
   if(s2<=M2Buffer[i] && M2Buffer[i]<=r2)
     {
      if(m_cnt==0) Medium1Buffer[i]=M2Buffer[i]; else Medium2Buffer[i]=M2Buffer[i];
      m_cnt++;
     }
   if(m_cnt<2 && s2<=M3Buffer[i] && M3Buffer[i]<=r2)
     {
      if(m_cnt==0) Medium1Buffer[i]=M3Buffer[i]; else Medium2Buffer[i]=M3Buffer[i];
      m_cnt++;
     }
   if(m_cnt<2 && s2<=M4Buffer[i] && M4Buffer[i]<=r2)
     {
      if(m_cnt==0) Medium1Buffer[i]=M4Buffer[i]; else Medium2Buffer[i]=M4Buffer[i];
      m_cnt++;
     }
   if(m_cnt<2 && s2<=M5Buffer[i] && M5Buffer[i]<=r2)
     {
      if(m_cnt==0) Medium1Buffer[i]=M5Buffer[i]; else Medium2Buffer[i]=M5Buffer[i];
      m_cnt++;
     }
   if(m_cnt<2 && s2<=M6Buffer[i] && M6Buffer[i]<=r2)
     {
      if(m_cnt==0) Medium1Buffer[i]=M6Buffer[i]; else Medium2Buffer[i]=M6Buffer[i];
      m_cnt++;
     }
   if(m_cnt<2 && s2<=M7Buffer[i] && M7Buffer[i]<=r2)
     {
      if(m_cnt==0) Medium1Buffer[i]=M7Buffer[i]; else Medium2Buffer[i]=M7Buffer[i];
      m_cnt++;
     }
   if(m_cnt<2 && s2<=M8Buffer[i] && M8Buffer[i]<=r2)
     {
      if(m_cnt==0) Medium1Buffer[i]=M8Buffer[i]; else Medium2Buffer[i]=M8Buffer[i];
      m_cnt++;
     }
//---
   if(m_cnt<1)Medium1Buffer[i] = Medium1Buffer[i-1];
   if(m_cnt<2)Medium2Buffer[i] = Medium2Buffer[i-1];
  }
//+------------------------------------------------------------------+
//| set long term peak                                               |
//+------------------------------------------------------------------+
void set_lt_peeks(double s2,double r2,int i)
  {
//--- long term peak lines
   int l_cnt=0;
   if(s2<=L1Buffer[i] && L1Buffer[i]<=r2)
     {
      Long1Buffer[i]=L1Buffer[i];
      l_cnt++;
     }
   else if(s2<=L2Buffer[i] && L2Buffer[i]<=r2)
     {
      if(l_cnt==0) Long1Buffer[i]=L2Buffer[i]; else Long2Buffer[i]=L2Buffer[i];
      l_cnt++;
     }
   else if(l_cnt<2 && s2<=L3Buffer[i] && L3Buffer[i]<=r2)
     {
      if(l_cnt==0) Long1Buffer[i]=L3Buffer[i]; else Long2Buffer[i]=L3Buffer[i];
      l_cnt++;
     }
   else if(l_cnt<2 && s2<=L4Buffer[i] && L4Buffer[i]<=r2)
     {
      if(l_cnt==0) Long1Buffer[i]=L4Buffer[i]; else Long2Buffer[i]=L4Buffer[i];
      l_cnt++;
     }
   else if(l_cnt<2 && s2<=L5Buffer[i] && L5Buffer[i]<=r2)
     {
      if(l_cnt==0) Long1Buffer[i]=L5Buffer[i]; else Long2Buffer[i]=L5Buffer[i];
      l_cnt++;
     }
   else if(l_cnt<2 && s2<=L6Buffer[i] && L6Buffer[i]<=r2)
     {
      if(l_cnt==0) Long1Buffer[i]=L6Buffer[i]; else Long2Buffer[i]=L6Buffer[i];
      l_cnt++;
     }
   else if(l_cnt<2 && s2<=L7Buffer[i] && L7Buffer[i]<=r2)
     {
      if(l_cnt==0) Long1Buffer[i]=L7Buffer[i]; else Long2Buffer[i]=L7Buffer[i];
      l_cnt++;
     }
   else if(l_cnt<2 && s2<=L8Buffer[i] && L8Buffer[i]<=r2)
     {
      if(l_cnt==0) Long1Buffer[i]=L8Buffer[i]; else Long2Buffer[i]=L8Buffer[i];
      l_cnt++;
     }
//---
   if(l_cnt<1)Long1Buffer[i] = Long1Buffer[i-1];
   if(l_cnt<2)Long2Buffer[i] = Long2Buffer[i-1];
  }
//+------------------------------------------------------------------+
//| Short term peak line                                             |
//+------------------------------------------------------------------+
bool calc_ds_peaks(int &d1_peaks[],int &st_peaks[],datetime t)
  {
   double m5high[];
   double m5low[];
   long m5vol[];
   ArraySetAsSeries(m5high,true);
   ArraySetAsSeries(m5low,true);
   ArraySetAsSeries(m5vol,true);
   int m5_len1=CopyTickVolume(Symbol(),PERIOD_M5,t,st_period,m5vol);
   int m5_len2=CopyHigh(Symbol(),PERIOD_M5,t,st_period,m5high);
   int m5_len3=CopyLow (Symbol(),PERIOD_M5,t,st_period,m5low);
   if(st_period==m5_len1 && m5_len1==m5_len2 && m5_len2==m5_len3)
     {
      //--- Short term peak line
      int st_offset=(int)MathRound(m5low[ArrayMinimum(m5low)]/_Point);
      calc_histgram(st_peaks,m5high,m5low,m5vol,st_period,st_offset,InpBinRange);
      //--- 1Day peak line
      int d1_offset=(int)MathRound(m5low[ArrayMinimum(m5low,0,d1_period)]/_Point);
      calc_histgram(d1_peaks,m5high,m5low,m5vol,d1_period,d1_offset,InpBinRange,d1_period);
      return (true);
     }
   return (false);
  }
//+------------------------------------------------------------------+
//| Long term peak line                                              |
//+------------------------------------------------------------------+
bool calc_ml_peaks(int  &lt_peaks[],int  &mt_peaks[],datetime t)
  {
   double h1high[];
   double h1low[];
   long   h1vol[];
   ArraySetAsSeries(h1high,true);
   ArraySetAsSeries(h1low,true);
   ArraySetAsSeries(h1vol,true);
//---
   int h1_len1=CopyTickVolume(Symbol(),PERIOD_H1,t,lt_period,h1vol);
   int h1_len2=CopyHigh(Symbol(),PERIOD_H1,t,lt_period,h1high);
   int h1_len3=CopyLow (Symbol(),PERIOD_H1,t,lt_period,h1low);
   if(lt_period==h1_len1 && h1_len1==h1_len2 && h1_len2==h1_len3)
     {
      //--- Long term peak line
      int lt_offset=(int)MathRound(h1low[ArrayMinimum(h1low)]/_Point);
      calc_histgram(lt_peaks,h1high,h1low,h1vol,lt_period,lt_offset,InpBinRange*16);
      //--- Middle term peak line
      int mt_offset=(int)MathRound(h1low[ArrayMinimum(h1low,0,mt_period)]/_Point);
      calc_histgram(mt_peaks,h1high,h1low,h1vol,mt_period,mt_offset,InpBinRange*8,mt_period);
      return (true);
     }
   return (false);
  }
//+------------------------------------------------------------------+
//| calc histgram                                                    |
//+------------------------------------------------------------------+
int calc_histgram(int  &peaks[],const double  &hi[],const double  &lo[],const long  &vol[],int len,int offset,double binRange,int barcount=NULL)
  {
//---
   int factor=zoom_out_factor;  // zoom out factor 
//---
   if(barcount==NULL) barcount=len;
//--- for calcuration
   int work[][2];
//--- binrange zoom out
   double binRangeZO=binRange*factor;
//--- histgram limit
   int limit=(int)MathRound(hi[ArrayMaximum(hi,0,barcount)]/_Point);
//--- histgram bin steps
   int steps=(int)MathRound((limit-offset)/binRange)+1;
//--- histgram bin*zoomout steps
   int stepsZO=(int)MathRound((limit-offset)/binRangeZO)+1;
//--- volume histgram
   int vh[];
//--- volume histgram zoomout
   int vhZO[];
//--- init
   ArrayResize(vh,steps);
   ArrayInitialize(vh,0);
   ArrayResize(vhZO,stepsZO);
   ArrayInitialize(vhZO,0);
//--- histgram loop
   for(int j=barcount-1;j>=0;j--)
     {
      int v=1;
      if(InpUsingVolumeWeight)
         v=(int)MathRound(MathSqrt(MathMin(vol[j],1)));
      int l =(int)MathRound(lo[j]/_Point);
      int h =(int)MathRound(hi[j]/_Point);
      int min = (int)MathRound((l-offset)/binRange);
      int max = (int)MathRound((h-offset)/binRange);
      int minZO = (int)MathRound((l-offset)/binRangeZO);
      int maxZO = (int)MathRound((h-offset)/binRangeZO);
      //--- for normal
      for(int k=min;k<=max;k++)vh[k]+=v;
      //--- for zoomout
      for(int k=minZO;k<=maxZO;k++)vhZO[k]+=v;

     }
//--- find peaks
   int peak_count=find_peaks(work,vhZO,stepsZO,binRangeZO);
//--- sharpness
   for(int j=0;j<peak_count;j++)
     {
      int base= MathMin(steps-1,work[j][1] * factor);
      int max = vh[base];
      int peak = base;
      for(int k=0;k<factor;k++)
        {
         if(steps-1<base+k)break;
         if(max<vh[base+k])
           {
            max=vh[base+k];
            peak=base+k;
           }
        }
      work[j][1]=peak;
     }
//--- sort
   int cnt=0;
   for(int j=peak_count-1;j>=0;j--)
     {
      cnt++;
      ArrayResize(peaks,cnt);
      peaks[cnt-1]=(int)MathRound(offset+vh[work[j][1]]*binRange+(binRange/2));
     }
//---
   return (peak_count);
  }
//+------------------------------------------------------------------+
//|  Find peaks                                                      |
//+------------------------------------------------------------------+
int find_peaks(int &peaks[][2],const int  &vh[],int steps,double binrange)
  {
   if(steps<=10)
     {
      ArrayResize(peaks,1);
      peaks[0][1] = ArrayMaximum(vh);
      peaks[0][0] =vh[peaks[0][1]];
      return 1;
     }
   int count=0;
   for(int i=2;i<steps-2;i++)
     {
      int max=MathMax(MathMax(MathMax(MathMax(
                      vh[i-2],vh[i-1]),vh[i]),vh[i+1]),vh[i+2]);
      if(vh[i]==max)
        {
         count++;
         ArrayResize(peaks,count);
         peaks[count-1][0] = vh[i];
         peaks[count-1][1] = i;
        }
     }
   if(count>1) ArraySort(peaks);
//---
   return(count);
  }
//+------------------------------------------------------------------+
//|  TimeHour                                                        |
//+------------------------------------------------------------------+
int TimeHour(datetime t)
  {
   MqlDateTime tm;
   TimeToStruct(t,tm);
   return (tm.hour);
  }
//+------------------------------------------------------------------+
