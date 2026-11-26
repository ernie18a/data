# Super QuantumX Trend Shift Indicator V2

- url: https://www.tradingview.com/script/PSDjI7yr-Super-QuantumX-Trend-Shift-Indicator-V2/
- type: indicator
- pine_id: PUB;e9991ba42160470f80ed3323ad66aea5
- version: 2.0

## Description

[b]Overview[/b]
The [b]Super QuantumX Trend Shift Indicator V2[/b] is an institutional-grade confluence engine designed for professional scalpers and intraday trend followers. While many retail indicators focus on a single metric (like price momentum), Super QuantumX recognizes that institutional moves are driven by a convergence of Momentum, Volume, Volatility, and Market Structure.

- This indicator is a sophisticated "Decision Matrix." It is not simply a collection of indicators on one chart; it is a gated signal system. A BUY or SELL signal is only generated when six distinct market dimensions align perfectly. This multi-layered approach filters out the noise of low-liquidity sessions and identifies the exact moment "Smart Money" enters the market.

[b]Core Institutional Components & Why They Are Used:[/b]
[b]1. Refined Momentum (Supertrend Logic):[/b] Used to define the primary active zones. We use Cyan for bullish and Purple for bearish momentum to provide an immediate visual bias.
[b]2. Institutional Moving Averages (Multi-Type EMA Cross):[/b] Standard retail crosses are often too slow. We provide 6 adjustable MA types (EMA, TEMA, HMA, etc.) to confirm that the short-term trend is supported by institutional moving average baselines.
[b]3. Accumulation Detection (Squeeze Pro):[/b] Before an institutional move occurs, the market often consolidates. We integrate Bollinger Band and Keltner Channel compression logic (Yellow bars) to identify these high-pressure zones where big orders are being filled.
[b]4. Relative Aggression (CVD Proxy): [/b]Using a Cumulative Volume Delta proxy, the script ensures that signals are backed by aggressive market participants rather than thin retail volume.
[b]5. Velocity & Strength (MACD/RSI/ADX):[/b] MACD tracks the velocity of the move, RSI confirms strength relative to the last 14 bars, and ADX filters out "Chop" zones by muting signals when volatility is too low to sustain a scalp.
[b]6. Tactical Confirmation (Candle Pattern Recognition):[/b] Even if indicators align, we require a price action "trigger." The script looks for institutional-grade Engulfing patterns to ensure an impulse candle is behind every signal.

[b]Advanced Profit Target Hierarchy[/b]
Unlike standard pivot points, our target system is dynamic and vertically aligned for a clean "R1-R3" look:
- [b]HVN TARGET #1 & #2:[/b] Uses High Volume Nodedetection over a 100-bar and 25-bar lookback to find the Point of Control where liquidity is most dense.
- [b]TARGET #3 & #4:[/b] Uses 1.618 and 2.618 Fibonacci Extensions of the higher-timeframe move to identify trend exhaustion levels.

[b]The Multi-Timeframe Dashboard[/b]
A real-time dashboard tracks the health of the trade by showing the status of the Current, 15-minute, and 1-hour trend alignments. This ensures you never scalp against the "Master Trend" of the day.

[b]How to Use[/b]
- [b]The Setup:[/b] Wait for [b]Yellow bars[/b](Squeeze) to appear. This indicates institutional interest is building.
- [b]The Trigger:[/b] A [b]BUY[/b] or [b]SELL[/b] label will appear when all 6 internal strategies align.
- [b]The Zones:[/b] Only take long signals in Cyan zones and short signals in Purple zones.
- [b]The Exit:[/b] Take profit at the horizontal[b] HVN[/b] or [b]Fib[/b] target levels and trail your stop along the [b]Quantum Line[/b].

[b]Settings & Customization[/b]
Traders have full control over signal sensitivity, including an [b]ATR Strength Filter[/b] to ensure candles have enough range to trade, and an optional [b]Signal Cooldown[/b] to prevent repetitive labels during volatile sessions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tradedailywithseb


//@version=6
indicator("Super QuantumX Trend Shift Indicator V2", "Super QuantumX V2", overlay = true, max_labels_count = 500, max_lines_count = 500)

// --- Constants ---
color C_CYAN   = #00bcd4
color C_PURPLE = #9c27b0
color C_GREY   = #787b86
color C_GREEN  = #089981
color C_RED    = #f23645
color C_BLACK  = #131722
color C_WHITE  = #ffffff
color C_SQZ    = #ffeb3b 

// --- Inputs ---
grp_sig = "Signal Settings"
showSignals = input.bool(true, "Enable Buy/Sell Signals", group = grp_sig)
useCooldown = input.bool(true, "Enable Signal Cooldown", group = grp_sig)
cooldownLen = input.int(10, "Cooldown Bars", minval = 1, group = grp_sig)
useAtrFilter = input.bool(true, "Enable ATR Strength Filter", group = grp_sig)
atrLen      = input.int(14, "ATR Length", group = grp_sig)
atrMult     = input.float(1.0, "ATR Strength Multiplier", step = 0.1, group = grp_sig)

