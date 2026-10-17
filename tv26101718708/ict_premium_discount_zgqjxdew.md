# ICT Premium Discount

- url: https://www.tradingview.com/script/ZgQJXdEw-ICT-Premium-Discount/
- type: indicator
- pine_id: PUB;8285432e8b1e49c59d91bc9c7db696ce
- version: 1.0

## Description

[b]OVERVIEW[/b]

ICT Premium Discount splits the current swing range into two halves around its midpoint. The half above the midpoint is premium and the half below it is discount. It also draws the optimal trade entry zone, a retracement band between two chosen levels, and a set of Fibonacci levels across the range. A small table shows where the latest close sits.


[b]HOW IT WORKS[/b]

The indicator finds swings and tracks the market bias from breaks of structure and changes of character. The range follows the bias. In a bullish bias, the range top is refreshed by each new swing high, and the range bottom moves only when a lower low appears. In a bearish bias, it is the mirror. Without a bias, both ends follow the latest swing. The midpoint of the range is the equilibrium. Price above it is in premium and price below it is in discount. The optimal trade entry zone is a band between two retracement levels, with a sweet spot line between them. Fibonacci level lines are drawn across the range. Two alerts fire while price is inside the zone.


[image]KaLkQcOc[/image]
[i]The swing range split at its midpoint, with the OTE band and the Fibonacci levels, on a 4h Bitcoin chart.[/i]


[b]WHAT YOU'LL SEE ON THE CHART[/b]

[list]
[*][b]Premium and discount zones[/b] — two shaded halves of the range around an equilibrium line, the discount half in the bullish colour and the premium half in the bearish colour.
[*][b]OTE zone[/b] — a shaded band in the accent colour between the two retracement levels, with a line at the sweet spot.
[*][b]Fibonacci levels[/b] — horizontal lines across the range, those inside the OTE band emphasised.
[*][b]Dashboard[/b] — a small table with the zone price is in and its position in the range.
[/list]

[image]pRSR9Q19[/image]
[i]The same indicator on a daily Bitcoin chart, where the range is measured from larger swings.[/i]


[b]BEST FOR[/b]

This indicator draws and labels price structure rather than reporting a single event type, so no market or timeframe group is singled out. It was not measured, and it reads the candles of whatever chart it is placed on.


[b]ALERTS[/b]

[list]
[*]Price In Bullish OTE
[*]Price In Bearish OTE
[/list]


[b]LIMITATIONS[/b]

The script reads the candles of the chart it is placed on, so results on non-standard chart types differ from results on regular candles. Swing points are known only after the chosen number of bars has passed, so swing-based items appear with that delay. It is a drawing and labelling tool, not a forecast. It is weaker in these situations:

[list]
[*]Choppy markets, where the range changes often
[*]Early in a chart, before swings and bias are established
[*]Reading the Fibonacci lines and the OTE band together in a bullish range, since they are measured from different ends
[*]Intrabar use, since a zone alert can disappear before the bar closes
[/list]


[b]OPEN SOURCE[/b]

The source code is open. This script is one module of the author's own larger ICT toolkit, published here on its own so it can be read, checked and reused under the Mozilla Public License 2.0.


[b]ACCESS[/b]

Free, open-source script.


[b]DISCLAIMER[/b]

[i]This indicator is a technical analysis tool, not investment advice. The author is not a registered investment adviser, broker or dealer. Nothing here is a recommendation to buy, sell or hold any instrument. What you see on the chart is the output of a calculation you configured. Any decision you take from it is yours. Past behaviour of an indicator — including anything you observe in historical bars or in a backtest, which is a simulation — does not indicate future results. Trading carries a real risk of loss, including your entire capital. Charting uses TradingView® technology. TradingView is unaffiliated with the author. For educational purposes only. Not investment advice.[/i]

## Source Code

