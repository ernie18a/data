# Percent Gainer - Balanced Price Range

- url: https://www.tradingview.com/script/H8mX2u5w-Percent-Gainer-Balanced-Price-Range/
- type: indicator
- pine_id: PUB;3337047ba4d943968f3cd3c0ba9ab260
- version: 1.0

## Description

This indicator finds Balanced Price Ranges (BPRs) and draws each one as a zone that stays on the chart until price breaks it. A BPR forms when a fair value gap (FVG) in one direction is followed by an overlapping FVG in the opposite direction. The zone is only the overlapping area, which price has now moved through quickly in both directions.

How it works

Gap detection. A fair value gap is a three-candle pattern. A bullish gap forms when the low of the third candle is above the high of the first candle. A bearish gap forms when the high of the third candle is below the low of the first candle. Every qualifying gap is stored as a candidate.
Overlap. When a new gap forms, the script checks it against earlier gaps in the opposite direction that formed within the lookback window. If their price ranges overlap, the overlapping area becomes a BPR.
A bearish gap followed by an overlapping bullish gap creates a long BPR (green).
A bullish gap followed by an overlapping bearish gap creates a short BPR (red).
Zone life. Each BPR extends to the right until price goes through its far edge, meaning the bottom of a long BPR or the top of a short BPR. You choose whether a candle close or a wick ends the zone. An optional maximum life can retire zones that have not broken.

Non-repainting design

Gaps are only registered on the bar where the gap timeframe's candle closes, so a BPR appears at the same point in real time as it does in history. When the gap timeframe is higher than the chart, the script reads the last closed candle of that timeframe, with no lookahead. With "Zone Broken By" set to Close, a zone only ends when a candle actually closes beyond it. A live price dip that recovers before the close does not end the zone.

Boxes are drawn starting from the first gap's candles so you can see where the zone came from. The zone only exists from the bar where the second gap's candle closes.

Settings

BPR: Gap Detection

Gap Detection Timeframe: the timeframe both gaps are detected on. Leave blank to use the chart timeframe. Choose the chart timeframe or a higher one that divides into it evenly, such as 5 minutes on a 1-minute chart or 15 minutes on a 5-minute chart.
Min Gap Height (ATRx): each of the two gaps must be at least this many ATRs tall. 0 accepts any gap.
Gap ATR Length: the ATR length used by the height, overlap and expansion settings. The ATR is calculated on the gap timeframe.
Zone Expansion (ATRx): widens each finished BPR by ATR × this value on both sides. The overlap is always found from the raw gaps first, so expansion never creates a BPR that didn't exist. A wider zone also needs a bigger move to break. 0 turns it off.
Use Gap Formation Time Window / Gap Window (NYC time): when on, only first gaps whose third candle opens inside this New York time window are tracked. The second, overlapping gap can form at any time.

BPR: Overlap & Zone Life

Max Bars Between the Two Gaps: the opposite gap must form within this many gap-timeframe bars of the first gap, or the first gap is dropped.
Min Overlap Height (ATRx): the overlap itself must be at least this many ATRs tall. 0 accepts any overlap.
Zone Broken By: Close ends a zone when a candle closes beyond its far edge. Wick ends it when any wick trades beyond it.
Max Zone in Bars: an unbroken zone stops extending after this many gap-timeframe bars from when it formed. 0 extends it until it breaks.

Display

Show 50% Line: draws a dashed line at the middle of each BPR.
Delete Broken Zones: when on, broken zones are removed so only live BPRs stay on the chart. When off, broken zones stay as history and stop extending.
Show Candidate FVGs: also draws every raw gap that could still become half of a BPR. Candidates are aqua (bearish gaps) and red (bullish gaps).
Long / Short BPR Color, 50% Line Color: the zone and midline colors.
Max Boxes Kept: the oldest boxes and midlines are deleted once this number is exceeded.

Alerts

BPR Formed Long: fires when a new long BPR forms.
BPR Formed Short: fires when a new short BPR forms.
Both fire once, at the close of the bar that completes the BPR.

How to use it

The script marks zones only. It does not generate entries or exits. Many traders treat a BPR as an area where price may react on a return, because both sides of it have already been delivered quickly. A long BPR that holds on a pullback can act as support, and a short BPR can act as resistance. A close through the far edge means the zone has failed. Combine the zones with your own analysis, risk management and confirmation.

What sets this version apart

