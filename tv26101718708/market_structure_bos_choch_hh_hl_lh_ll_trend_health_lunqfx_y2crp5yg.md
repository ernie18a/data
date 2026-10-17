# Market Structure BOS, CHoCH, HH HL LH LL & Trend Health [LunqFX]

- url: https://www.tradingview.com/script/Y2cRp5yG-Market-Structure-BOS-CHoCH-HH-HL-LH-LL-Trend-Health-LunqFX/
- type: indicator
- pine_id: PUB;14394d3370cc4216a172dc4edd471067
- version: 1.0

## Description

Market structure is the skeleton of every trend: a series of higher highs and higher lows, or lower highs and lower lows, until a break says the trend has changed. This indicator maps that skeleton automatically — labelling every swing as HH, HL, LH or LL, drawing each Break of Structure (BOS) and Change of Character (CHoCH) — and adds one thing no other structure tool has: it tells you the trend is failing BEFORE the structure actually breaks.

❶ THE STRUCTURE MAP

▸ SWING LABELS — every confirmed swing point is labelled HH (higher high), HL (higher low), LH (lower high) or LL (lower low). The sequence of those four labels IS the trend, and having it on the chart removes the guesswork from reading price action.

▸ BOS — Break of Structure. Price closes through the last swing level in the direction of the trend: the trend is continuing. Drawn as a dashed line from the broken level with a BOS label.

▸ CHoCH — Change of Character. Price closes through the last swing level against the trend: the trend has flipped. Drawn as a solid, highlighted line — this is the reversal signal smart-money traders wait for.

▸ STRUCTURE CANDLES — the candles themselves are coloured by the structural trend, not by whether each bar closed up or down. Green means the market structure is bullish, violet means bearish, so the regime is obvious at a single glance. Their brightness fades as Trend Health falls.

❷ TREND HEALTH 0–100 — THE EARLY WARNING

Every other structure tool tells you a trend has ended after CHoCH prints. By then the move is already gone. Trend Health measures the two things that decay before every structure break:

▸ EXPANSION — in a healthy trend each new extreme clears the previous one by at least as much as the last leg did. When new highs barely exceed the old ones, the trend is running out of fuel.

▸ RETRACEMENT — in a healthy trend pullbacks stay shallow. When each pullback eats deeper into the previous leg, control is shifting to the other side.

Both are measured on the live leg, normalised by ATR so the score behaves the same on any symbol and timeframe, and blended into a single 0–100 reading. When it drops below your threshold the dashboard flags WEAKENING — while the trend is still technically intact. That is the warning CHoCH cannot give you, because CHoCH is confirmation, not anticipation.

❸ THE STRUCTURE TAPE

Instead of a table of numbers, the dashboard shows a timeline of the last five structure events, oldest to newest: BOS ▲ · BOS ▲ · CHoCH ▼ · BOS ▼. Reading the sequence tells you instantly whether the market is trending cleanly (a run of BOS in one direction) or chopping (CHoCH flipping back and forth) — context you cannot get from a single label on the chart.

❹ HOW TO TRADE IT

1 — Establish the bias from MARKET STRUCTURE in the panel. Bullish structure = look for longs, bearish = look for shorts. Do not fight it.

2 — Use BOS as continuation. A BOS in the direction of your bias confirms the trend is intact; the broken level often becomes support or resistance on the retest.

3 — Use CHoCH as the reversal trigger. A CHoCH against the prevailing trend is the earliest confirmed signal that structure has flipped. Wait for it before trading a reversal.

4 — Use TREND HEALTH for timing and risk. Health above 65 with a run of BOS on the tape = a clean trend, hold your position and trail. Health falling into WEAKENING = tighten stops, take partials, and stop adding — the structure is decaying and a CHoCH becomes more likely.

5 — Read the tape for market state. Several BOS in a row = trending market, trade continuations. Alternating CHoCH = choppy market, stand aside or trade the range instead.

❺ HOW IT WORKS

