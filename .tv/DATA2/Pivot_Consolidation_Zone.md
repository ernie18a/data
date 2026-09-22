<!-- tradingview-pine-id: PUB;72c37a24399f46378c6439863b73712a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Pivot Consolidation Zone

Source: https://www.tradingview.com/script/8rFt5Wpp-Pivot-Consolidation-Zone/

## Description

█ OVERVIEW
Pivot Consolidation Zone detects consolidation ranges built between a confirmed pivot high and a confirmed pivot low. A zone is only created once both pivots have been tested and the pair satisfies a set of conditions: time distance, continuity of closes, and an optional height limit relative to ATR.

Once a zone is created, the indicator tracks its development and builds a Volume Profile for the range between the pivot high and pivot low. The profile shows the distribution of volume across price levels, along with an approximate Buy/Sell Volume split.

A close outside the zone ends the zone's activity and can generate a bullish or bearish signal. An optional Volume Confirmation filter requires the breakout direction to agree with the dominant volume side accumulated inside the zone before the breakout candle.

After a breakout, the zone is closed regardless of whether Volume Confirmation is met — the filter only determines whether a confirmed signal (and the zone recolor) is generated, not whether the zone ends. An optional TP/SL module can then plot Entry, Stop Loss, and up to three Take Profit levels, based on ATR or a fixed percentage and a chosen Risk:Reward.

█ CONCEPTS
The indicator combines pivot structure, the consolidation range, tests of the pivot candles, volume distribution, and breakout detection. A pivot on its own does not create a zone — a paired upper and lower pivot, a test on both sides, and price behavior inside the resulting range are all required.

Pivot Structure
A confirmed pivot high and pivot low mark the potential boundaries of a future zone. Pivot Length is the number of candles required on both sides of a local high or low to confirm it.

The zone's upper boundary is the pivot high price, and the lower boundary is the pivot low price. These two levels define the box and should not be confused with a test (see "Pivot Tests" below).

Pivot Pair
A zone is only created from a pair that satisfies all of the following conditions at once:
• the pivot high sits above the pivot low,
• both pivots fall within Max Pivot Pair Distance,
• closes between the start of the pair and the current candle stay inside the resulting range,
• the pair's height passes the optional ATR limit.

Max Pivot Pair Distance limits how far apart in time the pivots forming a single zone can be. This prevents distant price extremes from being automatically merged into one wide range.

Zone Range
Once a valid pair is found, the indicator draws a box:
• Top — the pivot high,
• Bottom — the pivot low,
• Left — extends backward as long as closes stay inside the range, up to a maximum of Max Box Left Edge bars,
• Right — advances with each new candle for as long as the zone remains active.

An optional ATR filter rejects pairs whose height exceeds a specified multiple of ATR.

Pivot Tests
A test does not refer to a touch of the finished zone's boundary. It refers only to the range of the candle that formed a given pivot.

For a pivot high, the indicator stores the range from that candle's high down to its low. For a pivot low, it stores the range from that candle's low up to its high. A test is recorded whenever a later candle overlaps this stored range.

Both pivots must accumulate at least one such test before the pair can form a zone. Optional markers show:
• ▼ — the pivot high candle,
• ▲ — the pivot low candle,
• numbered labels — successive tests of that pivot candle's range.

Numbering runs separately for the upper and lower pivot. These markers document the history that preceded the zone's formation, not subsequent touches of the already-drawn box.

ATR Breakout Margin
Min Breakout Size (x ATR) sets how far a close must move beyond a level to be treated as a breakout:
ATR × Min Breakout Size

A value of 0 disables the filter. The same margin is used to invalidate pivots, to check the continuity of the range, and to detect the zone breakout itself, so minor violations can be treated as noise.

Volume Profile
For an active zone, the range's height is divided into Price Bins. Each candle's volume is distributed across the bins according to how much of its high-low range overlaps each price level, then split into Buy and Sell Volume based on where the candle's close sits within that range:
• a close nearer the high increases the Buy Volume share,
• a close nearer the low increases the Sell Volume share.

The width of the strongest bin corresponds to Max Profile Width, and the remaining bins are scaled proportionally to it. The profile therefore shows both where volume concentrated and its approximate directional split.

By default, only the portion of a candle inside the zone is counted. Include Wick Volume Outside the Zone also adds volume from wicks extending beyond the range, assigning the excess to the nearest edge bin. This setting affects the profile, the Buy/Sell bars, the percentage label, and Volume Confirmation.

Buy/Sell Volume Split
Below the zone, two bars and a label can show the Buy/Sell Volume split for the entire range. The dominant side is:
• Buy — when Buy Volume is greater than or equal to Sell Volume,
• Sell — when Sell Volume is greater than Buy Volume.

Breakout
A zone ends when price closes outside its range:
• Breakout Up — Close > Zone Top + ATR margin,
• Breakout Down — Close < Zone Bottom − ATR margin.

If Volume Confirmation is disabled, the signal direction depends only on the breakout side. If enabled, a bullish breakout requires Buy Volume to be dominant, and a bearish breakout requires Sell Volume to be dominant.

The breakout candle is not added to the profile before this evaluation, so the breakout impulse itself cannot inflate the side that is confirming its own exit from the zone.

After a confirmed breakout, Recolor Zone on Breakout can change the box color to bullish or bearish. If the breakout is not confirmed, the zone stays neutral in color but is still closed.

TP/SL
After a confirmed signal, the TP/SL module plots Entry at the close of the breakout candle, a Stop Loss, and up to three targets. SL can be calculated as ATR × multiplier or as a fixed percentage from Entry. TP levels are derived from the chosen Risk:Reward ratios applied to the Entry-SL distance.

