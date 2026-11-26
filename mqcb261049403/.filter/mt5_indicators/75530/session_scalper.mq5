//+------------------------------------------------------------------+
//|                                              session_scalper.mq5 |
//|                                    Copyright 2026, Phan Van Khoa |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, Phan Van Khoa"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Session-based scalping indicator. Highlights the active trading session and shows the opening price of the session."
#property description "Works with the M1-M15 timeframes. A classic scalping technique is to fade the first impulsive move away from the session open."
#property description "Use the SessionOpen line together with the highlighted background to time entries at the beginning of a session."
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

//--- plot SessionOpen
#property indicator_label1  "SessionOpen"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- input parameters
input int      InpSessionStartHour  = 7;             // Session start hour (terminal time)
input int      InpSessionStartMinute = 0;            // Session start minute
input int      InpSessionDuration  = 8;              // Session duration, hours
input bool     InpFillBackground   = true;           // Fill session background
input color    InpBackgroundColor  = C'220,230,255'; // Background fill color
input ENUM_TIMEFRAMES InpTradeFrame = PERIOD_M1;    // Scalping timeframe

//--- indicator buffers
double         SessionOpenBuffer[];

//--- handle of the higher timeframe to detect session start
int            m_handle = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set buffer as used for drawing
   SetIndexBuffer(0, SessionOpenBuffer, INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

//--- attach a lower-resolution copy of the chart for stable session anchors
   m_handle = iMA(_Symbol, InpTradeFrame, 1, 0, MODE_SMA, PRICE_CLOSE);
   if(m_handle == INVALID_HANDLE)
     {
      Print("Failed to create the supporting indicator handle");
      return(INIT_FAILED);
     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(m_handle != INVALID_HANDLE)
      IndicatorRelease(m_handle);
  }
//+------------------------------------------------------------------+
//| Convert a bar time into the local day index                      |
//+------------------------------------------------------------------+
datetime DayStart(const datetime t)
  {
   MqlDateTime dt;
   TimeToStruct(t, dt);
   dt.hour = 0;
   dt.min  = 0;
   dt.sec  = 0;
   return(StructToTime(dt));
  }
//+------------------------------------------------------------------+
//| Return the session opening time for a given bar                  |
//+------------------------------------------------------------------+
datetime SessionStartTime(const datetime t)
  {
   datetime day = DayStart(t);
   datetime start = day + InpSessionStartHour * 3600 + InpSessionStartMinute * 60;
   if(start > t)
      start -= 24 * 3600;
   return(start);
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
   if(rates_total < 1)
      return(0);

   int start = (prev_calculated > 0) ? prev_calculated - 1 : 0;

   for(int i = start; i < rates_total; i++)
     {
      datetime sOpen = SessionStartTime(time[i]);
      datetime sEnd  = sOpen + InpSessionDuration * 3600;

      SessionOpenBuffer[i] = EMPTY_VALUE;

      if(time[i] >= sOpen && time[i] < sEnd)
        {
         int idx = iBarShift(_Symbol, _Period, sOpen);
         if(idx >= 0)
            SessionOpenBuffer[i] = open[idx];
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Chart event function - redraw the background on timeframe change |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE)
      ChartRedraw();
  }
//+------------------------------------------------------------------+
