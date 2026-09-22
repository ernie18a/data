<!-- tradingview-pine-id: PUB;87bb22ce37794c0aac7530ec30466ddd -->
<!-- tradingview-pine-version: 3.0 -->
<!-- tradingviewscripts-format: 1 -->
# ZoneKit

Source: https://www.tradingview.com/script/umYGvOiu-ZoneKit/

## Description

Library  "ZoneKit"
Generic 3-candle price-gap zone detection and drawing utilities.
Detects a gap between two candle extremes separated by one middle
candle, with an optional stricter mode requiring displacement on
both sides of the gap. Builds a box (and optional midline) to
represent the zone once detected.

scanZone(mode, h0, h2, l0, l2, c0, c1, c2, o0, o1, o2, minGap)
  Scans three consecutive candles for a price-gap zone in either
direction.
  Parameters:
    mode (string): "Standard" for a plain 3-candle gap; "Confirmed" for a gap
that also requires displacement (an "outside print") on both
sides of the gap, a stricter variant.
    h0 (float): Current candle's high.
    h2 (float): Two candles back's high.
    l0 (float): Current candle's low.
    l2 (float): Two candles back's low.
    c0 (float): Current candle's close.
    c1 (float): One candle back's close.
    c2 (float): Two candles back's close.
    o0 (float): Current candle's open.
    o1 (float): One candle back's open.
    o2 (float): Two candles back's open.
    minGap (float): Minimum required gap size, in price units.
  Returns: [isUp, isDown, upTop, upBot, downTop, downBot]

buildZone(top, bot, formTime, confTime, hourEnd, isUp, isLast, zoneColor, showMid, midColor, midStyle)
  Draws a zone box (and optional midline) and returns the
populated Zone object.
  Parameters:
    top (float): The zone's upper boundary.
    bot (float): The zone's lower boundary.
    formTime (int): Bar time the zone formed.
    confTime (int): Bar time the zone was confirmed.
    hourEnd (int): Caller-defined expiry time for the zone.
    isUp (bool): True if this is an upward (bullish) zone.
    isLast (bool): Caller-defined flag, passed straight through to the Zone.
    zoneColor (color): The resolved color for the box (and border).
    showMid (bool): Whether to also draw a midline through the zone's center.
    midColor (color): Color for the midline, if drawn.
    midStyle (string): Line style for the midline: "Solid", "Dotted", or "Dashed".
  Returns: The newly created Zone.