A new signal replaces the previous set of levels. The lines extend with price and stop once the market reaches the SL or the highest enabled TP. This is a level-planning tool, not an assessment of entry quality.

█ FEATURES
• Zone detection from a tested pivot high/pivot low pair, with a time-distance limit, close continuity check, and an optional ATR height limit.
• Volume Profile inside the zone, split into Price Bins with Buy and Sell Volume.
• Optional inclusion of wick volume extending outside the zone.
• Bars and label showing the total Buy/Sell Volume split below the zone.
• Upside and downside breakout signals, with optional Volume Confirmation.
• Zone recoloring on a confirmed breakout.
• Optional markers for pivot candles and numbered tests of their range.
• TP/SL module: Entry, SL, and TP1-TP3 based on ATR or percentage, and Risk:Reward.
• Alerts for upside and downside breakouts.

█ APPLICATIONS
Consolidation Analysis
The indicator locates ranges where price stays between a confirmed and tested pivot high and pivot low, producing a structure anchored to specific swing candles instead of a manually drawn box.

Zone Strength and Volume
The Volume Profile shows which price levels accumulated the most volume. The Buy/Sell split adds context on which side held the advantage across the whole range, not just at the moment of breakout.

Breakout Analysis
A signal marks price leaving the zone on a close outside its range. Volume Confirmation can narrow this down to breakouts that align with the volume split accumulated beforehand.

Example of Use
An active zone is better treated as an area of equilibrium than as a ready-made entry. Before acting on a signal, it helps to weigh:
• the breakout side,
• the dominant Buy/Sell Volume,
• the shape of the Volume Profile,
• the zone's position within the broader structure,
• momentum and context from a higher timeframe.

The zone being drawn, or a triangle appearing, is not on its own a sufficient reason to trade.

█ NOTES
• A test refers to the range of the pivot candle, not to a touch of the already-formed zone boundary.
• Volume Confirmation is optional. Without it, the signal depends only on the breakout direction.
• The breakout candle is excluded from the Volume Profile until after Volume Confirmation is evaluated.
• Buy and Sell Volume are derived from where the close sits within each candle's range. This is an estimate, not actual tape/order-flow buy/sell data.
• Show Breakout Signals is a shared switch: disabling it also disables the TP/SL module and the alerts, not just the on-chart triangles.
• TP/SL is a visual level-planning tool and does not assess the quality of a signal.
• This indicator does not replace independent market analysis or risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Uncle_the_shooter

//@version=6
indicator("Pivot Consolidation Zone", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500, max_bars_back=600)

// ZONE SETTINGS 
length      = input.int(10, "Pivot Length", minval=2, maxval=30, group="Zone Settings", tooltip="Number of bars required on both sides to confirm a local swing high/low (pivot).")
maxPairBars = input.int(100, "Max Pivot Pair Distance (bars)", minval=20, group="Zone Settings", tooltip="Maximum distance in bars between a pivot pair (high and low) that can form a zone. Setting this too high may combine price extremes that are far apart in time.")
maxLeftBack = input.int(250, "Max Box Left Edge (bars back)", minval=20, group="Zone Settings", tooltip="How far back (in bars) the left edge of the zone box can extend from the pivot, as long as the closing price stays inside the zone.")
useAtrCap   = input.bool(true, "Cap Max Zone Height by ATR", group="Zone Settings", tooltip="Rejects pivot pairs whose price range exceeds a specified multiple of ATR, preventing very wide, low-value zones from being created.")
atrLen      = input.int(100, "ATR Length", minval=1, group="Zone Settings", tooltip="ATR period used to cap the zone height and for the minimum breakout filter below.")
maxMultBox  = input.float(5.0, "Max Zone Height (x ATR)", minval=0, group="Zone Settings", tooltip="Maximum allowed zone height as a multiple of ATR. Active only when 'Cap Max Zone Height by ATR' is enabled.")
minBreakAtr = input.float(0.0, "Min Breakout Size (x ATR)", minval=0, step=0.1, group="Zone Settings", tooltip="0 disables this filter. Price must close beyond the pivot/zone by N x ATR to invalidate a level or end a zone, filtering out minor noise breakouts.")

// VOLUME PROFILE 
showProfile       = input.bool(true, "Show Zone Volume Profile", group="Volume Profile", tooltip="Draws a horizontal buy/sell volume histogram along the right edge of the zone, split into price bins.")
profileBins       = input.int(30, "Number of Price Bins", minval=3, maxval=40, group="Volume Profile", tooltip="Number of horizontal price bins the zone height is divided into when computing the profile.")
profileWidth      = input.int(30, "Max Profile Width (bars)", minval=5, maxval=100, group="Volume Profile", tooltip="Width, in bars, of the strongest bin in the profile. All other bins are scaled proportionally to it.")
includeOuterWicks = input.bool(false, "Include Wick Volume Outside the Zone", group="Volume Profile", tooltip="Disabled (default): only volume occurring at prices inside the zone is counted; the portion of a candle's wick extending outside the zone is ignored. Enabled: the candle's full volume is counted, with the excess from an outside wick assigned to the nearest edge bin. This setting also affects the buy/sell bars, the buy/sell label, and the breakout signals.")
const float PROFILE_BIN_GAP_PCT = 10.0

