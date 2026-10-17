# Volatility Percentile [EXCAVO]

- url: https://www.tradingview.com/script/PGeQlzAW-Volatility-Percentile-EXCAVO/
- type: indicator
- pine_id: PUB;de488de127bd42a9a800c6477e286d04
- version: 1.0

## Description

ATR Percentile Rank with Four-State Volatility Classification and Trend Detection

The [i]Volatility Percentile[/i] measures where the current Average True Range stands
relative to its own history using a percentile rank. Rather than comparing ATR to a
fixed threshold, the indicator continuously evaluates whether current volatility is
low, normal, elevated, or extreme relative to the recent distribution - adapting
automatically to each instrument and timeframe.

This is not a basic ATR display. The percentile rank provides a normalized, context-aware
measure of volatility that remains comparable across assets, timeframes, and market cycles.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW TO USE[/b]

[b]Step 1[/b]  →  Add the indicator to a new pane. The histogram appears immediately,
              colored by the current volatility state (blue, gray, orange, or red).
[b]Step 2[/b]  →  Read the state from the histogram color and dashboard. Blue = Low,
              Gray = Normal, Orange = Elevated, Red = Extreme.
[b]Step 3[/b]  →  Note the percentile value. Above 80% indicates the current ATR is
              in the top 20% of its historical range - unusually wide price swings.
              Below 25% indicates unusually quiet conditions.
[b]Step 4[/b]  →  Check the Vol Trend row in the dashboard. RISING means the ATR is
              accelerating above its 20-bar average. FALLING means it is contracting.
[b]Step 5[/b]  →  Set up state-change alerts to receive notifications when volatility
              transitions between states on bar close.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW IT CALCULATES[/b]

[b]◆  ATR Percentile Rank[/b]
The indicator computes ATR(length) on each bar, then applies ta.percentrank() over
the lookback period. The percentile rank answers: "Out of the last N bars, what
percentage had an ATR lower than today's?" A result of 80 means 80% of recent bars
had a smaller ATR - current volatility is in the top 20% historically. The rank
always falls between 0 and 100, making it directly comparable across instruments.

[b]◆  Smoothing[/b]
The raw percentile rank is passed through a simple moving average of configurable
length (default 3 bars). This suppresses single-bar spikes that would otherwise
cause false state transitions. The smoothed value is used for both the histogram
display and state classification. Setting smoothing to 1 disables it entirely.

[b]◆  Four-State Classification[/b]
The smoothed percentile is compared against three configurable thresholds to assign
one of four states: Low (below 25th percentile), Normal (25th to 60th), Elevated
(60th to 80th), or Extreme (above 80th). State boundaries are user-adjustable,
allowing calibration for instruments that spend more time at elevated volatility
levels (such as crypto) versus lower-volatility markets.

[b]◆  Volatility Trend[/b]
A secondary calculation compares the current ATR to its 20-bar simple moving average.
ATR above 105% of the SMA is classified as RISING. ATR below 95% of the SMA is
classified as FALLING. Between those bands the trend is STABLE. This early-warning
layer detects momentum in volatility before a state boundary is crossed.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ WHAT MAKES IT DIFFERENT[/b]

[b]◆  Percentile Rank vs Fixed Threshold[/b]
A fixed ATR threshold (e.g., "ATR > 500 = high volatility") fails when applied across
different instruments or timeframes. The percentile approach self-calibrates: the same
indicator works on BTCUSD hourly and EURUSD daily without parameter changes, because
it measures volatility relative to the instrument's own recent history.

[b]◆  Four States Instead of Two[/b]
Most volatility filters use a binary high/low split. Separating Normal from Elevated
and Extreme provides more granular awareness: Elevated volatility may still be
tradable, while Extreme conditions warrant a different approach to position sizing.
The four-state model also makes transitions visible earlier - Elevated appears before
Extreme is reached.

[b]◆  Volatility Trend Detection[/b]
The Vol Trend layer detects whether ATR is currently accelerating or decelerating,
independently of which state it is in. It is possible to be in Normal state with
RISING trend (volatility building) or in Elevated state with FALLING trend
(volatility contracting back toward normal). This combination is visible only in the
dashboard and is not represented by the histogram color alone.

[b]◆  ATR / Price Ratio[/b]
The dashboard shows ATR expressed as a percentage of the current close price. This
normalized measure is directly comparable across instruments and useful for estimating
stop distance relative to price without manual calculation.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ DASHBOARD[/b]