Swing points come from confirmed pivots, so a swing only exists once the bars on both sides of it have closed. The most recent swing high and swing low become the active structure levels. When a bar CLOSES beyond one of them (a wick-based mode is available), the break is registered: in the direction of the current trend it is a BOS, against it a CHoCH, and the trend state flips. Trend Health compares the size of the current expansion leg with the previous one in ATR units, and the depth of the latest pullback against the leg it retraced, then blends them 60/40 into the 0–100 score. Immediately after a CHoCH there is no second leg to compare yet, so the panel honestly reports NEW TREND instead of a misleading health reading.

Works on every symbol and timeframe — forex, gold, indices, crypto and stocks — because every threshold is either structural or ATR-normalised, with nothing to configure per market.

SETTINGS — swing length (how major a swing must be), break on close or wick, the health threshold that flags weakening, swing labels and BOS/CHoCH lines on/off, number of events kept, structure candles on/off, and dashboard position.

ALERTS — BOS up, BOS down, CHoCH up, CHoCH down, and Structure Weakening (the early warning).

NON-REPAINTING — swings are built from confirmed pivots and every break is validated on bar close. A label or line that has printed never moves or disappears.

Every component here describes the same object — the market's structure — at a different resolution: the swings build it, BOS and CHoCH break it, Trend Health measures its condition, and the tape is its history. That is why they belong in one tool rather than five.

This indicator is an educational market-analysis tool, not financial advice. Trend Health describes the current structure's condition and does not predict future prices. Always confirm with your own analysis and manage your risk.

Pre-publish checklist

## Source Code

````pine
//@version=6
// ============================================================================
//  Market Structure — BOS, CHoCH, HH/HL/LH/LL & Trend Health [LunqFX]
// ----------------------------------------------------------------------------
//  Market structure, read the way a smart-money trader reads it — and one thing
//  no other structure tool does: it warns you BEFORE the structure breaks.
//
//  • SWING MAP — every confirmed swing is labelled HH, HL, LH or LL, so the
//    trend's skeleton is on the chart at a glance.
//  • BOS / CHoCH — a close through the last swing level is a Break of Structure
//    (continuation) or a Change of Character (reversal), drawn and labelled.
//  • TREND HEALTH 0-100  ← the original part. Every trend decays before it
//    breaks: new highs stop expanding and pullbacks get deeper. Health measures
//    exactly those two things on the live leg, so you get a WEAKENING warning
//    while the trend is still technically intact — before CHoCH confirms it.
//  • STRUCTURE TAPE — the last structure events as a timeline, so you can read
//    the sequence (BOS → BOS → CHoCH) instead of guessing from the chart.
//
//  Every component describes the SAME thing — the market's structure — at a
//  different resolution: the swings build it, BOS/CHoCH break it, Health
//  measures its condition, and the tape is its history. That is why they
//  belong in one tool.
//
//  NON-REPAINTING: swings come from confirmed pivots (closed bars) and every
//  break is validated on bar close. Nothing is redrawn after the fact.
// ============================================================================
indicator("Market Structure — BOS, CHoCH, HH/HL/LH/LL & Trend Health [LunqFX]",
     "Market Structure [LunqFX]", overlay = true,
     max_labels_count = 500, max_lines_count = 500)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE — built for a LIGHT chart (pale cyan → white gradient).
//  Rule: on a light background contrast comes from DARKNESS, and the hues are
//  kept far from the background's cyan family. Weak structure = pale (close to
//  the background), strong structure = deep and saturated.
// ─────────────────────────────────────────────────────────────────────────
BULL      = #2E7D32          // deep forest green — lines & candles on light bg
BULL_DEEP = #1B5E20          // darkest, edges
BULL_PALE = #A5D6A7          // pale, low trend health
BULL_TXT  = #6BE79B          // bright — text sitting ON dark cards
BEAR      = #C62828          // deep brick red (cyan's complement zone: pops)
BEAR_DEEP = #8E1A1A
BEAR_PALE = #EF9A9A
BEAR_TXT  = #FF8F8F
AMBER     = #E9962B          // warning on dark card
INK       = #10151C          // dark label plate
CARD      = #141A22          // dark floating panel on a light chart
TXT       = #F2F5F8
MUTE      = #97A3B2

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gS      = "Structure"
swLen   = input.int(10, "Swing length", minval = 2, maxval = 60, group = gS, tooltip = "Higher = only major swings count as structure.")
useClose= input.bool(true, "Break on close", group = gS, tooltip = "ON = a bar must CLOSE through the level. OFF = a wick is enough.")