````pine
// Split from the author's own "ICT Smart Money Toolkit" (all modules in one script).
// ═══════════════════════════════════════════════════════════════
//  ICT Premium Discount
//  v1.0.0 · 2026-10-05
//  Open source, Mozilla Public License 2.0
//
//  Measures : Where price sits inside the current swing range: premium or
//             discount half, the equilibrium and the OTE retracement zone.
//  Not      : This is not investment advice.
// ═══════════════════════════════════════════════════════════════
//@version=6
indicator("ICT Premium Discount", shorttitle="ICT PD", overlay=true, behind_chart=false, max_bars_back=300, max_lines_count=500, max_boxes_count=500, max_labels_count=500)
// max_bars_back=300 — Pine's own default; deepest explicit history: one bar back; the swing size is handled by ta.pivothigh / ta.pivotlow.
// max_lines_count / max_boxes_count / max_labels_count declared because this script draws line, box, label objects; the source declared 500 for all three.

// ── THEME ─────────────────────────────────────────────────────
// [§3.1] design tokens — do not edit per-indicator.
C_UP       = #26A69A
C_DOWN     = #EF5350
C_NEUTRAL  = #787B86
C_ACCENT   = #F0B90B
C_INFO     = #2962FF
C_TEXT     = #D1D4DC
C_TEXT_DIM = #787B86
C_BG       = #131722
C_BORDER   = #2A2E39

// ── INPUTS ────────────────────────────────────────────────────
// [§4.1] Group names and their order are fixed. Unused groups are omitted.
G_CORE    = "◆━━━━━━━ Calculation ━━━━━━━◆"
G_VISUAL  = "◆━━━━━━━ Appearance ━━━━━━━◆"
G_TABLE   = "◆━━━━━━━ Dashboard ━━━━━━━◆"

i_oteFibHigh     = input.float(0.786, "OTE Upper Fib", minval = 0.5, maxval = 1.0, step = 0.01, group = G_CORE, tooltip = "Deeper retracement limit of the OTE zone.")
i_oteFibMid      = input.float(0.705, "OTE Sweet Spot", minval = 0.5, maxval = 1.0, step = 0.005, group = G_CORE, tooltip = "Midline of the OTE zone.")
i_oteFibLow      = input.float(0.618, "OTE Lower Fib", minval = 0.5, maxval = 1.0, step = 0.01, group = G_CORE, tooltip = "Shallower retracement limit of the OTE zone.")
i_swingLen       = input.int(5, "Swing Sensitivity", minval = 2, maxval = 50, group = G_CORE, tooltip = "Bars required on each side of a pivot for it to count as a swing. Only the structure used by this indicator reads it.")
i_showPDZone     = input.bool(true, "Show Premium/Discount Zone", group = G_VISUAL, tooltip = "Draws the premium and discount halves of the current range with the equilibrium line.")
i_showOTE        = input.bool(true, "Show OTE Zone", group = G_VISUAL, tooltip = "Draws the optimal trade entry zone between the two retracement levels.")
i_showFibLevels  = input.bool(true, "Show Fibonacci Levels", group = G_VISUAL, tooltip = "Draws the retracement levels 0, 0.236, 0.382, 0.5, 0.618, 0.705, 0.786 and 1 across the range.")

i_colUp     = input.color(C_UP, "Bullish Color", group = G_VISUAL, tooltip = "Colour of the discount half of the range.")
i_colDown   = input.color(C_DOWN, "Bearish Color", group = G_VISUAL, tooltip = "Colour of the premium half of the range.")
i_colAccent = input.color(C_ACCENT, "Accent Color", group = G_VISUAL, tooltip = "Colour of the OTE zone and the Fibonacci levels inside it.")

i_showTable      = input.bool(true, "Show Dashboard", group = G_TABLE, tooltip = "Shows the summary table on the chart.")
i_tablePos       = input.string("Top Right", "Dashboard Position", options = ["Top Left", "Bottom Left", "Top Right", "Bottom Right"], group = G_TABLE, tooltip = "Corner of the chart where the dashboard is placed.")

// ── CALC ──────────────────────────────────────────────────────
f_getPosition(posStr) =>
    switch posStr
        "Top Left" => position.top_left
        "Bottom Left" => position.bottom_left
        "Top Right" => position.top_right
        "Bottom Right" => position.bottom_right

