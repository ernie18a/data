//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Smooth PGO"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Smooth PGO"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDodgerBlue,clrSandyBrown
#property indicator_width1  2
//
//--- input parameters
//
input int                 inpPgoPeriod   = 89;          // PGO period
input ENUM_APPLIED_PRICE  inpPrice       = PRICE_CLOSE; // Price
input double              inpTmSmoothing =  5;          // TM smoothing
input double              inpTmDamping   =  5;          // TM damping
input double              inpTmNoise     =  2;          // TM noise
//
//--- indicator buffers
//
double val[],valc[];
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"TM Smoothed PGO ("+(string)inpPgoPeriod+","+(string)inpTmSmoothing+")");
   return(INIT_SUCCEEDED);
}
//------------------------------------------------------------------
// Custom indicator de-initialization function
//------------------------------------------------------------------
void OnDeinit(const int reason) { return; }
//------------------------------------------------------------------
// Custom iteration function
//------------------------------------------------------------------
double work[];
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{                
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
   if (ArraySize(work)!=rates_total) ArrayResize(work,rates_total);
   
   //
   //---
   //

   double alphaAtr = 2.0/(1.0+inpPgoPeriod);   
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !_StopFlag; i++)
   {
      double _price = getPrice(inpPrice,open,close,high,low,i,rates_total);
      work[i] = (i>0) ? work[i-1] + alphaAtr*(MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1])-work[i-1]) : high[i]-low[i];
      val[i]  = iTmSmooth((_price-iSma(_price,inpPgoPeriod,i,rates_total))/work[i],inpTmDamping,inpTmNoise,inpTmSmoothing,i,rates_total);
      valc[i] = (i>0) ? (val[i]<val[i-1]) : 0 ;
   }          
   return(rates_total);
}

//+------------------------------------------------------------------
//| Custom functions
//+------------------------------------------------------------------
double workSma[][1];
//
//---
//
double iSma(double price,int period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo]=price;
   double avg=price; int k=1; for(; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo];
   return(avg/(double)k);
  }
//
//---
//
double wrkTm[][3];
#define _price 0
#define _y1    1
#define _y2    2
//
//---
//
double iTmSmooth(double price, double damping, double noise, double length, int i, int bars)
{
   if (ArrayRange(wrkTm,0) != bars) ArrayResize(wrkTm,bars);
   if (length<=1) return(price);

   //
   //
   //
   //
   //

      wrkTm[i][_price] = price;

         double y1 = i>0 ? wrkTm[i-1][_y1] : 0;
         double y2 = i>0 ? wrkTm[i-1][_y2] : 0;
         
         double err = (wrkTm[i][_price]-2.0*y1+y2)/noise; 
         double drv = MathMax(MathMin((1.0/length)*err*err+(1.0/length)*MathAbs(err),0.5),0.0);
         double dmp = MathMax(MathMin((1.0/length)*MathAbs(y1-y2)/noise + damping/100.0,1.0),0.0);
         
         //
         //
         //
         //
         //
         
      double tmAvg  = y1 + noise*err*drv + (y1-y2)*(1.0-dmp);
      wrkTm[i][_y1] = tmAvg;
      wrkTm[i][_y2] = y1;
      return(tmAvg);
      #undef _price
      #undef _y1
      #undef _y2
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
