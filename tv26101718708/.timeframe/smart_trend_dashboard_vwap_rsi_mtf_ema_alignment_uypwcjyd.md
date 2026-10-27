# Smart Trend Dashboard: VWAP + RSI MTF + EMA Alignment

- url: https://www.tradingview.com/script/UyPWCjYD-Smart-Trend-Dashboard-VWAP-RSI-MTF-EMA-Alignment/
- type: indicator
- pine_id: PUB;25410c16d0f347ddbc2cf47f4ffad7fb
- version: 1.0

## Description

OVERVIEW

VWAP + RSI MTF Trend Dashboard is a structured market analysis tool designed to help traders evaluate trend alignment, momentum strength, and key price positioning across multiple timeframes.

Instead of relying on a single indicator, this script combines Multi-Timeframe RSI, EMA trend filters, and anchored VWAP (Daily & Weekly) into a unified dashboard. The goal is not prediction, but clarity — providing a clean, data-driven view of market conditions without unnecessary noise.

Similar to professional tools that focus on structure and context rather than clutter, this indicator emphasizes alignment across timeframes and institutional price levels.
https://www.tradingview.com/x/2V7CJQCM/
🔵 CONCEPT

Markets move based on momentum, trend, and value.

This script builds around three core principles:

◉ Multi-Timeframe Confirmation
https://www.tradingview.com/x/fLEiC6d3/
Instead of analyzing a single timeframe, the indicator evaluates RSI and EMA across multiple timeframes to identify true directional alignment.

◉ VWAP as Institutional Benchmark

VWAP represents the average traded price weighted by volume, often used by institutions as a reference level for value and execution.

Price above VWAP → potential bullish bias
Price below VWAP → potential bearish bias
◉ Confluence-Based Trend Strength

Rather than generating isolated signals, the script calculates a trend strength score based on multiple aligned conditions, helping traders avoid weak or conflicting setups.

🔵 FEATURES
◉ Multi-Timeframe RSI Engine
Tracks RSI across 4 customizable timeframes
Highlights overbought / oversold conditions
Detects momentum shifts
◉ EMA Trend Alignment
EMA plotted across multiple timeframes
Acts as dynamic trend filter
Helps identify directional bias
◉ Anchored VWAP (Daily & Weekly)
Institutional price reference
Optional VWAP bands
Supports:
Standard deviation mode
Percentage mode
◉ VWAP Deviation Bands
Identify extended price zones
Useful for:
Mean reversion
Breakout continuation
◉ Trend Strength Scoring System
Combines:
RSI alignment (4 TFs)
EMA positioning (4 TFs)
Outputs a 0–100% strength score
◉ Smart Dashboard Panel

Displays:

RSI values per timeframe
EMA positioning
Trend state (Bullish / Bearish / Mixed)
VWAP relationship (Above / Below)
Overall market strength
◉ Alert System
Strong Bullish / Bearish alignment
RSI overbought / oversold transitions
Price crossing Daily & Weekly VWAP
🔵 HOW TO USE
◉ Trend Identification
Look for alignment across multiple timeframes
Strong trend = higher confluence score
◉ VWAP Context
Above VWAP → bullish environment
Below VWAP → bearish environment
◉ Momentum Confirmation
Use RSI to confirm entries
Avoid trades when RSI shows divergence or weakness
◉ Trend Strength Filter
75–100% → Strong trend
50–75% → Moderate
Below 50% → Weak / ranging
◉ Best Practice

Use this indicator alongside:

Price action
Market structure
Risk management
🔵 NOTES
This script is designed as a decision-support tool, not a standalone trading system
Signals represent market conditions, not direct buy/sell instructions
Works across all markets (Stocks, Forex, Crypto, Indices)
⚠️ DISCLAIMER

This indicator is for educational and informational purposes only.
It does not provide financial advice, investment recommendations, or trading signals.

Trading involves risk. Always:

Perform your own analysis
Use proper risk management
Consult a qualified financial advisor if needed

Past performance does not guarantee future results.

🔵 CONCLUSION

