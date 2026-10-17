# Combined RSI + ADX/DI + Stochastic + EMA Stack

- url: https://www.tradingview.com/script/2zXCGs4t-Combined-RSI-ADX-DI-Stochastic-EMA-Stack/
- type: indicator
- pine_id: PUB;49e9afe85e024848801badc4e3fa9603
- version: 1.0

## Description

[b]Short Description[/b]
A compact market structure indicator that combines EMA stack alignment, ADX/DI trend strength, RSI vs RSI SMA, Stochastic positioning, and an optional trend filter to present bull, bear, neutral, and no-trade conditions in a clear visual format.
[b]
Long Description[/b]
Combined RSI + ADX/DI + Stochastic + EMA Stack is a compact market-structure indicator designed to help traders evaluate directional alignment, trend strength, and momentum conditions in one place.
The indicator combines:
[list]
[*]EMA stack alignment
[*]ADX trend strength
[*]DI directional confirmation
[*]RSI relative to its SMA
[*]Stochastic position above or below the midline
[*]Optional trend filter using EMA 100 or EMA 200
[/list]

[b]How it works[/b]
The main structural check is the selected EMA stack. The user can choose how strict that stack should be, from a simple 9 > 21 relationship to a broader multi-EMA sequence.

A bullish state requires:
the selected EMA stack to be aligned bullish
ADX above the no-trade threshold
+DI above the DI threshold
RSI above its SMA
Stochastic above 50
price above the selected trend filter when the filter is enabled

A bearish state requires:
the selected EMA stack to be aligned bearish
ADX above the no-trade threshold
-DI above the DI threshold
RSI below its SMA
Stochastic below 50
price below the selected trend filter when the filter is enabled

A no-trade state appears when ADX is below the defined threshold. This helps filter out weaker market conditions where trend strength may not be sufficient.

[b]How to read the panel[/b]

The compact panel is designed to make the current condition easy to understand at a glance.
[list]
[*]Green indicates bullish alignment
[*]Red indicates bearish alignment
[*]Amber indicates a no-trade condition because ADX is below threshold
[*]Neutral coloring indicates partial alignment, but not enough confirmation for a full bullish or bearish state
[/list]

Each row shows the current value and whether that condition is currently supporting the active side.

[b]Exit consideration[/b]

The script also includes stochastic-based exit context.

For long trades:
monitor when %K crosses below %D from an overbought area, typically above 80
this can indicate that bullish momentum is weakening

For short trades:
monitor when %K crosses above %D from an oversold area, typically below 20
this can indicate that bearish momentum is weakening
Suggested use

This indicator is best used as a trend-alignment and market-structure tool rather than as a standalone trading system. It can help traders:
[list]
[*]identify whether bullish or bearish conditions are structurally aligned
[*]avoid weaker market environments through the ADX no-trade filter
[*]confirm direction with DI, RSI, and Stochastic
[*]apply a broader directional bias using EMA 100 or EMA 200
[*]monitor stochastic crossover conditions as possible exit considerations
[/list]

Default settings are intended to provide a balanced starting point, while still allowing users to make the EMA stack and trend filter stricter or more flexible.

[b]Notes[/b]

This indicator is intended for chart analysis and educational use. It should be used alongside broader market context, risk management, and personal trade planning.
Preferred time frame D or W chart for stocks.

[b]Attribution[/b]

This script includes logic derived in part from “ADX Di+ Di- [Gu5]” by gu5tavo71.
Original source:
https://www.safecreative.org/work/2302153511401-adx-di-di-gu5-
© gu5tavo71 (Gustavo Cardelle)
License notice provided by the original author:
Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)
https://creativecommons.org/licenses/by-nc-sa/4.0/

Summary of the author’s stated terms:
Share, copy and redistribute this script
Adapt, transform and build on this script
NonCommercial: You may not use the material for commercial purposes
Release Notes

Initial Release — Sam George
Combined RSI + ADX/DI + Stochastic + EMA Stack was created to make multi-factor trend alignment easier to read in a clear, compact format.

