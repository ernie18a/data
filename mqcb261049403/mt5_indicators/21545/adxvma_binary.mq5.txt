//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "ADXVMA moving average - binary"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "ADXVMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDeepPink
#property indicator_width1  2
#property indicator_minimum -1.1
#property indicator_maximum  1.1
//--- input parameters
input double             inpPeriod = 14;           // Period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_MEDIAN; // Price
//--- indicator buffers
double val[],adxvma[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,adxvma,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"ADXVMA binary("+(string)inpPeriod+")");
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
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      adxvma[i]=iAdxvma(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,i,rates_total);
      val[i] = (i>0) ?(adxvma[i]>adxvma[i-1]) ? 1 :(adxvma[i]<adxvma[i-1]) ? -1 : val[i-1]: 0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _adxVmaInstances 1
#define _adxVmaInstancesSize 7
double  adxvmaWork[][_adxVmaInstances*_adxVmaInstancesSize];
#define _adxvmaWprc 0
#define _adxvmaWpdm 1
#define _adxvmaWmdm 2
#define _adxvmaWpdi 3
#define _adxvmaWmdi 4
#define _adxvmaWout 5
#define _adxvmaWval 6
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iAdxvma(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(adxvmaWork,0)!=bars) ArrayResize(adxvmaWork,bars); instanceNo*=_adxVmaInstancesSize;
//
//---
//
   adxvmaWork[r][instanceNo+_adxvmaWprc]=price;
   if(r<1)
     {
      adxvmaWork[r][instanceNo+_adxvmaWval]=adxvmaWork[r][instanceNo+_adxvmaWprc];
      return(adxvmaWork[r][_adxvmaWval]);
     }
//
//---
//
   double tpdm = 0;
   double tmdm = 0;
   double diff = adxvmaWork[r][instanceNo+_adxvmaWprc]-adxvmaWork[r-1][instanceNo+_adxvmaWprc];
   if(diff>0)
      tpdm =  diff;
   else  tmdm = -diff;
   adxvmaWork[r][instanceNo+_adxvmaWpdm] = ((period-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWpdm]+tpdm)/period;
   adxvmaWork[r][instanceNo+_adxvmaWmdm] = ((period-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWmdm]+tmdm)/period;
//
//---
//
   double trueRange = adxvmaWork[r][instanceNo+_adxvmaWpdm]+adxvmaWork[r][instanceNo+_adxvmaWmdm];
   double tpdi      = 0;
   double tmdi      = 0;
   if(trueRange>0)
     {
      tpdi = adxvmaWork[r][instanceNo+_adxvmaWpdm]/trueRange;
      tmdi = adxvmaWork[r][instanceNo+_adxvmaWmdm]/trueRange;
     }
   adxvmaWork[r][instanceNo+_adxvmaWpdi] = ((period-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWpdi]+tpdi)/period;
   adxvmaWork[r][instanceNo+_adxvmaWmdi] = ((period-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWmdi]+tmdi)/period;
//
//---
//
   double tout=0;
   if((adxvmaWork[r][instanceNo+_adxvmaWpdi]+adxvmaWork[r][instanceNo+_adxvmaWmdi])>0)
      tout=MathAbs(adxvmaWork[r][instanceNo+_adxvmaWpdi]-adxvmaWork[r][instanceNo+_adxvmaWmdi])/(adxvmaWork[r][instanceNo+_adxvmaWpdi]+adxvmaWork[r][instanceNo+_adxvmaWmdi]);
   adxvmaWork[r][instanceNo+_adxvmaWout]=((period-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWout]+tout)/period;
//
//---
//
   double thi = MathMax(adxvmaWork[r][instanceNo+_adxvmaWout],adxvmaWork[r-1][instanceNo+_adxvmaWout]);
   double tlo = MathMin(adxvmaWork[r][instanceNo+_adxvmaWout],adxvmaWork[r-1][instanceNo+_adxvmaWout]);
   for(int j=2; j<(int)period && r-j>=0; j++)
     {
      thi = MathMax(adxvmaWork[r-j][instanceNo+_adxvmaWout],thi);
      tlo = MathMin(adxvmaWork[r-j][instanceNo+_adxvmaWout],tlo);
     }
   double vi=0; if((thi-tlo)>0) vi=(adxvmaWork[r][instanceNo+_adxvmaWout]-tlo)/(thi-tlo);
//
//---
//
   adxvmaWork[r][instanceNo+_adxvmaWval]=((period-vi)*adxvmaWork[r-1][instanceNo+_adxvmaWval]+vi*adxvmaWork[r][instanceNo+_adxvmaWprc])/period;
   return(adxvmaWork[r][instanceNo+_adxvmaWval]);
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
