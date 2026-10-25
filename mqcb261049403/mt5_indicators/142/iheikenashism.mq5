//+------------------------------------------------------------------+
//|                                                iHeikenAshiSm.mq5 |
//|                                                          Integer |
//|                                                 http://dmffx.com |
//+------------------------------------------------------------------+
#property copyright "Integer"
#property link      "http://dmffx.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 17
#property indicator_plots   1
//--- plot HeikenAshi
#property indicator_label1  "HeikenAshi"
#property indicator_color1  DodgerBlue,Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

enum eType
  {
   CANDLES=DRAW_COLOR_CANDLES,
   BARS=DRAW_COLOR_BARS
  };

enum eVar
  {
   HeikenAshi=0,
   Price=1
  };

/*
   The Heiken Ashi indicator with smoothing.
   Depending on the parameter TYPE (BARS,CANDLES) it can be plotted as bars or candles.
   Depending on the parameter Variant (HeikenAshi,Price) it can plot HeikenAshi bars
   or conventional candles, painted as Heiken Ashi bars.
  
   Parameters:
  
   Variant - bars to plot (candles): barsы (candles) Heiken Ashi or standard price bars (candles);
   Type - drawing type: bars or candles;
   MAPeriod - МА period;
   MAMethod - МА method: 0-SMA, 1-EMA, 2-SMMA, 3-LWMA;
   SmPeriod - smoothing period;
   SmMethod - smoothing method: 0-SMA, 1-EMA, 2-SMMA, 3-LWMA.
*/

//--- input parameters
input eVar             Variant   =  HeikenAshi;    /*Variant*/   // Heiken Ashi or price
input eType            Type      =  CANDLES;       /*Type*/      // drawing type - bars or candles
input int              MAPeriod  =  1;             /*MAPeriod*/  // МА period
input ENUM_MA_METHOD   MAMethod  =  MODE_SMA;      /*MAMethod*/  // МА method: 0-SMA, 1-EMA, 2-SMMA, 3-LWMA
input int              SmPeriod  =  1;             /*SmPeriod*/  // Smoothing period
input ENUM_MA_METHOD   SmMethod  =  MODE_SMA;      /*SmMethod*/  // Smoothing method: 0-SMA, 1-EMA, 2-SMMA, 3-LWMA

//--- indicator buffers
double         HeikenAshiBuffer1[];
double         HeikenAshiBuffer2[];
double         HeikenAshiBuffer3[];
double         HeikenAshiBuffer4[];
double         HeikenAshiColors[];

double         OpenMABuffer[];
double         HighMABuffer[];
double         LowMABuffer[];
double         CloseMABuffer[];

double         _open[];
double         _high[];
double         _low[];
double         _close[];

double         _openSm[];
double         _highSm[];
double         _lowSm[];
double         _closeSm[];