Real-time panel showing current volatility conditions:
[list]
[*][b]State[/b] - active volatility state (LOW / NORMAL / ELEVATED / EXTREME), colored by type
[*][b]Percentile[/b] - current smoothed ATR percentile rank (0-100%)
[*][b]ATR[/b] - raw ATR value in price units for the current bar
[*][b]ATR / Price[/b] - ATR expressed as a percentage of close price
[*][b]Vol Trend[/b] - volatility momentum (RISING / FALLING / STABLE) vs 20-bar ATR average
[*][b]Lookback[/b] - active lookback period used for percentile calculation
[/list]

Legend table (bottom left) explains histogram colors and boundary lines. Both panels
toggle in Dashboard settings.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ SETTINGS[/b]

[b]Engine[/b]
[list]
[*][b]ATR Length[/b] - 14 bars (period for Average True Range calculation)
[*][b]Lookback Period[/b] - 200 bars (history window for percentile rank)
[*][b]Smoothing[/b] - 3 bars (applied to raw percentile; 1 = no smoothing)
[/list]

[b]State Thresholds[/b]
[list]
[*][b]Low / Normal[/b] - 25 (percentile boundary between Low and Normal states)
[*][b]Normal / Elevated[/b] - 60 (percentile boundary between Normal and Elevated states)
[*][b]Elevated / Extreme[/b] - 80 (percentile boundary between Elevated and Extreme states)
[/list]

[b]Visualization[/b]
[list]
[*][b]Low Vol Color[/b] - default blue
[*][b]Extreme Vol Color[/b] - default red
[*][b]Elevated Vol Color[/b] - default orange
[*][b]Show State Ribbon[/b] - OFF (colored markers at pane bottom)
[*][b]Background Highlight[/b] - ON (subtle tint matching active state)
[/list]

[b]Alerts[/b]
[list]
[*][b]JSON Alerts[/b] - OFF (enable for bot integration)
[/list]

[b]Dashboard[/b]
[list]
[*][b]Dashboard Position[/b] - Top Right
[*][b]Show Dashboard[/b] - ON
[*][b]Show Legend[/b] - ON
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ ALERTS[/b]

[list]
[*][b]Extreme Volatility[/b] - state transitioned to Extreme on bar close
[*][b]Elevated Volatility[/b] - state transitioned to Elevated on bar close
[*][b]Normal Volatility[/b] - state transitioned to Normal on bar close
[*][b]Low Volatility[/b] - state transitioned to Low on bar close
[*][b]Volatility State Change[/b] - any state transition detected on bar close
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Best regards,
EXCAVO

[quote]
[b]Disclaimer[/b]
Trading involves significant risk. This indicator is a technical analysis tool
and does not constitute financial advice, investment recommendations, or a
guarantee of future results. Past indicator behavior does not guarantee future
performance. Always use proper risk management and your own judgment.
[/quote]

## Source Code

````pine
// (c) EXCAVO
// This work is licensed under Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)
//
// Volatility Percentile [EXCAVO]
// -----------------------------------------------------------------------------
// ATR percentile rank with four-state volatility classification and trend detection.
//
//@version=6
indicator("Volatility Percentile [EXCAVO]", "EXCAVO Volatility Percentile",
     overlay       = false,
     max_bars_back = 500)

//-----------------------------------------------------------------------------}
// Inputs
//-----------------------------------------------------------------------------{
string GRP_ENG    = "Engine"
string GRP_THRESH = "State Thresholds"
string GRP_VIZ    = "Visualization"
string GRP_ALERTS = "Alerts"
string GRP_DASH   = "Dashboard"

int   i_atr_len  = input.int  (14,  "ATR Length",         minval = 1,  maxval = 100, group = GRP_ENG,
     tooltip = "Period for the Average True Range calculation.")
int   i_lookback = input.int  (200, "Lookback Period",     minval = 50, maxval = 500, group = GRP_ENG,
     tooltip = "Historical bars used to compute the ATR percentile rank. Higher values provide more historical context.")
int   i_smooth   = input.int  (3,   "Smoothing",           minval = 1,  maxval = 20,  group = GRP_ENG,
     tooltip = "Smoothing applied to the raw percentile. 1 = no smoothing.")

int   i_lo       = input.int  (25,  "Low / Normal",        minval = 5,  maxval = 40,  group = GRP_THRESH,
     tooltip = "Percentile boundary between Low and Normal volatility states.")
