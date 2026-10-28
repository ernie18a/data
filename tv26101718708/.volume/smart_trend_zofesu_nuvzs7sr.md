# Smart Trend [Zofesu]

- url: https://www.tradingview.com/script/nUVZS7SR-Smart-Trend-Zofesu/
- type: indicator
- pine_id: PUB;8932e5aeecd24039bcf0d45ad3d1653c
- version: 1.0

## Description

[b]Smart Trend [Zofesu][/b] is an ATR-based trend following indicator extended with two original filtering layers not present in standard Supertrend implementations: a Hull Moving Average macro trend filter and a Volume Percentile Rank confirmation system.

The ATR trailing stop concept is well established in technical analysis. The original additions in this script are the dual-filter architecture and how the three layers interact to produce signals only when all conditions align.

─────────────────────────────────────
[b]01 — What is Smart Trend?[/b]
─────────────────────────────────────
[b]Smart Trend [Zofesu][/b] plots a dynamic trend line based on ATR volatility. The line trails price and flips direction when price breaks through it with volume confirmation. Two additional filters gate the signals — ensuring entries align with both macro trend direction and institutional volume participation.

The result is fewer but higher-quality signals compared to a standard ATR trailing stop.

─────────────────────────────────────
[b]02 — Three-Layer Architecture[/b]
─────────────────────────────────────
[b]Layer 1 — ATR Trend Engine (Core)[/b]
The trend line is calculated using ATR × multiplier applied to high/low. It trails in the direction of the trend and flips only when price closes on the opposite side with confirmation.

[b]Upper band[/b] = high - (ATR × multiplier) — support in uptrend
[b]Lower band[/b] = low + (ATR × multiplier) — resistance in downtrend

The trend line locks at the highest support or lowest resistance seen during the trend — it only moves in the direction of the trend, never against it.

[b]Layer 2 — HMA Macro Filter (Original)[/b]
A Hull Moving Average with a long smoothing period (default 500) acts as a macro trend filter. When enabled, signals are only shown when the ATR trend direction agrees with the HMA macro direction. Conflicting signals (ATR bullish but price below HMA) are shown in gray — indicating low-confidence state.

This filter is the key difference from a standard Supertrend. It eliminates counter-trend entries in strongly trending markets.

[b]Layer 3 — Volume Percentile Rank (Original)[/b]
A trend flip requires not just a price break but also a volume confirmation. Volume is ranked as a percentile over 500 bars. A flip only occurs if current volume rank exceeds the configured threshold (default 40th percentile).

This prevents trend flips on low-volume, potentially false breakouts.

─────────────────────────────────────
[b]03 — Settings[/b]
─────────────────────────────────────
[b]ATR Period[/b] — default 25
Lookback for ATR calculation. Higher = smoother trend line, less reactive.

[b]Volatility Multiplier[/b] — default 3.2
Controls band width. Higher = fewer flips, stays in trend longer. Lower = more reactive, more signals.

[b]Enable Main Trend Filter[/b] — default on
When on, signals require HMA macro trend agreement. When off, raw ATR signals only.

[b]Main Trend Smoothness (HMA)[/b] — default 500
HMA length for macro trend. Higher = slower macro trend, fewer conflicting signals filtered out.

[b]Show Background Bias Tint[/b] — default on
Green background = macro trend bullish. Red = macro trend bearish. Gray = conflicting state.

[b]Require Volume Confirmation[/b] — default on
When on, trend flips require volume rank above threshold.

[b]Volume Percentile Rank[/b] — default 40
Minimum volume percentile required for a trend flip. 40 = volume must be in top 60% of last 500 bars.

─────────────────────────────────────
[b]04 — Signal Colors[/b]
─────────────────────────────────────
🟢 Teal line — ATR trend bullish, confirmed by HMA filter
🔴 Red line — ATR trend bearish, confirmed by HMA filter
⚫ Gray line — ATR trend direction conflicts with HMA macro trend — low confidence, avoid trading

[b]BUY label[/b] — trend flipped bullish with all filters aligned
[b]SELL label[/b] — trend flipped bearish with all filters aligned

─────────────────────────────────────
[b]05 — How To Use[/b]
─────────────────────────────────────
[b]Step 1[/b] — Check background color
Green tint = macro trend bullish, look for longs only.
Red tint = macro trend bearish, look for shorts only.

[b]Step 2[/b] — Wait for trend line flip
BUY label = trend flipped to bullish with volume confirmation.
SELL label = trend flipped to bearish with volume confirmation.

