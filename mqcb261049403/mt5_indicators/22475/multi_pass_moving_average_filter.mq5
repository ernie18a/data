//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#define   _maxPass  5
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_label1  "Multi pass moving average filter"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_width1  6
#property indicator_label2  "Multi pass moving average filter"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrLimeGreen,clrDarkOrange
#property indicator_width2  2
//
//--- input parameters
//
input int                inpPeriod     = 10;          // MP average period
input int                inpFilterPass = 1;           // Filter pass
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price
//
//--- indicator buffers
//
double val[],valc[],vals[];
int _pass;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
{
//--- indicator buffers mapping
   SetIndexBuffer(0,vals,INDICATOR_DATA);
   SetIndexBuffer(1,val,INDICATOR_DATA);
   SetIndexBuffer(2,valc,INDICATOR_COLOR_INDEX);
      _pass = MathMax(MathMin(inpFilterPass,_maxPass),1);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Multi pass moving average filter ("+(string)inpPeriod+","+(string)_pass+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      val[i]  = iMpFilter(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,_pass,i,rates_total);
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
      vals[i] = val[i];
     }
   return(i);
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double _filter[][_maxPass+1];
//
//---
//
double iMpFilter(double price, int period, int passes, int i, int bars, int instance=0)
{
   if (ArrayRange(_filter,0) != bars) ArrayResize(_filter,bars);

   
   //
   //--
   //
   
      double ma = 0;
      for (int p=0; p<passes; p++)
      {
         if (p==0) _filter[i][0] = price;
         if (i>=period)
                  ma = _filter[i-1][p+1]+(_filter[i][p]-_filter[i-period][p])/(double)period;
         else {   ma = _filter[i][p]; int k=1; for (; k<period && (i-k)>=0; k++) ma += _filter[i-k][p];
                                                                                 ma /= (double)k; }                                                                            
         _filter[i][p+1] = ma;
      }
   return(ma);
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