// ZONE VOLUME SPLIT 
showBoxVolBars    = input.bool(true, "Show Buy/Sell Bars Below Zone", group="Zone Volume Split", tooltip="Two horizontal bars below the zone showing the ratio of buy to sell volume across the entire zone.")
showBoxVolLabel   = input.bool(true, "Show Buy/Sell % Label", group="Zone Volume Split", tooltip="Percentage label below the bars showing the exact buy/sell volume split within the zone.")
volLabelSizeInput = input.string("Small", "Buy/Sell % Label Size", options=["Tiny", "Small", "Normal"], group="Zone Volume Split", tooltip="Size of the buy/sell percentage label, independent of the pivot/test marker size.")

// BREAKOUT SIGNALS 
showBreakoutSignals    = input.bool(true, "Show Breakout Signals", group="Breakout Signals", tooltip="Plots a triangle on the chart when the zone breaks out to the upside or downside.")
requireVolConfirmation = input.bool(false, "Require Dominant Volume Confirmation", group="Breakout Signals", tooltip="Enabled: a signal (and the zone recolor) fires only when the breakout direction agrees with the dominant volume side within the zone. Disabled: the signal is determined solely by breakout direction, regardless of volume.")
recolorBoxOnBreakout   = input.bool(true, "Recolor Zone on Breakout", group="Breakout Signals", tooltip="After a breakout, the zone box changes from neutral to bullish/bearish based on the breakout direction (and volume, if required above). If the signal is not confirmed, the box remains neutral.")
signalSizeInput         = input.string("Small", "Breakout Signal Size", options=["Tiny", "Small", "Normal"], group="Breakout Signals", tooltip="Size of the breakout signal triangles on the chart.")

// PIVOT & TEST MARKERS 
showPivotMarkers = input.bool(false, "Show Pivot Markers (▼/▲)", group="Pivot & Test Markers", tooltip="Labels marking the pivots that formed the upper (▼) and lower (▲) boundary of the zone.")
showTestMarkers  = input.bool(false, "Show Zone Boundary Test Markers", group="Pivot & Test Markers", tooltip="Numbered markers showing each successive test of the zone's upper and lower boundary by price.")
markerSizeInput  = input.string("Small", "Pivot & Test Marker Size", options=["Tiny", "Small", "Normal"], group="Pivot & Test Markers", tooltip="Applies to both pivot markers and zone boundary test markers.")

// COLORS 
colBull          = input.color(color.rgb(6, 162, 47), "Bullish Color", group="Colors", tooltip="Used for: the lower zone boundary (support) and its tests, a confirmed upside breakout, and the buy side of the volume profile/bars.")
colBear          = input.color(color.rgb(207, 23, 23), "Bearish Color", group="Colors", tooltip="Used for: the upper zone boundary (resistance) and its tests, a confirmed downside breakout, and the sell side of the volume profile/bars.")
colNeutral       = input.color(color.gray, "Neutral Color", group="Colors", tooltip="Color of the zone box itself until a breakout occurs. After a breakout, the box switches to the bullish or bearish color (see 'Breakout Signals').")
zoneBgTransp     = input.int(85, "Zone Background Transparency", minval=0, maxval=100, group="Colors", tooltip="Transparency of the zone box fill (0 = fully opaque, 100 = invisible). Applies to both the neutral color and the post-breakout color.")
zoneBorderTransp = input.int(0, "Zone Border Transparency", minval=0, maxval=100, group="Colors", tooltip="Transparency of the zone box border (0 = fully opaque, 100 = invisible). Applies to both the neutral color and the post-breakout color.")
profileTransp    = input.int(60, "Volume Profile Transparency", minval=0, maxval=100, group="Colors", tooltip="Transparency of the volume profile bins (0 = fully opaque, 100 = invisible).")

// TP/SL 
showTargets  = input.bool(true, "Show TP/SL Levels", group="TP/SL", tooltip="Plots Entry, Stop Loss, and Take Profit levels for every new breakout signal.")
useAtrSL     = input.bool(true, "SL = ATR", group="TP/SL", tooltip="Enabled: the Stop Loss distance from the entry price is calculated from ATR (ATR multiplier for SL).\nDisabled: a fixed percentage value is used (SL % from Entry).")
tpAtrPeriod  = input.int(14, "ATR Period (TP/SL)", minval=1, group="TP/SL", tooltip="ATR period used to determine the Stop Loss distance and Take Profit levels. Independent from the ATR used for zone filtering above.")
slAtrMult    = input.float(1.5, "SL ATR Multiplier", step=0.1, group="TP/SL", tooltip="ATR multiplier that determines the Stop Loss distance from the entry price, active when 'SL = ATR' is enabled.")
slPercent    = input.float(1.0, "SL % from Entry", step=0.1, group="TP/SL", tooltip="Percentage distance of the Stop Loss from the entry price, used when 'SL = ATR' is disabled.")
rrTP1        = input.float(1.0, "TP1 Risk:Reward", step=0.1, group="TP/SL", tooltip="Risk:Reward ratio for Take Profit 1. A value of 1.0 means TP1 sits at a distance equal to the risk (SL) from the entry price.")
rrTP2        = input.float(2.0, "TP2 Risk:Reward", step=0.1, group="TP/SL", tooltip="Risk:Reward ratio for Take Profit 2.")
rrTP3        = input.float(3.0, "TP3 Risk:Reward", step=0.1, group="TP/SL", tooltip="Risk:Reward ratio for Take Profit 3.")

