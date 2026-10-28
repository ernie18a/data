//+------------------------------------------------------------------+
//|                                    Chart Navigator MT5 Light.mq5 |
//|        Light mini-map: price engine + viewport navigation only   |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2026, CapitalPlus"
#property link      "https://www.mql5.com/en/users/capitalplus"
#property version   "1.00"
#property strict

#property description "Chart Navigator MT5 Light: price mini-map and viewport navigation."
#property description "Only price mini-map, viewport navigation, vertical lines, and date tools."

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

#include <Canvas\Canvas.mqh>

//+------------------------------------------------------------------+
//| Configuration                                                    |
//+------------------------------------------------------------------+
// This file is intentionally self-contained.  The only external include is the
// standard MT5 canvas library above; all application classes are declared below.
// The goal is to make the CodeBase version easy to compile and easy to study.

#define MIN_VIEW_RANGE  0.005
#define VIEW_TOLERANCE  0.0005
#define PADDING_Y       5
#define SCROLL_STEP     5
#define RZ              7
#define RZ_TOP          4
#define MIN_W           80
#define MIN_H           24

const int MAP_LOADING_FONT_SIZE = 12;

enum ENUM_INTERACT
  {
   IA_NONE = 0,
   IA_MOVE,
   IA_RESIZE_T,
   IA_RESIZE_B,
   IA_RESIZE_L,
   IA_RESIZE_R,
   IA_RESIZE_TL,
   IA_RESIZE_TR,
   IA_RESIZE_BL,
   IA_RESIZE_BR,
   IA_DRAG_VIEWPORT
  };

//--- Public indicator settings -----------------------------------------------
input string __NavLightHdr1 = " "; // ====== Mini-map layout ======
input int    InpInitHeight = 80;      // Mini-map height, px
input int    InpInitMargin = 8;       // Distance from chart edge, px
input string InpUiFontName = "Arial"; // Interface font

input string __NavLightHdrDate = " "; // ====== Mini-map date settings ======
input bool     InpMapDateFromEnabled = true;                  // Use mini-map start date
input datetime InpMapDateFrom        = D'2025.01.01 00:00';   // Mini-map start date
input bool     InpMapDateToEnabled   = false;                 // Use mini-map end date
input datetime InpMapDateTo          = D'2026.01.01 00:00';   // Mini-map end date

input bool     InpShowMapHoverDate   = true;                  // Show dynamic date under cursor
input int      InpMapHoverDateFont   = 8;                     // Dynamic date font size
input int      InpMapHoverDateOffset = 4;                     // Dynamic date distance above map, px
input color    InpMapHoverDateBg     = C'22,24,26';           // Dynamic date background
input color    InpMapHoverDateBorder = C'44,48,52';           // Dynamic date border
input color    InpMapHoverDateText   = C'220,225,230';        // Dynamic date text

input string __NavLightHdrVLines = " "; // ====== Vertical lines ======
input bool     InpShowVerticalLines   = true;                 // Show vertical lines on mini-map
input bool     InpVLineUseObjectColor = true;                 // Vertical lines use chart-object color
input color    InpVLineColor          = C'235,205,100';       // Vertical lines fallback color
input int      InpVLineOpacity        = 200;                  // Vertical lines opacity, 0..255
input int      InpVLineWidth          = 1;                    // Vertical lines width, px

input string __NavLightHdr2 = " "; // ====== Mini-map colors ======
input color InpUserThemeRibbonBg       = C'22,24,26';    // Mini-map background
input color InpUserThemeEdge           = C'44,48,52';    // Mini-map border
input color InpUserThemeEdgeHover      = C'80,140,190';  // Resize hover border
input color InpUserThemeCorner         = C'130,110,190'; // Corner marks
input color InpUserThemeCornerHover    = C'80,140,190';  // Corner hover marks
input color InpUserThemeViewportBorder = C'80,140,190';  // Viewport border
input color InpUserThemeViewportFill   = C'32,52,72';    // Viewport fill

//+------------------------------------------------------------------+
//| Theme                                                           |
//+------------------------------------------------------------------+
color NavThemeRibbonBg()
  {
   return InpUserThemeRibbonBg;
  }

color NavThemeEdge(const bool hover=false)
  {
   return hover ? InpUserThemeEdgeHover : InpUserThemeEdge;
  }

color NavThemeHoverBrd()
  {
   return InpUserThemeEdgeHover;
  }

color NavThemeCorner(const bool hover=false)
  {
   return hover ? InpUserThemeCornerHover : InpUserThemeCorner;
  }

color NavThemeViewportBorder()
  {
   return InpUserThemeViewportBorder;
  }

color NavThemeViewportFill()
  {
   return InpUserThemeViewportFill;
  }

color NavThemeDim()
  {
   return C'160,170,180';
  }

//+------------------------------------------------------------------+
//| Data Provider                                                   |
//+------------------------------------------------------------------+

// Loads chart history into two normalized arrays:
//   m_time[]  - bar time, oldest -> newest
//   m_close[] - close price, oldest -> newest
// Keeping this order makes the canvas projection simple: X grows from left to right.
// Terminal series indexes are still stored separately as m_barFrom/m_barTo for chart navigation.
class CNavDataProvider
  {
private:
   double            m_close[];
   datetime          m_time[];       // bar open time in map order (oldest -> newest)
   int               m_totalBars;    // bars in current dataset (filtered range)
   int               m_chartBars;    // total bars on chart (for new-bar detection)
   double            m_priceMax;
   double            m_priceRng;
   datetime          m_timeFirst;    // open time of oldest bar in loaded range
   datetime          m_timeLast;     // open time of newest bar in loaded range

   // Series bar indices for the loaded range (series order: 0 = newest chart bar)
   int               m_barFrom;      // oldest bar in range (largest series index)
   int               m_barTo;        // newest bar in range (smallest series index)

public:
                     CNavDataProvider()
     : m_totalBars(0), m_chartBars(0),
       m_priceMax(0), m_priceRng(1),
       m_timeFirst(0), m_timeLast(0),
       m_barFrom(0), m_barTo(0)
     {}

   //--- Load bars filtered to [dateFrom, dateTo].
   //    Pass 0 for either to use the full history boundary.
   //    Called by the indicator with runtime input values.
   bool              Load(datetime dateFrom = 0, datetime dateTo = 0)
     {
      if(dateFrom > 0 && dateTo > 0 && dateFrom > dateTo)
        {
         PrintFormat("CNavDataProvider::Load invalid date range: from=%s to=%s",
                     TimeToString(dateFrom, TIME_DATE|TIME_MINUTES),
                     TimeToString(dateTo,   TIME_DATE|TIME_MINUTES));
         return false;
        }
      return _LoadRange(dateFrom, dateTo);
     }

   //--- Accessors
   int               TotalBars()      { return m_totalBars; }
   int               ChartTotalBars() { return m_chartBars; }
   double            Close(int i)
     {
      int n = ArraySize(m_close);
      if(n <= 0) return 0.0;
      if(i < 0) i = 0;
      if(i >= n) i = n - 1;
      return m_close[i];
     }
   double            PriceMax()       { return m_priceMax; }
   double            PriceRng()       { return m_priceRng; }
   datetime          TimeFirst()      { return m_timeFirst; }
   datetime          TimeLast()       { return m_timeLast; }
   datetime          TimeAt(int i)
     {
      int n = ArraySize(m_time);
      if(n <= 0) return 0;
      if(i < 0) i = 0;
      if(i >= n) i = n - 1;
      return m_time[i];
     }

   // Series bar index of the OLDEST bar in the loaded range (largest index)
   int               BarFrom()        { return m_barFrom; }
   // Series bar index of the NEWEST bar in the loaded range (smallest index)
   int               BarTo()          { return m_barTo; }

private:
   bool              _CopyOneRateByDate(const datetime t,
                                              MqlRates &rate,
                                              const string label)
     {
      if(t <= 0)
         return false;

      MqlRates one[];
      ArraySetAsSeries(one, false);
      ResetLastError();
      int copied = CopyRates(_Symbol, _Period, t, 1, one);
      int err = GetLastError();
      if(copied != 1)
        {
         PrintFormat("CNavDataProvider::_CopyOneRateByDate not ready %s=%s copied=%d err=%d",
                     label, TimeToString(t, TIME_DATE|TIME_MINUTES), copied, err);
         return false;
        }

      rate = one[0];
      if(rate.time <= 0)
        {
         PrintFormat("CNavDataProvider::_CopyOneRateByDate invalid time %s=%s copiedTime=%I64d",
                     label, TimeToString(t, TIME_DATE|TIME_MINUTES), (long)rate.time);
         return false;
        }
      return true;
     }

   bool              _CopyCurrentRate(MqlRates &rate)
     {
      MqlRates one[];
      ArraySetAsSeries(one, false);
      ResetLastError();
      int copied = CopyRates(_Symbol, _Period, 0, 1, one);
      int err = GetLastError();
      if(copied != 1)
        {
         PrintFormat("CNavDataProvider::_CopyCurrentRate not ready copied=%d err=%d", copied, err);
         return false;
        }

      rate = one[0];
      return (rate.time > 0);
     }

   int               _ResolveShiftByTime(const datetime t,
                                         const datetime currentBarTime)
     {
      if(t <= 0 || currentBarTime <= 0)
         return -1;

      ResetLastError();
      int sh = iBarShift(_Symbol, _Period, t, false);
      if(sh >= 0)
         return sh;

      // Fallback for the exact failure seen after MN1/D1/H4 -> M1 switches:
      // CopyRates(date range) can already have built the requested block, while
      // the chart-owned Bars()/iBarShift cache has not fully expanded yet.  Bars
      // by date interval gives us the same series shift: number of bars from the
      // requested bar through the current bar minus one.
      ResetLastError();
      int cnt = Bars(_Symbol, _Period, t, currentBarTime);
      int err = GetLastError();
      if(cnt > 0)
         return cnt - 1;

      PrintFormat("CNavDataProvider::_ResolveShiftByTime failed time=%s current=%s bars=%d err=%d",
                  TimeToString(t, TIME_DATE|TIME_MINUTES),
                  TimeToString(currentBarTime, TIME_DATE|TIME_MINUTES),
                  cnt, err);
      return -1;
     }

   bool              _ResolveBoundaryShiftByDate(const datetime t,
                                                     const bool oldestBoundary,
                                                     const int avail,
                                                     int &shift)
     {
      if(avail <= 1)
         return false;

      shift = oldestBoundary ? avail - 1 : 0;
      if(t <= 0)
         return true;

      ResetLastError();
      int sh = iBarShift(_Symbol, _Period, t, false);
      if(sh >= 0)
        {
         if(sh >= avail)
            sh = avail - 1;
         shift = sh;
         return true;
        }

      datetime newest = iTime(_Symbol, _Period, 0);
      datetime oldest = iTime(_Symbol, _Period, avail - 1);

      // Boundary outside currently available terminal history: clamp to the nearest
      // real chart edge instead of rejecting the whole map.
      if(newest > 0 && t >= newest)
        {
         shift = 0;
         return true;
        }
      if(oldest > 0 && t <= oldest)
        {
         shift = avail - 1;
         return true;
        }

      PrintFormat("CNavDataProvider::_ResolveBoundaryShiftByDate failed boundary=%s oldest=%s newest=%s err=%d",
                  TimeToString(t, TIME_DATE|TIME_MINUTES),
                  TimeToString(oldest, TIME_DATE|TIME_MINUTES),
                  TimeToString(newest, TIME_DATE|TIME_MINUTES),
                  GetLastError());
      return false;
     }

   bool              _CopyRatesByDateRange(const datetime inpFrom,
                                           const datetime inpTo,
                                           MqlRates &rates[],
                                           int &newBarTo,
                                           int &newBarFrom,
                                           int &chartBarsResolved)
     {
      int avail = Bars(_Symbol, _Period);
      if(avail <= 1)
         return false;

      int barFrom = avail - 1;  // oldest boundary, larger MT series index
      int barTo   = 0;          // newest boundary, smaller MT series index

      if(!_ResolveBoundaryShiftByDate(inpFrom, true,  avail, barFrom))
         return false;
      if(!_ResolveBoundaryShiftByDate(inpTo,   false, avail, barTo))
         return false;

      if(barFrom >= avail)
         barFrom = avail - 1;
      if(barTo < 0)
         barTo = 0;

      // For MT series indexing the older bar has the larger index.
      // If the date filter collapses to an invalid interval, reject it cleanly.
      if(barFrom < barTo)
        {
         PrintFormat("CNavDataProvider::_CopyRatesByDateRange invalid shift range fromShift=%d toShift=%d From=%s To=%s",
                     barFrom, barTo,
                     TimeToString(inpFrom, TIME_DATE|TIME_MINUTES),
                     TimeToString(inpTo,   TIME_DATE|TIME_MINUTES));
         return false;
        }

      if(!_CopyRatesByShiftRange(barTo, barFrom, rates))
         return false;

      newBarTo = barTo;
      newBarFrom = barFrom;
      chartBarsResolved = avail;
      return true;
     }

   bool              _CopyRatesByShiftRange(const int barTo,
                                            const int barFrom,
                                            MqlRates &rates[])
     {
      if(barTo < 0 || barFrom < barTo)
         return false;

      int total = barFrom - barTo + 1;
      if(total <= 1)
         return false;

      ResetLastError();
      if(ArrayResize(rates, total) != total)
        {
         PrintFormat("CNavDataProvider::_CopyRatesByShiftRange ArrayResize failed total=%d err=%d",
                     total, GetLastError());
         return false;
        }
      ArraySetAsSeries(rates, false);

      // CopyRates() ordering can differ across access forms/builds.
      // Copy by terminal series shifts, then normalize every chunk to
      // physical order oldest -> newest before it reaches WaveCache/ChartSync.
      const int chunkBars = 50000;
      int dst = 0;

      for(int chunkOldest = barFrom; chunkOldest >= barTo; )
        {
         int chunkNewest = chunkOldest - chunkBars + 1;
         if(chunkNewest < barTo)
            chunkNewest = barTo;

         int need = chunkOldest - chunkNewest + 1;
         if(need <= 0)
            return false;

         MqlRates part[];
         ArraySetAsSeries(part, false);
         ResetLastError();
         int copied = CopyRates(_Symbol, _Period, chunkNewest, need, part);
         if(copied != need)
           {
            PrintFormat("CNavDataProvider::_CopyRatesByShiftRange chunk copy incomplete newestShift=%d oldestShift=%d copied=%d requested=%d err=%d",
                        chunkNewest, chunkOldest, copied, need, GetLastError());
            return false;
           }

         bool asc = (copied <= 1 || part[0].time <= part[copied - 1].time);
         for(int i = 0; i < copied; i++)
           {
            if(dst >= total)
               return false;

            int src = asc ? i : (copied - 1 - i);
            rates[dst++] = part[src];
           }

         chunkOldest = chunkNewest - 1;
        }

      if(dst != total)
        {
         PrintFormat("CNavDataProvider::_CopyRatesByShiftRange copied size mismatch copied=%d total=%d",
                     dst, total);
         return false;
        }

      return true;
     }

   //--- Load bars in the date range [inpFrom, inpTo].
   //    If both are 0 the full chart history is loaded (original behaviour).
   bool              _LoadRange(datetime inpFrom, datetime inpTo)
     {
      int avail = Bars(_Symbol, _Period);
      if(avail <= 1) return false;

      if(inpFrom > 0 && inpTo > 0 && inpFrom > inpTo)
         return false;

      int       newBarTo   = 0;
      int       newBarFrom = avail - 1;
      int       newChartBars = avail;
      MqlRates  rates[];
      bool      boundedRange = (inpFrom > 0 || inpTo > 0);

      if(boundedRange)
        {
         // For an explicit date filter, load the requested interval directly by
         // time.  Do not require Bars()/iTime(avail-1) to already include deep
         // M1 history: after a high-TF -> M1 switch that chart cache is exactly
         // the part that lags and caused the endless Loading state.
         if(!_CopyRatesByDateRange(inpFrom, inpTo, rates,
                                   newBarTo, newBarFrom, newChartBars))
            return false;
        }
      else
        {
         newBarTo   = 0;           // newest chart bar
         newBarFrom = avail - 1;   // oldest chart bar
         newChartBars = avail;

         int barsNeeded = newBarFrom - newBarTo + 1;
         if(barsNeeded <= 1) return false;

         if(!_CopyRatesByShiftRange(newBarTo, newBarFrom, rates))
           {
            PrintFormat("CNavDataProvider::_LoadRange CopyRates full range not ready barTo=%d barFrom=%d requested=%d",
                        newBarTo, newBarFrom, barsNeeded);
            return false;
           }
        }

      int cc = ArraySize(rates);
      if(cc <= 1)
        {
         PrintFormat("CNavDataProvider::_LoadRange too few bars after copy copied=%d",
                     cc);
         return false;
        }

      //--- Optimisation: skip reload if nothing changed --------------------------
      if(newBarFrom == m_barFrom &&
         newBarTo   == m_barTo   &&
         newChartBars == m_chartBars &&
         cc         == m_totalBars &&
         m_totalBars > 0)
         return true;

      ArrayResize(m_close, cc);
      ArrayResize(m_time,  cc);
      ArraySetAsSeries(m_close, false);
      ArraySetAsSeries(m_time,  false);
      for(int i = 0; i < cc; i++)
        {
         m_close[i] = rates[i].close;
         m_time[i]  = rates[i].time;
        }

      m_totalBars = cc;
      m_chartBars = (newChartBars > newBarFrom + 1 ? newChartBars : newBarFrom + 1);
      m_barFrom   = newBarFrom;
      m_barTo     = newBarTo;
      m_timeFirst = rates[0].time;        // oldest copied bar open time
      m_timeLast  = rates[cc - 1].time;   // newest copied bar open time

      if(m_timeFirst <= 0 || m_timeLast <= 0 || m_timeFirst > m_timeLast)
        {
         PrintFormat("CNavDataProvider::_LoadRange invalid copied time range timeFirst=%I64d timeLast=%I64d copied=%d",
                     (long)m_timeFirst, (long)m_timeLast, cc);
         return false;
        }

      return _CalcPriceRange();
     }

   bool              _CalcPriceRange()
     {
      if(m_totalBars <= 1) return false;

      // Do not use ArrayMinimum/ArrayMaximum here.  MQL4 and MQL5 have historically differed in helper details here.
      // A direct port can accidentally calculate min/max from an empty/invalid slice.
      // The visible symptom was a collapsed price wave: one horizontal dash.
      double pmin = DBL_MAX;
      double pmax = -DBL_MAX;

      for(int i = 0; i < m_totalBars; i++)
        {
         double c = m_close[i];
         if(!MathIsValidNumber(c))
            continue;

         if(c < pmin) pmin = c;
         if(c > pmax) pmax = c;
        }

      if(pmin == DBL_MAX || pmax == -DBL_MAX)
         return false;

      m_priceMax = pmax;

      double point = _Point;
      if(!MathIsValidNumber(point) || point <= 0.0)
         point = 0.00000001;

      m_priceRng = pmax - pmin;
      if(!MathIsValidNumber(m_priceRng) || m_priceRng <= 0.0)
         m_priceRng = point;
      if(m_priceRng < point)
         m_priceRng = point;

      return true;
     }
  };

