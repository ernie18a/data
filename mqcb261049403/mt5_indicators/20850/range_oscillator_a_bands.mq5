//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Range oscillator with bands"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_label1  "Band up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Average range oscillator"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Band down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSandyBrown
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Range oscillator"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrDodgerBlue,clrSandyBrown
#property indicator_width4  2
//--- input parameters
input int     inpRngPeriod       = 40;  // Range oscillator period
input int     inpBandsPeriod     = 20;  // Bands period 
input double  inpBandsDeviations = 2.0; // Bands deviation
//--- buffers declarations
double val[],valc[],bandu[],bandm[],bandd[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,bandu,INDICATOR_DATA);
   SetIndexBuffer(1,bandm,INDICATOR_DATA);
   SetIndexBuffer(2,bandd,INDICATOR_DATA);
   SetIndexBuffer(3,val,INDICATOR_DATA);
   SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Range oscillator + bands ("+(string)inpRngPeriod+","+(string)inpBandsPeriod+")");
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
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      int    _start = MathMax(i-inpRngPeriod+1,0);
      double _max   = high[ArrayMaximum(high,_start,inpRngPeriod)];
      double _min   = low [ArrayMinimum(low ,_start,inpRngPeriod)];
      double _med   = (high[i]+low[i])/2;
      val[i]   = (_max!=_min) ? 100*(_med-_min)/(_max-_min) : 0;
      bandm[i] = iSma(val[i],inpBandsPeriod,i,rates_total);
      double _dev=iDeviation(val[i],inpBandsPeriod,i,rates_total);
      bandu[i] = bandm[i]+inpBandsDeviations*_dev;
      bandd[i] = bandm[i]-inpBandsDeviations*_dev;
      valc[i]=(val[i]>bandu[i]) ? 1 :(val[i]<bandd[i]) ? 2 : 0;
     }
   return (i);
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
