//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "CCI candles (of smoothed prices)"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   1
#property indicator_label1  "cci"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGray,clrDodgerBlue,clrSandyBrown
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
input int       inpCciPeriod = 32;      // CCI period
input int       inpSmtPeriod = 14;      // Smoothing period (<=1 for no smoothing)
input enMaTypes inpMaMethod  = ma_sma;  // Smoothing method
                                        //
//--- indicator buffers
//

double ccio[],ccih[],ccil[],ccic[],ccicl[],savgh[],savgl[],savgo[],savgc[];
string _avgNames[]={"SMA","EMA","SMMA","LWMA"};
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
  {
   SetIndexBuffer(0,ccio,INDICATOR_DATA);
   SetIndexBuffer(1,ccih,INDICATOR_DATA);
   SetIndexBuffer(2,ccil,INDICATOR_DATA);
   SetIndexBuffer(3,ccic,INDICATOR_DATA);
   SetIndexBuffer(4,ccicl,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,savgo,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,savgh,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,savgl,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,savgc,INDICATOR_CALCULATIONS);
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI candles ("+(string)inpCciPeriod+")("+(string)inpSmtPeriod+" "+_avgNames[inpMaMethod]+" smoothed)");
   return(INIT_SUCCEEDED);
  }
//------------------------------------------------------------------
// Custom indicator de-initialization function
//------------------------------------------------------------------
void OnDeinit(const int reason) { return; }
//------------------------------------------------------------------
// Custom iteration function
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

//
//---
//

   double _cci[4];
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      savgh[i] = iCustomMa(inpMaMethod,high[i] ,inpSmtPeriod,i,rates_total,0);
      savgl[i] = iCustomMa(inpMaMethod,low[i]  ,inpSmtPeriod,i,rates_total,1);
      savgo[i] = iCustomMa(inpMaMethod,open[i] ,inpSmtPeriod,i,rates_total,2);
      savgc[i] = iCustomMa(inpMaMethod,close[i],inpSmtPeriod,i,rates_total,3);
      double avgh=0,avgl=0,avgo=0,avgc=0;
      for(int k=0; k<inpCciPeriod && (i-k)>=0; k++)
        {
         avgh += savgh[i-k];
         avgl += savgl[i-k];
         avgo += savgo[i-k];
         avgc += savgc[i-k];
        }
      avgh /= inpCciPeriod;
      avgl /= inpCciPeriod;
      avgo /= inpCciPeriod;
      avgc /= inpCciPeriod;
      double devh=0,devl=0,devo=0,devc=0;
      for(int k=0; k<inpCciPeriod && (i-k)>=0; k++)
        {
         devh += MathAbs(savgh[i-k]-avgh);
         devl += MathAbs(savgl[i-k]-avgl);
         devo += MathAbs(savgo[i-k]-avgo);
         devc += MathAbs(savgc[i-k]-avgc);
        }
      devh /= inpCciPeriod;
      devl /= inpCciPeriod;
      devo /= inpCciPeriod;
      devc /= inpCciPeriod;

      //
      //---
      //

      _cci[0]=(devh!=0) ?(savgh[i]-avgh)/(0.015*devh) : 0;
      _cci[1]=(devl!=0) ?(savgl[i]-avgl)/(0.015*devl) : 0;
      _cci[2]=(devo!=0) ?(savgo[i]-avgo)/(0.015*devo) : 0;
      _cci[3]=(devc!=0) ?(savgc[i]-avgc)/(0.015*devc) : 0;
      ccio[i] = _cci[2];
      ccic[i] = _cci[3];
      ccih[i] = _cci[ArrayMaximum(_cci,0,4)];
      ccil[i] = _cci[ArrayMinimum(_cci,0,4)];
      ccicl[i]=(ccic[i]>ccio[i]) ? 1 :(ccic[i]<ccio[i]) ? 2 : 0;
     }
   return(i);
  }
//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
#define _maInstances 4
#define _maWorkBufferx1 _maInstances
//
//---
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
double workEma[][_maWorkBufferx1];
//
//---
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
//---
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
//---
//
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
