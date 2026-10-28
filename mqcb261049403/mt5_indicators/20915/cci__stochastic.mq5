//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3
#property indicator_label1  "up level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "down level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_DOT
#property indicator_label3  "value"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrLimeGreen,clrOrange
#property indicator_width3  2
//
//---
//
input int                inpCciPeriod       = 32;            // CCI period
input ENUM_APPLIED_PRICE inpCciPrice        = PRICE_TYPICAL; // Price
input int                inpStoPeriod       = 32;            // Stochastic period
input int                inpStoSlowing      = 9;             // Stochastic slowing period
input double             inpLevelUp         = 80;            // Level up
input double             inpLevelDown       = 20;            // Level down
                                                             //
//---
//
double  val[],valc[],levelUp[],levelDn[],prices[],cci[],sto[];
//------------------------------------------------------------------
//
//------------------------------------------------------------------
void OnInit()
  {
   SetIndexBuffer(0,levelUp,INDICATOR_DATA);
   SetIndexBuffer(1,levelDn,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,prices,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,cci,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,sto,INDICATOR_CALCULATIONS);
   for(int i=0; i<2; i++) PlotIndexSetInteger(i,PLOT_SHOW_DATA,false);
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI - Stochastic ("+(string)inpCciPeriod+","+(string)inpStoPeriod+")");
  }
//------------------------------------------------------------------
//
//------------------------------------------------------------------
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
      prices[i]  = getPrice(inpCciPrice,open,close,high,low,i,rates_total);
      double avg = 0; for(int k=0; k<inpCciPeriod && (i-k)>=0; k++) avg +=         prices[i-k];      avg /= inpCciPeriod;
      double dev = 0; for(int k=0; k<inpCciPeriod && (i-k)>=0; k++) dev += MathAbs(prices[i-k]-avg); dev /= inpCciPeriod;

      //
      //---
      //

      cci[i]=(dev!=0) ?(prices[i]-avg)/(0.015*dev) : 0;
      int _start= MathMax(i-inpStoPeriod+1,0);
      double hh = cci[ArrayMaximum(cci,_start,inpStoPeriod)];
      double ll = cci[ArrayMinimum(cci,_start,inpStoPeriod)];
      sto[i]     = (hh!=ll) ? 100*(cci[i]-ll)/(hh-ll) : 0;
      val[i]     = 0; for(int k=0; k<inpStoSlowing && (i-k)>=0; k++) val[i] += sto[i-k];  val[i] /= inpStoSlowing;
      levelUp[i] = inpLevelUp;
      levelDn[i] = inpLevelDown;
      valc[i]    = (val[i]>levelUp[i]) ? 1 : (val[i]<levelDn[i]) ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1]: 0 : 0;
     }
   return(i);
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
