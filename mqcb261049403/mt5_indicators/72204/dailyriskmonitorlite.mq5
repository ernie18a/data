// Daily Risk Monitor Lite MT5
// Read-only account-level risk monitor indicator.
// Main responsibilities:
// 1) collect current calculation parameters,
// 2) refresh the risk snapshot on a timer,
// 3) forward the snapshot to the chart panel.

#property strict
#property indicator_chart_window
#property indicator_plots 0

#include "RiskCalc.mqh"
#include "PanelView.mqh"

input group "=== Risk Settings ==="
input double           InpDailyLossLimitMoney = 500.0;           // Daily loss limit in account currency. Used for Risk Usage % and status color.
input bool             InpIncludeCommission   = true;            // If true, include deal commission in Daily Realized.
input bool             InpIncludeSwap         = true;            // If true, include swap in Daily Realized and current Floating P/L.

input group "=== Day Range Settings ==="
input bool             InpUseBrokerDay        = true;            // If true, use broker/server day 00:00 as the daily reset point.
input int              InpManualDayStartHour  = 0;               // If broker day mode is off, use this server-time hour as the daily reset point.

input group "=== Panel Settings ==="
input ENUM_BASE_CORNER InpCorner              = CORNER_LEFT_UPPER; // Panel anchor corner on the chart.
input int              InpXOffset             = 16;                // Horizontal offset from the selected corner.
input int              InpYOffset             = 24;                // Vertical offset from the selected corner.
input int              InpFontSize            = 10;                // Base font size for panel labels and values.
input color            InpPanelBgColor        = clrBlack;          // Panel background color.
input color            InpSafeColor           = clrLimeGreen;      // Safe status color.
input color            InpWarnColor           = clrGold;           // Warning status color.
input color            InpDangerColor         = clrTomato;         // Danger status color.

// Single panel controller used by the indicator lifecycle.
CDRMLPanelView g_panel_view;

// Copies indicator input values into the calculation config structure used
// by the risk engine module.
void DRMLBuildCalcConfig(DRMLCalcConfig &config)
  {
   config.daily_loss_limit_money = InpDailyLossLimitMoney;
   config.include_commission = InpIncludeCommission;
   config.include_swap = InpIncludeSwap;
   config.use_broker_day = InpUseBrokerDay;
   config.manual_day_start_hour = InpManualDayStartHour;
  }

// Copies indicator input values into the panel config structure used
// by the on-chart UI module.
void DRMLBuildPanelConfig(DRMLPanelConfig &config)
  {
   config.corner = InpCorner;
   config.x_offset = InpXOffset;
   config.y_offset = InpYOffset;
   config.font_size = MathMax(InpFontSize,8);
   config.panel_bg_color = InpPanelBgColor;
   config.safe_color = InpSafeColor;
   config.warn_color = InpWarnColor;
   config.danger_color = InpDangerColor;
  }

// Rebuilds the latest risk snapshot and redraws the chart panel.
// This is called on initialization and on every timer tick.
void DRMLRefreshPanel()
  {
   DRMLCalcConfig calc_config;
   DRMLBuildCalcConfig(calc_config);

   DRMLRiskSnapshot snapshot;
   DRMLCalculateSnapshot(calc_config,snapshot);

   g_panel_view.Update(snapshot);
  }

// Indicator initialization:
// - set short name,
// - create panel objects,
// - enable mouse move events for custom drag,
// - start the timer-based refresh loop.
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME,"Daily Risk Monitor Lite");

   DRMLPanelConfig panel_config;
   DRMLBuildPanelConfig(panel_config);
   g_panel_view.Setup(ChartID(),panel_config);

   if(!g_panel_view.Create())
      return INIT_FAILED;

   ChartSetInteger(ChartID(),CHART_EVENT_MOUSE_MOVE,true);

   if(!EventSetTimer(1))
     {
      g_panel_view.Destroy();
      return INIT_FAILED;
     }

   DRMLRefreshPanel();
   return INIT_SUCCEEDED;
  }

// Indicator cleanup:
// - stop timer,
// - disable mouse move event forwarding,
// - remove every DRML_ chart object.
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ChartSetInteger(ChartID(),CHART_EVENT_MOUSE_MOVE,false);
   g_panel_view.Destroy();
  }

// Timer-driven refresh keeps the indicator logic simple and avoids
// recalculating the full history on every incoming tick.
void OnTimer()
  {
   DRMLRefreshPanel();
  }

// Forwards chart mouse events to the panel module so the custom UI can be
// dragged without relying on default MT5 object dragging.
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   g_panel_view.HandleChartEvent(id,lparam,dparam,sparam);
  }

// This indicator does not calculate buffers. Returning rates_total keeps the
// indicator interface valid while all visible output is handled by chart objects.
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
   return rates_total;
  }
