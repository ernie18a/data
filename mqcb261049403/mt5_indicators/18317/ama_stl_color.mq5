//+------------------------------------------------------------------+
//|                                                AMA_STL_Color.mq5 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#property strict

#property indicator_chart_window

#ifdef __MQL4__
#property indicator_buffers 2
#endif

#ifdef __MQL5__
#property indicator_buffers 5
#property indicator_plots 2
#endif

#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE

#property indicator_color1 clrDodgerBlue
#property indicator_color2 clrTomato

#property indicator_width1 3
#property indicator_width2 3

#property indicator_label1 "Up Line"
#property indicator_label2 "Dn Line"

//---
input uint InpRange=9;//Range
input uint InpFastPeriod=2;//Fast Period
input uint InpSlowPeriod=30;//Slow Period
input uint InpMaxBars=200;//Count Bars
input uint InpFilter=25;//Filter

//---
double Up[];
double Down[];
double trend[];
double fAMA[];
double mAMA[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
#ifdef __MQL4__   
   IndicatorBuffers(5);
#endif
//---
   SetIndexBuffer(0,Up,INDICATOR_DATA);
   SetIndexBuffer(1,Down,INDICATOR_DATA);
   SetIndexBuffer(2,trend,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,fAMA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,mAMA,INDICATOR_CALCULATIONS);
//---   
   ArraySetAsSeries(Up,true);
   ArraySetAsSeries(Down,true);
   ArraySetAsSeries(trend,true);
   ArraySetAsSeries(fAMA,true);
   ArraySetAsSeries(mAMA,true);
//---
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

   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);

   int limit;
   if(prev_calculated==0)
     {
      limit=rates_total-(int)InpRange-2;
      if(InpMaxBars>0)
         limit=(int)fmin(limit,InpMaxBars);

      ArrayInitialize(Up,EMPTY_VALUE);
      ArrayInitialize(Down,EMPTY_VALUE);
     }
   else
     {
      limit=rates_total-prev_calculated;
     }

//---
   double k1=2.0/(InpSlowPeriod+1);
   double k2=2.0/(InpFastPeriod+1)-k1;

//---
   double AMA=close[InpMaxBars-InpRange];
   mAMA[InpMaxBars-InpRange]=close[InpMaxBars-InpRange+1];

//---
   for(int cb=(int)InpMaxBars; cb>=0; cb--)
     {

      double Noise=0.0;
      for(int i=cb; i<cb+(int)InpRange; i++)
         Noise+=fabs(close[i]-close[i+1]);

      double ER=0.0;
      if(Noise!=0.0)
         ER=fabs(close[cb]-close[cb+InpRange])/Noise;

      double SSC=(ER*k2+k1);
      AMA+=NormalizeDouble(SSC*SSC*(close[cb]-AMA),_Digits);
      mAMA[cb]=AMA;

      if(InpFilter<1)
         fAMA[cb]=mAMA[cb];
      else
        {
         double sdAMA=0.0;
         for(int i=cb; i<cb+(int)InpSlowPeriod; i++)
            sdAMA+=fabs(mAMA[i]-mAMA[i+1]);

         double dAMA=mAMA[cb]-mAMA[cb+1];
         //----
         if(dAMA>=0.0)
           {
            if(dAMA<NormalizeDouble(InpFilter*sdAMA/(100*InpSlowPeriod),_Digits) && 
               high[cb]<=high[ArrayMaximum(high,4,cb)]+10*_Point)
              {
               fAMA[cb]=fAMA[cb+1];
              }
            else
              {
               fAMA[cb]=mAMA[cb];
              }
           }
         else
           {
            if(fabs(dAMA)<NormalizeDouble(InpFilter*sdAMA/(100*InpSlowPeriod),_Digits) && 
               low[cb]>low[ArrayMinimum(low,4,cb)]-10*_Point)
              {
               fAMA[cb]=fAMA[cb+1];
              }
            else
              {
               fAMA[cb]=mAMA[cb];
              }
           }

         sdAMA=0.0;
        }

     }
//---
   for(int i=(int)InpMaxBars; i>=0; i--)
     {
      trend[i]=trend[i+1];

      if(fAMA[i]>fAMA[i+1]) trend[i] =1;
      if(fAMA[i]<fAMA[i+1]) trend[i] =-1;

      if(trend[i]>0)
        {
         Up[i]=fAMA[i];
         if(trend[i+1]<0)
            Up[i+1]=fAMA[i+1];
         Down[i]=EMPTY_VALUE;
        }
      else
      if(trend[i]<0)
        {
         Down[i]=fAMA[i];
         if(trend[i+1]>0)
            Down[i+1]=fAMA[i+1];
         Up[i]=EMPTY_VALUE;
        }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
