//------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "BB stops - MACD"
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
input int                MacdFastPeriod  = 12;          // Fast MACD period
input int                MacdSlowPeriod  = 26;          // Slow MACD period
input ENUM_APPLIED_PRICE Price           = PRICE_CLOSE; // MACD Price
input int                BbPeriod        = 20;          // Bollinger stops period
input int                DeviationPeriod = 20;          // Deviations period
input double             Deviation       = 1;           // Deviation
input double             Risk            = 1;           // Risk (%)
double macd[],bba[],bbc[],bblu[],bbld[],bmax[],bmin[];
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
   SetIndexBuffer(0,macd,INDICATOR_DATA);
   SetIndexBuffer(1,bmax,INDICATOR_DATA);
   SetIndexBuffer(2,bmin,INDICATOR_DATA);
   SetIndexBuffer(3,bblu,INDICATOR_DATA);
   SetIndexBuffer(4,bbld,INDICATOR_DATA);
   SetIndexBuffer(5,bba,INDICATOR_DATA);  PlotIndexSetInteger(5,PLOT_ARROW,159);
   SetIndexBuffer(6,bbc,INDICATOR_COLOR_INDEX);
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
      double _price = getPrice(Price,open,close,high,low,i,rates_total);
      macd[i] = iEma(_price,MacdFastPeriod,i,rates_total,0)-iEma(_price,MacdSlowPeriod,i,rates_total,1);
      _bbReturnStruct _result = iBbStops(macd[i],BbPeriod,Risk,DeviationPeriod,Deviation,i,rates_total);
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

//------------------------------------------------------------------
// custom functions
//------------------------------------------------------------------
double workEma[][2];
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