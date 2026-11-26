# Trend Vector Pro v2.0

- url: https://www.tradingview.com/script/csOouivq-Trend-Vector-Pro-v2-0/
- type: strategy
- pine_id: PUB;0f41feb0a63447e2ac31677b6e12a270
- version: 2.0

## Description

[b]Trend Vector Pro v2.0[/b]
[b]👨‍💻 Developed by: Mohammed Bedaiwi[/b]

[b]💡 Strategy Overview & Coherence[/b]

[b]Trend Vector Pro (TVPro)[/b] is a momentum-based trend & reversal strategy that uses a custom smoothed oscillator, an optional ADX filter, and classic Pivot Points to create a single, coherent trading framework.

[b]Instead of stacking random indicators, TVPro is built around these integrated components:[/b]
[list]
[*] A custom momentum engine (signal generation)
[*] An optional ADX filter (trend quality control)
[*] Daily Pivot Points (context, targets & S/R)
[*] Swing-based “Golden Bar” trailing stops (trade management)
[*] Optional extended bar detection (overextension alerts)
[/list]
All parts are designed to work together and are documented below to address originality & usefulness requirements.

[b]🔍 Core Components & Justification[/b]

[b]1. Custom Momentum Engine (Main Signal Source)[/b]
TVPro’s engine is a custom oscillator derived from the bar midpoint ([code]hl2[/code]), similar in spirit to the Awesome Oscillator but adapted and fully integrated into the strategy. It measures velocity and acceleration of price, letting the script distinguish between strong impulses, weakening trends, and pure noise.

[b]2. ADX Filter (Trend Strength Validation – Optional)[/b]
Uses Average Directional Index (ADX) as a gatekeeper.
[i]Why this matters:[/i] This prevents the strategy from firing signals in choppy, non-trending environments (when ADX is below the threshold) and keeps trades focused on periods of clear directional strength.

[b]3. Classic Pivot Points (Context & Targets)[/b]
Calculates Daily Pivot Points ([code]PP, R1-R3, S1-S3[/code]) via [code]request.security()[/code] using prior session data.
[i]Why this matters:[/i] Momentum gives the signal, ADX validates the environment, and Pivots add external structure for risk and target planning. This is a designed interaction, not a random mashup.

[b]🧭 Trend State Logic (5-State Bar Coloring)[/b]

The strategy uses the momentum's value + slope to define five states, turning the chart into a visual momentum map:

[list]
[*] [b]🟢 STRONG BULL (Bright Green):[/b] Momentum accelerating UP. → Strong upside impulse.
[*] [b]🌲 WEAK BULL (Dark Green):[/b] Momentum decelerating DOWN (while positive). → Pullback/pause zone.
[*] [b]🔴 STRONG BEAR (Bright Red):[/b] Momentum accelerating DOWN. → Strong downside impulse.
[*] [b]🍷 WEAK BEAR (Dark Red):[/b] Momentum decelerating UP (while negative). → Rally/short-covering zone.
[*] [b]🔵 NEUTRAL / CHOP (Cyan):[/b] Momentum is near zero (based on noise threshold). → Consolidation / low volatility.
[/list]

[b]🎯 Signal Logic Modes[/b]

TVPro provides two selectable entry styles, controlled by input:

[list=1]
[*] [b]Reversals Only (Cleaner Mode – Default):[/b] Targets trend flips. Entry triggers when the current state is Bullish (or Bearish) and the previous state was not. This reduces noise and over-trading.
[*] [b]All Strong Pulses (Aggressive Mode):[/b] Targets acceleration phases. Entry triggers when the bar turns to [b]STRONG BULL[/b] or [b]STRONG BEAR[/b] after any other state. This mode produces more trades.
[/list]

[b]📌 Risk Management Tools[/b]

[list]
[*] [b]🟡 Golden Bars – Trailing Stops:[/b] Yellow “Trail” Arrows mark confirmed Swing Highs/Lows. These are used as logical trailing stop levels based on market structure.
[*] [b]Extended Bars:[/b] Detects when price closes outside a 2-standard-deviation channel, flagging overextension where a pullback is more likely.
[*] [b]Pivot Points:[/b] Used as external targets for Take Profit and structural stop placement.
[/list]

