//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Mogalef bands"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
#property indicator_label1  "Level up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrForestGreen
#property indicator_label2  "Middle level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Level down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrCrimson
//--- input parameters
input int                inpPeriod           = 3;           // Period
input ENUM_APPLIED_PRICE inpPrice            = PRICE_CLOSE; // Price
input int                inpDeviationsPeriod = 7;           // Deviations period
//--- indicator buffers
double levup[],levmi[],levdn[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,levup,INDICATOR_DATA);
   SetIndexBuffer(1,levmi,INDICATOR_DATA);
   SetIndexBuffer(2,levdn,INDICATOR_DATA);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Mogalef bands ("+(string)inpPeriod+")");
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
   
   //
   //---
   //

      for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !_StopFlag; i++)
      {
         double linreg    = iLinr(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,i,rates_total);
         double deviation = iDeviation(linreg,inpDeviationsPeriod,i,rates_total);
         if (i==0)
         {
            levup[i] = linreg;
            levdn[i] = linreg;
            levmi[i] = linreg;
            continue;
         }         
         
         //
         //---
         //
         
         levup[i] = levup[i-1];
         levdn[i] = levdn[i-1];
         levmi[i] = levmi[i-1];
         if (linreg>levup[i-1] || linreg<levdn[i-1])
         {
            levup[i] = linreg+2.0*deviation;
            levdn[i] = linreg-2.0*deviation;
            levmi[i] = linreg;
         }
      }
   return(rates_total);
  }
  
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workDev[][1];
//
//---
//
double iDeviation(double value,int length,int i,int bars, int instanceNo=0,bool isSample=false)
  {
   if(ArrayRange(workDev,0)!=bars) ArrayResize(workDev,bars);  workDev[i][instanceNo]=value; if (i<length) return(0);
   
   //
   //---
   //
   
   double sumx=0,sumxx=0; 
      for(int k=0; k<length && (i-k)>=0; sumx+=workDev[i-k][instanceNo],sumxx+=workDev[i-k][instanceNo]*workDev[i-k][instanceNo],k++) {}
   return(MathSqrt((sumxx-sumx*sumx/(double)length)/MathMax(length-isSample,1)));
  }
//
//---
//  
double workLinr[][1];
double iLinr(double price, int period, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(workLinr,0)!= bars) ArrayResize(workLinr,bars);

   //
   //---
   //
   
      period = MathMax(period,1);
      workLinr[r][instanceNo] = price;
         if (r<period) return(price);
         double lwmw = period; double lwma = lwmw*price;
         double sma  = price;
         for(int k=1; k<period && (r-k)>=0; k++)
         {
            double weight = period-k;
                   lwmw  += weight;
                   lwma  += weight*workLinr[r-k][instanceNo];  
                   sma   +=        workLinr[r-k][instanceNo];
         }             
   
   return(3.0*lwma/lwmw-2.0*sma/(double)period);
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