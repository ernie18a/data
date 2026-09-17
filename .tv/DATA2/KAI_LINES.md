<!-- tradingview-pine-id: PUB;e2d1b88d92a742b9a3d8a07f6ca7b062 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# KAI LINES

Source: https://www.tradingview.com/script/TfNG2Jj4-KAI-LINES/

## Description

**KAI LINES — Smart Money Market Structure & Trade Plan Indicator**

KAI LINES is an all-in-one market structure and trade planning indicator designed to help traders identify potential trend shifts, continuation moves, entry areas, stop-loss levels, and profit targets directly on the chart.

The indicator tracks both **Major Market Structure** and **Internal Market Structure**, allowing traders to quickly understand the bigger market direction while also identifying shorter-term structural changes.

### Key Features

**Market Structure Detection**

* Identifies bullish and bearish structure breaks.
* Major structure is displayed as **BREAKOUT**.
* Internal structure is displayed as **BREAKOUT 2**.
* Tracks both **Change of Character (CHoCH)** and **Break of Structure (BoS)**.

**Automatic BUY & SELL Setups**
KAI LINES can generate trading setups when a market structure shift occurs.

Users can choose between:

* **CHoCH Only** — focuses on potential reversal setups.
* **CHoCH + BoS** — includes both reversal and continuation setups.

**Automatic Trade Plan**

Whenever a valid setup is detected, the indicator automatically calculates and displays:

* BUY or SELL Target Signal
* Primary Entry Area
* Secondary Pullback Entry Area
* Stop Loss Price
* Take Profit 1
* Take Profit 2
* Take Profit 3
* Take Profit 4

Profit targets are calculated using configurable **Risk-to-Reward (R) multiples**, allowing traders to customize their trade management style.

Default targets:

* TP1 = 1R
* TP2 = 2R
* TP3 = 3R
* TP4 = 4R

**Dynamic Stop Loss**

Stop Loss can be calculated using:

* ATR-based volatility
* Previous market structure / swing level

ATR length, ATR multiplier, additional SL buffer, and entry pullback depth can all be customized.

**External & Internal Trend Panel**

A simple trend dashboard displays the current condition of:

* External / Major Structure
* Internal / Minor Structure

This makes it easier to see whether both structures are aligned bullish, bearish, or conflicting.

**TradingView Alerts**

KAI LINES supports BUY and SELL alerts when a new setup is generated, making it possible to monitor multiple markets without constantly watching the chart.

### How to Read KAI LINES

**Bullish Setup**
A bullish structure shift can generate a BUY signal.

The indicator will automatically display:
Entry Area → Stop Loss → TP1 → TP2 → TP3 → TP4.

**Bearish Setup**
A bearish structure shift can generate a SELL signal.

The same trade-plan structure is automatically calculated in the opposite direction.

For higher-quality setups, traders can combine KAI LINES with market context such as trend direction, liquidity, support/resistance, higher-timeframe structure, volume, or fundamental catalysts.

### Important

KAI LINES is a technical analysis and trade-planning tool — it does not guarantee profitable trades.

Signals are evaluated on the **live candle and may change before the candle closes**. For more reliable confirmation, traders should evaluate signals after the candle has closed.

Always use proper risk management.