Gap detection on any higher timeframe, without repainting, while you trade a lower chart.
ATR-based filters for both gap size and overlap size, so small or insignificant zones can be filtered out on any instrument.
Zone Expansion that is applied after the raw overlap test, so padding never invents a zone.
An optional formation time window that applies to the first gap only.
A choice of close or wick break rules, plus an optional maximum zone life.

Limitations

A BPR can only be confirmed after its second gap's third candle closes, so zones always appear after the fact. Higher gap timeframes delay confirmation further.
Gap timeframes that don't divide evenly into the chart timeframe can miss gaps. Gap timeframes lower than the chart only register the last gap inside each chart bar.
Use standard candles. On Heikin Ashi or other non-standard chart types, gaps and breaks are calculated from synthetic prices, not real ones.
Old boxes are deleted once Max Boxes Kept is reached.
This indicator is for educational and analytical purposes only. It is not financial advice, and past zone behavior does not guarantee future reactions.

## Source Code

````pine
// © Straight Line Trades Inc. & Percent Gainers. All rights reserved.

//@version=6
indicator("Percent Gainer - Balanced Price Range", shorttitle = "PG BPR", overlay = true, max_boxes_count = 500, max_lines_count = 500)

// ======================================================================
// BALANCED PRICE RANGE (BPR) — zones only, no entry signals
// ======================================================================
//
//   1. A 3-candle FVG forms on the gap timeframe (read on the bar it CLOSES, non-repainting).
//   2. A later OPPOSITE FVG overlaps it within the lookback.
//        bearish gap then bullish gap = LONG BPR  (bullish colour)
//        bullish gap then bearish gap = SHORT BPR (bearish colour)
//      The zone is the OVERLAP only.
//   3. The box extends until price goes through its FAR edge
//      (the bottom of a long BPR, the top of a short BPR), or until Max Zone Life.
// ======================================================================

// ── Gap detection ──
grpGap = "---> BPR: Gap Detection"
bprTF           = input.timeframe("", "Gap Detection Timeframe", group = grpGap,
                  tooltip = "Timeframe both gaps are detected on. Blank = chart timeframe.\n\nGaps are read from the last CLOSED bar of this timeframe (non-repainting).")
bprAtrMult      = input.float(0.0, "    Min Gap Height (ATRx)", step = 0.05, minval = 0, group = grpGap,
                  tooltip = "EACH of the two gaps must be at least this many ATRs tall. 0 = any gap.")
bprAtrLen       = input.int(14, "    Gap ATR Length", minval = 1, group = grpGap)
bprExpandMult   = input.float(0.0, "    Zone Expansion (ATRx)", step = 0.05, minval = 0, group = grpGap,
                  tooltip = "Pads the finished BPR by ATR x this on BOTH sides.\n\nThe overlap itself is found from the RAW gaps, so padding never creates a BPR that did not exist. A wider zone also needs a bigger move to break.\n\n0 = off.")
bprUseGapWindow = input.bool(false, "Use Gap Formation Time Window", group = grpGap,
                  tooltip = "ON: only FIRST gaps whose 3rd candle opens inside the window are tracked. The overlapping second gap may form at any time.")
bprGapSess      = input.session("0800-1100", "    Gap Window (NYC time)", group = grpGap)

// ── Overlap & zone life ──
grpBpr = "---> BPR: Overlap & Zone Life"
bprLookback     = input.int(20, "Max Bars Between the Two Gaps", minval = 1, group = grpBpr,
                  tooltip = "The overlapping opposite FVG must form within this many gap-timeframe bars of the first FVG, or the first FVG is dropped.")
bprMinOverlap   = input.float(0.0, "  Min Overlap Height (ATRx)", step = 0.05, minval = 0, group = grpBpr,
                  tooltip = "The overlap (the BPR itself) must be at least this many ATRs tall. 0 = any overlap.")
bprBreakType    = input.string("Close", "  Zone Broken By", options = ["Close", "Wick"], group = grpBpr,
                  tooltip = "What ends a zone: price going through its FAR edge (the bottom of a long BPR, the top of a short BPR).\nClose: a candle closes through it.\nWick: any wick through it.")
zoneMaxBars     = input.int(0, "  Max Zone in Bars (0 = until broken)", minval = 0, group = grpBpr,
                  tooltip = "A zone that has not been broken stops extending after this many gap-timeframe bars from when it formed.\n0 = extend until broken.")

