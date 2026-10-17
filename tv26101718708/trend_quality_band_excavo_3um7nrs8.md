# Trend Quality Band [EXCAVO]

- url: https://www.tradingview.com/script/3um7NRs8-Trend-Quality-Band-EXCAVO/
- type: indicator
- pine_id: PUB;390f7a191a4e4f31b642d67cc0fba4e8
- version: 1.0

## Description

Volatility-Ranked SuperTrend That Tightens in Calm Markets and Widens in Volatile Ones

The [i]Trend Quality Band[/i] is an adaptive trend-following indicator built on a
SuperTrend core whose band width is controlled entirely by ATR percentile rank. Instead
of a fixed multiplier, the band compresses when current volatility is historically
low and expands when it is historically high - giving the trend line room when it
needs it and keeping it tight when conditions allow.

This is not a standard SuperTrend with a different parameter. The driving mechanism
is a statistical rank: each bar, the current ATR is compared against its full
lookback history to produce a 0-100% rank, which then scales the band multiplier
non-linearly between configurable compress and expand factors.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW TO USE[/b]

[b]Step 1[/b]  →  Add the indicator. The adaptive trend band appears immediately.
              Blue band below price = bullish trend. Red band above price = bearish.
[b]Step 2[/b]  →  Watch for flip signals. Triangles mark the bar where the trend
              changed direction. Bullish flip = triangle below bar. Bearish = above.
[b]Step 3[/b]  →  Read the ATR Rank in the dashboard. Below 35% = low volatility
              (compressed band, trend holds tight). Above 65% = high volatility
              (expanded band, wider room before a flip fires).
[b]Step 4[/b]  →  Use the Regime label. "Low Vol" means the band is near its
              narrowest - trends confirmed here are high quality. "High Vol"
              means the band is expanded to filter noise in choppy conditions.
[b]Step 5[/b]  →  Set alerts for Bullish or Bearish Trend Flip to be notified
              on confirmed direction changes.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ HOW IT CALCULATES[/b]

[b]◆  ATR Percentile Rank[/b]
On every bar, the indicator computes the ATR using the configured length, then
ranks it against its own history over the Rank Lookback period:

  atr_rank = percentrank(ATR, lookback) / 100

This produces a value from 0 to 1. A rank of 0.1 means current ATR is lower
than 90% of recent history (unusually quiet). A rank of 0.9 means current ATR
exceeds 90% of recent history (unusually volatile).

[b]◆  Non-Linear Multiplier Scaling[/b]
The rank is mapped to a scaling factor using three zones defined by the
Compress Below and Expand Above thresholds (default 0.35 / 0.65):

  t = clamp((atr_rank - compress_thresh) / (expand_thresh - compress_thresh), 0, 1)
  rank_scale = compress_factor + t x (expand_factor - compress_factor)
  eff_mult = base_multiplier x rank_scale

When rank is below the compress threshold, rank_scale approaches the Compress
Factor (default 0.65). When rank exceeds the expand threshold, rank_scale
approaches the Expand Factor (default 1.55). Between the thresholds, the scale
interpolates linearly. The result: a multiplier that ranges from approximately
1.6x (base 2.5 x 0.65) to 3.9x (base 2.5 x 1.55) depending on regime.

[b]◆  SuperTrend Ratchet Logic[/b]
The adaptive multiplier feeds a standard SuperTrend ratchet:

  upper_raw = src + eff_mult x ATR
  lower_raw = src - eff_mult x ATR

  lower_band = close[1] > lower_band[1] ? max(lower_raw, lower_band[1]) : lower_raw
  upper_band = close[1] < upper_band[1] ? min(upper_raw, upper_band[1]) : upper_raw

The ratchet means the active band can only move in the direction of the trend -
it never widens to catch a missed flip. A flip fires when price closes beyond
the active band. The direction variable tracks the current trend state.

[b]◆  Regime Classification[/b]
The rank is compared against the two thresholds to produce a named regime:
Low Vol (rank < 0.35), Normal (0.35-0.65), or High Vol (rank > 0.65). This
regime label and the live multiplier value are shown in the dashboard so the
trader can see exactly why the band is positioned where it is.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ WHAT MAKES IT DIFFERENT[/b]

