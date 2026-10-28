//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Rsi candles"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "RSI"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGray,clrDodgerBlue,clrCrimson

input int inpRsiPeriod=14;      // RSI period

                                //
//--- indicator buffers
//

double rsio[],rsih[],rsil[],rsic[],rsicl[];
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
   IndicatorSetString(INDICATOR_SHORTNAME,"Rsi candles ("+(string)inpRsiPeriod+")");
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
      _rsi[0] = iRsi(open[i] ,inpRsiPeriod,i,rates_total,0);
      _rsi[1] = iRsi(high[i] ,inpRsiPeriod,i,rates_total,1);
      _rsi[2] = iRsi(low[i]  ,inpRsiPeriod,i,rates_total,2);
      _rsi[3] = iRsi(close[i],inpRsiPeriod,i,rates_total,3);
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
