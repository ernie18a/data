//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Synthetic RSX"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "Synthetic RSI"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
//--- input parameters
input int                inpEmaPeriod1   = 48;  // Ema 1 period
input int                inpRsiPeriod1   = 32;  // Rsx 1 period
input int                inpEmaPeriod2   = 24;  // Ema 2 period
input int                inpRsiPeriod2   = 16;  // Rsx 2 period
input int                inpEmaPeriod3   = 12;  // Ema 3 period
input int                inpRsiPeriod3   =  8;  // Rsx 3 period
input ENUM_APPLIED_PRICE inpPrice= PRICE_CLOSE; // Price 
input int                inpSignalPeriod=8;
//--- buffers declarations
double val[],valc[],signal[],signalc[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,signal,INDICATOR_DATA);
   SetIndexBuffer(3,signalc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Synthetic RSX ("+(string)inpRsiPeriod1+","+(string)inpEmaPeriod1+","+(string)inpRsiPeriod2+","+(string)inpEmaPeriod2+","+(string)inpRsiPeriod3+","+(string)inpEmaPeriod3+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double price = getPrice(inpPrice,open,close,high,low,i,rates_total);
      double rsi1  = iRsx(iEma(price,inpEmaPeriod1,i,rates_total,0),inpRsiPeriod1,i,rates_total,0);
      double rsi2  = iRsx(iEma(price,inpEmaPeriod2,i,rates_total,1),inpRsiPeriod2,i,rates_total,1);
      double rsi3  = iRsx(iEma(price,inpEmaPeriod3,i,rates_total,2),inpRsiPeriod3,i,rates_total,2);
      val[i]     = (rsi3+2.0*rsi2+3.0*rsi1)/6.0;
      signal[i]  = iEma(val[i],inpSignalPeriod,i,rates_total,3);
      valc[i]    = (val[i]>signal[i]) ? 1 :(val[i]<signal[i]) ? 2 : (i>0) ? valc[i-1] : 0;
      signalc[i] = valc[i];
     }
   return (rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _rsxRingSize       5
#define _rsxInstances      3
#define _rsxInstancesSize 13
double workRsi[_rsxRingSize][_rsxInstances*_rsxInstancesSize];
#define _price  0
//
//---
//
double iRsx(double price,double period,int i, int bars, int instanceNo=0)
  {
   int _indP = (int)MathMod(i-1,_rsxRingSize);
   int _indC = (int)MathMod(i  ,_rsxRingSize);
   int _inst = instanceNo*_rsxInstancesSize;
   
      if(i<period) { for(int k=1; k<_rsxInstancesSize; k++) workRsi[_indC][_inst+k]=0; return(50); }
   
      workRsi[_indC][_inst]=price;
      double Kg=(3.0)/(2.0+period),Hg=1.0-Kg;
      //
      //---
      //
      double mom = workRsi[_indC][_inst]-workRsi[_indP][_inst];
      double moa = MathAbs(mom);
      for(int k=0; k<3; k++)
      {
         int kk=_inst+k*2;
         workRsi[_indC][kk+1] = Kg*mom                  + Hg*workRsi[_indP][kk+1];
         workRsi[_indC][kk+2] = Kg*workRsi[_indC][kk+1] + Hg*workRsi[_indP][kk+2]; mom = 1.5*workRsi[_indC][kk+1] - 0.5 * workRsi[_indC][kk+2];
         workRsi[_indC][kk+7] = Kg*moa                  + Hg*workRsi[_indP][kk+7];
         workRsi[_indC][kk+8] = Kg*workRsi[_indC][kk+7] + Hg*workRsi[_indP][kk+8]; moa = 1.5*workRsi[_indC][kk+7] - 0.5 * workRsi[_indC][kk+8];
     }
   return(MathMax(MathMin((mom/MathMax(moa,DBL_MIN)+1.0)*50.0,100.00),0.00));
  }
//
//---
//
double workEma[][4];
//
//---
//
double iEma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=_bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo]=price;
   if(r>0 && period>1)
      workEma[r][instanceNo]=workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
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