//+------------------------------------------------------------------+
//| Wave Cache                                                      |
//+------------------------------------------------------------------+

// Converts bar prices to pixel Y coordinates once per rebuild.
// The renderer can then draw the mini-chart without touching price arrays on every frame.
class CNavWaveCache
  {
private:
   int               m_waveY[];
   uint              m_waveColor[];

   int               _SafeY(double price, double priceMax, double priceRng, int drawH)
     {
      if(drawH <= 0) drawH = 1;
      if(!MathIsValidNumber(price) || !MathIsValidNumber(priceMax) ||
         !MathIsValidNumber(priceRng) || priceRng <= 0.0)
         return PADDING_Y;

      double yf = (priceMax - price) / priceRng * (double)drawH;
      if(!MathIsValidNumber(yf))
         return PADDING_Y;

      int py = PADDING_Y + (int)MathRound(yf);
      return MathMax(PADDING_Y, MathMin(py, PADDING_Y + drawH));
     }

public:
   void              Build(CNavDataProvider &dp, int winW, int winH)
     {
      int totalBars = dp.TotalBars();
      if(winW <= 0 || totalBars <= 0)
        {
         ArrayResize(m_waveY,     0);
         ArrayResize(m_waveColor, 0);
         return;
        }

      ResetLastError();
      if(ArrayResize(m_waveY, winW) != winW || ArrayResize(m_waveColor, winW) != winW)
        {
         PrintFormat("CNavWaveCache::Build ArrayResize failed winW=%d err=%d",
                     winW, GetLastError());
         ArrayResize(m_waveY,     0);
         ArrayResize(m_waveColor, 0);
         return;
        }

      int drawH = winH - PADDING_Y * 2;
      if(drawH <= 0) drawH = 1;

      double priceMax = dp.PriceMax();
      double priceRng = dp.PriceRng();
      if(!MathIsValidNumber(priceMax) || !MathIsValidNumber(priceRng) || priceRng <= 0.0)
        {
         ArrayResize(m_waveY,     0);
         ArrayResize(m_waveColor, 0);
         return;
        }

      // Fixed wave color (bluish).
      uint fixedColor = ColorToARGB(C'100,160,220', 255);

      for(int x = 0; x < winW; x++)
        {
         int bi = (winW > 1)
                  ? (int)MathRound((double)x / (winW - 1) * (totalBars - 1))
                  : 0;
         bi = MathMax(0, MathMin(bi, totalBars - 1));

         m_waveY[x] = _SafeY(dp.Close(bi), priceMax, priceRng, drawH);

         m_waveColor[x] = fixedColor;
        }
     }

   int               Size()        { return ArraySize(m_waveY); }
   int               GetY(int x)
     {
      int n = ArraySize(m_waveY);
      if(n <= 0) return PADDING_Y;
      if(x < 0) x = 0;
      if(x >= n) x = n - 1;
      return m_waveY[x];
     }
   uint              GetColor(int x)
     {
      int n = ArraySize(m_waveColor);
      if(n <= 0) return ColorToARGB(C'100,160,220', 255);
      if(x < 0) x = 0;
      if(x >= n) x = n - 1;
      return m_waveColor[x];
     }
  };

//+------------------------------------------------------------------+
//| Chart Synchronizer                                              |
//+------------------------------------------------------------------+

