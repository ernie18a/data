//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Volatility bands percent"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Volatility band percent"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDeepSkyBlue
#property indicator_width1  2
//
//--- input parameters
//
enum enDevType
  {
   use_classical, // Use classical deviations
   use_rooke      // Use David Rooke type of deviations
  };
input int                inpBandPeriod     = 20;             // Bands period period
input double             inpBandDeviations = 2;              // Bands deviations
input ENUM_APPLIED_PRICE inpPrice          = PRICE_CLOSE;    // Price
input enDevType          inpDeviationsType = use_rooke;      // Deviations type

                                                             //
//---
//
double  bandm[],percent[],prices[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,percent,INDICATOR_DATA);
   SetIndexBuffer(1,bandm,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,prices,INDICATOR_CALCULATIONS);
//---
   IndicatorSetInteger(INDICATOR_LEVELS,2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,100);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,  0);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Volatility bands percent ("+(string)inpBandPeriod+","+(string)inpBandDeviations+")");
//--- successful init
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   return;
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      prices[i]=getPrice(inpPrice,close,open,high,low,i,rates_total);
      double tema1 = iTema(prices[i],inpBandPeriod,i,rates_total,0);
      double tema2 = iTema(tema1    ,inpBandPeriod,i,rates_total,1);
      bandm[i]=2.0*tema1-tema2;
      double width=inpBandDeviations*iDeviationPlus(prices,bandm,inpBandPeriod,i);
      percent[i] = (width>0) ? 100.0*(prices[i]-bandm[i])/width : 0;
     }
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workTema[][6];
#define _tema1 0
#define _tema2 1
#define _tema3 2
//
//---
//
double iTema(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(period<=1) return(price);
   if(ArrayRange(workTema,0)!=bars) ArrayResize(workTema,bars); instanceNo*=3;
//
//---
//
   workTema[r][_tema1+instanceNo] = price;
   workTema[r][_tema2+instanceNo] = price;
   workTema[r][_tema3+instanceNo] = price;
   double alpha=2.0/(1.0+period);
   if(r>0)
     {
      workTema[r][_tema1+instanceNo] = workTema[r-1][_tema1+instanceNo]+alpha*(price                         -workTema[r-1][_tema1+instanceNo]);
      workTema[r][_tema2+instanceNo] = workTema[r-1][_tema2+instanceNo]+alpha*(workTema[r][_tema1+instanceNo]-workTema[r-1][_tema2+instanceNo]);
      workTema[r][_tema3+instanceNo]=workTema[r-1][_tema3+instanceNo]+alpha*(workTema[r][_tema2+instanceNo]-workTema[r-1][_tema3+instanceNo]); 
     }
   return(workTema[r][_tema3+instanceNo]+3.0*(workTema[r][_tema1+instanceNo]-workTema[r][_tema2+instanceNo]));
  }
//
//
//    In the original article the second method is how deviation is
//    calculated . It is a questionableble method , but if we apply
//    standard calculation the bands tend to be "spiky".That is the
//    reason to have the "UseClassicalDeviations" option
//
//
double iDeviationPlus(double &values[],double &ma[],int period,int i)
  {
   double sum=0;
   if(inpDeviationsType==use_classical)
      for(int k=0; k<period && (i-k)>=0; k++) sum += (values[i-k]-ma[i])  *(values[i-k]-ma[i]);
   else  for(int k=0; k<period && (i-k)>=0; k++) sum += (values[i-k]-ma[i-k])*(values[i-k]-ma[i-k]);
   return(MathSqrt(sum/period));
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
