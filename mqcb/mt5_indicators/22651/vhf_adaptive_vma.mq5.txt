//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "VHF adaptive VMA"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_label1  "Shadow"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_width1  6
#property indicator_label2  "VMA"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width2  2
//--- input parameters
input int                inpPeriod  = 14;          // VMA period
input int                inpPeriod2 =  0;          // VHF period (<=1 for same as VMA period
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE; // Price
//--- indicator buffers
double val[],valc[],vals[],vhf1[],vhf2[];
double _alpha; int _adpPeriod;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
{
   //--- indicator buffers mapping
   SetIndexBuffer(0,vals    ,INDICATOR_DATA);
   SetIndexBuffer(1,val     ,INDICATOR_DATA);
   SetIndexBuffer(2,valc    ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,vhf1    ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,vhf2    ,INDICATOR_CALCULATIONS);
      _alpha     = 2.0/(1.0+inpPeriod);   
      _adpPeriod = (inpPeriod2<=1 ? inpPeriod : inpPeriod2);
   //--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"VMA ("+(string)inpPeriod+")");
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
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !_StopFlag; i++)
   {
      double _price = getPrice(inpPrice,open,close,high,low,i);
      double _vhf   = iVhf(_adpPeriod,close,vhf1,vhf2,i);
            val[i]  = (i>0) ? val[i-1]+(_alpha*_vhf*2.0)*(_price-val[i-1]) : _price;
            valc[i] = (i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
            vals[i] = val[i];
   }
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
//
//---
//
template<typename T>
double iVhf(int period, T& price[], double& diff[], double& noise[], int i)
{
      diff[i] = (i>0) ? (price[i]>price[i-1]) ? price[i]-price[i-1] : price[i-1]-price[i] : 0;
         if (i>=period)
                 noise[i] = noise[i-1]-diff[i-period]+diff[i];
         else  { noise[i] = 0; for(int k=0; k<period && (i-k)>=0; k++) noise[i] += diff[i-k]; }
   
         //
         //----
         //         
         
         int start = (i>=period) ? i-period+1 :0;
         double HCP = price[ArrayMaximum(price,start,period)];
         double LCP = price[ArrayMinimum(price,start,period)];

         return((noise[i]!=0) ? (HCP-LCP)/noise[i] : 0);
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