This first release includes:
[list]
[*]Configurable EMA stack alignment for flexible trend structure analysis
[*]ADX no-trade filter to help avoid weaker trend conditions
[*]DI threshold confirmation for directional strength
[*]RSI vs RSI SMA for momentum bias
[*]Stochastic midline confirmation for additional trend alignment
[*]Optional Trend Filter using EMA 100 or EMA 200
[*]Compact state panel showing bull, bear, neutral, and no-trade conditions
[*]Stochastic-based exit context for long and short trade management
[*]Improved visual structure for faster decision support and easier interpretation
[/list]

This version is intended to provide a structured view of market condition, trend quality, and alignment across multiple components in one place.

## Source Code

````pine
// © Sam George
// Combined RSI+ADX/DI+STOCHASTIC+EMA Stack
//
// This script includes logic derived in part from:
// "ADX Di+ Di- [Gu5]" by gu5tavo71
// © gu5tavo71 (Gustavo Cardelle)
//
// Original source:
// https://www.safecreative.org/work/2302153511401-adx-di-di-gu5-
//
// License notice provided by the original author:
// Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)
// https://creativecommons.org/licenses/by-nc-sa/4.0/
//
// You are free to share, copy, redistribute, adapt, transform,
// and build on this script for non-commercial purposes.
//
// This version adds EMA stack alignment, RSI/SMA logic, stochastic context,
// trend filtering, compact state-panel presentation, and exit considerations.
//@version=5
indicator("Combined RSI + ADX/DI + Stochastic + EMA Stack", overlay=false)

//==============================================================================
// INPUTS
//==============================================================================

// 1. Show / Hide Components
showRsiSection = input.bool(true, "Show RSI", group="1. Show / Hide Components")
showAdxSection = input.bool(true, "Show ADX / DI", group="1. Show / Hide Components")
showStochSection = input.bool(true, "Show Stochastic", group="1. Show / Hide Components")

// 2. RSI Settings
rsiLength = input.int(14, "RSI Length", minval=1, maxval=100, group="2. RSI Settings")
rsiSmaLength = input.int(20, "RSI SMA Length", minval=1, maxval=200, group="2. RSI Settings")
rsiLevel70 = input.float(70.0, "RSI Upper Extreme", minval=0, maxval=100, group="2. RSI Settings")
rsiLevel55 = input.float(55.0, "RSI Bullish Regime", minval=0, maxval=100, group="2. RSI Settings")
rsiLevel50 = input.float(50.0, "RSI Midline", minval=0, maxval=100, group="2. RSI Settings")
rsiLevel45 = input.float(45.0, "RSI Bearish Regime", minval=0, maxval=100, group="2. RSI Settings")
rsiLevel30 = input.float(30.0, "RSI Lower Extreme", minval=0, maxval=100, group="2. RSI Settings")
showRsiFill = input.bool(true, "Show RSI Fill", group="2. RSI Settings")
showRsiGuides = input.bool(true, "Show RSI Horizontal Lines", group="2. RSI Settings")

// 3. ADX / DI Settings
adxSmoothing = input.int(14, "ADX Smoothing", minval=1, group="3. ADX / DI Settings")
diLength = input.int(14, "DI Length", minval=1, group="3. ADX / DI Settings")
adxNoTradeThreshold = input.float(12.0, "ADX No Trade Threshold", minval=0, maxval=100, group="3. ADX / DI Settings")
diTrendThreshold = input.float(25.0, "DI Trend Threshold", minval=0, maxval=100, group="3. ADX / DI Settings")
adxLevel20 = input.float(20.0, "ADX Early Trend", minval=0, maxval=100, group="3. ADX / DI Settings")
adxLevel25 = input.float(25.0, "ADX Confirmed Trend", minval=0, maxval=100, group="3. ADX / DI Settings")
adxLevel35 = input.float(35.0, "ADX Strong Trend", minval=0, maxval=100, group="3. ADX / DI Settings")
showDiFill = input.bool(true, "Show DI Fill", group="3. ADX / DI Settings")
showAdxGuides = input.bool(true, "Show ADX Horizontal Lines", group="3. ADX / DI Settings")

