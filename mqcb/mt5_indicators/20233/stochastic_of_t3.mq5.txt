//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "Stochastic of T3"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Stochastic of T3"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
//--- input parameters
input int                inpStoPeriod  =  34;         // Stochastic period
input int                inpStoSlowing =   3;         // Stochastic slowing
input int                inpT3Period   =  14;         // T3 period
input double             inpT3Hot      =  0.7;        // T3 hot
input bool               inpT3Original =  false;      // T3 original Tim Tillson calculation
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price 
//--- buffers declarations
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
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic of T3 ("+(string)inpStoPeriod+","+(string)inpStoSlowing+","+(string)inpT3Period+")");
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
      double _price=iT3(getPrice(inpPrice,open,close,high,low,i,rates_total),inpT3Period,inpT3Hot,inpT3Original,i,rates_total);
      val[i]  = iStoch(_price,_price,_price,inpStoPeriod,inpStoSlowing,rates_total,i);
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
     }
   return (i);
  }

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workSto[][5];
#define _hi 0
#define _lo 1
#define _re 2
#define _ma 3
#define _mi 4
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iStoch(double priceR,double priceH,double priceL,int period,int slowing,int bars,int i,int instanceNo=0)
  {
   if(ArrayRange(workSto,0)!=bars) ArrayResize(workSto,bars); instanceNo*=5;
   workSto[i][_hi+instanceNo] = priceH;
   workSto[i][_lo+instanceNo] = priceL;
   workSto[i][_re+instanceNo] = priceR;
   workSto[i][_ma+instanceNo] = priceH;
   workSto[i][_mi+instanceNo] = priceL;
   for(int k=1; k<period && (i-k)>=0; k++)
     {
      workSto[i][_mi+instanceNo] = MathMin(workSto[i][_mi+instanceNo],workSto[i-k][instanceNo+_lo]);
      workSto[i][_ma+instanceNo] = MathMax(workSto[i][_ma+instanceNo],workSto[i-k][instanceNo+_hi]);
     }
   double sumlow  = 0.0;
   double sumhigh = 0.0;
   for(int k=0; k<slowing && (i-k)>=0; k++)
     {
      sumlow  += workSto[i-k][_re+instanceNo]-workSto[i-k][_mi+instanceNo];
      sumhigh += workSto[i-k][_ma+instanceNo]-workSto[i-k][_mi+instanceNo];
     }
   if(sumhigh!=0.0)
      return(100.0*sumlow/sumhigh);
   else  return(0);
  }

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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//
//
//
   int buffer=instanceNo*_t3InstancesSize; for(int k=0; k<6; k++) workT3[r][k+buffer]=(r>0) ? workT3[r-1][k+buffer]: price;
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
//
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