// Swing pivots. A pivot is known i_swingLen bars after it formed.
pivotHigh    = ta.pivothigh(high, i_swingLen, i_swingLen)
pivotLow     = ta.pivotlow(low, i_swingLen, i_swingLen)
pivotHighBar = bar_index - i_swingLen
pivotLowBar  = bar_index - i_swingLen

// ── STATE / SIGNAL ────────────────────────────────────────────
// Signals are evaluated on every tick, as in the source script; they are not gated with barstate.isconfirmed.
// An intrabar event can therefore appear and disappear on the open bar. See the notes in identity.yaml.

// ── swing state ──
var float s_lastSwingHigh     = na
var int   s_lastSwingHighBar  = na
var float s_lastSwingLow      = na
var int   s_lastSwingLowBar   = na
var float s_prevSwingHigh     = na
var int   s_prevSwingHighBar  = na
var float s_prevSwingLow      = na
var int   s_prevSwingLowBar   = na
var string s_lastHighType     = ""    // HH or LH
var string s_lastLowType      = ""    // HL or LL
var int   s_lastSwingType     = 0     // 1 = last swing was a high, -1 = a low (swings alternate)

// Alternating swings: two highs in a row update the earlier one instead of creating a new swing.
bool swingHighConfirmed = false
bool swingLowConfirmed  = false

if not na(pivotHigh)
    if s_lastSwingType == 1
        highType = na(s_prevSwingHigh) ? "HH" : (pivotHigh > s_prevSwingHigh ? "HH" : "LH")
        s_lastSwingHigh    := pivotHigh
        s_lastSwingHighBar := pivotHighBar
        s_lastHighType     := highType
        swingHighConfirmed := true
    else
        highType = na(s_lastSwingHigh) ? "HH" : (pivotHigh > s_lastSwingHigh ? "HH" : "LH")
        s_prevSwingHigh    := s_lastSwingHigh
        s_prevSwingHighBar := s_lastSwingHighBar
        s_lastSwingHigh    := pivotHigh
        s_lastSwingHighBar := pivotHighBar
        s_lastHighType     := highType
        s_lastSwingType    := 1
        swingHighConfirmed := true

if not na(pivotLow)
    if s_lastSwingType == -1
        lowType = na(s_prevSwingLow) ? "HL" : (pivotLow > s_prevSwingLow ? "HL" : "LL")
        s_lastSwingLow    := pivotLow
        s_lastSwingLowBar := pivotLowBar
        s_lastLowType     := lowType
        swingLowConfirmed := true
    else
        lowType = na(s_lastSwingLow) ? "HL" : (pivotLow > s_lastSwingLow ? "HL" : "LL")
        s_prevSwingLow    := s_lastSwingLow
        s_prevSwingLowBar := s_lastSwingLowBar
        s_lastSwingLow    := pivotLow
        s_lastSwingLowBar := pivotLowBar
        s_lastLowType     := lowType
        s_lastSwingType   := -1
        swingLowConfirmed := true

// ── BOS / CHoCH ──
// Market bias: 1 bullish, -1 bearish, 0 undefined. A close through the last swing is a BOS when it
// follows the bias and a CHoCH when it goes against it. A swing level can only be broken once.
var int   s_marketBias     = 0
var bool  s_bosUp          = false
var bool  s_bosDn          = false
var bool  s_chochUp        = false
var bool  s_chochDn        = false
var float s_lastBrokenHigh = na
var float s_lastBrokenLow  = na

s_bosUp   := false
s_bosDn   := false
s_chochUp := false
s_chochDn := false

bullBreak = not na(s_lastSwingHigh) and (na(s_lastBrokenHigh) or s_lastSwingHigh != s_lastBrokenHigh) and close > s_lastSwingHigh and close[1] <= s_lastSwingHigh

