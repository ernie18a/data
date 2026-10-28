# Guppy MMA Mean Reversion Signals

- url: https://www.tradingview.com/script/HkERwTLg-Guppy-MMA-Mean-Reversion-Signals/
- type: indicator
- pine_id: PUB;b445a35a712f4297887a545fed5341af
- version: 1.0

## Description

The [b]Guppy MMA Mean Reversion System[/b] is a trend-following mean reversion tool designed to identify high-probability pullbacks within established trends. By combining the classic Guppy Multiple Moving Average (GMMA) with volatility, volume, and momentum filters, this script aims to reduce the "noise" often found in standard moving average cross strategies.

[b]The Concept: Why this  Works[/b]

Standard GMMA indicators are excellent for visualizing trend strength but often lack precise entry triggers or filters to avoid entering during periods of low volume or extreme exhaustion. This script addresses these limitations by integrating four distinct analytical components:

[b]- GMMA Ribbons (Trend & Reversion Zones)[/b]: We use two groups of EMAs (Short-term and Long-term). The Long-term group defines the "institutional" trend. Our entry logic looks for price to revert from the short-term trend back into the long-term trend zone—a classic sign of a healthy pullback.

[b]- CVD Confluence (Volume Confirmation)[/b]: Using Cumulative Volume Delta (CVD) based on candle-body delta approximations, the script ensures that volume flow supports the entry direction. This prevents entering pullbacks that lack the necessary buying/selling pressure to resume the trend.

[b]- ATR Volatility Filter (Statistical Spacing)[/b]: To avoid "choppy" entries, this filter requires the price to be at a statistically significant distance from the EMA based on market volatility (ATR). This ensures you are entering at a true "discount" rather than in a sideways market.

[b]- RSI Exhaustion Filter (Momentum Safety)[/b]: We utilize RSI to ensure that a reversion hasn't reached an overextended state. For example, it prevents buying a pullback if the RSI indicates the asset is already in an overbought exhaustion phase.

[b]How to Use[/b]

[b]- Long Entries (Green Circles)[/b]: Triggers when the Long-term ribbon is bullish, and price pulls back to touch the Long-term EMA group, provided the CVD, ATR, and RSI conditions are met.

[b]- Short Entries (Red Circles)[/b]: Triggers when the Long-term ribbon is bearish, and price rallies to touch the Long-term EMA group, filtered by volume and momentum.

[b]- Exits (Labels)[/b]: Exit signals appear when price successfully reverts back to the "fast" Short-term group, marking the completion of the mean reversion move.

[b]Key Features & Customization[/b]

[b]- Independent Toggles[/b]: You can independently turn on/off buy signals, sell signals, and their respective exits to suit your specific trading style (e.g., only trading the long side).

[b]- Signal Cooldown[/b]: Includes a customizable "bar count" cooldown to prevent multiple overlapping signals during high-volatility periods.

[b]- Comprehensive Settings[/b]: Fully adjustable EMA lengths, ATR multipliers, and RSI thresholds to adapt the system to different timeframes and asset classes (Crypto, Forex, Stocks).

Settings Guide
[b]- Use ATR Filter[/b]: Increase the multiplier for more conservative, wider entries.

[b]- Use CVD Filter[/b]: Enable to ensure volume delta is trending with your entry.

[b]- Use RSI Filter[/b]: Helps avoid "catching falling knives" by filtering out trades during extreme momentum spikes.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tradedailywithseb


//@version=6
indicator("Guppy MMA Mean Reversion Signals", shorttitle="GMMA Signals", overlay=true)

// --- Groups and Constants ---
GRP_SHORT    = "Short-Term Group"
GRP_LONG     = "Long-Term Group"
GRP_FILTERS  = "Additional Settings"
GRP_VIS      = "Signal Visibility"
C_BULL       = #089981
C_BEAR       = #f23645
C_SHORT      = #5b9cf6

// --- Inputs ---
shortLen1 = input.int(3, "EMA 1", minval=1, group=GRP_SHORT)
shortLen2 = input.int(5, "EMA 2", minval=1, group=GRP_SHORT)
shortLen3 = input.int(8, "EMA 3", minval=1, group=GRP_SHORT)
shortLen4 = input.int(10, "EMA 4", minval=1, group=GRP_SHORT)
shortLen5 = input.int(12, "EMA 5", minval=1, group=GRP_SHORT)
shortLen6 = input.int(15, "EMA 6", minval=1, group=GRP_SHORT)

longLen1 = input.int(30, "EMA 1", minval=1, group=GRP_LONG)
longLen2 = input.int(35, "EMA 2", minval=1, group=GRP_LONG)
longLen3 = input.int(40, "EMA 3", minval=1, group=GRP_LONG)
longLen4 = input.int(45, "EMA 4", minval=1, group=GRP_LONG)
longLen5 = input.int(50, "EMA 5", minval=1, group=GRP_LONG)
longLen6 = input.int(60, "EMA 6", minval=1, group=GRP_LONG)

// ATR Settings
useAtrFilter = input.bool(false, "Use ATR Volatility Filter", group=GRP_FILTERS, tooltip="Filters entries based on ATR distance.")
atrLength    = input.int(14, "ATR Length", minval=1, group=GRP_FILTERS)
atrMult      = input.float(1.5, "ATR Multiplier", minval=0.1, step=0.1, group=GRP_FILTERS)

// CVD Settings
useCvdFilter = input.bool(false, "Use CVD Confluence Filter", group=GRP_FILTERS, tooltip="Filters signals using Cumulative Volume Delta.")
cvdEmaLen    = input.int(20, "CVD Smoothing Length", minval=1, group=GRP_FILTERS)

