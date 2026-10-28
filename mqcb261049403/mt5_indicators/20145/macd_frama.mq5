//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property link        "https://www.mql5.com/en/users/mladen/publications"
#property version     "1.00"
#property description "Macd FRAMA"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "Macd frama filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'218,231,226',C'255,221,217'
#property indicator_label2  "Macd frama value"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDodgerBlue,clrCrimson
#property indicator_width2  2
#property indicator_label3  "Macd signal"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_width3  1

//--- input parameters
input int                inpFastPeriod   = 19;          // Fast FRAMA period
input int                inpSlowPeriod   = 39;          // Slow FRAMA period
input int                inpSignalPeriod = 25;          // Signal period
input int                inpSmoothPeriod = 25;          // Smoothing period
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE; // Price 
//--- buffers declarations
double fillu[],filld[],val[],valc[],signal[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,fillu,INDICATOR_DATA);
   SetIndexBuffer(1,filld,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,signal,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Macd FRAMA ("+(string)inpFastPeriod+","+(string)inpSlowPeriod+","+(string)inpSignalPeriod+","+(string)inpSmoothPeriod+")");
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

   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      double _price=getPrice(inpPrice,open,close,high,low,i,rates_total);
      val[i]    = iSsm(iFrama(_price,inpFastPeriod,i,rates_total,0),inpSmoothPeriod,i,rates_total,0)-iSsm(iFrama(_price,inpSlowPeriod,i,rates_total,1),inpSmoothPeriod,i,rates_total,1);
      signal[i] = iFrama(val[i],inpSignalPeriod,i,rates_total,2);
      fillu[i]  = val[i];
      filld[i]  = signal[i];
      valc[i]=(val[i]>signal[i]) ? 1 :(val[i]<signal[i]) ? 2 :(i>0) ? valc[i-1]: 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workSsm[][4];
#define _tprice  0
#define _ssm     1

double workSsmCoeffs[][4];
#define _speriod 0
#define _sc1    1
#define _sc2    2
#define _sc3    3
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSsm(double price,double period,int i,int bars,int instanceNo=0)
  {
   if(period<=1) return(price);
   if(ArrayRange(workSsm,0)!=bars) ArrayResize(workSsm,bars);
   if(ArrayRange(workSsmCoeffs,0)<(instanceNo+1)) ArrayResize(workSsmCoeffs,instanceNo+1);
   if(workSsmCoeffs[instanceNo][_speriod]!=period)
     {
      workSsmCoeffs[instanceNo][_speriod]=period;
      double a1 = MathExp(-1.414*M_PI/period);
      double b1 = 2.0*a1*MathCos(1.414*M_PI/period);
      workSsmCoeffs[instanceNo][_sc2] = b1;
      workSsmCoeffs[instanceNo][_sc3] = -a1*a1;
      workSsmCoeffs[instanceNo][_sc1] = 1.0 - workSsmCoeffs[instanceNo][_sc2] - workSsmCoeffs[instanceNo][_sc3];
     }
   int s=instanceNo*2;
   workSsm[i][s+_ssm]    = price;
   workSsm[i][s+_tprice] = price;
   if(i>1)
     {
      workSsm[i][s+_ssm]=workSsmCoeffs[instanceNo][_sc1]*(workSsm[i][s+_tprice]+workSsm[i-1][s+_tprice])/2.0+
                         workSsmCoeffs[instanceNo][_sc2]*workSsm[i-1][s+_ssm]+
                         workSsmCoeffs[instanceNo][_sc3]*workSsm[i-2][s+_ssm]; 
     }
   return(workSsm[i][s+_ssm]);
  }
//
//
//
double workFrama[][6];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iFrama(double price,int fperiod,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workFrama,0)!=bars) ArrayResize(workFrama,bars); instanceNo*=2;
   workFrama[r][instanceNo+0] = price;
   if(r<1 || fperiod<=1) workFrama[r][instanceNo+1]=price;
   else
     {
      int halfPeriod=MathMax(fperiod/2,1),k;
      double hh=workFrama[r][instanceNo+0],ll=workFrama[r][instanceNo+0];
      for(k=1; k<fperiod && (r-k)>=0; k++)
        {
         hh = MathMax(workFrama[r-k][instanceNo+0],hh);
         ll = MathMin(workFrama[r-k][instanceNo+0],ll);
        }
      double n3=(hh-ll)/(double)fperiod;
      hh=ll=workFrama[r][instanceNo+0];
      for(k=1; k<halfPeriod && (r-k)>=0; k++)
        {
         hh = MathMax(workFrama[r-k][instanceNo+0],hh);
         ll = MathMin(workFrama[r-k][instanceNo+0],ll);
        }
      double n1=(hh-ll)/(double)halfPeriod;
      hh=ll=workFrama[MathMax(r-halfPeriod,0)][instanceNo+0];
      for(k=halfPeriod+1; k<fperiod && (r-k)>=0; k++)
        {
         hh = MathMax(workFrama[r-k][instanceNo+0],hh);
         ll = MathMin(workFrama[r-k][instanceNo+0],ll);
        }
      double n2=(hh-ll)/(double)halfPeriod;
      double dimen=0;
      if((n1+n2)>0 && n3>0) dimen=(MathLog(n1+n2)-MathLog(n3))/MathLog(2.0);
      double alpha=MathMin(MathMax(MathExp(-4.6*(dimen-1.0)),0.001),1.000);
      workFrama[r][instanceNo+1]=alpha*price+(1-alpha)*workFrama[r-1][instanceNo+1];
     }
   return(workFrama[r][instanceNo+1]);
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
