//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Corrected RSI"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "RSI"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Corrected RSI"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width2  2
//--- input parameters
input int                inpRsiPeriod  =  14;         // RSI period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price 
//--- buffers declarations
double val[],valc[],rsi[],rsic[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,rsi,INDICATOR_DATA);
   SetIndexBuffer(1,rsic,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Corrected RSI ("+(string)inpRsiPeriod+")");
//---
   return (INIT_SUCCEEDED);
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
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   double _rsiVal[1];
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      rsi[i]  = iRsi(getPrice(inpPrice,open,close,high,low,i,rates_total),inpRsiPeriod,i,rates_total);
      val[i]  = iCorrMa(rsi[i],rsi[i],inpRsiPeriod,i,rates_total);
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
      rsic[i] = valc[i];
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _corrMaInstances 1
#define _corrMaInstancesSize 3
double workCorrMa[][_corrMaInstances*_corrMaInstancesSize];
#define _price 0
#define _orig  1
#define _corr  2
//
//---
//
double iCorrMa(double _avg, double price, int period, int i, int _bars, int instanceNo=0)
{
   if (ArrayRange(workCorrMa,0)!= _bars) ArrayResize(workCorrMa,_bars); instanceNo*=_corrMaInstancesSize;
      workCorrMa[i][_price] = price;
      workCorrMa[i][_orig]  = _avg;

      //
      //---
      //
      
      double oldMean   = price;
      double newMean   = price;
      double squares   = 0; int k=1;
      for (; k<period && (i-k)>=0; k++)
      {
         newMean  = (workCorrMa[i-k][_price]-oldMean)/(k+1)+oldMean;
         squares += (workCorrMa[i-k][_price]-oldMean)*(workCorrMa[i-k][_price]-newMean);
         oldMean  = newMean;
      }
      double _deviation = MathSqrt(squares/k);
      double v1         = MathPow(_deviation,2);
      double v2         = (i>0) ? MathPow(workCorrMa[i-1][_corr]-workCorrMa[i][_orig],2) : 0;
      double c          = (v2<v1||v2==0) ? 0 : 1-v1/v2;
          workCorrMa[i][_corr] = (i>0) ? workCorrMa[i-1][_corr]+c*(workCorrMa[i][_orig]-workCorrMa[i-1][_corr]) : workCorrMa[i][_orig];
   return(workCorrMa[i][_corr]);
   #undef _price
   #undef _orig
   #undef _corr
}
//
//---
//
#define rsiInstances 1
double workRsi[][rsiInstances*3];
#define _price  0
#define _change 1
#define _changa 2
//
//
//
double iRsi(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workRsi,0)!=bars) ArrayResize(workRsi,bars);
   int z=instanceNo*3;

//
//
//
//
//

   workRsi[r][z+_price]=price;
   double alpha=1.0/MathMax(period,1);
   if(r<period)
     {
      int k; double sum=0; for(k=0; k<period && (r-k-1)>=0; k++) sum+=MathAbs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
      workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/MathMax(k,1);
      workRsi[r][z+_changa] =                                         sum/MathMax(k,1);
     }
   else
     {
      double change=workRsi[r][z+_price]-workRsi[r-1][z+_price];
      workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(        change  - workRsi[r-1][z+_change]);
      workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(MathAbs(change) - workRsi[r-1][z+_changa]);
     }
   return(50.0*(workRsi[r][z+_change]/MathMax(workRsi[r][z+_changa],DBL_MIN)+1));
   #undef _price
   #undef _change
   #undef _changa
  }
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   if(i>=0)
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