VWAP + RSI MTF Trend Dashboard transforms multiple technical components into a clean, structured workflow.

By focusing on:

Multi-timeframe alignment
Institutional price levels
Momentum confirmation

it helps traders better understand market context, reduce noise, and make more informed decisions.

## Source Code

````pine
//@version=5
indicator("VWAP+RSI MTF)", overlay=true, max_bars_back=5000)

// ============================================================================
// RSI SETTINGS
// ============================================================================
rsiLength     = input.int(14, "RSI Length",           minval=1,              group="RSI Settings")
rsiOverbought = input.int(70, "RSI Overbought Level", minval=50, maxval=100, group="RSI Settings")
rsiOversold   = input.int(30, "RSI Oversold Level",   minval=0,  maxval=50,  group="RSI Settings")

// ============================================================================
// EMA SETTINGS
// ============================================================================
emaLength = input.int(21, "EMA Length", minval=1, group="EMA Settings")

// ============================================================================
// MULTI-TIMEFRAME SETTINGS
// ============================================================================
tf1 = input.timeframe("15",  "Timeframe 1", group="Timeframes")
tf2 = input.timeframe("60",  "Timeframe 2", group="Timeframes")
tf3 = input.timeframe("240", "Timeframe 3", group="Timeframes")
tf4 = input.timeframe("D",   "Timeframe 4", group="Timeframes")

// ============================================================================
// DISPLAY SETTINGS
// ============================================================================
showEMA       = input.bool(true, "Show EMA Lines", group="Display")
showDashboard = input.bool(true, "Show Dashboard", group="Display")

// ============================================================================
// VWAP SETTINGS
// ============================================================================
showDailyVWAP  = input.bool(true,  "Show Daily VWAP",          group="VWAP Settings")
showWeeklyVWAP = input.bool(true,  "Show Weekly VWAP",         group="VWAP Settings")
hideonDWM      = input.bool(false, "Hide VWAP on 1D or Above", group="VWAP Settings")
vwapSrc        = input.source(hlc3, "VWAP Source",             group="VWAP Settings")
vwapOffset     = input.int(0, "VWAP Offset",                   group="VWAP Settings")

// ============================================================================
// VWAP BANDS SETTINGS
// ============================================================================
calcModeInput = input.string("Standard Deviation", "Bands Calculation Mode",
     options=["Standard Deviation", "Percentage"], group="VWAP Bands")
showBand_1 = input.bool(true,  "",                    group="VWAP Bands", inline="band_1")
bandMult_1 = input.float(1.0, "Bands Multiplier #1", group="VWAP Bands", inline="band_1", step=0.5, minval=0)
showBand_2 = input.bool(false, "",                    group="VWAP Bands", inline="band_2")
bandMult_2 = input.float(2.0, "Bands Multiplier #2", group="VWAP Bands", inline="band_2", step=0.5, minval=0)
showBand_3 = input.bool(false, "",                    group="VWAP Bands", inline="band_3")
bandMult_3 = input.float(3.0, "Bands Multiplier #3", group="VWAP Bands", inline="band_3", step=0.5, minval=0)

// ============================================================================
// RSI & EMA MULTI-TF CALCULATIONS
// ============================================================================
rsi_tf1 = request.security(syminfo.tickerid, tf1, ta.rsi(close, rsiLength))
rsi_tf2 = request.security(syminfo.tickerid, tf2, ta.rsi(close, rsiLength))
rsi_tf3 = request.security(syminfo.tickerid, tf3, ta.rsi(close, rsiLength))
rsi_tf4 = request.security(syminfo.tickerid, tf4, ta.rsi(close, rsiLength))

ema_tf1 = request.security(syminfo.tickerid, tf1, ta.ema(close, emaLength))
ema_tf2 = request.security(syminfo.tickerid, tf2, ta.ema(close, emaLength))
ema_tf3 = request.security(syminfo.tickerid, tf3, ta.ema(close, emaLength))
ema_tf4 = request.security(syminfo.tickerid, tf4, ta.ema(close, emaLength))

currentPrice = close

