# Apex Price Patterns & Candlestick Engine [Pineify]

- url: https://www.tradingview.com/script/RnnnrF9P-Apex-Price-Patterns-Candlestick-Engine-Pineify/
- type: indicator
- pine_id: PUB;3dd6aaab2838427a870b1318db84a6df
- version: 1.0

## Description

[b]Apex Price Patterns & Candlestick Engine [Pineify][/b]

Apex Price Patterns & Candlestick Engine combines EMA trend context, confirmed swing structure, and selected candlestick formations. It filters pattern labels by regime: bullish patterns print only when the fast EMA is above the slow EMA, and bearish patterns print only when the fast EMA is below the slow EMA.

[b]Key Features[/b]

[list]
[*]Fast/slow EMA filter for bullish, bearish, or neutral trend state

[*]Confirmed HH, HL, LH, and LL labels from pivot highs and lows

[*]Trend-aligned hammer, shooting star, engulfing, morning star, and evening star labels

[*]Trend candle coloring, EMA plots, dashboard, and alerts
[/list]

[b]How It Works[/b]

The script calculates a fast [i]EMA[/i] and slow [i]EMA[/i]. Their relationship defines trend state and controls candle coloring, the dashboard, and signal eligibility.

Market structure comes from [i]ta.pivothigh()[/i] and [i]ta.pivotlow()[/i]. A swing confirms only after the selected number of bars has passed on both sides, creating a known delay but keeping labels stable. Pivot highs mark HH or LH; pivot lows mark HL or LL.

The candle engine measures range, body width, wick percentages, and average body size. Wick/body imbalance detects hammers and shooting stars. Engulfing logic requires an opposite-color prior candle and meaningful current body. Morning and evening stars use a three-candle sequence.

[b]How the Components Work Together[/b]

EMA trend defines bias, pivots define structure, and candle patterns provide timing. A bullish label after an HL in an EMA uptrend may highlight a pullback rejection. A bearish label after an LH in an EMA downtrend may highlight a failed rally.

[b]Trading Ideas and Insights[/b]

[list]
[*]Use bullish labels near HL structure as possible trend-continuation context

[*]Use bearish labels near LH structure as possible downtrend-continuation context

[*]Compare HH/HL or LH/LL sequences against the EMA state to spot agreement or conflict
[/list]

Signals are context aids, not standalone trade instructions.

[b]Unique Aspects[/b]

[list]
[*]Pattern labels are trend-filtered instead of printed everywhere

[*]Structure uses confirmed pivots rather than raw highs and lows

[*]Trend, latest structure, and EMA relationship are summarized together
[/list]

[b]How to Use[/b]

[list=1]
[*]Add the indicator and check the dashboard trend state

[*]Read recent HH/HL/LH/LL labels to judge structure

[*]Watch for trend-aligned candle labels near recent swing areas

[*]Set alerts for pattern or structure events
[/list]

[b]Customization[/b]

[list]
[*][b]Fast EMA Length[/b] (default: 20) — Short trend filter; lower values react faster

[*][b]Slow EMA Length[/b] (default: 50) — Baseline trend filter; higher values change slower

[*][b]Swing Pivot Length[/b] (default: 10) — Bars required on both sides of a swing

[*][b]Visual Toggles[/b] — Show or hide labels, candle coloring, and dashboard
[/list]

[b]Conclusion[/b]

This indicator is for traders who read trend, structure, and candles together. Its value is showing when EMA direction, confirmed pivots, and proportion-based candlestick patterns are aligned.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Pineify

//======================================================================//
//                    ____  _            _  __                          //
//                   |  _ \(_)_ __   ___(_)/ _|_   _                    //
//                   | |_) | | '_ \ / _ \ | |_| | | |                   //
//                   |  __/| | | | |  __/ |  _| |_| |                   //
//                   |_|   |_|_| |_|\___|_|_|  \__, |                   //
//                                             |___/                    //
//======================================================================//
//
// Apex Price Patterns & Candlestick Engine
// ----------------------------------------
// Combines EMA trend context, confirmed swing structure, and selected
// candlestick formations into one price-action overlay. Pattern labels are
// filtered by trend so reversal-style candles are treated as directional
// continuation or pullback signals instead of isolated textbook patterns.
//
// Market states and signals:
//   1. Trend bias — fast EMA versus slow EMA defines bullish, bearish, or neutral context
//   2. Structure — confirmed pivots mark higher highs, higher lows, lower highs, and lower lows
//   3. Pattern events — hammers, stars, engulfing candles, and morning/evening stars print only in aligned trends
//

