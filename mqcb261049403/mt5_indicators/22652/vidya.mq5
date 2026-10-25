//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Vidya"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   2
#property indicator_label1  "Shadow"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_width1  6
#property indicator_label2  "Vidya"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width2  2
//--- input parameters
input int                inpPeriod  = 12;          // Vidya period
input int                inpPeriod2 =  0;          // Momentum period (<=1 for same as Vidya period
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE; // Price
//--- indicator buffers
double val[],valc[],vals[],cmo1[],cmo2[],cmo3[],cmo4[];
double _alpha; int _adpPeriod;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,vals,INDICATOR_DATA);
   SetIndexBuffer(1,val ,INDICATOR_DATA);
   SetIndexBuffer(2,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,cmo1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,cmo2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,cmo3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,cmo4,INDICATOR_CALCULATIONS);
      _alpha = 2.0/(1.0+inpPeriod);   
      _adpPeriod  = (inpPeriod2<=1 ? inpPeriod : inpPeriod2);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Vidya ("+(string)inpPeriod+")");
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
   int i = (prev_calculated>0 ? prev_calculated-1 : 0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _price = getPrice(inpPrice,open,close,high,low,i);
      double _cmo   = iCmo(_adpPeriod,close,cmo1,cmo2,cmo3,cmo4,i);
         if (_cmo<0) _cmo = -_cmo;
            val[i]  = (i>0) ? val[i-1]+(_alpha*_cmo)*(_price-val[i-1]) : _price;
            valc[i] = (i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
            vals[i] = val[i];
   }
   return(i);
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
//
//---
//
template<typename T>
double iCmo(int period, T& price[], double& diffu[], double& diffd[], double& cumu[], double& cumd[], int i)
{
   double diff = (i>0?price[i]-price[i-1]:0);
   if (diff>0) 
         { diffu[i] =  diff; diffd[i] = 0; }
   else  { diffd[i] = -diff; diffu[i] = 0; }
   if (i<period)
   {
      cumu[i] = cumd[i] = 0; 
      for(int k=0; k<period && (i-k)>=0; k++) 
      { 
         cumu[i] += diffu[i-k]; 
         cumd[i] += diffd[i-k]; 
      }
   }
   else  
   { 
      cumu[i] = cumu[i-1]-diffu[i-period]+diffu[i];
      cumd[i] = cumd[i-1]-diffd[i-period]+diffd[i];
   }
   return((cumu[i]+cumd[i])!=0 ? (cumu[i]-cumd[i])/(cumu[i]+cumd[i]) : 0);   
}
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i)
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
