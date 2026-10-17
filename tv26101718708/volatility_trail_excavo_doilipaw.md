# Volatility Trail [EXCAVO]

- url: https://www.tradingview.com/script/doilIpAW-Volatility-Trail-EXCAVO/
- type: indicator
- pine_id: PUB;d1b17a5a6c9740ed9f16c6073822a6eb
- version: 1.0

## Description

ATR Percentile Rank Painted as a Semi-Transparent Wave Beneath Every Candle

The [i]Volatility Trail[/i] takes the four-state volatility regime classification
from the standard ATR-percentile model and renders it directly on the price
chart as a semi-transparent wave hanging under each candle. The wave reads at
a glance: blue under the candles means quiet markets, orange means heating up,
red means volatility extremes. No separate indicator pane is required.

This is not a basic ATR oscillator. The ATR is normalised against its own
historical distribution, smoothed, and classified into four bounded regimes
(Low / Normal / Elevated / Extreme) with adjustable thresholds. The on-chart
trail is the same engine as the standard Volatility Percentile indicator,
just drawn where you actually read price.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW TO USE[/b]

[b]Step 1[/b]  →  Add the indicator. A coloured wave appears beneath every
              candle as soon as enough history is available for the percentile
              lookback to be meaningful (default 200 bars).
[b]Step 2[/b]  →  Read the wave colour:
              - Blue  = Low volatility (compression, mean-reversion regime)
              - Grey  = Normal volatility
              - Orange = Elevated volatility (trend regime)
              - Red   = Extreme volatility (top decile, exhaustion risk)
[b]Step 3[/b]  →  Watch transitions. A switch from blue to orange flags a
              breakout out of compression. A switch from red back to orange
              flags a release from extreme volatility - often the right side
              of a spike. The floating state badge to the right of the last
              candle shows the current regime name at a glance.
[b]Step 4[/b]  →  Check the dashboard. State, raw percentile, ATR, ATR / Price,
              and Vol Trend show the current regime numerically. Use these to
              size positions and pick filters that depend on volatility.
[b]Step 5[/b]  →  Combine with structure. The trail is a context tool, not a
              directional one - it tells you HOW volatile the market is, not
              WHICH way it will move. Pair it with your own setup criteria.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW IT CALCULATES[/b]

[b]◆  ATR Percentile Rank[/b]
The base measure is Average True Range over the user-set length (default 14).
For every bar the current ATR is ranked against its own values over the
Lookback Period (default 200): percentile = 100 x rank / N. A value of 90
means current volatility is higher than 90 percent of bars in the lookback
window. This normalisation makes the reading comparable across instruments
and timeframes - 90th-percentile vol on BTC and on EURUSD are both rare even
though their absolute ATRs differ by orders of magnitude.

[b]◆  Smoothing[/b]
The raw percentile is smoothed with a short SMA (default 3) to reduce single-
bar noise. Smoothing = 1 disables this step.

[b]◆  Four-State Classification[/b]
The smoothed percentile is bucketed into four regimes:
  - Low      = below Low / Normal boundary  (default 25)
  - Normal   = between Low / Normal and Normal / Elevated (default 25 to 60)
  - Elevated = between Normal / Elevated and Elevated / Extreme (default 60 to 80)
  - Extreme  = at or above Elevated / Extreme (default 80)
All three boundaries are user-adjustable.

[b]◆  Candle-Anchored Downward Wave[/b]
A semi-transparent band hangs directly under each candle. The upper edge
is the bar's low, lightly EMA-smoothed so single-bar wick spikes do not
poke through the ribbon. The lower edge drops below by an ATR-scaled
distance: drop = ATR x (1 + percentile x Wave Distance Scale). At calm
regimes the wave is a thin sliver under price; at volatile extremes it
extends well below. The colour is the active state colour, and the
opacity within each state band is gradient (see next item).

