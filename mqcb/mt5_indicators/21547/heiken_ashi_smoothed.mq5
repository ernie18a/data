//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Heiken ashi smoothed"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "HeikenAshi";
#property indicator_type1   DRAW_COLOR_CANDLES 
#property indicator_color1  clrSilver,clrLimeGreen,clrDarkOrange
//
//---
//
enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };
input int       inpMaPeriod      = 7;        // Smoothing period
input enMaTypes inpMaMetod       = ma_lwma;  // Smoothing method
input int       inpStep          = 0;        // Step size
input bool      inpBetterFormula = false;    // Use better formula
                                             //
//---
//
double hah[],hal[],hao[],hac[],haC[];
//------------------------------------------------------------------
//
//------------------------------------------------------------------
int OnInit()
  {
   SetIndexBuffer(0,hao,INDICATOR_DATA);
   SetIndexBuffer(1,hah,INDICATOR_DATA);
   SetIndexBuffer(2,hal,INDICATOR_DATA);
   SetIndexBuffer(3,hac,INDICATOR_DATA);
   SetIndexBuffer(4,haC,INDICATOR_COLOR_INDEX);
   return(INIT_SUCCEEDED);
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

//
//
//
//
//

   double _pointModifier=MathPow(10,SymbolInfoInteger(_Symbol,SYMBOL_DIGITS)%2);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double maOpen  = iCustomMa(inpMaMetod,open[i] ,inpMaPeriod,i,rates_total,0);
      double maClose = iCustomMa(inpMaMetod,close[i],inpMaPeriod,i,rates_total,1);
      double maLow   = iCustomMa(inpMaMetod,low[i]  ,inpMaPeriod,i,rates_total,2);
      double maHigh  = iCustomMa(inpMaMetod,high[i] ,inpMaPeriod,i,rates_total,3);

      double haClose = (inpBetterFormula) ? (maHigh!=maLow) ? (maOpen+maClose)/2+(((maClose-maOpen)/(maHigh-maLow))*MathAbs((maClose-maOpen)/2)) : (maOpen+maClose)/2 : (maOpen+maHigh+maLow+maClose)/4;
      double haOpen  = (i>0) ? (hao[i-1]+hac[i-1])/2 : open[i];
      double haHigh  = MathMax(maHigh, MathMax(haOpen,haClose));
      double haLow   = MathMin(maLow,  MathMin(haOpen,haClose));

      hal[i]=haLow;
      hah[i]=haHigh;
      hao[i]=haOpen;
      hac[i]=haClose;

      //
      //
      //
      //
      //

      if(i>0 && inpStep>0)
        {
         if(MathAbs(hah[i]-hah[i-1]) < inpStep*_pointModifier*_Point) hah[i]=hah[i-1];
         if(MathAbs(hal[i]-hal[i-1]) < inpStep*_pointModifier*_Point) hal[i]=hal[i-1];
         if(MathAbs(hao[i]-hao[i-1]) < inpStep*_pointModifier*_Point) hao[i]=hao[i-1];
         if(MathAbs(hac[i]-hac[i-1]) < inpStep*_pointModifier*_Point) hac[i]=hac[i-1];
        }
      haC[i]=(hao[i]>hac[i]) ? 2 :(hao[i]<hac[i]) ? 1 :(i>0) ? haC[i-1]: 0;
     }
   return(i);
  }

//------------------------------------------------------------------
// custom functions
//------------------------------------------------------------------
#define _maInstances 4
#define _maWorkBufferx1 1*_maInstances
//
//
//
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
//
//---
//
double workSma[][_maWorkBufferx1];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSma(double price,int period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo]=price;
   double avg=price; int k=1; for(; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo];  avg/=(double)k;
   return(avg);
  }
//
//---
//
double workEma[][_maWorkBufferx1];
//
//
//
double iEma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=_bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo]=price;
   if(r>0 && period>1)
      workEma[r][instanceNo]=workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
  }
//
//---
//
double workSmma[][_maWorkBufferx1];
//
//
//
double iSmma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSmma,0)!=_bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo]=price;
   if(r>1 && period>1)
      workSmma[r][instanceNo]=workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
  }
//
//---
//
double workLwma[][_maWorkBufferx1];
//
//
//
double iLwma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workLwma,0)!=_bars) ArrayResize(workLwma,_bars);

   workLwma[r][instanceNo] = price; if(period<1) return(price);
   double sumw = period;
   double sum  = period*price;

   for(int k=1; k<period && (r-k)>=0; k++)
     {
      double weight = period-k;
      sumw  += weight;
      sum   += weight*workLwma[r-k][instanceNo];
     }
   return(sum/sumw);
  }
//+------------------------------------------------------------------+