[b]◆  ATR Percentile Rank as the Sole Driver[/b]
Most adaptive SuperTrend variants modulate bands using the Efficiency Ratio (a
directional momentum measure) or volatility ratios against a moving average.
This indicator uses a statistical rank: the current ATR is compared against its
entire recent history rather than a smoothed baseline. A rank of 80% means the
current bar is more volatile than 80% of recent bars - a precise, context-aware
signal that a fixed multiplier or a ratio cannot capture.

[b]◆  Compress-and-Expand Band Behavior[/b]
The two-threshold system creates three distinct regimes. In the Low Vol regime
the band compresses toward the Compress Factor - trend flips require less
movement, keeping the indicator responsive during quiet trends. In the High Vol
regime the band expands toward the Expand Factor - preventing false flips during
breakouts and spike-heavy conditions. The Normal regime interpolates between
the two, creating a smooth transition rather than a step function.

[b]◆  Live Multiplier Transparency[/b]
The dashboard shows the actual effective multiplier value on every bar. This
tells the trader exactly how wide the band currently is and why. When the
multiplier reads 1.6x the band is near its tightest. When it reads 3.8x the
band is near its widest. No guesswork about how the indicator is behaving.

[b]◆  Non-Repainting by Default[/b]
Flip signals are gated by barstate.isconfirmed - they only fire on the closed
bar. The Allow Repainting input is available for users who prefer real-time
updates, but the default ensures historical flips on the chart are accurate.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ DASHBOARD[/b]

Real-time panel (top right by default) shows the current state:

[list]
[*][b]Trend[/b] - BULLISH or BEARISH, colored by direction
[*][b]ATR Rank[/b] - current ATR percentile rank as a percentage (0-100%)
[*][b]Regime[/b] - Low Vol / Normal / High Vol based on rank thresholds
[*][b]Multiplier[/b] - effective band multiplier currently in use
[*][b]Band[/b] - current price level of the active trend band
[/list]

Legend table (bottom left) identifies all visual elements on the chart:
[list]
[*][b]━ (blue)[/b] - Bullish trend band
[*][b]━ (red)[/b] - Bearish trend band
[*][b]┅ (orange)[/b] - Midline EMA, color reflects volatility regime
[*][b]▲ (blue)[/b] - Bullish trend flip
[*][b]▼ (red)[/b] - Bearish trend flip
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ SETTINGS[/b]

[b]Core Settings[/b]
[list]
[*][b]ATR Length[/b] - 14 (lookback for ATR calculation)
[*][b]Base Multiplier[/b] - 2.5 (center-point multiplier at rank = 0.5)
[*][b]Source[/b] - 0 = HL2, 1 = Close, 2 = HLC3
[/list]

[b]ATR Rank Settings[/b]
[list]
[*][b]Rank Lookback[/b] - 200 bars (history used for percentile rank)
[*][b]Compress Below[/b] - 0.35 (rank threshold for low volatility regime)
[*][b]Expand Above[/b] - 0.65 (rank threshold for high volatility regime)
[*][b]Compress Factor[/b] - 0.65 (multiplier scale at minimum rank)
[*][b]Expand Factor[/b] - 1.55 (multiplier scale at maximum rank)
[/list]

[b]Visualization[/b]
[list]
[*][b]Bullish Color[/b] - blue (customizable)
[*][b]Bearish Color[/b] - red (customizable)
[*][b]Signal Color[/b] - orange (customizable)
[*][b]Show Band Fill[/b] - ON (semi-transparent fill between band and price)
[*][b]Show Flip Signals[/b] - ON (arrow shapes at trend flip bars)
[*][b]Show Background[/b] - OFF (chart background colored by trend)
[*][b]Show Smooth Band[/b] - ON (EMA-smoothed band line, removes staircase appearance)
[*][b]Smooth Length[/b] - 5 (EMA period for band smoothing)
[*][b]Show Midline[/b] - ON (EMA of price colored by volatility regime)
[*][b]Midline Length[/b] - 20 (EMA period for the midline)
[/list]

