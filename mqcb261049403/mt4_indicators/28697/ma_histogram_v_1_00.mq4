//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Szymon Palczyński"
#property link      "https://www.mql5.com/en/users/stiopa"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
extern int   Period_ma=6;//Period

double Buffer1[];
double Buffer2[];
double Buffer3[];
int OnInit()
  {
   EventSetMillisecondTimer(100);
   IndicatorShortName("MA_HISTOGRAM");
   SetIndexBuffer(1,Buffer1);
   SetIndexStyle(1,DRAW_NONE,EMPTY,2,clrRed);
   SetIndexBuffer(2,Buffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM,DRAW_LINE,3,clrRed);
   SetIndexBuffer(3,Buffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM,DRAW_LINE,3,clrBlue);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   SetIndexStyle(2,DRAW_HISTOGRAM,DRAW_LINE,ScaleGet(0),clrRed);
   SetIndexStyle(3,DRAW_HISTOGRAM,DRAW_LINE,ScaleGet(0),clrBlue);
   double Sum;
   int shift;
   int N_bars=WindowFirstVisibleBar()-Period_ma;
   for(shift=N_bars; shift>=0; shift--)
     {
      Sum=0.0;
      for(int shift2=0; shift2<Period_ma; shift2++)
         Sum+=iMA(NULL,0,Period_ma,0,MODE_SMMA,PRICE_MEDIAN,shift+shift2);

      Buffer1[shift]=Sum/Period_ma;
      Buffer2[shift]=Buffer1[shift+1];

      Buffer2[shift]=Buffer1[shift]-(Buffer1[shift]-Buffer2[shift])*2;
      Buffer3[shift]=Buffer1[shift]+(Buffer1[shift]-Buffer2[shift])*2;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ScaleGet(const long chart_ID=0)
  {
   long result=-1;
   ResetLastError();
   if(!ChartGetInteger(chart_ID,CHART_SCALE,0,result))
     {
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
   return((int)result);
  }
//+------------------------------------------------------------------+
