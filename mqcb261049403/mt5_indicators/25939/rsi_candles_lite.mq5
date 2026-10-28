//------------------------------------------------------------------
#property strict
#property copyright   "Copyright 2019, Soewono Effendi"
#property link        "https://www.mql5.com/en/users/seffx"
#property version     "1.00"
#property description "Rsi candles - improved version"
#property description "based on RSI_candles by (C) mladen, 2018"
#property description "https://www.mql5.com/en/code/20968"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGray,clrDodgerBlue,clrCrimson

#property indicator_level1  70.0 
#property indicator_level2  30.0 
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT

input int inpRsiPeriod=14;      // RSI period

                                //
//--- indicator buffers
//

double rsio[],rsih[],rsil[],rsic[],rsicl[];
int hRsiO;
int hRsiC;
int hRsiH;
int hRsiL;
int last_bars;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getValue(int handle,int pos)
  {
   double buffer[1];
   if(CopyBuffer(handle,0,pos,1,buffer)==1)
      return(buffer[0]);
   return(EMPTY_VALUE);
  }
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
  {
   ArraySetAsSeries(rsio,true);
   ArraySetAsSeries(rsih,true);
   ArraySetAsSeries(rsil,true);
   ArraySetAsSeries(rsic,true);
   ArraySetAsSeries(rsicl,true);
   SetIndexBuffer(0,rsio,INDICATOR_DATA);
   SetIndexBuffer(1,rsih,INDICATOR_DATA);
   SetIndexBuffer(2,rsil,INDICATOR_DATA);
   SetIndexBuffer(3,rsic,INDICATOR_DATA);
   SetIndexBuffer(4,rsicl,INDICATOR_COLOR_INDEX);
   string name="Rsi candles ("+(string)inpRsiPeriod+")";
   IndicatorSetString(INDICATOR_SHORTNAME,name);
   PlotIndexSetString(0,PLOT_LABEL,name);
   hRsiO = iRSI(NULL, 0, inpRsiPeriod, PRICE_OPEN);
   hRsiC = iRSI(NULL, 0, inpRsiPeriod, PRICE_CLOSE);;
   hRsiH = iRSI(NULL, 0, inpRsiPeriod, PRICE_HIGH);;
   hRsiL = iRSI(NULL, 0, inpRsiPeriod, PRICE_LOW);;
   return(INIT_SUCCEEDED);
  }
//------------------------------------------------------------------
// Custom indicator de-initialization function
//------------------------------------------------------------------
void OnDeinit(const int reason)
  {
   IndicatorRelease(hRsiO);
   IndicatorRelease(hRsiC);
   IndicatorRelease(hRsiH);
   IndicatorRelease(hRsiL);
   return;
  }
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
   double _rsi[4],rsiO,rsiC,rsiH,rsiL;
   int i;
   int calculated=BarsCalculated(hRsiC);
   if(calculated<inpRsiPeriod)
     {
      return(prev_calculated);
     }
   last_bars = calculated;
   if(prev_calculated==0)
      i=rates_total-1;
   else
      i=rates_total - prev_calculated;
      
   for(;(i>=0) && !_StopFlag; i--)
     {
      rsiO = getValue(hRsiO, i);
      rsiC = getValue(hRsiC, i);
      rsiH = getValue(hRsiH, i);
      rsiL = getValue(hRsiL, i);

      _rsi[0] = rsiO;
      _rsi[1] = rsiH;
      _rsi[2] = rsiL;
      _rsi[3] = rsiC;


      rsio[i] = _rsi[0];
      rsic[i] = _rsi[3];
      rsih[i] = _rsi[ArrayMaximum(_rsi)];
      rsil[i] = _rsi[ArrayMinimum(_rsi)];
      rsicl[i]=(rsiC > rsiO) ? 1 :(rsiC < rsiO) ? 2 : 0;
     }
   return(rates_total - 1);
  }
//+------------------------------------------------------------------+
