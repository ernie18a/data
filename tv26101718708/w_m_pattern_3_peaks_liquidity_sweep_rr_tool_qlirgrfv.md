# W & M Pattern | 3 Peaks + Liquidity Sweep | RR Tool

- url: https://www.tradingview.com/script/qLIrGrfv-W-M-Pattern-3-Peaks-Liquidity-Sweep-RR-Tool/
- type: indicator
- pine_id: PUB;9d2806e1f9d24b078ace822e05a1bdf3
- version: 1.0

## Description

W & M Pattern | 3 Peaks + Liquidity Sweep | RR Tool
This indicator identifies high-probability reversal setups by combining classical market structure analysis with liquidity sweep detection — two concepts widely used in Smart Money and Price Action trading.
How It Works
The indicator continuously scans the chart for two mirror-image setups:
Bullish W Pattern (Long Setup)

In a falling market, price forms three consecutive Lower Highs (LH1 → LH2 → LH3), confirming a bearish structure. The indicator then watches for a W formation — where price first drops to a swing low, sweeps below it to grab liquidity (the sharp wick down), and then reverses sharply upward forming the right leg of the W. This liquidity sweep is the key trigger, as it signals that smart money has absorbed sell-side orders and a reversal is likely. A long entry is signaled as price recovers, with the stop loss placed just below the W's sweep low and the take profit targeting either the 1st or 3rd Lower High.
Bearish M Pattern (Short Setup)

In a rising market, price forms three consecutive Higher Highs (HH1 → HH2 → HH3), confirming a bullish structure. The indicator then watches for an M formation — where price pushes above the prior swing high to sweep buy-side liquidity (the sharp wick up), then fails and drops below the neckline. This sweep signals that smart money has distributed into retail buying pressure and a reversal downward is likely. A short entry is signaled as price breaks down, with the stop loss just above the M's sweep high and take profit targeting the 1st or 3rd Higher High.

## Source Code

````pine
//@version=6
indicator("W & M Pattern | 3 Peaks + Liquidity Sweep | RR Tool", overlay=true, max_lines_count=500, max_labels_count=200, max_boxes_count=100)

// ══════════════════════════════════════════════
//   INPUTS
// ══════════════════════════════════════════════
pivotLen     = input.int(4,    "Pivot Length",               minval=2, maxval=10,  group="Pattern Settings")
minPeakGap   = input.float(0.05, "Min % Gap Between Peaks",  minval=0.01, maxval=1.0, step=0.01, group="Pattern Settings", tooltip="Peaks must differ by at least this % to count as separate structure")
cooldown     = input.int(30,   "Min Bars Between Signals",   minval=10, maxval=200, group="Pattern Settings")
boxBars      = input.int(50,   "RR Box Width (bars)",        minval=10, maxval=200, group="Display")
rrTarget     = input.string("1st Peak", "Take Profit Target",options=["1st Peak", "3rd Peak"], group="Display")

// Trend Settings
trendEma1    = input.int(50,  "Fast Trend EMA",  minval=5,  maxval=200, group="Trend Filter")
trendEma2    = input.int(200, "Slow Trend EMA",  minval=20, maxval=500, group="Trend Filter")
showTrendBg  = input.bool(true, "Show Trend Background", group="Trend Filter")

// ══════════════════════════════════════════════
//   TREND DETECTION (EMA 50 / 200)
// ══════════════════════════════════════════════
ema50  = ta.ema(close, trendEma1)
ema200 = ta.ema(close, trendEma2)

isBearishTrend = ema50 < ema200   // downtrend → only show W
isBullishTrend = ema50 > ema200   // uptrend   → only show M

// Plot EMAs
plot(ema50,  "Fast EMA", color=color.new(color.yellow, 0), linewidth=1)
plot(ema200, "Slow EMA", color=color.new(color.white,  0), linewidth=1)

// Subtle background color showing current trend
bgcolor(showTrendBg and isBearishTrend ? color.new(color.red,   93) : na, title="Bearish Trend BG")
bgcolor(showTrendBg and isBullishTrend ? color.new(color.teal,  93) : na, title="Bullish Trend BG")

// Trend label on last bar
if barstate.islast
    trendTxt   = isBullishTrend ? "▲ BULLISH TREND\nLooking for M" : "▼ BEARISH TREND\nLooking for W"
    trendCol   = isBullishTrend ? color.teal : color.red
    label.new(bar_index, high * 1.001, trendTxt,
              color=trendCol, textcolor=color.white,
              style=label.style_label_left, size=size.small)

// ══════════════════════════════════════════════
//   PIVOT STORAGE
// ══════════════════════════════════════════════
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow (low,  pivotLen, pivotLen)

var float ph1 = na, var float ph2 = na, var float ph3 = na
var int   pb1 = na, var int   pb2 = na, var int   pb3 = na
var float pl1 = na, var float pl2 = na, var float pl3 = na
var int   lb1 = na, var int   lb2 = na, var int   lb3 = na

if not na(ph)
    ph3 := ph2,  pb3 := pb2
    ph2 := ph1,  pb2 := pb1
    ph1 := ph,   pb1 := bar_index - pivotLen

if not na(pl)
    pl3 := pl2,  lb3 := lb2
    pl2 := pl1,  lb2 := lb1
    pl1 := pl,   lb1 := bar_index - pivotLen