// 4. Stochastic Settings
stochKLength = input.int(14, "Stochastic %K Length", minval=1, group="4. Stochastic Settings")
stochDLength = input.int(3, "Stochastic %D Length", minval=1, group="4. Stochastic Settings")
stochSmooth = input.int(3, "Stochastic Smoothing", minval=1, group="4. Stochastic Settings")
stochLevel80 = input.float(80.0, "Stochastic Overbought", minval=0, maxval=100, group="4. Stochastic Settings")
stochLevel50 = input.float(50.0, "Stochastic Midline", minval=0, maxval=100, group="4. Stochastic Settings")
stochLevel20 = input.float(20.0, "Stochastic Oversold", minval=0, maxval=100, group="4. Stochastic Settings")
showStochFill = input.bool(true, "Show Stochastic Fill", group="4. Stochastic Settings")
showStochGuides = input.bool(true, "Show Stochastic Horizontal Lines", group="4. Stochastic Settings")

// 5. Zone Logic Settings
trendFilterMode = input.string("EMA 200", "Trend Filter", options=["Off", "EMA 100", "EMA 200"], group="5. Zone Logic Settings")

// 6. Visual Settings
minimalMode = input.bool(true, "Minimal Mode", group="6. Visual Settings")
showSectionLabels = input.bool(false, "Show Section Labels", group="6. Visual Settings")
showDebugLabel = input.bool(false, "Show Debug Label", group="6. Visual Settings")
showStatePanel = input.bool(true, "Show Compact State Panel", group="6. Visual Settings")

// 7. EMA Background
ema1Length = input.int(9, "EMA 1 (Fastest)", minval=1, group="7. EMA Background")
ema2Length = input.int(21, "EMA 2", minval=1, group="7. EMA Background")
ema3Length = input.int(30, "EMA 3", minval=1, group="7. EMA Background")
ema4Length = input.int(55, "EMA 4", minval=1, group="7. EMA Background")
ema5Length = input.int(100, "EMA 5", minval=1, group="7. EMA Background")
ema6Length = input.int(200, "EMA 6 (Slowest)", minval=1, group="7. EMA Background")
emaStackMode = input.string("9 > 21", "EMA Stack Rule", options=["9 > 21", "9 > 21 > 30", "9 > 21 > 30 > 55", "9 > 21 > 30 > 55 > 100", "9 > 21 > 30 > 55 > 100 > 200"], group="7. EMA Background")
showEmaStackBackground = input.bool(true, "Show EMA Stack Background", group="7. EMA Background")
showEmaNeutralBackground = input.bool(true, "Show EMA Neutral Background", group="7. EMA Background")
emaBullBgTransparency = input.int(97, "Bull Background Transparency", minval=0, maxval=100, group="7. EMA Background")
emaBearBgTransparency = input.int(97, "Bear Background Transparency", minval=0, maxval=100, group="7. EMA Background")
emaNeutralBgTransparency = input.int(98, "Neutral Background Transparency", minval=0, maxval=100, group="7. EMA Background")

//==============================================================================
// COLORS
//==============================================================================
RSI_BLUE = color.rgb(25, 105, 255)
RSI_ORANGE = color.rgb(255, 160, 20)

ADX_GREEN = #006400
ADX_GREENLIGHT = #388e3c
ADX_RED = #8B0000
ADX_REDLIGHT = #b71c1c
ADX_NOTRADE = color.rgb(255, 140, 0)

STOCH_BLUE = color.rgb(120, 170, 255)
STOCH_ORANGE = color.rgb(255, 195, 120)

PANEL_TEXT_GREEN = color.rgb(40, 255, 140)
PANEL_TEXT_RED = color.rgb(255, 110, 110)
PANEL_TEXT_ORANGE = color.rgb(255, 190, 70)
PANEL_TEXT_NEUTRAL = color.rgb(232, 235, 240)
PANEL_TEXT_DIM = color.rgb(175, 180, 190)
PANEL_TEXT_WHITE = color.white

PANEL_BG_GREEN = color.rgb(22, 48, 34)
PANEL_BG_RED = color.rgb(56, 26, 26)
PANEL_BG_ORANGE = color.rgb(64, 44, 18)
PANEL_BG_NEUTRAL = color.rgb(42, 44, 50)
PANEL_BG_HEADER = color.rgb(96, 100, 108)
PANEL_BG_LABEL = color.rgb(74, 78, 86)