//@version=6
indicator("Apex Price Patterns & Candlestick Engine [Pineify]", overlay=true, max_labels_count=500, max_lines_count=500)

//---------------------------------------------------------------------------------------------------------------------}
// INPUT SETTINGS
//---------------------------------------------------------------------------------------------------------------------{
color GREEN = #089981
color RED   = #F23645
color BLUE  = #2962FF
color GRAY  = #787b86
color ORANGE = #FF9800
color DASH_BG = #1e222d
color DASH_BORDER = #373a46

grpTrend  = "Trend & Structure Settings"
grpVisual = "Aesthetics & Visuals"

emaFastLen = input.int(20, "Fast EMA Length", group=grpTrend, minval=1, tooltip="Short EMA used to define the active trend bias. Lower values react faster to price but can flip more often in ranges.")
emaSlowLen = input.int(50, "Slow EMA Length", group=grpTrend, minval=1, tooltip="Long EMA used as the slower trend baseline. Higher values require stronger directional movement before the trend state changes.")
pivotLen   = input.int(10, "Swing Pivot Length", group=grpTrend, minval=2, tooltip="Bars required on each side of a swing before a high or low is confirmed. Lower values show more structure labels; higher values isolate broader swings.")

showCandlePatterns = input.bool(true, "Show Candlestick Patterns", group=grpVisual, tooltip="Displays trend-filtered candlestick pattern labels when hammer, star, engulfing, or morning/evening star conditions are detected.")
showStructure      = input.bool(true, "Show Market Structure (HH/LL)", group=grpVisual, tooltip="Displays confirmed swing labels for higher highs, higher lows, lower highs, and lower lows.")
colorCandles       = input.bool(true, "Color Candles by Trend", group=grpVisual, tooltip="Colors price bars by EMA trend state: green for bullish bias, red for bearish bias, and gray for neutral or equal EMAs.")
showDashboard      = input.bool(true, "Show Dashboard", group=grpVisual, tooltip="Shows a compact status table with the current EMA trend, latest confirmed structure point, and EMA relationship.")

//---------------------------------------------------------------------------------------------------------------------}
// TREND & MARKET STRUCTURE DETECTION
//---------------------------------------------------------------------------------------------------------------------{
// The EMA pair provides a simple directional filter. Candlestick formations are only
// considered actionable when they agree with this broader bias, reducing countertrend noise.
fastEma = ta.ema(close, emaFastLen)
slowEma = ta.ema(close, emaSlowLen)

uptrend    = fastEma > slowEma
downtrend  = fastEma < slowEma

// Two-sided pivots confirm structure only after `pivotLen` future bars validate the swing.
// This creates a deterministic delay but keeps HH/HL/LH/LL labels stable once printed.
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastPh = na
var float lastPl = na
var string lastStruct = "None"

if not na(ph)
    isHH = na(lastPh) or ph > lastPh
    lastPh := ph
    lastStruct := isHH ? "HH" : "LH"
    if showStructure
        label.new(bar_index - pivotLen, ph, lastStruct, color=color(na), textcolor=isHH ? GREEN : RED, style=label.style_label_down, size=size.small)

if not na(pl)
    isLL = na(lastPl) or pl < lastPl
    lastPl := pl
    lastStruct := isLL ? "LL" : "HL"
    if showStructure
        label.new(bar_index - pivotLen, pl, lastStruct, color=color(na), textcolor=isLL ? RED : GREEN, style=label.style_label_up, size=size.small)

//---------------------------------------------------------------------------------------------------------------------}
// CANDLESTICK PATTERN ENGINE
//---------------------------------------------------------------------------------------------------------------------{
// Pattern detection is based on wick/body proportions rather than fixed point values,
// making the same logic portable across instruments with different price scales.
c_top     = math.max(open, close)
c_bot     = math.min(open, close)
hl_width  = high - low
bod_width = c_top - c_bot

hw_per        = hl_width > 0 ? ((high - c_top) / hl_width) * 100 : 0
lw_per        = hl_width > 0 ? ((c_bot - low) / hl_width) * 100 : 0
b_per         = hl_width > 0 ? (bod_width / hl_width) * 100 : 0
bod_width_sma = ta.sma(bod_width, 10)

doji = math.round_to_mintick(close) == math.round_to_mintick(open)
gc   = close > open
rc   = close < open

