# Klinger Volume Oscillator (KVO) + Signals

- url: https://www.tradingview.com/script/RtiFtHtK-Klinger-Volume-Oscillator-KVO-Signals/
- type: indicator
- pine_id: PUB;08194599565947eebf1c36f66e59147d
- version: 1.0

## Description

KVO Trade Signals — Klinger Volume Oscillator with Filtered, Confirmed Cross Signals

OVERVIEW
This script adds a tunable buy/sell signal engine to the classic Klinger Volume Oscillator (KVO). The oscillator math is unchanged from the original. What's new is a set of filters and a confirmation step that decide which KVO/Trigger crosses become signals. They are built to separate strong, trending crosses from the weak, back-and-forth crosses that show up in choppy markets.

CREDIT
The Klinger Volume Oscillator calculation in this script comes from HPotter's open-source "Klinger Volume Oscillator (KVO)" v1.0 on TradingView. All credit for the original indicator goes to HPotter, and for the underlying concept to Stephen Klinger, who created the Klinger Volume Oscillator. HPotter's default lengths of 34 (fast), 55 (slow) and 13 (trigger) are kept. This version ports that code to Pine Script v6 and adds the signal, filter, confirmation and diagnostic layers described below. Like the original, it is published open-source.

HOW IT WORKS
• Blue line = KVO (fast EMA minus slow EMA of signed volume). Red line = Trigger (EMA of KVO).
• SELL candidate: Blue crosses DOWN through Red.
• BUY candidate: Blue crosses UP through Red.
• A candidate becomes a signal only if it passes every enabled filter and then the confirmation check.

Raw KVO values are in volume units, so they vary hugely between symbols and timeframes. To keep the settings portable, every filter is measured as a percentage of the KVO's own standard deviation over the Normalization Lookback. For example, 100% means "one standard deviation." The same settings mean roughly the same thing on any chart.

Signals appear as BUY/SELL labels on the price chart and as small triangles in the oscillator pane. You can turn each display on or off.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
INPUTS — THE LEVERS AND DIALS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

KVO LENGTHS
• Trigger / Fast / Slow Length (13 / 34 / 55): the standard KVO settings. Leave these alone unless you deliberately want a faster or slower oscillator.

SIGNAL FILTERS (units = % of KVO std dev)
• Normalization Lookback (200 bars): the window used to measure KVO's standard deviation. Every "%" setting below is relative to it. Longer = steadier scale. Shorter = adapts faster to changing volume regimes.

• Use zero-line filter (on): requires crosses to happen on the "stretched" side of zero. Sells must happen above zero and buys below.
• Zero-Line Distance (20%): how far from zero the cross must occur. Sell: Blue must be above +X%. Buy: Blue must be below −X%. The faint red and green lines in the pane show these levels.
  – 0 = anywhere on the correct side of zero.
  – Negative values let crosses fire slightly on the wrong side. For example, −10 lets a Buy fire up to 10% above zero.
  – Turn it off if good signals regularly happen near or across zero on your market.

• Min Run-Up Gap (50%): before the cross, Blue must have been at least this far from Red on the opposite side within the last Run-Up Bars. Good crosses usually come "from a distance," while chop crosses weave in and out of a narrow band. This is usually the most effective chop filter. 0 = off.
• Run-Up Bars (10): how far back the run-up gap is measured.

• Min Cross Strength (0 = off): how quickly the Blue/Red gap opens through the cross, measured as the change in (KVO − Trigger) over Strength Bars. Flat, lazy crosses score low.
• Strength Bars (3): the window for the strength measurement.

CONFIRMATION (blocks barely-crossed fakeouts)
• Confirmation Bars (1): the signal prints this many bars after the cross, and only if Blue stayed on the new side of Red on every bar. 0 = fire on the cross bar itself (fastest, but more fakeouts).
• Min Close-Through Margin (10%): on the signal bar, Blue must be at least this far past Red. 0 = off.
• Signal candle must close in trade direction (on): Buy needs a green candle (close > open) and Sell needs a red one.

TREND FILTER (Donchian midline)
• Use Donchian midline slope (on): Sells only when the Donchian midline is flat or falling, and Buys only when it is flat or rising. This keeps you from fading a channel that is still trending.
• Donchian Length (20): the channel length.
• Slope Lookback (3): compares the current midline with the midline this many bars ago. Shorter lookbacks (2) react faster after V-shaped reversals, where the midline lags.
• Flat Tolerance (0 ticks): a midline change within this many ticks counts as flat.

