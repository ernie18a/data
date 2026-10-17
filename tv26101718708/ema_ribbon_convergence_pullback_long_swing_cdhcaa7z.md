# EMA Ribbon Convergence Pullback Long [Swing]

- url: https://www.tradingview.com/script/cDhCaA7Z-EMA-Ribbon-Convergence-Pullback-Long-Swing/
- type: indicator
- pine_id: PUB;288d012770ca4d4aa4be9182c0b45897
- version: 1.0

## Description

EMA Ribbon Convergence Pullback Long [Swing] v10

Type: Long-only entry signal indicator (Pine Script v5, indicator())
Market: Indian equities (NSE), daily timeframe — works on other markets/timeframes but tuned for daily swings
Core idea: Flag a long entry when a 10-EMA ribbon (10 to 100) has recently tightened into a basing zone, price pulls back into it, and then closes back above the fastest EMA.

Note: This is the indicator version — it plots entry signals and alerts only. It does not size positions, place stops/targets, or run backtests. See the separate strategy() build (v11+) if you need Strategy Tester results with stop-loss/target logic.


1. Concept

The ribbon is 10 EMAs (10, 20, 30 ... 100). Three market states matter:


Basing (convergence): the EMAs bunch close together — the stock is consolidating rather than trending.
Pullback: after an uptrend resumes, price dips back down and touches or dips slightly below the ribbon.
Reversal (trigger): price closes back above the fastest EMA (EMA10), confirming buyers have stepped back in.


The indicator signals on step 3, provided step 1 happened recently and the broader trend (price vs EMA100) is still up.

Important design note: the ribbon does not need to be tightly converged on the trigger bar itself. A real pullback naturally causes the fast EMA to dip below the slower ones — requiring "tight AND perfectly ordered" on the same bar as the breakout is close to a contradiction. This version checks convergence over a recent lookback window, then checks the breakout separately as a distinct condition.


2. Entry Logic (all must be true)

#ConditionDescription1Basing RecentlyRibbon spread was "tight" (below threshold) at some point in the last N bars (convergenceLookback)2Trend UpPrice is above EMA100 (or EMA100 rising, depending on mode selected)3Pulled BackPrice's low touched or dipped below EMA10 within the last N bars (pullbackLookback)4Reversal TriggerClose crosses back above EMA10 (or, optionally, a bullish engulfing/hammer candle)5CooldownAt least cooldownBars bars since the last signal, to reduce signal spam

A yellow dot marks "near miss" bars — everything above is true except the trigger hasn't fired yet. Useful as an early watchlist flag.

Known gap in this version: cooldown is bar-count based only — there is no price-distance check, so two signals can fire close together in price if they land just outside the cooldown window on the same basing structure (this was fixed with a price-gap filter in v11).


3. What This Version Does Not Include


No stop-loss or target levels
No position sizing or backtest stats (Strategy Tester tab will not appear — this is an indicator(), not a strategy())
No price-distance-based duplicate-signal suppression (bar-count cooldown only)
No higher-timeframe (weekly) trend filter



4. Key Inputs Reference

Convergence


useAdaptive (default ON) — auto-scales the "tight ribbon" threshold to the stock's own recent volatility (percentile-based) instead of a fixed %. Recommended ON, especially across stocks at very different price levels.
convergenceThresh (default 3.0%) — fixed threshold used only if useAdaptive is OFF, and as the automatic fallback during the adaptive method's warm-up period (first ~150 bars of a chart's history).
pctLen (default 150) — lookback window for the adaptive percentile calculation.
pctRank (default 30) — lower = stricter/tighter convergence requirement.


Ribbon Order


requireBullishOrder (default OFF) — if ON, also requires EMA10 > EMA50 > EMA100 strictly on the trigger bar. Keep OFF for normal pullback entries; turning it ON produces a much rarer "clean trend only" variant. When OFF, this is tracked as an informational-only value in the Data Window.


Setup / Pullback / Trend


