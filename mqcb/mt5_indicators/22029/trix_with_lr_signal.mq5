//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Trix with linear regression signal line"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "Trix signal"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDodgerBlue,clrSandyBrown
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Trix"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDodgerBlue,clrSandyBrown
#property indicator_width2  2
//--- input parameters
input int                inpTrixPeriod = 8;            // Trix period
input ENUM_APPLIED_PRICE inpTrixPrice  = PRICE_CLOSE;  // Price
input int                inpSignPeriod = 14;           // Signal period
//--- buffers declarations
double val[],valc[],signal[],signalc[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,signal,INDICATOR_DATA);
   SetIndexBuffer(1,signalc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"TRIX with LR ("+(string)inpTrixPeriod+","+(string)inpSignPeriod+")");
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
double workTrix[][3];
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
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   if (ArrayRange(workTrix,0)!=rates_total) ArrayResize(workTrix,rates_total);

   //
   //---
   //
   
   double alpha = 2.0/(1.0+inpTrixPeriod);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double price = MathLog(getPrice(inpTrixPrice,open,close,high,low,i,rates_total));
            workTrix[i][0] = (i>0) ? workTrix[i-1][0]+alpha*(price         -workTrix[i-1][0]) : 0;
            workTrix[i][1] = (i>0) ? workTrix[i-1][1]+alpha*(workTrix[i][0]-workTrix[i-1][1]) : 0;
            workTrix[i][2] = (i>0) ? workTrix[i-1][2]+alpha*(workTrix[i][1]-workTrix[i-1][2]) : 0;
         
            val[i]     = (i>0) ? (workTrix[i-1][2]!=0) ? (workTrix[i][2]-workTrix[i-1][2])/workTrix[i-1][2] : 0 : 0;
            signal[i]  = iLinr(val[i],inpSignPeriod,i,rates_total);
            valc[i]    = (val[i]>signal[i]) ? 1 :(val[i]<signal[i]) ? 2 : (i>0) ? valc[i-1]: 0;
            signalc[i] = valc[i];
     }
   return (i);
  }

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workLinr[][1];
//
//---
//
double iLinr(double price, double period, int r, int bars, int instanceNo=0)
{
   if (ArraySize(workLinr)!= bars) ArrayResize(workLinr,bars);

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      workLinr[r][instanceNo] = price;
         double lwmw = period; double lwma = lwmw*price;
         double sma  = price;
         for(int k=1; k<period && (r-k)>=0; k++)
         {
            double weight = period-k;
                   lwmw  += weight;
                   lwma  += weight*workLinr[r-k][instanceNo];  
                   sma   +=        workLinr[r-k][instanceNo];
         }             
   
   return(3.0*lwma/lwmw-2.0*sma/period);
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
