//+------------------------------------------------------------------+
//| QCL Smoothed Heikin Ashi                                         |
//| Two-stage smoothed Heikin Ashi candles.                          |
//+------------------------------------------------------------------+
#property copyright "Quant Chart Lab"
#property version   "1.02"
#property indicator_chart_window
#property indicator_buffers 24
#property indicator_plots   3
#property indicator_type1   DRAW_CANDLES
#property indicator_color1  clrMediumSeaGreen
#property indicator_label1  "Bullish Candles"
#property indicator_type2   DRAW_CANDLES
#property indicator_color2  clrTomato
#property indicator_label2  "Bearish Candles"
#property indicator_type3   DRAW_CANDLES
#property indicator_color3  clrSilver
#property indicator_label3  "Neutral Candles"

input group "Primary Price Smoothing"
input int                  InpPricePeriod=14;           // Smoothing Period
input ENUM_MA_METHOD       InpPriceMethod=MODE_EMA;      // Moving Average Method
input group "Secondary Heikin Ashi Smoothing"
input int                  InpCandlePeriod=14;          // Smoothing Period
input ENUM_MA_METHOD       InpCandleMethod=MODE_EMA;     // Moving Average Method

double OutO[],OutH[],OutL[],OutC[];
double BearO[],BearH[],BearL[],BearC[];
double NeutralO[],NeutralH[],NeutralL[],NeutralC[];
double BaseO[],BaseH[],BaseL[],BaseC[];
double HaO[],HaH[],HaL[],HaC[];
double SmoothO[],SmoothH[],SmoothL[],SmoothC[];

// Arrays use chronological indexing: zero is the oldest bar.
// Partial-window seeds provide defined values on every startup bar.
double MovingAverage(const double &source[],const double &result[],
                     const int i,const int period,const ENUM_MA_METHOD method)
  {
   if(i==0 || period==1)
      return source[i];
   if(method==MODE_EMA)
      return result[i-1]+2.0/(period+1.0)*(source[i]-result[i-1]);
   int count=MathMin(i+1,period);
   if(method==MODE_SMMA && i>=period)
      return result[i-1]+(source[i]-result[i-1])/period;
   if(method==MODE_LWMA)
     {
      double sum=0.0;
      for(int k=0;k<count;k++)
         sum+=source[i-count+1+k]*(k+1.0);
      return sum/(count*(count+1.0)/2.0);
     }
   if(i<period)
      return (result[i-1]*i+source[i])/(i+1.0);
   return result[i-1]+(source[i]-source[i-period])/period;
  }

