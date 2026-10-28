//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "Hull high"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width1  2
#property indicator_label2  "Hull close"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width2  2
#property indicator_label3  "Hull low"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width3  2
//--- input parameters
input double inpHullPeriod=27;  // Hull period
//--- indicator buffers
double hullu[],hulluc[],hullc[],hullcc[],hulld[],hulldc[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,hullu,INDICATOR_DATA);
   SetIndexBuffer(1,hulluc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,hullc,INDICATOR_DATA);
   SetIndexBuffer(3,hullcc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,hulld,INDICATOR_DATA);
   SetIndexBuffer(5,hulldc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Triple Hull ("+(string)inpHullPeriod+")");
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
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      hullu[i] = iHull(high[i],inpHullPeriod,i,rates_total,0);
      hullc[i] = iHull(close[i],inpHullPeriod,i,rates_total,1);
      hulld[i] = iHull(low[i],inpHullPeriod,i,rates_total,2);
      hulluc[i] = (i>0) ? (hullu[i]>hullu[i-1]) ? 2 : (hullu[i]<hullu[i-1]) ? 1 : hulluc[i-1] : 0;
      hullcc[i] = (i>0) ? (hullc[i]>hullc[i-1]) ? 2 : (hullc[i]<hullc[i-1]) ? 1 : hullcc[i-1] : 0;
      hulldc[i] = (i>0) ? (hulld[i]>hulld[i-1]) ? 2 : (hulld[i]<hulld[i-1]) ? 1 : hulldc[i-1] : 0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double workHull[][6];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iHull(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workHull,0)!=bars) ArrayResize(workHull,bars);
   instanceNo*=2; workHull[r][instanceNo]=price;
   if(period<=1) return(price);
//
//---
//
   int HmaPeriod  = (int)MathMax(period,2);
   int HalfPeriod = (int)MathFloor(HmaPeriod/2);
   int HullPeriod = (int)MathFloor(MathSqrt(HmaPeriod));
   double hma,hmw,weight;
   hmw=HalfPeriod; hma=hmw*price;
   for(int k=1; k<HalfPeriod && (r-k)>=0; k++)
     {
      weight = HalfPeriod-k;
      hmw   += weight;
      hma   += weight*workHull[r-k][instanceNo];
     }
   workHull[r][instanceNo+1]=2.0*hma/hmw;
   hmw=HmaPeriod; hma=hmw*price;
   for(int k=1; k<period && (r-k)>=0; k++)
     {
      weight = HmaPeriod-k;
      hmw   += weight;
      hma   += weight*workHull[r-k][instanceNo];
     }
   workHull[r][instanceNo+1]-=hma/hmw;
   hmw=HullPeriod; hma=hmw*workHull[r][instanceNo+1];
   for(int k=1; k<HullPeriod && (r-k)>=0; k++)
     {
      weight = HullPeriod-k;
      hmw   += weight;
      hma   += weight*workHull[r-k][1+instanceNo];
     }
   return(hma/hmw);
  }
//+------------------------------------------------------------------+
