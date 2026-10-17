# FVG and Order Blocks Detector

- url: https://www.tradingview.com/script/EwqKQxEF-FVG-and-Order-Blocks-Detector/
- type: indicator
- pine_id: PUB;11ab1fda14234258b0a6a43d8b747428
- version: 1.0

## Description

FVG and Order Blocks Detector
[url=https://www.tradingview.com/u/Michael_Fx_Trader/]https://www.tradingview.com/u/Michael_Fx_Trader/[/url]

What This Indicator Is

FVG and Order Blocks Detector automatically finds Fair Value Gaps and bullish and bearish order blocks on any chart and marks each one as a clean, flat rectangle with its name written in bold, centered text. Nothing has to be drawn by hand, and nothing is left ambiguous: every zone is the output of a fixed rule set, it grows forward while it is still unproven, and it freezes exactly where price finally mitigates it, staying on the chart afterward as a faded historical record unless you choose to hide mitigated zones entirely. This is an educational technical analysis tool, not financial advice.
[image]https://www.tradingview.com/x/Eya7RhCX/[/image]

Why It Was Built

Fair value gaps and order blocks are two of the most commonly used price action concepts, but most tools that draw them either clutter the chart with dozens of overlapping boxes, keep showing zones long after they have clearly failed, or use text and coloring that is hard to read at a glance. This tool exists to keep the chart clean and legible: a hard limit on how many zones of each type are kept at once, a clear visual difference between an active zone and a mitigated one, and large, centered, bold labels that tell you exactly what each rectangle is without needing a legend.
[image]https://www.tradingview.com/x/vG3XAMoz/[/image]

How It Works

A Fair Value Gap is the classic three candle imbalance: when the current candle's low sits above the high from two candles back, that gap between them is marked bullish, and the mirror case, where the current high sits below the low from two candles back, is marked bearish. Gaps can also be calculated from a higher timeframe than the chart you are viewing, using only fully confirmed higher timeframe candles so nothing ever repaints. A minimum size filter, measured as a multiple of the fourteen period Average True Range, ignores gaps too small to matter. Once a gap is created, it is tracked using whichever mitigation rule you choose: Touch, which fills it the instant price enters the zone at all, Fifty Percent Fill, which waits until price reaches the exact middle of the gap, or Full Fill, which only counts the gap as closed once price has traded all the way through it.

Order blocks are built from swing highs and swing lows confirmed with your chosen lookback on each side. When price finally closes, or just wicks through if you prefer a faster reaction, above a confirmed swing high, that counts as an upward structure break, and the indicator looks back across every candle between that swing point and the breaking candle to find the last bearish candle with the lowest low, which becomes the order block for that break. A downward break works the same way in reverse, picking out the last bullish candle with the highest high. An optional displacement filter requires the breaking candle itself to have a large enough range, measured against the Average True Range, so a block is never built from a weak, low conviction break. A new block is also skipped entirely if it overlaps too heavily in price with an existing, still active block of the same type, which keeps the chart from filling up with near duplicate zones. Each block is then tracked for mitigation using either a close through it or any wick through it, whichever you choose, and the zone can be built from the full candle's high to low or from just its open to close body, depending on your preference.
[image]https://www.tradingview.com/x/P3tx5brh/[/image]

How To Read The Chart

Every zone is a solid, borderless rectangle with its name, Fair Value Gap, Bullish Order Block, or Bearish Order Block, written in bold text sitting exactly in the center of the box, both left to right and top to bottom. An active zone keeps stretching forward into the empty space on the right side of the chart, which is your visual cue that price has not yet dealt with it. The moment that happens, the box stops growing and locks in place exactly at the candle that mitigated it, and its color shifts to a faded, muted version so your eye can immediately tell the difference between a zone that still matters and one that has already played out. If you are using the Directional Colors theme instead of the default gray, bullish zones and bearish zones are also colored differently from each other, on top of the active versus faded distinction.
[image]https://www.tradingview.com/x/vfUieq8e/[/image]

How To Use It For Analysis

Treat every zone as an area of interest rather than a precise entry trigger. A still-active order block or fair value gap sitting ahead of price is a level worth watching for a reaction if price returns to it, especially one built on a candle that passed the displacement filter, since that reflects a genuinely forceful move rather than routine noise. A zone that has already faded tells you that level has been used up and is generally less important going forward, though it can still serve as a reference for how price has behaved historically at that price area. Because the indicator never hides the past unless you ask it to, you can scroll back through a chart's history and see exactly how often a given type of zone actually got respected versus simply broken through, which is a useful gut check before relying on the same pattern going forward. As with any price action tool, combine this with your own trend reading, other confluence, and proper risk management rather than trading a zone in isolation.
[image]https://www.tradingview.com/x/xwVtQYeg/[/image]

What The Indicator Draws On The Chart

For every Fair Value Gap, you get a flat rectangle spanning the three candle gap, labeled with your chosen FVG text, which keeps extending to the right while unmitigated and freezes the instant your chosen mitigation rule is satisfied. For every order block, you get the same style of flat rectangle built from the block candle's high and low or its body, labeled Bullish Order Block or Bearish Order Block according to your chosen naming convention, which also keeps extending forward until price mitigates it through a close or a wick, again based on your settings. Every label automatically shrinks to a smaller text size on narrower zones so the text never spills outside its box. Color follows whichever theme you have selected, a single neutral gray for every zone type, or four distinct directional colors, each with its own separate, more transparent shade once mitigated.
[image]https://www.tradingview.com/x/b55ncxsp/[/image]

Settings Worth Knowing Before Use

How many zones of each type are kept on the chart at once, whether mitigated zones are hidden outright or kept as a faded record, the label text size, color, and bold setting, whether the bullish and bearish order block names are standard or swapped, the color theme and its individual directional colors, whether fair value gaps are shown at all and on which timeframe, the minimum gap size filter, the fair value gap mitigation rule, the swing lookback used for order blocks, whether a break needs a full close or just a wick, the displacement filter and its strength, whether a block uses the full candle or just its body, and the order block mitigation source can all be adjusted from the indicator's settings panel to suit different instruments, timeframes, and personal preferences.

Disclaimer

This indicator is an educational technical analysis tool and does not constitute financial advice. A drawn zone describes a specific, mechanical price action pattern found in past and current data, not a prediction or a guarantee of how price will behave at that level in the future. All trading involves risk, and past reactions to a zone do not guarantee future results. Always use proper risk management and combine this tool with your own analysis before entering any trade.

Original Script Declaration

Script Name: FVG and Order Blocks Detector
Author: Michael_Fx_Trader
Publisher: Michael_Fx_Trader
Rights: Copyright Michael_Fx_Trader. All rights reserved.

Originality Statement: This is an original work, designed and coded from scratch by Michael_Fx_Trader. The flat, centered label zone drawing system, where a zone grows into the empty future space while active and freezes in place the instant it is mitigated, the three mode fair value gap mitigation engine, the swing, displacement, and overlap filtered order block engine with a selectable naming convention that swaps only the displayed labels without changing the underlying detection, and the per type oldest first zone limit were all independently conceived and implemented for this publication. No proprietary source code, private scripts, or copyrighted material belonging to any other author has been copied, mashed up, or reused in any part of this script.

Author Verification and Declaration: I, Michael_Fx_Trader, am the sole author and publisher of this script. I hold full authorship rights over its source code, its underlying logic, and its visual presentation. Fair value gaps and order blocks are well known, generic, publicly discussed price action concepts not owned by any individual author. Only the specific detection, filtering, mitigation, and drawing logic built around them here is original to this script, and nothing in it was copied or adapted from another author's published work.

## Source Code

````pine
//@version=6

// =============================================================================
//                         ORIGINAL SCRIPT DECLARATION
// =============================================================================
// Script Name   : FVG and Order Blocks Detector
// Author        : Michael_Fx_Trader
// Publisher     : Michael_Fx_Trader
// Rights        : © Michael_Fx_Trader. All rights reserved.
//
// Originality Statement:
//   This is an original work, designed and coded from scratch by
//   Michael_Fx_Trader. The flat, centered-label zone drawing system (zones
//   that grow into the empty future space while active and freeze in place
//   the instant they are mitigated), the three-mode FVG mitigation engine
//   (touch, 50 percent fill, full fill), the swing/displacement/overlap-
//   filtered order block engine with a selectable naming convention that
//   swaps only the displayed labels without changing the underlying
//   detection, and the per-type oldest-first zone limit were all
//   independently conceived and implemented for this publication. No
//   proprietary source code, private scripts, or copyrighted material
//   belonging to any other author has been copied, mashed-up, or reused in
//   any part of this script. This script was written fresh for this
//   publication and does not reuse code from any brief, prompt, or third-
//   party material supplied to the author; only the general, publicly-known
//   fair value gap and order block concepts were used as a conceptual
//   starting point.
//
// Author Verification / Declaration:
//   I, Michael_Fx_Trader, am the sole author and publisher of this script.
//   I hold full authorship rights over its source code, its underlying logic,
//   and its visual presentation. Fair value gaps and order blocks are
//   well-known, generic, publicly discussed price-action concepts not owned
//   by any individual author; only the specific detection, filtering,
//   mitigation, and drawing logic built around them here is original to this
//   script.
//
// Educational note: this is an educational technical-analysis tool, not
//   financial advice.
// =============================================================================

indicator("FVG and Order Blocks Detector", shorttitle = "IOB Zones", overlay = true,
     max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_bars_back = 5000)

int BULLISH = 1
int BEARISH = -1

// =============================================================================
// GROUP: General
// =============================================================================

grpGen = "General"
maxZonesPerType = input.int(5, "Max Zones Per Type", minval = 1, maxval = 30, group = grpGen,
     tooltip = "Maximum number of bullish FVGs, bearish FVGs, bullish order blocks and bearish order blocks kept on the chart, counted separately. The oldest of that type is removed first once the limit is exceeded.")
hideMitigated = input.bool(false, "Hide Mitigated Zones", group = grpGen,
     tooltip = "When on, a zone is deleted entirely once mitigated instead of staying on the chart in a faded state.")
labelSizeInput = input.string("Small", "Label Text Size", options = ["Tiny", "Small", "Normal", "Large"], group = grpGen,
     tooltip = "Text size used for zone labels. Automatically shrinks to Tiny on zones narrower than about 25 bars so the text still fits.")
labelTextColor = input.color(#131722, "Label Text Color", group = grpGen)
boldLabels = input.bool(true, "Bold Labels", group = grpGen,
     tooltip = "Draws zone label text in bold using Pine's text formatting option.")
namingConvention = input.string("Standard", "Naming Convention", options = ["Standard", "Reversed"], group = grpGen,
     tooltip = "Standard: a bullish order block is the last bearish candle before an upward break, a bearish order block is the last bullish candle before a downward break. Reversed swaps only the two labels (and their alert names); the underlying detection and mitigation logic is identical either way.")

// =============================================================================
// GROUP: Zone Colors
// =============================================================================

grpColor = "Zone Colors"
colorTheme = input.string("Gray Classic", "Color Theme", options = ["Gray Classic", "Directional Colors"], group = grpColor,
     tooltip = "Gray Classic uses one neutral gray for every zone type. Directional Colors uses a different color for each zone type and direction.")
dcBullFvg = input.color(color.new(#00ff68, 75), "Bullish FVG (Directional)", group = grpColor)
dcBearFvg = input.color(color.new(#ff0008, 75), "Bearish FVG (Directional)", group = grpColor)
dcBullOb  = input.color(color.new(#2157f3, 75), "Bullish OB (Directional)", group = grpColor)
dcBearOb  = input.color(color.new(#f23645, 75), "Bearish OB (Directional)", group = grpColor)

GRAY_ACTIVE = color.new(#b2b5be, 35)
GRAY_MITIGATED = color.new(#b2b5be, 75)

// =============================================================================
// GROUP: Fair Value Gaps
// =============================================================================

grpFvg = "Fair Value Gaps"
showFvg = input.bool(true, "Show FVGs", group = grpFvg)
fvgTf = input.timeframe("", "FVG Timeframe", group = grpFvg, tooltip = "Empty uses the chart's own timeframe.")
minGapAtr = input.float(0.1, "Minimum Gap Size (ATR multiple)", minval = 0.0, maxval = 5.0, step = 0.05, group = grpFvg,
     tooltip = "Gaps smaller than this multiple of ATR(14) are ignored.")
fvgMitigationMode = input.string("Full Fill", "Mitigation Mode", options = ["Touch", "50 Percent Fill", "Full Fill"], group = grpFvg)
fvgLabelText = input.string("FVG", "FVG Label Text", group = grpFvg)

// =============================================================================
// GROUP: Order Blocks
// =============================================================================

grpOb = "Order Blocks"
showOb = input.bool(true, "Show Order Blocks", group = grpOb)
swingLookback = input.int(8, "Swing Lookback", minval = 3, maxval = 50, group = grpOb,
     tooltip = "Bars on each side required to confirm a swing high or swing low.")
breakConfirmation = input.string("Candle Close", "Break Confirmation", options = ["Candle Close", "Wick"], group = grpOb,
     tooltip = "Candle Close requires a full close beyond the swing level. Wick accepts any wick beyond it.")
useDisplacement = input.bool(true, "Displacement Filter", inline = "disp", group = grpOb)
displacementMult = input.float(1.2, "", minval = 0.5, maxval = 5.0, step = 0.1, inline = "disp", group = grpOb,
     tooltip = "The breaking candle's full range must be at least this multiple of ATR(14) for the break to count.")
blockBodyMode = input.string("Full Candle (High to Low)", "Block Body Mode", options = ["Full Candle (High to Low)", "Body Only (Open to Close)"], group = grpOb)
mitigationSource = input.string("Wick", "Mitigation Source", options = ["Close", "Wick"], group = grpOb,
     tooltip = "Close: a block is only mitigated once price closes through it. Wick: any wick through it mitigates it.")
bullObLabelText = input.string("BULLISH ORDER BLOCK", "Bullish OB Label Text", group = grpOb)
bearObLabelText = input.string("BEARISH ORDER BLOCK", "Bearish OB Label Text", group = grpOb)

// =============================================================================
// USER-DEFINED TYPES
// =============================================================================

// A Fair Value Gap zone.
type GapZone
    float top = na
    float bottom = na
    float midpoint = na
    int   side = 0            // BULLISH or BEARISH
    int   leftTime = na
    int   rightTime = na
    box   zoneBox = na
    label zoneLabel = na
    bool  isMitigated = false
    int   mitigationTime = na

// An order block zone.
type BlockZone
    float top = na
    float bottom = na
    int   side = 0            // BULLISH (demand, from an upward break) or BEARISH (supply, from a downward break)
    int   leftTime = na
    int   rightTime = na
    box   zoneBox = na
    label zoneLabel = na
    bool  isMitigated = false
    int   mitigationTime = na

// A confirmed swing point waiting to be broken.
type SwingMark
    float price = na
    int   barIndex = na
    int   barTime = na
    bool  alreadyBroken = false

// Per-bar signal flags for alerts, recreated fresh every bar.
type SignalFlags
    bool bullGapCreated = false
    bool bearGapCreated = false
    bool bullGapFilled = false
    bool bearGapFilled = false
    bool bullBlockCreated = false
    bool bearBlockCreated = false
    bool bullBlockBroken = false
    bool bearBlockBroken = false

// =============================================================================
// PERSISTENT STATE
// =============================================================================

var array<GapZone>   gapList   = array.new<GapZone>()
var array<BlockZone> blockList = array.new<BlockZone>()

var SwingMark lastSwingHigh = SwingMark.new()
var SwingMark lastSwingLow  = SwingMark.new()

var int firstBarTime = na
if na(firstBarTime)
    firstBarTime := time

flags = SignalFlags.new()

atrVal = ta.atr(14)
barDur = time - time[1]
futureTime = time + barDur * 15

f_sizeOf(string s) => s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : size.small
chosenSize = f_sizeOf(labelSizeInput)
textFmt = boldLabels ? text.format_bold : text.format_none

// =============================================================================
// HELPER: CHOOSE A ZONE'S DISPLAY LABEL TEXT AND COLOR
// =============================================================================

f_gapColor(int side, bool mitigated) =>
    if colorTheme == "Gray Classic"
        mitigated ? GRAY_MITIGATED : GRAY_ACTIVE
    else
        base = side == BULLISH ? dcBullFvg : dcBearFvg
        mitigated ? color.new(color.gray, 90) : base

f_obColor(int displaySide, bool mitigated) =>
    if colorTheme == "Gray Classic"
        mitigated ? GRAY_MITIGATED : GRAY_ACTIVE
    else
        base = displaySide == BULLISH ? dcBullOb : dcBearOb
        mitigated ? color.new(color.gray, 90) : base

f_obLabelText(int displaySide) =>
    displaySide == BULLISH ? bullObLabelText : bearObLabelText

// =============================================================================
// HELPER: CENTERED LABEL SIZE (auto-shrink on narrow zones)
// =============================================================================

f_labelSizeFor(int leftT, int rightT) =>
    widthBars = barDur > 0 ? (rightT - leftT) / barDur : 999
    widthBars < 25 ? size.tiny : chosenSize

// =============================================================================
// FAIR VALUE GAP DETECTION (non-repainting: confirmed bars only)
// =============================================================================

if showFvg and barstate.isconfirmed
    bool patternReady = false
    float gTop = na
    float gBottom = na
    int   gSide = 0
    int   gLeftTime = na

    if fvgTf == ""
        // chart-timeframe three-candle pattern
        if low > high[2]
            patternReady := true
            gSide := BULLISH
            gTop := low
            gBottom := high[2]
            gLeftTime := time[2]
        else if high < low[2]
            patternReady := true
            gSide := BEARISH
            gTop := low[2]
            gBottom := high
            gLeftTime := time[2]
    else
        // higher-timeframe pattern, using only confirmed previous HTF bars (no lookahead)
        [hA, lA, tA, hB, lB, tB] = request.security(syminfo.tickerid, fvgTf,
             [high[1], low[1], time[1], high[2], low[2], time[2]], lookahead = barmerge.lookahead_off)
        var int lastHtfTime = na
        isNewHtf = tA != lastHtfTime
        lastHtfTime := tA
        if isNewHtf
            if lA > hB
                patternReady := true
                gSide := BULLISH
                gTop := lA
                gBottom := hB
                gLeftTime := tB
            else if hA < lB
                patternReady := true
                gSide := BEARISH
                gTop := lB
                gBottom := hA
                gLeftTime := tB

    if patternReady and (gTop - gBottom) >= minGapAtr * atrVal
        newGap = GapZone.new(top = gTop, bottom = gBottom, midpoint = (gTop + gBottom) / 2.0, side = gSide,
             leftTime = gLeftTime, rightTime = futureTime)
        col = f_gapColor(gSide, false)
        newGap.zoneBox := box.new(gLeftTime, gTop, futureTime, gBottom, xloc = xloc.bar_time,
             border_color = na, bgcolor = col)
        midX = math.round(gLeftTime + (futureTime - gLeftTime) / 2)
        newGap.zoneLabel := label.new(gLeftTime, (gTop + gBottom) / 2.0, fvgLabelText, xloc = xloc.bar_time,
             style = label.style_label_center, color = color.new(color.black, 100), textcolor = labelTextColor,
             size = f_labelSizeFor(gLeftTime, futureTime), text_formatting = textFmt)
        label.set_x(newGap.zoneLabel, midX)
        array.push(gapList, newGap)
        if gSide == BULLISH
            flags.bullGapCreated := true
        else
            flags.bearGapCreated := true

// =============================================================================
// FAIR VALUE GAP MITIGATION (backwards loop so removal never skips items)
// =============================================================================

if array.size(gapList) > 0
    for i = array.size(gapList) - 1 to 0
        g = array.get(gapList, i)
        if not g.isMitigated
            mitigatedNow = switch fvgMitigationMode
                "Touch" => high >= g.bottom and low <= g.top
                "50 Percent Fill" => g.side == BULLISH ? low <= g.midpoint : high >= g.midpoint
                => g.side == BULLISH ? low < g.bottom : high > g.top
            if mitigatedNow
                g.isMitigated := true
                g.mitigationTime := time
                if g.side == BULLISH
                    flags.bullGapFilled := true
                else
                    flags.bearGapFilled := true
                if hideMitigated
                    box.delete(g.zoneBox)
                    label.delete(g.zoneLabel)
                    array.remove(gapList, i)
                else
                    box.set_right(g.zoneBox, time)
                    box.set_bgcolor(g.zoneBox, f_gapColor(g.side, true))
                    label.set_x(g.zoneLabel, math.round(g.leftTime + (time - g.leftTime) / 2))
                    label.set_size(g.zoneLabel, f_labelSizeFor(g.leftTime, time))

// =============================================================================
// SWING PIVOT DETECTION FOR ORDER BLOCKS
// =============================================================================

ph = ta.pivothigh(high, swingLookback, swingLookback)
pl = ta.pivotlow(low, swingLookback, swingLookback)

if showOb
    if not na(ph)
        lastSwingHigh.price := ph
        lastSwingHigh.barIndex := bar_index - swingLookback
        lastSwingHigh.barTime := time[swingLookback]
        lastSwingHigh.alreadyBroken := false
    if not na(pl)
        lastSwingLow.price := pl
        lastSwingLow.barIndex := bar_index - swingLookback
        lastSwingLow.barTime := time[swingLookback]
        lastSwingLow.alreadyBroken := false

// =============================================================================
// HELPERS: FIND THE ORDER BLOCK CANDLE INSIDE A RANGE
// =============================================================================

// Searches offsets 0..fromOffset (0 = current bar) for the last bearish candle
// with the lowest low; falls back to the absolute lowest low if none is bearish.
f_findBearishLow(int fromOffset) =>
    bestIdx = 0
    bestLow = low
    foundBear = false
    for k = 0 to fromOffset
        if close[k] < open[k] and low[k] < (foundBear ? bestLow : 1e10)
            bestLow := low[k]
            bestIdx := k
            foundBear := true
    if not foundBear
        bestLow2 = low
        for k = 0 to fromOffset
            if low[k] < bestLow2
                bestLow2 := low[k]
                bestIdx := k
    bestIdx

// Mirror of the above for the highest high among bullish candles.
f_findBullishHigh(int fromOffset) =>
    bestIdx = 0
    bestHigh = high
    foundBull = false
    for k = 0 to fromOffset
        if close[k] > open[k] and high[k] > (foundBull ? bestHigh : -1e10)
            bestHigh := high[k]
            bestIdx := k
            foundBull := true
    if not foundBull
        bestHigh2 = high
        for k = 0 to fromOffset
            if high[k] > bestHigh2
                bestHigh2 := high[k]
                bestIdx := k
    bestIdx

// =============================================================================
// ORDER BLOCK MITIGATION (backwards loop)
// =============================================================================

if array.size(blockList) > 0
    for i = array.size(blockList) - 1 to 0
        bl = array.get(blockList, i)
        if not bl.isMitigated
            src = mitigationSource == "Close" ? close : (bl.side == BULLISH ? low : high)
            mitigatedNow2 = bl.side == BULLISH ? src < bl.bottom : src > bl.top
            if mitigatedNow2
                bl.isMitigated := true
                bl.mitigationTime := time
                displaySide = namingConvention == "Reversed" ? -bl.side : bl.side
                if displaySide == BULLISH
                    flags.bullBlockBroken := true
                else
                    flags.bearBlockBroken := true
                if hideMitigated
                    box.delete(bl.zoneBox)
                    label.delete(bl.zoneLabel)
                    array.remove(blockList, i)
                else
                    box.set_right(bl.zoneBox, time)
                    box.set_bgcolor(bl.zoneBox, f_obColor(displaySide, true))
                    label.set_x(bl.zoneLabel, math.round(bl.leftTime + (time - bl.leftTime) / 2))
                    label.set_size(bl.zoneLabel, f_labelSizeFor(bl.leftTime, time))

// =============================================================================
// STRUCTURE BREAK + ORDER BLOCK CREATION
// =============================================================================

f_overlapsTooMuch(float newTop, float newBot, int side) =>
    overlapFound = false
    if array.size(blockList) > 0
        for i = 0 to array.size(blockList) - 1
            bx = array.get(blockList, i)
            if not bx.isMitigated and bx.side == side
                interTop = math.min(newTop, bx.top)
                interBot = math.max(newBot, bx.bottom)
                interH = math.max(0.0, interTop - interBot)
                newH = newTop - newBot
                if newH > 0 and (interH / newH) > 0.7
                    overlapFound := true
    overlapFound

if showOb and barstate.isconfirmed
    breakRange = high - low
    displacementOk = not useDisplacement or breakRange >= displacementMult * atrVal

    // ---- upward break: last bearish candle before the break becomes the demand block ----
    upBreakSrc = breakConfirmation == "Wick" ? high : close
    if not na(lastSwingHigh.price) and not lastSwingHigh.alreadyBroken and upBreakSrc > lastSwingHigh.price and displacementOk
        lastSwingHigh.alreadyBroken := true
        fromOffset = bar_index - lastSwingHigh.barIndex
        idx = f_findBearishLow(fromOffset)
        obTop = blockBodyMode == "Full Candle (High to Low)" ? high[idx] : math.max(open[idx], close[idx])
        obBottom = blockBodyMode == "Full Candle (High to Low)" ? low[idx] : math.min(open[idx], close[idx])
        if not f_overlapsTooMuch(obTop, obBottom, BULLISH)
            newBlock = BlockZone.new(top = obTop, bottom = obBottom, side = BULLISH, leftTime = time[idx], rightTime = futureTime)
            displaySideNew = namingConvention == "Reversed" ? BEARISH : BULLISH
            col2 = f_obColor(displaySideNew, false)
            newBlock.zoneBox := box.new(time[idx], obTop, futureTime, obBottom, xloc = xloc.bar_time, border_color = na, bgcolor = col2)
            newBlock.zoneLabel := label.new(time[idx], (obTop + obBottom) / 2.0, f_obLabelText(displaySideNew), xloc = xloc.bar_time,
                 style = label.style_label_center, color = color.new(color.black, 100), textcolor = labelTextColor,
                 size = f_labelSizeFor(time[idx], futureTime), text_formatting = textFmt)
            label.set_x(newBlock.zoneLabel, math.round(time[idx] + (futureTime - time[idx]) / 2))
            array.push(blockList, newBlock)
            flags.bullBlockCreated := true

    // ---- downward break: last bullish candle before the break becomes the supply block ----
    dnBreakSrc = breakConfirmation == "Wick" ? low : close
    if not na(lastSwingLow.price) and not lastSwingLow.alreadyBroken and dnBreakSrc < lastSwingLow.price and displacementOk
        lastSwingLow.alreadyBroken := true
        fromOffset2 = bar_index - lastSwingLow.barIndex
        idx2 = f_findBullishHigh(fromOffset2)
        obTop2 = blockBodyMode == "Full Candle (High to Low)" ? high[idx2] : math.max(open[idx2], close[idx2])
        obBottom2 = blockBodyMode == "Full Candle (High to Low)" ? low[idx2] : math.min(open[idx2], close[idx2])
        if not f_overlapsTooMuch(obTop2, obBottom2, BEARISH)
            newBlock2 = BlockZone.new(top = obTop2, bottom = obBottom2, side = BEARISH, leftTime = time[idx2], rightTime = futureTime)
            displaySideNew2 = namingConvention == "Reversed" ? BULLISH : BEARISH
            col3 = f_obColor(displaySideNew2, false)
            newBlock2.zoneBox := box.new(time[idx2], obTop2, futureTime, obBottom2, xloc = xloc.bar_time, border_color = na, bgcolor = col3)
            newBlock2.zoneLabel := label.new(time[idx2], (obTop2 + obBottom2) / 2.0, f_obLabelText(displaySideNew2), xloc = xloc.bar_time,
                 style = label.style_label_center, color = color.new(color.black, 100), textcolor = labelTextColor,
                 size = f_labelSizeFor(time[idx2], futureTime), text_formatting = textFmt)
            label.set_x(newBlock2.zoneLabel, math.round(time[idx2] + (futureTime - time[idx2]) / 2))
            array.push(blockList, newBlock2)
            flags.bearBlockCreated := true

// =============================================================================
// ENFORCE MAX ZONES PER TYPE (oldest of that type removed first)
// =============================================================================

f_trimGaps(int side) =>
    count = 0
    if array.size(gapList) > 0
        for i = 0 to array.size(gapList) - 1
            if array.get(gapList, i).side == side
                count += 1
    if count > maxZonesPerType
        if array.size(gapList) > 0
            for i = 0 to array.size(gapList) - 1
                g2 = array.get(gapList, i)
                if g2.side == side
                    box.delete(g2.zoneBox)
                    label.delete(g2.zoneLabel)
                    array.remove(gapList, i)
                    break

f_trimBlocks(int side) =>
    count2 = 0
    if array.size(blockList) > 0
        for i = 0 to array.size(blockList) - 1
            if array.get(blockList, i).side == side
                count2 += 1
    if count2 > maxZonesPerType
        if array.size(blockList) > 0
            for i = 0 to array.size(blockList) - 1
                b2 = array.get(blockList, i)
                if b2.side == side
                    box.delete(b2.zoneBox)
                    label.delete(b2.zoneLabel)
                    array.remove(blockList, i)
                    break

f_trimGaps(BULLISH)
f_trimGaps(BEARISH)
f_trimBlocks(BULLISH)
f_trimBlocks(BEARISH)

// =============================================================================
// REFRESH ACTIVE ZONES (extend into future space) - last bar only, for speed
// =============================================================================

if barstate.islast or barstate.islastconfirmedhistory
    if array.size(gapList) > 0
        for i = 0 to array.size(gapList) - 1
            g3 = array.get(gapList, i)
            if not g3.isMitigated
                box.set_right(g3.zoneBox, futureTime)
                label.set_x(g3.zoneLabel, math.round(g3.leftTime + (futureTime - g3.leftTime) / 2))
                label.set_size(g3.zoneLabel, f_labelSizeFor(g3.leftTime, futureTime))
    if array.size(blockList) > 0
        for i = 0 to array.size(blockList) - 1
            b3 = array.get(blockList, i)
            if not b3.isMitigated
                box.set_right(b3.zoneBox, futureTime)
                label.set_x(b3.zoneLabel, math.round(b3.leftTime + (futureTime - b3.leftTime) / 2))
                label.set_size(b3.zoneLabel, f_labelSizeFor(b3.leftTime, futureTime))

// =============================================================================
// ALERTS
// =============================================================================

alertcondition(flags.bullGapCreated, "FVG Bullish Created", "FVG and Order Blocks Detector: new bullish fair value gap.")
alertcondition(flags.bearGapCreated, "FVG Bearish Created", "FVG and Order Blocks Detector: new bearish fair value gap.")
alertcondition(flags.bullGapFilled, "FVG Bullish Filled", "FVG and Order Blocks Detector: bullish fair value gap mitigated.")
alertcondition(flags.bearGapFilled, "FVG Bearish Filled", "FVG and Order Blocks Detector: bearish fair value gap mitigated.")
alertcondition(flags.bullBlockCreated, "Upward-Break Order Block Created", "FVG and Order Blocks Detector: new order block from an upward structure break.")
alertcondition(flags.bearBlockCreated, "Downward-Break Order Block Created", "FVG and Order Blocks Detector: new order block from a downward structure break.")
alertcondition(flags.bullBlockBroken, "Upward-Break Order Block Mitigated", "FVG and Order Blocks Detector: order block from an upward structure break was mitigated.")
alertcondition(flags.bearBlockBroken, "Downward-Break Order Block Mitigated", "FVG and Order Blocks Detector: order block from a downward structure break was mitigated.")
````
