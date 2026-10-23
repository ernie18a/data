//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   4
#property indicator_label1  "filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrYellowGreen,clrPaleVioletRed
#property indicator_label2  "up level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_DOT
#property indicator_label3  "down level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDeepPink
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Instantaneous trendline"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrSilver,clrMediumSeaGreen,clrDeepPink
#property indicator_width4  2
//---
enum enDisplayFill
{
   fill_display, // Display the filled zones
   fill_dont     // Don't display the filled zones
};
input double             inpPeriod  = 14;            // Period
input double             inpPeriodl =  9;            // Levels period (<=1 for same as trendline period)
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE;   // Price
input enDisplayFill      inpDisplay = fill_display;  // Filled zones display :
//
//---
//
double val[],valc[],levelUp[],levelDn[],fillu[],filld[];
double _levelsPeriod;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
   //---- indicator buffers mapping
   SetIndexBuffer(0,fillu,INDICATOR_DATA); 
   SetIndexBuffer(1,filld,INDICATOR_DATA); 
   SetIndexBuffer(2,levelUp,INDICATOR_DATA); 
   SetIndexBuffer(3,levelDn,INDICATOR_DATA);
   SetIndexBuffer(4,val,INDICATOR_DATA);
   SetIndexBuffer(5,valc,INDICATOR_COLOR_INDEX);
      PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
      //----
            _levelsPeriod = (inpPeriodl<=1 ? inpPeriod : inpPeriodl);
      //----
   IndicatorSetString(INDICATOR_SHORTNAME,"Instantaneous trendline levels ("+(string)inpPeriod+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
   {
      val[i] = iTl(getPrice(inpPrice,open,close,high,low,i),inpPeriod,i,0);
         double _levelUp = iTl(val[i],_levelsPeriod,i,1,(i>0 ? !(val[i]>levelDn[i-1]) : false));
         double _levelDn = iTl(val[i],_levelsPeriod,i,2,(i>0 ? !(val[i]<levelUp[i-1]) : false));
      levelUp[i] = MathMax(_levelUp,_levelDn);
      levelDn[i] = MathMin(_levelUp,_levelDn);
      valc[i]    = (val[i]>levelUp[i]) ? 1 : (val[i]<levelDn[i]) ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1]: 0 : 0;
      fillu[i]   = (inpDisplay==fill_dont) ? EMPTY_VALUE : val[i];
      filld[i]   = (inpDisplay==fill_dont) ? EMPTY_VALUE : (valc[i]==0) ? val[i] : (valc[i]==1) ? levelUp[i] : levelDn[i];
   }
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _itlInstances     3
#define _itlInstancesSize 3
#define _itlRingSize      8
double workItl[_itlRingSize][_itlInstances*_itlInstancesSize];
#define _smooth 1
#define _trend  2
//
//
//
double iTl(double price, double period, int i, int instance=0, bool copy=false)
{
   int _indC  = (i  ) % _itlRingSize;
   int _indP1 = (i-1) % _itlRingSize;
   int _inst  = instance*_itlInstancesSize;

   //
   //---
   //

      workItl[_indC][_inst] = price;
      if (!copy && i>2 && period>1)
      {
         int    _indP2 = (i-2) % _itlRingSize;
         int    _indP3 = (i-3) % _itlRingSize;
         double alpha  = 2.0/(1.0+period);
         workItl[_indC][_inst+_smooth] = (workItl[_indC][_inst]+2.0*workItl[_indP1][_inst]+2.0*workItl[_indP2][_inst]+workItl[_indP3][_inst])/6.0;
         workItl[_indC][_inst+_trend]  = (alpha-alpha*alpha/4)*workItl[_indC][_inst+_smooth]+ 0.5*alpha*alpha*workItl[_indP1][_inst+_smooth] - (alpha-0.75*alpha*alpha)*workItl[_indP2][_inst+_smooth] + 2*(1 - alpha)*workItl[_indP1][_inst+_trend] - (1-alpha)*(1-alpha)*workItl[_indP2][_inst+_trend];
      } 
      else 
      {
         workItl[_indC][_inst+_smooth] = (i>0) ? workItl[_indP1][_inst+_smooth] : price;
         workItl[_indC][_inst+_trend]  = (i>0) ? workItl[_indP1][_inst+_trend]  : price;
      }         
      return (workItl[_indC][_inst+_trend]);
   
   //
   //---
   //
   
   #undef _smooth
   #undef _trend
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