//==============================================================================
// FUNCTIONS
//==============================================================================
f_dir_mov(_len) =>
    _up = ta.change(high)
    _down = -ta.change(low)
    _plusDM = na(_up) ? na : (_up > _down and _up > 0 ? _up : 0)
    _minusDM = na(_down) ? na : (_down > _up and _down > 0 ? _down : 0)
    _trueRange = ta.rma(ta.tr, _len)
    _plus = fixnan(100 * ta.rma(_plusDM, _len) / _trueRange)
    _minus = fixnan(100 * ta.rma(_minusDM, _len) / _trueRange)
    [_plus, _minus]

f_adx(_diLen, _sigLen) =>
    [_plus, _minus] = f_dir_mov(_diLen)
    _sum = _plus + _minus
    _adx = 100 * ta.rma(math.abs(_plus - _minus) / (_sum == 0 ? 1 : _sum), _sigLen)
    [_adx, _plus, _minus]

f_ema_stack_bull(_mode, _ema1, _ema2, _ema3, _ema4, _ema5, _ema6) =>
    switch _mode
        "9 > 21" => _ema1 > _ema2
        "9 > 21 > 30" => _ema1 > _ema2 and _ema2 > _ema3
        "9 > 21 > 30 > 55" => _ema1 > _ema2 and _ema2 > _ema3 and _ema3 > _ema4
        "9 > 21 > 30 > 55 > 100" => _ema1 > _ema2 and _ema2 > _ema3 and _ema3 > _ema4 and _ema4 > _ema5
        => _ema1 > _ema2 and _ema2 > _ema3 and _ema3 > _ema4 and _ema4 > _ema5 and _ema5 > _ema6

f_ema_stack_bear(_mode, _ema1, _ema2, _ema3, _ema4, _ema5, _ema6) =>
    switch _mode
        "9 > 21" => _ema1 < _ema2
        "9 > 21 > 30" => _ema1 < _ema2 and _ema2 < _ema3
        "9 > 21 > 30 > 55" => _ema1 < _ema2 and _ema2 < _ema3 and _ema3 < _ema4
        "9 > 21 > 30 > 55 > 100" => _ema1 < _ema2 and _ema2 < _ema3 and _ema3 < _ema4 and _ema4 < _ema5
        => _ema1 < _ema2 and _ema2 < _ema3 and _ema3 < _ema4 and _ema4 < _ema5 and _ema5 < _ema6

f_ema_stack_text(_mode, _ema1Len, _ema2Len, _ema3Len, _ema4Len, _ema5Len, _ema6Len) =>
    switch _mode
        "9 > 21" => str.tostring(_ema1Len) + " > " + str.tostring(_ema2Len)
        "9 > 21 > 30" => str.tostring(_ema1Len) + " > " + str.tostring(_ema2Len) + " > " + str.tostring(_ema3Len)
        "9 > 21 > 30 > 55" => str.tostring(_ema1Len) + " > " + str.tostring(_ema2Len) + " > " + str.tostring(_ema3Len) + " > " + str.tostring(_ema4Len)
        "9 > 21 > 30 > 55 > 100" => str.tostring(_ema1Len) + " > " + str.tostring(_ema2Len) + " > " + str.tostring(_ema3Len) + " > " + str.tostring(_ema4Len) + " > " + str.tostring(_ema5Len)
        => str.tostring(_ema1Len) + " > " + str.tostring(_ema2Len) + " > " + str.tostring(_ema3Len) + " > " + str.tostring(_ema4Len) + " > " + str.tostring(_ema5Len) + " > " + str.tostring(_ema6Len)

//==============================================================================
// CALCULATIONS
//==============================================================================
rsiValue = ta.rsi(close, rsiLength)
rsiSma = ta.sma(rsiValue, rsiSmaLength)

[adxValue, diPlus, diMinus] = f_adx(diLength, adxSmoothing)
adxRising = adxValue > adxValue[1]
adxNoTrade = adxValue < adxNoTradeThreshold
adxTrendOk = adxValue > adxNoTradeThreshold