[b]Dashboard[/b]
[list]
[*][b]Show Dashboard[/b] - ON
[*][b]Show Legend[/b] - ON
[*][b]Dashboard Position[/b] - Top Right
[/list]

[b]Alert Settings[/b]
[list]
[*][b]Allow Repainting[/b] - OFF
[*][b]JSON Alerts[/b] - OFF
[/list]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]▸ ALERTS[/b]

[list]
[*][b]Bullish Trend Flip[/b] - trend changed from bearish to bullish on bar close
[*][b]Bearish Trend Flip[/b] - trend changed from bullish to bearish on bar close
[*][b]Trend Flip[/b] - any direction change
[/list]

JSON payloads include action, direction, ticker, price, timeframe, and indicator.

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
// Trend Quality Band [EXCAVO]
// -----------------------------------------------------------------------------
// SuperTrend whose band width is modulated by ATR percentile rank.
// Narrow bands in low-volatility trends, wide bands in high-volatility regimes.
//
//@version=6
indicator("Trend Quality Band [EXCAVO]", "EXCAVO Trend Quality Band",
     overlay          = true,
     max_boxes_count  = 500,
     max_lines_count  = 500,
     max_labels_count = 500)

//-----------------------------------------------------------------------------}
// Inputs
//-----------------------------------------------------------------------------{
string GRP_CORE   = "Core Settings"
string GRP_RANK   = "ATR Rank Settings"
string GRP_VIZ    = "Visualization"
string GRP_DASH   = "Dashboard"
string GRP_ALERTS = "Alert Settings"

int   i_atr_len   = input.int  (14,   "ATR Length",         minval = 5,   maxval = 100,  group = GRP_CORE,
     tooltip = "Lookback for ATR calculation.")
float i_base_mult = input.float(2.5,  "Base Multiplier",    minval = 0.5, maxval = 6.0, step = 0.1, group = GRP_CORE,
     tooltip = "Center-point ATR multiplier applied when ATR rank = 0.5. Actual multiplier scales around this value.")
int   i_src_type  = input.int  (0,    "Source",             minval = 0,   maxval = 2,    group = GRP_CORE,
     tooltip = "Price source: 0 = HL2, 1 = Close, 2 = HLC3.")

int   i_rank_len  = input.int  (200,  "Rank Lookback",      minval = 50,  maxval = 500,  group = GRP_RANK,
     tooltip = "Number of bars used to rank current ATR against history. Longer = more stable rank, slower to adapt.")
float i_rank_lo   = input.float(0.35, "Compress Below",     minval = 0.1, maxval = 0.5, step = 0.05, group = GRP_RANK,
     tooltip = "ATR rank threshold below which the band compresses. Low volatility regime - trend holds tighter.")
float i_rank_hi   = input.float(0.65, "Expand Above",       minval = 0.5, maxval = 0.9, step = 0.05, group = GRP_RANK,
     tooltip = "ATR rank threshold above which the band expands. High volatility regime - wider bands prevent false flips.")
float i_compress  = input.float(0.65, "Compress Factor",    minval = 0.3, maxval = 0.9, step = 0.05, group = GRP_RANK,
     tooltip = "Multiplier scale at minimum rank (rank = 0). Band = base_mult x compress_factor.")
float i_expand    = input.float(1.55, "Expand Factor",      minval = 1.1, maxval = 2.5, step = 0.05, group = GRP_RANK,
     tooltip = "Multiplier scale at maximum rank (rank = 1). Band = base_mult x expand_factor.")

color C_BULL      = input.color(color.rgb(0, 60, 180),   "Bullish Color", group = GRP_VIZ,
     tooltip = "Color for bullish trend line and signals.")
color C_BEAR      = input.color(color.rgb(200, 40, 40),  "Bearish Color", group = GRP_VIZ,
     tooltip = "Color for bearish trend line and signals.")
color C_SIGNAL    = input.color(color.rgb(255, 140, 0),  "Signal Color",  group = GRP_VIZ,
     tooltip = "Color for flip signal markers.")
bool  i_show_band  = input.bool (true,  "Show Band Fill",    group = GRP_VIZ,
     tooltip = "Fill the area between the trend line and price with a semi-transparent color.")