// Translates between two coordinate systems:
//   1) MT5 chart position in bar-series indexes, where 0 is the newest bar.
//   2) Mini-map viewport fractions in the [0..1] range, left to right.
class CNavChartSync
  {
private:
   bool              m_isNavigating;
   int               m_lastTargetRightBarTS;

public:
                     CNavChartSync() :
                        m_isNavigating(false),
                        m_lastTargetRightBarTS(-1) {}

   //--- Sync viewport fractions from current chart position.
   //
   //    totalBars  - number of bars in the filtered map range
   //    barFrom    - series index (0=newest) of the OLDEST bar in the range
   //    inRange    - OUTPUT: true when the chart view overlaps the map range
   //
   //    The rectangle itself is always normalized to [0..1].  Near the newest
   //    edge with CHART_SHIFT enabled, the terminal can show fewer real bars
   //    because part of the chart window is empty right-indent space; in that
   //    special case the box is intentionally clipped by using CHART_VISIBLE_BARS.
   void              SyncViewFromChart(double &viewStart, double &viewEnd,
                                       int totalBars, int barFrom,
                                       bool &inRange)
     {
      inRange = false;
      if(totalBars <= 0) { viewStart = 0.8; viewEnd = 1.0; return; }

      int chartTotalBars = Bars(_Symbol, _Period);
      if(chartTotalBars <= 0)
         chartTotalBars = MathMax(barFrom + 1, totalBars);

      int firstBarTS = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
      if(firstBarTS < 0 || firstBarTS >= chartTotalBars)
         return;

      int viewBars = _ViewportBarsForSync(chartTotalBars, firstBarTS);
      if(viewBars <= 0)
         return;

      // Chart viewport [rightBarTS .. firstBarTS] vs map [barTo .. barFrom]
      // (larger series index = older bar).  Project the INTERSECTION to the
      // minimap.  If the main chart shows more history than the map range, the
      // viewport box must absorb the entire map instead of forcing the map range
      // to expand to the chart's visible history.
      inRange = _ProjectChartWindowToMap(viewStart, viewEnd,
                                         totalBars, barFrom,
                                         firstBarTS, viewBars);
     }

   //--- Navigate chart so that the position clicked on the map becomes visible.
   //
   //    totalBars      - bars in filtered range
   //    barFrom        - series index of map's oldest bar
   //    chartTotalBars - total bars on chart (= DataProvider.ChartTotalBars())
   void              SyncChartFromView(double viewStart, double viewEnd,
                                       int totalBars, int barFrom,
                                       int chartTotalBars)
     {
      if(totalBars <= 0 || chartTotalBars <= 0) return;
      if(barFrom < 0 || barFrom >= chartTotalBars) return;

      // Navigation must use the full chart-window capacity in bars, not the
      // clipped number of visible real bars at the newest edge.  Otherwise a
      // viewport dragged away from the right-shift zone keeps the old shortened
      // width and falls behind the minimap box.
      int viewBars = _ViewportBarsForNavigation(chartTotalBars);
      if(viewBars <= 0) return;

      double vs = viewStart;
      double ve = viewEnd;
      if(!MathIsValidNumber(vs) || !MathIsValidNumber(ve)) return;
      if(ve <= vs) return;
      ClampPair(vs, ve);

      int maxTargetOldest = totalBars - 1;
      if(maxTargetOldest < 0)
         maxTargetOldest = 0;

      // targetOldest: index within filtered range (0 = map's oldest bar).
      int targetOldest = (int)MathRound(vs * (double)totalBars);
      targetOldest = MathMax(0, MathMin(targetOldest, maxTargetOldest));

      // Convert minimap left edge to the desired first visible bar in MT series
      // indexing: 0 = newest bar, chartTotalBars-1 = oldest bar.
      int targetFirstBarTS = barFrom - targetOldest;
      if(targetFirstBarTS < 0)
         targetFirstBarTS = 0;
      if(targetFirstBarTS >= chartTotalBars)
         targetFirstBarTS = chartTotalBars - 1;

      // Absolute navigation from CHART_END.  The shift value itself is still
      // relative to CHART_END in the terminal chart API, but the computed target right edge is
      // an absolute series-index target.
      int targetRightBarTS = targetFirstBarTS - viewBars + 1;
      if(targetRightBarTS < 0)
         targetRightBarTS = 0;
      if(targetRightBarTS >= chartTotalBars)
         targetRightBarTS = chartTotalBars - 1;

      int firstBarTS = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
      if(firstBarTS >= 0 && firstBarTS < chartTotalBars)
        {
         int currentViewBars = _ViewportBarsForSync(chartTotalBars, firstBarTS);
         int currentRightBarTS = firstBarTS - currentViewBars + 1;
         if(currentRightBarTS < 0)
            currentRightBarTS = 0;
         if(currentRightBarTS >= chartTotalBars)
            currentRightBarTS = chartTotalBars - 1;

         if(MathAbs(currentRightBarTS - targetRightBarTS) <= 1)
           {
            m_lastTargetRightBarTS = targetRightBarTS;
            return;
           }
        }

      // Active drag must use the same positioning model as an accurate map click:
      // every mouse X is a fresh target relative to the current terminal viewport.
      // The CHART_BEGIN absolute path was bar-accurate, but on some terminal builds it
      // can force a heavy visual redraw of the price chart during high-frequency
      // mouse movement (brief "white separator" noise).  Do not use it while the
      // left button is held; keep it only as a non-drag fallback below.
      if(m_isNavigating)
        {
         if(m_lastTargetRightBarTS == targetRightBarTS)
            return;

         // Anchor navigation by the desired right edge.  In MT5 this is usually more
         // stable than repeatedly shifting from the current position while the
         // mouse is held, and it keeps the clicked mini-map point in the same
         // relative position inside the viewport box.
         ResetLastError();
         if(ChartNavigate(0, CHART_END, -targetRightBarTS))
           {
            m_lastTargetRightBarTS = targetRightBarTS;
            return;
           }

         if(firstBarTS < 0 || firstBarTS >= chartTotalBars)
            return;

         int shiftFromCurrent = firstBarTS - targetFirstBarTS;
         ResetLastError();
         if(ChartNavigate(0, CHART_CURRENT_POS, shiftFromCurrent))
           {
            m_lastTargetRightBarTS = targetRightBarTS;
            return;
           }

         PrintFormat("CNavChartSync::SyncChartFromView drag ChartNavigate failed endShift=%d currentShift=%d targetFirst=%d targetRight=%d err=%d",
                     -targetRightBarTS, shiftFromCurrent, targetFirstBarTS, targetRightBarTS, GetLastError());
         return;
        }

      // For a single click, first try an absolute right-edge target.
      // CHART_END with a negative shift means: move left from the latest bar by
      // targetRightBarTS bars.  This avoids half-window drift after mini-map clicks.
      ResetLastError();
      if(ChartNavigate(0, CHART_END, -targetRightBarTS))
         return;

      if(firstBarTS >= 0 && firstBarTS < chartTotalBars)
        {
         int shiftFromCurrent = firstBarTS - targetFirstBarTS;
         ResetLastError();
         if(ChartNavigate(0, CHART_CURRENT_POS, shiftFromCurrent))
            return;

         PrintFormat("CNavChartSync::SyncChartFromView current-position ChartNavigate failed shift=%d targetFirst=%d targetRight=%d err=%d",
                     shiftFromCurrent, targetFirstBarTS, targetRightBarTS, GetLastError());
        }

      int shiftFromBegin = (chartTotalBars - 1) - targetFirstBarTS;
      if(shiftFromBegin < 0)
         shiftFromBegin = 0;

      ResetLastError();
      if(ChartNavigate(0, CHART_BEGIN, shiftFromBegin))
         return;
      else
         PrintFormat("CNavChartSync::SyncChartFromView ChartNavigate failed endShift=%d beginShift=%d targetFirst=%d targetRight=%d err=%d",
                     -targetRightBarTS, shiftFromBegin, targetFirstBarTS, targetRightBarTS, GetLastError());
     }

   //--- Return the normal, full chart-window width as a minimap fraction.
   //    Used only by viewport-box dragging, so the box can restore its normal
   //    size after leaving the clipped newest-edge/right-shift zone.
   double            ViewportWidthFraction(const int totalBars)
     {
      if(totalBars <= 0)
         return MIN_VIEW_RANGE;

      int chartTotalBars = Bars(_Symbol, _Period);
      if(chartTotalBars <= 0)
         chartTotalBars = totalBars;

      int bars = _ViewportBarsForNavigation(chartTotalBars);
      if(bars <= 0)
         return MIN_VIEW_RANGE;

      double rng = (double)bars / (double)totalBars;
      if(!MathIsValidNumber(rng) || rng < MIN_VIEW_RANGE)
         rng = MIN_VIEW_RANGE;
      if(rng > 1.0)
         rng = 1.0;
      return rng;
     }

   //--- Predict viewport after a wheel-scroll step (pre-render before ChartNavigate fires).
   //
   //    barFrom - series index of map's oldest bar (same meaning as above)
   void              PredictFromScroll(double &viewStart, double &viewEnd,
                                       int totalBars, int delta, int barFrom)
     {
      if(totalBars <= 0) return;

      int chartTotalBars = Bars(_Symbol, _Period);
      if(chartTotalBars <= 0)
         chartTotalBars = MathMax(barFrom + 1, totalBars);

      int firstBarTS = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
      int newFirst   = MathMax(0, firstBarTS - delta * SCROLL_STEP);
      if(newFirst >= chartTotalBars)
         newFirst = chartTotalBars - 1;

      int viewBars   = _ViewportBarsForSync(chartTotalBars, newFirst);
      if(viewBars <= 0)
         return;

      _ProjectChartWindowToMap(viewStart, viewEnd,
                               totalBars, barFrom,
                               newFirst, viewBars);
     }

   void              ClampPair(double &s, double &e)
     {
      double width = e - s;
      if(!MathIsValidNumber(width) || width < MIN_VIEW_RANGE) width = MIN_VIEW_RANGE;
      if(width > 1.0) width = 1.0;

      if(!MathIsValidNumber(s)) s = 0.0;
      if(!MathIsValidNumber(e)) e = s + width;

      if(s < 0.0)
        {
         s = 0.0;
         e = s + width;
         if(e > 1.0) e = 1.0;
         return;
        }

      if(e > 1.0)
        {
         e = 1.0;
         s = e - width;
         if(s < 0.0) s = 0.0;
         return;
        }

      if(e - s < MIN_VIEW_RANGE)
        {
         e = s + MIN_VIEW_RANGE;
         if(e > 1.0)
           {
            e = 1.0;
            s = 1.0 - MIN_VIEW_RANGE;
           }
        }
     }

   bool              IsNavigating()        { return m_isNavigating; }
   void              SetNavigating(bool v)
     {
      m_isNavigating = v;
      if(!v)
         m_lastTargetRightBarTS = -1;
     }

private:
   bool              _ProjectChartWindowToMap(double &viewStart,
                                                       double &viewEnd,
                                                       const int totalBars,
                                                       const int barFrom,
                                                       const int firstBarTS,
                                                       const int viewBars)
     {
      if(totalBars <= 0 || viewBars <= 0)
         return false;

      int barTo = barFrom - totalBars + 1;
      if(barTo < 0)
         barTo = 0;

      int rightBarTS = firstBarTS - viewBars + 1;
      if(rightBarTS < 0)
         rightBarTS = 0;

      // Intersect two series-index intervals:
      // map  = [barTo .. barFrom], view = [rightBarTS .. firstBarTS],
      // where the left/old edge has the larger series index.
      int intersectionOldest = (firstBarTS < barFrom ? firstBarTS : barFrom);
      int intersectionNewest = (rightBarTS > barTo ? rightBarTS : barTo);

      if(intersectionNewest > intersectionOldest)
        {
         // No overlap.  Park the normalized box at the nearest map edge; the
         // caller can suppress drawing through its inRange flag.
         if(rightBarTS > barFrom)
           {
            viewStart = 0.0;
            viewEnd   = MIN_VIEW_RANGE;
           }
         else
           {
            viewEnd   = 1.0;
            viewStart = 1.0 - MIN_VIEW_RANGE;
           }
         ClampPair(viewStart, viewEnd);
         return false;
        }

      double ns = (double)(barFrom - intersectionOldest) / (double)totalBars;
      double ne = (double)(barFrom - intersectionNewest + 1) / (double)totalBars;

      // Passive chart->map synchronization must preserve a very narrow M1
      // viewport.  ClampPair() intentionally inflates widths to MIN_VIEW_RANGE
      // for manual dragging usability, but here that turns a dense M1 view into
      // a visible block.  The overlay renderer already enforces a 2-pixel minimum.
      _ClampProjectedPair(ns, ne, totalBars);
      viewStart = ns;
      viewEnd   = ne;
      return true;
     }

   void              _ClampProjectedPair(double &s, double &e, const int totalBars)
     {
      if(!MathIsValidNumber(s)) s = 0.0;
      if(!MathIsValidNumber(e)) e = s;

      if(s > e)
        {
         double tmp = s;
         s = e;
         e = tmp;
        }

      if(s < 0.0) s = 0.0;
      if(e > 1.0) e = 1.0;

      if(e <= s)
        {
         double minOneBar = (totalBars > 0 ? 1.0 / (double)totalBars : 0.000001);
         if(minOneBar <= 0.0 || !MathIsValidNumber(minOneBar))
            minOneBar = 0.000001;

         e = s + minOneBar;
         if(e > 1.0)
           {
            e = 1.0;
            s = e - minOneBar;
            if(s < 0.0) s = 0.0;
           }
        }
     }

   int               _SafeVisibleBars(const int chartTotalBars)
     {
      int bars = (int)ChartGetInteger(0, CHART_VISIBLE_BARS);
      if(bars <= 0)
         return 0;
      if(bars > chartTotalBars)
         bars = chartTotalBars;
      return bars;
     }

   int               _SafeWidthInBars(const int chartTotalBars)
     {
      int bars = (int)ChartGetInteger(0, CHART_WIDTH_IN_BARS);
      if(bars <= 0)
         bars = _SafeVisibleBars(chartTotalBars);
      if(bars <= 0)
         return 0;
      if(bars > chartTotalBars)
         bars = chartTotalBars;
      return bars;
     }

   int               _ViewportBarsForSync(const int chartTotalBars, const int firstBarTS)
     {
      int widthBars   = _SafeWidthInBars(chartTotalBars);
      int visibleBars = _SafeVisibleBars(chartTotalBars);
      if(widthBars <= 0)
         return visibleBars;
      if(visibleBars <= 0)
         return widthBars;

      bool chartShift = (bool)ChartGetInteger(0, CHART_SHIFT);
      int rightByFullWidth = firstBarTS - widthBars + 1;

      // Keep the box width tied to chart zoom.  Use the clipped visible width
      // only at the newest edge, where the chart shift area can contain empty space.
      if(chartShift && rightByFullWidth < 0)
         return visibleBars;

      return widthBars;
     }

   int               _ViewportBarsForNavigation(const int chartTotalBars)
     {
      int widthBars = _SafeWidthInBars(chartTotalBars);
      if(widthBars > 0)
         return widthBars;
      return _SafeVisibleBars(chartTotalBars);
     }
  };

