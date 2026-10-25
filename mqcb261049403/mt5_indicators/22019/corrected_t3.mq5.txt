//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "T3"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrCrimson,clrLimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Corrected T3"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrCrimson,clrLimeGreen
#property indicator_width2  2
//--- input parameters
enum enT3Type
  {
   t3_tillson, // Tim Tillson way of calculation
   t3_fulksmat // Fulks/Matulich way of calculation
  };
input double             inpPeriod = 10;           // Period
input double             inpHot    = 0.7;          // T3 hot
input enT3Type           inpT3Type = t3_fulksmat;  // T3 type
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE;  // Price
//--- indicator buffers
double val[],valc[],avg[],avgc[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,avg,INDICATOR_DATA);
   SetIndexBuffer(1,avgc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Corrected T3 ("+(string)inpPeriod+")");
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
      double _price   = getPrice(inpPrice,open,close,high,low,i,rates_total);
      avg[i]  = iT3(_price,inpPeriod,inpHot,inpT3Type==t3_tillson,i,rates_total);
      val[i]  = iCorrMa(avg[i],_price,(int)inpPeriod,i,rates_total);
      valc[i] = (i>0) ?(val[i]<avg[i]) ? 2 :(val[i]>avg[i]) ? 1 : valc[i-1]: 0;
      avgc[i] = valc[i];
     }
   return(rates_total);
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
#define _t3Instances     1
#define _t3InstancesSize 6
double workT3[][_t3Instances*_t3InstancesSize];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5
//
//---
//
double iT3(double price,double period,double hot,bool original,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workT3,0)!=bars) ArrayResize(workT3,bars);
   if(ArrayRange(workT3Coeffs,0)<(instanceNo+1)) ArrayResize(workT3Coeffs,instanceNo+1);
   if(workT3Coeffs[instanceNo][_period]!=period)
     {
      workT3Coeffs[instanceNo][_period]=period;
      workT3Coeffs[instanceNo][_c1] = -hot*hot*hot;
      workT3Coeffs[instanceNo][_c2] = 3*hot*hot+3*hot*hot*hot;
      workT3Coeffs[instanceNo][_c3] = -6*hot*hot-3*hot-3*hot*hot*hot;
      workT3Coeffs[instanceNo][_c4] = 1+3*hot+hot*hot*hot+3*hot*hot;
      if(original)
         workT3Coeffs[instanceNo][_alpha]=2.0/(1.0+period);
      else workT3Coeffs[instanceNo][_alpha]=2.0/(2.0+(period-1.0)/2.0);
     }
   //---
   int buffer=instanceNo*_t3InstancesSize;
   for(int k=0; k<6; k++) workT3[r][k+buffer]=(r>0) ? workT3[r-1][k+buffer]: price;
   if(r>0 && period>1)
     {
      workT3[r][0+buffer] = workT3[r-1][0+buffer]+workT3Coeffs[instanceNo][_alpha]*(price              -workT3[r-1][0+buffer]);
      workT3[r][1+buffer] = workT3[r-1][1+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][0+buffer]-workT3[r-1][1+buffer]);
      workT3[r][2+buffer] = workT3[r-1][2+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][1+buffer]-workT3[r-1][2+buffer]);
      workT3[r][3+buffer] = workT3[r-1][3+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][2+buffer]-workT3[r-1][3+buffer]);
      workT3[r][4+buffer] = workT3[r-1][4+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][3+buffer]-workT3[r-1][4+buffer]);
      workT3[r][5+buffer] = workT3[r-1][5+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][4+buffer]-workT3[r-1][5+buffer]);
     }
   return(workT3Coeffs[instanceNo][_c1]*workT3[r][5+buffer] +
          workT3Coeffs[instanceNo][_c2]*workT3[r][4+buffer]+
          workT3Coeffs[instanceNo][_c3]*workT3[r][3+buffer]+
          workT3Coeffs[instanceNo][_c4]*workT3[r][2+buffer]);
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