DISPLAY
• Show signals on price chart / in oscillator pane.
• Show filter values on crosses (for tuning) and Diagnostic label size: see the next section.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
HOW TO TUNE IT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Turn on "Show filter values on crosses (for tuning)". Every Blue/Red cross gets a label with each filter's reading and a ✓ (pass) or ✗ (fail):
   – Zero = KVO's position as a signed % of std dev (for example, −85 means 0.85 std dev below zero)
   – Gap = the run-up gap %
   – Str = cross strength (shown only when that filter is on)
   – DC = Donchian slope pass/fail
   Blue label = passed all cross filters and is waiting for confirmation. Gray label = blocked.
   Orange "no confirm" label = a cross that passed the filters but failed confirmation. It shows the reason: "recrossed" (Blue fell back through Red), "margin N" (not far enough past Red), or "candle" (wrong-colored signal candle).

2. Scroll back through your market and timeframe. Mark the crosses you would have wanted to take and the ones you would have wanted to skip.

3. Compare their numbers. Look for the setting that separates the two groups, and set its threshold between them. In testing, Run-Up Gap was often the clearest difference: wanted crosses showed gaps in the hundreds, while chop crosses were mostly well below that.

4. If a good signal is missing, its label tells you which filter blocked it (the ✗). Loosen only that filter. Common cases:
   – Zero ✗ on a good reversal: the oscillator hadn't reached the stretched side yet. Lower or negate Zero-Line Distance, or turn the zero filter off.
   – DC ✗ just after a sharp V-bottom or V-top: reduce Slope Lookback to 2, or raise Flat Tolerance.
   – Orange "margin": lower Min Close-Through Margin, or use 0 Confirmation Bars.

5. If too many bad signals get through, tighten the filter whose numbers best separate them. That is usually Run-Up Gap first, then Zero-Line Distance or Confirmation.

6. Turn the diagnostics off when you're done. They're for tuning and clutter the chart.

The pane's autoscale can be misleading. A KVO that looks "just above zero" may actually be a full standard deviation above it. Trust the label's Zero % over your eye.

Cross Strength and Run-Up Gap (above/below) are also shown in the Data Window for every bar.

ALERTS
Two alert conditions are included: "KVO Buy" and "KVO Sell". They fire only on fully filtered and confirmed signals. Set alerts to "Once Per Bar Close." Signals are evaluated on the bar's values, so a signal can appear and then disappear while a bar is still forming.

NOTES
• The KVO is volume-based. It needs a symbol with real volume data and is not meaningful on symbols without it.
• The default settings are a starting point, not an optimized set. Market, timeframe and session all change what works, so tune on your own charts.
• This is an analysis tool, not a trading system or financial advice. Past signal behavior does not guarantee future results.

## Source Code

````pine
//@version=6
// Based on HPotter's Klinger Volume Oscillator (KVO) v1.0, adapted with cross signals
// Threshold and cross-strength filters are normalized to KVO's own standard deviation,
// so they are chart-scale independent and portable across symbols/timeframes.
indicator(title = "Klinger Volume Oscillator (KVO) + Signals", shorttitle = "KVO Signals", format = format.volume, max_labels_count = 500)

// ── Inputs ──────────────────────────────────────────────
trigLen   = input.int(13, "Trigger Length", minval = 1)
fastX     = input.int(34, "Fast Length",    minval = 1)
slowX     = input.int(55, "Slow Length",    minval = 1)

grpF      = "Signal Filters (units = % of KVO std dev)"
normLen   = input.int(200, "Normalization Lookback (bars)", minval = 20, group = grpF,
     tooltip = "Bars used to measure KVO's standard deviation. Both filters below are expressed as % of this.")
useZero   = input.bool(true, "Use zero-line filter", group = grpF,
     tooltip = "Off = Buy/Sell on any qualifying cross regardless of where it happens.")
threshold = input.int(20, "Zero-Line Distance (%)", minval = -300, maxval = 300, group = grpF,
     tooltip = "Sell: Blue must be above +X% of std dev at the cross. Buy: below -X%.\n0 = just above/below zero.\nNegative = allows crosses slightly on the wrong side (e.g. -10 lets a Buy fire up to 10% ABOVE zero, and a Sell up to 10% below).")
minGap    = input.int(50, "Min Run-Up Gap (%)", minval = 0, group = grpF,
     tooltip = "Blue must have been at least X% of std dev away from Red (on the far side) within the last Run-Up Bars before the cross. Blocks weaving/chop crosses. 0 = off.")
gapBars   = input.int(10, "Run-Up Bars", minval = 2, group = grpF)
minStr    = input.int(0, "Min Cross Strength", minval = 0, group = grpF,
     tooltip = "How fast the Blue-Red gap opens through the cross: change in (KVO - Trigger) over Strength Bars, as % of std dev. Flat chop crosses score low. 0 = off.")