bool  i_show_sig   = input.bool (true,  "Show Flip Signals", group = GRP_VIZ,
     tooltip = "Mark bullish and bearish trend flips with arrow shapes.")
bool  i_show_bg    = input.bool (false, "Show Background",   group = GRP_VIZ,
     tooltip = "Color the chart background by trend direction.")
bool  i_show_smooth = input.bool(true,  "Show Smooth Band",  group = GRP_VIZ,
     tooltip = "Draw an EMA-smoothed version of the trend band. Removes staircase appearance. Flip logic uses the raw ratchet band, not this line.")
int   i_smooth_len  = input.int (5,    "Smooth Length",      minval = 2, maxval = 30, group = GRP_VIZ,
     tooltip = "EMA period for smoothing the band line. Shorter = closer to raw, longer = smoother.")
bool  i_show_mid    = input.bool(true,  "Show Midline",      group = GRP_VIZ,
     tooltip = "Draw an EMA of price as a smooth midline. Color reflects volatility regime: blue = Low Vol, orange = Normal, red = High Vol.")
int   i_mid_len     = input.int (20,   "Midline Length",     minval = 5, maxval = 200, group = GRP_VIZ,
     tooltip = "EMA period for the midline.")

bool  i_show_dash = input.bool (true,  "Show Dashboard",    group = GRP_DASH,
     tooltip = "Toggle the information dashboard.")
bool  i_show_lgnd = input.bool (true,  "Show Legend",       group = GRP_DASH,
     tooltip = "Toggle the legend panel.")
string i_dash_pos = input.string("Top Right", "Dashboard Position", group = GRP_DASH,
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
     tooltip = "Position of the dashboard table on the chart.")

bool  i_repaint   = input.bool (false, "Allow Repainting",  group = GRP_ALERTS,
     tooltip = "OFF = signals on bar close only (recommended). ON = real-time signals that may repaint.")
bool  i_json      = input.bool (false, "JSON Alerts",        group = GRP_ALERTS,
     tooltip = "Enable JSON-formatted alerts for bot integration.")

//-----------------------------------------------------------------------------}
// Constants
//-----------------------------------------------------------------------------{
color C_NEUTRAL     = color.rgb(80, 80, 100)
color C_DASH_BG     = color.rgb(50, 53, 60)
color C_DASH_BORDER = color.rgb(80, 85, 95)
color C_DASH_BULL   = color.rgb(80, 140, 255)
color C_DASH_BEAR   = color.rgb(240, 70, 70)
color C_DASH_SIGNAL = color.rgb(255, 170, 50)

int BAND_ALPHA = 80
int BG_ALPHA   = 93

//-----------------------------------------------------------------------------}
// Core — ATR Percentile Rank + Adaptive Multiplier
//-----------------------------------------------------------------------------{

// Price source
float src = switch i_src_type
    1 => close
    2 => hlc3
    => hl2

// Raw ATR
float atr = ta.atr(i_atr_len)

// ATR percentile rank: how does current ATR compare to its history?
// rank = 0 → current ATR is lowest in lookback (tight, low volatility)
// rank = 1 → current ATR is highest in lookback (wide, high volatility)
float atr_rank = ta.percentrank(atr, i_rank_len) / 100.0

// Map rank to a scaling factor using compress/expand factors:
// rank <= compress_thresh → scale toward i_compress
// rank >= expand_thresh   → scale toward i_expand
// between thresholds      → linear interpolation
float t = math.max(0.0, math.min(1.0,
     (atr_rank - i_rank_lo) / math.max(i_rank_hi - i_rank_lo, 0.01)))
float rank_scale = i_compress + t * (i_expand - i_compress)

// Final adaptive multiplier: base_mult scaled by rank
float eff_mult = i_base_mult * rank_scale

//-----------------------------------------------------------------------------}
// Core — SuperTrend with Adaptive Multiplier
//-----------------------------------------------------------------------------{
var float st_upper = na
var float st_lower = na
var int   st_dir   = 1      // 1 = bullish, -1 = bearish

float upper_raw = src + eff_mult * atr
float lower_raw = src - eff_mult * atr