int OnInit()
  {
   if(InpPricePeriod<1 || InpCandlePeriod<1 ||
      InpPricePeriod>10000 || InpCandlePeriod>10000)
     {
      Print("Smoothing periods must be between 1 and 10000.");
      return INIT_PARAMETERS_INCORRECT;
     }
   SetIndexBuffer(0,OutO,INDICATOR_DATA);
   SetIndexBuffer(1,OutH,INDICATOR_DATA);
   SetIndexBuffer(2,OutL,INDICATOR_DATA);
   SetIndexBuffer(3,OutC,INDICATOR_DATA);
   SetIndexBuffer(4,BearO,INDICATOR_DATA);
   SetIndexBuffer(5,BearH,INDICATOR_DATA);
   SetIndexBuffer(6,BearL,INDICATOR_DATA);
   SetIndexBuffer(7,BearC,INDICATOR_DATA);
   SetIndexBuffer(8,NeutralO,INDICATOR_DATA);
   SetIndexBuffer(9,NeutralH,INDICATOR_DATA);
   SetIndexBuffer(10,NeutralL,INDICATOR_DATA);
   SetIndexBuffer(11,NeutralC,INDICATOR_DATA);
   SetIndexBuffer(12,BaseO,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,BaseH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,BaseL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(15,BaseC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(16,HaO,INDICATOR_CALCULATIONS);
   SetIndexBuffer(17,HaH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(18,HaL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(19,HaC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(20,SmoothO,INDICATOR_CALCULATIONS);
   SetIndexBuffer(21,SmoothH,INDICATOR_CALCULATIONS);
   SetIndexBuffer(22,SmoothL,INDICATOR_CALCULATIONS);
   SetIndexBuffer(23,SmoothC,INDICATOR_CALCULATIONS);
   for(int plot=0;plot<3;plot++)
     {
      PlotIndexSetInteger(plot,PLOT_DRAW_BEGIN,InpPricePeriod+InpCandlePeriod+2);
      PlotIndexSetDouble(plot,PLOT_EMPTY_VALUE,EMPTY_VALUE);
     }
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   IndicatorSetString(INDICATOR_SHORTNAME,
                      StringFormat("QCL Smoothed Heikin Ashi (%d,%d)",
                                   InpPricePeriod,InpCandlePeriod));
   return INIT_SUCCEEDED;
  }

int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],const double &open[],
                const double &high[],const double &low[],const double &close[],
                const long &tick_volume[],const long &volume[],const int &spread[])
  {
   if(rates_total<1)
      return 0;
   ArraySetAsSeries(open,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);
   ArraySetAsSeries(close,false);
   int start=(prev_calculated>0 && prev_calculated<=rates_total)
             ? prev_calculated-1 : 0;
   for(int i=start;i<rates_total && !IsStopped();i++)
     {
      BaseO[i]=MovingAverage(open,BaseO,i,InpPricePeriod,InpPriceMethod);
      BaseH[i]=MovingAverage(high,BaseH,i,InpPricePeriod,InpPriceMethod);
      BaseL[i]=MovingAverage(low,BaseL,i,InpPricePeriod,InpPriceMethod);
      BaseC[i]=MovingAverage(close,BaseC,i,InpPricePeriod,InpPriceMethod);
      // Preserve the source's initial price-candle seed interval.
      if(i<=InpPricePeriod+1)
        {
         HaO[i]=BaseO[i]; HaH[i]=BaseH[i];
         HaL[i]=BaseL[i]; HaC[i]=BaseC[i];
        }
      else
        {
         HaO[i]=(HaO[i-1]+HaC[i-1])/2.0;
         HaC[i]=(BaseO[i]+BaseH[i]+BaseL[i]+BaseC[i])/4.0;
         HaH[i]=MathMax(BaseH[i],MathMax(HaO[i],HaC[i]));
         HaL[i]=MathMin(BaseL[i],MathMin(HaO[i],HaC[i]));
        }
      SmoothO[i]=MovingAverage(HaO,SmoothO,i,InpCandlePeriod,InpCandleMethod);
      SmoothH[i]=MovingAverage(HaH,SmoothH,i,InpCandlePeriod,InpCandleMethod);
      SmoothL[i]=MovingAverage(HaL,SmoothL,i,InpCandlePeriod,InpCandleMethod);
      SmoothC[i]=MovingAverage(HaC,SmoothC,i,InpCandlePeriod,InpCandleMethod);
      double candle_open,candle_high,candle_low,candle_close;
      candle_open=SmoothO[i]; candle_close=SmoothC[i];
      candle_high=MathMax(SmoothH[i],MathMax(candle_open,candle_close));
      candle_low=MathMin(SmoothL[i],MathMin(candle_open,candle_close));
      // Clear all plots on each update, including intrabar direction changes.
      OutO[i]=OutH[i]=OutL[i]=OutC[i]=EMPTY_VALUE;
      BearO[i]=BearH[i]=BearL[i]=BearC[i]=EMPTY_VALUE;
      NeutralO[i]=NeutralH[i]=NeutralL[i]=NeutralC[i]=EMPTY_VALUE;
      if(SmoothC[i]>SmoothO[i])
        {
         OutO[i]=candle_open; OutH[i]=candle_high;
         OutL[i]=candle_low; OutC[i]=candle_close;
        }
      else if(SmoothC[i]<SmoothO[i])
        {
         BearO[i]=candle_open; BearH[i]=candle_high;
         BearL[i]=candle_low; BearC[i]=candle_close;
        }
      else
        {
         NeutralO[i]=candle_open; NeutralH[i]=candle_high;
         NeutralL[i]=candle_low; NeutralC[i]=candle_close;
        }
     }
   return IsStopped() ? 0 : rates_total;
  }
//+------------------------------------------------------------------+