gH      = "Trend Health"
weakLvl = input.int(40, "Weakening below", minval = 10, maxval = 70, group = gH, tooltip = "Health under this value flags the trend as weakening — an early warning before CHoCH.")

gV      = "Visuals"
showSw  = input.bool(true, "Swing labels (HH / HL / LH / LL)", group = gV)
showBrk = input.bool(true, "BOS / CHoCH lines", group = gV)
keepN   = input.int(14, "Structure events kept", minval = 4, maxval = 60, group = gV)
candOn  = input.bool(true, "Structure candles", group = gV, tooltip = "Candles coloured by the structural trend, brightness by Trend Health.")

gP      = "Dashboard"
showHUD = input.bool(true, "Show structure tape", group = gP)
hudPos  = input.string("Bottom Center","Position", options=["Bottom Center","Top Center","Top Right","Bottom Right","Bottom Left"], group = gP)

// ─────────────────────────────────────────────────────────────────────────
//  SWINGS
// ─────────────────────────────────────────────────────────────────────────
atr14 = ta.atr(14)
ph = ta.pivothigh(swLen, swLen)
pl = ta.pivotlow(swLen, swLen)

var array<float> shArr = array.new<float>()
var array<float> slArr = array.new<float>()
var array<label> swLbs = array.new<label>()

// structure levels currently in play
var float structHigh = na
var int   structHighB = na
var bool  highUsed = false
var float structLow = na
var int   structLowB = na
var bool  lowUsed = false
var int   trend = 0

if not na(ph)
    prevH = array.size(shArr) > 0 ? array.get(shArr, array.size(shArr) - 1) : na
    array.push(shArr, ph)
    if array.size(shArr) > 5
        array.shift(shArr)
    structHigh  := ph
    structHighB := bar_index - swLen
    highUsed    := false
    if showSw and not na(prevH)
        isHH = ph > prevH
        l = label.new(bar_index - swLen, ph, " " + (isHH ? "HH" : "LH") + " ", style = label.style_label_down, color = color.new(INK, 12), textcolor = isHH ? BULL_TXT : BEAR_TXT, size = size.large)
        array.push(swLbs, l)
        while array.size(swLbs) > keepN * 3
            label.delete(array.shift(swLbs))

if not na(pl)
    prevL = array.size(slArr) > 0 ? array.get(slArr, array.size(slArr) - 1) : na
    array.push(slArr, pl)
    if array.size(slArr) > 5
        array.shift(slArr)
    structLow  := pl
    structLowB := bar_index - swLen
    lowUsed    := false
    if showSw and not na(prevL)
        isHL = pl > prevL
        l = label.new(bar_index - swLen, pl, " " + (isHL ? "HL" : "LL") + " ", style = label.style_label_up, color = color.new(INK, 12), textcolor = isHL ? BULL_TXT : BEAR_TXT, size = size.large)
        array.push(swLbs, l)
        while array.size(swLbs) > keepN * 3
            label.delete(array.shift(swLbs))

// ─────────────────────────────────────────────────────────────────────────
//  BOS / CHoCH  (confirmed bars only)
// ─────────────────────────────────────────────────────────────────────────
var array<line>  brkLn = array.new<line>()
var array<label> brkLb = array.new<label>()
var array<string> evT = array.new<string>()      // "BOS" / "CHoCH"
var array<int>    evD = array.new<int>()         // 1 up, -1 down

pushEvent(string t, int d) =>
    array.push(evT, t)
    array.push(evD, d)
    while array.size(evT) > keepN
        array.shift(evT)
        array.shift(evD)

drawBreak(float lvl, int b0, bool up, bool isChoch) =>
    if showBrk
        col = up ? BULL : BEAR
        ln = line.new(b0, lvl, bar_index, lvl, color = color.new(col, isChoch ? 0 : 30), width = isChoch ? 3 : 2, style = isChoch ? line.style_solid : line.style_dashed)
        array.push(brkLn, ln)
        // CHoCH: solid deep plate + white text. BOS: dark plate + bright text.
        txtC = up ? BULL_TXT : BEAR_TXT
        lb = label.new(math.round(math.avg(b0, bar_index)), lvl, isChoch ? " CHoCH " : " BOS ", style = label.style_label_center, color = color.new(isChoch ? col : INK, isChoch ? 0 : 10), textcolor = isChoch ? color.white : txtC, size = size.large)
        array.push(brkLb, lb)
        while array.size(brkLn) > keepN
            line.delete(array.shift(brkLn))
        while array.size(brkLb) > keepN
            label.delete(array.shift(brkLb))