if bullBreak
    if s_marketBias == 1 or s_marketBias == 0
        s_bosUp := true
        s_marketBias := 1
    else
        s_chochUp := true
        s_marketBias := 1
    s_lastBrokenHigh := s_lastSwingHigh

bearBreak = not na(s_lastSwingLow) and (na(s_lastBrokenLow) or s_lastSwingLow != s_lastBrokenLow) and close < s_lastSwingLow and close[1] >= s_lastSwingLow and not bullBreak

if bearBreak
    if s_marketBias == -1 or s_marketBias == 0
        s_bosDn := true
        s_marketBias := -1
    else
        s_chochDn := true
        s_marketBias := -1
    s_lastBrokenLow := s_lastSwingLow

// ── premium / discount range and OTE levels ──
// Range follows the bias: with a bullish bias the high is refreshed by every new swing high and the low only moves
// when a lower low appears; with a bearish bias it is mirrored; with no bias both follow the latest swing.
var float s_pdHigh = na
var float s_pdLow  = na
var int   s_pdDir  = 0

if swingHighConfirmed
    if s_marketBias == 1
        s_pdHigh := s_lastSwingHigh
    else if s_marketBias == -1
        if na(s_pdHigh) or s_lastSwingHigh > s_pdHigh
            s_pdHigh := s_lastSwingHigh
    else
        s_pdHigh := s_lastSwingHigh
    s_pdDir := 1

if swingLowConfirmed
    if s_marketBias == -1
        s_pdLow := s_lastSwingLow
    else if s_marketBias == 1
        if na(s_pdLow) or s_lastSwingLow < s_pdLow
            s_pdLow := s_lastSwingLow
    else
        s_pdLow := s_lastSwingLow
    s_pdDir := -1

pdValid = not na(s_pdHigh) and not na(s_pdLow) and s_pdHigh > s_pdLow
pdRange = pdValid ? s_pdHigh - s_pdLow : na
pdEQ    = pdValid ? s_pdLow + pdRange * 0.5 : na

inPremium  = pdValid and close > pdEQ
inDiscount = pdValid and close < pdEQ

// Bearish OTE is measured up from the low, bullish OTE down from the high.
oteTopBear    = pdValid ? s_pdLow + pdRange * i_oteFibHigh : na
oteMidBear    = pdValid ? s_pdLow + pdRange * i_oteFibMid  : na
oteBottomBear = pdValid ? s_pdLow + pdRange * i_oteFibLow  : na

oteTopBull    = pdValid ? s_pdHigh - pdRange * i_oteFibLow  : na
oteMidBull    = pdValid ? s_pdHigh - pdRange * i_oteFibMid  : na
oteBottomBull = pdValid ? s_pdHigh - pdRange * i_oteFibHigh : na

inBullOTE = pdValid and s_marketBias == 1 and close >= oteBottomBull and close <= oteTopBull and inDiscount
inBearOTE = pdValid and s_marketBias == -1 and close >= oteBottomBear and close <= oteTopBear and inPremium

// ── PLOT ──────────────────────────────────────────────────────
// Premium / discount range, OTE band and Fibonacci levels. The range and OTE objects are redrawn from scratch
// on every update and only the last drawing survives, so they are built on the last bar only.
var box   s_pdPremiumBox  = na
var box   s_pdDiscountBox = na
var line  s_pdLineHigh    = na
var line  s_pdLineEQ      = na
var line  s_pdLineLow     = na
var label s_pdLblHigh     = na
var label s_pdLblEQ       = na
var label s_pdLblLow      = na