int   i_hi       = input.int  (60,  "Normal / Elevated",   minval = 41, maxval = 75,  group = GRP_THRESH,
     tooltip = "Percentile boundary between Normal and Elevated volatility states.")
int   i_ext      = input.int  (80,  "Elevated / Extreme",  minval = 76, maxval = 95,  group = GRP_THRESH,
     tooltip = "Percentile boundary between Elevated and Extreme volatility states.")

color C_BULL        = input.color(color.rgb(0,   60,  180), "Low Vol Color",       group = GRP_VIZ,
     tooltip = "Color for Low volatility state.")
color C_BEAR        = input.color(color.rgb(200, 40,  40),  "Extreme Vol Color",   group = GRP_VIZ,
     tooltip = "Color for Extreme volatility state.")
color C_SIGNAL      = input.color(color.rgb(255, 140, 0),   "Elevated Vol Color",  group = GRP_VIZ,
     tooltip = "Color for Elevated volatility state.")
bool  i_show_ribbon = input.bool (false,                    "Show State Ribbon",   group = GRP_VIZ,
     tooltip = "Colored marker strip at pane bottom showing volatility state history.")
bool  i_show_bg     = input.bool (true,                     "Background Highlight", group = GRP_VIZ,
     tooltip = "Subtle background tint matching the active volatility state.")

bool  i_json        = input.bool (false, "JSON Alerts (for bots)", group = GRP_ALERTS,
     tooltip = "Enable JSON-formatted alerts for automated trading systems.")

string i_dash_pos   = input.string("Top Right", "Dashboard Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH,
     tooltip = "Position of the dashboard panel.")
bool   i_show_dash  = input.bool(true, "Show Dashboard", group = GRP_DASH)
bool   i_show_lgnd  = input.bool(true, "Show Legend",    group = GRP_DASH)

//-----------------------------------------------------------------------------}
// Constants
//-----------------------------------------------------------------------------{
color C_NEUTRAL     = color.rgb(80,  80,  100)
color C_DASH_BG     = color.rgb(50,  53,  60)
color C_DASH_BORDER = color.rgb(80,  85,  95)
color C_DASH_BULL   = color.rgb(80,  140, 255)
color C_DASH_BEAR   = color.rgb(240, 70,  70)
color C_DASH_SIGNAL = color.rgb(255, 170, 50)
color C_DASH_SIDE   = color.rgb(150, 155, 170)

//-----------------------------------------------------------------------------}
// Core
//-----------------------------------------------------------------------------{
float atr_val  = ta.atr(i_atr_len)
float atr_pct  = close > 0 ? atr_val / close * 100 : 0.0
float pct_raw  = ta.percentrank(atr_val, i_lookback)
float pct_rank = i_smooth > 1 ? ta.sma(pct_raw, i_smooth) : pct_raw
float atr_sma  = ta.sma(atr_val, 20)

// Four-state classification: 0=Low, 1=Normal, 2=Elevated, 3=Extreme
int vol_state = pct_rank >= i_ext ? 3 : pct_rank >= i_hi ? 2 : pct_rank >= i_lo ? 1 : 0

color state_color = switch vol_state
    3 => C_BEAR
    2 => C_SIGNAL
    1 => C_NEUTRAL
    => C_BULL

string state_name = switch vol_state
    3 => "EXTREME"
    2 => "ELEVATED"
    1 => "NORMAL"
    => "LOW"

string vol_trend = atr_val > atr_sma * 1.05 ? "RISING" : atr_val < atr_sma * 0.95 ? "FALLING" : "STABLE"

//-----------------------------------------------------------------------------}
// Detection — State Change
//-----------------------------------------------------------------------------{
var int prev_state  = na
bool state_changed  = not na(prev_state) and vol_state != prev_state and barstate.isconfirmed
bool to_extreme     = state_changed and vol_state == 3
bool to_elevated    = state_changed and vol_state == 2
bool to_normal      = state_changed and vol_state == 1
bool to_low         = state_changed and vol_state == 0
prev_state         := vol_state

//-----------------------------------------------------------------------------}
// Visuals
//-----------------------------------------------------------------------------{
plot(pct_rank, "ATR Percentile",  color = state_color,                linewidth = 1, style = plot.style_columns, histbase = 0)
plot(i_ext,    "Extreme Bound",   color = color.new(C_BEAR,   40),    linewidth = 1)
plot(i_hi,     "Elevated Bound",  color = color.new(C_SIGNAL, 40),    linewidth = 1)
plot(i_lo,     "Low Bound",       color = color.new(C_BULL,   40),    linewidth = 1)
plotshape(i_show_ribbon, "Ribbon", shape.square, location.bottom, color = color.new(state_color, 40), size = size.small)
bgcolor(i_show_bg ? color.new(state_color, 93) : na)

