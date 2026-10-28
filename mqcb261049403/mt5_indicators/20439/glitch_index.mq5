//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Glitch index"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_label1  "Histogram"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDarkGray,clrLimeGreen,clrGreen,clrFireBrick,clrOrangeRed
#property indicator_width1  2
#property indicator_label2  "Glitch index value"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrLimeGreen,clrGreen,clrFireBrick,clrOrangeRed
#property indicator_width2  2
//--- input parameters
input int                inpSmaPeriod    = 30;          // Average period
input double             inpLevel1       = 2;           // Level 1
input double             inpLevel2       = 5;           // Level 2
//--- buffers declarations
double histo[],histoc[],val[],valc[],sma[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,histo,INDICATOR_DATA);
   SetIndexBuffer(1,histoc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,sma,INDICATOR_CALCULATIONS);
//
// levels
//
   IndicatorSetInteger(INDICATOR_LEVELS,5);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,inpLevel2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,inpLevel1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,-inpLevel1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,4,-inpLevel2);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Glitch index ("+(string)inpSmaPeriod+")");
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
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      sma[i]=iSma(close[i],inpSmaPeriod,i,rates_total);
      double rocSma = (i>0) ? ((sma[i]-sma[i-1])*0.1)+1.0 : 0;
      double smaMul = sma[i]*rocSma;
      double diff   = close[i]-smaMul;

      //
      //---
      //

      val[i]=(diff/close[i])*100.0;
      while(true)
        {
         if(val[i] >  inpLevel2) { valc[i] = 1; break; }
         if(val[i] >  inpLevel1) { valc[i] = 2; break; }
         if(val[i] < -inpLevel2) { valc[i] = 4; break; }
         if(val[i] < -inpLevel1) { valc[i] = 3; break; }
         valc[i]= 0; break;
        }
      histo[i]=val[i];
      histoc[i]=valc[i];
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
//+------------------------------------------------------------------+