stochK = ta.sma(ta.stoch(close, high, low, stochKLength), stochSmooth)
stochD = ta.sma(stochK, stochDLength)

stochBearExitLong = ta.crossunder(stochK, stochD) and math.max(stochK, stochD) >= stochLevel80
stochBullExitShort = ta.crossover(stochK, stochD) and math.min(stochK, stochD) <= stochLevel20

ema1 = ta.ema(close, ema1Length)
ema2 = ta.ema(close, ema2Length)
ema3 = ta.ema(close, ema3Length)
ema4 = ta.ema(close, ema4Length)
ema5 = ta.ema(close, ema5Length)
ema6 = ta.ema(close, ema6Length)

trendFilterEma = trendFilterMode == "EMA 100" ? ema5 : trendFilterMode == "EMA 200" ? ema6 : na
trendFilterLabel = trendFilterMode == "Off" ? "Off" : trendFilterMode

emaBullStack = f_ema_stack_bull(emaStackMode, ema1, ema2, ema3, ema4, ema5, ema6)
emaBearStack = f_ema_stack_bear(emaStackMode, ema1, ema2, ema3, ema4, ema5, ema6)
emaStackText = f_ema_stack_text(emaStackMode, ema1Length, ema2Length, ema3Length, ema4Length, ema5Length, ema6Length)

rsiBullAlign = rsiValue > rsiSma
rsiBearAlign = rsiValue < rsiSma
stochBullAlign = stochK > stochLevel50
stochBearAlign = stochK < stochLevel50
diBullAlign = diPlus > diTrendThreshold
diBearAlign = diMinus > diTrendThreshold

priceBullFilter = trendFilterMode == "Off" ? true : close > trendFilterEma
priceBearFilter = trendFilterMode == "Off" ? true : close < trendFilterEma

bullZone = adxTrendOk and diBullAlign and rsiBullAlign and emaBullStack and stochBullAlign and priceBullFilter
bearZone = adxTrendOk and diBearAlign and rsiBearAlign and emaBearStack and stochBearAlign and priceBearFilter

stateText = adxNoTrade ? "NO TRADE" : bullZone ? "BULL" : bearZone ? "BEAR" : "NEUTRAL"
stateTextColor = adxNoTrade ? PANEL_TEXT_ORANGE : bullZone ? PANEL_TEXT_GREEN : bearZone ? PANEL_TEXT_RED : PANEL_TEXT_NEUTRAL
panelBodyBg = adxNoTrade ? PANEL_BG_ORANGE : bullZone ? PANEL_BG_GREEN : bearZone ? PANEL_BG_RED : PANEL_BG_NEUTRAL

emaRowText = emaStackText + " " + (emaBullStack or emaBearStack ? "✓" : "•")
emaRowColor = emaBullStack ? PANEL_TEXT_GREEN : emaBearStack ? PANEL_TEXT_RED : PANEL_TEXT_DIM

adxRowText = str.tostring(adxValue, "#.#") + " / " + str.tostring(adxNoTradeThreshold, "#.#") + " " + (adxTrendOk ? "✓" : "✗")
adxRowColor = adxTrendOk ? PANEL_TEXT_GREEN : PANEL_TEXT_ORANGE

diPlusRowText = str.tostring(diPlus, "#.#") + " / " + str.tostring(diTrendThreshold, "#.#") + " " + (diBullAlign ? "✓" : "✗")
diPlusRowColor = diBullAlign ? PANEL_TEXT_GREEN : PANEL_TEXT_DIM

diMinusRowText = str.tostring(diMinus, "#.#") + " / " + str.tostring(diTrendThreshold, "#.#") + " " + (diBearAlign ? "✓" : "✗")
diMinusRowColor = diBearAlign ? PANEL_TEXT_RED : PANEL_TEXT_DIM

rsiRowText = str.tostring(rsiValue, "#.#") + " vs " + str.tostring(rsiSma, "#.#") + " " + (rsiBullAlign ? "✓" : rsiBearAlign ? "✓" : "•")
rsiRowColor = rsiBullAlign ? PANEL_TEXT_GREEN : rsiBearAlign ? PANEL_TEXT_RED : PANEL_TEXT_DIM