int OpenMAHandle,HighMAHandle,LowMAHandle,CloseMAHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,Type);

   SetIndexBuffer(0,HeikenAshiBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,HeikenAshiBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,HeikenAshiBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,HeikenAshiBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,HeikenAshiColors,INDICATOR_COLOR_INDEX);

   SetIndexBuffer(5,OpenMABuffer,INDICATOR_DATA);
   SetIndexBuffer(6,HighMABuffer,INDICATOR_DATA);
   SetIndexBuffer(7,LowMABuffer,INDICATOR_DATA);
   SetIndexBuffer(8,CloseMABuffer,INDICATOR_DATA);

   SetIndexBuffer(9,_open,INDICATOR_DATA);
   SetIndexBuffer(10,_high,INDICATOR_DATA);
   SetIndexBuffer(11,_low,INDICATOR_DATA);
   SetIndexBuffer(12,_close,INDICATOR_DATA);

   SetIndexBuffer(13,_openSm,INDICATOR_DATA);
   SetIndexBuffer(14,_highSm,INDICATOR_DATA);
   SetIndexBuffer(15,_lowSm,INDICATOR_DATA);
   SetIndexBuffer(16,_closeSm,INDICATOR_DATA);

   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);

   OpenMAHandle=iMA(_Symbol,PERIOD_CURRENT,MAPeriod,0,MAMethod,PRICE_OPEN);
   HighMAHandle=iMA(_Symbol,PERIOD_CURRENT,MAPeriod,0,MAMethod,PRICE_HIGH);
   LowMAHandle=iMA(_Symbol,PERIOD_CURRENT,MAPeriod,0,MAMethod,PRICE_LOW);
   CloseMAHandle=iMA(_Symbol,PERIOD_CURRENT,MAPeriod,0,MAMethod,PRICE_CLOSE);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime  &time[],
                const double  &open[],
                const double  &high[],
                const double  &low[],
                const double  &close[],
                const long  &tick_volume[],
                const long  &volume[],
                const int  &spread[])
  {
   static bool error=true;
   int start,start2,start3;
   int begin2;
   int beginX;
   if(prev_calculated==0)
     {
      error=true;
     }
   if(error)
     {
      start=MAPeriod;
      begin2=start;
      start2=begin2;
      start3=start2;
      beginX=start3;
      error=false;
      ArrayInitialize(HeikenAshiBuffer1,EMPTY_VALUE);
      ArrayInitialize(HeikenAshiBuffer2,EMPTY_VALUE);
      ArrayInitialize(HeikenAshiBuffer3,EMPTY_VALUE);
      ArrayInitialize(HeikenAshiBuffer4,EMPTY_VALUE);
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,MAPeriod+SmPeriod);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,MAPeriod+SmPeriod);
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,MAPeriod+SmPeriod);
      PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,MAPeriod+SmPeriod);
     }
   else
     {
      start=prev_calculated-1;
      start2=start;
      start3=start;
     }

   if(CopyBuffer(OpenMAHandle,0,0,rates_total-start,OpenMABuffer)==-1)
     {
      error=true;
      return(0);
     }
   if(CopyBuffer(HighMAHandle,0,0,rates_total-start,HighMABuffer)==-1)
     {
      error=true;
      return(0);
     }
   if(CopyBuffer(LowMAHandle,0,0,rates_total-start,LowMABuffer)==-1)
     {
      error=true;
      return(0);
     }
   if(CopyBuffer(CloseMAHandle,0,0,rates_total-start,CloseMABuffer)==-1)
     {
      error=true;
      return(0);
     }
   if(start2==begin2)
     {
      _open[start2]=OpenMABuffer[start2];
      _high[start2]=HighMABuffer[start2];
      _low[start2]=LowMABuffer[start2];
      _close[start2]=CloseMABuffer[start2];
      start2++;
     }
   for(int i=start2;i<rates_total;i++)
     {
      _close[i]=(OpenMABuffer[i]+HighMABuffer[i]+LowMABuffer[i]+CloseMABuffer[i])/4;
      _open[i]=(_open[i-1]+_close[i-1])/2;
      _high[i]=MathMax(HighMABuffer[i],MathMax(_open[i],_close[i]));
      _low[i]=MathMin(LowMABuffer[i],MathMin(_open[i],_close[i]));
     }
   fMAOnArray2(_open,_openSm,SmPeriod,SmMethod,beginX,start3,rates_total);
   fMAOnArray2(_high,_highSm,SmPeriod,SmMethod,beginX,start3,rates_total);
   fMAOnArray2(_low,_lowSm,SmPeriod,SmMethod,beginX,start3,rates_total);
   fMAOnArray2(_close,_closeSm,SmPeriod,SmMethod,beginX,start3,rates_total);
   if(Variant==HeikenAshi)
     {
      for(int i=start3;i<rates_total;i++)
        {
         HeikenAshiColors[i]=HeikenAshiColors[i-1];
         HeikenAshiBuffer1[i]=_openSm[i];
         HeikenAshiBuffer2[i]=MathMax(_highSm[i],MathMax(_openSm[i],_closeSm[i]));
         HeikenAshiBuffer3[i]=MathMin(_lowSm[i],MathMin(_openSm[i],_closeSm[i]));
         HeikenAshiBuffer4[i]=_closeSm[i];
         if(_closeSm[i]<_openSm[i])HeikenAshiColors[i]=1;
         if(_closeSm[i]>_openSm[i])HeikenAshiColors[i]=0;
        }
     }
   else
     {
      for(int i=start3;i<rates_total;i++)
        {
         HeikenAshiColors[i]=HeikenAshiColors[i-1];
         HeikenAshiBuffer1[i]=open[i];
         HeikenAshiBuffer2[i]=high[i];
         HeikenAshiBuffer3[i]=low[i];
         HeikenAshiBuffer4[i]=close[i];
         if(_closeSm[i]<_openSm[i])HeikenAshiColors[i]=1;
         if(_closeSm[i]>_openSm[i])HeikenAshiColors[i]=0;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| fMAOnArray2                                                      |
//+------------------------------------------------------------------+
void fMAOnArray2(const double  &aData[],double  &aMA[],int aPeriod,int aMethod,int aBegin,int aStart,int aRatesTotal)
  {
   double p1;
   double p2;
   double tWS=0;
   switch(aMethod)
     {
      case MODE_SMA:
         aStart=MathMax(aStart,aBegin+aPeriod);
         for(int i=aStart;i<aRatesTotal;i++)
           {
            if(i==aBegin+aPeriod)
              {
               aMA[i]=0;
               for(int j=0;j<aPeriod;j++)
                 {
                  aMA[i]+=aData[i-j];
                 }
               aMA[i]/=aPeriod;
              }
            else
              {
               aMA[i]=aMA[i-1]-(aData[i-aPeriod]-aData[i])/aPeriod;
              }
           }
         break;
      case MODE_EMA:
         if(aStart==aBegin)
           {
            aMA[aBegin]=aData[aBegin];
            aStart++;
           }
         p1=2.0/(1.0+aPeriod);
         p2=(1.0-p1);
         for(int i=aStart;i<aRatesTotal;i++)
           {
            aMA[i]=p1*aData[i]+p2*aMA[i-1];
           }
         break;
      case MODE_LWMA:
         aStart=MathMax(aStart,aBegin+aPeriod);
         tWS=(1.0+aPeriod)/2.0*aPeriod;
         for(int i=aStart;i<aRatesTotal;i++)
           {
            aMA[i]=0;
            for(int j=0;j<aPeriod;j++)
              {
               aMA[i]+=aData[i-j]*(aPeriod-j);

              }
            aMA[i]/=tWS;
           }
         break;
      case MODE_SMMA:
         if(aStart==aBegin)
           {
            aMA[aBegin]=aData[aBegin];
            aStart++;
           }
         p1=1.0/aPeriod;
         p2=(1.0-p1);
         for(int i=aStart;i<aRatesTotal;i++)
           {
            aMA[i]=p1*aData[i]+p2*aMA[i-1];
           }
         break;
     }
  }
//+------------------------------------------------------------------+
//| fMADrawBegin                                                     |
//+------------------------------------------------------------------+
int fMADrawBegin(int aPeriod,int aMethod)
  {
   switch(aMethod)
     {
      case 1: return(10*aPeriod);
      case 2: return(20*aPeriod);
     }
   return(aPeriod);
  }
//+------------------------------------------------------------------+
