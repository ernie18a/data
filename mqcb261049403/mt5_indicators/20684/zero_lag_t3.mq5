//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "Zero lag T3"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width1  2
//--- input parameters
enum enT3Type
  {
   t3_tillson, // Tim Tillson way of calculation
   t3_fulksmat // Fulks/Matulich way of calculation
  };
input double             inpPeriod = 14;           // Period
input double             inpHot    = 0.7;          // T3 hot
input enT3Type           inpT3Type = t3_fulksmat;  // T3 type
input ENUM_APPLIED_PRICE inpPrice  = PRICE_MEDIAN; // Price
//--- indicator buffers
double val[],valc[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Zero lag T3 ("+(string)inpPeriod+")");
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
      double t31 = iT3(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,inpHot,inpT3Type==t3_tillson,i,rates_total,0);
      double t32 = iT3(t31                                                 ,inpPeriod,inpHot,inpT3Type==t3_tillson,i,rates_total,1);
      val[i]=2.0*t31-t32;
      valc[i]=(i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _t3Instances     2
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
