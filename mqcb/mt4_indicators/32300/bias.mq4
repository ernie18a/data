//+------------------------------------------------------------------+
//|                                                         BIAS.mq4 |
//|                                                        Submarine |
//|                                      WeChart:ExpertAdvisorTrader |
//+------------------------------------------------------------------+
#property copyright "Submarine"
#property link      "https://www.mql5.com/en/users/carllin000"
#property version   "3.00"
#property strict
#property indicator_buffers 3
#property indicator_separate_window
double         LongBuffer[];
double         MidBuffer[];
double         ShortBuffer[];

ENUM_TIMEFRAMES InPeriod = PERIOD_CURRENT;
input int   InLong  = 6;
input color ClrLong = clrRed;
input int   InMid   = 12;
input color ClrMid  = clrYellow;
input int   InShort = 24;
input color ClrShort= clrGreen;

int ControlBars = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  EventSetTimer(1);
//--- indicator buffers mapping
    SetIndexBuffer(0,LongBuffer);
    SetIndexBuffer(1,MidBuffer);
    SetIndexBuffer(2,ShortBuffer);
    SetIndexStyle(0,DRAW_LINE,0,1,ClrLong);
    SetIndexStyle(1,DRAW_LINE,0,1,ClrMid);
    SetIndexStyle(2,DRAW_LINE,0,1,ClrShort);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---
    RefreshRates();
    ChartRedraw();
   
   int BarsWind;
   if (ControlBars!=0) BarsWind=ControlBars; else BarsWind=WindowFirstVisibleBar();
    for(int i=BarsWind; i>=0; i--)
       {
        LongBuffer[i]  = ((close[i]-iMA(NULL,InPeriod,InLong,0,0,0,i)) / (iMA(NULL,InPeriod,InLong,0,0,0,i)) *100);
        MidBuffer[i]   = ((close[i]-iMA(NULL,InPeriod,InMid,0,0,0,i))  / (iMA(NULL,InPeriod,InMid,0,0,0,i))  *100);
        ShortBuffer[i] = ((close[i]-iMA(NULL,InPeriod,InShort,0,0,0,i))/ (iMA(NULL,InPeriod,InShort,0,0,0,i))*100);
        
       /*
       BIAS1 : (CLOSE-MA(CLOSE,L1））/MA(CLOSE,L1）*100;
       BIAS2 : (CLOSE-MA(CLOSE,L2））/MA(CLOSE,L2）*100;
       BIAS3 : (CLOSE-MA(CLOSE,L3））/MA(CLOSE,L3）*100;
       */
       }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