[b]◆  Within-Band Opacity Gradient[/b]
The wave colour is the state colour (blue / grey / orange / red), but the
opacity is not flat across each state - it ramps from Min Opacity at the
LOWER edge of the band (regime just entered) to Max Opacity at the UPPER
edge (peak of the regime, about to graduate to the next state). So a fresh
red band that just crossed into Extreme is light red, while a red band at
percentile 95 is a deep saturated red. The same gradient applies inside
the Low / Normal / Elevated bands. This lets you read at a glance whether
the current regime is just beginning, peaking, or about to fade into the
next state - approach and exhaustion are separately readable inside every
band.

[b]◆  Vol Trend[/b]
ATR is compared to its 20-bar SMA. Above 1.05x SMA = RISING, below 0.95x =
FALLING, else STABLE. Shown on the dashboard as a quick second-derivative
read of the regime.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ WHAT MAKES IT DIFFERENT[/b]

[b]◆  Wave Lives On The Price Chart[/b]
Most volatility indicators occupy a separate pane and force the eye to jump
between price action and the oscillator. The wave overlays the same regime
information directly on the candles, so price and volatility are read
together in one view.

[b]◆  Adaptive Across Instruments[/b]
Percentile-rank normalisation removes the absolute ATR units. A BTC chart
and a EURUSD chart use the same scale (0 to 100), so the same thresholds
work everywhere without manual tuning.

[b]◆  Four Bounded Regimes Instead Of A Raw Line[/b]
A raw ATR plot tells you very little until you have a feel for what is
"normal" on that instrument. The four-state classification answers the
question directly - quiet, normal, elevated, or extreme - using
user-adjustable boundaries.

[b]◆  Within-Band Opacity Gradient[/b]
Inside each state band the wave opacity ramps from light (just-entered
regime) to saturated (regime at its peak). A fresh red band reads as
pale red; a deep mature Extreme reads as a saturated red. Approach and
exhaustion are separately readable inside every regime, not just on
state transitions.

[b]◆  Premium Visual Polish[/b]
A thin rim-light line follows the upper edge of the wave for definition,
and a contrast-aware state badge floats next to the last candle showing
the current regime name. The badge text colour is picked automatically
by the perceived luminance of the background so the label stays readable
on any state colour.

[b]◆  Optional Bar Coloring And Background[/b]
For users who want the regime even more visible, bar-coloring and
background-highlight toggles tint the candles or the chart background with
the active state colour. Both default off so the wave stays as the primary
visual.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ DASHBOARD[/b]

Real-time panel (top right) with the current regime readout:
[list]
[*][b]State[/b] - LOW / NORMAL / ELEVATED / EXTREME
[*][b]Percentile[/b] - the smoothed ATR percentile (0 to 100)
[*][b]ATR[/b] - raw Average True Range
[*][b]ATR / Price[/b] - ATR as a percentage of close (instrument-independent)
[*][b]Vol Trend[/b] - RISING / STABLE / FALLING based on ATR vs its 20-bar SMA
[*][b]Lookback[/b] - the bar count used for the percentile rank
[/list]

Legend table (bottom left) explains every colour. Both panels toggle in the
Dashboard settings.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ SETTINGS[/b]

[b]Engine[/b]
[list]
[*][b]ATR Length[/b] - 14 (period for the Average True Range)
[*][b]Lookback Period[/b] - 200 (historical bars used for the percentile rank)
[*][b]Smoothing[/b] - 3 (SMA length applied to the raw percentile; 1 disables it)
[/list]

[b]State Thresholds[/b]
[list]
[*][b]Low / Normal[/b] - 25 (boundary between Low and Normal regimes)
[*][b]Normal / Elevated[/b] - 60 (boundary between Normal and Elevated)
[*][b]Elevated / Extreme[/b] - 80 (boundary between Elevated and Extreme)
[/list]