stochRowText = str.tostring(stochK, "#.#") + " / " + str.tostring(stochLevel50, "#.#") + " " + (stochBullAlign ? "✓" : stochBearAlign ? "✓" : "•")
stochRowColor = stochBullAlign ? PANEL_TEXT_GREEN : stochBearAlign ? PANEL_TEXT_RED : PANEL_TEXT_DIM

trendRowText = trendFilterMode == "Off" ? "Off •" : trendFilterLabel + " " + str.tostring(trendFilterEma, "#.#") + " " + (priceBullFilter ? "✓" : priceBearFilter ? "✓" : "•")
trendRowColor = trendFilterMode == "Off" ? PANEL_TEXT_DIM : priceBullFilter ? PANEL_TEXT_GREEN : priceBearFilter ? PANEL_TEXT_RED : PANEL_TEXT_DIM

exitLongText = stochBearExitLong ? "Long Exit ✓" : "Long Exit •"
exitLongColor = stochBearExitLong ? PANEL_TEXT_ORANGE : PANEL_TEXT_DIM

exitShortText = stochBullExitShort ? "Short Exit ✓" : "Short Exit •"
exitShortColor = stochBullExitShort ? PANEL_TEXT_ORANGE : PANEL_TEXT_DIM

//==============================================================================
// BACKGROUND
//==============================================================================
color emaStackBgColor = na
if showEmaStackBackground
    if emaBullStack
        emaStackBgColor := color.new(color.lime, emaBullBgTransparency)
    else if emaBearStack
        emaStackBgColor := color.new(color.red, emaBearBgTransparency)
    else if showEmaNeutralBackground
        emaStackBgColor := color.new(color.gray, emaNeutralBgTransparency)

bgcolor(emaStackBgColor, title="EMA Stack Background")

//==============================================================================
// HORIZONTAL LINES
//==============================================================================
hline(rsiLevel70, "RSI 70", color=color.new(color.gray, 15), linestyle=hline.style_dotted, display=showRsiSection and showRsiGuides ? display.all : display.none)
hline(rsiLevel55, "RSI 55", color=color.new(color.purple, 0), linestyle=hline.style_dashed, display=showRsiSection and showRsiGuides ? display.all : display.none)
hline(rsiLevel50, "RSI 50", color=color.new(color.gray, 35), linestyle=hline.style_dotted, display=showRsiSection and showRsiGuides ? display.all : display.none)
hline(rsiLevel45, "RSI 45", color=color.new(color.purple, 0), linestyle=hline.style_dashed, display=showRsiSection and showRsiGuides ? display.all : display.none)
hline(rsiLevel30, "RSI 30", color=color.new(color.gray, 15), linestyle=hline.style_dotted, display=showRsiSection and showRsiGuides ? display.all : display.none)

hline(adxLevel20, "ADX 20", color=color.new(color.orange, 0), linestyle=hline.style_dotted, display=showAdxSection and showAdxGuides ? display.all : display.none)
hline(adxLevel25, "ADX 25", color=color.new(color.silver, 0), linestyle=hline.style_dashed, display=showAdxSection and showAdxGuides ? display.all : display.none)
hline(adxLevel35, "ADX 35", color=color.new(color.orange, 20), linestyle=hline.style_dotted, display=showAdxSection and showAdxGuides ? display.all : display.none)

hline(stochLevel80, "Stoch 80", color=color.new(color.red, 10), linestyle=hline.style_dotted, display=showStochSection and showStochGuides ? display.all : display.none)
hline(stochLevel50, "Stoch 50", color=color.new(color.gray, 50), linestyle=hline.style_dashed, display=showStochSection and showStochGuides ? display.all : display.none)
hline(stochLevel20, "Stoch 20", color=color.new(color.green, 10), linestyle=hline.style_dotted, display=showStochSection and showStochGuides ? display.all : display.none)

//==============================================================================
// MAIN PLOTS
//==============================================================================
rsiLineWidth = minimalMode ? 2 : 3
rsiSmaLineWidth = minimalMode ? 1 : 2
adxLineWidth = minimalMode ? 2 : 3
diLineWidth = minimalMode ? 1 : 2
stochLineWidth = minimalMode ? 1 : 2

