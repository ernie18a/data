//+------------------------------------------------------------------+
//|                                                HistogramTest.mq5 |
//|                                           Copyright 2015, fxborg |
//|                                  http://blog.livedoor.jp/fxborg/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, fxborg"
#property link      "http://blog.livedoor.jp/fxborg/"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 40
#property indicator_plots   10
#define PIP      ((_Digits <= 3) ? 0.01 : 0.0001)

#property indicator_chart_window
#property indicator_type1 DRAW_ARROW
#property indicator_type2 DRAW_ARROW
#property indicator_type3 DRAW_ARROW
#property indicator_type4 DRAW_ARROW
#property indicator_type5 DRAW_ARROW
#property indicator_type6 DRAW_ARROW
#property indicator_type7 DRAW_ARROW
#property indicator_type8 DRAW_ARROW
#property indicator_type9 DRAW_ARROW
#property indicator_type10 DRAW_ARROW
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2
#property indicator_width7 2
#property indicator_width8 2
#property indicator_width9 2
#property indicator_width10 2
#property indicator_color1 C'150,50,255'
#property indicator_color2 C'150,50,240'
#property indicator_color3 C'150,50,230'
#property indicator_color4 C'150,50,220'
#property indicator_color5 C'150,50,210'
#property indicator_color6 C'150,50,200'
#property indicator_color7 C'150,50,190'
#property indicator_color8 C'150,50,180'
#property indicator_color9 C'150,50,170'
#property indicator_color10 C'150,50,160'