[b]Visualization[/b]
[list]
[*][b]Low Vol Color[/b] - blue
[*][b]Extreme Vol Color[/b] - red
[*][b]Elevated Vol Color[/b] - orange
[*][b]Wave Top Smoothing[/b] - 3 (EMA length applied to the wave top; 1 = raw bar low with sharp peaks, 3 to 5 rounds off single-bar spikes while staying tight to price)
[*][b]Wave Distance Scale[/b] - 0.025 (controls how far the wave drops below each candle as volatility rises; drop = ATR x (1 + percentile x scale); default keeps drops modest - approximately 1 ATR at Low regime, 3.5 ATR at Extreme)
[*][b]Min Opacity[/b] - 25 (wave opacity at the LOWER edge of every state band - just-entered regime; very transparent)
[*][b]Max Opacity[/b] - 55 (wave opacity at the UPPER edge of every state band - peak of the regime; visible but kept semi-transparent so the candles stay readable)
[*][b]Wave Top Highlight[/b] - ON (thin rim-light line along the upper edge of the wave; adds definition and a premium glow)
[*][b]Right-edge State Label[/b] - ON (floating badge next to the last candle showing the current state name in the state color)
[*][b]Bar Coloring[/b] - OFF (when ON, also tints the candles with the state color)
[*][b]Background Highlight[/b] - OFF (when ON, tints the chart background)
[/list]

[b]Dashboard[/b]
[list]
[*][b]Show Dashboard[/b] - ON
[*][b]Dashboard Position[/b] - Top Right
[*][b]Show Legend[/b] - ON
[/list]

[b]Alerts[/b]
[list]
[*][b]JSON Alerts[/b] - OFF (when ON, emits a structured JSON payload via alert())
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ ALERTS[/b]

[list]
[*][b]Extreme Volatility[/b] - state just transitioned into Extreme
[*][b]Elevated Volatility[/b] - state just transitioned into Elevated
[*][b]Normal Volatility[/b] - state just transitioned into Normal
[*][b]Low Volatility[/b] - state just transitioned into Low
[/list]

