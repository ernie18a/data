//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Discontinued signal line ema synthetic momentum"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   4
#property indicator_label1  "no trend zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro
#property indicator_label2  "no trend zone up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_label2  "no trend zone down"
#property indicator_style2  STYLE_DOT
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Momentum"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrDodgerBlue,clrDeepPink
#property indicator_width4  2
//--- input parameters
input int                inpPeriod1  = 5;           // Period 1
input int                inpPeriod2  = 20;          // Period 2
input int                inpPeriod3  = 50;          // Period 3
input int                inpPeriod4  = 100;         // Period 4
input int                inpPeriod5  = 200;         // Period 5
input int                inpSignal   = 9;           // Signal period
input ENUM_APPLIED_PRICE inpPrice    = PRICE_CLOSE; // Price
//--- buffers and global variables declarations
double val[],valc[],dslup[],dsldn[],dslupl[],dsldnl[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,dslup,INDICATOR_DATA);
   SetIndexBuffer(1,dsldn,INDICATOR_DATA);
   SetIndexBuffer(2,dslupl,INDICATOR_DATA);
   SetIndexBuffer(3,dsldnl,INDICATOR_DATA);
   SetIndexBuffer(4,val,INDICATOR_DATA);
   SetIndexBuffer(5,valc,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"DSL Synthetic EMA momentum ("+(string)inpPeriod1+","+(string)inpPeriod2+","+(string)inpPeriod3+","+(string)inpPeriod4+","+(string)inpPeriod5+")");
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
   double _alpha=2.0/(1+inpSignal);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
   {
      double _price = getPrice(inpPrice,open,close,high,low,i);
      double _avg   = iEma(_price, inpPeriod1,i,0);
      double _avg1  = iEma(_price, inpPeriod2,i,1); double _mom1 = 100.*(_avg-_avg1)/_avg1;
      double _avg2  = iEma(_price, inpPeriod3,i,2); double _mom2 = 100.*(_avg-_avg2)/_avg2;
      double _avg3  = iEma(_price, inpPeriod4,i,3); double _mom3 = 100.*(_avg-_avg3)/_avg3;
      double _avg4  = iEma(_price, inpPeriod5,i,4); double _mom4 = 100.*(_avg-_avg4)/_avg4;
      val[i]  = (_mom4 +_mom3*inpPeriod5/inpPeriod4+_mom2*inpPeriod5/inpPeriod3+_mom1*inpPeriod5/inpPeriod2)/4.0;
      dslupl[i] = dslup[i] = (i>0) ? (val[i]>0) ? dslup[i-1]+_alpha*(val[i]-dslup[i-1]) : dslup[i-1] : 0;
      dsldnl[i] = dsldn[i] = (i>0) ? (val[i]<0) ? dsldn[i-1]+_alpha*(val[i]-dsldn[i-1]) : dsldn[i-1] : 0;
      valc[i] = (val[i]>dslup[i]) ? 1 :(val[i]<dsldn[i]) ? 2 : 0;
   }
   return (i);
}
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _emaInstances     5
#define _emaRingSize      5
double workEma[_emaRingSize][_emaInstances];
//
//
//
double iEma(double price, double period, int i, int _inst=0)
{
   int _indP = (i-1)%_emaRingSize;
   int _indC = (i  )%_emaRingSize;

   //
   //---
   //

   if (i>0 && period>1)
         workEma[_indC][_inst] = workEma[_indP][_inst]+(2.0/(1.0+period))*(price-workEma[_indP][_inst]);
   else  workEma[_indC][_inst] = price;
   return(workEma[_indC][_inst]);
}    
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i)
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
