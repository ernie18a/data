//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Kaufman adaptive average Keltner channel"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   5
#property indicator_label1  "upper filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'207,243,207'
#property indicator_label2  "lower filling"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'252,225,205'
#property indicator_label3  "Upper band"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrLimeGreen,clrSandyBrown
#property indicator_label4  "Lower band"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrLimeGreen,clrSandyBrown
#property indicator_label5  "Middle value"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDarkGray
//
//---
//
input int                inpPeriod        = 14;            // Period
input int                inpFastPeriod    =  2;            // Fast end period
input int                inpSlowPeriod    = 30;            // Slow end period
input double             inpPower         =  2;            // Smooth power
input ENUM_APPLIED_PRICE inpPrice         = PRICE_TYPICAL; // Price
input int                inpAtrPeriod     = 14;            // ATR period
input double             inpAtrMultiplier = 1.5;           // Channel multiplier

double bufferUp[],bufferUpc[],bufferDn[],bufferDnc[],bufferMe[],fupu[],fupd[],fdnd[],fdnu[];
//------------------------------------------------------------------
//
//------------------------------------------------------------------
int OnInit()
  {
   SetIndexBuffer(0,fupu,INDICATOR_DATA);     SetIndexBuffer(1,fupd,INDICATOR_DATA);
   SetIndexBuffer(2,fdnu,INDICATOR_DATA);     SetIndexBuffer(3,fdnd,INDICATOR_DATA);
   SetIndexBuffer(4,bufferUp,INDICATOR_DATA); SetIndexBuffer(5,bufferUpc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,bufferDn,INDICATOR_DATA); SetIndexBuffer(7,bufferDnc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(8,bufferMe,INDICATOR_DATA);
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason) { return; }
//
//---
//
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
   //
   //---
   //
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double _atr = 0;
         for (int k=0; k<inpAtrPeriod && (i-k-1)>=0; k++) _atr += MathMax(high[i-k],close[i-k-1])-MathMin(low[i-k],close[i-k-1]); _atr /= inpAtrPeriod;
      bufferMe[i] = iKama(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,inpFastPeriod,inpSlowPeriod,inpPower,i,open,close,high,low,rates_total);
      bufferUp[i] = bufferMe[i] + _atr*inpAtrMultiplier;
      bufferDn[i] = bufferMe[i] - _atr*inpAtrMultiplier;
      fupd[i]     = bufferMe[i]; fupu[i] = bufferUp[i];
      fdnu[i]     = bufferMe[i]; fdnd[i] = bufferDn[i];
      if(i>0)
        {
         bufferUpc[i] = bufferUpc[i-1];
         bufferDnc[i] = bufferDnc[i-1];

         //
         //
         //
         //
         //

         if(bufferUp[i]>bufferUp[i-1]) bufferUpc[i] = 0;
         if(bufferUp[i]<bufferUp[i-1]) bufferUpc[i] = 1;
         if(bufferDn[i]>bufferDn[i-1]) bufferDnc[i] = 0;
         if(bufferDn[i]<bufferDn[i-1]) bufferDnc[i] = 1;
        }
     }
   return(i);
  }

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define amaInstances     1
#define amaInstancesSize 3
double workAma[][amaInstances*amaInstancesSize];
#define _diff  0
#define _kama  1
#define _price 2
//
//---
//
double iKama(double price,int period,double fast,double slow,double power,int i,const double &open[],const double &close[],const double &high[],const double &low[],int bars,int instanceNo=0)
  {
   if(ArrayRange(workAma,0)!=bars) ArrayResize(workAma,bars);  int r=i; instanceNo*=amaInstancesSize;
   double fastend = (2.0 /(fast + 1));
   double slowend = (2.0 /(slow + 1));
//
//---
//
   double efratio=1; workAma[r][instanceNo+_price]=price;
   double signal = (r>=period) ? MathAbs(price-workAma[r-period][instanceNo+_price]) : 0;
   double noise  = 0;
   workAma[r][instanceNo+_diff]=(r>0) ? MathAbs(price-workAma[r-1][instanceNo+_price]) : 0;
   for(int k=0; k<period && r-k>=0; k++)
      noise+=workAma[r-k][instanceNo+_diff];
//
//---
//
   if(noise!=0)
      efratio = signal/noise;
   else  efratio = 1;
   double smooth=MathPow(efratio*(fastend-slowend)+slowend,power);
   workAma[r][instanceNo+_kama]=(r>0) ? workAma[r-1][instanceNo+_kama]+smooth*(price-workAma[r-1][instanceNo+_kama]) : price;
   return(workAma[r][instanceNo+_kama]);
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
