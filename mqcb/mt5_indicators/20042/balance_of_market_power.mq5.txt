//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "up level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "down level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_DOT
#property indicator_label3  "BOP value"
#property indicator_type3   DRAW_COLOR_HISTOGRAM
#property indicator_color3  clrSilver,clrLimeGreen,clrOrange
#property indicator_width3  2
//---
enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };
//--- input parameters  
input int       inpSmoothPeriod = 14;       // Result smoothing period
input enMaTypes inpSmoothMethod =  ma_sma;  // Result smoothing type
input double    inpLevelUp      =  0.2;     // Level up
input double    inpLevelDown    = -0.2;     // Level down
//--- buffers
double  val[],valc[],levelUp[],levelDn[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- indicator buffers mapping
   SetIndexBuffer(0,levelUp,INDICATOR_DATA);
   SetIndexBuffer(1,levelDn,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
//---
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
//---
   string _avgNames[]={"SMA","EMA","SMMA","LWMA"};
   IndicatorSetString(INDICATOR_SHORTNAME,"Balance of Market Power ("+_avgNames[inpSmoothMethod]+")("+(string)inpSmoothPeriod+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double HighLowRange=high[i]-low[i];
      double BullsRewardBasedOnOpen      = (HighLowRange!=0) ? (high[i] - open[i])/HighLowRange : 0;
      double BearsRewardBasedOnOpen      = (HighLowRange!=0) ? (open[i] - low[i])/HighLowRange : 0;
      double BullsRewardBasedOnClose     = (HighLowRange!=0) ? (close[i] - low[i])/HighLowRange : 0;
      double BearsRewardBasedOnClose     = (HighLowRange!=0) ? (high[i] - close[i])/HighLowRange : 0;
      double BullsRewardBasedOnOpenClose = (HighLowRange!=0) ? (close[i]>open[i]) ? (close[i] - open[i])/HighLowRange : 0 : 0;
      double BearsRewardBasedOnOpenClose = (HighLowRange!=0) ? (close[i]<open[i]) ? (open[i] - close[i])/HighLowRange : 0 : 0;
      double BullsRewardDaily            = (BullsRewardBasedOnOpen + BullsRewardBasedOnClose + BullsRewardBasedOnOpenClose) / 3;
      double BearsRewardDaily            = (BearsRewardBasedOnOpen + BearsRewardBasedOnClose + BearsRewardBasedOnOpenClose) / 3;
      //---
      val[i]     = iCustomMa(inpSmoothMethod,BullsRewardDaily-BearsRewardDaily,inpSmoothPeriod,i,rates_total);
      levelUp[i] = inpLevelUp;
      levelDn[i] = inpLevelDown;
      valc[i]    = (val[i]>levelUp[i]) ? 1 : (val[i]<levelDn[i]) ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1]: 0 : 0;
     }
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _maInstances 1
#define _maWorkBufferx1 1*_maInstances
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iCustomMa(int mode,double price,double length,int r,int bars,int instanceNo=0)
  {
   switch(mode)
     {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      default       : return(price);
     }
  }
double workSma[][_maWorkBufferx1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSma(double price,int period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars);
   workSma[r][instanceNo]=price;
   double avg=price; 
   int k=1; 
      for(; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo];
   return(avg/(double)k);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double workEma[][_maWorkBufferx1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iEma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=_bars) ArrayResize(workEma,_bars);
   workEma[r][instanceNo]=price;
   if(r>0 && period>1)
      workEma[r][instanceNo]=workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double workSmma[][_maWorkBufferx1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSmma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSmma,0)!=_bars) ArrayResize(workSmma,_bars);
   workSmma[r][instanceNo]=price;
   if(r>1 && period>1)
      workSmma[r][instanceNo]=workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double workLwma[][_maWorkBufferx1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iLwma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workLwma,0)!=_bars) ArrayResize(workLwma,_bars);

   workLwma[r][instanceNo] = price; if(period<1) return(price);
   double sumw = period;
   double sum  = period*price;
   for(int k=1; k<period && (r-k)>=0; k++)
     {
      double weight=period-k;
      sumw  += weight;
      sum   += weight*workLwma[r-k][instanceNo];
     }
   return(sum/sumw);
  }
//+------------------------------------------------------------------+
