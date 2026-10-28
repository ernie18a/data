//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Rsx QQE new"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "QQE"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
//--- input parameters
input int                inpRsiPeriod          = 14;         // RSX period
input int                inpRsiSmoothingFactor =  5;         // RSX smoothing factor
input double             inpWPSlow             = 4.236;      // QQE quantifier
input double             inpUpBound            =  10;        // Upper bound
input double             inpDnBound            = -10;        // Lower bound
input ENUM_APPLIED_PRICE inpPrice=PRICE_CLOSE; // Price 
//--- buffers declarations
double val[],vald[],valc[],levs[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,vald,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,val,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,levs,INDICATOR_CALCULATIONS);
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,inpUpBound);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,inpDnBound);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Rsx QQE new ("+(string)inpRsiPeriod+","+(string)inpRsiSmoothingFactor+")");
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
      val[i]=iEma(iRsi(getPrice(inpPrice,open,close,high,low,i,rates_total),inpRsiPeriod,i,rates_total),inpRsiSmoothingFactor,i,rates_total,0);
      double _iEma = iEma((i>0 ? MathAbs(val[i-1]-val[i]) : 0),inpRsiPeriod,i,rates_total,1);
      double _iEmm = iEma(                               _iEma,inpRsiPeriod,i,rates_total,2);
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
      vald[i]=val[i]-50;   
      valc[i]=(vald[i]>inpUpBound) ? 1 :(vald[i]<inpDnBound) ? 2 :0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _rsxInstances      1
#define _rsxInstancesSize 13
double workRsi[][_rsxInstances*_rsxInstancesSize];
#define _price  0
//
//---
//
double iRsi(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workRsi,0)!=bars) ArrayResize(workRsi,bars); int z=instanceNo*_rsxInstancesSize;
//
//---
//
   workRsi[r][z+_price]=price;
   double Kg=(3.0)/(2.0+period),Hg=1.0-Kg;
   if(r<period) { for(int k=1; k<13; k++) workRsi[r][k+z]=0; return(50); }
//
//---
//
   double mom = workRsi[r][_price+z]-workRsi[r-1][_price+z];
   double moa = MathAbs(mom);
   for(int k=0; k<3; k++)
     {
      int kk=k*2;
      workRsi[r][z+kk+1] = Kg*mom                + Hg*workRsi[r-1][z+kk+1];
      workRsi[r][z+kk+2] = Kg*workRsi[r][z+kk+1] + Hg*workRsi[r-1][z+kk+2]; mom = 1.5*workRsi[r][z+kk+1] - 0.5 * workRsi[r][z+kk+2];
      workRsi[r][z+kk+7] = Kg*moa                + Hg*workRsi[r-1][z+kk+7];
      workRsi[r][z+kk+8] = Kg*workRsi[r][z+kk+7] + Hg*workRsi[r-1][z+kk+8]; moa = 1.5*workRsi[r][z+kk+7] - 0.5 * workRsi[r][z+kk+8];
     }
   return(MathMax(MathMin((mom/MathMax(moa,DBL_MIN)+1.0)*50.0,100.00),0.00));
  }
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
