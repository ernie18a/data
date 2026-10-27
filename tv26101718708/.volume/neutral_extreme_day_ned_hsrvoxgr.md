# Neutral Extreme Day [NED]

- url: https://www.tradingview.com/script/HsrvoXgR-Neutral-Extreme-Day-NED/
- type: indicator
- pine_id: PUB;05fb560a1ae640d6919afc9cd34f3aa4
- version: 1.0

## Description

Neutral Extreme Day [NED] - Buy or Sell signal          


Signal logic:

Bullish — first 2-candle low gets taken out → next candle closes back above VWAP → fires the signal
Bearish — first 2-candle high gets broken → next candle closes back below VWAP → fires the signal

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © NeutralExtremeDay Indicator

//@version=5
indicator("Neutral Extreme Day [NED]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grp1 = "═══ Display Settings ═══"
showVWAP       = input.bool(true,  "Show VWAP Line",               group=grp1)
showRangeBox   = input.bool(true,  "Show First 2-Candle Range Box", group=grp1)
showBGColor    = input.bool(true,  "Show Background Color",         group=grp1)
showSignalLbl  = input.bool(true,  "Show Signal Labels",            group=grp1)

grp2 = "═══ Colors ═══"
bullColor      = input.color(color.new(#00e676, 0),  "Bullish Color",  group=grp2)
bearColor      = input.color(color.new(#ff1744, 0),  "Bearish Color",  group=grp2)
rangeColor     = input.color(color.new(#ffab00, 50), "Range Box Color",group=grp2)
vwapColor      = input.color(color.new(#2196F3, 0),  "VWAP Color",     group=grp2)

grp3 = "═══ Alert ═══"
alertOnBull    = input.bool(true, "Alert on Bullish Extreme", group=grp3)
alertOnBear    = input.bool(true, "Alert on Bearish Extreme", group=grp3)

// ═══════════════════════════════════════════════════════════════
//  VWAP — Anchored to session start
// ═══════════════════════════════════════════════════════════════
vwapVal = ta.vwap(hlc3)
plot(showVWAP ? vwapVal : na, "VWAP", color=vwapColor, linewidth=2, style=plot.style_line)

// ═══════════════════════════════════════════════════════════════
//  SESSION / DAY DETECTION
// ═══════════════════════════════════════════════════════════════
isNewDay = ta.change(time("D")) != 0

// ═══════════════════════════════════════════════════════════════
//  STATE VARIABLES — reset each day
// ═══════════════════════════════════════════════════════════════
var float rangeHigh    = na      // High of first 2 candles
var float rangeLow     = na      // Low of first 2 candles
var int   barCount     = 0       // Counts bars in current day
var bool  setupDone    = false   // True after 2nd bar closes
var bool  lowBroken    = false   // First 2-candle LOW swept
var bool  highBroken   = false   // First 2-candle HIGH swept
var int   dayType      = 0       // 0=undecided, 1=bullish, -1=bearish
var int   rangeBarStart = 0      // Bar index where range starts

// Range drawing objects
var box   rangeBox     = na
var line  vwapHighLine = na
var line  vwapLowLine  = na

// Reset on new day
if isNewDay
    barCount      := 0
    rangeHigh     := na
    rangeLow      := na
    setupDone     := false
    lowBroken     := false
    highBroken    := false
    dayType       := 0
    rangeBarStart := bar_index

// ═══════════════════════════════════════════════════════════════
//  BUILD FIRST 2-CANDLE RANGE
// ═══════════════════════════════════════════════════════════════
if not setupDone
    barCount += 1

    if barCount == 1
        rangeHigh := high
        rangeLow  := low

    else if barCount == 2
        rangeHigh := math.max(rangeHigh, high)
        rangeLow  := math.min(rangeLow, low)
        setupDone := true

        // Draw the range box
        if showRangeBox
            rangeBox := box.new(
             left        = rangeBarStart,
             top         = rangeHigh,
             right       = bar_index + 1,
             bottom      = rangeLow,
             bgcolor     = rangeColor,
             border_color= color.new(#ffab00, 0),
             border_width = 1)

// ═══════════════════════════════════════════════════════════════
//  SIGNAL DETECTION — after 2-candle range is locked
// ═══════════════════════════════════════════════════════════════
bool bullSignalTriggered = false
bool bearSignalTriggered = false

if setupDone and not na(rangeHigh) and not na(rangeLow)

    // ── Track if range boundaries have been broken ─────────────
    if low  < rangeLow  and not lowBroken
        lowBroken  := true

    if high > rangeHigh and not highBroken
        highBroken := true

    // ── BULLISH EXTREME UP DAY ──────────────────────────────────
    // Condition: First 2-candle LOW is broken (swept downward)
    //            AND price then closes ABOVE VWAP
    //            AND high has NOT been broken (pure low sweep)
    if lowBroken and close > vwapVal and dayType == 0
        dayType              := 1
        bullSignalTriggered  := true

        if showSignalLbl
            label.new(
             x           = bar_index,
             y           = low - (high - low) * 0.3,
             text        = "▲ BULLISH",
             style       = label.style_label_up,
             color       = bullColor,
             textcolor   = color.white,
             size        = size.normal)

    // ── BEARISH EXTREME DOWN DAY ────────────────────────────────
    // Condition: First 2-candle HIGH is broken (swept upward)
    //            AND price then closes BELOW VWAP
    //            AND low has NOT been broken (pure high sweep)
    if highBroken and close < vwapVal and dayType == 0
        dayType             := -1
        bearSignalTriggered := true

        if showSignalLbl
            label.new(
             x           = bar_index,
             y           = high + (high - low) * 0.3,
             text        = "▼ BEARISH",
             style       = label.style_label_down,
             color       = bearColor,
             textcolor   = color.white,
             size        = size.normal)

// ═══════════════════════════════════════════════════════════════
//  BACKGROUND COLOR — reflects the day bias once confirmed
// ═══════════════════════════════════════════════════════════════
bgcolor(
 showBGColor and dayType == 1  ? color.new(bullColor, 93) :
 showBGColor and dayType == -1 ? color.new(bearColor, 93) : na,
 title = "Day Type Background")

// ═══════════════════════════════════════════════════════════════
//  STATUS TABLE — top-right corner
// ═══════════════════════════════════════════════════════════════
var table statusTable = table.new(position.top_right, 2, 4,
 bgcolor       = color.new(#1a1a2e, 10),
 border_color  = color.new(#ffffff, 60),
 border_width  = 1,
 frame_color   = color.new(#ffffff, 40),
 frame_width   = 1)

if barstate.islast
    // Header
    table.cell(statusTable, 0, 0, "NED INDICATOR",
     text_color  = color.white,
     text_size   = size.small,
     bgcolor     = color.new(#1a1a2e, 0),
     text_halign = text.align_center)
    table.merge_cells(statusTable, 0, 0, 1, 0)

    // Range row
    table.cell(statusTable, 0, 1, "2-Bar Range",
     text_color  = color.new(#aaaaaa, 0),
     text_size   = size.small,
     bgcolor     = color.new(#1a1a2e, 20))
    table.cell(statusTable, 1, 1,
     setupDone ? str.tostring(rangeLow, "#.##") + " — " + str.tostring(rangeHigh, "#.##") : "Building...",
     text_color  = color.white,
     text_size   = size.small,
     bgcolor     = color.new(#1a1a2e, 20))

    // Low Broken row
    table.cell(statusTable, 0, 2, "Low Swept",
     text_color  = color.new(#aaaaaa, 0),
     text_size   = size.small,
     bgcolor     = color.new(#1a1a2e, 30))
    table.cell(statusTable, 1, 2,
     lowBroken ? "✓ YES" : "✗ NO",
     text_color  = lowBroken ? bullColor : color.new(#aaaaaa, 0),
     text_size   = size.small,
     bgcolor     = color.new(#1a1a2e, 30))

    // High Broken row
    table.cell(statusTable, 0, 3, "High Swept",
     text_color  = color.new(#aaaaaa, 0),
     text_size   = size.small,
     bgcolor     = color.new(#1a1a2e, 40))
    table.cell(statusTable, 1, 3,
     highBroken ? "✓ YES" : "✗ NO",
     text_color  = highBroken ? bearColor : color.new(#aaaaaa, 0),
     text_size   = size.small,
     bgcolor     = color.new(#1a1a2e, 40))

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(bullSignalTriggered,
 title   = "Bullish Extreme Up Day",
 message = "🟢 BULLISH — Low of first 2 candles swept, price now above VWAP.")

alertcondition(bearSignalTriggered,
 title   = "Bearish Extreme Down Day",
 message = "🔴 BEARISH EXTREME DOWN DAY — High of first 2 candles swept, price now below VWAP.")
````