showSlLevel  = input.bool(true, "Show SL Level", group="TP/SL Display", tooltip="Draws the line and label for the Stop Loss of the active signal.")
showTp1Level = input.bool(true, "Show TP1 Level", group="TP/SL Display", tooltip="Draws the line and label for Take Profit 1 of the active signal.")
showTp2Level = input.bool(true, "Show TP2 Level", group="TP/SL Display", tooltip="Draws the line and label for Take Profit 2 of the active signal.")
showTp3Level = input.bool(true, "Show TP3 Level", group="TP/SL Display", tooltip="Draws the line and label for Take Profit 3 of the active signal.")

markerSize = switch markerSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    => size.small

volLabelSize = switch volLabelSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    => size.small



atrVal = ta.atr(atrLen)
atrTP  = ta.atr(tpAtrPeriod)
brk    = minBreakAtr * atrVal

var hP  = array.new_float()
var hL  = array.new_float()
var hI  = array.new_int()
var hTi = array.new_int()
var hT  = array.new_int()
var hIn = array.new_bool()
var hTB = array.new_string()

var lP  = array.new_float()
var lH  = array.new_float()
var lI  = array.new_int()
var lTi = array.new_int()
var lT  = array.new_int()
var lIn = array.new_bool()
var lTB = array.new_string()

var bool  zoneActive = false
var float zoneTop    = na
var float zoneBottom = na
var box   zoneBox    = na
var int   zoneLeftIdx = na

// Volume profile arrays (buy/sell) for the current zone. Their totals also drive the
// buy/sell bars and percentage label for the whole zone box below.
var array<float> profBullVol = array.new_float(0)
var array<float> profBearVol = array.new_float(0)
var array<box>   profBullBox = array.new<box>(0)
var array<box>   profBearBox = array.new<box>(0)

var box   bullVolBox  = na
var box   bearVolBox  = na
var label volPctLabel = na

// TP/SL state 
var int      tpslDir        = 0
var float    tpslSL         = na
var float    tpslExtreme    = na
var line     tpslEntryLn    = na
var label    tpslEntryLb    = na
var line     tpslSlLn       = na
var label    tpslSlLb       = na
var line     tpslTp1Ln      = na
var label    tpslTp1Lb      = na
var line     tpslTp2Ln      = na
var label    tpslTp2Lb      = na
var line     tpslTp3Ln      = na
var label    tpslTp3Lb      = na
var line     tpslExtLn      = na
var linefill tpslRiskFill   = na
var linefill tpslRewardFill = na
var int      tpslEntryBar   = na

ph = ta.pivothigh(length, length)
pl = ta.pivotlow(length, length)

appendTest(string s, int idx) =>
    s == "" ? str.tostring(idx) : s + "," + str.tostring(idx)

markTests(string s, float price, color c) =>
    if s != ""
        parts = str.split(s, ",")
        for k = 0 to array.size(parts) - 1
            idx = int(str.tonumber(array.get(parts, k)))
            label.new(idx, price, str.tostring(k + 1), style=label.style_circle, color=color.new(c, 40), textcolor=color.white, size=markerSize)

// Left edge of the zone box: starting at the earlier pivot, walk left as long as the close
// stays inside the zone. The first close outside the range ends the prior swing and is
// excluded from the box. Returns [bar_offset, time] so the offset can also be reused for the
// volume profile backfill.
leftEdgeTime(float top, float bot, int pivotOffset, float breakSize, int maxBack) =>
    leftOff = pivotOffset
    lim = math.min(maxBack, bar_index)
    if pivotOffset < lim
        for k = pivotOffset + 1 to lim
            c = close[k]
            if na(c)
                break
            if c > top + breakSize or c < bot - breakSize
                break
            leftOff := k
    [leftOff, time[leftOff]]

// Adds a single candle's volume into the profile bins, splitting it into a buy and a sell
// portion based on where the close sits within the candle's range.
// clip=true  -> only counts the part of the candle within [bot, top] (wicks outside the zone are ignored)
// clip=false -> the candle's full volume is counted, with any excess from a wick outside the
//               zone assigned to the nearest edge bin
f_addBarToProfile(array<float> bullBins, array<float> bearBins, int nBins, float top, float bot, float bH, float bL, float bC, float bV, bool clip) =>
    float binH = (top - bot) / nBins
    if binH > 0 and bH > bL
        float fullRange = bH - bL
        float coreHigh = math.min(bH, top)
        float coreLow  = math.max(bL, bot)
        if coreHigh > coreLow
            for b = 0 to nBins - 1
                float binTop = top - b * binH
                float binBot = binTop - binH
                float ov_h = math.min(coreHigh, binTop)
                float ov_l = math.max(coreLow, binBot)
                if ov_h > ov_l
                    float overlap  = ov_h - ov_l
                    float addedVol = bV * overlap / fullRange
                    float bullPart = addedVol * (bC - bL) / fullRange
                    float bearPart = addedVol * (bH - bC) / fullRange
                    array.set(bullBins, b, array.get(bullBins, b) + bullPart)
                    array.set(bearBins, b, array.get(bearBins, b) + bearPart)
        if not clip
            if bH > top
                float overlapAbove = bH - math.max(bL, top)
                if overlapAbove > 0
                    float addedVol2 = bV * overlapAbove / fullRange
                    float bullPart2 = addedVol2 * (bC - bL) / fullRange
                    float bearPart2 = addedVol2 * (bH - bC) / fullRange
                    array.set(bullBins, 0, array.get(bullBins, 0) + bullPart2)
                    array.set(bearBins, 0, array.get(bearBins, 0) + bearPart2)
            if bL < bot
                float overlapBelow = math.min(bH, bot) - bL
                if overlapBelow > 0
                    float addedVol3 = bV * overlapBelow / fullRange
                    float bullPart3 = addedVol3 * (bC - bL) / fullRange
                    float bearPart3 = addedVol3 * (bH - bC) / fullRange
                    array.set(bullBins, nBins - 1, array.get(bullBins, nBins - 1) + bullPart3)
                    array.set(bearBins, nBins - 1, array.get(bearBins, nBins - 1) + bearPart3)

