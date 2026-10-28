//+------------------------------------------------------------------+
//|                                         TrendRegimeInspector.mq5 |
//|                    Open-source trend-condition indicator for MT5 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Jawad Bibar"
#property link      "https://forge.mql5.io"
#property version   "1.01"
#property description "A non-trading trend-condition indicator using MA direction, ADX and efficiency."
#property description "It displays information only and never opens, modifies or closes positions."
#property strict

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3

#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrFireBrick,clrDimGray,clrSeaGreen
#property indicator_width1  2
#property indicator_label1  "Trend score"

#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_width2  1
#property indicator_label2  "Efficiency %"

#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkOrange
#property indicator_width3  1
#property indicator_label3  "ADX"

#property indicator_level1  -50.0
#property indicator_level2  0.0
#property indicator_level3  50.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
#property indicator_minimum -100.0
#property indicator_maximum 100.0

input int            InpMAPeriod          = 50;       // Moving-average period
input ENUM_MA_METHOD InpMAMethod          = MODE_EMA; // Moving-average method
input int            InpADXPeriod         = 14;       // ADX period
input int            InpEfficiencyPeriod  = 20;       // Efficiency lookback
input double         InpStrongTrendScore  = 50.0;     // Strong-score threshold (0..100)

double g_trend_score[];
double g_trend_color[];
double g_efficiency[];
double g_adx[];
double g_ma_values[];
double g_adx_values[];

int g_ma_handle  = INVALID_HANDLE;
int g_adx_handle = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Kaufman efficiency ratio: directional distance / path length.  |
//+------------------------------------------------------------------+
double EfficiencyRatio(const double &close[],const int bar,const int period)
  {
   double path=0.0;
   for(int j=bar;j<bar+period;j++)
      path+=MathAbs(close[j]-close[j+1]);

   if(path<=0.0)
      return 0.0;

   return MathAbs(close[bar]-close[bar+period])/path;
  }

//+------------------------------------------------------------------+
//| Indicator initialization.                                       |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpMAPeriod<2 || InpADXPeriod<2 || InpEfficiencyPeriod<2 ||
      InpStrongTrendScore<0.0 || InpStrongTrendScore>100.0)
     {
      Print("Invalid Trend Regime Inspector input values.");
      return INIT_PARAMETERS_INCORRECT;
     }

   SetIndexBuffer(0,g_trend_score,INDICATOR_DATA);
   SetIndexBuffer(1,g_trend_color,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,g_efficiency,INDICATOR_DATA);
   SetIndexBuffer(3,g_adx,INDICATOR_DATA);

   ArraySetAsSeries(g_trend_score,true);
   ArraySetAsSeries(g_trend_color,true);
   ArraySetAsSeries(g_efficiency,true);
   ArraySetAsSeries(g_adx,true);
   ArraySetAsSeries(g_ma_values,true);
   ArraySetAsSeries(g_adx_values,true);

   g_ma_handle=iMA(_Symbol,_Period,InpMAPeriod,0,InpMAMethod,PRICE_CLOSE);
   g_adx_handle=iADX(_Symbol,_Period,InpADXPeriod);
   if(g_ma_handle==INVALID_HANDLE || g_adx_handle==INVALID_HANDLE)
     {
      Print("Unable to create the indicator handles. Error ",GetLastError());
      return INIT_FAILED;
     }

   IndicatorSetString(INDICATOR_SHORTNAME,"Trend Regime Inspector");
   IndicatorSetInteger(INDICATOR_DIGITS,1);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Release indicator resources.                                    |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_ma_handle!=INVALID_HANDLE)
      IndicatorRelease(g_ma_handle);
   if(g_adx_handle!=INVALID_HANDLE)
      IndicatorRelease(g_adx_handle);
  }

//+------------------------------------------------------------------+
//| Calculate the score and its transparent components.             |
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
   const int required_bars=MathMax(InpMAPeriod+2,InpEfficiencyPeriod+2);
   if(rates_total<required_bars)
      return 0;

   if(BarsCalculated(g_ma_handle)<rates_total || BarsCalculated(g_adx_handle)<rates_total)
      return prev_calculated;

   if(CopyBuffer(g_ma_handle,0,0,rates_total,g_ma_values)!=rates_total ||
      CopyBuffer(g_adx_handle,0,0,rates_total,g_adx_values)!=rates_total)
      return prev_calculated;

   int first_bar=rates_total-InpEfficiencyPeriod-1;
   if(prev_calculated>0)
      first_bar=MathMin(first_bar,rates_total-prev_calculated+1);

   for(int i=first_bar;i>=0;i--)
     {
      const double efficiency=EfficiencyRatio(close,i,InpEfficiencyPeriod);
      const double adx=MathMax(0.0,MathMin(100.0,g_adx_values[i]));
      const double slope=g_ma_values[i]-g_ma_values[i+1];

      int direction=0;
      if(close[i]>g_ma_values[i] && slope>0.0)
         direction=1;
      else if(close[i]<g_ma_values[i] && slope<0.0)
         direction=-1;

      // ADX is normalized at 50: a stronger ADX increases the score,
      // while the efficiency ratio discounts choppy price movement.
      const double adx_weight=MathMin(1.0,adx/50.0);
      const double score=direction*100.0*efficiency*adx_weight;

      g_trend_score[i]=score;
      g_efficiency[i]=100.0*efficiency;
      g_adx[i]=adx;

      if(score>=InpStrongTrendScore)
         g_trend_color[i]=2.0;
      else if(score<=-InpStrongTrendScore)
         g_trend_color[i]=0.0;
      else
         g_trend_color[i]=1.0;
     }

   // Only initialize the oldest bars once. Clearing them on every tick
   // would erase the already calculated history and leave only the latest
   // bars visible in the indicator window.
   if(prev_calculated==0)
     {
      for(int i=rates_total-1;i>first_bar;i--)
        {
         g_trend_score[i]=EMPTY_VALUE;
         g_efficiency[i]=EMPTY_VALUE;
         g_adx[i]=EMPTY_VALUE;
        }
     }

   return rates_total;
  }
//+------------------------------------------------------------------+
