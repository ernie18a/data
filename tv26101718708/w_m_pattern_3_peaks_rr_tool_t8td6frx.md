# W & M Pattern | 3 Peaks + RR Tool

- url: https://www.tradingview.com/script/T8td6FrX-W-M-Pattern-3-Peaks-RR-Tool/
- type: indicator
- pine_id: PUB;248e0138edf14b88a6715b9272b217ae
- version: 1.0

## Description

W and MW & M Pattern | 3 Peaks + Liquidity Sweep | RR Tool
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
indicator("W & M Pattern | 3 Peaks + RR Tool", overlay=true, max_lines_count=500, max_labels_count=200, max_boxes_count=100)

// ══════════════════════════════════════════════
//   INPUTS
// ══════════════════════════════════════════════
pivotLen   = input.int(3,  "Pivot Length (lower = more signals)", minval=2, maxval=10, group="Settings")
boxBars    = input.int(50, "RR Box Width (bars)",                 minval=10, maxval=200, group="Settings")
rrTarget   = input.string("1st Peak", "Take Profit Target",       options=["1st Peak", "3rd Peak"], group="Settings")
showW      = input.bool(true, "Show W (Bullish) Patterns",        group="Settings")
showM      = input.bool(true, "Show M (Bearish) Patterns",        group="Settings")

// ══════════════════════════════════════════════
//   PIVOT DETECTION
// ══════════════════════════════════════════════
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow (low,  pivotLen, pivotLen)

// Store last 6 pivot highs
var float ph1 = na, var float ph2 = na, var float ph3 = na
var int   pb1 = na, var int   pb2 = na, var int   pb3 = na

// Store last 6 pivot lows
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
//   DRAW RR BOX
// ══════════════════════════════════════════════
drawBox(entryP, slP, tpP, isBull, startB) =>
    risk   = math.abs(entryP - slP)
    reward = math.abs(tpP - entryP)
    rr     = reward / risk
    endB   = startB + boxBars

    profitCol = isBull ? color.new(color.teal,   75) : color.new(color.red,    75)
    lossCol   =                                         color.new(color.orange, 80)

    // Profit box
    box.new(startB, tpP, endB, entryP,
            bgcolor=profitCol, border_color=color.new(color.gray,70), border_width=1)
    // Loss box
    box.new(startB, entryP, endB, slP,
            bgcolor=lossCol, border_color=color.new(color.gray,70), border_width=1)

    // TP line
    line.new(startB, tpP, endB, tpP,
             color=isBull ? color.teal : color.red, width=2, style=line.style_dashed)
    // Entry line
    line.new(startB, entryP, endB, entryP,
             color=color.white, width=1, style=line.style_dotted)
    // SL line
    line.new(startB, slP, endB, slP,
             color=color.orange, width=2, style=line.style_dashed)

    // Info label
    txt = (isBull ? "▲ LONG" : "▼ SHORT") + "\n" +
          "Entry : " + str.tostring(math.round(entryP, 3)) + "\n" +
          "TP    : " + str.tostring(math.round(tpP,    3)) + "\n" +
          "SL    : " + str.tostring(math.round(slP,    3)) + "\n" +
          "RR    : 1:" + str.tostring(math.round(rr,   1))

    label.new(startB + 2, isBull ? tpP : slP, txt,
              color     = isBull ? color.teal : color.red,
              textcolor = color.white,
              style     = isBull ? label.style_label_down : label.style_label_up,
              size      = size.small)

// ══════════════════════════════════════════════
//   W PATTERN LOGIC
//   3 descending pivot highs (LH1 > LH2 > LH3)
//   followed by 2 pivot lows where PL2 < PL1
//   (sweep low) then price recovers = W
// ══════════════════════════════════════════════
var bool wDone = false
var int  wBar  = na
var bool wSig  = false
wSig := false