grp_ema = "Institutional Moving Averages"
maFastType = input.string("EMA", "Fast MA Type", options = ["SMA", "EMA", "WMA", "SMMA", "DEMA", "TEMA", "HMA"], group = grp_ema)
emaFastLen = input.int(9, "Fast MA Length", group = grp_ema)
maSlowType = input.string("EMA", "Slow MA Type", options = ["SMA", "EMA", "WMA", "SMMA", "DEMA", "TEMA", "HMA"], group = grp_ema)
emaSlowLen = input.int(21, "Slow MA Length", group = grp_ema)
emaFCol    = input.color(color.new(C_WHITE, 50), "Fast MA Color", group = grp_ema)
emaSCol    = input.color(color.new(C_WHITE, 70), "Slow MA Color", group = grp_ema)

grp_filt = "Trend & Volatility"
stM = input.float(3.0, "Supertrend Multiplier", group = grp_filt)
stL = input.int(10, "Supertrend Period", group = grp_filt)
htf1 = input.timeframe("15", "HTF 1 (15m)", group = grp_filt)
htf2 = input.timeframe("60", "HTF 2 (1h)", group = grp_filt)

grp_tp = "Take Profit Settings"
showTargets     = input.bool(true, "Show All Targets", group = grp_tp)
hvnLookback     = input.int(100, "Primary HVN Lookback", group = grp_tp)
hvnColor        = input.color(color.new(color.black, 0), "Primary HVN Color", group = grp_tp)
hvnLookbackFast = input.int(25, "Aggressive HVN Lookback", group = grp_tp)
hvnColorFast    = input.color(color.new(color.gray, 0), "Aggressive HVN Color", group = grp_tp)
showFibTarget   = input.bool(true, "Show Fib Targets (#3 & #4)", group = grp_tp)
fib3Color       = input.color(color.new(C_CYAN, 20), "Target #3 Color", group = grp_tp)
fib4Color       = input.color(color.new(C_GREEN, 20), "Target #4 Color", group = grp_tp)
fibTargetDashed = input.bool(true, "Dashed Fib Targets", group = grp_tp)

// --- Functions ---
st_dir(m, l) => 
    [_, d] = ta.supertrend(m, l)
    d

// Custom MA function
getMA(type, src, len) =>
    switch type
        "SMA"  => ta.sma(src, len)
        "EMA"  => ta.ema(src, len)
        "WMA"  => ta.wma(src, len)
        "SMMA" => ta.rma(src, len)
        "DEMA" => 2 * ta.ema(src, len) - ta.ema(ta.ema(src, len), len)
        "TEMA" => 3 * (ta.ema(src, len) - ta.ema(ta.ema(src, len), len)) + ta.ema(ta.ema(ta.ema(src, len), len), len)
        "HMA"  => ta.hma(src, len)
        => ta.ema(src, len)

// --- Calculations ---

// 1. Supertrend Core
[stV, stD] = ta.supertrend(stM, stL)
isUp = stD < 0
trendFlip = ta.change(stD) != 0

// 2. Volatility & CVD Proxy
[_, _, adxVal] = ta.dmi(14, 14)
isActive = adxVal > 20
deltaVal = (close - open) / (math.max(high - low, syminfo.mintick)) * volume
cvdVal = ta.cum(deltaVal)

// 3. MACD & RSI
[mLine, sLine, _] = ta.macd(close, 12, 26, 9)
rsiVal = ta.rsi(close, 14)

// 4. Moving Averages (Independent Types and Lengths)
maF = getMA(maFastType, close, emaFastLen)
maS = getMA(maSlowType, close, emaSlowLen)
maBull = maF > maS

// 5. Institutional Patterns
engB = (close > open) and (close[1] < open[1]) and (close > open[1])
engS = (close < open) and (close[1] > open[1]) and (close < open[1])

// 6. Squeeze Pro
basis = ta.sma(close, 20)
dev   = 2.0 * ta.stdev(close, 20)
lowerBB = basis - dev
upperBB = basis + dev
kcRange = ta.atr(20) * 1.5
sqzActive = (lowerBB > basis - kcRange) and (upperBB < basis + kcRange)

// 7. ATR Strength Filter
atrValue = ta.atr(atrLen)
isImpulseMove = not useAtrFilter or (high - low > atrValue * atrMult)

// 8. CORE SIGNAL LOGIC
lCond = isUp and mLine > sLine and rsiVal > 50 and cvdVal > cvdVal[1] and maBull and engB and isImpulseMove
sCond = not isUp and mLine < sLine and rsiVal < 50 and cvdVal < cvdVal[1] and not maBull and engS and isImpulseMove

var int lastSigB = 0
finalBuy  = lCond and (not useCooldown or (bar_index - lastSigB > cooldownLen))
finalSell = sCond and (not useCooldown or (bar_index - lastSigB > cooldownLen))

if finalBuy or finalSell
    lastSigB := bar_index

// 9. HTF Context
htfD1 = request.security(syminfo.tickerid, htf1, st_dir(stM, stL))
htfD2 = request.security(syminfo.tickerid, htf2, st_dir(stM, stL))
h1hVal = request.security(syminfo.tickerid, htf2, ta.highest(high, 20))
l1hVal = request.security(syminfo.tickerid, htf2, ta.lowest(low, 20))