if not na(ph)
    array.push(hP, ph)
    array.push(hL, low[length])
    array.push(hI, bar_index - length)
    array.push(hTi, time[length])
    array.push(hT, 0)
    array.push(hIn, false)
    array.push(hTB, "")
    if array.size(hP) > 40
        array.shift(hP)
        array.shift(hL)
        array.shift(hI)
        array.shift(hTi)
        array.shift(hT)
        array.shift(hIn)
        array.shift(hTB)

if not na(pl)
    array.push(lP, pl)
    array.push(lH, high[length])
    array.push(lI, bar_index - length)
    array.push(lTi, time[length])
    array.push(lT, 0)
    array.push(lIn, false)
    array.push(lTB, "")
    if array.size(lP) > 40
        array.shift(lP)
        array.shift(lH)
        array.shift(lI)
        array.shift(lTi)
        array.shift(lT)
        array.shift(lIn)
        array.shift(lTB)

if array.size(hP) > 0
    for i = array.size(hP) - 1 to 0
        p   = array.get(hP, i)
        plo = array.get(hL, i)
        if close > p + brk
            array.remove(hP, i)
            array.remove(hL, i)
            array.remove(hI, i)
            array.remove(hTi, i)
            array.remove(hT, i)
            array.remove(hIn, i)
            array.remove(hTB, i)
        else if low <= p and high >= plo
            if not array.get(hIn, i)
                array.set(hT, i, array.get(hT, i) + 1)
                array.set(hIn, i, true)
                array.set(hTB, i, appendTest(array.get(hTB, i), bar_index))
        else
            array.set(hIn, i, false)

if array.size(lP) > 0
    for i = array.size(lP) - 1 to 0
        p   = array.get(lP, i)
        phi = array.get(lH, i)
        if close < p - brk
            array.remove(lP, i)
            array.remove(lH, i)
            array.remove(lI, i)
            array.remove(lTi, i)
            array.remove(lT, i)
            array.remove(lIn, i)
            array.remove(lTB, i)
        else if high >= p and low <= phi
            if not array.get(lIn, i)
                array.set(lT, i, array.get(lT, i) + 1)
                array.set(lIn, i, true)
                array.set(lTB, i, appendTest(array.get(lTB, i), bar_index))
        else
            array.set(lIn, i, false)

int   pairH = na
int   pairL = na
int   bestStart = na

if array.size(hP) > 0 and array.size(lP) > 0
    for i = 0 to array.size(hP) - 1
        if array.get(hT, i) >= 1
            hp  = array.get(hP, i)
            hIx = array.get(hI, i)
            for j = 0 to array.size(lP) - 1
                if array.get(lT, j) >= 1
                    lp  = array.get(lP, j)
                    lIx = array.get(lI, j)
                    if hp > lp
                        startIdx = math.min(hIx, lIx)
                        barsBack = bar_index - startIdx
                        okRange = barsBack >= 0 and barsBack <= maxPairBars
                        if okRange
                            contained = true
                            for k = 1 to barsBack
                                if close[k] > hp + brk or close[k] < lp - brk
                                    contained := false
                            passesAtr = not useAtrCap or (hp - lp) <= maxMultBox * atrVal
                            if contained and passesAtr
                                if na(bestStart) or startIdx < bestStart
                                    bestStart := startIdx
                                    pairH := i
                                    pairL := j

if not zoneActive and not na(pairH) and not na(pairL)
    zoneActive := true
    zoneTop    := array.get(hP, pairH)
    zoneBottom := array.get(lP, pairL)
    pivotOff   = bar_index - math.min(array.get(hI, pairH), array.get(lI, pairL))
    [leftOff, startTime] = leftEdgeTime(zoneTop, zoneBottom, pivotOff, brk, maxLeftBack)
    zoneLeftIdx := bar_index - leftOff
    zoneBox    := box.new(startTime, zoneTop, time, zoneBottom, border_color=color.new(colNeutral, zoneBorderTransp), bgcolor=color.new(colNeutral, zoneBgTransp), xloc=xloc.bar_time)
    if showPivotMarkers
        label.new(array.get(hI, pairH), zoneTop, "▼", style=label.style_label_down, color=colBear, textcolor=color.white, size=markerSize)
        label.new(array.get(lI, pairL), zoneBottom, "▲", style=label.style_label_up, color=colBull, textcolor=color.white, size=markerSize)
    if showTestMarkers
        markTests(array.get(hTB, pairH), zoneTop, colBear)
        markTests(array.get(lTB, pairL), zoneBottom, colBull)

    // Reset the volume profile data for the new zone (delete the old bins so they don't
    // clutter the chart).
    if array.size(profBullBox) > 0
        for i = 0 to array.size(profBullBox) - 1
            bb = array.get(profBullBox, i)
            if not na(bb)
                box.delete(bb)
            be = array.get(profBearBox, i)
            if not na(be)
                box.delete(be)
    profBullVol := array.new_float(profileBins, 0.0)
    profBearVol := array.new_float(profileBins, 0.0)
    profBullBox := array.new<box>(profileBins, na)
    profBearBox := array.new<box>(profileBins, na)
    // Backfill the profile using the zone's historical bars (the current bar is added by the
    // loop below, once per bar).
    if leftOff > 0
        for k = 1 to leftOff
            f_addBarToProfile(profBullVol, profBearVol, profileBins, zoneTop, zoneBottom, high[k], low[k], close[k], volume[k], not includeOuterWicks)

    // Buy/sell bars and % label below the zone (new objects; earlier ones remain as history).
    if showBoxVolBars
        bullVolBox := box.new(zoneLeftIdx, zoneBottom, zoneLeftIdx, zoneBottom, bgcolor=color.new(colBull, 15), border_color=color.new(colBull, 15), xloc=xloc.bar_index)
        bearVolBox := box.new(zoneLeftIdx, zoneBottom, zoneLeftIdx, zoneBottom, bgcolor=color.new(colBear, 15), border_color=color.new(colBear, 15), xloc=xloc.bar_index)
    if showBoxVolLabel
        volPctLabel := label.new(zoneLeftIdx, zoneBottom, "", style=label.style_label_upper_left, color=colNeutral, textcolor=color.white, size=volLabelSize, xloc=xloc.bar_index)