//-----------------------------------------------------------------------------}
// Dashboard
//-----------------------------------------------------------------------------{
color dash_state_col = switch vol_state
    3 => C_DASH_BEAR
    2 => C_DASH_SIGNAL
    1 => C_DASH_SIDE
    => C_DASH_BULL

color dash_trend_col = vol_trend == "RISING" ? C_DASH_BEAR : vol_trend == "FALLING" ? C_DASH_BULL : C_NEUTRAL

string dash_pos = switch i_dash_pos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

if barstate.islast and i_show_dash
    var table dash = table.new(dash_pos, 2, 7,
         C_DASH_BG, C_DASH_BORDER, 2, C_DASH_BORDER, 2)

    table.cell(dash, 0, 0, "EXCAVO",
         text_color = C_DASH_BULL, text_size = size.normal, text_halign = text.align_left)
    table.cell(dash, 1, 0, "Vol Percentile",
         text_color = color.white, text_size = size.normal, text_halign = text.align_right)

    table.cell(dash, 0, 1, "State",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, state_name,
         text_color = dash_state_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 2, "Percentile",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, str.tostring(pct_rank, "0.0") + "%",
         text_color = dash_state_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 3, "ATR",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, str.tostring(atr_val, format.mintick),
         text_color = color.white, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 4, "ATR / Price",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(atr_pct, "0.00") + "%",
         text_color = color.white, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 5, "Vol Trend",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 5, vol_trend,
         text_color = dash_trend_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 6, "Lookback",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 6, str.tostring(i_lookback),
         text_color = color.white, text_size = size.small, text_halign = text.align_right)

//-----------------------------------------------------------------------------}
// Legend
//-----------------------------------------------------------------------------{
if barstate.islast and i_show_lgnd
    var table leg = table.new(position.bottom_left, 2, 7,
         C_DASH_BG, C_DASH_BORDER, 1, C_DASH_BORDER, 1)

    table.cell(leg, 0, 0, "LEGEND",
         text_color = C_DASH_BULL, text_size = size.normal, text_halign = text.align_center, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 0, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.merge_cells(leg, 0, 0, 1, 0)

    table.cell(leg, 0, 1, "▮", text_color = C_DASH_BEAR,   text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 1, "Extreme volatility",  text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 2, "▮", text_color = C_DASH_SIGNAL, text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 2, "Elevated volatility", text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 3, "▮", text_color = C_DASH_SIDE,   text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 3, "Normal volatility",   text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 4, "▮", text_color = C_DASH_BULL,   text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 4, "Low volatility",      text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 5, "━", text_color = color.new(color.gray, 40), text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 5, "State boundaries",    text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 6, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 6, "", text_size = size.small, bgcolor = C_DASH_BG)

//-----------------------------------------------------------------------------}
// Alerts
//-----------------------------------------------------------------------------{
alertcondition(to_extreme,  title = "Extreme Volatility",
     message = "EXCAVO Volatility Percentile: EXTREME volatility on {{ticker}} ({{interval}})")
alertcondition(to_elevated, title = "Elevated Volatility",
     message = "EXCAVO Volatility Percentile: ELEVATED volatility on {{ticker}} ({{interval}})")
alertcondition(to_normal,   title = "Normal Volatility",
     message = "EXCAVO Volatility Percentile: NORMAL volatility on {{ticker}} ({{interval}})")
alertcondition(to_low,      title = "Low Volatility",
     message = "EXCAVO Volatility Percentile: LOW volatility on {{ticker}} ({{interval}})")
alertcondition(state_changed, title = "Volatility State Change",
     message = "EXCAVO Volatility Percentile: State changed on {{ticker}} ({{interval}})")

if i_json and state_changed
    alert('{"ticker":"' + syminfo.ticker + '","state":"' + state_name + '",' +
          '"percentile":' + str.tostring(pct_rank, "0.0") + ',' +
          '"atr_pct":' + str.tostring(atr_pct, "0.00") + ',' +
          '"price":' + str.tostring(close, format.mintick) + ',' +
          '"indicator":"EXCAVO_Volatility_Percentile","timeframe":"' + timeframe.period + '"}',
          alert.freq_once_per_bar)
````