// Ratchet: band only tightens on the active side, never loosens while trend holds
st_upper := na(st_upper[1]) ? upper_raw :
     (close[1] < st_upper[1] ? math.min(upper_raw, st_upper[1]) : upper_raw)
st_lower := na(st_lower[1]) ? lower_raw :
     (close[1] > st_lower[1] ? math.max(lower_raw, st_lower[1]) : lower_raw)

// Trend direction
int prev_dir = nz(st_dir[1], 1)
st_dir := na(st_dir[1]) ? 1 :
     (prev_dir ==  1 and close < st_lower[1] ? -1 :
      prev_dir == -1 and close > st_upper[1] ?  1 : prev_dir)

// Active trend line
float st_line = st_dir == 1 ? st_lower : st_upper

// Flip conditions
bool flip_bull = st_dir ==  1 and st_dir[1] == -1
bool flip_bear = st_dir == -1 and st_dir[1] ==  1

// Signal gate (non-repainting by default)
bool confirmed = i_repaint ? true : barstate.isconfirmed
bool sig_bull  = flip_bull and confirmed
bool sig_bear  = flip_bear and confirmed

//-----------------------------------------------------------------------------}
// Regime Classification
//-----------------------------------------------------------------------------{
// Three volatility regimes based on rank thresholds
string regime     = atr_rank < i_rank_lo ? "Low Vol" :
     (atr_rank > i_rank_hi ? "High Vol" : "Normal")
color  regime_col = atr_rank < i_rank_lo ? C_DASH_BULL :
     (atr_rank > i_rank_hi ? C_DASH_BEAR : C_DASH_SIGNAL)

//-----------------------------------------------------------------------------}
// Smooth Band + Midline
//-----------------------------------------------------------------------------{

// EMA-smoothed version of the raw ratchet band (visual only — flips use st_line)
float smooth_band = ta.ema(st_line, i_smooth_len)

// Midline: EMA of price, colored by volatility regime
float mid_line  = ta.ema(src, i_mid_len)
color mid_col   = atr_rank < i_rank_lo ? C_BULL :
     (atr_rank > i_rank_hi ? C_BEAR : C_SIGNAL)

//-----------------------------------------------------------------------------}
// Visuals
//-----------------------------------------------------------------------------{
color line_col  = st_dir == 1 ? C_BULL : C_BEAR
color fill_col  = st_dir == 1 ? color.new(C_BULL, BAND_ALPHA) : color.new(C_BEAR, BAND_ALPHA)

// Smooth band visual — plot() justified: price-derived, stays on price scale, enables fill()
p_st   = plot(i_show_smooth ? smooth_band : st_line, "Trend Band",
     color = line_col, linewidth = 2)
p_src  = plot(src, "Source",
     color = color.new(color.black, 100), display = display.none)

fill(p_st, p_src, color = i_show_band ? fill_col : na, title = "Band Fill")

// Midline
plot(i_show_mid ? mid_line : na, "Midline",
     color = mid_col, linewidth = 1, style = plot.style_line)

bgcolor(i_show_bg ? (st_dir == 1 ? color.new(C_BULL, BG_ALPHA) : color.new(C_BEAR, BG_ALPHA)) : na,
     title = "Trend Background")

// Flip signal markers
plotshape(i_show_sig and sig_bull, "Bullish Flip",
     shape.triangleup, location.belowbar, C_BULL, size = size.small)
plotshape(i_show_sig and sig_bear, "Bearish Flip",
     shape.triangledown, location.abovebar, C_BEAR, size = size.small)

