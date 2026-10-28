//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://forge.mql5.io"
#property description "Relative Momentum Index (RMI)"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrSkyBlue,clrSandyBrown
#property indicator_width1  2
#property indicator_level1  10
#property indicator_level2  30
#property indicator_level3  70
#property indicator_level4  90

//--- input parameters
input int                inpRmiPeriod = 14;          // Relative momentum index period
input int                inpMomPeriod = 5;           // Momentum period
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE; // Price 

//--- buffers and global variables declarations
double val[],valc[],pbuffer[],nbuffer[],prices[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,prices,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,pbuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,nbuffer,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Relative momentum index ("+(string)inpRmiPeriod+","+(string)inpMomPeriod+")");
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
      prices[i]=getPrice(inpPrice,open,close,high,low,i,rates_total);
      double sumn=0;
      double sump=0;
      double rel =0;
      if(i<inpRmiPeriod+inpMomPeriod)
        {
         for(int k=0; k<inpRmiPeriod && (i-k-inpMomPeriod)>=0; k++)
           {
            rel=prices[i-k]-prices[i-k-inpMomPeriod];
            if(rel>0)
               sump+=rel;
            else  sumn-=rel;
           }
         pbuffer[i] = sump/inpRmiPeriod;
         nbuffer[i] = sumn/inpRmiPeriod;
        }
      else
        {
         rel=prices[i]-prices[i-inpMomPeriod];
         if(rel>0)
            sump = rel;
         else  sumn = -rel;
         pbuffer[i]=(pbuffer[i-1]*(inpRmiPeriod-1)+sump)/inpRmiPeriod;
         nbuffer[i]=(nbuffer[i-1]*(inpRmiPeriod-1)+sumn)/inpRmiPeriod;
        }
      val[i]=(nbuffer[i]+pbuffer[i]==0.0) ? 0 : 100.0*pbuffer[i]/(pbuffer[i]+nbuffer[i]);
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
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