strBars   = input.int(3, "Strength Bars", minval = 1, group = grpF,
     tooltip = "Bars over which the gap change is measured.")
showStr   = input.bool(false, "Show filter values on crosses (for tuning)", group = grpF,
     tooltip = "Labels EVERY Blue/Red cross with each filter's value and ✓/✗: Zero = KVO position as % of std dev (signed), Gap = run-up gap %, Str = cross strength (if on), DC = midline slope. Blue label = passed all cross filters (awaiting confirmation), gray = blocked. Orange = armed cross that failed confirmation, with reason.")

lblSizeIn = input.string("Normal", "Diagnostic label size", options = ["Small", "Normal", "Large", "Huge"], group = grpF)
lblSize   = lblSizeIn == "Small" ? size.small : lblSizeIn == "Normal" ? size.normal : lblSizeIn == "Large" ? size.large : size.huge

grpC      = "Confirmation (blocks barely-crossed fakeouts)"
confBars  = input.int(1, "Confirmation Bars", minval = 0, maxval = 10, group = grpC,
     tooltip = "Signal fires this many bars AFTER the cross, only if Blue stayed on the new side of Red every bar. 0 = fire on the cross bar.")
minMargin = input.int(10, "Min Close-Through Margin (%)", minval = 0, group = grpC,
     tooltip = "On the signal bar, Blue must be at least X% of std dev past Red (convincing close). 0 = off.")
useCandle = input.bool(true, "Signal candle must close in trade direction", group = grpC,
     tooltip = "Buy: signal bar close > open. Sell: close < open.")

grpT      = "Trend Filter (Donchian midline)"
useDC     = input.bool(true, "Use Donchian midline slope", group = grpT,
     tooltip = "Sell only when the midline is flat or falling; Buy only when flat or rising.")
dcLen     = input.int(20, "Donchian Length", minval = 1, group = grpT)
dcLook    = input.int(3, "Slope Lookback (bars)", minval = 1, group = grpT,
     tooltip = "Midline now vs. this many bars ago.")
dcTolTk   = input.int(0, "Flat Tolerance (ticks)", minval = 0, group = grpT,
     tooltip = "A change within this many ticks counts as flat.")

grpD        = "Display"
showOnPrice = input.bool(true, "Show signals on price chart",     group = grpD)
showInPane  = input.bool(true, "Show signals in oscillator pane", group = grpD)

// ── KVO calculation (unchanged logic) ───────────────────
xTrend   = hlc3 > hlc3[1] ? volume * 100 : -volume * 100
xFast    = ta.ema(xTrend, fastX)
xSlow    = ta.ema(xTrend, slowX)
xKVO     = xFast - xSlow
xTrigger = ta.ema(xKVO, trigLen)

// ── Normalization ───────────────────────────────────────
sd       = ta.stdev(xKVO, normLen)
safeSd   = nz(sd) > 0 ? sd : na
thrLevel = threshold / 100.0 * nz(sd)              // threshold in raw KVO units (for plotting)
spread   = xKVO - xTrigger
strength = math.abs(ta.change(spread, strBars)) / safeSd * 100.0

// Run-up gap: biggest separation on the far side before the cross (prior bars)
gapAbove = ta.highest(spread, gapBars)[1] / safeSd * 100.0     // Blue above Red (precedes a Sell)
gapBelow = -ta.lowest(spread, gapBars)[1] / safeSd * 100.0     // Blue below Red (precedes a Buy)

// Donchian midline slope
dcMid    = math.avg(ta.highest(high, dcLen), ta.lowest(low, dcLen))
dcChg    = dcMid - dcMid[dcLook]
dcTol    = dcTolTk * syminfo.mintick
dcShortOK = not useDC or dcChg <= dcTol
dcLongOK  = not useDC or dcChg >= -dcTol

// ── Signals ─────────────────────────────────────────────
crossDn  = ta.crossunder(xKVO, xTrigger) and (not useZero or xKVO >  thrLevel)
crossUp  = ta.crossover(xKVO, xTrigger)  and (not useZero or xKVO < -thrLevel)
strOK    = minStr == 0 or nz(strength) >= minStr
gapSellOK = minGap == 0 or nz(gapAbove) >= minGap
gapBuyOK  = minGap == 0 or nz(gapBelow) >= minGap
armSell  = crossDn and strOK and gapSellOK and dcShortOK and not na(safeSd)
armBuy   = crossUp and strOK and gapBuyOK  and dcLongOK  and not na(safeSd)

