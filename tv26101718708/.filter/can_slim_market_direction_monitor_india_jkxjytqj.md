# CAN SLIM Market Direction Monitor (India)

- url: https://www.tradingview.com/script/jKXJytQj-CAN-SLIM-Market-Direction-Monitor-India/
- type: indicator
- pine_id: PUB;66a15aa154c349e183785c2f2aeabd8b
- version: 1.0

## Description

How to use it

Open TradingView → load NSE:NIFTY on Daily timeframe.
Pine Editor (bottom panel) → paste contents → Save → Add to chart.
Cross-check on BSE:SENSEX and your sectoral indices.

What it computes

Distribution Days — full (≥0.2% down on rising vol) and stalling (0.5x weight). Auto-expires after 25 sessions or on a 5% rally from the DD's intraday low.
Follow-Through Day — Day 4–13 of a rally attempt with ≥1.5% gain on rising volume.
Phase — Green / Yellow / Red driven by DD count and price-vs-MA structure (the framework's logic, not just one trigger).
Weinstein Stage — 1–4 from the 30-week SMA and its slope.
Dashboard — phase, DD count, % vs 50/200 DMA, drawdown from 60-day high, MA structure, stage, rally-day counter, and posture text.
Alerts — DD, stalling, FTD, and zone transitions.

Caveats to keep in mind

DD logic requires volume. Some sectoral indices on TradingView lack volume — the script flags this on-chart. Use NSE:NIFTY as the primary tape.
Breadth metrics (% of Nifty 500 above 50/200-DMA) and FII/DII flows aren't in Pine's data — those still need to be brought in manually per the project's output protocol.
FTD detection is mechanical; always confirm the rally context (genuine correction preceding it) before treating the signal as actionable.

## Source Code

````pine
//@version=5
// =============================================================================
// CAN SLIM Market Direction Monitor — Indian Equities (NSE / BSE)
// =============================================================================
// Implements:
//   • William J. O'Neil's CAN SLIM "M" framework
//       - Distribution day counting (25-session window, 5% rally reset)
//       - Stalling day detection (0.5x weight)
//       - Follow-Through Day detection (Day 4–13 of rally attempt)
//   • Stan Weinstein's Stage Analysis (Stages 1–4 via 30-week SMA)
//   • Three-zone phase classification: GREEN / YELLOW / RED
//
// Apply primarily to: NSE:NIFTY (Nifty 50) and BSE:SENSEX
// Sectoral usage   : NSE:CNXIT, NSE:BANKNIFTY, NSE:CNXAUTO, NSE:CNXFMCG,
//                    NSE:CNXPHARMA, NSE:CNXMETAL, NSE:CNXREALTY,
//                    NSE:CNXPSUBANK, NSE:CNXENERGY, NSE:CNXINFRA, NSE:CNXFIN
//
// IMPORTANT: Distribution day logic requires volume. Some sectoral indices on
//            TradingView lack volume — the script will flag this on the chart.
// =============================================================================

indicator(
     title             = "CAN SLIM Market Direction Monitor (India)",
     shorttitle        = "CANSLIM-M",
     overlay           = true,
     max_labels_count  = 500,
     max_lines_count   = 100)

// =============================================================================
// INPUTS
// =============================================================================
var grpDD = "📉 Distribution Day Settings"
ddLookback   = input.int  (25,   "Lookback (sessions)",          minval=10, maxval=50, group=grpDD,
     tooltip="Distribution days expire after this many sessions")
ddThreshold  = input.float(-0.2, "% Threshold (≤, negative)",    maxval=0,  step=0.05, group=grpDD,
     tooltip="Index must close DOWN by ≥ this % on higher volume")
ddResetPct   = input.float(5.0,  "Reset Rally % from DD low",    minval=1.0, step=0.5, group=grpDD,
     tooltip="DD removed if index rallies ≥ this % from its intraday low")
stallingOn   = input.bool (true, "Count Stalling Days (0.5x weight)", group=grpDD)

var grpFTD = "🚀 Follow-Through Day Settings"
ftdMinGain   = input.float(1.5,  "Min Gain %",            minval=0.5, step=0.1, group=grpFTD)
ftdMinDay    = input.int  (4,    "Min Day of Rally Attempt", minval=1, group=grpFTD)
ftdMaxDay    = input.int  (13,   "Max Day of Rally Attempt", minval=5, group=grpFTD)

var grpPhase = "🎯 Phase Thresholds"
yellowMin    = input.float(3.0,  "Yellow Zone min DD count", minval=1.0, step=0.5, group=grpPhase)
redMin       = input.float(6.0,  "Red Zone min DD count",    minval=3.0, step=0.5, group=grpPhase)

var grpDisp = "🎨 Display"
showTable    = input.bool  (true,        "Show Dashboard Table", group=grpDisp)
tablePos     = input.string("top_right", "Table Position",
     options=["top_left","top_right","middle_left","middle_right","bottom_left","bottom_right"],
     group=grpDisp)
showLabels   = input.bool(true, "Show DD / FTD labels on chart", group=grpDisp)
showMA50     = input.bool(true, "Plot 50 DMA",                   group=grpDisp)
showMA200    = input.bool(true, "Plot 200 DMA",                  group=grpDisp)
showMA30W    = input.bool(true, "Plot 30-week MA (Weinstein)",   group=grpDisp)
colorBg      = input.bool(true, "Color background by phase",     group=grpDisp)
showLevels   = input.bool(true, "Show 60-day high / low",        group=grpDisp)

// =============================================================================
// MOVING AVERAGES
// =============================================================================
ma50  = ta.sma(close, 50)
ma200 = ta.sma(close, 200)
ma30w = ta.sma(close, 150)   // ≈ 30 weeks × 5 trading days

ma50RisingFlag  = ma50  > ma50[5]
ma200RisingFlag = ma200 > ma200[20]
ma30wRising     = ma30w > ma30w[10]

plot(showMA50  ? ma50  : na, "50 DMA",  color=color.new(color.blue,   0), linewidth=2)
plot(showMA200 ? ma200 : na, "200 DMA", color=color.new(color.red,    0), linewidth=2)
plot(showMA30W ? ma30w : na, "30W MA",  color=color.new(color.orange, 0), linewidth=2)

// =============================================================================
// DAILY METRICS
// =============================================================================
pctChg   = (close - close[1]) / close[1] * 100
volUp    = volume > volume[1]
midRange = (high + low) / 2

// =============================================================================
// DISTRIBUTION DAY DETECTION
// =============================================================================
isDD       = pctChg <= ddThreshold and volUp
isStalling = stallingOn and pctChg > 0 and pctChg < 0.2 and volUp and close < midRange

var int[]   ddBars    = array.new_int()
var float[] ddLows    = array.new_float()
var float[] ddWeights = array.new_float()

if isDD
    array.push(ddBars,    bar_index)
    array.push(ddLows,    low)
    array.push(ddWeights, 1.0)
else if isStalling
    array.push(ddBars,    bar_index)
    array.push(ddLows,    low)
    array.push(ddWeights, 0.5)

// Cleanup: expired (>25 sessions) or rallied-out (≥5% from intraday low)
// Iterate in reverse using while loop for safe removal
if array.size(ddBars) > 0
    i = array.size(ddBars) - 1
    while i >= 0
        ddBar    = array.get(ddBars, i)
        ddLow    = array.get(ddLows, i)
        expired  = (bar_index - ddBar) > ddLookback
        rallied  = bar_index > ddBar and high >= ddLow * (1 + ddResetPct / 100)
        if expired or rallied
            array.remove(ddBars,    i)
            array.remove(ddLows,    i)
            array.remove(ddWeights, i)
        i -= 1

ddCount     = 0.0
ddCountFull = 0
if array.size(ddWeights) > 0
    for j = 0 to array.size(ddWeights) - 1
        w = array.get(ddWeights, j)
        ddCount += w
        if w >= 1.0
            ddCountFull += 1

// =============================================================================
// FOLLOW-THROUGH DAY (rally-attempt tracking)
// =============================================================================
var int   rallyDay      = 0
var float rallyLowPrice = na
var int   rallyLowBar   = na

nearHigh = ta.highest(high, 50)
inCorr   = close < ma50 or close < nearHigh * 0.95

// Track the rally low only while market is in correction
if inCorr and (na(rallyLowPrice) or low < rallyLowPrice)
    rallyLowPrice := low
    rallyLowBar   := bar_index
    rallyDay      := 0

// Day 1: first up close after the rally low
if rallyDay == 0 and not na(rallyLowPrice) and bar_index > rallyLowBar and close > close[1]
    rallyDay := 1
else if rallyDay >= 1
    if low < rallyLowPrice
        rallyLowPrice := low
        rallyLowBar   := bar_index
        rallyDay      := 0
    else
        rallyDay += 1

// Reset stale rally state
if rallyDay > ftdMaxDay + 5
    rallyDay      := 0
    rallyLowPrice := na

isFTD = rallyDay >= ftdMinDay and rallyDay <= ftdMaxDay and pctChg >= ftdMinGain and volUp

// =============================================================================
// PHASE CLASSIFICATION (Green / Yellow / Red)
// =============================================================================
priceAbove50  = close > ma50
priceAbove200 = close > ma200
goldenCross   = ma50  > ma200

string phase = "GREEN"
if ddCount >= redMin
    phase := "RED"
else if not priceAbove200 and not ma200RisingFlag
    phase := "RED"
else if ddCount >= yellowMin
    phase := "YELLOW"
else if not priceAbove50
    phase := "YELLOW"
else if priceAbove50 and not priceAbove200
    phase := "YELLOW"

phaseCode  = phase == "GREEN" ? 1 : phase == "YELLOW" ? 2 : 3
phaseColor = phase == "GREEN"  ? color.new(color.green,  88) :
             phase == "YELLOW" ? color.new(color.yellow, 85) :
                                 color.new(color.red,    87)

bgcolor(colorBg ? phaseColor : na, title="Phase Background")

// =============================================================================
// WEINSTEIN STAGE ANALYSIS
// =============================================================================
priceVs30w = close > ma30w

string stage = "Stage 1 (Basing)"
if priceVs30w and ma30wRising
    stage := "Stage 2 (Advancing)"
else if priceVs30w and not ma30wRising
    stage := "Stage 3 (Topping)"
else if not priceVs30w and not ma30wRising
    stage := "Stage 4 (Declining)"

// =============================================================================
// ACTIONABLE POSTURE
// =============================================================================
string posture = "Full exposure permitted. Buy proper bases. Pyramid into strength."
if phase == "YELLOW"
    posture := "Tighten stops to 5–7%. Halve new positions. Harvest extended winners."
else if phase == "RED"
    posture := "Raise cash to 50–100%. Honor every stop. Wait for FTD before re-entry."

// =============================================================================
// LABELS ON CHART
// =============================================================================
if showLabels and isDD
    label.new(bar_index, low, "D",
         color=color.new(color.red, 20), textcolor=color.white,
         style=label.style_label_up, size=size.tiny)

if showLabels and isStalling
    label.new(bar_index, low, "s",
         color=color.new(color.orange, 30), textcolor=color.white,
         style=label.style_label_up, size=size.tiny)

if showLabels and isFTD
    label.new(bar_index, high,
         "FTD ✓\nDay " + str.tostring(rallyDay) + "  +" + str.tostring(pctChg, "#.##") + "%",
         color=color.new(color.green, 15), textcolor=color.white,
         style=label.style_label_down, size=size.normal)

// =============================================================================
// SUPPORT / RESISTANCE OVERLAYS
// =============================================================================
hi60 = ta.highest(high, 60)
lo60 = ta.lowest (low,  60)
plot(showLevels ? hi60 : na, "60-day High", color=color.new(color.green, 60), style=plot.style_circles)
plot(showLevels ? lo60 : na, "60-day Low",  color=color.new(color.red,   60), style=plot.style_circles)

// =============================================================================
// VOLUME-MISSING WARNING
// =============================================================================
volMissing = ta.cum(volume) == 0
if volMissing and barstate.islast
    label.new(bar_index, high,
         "⚠ No volume on this symbol\nDD logic disabled — apply to NSE:NIFTY",
         color=color.new(color.red, 0), textcolor=color.white,
         style=label.style_label_down, size=size.normal)

// =============================================================================
// DASHBOARD TABLE
// =============================================================================
posMap = tablePos == "top_left"      ? position.top_left      :
         tablePos == "top_right"     ? position.top_right     :
         tablePos == "middle_left"   ? position.middle_left   :
         tablePos == "middle_right"  ? position.middle_right  :
         tablePos == "bottom_left"   ? position.bottom_left   :
                                       position.bottom_right

var table dash = table.new(posMap, 2, 14, border_width=1, border_color=color.gray)

if showTable and barstate.islast
    bgPhase  = phase == "GREEN"  ? color.green  :
               phase == "YELLOW" ? color.yellow : color.red
    txtPhase = phase == "YELLOW" ? color.black  : color.white

    drawdown   = (close - hi60) / hi60 * 100
    pctFrom50  = (close - ma50)  / ma50  * 100
    pctFrom200 = (close - ma200) / ma200 * 100

    table.cell(dash, 0, 0, "🎯 MARKET DIRECTION",
         bgcolor=color.new(color.gray, 20), text_color=color.white, text_size=size.normal)
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "Symbol",
         text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(dash, 1, 1, syminfo.ticker,
         text_color=color.white, bgcolor=color.new(color.gray, 70))

    table.cell(dash, 0, 2, "Phase",
         text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(dash, 1, 2, phase,
         text_color=txtPhase, bgcolor=bgPhase, text_size=size.normal)

    table.cell(dash, 0, 3, "DD Count (25d)",
         text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(dash, 1, 3,
         str.tostring(ddCount, "#.#") + "  (" + str.tostring(ddCountFull) + " full)",
         text_color=color.white, bgcolor=color.new(color.gray, 70))

    todayStr = isDD       ? "❌ Distribution Day" :
               isStalling ? "⚠ Stalling Day"      :
               isFTD      ? "✅ Follow-Through Day" :
               pctChg >= 0 ? "Up "   + str.tostring(pctChg, "#.##") + "%"
                           : "Down " + str.tostring(pctChg, "#.##") + "%"
    todayCol = isDD ? color.red : isStalling ? color.orange :
               isFTD ? color.green : color.gray
    table.cell(dash, 0, 4, "Today",
         text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(dash, 1, 4, todayStr,
         text_color=color.white, bgcolor=color.new(todayCol, 50))

    table.cell(dash, 0, 5, "vs 50 DMA",
         text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(dash, 1, 5, str.tostring(pctFrom50, "+#.##;-#.##") + "%",
         text_color=color.white,
         bgcolor=color.new(priceAbove50 ? color.green : color.red, 60))

    table.cell(dash, 0, 6, "vs 200 DMA",
         text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(dash, 1, 6, str.tostring(pctFrom200, "+#.##;-#.##") + "%",
         text_color=color.white,
         bgcolor=color.new(priceAbove200 ? color.green : color.red, 60))

    table.cell(dash, 0, 7, "From 60d High",
         text_color=color.white, bgcolor=color.new(color.gray, 70))
    ddColor = drawdown > -3 ? color.green :
              drawdown > -10 ? color.yellow : color.red
    table.cell(dash, 1, 7, str.tostring(drawdown, "+#.##;-#.##") + "%",
         text_color=color.white, bgcolor=color.new(ddColor, 60))

    table.cell(dash, 0, 8, "MA Structure",
         text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(dash, 1, 8, goldenCross ? "Golden Cross ✓" : "Death Cross ✗",
         text_color=color.white,
         bgcolor=color.new(goldenCross ? color.green : color.red, 60))

    stageCol = stage == "Stage 2 (Advancing)" ? color.green :
               stage == "Stage 1 (Basing)"    ? color.blue  :
               stage == "Stage 3 (Topping)"   ? color.orange : color.red
    table.cell(dash, 0, 9, "Weinstein Stage",
         text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(dash, 1, 9, stage,
         text_color=color.white, bgcolor=color.new(stageCol, 50))

    rallyStr = rallyDay > 0
         ? "Day " + str.tostring(rallyDay) +
           (rallyDay >= ftdMinDay and rallyDay <= ftdMaxDay ? " (FTD window)" : "")
         : "—"
    table.cell(dash, 0, 10, "Rally Attempt",
         text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(dash, 1, 10, rallyStr,
         text_color=color.white, bgcolor=color.new(color.gray, 70))

    table.cell(dash, 0, 11, "Posture",
         text_color=color.white, bgcolor=color.new(color.gray, 50))
    table.cell(dash, 1, 11, posture,
         text_color=color.white, bgcolor=color.new(bgPhase, 70), text_size=size.small)

    table.cell(dash, 0, 12, "Updated",
         text_color=color.gray, bgcolor=color.new(color.gray, 80), text_size=size.tiny)
    table.cell(dash, 1, 12, str.format_time(time, "yyyy-MM-dd"),
         text_color=color.gray, bgcolor=color.new(color.gray, 80), text_size=size.tiny)

// =============================================================================
// ALERTS  (Create Alert → Condition: this script → choose one)
// =============================================================================
alertcondition(isDD,
     title   = "Distribution Day",
     message = "❌ Distribution Day on {{ticker}} — DD count rising")

alertcondition(isStalling,
     title   = "Stalling Day",
     message = "⚠ Stalling Day on {{ticker}} — institutional hesitation")

alertcondition(isFTD,
     title   = "Follow-Through Day",
     message = "✅ Follow-Through Day on {{ticker}} — potential new uptrend")

alertcondition(phaseCode == 3 and phaseCode[1] != 3,
     title   = "Entered RED Zone",
     message = "🔴 {{ticker}} entered RED Zone — raise cash, honor stops")

alertcondition(phaseCode == 2 and phaseCode[1] == 1,
     title   = "Entered YELLOW Zone",
     message = "🟡 {{ticker}} entered YELLOW Zone — tighten stops, halve new buys")

alertcondition(phaseCode == 1 and phaseCode[1] != 1,
     title   = "Entered GREEN Zone",
     message = "🟢 {{ticker}} entered GREEN Zone — confirmed uptrend")

alertcondition(ddCount >= redMin and ddCount[1] < redMin,
     title   = "DD Threshold Breach (RED)",
     message = "⚠ DD count breached RED threshold on {{ticker}}")
````