// RSI Settings
useRsiFilter = input.bool(false, "Use RSI Exhaustion Filter", group=GRP_FILTERS, tooltip="Filters out Longs if RSI is Overbought and Shorts if RSI is Oversold.")
rsiLen       = input.int(14, "RSI Length", minval=1, group=GRP_FILTERS)
rsiOB        = input.int(70, "RSI Overbought Level", minval=50, maxval=100, group=GRP_FILTERS)
rsiOS        = input.int(30, "RSI Oversold Level", minval=0, maxval=50, group=GRP_FILTERS)

// Cooldown Settings
useCooldown  = input.bool(true, "Use Signal Cooldown", group=GRP_FILTERS, tooltip="Prevents multiple signals from firing too close to each other.")
cooldownBars = input.int(5, "Cooldown Bar Count", minval=1, group=GRP_FILTERS)

// Signal Visibility Settings
showLong      = input.bool(true, "Show Buy Signals", group=GRP_VIS)
showShort     = input.bool(true, "Show Sell Signals", group=GRP_VIS)
showLongExit  = input.bool(true, "Show Long Exits", group=GRP_VIS)
showShortExit = input.bool(true, "Show Short Exits", group=GRP_VIS)

// --- Calculations ---
// Short-term EMAs
s1 = ta.ema(close, shortLen1)
s2 = ta.ema(close, shortLen2)
s3 = ta.ema(close, shortLen3)
s4 = ta.ema(close, shortLen4)
s5 = ta.ema(close, shortLen5)
s6 = ta.ema(close, shortLen6)

// Long-term EMAs
l1 = ta.ema(close, longLen1)
l2 = ta.ema(close, longLen2)
l3 = ta.ema(close, longLen3)
l4 = ta.ema(close, longLen4)
l5 = ta.ema(close, longLen5)
l6 = ta.ema(close, longLen6)

// ATR Calculation
atrValue = ta.atr(atrLength)
atrFilterLong  = not useAtrFilter or (math.abs(close - l1) >= atrValue * atrMult)
atrFilterShort = not useAtrFilter or (math.abs(close - l1) >= atrValue * atrMult)

// CVD Calculation
delta = (high - low) == 0 ? 0 : ((close - open) / (high - low) * volume)
cvd = ta.cum(delta)
cvdEma = ta.ema(cvd, cvdEmaLen)
cvdFilterLong  = not useCvdFilter or (cvd > cvdEma)
cvdFilterShort = not useCvdFilter or (cvd < cvdEma)

// RSI Calculation
rsiValue = ta.rsi(close, rsiLen)
rsiFilterLong  = not useRsiFilter or (rsiValue < rsiOB)
rsiFilterShort = not useRsiFilter or (rsiValue > rsiOS)

// Trend Logic
isBullish = l1 > l6
isBearish = l1 < l6

// Base Signal Logic
longBase  = isBullish and low <= l1 and low[1] > l1[1] and atrFilterLong and cvdFilterLong and rsiFilterLong
shortBase = isBearish and high >= l1 and high[1] < l1[1] and atrFilterShort and cvdFilterShort and rsiFilterShort

// Cooldown Logic
var int lastLongBar  = 0
var int lastShortBar = 0

longCondition  = longBase  and (not useCooldown or (bar_index - lastLongBar >= cooldownBars))
shortCondition = shortBase and (not useCooldown or (bar_index - lastShortBar >= cooldownBars))

if longCondition
    lastLongBar := bar_index

if shortCondition
    lastShortBar := bar_index

// Exits
longExitCondition  = isBullish and high >= s1 and high[1] < s1[1]
shortExitCondition = isBearish and low <= s1 and low[1] > s1[1]

// --- Visuals ---
// Short-Term Group Plots
plot(s1, "Short EMA 1", color.new(C_SHORT, 0))
plot(s2, "Short EMA 2", color.new(C_SHORT, 15))
plot(s3, "Short EMA 3", color.new(C_SHORT, 30))
plot(s4, "Short EMA 4", color.new(C_SHORT, 45))
plot(s5, "Short EMA 5", color.new(C_SHORT, 60))
plot(s6, "Short EMA 6", color.new(C_SHORT, 75))

// Long-Term Group Plots
plot(l1, "Long EMA 1", color.new(C_BEAR, 0))
plot(l2, "Long EMA 2", color.new(C_BEAR, 15))
plot(l3, "Long EMA 3", color.new(C_BEAR, 30))
plot(l4, "Long EMA 4", color.new(C_BEAR, 45))
plot(l5, "Long EMA 5", color.new(C_BEAR, 60))
plot(l6, "Long EMA 6", color.new(C_BEAR, 75))

// Signal Plotting
plotshape(showLong and longCondition, "Long Entry", shape.circle, location.belowbar, C_BULL, size=size.small)
plotshape(showShort and shortCondition, "Short Entry", shape.circle, location.abovebar, C_BEAR, size=size.small)

plotshape(showLongExit and longExitCondition, "Long Exit", shape.labeldown, location.abovebar, C_BULL, size=size.tiny, text="Exit", textcolor=color.white)
plotshape(showShortExit and shortExitCondition, "Short Exit", shape.labelup, location.belowbar, C_BEAR, size=size.tiny, text="Exit", textcolor=color.white)

// Data Window Outputs
plot(atrValue, "ATR Value", display=display.data_window)
plot(cvd, "CVD", display=display.data_window)
plot(rsiValue, "RSI", display=display.data_window)

// Alerts
alertcondition(longCondition, "Long Entry", "Guppy Long Entry Signal")
alertcondition(shortCondition, "Short Entry", "Guppy Short Entry Signal")
alertcondition(longExitCondition, "Long Exit", "Guppy Long Exit Signal")
alertcondition(shortExitCondition, "Short Exit", "Guppy Short Exit Signal")
````