if showW and not na(ph1) and not na(ph2) and not na(ph3) and not na(pl1) and not na(pl2)
    // 3 Lower Highs
    threeDown = ph3 > ph2 and ph2 > ph1

    // pl2 is the first low (left side of W), pl1 is the sweep (deeper low)
    sweepDone = pl1 < pl2 and lb1 > lb2

    // pl1 must come AFTER ph1 (sweep happens after 3rd peak)
    sweepAfterPeak = lb1 > pb1

    // Price is now recovering above pl2 (right leg rising)
    recovering = close > pl2

    allGood = threeDown and sweepDone and sweepAfterPeak and recovering

    // Fire only once per pattern
    if allGood and (na(wBar) or bar_index - wBar > 20)
        entryP = close
        slP    = pl1 - (pl1 * 0.0003)           // SL just below W low
        tpP    = rrTarget == "1st Peak" ? ph3 : ph1  // TP at 1st or 3rd peak

        if tpP > entryP                           // valid bullish setup
            drawBox(entryP, slP, tpP, true, bar_index)

            // Peak labels
            label.new(pb3, ph3, "LH1", color=color.new(color.red,30),
                      textcolor=color.white, style=label.style_label_down, size=size.tiny)
            label.new(pb2, ph2, "LH2", color=color.new(color.red,30),
                      textcolor=color.white, style=label.style_label_down, size=size.tiny)
            label.new(pb1, ph1, "LH3", color=color.new(color.red,30),
                      textcolor=color.white, style=label.style_label_down, size=size.tiny)

            // W bottom label
            label.new(lb1, pl1, "W\nSweep", color=color.teal,
                      textcolor=color.white, style=label.style_label_up, size=size.small)

            wBar := bar_index
            wSig := true

// ══════════════════════════════════════════════
//   M PATTERN LOGIC
//   3 ascending pivot highs (HH1 < HH2 < HH3)
//   followed by 2 pivot highs where PH after HH3
//   sweeps above then fails = M
// ══════════════════════════════════════════════
var bool mDone = false
var int  mBar  = na
var bool mSig  = false
mSig := false

if showM and not na(ph1) and not na(ph2) and not na(ph3) and not na(pl1) and not na(pl2)
    // 3 Higher Highs
    threeUp = ph3 < ph2 and ph2 < ph1

    // pl1 is pivot low after the 3rd high — first pullback after HH3
    // Then ph1 is the sweep high above ph2 but now failing
    sweepHigh     = ph1                           // most recent pivot high = sweep
    sweepHighBar  = pb1
    prevHigh      = ph2                           // the HH3
    prevHighBar   = pb2

    sweepDoneM    = sweepHigh > prevHigh and sweepHighBar > prevHighBar

    // Price now falling below pl1 (pivot low between the two humps)
    failingDown   = close < pl1 and lb1 > pb2

    allGoodM = threeUp and sweepDoneM and failingDown

    if allGoodM and (na(mBar) or bar_index - mBar > 20)
        entryP = close
        slP    = sweepHigh + (sweepHigh * 0.0003)   // SL just above M high
        tpP    = rrTarget == "1st Peak" ? ph3 : ph2  // TP at 1st or 3rd peak

        if tpP < entryP                               // valid bearish setup
            drawBox(entryP, slP, tpP, false, bar_index)

            // Peak labels
            label.new(pb3, ph3, "HH1", color=color.new(color.teal,30),
                      textcolor=color.white, style=label.style_label_up, size=size.tiny)
            label.new(pb2, ph2, "HH2", color=color.new(color.teal,30),
                      textcolor=color.white, style=label.style_label_up, size=size.tiny)
            label.new(pb1, ph1, "HH3\nSweep", color=color.red,
                      textcolor=color.white, style=label.style_label_down, size=size.small)

            mBar := bar_index
            mSig := true

// ══════════════════════════════════════════════
//   ALERTS
// ══════════════════════════════════════════════
alertcondition(wSig, "W Pattern", "▲ W Pattern Bullish Setup Detected!")
alertcondition(mSig, "M Pattern", "▼ M Pattern Bearish Setup Detected!")
````