With JSON Alerts ON, the alert() call emits a structured payload with
ticker, state, percentile, atr_pct, price, timeframe, and indicator fields -
use "Any alert() function call" as the TradingView alert event to receive
every state change as JSON on one alert.

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
// Volatility Trail [EXCAVO]
// -----------------------------------------------------------------------------
// On-chart overlay of the ATR percentile rank with four-state classification.
// Renders a coloured trail beneath every candle so the volatility regime is
// readable directly on the price chart - no separate pane needed.
//
//@version=6
indicator("Volatility Trail [EXCAVO]", "EXCAVO Volatility Trail",
     overlay       = true,
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
color C_ELEVATED      = input.color(color.rgb(255, 140, 0),   "Elevated Vol Color",  group = GRP_VIZ,
     tooltip = "Color for Elevated volatility state.")
int   i_top_smooth  = input.int  (3,    "Wave Top Smoothing",   minval = 1,    maxval = 20,                  group = GRP_VIZ,
     tooltip = "EMA length applied to the wave-top (the candle anchor). 1 = raw bar low (sharp peaks). 3 to 5 rounds off single-bar spikes while staying tight to price.")
float i_wave_scale  = input.float(0.025, "Wave Distance Scale", minval = 0.005, maxval = 0.10, step = 0.005, group = GRP_VIZ,
     tooltip = "How far the wave drops below each candle as volatility rises. Higher = deeper drop. Drop = ATR x (1 + percentile x scale). Default 0.025 keeps drops modest: ~1 ATR at Low regime, ~3.5 ATR at Extreme.")
int   i_wave_opacity_min = input.int (25,  "Min Opacity",          minval = 5,    maxval = 60,                group = GRP_VIZ,
     tooltip = "Wave opacity at the lowest volatility (lighter / more transparent). 0 = invisible, 100 = solid.")
int   i_wave_opacity_max = input.int (55,  "Max Opacity",          minval = 30,   maxval = 80,                group = GRP_VIZ,
     tooltip = "Wave opacity at the highest volatility (more visible). The wave opacity interpolates between Min and Max based on percentile. Kept below 80 so the band stays semi-transparent at extremes too.")
bool  i_wave_rim    = input.bool (true,                     "Wave Top Highlight",   group = GRP_VIZ,
     tooltip = "Thin rim-light line along the upper edge of the wave. Adds definition and a premium look. Inherits state color.")
bool  i_state_label = input.bool (true,                     "Right-edge State Label", group = GRP_VIZ,
     tooltip = "Floating label at the right of the last candle showing the current state name (LOW / NORMAL / ELEVATED / EXTREME), colored by state.")
bool  i_bar_clr     = input.bool (false,                    "Bar Coloring",         group = GRP_VIZ,
     tooltip = "Also tint the candle bodies with the active state color.")
bool  i_show_bg     = input.bool (false,                    "Background Highlight", group = GRP_VIZ,
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
color C_DASH_ELEVATED = color.rgb(255, 170, 50)
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
    2 => C_ELEVATED
    1 => C_NEUTRAL
    => C_BULL

string state_name = switch vol_state
    3 => "EXTREME"
    2 => "ELEVATED"
    1 => "NORMAL"
    => "LOW"

string vol_trend = atr_val > atr_sma * 1.05 ? "RISING" : atr_val < atr_sma * 0.95 ? "FALLING" : "STABLE"

//-----------------------------------------------------------------------------}
// Detection - State Change
//-----------------------------------------------------------------------------{
var int prev_state  = na
bool state_changed  = not na(prev_state) and vol_state != prev_state and barstate.isconfirmed
bool to_extreme     = state_changed and vol_state == 3
bool to_elevated    = state_changed and vol_state == 2
bool to_normal      = state_changed and vol_state == 1
bool to_low         = state_changed and vol_state == 0
prev_state         := vol_state

//-----------------------------------------------------------------------------}
// Visuals - candle-anchored downward wave
//-----------------------------------------------------------------------------{
// Single clean fill - upper edge at the (lightly smoothed) candle low so the
// wave hugs price without sharp wick spikes, lower edge "drop" below scaled
// by volatility:
//   drop = ATR x (1 + percentile x i_wave_scale)
//
// Opacity interpolates within the CURRENT state band: light at the lower
// edge of the regime (just entered), saturated at the upper edge (peak of
// the regime, about to graduate). So a fresh Extreme is faint red while a
// fully matured Extreme is deep red - approach and exhaustion are readable
// inside every band, with no horizontal step-shelves.
float wave_drop = atr_val * (1.0 + pct_rank * i_wave_scale)
float anchor    = i_top_smooth > 1 ? ta.ema(low, i_top_smooth) : low
float wave_top  = anchor
float wave_bot  = anchor - wave_drop

int   band_lo_i = vol_state == 3 ? i_ext : vol_state == 2 ? i_hi  : vol_state == 1 ? i_lo : 0
int   band_hi_i = vol_state == 3 ? 100   : vol_state == 2 ? i_ext : vol_state == 1 ? i_hi : i_lo
float band_span = math.max(1.0, float(band_hi_i - band_lo_i))
float pos_in_band = math.max(0.0, math.min(1.0, (pct_rank - band_lo_i) / band_span))

// Pine transparency inverted: 100 = invisible, 0 = solid.
int wave_op = int(math.round(100.0 - (i_wave_opacity_min + (i_wave_opacity_max - i_wave_opacity_min) * pos_in_band)))
color wave_clr = color.new(state_color, wave_op)

p_top = plot(wave_top, "Wave Upper", color = color.new(state_color, 100), display = display.none)
p_bot = plot(wave_bot, "Wave Lower", color = color.new(state_color, 100), display = display.none)
fill(p_top, p_bot, color = wave_clr, title = "Volatility Wave")

// Rim-light highlight along the top edge of the wave. Opacity inherits
// the fill's within-band gradient minus a constant offset, so the line is
// always one notch more saturated than the underlying fill - reads as a
// soft glow following the wave's upper boundary.
int   rim_op = math.max(0, wave_op - 40)
color rim_clr = color.new(state_color, rim_op)
plot(i_wave_rim ? wave_top : na, "Wave Top Highlight", color = rim_clr, linewidth = 1)

barcolor(i_bar_clr ? state_color : na)
bgcolor(i_show_bg ? color.new(state_color, 93) : na)

//-----------------------------------------------------------------------------}
// Right-edge state badge - floats next to the current candle
//-----------------------------------------------------------------------------{
// Pattern B (delete-and-recreate on barstate.islast) so the label never
// jumps when the user scrolls historical bars. Placed 3 bars to the right
// of the last candle, anchored at the current close, colored by state.
//
// Text color is picked by perceived luminance of the background (state)
// color: dark text on light backgrounds (Elevated orange), white text on
// dark backgrounds (Low blue, Extreme red). Uses ITU-R BT.601 weights.
float bg_lum = 0.299 * color.r(state_color) + 0.587 * color.g(state_color) + 0.114 * color.b(state_color)
color lbl_text_clr = bg_lum > 150 ? color.rgb(20, 22, 30) : color.white

var label state_lbl = na
if barstate.islast and i_state_label
    label.delete(state_lbl)
    state_lbl := label.new(
         x         = bar_index + 3,
         y         = close,
         text      = " " + state_name + " ",
         color     = state_color,
         textcolor = lbl_text_clr,
         style     = label.style_label_left,
         size      = size.small)

//-----------------------------------------------------------------------------}
// Dashboard
//-----------------------------------------------------------------------------{
color dash_state_col = switch vol_state
    3 => C_DASH_BEAR
    2 => C_DASH_ELEVATED
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
    table.cell(dash, 1, 0, "Vol Trail",
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
    var table leg = table.new(position.bottom_left, 2, 6,
         C_DASH_BG, C_DASH_BORDER, 1, C_DASH_BORDER, 1)

    table.cell(leg, 0, 0, "LEGEND",
         text_color = C_DASH_BULL, text_size = size.normal, text_halign = text.align_center, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 0, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.merge_cells(leg, 0, 0, 1, 0)

    table.cell(leg, 0, 1, "▮", text_color = C_DASH_BEAR,   text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 1, "Extreme volatility",  text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 2, "▮", text_color = C_DASH_ELEVATED, text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 2, "Elevated volatility", text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 3, "▮", text_color = C_DASH_SIDE,   text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 3, "Normal volatility",   text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 4, "▮", text_color = C_DASH_BULL,   text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 4, "Low volatility",      text_color = color.white, text_size = size.small, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 5, " ", text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 5, " ", text_size = size.small, bgcolor = C_DASH_BG)

//-----------------------------------------------------------------------------}
// Alerts
//-----------------------------------------------------------------------------{
alertcondition(to_extreme,  title = "Extreme Volatility",
     message = "EXCAVO Volatility Trail: EXTREME volatility on {{ticker}} ({{interval}})")
alertcondition(to_elevated, title = "Elevated Volatility",
     message = "EXCAVO Volatility Trail: ELEVATED volatility on {{ticker}} ({{interval}})")
alertcondition(to_normal,   title = "Normal Volatility",
     message = "EXCAVO Volatility Trail: NORMAL volatility on {{ticker}} ({{interval}})")
alertcondition(to_low,      title = "Low Volatility",
     message = "EXCAVO Volatility Trail: LOW volatility on {{ticker}} ({{interval}})")

if i_json and state_changed
    alert('{"ticker":"' + syminfo.ticker + '","state":"' + state_name + '",' +
          '"percentile":' + str.tostring(pct_rank, "0.0") + ',' +
          '"atr_pct":' + str.tostring(atr_pct, "0.00") + ',' +
          '"price":' + str.tostring(close, format.mintick) + ',' +
          '"indicator":"EXCAVO_Volatility_Trail","timeframe":"' + timeframe.period + '"}',
          alert.freq_once_per_bar_close)
````