if barstate.islast and i_showPDZone and pdValid
    box.delete(s_pdPremiumBox)
    box.delete(s_pdDiscountBox)
    line.delete(s_pdLineHigh)
    line.delete(s_pdLineEQ)
    line.delete(s_pdLineLow)
    label.delete(s_pdLblHigh)
    label.delete(s_pdLblEQ)
    label.delete(s_pdLblLow)

    int pdLeft  = bar_index - 3
    int pdRight = bar_index + 20

    s_pdPremiumBox  := box.new(pdLeft, s_pdHigh, pdRight, pdEQ, bgcolor = color.new(i_colDown, 92), border_color = color.new(i_colDown, 100), border_width = 0)
    s_pdDiscountBox := box.new(pdLeft, pdEQ, pdRight, s_pdLow, bgcolor = color.new(i_colUp, 92), border_color = color.new(i_colUp, 100), border_width = 0)

    s_pdLineHigh := line.new(pdLeft, s_pdHigh, pdRight, s_pdHigh, color = color.new(C_NEUTRAL, 30), style = line.style_solid, width = 1)
    s_pdLineEQ   := line.new(pdLeft, pdEQ, pdRight, pdEQ, color = C_NEUTRAL, style = line.style_dashed, width = 2)
    s_pdLineLow  := line.new(pdLeft, s_pdLow, pdRight, s_pdLow, color = color.new(C_NEUTRAL, 30), style = line.style_solid, width = 1)

    s_pdLblHigh := label.new(pdRight + 1, s_pdHigh, "0 (" + str.tostring(s_pdHigh, format.mintick) + ")", style = label.style_label_left, color = color.new(C_BG, 100), textcolor = color.new(C_NEUTRAL, 30), size = size.tiny)
    s_pdLblEQ   := label.new(pdRight + 1, pdEQ, "0.5 (" + str.tostring(pdEQ, format.mintick) + ")", style = label.style_label_left, color = color.new(C_BG, 100), textcolor = C_NEUTRAL, size = size.tiny)
    s_pdLblLow  := label.new(pdRight + 1, s_pdLow, "1 (" + str.tostring(s_pdLow, format.mintick) + ")", style = label.style_label_left, color = color.new(C_BG, 100), textcolor = color.new(C_NEUTRAL, 30), size = size.tiny)

var box   s_oteBox     = na
var line  s_oteLineTop = na
var line  s_oteLineMid = na
var line  s_oteLineBot = na
var label s_oteLblTop  = na
var label s_oteLblMid  = na
var label s_oteLblBot  = na

if barstate.islast and i_showOTE and pdValid
    box.delete(s_oteBox)
    line.delete(s_oteLineTop)
    line.delete(s_oteLineMid)
    line.delete(s_oteLineBot)
    label.delete(s_oteLblTop)
    label.delete(s_oteLblMid)
    label.delete(s_oteLblBot)

    float oteT = na
    float oteM = na
    float oteB = na

    if s_marketBias == 1
        oteT := oteTopBull
        oteM := oteMidBull
        oteB := oteBottomBull
    else if s_marketBias == -1
        oteT := oteTopBear
        oteM := oteMidBear
        oteB := oteBottomBear

    if not na(oteT)
        s_oteBox := box.new(bar_index - 3, oteT, bar_index + 15, oteB, bgcolor = color.new(i_colAccent, 85), border_color = color.new(i_colAccent, 100), border_width = 0)

        s_oteLineTop := line.new(bar_index - 3, oteT, bar_index + 15, oteT, color = color.new(i_colAccent, 15), style = line.style_solid, width = 1)
        s_oteLineMid := line.new(bar_index - 3, oteM, bar_index + 15, oteM, color = i_colAccent, style = line.style_dashed, width = 2)
        s_oteLineBot := line.new(bar_index - 3, oteB, bar_index + 15, oteB, color = color.new(i_colAccent, 15), style = line.style_solid, width = 1)

        string fibTopStr = s_marketBias == 1 ? str.tostring(i_oteFibLow) : str.tostring(i_oteFibHigh)
        string fibBotStr = s_marketBias == 1 ? str.tostring(i_oteFibHigh) : str.tostring(i_oteFibLow)

        s_oteLblTop := label.new(bar_index + 16, oteT, fibTopStr, style = label.style_label_left, color = color.new(C_BG, 100), textcolor = color.new(i_colAccent, 15), size = size.tiny)
        s_oteLblMid := label.new(bar_index + 16, oteM, str.tostring(i_oteFibMid) + " mid", style = label.style_label_left, color = color.new(C_BG, 100), textcolor = i_colAccent, size = size.tiny)
        s_oteLblBot := label.new(bar_index + 16, oteB, fibBotStr, style = label.style_label_left, color = color.new(C_BG, 100), textcolor = color.new(i_colAccent, 15), size = size.tiny)