// ══════════════════════════════════════════════
//   PEAK GAP CHECKER
// ══════════════════════════════════════════════
gapOk(a, b) =>
    math.abs(a - b) / ((a + b) / 2) * 100 >= minPeakGap

// ══════════════════════════════════════════════
//   DRAW RR BOX
// ══════════════════════════════════════════════
drawBox(entryP, slP, tpP, isBull, startB) =>
    risk   = math.abs(entryP - slP)
    reward = math.abs(tpP - entryP)
    rr     = reward / risk
    endB   = startB + boxBars

    profitCol = isBull ? color.new(color.teal, 75) : color.new(color.red, 75)

    box.new(startB, tpP, endB, entryP,
            bgcolor=profitCol, border_color=color.new(color.gray,70), border_width=1)
    box.new(startB, entryP, endB, slP,
            bgcolor=color.new(color.orange,80), border_color=color.new(color.gray,70), border_width=1)

    line.new(startB, tpP,    endB, tpP,    color=isBull ? color.teal : color.red, width=2, style=line.style_dashed)
    line.new(startB, entryP, endB, entryP, color=color.white,  width=1, style=line.style_dotted)
    line.new(startB, slP,    endB, slP,    color=color.orange, width=2, style=line.style_dashed)

    txt = (isBull ? "▲ LONG" : "▼ SHORT") + "\n" +
          "Entry : " + str.tostring(math.round(entryP, 3)) + "\n" +
          "TP    : " + str.tostring(math.round(tpP,    3)) + "\n" +
          "SL    : " + str.tostring(math.round(slP,    3)) + "\n" +
          "RR    : 1:" + str.tostring(math.round(rr,   1))

    label.new(startB + 2, isBull ? tpP : slP, txt,
              color=isBull ? color.teal : color.red,
              textcolor=color.white,
              style=isBull ? label.style_label_down : label.style_label_up,
              size=size.small)

// ══════════════════════════════════════════════
//   W PATTERN — only in BEARISH trend
// ══════════════════════════════════════════════
var int  wBar = na
var bool wSig = false
wSig := false

if isBearishTrend and not na(ph1) and not na(ph2) and not na(ph3) and not na(pl1) and not na(pl2)
    // 3 Lower Highs with minimum gap between each
    threeDown = ph3 > ph2 and ph2 > ph1 and gapOk(ph3, ph2) and gapOk(ph2, ph1)

    // Sweep: pl1 is deeper than pl2, and happened after 3rd peak
    sweepDone      = pl1 < pl2 and lb1 > lb2 and lb1 > pb1
    // Recovery: close is back above pl2 (right leg of W forming)
    recovering     = close > pl2

    if threeDown and sweepDone and recovering and (na(wBar) or bar_index - wBar > cooldown)
        entryP = close
        slP    = pl1 - (pl1 * 0.0003)
        tpP    = rrTarget == "1st Peak" ? ph3 : ph1

        if tpP > entryP
            drawBox(entryP, slP, tpP, true, bar_index)

            label.new(pb3, ph3, "LH1", color=color.new(color.red,30), textcolor=color.white, style=label.style_label_down, size=size.tiny)
            label.new(pb2, ph2, "LH2", color=color.new(color.red,30), textcolor=color.white, style=label.style_label_down, size=size.tiny)
            label.new(pb1, ph1, "LH3", color=color.new(color.red,30), textcolor=color.white, style=label.style_label_down, size=size.tiny)
            label.new(lb1, pl1, "W\nSweep", color=color.teal, textcolor=color.white, style=label.style_label_up, size=size.small)

            wBar := bar_index
            wSig := true

// ══════════════════════════════════════════════
//   M PATTERN — only in BULLISH trend
// ══════════════════════════════════════════════
var int  mBar = na
var bool mSig = false
mSig := false

if isBullishTrend and not na(ph1) and not na(ph2) and not na(ph3) and not na(pl1) and not na(pl2)
    // 3 Higher Highs with minimum gap
    threeUp = ph3 < ph2 and ph2 < ph1 and gapOk(ph3, ph2) and gapOk(ph2, ph1)

    // Sweep: ph1 is higher than ph2, happened after HH3
    sweepDoneM  = ph1 > ph2 and pb1 > pb2 and pb1 > lb1
    // Failure: price now falling below pl1 (neckline break)
    failingDown = close < pl1 and lb1 > pb2

    if threeUp and sweepDoneM and failingDown and (na(mBar) or bar_index - mBar > cooldown)
        entryP = close
        slP    = ph1 + (ph1 * 0.0003)
        tpP    = rrTarget == "1st Peak" ? ph3 : ph2

        if tpP < entryP
            drawBox(entryP, slP, tpP, false, bar_index)

            label.new(pb3, ph3, "HH1", color=color.new(color.teal,30), textcolor=color.white, style=label.style_label_up, size=size.tiny)
            label.new(pb2, ph2, "HH2", color=color.new(color.teal,30), textcolor=color.white, style=label.style_label_up, size=size.tiny)
            label.new(pb1, ph1, "HH3\nSweep", color=color.red, textcolor=color.white, style=label.style_label_down, size=size.small)

            mBar := bar_index
            mSig := true

// ══════════════════════════════════════════════
//   ALERTS
// ══════════════════════════════════════════════
alertcondition(wSig, "W Pattern (Bearish Trend)", "▲ W Pattern in Bearish Trend — Long Setup!")
alertcondition(mSig, "M Pattern (Bullish Trend)", "▼ M Pattern in Bullish Trend — Short Setup!")
````