[b]⚙️ Strategy Defaults (Crucial for Publication Compliance)[/b]

[b]To keep backtest results realistic and in line with House Rules, TVPro is published with the following fixed default settings:[/b]

[list]
[*] [b]Order Size:[/b] [i]5% of equity per trade[/i] ([code]default_qty_value = 5[/code])
[*] [b]Commission:[/b] [i]0.04% per order[/i] ([code]commission_value = 0.04[/code])
[*] [b]Slippage:[/b] [i]2 ticks[/i] ([code]slippage = 2[/code])
[*] [b]Initial Capital:[/b] 10,000
[/list]

[b]📘 How to Trade with Trend Vector Pro[/b]

[list]
[*] [b]Entry:[/b] Take Long when a Long signal appears and confirm the bar is Green (Bull state). Short for Red (Bear state).
[*] [b]Stop Loss:[/b] Place the initial SL near the latest swing High/Low, or near a relevant Pivot level.
[*] [b]Trade Management:[/b] Follow [i]Golden (Trail) Arrows[/i] to trail your stop behind structure.
[*] [b]Exits:[/b] Exit when: the trailing stop is hit, Price reaches a major Pivot level, or an opposite signal prints.
[/list]

[b]🛑 Disclaimer[/b]

[quote]
[b]This script is for educational purposes only and does not constitute financial advice.[/b] Past performance does not guarantee future results. Always forward-test and use proper risk management before applying any strategy to live trading.
[/quote]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mbedaiwi

//@version=6
strategy("Trend Vector Pro v2.1", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=5, 
commission_type=strategy.commission.percent, commission_value=0.04, slippage=2) 

// -----------------------------------------------------------------------------
// 1. CONFIGURATION & INPUTS  
// -----------------------------------------------------------------------------
grp_main = "Trend Configuration"
int fastLen = input.int(5, "Fast Momentum Length", minval=1, group=grp_main)
int slowLen = input.int(34, "Slow Momentum Length", minval=1, group=grp_main)
int smooth = input.int(5, "Smoothing Factor", minval=1, group=grp_main)
bool useAdaptive = input.bool(true, "Adaptive Length (short histories)", group=grp_main, tooltip="When the chart has fewer bars than the Slow Momentum Length (e.g. recently listed stocks on monthly/weekly), use all available bars instead of waiting for the full length. Early signals on such charts are less reliable.")

grp_filters = "Signal Filters & Strategy"
string tradeDir = input.string("Long Only", "Trade Direction", options=["Long Only", "Short Only", "Long & Short"], group=grp_filters, tooltip="Long Only: short signals close the long position instead of opening a short.\nShort Only: long signals close the short position instead of opening a long.")
bool allowLong  = tradeDir != "Short Only"
bool allowShort = tradeDir != "Long Only"

string sigMode = input.string("Reversals Only (Cleaner)", "Signal Logic Mode", options=["Reversals Only (Cleaner)", "All Strong Pulses (Aggressive)"], group=grp_filters)

// Early Entry (optional): buy when momentum turns up while still below zero
bool useEarly = input.bool(false, "Early Entry (momentum turning up below zero)", group=grp_filters, tooltip="Adds a long entry when the smoothed momentum turns up while still below zero (closer to bottoms, more false signals). If momentum turns down again before crossing zero, the position is closed (Early Exit).")

// Bottom Reversal (optional): oversold bounce back inside the lower Bollinger band
bool  useBottom = input.bool(false, "Bottom Reversal Entry", group=grp_filters, tooltip="Adds a long entry when the previous bar closed below the lower Bollinger band, the current bar closes back above it with a bullish candle, and RSI was oversold in the last 3 bars. Exits on a momentum turn-down below zero or the stop loss.")
int   rsiLen    = input.int(14, "Bottom: RSI Length", minval=2, group=grp_filters)
float rsiOS     = input.float(35, "Bottom: RSI Oversold Level", minval=1, maxval=50, group=grp_filters)