//+------------------------------------------------------------------+
//| Geometry                                                        |
//+------------------------------------------------------------------+

// Owns the mini-map rectangle and hit-testing.
// This keeps resize/drag math outside the renderer.
class CNavGeometryLight
  {
private:
   int               m_x;
   int               m_y;
   int               m_w;
   int               m_h;

   int               _MinW() const
     {
      return MIN_W;
     }

   int               _MinH() const
     {
      int h = MIN_H;
      if(h < 18) h = 18;
      return h;
     }

public:
                     CNavGeometryLight() : m_x(0), m_y(0), m_w(0), m_h(0) {}

   void              CalcInitial(const int margin, const int height,
                                 int chartW = 0, int chartH = 0)
     {
      int cw = (chartW > 0) ? chartW : (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      int ch = (chartH > 0) ? chartH : (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

      if(cw < MIN_W) cw = MIN_W;
      if(ch < MIN_H) ch = MIN_H;

      int h = MathMax(_MinH(), height);
      int x = MathMax(0, margin);
      int y = ch - h - MathMax(0, margin);
      int w = cw - 2 * MathMax(0, margin);

      m_x = x;
      m_y = MathMax(0, y);
      m_w = MathMax(_MinW(), w);
      m_h = h;
      ClampToChart();
     }

   void              ClampToChart()
     {
      int cw = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      int ch = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

      int minW = _MinW();
      int minH = _MinH();

      if(cw > 0)
        {
         int effMinW = MathMin(minW, cw);
         m_w = MathMax(effMinW, MathMin(m_w, cw));
         m_x = MathMax(0, MathMin(m_x, cw - m_w));
        }
      else
         m_w = MathMax(minW, m_w);

      if(ch > 0)
        {
         int effMinH = MathMin(minH, ch);
         m_h = MathMax(effMinH, MathMin(m_h, ch));
         m_y = MathMax(0, MathMin(m_y, ch - m_h));
        }
      else
         m_h = MathMax(minH, m_h);
     }

   bool              HitTest(const int mx, const int my,
                             const double viewStart,
                             const double viewEnd,
                             ENUM_INTERACT &result)
     {
      bool inX = (mx > m_x && mx < m_x + m_w);
      bool inY = (my > m_y && my < m_y + m_h);

      int cornerOut = 22;
      int cornerIn  = 14;

      bool nearX = (mx >= m_x - RZ && mx <= m_x + m_w + RZ);
      bool nearY = (my >= m_y - RZ && my <= m_y + m_h + RZ);

      bool cornerTL = (mx >= m_x - cornerOut       && mx <= m_x + cornerIn &&
                       my >= m_y - cornerOut       && my <= m_y + cornerIn);
      bool cornerTR = (mx >= m_x + m_w - cornerIn  && mx <= m_x + m_w + cornerOut &&
                       my >= m_y - cornerOut       && my <= m_y + cornerIn);
      bool cornerBL = (mx >= m_x - cornerOut       && mx <= m_x + cornerIn &&
                       my >= m_y + m_h - cornerIn  && my <= m_y + m_h + cornerOut);
      bool cornerBR = (mx >= m_x + m_w - cornerIn  && mx <= m_x + m_w + cornerOut &&
                       my >= m_y + m_h - cornerIn  && my <= m_y + m_h + cornerOut);

      if(cornerTL) { result = IA_RESIZE_TL; return true; }
      if(cornerTR) { result = IA_RESIZE_TR; return true; }
      if(cornerBL) { result = IA_RESIZE_BL; return true; }
      if(cornerBR) { result = IA_RESIZE_BR; return true; }

      bool onL = (mx >= m_x - RZ    && mx <= m_x + RZ       && nearY);
      bool onR = (mx >  m_x + m_w  && mx <= m_x + m_w + RZ && nearY);
      bool onT = (my >= m_y - RZ    && my <= m_y + RZ       && nearX);
      bool onB = (my >= m_y + m_h  && my <= m_y + m_h + RZ_TOP && nearX);

      if(onT && inX) { result = IA_RESIZE_T; return true; }
      if(onB && inX) { result = IA_RESIZE_B; return true; }
      if(onL && inY) { result = IA_RESIZE_L; return true; }
      if(onR && inY) { result = IA_RESIZE_R; return true; }

      if(inX && inY)
        {
         double pct = (m_w > 0) ? (double)(mx - m_x) / (double)m_w : 0.0;
         result = (pct >= viewStart && pct <= viewEnd) ? IA_DRAG_VIEWPORT : IA_MOVE;
         return true;
        }

      result = IA_NONE;
      return false;
     }

   int               X()    const { return m_x; }
   int               Y()    const { return m_y; }
   int               W()    const { return m_w; }
   int               H()    const { return m_h; }
   int               MinW() const { return _MinW(); }
   int               MinH() const { return _MinH(); }

   void              SetPos(const int x, const int y)
     {
      m_x = x;
      m_y = y;
     }

   void              SetSize(const int w, const int h)
     {
      m_w = MathMax(_MinW(), w);
      m_h = MathMax(_MinH(), h);
     }
  };

//+------------------------------------------------------------------+
//| Vertical Line Overlay                                           |
//+------------------------------------------------------------------+

// Projects only OBJ_VLINE objects to the mini-map.
// Other chart objects are deliberately ignored to keep the free light version small.
class CNavVLineOverlayLight
  {
private:
   static bool       _IsInternalName(const string name)
     {
      if(name == "") return true;
      if(StringFind(name, "ChartNavigatorMT5Light_") == 0) return true;
      if(StringFind(name, "NavRibbon_") == 0) return true;
      if(StringFind(name, "NavDateEdit_") == 0) return true;
      return false;
     }

   static int        _Clamp255(const int value)
     {
      if(value < 0)   return 0;
      if(value > 255) return 255;
      return value;
     }

   static int        _ClampWidth(const int value)
     {
      if(value < 1) return 1;
      if(value > 5) return 5;
      return value;
     }

   static int        _NearestLoadedBarIndex(CNavDataProvider &dp,
                                            const datetime t)
     {
      int n = dp.TotalBars();
      if(n <= 0 || t <= 0)
         return -1;

      datetime first = dp.TimeFirst();
      datetime last  = dp.TimeLast();
      if(first <= 0 || last <= 0)
         return -1;

      int ps = PeriodSeconds(_Period);
      if(ps <= 0) ps = 60;

      // Allow a small tolerance at the newest edge for objects whose time falls
      // inside the current not-yet-closed candle.
      if(t < first || t > last + ps)
         return -1;

      int lo = 0;
      int hi = n - 1;
      while(lo < hi)
        {
         int mid = (lo + hi) / 2;
         datetime mt = dp.TimeAt(mid);
         if(mt < t)
            lo = mid + 1;
         else
            hi = mid;
        }

      int idx = lo;
      if(idx > 0)
        {
         datetime a = dp.TimeAt(idx - 1);
         datetime b = dp.TimeAt(idx);
         long da = (long)t - (long)a;
         long db = (long)b - (long)t;
         if(da < 0) da = -da;
         if(db < 0) db = -db;
         if(da <= db)
            idx--;
        }

      if(idx < 0) idx = 0;
      if(idx >= n) idx = n - 1;
      return idx;
     }

   static int        _TX(CNavDataProvider &dp,
                         const datetime t,
                         const int winW)
     {
      int n = dp.TotalBars();
      if(n <= 1 || winW <= 1)
         return -1;

      int idx = _NearestLoadedBarIndex(dp, t);
      if(idx < 0)
         return -1;

      int x = (int)MathRound((double)idx / (double)(n - 1) * (double)(winW - 1));
      if(x < 0 || x >= winW)
         return -1;
      return x;
     }

public:
   static void       Draw(CCanvas &cv,
                          CNavDataProvider &dp,
                          const int winW,
                          const int winH)
     {
      if(!InpShowVerticalLines)
         return;
      if(winW <= 0 || winH <= 0 || dp.TotalBars() <= 1)
         return;

      int opacity = _Clamp255(InpVLineOpacity);
      if(opacity <= 0)
         return;

      int width = _ClampWidth(InpVLineWidth);
      int half = width / 2;

      int total = ObjectsTotal(0, -1, -1);
      for(int i = 0; i < total; i++)
        {
         string name = ObjectName(0, i, -1, -1);
         if(_IsInternalName(name))
            continue;

         long typeRaw = 0;
         if(!ObjectGetInteger(0, name, OBJPROP_TYPE, 0, typeRaw))
            continue;
         if((ENUM_OBJECT)typeRaw != OBJ_VLINE)
            continue;

         long timeRaw = 0;
         if(!ObjectGetInteger(0, name, OBJPROP_TIME, 0, timeRaw))
            continue;

         int x = _TX(dp, (datetime)timeRaw, winW);
         if(x < 0 || x >= winW)
            continue;

         color lineColor = InpVLineColor;
         if(InpVLineUseObjectColor)
           {
            long colorRaw = (long)InpVLineColor;
            if(ObjectGetInteger(0, name, OBJPROP_COLOR, 0, colorRaw))
               lineColor = (color)colorRaw;
           }
         if(lineColor == clrNONE)
            lineColor = InpVLineColor;

         uint argb = ColorToARGB(lineColor, opacity);
         for(int dx = -half; dx <= half; dx++)
           {
            int px = x + dx;
            if(px >= 0 && px < winW)
               cv.LineVertical(px, 0, winH - 1, argb);
           }
        }
     }
  };

//+------------------------------------------------------------------+
//| Interaction                                                     |
//+------------------------------------------------------------------+

// Small mouse-state machine for viewport dragging and mini-map resizing.
class CNavInteractionLight
  {
private:
   ENUM_INTERACT     m_state;
   int               m_startMX;
   int               m_startMY;
   int               m_startWX;
   int               m_startWY;
   int               m_startWW;
   int               m_startWH;
   double            m_startVS;
   double            m_startVE;
   bool              m_hoverEdge;
   ENUM_INTERACT     m_hoverMode;

public:
                     CNavInteractionLight()
     : m_state(IA_NONE),
       m_startMX(0), m_startMY(0), m_startWX(0), m_startWY(0),
       m_startWW(0), m_startWH(0), m_startVS(0.0), m_startVE(0.2),
       m_hoverEdge(false), m_hoverMode(IA_NONE) {}

   bool              OnMouseMove(const int mx,
                                 const int my,
                                 const bool leftDown,
                                 CNavGeometryLight &geom,
                                 CNavChartSync &sync,
                                 const int totalBars,
                                 double &viewStart,
                                 double &viewEnd,
                                 bool &needFullRebuild,
                                 bool &widthChanged,
                                 bool &heightChanged)
     {
      needFullRebuild = false;
      widthChanged    = false;
      heightChanged   = false;

      if(m_state != IA_NONE && leftDown)
        {
         int dx = mx - m_startMX;
         int dy = my - m_startMY;
         int nx = m_startWX;
         int ny = m_startWY;
         int nw = m_startWW;
         int nh = m_startWH;

         switch(m_state)
           {
            case IA_RESIZE_T:
               ny = m_startWY + dy; nh = m_startWH - dy; break;
            case IA_RESIZE_B:
               nh = m_startWH + dy; break;
            case IA_RESIZE_L:
               nx = m_startWX + dx; nw = m_startWW - dx; break;
            case IA_RESIZE_R:
               nw = m_startWW + dx; break;
            case IA_RESIZE_TL:
               nx = m_startWX + dx; nw = m_startWW - dx;
               ny = m_startWY + dy; nh = m_startWH - dy; break;
            case IA_RESIZE_TR:
               nw = m_startWW + dx;
               ny = m_startWY + dy; nh = m_startWH - dy; break;
            case IA_RESIZE_BL:
               nx = m_startWX + dx; nw = m_startWW - dx;
               nh = m_startWH + dy; break;
            case IA_RESIZE_BR:
               nw = m_startWW + dx; nh = m_startWH + dy; break;
            case IA_DRAG_VIEWPORT:
              {
               double centerPct = (geom.W() > 0) ? (double)(mx - geom.X()) / (double)geom.W() : 0.0;
               if(centerPct < 0.0) centerPct = 0.0;
               if(centerPct > 1.0) centerPct = 1.0;

               double clippedRng = m_startVE - m_startVS;
               if(!MathIsValidNumber(clippedRng) || clippedRng < MIN_VIEW_RANGE)
                  clippedRng = viewEnd - viewStart;
               if(!MathIsValidNumber(clippedRng) || clippedRng < MIN_VIEW_RANGE)
                  clippedRng = MIN_VIEW_RANGE;

               double fullRng = sync.ViewportWidthFraction(totalBars);
               if(!MathIsValidNumber(fullRng) || fullRng < clippedRng)
                  fullRng = clippedRng;
               if(fullRng > 1.0)
                  fullRng = 1.0;

               double rng = clippedRng;
               double ns = centerPct - rng * 0.5;
               if(ns < 0.0) ns = 0.0;
               if(ns > 1.0 - MIN_VIEW_RANGE) ns = 1.0 - MIN_VIEW_RANGE;

               bool startedAtRightEdge = (m_startVE >= 1.0 - VIEW_TOLERANCE);
               double restoreStart = 1.0 - fullRng;

               if(startedAtRightEdge && fullRng > clippedRng + VIEW_TOLERANCE)
                 {
                  if(ns > restoreStart)
                    {
                     double ne = 1.0;
                     if(ne - ns < MIN_VIEW_RANGE)
                        ns = 1.0 - MIN_VIEW_RANGE;
                     viewStart = ns;
                     viewEnd   = ne;
                     return true;
                    }
                  rng = fullRng;
                 }

               double ne = ns + rng;
               sync.ClampPair(ns, ne);
               viewStart = ns;
               viewEnd   = ne;
               return true;
              }
            default:
               return false;
           }

         int cw = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
         int ch = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
         if(cw <= 0) cw = geom.X() + geom.W();
         if(ch <= 0) ch = geom.Y() + geom.H();

         int minW = geom.MinW();
         int minH = geom.MinH();

         if(nw < minW)
           {
            if(nx != m_startWX)
               nx = m_startWX + m_startWW - minW;
            nw = minW;
           }
         if(nh < minH)
           {
            if(ny != m_startWY)
               ny = m_startWY + m_startWH - minH;
            nh = minH;
           }

         nx = MathMax(0, MathMin(nx, cw - minW));
         ny = MathMax(0, MathMin(ny, ch - minH));
         nw = MathMax(minW, MathMin(nw, cw - nx));
         nh = MathMax(minH, MathMin(nh, ch - ny));

         int oldW = geom.W();
         int oldH = geom.H();

         geom.SetPos(nx, ny);
         geom.SetSize(nw, nh);

         widthChanged  = (geom.W() != oldW);
         heightChanged = (geom.H() != oldH);
         return true;
        }

      if(!leftDown && m_state != IA_NONE)
        {
         bool doRebuild = _IsResize(m_state);
         m_state = IA_NONE;
         sync.SetNavigating(false);
         if(doRebuild)
            needFullRebuild = true;
         return true;
        }

      if(!leftDown)
        {
         ENUM_INTERACT ht;
         geom.HitTest(mx, my, viewStart, viewEnd, ht);
         bool edge = _IsResize(ht);
         ENUM_INTERACT hoverMode = edge ? ht : IA_NONE;

         if(edge != m_hoverEdge || hoverMode != m_hoverMode)
           {
            m_hoverEdge = edge;
            m_hoverMode = hoverMode;
            return true;
           }
         return false;
        }

      if(leftDown && m_state == IA_NONE)
        {
         ENUM_INTERACT ht;
         if(!geom.HitTest(mx, my, viewStart, viewEnd, ht))
            return false;
         if(ht == IA_NONE)
            return false;

         m_state   = ht;
         m_startMX = mx;
         m_startMY = my;
         m_startWX = geom.X();
         m_startWY = geom.Y();
         m_startWW = geom.W();
         m_startWH = geom.H();
         m_startVS = viewStart;
         m_startVE = viewEnd;

         if(ht == IA_MOVE || ht == IA_DRAG_VIEWPORT)
           {
            sync.SetNavigating(true);

            double clickPct = (geom.W() > 0) ? (double)(mx - geom.X()) / (double)geom.W() : 0.0;
            if(clickPct < 0.0) clickPct = 0.0;
            if(clickPct > 1.0) clickPct = 1.0;

            double rng = viewEnd - viewStart;
            double fullRng = sync.ViewportWidthFraction(totalBars);
            if(MathIsValidNumber(fullRng) && fullRng > rng)
               rng = fullRng;
            if(!MathIsValidNumber(rng) || rng < MIN_VIEW_RANGE)
               rng = MIN_VIEW_RANGE;
            if(rng > 1.0)
               rng = 1.0;

            double ns = clickPct - rng * 0.5;
            double ne = ns + rng;
            sync.ClampPair(ns, ne);

            viewStart = ns;
            viewEnd   = ne;
            m_state   = IA_DRAG_VIEWPORT;
            m_startMX = mx;
            m_startMY = my;
            m_startVS = viewStart;
            m_startVE = viewEnd;
            return true;
           }

         return true;
        }

      return false;
     }

   ENUM_INTERACT     State()     const { return m_state; }
   bool              HoverEdge() const { return m_hoverEdge; }
   ENUM_INTERACT     HoverMode() const { return m_hoverMode; }
   bool              IsActive()  const { return m_state != IA_NONE; }

private:
   bool              _IsResize(const ENUM_INTERACT mode) const
     {
      return (mode >= IA_RESIZE_T && mode <= IA_RESIZE_BR);
     }
  };

//+------------------------------------------------------------------+
//| Renderer                                                        |
//+------------------------------------------------------------------+

// Draws the whole mini-map on a single OBJ_BITMAP_LABEL-backed canvas.
// In MT5, this object may have to be recreated after external object creation
// when the mini-map must stay above user drawings.
class CNavRendererLight
  {
private:
   CCanvas           m_canvas;
   string            m_canvasName;
   int               m_x;
   int               m_y;
   int               m_w;
   int               m_h;
   int               m_canvasCapW;
   int               m_canvasCapH;

   int               _GrowthCapacity(const int currentCap,
                                      const int need,
                                      const int chartLimit)
     {
      if(need <= currentCap)
         return currentCap;

      int cap = currentCap;
      if(cap <= 0)
         cap = need;

      int step = MathMax(96, cap / 2);
      cap = MathMax(need, cap + step);

      if(chartLimit > 0)
        {
         cap = MathMin(cap, chartLimit);
         if(cap < need)
            cap = need;
        }
      return cap;
     }

   bool              _ReserveCanvasCapacity(const int needW,
                                            const int needH,
                                            const bool coverImmediately)
     {
      if(needW <= 0 || needH <= 0)
         return false;
      if(needW <= m_canvasCapW && needH <= m_canvasCapH)
         return true;

      int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
      int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);

      int newCapW = _GrowthCapacity(m_canvasCapW, needW, chartW);
      int newCapH = _GrowthCapacity(m_canvasCapH, needH, chartH);

      if(!m_canvas.Resize(newCapW, newCapH))
         return false;

      m_canvasCapW = newCapW;
      m_canvasCapH = newCapH;

      if(coverImmediately)
        {
         m_canvas.FillRectangle(0, 0, MathMax(0, newCapW - 1), MathMax(0, newCapH - 1),
                                ColorToARGB(NavThemeRibbonBg(), 255));
         m_canvas.Update(false);
        }
      return true;
     }

   void              _ApplyBitmapObjectProps()
     {
      if(m_canvasName == "" || ObjectFind(0, m_canvasName) < 0)
         return;

      ObjectSetInteger(0, m_canvasName, OBJPROP_CORNER,     CORNER_LEFT_UPPER);
      ObjectSetInteger(0, m_canvasName, OBJPROP_ANCHOR,     ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0, m_canvasName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, m_canvasName, OBJPROP_SELECTED,   false);
      ObjectSetInteger(0, m_canvasName, OBJPROP_HIDDEN,     true);
      ObjectSetInteger(0, m_canvasName, OBJPROP_BACK,       false);
      ObjectSetInteger(0, m_canvasName, OBJPROP_ZORDER,     1000000);
      ObjectSetString(0,  m_canvasName, OBJPROP_TOOLTIP,    "\n");
      ObjectSetInteger(0, m_canvasName, OBJPROP_XDISTANCE,  m_x);
      ObjectSetInteger(0, m_canvasName, OBJPROP_YDISTANCE,  m_y);
      ObjectSetInteger(0, m_canvasName, OBJPROP_XSIZE,      m_w);
      ObjectSetInteger(0, m_canvasName, OBJPROP_YSIZE,      m_h);
     }

   bool              _ResizeModeHasLeft(const ENUM_INTERACT mode) const
     {
      return (mode == IA_RESIZE_L  || mode == IA_RESIZE_TL || mode == IA_RESIZE_BL);
     }

   bool              _ResizeModeHasRight(const ENUM_INTERACT mode) const
     {
      return (mode == IA_RESIZE_R  || mode == IA_RESIZE_TR || mode == IA_RESIZE_BR);
     }

   bool              _ResizeModeHasTop(const ENUM_INTERACT mode) const
     {
      return (mode == IA_RESIZE_T  || mode == IA_RESIZE_TL || mode == IA_RESIZE_TR);
     }

   bool              _ResizeModeHasBottom(const ENUM_INTERACT mode) const
     {
      return (mode == IA_RESIZE_B  || mode == IA_RESIZE_BL || mode == IA_RESIZE_BR);
     }

   void              _DrawOuterBorder(const int winW,
                                      const int winH,
                                      const bool highlightEdges,
                                      const ENUM_INTERACT hoverMode)
     {
      if(winW <= 0 || winH <= 0)
         return;

      uint quiet = ColorToARGB(NavThemeEdge(false), 255);
      uint hot   = ColorToARGB(NavThemeHoverBrd(), 255);

      m_canvas.Rectangle(0, 0, winW - 1, winH - 1, quiet);

      bool left   = _ResizeModeHasLeft(hoverMode);
      bool right  = _ResizeModeHasRight(hoverMode);
      bool top    = _ResizeModeHasTop(hoverMode);
      bool bottom = _ResizeModeHasBottom(hoverMode);

      if(highlightEdges && hoverMode == IA_NONE)
        {
         left = true; right = true; top = true; bottom = true;
        }

      if(left)   m_canvas.LineVertical(0, 0, winH - 1, hot);
      if(right)  m_canvas.LineVertical(winW - 1, 0, winH - 1, hot);
      if(top)    m_canvas.LineHorizontal(0, winW - 1, 0, hot);
      if(bottom) m_canvas.LineHorizontal(0, winW - 1, winH - 1, hot);
     }

   void              _DrawCornerAccents(const int winW, const int winH)
     {
      int cs = 8;
      if(cs > winW - 1) cs = winW - 1;
      if(cs > winH - 1) cs = winH - 1;
      if(cs <= 0)
         return;

      uint ca = ColorToARGB(NavThemeCorner(false), 255);
      m_canvas.LineHorizontal(0,         cs,        0,        ca);
      m_canvas.LineVertical(  0,         0,         cs,       ca);
      m_canvas.LineHorizontal(winW-1-cs, winW-1,    0,        ca);
      m_canvas.LineVertical(  winW-1,    0,         cs,       ca);
      m_canvas.LineHorizontal(0,         cs,        winH-1,   ca);
      m_canvas.LineVertical(  0,         winH-1-cs, winH-1,   ca);
      m_canvas.LineHorizontal(winW-1-cs, winW-1,    winH-1,   ca);
      m_canvas.LineVertical(  winW-1,    winH-1-cs, winH-1,   ca);
     }

   void              _DrawViewport(const double viewStart,
                                   const double viewEnd,
                                   const int winW,
                                   const int winH,
                                   const bool showViewport,
                                   const bool drawFill)
     {
      if(!showViewport || winW <= 0 || winH <= 0)
         return;

      double vs = viewStart;
      double ve = viewEnd;
      if(!MathIsValidNumber(vs) || !MathIsValidNumber(ve))
         return;
      if(vs > ve)
        {
         double tmp = vs;
         vs = ve;
         ve = tmp;
        }
      if(vs < 0.0) vs = 0.0;
      if(ve > 1.0) ve = 1.0;
      if(ve <= vs)
         ve = MathMin(1.0, vs + MIN_VIEW_RANGE);

      int x1 = MathMax(0, MathMin((int)MathRound(vs * (double)winW), winW - 1));
      int x2 = MathMax(0, MathMin((int)MathRound(ve * (double)winW) - 1, winW - 1));
      if(x2 < x1)
         x2 = x1;

      uint fill = ColorToARGB(NavThemeViewportFill(), 255);
      uint brd  = ColorToARGB(NavThemeViewportBorder(), 255);

      if(drawFill)
        {
         if(x2 > x1 && winH > 2)
            m_canvas.FillRectangle(x1 + 1, 1, x2 - 1, winH - 2, fill);
         else
            m_canvas.FillRectangle(x1, 1, x2, winH - 2, fill);
        }

      // Explicit one-pixel rectangle.  Four separate lines are used instead of
      // relying on a helper so the top and bottom borders remain visible on all
      // terminal canvas builds.
      m_canvas.LineVertical(x1, 0, winH - 1, brd);
      m_canvas.LineVertical(x2, 0, winH - 1, brd);
      m_canvas.LineHorizontal(x1, x2, 0, brd);
      m_canvas.LineHorizontal(x1, x2, winH - 1, brd);
     }

public:
                     CNavRendererLight()
     : m_canvasName(""), m_x(0), m_y(0), m_w(0), m_h(0),
       m_canvasCapW(0), m_canvasCapH(0) {}

   bool              Create(const string name,
                            const int x,
                            const int y,
                            const int w,
                            const int h)
     {
      m_canvasName = name;
      m_x = x;
      m_y = y;
      m_w = w;
      m_h = h;

      ObjectDelete(0, name);
      if(!m_canvas.CreateBitmapLabel(0, 0, name, x, y, w, h))
         return false;

      m_canvasCapW = w;
      m_canvasCapH = h;
      _ApplyBitmapObjectProps();
      return true;
     }

   void              Destroy()
     {
      m_canvas.Destroy();
      m_canvasCapW = 0;
      m_canvasCapH = 0;
     }

   // MT5 can draw a newly created user object above an existing
   // OBJ_BITMAP_LABEL. To actually lift the mini-map above it,
   // ZORDER is not enough; the bitmap-label must be recreated after the external object.
   bool              RecreateTopLayer()
     {
      if(m_canvasName == "" || m_w <= 0 || m_h <= 0)
         return false;

      m_canvas.Destroy();
      ObjectDelete(0, m_canvasName);

      if(!m_canvas.CreateBitmapLabel(0, 0, m_canvasName, m_x, m_y, m_w, m_h))
         return false;

      m_canvasCapW = m_w;
      m_canvasCapH = m_h;
      _ApplyBitmapObjectProps();
      return true;
     }

   void              LiftToTop()
     {
      _ApplyBitmapObjectProps();
     }

   void              Move(const int x, const int y)
     {
      m_x = x;
      m_y = y;
      _ApplyBitmapObjectProps();
     }

   void              Resize(const int w, const int h)
     {
      if(w <= 0 || h <= 0)
         return;
      m_w = w;
      m_h = h;
      _ReserveCanvasCapacity(w, h, true);
      _ApplyBitmapObjectProps();
     }


   void              Draw(CNavWaveCache &wave,
                          CNavDataProvider &dp,
                          const double viewStart,
                          const double viewEnd,
                          const int winW,
                          const int winH,
                          const bool highlightEdges,
                          const bool showViewport = true,
                          const ENUM_INTERACT hoverMode = IA_NONE)
     {
      if(winW <= 0 || winH <= 0)
         return;

      m_w = winW;
      m_h = winH;
      _ReserveCanvasCapacity(winW, winH, false);
      _ApplyBitmapObjectProps();

      m_canvas.FillRectangle(0, 0, winW - 1, winH - 1,
                             ColorToARGB(NavThemeRibbonBg(), 255));

      // The viewport fill is drawn before the price line: the selected zone is
      // tinted, but the mini-chart itself remains visible and readable.
      _DrawViewport(viewStart, viewEnd, winW, winH, showViewport, true);

      int curW = MathMin(wave.Size(), winW);
      if(curW > 1)
        {
         int prevY = MathMax(PADDING_Y, MathMin(wave.GetY(0), winH - PADDING_Y));
         for(int x = 1; x < curW; x++)
           {
            int y = MathMax(PADDING_Y, MathMin(wave.GetY(x), winH - PADDING_Y));
            m_canvas.LineAA(x - 1, prevY, x, y, wave.GetColor(x));
            prevY = y;
           }
        }

      CNavVLineOverlayLight::Draw(m_canvas, dp, winW, winH);

      _DrawOuterBorder(winW, winH, highlightEdges, hoverMode);
      if(!highlightEdges)
         _DrawCornerAccents(winW, winH);

      // Draw the viewport border last.  The mini-map outer border also uses
      // y=0 and y=height-1; if it is drawn after the viewport, it hides the
      // upper and lower sides of the viewport rectangle.  Keeping this call last
      // makes all four sides of the box visible as a one-pixel frame.
      _DrawViewport(viewStart, viewEnd, winW, winH, showViewport, false);

      m_canvas.Update();
     }

   void              ShowLoading(const int winW, const int winH)
     {
      if(winW <= 0 || winH <= 0)
         return;

      m_w = winW;
      m_h = winH;
      _ReserveCanvasCapacity(winW, winH, false);
      _ApplyBitmapObjectProps();

      m_canvas.FillRectangle(0, 0, winW - 1, winH - 1,
                             ColorToARGB(NavThemeRibbonBg(), 255));
      m_canvas.FontSet(InpUiFontName, MAP_LOADING_FONT_SIZE, 0);
      m_canvas.TextOut(winW / 2, winH / 2, "  Loading...  ",
                       ColorToARGB(NavThemeDim(), 255), TA_CENTER | TA_VCENTER);
      _DrawOuterBorder(winW, winH, false, IA_NONE);
      _DrawCornerAccents(winW, winH);
      m_canvas.Update(true);
      ChartRedraw(0);
     }
  };

//+------------------------------------------------------------------+
//| Indicator entry point and event handling                         |
//+------------------------------------------------------------------+
#define NAV_LIGHT_CANVAS_NAME "ChartNavigatorMT5Light_Canvas"

CNavGeometryLight     g_geom;
CNavDataProvider      g_data;
CNavWaveCache         g_wave;
CNavChartSync         g_sync;
CNavInteractionLight  g_interact;
CNavRendererLight     g_renderer;

double                g_viewStart = 0.0;
double                g_viewEnd   = 0.2;
bool                  g_viewInRange = true;
bool                  g_isLoading = false;

string                g_lastSymbol = "";
int                   g_lastPeriod = 0;
int                   g_lastBars = 0;
datetime              g_lastNewestBarTime = 0;
int                   g_lastChartW = 0;
int                   g_lastChartH = 0;
int                   g_lastFirstVisibleBar = -1;
int                   g_lastChartWidthBars = -1;
int                   g_lastChartVisibleBars = -1;
bool                  g_mouseScrollBlocked = false;

bool                  g_mapHoverDateVisible = false;
datetime              g_mapHoverDateLastTime = 0;
int                   g_mapHoverDateLastX = -100000;
int                   g_mapHoverDateLastY = -100000;
int                   g_mapHoverDateLastW = 0;
string                g_mapHoverDateLastText = "";

long                  g_savedMouseMove = 0;
long                  g_savedMouseWheel = 0;
long                  g_savedMouseScroll = 1;
long                  g_savedChartForeground = 0;
long                  g_savedObjCreate = 0;
long                  g_savedObjDelete = 0;

//+------------------------------------------------------------------+
int _ChartW()
  {
   return (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
  }

//+------------------------------------------------------------------+
int _ChartH()
  {
   return (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
  }

//+------------------------------------------------------------------+
int _FirstVisibleBar()
  {
   return (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
  }

//+------------------------------------------------------------------+
int _ChartWidthInBars()
  {
   return (int)ChartGetInteger(0, CHART_WIDTH_IN_BARS);
  }

//+------------------------------------------------------------------+
int _ChartVisibleBars()
  {
   return (int)ChartGetInteger(0, CHART_VISIBLE_BARS);
  }

//+------------------------------------------------------------------+
void _RememberViewportState()
  {
   g_lastFirstVisibleBar = _FirstVisibleBar();
   g_lastChartWidthBars = _ChartWidthInBars();
   g_lastChartVisibleBars = _ChartVisibleBars();
  }

//+------------------------------------------------------------------+
bool _ReadChartFrame(int &cw, int &ch)
  {
   cw = _ChartW();
   ch = _ChartH();
   return (cw >= MIN_W && ch >= MIN_H);
  }

//+------------------------------------------------------------------+
void _RememberChartState()
  {
   g_lastBars = Bars(_Symbol, _Period);
   g_lastNewestBarTime = iTime(_Symbol, _Period, 0);
   _RememberViewportState();
  }

//+------------------------------------------------------------------+
void _SyncViewFromChart()
  {
   g_sync.SyncViewFromChart(g_viewStart,
                            g_viewEnd,
                            g_data.TotalBars(),
                            g_data.BarFrom(),
                            g_viewInRange);
  }

//+------------------------------------------------------------------+
void _SyncChartFromView()
  {
   g_sync.SyncChartFromView(g_viewStart,
                            g_viewEnd,
                            g_data.TotalBars(),
                            g_data.BarFrom(),
                            g_data.ChartTotalBars());
  }

//+------------------------------------------------------------------+
void _EffectiveDateRange(datetime &dateFrom, datetime &dateTo)
  {
   dateFrom = (InpMapDateFromEnabled && (long)InpMapDateFrom > 0) ? InpMapDateFrom : 0;
   dateTo   = (InpMapDateToEnabled   && (long)InpMapDateTo   > 0) ? InpMapDateTo   : 0;

   if(dateFrom > 0 && dateTo > 0 && dateFrom > dateTo)
     {
      datetime tmp = dateFrom;
      dateFrom = dateTo;
      dateTo = tmp;
     }
  }

//+------------------------------------------------------------------+
string _MapHoverDateBgName()
  {
   return "ChartNavigatorMT5Light_DateBg_" + IntegerToString(ChartID());
  }

//+------------------------------------------------------------------+
string _MapHoverDateTextName()
  {
   return "ChartNavigatorMT5Light_DateText_" + IntegerToString(ChartID());
  }

//+------------------------------------------------------------------+
bool _IsLightInternalObject(const string name)
  {
   if(name == "") return false;
   if(name == NAV_LIGHT_CANVAS_NAME) return true;
   if(name == _MapHoverDateBgName()) return true;
   if(name == _MapHoverDateTextName()) return true;
   if(StringFind(name, "ChartNavigatorMT5Light_") == 0) return true;
   return false;
  }

//+------------------------------------------------------------------+
bool _PointInMinimapHoverDateZone(const int mx, const int my)
  {
   if(g_isLoading || g_data.TotalBars() <= 0)
      return false;

   int winW = g_geom.W();
   int winH = g_geom.H();
   if(winW <= 1 || winH <= 1)
      return false;

   int pad = 24;
   return (mx >= g_geom.X() - pad && mx < g_geom.X() + winW + pad &&
           my >= g_geom.Y() - pad && my < g_geom.Y() + winH + pad);
  }

//+------------------------------------------------------------------+
bool _MapHoverDateFromMouseX(const int mx, datetime &outTime)
  {
   outTime = 0;

   int n = g_data.TotalBars();
   int w = g_geom.W();
   if(n <= 0 || w <= 1)
      return false;

   double pct = (double)(mx - g_geom.X()) / (double)(w - 1);
   if(pct < 0.0) pct = 0.0;
   if(pct > 1.0) pct = 1.0;

   int idx = (int)MathRound(pct * (double)(n - 1));
   if(idx < 0) idx = 0;
   if(idx >= n) idx = n - 1;

   outTime = g_data.TimeAt(idx);
   return (outTime > 0);
  }

//+------------------------------------------------------------------+
int _MapHoverDateFontSize()
  {
   int fs = InpMapHoverDateFont;
   if(fs < 6) fs = 6;
   if(fs > 32) fs = 32;
   return fs;
  }

//+------------------------------------------------------------------+
string _FormatMapHoverDate(const datetime t)
  {
   int ps = PeriodSeconds(_Period);
   if(ps >= 86400)
      return TimeToString(t, TIME_DATE);

   return TimeToString(t, TIME_DATE | TIME_MINUTES);
  }

//+------------------------------------------------------------------+
bool _EnsureMapHoverDateObjects()
  {
   string bg = _MapHoverDateBgName();
   string tx = _MapHoverDateTextName();

   if(ObjectFind(0, bg) < 0)
     {
      if(!ObjectCreate(0, bg, OBJ_RECTANGLE_LABEL, 0, 0, 0))
         return false;
     }

   if(ObjectFind(0, tx) < 0)
     {
      if(!ObjectCreate(0, tx, OBJ_LABEL, 0, 0, 0))
         return false;
     }

   ObjectSetInteger(0, bg, OBJPROP_CORNER,       CORNER_LEFT_UPPER);
   ObjectSetInteger(0, bg, OBJPROP_ANCHOR,       ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, bg, OBJPROP_SELECTABLE,   false);
   ObjectSetInteger(0, bg, OBJPROP_SELECTED,     false);
   ObjectSetInteger(0, bg, OBJPROP_HIDDEN,       true);
   ObjectSetInteger(0, bg, OBJPROP_BACK,         false);
   ObjectSetInteger(0, bg, OBJPROP_BORDER_TYPE,  BORDER_FLAT);
   ObjectSetInteger(0, bg, OBJPROP_STYLE,        STYLE_SOLID);
   ObjectSetInteger(0, bg, OBJPROP_WIDTH,        1);
   ObjectSetInteger(0, bg, OBJPROP_BGCOLOR,      InpMapHoverDateBg);
   ObjectSetInteger(0, bg, OBJPROP_COLOR,        InpMapHoverDateBorder);
   ObjectSetInteger(0, bg, OBJPROP_ZORDER,       1000008);
   ObjectSetString(0,  bg, OBJPROP_TOOLTIP,      "\n");

   ObjectSetInteger(0, tx, OBJPROP_CORNER,     CORNER_LEFT_UPPER);
   ObjectSetInteger(0, tx, OBJPROP_ANCHOR,     ANCHOR_CENTER);
   ObjectSetInteger(0, tx, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, tx, OBJPROP_SELECTED,   false);
   ObjectSetInteger(0, tx, OBJPROP_HIDDEN,     true);
   ObjectSetInteger(0, tx, OBJPROP_BACK,       false);
   ObjectSetInteger(0, tx, OBJPROP_ZORDER,     1000009);
   ObjectSetString(0,  tx, OBJPROP_TOOLTIP,    "\n");
   ObjectSetString(0,  tx, OBJPROP_FONT,       InpUiFontName);
   ObjectSetInteger(0, tx, OBJPROP_FONTSIZE,   _MapHoverDateFontSize());
   ObjectSetInteger(0, tx, OBJPROP_COLOR,      InpMapHoverDateText);

   return true;
  }

//+------------------------------------------------------------------+
void _PrepareMapHoverDateObjects()
  {
   if(!_EnsureMapHoverDateObjects())
      return;

   string bg = _MapHoverDateBgName();
   string tx = _MapHoverDateTextName();

   ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, -10000);
   ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, -10000);
   ObjectSetInteger(0, bg, OBJPROP_XSIZE,     1);
   ObjectSetInteger(0, bg, OBJPROP_YSIZE,     1);

   ObjectSetInteger(0, tx, OBJPROP_XDISTANCE, -10000);
   ObjectSetInteger(0, tx, OBJPROP_YDISTANCE, -10000);
   ObjectSetString(0,  tx, OBJPROP_TEXT,      "");

   g_mapHoverDateVisible = false;
   g_mapHoverDateLastTime = 0;
   g_mapHoverDateLastX = -100000;
   g_mapHoverDateLastY = -100000;
   g_mapHoverDateLastW = 0;
   g_mapHoverDateLastText = "";
  }

//+------------------------------------------------------------------+
void _HideMapHoverDate()
  {
   if(!g_mapHoverDateVisible)
      return;

   string bg = _MapHoverDateBgName();
   string tx = _MapHoverDateTextName();

   if(ObjectFind(0, bg) >= 0)
     {
      ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, -10000);
      ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, -10000);
      ObjectSetInteger(0, bg, OBJPROP_XSIZE,     1);
      ObjectSetInteger(0, bg, OBJPROP_YSIZE,     1);
     }

   if(ObjectFind(0, tx) >= 0)
     {
      ObjectSetInteger(0, tx, OBJPROP_XDISTANCE, -10000);
      ObjectSetInteger(0, tx, OBJPROP_YDISTANCE, -10000);
      ObjectSetString(0,  tx, OBJPROP_TEXT,      "");
     }

   g_mapHoverDateVisible = false;
   g_mapHoverDateLastTime = 0;
   g_mapHoverDateLastX = -100000;
   g_mapHoverDateLastY = -100000;
   g_mapHoverDateLastW = 0;
   g_mapHoverDateLastText = "";
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
void _DeleteMapHoverDate()
  {
   ObjectDelete(0, _MapHoverDateBgName());
   ObjectDelete(0, _MapHoverDateTextName());

   g_mapHoverDateVisible = false;
   g_mapHoverDateLastTime = 0;
   g_mapHoverDateLastX = -100000;
   g_mapHoverDateLastY = -100000;
   g_mapHoverDateLastW = 0;
   g_mapHoverDateLastText = "";
  }

//+------------------------------------------------------------------+
void _RestoreVisibleMapHoverDateOnTop()
  {
   if(!InpShowMapHoverDate || !g_mapHoverDateVisible || g_mapHoverDateLastText == "")
      return;

   int x = g_mapHoverDateLastX;
   int y = g_mapHoverDateLastY;
   int boxW = g_mapHoverDateLastW;
   string text = g_mapHoverDateLastText;

   if(boxW <= 0)
      return;

   int fontSize = _MapHoverDateFontSize();
   int padY = MathMax(2, fontSize / 4);
   int boxH = MathMax(14, fontSize + padY * 2 + 2);

   // If the canvas had to be recreated to stay above user objects,
   // the date label is recreated after the canvas to remain on top.
   ObjectDelete(0, _MapHoverDateBgName());
   ObjectDelete(0, _MapHoverDateTextName());

   if(!_EnsureMapHoverDateObjects())
      return;

   string bg = _MapHoverDateBgName();
   string tx = _MapHoverDateTextName();

   ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, bg, OBJPROP_XSIZE,     boxW);
   ObjectSetInteger(0, bg, OBJPROP_YSIZE,     boxH);

   ObjectSetInteger(0, tx, OBJPROP_XDISTANCE, x + boxW / 2);
   ObjectSetInteger(0, tx, OBJPROP_YDISTANCE, y + boxH / 2);
   ObjectSetString(0,  tx, OBJPROP_TEXT,      text);

   g_mapHoverDateVisible = true;
  }

