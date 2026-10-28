//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_label1  "up level"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "mid level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_DOT
#property indicator_label2  "down level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrange
#property indicator_style3  STYLE_DOT
#property indicator_label4  "value"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrSilver,clrLimeGreen,clrOrange
#property indicator_width4  2

//
//
//
//
//

input int     inpWprPeriod=14; // WPR period
input int     inpBBPeriod     = 20;  // Bollinger bands period
input double  inpBBDeviations =  2;  // Bollinger bands deviations
double  val[],valc[],levelUp[],levelDn[],levelMi[];
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void OnInit()
  {
   SetIndexBuffer(0,levelUp,INDICATOR_DATA);
   SetIndexBuffer(1,levelMi,INDICATOR_DATA);
   SetIndexBuffer(2,levelDn,INDICATOR_DATA);
   SetIndexBuffer(3,val,INDICATOR_DATA);
   SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
   for(int i=0; i<3; i++) PlotIndexSetInteger(i,PLOT_SHOW_DATA,false);
   IndicatorSetString(INDICATOR_SHORTNAME,"WPR + Bollineg bands ("+(string)inpWprPeriod+","+(string)inpBBPeriod+","+(string)inpBBDeviations+")");
  }
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

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
      int _start=MathMax(i-inpWprPeriod+1,0);
      double _max = high[ArrayMaximum(high,_start,inpWprPeriod)];
      double _min = low[ArrayMinimum(low,_start,inpWprPeriod)];
      val[i]     = (_max!=_min) ? -(_max-close[i])*100/(_max-_min) : 0;
      levelMi[i] = iSma(val[i],inpBBPeriod,i,rates_total);
      double deviation=iDeviation(val[i],inpBBPeriod,i,rates_total);
      levelUp[i] = levelMi[i]+inpBBDeviations*deviation;
      levelDn[i] = levelMi[i]-inpBBDeviations*deviation;
      valc[i]    = (val[i]>levelUp[i]) ? 1 : (val[i]<levelDn[i]) ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1]: 0 : 0;
     }
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workSma[][1];
//
//---
//  
double iSma(double price,int period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo]=price;
   double avg=price; int k=1; for(; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo];
   return(avg/(double)k);
  }
//
//---
//  
double workDev[];
//
//---
//
double iDeviation(double value,int length,int i,int bars,bool isSample=false)
  {
   if(ArraySize(workDev)!=bars) ArrayResize(workDev,bars);  workDev[i]=value;
   double sumx=0,sumxx=0; for(int k=0; k<length && (i-k)>=0; sumx+=workDev[i-k],sumxx+=workDev[i-k]*workDev[i-k],k++) {}
   return(MathSqrt((sumxx-sumx*sumx/length)/MathMax(length-isSample,1)));
  }
//+------------------------------------------------------------------+
