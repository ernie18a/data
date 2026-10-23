//+------------------------------------------------------------------+
//|                                                      VIP_DSR.mq5 |
//|                                       Copyright © 2010, KingLion |
//|                                     http://www.metastock.org.ua/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, KingLion"
#property link      "http://www.metastock.org.ua/"
#property version   "2.00"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_style1  STYLE_SOLID
#property indicator_style2  STYLE_SOLID
#property indicator_style3  STYLE_DOT
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  1
#property indicator_label1  "Resistance"
#property indicator_label2  "Support"
#property indicator_label3  "Mean"
#property indicator_color1 DarkGreen
#property indicator_color2 FireBrick
#property indicator_color3 DarkGoldenrod

string Custom_Indicator="VIP Dynamic Support/Resistance";
string Web_Address="www.metastock.org.ua";

double Support[];
double Resistance[];
double Mean[];
double Pivot[];
double MA[];

int counted_bars=0;

#define MODE_OPEN 0
#define MODE_CLOSE 3
#define MODE_VOLUME 4 
#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_TIME 5
#define EMPTY -1
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   IndicatorSetString(INDICATOR_SHORTNAME,Custom_Indicator+" | "+Web_Address);
   SetIndexBuffer(0,Resistance);
   SetIndexBuffer(1,Support);
   SetIndexBuffer(2,Mean);
   SetIndexBuffer(3,Pivot);
   SetIndexBuffer(4,MA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,25);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,25);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,25);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(Resistance,true);
   ArraySetAsSeries(Support,true);
   ArraySetAsSeries(Mean,true);
   ArraySetAsSeries(Pivot,true);
   ArraySetAsSeries(MA,true);
   int bars= Bars(_Symbol,_Period);
   if(bars<=0)
     {
      bool synchronized=false;
      int attempts=0;
      while(attempts<5)
        {
         if(SeriesInfoInteger(Symbol(),0,SERIES_SYNCHRONIZED))
           {
            synchronized=true;
            break;
           }
         attempts++;
         Sleep(10);
        }
      if(!synchronized)
         return(rates_total);
     }
   counted_bars=0;
   if(prev_calculated>0) counted_bars=prev_calculated-1;
   if(bars<=25) return(0);
   int i=bars-counted_bars-28;
   if(counted_bars>0) i++;
   else
     {
      Resistance[i]=high[i];
      Support[i]=low[i];
     }
   int j;
   for(j=0; j<i; j++)
      Pivot[j]=(high[iHighest(_Symbol,_Period,MODE_HIGH,3,j)]+low[iLowest(_Symbol,_Period,MODE_LOW,3,j)]+close[j])/3.0;
   for(j=0; j<i; j++)
      MA[j]=iMASMA(Pivot,bars,25,0,MODE_SMA,j);
   for(j=i-1; j>=0; j--)
     {
      if(Pivot[j+1]>MA[j+1] && Pivot[j]<MA[j])
         Resistance[j]=high[iHighest(_Symbol,_Period,MODE_HIGH,28,j)];
      else
         Resistance[j]=Resistance[j+1];
     }
   for(j=i-1; j>=0; j--)
     {
      if(Pivot[j+1]<MA[j+1] && Pivot[j]>MA[j])
         Support[j]=low[iLowest(_Symbol,_Period,MODE_LOW,28,j)];
      else
         Support[j]=Support[j+1];
     }
   for(j=0; j<i; j++)
      Mean[j]=NormalizeDouble((Resistance[j]+Support[j])/2.0,_Digits);

   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int iHighest(string symbol,ENUM_TIMEFRAMES timeframe,int type,int count=WHOLE_ARRAY,int start=0)
  {
   int rc=0;
   if(start<0)
      return(rc);
   if(count<= 0)
      count = Bars(symbol,timeframe);
   if(type==MODE_OPEN)
     {
      double Open[];
      ArraySetAsSeries(Open,true);
      CopyOpen(symbol,timeframe,start,count,Open);
      rc=ArrayMaximum(Open,0,count)+start;
     }
   else if(type==MODE_LOW)
     {
      double Low[];
      ArraySetAsSeries(Low,true);
      CopyLow(symbol,timeframe,start,count,Low);
      rc=ArrayMaximum(Low,0,count)+start;
     }
   else if(type==MODE_HIGH)
     {
      double High[];
      ArraySetAsSeries(High,true);
      CopyHigh(symbol,timeframe,start,count,High);
      rc=ArrayMaximum(High,0,count)+start;
     }
   else if(type==MODE_CLOSE)
     {
      double Close[];
      ArraySetAsSeries(Close,true);
      CopyClose(symbol,timeframe,start,count,Close);
      rc=ArrayMaximum(Close,0,count)+start;
     }
   else if(type==MODE_VOLUME)
     {
      long Volume[];
      ArraySetAsSeries(Volume,true);
      CopyTickVolume(symbol,timeframe,start,count,Volume);
      rc=ArrayMaximum(Volume,0,count)+start;
     }
   else if(type==MODE_TIME)
     {
      datetime Time[];
      ArraySetAsSeries(Time,true);
      CopyTime(symbol,timeframe,start,count,Time);
      rc=ArrayMaximum(Time,0,count)+start;
     }
   return(rc);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int iLowest(string symbol,ENUM_TIMEFRAMES timeframe,int type,int count=WHOLE_ARRAY,int start=0)
  {
   int rc=0;
   if(start<0)
      return(-1);
   if(count<= 0)
      count = Bars(symbol,timeframe);
   if(type==MODE_OPEN)
     {
      double Open[];
      ArraySetAsSeries(Open,true);
      CopyOpen(symbol,timeframe,start,count,Open);
      rc=ArrayMinimum(Open,0,count)+start;
     }
   else if(type==MODE_LOW)
     {
      double Low[];
      ArraySetAsSeries(Low,true);
      CopyLow(symbol,timeframe,start,count,Low);
      rc=ArrayMinimum(Low,0,count)+start;
     }
   else if(type==MODE_HIGH)
     {
      double High[];
      ArraySetAsSeries(High,true);
      CopyHigh(symbol,timeframe,start,count,High);
      rc=ArrayMinimum(High,0,count)+start;
     }
   else if(type==MODE_CLOSE)
     {
      double Close[];
      ArraySetAsSeries(Close,true);
      CopyClose(symbol,timeframe,start,count,Close);
      rc=ArrayMinimum(Close,0,count)+start;
     }
   else if(type==MODE_VOLUME)
     {
      long Volume[];
      ArraySetAsSeries(Volume,true);
      CopyTickVolume(symbol,timeframe,start,count,Volume);
      rc=ArrayMinimum(Volume,0,count)+start;
     }
   else if(type==MODE_TIME)
     {
      datetime Time[];
      ArraySetAsSeries(Time,true);
      CopyTime(symbol,timeframe,start,count,Time);
      rc=ArrayMinimum(Time,0,count)+start;
     }
   return(rc);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iMASMA(double &array[],int total,int period,int ma_shift,int ma_method,int shift)
  {
   double buf[],arr[];
   if(total == 0)
      total = ArraySize(array);
   if(total>0 && total<=period)
      return(0);
   if(shift>total-period-ma_shift)
      return(0);
   total=ArrayCopy(arr,array,0,shift+ma_shift,period);
   if(ArrayResize(buf,total)<0)
      return(0);
   double sum = 0;
   int i, pos = total - 1;
   for(i=1; i<period; i++,pos--)
      sum+=arr[pos];
   while(pos>=0)
     {
      sum+=arr[pos];
      buf[pos]=sum/period;
      sum-=arr[pos+period-1];
      pos--;
     }
   return(buf[0]);
  }
//+------------------------------------------------------------------+