//+------------------------------------------------------------------+
void _UpdateMapHoverDate(const int mx, const int my)
  {
   if(!InpShowMapHoverDate)
     {
      _HideMapHoverDate();
      return;
     }

   datetime t = 0;
   if(!_PointInMinimapHoverDateZone(mx, my) || !_MapHoverDateFromMouseX(mx, t))
     {
      _HideMapHoverDate();
      return;
     }

   string text = _FormatMapHoverDate(t);
   if(text == "")
     {
      _HideMapHoverDate();
      return;
     }

   int fontSize = _MapHoverDateFontSize();
   int padX = MathMax(6, fontSize / 2 + 2);
   int padY = MathMax(2, fontSize / 4);
   int charW = MathMax(5, (fontSize * 2) / 3);
   int boxW = MathMax(1, StringLen(text) * charW + padX * 2);
   int boxH = MathMax(14, fontSize + padY * 2 + 2);

   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   if(chartW <= 0) chartW = g_geom.X() + g_geom.W();
   if(chartH <= 0) chartH = g_geom.Y() + g_geom.H();

   int offset = InpMapHoverDateOffset;
   if(offset < 0) offset = 0;
   if(offset > 40) offset = 40;

   int x = mx - boxW / 2;
   int y = g_geom.Y() - boxH - offset;

   if(y < 0)
      y = g_geom.Y() + offset;

   if(x < 0) x = 0;
   if(x + boxW > chartW)
      x = MathMax(0, chartW - boxW);
   if(y + boxH > chartH)
      y = MathMax(0, chartH - boxH);

   bool changed = (!g_mapHoverDateVisible ||
                   t != g_mapHoverDateLastTime ||
                   x != g_mapHoverDateLastX ||
                   y != g_mapHoverDateLastY ||
                   boxW != g_mapHoverDateLastW ||
                   text != g_mapHoverDateLastText);
   if(!changed)
      return;

   if(!_EnsureMapHoverDateObjects())
      return;

   string bg = _MapHoverDateBgName();
   string tx = _MapHoverDateTextName();

   ObjectSetInteger(0, bg, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, bg, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, bg, OBJPROP_XSIZE,     boxW);
   ObjectSetInteger(0, bg, OBJPROP_YSIZE,     boxH);

   ObjectSetInteger(0, tx, OBJPROP_XDISTANCE, x + boxW / 2);
   ObjectSetInteger(0, tx, OBJPROP_YDISTANCE, y + boxH / 2);
   ObjectSetString(0,  tx, OBJPROP_TEXT,      text);

   g_mapHoverDateVisible = true;
   g_mapHoverDateLastTime = t;
   g_mapHoverDateLastX = x;
   g_mapHoverDateLastY = y;
   g_mapHoverDateLastW = boxW;
   g_mapHoverDateLastText = text;

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
void _DrawMap(const bool highlightEdges = false,
              const ENUM_INTERACT hoverMode = IA_NONE)
  {
   g_renderer.Draw(g_wave,
                   g_data,
                   g_viewStart,
                   g_viewEnd,
                   g_geom.W(),
                   g_geom.H(),
                   highlightEdges,
                   g_viewInRange,
                   hoverMode);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
bool _LoadDataAndRebuild()
  {
   datetime dateFrom = 0;
   datetime dateTo = 0;
   _EffectiveDateRange(dateFrom, dateTo);

   if(!g_data.Load(dateFrom, dateTo))
     {
      g_isLoading = true;
      g_renderer.ShowLoading(g_geom.W(), g_geom.H());
      return false;
     }

   g_isLoading = false;
   g_wave.Build(g_data, g_geom.W(), g_geom.H());
   _SyncViewFromChart();
   _RememberChartState();
   _DrawMap(false, IA_NONE);
   return true;
  }

//+------------------------------------------------------------------+
void _SetMouseScrollBlocked(const bool blocked)
  {
   if(blocked == g_mouseScrollBlocked)
      return;

   g_mouseScrollBlocked = blocked;
   ChartSetInteger(0, CHART_MOUSE_SCROLL, blocked ? false : g_savedMouseScroll);
  }

//+------------------------------------------------------------------+
void _ApplyChartFrameChange(const int chartW, const int chartH)
  {
   if(chartW <= 0 || chartH <= 0)
      return;

   bool frameChanged = (chartW != g_lastChartW || chartH != g_lastChartH);
   if(!frameChanged)
      return;

   int oldX = g_geom.X();
   int oldY = g_geom.Y();
   int oldW = g_geom.W();
   int oldH = g_geom.H();

   int distLeft = oldX;
   int distRight = (g_lastChartW > 0) ? g_lastChartW - (oldX + oldW) : InpInitMargin;
   int distTop = oldY;
   int distBottom = (g_lastChartH > 0) ? g_lastChartH - (oldY + oldH) : InpInitMargin;
   if(distRight < 0) distRight = 0;
   if(distBottom < 0) distBottom = 0;

   int newX = oldX;
   int newY = oldY;
   int newW = oldW;
   int newH = oldH;

   int margin = MathMax(0, InpInitMargin);
   int threshold = margin + 10;

   bool anchorLeft = (distLeft <= threshold);
   bool anchorRight = (distRight <= threshold);
   bool anchorTop = (distTop <= threshold);
   bool anchorBottom = (distBottom <= threshold);

   if(anchorLeft && anchorRight)
     {
      newX = margin;
      newW = chartW - 2 * margin;
     }
   else if(anchorRight)
      newX = chartW - margin - oldW;
   else if(anchorLeft)
      newX = margin;

   if(anchorTop && anchorBottom)
     {
      newY = margin;
      newH = chartH - 2 * margin;
     }
   else if(anchorBottom)
      newY = chartH - margin - oldH;
   else if(anchorTop)
      newY = margin;

   g_geom.SetPos(newX, newY);
   g_geom.SetSize(newW, newH);
   g_geom.ClampToChart();

   bool widthChanged = (g_geom.W() != oldW);
   bool heightChanged = (g_geom.H() != oldH);
   bool posChanged = (g_geom.X() != oldX || g_geom.Y() != oldY);

   g_lastChartW = chartW;
   g_lastChartH = chartH;

   if(posChanged)
      g_renderer.Move(g_geom.X(), g_geom.Y());

   if(widthChanged || heightChanged)
     {
      g_renderer.Resize(g_geom.W(), g_geom.H());
      g_wave.Build(g_data, g_geom.W(), g_geom.H());
      _SyncViewFromChart();
      _DrawMap(false, IA_NONE);
     }
   else if(posChanged)
      ChartRedraw(0);
  }

//+------------------------------------------------------------------+
void _RefreshIfChartViewportChanged()
  {
   if(g_interact.IsActive() || g_sync.IsNavigating())
      return;
   if(g_data.TotalBars() <= 0)
      return;

   int firstNow = _FirstVisibleBar();
   int widthBarsNow = _ChartWidthInBars();
   int visibleBarsNow = _ChartVisibleBars();

   bool changed = (firstNow != g_lastFirstVisibleBar ||
                   widthBarsNow != g_lastChartWidthBars ||
                   visibleBarsNow != g_lastChartVisibleBars);
   if(!changed)
      return;

   // Chart zoom changes CHART_WIDTH_IN_BARS, while CHART_FIRST_VISIBLE_BAR may
   // stay unchanged.  Track both values so the viewport box resizes immediately
   // after zoom-in / zoom-out buttons, mouse wheel zoom, or keyboard zoom.
   _SyncViewFromChart();
   _DrawMap(false, IA_NONE);
   _RememberViewportState();
  }

//+------------------------------------------------------------------+
void _RefreshIfChartDataChanged()
  {
   int barsNow = Bars(_Symbol, _Period);
   datetime newestNow = iTime(_Symbol, _Period, 0);

   if(g_isLoading)
     {
      _LoadDataAndRebuild();
      return;
     }

   if(_Symbol != g_lastSymbol || (int)_Period != g_lastPeriod)
     {
      g_lastSymbol = _Symbol;
      g_lastPeriod = (int)_Period;
      g_renderer.ShowLoading(g_geom.W(), g_geom.H());
      _LoadDataAndRebuild();
      return;
     }

   if(barsNow != g_lastBars || newestNow != g_lastNewestBarTime)
      _LoadDataAndRebuild();
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   g_savedMouseMove = ChartGetInteger(0, CHART_EVENT_MOUSE_MOVE);
   g_savedMouseWheel = ChartGetInteger(0, CHART_EVENT_MOUSE_WHEEL);
   g_savedMouseScroll = ChartGetInteger(0, CHART_MOUSE_SCROLL);
   g_savedChartForeground = ChartGetInteger(0, CHART_FOREGROUND);
   g_savedObjCreate = ChartGetInteger(0, CHART_EVENT_OBJECT_CREATE);
   g_savedObjDelete = ChartGetInteger(0, CHART_EVENT_OBJECT_DELETE);

   ChartSetInteger(0, CHART_FOREGROUND, false);
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   ChartSetInteger(0, CHART_EVENT_MOUSE_WHEEL, true);
   ChartSetInteger(0, CHART_EVENT_OBJECT_CREATE, true);
   ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, true);

   int chartW = 0;
   int chartH = 0;
   if(!_ReadChartFrame(chartW, chartH))
     {
      chartW = MathMax(MIN_W, _ChartW());
      chartH = MathMax(MIN_H, _ChartH());
     }

   g_lastChartW = chartW;
   g_lastChartH = chartH;
   g_lastSymbol = _Symbol;
   g_lastPeriod = (int)_Period;

   g_geom.CalcInitial(InpInitMargin, InpInitHeight, chartW, chartH);
   g_geom.ClampToChart();

   if(!g_renderer.Create(NAV_LIGHT_CANVAS_NAME,
                         g_geom.X(),
                         g_geom.Y(),
                         g_geom.W(),
                         g_geom.H()))
     {
      Print("Chart Navigator MT5 Light: failed to create canvas");
      return INIT_FAILED;
     }

   if(InpShowMapHoverDate)
      _PrepareMapHoverDateObjects();

   EventSetTimer(1);
   _LoadDataAndRebuild();
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   _SetMouseScrollBlocked(false);
   _DeleteMapHoverDate();
   g_renderer.Destroy();

   ChartSetInteger(0, CHART_MOUSE_SCROLL,        g_savedMouseScroll);
   ChartSetInteger(0, CHART_FOREGROUND,          g_savedChartForeground);
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE,    g_savedMouseMove);
   ChartSetInteger(0, CHART_EVENT_MOUSE_WHEEL,   g_savedMouseWheel);
   ChartSetInteger(0, CHART_EVENT_OBJECT_CREATE, g_savedObjCreate);
   ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, g_savedObjDelete);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