// ── Display ──
grpDisp = "---> Display"
showMid         = input.bool(false, "Show 50% Line", group = grpDisp)
deleteBroken    = input.bool(false, "Delete Broken Zones", group = grpDisp,
                  tooltip = "ON: a zone's box and 50% line are removed once price breaks it, so only live BPRs are on the chart.\nOFF: broken zones stay as history and simply stop extending.")
showCand        = input.bool(false, "Show Candidate FVGs", group = grpDisp,
                  tooltip = "OFF: only confirmed BPRs are drawn.\nON: also draws every raw FVG that could still become half of a BPR.")
bullCol         = input.color(color.green, "Long BPR Color",  group = grpDisp)
bearCol         = input.color(color.red,   "Short BPR Color", group = grpDisp)
midCol          = input.color(color.white, "50% Line Color",  group = grpDisp)
maxBoxes        = input.int(100, "Max Boxes Kept", minval = 1, maxval = 500, group = grpDisp,
                  tooltip = "Oldest boxes (and their 50% lines) are deleted once this is exceeded.")

MAX_ZONES = 300   // zones tracked in memory (BPRs + candidates)

// ======================================================================
// ZONE TYPE
// ======================================================================
type BprZone
    float top
    float bot
    int   gapBar
    bool  isLong                // true = bearish FIRST gap -> becomes a LONG BPR
    bool  bprOk   = false
    int   bprBar  = na
    bool  invalid = false
    box   bx      = na
    line  ml      = na

var array<BprZone> zones    = array.new<BprZone>()
var array<box>     boxHist  = array.new<box>()
var array<line>    lineHist = array.new<line>()

f_trackBox(box _b) =>
    array.push(boxHist, _b)
    while array.size(boxHist) > maxBoxes
        box _old = array.shift(boxHist)
        if not na(_old)
            box.delete(_old)
    true

f_trackLine(line _l) =>
    array.push(lineHist, _l)
    while array.size(lineHist) > maxBoxes
        line _old = array.shift(lineHist)
        if not na(_old)
            line.delete(_old)
    true

// ======================================================================
// GAP DETECTION (gap timeframe)
// ======================================================================
// Indices are [0]-based on the gap TF: [0] = gap's 3rd candle, [2] = 1st candle.
// Read with lookahead_off and only used on the chart bar where that gap-TF bar CLOSES.
f_gapCalc() =>
    float _atr   = ta.atr(bprAtrLen)
    bool  _inWin = not na(time(timeframe.period, bprGapSess, "America/New_York"))
    // up gap:   zone = high[2] .. low     (bullish gap)
    // down gap: zone = high    .. low[2]  (bearish gap)
    bool  _upGap = low  > high[2] and (bprAtrMult <= 0 or (low - high[2]) >= bprAtrMult * _atr)
    bool  _dnGap = high < low[2]  and (bprAtrMult <= 0 or (low[2] - high) >= bprAtrMult * _atr)
    [_upGap, low, high[2], _dnGap, low[2], high, time, _inWin, _atr, time_close]