// ============================================================================
// VWAP ANCHOR DETECTION
// ============================================================================
cumVolume = ta.cum(volume)
if barstate.islast and cumVolume == 0
    runtime.error("No volume is provided by the data vendor.")

bool isNewDay = timeframe.change("D")
if na(vwapSrc[1])
    isNewDay := true

bool isNewWeek = timeframe.change("W")
if na(vwapSrc[1])
    isNewWeek := true

// ============================================================================
// VWAP CORE CALCULATIONS (always computed, shown conditionally)
// ============================================================================
[_vD, _stdevUD, _] = ta.vwap(vwapSrc, isNewDay,  1)
[_vW, _stdevUW, _] = ta.vwap(vwapSrc, isNewWeek, 1)

bool showDVWAP = showDailyVWAP  and not (hideonDWM and timeframe.isdwm)
bool showWVWAP = showWeeklyVWAP and not (hideonDWM and timeframe.isdwm)

float vwapDaily  = showDVWAP ? _vD : na
float vwapWeekly = showWVWAP ? _vW : na

float _basisD = calcModeInput == "Standard Deviation" ? (_stdevUD - _vD) : _vD * 0.01
float _basisW = calcModeInput == "Standard Deviation" ? (_stdevUW - _vW) : _vW * 0.01

// Daily VWAP Bands
float dUpperBand1 = showDVWAP ? _vD + _basisD * bandMult_1 : na
float dLowerBand1 = showDVWAP ? _vD - _basisD * bandMult_1 : na
float dUpperBand2 = showDVWAP ? _vD + _basisD * bandMult_2 : na
float dLowerBand2 = showDVWAP ? _vD - _basisD * bandMult_2 : na
float dUpperBand3 = showDVWAP ? _vD + _basisD * bandMult_3 : na
float dLowerBand3 = showDVWAP ? _vD - _basisD * bandMult_3 : na

// Weekly VWAP Bands
float wUpperBand1 = showWVWAP ? _vW + _basisW * bandMult_1 : na
float wLowerBand1 = showWVWAP ? _vW - _basisW * bandMult_1 : na
float wUpperBand2 = showWVWAP ? _vW + _basisW * bandMult_2 : na
float wLowerBand2 = showWVWAP ? _vW - _basisW * bandMult_2 : na
float wUpperBand3 = showWVWAP ? _vW + _basisW * bandMult_3 : na
float wLowerBand3 = showWVWAP ? _vW - _basisW * bandMult_3 : na

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================
getRSIColor(float rsiValue) =>
    color result = color.orange
    if rsiValue >= rsiOverbought
        result := color.red
    else if rsiValue <= rsiOversold
        result := color.lime
    else if rsiValue >= 50
        result := color.green
    result

getEMAColor(float emaValue, float price) =>
    price > emaValue ? color.lime : color.red

// ============================================================================
// EMA PLOTS
// ============================================================================
plot(showEMA ? ema_tf1 : na, title="EMA TF1", color=color.new(color.blue,   50), linewidth=1)
plot(showEMA ? ema_tf2 : na, title="EMA TF2", color=color.new(color.green,  50), linewidth=1)
plot(showEMA ? ema_tf3 : na, title="EMA TF3", color=color.new(color.orange, 50), linewidth=1)
plot(showEMA ? ema_tf4 : na, title="EMA TF4", color=color.new(color.red,    50), linewidth=2)