rsiPlot = plot(showRsiSection ? rsiValue : na, title="RSI", color=RSI_BLUE, linewidth=rsiLineWidth, display=display.pane)
rsiSmaPlot = plot(showRsiSection ? rsiSma : na, title="RSI SMA", color=RSI_ORANGE, linewidth=rsiSmaLineWidth, display=display.pane)

color rsiFillColor = na
if showRsiSection and showRsiFill
    if rsiValue > rsiSma
        rsiFillColor := minimalMode ? color.new(color.green, 91) : color.new(color.green, 84)
    else
        rsiFillColor := minimalMode ? color.new(color.red, 91) : color.new(color.red, 84)
fill(rsiPlot, rsiSmaPlot, color=rsiFillColor, title="RSI Fill")

adxColor = color.gray
if adxNoTrade
    adxColor := ADX_NOTRADE
else if adxRising and diPlus > diMinus
    adxColor := color.new(ADX_GREEN, 0)
else if not adxRising and diPlus > diMinus
    adxColor := color.new(ADX_GREENLIGHT, 0)
else if adxRising and diMinus > diPlus
    adxColor := color.new(ADX_RED, 0)
else if not adxRising and diMinus > diPlus
    adxColor := color.new(ADX_REDLIGHT, 0)

plot(showAdxSection ? adxValue : na, title="ADX", color=adxColor, linewidth=adxLineWidth, display=display.pane)
diPlusPlot = plot(showAdxSection ? diPlus : na, title="+DI", color=ADX_GREEN, linewidth=diLineWidth, display=display.pane)
diMinusPlot = plot(showAdxSection ? diMinus : na, title="-DI", color=ADX_RED, linewidth=diLineWidth, display=display.pane)

color diFillColor = na
if showAdxSection and showDiFill
    if diPlus > diMinus
        diFillColor := minimalMode ? color.new(ADX_GREEN, 94) : color.new(ADX_GREEN, 89)
    else
        diFillColor := minimalMode ? color.new(ADX_RED, 94) : color.new(ADX_RED, 89)
fill(diPlusPlot, diMinusPlot, color=diFillColor, title="DI Fill")

stochKPlot = plot(showStochSection ? stochK : na, title="Stochastic %K", color=STOCH_BLUE, linewidth=stochLineWidth, display=display.pane)
stochDPlot = plot(showStochSection ? stochD : na, title="Stochastic %D", color=STOCH_ORANGE, linewidth=stochLineWidth, display=display.pane)