bosUp   = false
bosDn   = false
chochUp = false
chochDn = false
var int legCount = 0        // continuation breaks since the trend flipped

srcUp = useClose ? close : high
srcDn = useClose ? close : low

if barstate.isconfirmed
    if not na(structHigh) and not highUsed and srcUp > structHigh
        highUsed := true
        isC = trend == -1
        if isC
            chochUp := true
            legCount := 0
        else
            bosUp := true
            legCount += 1
        trend := 1
        drawBreak(structHigh, structHighB, true, isC)
        pushEvent(isC ? "CHoCH" : "BOS", 1)
    if not na(structLow) and not lowUsed and srcDn < structLow
        lowUsed := true
        isC = trend == 1
        if isC
            chochDn := true
            legCount := 0
        else
            bosDn := true
            legCount += 1
        trend := -1
        drawBreak(structLow, structLowB, false, isC)
        pushEvent(isC ? "CHoCH" : "BOS", -1)

// ─────────────────────────────────────────────────────────────────────────
//  TREND HEALTH 0-100  — the original engine
//  Two things decay before every structure break:
//    expansion  — each new extreme should exceed the last by MORE than before
//    retracement— pullbacks into the leg should stay shallow
//  Health blends both. It falls while the trend is still technically intact,
//  which is the early warning CHoCH cannot give you.
// ─────────────────────────────────────────────────────────────────────────
health = 50.0
if array.size(shArr) >= 3 and array.size(slArr) >= 3 and atr14 > 0
    nH = array.size(shArr)
    nL = array.size(slArr)
    h1 = array.get(shArr, nH - 1)
    h2 = array.get(shArr, nH - 2)
    h3 = array.get(shArr, nH - 3)
    l1 = array.get(slArr, nL - 1)
    l2 = array.get(slArr, nL - 2)
    l3 = array.get(slArr, nL - 3)
    if trend >= 0
        e1   = (h1 - h2) / atr14
        e2   = math.max((h2 - h3) / atr14, 0.25)
        // graded, not a hard zero: full expansion = 100, none = ~33, contraction = 0
        expS = math.max(0.0, math.min(1.0, (e1 / e2 + 0.5) / 1.5)) * 100.0
        leg  = math.max(h1 - l2, syminfo.mintick)
        retr = (h1 - l1) / leg
        rS   = math.max(0.0, math.min(1.0, (1.0 - retr) / 0.6)) * 100.0
        health := 0.6 * expS + 0.4 * rS
    else
        e1   = (l2 - l1) / atr14
        e2   = math.max((l3 - l2) / atr14, 0.25)
        expS = math.max(0.0, math.min(1.0, (e1 / e2 + 0.5) / 1.5)) * 100.0
        leg  = math.max(h2 - l1, syminfo.mintick)
        retr = (h1 - l1) / leg
        rS   = math.max(0.0, math.min(1.0, (1.0 - retr) / 0.6)) * 100.0
        health := 0.6 * expS + 0.4 * rS

healthR  = math.round(math.max(0, math.min(100, health)))
// a freshly flipped trend has no second leg yet — nothing to measure decay on,
// so it is reported as NEW TREND instead of a false "weakening" reading
newTrend  = trend != 0 and legCount < 1
weakening = trend != 0 and not newTrend and healthR < weakLvl
justWeak  = weakening and not weakening[1]