// ============================================================================
// DAILY VWAP PLOTS (Blue tones)
// ============================================================================
plot(vwapDaily, title="Daily VWAP", color=#2962FF, linewidth=2, offset=vwapOffset)

dUp1 = plot(showBand_1 ? dUpperBand1 : na, title="D Upper Band #1", color=color.new(color.blue,  40), offset=vwapOffset)
dLo1 = plot(showBand_1 ? dLowerBand1 : na, title="D Lower Band #1", color=color.new(color.blue,  40), offset=vwapOffset)
fill(dUp1, dLo1, title="D Band Fill #1", color=color.new(color.blue, 93))

dUp2 = plot(showBand_2 ? dUpperBand2 : na, title="D Upper Band #2", color=color.new(color.aqua,  40), offset=vwapOffset)
dLo2 = plot(showBand_2 ? dLowerBand2 : na, title="D Lower Band #2", color=color.new(color.aqua,  40), offset=vwapOffset)
fill(dUp2, dLo2, title="D Band Fill #2", color=color.new(color.aqua, 93))

dUp3 = plot(showBand_3 ? dUpperBand3 : na, title="D Upper Band #3", color=color.new(color.teal,  40), offset=vwapOffset)
dLo3 = plot(showBand_3 ? dLowerBand3 : na, title="D Lower Band #3", color=color.new(color.teal,  40), offset=vwapOffset)
fill(dUp3, dLo3, title="D Band Fill #3", color=color.new(color.teal, 93))

// ============================================================================
// WEEKLY VWAP PLOTS (Orange tones)
// ============================================================================
plot(vwapWeekly, title="Weekly VWAP", color=#FF6D00, linewidth=2, offset=vwapOffset)

wUp1 = plot(showBand_1 ? wUpperBand1 : na, title="W Upper Band #1", color=color.new(color.orange,  40), offset=vwapOffset)
wLo1 = plot(showBand_1 ? wLowerBand1 : na, title="W Lower Band #1", color=color.new(color.orange,  40), offset=vwapOffset)
fill(wUp1, wLo1, title="W Band Fill #1", color=color.new(color.orange, 93))

wUp2 = plot(showBand_2 ? wUpperBand2 : na, title="W Upper Band #2", color=color.new(color.yellow,  40), offset=vwapOffset)
wLo2 = plot(showBand_2 ? wLowerBand2 : na, title="W Lower Band #2", color=color.new(color.yellow,  40), offset=vwapOffset)
fill(wUp2, wLo2, title="W Band Fill #2", color=color.new(color.yellow, 93))

wUp3 = plot(showBand_3 ? wUpperBand3 : na, title="W Upper Band #3", color=color.new(color.maroon,  40), offset=vwapOffset)
wLo3 = plot(showBand_3 ? wLowerBand3 : na, title="W Lower Band #3", color=color.new(color.maroon,  40), offset=vwapOffset)
fill(wUp3, wLo3, title="W Band Fill #3", color=color.new(color.maroon, 93))

// ============================================================================
// TREND STRENGTH SCORE (RSI + EMA, 8 factors)
// ============================================================================
bullishScore = 0
bullishScore := bullishScore + (rsi_tf1 >= 50 ? 1 : 0)
bullishScore := bullishScore + (rsi_tf2 >= 50 ? 1 : 0)
bullishScore := bullishScore + (rsi_tf3 >= 50 ? 1 : 0)
bullishScore := bullishScore + (rsi_tf4 >= 50 ? 1 : 0)
bullishScore := bullishScore + (currentPrice > ema_tf1 ? 1 : 0)
bullishScore := bullishScore + (currentPrice > ema_tf2 ? 1 : 0)
bullishScore := bullishScore + (currentPrice > ema_tf3 ? 1 : 0)
bullishScore := bullishScore + (currentPrice > ema_tf4 ? 1 : 0)

trendStrength = bullishScore * 12.5

bgColor = bullishScore >= 6 ? color.new(color.green, 95) : bullishScore >= 4 ? color.new(color.yellow, 97) : color.new(color.red, 95)
bgcolor(bgColor, title="Trend Background")

// ============================================================================
// DASHBOARD  (4 cols x 12 rows)
// ============================================================================
var table dashboard = table.new(position.middle_right, 4, 12,
     bgcolor       = color.new(color.black, 10),
     frame_color   = color.new(color.white, 70), frame_width  = 2,
     border_width  = 1, border_color = color.new(color.white, 80))

if barstate.islast and showDashboard

    // ── Header ──────────────────────────────────────────────────────────────
    table.cell(dashboard, 0, 0, "TF",    bgcolor=color.new(color.blue, 20), text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 1, 0, "RSI",   bgcolor=color.new(color.blue, 20), text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 2, 0, "EMA",   bgcolor=color.new(color.blue, 20), text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 3, 0, "Trend", bgcolor=color.new(color.blue, 20), text_color=color.white, text_size=size.normal)

    // ── TF1 ─────────────────────────────────────────────────────────────────
    trend1 = rsi_tf1 >= 50 and currentPrice > ema_tf1 ? "BULL" : rsi_tf1 < 50 and currentPrice < ema_tf1 ? "BEAR" : "MIX"
    table.cell(dashboard, 0, 1, tf1, bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 1, 1, str.tostring(math.round(rsi_tf1, 1)), bgcolor=color.new(getRSIColor(rsi_tf1), 70), text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 2, 1, str.tostring(math.round(ema_tf1, 2)), bgcolor=color.new(getEMAColor(ema_tf1, currentPrice), 70), text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 3, 1, trend1, bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=size.normal)

    // ── TF2 ─────────────────────────────────────────────────────────────────
    trend2 = rsi_tf2 >= 50 and currentPrice > ema_tf2 ? "BULL" : rsi_tf2 < 50 and currentPrice < ema_tf2 ? "BEAR" : "MIX"
    table.cell(dashboard, 0, 2, tf2, bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 1, 2, str.tostring(math.round(rsi_tf2, 1)), bgcolor=color.new(getRSIColor(rsi_tf2), 70), text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 2, 2, str.tostring(math.round(ema_tf2, 2)), bgcolor=color.new(getEMAColor(ema_tf2, currentPrice), 70), text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 3, 2, trend2, bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=size.normal)

    // ── TF3 ─────────────────────────────────────────────────────────────────
    trend3 = rsi_tf3 >= 50 and currentPrice > ema_tf3 ? "BULL" : rsi_tf3 < 50 and currentPrice < ema_tf3 ? "BEAR" : "MIX"
    table.cell(dashboard, 0, 3, tf3, bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 1, 3, str.tostring(math.round(rsi_tf3, 1)), bgcolor=color.new(getRSIColor(rsi_tf3), 70), text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 2, 3, str.tostring(math.round(ema_tf3, 2)), bgcolor=color.new(getEMAColor(ema_tf3, currentPrice), 70), text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 3, 3, trend3, bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=size.normal)

    // ── TF4 ─────────────────────────────────────────────────────────────────
    trend4 = rsi_tf4 >= 50 and currentPrice > ema_tf4 ? "BULL" : rsi_tf4 < 50 and currentPrice < ema_tf4 ? "BEAR" : "MIX"
    table.cell(dashboard, 0, 4, tf4, bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 1, 4, str.tostring(math.round(rsi_tf4, 1)), bgcolor=color.new(getRSIColor(rsi_tf4), 70), text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 2, 4, str.tostring(math.round(ema_tf4, 2)), bgcolor=color.new(getEMAColor(ema_tf4, currentPrice), 70), text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 3, 4, trend4, bgcolor=color.new(color.gray, 50), text_color=color.white, text_size=size.normal)

    // ── Daily VWAP Row ───────────────────────────────────────────────────────
    dVwapStr = not na(vwapDaily)  ? str.tostring(math.round(vwapDaily,  2)) : "OFF"
    dVwapDir = not na(vwapDaily)  ? (currentPrice > vwapDaily  ? "Above" : "Below") : "---"
    dVwapBg  = not na(vwapDaily)  ? (currentPrice > vwapDaily  ? color.new(color.green, 55) : color.new(color.red, 55)) : color.new(color.gray, 55)
    table.cell(dashboard, 0, 5, "D VWAP",  bgcolor=color.new(#2962FF, 35), text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 1, 5, dVwapStr,  bgcolor=dVwapBg, text_color=color.white, text_size=size.normal)
    table.merge_cells(dashboard, 1, 5, 2, 5)
    table.cell(dashboard, 3, 5, dVwapDir,  bgcolor=dVwapBg, text_color=color.white, text_size=size.normal)

    // ── Weekly VWAP Row ──────────────────────────────────────────────────────
    wVwapStr = not na(vwapWeekly) ? str.tostring(math.round(vwapWeekly, 2)) : "OFF"
    wVwapDir = not na(vwapWeekly) ? (currentPrice > vwapWeekly ? "Above" : "Below") : "---"
    wVwapBg  = not na(vwapWeekly) ? (currentPrice > vwapWeekly ? color.new(color.green, 55) : color.new(color.red, 55)) : color.new(color.gray, 55)
    table.cell(dashboard, 0, 6, "W VWAP",  bgcolor=color.new(#FF6D00, 35), text_color=color.white, text_size=size.normal)
    table.cell(dashboard, 1, 6, wVwapStr,  bgcolor=wVwapBg, text_color=color.white, text_size=size.normal)
    table.merge_cells(dashboard, 1, 6, 2, 6)
    table.cell(dashboard, 3, 6, wVwapDir,  bgcolor=wVwapBg, text_color=color.white, text_size=size.normal)

    // ── Separator ────────────────────────────────────────────────────────────
    table.cell(dashboard, 0, 7, "", bgcolor=color.new(color.gray, 80), text_color=color.white, text_size=size.tiny)
    table.merge_cells(dashboard, 0, 7, 3, 7)

    // ── Trend Strength Header ────────────────────────────────────────────────
    table.cell(dashboard, 0, 8, "TREND STRENGTH", bgcolor=color.new(color.purple, 30), text_color=color.white, text_size=size.normal)
    table.merge_cells(dashboard, 0, 8, 3, 8)

    // ── Trend Strength Value ─────────────────────────────────────────────────
    strengthColor = trendStrength >= 75 ? color.new(color.green, 40) : trendStrength >= 50 ? color.new(color.yellow, 40) : color.new(color.red, 40)
    table.cell(dashboard, 0, 9, str.tostring(math.round(trendStrength, 0)) + "%", bgcolor=strengthColor, text_color=color.white, text_size=size.large)
    table.merge_cells(dashboard, 0, 9, 3, 9)

    // ── Overall Direction ────────────────────────────────────────────────────
    overallDir   = bullishScore >= 6 ? "STRONG BULLISH" : bullishScore >= 4 ? "NEUTRAL" : "STRONG BEARISH"
    overallColor = bullishScore >= 6 ? color.new(color.green, 50) : bullishScore >= 4 ? color.new(color.yellow, 50) : color.new(color.red, 50)
    table.cell(dashboard, 0, 10, overallDir, bgcolor=overallColor, text_color=color.white, text_size=size.large)
    table.merge_cells(dashboard, 0, 10, 3, 10)

    // ── Current Price ────────────────────────────────────────────────────────
    table.cell(dashboard, 0, 11, "Price: " + str.tostring(math.round(currentPrice, 2)), bgcolor=color.new(color.blue, 30), text_color=color.white, text_size=size.normal)
    table.merge_cells(dashboard, 0, 11, 3, 11)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(bullishScore >= 6,                        title="Strong Bullish",            message="Strong Bullish Alignment Detected!")
alertcondition(bullishScore <= 2,                        title="Strong Bearish",            message="Strong Bearish Alignment Detected!")
alertcondition(ta.crossover( rsi_tf4, rsiOverbought),   title="Daily RSI Overbought",      message="Daily RSI entered Overbought zone!")
alertcondition(ta.crossunder(rsi_tf4, rsiOversold),     title="Daily RSI Oversold",        message="Daily RSI entered Oversold zone!")
alertcondition(ta.crossover( close,   vwapDaily),       title="Price Above Daily VWAP",    message="Price crossed ABOVE Daily VWAP!")
alertcondition(ta.crossunder(close,   vwapDaily),       title="Price Below Daily VWAP",    message="Price crossed BELOW Daily VWAP!")
alertcondition(ta.crossover( close,   vwapWeekly),      title="Price Above Weekly VWAP",   message="Price crossed ABOVE Weekly VWAP!")
alertcondition(ta.crossunder(close,   vwapWeekly),      title="Price Below Weekly VWAP",   message="Price crossed BELOW Weekly VWAP!")
````