Zone
  Represents a detected price-gap zone and its drawn chart objects.
  Fields:
    mainBox (series box): The zone's drawn box.
    midLine (series line): Optional midline through the zone's center.
    boxLabel (series label): Optional label attached to the zone.
    overlayBox (series box): Optional secondary box (e.g. for partial-fill shading).
    top (series float): The zone's upper boundary.
    bot (series float): The zone's lower boundary.
    formationTime (series int): The bar time the zone formed.
    confirmTime (series int): The bar time the zone was confirmed.
    hourEnd (series int): A caller-defined expiry time for the zone.
    isFilled (series bool): Whether the zone has been fully filled/mitigated.
    wasHit (series bool): Whether price has touched the zone at all.
    isProcessed (series bool): Internal bookkeeping flag for caller use.
    isLast (series bool): Caller-defined flag (e.g. "most recent of its kind").
    isBull (series bool): True if the zone is an upward (bullish) gap.
    isFlipped (series bool): Whether the zone has flipped direction (price closed
    fillProgress (series float): Tracks how far into the zone price has intruded.

---

## Source Code

````pine
//@version=6

// @description Generic 3-candle price-gap zone detection and drawing utilities.
//              Detects a gap between two candle extremes separated by one middle
//              candle, with an optional stricter mode requiring displacement on
//              both sides of the gap. Builds a box (and optional midline) to
//              represent the zone once detected.
library("ZoneKit", overlay = true)

import PineCoders/ConditionalAverages/2 as pc

// @type Represents a detected price-gap zone and its drawn chart objects.
// @field mainBox The zone's drawn box.
// @field midLine Optional midline through the zone's center.
// @field boxLabel Optional label attached to the zone.
// @field overlayBox Optional secondary box (e.g. for partial-fill shading).
// @field top The zone's upper boundary.
// @field bot The zone's lower boundary.
// @field formationTime The bar time the zone formed.
// @field confirmTime The bar time the zone was confirmed.
// @field hourEnd A caller-defined expiry time for the zone.
// @field isFilled Whether the zone has been fully filled/mitigated.
// @field wasHit Whether price has touched the zone at all.
// @field isProcessed Internal bookkeeping flag for caller use.
// @field isLast Caller-defined flag (e.g. "most recent of its kind").
// @field isBull True if the zone is an upward (bullish) gap.
// @field isFlipped Whether the zone has flipped direction (price closed
//        through it against its original bias).
// @field fillProgress Tracks how far into the zone price has intruded.
export type Zone
    box mainBox
    line midLine
    label boxLabel
    box overlayBox
    float top
    float bot
    int formationTime
    int confirmTime
    int hourEnd
    bool isFilled
    bool wasHit
    bool isProcessed
    bool isLast
    bool isBull
    bool isFlipped
    float fillProgress

// @function Scans three consecutive candles for a price-gap zone in either
//           direction.
// @param mode "Standard" for a plain 3-candle gap; "Confirmed" for a gap
//        that also requires displacement (an "outside print") on both
//        sides of the gap, a stricter variant.
// @param h0 Current candle's high.
// @param h2 Two candles back's high.
// @param l0 Current candle's low.
// @param l2 Two candles back's low.
// @param c0 Current candle's close.
// @param c1 One candle back's close.
// @param c2 Two candles back's close.
// @param o0 Current candle's open.
// @param o1 One candle back's open.
// @param o2 Two candles back's open.
// @param minGap Minimum required gap size, in price units.
// @returns [isUp, isDown, upTop, upBot, downTop, downBot]
export scanZone(string mode, float h0, float h2, float l0, float l2, float c0, float c1, float c2, float o0, float o1, float o2, float minGap) =>
    bool isUp = false
    bool isDown = false
    float upTop = 0.0
    float upBot = 0.0
    float downTop = 0.0
    float downBot = 0.0

    if mode == 'Standard'
        isUp := h2 < l0 and l0 - h2 >= minGap
        upTop := l0
        upBot := h2

        if isUp
            float body2Top = math.max(c2, o2)
            float body1Bot = math.min(c1, o1)
            float body1Top = math.max(c1, o1)
            float body0Bot = math.min(c0, o0)

            if body2Top < body1Bot
                upBot := body2Top
                upBot
            if body1Top < body0Bot
                upTop := body0Bot
                upTop

        isDown := l2 > h0 and l2 - h0 >= minGap
        downTop := l2
        downBot := h0

        if isDown
            float body2Bot = math.min(c2, o2)
            float body1Top = math.max(c1, o1)
            float body1Bot = math.min(c1, o1)
            float body0Top = math.max(c0, o0)

            if body2Bot > body1Top
                downTop := body2Bot
                downTop
            if body1Bot > body0Top
                downBot := body0Top
                downBot

    else if mode == 'Confirmed'
        isUp := h2 < l0 and l0 - h2 >= minGap
        upTop := l0
        upBot := h2

        if isUp
            float body2Top = math.max(c2, o2)
            float body1Bot = math.min(c1, o1)
            float body1Top = math.max(c1, o1)
            float body0Bot = math.min(c0, o0)

            bool outside_2_1 = body2Top < body1Bot
            bool outside_1_0 = body1Top < body0Bot

            if outside_2_1 and outside_1_0
                upBot := body2Top
                upTop := body0Bot
                upTop
            else
                isUp := false
                isUp

        isDown := l2 > h0 and l2 - h0 >= minGap
        downTop := l2
        downBot := h0

        if isDown
            float body2Bot = math.min(c2, o2)
            float body1Top = math.max(c1, o1)
            float body1Bot = math.min(c1, o1)
            float body0Top = math.max(c0, o0)

            bool outside_2_1 = body2Bot > body1Top
            bool outside_1_0 = body1Bot > body0Top

            if outside_2_1 and outside_1_0
                downTop := body2Bot
                downBot := body0Top
                downBot
            else
                isDown := false
                isDown

    [isUp, isDown, upTop, upBot, downTop, downBot]

// @function Draws a zone box (and optional midline) and returns the
//           populated Zone object.
// @param top The zone's upper boundary.
// @param bot The zone's lower boundary.
// @param formTime Bar time the zone formed.
// @param confTime Bar time the zone was confirmed.
// @param hourEnd Caller-defined expiry time for the zone.
// @param isUp True if this is an upward (bullish) zone.
// @param isLast Caller-defined flag, passed straight through to the Zone.
// @param zoneColor The resolved color for the box (and border).
// @param showMid Whether to also draw a midline through the zone's center.
// @param midColor Color for the midline, if drawn.
// @param midStyle Line style for the midline: "Solid", "Dotted", or "Dashed".
// @returns The newly created Zone.
export buildZone(float top, float bot, int formTime, int confTime, int hourEnd, bool isUp, bool isLast, color zoneColor, bool showMid, color midColor, string midStyle) =>
    resolvedMidStyle = midStyle == 'Solid' ? line.style_solid : midStyle == 'Dotted' ? line.style_dotted : line.style_dashed

    box newBox = box.new(left = formTime, top = top, right = hourEnd, bottom = bot, bgcolor = zoneColor, border_color = zoneColor, border_width = 1, xloc = xloc.bar_time)

    line newMidLine = na
    if showMid
        float mid = (top + bot) / 2.0
        newMidLine := line.new(formTime, mid, hourEnd, mid, color = midColor, style = resolvedMidStyle, width = 1, xloc = xloc.bar_time)
        newMidLine

    Zone z = Zone.new(mainBox = newBox, midLine = newMidLine, boxLabel = na, overlayBox = na, top = top, bot = bot, formationTime = formTime, confirmTime = confTime, hourEnd = hourEnd, isFilled = false, wasHit = false, isProcessed = false, isLast = isLast, isBull = isUp, isFlipped = false, fillProgress = isUp ? top : bot)

    z

// @function Checks whether price sits above (or below) a stack of EMAs of
//           increasing length, a simple multi-timeframe trend alignment
//           filter.
// @param src The source series to compare against the EMA stack (e.g. hl2).
// @param len1 Length of the shortest EMA.
// @param len2 Length of the second EMA.
// @param len3 Length of the third EMA.
// @param len4 Length of the longest EMA.
// @returns [uptrend, downtrend, ema1, ema2, ema3, ema4] -- uptrend is true
//          when src is above all four EMAs, downtrend when it's below all
//          four. The individual EMA values are also returned for plotting
//          or further use by the caller.
export trendStack(float src, int len1, int len2, int len3, int len4) =>
    float ema1 = ta.ema(src, len1)
    float ema2 = ta.ema(src, len2)
    float ema3 = ta.ema(src, len3)
    float ema4 = ta.ema(src, len4)

    bool uptrend = src > ema1 and src > ema2 and src > ema3 and src > ema4
    bool downtrend = src < ema1 and src < ema2 and src < ema3 and src < ema4

    [uptrend, downtrend, ema1, ema2, ema3, ema4]

// @function Tracks a pivot-based upper/lower band pair and their midpoint,
//           stepping incrementally toward each new pivot high/low as it forms.
// @param len Lookback length for the highest-high / lowest-low pivot check.
// @returns [upper, lower, mid, dir] -- dir is 1 just after a new pivot high,
//          -1 just after a new pivot low, and holds its last value otherwise.
export pivotAvg(int len) =>
    var float h_avg = high
    var float l_avg = low
    float upper = na
    float lower = na
    float hst = ta.highest(len)
    float lst = ta.lowest(len)
    bool new_high = high == hst
    bool new_low = low == lst
    h_avg := ta.vwap(high, new_high)
    l_avg := ta.vwap(low, new_low)
    float h_change = ta.change(h_avg)
    float l_change = ta.change(l_avg)
    upper := new_high ? hst : (hst == hst[1] ? upper[1] + h_change : math.min(hst, upper[1] + h_change))
    lower := new_low ? lst : (lst == lst[1] ? lower[1] + l_change : math.max(lst, lower[1] + l_change))
    float mid = math.avg(upper, lower)
    var int dir = 0
    dir := new_high ? 1 : new_low ? -1 : dir[1]
    [upper, lower, mid, dir]

// @function Computes a rolling volume-weighted average of a source series
//           over a trailing time window, along with its variance and
//           standard deviation.
// @param src The source series (e.g. close).
// @param windowMs Trailing window size, in milliseconds.
// @param minBars Minimum number of bars required before the window is
//        considered valid.
// @returns [avg, variance, stDev]
export rollingAvg(float src, int windowMs, int minBars) =>
    float sumSrcVol = pc.totalForTimeWhen(src * volume, windowMs, true, minBars)
    float sumVol = pc.totalForTimeWhen(volume, windowMs, true, minBars)
    float sumSrcSrcVol = pc.totalForTimeWhen(volume * math.pow(src, 2), windowMs, true, minBars)

    float avg = sumSrcVol / sumVol
    float variance = math.max(sumSrcSrcVol / sumVol - math.pow(avg, 2), 0.0)
    float stDev = math.sqrt(variance)

    [avg, variance, stDev]

// @type Tracks market-structure trend state for Change-of-Character (CHoCH)
//       detection: the current trend direction plus the anchor and extreme
//       points of the active leg (e.g. for drawing a fib fan from the leg's
//       origin).
// @field trend Current trend direction: 1 = bullish, -1 = bearish, 0 = not
//        yet determined.
// @field extremeHighY The highest high reached during the current leg.
// @field extremeHighX The bar index of extremeHighY.
// @field extremeLowY The lowest low reached during the current leg.
// @field extremeLowX The bar index of extremeLowY.
// @field startX Bar index anchor for the current leg.
// @field startY Price anchor for the current leg.
export type ChochState
    int trend = 0
    float extremeHighY = na
    int extremeHighX = na
    float extremeLowY = na
    int extremeLowX = na
    int startX = na
    float startY = na

// @function Updates a ChochState with the current bar's data: tracks the
//           active leg's extremes and detects a Change of Character (CHoCH)
//           -- a close beyond the last confirmed opposing swing point.
// @param state The ChochState to update. Create one with ChochState.new()
//        and hold it in a `var` at the call site so it persists across bars.
// @param recentPH_Y Most recent confirmed swing-high price (na if none yet).
// @param recentPH_X Bar index of recentPH_Y.
// @param recentPL_Y Most recent confirmed swing-low price (na if none yet).
// @param recentPL_X Bar index of recentPL_Y.
// @param hi Current bar's high.
// @param lo Current bar's low.
// @param cl Current bar's close.
// @param idx Current bar's index.
// @returns [isBullChoCh, isBearChoCh] -- true on the bar a CHoCH is
//          detected in that direction, false otherwise. When either is
//          true, the caller should also treat its own swing-break
//          tracking (e.g. "has this pivot already been broken") as reset,
//          since the leg just changed direction.
export method update(ChochState state, float recentPH_Y, int recentPH_X, float recentPL_Y, int recentPL_X, float hi, float lo, float cl, int idx) =>
    bool isBullChoCh = false
    bool isBearChoCh = false

    if state.trend == 0
        if not na(recentPH_Y) and na(recentPL_Y)
            state.trend := -1
            state.startX := recentPH_X
            state.startY := recentPH_Y
            state.extremeLowY := lo
            state.extremeLowX := idx
        else if not na(recentPL_Y) and na(recentPH_Y)
            state.trend := 1
            state.startX := recentPL_X
            state.startY := recentPL_Y
            state.extremeHighY := hi
            state.extremeHighX := idx

    if na(state.extremeHighY) or hi > state.extremeHighY
        state.extremeHighY := hi
        state.extremeHighX := idx

    if na(state.extremeLowY) or lo < state.extremeLowY
        state.extremeLowY := lo
        state.extremeLowX := idx

    if state.trend == -1
        if not na(recentPH_Y) and cl > recentPH_Y
            isBullChoCh := true
            state.trend := 1
            state.startX := state.extremeLowX
            state.startY := state.extremeLowY
            state.extremeHighY := hi
            state.extremeHighX := idx
    else if state.trend == 1
        if not na(recentPL_Y) and cl < recentPL_Y
            isBearChoCh := true
            state.trend := -1
            state.startX := state.extremeHighX
            state.startY := state.extremeHighY
            state.extremeLowY := lo
            state.extremeLowX := idx

    [isBullChoCh, isBearChoCh]
````
