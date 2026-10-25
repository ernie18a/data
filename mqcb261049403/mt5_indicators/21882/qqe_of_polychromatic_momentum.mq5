//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "QQE of Polychromatic momentum"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "QQE fast"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "QQE slow"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_label3  "QQE"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width3  2
//--- input parameters
input int                inpPcmPeriod          = 50;          // Polychromatic momentum period
input int                inpPcmSmoothingFactor = 14;          // Polychromatic momentum smoothing factor
input double             inpWPFast             = 2.618;       // Fast period
input double             inpWPSlow             = 4.236;       // Slow period
input ENUM_APPLIED_PRICE inpPcmPrice           = PRICE_CLOSE; // Price 
//--- buffers declarations
double val[],valc[],levs[],levf[],prices[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,levf,INDICATOR_DATA);
   SetIndexBuffer(1,levs,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,prices,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"QQE of Polychormatic momentum ("+(string)inpPcmPeriod+","+(string)inpPcmSmoothingFactor+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      prices[i]=getPrice(inpPcmPrice,open,close,high,low,i,rates_total);
      double sumMom = 0;
      double sumWgh = 0;
      for(int k=0; k<inpPcmPeriod && (i-k-1)>=0; k++)
        {
         double weight = MathSqrt(k+1);
         sumMom += (prices[i]-prices[i-k-1])/weight;
         sumWgh += weight;
        }
      val[i] = iDsema((sumWgh != 0) ? sumMom/sumWgh : 0,inpPcmSmoothingFactor,i,rates_total,0);
      double _iEma = iEma((i>0 ? MathAbs(val[i-1]-val[i]) : 0),inpPcmPeriod,i,rates_total,1);
      double _iEmm = iEma(                               _iEma,inpPcmPeriod,i,rates_total,2);
      double _iEmf = _iEmm*inpWPFast;
      double _iEms = _iEmm*inpWPSlow;
      //
      //---
      //
        {
         double tr = (i>0) ? levs[i-1] : 0;
         double dv = tr;
         if(val[i] < tr) { tr = val[i] + _iEms; if((i>0 && val[i-1] < dv) && (tr > dv)) tr = dv; }
         if(val[i] > tr) { tr = val[i] - _iEms; if((i>0 && val[i-1] > dv) && (tr < dv)) tr = dv; }
         levs[i]=tr;
        }
        {
         double tr = (i>0) ? levf[i-1] : 0;
         double dv = tr;
         if(val[i] < tr) { tr = val[i] + _iEmf; if((i>0 && val[i-1] < dv) && (tr > dv)) tr = dv; }
         if(val[i] > tr) { tr = val[i] - _iEmf; if((i>0 && val[i-1] > dv) && (tr < dv)) tr = dv; }
         levf[i]=tr;
        }
      valc[i]=(val[i]>levf[i] && val[i]>levs[i]) ? 1 :(val[i]<levf[i] && val[i]<levs[i]) ? 2 :(i>0) ? valc[i-1]: 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workDsema[][2];
#define _ema1 0
#define _ema2 1
//
//---
//
double iDsema(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(period<=1) return(price);
   if(ArrayRange(workDsema,0)!=bars) ArrayResize(workDsema,bars); instanceNo*=2;

//
//
//
//
//

   workDsema[r][_ema1+instanceNo] = price;
   workDsema[r][_ema2+instanceNo] = price;
   double alpha=2.0/(1.0+MathSqrt(period));
   if(r>0)
     {
      workDsema[r][_ema1+instanceNo]=workDsema[r-1][_ema1+instanceNo]+alpha*(price                         -workDsema[r-1][_ema1+instanceNo]);
      workDsema[r][_ema2+instanceNo]=workDsema[r-1][_ema2+instanceNo]+alpha*(workDsema[r][_ema1+instanceNo]-workDsema[r-1][_ema2+instanceNo]); 
     }
   return(workDsema[r][_ema2+instanceNo]);
  }
  #undef _ema1
  #undef _ema2
//
//---
//
double workEma[][3];
//
//---
//
double iEma(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=bars) ArrayResize(workEma,bars);

//
//---
//

   workEma[r][instanceNo]=price;
   if(r>0 && period>1)
      workEma[r][instanceNo]=workEma[r-1][instanceNo]+2.0/(1.0+period)*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
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