bool bullBreakoutSignal = false
bool bearBreakoutSignal = false

if zoneActive
    box.set_right(zoneBox, time)

    bool breakoutUp   = close > zoneTop + brk
    bool breakoutDown = close < zoneBottom - brk
    bool isBreakoutBar = breakoutUp or breakoutDown

    // The current bar's volume is only added to the profile when this bar does NOT close the
    // zone. This ensures that:
    //  - the breakout bar itself cannot inflate the side it is meant to confirm
    //    (requireVolConfirmation evaluates the volume split from before the breakout bar,
    //    not including it),
    //  - with includeOuterWicks enabled, the breakout impulse is not dumped into the edge bin —
    //    the profile and bars freeze at their last state from inside the consolidation.
    if not isBreakoutBar
        f_addBarToProfile(profBullVol, profBearVol, profileBins, zoneTop, zoneBottom, high, low, close, volume, not includeOuterWicks)

    if showProfile
        maxBinTotal = 0.0
        for b = 0 to profileBins - 1
            tot = array.get(profBullVol, b) + array.get(profBearVol, b)
            if tot > maxBinTotal
                maxBinTotal := tot

        // The zone height is first divided into `profileBins` equal nominal slots, which sets
        // the gap size in price units. The actual bin height (binH) is then reduced so that
        // every gap between bins is equal, and the outermost bins sit flush against the zone's
        // upper and lower boundary.
        nominalBinH   = (zoneTop - zoneBottom) / profileBins
        binGapAmt     = nominalBinH * PROFILE_BIN_GAP_PCT / 100.0
        totalGapSpace = binGapAmt * (profileBins - 1)
        binH          = (zoneTop - zoneBottom - totalGapSpace) / profileBins
        leftAnchor    = bar_index + 1

        for b = 0 to profileBins - 1
            bullV = array.get(profBullVol, b)
            bearV = array.get(profBearVol, b)
            tot   = bullV + bearV
            width = maxBinTotal > 0 ? math.round(profileWidth * tot / maxBinTotal) : 0.0
            bullW = tot > 0 ? math.round(width * bullV / tot) : 0.0
            bearW = width - bullW

            binTop = zoneTop - b * (binH + binGapAmt)
            binBot = binTop - binH

            bullLeft  = leftAnchor
            bullRight = leftAnchor + int(bullW)
            bearLeft  = bullRight
            bearRight = bullRight + int(bearW)

            existingBull = array.get(profBullBox, b)
            if na(existingBull)
                newBull = box.new(bullLeft, binTop, bullRight, binBot, border_color=color.new(colBull, profileTransp), border_width=1, bgcolor=color.new(colBull, profileTransp), xloc=xloc.bar_index)
                array.set(profBullBox, b, newBull)
            else
                box.set_left(existingBull, bullLeft)
                box.set_right(existingBull, bullRight)
                box.set_top(existingBull, binTop)
                box.set_bottom(existingBull, binBot)

            existingBear = array.get(profBearBox, b)
            if na(existingBear)
                newBear = box.new(bearLeft, binTop, bearRight, binBot, border_color=color.new(colBear, profileTransp), border_width=1, bgcolor=color.new(colBear, profileTransp), xloc=xloc.bar_index)
                array.set(profBearBox, b, newBear)
            else
                box.set_left(existingBear, bearLeft)
                box.set_right(existingBear, bearRight)
                box.set_top(existingBear, binTop)
                box.set_bottom(existingBear, binBot)

    // Sum of the bins = total buy/sell volume within the zone (respects includeOuterWicks).
    totalBull = array.sum(profBullVol)
    totalBear = array.sum(profBearVol)

    if showBoxVolBars or showBoxVolLabel
        float barH2    = atrVal * 0.18
        float gapH2    = atrVal * 0.08
        float bullTop2 = zoneBottom - gapH2
        float bullBot2 = bullTop2 - barH2
        float bearTop2 = bullBot2 - gapH2
        float bearBot2 = bearTop2 - barH2

        if showBoxVolBars
            float totalVolBars = totalBull + totalBear
            int   fullWidth2   = math.max((bar_index + 1) - zoneLeftIdx, 1)
            int   bullRight2   = totalVolBars > 0 ? zoneLeftIdx + math.round(fullWidth2 * (totalBull / totalVolBars)) : zoneLeftIdx + math.round(fullWidth2 * 0.5)
            int   bearRight2   = totalVolBars > 0 ? zoneLeftIdx + math.round(fullWidth2 * (totalBear / totalVolBars)) : zoneLeftIdx + math.round(fullWidth2 * 0.5)

            box.set_lefttop(bullVolBox, zoneLeftIdx, bullTop2)
            box.set_rightbottom(bullVolBox, bullRight2, bullBot2)
            box.set_lefttop(bearVolBox, zoneLeftIdx, bearTop2)
            box.set_rightbottom(bearVolBox, bearRight2, bearBot2)

        if showBoxVolLabel
            float totalVolL = totalBull + totalBear
            float bullPctL  = totalVolL > 0 ? math.round((totalBull / totalVolL * 100.0) * 10) / 10 : 50.0
            float sellPctL  = 100.0 - bullPctL
            color bgColL = bullPctL > 50.0 ? colBull : bullPctL < 50.0 ? colBear : colNeutral
            string txtL  = "Buy " + str.tostring(bullPctL, "#.#") + "%\nSell " + str.tostring(sellPctL, "#.#") + "%"
            label.set_xy(volPctLabel, zoneLeftIdx, bearBot2 - gapH2 * 0.5)
            label.set_text(volPctLabel, txtL)
            label.set_color(volPctLabel, bgColL)

    // Breakout detection and optional dominant-volume confirmation. breakoutUp/breakoutDown
    // were computed above, before the current bar was potentially added to the profile.
    if isBreakoutBar
        bool bullDominant = totalBull >= totalBear
        bool bearDominant = totalBear > totalBull
        bool validUp   = breakoutUp   and (not requireVolConfirmation or bullDominant)
        bool validDown = breakoutDown and (not requireVolConfirmation or bearDominant)

        if showBreakoutSignals
            bullBreakoutSignal := validUp
            bearBreakoutSignal := validDown

        if recolorBoxOnBreakout
            if validUp
                box.set_bgcolor(zoneBox, color.new(colBull, zoneBgTransp))
                box.set_border_color(zoneBox, color.new(colBull, zoneBorderTransp))
            else if validDown
                box.set_bgcolor(zoneBox, color.new(colBear, zoneBgTransp))
                box.set_border_color(zoneBox, color.new(colBear, zoneBorderTransp))

        zoneActive := false