**KAI LINES — Structure. Entry. Risk. Target.**

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KAI
//@version=6
indicator("KAI LINES", "KAI LINES", overlay = true, max_bars_back = 5000, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// =====================================================================================================================
// KAI LINES
// Smart-Money market structure + automatic trade-plan tool.
// Major structure = BREAKOUT
// Internal structure = BREAKOUT 2
// NOTE: Signals evaluate on the live bar and can change before the candle closes.
// =====================================================================================================================

// ============================ INPUTS =================================================================================
gS = "Structure"

swingLen = input.int(5, "Major Structure Length", minval = 1, group = gS, tooltip = "Pivot lookback that times the Buy/Sell signals (major structure).")
intLen = input.int(3, "Internal Structure Length", minval = 1, group = gS, tooltip = "Pivot lookback for internal (minor) structure.")

showMajor = input.bool(true, "Show BREAKOUT (major structure)", group = gS)
showInternal = input.bool(true, "Show BREAKOUT 2 (internal structure)", group = gS)

// ============================ TRADE PLAN =============================================================================
gT = "Trade Plan (TP / SL)"

sigSource = input.string("CHoCH (reversal only)", "Generate setup on", options = ["CHoCH (reversal only)", "CHoCH + BoS"], group = gT, tooltip = "Reversal-only entries, or add continuation structure-break entries too.")

useATR = input.bool(true, "Stop-Loss from ATR (else last swing)", group = gT)

atrLen = input.int(14, "ATR Length", minval = 1, group = gT)

atrMult = input.float(1.5, "Stop-Loss ATR ×", minval = 0.1, step = 0.1, group = gT)

slBufPerc = input.float(0.0, "Extra SL buffer (%)", minval = 0.0, step = 0.05, group = gT)

entryDepth = input.float(0.25, "2nd entry depth (R)", minval = 0.0, step = 0.05, group = gT, tooltip = "Second Area Signal = entry pulled back this fraction of risk.")

rr1 = input.float(1.0, "Take Profit 1 (R)", step = 0.1, group = gT)
rr2 = input.float(2.0, "Take Profit 2 (R)", step = 0.1, group = gT)
rr3 = input.float(3.0, "Take Profit 3 (R)", step = 0.1, group = gT)
rr4 = input.float(4.0, "Take Profit 4 (R)", step = 0.1, group = gT)

zoneLen = input.int(60, "Zone length (bars)", minval = 5, group = gT)

// ============================ COLORS =================================================================================
gC = "Colors (KAI scheme)"

colBuy = input.color(#26a69a, "Buy / Bullish", group = gC)
colSell = input.color(#ef5350, "Sell / Bearish", group = gC)
colSL = input.color(#bf0a30, "Stop Loss", group = gC)
colArea = input.color(#ff7a00, "Area / Entry", group = gC)
colTP = input.color(#2eb344, "Take Profit", group = gC)
colZone = input.color(#7b68ee, "Reward zone fill", group = gC)

// ============================ INFO ===================================================================================
gI = "Info"

showTable = input.bool(true, "Show trend panel", group = gI)

showMarkers = input.bool(true, "Show Buy/Sell history markers", group = gI)

showLabels = input.bool(true, "Show price labels", group = gI, tooltip = "Text callouts for signal, stop loss, entry areas, and take profits.")

// ============================ STRUCTURE ENGINE =======================================================================
detectStructure(float ph, float pl, int len) =>

    var float upLvl = na
    var int upBar = na

    var float dnLvl = na
    var int dnBar = na

    var int trend = 0

    var int lockUp = -1
    var int lockDn = -1

    if not na(ph)
        upLvl := ph
        upBar := bar_index - len

    if not na(pl)
        dnLvl := pl
        dnBar := bar_index - len

    bool bosBull = false
    bool chochBull = false

    bool bosBear = false
    bool chochBear = false

    float brokeLvl = na
    int brokeBar = na

    // Bullish structure break
    if not na(upLvl) and ta.crossover(close, upLvl) and lockUp != upBar

        if trend == -1
            chochBull := true
        else
            bosBull := true

        brokeLvl := upLvl
        brokeBar := upBar

        trend := 1
        lockUp := upBar

    // Bearish structure break
    if not na(dnLvl) and ta.crossunder(close, dnLvl) and lockDn != dnBar

        if trend == 1
            chochBear := true
        else
            bosBear := true

        brokeLvl := dnLvl
        brokeBar := dnBar

        trend := -1
        lockDn := dnBar

    [bosBull, chochBull, bosBear, chochBear, brokeLvl, brokeBar, trend, upLvl, dnLvl]

// ============================ PIVOTS =================================================================================
mph = ta.pivothigh(swingLen, swingLen)
mpl = ta.pivotlow(swingLen, swingLen)

iph = ta.pivothigh(intLen, intLen)
ipl = ta.pivotlow(intLen, intLen)

// ============================ STRUCTURE RESULTS ======================================================================
[mBosBull, mChochBull, mBosBear, mChochBear, mLvl, mBar, mTrend, mUpLvl, mDnLvl] = detectStructure(mph, mpl, swingLen)

[iBosBull, iChochBull, iBosBear, iChochBear, iLvl, iBar, iTrend, iUpLvl, iDnLvl] = detectStructure(iph, ipl, intLen)

// ============================ STRUCTURE DRAWING ======================================================================
f_break(bool cond, float lvl, int bbar, string txt, color col, bool isBull, bool shouldShow, bool minor) =>

    if cond and shouldShow and not na(lvl) and not na(bbar)

        line.new(
             bbar,
             lvl,
             bar_index,
             lvl,
             color = color.new(col, 30),
             style = minor ? line.style_dotted : line.style_dashed,
             width = minor ? 1 : 2
         )

        label.new(
             int((bbar + bar_index) / 2),
             lvl,
             txt,
             style = isBull ? label.style_label_down : label.style_label_up,
             textcolor = col,
             color = color.new(col, 90),
             size = minor ? size.tiny : size.small
         )

// ============================ MAJOR STRUCTURE ========================================================================
f_break(mChochBull, mLvl, mBar, "BREAKOUT", colBuy, true, showMajor, false)

f_break(mBosBull, mLvl, mBar, "BREAKOUT", colBuy, true, showMajor, false)

f_break(mChochBear, mLvl, mBar, "BREAKOUT", colSell, false, showMajor, false)

f_break(mBosBear, mLvl, mBar, "BREAKOUT", colSell, false, showMajor, false)

// ============================ INTERNAL STRUCTURE =====================================================================
f_break(iChochBull, iLvl, iBar, "BREAKOUT 2", colBuy, true, showInternal, true)

f_break(iBosBull, iLvl, iBar, "BREAKOUT 2", colBuy, true, showInternal, true)

f_break(iChochBear, iLvl, iBar, "BREAKOUT 2", colSell, false, showInternal, true)

f_break(iBosBear, iLvl, iBar, "BREAKOUT 2", colSell, false, showInternal, true)

// ============================ SIGNAL TRIGGERS ========================================================================
sigOnBoS = sigSource == "CHoCH + BoS"

longSetup = mChochBull or (sigOnBoS and mBosBull)

shortSetup = mChochBear or (sigOnBoS and mBosBear)

// ============================ ATR ====================================================================================
atr = ta.atr(atrLen)

// ============================ DRAWING VARIABLES ======================================================================
var box bxReward = na
var box bxEntry = na
var box bxSL = na

var line lnSL = na
var line lnE1 = na
var line lnE2 = na

var line lnTP1 = na
var line lnTP2 = na
var line lnTP3 = na
var line lnTP4 = na

var label lbSig = na
var label lbSL = na

var label lbA1 = na
var label lbA2 = na

var label lbTP1 = na
var label lbTP2 = na
var label lbTP3 = na
var label lbTP4 = na

// ============================ CLEAR PREVIOUS PLAN ====================================================================
f_clear() =>

    box.delete(bxReward)
    box.delete(bxEntry)
    box.delete(bxSL)

    line.delete(lnSL)
    line.delete(lnE1)
    line.delete(lnE2)

    line.delete(lnTP1)
    line.delete(lnTP2)
    line.delete(lnTP3)
    line.delete(lnTP4)

    label.delete(lbSig)
    label.delete(lbSL)

    label.delete(lbA1)
    label.delete(lbA2)

    label.delete(lbTP1)
    label.delete(lbTP2)
    label.delete(lbTP3)
    label.delete(lbTP4)

// ============================ ZONE RIGHT EDGE ========================================================================
right = bar_index + zoneLen

// ============================ BUY SETUP ==============================================================================
if longSetup

    f_clear()

    float entry = close

    float strisk = na(mDnLvl) ? atr * atrMult : math.max(entry - mDnLvl, syminfo.mintick)

    float risk = (useATR ? atr * atrMult : strisk) * (1 + slBufPerc / 100)

    float sl = entry - risk

    float e2 = entry - risk * entryDepth

    float t1 = entry + risk * rr1
    float t2 = entry + risk * rr2
    float t3 = entry + risk * rr3
    float t4 = entry + risk * rr4

    float band = risk * 0.04

    // Reward zone
    bxReward := box.new(
         bar_index,
         math.max(entry, t4),
         right,
         math.min(entry, t4),
         border_width = 0,
         bgcolor = color.new(colZone, 88)
     )

    // Entry zone
    bxEntry := box.new(
         bar_index,
         math.max(entry, e2),
         right,
         math.min(entry, e2),
         border_color = color.new(colArea, 40),
         bgcolor = color.new(colArea, 80),
         border_width = 1
     )

    // Stop loss zone
    bxSL := box.new(
         bar_index,
         sl + band,
         right,
         sl - band,
         border_width = 0,
         bgcolor = color.new(colSL, 70)
     )

    // Stop loss
    lnSL := line.new(
         bar_index,
         sl,
         right,
         sl,
         color = colSL,
         width = 2
     )

    // Entry 1
    lnE1 := line.new(
         bar_index,
         entry,
         right,
         entry,
         color = colArea,
         width = 1
     )

    // Entry 2
    lnE2 := line.new(
         bar_index,
         e2,
         right,
         e2,
         color = colArea,
         style = line.style_dotted
     )

    // TP1
    lnTP1 := line.new(
         bar_index,
         t1,
         right,
         t1,
         color = colTP,
         style = line.style_dashed
     )

    // TP2
    lnTP2 := line.new(
         bar_index,
         t2,
         right,
         t2,
         color = colTP,
         style = line.style_dashed
     )

    // TP3
    lnTP3 := line.new(
         bar_index,
         t3,
         right,
         t3,
         color = colTP,
         style = line.style_dashed
     )

    // TP4
    lnTP4 := line.new(
         bar_index,
         t4,
         right,
         t4,
         color = colTP,
         style = line.style_dashed
     )

    if showLabels

        lbSig := label.new(
             bar_index,
             sl - band,
             "Target Signal BUY",
             style = label.style_label_up,
             color = colBuy,
             textcolor = color.white,
             size = size.small
         )

        lbSL := label.new(
             right,
             sl,
             "Stop Loss Price: " + str.tostring(sl, format.mintick),
             style = label.style_label_left,
             color = colSL,
             textcolor = color.white,
             size = size.small
         )

        lbA1 := label.new(
             right,
             entry,
             "Area Signal : " + str.tostring(entry, format.mintick),
             style = label.style_label_left,
             color = colArea,
             textcolor = color.white,
             size = size.small
         )

        lbA2 := label.new(
             right,
             e2,
             "Area Signal : " + str.tostring(e2, format.mintick),
             style = label.style_label_left,
             color = colArea,
             textcolor = color.white,
             size = size.small
         )

        lbTP1 := label.new(
             right,
             t1,
             "(1) Take Profit: " + str.tostring(t1, format.mintick),
             style = label.style_label_left,
             color = colTP,
             textcolor = color.white,
             size = size.small
         )

        lbTP2 := label.new(
             right,
             t2,
             "(2) Take Profit: " + str.tostring(t2, format.mintick),
             style = label.style_label_left,
             color = colTP,
             textcolor = color.white,
             size = size.small
         )

        lbTP3 := label.new(
             right,
             t3,
             "(3) Take Profit: " + str.tostring(t3, format.mintick),
             style = label.style_label_left,
             color = colTP,
             textcolor = color.white,
             size = size.small
         )

        lbTP4 := label.new(
             right,
             t4,
             "(4) Take Profit: " + str.tostring(t4, format.mintick),
             style = label.style_label_left,
             color = colTP,
             textcolor = color.white,
             size = size.small
         )

    alert(
         "KAI LINES BUY | Entry " +
         str.tostring(entry, format.mintick) +
         " | SL " +
         str.tostring(sl, format.mintick) +
         " | TP1 " +
         str.tostring(t1, format.mintick) +
         " | TP4 " +
         str.tostring(t4, format.mintick),
         alert.freq_once_per_bar
     )

// ============================ SELL SETUP =============================================================================
else if shortSetup

    f_clear()

    float entry = close

    float strisk = na(mUpLvl) ? atr * atrMult : math.max(mUpLvl - entry, syminfo.mintick)

    float risk = (useATR ? atr * atrMult : strisk) * (1 + slBufPerc / 100)

    float sl = entry + risk

    float e2 = entry + risk * entryDepth

    float t1 = entry - risk * rr1
    float t2 = entry - risk * rr2
    float t3 = entry - risk * rr3
    float t4 = entry - risk * rr4

    float band = risk * 0.04

    // Reward zone
    bxReward := box.new(
         bar_index,
         math.max(entry, t4),
         right,
         math.min(entry, t4),
         border_width = 0,
         bgcolor = color.new(colZone, 88)
     )

    // Entry zone
    bxEntry := box.new(
         bar_index,
         math.max(entry, e2),
         right,
         math.min(entry, e2),
         border_color = color.new(colArea, 40),
         bgcolor = color.new(colArea, 80),
         border_width = 1
     )

    // Stop loss zone
    bxSL := box.new(
         bar_index,
         sl + band,
         right,
         sl - band,
         border_width = 0,
         bgcolor = color.new(colSL, 70)
     )

    // Stop loss
    lnSL := line.new(
         bar_index,
         sl,
         right,
         sl,
         color = colSL,
         width = 2
     )

    // Entry 1
    lnE1 := line.new(
         bar_index,
         entry,
         right,
         entry,
         color = colArea,
         width = 1
     )

    // Entry 2
    lnE2 := line.new(
         bar_index,
         e2,
         right,
         e2,
         color = colArea,
         style = line.style_dotted
     )

    // TP1
    lnTP1 := line.new(
         bar_index,
         t1,
         right,
         t1,
         color = colTP,
         style = line.style_dashed
     )

    // TP2
    lnTP2 := line.new(
         bar_index,
         t2,
         right,
         t2,
         color = colTP,
         style = line.style_dashed
     )

    // TP3
    lnTP3 := line.new(
         bar_index,
         t3,
         right,
         t3,
         color = colTP,
         style = line.style_dashed
     )

    // TP4
    lnTP4 := line.new(
         bar_index,
         t4,
         right,
         t4,
         color = colTP,
         style = line.style_dashed
     )

    if showLabels

        lbSig := label.new(
             bar_index,
             sl + band,
             "Target Signal SELL",
             style = label.style_label_down,
             color = colSell,
             textcolor = color.white,
             size = size.small
         )

        lbSL := label.new(
             right,
             sl,
             "Stop Loss Price: " + str.tostring(sl, format.mintick),
             style = label.style_label_left,
             color = colSL,
             textcolor = color.white,
             size = size.small
         )

        lbA1 := label.new(
             right,
             entry,
             "Area Signal : " + str.tostring(entry, format.mintick),
             style = label.style_label_left,
             color = colArea,
             textcolor = color.white,
             size = size.small
         )

        lbA2 := label.new(
             right,
             e2,
             "Area Signal : " + str.tostring(e2, format.mintick),
             style = label.style_label_left,
             color = colArea,
             textcolor = color.white,
             size = size.small
         )

        lbTP1 := label.new(
             right,
             t1,
             "(1) Take Profit: " + str.tostring(t1, format.mintick),
             style = label.style_label_left,
             color = colTP,
             textcolor = color.white,
             size = size.small
         )

        lbTP2 := label.new(
             right,
             t2,
             "(2) Take Profit: " + str.tostring(t2, format.mintick),
             style = label.style_label_left,
             color = colTP,
             textcolor = color.white,
             size = size.small
         )

        lbTP3 := label.new(
             right,
             t3,
             "(3) Take Profit: " + str.tostring(t3, format.mintick),
             style = label.style_label_left,
             color = colTP,
             textcolor = color.white,
             size = size.small
         )

        lbTP4 := label.new(
             right,
             t4,
             "(4) Take Profit: " + str.tostring(t4, format.mintick),
             style = label.style_label_left,
             color = colTP,
             textcolor = color.white,
             size = size.small
         )

    alert(
         "KAI LINES SELL | Entry " +
         str.tostring(entry, format.mintick) +
         " | SL " +
         str.tostring(sl, format.mintick) +
         " | TP1 " +
         str.tostring(t1, format.mintick) +
         " | TP4 " +
         str.tostring(t4, format.mintick),
         alert.freq_once_per_bar
     )

// ============================ EXTEND ACTIVE PLAN =====================================================================
if barstate.islast and not na(bxReward)

    box.set_right(bxReward, right)

    box.set_right(bxEntry, right)

    box.set_right(bxSL, right)

// ============================ HISTORY MARKERS ========================================================================
plotshape(
     showMarkers and longSetup,
     title = "Buy",
     style = shape.labelup,
     location = location.belowbar,
     color = colBuy,
     text = "Buy",
     textcolor = color.white,
     size = size.tiny
 )

plotshape(
     showMarkers and shortSetup,
     title = "Sell",
     style = shape.labeldown,
     location = location.abovebar,
     color = colSell,
     text = "Sell",
     textcolor = color.white,
     size = size.tiny
 )

// ============================ ALERT CONDITIONS =======================================================================
alertcondition(
     longSetup,
     title = "KAI LINES Buy",
     message = "KAI LINES: BUY setup formed"
 )

alertcondition(
     shortSetup,
     title = "KAI LINES Sell",
     message = "KAI LINES: SELL setup formed"
 )

// ============================ TREND FUNCTIONS ========================================================================
f_trendTxt(int t) =>
    t == 1 ? "Bullish" : t == -1 ? "Bearish" : "—"

f_trendCol(int t) =>
    t == 1 ? colBuy : t == -1 ? colSell : color.gray

// ============================ TREND PANEL ============================================================================
var table tbl = na

if showTable and barstate.islast

    if not na(tbl)
        table.delete(tbl)

    tbl := table.new(
         position.top_right,
         2,
         3,
         border_width = 1,
         frame_color = color.new(color.gray, 50),
         frame_width = 1
     )

    table.cell(
         tbl,
         0,
         0,
         "KAI LINES",
         text_color = color.white,
         bgcolor = color.new(color.black, 0),
         text_size = size.small
     )

    table.cell(
         tbl,
         1,
         0,
         "",
         bgcolor = color.new(color.black, 0)
     )

    table.cell(
         tbl,
         0,
         1,
         "External",
         text_color = color.white,
         bgcolor = color.new(color.gray, 70),
         text_size = size.small
     )

    table.cell(
         tbl,
         1,
         1,
         f_trendTxt(mTrend),
         text_color = color.white,
         bgcolor = color.new(f_trendCol(mTrend), 30),
         text_size = size.small
     )

    table.cell(
         tbl,
         0,
         2,
         "Internal",
         text_color = color.white,
         bgcolor = color.new(color.gray, 70),
         text_size = size.small
     )

    table.cell(
         tbl,
         1,
         2,
         f_trendTxt(iTrend),
         text_color = color.white,
         bgcolor = color.new(f_trendCol(iTrend), 30),
         text_size = size.small
     )
````
