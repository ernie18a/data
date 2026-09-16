<!-- tradingview-pine-id: PUB;869d090ae2e74d9bb92637e63a67ecd1 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Swing Volume Profile (VPVR) with POC and Value Area

Source: https://www.tradingview.com/script/vKFHTSUR-Swing-Volume-Profile-VPVR-with-POC-and-Value-Area/

## Description

Swing Volume Profile (VPVR) with POC and Value Area

What it does
This indicator builds a volume profile anchored to the last confirmed swing pivot instead of a fixed number of bars. As price makes a new confirmed swing high or low, the profile re-anchors and rebuilds over the range from that pivot to the current bar.

How it works
Swing pivots are detected with a symmetric left/right pivot strength. The price range between the last confirmed pivot and the current bar is divided into rows, and each bar's volume is spread evenly across the rows its high-low range covers.

[*] The row with the most volume becomes the Point of Control (POC).
[*] Starting from the POC, the script expands outward to the next-highest-volume row on either side until the chosen share of total volume is enclosed - that range is the Value Area, bounded by VAH (Value Area High) and VAL (Value Area Low).
[*] An optional estimated buy/sell split colors each row by where price closed inside every bar's range (close near the high leans buy, close near the low leans sell). This is a derived estimate from bar data, not tick or order flow data, and is off by default.
[*] The profile is placed beside price, never on top of it, with an adjustable offset so the most recent candles stay uncovered.
[*] An optional faded profile of the previous completed swing can be shown alongside the current one for comparison.

How to use it

[*] Add the script to a chart. The profile appears once the first swing pivot has confirmed.
[*] Read the widest row as the Point of Control and the shaded band around it as the Value Area.
[*] Turn on Split Buy/Sell to see an estimated buy/sell lean per row, or Show Previous Swing Profile to compare against the prior swing.
[*] Watch for price crossing the POC or leaving the Value Area, and use the matching alert instead of watching the chart continuously.

Inputs

[*] Anchor - Pivot Strength (bars required on both sides of a high/low to confirm a pivot), Anchor Mode (Last Swing High, Last Swing Low, or Last Swing Either), Max Bars In Profile (safety cap while no new pivot has confirmed).
[*] Profile - Rows, Value Area % (50-95), Split Buy/Sell (estimated), Show Previous Swing Profile.
[*] Placement - Profile Side (Right of Price or Left Edge of Range), Profile Width %, Offset Bars.
[*] Style - Profile Color, Buy Color, Sell Color, POC Color, Value Area Color, Profile Opacity, Show POC Line, Show Value Area Box, Extend POC To Right, Show Level Prices, Text Size.

Signals and alerts

[*] Price crossed POC - fires once per bar close when price closes across the swing-anchored volume profile's POC level.
[*] Price left Value Area - fires once per bar close when price closes outside the value area after previously trading inside it.
[*] New swing anchor set - fires once per bar close when a new confirmed swing pivot re-anchors the volume profile.

Repainting
No repainting - measured, not claimed: alert conditions are evaluated only on confirmed bar closes. The profile itself updates live while the current bar is still forming, similar to a moving average or VWAP, but no past drawing is ever redrawn or removed retroactively.

Limitations

[*] The buy/sell split is an estimate derived from bar close position, not real order flow.
[*] The profile only appears once a first swing pivot has confirmed on the chart.
[*] This script works exclusively with bars of the chart's own timeframe. It does not request data from any other timeframe or resolution, so it has no plan-dependent history limit and looks the same on every account tier and every amount of chart history.

One package, one system - module from a shared engine of chart-timeframe-only indicators.

This script is a charting tool for educational purposes. It does not provide financial advice and does not predict future price movement. Trading carries risk; decisions and their outcome remain yours.

---

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) KronosMMXM

