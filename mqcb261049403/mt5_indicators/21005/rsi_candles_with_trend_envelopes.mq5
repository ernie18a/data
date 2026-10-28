//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Rsi candles with trend envelopes"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   5
#property indicator_label1  "RSI"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGray,clrDodgerBlue,clrCrimson
#property indicator_width1  1
#property indicator_label2  "Trend envelope up trend line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_width2  2
#property indicator_label3  "Trend envelope down trend line"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrCrimson
#property indicator_width3  2
#property indicator_label4  "Trend envelope up trend start"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrDodgerBlue
#property indicator_width4  2
#property indicator_label5  "Trend envelope down trend start"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrCrimson
#property indicator_width5  2

input int    inpRsiPeriod = 2;      // RSI period
input double inpDeviation = 20;      // Trend envelopes deviation %
                                     //
//--- indicator buffers
//

double rsio[],rsih[],rsil[],rsic[],rsicl[],lineup[],linedn[],arrowup[],arrowdn[];
//
//--- custom structures
//

struct sTrendEnvelope
  {
   double            upline;
   double            downline;
   int               trend;
   bool              trendChange;
  };
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
   SetIndexBuffer(5,lineup,INDICATOR_DATA);
   SetIndexBuffer(6,linedn,INDICATOR_DATA);
   SetIndexBuffer(7,arrowup,INDICATOR_DATA); PlotIndexGetInteger(3,PLOT_ARROW,159);
   SetIndexBuffer(8,arrowdn,INDICATOR_DATA); PlotIndexGetInteger(4,PLOT_ARROW,159);
   IndicatorSetString(INDICATOR_SHORTNAME,"Rsi candles with trend envelopes ("+(string)inpRsiPeriod+","+(string)inpDeviation+")");
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
      sTrendEnvelope _result=iTrendEnvelope(rsih[i],rsil[i],rsic[i],inpDeviation,i,rates_total);
      lineup[i]  = _result.upline;
      linedn[i]  = _result.downline;
      arrowup[i] = (_result.trendChange && _result.trend== 1) ? lineup[i] : EMPTY_VALUE;
      arrowdn[i] = (_result.trendChange && _result.trend==-1) ? linedn[i] : EMPTY_VALUE;
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

//
//---
//
#define _trendEnvelopesInstances 1
#define _trendEnvelopesInstancesSize 3
double workTrendEnvelopes[][_trendEnvelopesInstances*_trendEnvelopesInstancesSize];
#define _teSmin  0
#define _teSmax  1 
#define _teTrend 2
//
//---
//

sTrendEnvelope iTrendEnvelope(double valueh,double valuel,double value,double deviation,int i,int bars,int instanceNo=0)
  {
   if(ArrayRange(workTrendEnvelopes,0)!=bars) ArrayResize(workTrendEnvelopes,bars); instanceNo*=_trendEnvelopesInstancesSize;

//
//---
//

   workTrendEnvelopes[i][instanceNo+_teSmax]  = (1+deviation/100)*valueh;
   workTrendEnvelopes[i][instanceNo+_teSmin]  = (1-deviation/100)*valuel;
   workTrendEnvelopes[i][instanceNo+_teTrend] = (i>0) ? (value>workTrendEnvelopes[i-1][instanceNo+_teSmax]) ? 1 : (value<workTrendEnvelopes[i-1][instanceNo+_teSmin]) ? -1 : workTrendEnvelopes[i-1][instanceNo+_teTrend] : 0;
   if(i>0 && workTrendEnvelopes[i][instanceNo+_teTrend]>0 && workTrendEnvelopes[i][instanceNo+_teSmin]<workTrendEnvelopes[i-1][instanceNo+_teSmin]) workTrendEnvelopes[i][instanceNo+_teSmin] = workTrendEnvelopes[i-1][instanceNo+_teSmin];
   if(i>0 && workTrendEnvelopes[i][instanceNo+_teTrend]<0 && workTrendEnvelopes[i][instanceNo+_teSmax]>workTrendEnvelopes[i-1][instanceNo+_teSmax]) workTrendEnvelopes[i][instanceNo+_teSmax] = workTrendEnvelopes[i-1][instanceNo+_teSmax];

//
//---
//

   sTrendEnvelope _result;
   _result.trend       = (int)workTrendEnvelopes[i][instanceNo+_teTrend];
   _result.trendChange = (i>0) ? ( workTrendEnvelopes[i][instanceNo+_teTrend]!=workTrendEnvelopes[i-1][instanceNo+_teTrend]) : false;
   _result.upline      = (workTrendEnvelopes[i][instanceNo+_teTrend]== 1) ? workTrendEnvelopes[i][instanceNo+_teSmin] : EMPTY_VALUE;
   _result.downline    = (workTrendEnvelopes[i][instanceNo+_teTrend]==-1) ? workTrendEnvelopes[i][instanceNo+_teSmax] : EMPTY_VALUE;
   return(_result);
  };
//+------------------------------------------------------------------+