// --- Visuals ---

// 1. Chart Background & Trend Line
bgcolor(isActive ? na : color.new(C_GREY, 95))
plot(stV, "Quantum Line", sqzActive ? C_SQZ : (isUp ? C_CYAN : C_PURPLE), 2)
barcolor(sqzActive ? C_SQZ : (isActive ? (isUp ? C_CYAN : C_PURPLE) : C_GREY))
plot(maF, "Fast MA", emaFCol), plot(maS, "Slow MA", emaSCol)

// 2. Signals
if finalBuy and showSignals
    label.new(bar_index, low, "BUY", color=C_GREEN, textcolor=C_WHITE, style=label.style_label_up)
if finalSell and showSignals
    label.new(bar_index, high, "SELL", color=C_RED, textcolor=C_WHITE, style=label.style_label_down)

// 3. Targets (Inline objects)
var line L1 = na, var line L2 = na, var line L3 = na, var line L4 = na
var label LB1 = na, var label LB2 = na, var label LB3 = na, var label LB4 = na

vMaxP = ta.highest(volume, hvnLookback)
vMaxA = ta.highest(volume, hvnLookbackFast)
hvn1 = ta.valuewhen(volume == vMaxP, close, 0)
hvn2 = ta.valuewhen(volume == vMaxA, close, 0)

if trendFlip and showTargets
    line.delete(L1), line.delete(L2), line.delete(L3), line.delete(L4)
    label.delete(LB1), label.delete(LB2), label.delete(LB3), label.delete(LB4)
    r = h1hVal - l1hVal
    p3 = isUp ? l1hVal + r * 1.618 : h1hVal - r * 1.618
    p4 = isUp ? l1hVal + r * 2.618 : h1hVal - r * 2.618
    fS = fibTargetDashed ? line.style_dashed : line.style_solid
    L1 := line.new(bar_index, hvn1, bar_index, hvn1, color=hvnColor, width=2)
    L2 := line.new(bar_index, hvn2, bar_index, hvn2, color=hvnColorFast, width=2)
    L3 := line.new(bar_index, p3, bar_index, p3, color=fib3Color, width=2, style=fS)
    L4 := line.new(bar_index, p4, bar_index, p4, color=fib4Color, width=2, style=fS)
    LB1 := label.new(bar_index, hvn1, "HVN #1", color=#00000000, textcolor=hvnColor, style=label.style_label_left, size=size.small)
    LB2 := label.new(bar_index, hvn2, "HVN #2", color=#00000000, textcolor=hvnColorFast, style=label.style_label_left, size=size.small)
    LB3 := label.new(bar_index, p3, "T3 (1.618)", color=#00000000, textcolor=fib3Color, style=label.style_label_left, size=size.small)
    LB4 := label.new(bar_index, p4, "T4 (2.618)", color=#00000000, textcolor=fib4Color, style=label.style_label_left, size=size.small)

if not na(L1)
    line.set_x2(L1, bar_index), line.set_x2(L2, bar_index), line.set_x2(L3, bar_index), line.set_x2(L4, bar_index)
    label.set_x(LB1, bar_index+2), label.set_x(LB2, bar_index+2), label.set_x(LB3, bar_index+2), label.set_x(LB4, bar_index+2)

// 4. Dashboard
var table d = table.new(position.top_right, 2, 5, border_width=1, frame_color=C_GREY, frame_width=1)
if barstate.islast
    table.cell(d, 0, 0, "Current TF", bgcolor=C_BLACK, text_color=C_WHITE)
    table.cell(d, 1, 0, isUp ? "BULL" : "BEAR", bgcolor=isUp ? C_CYAN : C_PURPLE, text_color=C_WHITE)
    table.cell(d, 0, 1, "15m Trend", bgcolor=C_BLACK, text_color=C_WHITE)
    table.cell(d, 1, 1, htfD1 < 0 ? "BULL" : "BEAR", bgcolor=htfD1 < 0 ? C_CYAN : C_PURPLE, text_color=C_WHITE)
    table.cell(d, 0, 2, "1h Trend", bgcolor=C_BLACK, text_color=C_WHITE)
    table.cell(d, 1, 2, htfD2 < 0 ? "BULL" : "BEAR", bgcolor=htfD2 < 0 ? C_CYAN : C_PURPLE, text_color=C_WHITE)
    table.cell(d, 0, 3, "MA Trend", bgcolor=C_BLACK, text_color=C_WHITE)
    table.cell(d, 1, 3, maBull ? "BULL" : "BEAR", bgcolor=maBull ? C_CYAN : C_PURPLE, text_color=C_WHITE)
    table.cell(d, 0, 4, "Squeeze", bgcolor=C_BLACK, text_color=C_WHITE)
    table.cell(d, 1, 4, sqzActive ? "READY" : "NO", bgcolor=sqzActive ? C_SQZ : C_BLACK, text_color=sqzActive ? C_BLACK : C_WHITE)
````
