//------------------------------------------------------------------
#property copyright   "Copyright 2018, mladen"
#property link        "mladenfx@gmail.com"
#property description "Schaff trend cycle - non lag MA"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   1
#property indicator_label1  "Schaff trend cycle - NLMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrLimeGreen,clrOrange
#property indicator_width1  2
// input parameters
input int                 SchaffPeriod = 32;          // Schaff period
input int                 FastNlma     = 23;          // Fast nonlag ma period
input int                 SlowNlma     = 50;          // Slow nonlag ma period
input double              SmoothPeriod = 3;           // Smoothing period
input ENUM_APPLIED_PRICE  Price        = PRICE_CLOSE; // Price

double  val[],valc[],macd[],fastk1[],fastd1[],fastk2[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,macd,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,fastk1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,fastk2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,fastd1,INDICATOR_CALCULATIONS);
   IndicatorSetString(INDICATOR_SHORTNAME,"Schaff trend cycle NLMA ("+(string)SchaffPeriod+","+(string)FastNlma+","+(string)SlowNlma+","+(string)SmoothPeriod+")");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tickVolume[],
                const long &volume[],
                const int &spread[])
{

   if (Bars(_Symbol,_Period)<rates_total) return(-1);
//
//
//
   double alpha=2.0/(1.0+SmoothPeriod);
   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
   {
      double price=getPrice(Price,open,close,high,low,i,rates_total);
      macd[i]=iNonLagMa(price,FastNlma,i,rates_total,0)-iNonLagMa(price,SlowNlma,i,rates_total,1);
      int    start    = MathMax(i-SchaffPeriod+1,0);
      double lowMacd  = macd[ArrayMinimum(macd,start,SchaffPeriod)];
      double highMacd = macd[ArrayMaximum(macd,start,SchaffPeriod)]-lowMacd;
      fastk1[i] = (highMacd > 0) ? 100*((macd[i]-lowMacd)/highMacd) : (i>0) ? fastk1[i-1] : 0;
      fastd1[i] = (i>0) ? fastd1[i-1]+alpha*(fastk1[i]-fastd1[i-1]) : fastk1[i];
      double lowStoch  = fastd1[ArrayMinimum(fastd1,start,SchaffPeriod)];
      double highStoch = fastd1[ArrayMaximum(fastd1,start,SchaffPeriod)]-lowStoch;
      fastk2[i] = (highStoch > 0) ? 100*((fastd1[i]-lowStoch)/highStoch) : (i>0) ? fastk2[i-1] : 0;
      val[i]    = (i>0) ?  val[i-1]+alpha*(fastk2[i]-val[i-1]) : fastk2[i];
      valc[i]   = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : 0 : 0;
     }
   return(i);
  }
//------------------------------------------------------------------
// custom functions
//------------------------------------------------------------------
#define _maInstances 2
#define _maWorkBufferx1 _maInstances
#define _length  0
#define _len     1
#define _weight  2

double  nlmvalues[ ][3];
double  nlmprices[ ][_maWorkBufferx1];
double  nlmalphas[ ][_maWorkBufferx1];

//
//
//
//
//

double iNonLagMa(double price, double length, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(nlmprices,0) != bars)         ArrayResize(nlmprices,bars);
   if (ArrayRange(nlmvalues,0) <  instanceNo+1) ArrayResize(nlmvalues,instanceNo+1);
                               nlmprices[r][instanceNo]=price;
   if (length<5 || r<3) return(nlmprices[r][instanceNo]);
   
   //
   //
   //
   //
   //
   
   if (nlmvalues[instanceNo][_length] != length)
   {
      double Cycle = 4.0;
      double Coeff = 3.0*M_PI;
      int    Phase = (int)(length-1);
      
         nlmvalues[instanceNo][_length] =       length;
         nlmvalues[instanceNo][_len   ] = (int)(length*4) + Phase;  
         nlmvalues[instanceNo][_weight] = 0;

         if (ArrayRange(nlmalphas,0) < (int)nlmvalues[instanceNo][_len]) ArrayResize(nlmalphas,(int)nlmvalues[instanceNo][_len]);
         for (int k=0; k<(int)nlmvalues[instanceNo][_len]; k++)
         {
            double t;
            if (k<=Phase-1) 
                  t = 1.0 * k/(Phase-1);
            else  t = 1.0 + (k-Phase+1)*(2.0*Cycle-1.0)/(Cycle*length-1.0); 
            double beta = MathCos(M_PI*t);
            double g = 1.0/(Coeff*t+1); if (t <= 0.5 ) g = 1;
      
            nlmalphas[k][instanceNo]        = g * beta;
            nlmvalues[instanceNo][_weight] += nlmalphas[k][instanceNo];
         }
   }
   
   //
   //
   //
   //
   //
   
   if (nlmvalues[instanceNo][_weight]>0)
   {
      double sum = 0;
           for (int k=0; k < (int)nlmvalues[instanceNo][_len] && (r-k)>=0; k++) sum += nlmalphas[k][instanceNo]*nlmprices[r-k][instanceNo];
           return( sum / nlmvalues[instanceNo][_weight]);
   }
   else return(0);           
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