//@version=6
indicator("Swing Volume Profile (VPVR) with POC and Value Area", shorttitle = "Swing Volume Profile (kronos)", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

//#region TYPES ================================================================

enum AnchorMode
    lastSwingHigh   = "Last Swing High"
    lastSwingLow    = "Last Swing Low"
    lastSwingEither = "Last Swing Either"

enum ProfileSide
    rightOfPrice     = "Right of Price"
    leftEdgeOfRange  = "Left Edge of Range"

//#endregion

//#region CONSTANTS ============================================================

color  PROFILE_COLOR     = #2962ffff
color  BUY_COLOR         = #008080ff
color  SELL_COLOR        = #800000ff
color  POC_COLOR         = #ffa500ff
color  VALUE_AREA_COLOR  = #808080ff
color  ANCHOR_LINE_COLOR = #808080ff
color  HIDDEN_COLOR      = color.new(#000000, 100)
string GRP_ANCHOR        = "Anchor"
string GRP_PROFILE       = "Profile"
string GRP_PLACEMENT     = "Placement"
string GRP_STYLE         = "Style"
string GRP_ALERTS        = "Alerts"
int    MAX_ROW_BUDGET    = 440

string TIP_PIVOT_STRENGTH = """Bars required on both sides of a high/low before it confirms as
a swing pivot."""
string TIP_MAX_BARS       = """Safety cap on how many bars the profile spans while no new pivot
has confirmed."""
string TIP_SPLIT_BUY_SELL = """Estimates each row's buy/sell split from where price closed inside
every bar's range. This is not tick data."""
string TIP_OFFSET_BARS    = "Gap kept between the last bar and the profile so no candle is covered."

//#endregion

//#region INPUTS ===============================================================

int         pivotStrengthInput   = input.int(10, "Pivot Strength", minval = 1, maxval = 200, group = GRP_ANCHOR, tooltip = TIP_PIVOT_STRENGTH)
AnchorMode  anchorModeInput      = input.enum(AnchorMode.lastSwingEither, "Anchor Mode", group = GRP_ANCHOR)
int         maxBarsInput         = input.int(500, "Max Bars In Profile", minval = 20, maxval = 5000, group = GRP_ANCHOR, tooltip = TIP_MAX_BARS)

int         rowsInput            = input.int(24, "Rows", minval = 8, maxval = 100, group = GRP_PROFILE)
float       valueAreaPctInput    = input.float(70, "Value Area %", minval = 50, maxval = 95, group = GRP_PROFILE)
bool        splitBuySellInput    = input.bool(false, "Split Buy/Sell (estimated)", group = GRP_PROFILE, tooltip = TIP_SPLIT_BUY_SELL)
bool        showGhostInput       = input.bool(false, "Show Previous Swing Profile", group = GRP_PROFILE)

ProfileSide profileSideInput     = input.enum(ProfileSide.rightOfPrice, "Profile Side", group = GRP_PLACEMENT)
int         profileWidthPctInput = input.int(25, "Profile Width %", minval = 5, maxval = 100, group = GRP_PLACEMENT)
int         offsetBarsInput      = input.int(3, "Offset Bars", minval = 0, maxval = 50, group = GRP_PLACEMENT, tooltip = TIP_OFFSET_BARS)

color       profileColorInput    = input.color(PROFILE_COLOR, "Profile Color", group = GRP_STYLE)
color       buyColorInput        = input.color(BUY_COLOR, "Buy Color", group = GRP_STYLE, active = splitBuySellInput)
color       sellColorInput       = input.color(SELL_COLOR, "Sell Color", group = GRP_STYLE, active = splitBuySellInput)
color       pocColorInput        = input.color(POC_COLOR, "POC Color", group = GRP_STYLE)
color       valueAreaColorInput  = input.color(VALUE_AREA_COLOR, "Value Area Color", group = GRP_STYLE)
int         profileOpacityInput  = input.int(65, "Profile Opacity", minval = 0, maxval = 100, group = GRP_STYLE)
bool        showPocLineInput     = input.bool(true, "Show POC Line", group = GRP_STYLE)
bool        showVaBoxInput       = input.bool(true, "Show Value Area Box", group = GRP_STYLE)
bool        extendPocInput       = input.bool(false, "Extend POC To Right", group = GRP_STYLE, active = showPocLineInput)
bool        showLevelPricesInput = input.bool(true, "Show Level Prices", group = GRP_STYLE)
int         textSizeInput        = input.int(12, "Text Size", minval = 8, maxval = 40, group = GRP_STYLE, active = showLevelPricesInput)

bool        alertPocCrossInput   = input.bool(true, "Alert On POC Cross", group = GRP_ALERTS)
bool        alertVaExitInput     = input.bool(true, "Alert On Value Area Exit", group = GRP_ALERTS)

//#endregion

//#region FUNCTIONS ============================================================

// @function     Returns the box at `idx` in `arr`, creating a hidden one on first use.
// @param arr    (array<box>) Backing array of recycled box objects.
// @param idx    (series int) Slot index to fetch or initialize.
// @returns      (series box) The box at that slot, guaranteed non-na.
getOrCreateBox(array<box> arr, series int idx) =>
    box b = array.get(arr, idx)
    if na(b)
        b := box.new(bar_index, close, bar_index, close, border_color = na, bgcolor = na)
        array.set(arr, idx, b)
    b

//#endregion

//#region CALCULATIONS =========================================================

// Object budget guard. Fixed budget on drawn boxes so the script never fights
// Pine's object limit. If the current settings would exceed it, the
// effective row count shrinks instead of the script aborting or losing
// objects.
int mainPerRow  = splitBuySellInput ? 2 : 1
int ghostPerRow = showGhostInput ? 1 : 0
int perRowBoxes = mainPerRow + ghostPerRow
int effRows     = math.min(rowsInput, int(MAX_ROW_BUDGET / perRowBoxes))

// mainBoxA is the full row, or the buy segment when Split Buy/Sell is on.
// mainBoxB is the sell segment when split, otherwise kept hidden.
var array<box> mainBoxA  = array.new<box>(effRows, na)
var array<box> mainBoxB  = array.new<box>(effRows, na)
var array<box> ghostBoxA = array.new<box>(effRows, na)

var box   vaBox      = box.new(bar_index, close, bar_index, close, border_color = na, bgcolor = na)
var line  pocLine    = line.new(bar_index, close, bar_index, close, color = HIDDEN_COLOR)
var line  vahLine    = line.new(bar_index, close, bar_index, close, color = HIDDEN_COLOR)
var line  valLine    = line.new(bar_index, close, bar_index, close, color = HIDDEN_COLOR)
var line  anchorLine = line.new(bar_index, close, bar_index, close, color = HIDDEN_COLOR)
var label pocLabel   = label.new(
  bar_index, close, "", style = label.style_label_left,
  textcolor = POC_COLOR, color = HIDDEN_COLOR, size = textSizeInput)
var label vahLabel   = label.new(
  bar_index, close, "", style = label.style_label_left,
  textcolor = VALUE_AREA_COLOR, color = HIDDEN_COLOR, size = textSizeInput)
var label valLabel   = label.new(
  bar_index, close, "", style = label.style_label_left,
  textcolor = VALUE_AREA_COLOR, color = HIDDEN_COLOR, size = textSizeInput)

// Swing anchor tracking.
float ph = ta.pivothigh(pivotStrengthInput, pivotStrengthInput)
float pl = ta.pivotlow(pivotStrengthInput, pivotStrengthInput)

var int anchorBarIndex     = na
var int prevAnchorBarIndex = na

bool gotHigh = not na(ph) and anchorModeInput != AnchorMode.lastSwingLow
bool gotLow  = not na(pl) and anchorModeInput != AnchorMode.lastSwingHigh

bool newAnchor = false
if gotHigh or gotLow
    int pivotBarIndex = bar_index - pivotStrengthInput
    prevAnchorBarIndex := anchorBarIndex
    anchorBarIndex := pivotBarIndex
    newAnchor := true

// Alert state, carried across bars so a value-area exit can be detected as
// an edge (was inside, now outside) rather than re-fired on every bar spent
// outside.
var float pocLevel = na
var float vahLevel = na
var float valLevel = na
var bool  insideVA = true

// pine-lint: no-visuals drawing shares the compute loop, see the note below
// Profile computation and drawing, fused. Runs only on the last bar so the
// whole chart's history is never re-walked on every historical bar. Computing
// each row's volume and drawing its box share the same loop below: a second
// full scan just to separate "calculate" from "draw" would double the cost
// of the most expensive part of the script for no behavioural difference.
if barstate.islast and not na(anchorBarIndex)
    int rangeStart = math.max(anchorBarIndex, bar_index - maxBarsInput)
    int rangeLen   = bar_index - rangeStart

    float hi = high
    float lo = low
    for i = 0 to rangeLen
        hi := math.max(hi, high[i])
        lo := math.min(lo, low[i])
    if hi <= lo
        hi := lo + syminfo.mintick

    float rowHeight = (hi - lo) / effRows

    array<float> rowVol     = array.new<float>(effRows, 0.0)
    array<float> rowBuyVol  = array.new<float>(effRows, 0.0)
    array<float> rowSellVol = array.new<float>(effRows, 0.0)

    for i = 0 to rangeLen
        float bh = high[i]
        float bl = low[i]
        float bc = close[i]
        float bv = nz(volume[i], 0.0)
        float buyRatio  = bh > bl ? (bc - bl) / (bh - bl) : 0.5
        float sellRatio = 1 - buyRatio
        int   rowLowIdx  = int(math.max(0, math.min(effRows - 1,
          math.floor((bl - lo) / rowHeight))))
        int   rowHighIdx = int(math.max(0, math.min(effRows - 1,
          math.floor((bh - lo) / rowHeight))))
        int   spanRows   = rowHighIdx - rowLowIdx + 1
        float volPerRow  = bv / spanRows
        for r = rowLowIdx to rowHighIdx
            array.set(rowVol, r, array.get(rowVol, r) + volPerRow)
            array.set(rowBuyVol, r, array.get(rowBuyVol, r) + volPerRow * buyRatio)
            array.set(rowSellVol, r, array.get(rowSellVol, r) + volPerRow * sellRatio)

    float maxRowVol = array.max(rowVol)
    int   pocIdx    = array.indexof(rowVol, maxRowVol)

    float totalVol  = array.sum(rowVol)
    bool  hasVolume = totalVol > 0
    float targetVol = totalVol * valueAreaPctInput / 100
    int   vaLowIdx  = pocIdx
    int   vaHighIdx = pocIdx
    float accVol    = array.get(rowVol, pocIdx)
    while accVol < targetVol and (vaLowIdx > 0 or vaHighIdx < effRows - 1)
        float volBelow = vaLowIdx > 0 ? array.get(rowVol, vaLowIdx - 1) : -1.0
        float volAbove = vaHighIdx < effRows - 1 ? array.get(rowVol, vaHighIdx + 1) : -1.0
        if volAbove >= volBelow
            vaHighIdx += 1
            accVol += array.get(rowVol, vaHighIdx)
        else
            vaLowIdx -= 1
            accVol += array.get(rowVol, vaLowIdx)

    pocLevel := hasVolume ? lo + (pocIdx + 0.5) * rowHeight : na
    vahLevel := hasVolume ? lo + (vaHighIdx + 1) * rowHeight : na
    valLevel := hasVolume ? lo + vaLowIdx * rowHeight : na

    int baseX = profileSideInput == ProfileSide.rightOfPrice
      ? bar_index + offsetBarsInput
      : anchorBarIndex
    int requestedWidthBars = math.max(3, int(rangeLen * profileWidthPctInput / 100))
    int maxFutureWidth     = math.max(3, bar_index + 500 - baseX)
    int maxWidthBars       = math.min(requestedWidthBars, maxFutureWidth)
    int fillTrans    = 100 - profileOpacityInput

    for r = 0 to effRows - 1
        float vol    = array.get(rowVol, r)
        float top    = lo + (r + 1) * rowHeight
        float bottom = lo + r * rowHeight
        if splitBuySellInput
            float buyVol   = array.get(rowBuyVol, r)
            float sellVol  = array.get(rowSellVol, r)
            int   buyLenI  = maxRowVol > 0 ? int(math.round(maxWidthBars * buyVol / maxRowVol)) : 0
            int   sellLenI = maxRowVol > 0 ? int(math.round(maxWidthBars * sellVol / maxRowVol)) : 0
            box bxBuy = getOrCreateBox(mainBoxA, r)
            box.set_lefttop(bxBuy, baseX, top)
            box.set_rightbottom(bxBuy, baseX + buyLenI, bottom)
            box.set_bgcolor(bxBuy, color.new(buyColorInput, fillTrans))
            box.set_border_color(bxBuy, na)
            box bxSell = getOrCreateBox(mainBoxB, r)
            box.set_lefttop(bxSell, baseX + buyLenI, top)
            box.set_rightbottom(bxSell, baseX + buyLenI + sellLenI, bottom)
            box.set_bgcolor(bxSell, color.new(sellColorInput, fillTrans))
            box.set_border_color(bxSell, na)
        else
            int rowLenI = maxRowVol > 0 ? int(math.round(maxWidthBars * vol / maxRowVol)) : 0
            box bx = getOrCreateBox(mainBoxA, r)
            box.set_lefttop(bx, baseX, top)
            box.set_rightbottom(bx, baseX + rowLenI, bottom)
            box.set_bgcolor(bx, color.new(profileColorInput, fillTrans))
            box.set_border_color(bx, na)
            box bxHidden = getOrCreateBox(mainBoxB, r)
            box.set_lefttop(bxHidden, baseX, top)
            box.set_rightbottom(bxHidden, baseX, bottom)
            box.set_bgcolor(bxHidden, na)

    if showVaBoxInput and hasVolume
        box.set_lefttop(vaBox, baseX, vahLevel)
        box.set_rightbottom(vaBox, baseX + maxWidthBars, valLevel)
        box.set_bgcolor(vaBox, color.new(valueAreaColorInput, 85))
        box.set_border_color(vaBox, na)
    else
        box.set_bgcolor(vaBox, na)

    if showPocLineInput and hasVolume
        line.set_xy1(pocLine, baseX, pocLevel)
        line.set_xy2(pocLine, baseX + maxWidthBars, pocLevel)
        line.set_color(pocLine, pocColorInput)
        line.set_width(pocLine, 2)
        line.set_extend(pocLine, extendPocInput ? extend.right : extend.none)
    else
        line.set_color(pocLine, HIDDEN_COLOR)

    if hasVolume
        line.set_xy1(vahLine, baseX, vahLevel)
        line.set_xy2(vahLine, baseX + maxWidthBars, vahLevel)
        line.set_color(vahLine, color.new(valueAreaColorInput, 20))
        line.set_style(vahLine, line.style_dotted)

        line.set_xy1(valLine, baseX, valLevel)
        line.set_xy2(valLine, baseX + maxWidthBars, valLevel)
        line.set_color(valLine, color.new(valueAreaColorInput, 20))
        line.set_style(valLine, line.style_dotted)
    else
        line.set_color(vahLine, HIDDEN_COLOR)
        line.set_color(valLine, HIDDEN_COLOR)

    line.set_xy1(anchorLine, anchorBarIndex, lo)
    line.set_xy2(anchorLine, anchorBarIndex, hi)
    line.set_color(anchorLine, color.new(ANCHOR_LINE_COLOR, 40))
    line.set_style(anchorLine, line.style_dashed)
    line.set_width(anchorLine, 1)

    if showLevelPricesInput and hasVolume
        label.set_xy(pocLabel, baseX + maxWidthBars, pocLevel)
        label.set_text(pocLabel, "POC " + str.tostring(pocLevel, format.mintick))
        label.set_textcolor(pocLabel, pocColorInput)
        label.set_color(pocLabel, HIDDEN_COLOR)
        label.set_size(pocLabel, textSizeInput)
        label.set_style(pocLabel, label.style_label_left)

        label.set_xy(vahLabel, baseX + maxWidthBars, vahLevel)
        label.set_text(vahLabel, "VAH " + str.tostring(vahLevel, format.mintick))
        label.set_textcolor(vahLabel, valueAreaColorInput)
        label.set_color(vahLabel, HIDDEN_COLOR)
        label.set_size(vahLabel, textSizeInput)
        label.set_style(vahLabel, label.style_label_left)

        label.set_xy(valLabel, baseX + maxWidthBars, valLevel)
        label.set_text(valLabel, "VAL " + str.tostring(valLevel, format.mintick))
        label.set_textcolor(valLabel, valueAreaColorInput)
        label.set_color(valLabel, HIDDEN_COLOR)
        label.set_size(valLabel, textSizeInput)
        label.set_style(valLabel, label.style_label_left)
    else
        label.set_text(pocLabel, "")
        label.set_text(vahLabel, "")
        label.set_text(valLabel, "")

    // Ghost profile (previous swing).
    bool ghostHistoryAvailable = bar_index - anchorBarIndex <= maxBarsInput
    if showGhostInput and ghostHistoryAvailable and not na(prevAnchorBarIndex)
      and prevAnchorBarIndex < anchorBarIndex
        int gRangeStart  = math.max(prevAnchorBarIndex, bar_index - maxBarsInput)
        int gOffsetEnd   = bar_index - gRangeStart
        int gOffsetStart = bar_index - anchorBarIndex

        float gHi = high[gOffsetStart]
        float gLo = low[gOffsetStart]
        for i = gOffsetStart to gOffsetEnd
            gHi := math.max(gHi, high[i])
            gLo := math.min(gLo, low[i])
        if gHi <= gLo
            gHi := gLo + syminfo.mintick

        float gRowHeight = (gHi - gLo) / effRows
        array<float> gRowVol = array.new<float>(effRows, 0.0)
        for i = gOffsetStart to gOffsetEnd
            float gbh = high[i]
            float gbl = low[i]
            float gbv = nz(volume[i], 0.0)
            int gRowLowIdx  = int(math.max(0, math.min(effRows - 1,
              math.floor((gbl - gLo) / gRowHeight))))
            int gRowHighIdx = int(math.max(0, math.min(effRows - 1,
              math.floor((gbh - gLo) / gRowHeight))))
            int gSpanRows   = gRowHighIdx - gRowLowIdx + 1
            float gVolPerRow = gbv / gSpanRows
            for r = gRowLowIdx to gRowHighIdx
                array.set(gRowVol, r, array.get(gRowVol, r) + gVolPerRow)

        float gMaxRowVol    = array.max(gRowVol)
        int   gBaseX        = prevAnchorBarIndex
        int   gMaxWidthBars = math.max(3,
          int((anchorBarIndex - prevAnchorBarIndex) * profileWidthPctInput / 100))
        int   gTrans        = int(100 - math.round(profileOpacityInput / 2.0))

        for r = 0 to effRows - 1
            float gVol    = array.get(gRowVol, r)
            float gTop    = gLo + (r + 1) * gRowHeight
            float gBottom = gLo + r * gRowHeight
            int gLenI = gMaxRowVol > 0 ? int(math.round(gMaxWidthBars * gVol / gMaxRowVol)) : 0
            box gBx = getOrCreateBox(ghostBoxA, r)
            box.set_lefttop(gBx, gBaseX, gTop)
            box.set_rightbottom(gBx, gBaseX + gLenI, gBottom)
            box.set_bgcolor(gBx, color.new(profileColorInput, gTrans))
            box.set_border_color(gBx, na)
    else
        for r = 0 to effRows - 1
            box gBxOff = array.get(ghostBoxA, r)
            if not na(gBxOff)
                box.set_bgcolor(gBxOff, na)

bool pocCrossCond = alertPocCrossInput
  and barstate.isconfirmed
  and not na(pocLevel)
  and ta.cross(close, pocLevel)

bool vaExitCond = false
if barstate.isconfirmed and not na(vahLevel) and not na(valLevel)
    bool curInside = close >= valLevel and close <= vahLevel
    vaExitCond := alertVaExitInput and insideVA and not curInside
    insideVA := curInside

//#endregion

//#region ALERTS ===============================================================

alertcondition(
  pocCrossCond, "Price crossed POC",
  "Price closed across the swing-anchored volume profile POC level.")
alertcondition(
  vaExitCond, "Price left Value Area",
  "Price closed outside the value area after previously trading inside it.")
alertcondition(
  newAnchor, "New swing anchor set",
  "A new confirmed swing pivot has re-anchored the volume profile.")

//#endregion
````
