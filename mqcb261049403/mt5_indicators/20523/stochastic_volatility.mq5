//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   4
#property indicator_label1  "up level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "down level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Stochastic volatility"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrLimeGreen
#property indicator_width3  2
#property indicator_label4  "Signal"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrOrangeRed
#property indicator_style4  STYLE_DOT
//
//---
//
//
//--- input parameters
//

input int                Length             =  30;            // Stochastic period
input int                Slowing            =   5;            // Stochastic slowing
input int                Signal             =   5;            // Signal period
input int                BandsLength        = 126;            // Bands period
input double             BandsDeviation     =   1;            // Bands deviation
input ENUM_APPLIED_PRICE Price              = PRICE_CLOSE;    // Price
input bool               OriginalStoch      = true;           // Calculate using original stochastic
input bool               OriginalVolatility = true;           // Calculate using original volatility

double val[],valc[],signal[],levelUp[],levelDn[],prices[],logBuffer[],volBuffer[],wrkBuffer[][2];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,levelUp,INDICATOR_DATA);
   SetIndexBuffer(1,levelDn,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,signal,INDICATOR_DATA);
   SetIndexBuffer(5,prices,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,logBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,volBuffer,INDICATOR_CALCULATIONS);
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic volatility ("+(string)Length+","+(string)Slowing+","+(string)Signal+")");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
#define __hi 0
#define __lo 1
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   if(ArrayRange(wrkBuffer,0)!=rates_total) ArrayResize(wrkBuffer,rates_total);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      prices[i]=getPrice(Price,open,close,high,low,i,rates_total);
      double vol1 = volatility(prices,logBuffer,10,i)*3.0;
      double vol2 = volatility(prices,logBuffer,21,i)*3.0;
      double vol3 = volatility(prices,logBuffer,34,i)*2.0;
      double vol4 = volatility(prices,logBuffer,55,i);
      double vol5 = volatility(prices,logBuffer,89,i);
      volBuffer[i]=(vol1+vol2+vol3+vol4+vol5);

      //
      //---
      //

      double hi = volBuffer[i];
      double lo = volBuffer[i];
      for(int k=1; k<Length && (i-k)>=0; k++)
        {
         hi = MathMax(hi,volBuffer[i-k]);
         lo = MathMin(lo,volBuffer[i-k]);
        }
      wrkBuffer[i][__hi] = hi;
      wrkBuffer[i][__lo] = lo;

      //
      //---
      //

      double stoc=0;
      if(OriginalStoch)
        {
         double sumRng = 0;
         double sumLow = 0;
         for(int k=0; k<Slowing && (i-k)>=0; k++)
           {
            sumRng += wrkBuffer[i-k][__hi]-wrkBuffer[i-k][__lo];
            sumLow += volBuffer[i-k]      -wrkBuffer[i-k][__lo];
           }
         if(sumRng!=0) stoc=100*sumLow/sumRng;
        }
      else
        {
         double stov=0;
         if(hi!=lo) stov=100*(volBuffer[i]-lo)/(hi-lo);
         stoc=(i>0) ? MathMax(MathMin(val[i-1]+(2.0/(1.0+Slowing))*(stov-val[i-1]),100),0) : 0;
        }

      //
      //---
      //

      val[i]    = stoc;
      signal[i] = iSma(val,Signal,i);

      //
      //---
      //

      double average   = iSma(val,BandsLength,i);
      double deviation = iDeviation(val,BandsLength,average,i);
      levelUp[i] = average+deviation+BandsDeviation;
      levelDn[i] = average-deviation+BandsDeviation;
      valc[i]=(val[i]<levelDn[i]) ? 1 : 0;
     }
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double volatility(double &array[],double &destArray[],int length,int i)
  {
   destArray[i]=(i>0) ?(array[i-1]!=0) ? MathLog(array[i]/array[i-1]) : 0 : 0;
   if(i>=length)
     {
      double average=destArray[i],dSum=0;
      for(int k=0; k<length && (i-k)>=0; k++) average += destArray[i-k]; average /= (double)length;
      for(int k=0; k<length && (i-k)>=0; k++) dSum += (destArray[i-k]-average)*(destArray[i-k]-average);
      double deviation=MathSqrt(dSum/length);
      if(OriginalVolatility)
         return((average+deviation)*MathSqrt(252));
      else  return(deviation);
     }
   else return(0);
  }
//
//---
//
double iSma(double &array[],int period,int pos)
  {
   double sum=array[pos];
   for(int i=1; i<period && (pos-i)>=0; i++) sum+=array[pos-i];
   return(sum/period);
  }
//
//---
//
double iDeviation(double &array[],int period,double dMA,int pos)
  {
   double dSum = 0;
   for(int i=0; i<period && (pos-i)>=0; i++) dSum += (array[pos-i]-dMA)*(array[pos-i]-dMA);
   return(MathSqrt(dSum/period));
  }
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   switch(tprice)
     {
      case PRICE_CLOSE:     return(close[i]);
      case PRICE_OPEN:      return(open[i]);
      case PRICE_HIGH:      return(high[i]);
      case PRICE_LOW:       return(low[i]);
      case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
      case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
      case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