color stochFillColor = na
if showStochSection and showStochFill
    if stochK > stochD
        stochFillColor := minimalMode ? color.rgb(8, 112, 102, 55) : color.rgb(0, 137, 123, 49)
    else
        stochFillColor := minimalMode ? color.rgb(131, 4, 72, 52) : color.new(#630437, 44)
fill(stochKPlot, stochDPlot, color=stochFillColor, title="Stochastic Fill")

//==============================================================================
// SECTION LABELS
//==============================================================================
var label sectionLabelRsi = na
var label sectionLabelAdx = na
var label sectionLabelStoch = na
var label debugInfoLabel = na

if barstate.islast
    if not na(sectionLabelRsi)
        label.delete(sectionLabelRsi)
    if not na(sectionLabelAdx)
        label.delete(sectionLabelAdx)
    if not na(sectionLabelStoch)
        label.delete(sectionLabelStoch)
    if not na(debugInfoLabel)
        label.delete(debugInfoLabel)

    if showSectionLabels and showRsiSection
        sectionLabelRsi := label.new(bar_index, 88, "RSI", style=label.style_label_left, textcolor=color.white, color=color.new(RSI_BLUE, 75))
    if showSectionLabels and showAdxSection
        sectionLabelAdx := label.new(bar_index, 50, "ADX / DI", style=label.style_label_left, textcolor=color.white, color=color.new(color.gray, 75))
    if showSectionLabels and showStochSection
        sectionLabelStoch := label.new(bar_index, 12, "STOCH", style=label.style_label_left, textcolor=color.white, color=color.new(STOCH_ORANGE, 75))

    if showDebugLabel
        debugInfoLabel := label.new(
             bar_index,
             56,
             "Bull Zone " + str.tostring(bullZone ? 1 : 0) +
             " | Bear Zone " + str.tostring(bearZone ? 1 : 0) +
             "\nLong Exit " + str.tostring(stochBearExitLong ? 1 : 0) +
             " | Short Exit " + str.tostring(stochBullExitShort ? 1 : 0),
             style=label.style_label_left,
             textcolor=color.white,
             color=color.new(color.black, 65)
         )

//==============================================================================
// SMALL PANEL
//==============================================================================
var table statePanel = table.new(position.bottom_right, 2, 10, border_width=1)

if barstate.islast and showStatePanel
    table.clear(statePanel, 0, 0, 1, 9)

    table.cell(statePanel, 0, 0, "STATE", text_color=PANEL_TEXT_WHITE, bgcolor=PANEL_BG_LABEL, text_size=size.small)
    table.cell(statePanel, 1, 0, stateText, text_color=stateTextColor, bgcolor=PANEL_BG_HEADER, text_size=size.small)

    table.cell(statePanel, 0, 1, "EMA Stack", text_color=PANEL_TEXT_WHITE, bgcolor=PANEL_BG_LABEL, text_size=size.small)
    table.cell(statePanel, 1, 1, emaRowText, text_color=emaRowColor, bgcolor=panelBodyBg, text_size=size.small)

    table.cell(statePanel, 0, 2, "ADX", text_color=PANEL_TEXT_WHITE, bgcolor=PANEL_BG_LABEL, text_size=size.small)
    table.cell(statePanel, 1, 2, adxRowText, text_color=adxRowColor, bgcolor=panelBodyBg, text_size=size.small)

    table.cell(statePanel, 0, 3, "+DI", text_color=PANEL_TEXT_WHITE, bgcolor=PANEL_BG_LABEL, text_size=size.small)
    table.cell(statePanel, 1, 3, diPlusRowText, text_color=diPlusRowColor, bgcolor=panelBodyBg, text_size=size.small)

    table.cell(statePanel, 0, 4, "-DI", text_color=PANEL_TEXT_WHITE, bgcolor=PANEL_BG_LABEL, text_size=size.small)
    table.cell(statePanel, 1, 4, diMinusRowText, text_color=diMinusRowColor, bgcolor=panelBodyBg, text_size=size.small)

    table.cell(statePanel, 0, 5, "RSI vs SMA", text_color=PANEL_TEXT_WHITE, bgcolor=PANEL_BG_LABEL, text_size=size.small)
    table.cell(statePanel, 1, 5, rsiRowText, text_color=rsiRowColor, bgcolor=panelBodyBg, text_size=size.small)

    table.cell(statePanel, 0, 6, "Stoch", text_color=PANEL_TEXT_WHITE, bgcolor=PANEL_BG_LABEL, text_size=size.small)
    table.cell(statePanel, 1, 6, stochRowText, text_color=stochRowColor, bgcolor=panelBodyBg, text_size=size.small)

    table.cell(statePanel, 0, 7, "Trend Filter", text_color=PANEL_TEXT_WHITE, bgcolor=PANEL_BG_LABEL, text_size=size.small)
    table.cell(statePanel, 1, 7, trendRowText, text_color=trendRowColor, bgcolor=panelBodyBg, text_size=size.small)

    table.cell(statePanel, 0, 8, "Long Exit", text_color=PANEL_TEXT_WHITE, bgcolor=PANEL_BG_LABEL, text_size=size.small)
    table.cell(statePanel, 1, 8, exitLongText, text_color=exitLongColor, bgcolor=panelBodyBg, text_size=size.small)

    table.cell(statePanel, 0, 9, "Short Exit", text_color=PANEL_TEXT_WHITE, bgcolor=PANEL_BG_LABEL, text_size=size.small)
    table.cell(statePanel, 1, 9, exitShortText, text_color=exitShortColor, bgcolor=panelBodyBg, text_size=size.small)

if barstate.islast and not showStatePanel
    table.clear(statePanel, 0, 0, 1, 9)
````
