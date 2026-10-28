//------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "BB stops - RSI"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   6
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSilver
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDodgerBlue
#property indicator_width4  3
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrSandyBrown
#property indicator_width5  3
#property indicator_type6   DRAW_COLOR_ARROW
#property indicator_color6  clrSilver,clrDodgerBlue,clrSandyBrown
#property indicator_width6  2

//
//---
//
input int                RsiPeriod       = 14;          // RSI period
input ENUM_APPLIED_PRICE Price           = PRICE_CLOSE; // RSI Price
input int                BbPeriod        = 20;          // Bollinger stops period
input int                DeviationPeriod = 20;          // Deviations period
input double             Deviation       = 1;           // Deviation
input double             Risk            = 1;           // Risk (%)
double rsi[],bba[],bbc[],bblu[],bbld[],bmax[],bmin[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct _bbReturnStruct
  {
   double            upValue;
   double            downValue;
   int               trend;
   bool              trendChange;
  };
//------------------------------------------------------------------
//
//------------------------------------------------------------------
void OnInit()
  {
   SetIndexBuffer(0,rsi,INDICATOR_DATA);
   SetIndexBuffer(1,bmax,INDICATOR_DATA);
   SetIndexBuffer(2,bmin,INDICATOR_DATA);
   SetIndexBuffer(3,bblu,INDICATOR_DATA);
   SetIndexBuffer(4,bbld,INDICATOR_DATA);
   SetIndexBuffer(5,bba,INDICATOR_DATA);  PlotIndexSetInteger(5,PLOT_ARROW,159);
   SetIndexBuffer(6,bbc,INDICATOR_COLOR_INDEX);
   IndicatorSetString(INDICATOR_SHORTNAME,"BB stops - RSI ("+(string)RsiPeriod+","+(string)BbPeriod+","+(string)DeviationPeriod+")");
  }
//
//---
//
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tickVolume[],
                const long &volume[],
                const int &spread[])
  {

   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      rsi[i] = iRsi(getPrice(Price,open,close,high,low,i,rates_total),RsiPeriod,i,rates_total);
      _bbReturnStruct _result = iBbStops(rsi[i],BbPeriod,Risk,DeviationPeriod,Deviation,i,rates_total);
            bmax[i] = _result.upValue;
            bmin[i] = _result.downValue;
            bblu[i] = EMPTY_VALUE;
            bbld[i] = EMPTY_VALUE;
               if(_result.trend ==  1) { bblu[i] = _result.upValue;   bbc[i] = 1; }
               if(_result.trend == -1) { bbld[i] = _result.downValue; bbc[i] = 2; }
            bba[i]  = (_result.trendChange) ? (_result.trend==1) ? bblu[i]: bbld[i]: EMPTY_VALUE;
     }
   return(i);
  }

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define rsiInstances 1
double workRsi[][rsiInstances*3];
#define _price  0
#define _prices 3
#define _change 1
#define _changa 2
//
//---
//
double iRsi(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workRsi,0)!=bars) ArrayResize(workRsi,bars);
   int z=instanceNo*3;
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
#define _bbStopsInstances     1
#define _bbStopsInstancesSize 6
double bbWork[][_bbStopsInstances*_bbStopsInstancesSize];
#define _bbPrice 0
#define _bbAmax  1
#define _bbAmin  2
#define _bbBmax  3
#define _bbBmin  4
#define _bbTrend 5
//
//---
//
_bbReturnStruct iBbStops(double price,int period,double risk,int deviationPeriod,double deviation, int i,int bars,int instanceNo=0)
  {
   if(ArrayRange(bbWork,0)!=bars) ArrayResize(bbWork,bars); instanceNo*=_bbStopsInstancesSize;

   //
   //---
   //

   bbWork[i][instanceNo+_bbPrice]=price;
      double oldMean   = price;
      double newMean   = price;
      double squares   = 0;
      for(int k=1; k<deviationPeriod && (i-k)>=0; k++)
      {
         newMean  = (bbWork[i-k][instanceNo+_bbPrice]-oldMean)/(k+1)+oldMean;
         squares += (bbWork[i-k][instanceNo+_bbPrice]-oldMean)*(bbWork[i-k][instanceNo+_bbPrice]-newMean);
         oldMean  = newMean;
      }
      double dev   = MathSqrt(squares/deviationPeriod);
      double ma    = price;
      for(int k=1; k<period && (i-k)>=0; k++) ma+=bbWork[i-k][instanceNo+_bbPrice]; ma/=period;
      bbWork[i][instanceNo+_bbAmax] = ma+dev*deviation;
      bbWork[i][instanceNo+_bbAmin] = ma-dev*deviation;
      bbWork[i][instanceNo+_bbBmax] = bbWork[i][instanceNo+_bbAmax]+0.5*(risk-1)*(bbWork[i][instanceNo+_bbAmax]-bbWork[i][instanceNo+_bbAmin]);
      bbWork[i][instanceNo+_bbBmin]= bbWork[i][instanceNo+_bbAmin]-0.5*(risk-1)*(bbWork[i][instanceNo+_bbAmax]-bbWork[i][instanceNo+_bbAmin]);
      bbWork[i][instanceNo+_bbTrend] =(i>0) ?(price>bbWork[i-1][instanceNo+_bbAmax]) ? 1 :(price<bbWork[i-1][instanceNo+_bbAmin]) ? -1 : bbWork[i-1][instanceNo+_bbTrend] : 0;
      if(i>0)
      {
         if(bbWork[i][instanceNo+_bbTrend]==-1 && bbWork[i][instanceNo+_bbAmax]>bbWork[i-1][instanceNo+_bbAmax]) bbWork[i][instanceNo+_bbAmax] = bbWork[i-1][instanceNo+_bbAmax];
         if(bbWork[i][instanceNo+_bbTrend]== 1 && bbWork[i][instanceNo+_bbAmin]<bbWork[i-1][instanceNo+_bbAmin]) bbWork[i][instanceNo+_bbAmin] = bbWork[i-1][instanceNo+_bbAmin];
         if(bbWork[i][instanceNo+_bbTrend]==-1 && bbWork[i][instanceNo+_bbBmax]>bbWork[i-1][instanceNo+_bbBmax]) bbWork[i][instanceNo+_bbBmax] = bbWork[i-1][instanceNo+_bbBmax];
         if(bbWork[i][instanceNo+_bbTrend]== 1 && bbWork[i][instanceNo+_bbBmin]<bbWork[i-1][instanceNo+_bbBmin]) bbWork[i][instanceNo+_bbBmin] = bbWork[i-1][instanceNo+_bbBmin];
        }
   _bbReturnStruct _result;
                   _result.upValue   = bbWork[i][instanceNo+_bbBmin];
                   _result.downValue = bbWork[i][instanceNo+_bbBmax];
                   _result.trend     = (int)bbWork[i][instanceNo+_bbTrend];
                   _result.trendChange=(i>0) ? (bbWork[i][instanceNo+_bbTrend]!=bbWork[i-1][instanceNo+_bbTrend]) : false;
   return(_result);
  }
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   if(i>=0)
      switch(tprice)
        {
         case PRICE_CLOSE:     return(close[i]);
         case PRICE_OPEN:      return(open[i]);
         case PRICE_HIGH:      return(high[i]);
         case PRICE_LOW:       return(low[i]);
         case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
         case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
         case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
        }
   return(0);
  }
//+------------------------------------------------------------------+