// TP/SL - create levels on a new breakout signal 
if showTargets and (bullBreakoutSignal or bearBreakoutSignal)
    bool isBuyTrade = bullBreakoutSignal

    line.delete(tpslEntryLn)
    label.delete(tpslEntryLb)
    line.delete(tpslSlLn)
    label.delete(tpslSlLb)
    line.delete(tpslTp1Ln)
    label.delete(tpslTp1Lb)
    line.delete(tpslTp2Ln)
    label.delete(tpslTp2Lb)
    line.delete(tpslTp3Ln)
    label.delete(tpslTp3Lb)
    line.delete(tpslExtLn)
    linefill.delete(tpslRiskFill)
    linefill.delete(tpslRewardFill)

    tpslDir      := isBuyTrade ? 1 : -1
    tpslEntryBar := bar_index

    float entryP   = close
    float riskDist = useAtrSL ? atrTP * slAtrMult : entryP * (slPercent / 100.0)

    // Entry, SL, TP1-3 use 40 transparency; the risk/reward fills use 80 transparency.
    color entryCol    = color.new(isBuyTrade ? colBull : colBear, 40)
    color slCol       = color.new(isBuyTrade ? colBear : colBull, 40)
    color tpCol       = color.new(isBuyTrade ? colBull : colBear, 40)
    color riskFillC   = color.new(isBuyTrade ? colBear : colBull, 80)
    color rewardFillC = color.new(isBuyTrade ? colBull : colBear, 80)

    float slP  = isBuyTrade ? entryP - riskDist : entryP + riskDist
    float tp1P = isBuyTrade ? entryP + riskDist * rrTP1 : entryP - riskDist * rrTP1
    float tp2P = isBuyTrade ? entryP + riskDist * rrTP2 : entryP - riskDist * rrTP2
    float tp3P = isBuyTrade ? entryP + riskDist * rrTP3 : entryP - riskDist * rrTP3

    tpslSL      := slP
    tpslExtreme := showTp3Level ? tp3P : showTp2Level ? tp2P : showTp1Level ? tp1P : na

    tpslEntryLn := line.new(bar_index, entryP, bar_index + 1, entryP,
         color = entryCol, width = 2, extend = extend.none)
    tpslEntryLb := label.new(bar_index, entryP,
         (isBuyTrade ? 'BUY ' : 'SELL ') + str.tostring(entryP, format.mintick),
         style = label.style_label_left, color = entryCol,
         textcolor = color.white, size = size.small)

    if showSlLevel
        tpslSlLn := line.new(bar_index, slP, bar_index + 1, slP,
             color = slCol, width = 1, style = line.style_dashed, extend = extend.none)
        tpslSlLb := label.new(bar_index, slP,
             'SL ' + str.tostring(slP, format.mintick),
             style = label.style_label_left, color = slCol,
             textcolor = color.white, size = size.small)

    if showTp1Level
        tpslTp1Ln := line.new(bar_index, tp1P, bar_index + 1, tp1P,
             color = tpCol, width = 1, extend = extend.none)
        tpslTp1Lb := label.new(bar_index, tp1P,
             'TP1 ' + str.tostring(tp1P, format.mintick),
             style = label.style_label_left, color = tpCol,
             textcolor = color.white, size = size.small)

    if showTp2Level
        tpslTp2Ln := line.new(bar_index, tp2P, bar_index + 1, tp2P,
             color = tpCol, width = 1, extend = extend.none)
        tpslTp2Lb := label.new(bar_index, tp2P,
             'TP2 ' + str.tostring(tp2P, format.mintick),
             style = label.style_label_left, color = tpCol,
             textcolor = color.white, size = size.small)

    if showTp3Level
        tpslTp3Ln := line.new(bar_index, tp3P, bar_index + 1, tp3P,
             color = tpCol, width = 1, style = line.style_dotted, extend = extend.none)
        tpslTp3Lb := label.new(bar_index, tp3P,
             'TP3 ' + str.tostring(tp3P, format.mintick),
             style = label.style_label_left, color = tpCol,
             textcolor = color.white, size = size.small)

    if showSlLevel
        tpslRiskFill := linefill.new(tpslEntryLn, tpslSlLn, riskFillC)

    float fillExtreme = entryP
    if isBuyTrade
        if showTp1Level
            fillExtreme := math.max(fillExtreme, tp1P)
        if showTp2Level
            fillExtreme := math.max(fillExtreme, tp2P)
        if showTp3Level
            fillExtreme := math.max(fillExtreme, tp3P)
        if fillExtreme > entryP
            tpslExtLn      := line.new(bar_index, fillExtreme, bar_index + 1, fillExtreme, color = na, extend = extend.none)
            tpslRewardFill := linefill.new(tpslEntryLn, tpslExtLn, rewardFillC)
    else
        if showTp1Level
            fillExtreme := math.min(fillExtreme, tp1P)
        if showTp2Level
            fillExtreme := math.min(fillExtreme, tp2P)
        if showTp3Level
            fillExtreme := math.min(fillExtreme, tp3P)
        if fillExtreme < entryP
            tpslExtLn      := line.new(bar_index, fillExtreme, bar_index + 1, fillExtreme, color = na, extend = extend.none)
            tpslRewardFill := linefill.new(tpslEntryLn, tpslExtLn, rewardFillC)