convergenceLookback (default 10) — how far back to check for a basing zone.
pullbackLookback (default 6) — how far back to check for a dip into the ribbon.
trendFilterMode (default "Price Above EMA100, no slope") — choose between slope-based or simple price-vs-EMA100 trend filters.
trendLen (default 10) — slope lookback, only used in the 10-bar EMA100-rising mode.
cooldownBars (default 5) — minimum bars between signals.


Candle Confirmation


requireCandlePattern (default OFF) — if ON, requires an engulfing or hammer candle in addition to the crossover. OFF gives more signals; ON gives fewer, higher-conviction ones.
useEngulfing, useHammer, minBodyATRRatio — pattern-detection sub-settings, only relevant if the above is ON or you're using patterns as an alternative trigger.


Diagnostics


showDebugTable — live stats panel (top-right) showing hover/click instructions.
showSetupMarkers — yellow "near miss" dots.
showWarmupBg — shades the region at the start of the chart where the adaptive threshold hasn't fully matured yet (using the fixed-% fallback instead).
Hidden 🔍-prefixed data-window plots — hover any bar (or click-and-hold on the chart) and open TradingView's Data Window (right-hand toolbar icon, or Alt+D) to see the live true/false state of every condition for that specific bar: Spread %, Threshold Used, Converged, EMA Order, Ribbon Bullish, Basing Recently, Pulled Back, Close Crossed Up, Candle Pattern, Trend Up, and the final BUY Signal flag. This is the fastest way to understand why a bar did or didn't signal.



5. How to Use


Paste the script into Pine Editor and add to chart.
Set an alert on the built-in alertcondition ("EMA Ribbon Long Entry") if you want notifications — set trigger to "Once Per Bar Close" to avoid intrabar flicker.
Use the Data Window (see Diagnostics above) to inspect any historical bar and confirm which conditions passed.
Because there's no stop-loss/target built in here, define your own risk management manually before acting on a signal (e.g., stop below the pullback low, target at a fixed risk-multiple).



6. Known Limitations


Long-only, daily-timeframe design. No short logic; not tested on intraday timeframes.
No higher-timeframe (weekly) trend filter — the indicator can still fire during a daily pullback that's actually part of a larger weekly downtrend. Consider manually checking the weekly chart before taking a signal.
No exit logic. This tells you when to consider entering, not when to exit — position sizing, stop-loss, and target are entirely up to you at this version.
Not backtested with real trade statistics at this stage — visual/historical review only. Use the v11+ strategy() build for Strategy Tester metrics (win rate, profit factor, drawdown).
This is not financial advice. Validate signals manually, paper trade, and manage risk according to your own plan before using with real capital.

## Source Code

````pine
//@version=6
indicator("EMA Ribbon Convergence Pullback Long [Swing]", overlay=true, max_labels_count=500)

// ================= INPUTS =================
showRibbon        = input.bool(true, "Show EMA Ribbon")

grpConv = "Convergence"
useAdaptive       = input.bool(true, "Use Adaptive Threshold (Percentile)", group=grpConv)
convergenceThresh = input.float(3.0, "Fixed Max Ribbon Spread % (also warm-up fallback)", minval=0.1, step=0.1, group=grpConv)
pctLen            = input.int(150, "Adaptive Lookback (bars)", minval=30, group=grpConv)
pctRank           = input.float(30.0, "Adaptive Percentile (lower = tighter)", minval=1, maxval=50, group=grpConv)

grpOrder = "Ribbon Order (informational, off by default)"
requireBullishOrder = input.bool(false, "Require EMA10>EMA50>EMA100 order to fire signal", group=grpOrder, tooltip="OFF by default. A real pullback inverts the fast EMA below the slow ones by definition — requiring order during the trigger contradicts the pullback itself. Turn ON only if you want a stricter, rarer 'clean trend only' variant.")