// ─────────────────────────────────────────────────────────────────────────
//  STRUCTURE CANDLES — trend by colour, health by brightness
// ─────────────────────────────────────────────────────────────────────────
// on a light chart a weak trend fades toward the background (pale) and a strong
// one deepens — the opposite of a dark theme
hFrac  = healthR / 100.0
cBody  = trend > 0 ? color.from_gradient(hFrac, 0, 1, BULL_PALE, BULL) : trend < 0 ? color.from_gradient(hFrac, 0, 1, BEAR_PALE, BEAR) : #9AA6B4
cEdge  = trend > 0 ? BULL_DEEP : trend < 0 ? BEAR_DEEP : #6B7684
plotcandle(candOn ? open : na, high, low, close, title = "Structure Candles", color = cBody, wickcolor = cEdge, bordercolor = cEdge)

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD — a horizontal STRUCTURE TAPE, not a stats table
// ─────────────────────────────────────────────────────────────────────────
hudPosition(string s) =>
    switch s
        "Bottom Center" => position.bottom_center
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Bottom Right"  => position.bottom_right
        => position.bottom_left

var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    TAPE = 5
    hud := table.new(hudPosition(hudPos), 3 + TAPE, 2, bgcolor = CARD, border_color = color.new(#2A313D, 0), border_width = 1, frame_width = 0)

    tCol = trend > 0 ? BULL_TXT : trend < 0 ? BEAR_TXT : MUTE
    tTx  = trend > 0 ? "▲ BULLISH" : trend < 0 ? "▼ BEARISH" : "— NEUTRAL"
    hCol = healthR >= 65 ? BULL_TXT : healthR >= weakLvl ? AMBER : BEAR_TXT
    sTx  = trend == 0 ? "NO STRUCTURE" : newTrend ? "NEW TREND" : weakening ? "WEAKENING" : healthR >= 65 ? "STRONG" : "HOLDING"
    sCol = trend == 0 ? MUTE : newTrend ? (trend > 0 ? BULL_TXT : BEAR_TXT) : weakening ? AMBER : healthR >= 65 ? BULL_TXT : TXT

    table.cell(hud, 0, 0, "  MARKET STRUCTURE  ", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = CARD)
    table.cell(hud, 0, 1, "  " + tTx + "  ", text_color = tCol, text_size = size.huge, text_halign = text.align_left, bgcolor = CARD)

    table.cell(hud, 1, 0, "  TREND HEALTH  ", text_color = MUTE, text_size = size.normal, text_halign = text.align_center, bgcolor = CARD)
    table.cell(hud, 1, 1, "  " + str.tostring(healthR) + "  ", text_color = hCol, text_size = size.huge, text_halign = text.align_center, bgcolor = CARD)

    table.cell(hud, 2, 0, "  STATE  ", text_color = MUTE, text_size = size.normal, text_halign = text.align_center, bgcolor = CARD)
    table.cell(hud, 2, 1, "  " + sTx + "  ", text_color = weakening ? INK : sCol, text_size = size.large, text_halign = text.align_center, bgcolor = weakening ? AMBER : CARD)

    // the tape: oldest → newest, left to right
    n = array.size(evT)
    for k = 0 to TAPE - 1
        idx = n - TAPE + k
        c = 3 + k
        table.cell(hud, c, 0, k == 0 ? "  STRUCTURE TAPE  " : " ", text_color = MUTE, text_size = size.normal, text_halign = text.align_center, bgcolor = CARD)
        if idx >= 0 and idx < n
            t = array.get(evT, idx)
            d = array.get(evD, idx)
            isC = t == "CHoCH"
            chipBg = d > 0 ? BULL : BEAR
            chipTx = d > 0 ? BULL_TXT : BEAR_TXT
            table.cell(hud, c, 1, "  " + t + (d > 0 ? " ▲  " : " ▼  "), text_color = isC ? color.white : chipTx, text_size = size.large, text_halign = text.align_center, bgcolor = isC ? chipBg : color.new(chipBg, 70))
        else
            table.cell(hud, c, 1, "  ·  ", text_color = MUTE, text_size = size.large, text_halign = text.align_center, bgcolor = CARD)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(bosUp,    "BOS up",            "LunqFX Market Structure: bullish Break of Structure")
alertcondition(bosDn,    "BOS down",          "LunqFX Market Structure: bearish Break of Structure")
alertcondition(chochUp,  "CHoCH up",          "LunqFX Market Structure: bullish Change of Character — trend flipped up")
alertcondition(chochDn,  "CHoCH down",        "LunqFX Market Structure: bearish Change of Character — trend flipped down")
alertcondition(justWeak, "Structure weakening","LunqFX Market Structure: trend health dropped — structure weakening, reversal risk rising")
````