// Bullish formations are treated as continuation/pullback signals inside an EMA uptrend.
// The trend filter keeps these labels from appearing as unsupported bottom-picking calls.
hammer = (lw_per > (b_per * 2) and b_per < 50 and hw_per < 10 and not doji) and uptrend
bull_engulfing = rc[1] and gc and (bod_width > bod_width_sma / 2) and (open < close[1]) and (c_top > c_top[1]) and uptrend
morning_star = (rc[2] and nz(b_per[2], 0) > 60) and (rc[1] and nz(bod_width[1], 0) < (bod_width[2] / 2)) and (gc and close > hl2) and uptrend

// Bearish formations mirror the bullish logic: they matter most when the EMA regime
// already points lower, so labels emphasize pullback failure and trend continuation.
s_star = (hw_per > (b_per * 2) and b_per < 50 and lw_per < 10 and not doji) and downtrend
bear_engulfing = gc[1] and rc and (bod_width > bod_width_sma / 2) and (close < open[1]) and (c_bot < c_bot[1]) and downtrend
evening_star = (gc[2] and nz(b_per[2], 0) > 60) and (gc[1] and nz(bod_width[1], 0) < (bod_width[2] / 2)) and (rc and close < hl2) and downtrend

bullSignal = hammer or bull_engulfing or morning_star
bearSignal = s_star or bear_engulfing or evening_star

string bullTxt = ""
string bearTxt = ""

if hammer
    bullTxt := "Hammer"
else if bull_engulfing
    bullTxt := "Bull Engulf"
else if morning_star
    bullTxt := "Morning Star"

if s_star
    bearTxt := "Shoot Star"
else if bear_engulfing
    bearTxt := "Bear Engulf"
else if evening_star
    bearTxt := "Evening Star"

//---------------------------------------------------------------------------------------------------------------------}
// PLOTTING & AESTHETICS
//---------------------------------------------------------------------------------------------------------------------{
if bullSignal and showCandlePatterns
    label.new(bar_index, low - (high - low) * 0.5, bullTxt, color=color.new(GREEN, 30), textcolor=color.white, style=label.style_label_up, size=size.small)

if bearSignal and showCandlePatterns
    label.new(bar_index, high + (high - low) * 0.5, bearTxt, color=color.new(RED, 30), textcolor=color.white, style=label.style_label_down, size=size.small)

candleColor = uptrend ? GREEN : downtrend ? RED : GRAY
barcolor(colorCandles ? candleColor : na)

plot(fastEma, "Fast EMA", color=BLUE, linewidth=1)
plot(slowEma, "Slow EMA", color=ORANGE, linewidth=1)

// The dashboard summarizes the three layers of context without requiring the user
// to inspect every plot: trend state, latest confirmed structure, and EMA relationship.
var table dash = table.new(position.top_right, 2, 3, bgcolor=DASH_BG, border_color=DASH_BORDER, border_width=1)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "Market Trend", text_color=color.white, text_size=size.small, bgcolor=DASH_BG)
    table.cell(dash, 1, 0, uptrend ? "BULLISH" : downtrend ? "BEARISH" : "NEUTRAL", text_color=uptrend ? GREEN : downtrend ? RED : GRAY, text_size=size.small, bgcolor=DASH_BG)
    
    table.cell(dash, 0, 1, "Last Structure", text_color=color.white, text_size=size.small, bgcolor=DASH_BG)
    table.cell(dash, 1, 1, lastStruct, text_color=(lastStruct == "HH" or lastStruct == "HL") ? GREEN : (lastStruct == "LL" or lastStruct == "LH") ? RED : GRAY, text_size=size.small, bgcolor=DASH_BG)
    
    table.cell(dash, 0, 2, "EMA Signal", text_color=color.white, text_size=size.small, bgcolor=DASH_BG)
    table.cell(dash, 1, 2, uptrend ? "Fast > Slow" : downtrend ? "Slow > Fast" : "Equal", text_color=BLUE, text_size=size.small, bgcolor=DASH_BG)

//---------------------------------------------------------------------------------------------------------------------}
// SIGNALS
//---------------------------------------------------------------------------------------------------------------------{
alertcondition(bullSignal, title="Bullish Pattern", message="Apex: Bullish Candlestick Pattern Detected! Consider Long Entry.")
alertcondition(bearSignal, title="Bearish Pattern", message="Apex: Bearish Candlestick Pattern Detected! Consider Short Entry.")
alertcondition(uptrend and lastStruct == "HL", title="Bullish Structure", message="Apex: Higher Low detected in uptrend - Potential Long Entry Zone.")
alertcondition(downtrend and lastStruct == "LH", title="Bearish Structure", message="Apex: Lower High detected in downtrend - Potential Short Entry Zone.")
````