grpPB = "Setup / Pullback / Trend"
convergenceLookback = input.int(10, "Ribbon must have been converged within last N bars", minval=1, maxval=30, group=grpPB)
pullbackLookback  = input.int(6, "Pullback Lookback (bars, includes trigger bar)", minval=1, maxval=20, group=grpPB)
trendFilterMode   = input.string("Price Above EMA100 (no slope)", "Trend Filter", options=["EMA100 Rising (10-bar)", "EMA100 Rising (3-bar, faster)", "Price Above EMA100 (no slope)", "Off"], group=grpPB)
trendLen          = input.int(10, "  ↳ Slope Lookback (10-bar mode only)", minval=2, group=grpPB)
cooldownBars      = input.int(5, "Min Bars Between Signals", minval=1, group=grpPB)

grpCandle = "Candle Confirmation"
requireCandlePattern = input.bool(false, "Require Engulfing/Hammer (OFF = crossover above ribbon is enough)", group=grpCandle)
useEngulfing      = input.bool(true, "  ↳ Count Bullish Engulfing", group=grpCandle)
useHammer         = input.bool(true, "  ↳ Count Hammer", group=grpCandle)
minBodyATRRatio   = input.float(0.05, "  ↳ Min Candle Body (x ATR)", minval=0.0, step=0.01, group=grpCandle)

grpDebug = "Diagnostics"
showDebugTable    = input.bool(true, "Show Live Table (last bar only)", group=grpDebug)
showSetupMarkers  = input.bool(true, "Show 'Near Miss' Setup Markers (historical)", group=grpDebug)
showWarmupBg      = input.bool(true, "Highlight Warm-Up Period", group=grpDebug)

// ================= EMAs =================
e10  = ta.ema(close, 10)
e20  = ta.ema(close, 20)
e30  = ta.ema(close, 30)
e40  = ta.ema(close, 40)
e50  = ta.ema(close, 50)
e60  = ta.ema(close, 60)
e70  = ta.ema(close, 70)
e80  = ta.ema(close, 80)
e90  = ta.ema(close, 90)
e100 = ta.ema(close, 100)