[b]Step 3[/b] — Check line color
Teal or Red = high confidence signal (all filters aligned).
Gray = skip — ATR and HMA disagree.

[b]Step 4[/b] — Alerts
Two alert conditions are pre-configured:
Smart Trend: BUY Signal
Smart Trend: SELL Signal

─────────────────────────────────────
[b]06 — Best Timeframes[/b]
─────────────────────────────────────
H1, H4 and D1 produce the most reliable signals with default settings.
On lower timeframes consider reducing the ATR Period to 14 and Volume Percentile to 30.
On higher timeframes (W1) consider increasing the ATR Period to 34+.

[b]Works on all asset classes:[/b] Indices, Forex, Gold, Oil, Crypto.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Since 2020 Zofesu

//@version=6
indicator("Smart Trend [Zofesu]", overlay=true, shorttitle="Zofesu - SmartTrend")

// --- INPUTS ---
group_trend   = "Trend Core Settings"
atr_length    = input.int(25, title="ATR Period", group=group_trend)
multiplier    = input.float(3.2, title="Volatility Multiplier", step=0.1, group=group_trend)

group_filter = "The Great Filter (Main Trend)"
use_filter   = input.bool(true, title="Enable Main Trend Filter?", group=group_filter)
filter_len   = input.int(500, title="Main Trend Smoothness (HMA)", group=group_filter)
show_bg      = input.bool(true, title="Show Background Bias Tint?", group=group_filter)

group_vol    = "Volume Confirmation"
use_vol      = input.bool(true, title="Require Volume Confirmation?", group=group_vol)
vol_pct_target = input.int(40, title="Volume Percentile Rank (%)", minval=1, maxval=100, group=group_vol)

// --- CALCULATIONS ---
atr = ta.atr(atr_length)
v_rank = ta.percentrank(volume, 500)

// Main Filter (Hull Moving Average)
main_trend_ma = ta.hma(close, filter_len)
main_trend_bull = close > main_trend_ma
main_trend_bear = close < main_trend_ma

// Trend Engine Logic
var float trend_line = na
var int trend_dir = 1 

float upper_band = high - (atr * multiplier)
float lower_band = low + (atr * multiplier)

bool vol_confirmed = not use_vol or v_rank > vol_pct_target

if na(trend_line)
    trend_line := upper_band

if trend_dir == 1
    if close < trend_line and vol_confirmed
        trend_dir := -1
        trend_line := lower_band
    else
        trend_line := math.max(nz(trend_line[1]), upper_band)
else
    if close > trend_line and vol_confirmed
        trend_dir := 1
        trend_line := upper_band
    else
        trend_line := math.min(nz(trend_line[1]), lower_band)

// --- VISUALIZATION ---
bg_color = show_bg ? (main_trend_bull ? color.new(#00ffbb, 95) : color.new(#ff0055, 95)) : na
bgcolor(bg_color, title="Trend Bias Background")

line_color = trend_dir == 1 ? color.new(#00ffbb, 0) : color.new(#ff0055, 0)
final_line_col = use_filter ? (trend_dir == 1 and not main_trend_bull ? color.new(color.gray, 50) : trend_dir == -1 and not main_trend_bear ? color.new(color.gray, 50) : line_color) : line_color

plot(trend_line, "Trend Line", color=final_line_col, linewidth=2, style=plot.style_linebr)

// Strategy Signals
bool show_long  = (trend_dir == 1 and trend_dir[1] == -1) and (not use_filter or main_trend_bull)
bool show_short = (trend_dir == -1 and trend_dir[1] == 1) and (not use_filter or main_trend_bear)

plotshape(show_long, "Long Entry", shape.triangleup, location.belowbar, color.new(#00ffbb, 0), size=size.small, text="BUY", textcolor=color.white)
plotshape(show_short, "Short Entry", shape.triangledown, location.abovebar, color.new(#ff0055, 0), size=size.small, text="SELL", textcolor=color.white)

plot(use_filter ? main_trend_ma : na, "Main Trend Reference", color=color.new(color.white, 80), linewidth=1, style=plot.style_line)

// --- ALERT CONDITION LOGIC ---
alertcondition(show_long, title="Smart Trend: BUY Signal", message="Smart Trend Buy Signal on {{ticker}}")
alertcondition(show_short, title="Smart Trend: SELL Signal", message="Smart Trend Sell Signal on {{ticker}}")
````