bool useAdx = input.bool(false, "Use ADX Filter?", group=grp_filters)
int adxThresh = input.int(20, "ADX Threshold", minval=1, group=grp_filters)

grp_risk = "Risk Management"
string slMode  = input.string("Off", "Stop Loss", options=["Off", "Percent", "ATR"], group=grp_risk, tooltip="Fixed stop set at entry. Percent: entry minus X%. ATR: entry minus (ATR x multiplier).")
float  slPct   = input.float(10.0, "Stop Loss %", minval=0.1, step=0.5, group=grp_risk)
int    atrLen  = input.int(14, "ATR Length", minval=1, group=grp_risk)
float  atrMult = input.float(3.0, "ATR Multiplier", minval=0.1, step=0.1, group=grp_risk)
bool   showSL  = input.bool(true, "Show Stop Line", group=grp_risk)

grp_visuals = "Visual Settings"
string textSize  = input.string(size.small, "Labels Text Size", options=[size.auto, size.tiny, size.small, size.normal, size.large], group=grp_visuals)
string themeMode = input.string("Auto", "Color Theme", options=["Auto", "Dark", "Light"], group=grp_visuals, tooltip="Auto detects the chart background and picks the matching palette.")

// --- Dark background palette ---
grp_dark = "Palette — Dark Background"
color d_strong_bull = input.color(#00E676, "Strong Bullish",   group=grp_dark)
color d_weak_bull   = input.color(#2E9E5B, "Neutral/Bullish",  group=grp_dark)
color d_neutral     = input.color(#26C6DA, "Neutral",          group=grp_dark)
color d_weak_bear   = input.color(#B23A48, "Neutral/Bearish",  group=grp_dark)
color d_strong_bear = input.color(#FF1744, "Strong Bearish",   group=grp_dark)
color d_golden      = input.color(#FFD600, "Golden Bar",       group=grp_dark)
color d_extended    = input.color(#B0BEC5, "Extended Bar",     group=grp_dark)
color d_res         = input.color(#EF5350, "Pivot Resistance", group=grp_dark)
color d_sup         = input.color(#66BB6A, "Pivot Support",    group=grp_dark)
color d_pp          = input.color(#FFD600, "Pivot Point (PP)", group=grp_dark)

// --- Light background palette ---
grp_light = "Palette — Light Background"
color l_strong_bull = input.color(#00A152, "Strong Bullish",   group=grp_light)
color l_weak_bull   = input.color(#81C784, "Neutral/Bullish",  group=grp_light)
color l_neutral     = input.color(#0097A7, "Neutral",          group=grp_light)
color l_weak_bear   = input.color(#E57373, "Neutral/Bearish",  group=grp_light)
color l_strong_bear = input.color(#D50000, "Strong Bearish",   group=grp_light)
color l_golden      = input.color(#F9A825, "Golden Bar",       group=grp_light)
color l_extended    = input.color(#78909C, "Extended Bar",     group=grp_light)
color lt_res         = input.color(#C62828, "Pivot Resistance", group=grp_light)
color lt_sup         = input.color(#2E7D32, "Pivot Support",    group=grp_light)
color lt_pp          = input.color(#EF6C00, "Pivot Point (PP)", group=grp_light)

grp_pivots = "Pivots Lines"
bool showPivotLines = input.bool(false, "Show Pivot Lines on Chart", group=grp_pivots)
string pivotPeriod = input.timeframe("D", "Pivot Timeframe", group=grp_pivots)

// -----------------------------------------------------------------------------
// 1b. THEME DETECTION & ACTIVE PALETTE
// -----------------------------------------------------------------------------
float bgLuma  = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
bool  isDark  = themeMode == "Dark" ? true : themeMode == "Light" ? false : bgLuma < 128

color col_strong_bull = isDark ? d_strong_bull : l_strong_bull
color col_weak_bull   = isDark ? d_weak_bull   : l_weak_bull
color col_neutral     = isDark ? d_neutral     : l_neutral
color col_weak_bear   = isDark ? d_weak_bear   : l_weak_bear
color col_strong_bear = isDark ? d_strong_bear : l_strong_bear
color col_golden      = isDark ? d_golden      : l_golden
color col_extended    = isDark ? d_extended    : l_extended
color c_res           = isDark ? d_res         : lt_res
color c_sup           = isDark ? d_sup         : lt_sup
color c_pp            = isDark ? d_pp          : lt_pp

// -----------------------------------------------------------------------------
// 2. MOMENTUM ENGINE & ADX
// -----------------------------------------------------------------------------
float mid = hl2
int   barsAvail = bar_index + 1
int   effSlow   = useAdaptive ? math.max(math.min(slowLen, barsAvail), 1) : slowLen
int   minBars   = math.max(fastLen * 2, fastLen + 2)
float aoRaw     = ta.sma(mid, fastLen) - ta.sma(mid, effSlow)
float ao        = (useAdaptive and barsAvail < minBars) ? na : aoRaw
float aoSmooth = ta.ema(ao, smooth) 

[diplus, diminus, adxValue] = ta.dmi(14, 14)
bool marketIsTrending = useAdx ? (adxValue > adxThresh) : true

// -----------------------------------------------------------------------------
// 3. TREND STATE LOGIC
// -----------------------------------------------------------------------------
var color barColor = na
string stateBias = "NEUTRAL"

// Momentum must be fully computed before any state / signal is produced
bool momReady = not na(aoSmooth) and not na(aoSmooth[1])

if not momReady
    barColor := na
    stateBias := "NEUTRAL"
else if aoSmooth > 0
    if aoSmooth > aoSmooth[1]
        barColor := col_strong_bull
        stateBias := "STRONG BULL"
    else
        barColor := col_weak_bull
        stateBias := "WEAK BULL"
else
    if aoSmooth < aoSmooth[1]
        barColor := col_strong_bear
        stateBias := "STRONG BEAR"
    else
        barColor := col_weak_bear
        stateBias := "WEAK BEAR"

float noiseThreshold = ta.stdev(aoSmooth, 100) * 0.2
if momReady and math.abs(aoSmooth) < noiseThreshold
    barColor := col_neutral
    stateBias := "NEUTRAL"

// Trend bias used by ALL signals. Captured here so the visual-only
// Extended / Golden overrides below can never block or alter entries/exits.
string trendBias = stateBias

// -----------------------------------------------------------------------------
// 4. SPECIAL BAR LOGIC (Visuals Only)
// -----------------------------------------------------------------------------
int extPeriod = 20
float extDev = 2.0
float basis = ta.sma(close, extPeriod)
float dev = ta.stdev(close, extPeriod)
float upper = basis + (dev * extDev)
float lower = basis - (dev * extDev)
bool isExtended = (close > upper) or (close < lower)

if isExtended and momReady
    barColor := col_extended
    stateBias := "EXTENDED"

bool isSwingHigh = high[1] > high[0] and high[1] > high[2]
bool isSwingLow = low[1] < low[0] and low[1] < low[2]
bool goldenBull = (trendBias == "STRONG BULL" or trendBias == "WEAK BULL") and isSwingHigh
bool goldenBear = (trendBias == "STRONG BEAR" or trendBias == "WEAK BEAR") and isSwingLow

if goldenBull or goldenBear
    barColor := col_golden

barcolor(barColor)

// -----------------------------------------------------------------------------
// 5. SIGNALS GENERATION
// -----------------------------------------------------------------------------
bool entryLong = false
bool entryShort = false

// Logic A: Aggressive (based on trend state, not bar color)
bool aggLong = (trendBias == "STRONG BULL") and (trendBias[1] != "STRONG BULL")
bool aggShort = (trendBias == "STRONG BEAR") and (trendBias[1] != "STRONG BEAR")

// Logic B: Reversals Only
bool isBullBias = (trendBias == "STRONG BULL" or trendBias == "WEAK BULL")
bool isBearBias = (trendBias == "STRONG BEAR" or trendBias == "WEAK BEAR")
bool revLong = isBullBias and not isBullBias[1]
bool revShort = isBearBias and not isBearBias[1]

if sigMode == "Reversals Only (Cleaner)"
    entryLong := revLong
    entryShort := revShort
else
    entryLong := aggLong
    entryShort := aggShort

// Logic C: Early Entry (optional, long side)
bool momTurnUp   = aoSmooth < 0 and aoSmooth > aoSmooth[1] and aoSmooth[1] <= aoSmooth[2]
bool momTurnDown = aoSmooth < 0 and aoSmooth < aoSmooth[1] and aoSmooth[1] >= aoSmooth[2]
bool earlyLong   = useEarly and momTurnUp and not entryLong

// Logic D: Bottom Reversal (optional, long side)
float rsiVal     = ta.rsi(close, rsiLen)
float rsiLow3    = ta.lowest(rsiVal, 3)
bool  bottomLong = useBottom and momReady and not isBullBias and close[1] < lower[1] and close > lower and close > open and rsiLow3 < rsiOS and not entryLong and not earlyLong

bool earlyExit   = (useEarly or useBottom) and momTurnDown
entryLong := entryLong or earlyLong or bottomLong

bool rawLong  = entryLong
bool rawShort = entryShort
if useAdx
    entryLong := entryLong and marketIsTrending
    entryShort := entryShort and marketIsTrending

// -----------------------------------------------------------------------------
// 6. STRATEGY EXECUTION (BACKTESTING) — respects Trade Direction
// -----------------------------------------------------------------------------
strategy.risk.allow_entry_in(tradeDir == "Long Only" ? strategy.direction.long : tradeDir == "Short Only" ? strategy.direction.short : strategy.direction.all)

if rawShort and not allowShort
    strategy.close("Long", comment="Exit Long")
if earlyExit and strategy.position_size > 0
    strategy.close("Long", comment="Early Exit")
if rawLong and not allowLong
    strategy.close("Short", comment="Exit Short")

if entryLong and allowLong
    strategy.entry("Long", strategy.long, comment=bottomLong ? "Bottom Long" : earlyLong ? "Early Long" : "Long")
if entryShort and allowShort
    strategy.entry("Short", strategy.short, comment="Short")

// --- Stop Loss (fixed at entry) ---
float atrVal = ta.atr(atrLen)
var float longStop  = na
var float shortStop = na
if slMode != "Off"
    if entryLong and allowLong and strategy.position_size <= 0
        longStop := slMode == "Percent" ? close * (1 - slPct / 100) : close - atrMult * atrVal
    if entryShort and allowShort and strategy.position_size >= 0
        shortStop := slMode == "Percent" ? close * (1 + slPct / 100) : close + atrMult * atrVal
    if not na(longStop) and (strategy.position_size > 0 or (entryLong and allowLong))
        strategy.exit("Long SL", from_entry="Long", stop=longStop, comment="Stop Loss")
    if not na(shortStop) and (strategy.position_size < 0 or (entryShort and allowShort))
        strategy.exit("Short SL", from_entry="Short", stop=shortStop, comment="Stop Loss")

plot(showSL and slMode != "Off" and strategy.position_size > 0 ? longStop : na, "Long Stop", color=col_strong_bear, style=plot.style_linebr, linewidth=1)
plot(showSL and slMode != "Off" and strategy.position_size < 0 ? shortStop : na, "Short Stop", color=col_strong_bull, style=plot.style_linebr, linewidth=1)

// -----------------------------------------------------------------------------
// 7. VISUALS: ARROWS & LABELS
// -----------------------------------------------------------------------------
color dynamicText = chart.fg_color 

// Exit labels only when there is actually a position to exit
bool showLongSig  = allowLong  ? entryLong  : (rawLong  and strategy.position_size < 0)
bool showShortSig = allowShort ? entryShort : (rawShort and strategy.position_size > 0)
string longTxt  = allowLong  ? (bottomLong ? "Bottom\nLong" : earlyLong ? "Early\nLong" : "Long") : "Exit\nShort"
string shortTxt = allowShort ? "Short" : "Exit\nLong"

plotshape(showLongSig, title="Long Signal", style=shape.arrowup, location=location.belowbar, color=col_strong_bull, size=size.tiny)
plotshape(showShortSig, title="Short Signal", style=shape.arrowdown, location=location.abovebar, color=col_strong_bear, size=size.tiny)

if showLongSig
    label.new(bar_index, low, longTxt, yloc=yloc.belowbar, color=color(na), textcolor=dynamicText, style=label.style_none, size=textSize)
if showShortSig
    label.new(bar_index, high, shortTxt, yloc=yloc.abovebar, color=color(na), textcolor=dynamicText, style=label.style_none, size=textSize)

bool showTrailShort = goldenBear and allowShort
bool showTrailLong  = goldenBull and allowLong
plotshape(showTrailShort, title="Trail Stop (Short)", style=shape.arrowdown, location=location.abovebar, color=col_golden, size=size.tiny)
plotshape(showTrailLong, title="Trail Stop (Long)", style=shape.arrowup, location=location.belowbar, color=col_golden, size=size.tiny)

if showTrailShort
    label.new(bar_index, high, "Trail\nShort", yloc=yloc.abovebar, color=color(na), textcolor=dynamicText, style=label.style_none, size=textSize)
if showTrailLong
    label.new(bar_index, low, "Trail\nLong", yloc=yloc.belowbar, color=color(na), textcolor=dynamicText, style=label.style_none, size=textSize)

// -----------------------------------------------------------------------------
// 8. DASHBOARD
// -----------------------------------------------------------------------------
var label infoLabel = label.new(na, na, "")
label.delete(infoLabel)

if barstate.islast
    string biasText = "BIAS: " + stateBias + "\nMODE: " + tradeDir
    // Panel background contrasts slightly with the chart so it reads on both themes
    color panelBg  = isDark ? color.new(#1E222D, 0) : color.new(#F0F3FA, 0)
    color txtColor = barColor
    infoLabel := label.new(bar_index + 3, close, text=biasText, color=panelBg, textcolor=txtColor, style=label.style_label_left, text_formatting=text.format_bold, size=size.small)

// -----------------------------------------------------------------------------
// 9. PIVOT POINTS
// -----------------------------------------------------------------------------
p_h = request.security(syminfo.tickerid, pivotPeriod, high[1], lookahead=barmerge.lookahead_on)
p_l = request.security(syminfo.tickerid, pivotPeriod, low[1], lookahead=barmerge.lookahead_on)
p_c = request.security(syminfo.tickerid, pivotPeriod, close[1], lookahead=barmerge.lookahead_on)

float pp = (p_h + p_l + p_c) / 3
float r1 = (2 * pp) - p_l
float s1 = (2 * pp) - p_h
float r2 = pp + (p_h - p_l)
float s2 = pp - (p_h - p_l)
float r3 = p_h + 2 * (pp - p_l)
float s3 = p_l - 2 * (p_h - pp)

draw_pivot_line(price, col, width) =>
    line.new(bar_index, price, bar_index, price, color=col, width=width)

var line l_r3 = na
var line l_r2 = na
var line l_r1 = na
var line l_pp = na
var line l_s1 = na
var line l_s2 = na
var line l_s3 = na

bool isNewPivotPeriod = ta.change(time(pivotPeriod)) != 0

if showPivotLines
    if isNewPivotPeriod
        l_r3 := draw_pivot_line(r3, color.new(c_res, 30), 1)
        l_r2 := draw_pivot_line(r2, color.new(c_res, 30), 1)
        l_r1 := draw_pivot_line(r1, color.new(c_res, 30), 1)
        l_pp := draw_pivot_line(pp, c_pp, 2)
        l_s1 := draw_pivot_line(s1, color.new(c_sup, 30), 1)
        l_s2 := draw_pivot_line(s2, color.new(c_sup, 30), 1)
        l_s3 := draw_pivot_line(s3, color.new(c_sup, 30), 1)
    else
        line.set_x2(l_r3, bar_index)
        line.set_x2(l_r2, bar_index)
        line.set_x2(l_r1, bar_index)
        line.set_x2(l_pp, bar_index)
        line.set_x2(l_s1, bar_index)
        line.set_x2(l_s2, bar_index)
        line.set_x2(l_s3, bar_index)
````
