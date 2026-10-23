//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_label1  "Linear regression"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrLimeGreen,clrOrange
#property indicator_width1  2
#property indicator_label2  "Linear regression channel up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Linear regression line"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDimGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Linear regression channel down"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDarkOrange
#property indicator_style4  STYLE_DOT
//
//--- input parameters
//
input int                inpLrPeriod           = 30;          // Linear regression period
input ENUM_APPLIED_PRICE inpPrice              = PRICE_CLOSE; // Price
input int                inpProjectionLength   = 50;          // Projection length
input double             inpChannelMultiplier  = 1.0;         // Stadard error channel width
//
//---
//
double  val[],valc[],chanup[],chanmi[],chandn[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,chanup,INDICATOR_DATA);
   SetIndexBuffer(3,chanmi,INDICATOR_DATA);
   SetIndexBuffer(4,chandn,INDICATOR_DATA);
   PlotIndexSetInteger(1,PLOT_SHIFT,inpProjectionLength);
   PlotIndexSetInteger(3,PLOT_SHIFT,inpProjectionLength);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Linear regression ("+(string)inpLrPeriod+")");
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
   double _lrslope,_lrerror;
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      val[i]    = iLrValue(getPrice(inpPrice,open,close,high,low,i,rates_total),inpLrPeriod,_lrslope,_lrerror,i,rates_total);
      valc[i]   = (_lrslope > 0) ? 1 : (_lrslope<0) ? 2 : (i>0) ? valc[i-1] : 0;
      chandn[i] = EMPTY_VALUE;
      chanmi[i] = EMPTY_VALUE;
      chanup[i] = EMPTY_VALUE;
      if(i==rates_total-1)
        {
         for(int k=0; k<inpLrPeriod; k++) chanmi[rates_total-k-1] = val[rates_total-1]-_lrslope*k;
         for(int k=inpLrPeriod+inpProjectionLength; k>=0; k--)
           {
            chanup[rates_total-k-1] = val[rates_total-1]-_lrslope*(k-inpProjectionLength)+inpChannelMultiplier*_lrerror;
            chandn[rates_total-k-1] = val[rates_total-1]-_lrslope*(k-inpProjectionLength)-inpChannelMultiplier*_lrerror;
           }
        }

     }
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,rates_total-inpProjectionLength-inpLrPeriod);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,rates_total-inpLrPeriod);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,rates_total-inpProjectionLength-inpLrPeriod);
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workLr[];
//
//---
//
double iLrValue(double value,int period,double &slope,double &error,int r,int bars)
  {
   if(ArraySize(workLr)!=bars) ArrayResize(workLr,bars); workLr[r]=value;
   if(r<period || period<2) return(value);

//
//---
//

   double sumx=0,sumxx=0,sumxy=0,sumy=0,sumyy=0;
   for(int k=0; k<period; k++)
     {
      double price=workLr[r-k];
      sumx  += k;
      sumxx += k*k;
      sumxy += k*price;
      sumy  +=   price;
      sumyy +=   price*price;
     }
   slope = (period*sumxy-sumx*sumy)/(sumx*sumx-period*sumxx);
   error = MathSqrt((period*sumyy-sumy*sumy-slope*slope*(period*sumxx-sumx*sumx))/(period*(period-2)));

//
//---
//

   return((sumy + slope*sumx)/period);
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