//-----------------------------------------------------------------------------}
// Dashboard
//-----------------------------------------------------------------------------{
if barstate.islast and i_show_dash
    string dash_pos_str = switch i_dash_pos
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        =>                position.top_right

    var table dash = table.new(dash_pos_str, 2, 6,
         bgcolor      = C_DASH_BG,
         border_color = C_DASH_BORDER,
         border_width = 2,
         frame_color  = C_DASH_BORDER,
         frame_width  = 2)

    table.cell(dash, 0, 0, "EXCAVO",
         text_color  = C_DASH_BULL, text_size = size.normal,
         text_halign = text.align_center, bgcolor = C_DASH_BG)
    table.cell(dash, 1, 0, "Trend Quality Band",
         text_color  = color.white, text_size = size.normal,
         text_halign = text.align_center, bgcolor = C_DASH_BG)
    table.merge_cells(dash, 0, 0, 1, 0)

    string trend_str = st_dir == 1 ? "BULLISH" : "BEARISH"
    color  trend_col = st_dir == 1 ? C_DASH_BULL : C_DASH_BEAR

    table.cell(dash, 0, 1, "Trend",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 1, trend_str,
         text_color = trend_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 2, "ATR Rank",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 2, str.tostring(atr_rank * 100, "#.0") + "%",
         text_color = regime_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 3, "Regime",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 3, regime,
         text_color = regime_col, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 4, "Multiplier",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(eff_mult, "#.00") + "x",
         text_color = C_DASH_SIGNAL, text_size = size.small, text_halign = text.align_right)

    table.cell(dash, 0, 5, "Band",
         text_color = color.white, text_size = size.small, text_halign = text.align_left)
    table.cell(dash, 1, 5, str.tostring(st_line, format.mintick),
         text_color = trend_col, text_size = size.small, text_halign = text.align_right)

//-----------------------------------------------------------------------------}
// Legend
//-----------------------------------------------------------------------------{
if barstate.islast and i_show_lgnd
    var table leg = table.new(position.bottom_left, 2, 7,
         bgcolor      = C_DASH_BG,
         border_color = C_DASH_BORDER,
         border_width = 1,
         frame_color  = C_DASH_BORDER,
         frame_width  = 1)

    table.cell(leg, 0, 0, "LEGEND",
         text_color  = C_DASH_BULL, text_size = size.normal,
         text_halign = text.align_center, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 0, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.merge_cells(leg, 0, 0, 1, 0)

    table.cell(leg, 0, 1, "━",
         text_color = C_DASH_BULL, text_size = size.small, text_halign = text.align_left, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 1, "Bullish trend band",
         text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 2, "━",
         text_color = C_DASH_BEAR, text_size = size.small, text_halign = text.align_left, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 2, "Bearish trend band",
         text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 3, "┅",
         text_color = C_DASH_SIGNAL, text_size = size.small, text_halign = text.align_left, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 3, "Midline (EMA, regime color)",
         text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 4, "▲",
         text_color = C_DASH_BULL, text_size = size.small, text_halign = text.align_left, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 4, "Bullish trend flip",
         text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 5, "▼",
         text_color = C_DASH_BEAR, text_size = size.small, text_halign = text.align_left, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 5, "Bearish trend flip",
         text_color = color.white, text_size = size.small, text_halign = text.align_left, bgcolor = C_DASH_BG)

    table.cell(leg, 0, 6, "", text_size = size.small, bgcolor = C_DASH_BG)
    table.cell(leg, 1, 6, "", text_size = size.small, bgcolor = C_DASH_BG)

//-----------------------------------------------------------------------------}
// Alerts
//-----------------------------------------------------------------------------{
alertcondition(sig_bull, title = "Bullish Trend Flip",
     message = "EXCAVO Trend Quality Band: Bullish flip on {{ticker}} ({{interval}})")
alertcondition(sig_bear, title = "Bearish Trend Flip",
     message = "EXCAVO Trend Quality Band: Bearish flip on {{ticker}} ({{interval}})")
alertcondition(sig_bull or sig_bear, title = "Trend Flip",
     message = "EXCAVO Trend Quality Band: Trend flip on {{ticker}} ({{interval}})")

if i_json and (sig_bull or sig_bear) and barstate.isconfirmed
    string _t   = syminfo.ticker
    string _p   = str.tostring(close, format.mintick)
    string _tf  = timeframe.period
    string _dir = sig_bull ? "bullish" : "bearish"
    string _msg = '{"action":"flip","direction":"' + _dir + '","ticker":"' + _t + '","price":"' + _p + '","timeframe":"' + _tf + '","indicator":"EXCAVO_Trend_Quality_Band"}'
    alert(_msg, alert.freq_once_per_bar)
````