// Fibonacci levels are anchored at the bar where the last swing confirmed, so they are redrawn on swing events.
var line[]  s_fibLines  = array.new_line()
var label[] s_fibLabels = array.new_label()

if i_showFibLevels and pdValid and (swingHighConfirmed or swingLowConfirmed)
    if array.size(s_fibLines) > 0
        for i = array.size(s_fibLines) - 1 to 0
            line.delete(array.get(s_fibLines, i))
        array.clear(s_fibLines)

    if array.size(s_fibLabels) > 0
        for i = array.size(s_fibLabels) - 1 to 0
            label.delete(array.get(s_fibLabels, i))
        array.clear(s_fibLabels)

    float[] fibLevels = array.from(0.0, 0.236, 0.382, 0.5, 0.618, 0.705, 0.786, 1.0)
    string[] fibNames = array.from("0.0", "0.236", "0.382", "0.5 (EQ)", "0.618", "0.705", "0.786", "1.0")

    for idx = 0 to array.size(fibLevels) - 1
        fibVal = array.get(fibLevels, idx)
        fibName = array.get(fibNames, idx)
        fibPrice = s_pdLow + pdRange * fibVal

        fibColor = fibVal == 0.705 ? i_colAccent : fibVal == 0.5 ? C_NEUTRAL : fibVal >= 0.618 and fibVal <= 0.786 ? color.new(i_colAccent, 30) : color.new(C_NEUTRAL, 70)
        fibWidth = fibVal == 0.705 ? 2 : fibVal == 0.5 ? 2 : 1

        fLine = line.new(bar_index - 10, fibPrice, bar_index + 10, fibPrice, color = fibColor, style = line.style_dotted, width = fibWidth)
        array.push(s_fibLines, fLine)

        fLabel = label.new(bar_index + 11, fibPrice, fibName, style = label.style_label_left, color = color.new(C_BG, 100), textcolor = fibColor, size = size.tiny)
        array.push(s_fibLabels, fLabel)

// ── DASHBOARD ─────────────────────────────────────────────────
// Dashboard. Strings are built on the last bar only.
if barstate.islast and i_showTable
    var table s_dash = table.new(f_getPosition(i_tablePos), 3, 2, bgcolor = C_BG, border_width = 1, border_color = C_BORDER)
    table.cell(s_dash, 0, 0, "ICT Premium Discount", text_color = C_TEXT, text_size = size.small, bgcolor = C_BORDER)
    table.cell(s_dash, 1, 0, "", bgcolor = C_BORDER)
    table.cell(s_dash, 2, 0, timeframe.period, text_color = C_TEXT_DIM, text_size = size.small, bgcolor = C_BORDER)

    string zoneText = inPremium ? "PREMIUM" : inDiscount ? "DISCOUNT" : "EQ"
    color  zoneClr  = inPremium ? i_colDown : inDiscount ? i_colUp : C_NEUTRAL
    table.cell(s_dash, 0, 1, "Zone", text_color = C_TEXT, text_size = size.tiny)
    table.cell(s_dash, 1, 1, zoneText, text_color = zoneClr, text_size = size.tiny)
    table.cell(s_dash, 2, 1, not na(pdEQ) ? str.tostring(pdEQ, format.mintick) : "—", text_color = C_TEXT_DIM, text_size = size.tiny)

// ── ALERTS ────────────────────────────────────────────────────
alertcondition(inBullOTE, title = "Price In Bullish OTE", message = "{{ticker}} {{interval}} - Price is inside the bullish OTE zone (Fib 0.618-0.786, discount).")
alertcondition(inBearOTE, title = "Price In Bearish OTE", message = "{{ticker}} {{interval}} - Price is inside the bearish OTE zone (Fib 0.618-0.786, premium).")
````