[upGap, upTop, upBot, dnGap, dnTop, dnBot, gapTime, gapInWin, gapAtr, htfClose] = request.security(syminfo.tickerid, bprTF, f_gapCalc(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// Gap-TF bar counts -> chart bars (floored to 1, so the chart TF means plain chart bars)
string htfRes         = bprTF == "" ? timeframe.period : bprTF
float  barsPerHtf     = math.max(timeframe.in_seconds(htfRes) / timeframe.in_seconds(timeframe.period), 1)
float  lookbackScaled = bprLookback * barsPerHtf
float  zoneMaxScaled  = zoneMaxBars * barsPerHtf
int    gapSpan        = int(math.round(3 * barsPerHtf))

// ======================================================================
// 1) REGISTER GAPS + FORM BPRs
// ======================================================================
bool bprFormedLong  = false
bool bprFormedShort = false

bool newGap = not na(gapTime) and not na(htfClose) and time_close == htfClose and barstate.isconfirmed
if newGap and (upGap or dnGap)
    bool  _isLong = dnGap
    float _top    = _isLong ? dnTop : upTop
    float _bot    = _isLong ? dnBot : upBot

    // Does this new gap overlap an older OPPOSITE candidate? The older gap's zone shrinks to the overlap.
    if array.size(zones) > 0 and not na(_top) and not na(_bot)
        for j = 0 to array.size(zones) - 1
            BprZone _bz = array.get(zones, j)
            if _bz.invalid or _bz.bprOk or _bz.isLong == _isLong
                continue
            if bar_index - _bz.gapBar > lookbackScaled
                continue
            float _oTop = math.min(_bz.top, _top)
            float _oBot = math.max(_bz.bot, _bot)
            if _oTop > _oBot and (_oTop - _oBot) >= bprMinOverlap * nz(gapAtr, 0)
                // Zone Expansion pads the finished BPR. The overlap test above used the RAW gaps.
                if bprExpandMult > 0 and not na(gapAtr)
                    _oTop += gapAtr * bprExpandMult
                    _oBot -= gapAtr * bprExpandMult
                _bz.bprOk  := true
                _bz.bprBar := bar_index
                _bz.top    := _oTop
                _bz.bot    := _oBot
                color _bc   = _bz.isLong ? bullCol : bearCol
                int   _left = _bz.gapBar - gapSpan
                if na(_bz.bx)
                    _bz.bx := box.new(_left, _oTop, bar_index, _oBot, border_color = color.new(_bc, 20), bgcolor = color.new(_bc, 80), text = "BPR", text_size = size.tiny, text_color = color.new(_bc, 0), text_halign = text.align_left)
                    f_trackBox(_bz.bx)
                else
                    box.set_top(_bz.bx, _oTop)
                    box.set_bottom(_bz.bx, _oBot)
                    box.set_text(_bz.bx, "BPR")
                    box.set_border_color(_bz.bx, color.new(_bc, 20))
                    box.set_bgcolor(_bz.bx, color.new(_bc, 80))
                    box.set_text_color(_bz.bx, color.new(_bc, 0))
                if showMid
                    float _m = (_oTop + _oBot) / 2
                    _bz.ml := line.new(_left, _m, bar_index, _m, color = midCol, style = line.style_dashed, width = 1)
                    f_trackLine(_bz.ml)
                if _bz.isLong
                    bprFormedLong := true
                else
                    bprFormedShort := true

    // Register the new gap as a candidate (it can become the FIRST half of a later BPR)
    bool _winOk = not bprUseGapWindow or gapInWin
    if _winOk and not na(_top) and not na(_bot)
        BprZone _nz = BprZone.new(top = _top, bot = _bot, gapBar = bar_index + 1, isLong = _isLong)
        if showCand
            color _cc = _isLong ? color.aqua : color.red
            _nz.bx := box.new(bar_index + 1 - gapSpan, _top, bar_index, _bot, border_color = color.new(_cc, 30), bgcolor = color.new(_cc, 85), text = "BPR cand.", text_size = size.tiny, text_color = color.new(_cc, 20), text_halign = text.align_left)
            f_trackBox(_nz.bx)
        array.unshift(zones, _nz)
        if array.size(zones) > MAX_ZONES
            array.pop(zones)

// ======================================================================
// 2) EXTEND LIVE ZONES, END BROKEN / EXPIRED ONES
// ======================================================================
if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        BprZone z = array.get(zones, i)
        if z.invalid
            continue
        int _age = bar_index - z.gapBar
        // Registration bar: nothing to do on the gap's own 3rd candle
        if _age < 0
            continue

        if not na(z.bx)
            box.set_right(z.bx, bar_index)
        if not na(z.ml)
            line.set_x2(z.ml, bar_index)

        // Candidate still waiting for its overlapping opposite gap
        if not z.bprOk
            if _age > lookbackScaled
                z.invalid := true
            continue

        int _bAge = bar_index - z.bprBar
        // Broken from the bar AFTER formation: price through the FAR edge
        // Close breaks wait for the bar to close, so a live dip that recovers never ends the zone. Wick breaks stay intrabar.
        if _bAge > 0 and (bprBreakType == "Wick" or barstate.isconfirmed)
            bool _broke = z.isLong ? (bprBreakType == "Wick" ? low < z.bot : close < z.bot) : (bprBreakType == "Wick" ? high > z.top : close > z.top)
            if _broke
                z.invalid := true
                if deleteBroken
                    if not na(z.bx)
                        box.delete(z.bx)
                    if not na(z.ml)
                        line.delete(z.ml)
                continue

        if zoneMaxBars > 0 and _bAge > zoneMaxScaled
            z.invalid := true

// 3) Drop dead zones so the loop stays short
if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        if array.get(zones, i).invalid
            array.remove(zones, i)

// ======================================================================
// ALERTS
// ======================================================================
alertcondition(bprFormedLong,  "BPR Formed Long",  "New LONG BPR on {{ticker}} ({{interval}})")
alertcondition(bprFormedShort, "BPR Formed Short", "New SHORT BPR on {{ticker}} ({{interval}})")
````