// TP/SL - update line/label positions and detect SL/TP hits 
if tpslDir != 0
    if not na(tpslEntryLb)
        label.set_x(tpslEntryLb, bar_index)
    if not na(tpslSlLb)
        label.set_x(tpslSlLb, bar_index)
    if not na(tpslTp1Lb)
        label.set_x(tpslTp1Lb, bar_index)
    if not na(tpslTp2Lb)
        label.set_x(tpslTp2Lb, bar_index)
    if not na(tpslTp3Lb)
        label.set_x(tpslTp3Lb, bar_index)

    if not na(tpslEntryLn)
        line.set_x2(tpslEntryLn, bar_index + 1)
    if not na(tpslSlLn)
        line.set_x2(tpslSlLn, bar_index + 1)
    if not na(tpslTp1Ln)
        line.set_x2(tpslTp1Ln, bar_index + 1)
    if not na(tpslTp2Ln)
        line.set_x2(tpslTp2Ln, bar_index + 1)
    if not na(tpslTp3Ln)
        line.set_x2(tpslTp3Ln, bar_index + 1)
    if not na(tpslExtLn)
        line.set_x2(tpslExtLn, bar_index + 1)

    bool slHit = tpslDir == 1 ? low <= tpslSL : high >= tpslSL
    bool tpHit = not na(tpslExtreme) and
         (tpslDir == 1 ? high >= tpslExtreme : low <= tpslExtreme)

    if bar_index > tpslEntryBar and (slHit or tpHit)
        if not na(tpslEntryLn)
            line.set_x2(tpslEntryLn, bar_index)
        if not na(tpslSlLn)
            line.set_x2(tpslSlLn, bar_index)
        if not na(tpslTp1Ln)
            line.set_x2(tpslTp1Ln, bar_index)
        if not na(tpslTp2Ln)
            line.set_x2(tpslTp2Ln, bar_index)
        if not na(tpslTp3Ln)
            line.set_x2(tpslTp3Ln, bar_index)
        if not na(tpslExtLn)
            line.set_x2(tpslExtLn, bar_index)
        tpslDir := 0

// BACKTESTER OUTPUT PLOTS 
plot(bullBreakoutSignal ? 1 : na, "backtest_buy",  display = display.none)
plot(bearBreakoutSignal ? 1 : na, "backtest_sell", display = display.none)

// plotshape requires size as a const string literal, so the size selection is split into a
// separate call per option.
plotshape(bullBreakoutSignal and signalSizeInput == "Tiny",   title="Breakout Up (Tiny)",   style=shape.triangleup, location=location.belowbar, color=colBull, size=size.tiny)
plotshape(bullBreakoutSignal and signalSizeInput == "Small",  title="Breakout Up (Small)",  style=shape.triangleup, location=location.belowbar, color=colBull, size=size.small)
plotshape(bullBreakoutSignal and signalSizeInput == "Normal", title="Breakout Up (Normal)", style=shape.triangleup, location=location.belowbar, color=colBull, size=size.normal)

plotshape(bearBreakoutSignal and signalSizeInput == "Tiny",   title="Breakout Down (Tiny)",   style=shape.triangledown, location=location.abovebar, color=colBear, size=size.tiny)
plotshape(bearBreakoutSignal and signalSizeInput == "Small",  title="Breakout Down (Small)",  style=shape.triangledown, location=location.abovebar, color=colBear, size=size.small)
plotshape(bearBreakoutSignal and signalSizeInput == "Normal", title="Breakout Down (Normal)", style=shape.triangledown, location=location.abovebar, color=colBear, size=size.normal)

alertcondition(bullBreakoutSignal, title="Zone Breakout Up", message="Consolidation zone breakout to the UPSIDE")
alertcondition(bearBreakoutSignal, title="Zone Breakout Down", message="Consolidation zone breakout to the DOWNSIDE")
````
