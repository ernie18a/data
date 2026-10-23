//+------------------------------------------------------------------+
//|                                              BBandWidthRatio.mq5 |
//|                                           Copyright 2017, sachjo |
//|                                                         https:// |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, sachjo"
#property link      "https://"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1

#property indicator_plots   1

//--- plot Close

#property indicator_label1  "BBandWidth"

#property indicator_type1   DRAW_LINE

#property indicator_color1  clrYellow

#property indicator_style1  STYLE_SOLID

#property indicator_width1  3

//--- indicator buffers

double Buf[];

double BufMA[];

//--- input parameters
input int      BB_Period=25;     //BBands Period
input double   Deviation=2.0;    //Standard Deviation

// handle of technical indicator
int hMA;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,Buf,INDICATOR_DATA);

// initialize SMA and get handle

   hMA=iMA(NULL,0,BB_Period,0,MODE_SMA,PRICE_CLOSE);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator denitialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)

  {

// Release indicator

   IndicatorRelease(hMA);

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
   int limit=prev_calculated;

   if(prev_calculated>0)
      limit--;

   int count=rates_total-limit;

// copy MA values to buffer

   if(CopyBuffer(hMA, 0, 0, count, BufMA) < count) return(0);

   for(int i=limit; i<rates_total; i++)

     {
      if(i<BB_Period) Buf[i]=0;
      else
        {
         double sum=0;
         for(int j=0; j<BB_Period; j++)sum+=close[i-j];
         double ave=sum/BB_Period;

         sum=0;
         for(int j=0; j<BB_Period; j++)sum+=(close[i-j]-ave)*(close[i-j]-ave);
         double sko=MathSqrt(sum/BB_Period);

         Buf[i]=2*(Deviation*sko)/BufMA[i-limit];
        }

     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
