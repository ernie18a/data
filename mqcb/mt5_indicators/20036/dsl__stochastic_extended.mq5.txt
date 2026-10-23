//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
#property strict
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
#property indicator_label3  "value"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrSilver,clrLimeGreen,clrOrange
#property indicator_width3  2
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };
//----------------
enum enStochPrice
  {
   sto_htl, // High/low
   sto_ctc  // Close/close
  };
input int          inpStoPeriod       = 32;      // Stochastic period
input int          inpStoSlowing      = 9;       // Stochastic slowing period
input enMaTypes    inpStoMaType       = ma_sma;  // Stochastic average type      
input int          inpSigPeriod       = 9;       // Stochastic signal period
input enStochPrice inpStoPrice        = sto_htl; // Price :
double  val[],valc[],levelUp[],levelDn[];
string _avgNames[]={"SMA","EMA","SMMA","LWMA"};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
  {
   SetIndexBuffer(0,levelUp,INDICATOR_DATA);
   SetIndexBuffer(1,levelDn,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
   for(int i=0; i<2; i++) PlotIndexSetInteger(i,PLOT_SHOW_DATA,false);
   IndicatorSetString(INDICATOR_SHORTNAME,"(dsl) Stochastic ("+_avgNames[inpStoMaType]+")("+(string)inpStoPeriod+","+(string)inpSigPeriod+")");
  }
//+------------------------------------------------------------------+
//|                                                                  |
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

   double alpha=2.0/(1.0+inpSigPeriod);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      int _start=(int)MathMax(i-inpStoPeriod+1,0);
      double _lo     = (inpStoPrice==sto_htl) ? low[ ArrayMinimum(low ,_start,inpStoPeriod)] : close[ArrayMinimum(close,_start,inpStoPeriod)];
      double _hi     = (inpStoPrice==sto_htl) ? high[ArrayMaximum(high,_start,inpStoPeriod)] : close[ArrayMaximum(close,_start,inpStoPeriod)];
      double sumlow  = iCustomMa(inpStoMaType,close[i]-_lo,inpStoSlowing,i,rates_total,0);
      double sumhigh = iCustomMa(inpStoMaType,_hi     -_lo,inpStoSlowing,i,rates_total,1);
      //
      //---------------------
      //
      val[i]     = (sumhigh!=sumlow) ? 100*sumlow/sumhigh : 100;
      levelUp[i] = (i>0) ? (val[i]>50) ? levelUp[i-1]+alpha*(val[i]-levelUp[i-1]) : levelUp[i-1] : 0;
      levelDn[i] = (i>0) ? (val[i]<50) ? levelDn[i-1]+alpha*(val[i]-levelDn[i-1]) : levelDn[i-1] : 0;
      valc[i]    = (val[i]>levelUp[i]) ? 1 : (val[i]<levelDn[i]) ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1]: 0 : 0;
     }
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _maInstances 2
#define _maWorkBufferx1 1*_maInstances
double workSma[][_maWorkBufferx1];
double workEma[][_maWorkBufferx1];
double workSmma[][_maWorkBufferx1];
double workLwma[][_maWorkBufferx1];
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSma(double price,int period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo]=price;
   double avg=price; int k=1; for(; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo];
   return(avg/(double)k);
  }
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