input  int InpCalcTime=4;    // Calculation Time(hour)
input  int InpDailyPeriod=60;  // DailyPeriod(hour)
input  int InpFastPeriod=180;  // FastPeriod(hour)
input  int InpSlowPeriod=30;   // SlowPeriod(day)
//---
int FastPeriod=InpFastPeriod*2;  //(30min)
int SlowPeriod=24*InpSlowPeriod*2;  //(30min)
//---
int DailyPeriod=InpDailyPeriod*12;  //(60h/5min)
int D1BinRange=5;
int BinRange=15;
//---
double P1Buffer[];
double P2Buffer[];
double P3Buffer[];
double P4Buffer[];
double P5Buffer[];
double P6Buffer[];
double P7Buffer[];
double P8Buffer[];
double P9Buffer[];
double P10Buffer[];
//---
double D1Buffer[];
double D2Buffer[];
double D3Buffer[];
double D4Buffer[];
double D5Buffer[];
double D6Buffer[];
double D7Buffer[];
double D8Buffer[];
double D9Buffer[];
double D10Buffer[];
//---
double F1Buffer[];
double F2Buffer[];
double F3Buffer[];
double F4Buffer[];
double F5Buffer[];
double F6Buffer[];
double F7Buffer[];
double F8Buffer[];
double F9Buffer[];
double F10Buffer[];
//---
double S1Buffer[];
double S2Buffer[];
double S3Buffer[];
double S4Buffer[];
double S5Buffer[];
double S6Buffer[];
double S7Buffer[];
double S8Buffer[];
double S9Buffer[];
double S10Buffer[];
//---
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   min_rates_total=100;
//--- indicator buffers mapping
   SetIndexBuffer(0,P1Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,P2Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,P3Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,P4Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,P5Buffer,INDICATOR_DATA);
   SetIndexBuffer(5,P6Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,P7Buffer,INDICATOR_DATA);
   SetIndexBuffer(7,P8Buffer,INDICATOR_DATA);
   SetIndexBuffer(8,P9Buffer,INDICATOR_DATA);
   SetIndexBuffer(9,P10Buffer,INDICATOR_DATA);
   SetIndexBuffer(10,D1Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,D2Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,D3Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,D4Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,D5Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(15,D6Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(16,D7Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(17,D8Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(18,D9Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(19,D10Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(20,F1Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(21,F2Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(22,F3Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(23,F4Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(24,F5Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(25,F6Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(26,F7Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(27,F8Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(28,F9Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(29,F10Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(30,S1Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(31,S2Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(32,S3Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(33,S4Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(34,S5Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(35,S6Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(36,S7Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(37,S8Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(38,S9Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(39,S10Buffer,INDICATOR_CALCULATIONS);
//---
   for(int i=0;i<10;i++)
     {
      PlotIndexSetInteger(i,PLOT_ARROW,158);
      PlotIndexSetDouble(i,PLOT_EMPTY_VALUE,EMPTY_VALUE);
      PlotIndexSetInteger(i,PLOT_DRAW_BEGIN,min_rates_total);
     }
   string short_name="Peak Line Histogram Test";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
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
   first=1000;
   if(first+1<prev_calculated) first=prev_calculated-2;
//---
   for(i=first; i<rates_total && !IsStopped(); i++)
     {
      bool is_update=false;
      MqlDateTime tm0,tm1;
      TimeToStruct(time[i],tm0);
      TimeToStruct(time[i-1],tm1);
      if(tm1.hour!=tm0.hour && tm0.hour==InpCalcTime)
        {
         is_update=true;
         calc_peaks(1,PERIOD_M5,D1BinRange,DailyPeriod,i,time[i],1);
         calc_peaks(2,PERIOD_M30,BinRange,FastPeriod,i,time[i],2);
         calc_peaks(3,PERIOD_M30,BinRange,SlowPeriod,i,time[i],2);
        }
      if(!is_update)
        {
         D1Buffer[i] = D1Buffer[i-1];
         D2Buffer[i] = D2Buffer[i-1];
         D3Buffer[i] = D3Buffer[i-1];
         D4Buffer[i] = D4Buffer[i-1];
         D5Buffer[i] = D5Buffer[i-1];
         D6Buffer[i] = D6Buffer[i-1];
         D7Buffer[i] = D7Buffer[i-1];
         D8Buffer[i] = D8Buffer[i-1];
         D9Buffer[i] = D9Buffer[i-1];
         D10Buffer[i]= D10Buffer[i-1];
         //---
         F1Buffer[i] = F1Buffer[i-1];
         F2Buffer[i] = F2Buffer[i-1];
         F3Buffer[i] = F3Buffer[i-1];
         F4Buffer[i] = F4Buffer[i-1];
         F5Buffer[i] = F5Buffer[i-1];
         F6Buffer[i] = F6Buffer[i-1];
         F7Buffer[i] = F7Buffer[i-1];
         F8Buffer[i] = F8Buffer[i-1];
         F9Buffer[i] = F9Buffer[i-1];
         F10Buffer[i]= F10Buffer[i-1];
         //---
         S1Buffer[i] = S1Buffer[i-1];
         S2Buffer[i] = S2Buffer[i-1];
         S3Buffer[i] = S3Buffer[i-1];
         S4Buffer[i] = S4Buffer[i-1];
         S5Buffer[i] = S5Buffer[i-1];
         S6Buffer[i] = S6Buffer[i-1];
         S7Buffer[i] = S7Buffer[i-1];
         S8Buffer[i] = S8Buffer[i-1];
         S9Buffer[i] = S9Buffer[i-1];
         S10Buffer[i]= S10Buffer[i-1];
        }
      double ma=(high[i]+low[i]+close[i])/3;
      //---
      double res=getPeaks(ma,BinRange*2,i);
      if(res>0.0)
        {
         append_peaks(i,res,0);
        }
      else
        {
         P1Buffer[i] = P1Buffer[i-1];
         P2Buffer[i] = P2Buffer[i-1];
         P3Buffer[i] = P3Buffer[i-1];
         P4Buffer[i] = P4Buffer[i-1];
         P5Buffer[i] = P5Buffer[i-1];
         P6Buffer[i] = P6Buffer[i-1];
         P7Buffer[i] = P7Buffer[i-1];
         P8Buffer[i] = P8Buffer[i-1];
         P9Buffer[i] = P9Buffer[i-1];
         P10Buffer[i]= P10Buffer[i-1];
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPeaks(double v,int binRange,int i)
  {
   double min=v-binRange*PIP*1.5;
   double max=v+binRange*PIP*1.5;
//---
   if(min <= P1Buffer[i-1] && P1Buffer[i-1] <= max) return 0.0;
   if(min <= P2Buffer[i-1] && P2Buffer[i-1] <= max) return 0.0;
   if(min <= P3Buffer[i-1] && P3Buffer[i-1] <= max) return 0.0;
   if(min <= P4Buffer[i-1] && P4Buffer[i-1] <= max) return 0.0;
   if(min <= P5Buffer[i-1] && P5Buffer[i-1] <= max) return 0.0;
   if(min <= P6Buffer[i-1] && P6Buffer[i-1] <= max) return 0.0;
   if(min <= P7Buffer[i-1] && P7Buffer[i-1] <= max) return 0.0;
   if(min <= P8Buffer[i-1] && P8Buffer[i-1] <= max) return 0.0;
   if(min <= P9Buffer[i-1] && P9Buffer[i-1] <= max) return 0.0;
   if(min <= P10Buffer[i-1] && P10Buffer[i-1] <= max) return 0.0;
//---
   min=v-binRange*PIP;
   max=v+binRange*PIP;
//---
   if(min <= D1Buffer[i] && D1Buffer[i] <= max) return D1Buffer[i];
   if(min <= D2Buffer[i] && D2Buffer[i] <= max) return D2Buffer[i];
   if(min <= D3Buffer[i] && D3Buffer[i] <= max) return D3Buffer[i];
   if(min <= D4Buffer[i] && D4Buffer[i] <= max) return D4Buffer[i];
   if(min <= D5Buffer[i] && D5Buffer[i] <= max) return D5Buffer[i];
   if(min <= D6Buffer[i] && D6Buffer[i] <= max) return D6Buffer[i];
   if(min <= D7Buffer[i] && D7Buffer[i] <= max) return D7Buffer[i];
   if(min <= D8Buffer[i] && D8Buffer[i] <= max) return D8Buffer[i];
   if(min <= D9Buffer[i] && D9Buffer[i] <= max) return D9Buffer[i];
   if(min <= D10Buffer[i] && D10Buffer[i] <= max) return D10Buffer[i];
//---
   if(min <= S1Buffer[i] && S1Buffer[i] <= max) return S1Buffer[i];
   if(min <= S2Buffer[i] && S2Buffer[i] <= max) return S2Buffer[i];
   if(min <= S3Buffer[i] && S3Buffer[i] <= max) return S3Buffer[i];
   if(min <= S4Buffer[i] && S4Buffer[i] <= max) return S4Buffer[i];
   if(min <= S5Buffer[i] && S5Buffer[i] <= max) return S5Buffer[i];
   if(min <= S6Buffer[i] && S6Buffer[i] <= max) return S6Buffer[i];
   if(min <= S7Buffer[i] && S7Buffer[i] <= max) return S7Buffer[i];
   if(min <= S8Buffer[i] && S8Buffer[i] <= max) return S8Buffer[i];
   if(min <= S9Buffer[i] && S9Buffer[i] <= max) return S9Buffer[i];
   if(min <= S10Buffer[i] && S10Buffer[i] <= max) return S10Buffer[i];
//---
   if(min <= F1Buffer[i] && F1Buffer[i] <= max) return F1Buffer[i];
   if(min <= F2Buffer[i] && F2Buffer[i] <= max) return F2Buffer[i];
   if(min <= F3Buffer[i] && F3Buffer[i] <= max) return F3Buffer[i];
   if(min <= F4Buffer[i] && F4Buffer[i] <= max) return F4Buffer[i];
   if(min <= F5Buffer[i] && F5Buffer[i] <= max) return F5Buffer[i];
   if(min <= F6Buffer[i] && F6Buffer[i] <= max) return F6Buffer[i];
   if(min <= F7Buffer[i] && F7Buffer[i] <= max) return F7Buffer[i];
   if(min <= F8Buffer[i] && F8Buffer[i] <= max) return F8Buffer[i];
   if(min <= F9Buffer[i] && F9Buffer[i] <= max) return F9Buffer[i];
   if(min <= F10Buffer[i] && F10Buffer[i] <= max) return F10Buffer[i];
//---
   return 0.0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calc_peaks(int opt,ENUM_TIMEFRAMES tf,int binRange,int period,int i,datetime t,int limit)
  {
   int  peaks[];
   int  hist[];
   int  offset;
   if(generate_histgram(offset,peaks,hist,t,tf,binRange,period))
     {
      int peak_cnt=ArraySize(peaks);
      if(peak_cnt>0)
        {
         int line_cnt=0;
         for(int j=0;j<MathMin(limit,peak_cnt);j++)
           {
            double peak=(offset+peaks[j]*binRange+binRange/2) *PIP;
            append_peaks(i,peak,opt);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool generate_histgram(int  &offset,
                       int  &tf_peaks[],
                       int  &tf_hist[],
                       datetime t,
                       ENUM_TIMEFRAMES tf,
                       int binRange,
                       int histPeriod)
  {
   double tf_high[];
   double tf_low[];
   long tf_vol[];
   ArraySetAsSeries(tf_high,true);
   ArraySetAsSeries(tf_low,true);
   ArraySetAsSeries(tf_vol,true);
   int tf_len1=CopyTickVolume(Symbol(),tf,t,histPeriod,tf_vol);
   int tf_len2=CopyHigh(Symbol(),tf,t,histPeriod,tf_high);
   int tf_len3=CopyLow (Symbol(),tf,t,histPeriod,tf_low);
//--- check copy count
   bool tf_ok=(histPeriod==tf_len1 && tf_len1==tf_len2 && tf_len2==tf_len3);
   if(!tf_ok)return (false);
//---
   offset=(int)MathRound(tf_low[ArrayMinimum(tf_low)]/PIP);
   int limit=(int)MathRound(tf_high[ArrayMaximum(tf_high)]/PIP);
//---
   calc_histgram(tf_peaks,tf_hist,tf_high,tf_low,tf_vol,offset,limit,binRange,histPeriod);
//---
   return (true);
  }
//+------------------------------------------------------------------+
//| calc histgram                                                    |
//+------------------------------------------------------------------+
bool calc_histgram(int &peaks[],
                   int &hist[],
                   const double  &hi[],
                   const double  &lo[],
                   const long  &vol[],
                   int offset,
                   int limit,
                   double binRange,
                   int histPeriod)
  {
//---
   int j,k;
//--- histgram bin steps
   int steps=(int)MathRound((limit-offset)/binRange)+1;
//--- init
   ArrayResize(hist,steps);
   ArrayInitialize(hist,0);
//--- histgram loop
   for(j=histPeriod-1;j>=0;j--)
     {
      int l =(int)MathRound(lo[j]/PIP);
      int h =(int)MathRound(hi[j]/PIP);
      int v=(int)MathRound(MathSqrt(MathMin(vol[j],1)));
      int min = (int)MathRound((l-offset)/binRange);
      int max = (int)MathRound((h-offset)/binRange);
      //--- for normal
      for(k=min;k<=max;k++)hist[k]+=v;
     }
//--- find peaks
   int work[][2];
//--- find peaks
   int peak_count=find_peaks(work,hist,steps,binRange);
   ArrayResize(peaks,0,peak_count);
   int top=0;
   int cnt=0;
   for(j=peak_count-1;j>=0;j--)
     {
      if(j==(peak_count-1))top=work[j][0];
      if(work[j][0]>top*0.1)
        {
         cnt++;
         ArrayResize(peaks,cnt,peak_count);
         peaks[cnt-1]=work[j][1];
        }
     }
   return (true);
  }
//+------------------------------------------------------------------+
//|  Find peaks                                                      |
//+------------------------------------------------------------------+
int find_peaks(int &peaks[][2],const int  &hist[],int steps,double binrange)
  {
   if(steps<=10)
     {
      ArrayResize(peaks,1);
      peaks[0][1] = ArrayMaximum(hist);
      peaks[0][0] =hist[peaks[0][1]];
      return 1;
     }
   int count=0;
   for(int i=2;i<steps-2;i++)
     {
      int max=MathMax(MathMax(MathMax(MathMax(
                      hist[i-2],hist[i-1]),hist[i]),hist[i+1]),hist[i+2]);
      if(hist[i]==max)
        {
         count++;
         ArrayResize(peaks,count);
         int total=hist[i-2]+hist[i-1]+hist[i]+hist[i+1]+hist[i+2];
         peaks[count-1][0] = total;
         peaks[count-1][1] = i;
        }
     }
   if(count>1)
     {
      ArraySort(peaks);
     }
//---
   return(count);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void append_peaks(int i,double v,int opt)
  {
   if(opt==0)
     {
      P1Buffer[i]=v;
      P2Buffer[i]=P1Buffer[i-1];
      P3Buffer[i]=P2Buffer[i-1];
      P4Buffer[i]=P3Buffer[i-1];
      P5Buffer[i]=P4Buffer[i-1];
      P6Buffer[i]=P5Buffer[i-1];
      P7Buffer[i]=P6Buffer[i-1];
      P8Buffer[i]=P7Buffer[i-1];
      P9Buffer[i]=P8Buffer[i-1];
      P10Buffer[i]=P9Buffer[i-1];
     }
   else if(opt==1)
     {
      D1Buffer[i]=v;
      D2Buffer[i]=D1Buffer[i-1];
      D3Buffer[i]=D2Buffer[i-1];
      D4Buffer[i]=D3Buffer[i-1];
      D5Buffer[i]=D4Buffer[i-1];
      D6Buffer[i]=D5Buffer[i-1];
      D7Buffer[i]=D6Buffer[i-1];
      D8Buffer[i]=D7Buffer[i-1];
      D9Buffer[i]=D8Buffer[i-1];
      D10Buffer[i]=D9Buffer[i-1];
     }
   else if(opt==2)
     {
      F1Buffer[i]=v;
      F2Buffer[i]=F1Buffer[i-1];
      F3Buffer[i]=F2Buffer[i-1];
      F4Buffer[i]=F3Buffer[i-1];
      F5Buffer[i]=F4Buffer[i-1];
      F6Buffer[i]=F5Buffer[i-1];
      F7Buffer[i]=F6Buffer[i-1];
      F8Buffer[i]=F7Buffer[i-1];
      F9Buffer[i]=F8Buffer[i-1];
      F10Buffer[i]=F9Buffer[i-1];
     }
   else if(opt==3)
     {
      S1Buffer[i]=v;
      S2Buffer[i]=S1Buffer[i-1];
      S3Buffer[i]=S2Buffer[i-1];
      S4Buffer[i]=S3Buffer[i-1];
      S5Buffer[i]=S4Buffer[i-1];
      S6Buffer[i]=S5Buffer[i-1];
      S7Buffer[i]=S6Buffer[i-1];
      S8Buffer[i]=S7Buffer[i-1];
      S9Buffer[i]=S8Buffer[i-1];
      S10Buffer[i]=S9Buffer[i-1];
     }
  }
//+------------------------------------------------------------------+