void OnTimer()
  {
   _RefreshIfChartDataChanged();

   int chartW = 0;
   int chartH = 0;
   if(_ReadChartFrame(chartW, chartH) && !g_interact.IsActive())
      _ApplyChartFrameChange(chartW, chartH);

   _RefreshIfChartViewportChanged();
  }

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
   _RefreshIfChartDataChanged();
   return rates_total;
  }

//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      if(g_interact.IsActive() || g_sync.IsNavigating())
         return;

      int chartW = 0;
      int chartH = 0;
      if(!_ReadChartFrame(chartW, chartH))
         return;

      bool frameChanged = (chartW != g_lastChartW || chartH != g_lastChartH);
      bool symbolChanged = (_Symbol != g_lastSymbol || (int)_Period != g_lastPeriod);

      int firstNow = _FirstVisibleBar();
      int widthBarsNow = _ChartWidthInBars();
      int visibleBarsNow = _ChartVisibleBars();
      bool viewportBarsChanged = (widthBarsNow != g_lastChartWidthBars ||
                                  visibleBarsNow != g_lastChartVisibleBars);

      if(symbolChanged)
        {
         g_lastSymbol = _Symbol;
         g_lastPeriod = (int)_Period;
         g_renderer.ShowLoading(g_geom.W(), g_geom.H());
         _LoadDataAndRebuild();
         return;
        }

      if(frameChanged)
         _ApplyChartFrameChange(chartW, chartH);

      if(firstNow != g_lastFirstVisibleBar || frameChanged || viewportBarsChanged)
        {
         _SyncViewFromChart();
         _DrawMap(false, IA_NONE);
         _RememberViewportState();
        }
      return;
     }

   if(id == CHARTEVENT_OBJECT_CREATE ||
      id == CHARTEVENT_OBJECT_DELETE ||
      id == CHARTEVENT_OBJECT_CHANGE ||
      id == CHARTEVENT_OBJECT_DRAG)
     {
      if(!_IsLightInternalObject(sparam))
        {
         // In MT5, a new external object can be drawn above the old canvas.
         // Recreate the bitmap-label only when an object is created; on drag/change
         // a mini-map redraw is enough if VLINE projection is enabled.
         if(id == CHARTEVENT_OBJECT_CREATE)
            g_renderer.RecreateTopLayer();
         else
            g_renderer.LiftToTop();

         if(id == CHARTEVENT_OBJECT_CREATE || InpShowVerticalLines)
            _DrawMap(false, IA_NONE);

         _RestoreVisibleMapHoverDateOnTop();
         ChartRedraw(0);
        }
      return;
     }

   if(id == CHARTEVENT_MOUSE_WHEEL)
     {
      // MT5 can send wheel events before the chart-change repaint has fully settled.
      // The timer is still the final safety net, but this gives quicker viewport feedback.
      _RefreshIfChartViewportChanged();
      return;
     }

   if(id != CHARTEVENT_MOUSE_MOVE)
      return;

   int mx = (int)lparam;
   int my = (int)dparam;
   int st = (int)StringToInteger(sparam);
   bool leftDown = ((st & 1) != 0);

   // The date must not disappear when the viewport box is clicked or dragged.
   // It is updated from the current cursor X and hidden only when the cursor leaves the mini-map area.
   _UpdateMapHoverDate(mx, my);

   bool needRebuild = false;
   bool widthChanged = false;
   bool heightChanged = false;
   ENUM_INTERACT stateBefore = g_interact.State();

   bool needDraw = g_interact.OnMouseMove(mx,
                                          my,
                                          leftDown,
                                          g_geom,
                                          g_sync,
                                          g_data.TotalBars(),
                                          g_viewStart,
                                          g_viewEnd,
                                          needRebuild,
                                          widthChanged,
                                          heightChanged);

   if(leftDown && g_interact.IsActive())
      _SetMouseScrollBlocked(true);
   else if(!leftDown && g_mouseScrollBlocked)
      _SetMouseScrollBlocked(false);

   if(!needDraw)
     {
      return;
     }

   if(g_interact.State() == IA_DRAG_VIEWPORT || stateBefore == IA_DRAG_VIEWPORT)
     {
      g_viewInRange = true;
      _SyncChartFromView();
      _DrawMap(false, IA_NONE);
      _RememberViewportState();
      return;
     }

   if(widthChanged || heightChanged || needRebuild)
     {
      g_renderer.Move(g_geom.X(), g_geom.Y());
      g_renderer.Resize(g_geom.W(), g_geom.H());
      g_wave.Build(g_data, g_geom.W(), g_geom.H());
      _SyncViewFromChart();
      _DrawMap(g_interact.HoverEdge(), g_interact.HoverMode());
      return;
     }

   if(!leftDown && stateBefore == IA_NONE && g_interact.State() == IA_NONE)
     {
      _DrawMap(g_interact.HoverEdge(), g_interact.HoverMode());
      return;
     }

  }
//+------------------------------------------------------------------+
