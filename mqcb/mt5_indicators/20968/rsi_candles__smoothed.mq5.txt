//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Rsi candles smoothed"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "RSI"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGray,clrDodgerBlue,clrCrimson

enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };
input int       inpRsiPeriod = 32;      // RSI period
input int       inpSmtPeriod = 14;      // Smoothing period (<=1 for no smoothing)
input enMaTypes inpMaMethod  = ma_sma;  // Smoothing method
                                //
//--- indicator buffers
//

double rsio[],rsih[],rsil[],rsic[],rsicl[];
string _avgNames[]={"SMA","EMA","SMMA","LWMA"};
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
  {
   SetIndexBuffer(0,rsio,INDICATOR_DATA);
   SetIndexBuffer(1,rsih,INDICATOR_DATA);
   SetIndexBuffer(2,rsil,INDICATOR_DATA);
   SetIndexBuffer(3,rsic,INDICATOR_DATA);
   SetIndexBuffer(4,rsicl,INDICATOR_COLOR_INDEX);
   IndicatorSetString(INDICATOR_SHORTNAME,"Rsi candles ("+(string)inpRsiPeriod+")("+(string)inpSmtPeriod+" "+_avgNames[inpMaMethod]+" smoothed+)");
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

   double _rsi[4];
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      _rsi[0] = iRsi(iCustomMa(inpMaMethod,open[i] ,inpSmtPeriod,i,rates_total,0),inpRsiPeriod,i,rates_total,0);
      _rsi[1] = iRsi(iCustomMa(inpMaMethod,high[i] ,inpSmtPeriod,i,rates_total,1),inpRsiPeriod,i,rates_total,1);
      _rsi[2] = iRsi(iCustomMa(inpMaMethod,low[i]  ,inpSmtPeriod,i,rates_total,2),inpRsiPeriod,i,rates_total,2);
      _rsi[3] = iRsi(iCustomMa(inpMaMethod,close[i],inpSmtPeriod,i,rates_total,3),inpRsiPeriod,i,rates_total,3);
      rsio[i] = _rsi[0];
      rsic[i] = _rsi[3];
      rsih[i] = _rsi[ArrayMaximum(_rsi,0,4)];
      rsil[i] = _rsi[ArrayMinimum(_rsi,0,4)];
      rsicl[i]=(rsic[i]>rsio[i]) ? 1 :(rsic[i]<rsio[i]) ? 2 : 0;
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
//
//---
//
#define rsiInstances 4
#define rsiInstancesSize 3
double workRsi[][rsiInstances*rsiInstancesSize];
#define _price  0
#define _change 1
#define _changa 2
//
//---
//
double iRsi(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workRsi,0)!=bars) ArrayResize(workRsi,bars);
   int z=instanceNo*rsiInstancesSize;

//
//---
//

   workRsi[r][z+_price]=price;
   double alpha=1.0/MathMax(period,1);
   if(r<period)
     {
      int k; double sum=0; for(k=0; k<period && (r-k-1)>=0; k++) sum+=MathAbs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
      workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/MathMax(k,1);
      workRsi[r][z+_changa] =                                         sum/MathMax(k,1);
     }
   else
     {
      double change=workRsi[r][z+_price]-workRsi[r-1][z+_price];
      workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(        change  - workRsi[r-1][z+_change]);
      workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(MathAbs(change) - workRsi[r-1][z+_changa]);
     }
   return(50.0*(workRsi[r][z+_change]/MathMax(workRsi[r][z+_changa],DBL_MIN)+1));
  }
//+------------------------------------------------------------------+