// Confirmation: wait confBars, Blue must stay on the new side and clear the margin
marginLvl = minMargin / 100.0 * nz(sd)
minSpr    = ta.lowest(spread,  confBars + 1)     // over cross bar .. now
maxSpr    = ta.highest(spread, confBars + 1)
var int buyArmBar  = na
var int sellArmBar = na
if armBuy
    buyArmBar  := bar_index
    sellArmBar := na
if armSell
    sellArmBar := bar_index
    buyArmBar  := na

buySig     = false
sellSig    = false
buyFailed  = false
sellFailed = false
if not na(buyArmBar) and bar_index - buyArmBar == confBars
    buySig    := minSpr > 0 and spread >= marginLvl and (not useCandle or close > open)
    buyFailed := not buySig
    buyArmBar := na
if not na(sellArmBar) and bar_index - sellArmBar == confBars
    sellSig    := maxSpr < 0 and spread <= -marginLvl and (not useCandle or close < open)
    sellFailed := not sellSig
    sellArmBar := na

// ── Plots ───────────────────────────────────────────────
hline(0, "Zero", color = color.gray, linestyle = hline.style_solid)
plot(useZero ?  thrLevel : na, "Sell Threshold", color = color.new(color.red,   60), style = plot.style_line)
plot(useZero ? -thrLevel : na, "Buy Threshold",  color = color.new(color.green, 60), style = plot.style_line)

plot(xKVO,     "KVO",     color = color.blue)
plot(xTrigger, "Trigger", color = color.red)

// Markers in the oscillator pane
plotshape(showInPane and buySig,  "Buy (pane)",  shape.triangleup,   location.bottom, color.green, size = size.tiny)
plotshape(showInPane and sellSig, "Sell (pane)", shape.triangledown, location.top,    color.red,   size = size.tiny)

// Markers on the price chart
plotshape(showOnPrice and buySig,  "Buy",  shape.labelup,   location.belowbar, color.green, text = "BUY",  textcolor = color.white, size = size.small, force_overlay = true)
plotshape(showOnPrice and sellSig, "Sell", shape.labeldown, location.abovebar, color.red,   text = "SELL", textcolor = color.white, size = size.small, force_overlay = true)

// Tuning labels: EVERY Blue/Red cross, showing each filter's value and pass (✓) / fail (✗)
rawUp = ta.crossover(xKVO, xTrigger)
rawDn = ta.crossunder(xKVO, xTrigger)
ck(bool ok) => ok ? "✓" : "✗"
if showStr and (rawUp or rawDn) and not na(safeSd)
    zPct  = xKVO / safeSd * 100.0
    zOK   = rawUp ? crossUp : crossDn
    g     = rawUp ? gapBelow : gapAbove
    gOK   = rawUp ? gapBuyOK : gapSellOK
    dcOK  = rawUp ? dcLongOK : dcShortOK
    armed = rawUp ? armBuy : armSell
    txt   = "Zero " + str.tostring(zPct, "#") + ck(zOK) +
         "\nGap " + str.tostring(g, "#") + ck(gOK) +
         (minStr > 0 ? "\nStr " + str.tostring(strength, "#") + ck(strOK) : "") +
         (useDC ? "\nDC " + ck(dcOK) : "")
    label.new(bar_index, xKVO, txt,
         style     = rawUp ? label.style_label_up : label.style_label_down,
         color     = armed ? color.new(color.blue, 30) : color.new(color.gray, 40),
         textcolor = color.white,
         size      = lblSize)

// Tuning: armed crosses that failed confirmation, with the reason
if showStr and (buyFailed or sellFailed)
    m       = (buyFailed ? spread : -spread) / nz(safeSd, 1) * 100.0
    stayed  = buyFailed ? minSpr > 0 : maxSpr < 0
    candOK  = not useCandle or (buyFailed ? close > open : close < open)
    reason  = not stayed ? "recrossed" : m < minMargin ? "margin " + str.tostring(m, "#") : not candOK ? "candle" : ""
    label.new(bar_index, xKVO, "no confirm: " + reason,
         style     = buyFailed ? label.style_label_up : label.style_label_down,
         color     = color.new(color.orange, 20),
         textcolor = color.black,
         size      = lblSize)

// Data window readout
plot(strength, "Cross Strength", display = display.data_window)
plot(gapAbove, "Run-Up Gap (above)", display = display.data_window)
plot(gapBelow, "Run-Up Gap (below)", display = display.data_window)

// ── Alerts ──────────────────────────────────────────────
alertcondition(buySig,  "KVO Buy",  "KVO Buy: Blue crossed up over Red below -threshold with filters + confirmation")
alertcondition(sellSig, "KVO Sell", "KVO Sell: Blue crossed down over Red above +threshold with filters + confirmation")
````