plot(showRibbon ? e10  : na, "EMA 10",  color=color.new(#00e5ff, 0))
plot(showRibbon ? e20  : na, "EMA 20",  color=color.new(#29d1ff, 10))
plot(showRibbon ? e30  : na, "EMA 30",  color=color.new(#52bdff, 20))
plot(showRibbon ? e40  : na, "EMA 40",  color=color.new(#7ba9ff, 30))
plot(showRibbon ? e50  : na, "EMA 50",  color=color.new(#a495ff, 40))
plot(showRibbon ? e60  : na, "EMA 60",  color=color.new(#c481f0, 50))
plot(showRibbon ? e70  : na, "EMA 70",  color=color.new(#e56dd6, 60))
plot(showRibbon ? e80  : na, "EMA 80",  color=color.new(#ff59b3, 70))
plot(showRibbon ? e90  : na, "EMA 90",  color=color.new(#ff4590, 80))
plot(showRibbon ? e100 : na, "EMA 100", color=color.new(#ff3060, 0))

// ================= RIBBON STATE =================
ribbonTop = e10
ribbonMax = math.max(e10, e20, e30, e40, e50, e60, e70, e80, e90, e100)
ribbonMin = math.min(e10, e20, e30, e40, e50, e60, e70, e80, e90, e100)
spreadPct = (ribbonMax - ribbonMin) / close * 100

adaptiveThreshRaw = ta.percentile_nearest_rank(spreadPct, pctLen, pctRank)
inWarmup          = na(adaptiveThreshRaw)
adaptiveThresh     = inWarmup ? convergenceThresh : adaptiveThreshRaw
isConverged        = useAdaptive ? spreadPct <= adaptiveThresh : spreadPct <= convergenceThresh

bgcolor(showWarmupBg and useAdaptive and inWarmup ? color.new(color.gray, 85) : na, title="Adaptive Threshold Warm-Up")

isBullishOrder = e10 > e50 and e50 > e100   // now informational only unless requireBullishOrder is ON

ribbonBullish = isConverged and (requireBullishOrder ? isBullishOrder : true)   // "basing" bar

wasRibbonBullishRecently = false
for i = 0 to convergenceLookback
    if ribbonBullish[i]
        wasRibbonBullishRecently := true
        break

trendUp = switch trendFilterMode
    "EMA100 Rising (10-bar)"        => e100 > e100[trendLen]
    "EMA100 Rising (3-bar, faster)" => e100 > e100[3]
    "Price Above EMA100 (no slope)" => close > e100
    "Off"                           => true
    => true

// ================= PULLBACK DETECTION =================
pulledBack = false
for i = 0 to pullbackLookback
    if low[i] <= ribbonTop[i]
        pulledBack := true
        break

// ================= CANDLE PATTERNS (optional confirmation) =================
atrVal    = ta.atr(14)
bodySize  = math.abs(close - open)
bigBody   = bodySize >= atrVal * minBodyATRRatio

bullishEngulfing = useEngulfing and close > open and close[1] < open[1] and close >= open[1] and open <= close[1] and bigBody

lowerWick = math.min(open, close) - low
upperWick = high - math.max(open, close)
isHammer  = useHammer and lowerWick >= bodySize * 2 and upperWick <= bodySize * 0.6 and close > open and bigBody

patternCandle  = bullishEngulfing or isHammer
closeCrossUp   = ta.crossover(close, ribbonTop)
reversalTrigger = closeCrossUp or patternCandle

// ================= ENTRY LOGIC =================
rawSignal = wasRibbonBullishRecently and trendUp and pulledBack and reversalTrigger and (requireCandlePattern ? patternCandle : true)

var int lastSignalBar = na
canFire   = na(lastSignalBar) or (bar_index - lastSignalBar) >= cooldownBars
buySignal = rawSignal and canFire

if buySignal
    lastSignalBar := bar_index

// ================= DATA WINDOW OUTPUTS =================
plot(spreadPct,                        "🔍 Spread %",                display=display.data_window)
plot(adaptiveThresh,                   "🔍 Threshold Used",          display=display.data_window)
plot(isConverged ? 1 : 0,              "🔍 Converged (1=yes)",       display=display.data_window)
plot(isBullishOrder ? 1 : 0,           "🔍 EMA10>50>100 (info only)",display=display.data_window)
plot(ribbonBullish ? 1 : 0,            "🔍 Ribbon Bullish Today",    display=display.data_window)
plot(wasRibbonBullishRecently ? 1 : 0, "🔍 Basing Recently",         display=display.data_window)
plot(pulledBack ? 1 : 0,               "🔍 Pulled Back",             display=display.data_window)
plot(closeCrossUp ? 1 : 0,             "🔍 Close Crossed Up",        display=display.data_window)
plot(patternCandle ? 1 : 0,            "🔍 Candle Pattern",          display=display.data_window)
plot(trendUp ? 1 : 0,                  "🔍 Trend Up",                display=display.data_window)
plot(buySignal ? 1 : 0,                "🔍 BUY SIGNAL",              display=display.data_window)

// ================= VISUALS & ALERTS =================
bgcolor(ribbonBullish ? color.new(color.teal, 90) : na, title="Ribbon Convergence Zone (basing)")

plotshape(buySignal, title="Long Entry (BUY)", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small, text="BUY", textcolor=color.lime)

nearMiss = showSetupMarkers and wasRibbonBullishRecently and pulledBack and trendUp and not reversalTrigger and canFire
plotshape(nearMiss, title="Setup Forming", style=shape.circle, location=location.belowbar, color=color.yellow, size=size.tiny)

alertcondition(buySignal, title="EMA Ribbon Long Entry", message="Long entry on {{ticker}} at {{close}}")

// ================= DIAGNOSTICS TABLE (last bar) =================
var table dbg = table.new(position.top_right, 2, 3, bgcolor=color.new(color.black, 20), border_width=1)
if showDebugTable and barstate.islast
    table.cell(dbg, 0, 0, "Hover any bar", text_color=color.gray, text_size=size.small)
    table.cell(dbg, 1, 0, "→ Data Window", text_color=color.aqua, text_size=size.small)
    table.cell(dbg, 0, 1, "or click+hold", text_color=color.gray, text_size=size.small)
    table.cell(dbg, 1, 1, "on any candle", text_color=color.gray, text_size=size.small)
````
