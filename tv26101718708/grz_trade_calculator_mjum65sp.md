# GRZ: Trade Calculator

- url: https://www.tradingview.com/script/MJum65Sp-GRZ-Trade-Calculator/
- type: indicator
- pine_id: PUB;ac03cc757e714284b21df3487e2921d0
- version: 1.0

## Description

GRZ: Trade Calculator is an advanced trade management and risk visualization indicator designed for leveraged trading and active position management.

The indicator allows traders to manually define entry price, position size, leverage, multiple stop losses, and take profit targets directly on the chart. It automatically calculates projected profit and loss values for each level based on trade direction and displays them using dynamic right-aligned lines and detailed chart labels.

The script supports multi-stage stop loss management, including optional automatic hiding of SL1 after it has been hit and dynamic reduction of active trade size after partial stop execution. Remaining position size, realized losses, and adjusted profit targets are recalculated automatically in real time.

Visual line colours update dynamically based on whether the active trade is currently in profit or loss, while configurable label formatting displays exact PNL values, close sizes, and target prices for entries, stop losses, and take profits.

This indicator is designed for traders who want a clear visual representation of active trade structure, risk exposure, partial stop management, and projected outcomes directly on the TradingView chart while managing high leverage or scaled positions.

## Source Code

````pine
//@version=6
indicator("GRZ: Trade Calculator", overlay=true, max_lines_count=50, max_labels_count=50)

//────────────────────────────────────
// INPUTS
//────────────────────────────────────
groupTrade = "Trade Setup"
groupSL    = "Stop Loss"
groupTP    = "Take Profit"
groupLines = "Line Style"
groupTags  = "Line Tags"
groupAuto  = "Auto SL Management"

tradeDirection = input.string("Long", "Trade Direction", options=["Long", "Short"], group=groupTrade)
entryPrice     = input.float(0.0, "Entry Price", step=0.0001, group=groupTrade)
entryUsd       = input.float(0.0, "Entry USD", step=0.01, group=groupTrade)
leverage       = input.float(200.0, "Leverage", step=1.0, minval=1.0, group=groupTrade)

// SL
sl1    = input.float(0.0, "SL 1 Price", step=0.0001, group=groupSL)
sl1Usd = input.float(0.0, "SL 1 Close USD", step=0.01, group=groupSL)

sl2    = input.float(0.0, "SL 2 Price", step=0.0001, group=groupSL)
sl2Usd = input.float(0.0, "SL 2 USD", step=0.01, group=groupSL)

// TP
tp1    = input.float(0.0, "TP 1 Price", step=0.0001, group=groupTP)
tp1Usd = input.float(0.0, "TP 1 USD (0 = active trade size)", step=0.01, group=groupTP)

tp2    = input.float(0.0, "TP 2 Price", step=0.0001, group=groupTP)
tp2Usd = input.float(0.0, "TP 2 USD (0 = active trade size)", step=0.01, group=groupTP)

// Auto SL management
autoHideSL1AfterHit = input.bool(true, "Hide SL1 After Hit", group=groupAuto)
reduceTradeAfterSL1 = input.bool(true, "Reduce Trade Size After SL1 Hit", group=groupAuto)
resetSL1State       = input.bool(false, "Reset SL1 Hit State", group=groupAuto)

// Line style
entryColor     = input.color(color.blue, "Entry Line Color", group=groupLines)
entryProfitCol = input.color(color.green, "Entry Profit Color", group=groupLines)
entryLossCol   = input.color(color.red, "Entry Loss Color", group=groupLines)
slColor        = input.color(color.red, "Stop Loss Color", group=groupLines)
tpColor        = input.color(color.green, "Take Profit Color", group=groupLines)

entryWidth = input.int(2, "Entry Line Width", minval=1, maxval=5, group=groupLines)
slWidth    = input.int(2, "SL Line Width", minval=1, maxval=5, group=groupLines)
tpWidth    = input.int(2, "TP Line Width", minval=1, maxval=5, group=groupLines)

altOpacity   = input.int(40, "Secondary Line Opacity", minval=0, maxval=100, group=groupLines)
lineBarsWide = input.int(120, "Line Length (bars)", minval=10, maxval=500, group=groupLines)
rightOffset  = input.int(30, "Right Offset (bars)", minval=0, maxval=200, group=groupLines)

// Tag style
showLineTags = input.bool(true, "Show Line Tags", group=groupTags)
tagSide      = input.string("Left", "Tag Position", options=["Left", "Right"], group=groupTags)
tagTextColor = input.color(color.white, "Tag Text Color", group=groupTags)
tagOffset    = input.int(2, "Tag Offset", minval=0, maxval=50, group=groupTags)

//────────────────────────────────────
// HELPERS
//────────────────────────────────────
f_money(x) =>
    "$" + str.tostring(x, "#.##")

f_money_signed(x) =>
    x > 0 ? "+$" + str.tostring(x, "#.##") : x < 0 ? "-$" + str.tostring(math.abs(x), "#.##") : "$0.00"

f_price(x) =>
    str.tostring(x, format.mintick)

f_pnl(bool isLong, float usd, float entry, float target) =>
    qty = entry > 0 ? usd / entry : na
    isLong ? qty * (target - entry) : qty * (entry - target)

f_tag_text(string prefix, float price, float usdAmount, float pnl) =>
    prefix + " " + f_money_signed(pnl) + " / " + f_money(usdAmount) + " - " + f_price(price)

f_tag_bar(int startBar, int endBar, int offset) =>
    tagSide == "Left" ? startBar - offset : endBar + offset

f_tag_style() =>
    tagSide == "Left" ? label.style_label_right : label.style_label_left

//────────────────────────────────────
// CALCS
//────────────────────────────────────
isLong     = tradeDirection == "Long"
validEntry = entryPrice > 0 and entryUsd > 0

sl1CloseUsd = math.min(math.max(sl1Usd, 0.0), entryUsd)

// Persistent SL1 hit state
var bool sl1Hit = false
var bool prevReset = false

if resetSL1State != prevReset
    sl1Hit := false
    prevReset := resetSL1State

sl1HitNow = validEntry and sl1 > 0 and not sl1Hit and barstate.isrealtime and (isLong ? low <= sl1 : high >= sl1)

if sl1HitNow
    sl1Hit := true

activeEntryUsd = reduceTradeAfterSL1 and sl1Hit ? math.max(entryUsd - sl1CloseUsd, 0.0) : entryUsd

livePnl = validEntry ? f_pnl(isLong, activeEntryUsd, entryPrice, close) : na

tp1SizeUsd = tp1Usd > 0 ? tp1Usd : activeEntryUsd
tp2SizeUsd = tp2Usd > 0 ? tp2Usd : activeEntryUsd

// SL1: PNL uses FULL trade size, label shows close size
sl1PnlFull = validEntry and sl1 > 0 ? f_pnl(isLong, entryUsd, entryPrice, sl1) : na

// SL2: assumes SL1 has already closed sl1Usd, remaining position closes at SL2
sl2RemainingUsd = math.max(entryUsd - sl1CloseUsd, 0.0)
sl1RealizedPnl  = validEntry and sl1 > 0 and sl1CloseUsd > 0 ? f_pnl(isLong, sl1CloseUsd, entryPrice, sl1) : 0.0
sl2TotalPnl     = validEntry and sl2 > 0 ? sl1RealizedPnl + f_pnl(isLong, sl2RemainingUsd, entryPrice, sl2) : na

entryActiveColor = not validEntry ? entryColor : livePnl >= 0 ? entryProfitCol : entryLossCol

showSL1 = sl1 > 0 and not (autoHideSL1AfterHit and sl1Hit)

//────────────────────────────────────
// RIGHT-ALIGNED LINES
//────────────────────────────────────
lineEndBar   = bar_index + rightOffset
lineStartBar = math.max(0, lineEndBar - lineBarsWide)

tagBar   = f_tag_bar(lineStartBar, lineEndBar, tagOffset)
tagStyle = f_tag_style()

var line entryLine = na
var line sl1Line   = na
var line sl2Line   = na
var line tp1Line   = na
var line tp2Line   = na

var label entryTag = na
var label sl1Tag   = na
var label sl2Tag   = na
var label tp1Tag   = na
var label tp2Tag   = na

if barstate.islast
    line.delete(entryLine)
    line.delete(sl1Line)
    line.delete(sl2Line)
    line.delete(tp1Line)
    line.delete(tp2Line)

    label.delete(entryTag)
    label.delete(sl1Tag)
    label.delete(sl2Tag)
    label.delete(tp1Tag)
    label.delete(tp2Tag)

    if validEntry
        entryLine := line.new(lineStartBar, entryPrice, lineEndBar, entryPrice, color=entryActiveColor, width=entryWidth)

        if showLineTags
            entryTag := label.new(
                tagBar,
                entryPrice,
                f_tag_text("Entry", entryPrice, activeEntryUsd, livePnl),
                xloc=xloc.bar_index,
                style=tagStyle,
                textcolor=tagTextColor,
                color=color.new(entryActiveColor, 0)
            )

    if showSL1
        sl1Line := line.new(lineStartBar, sl1, lineEndBar, sl1, color=slColor, width=slWidth)

        if showLineTags
            sl1Tag := label.new(
                tagBar,
                sl1,
                f_tag_text("SL", sl1, sl1CloseUsd, sl1PnlFull),
                xloc=xloc.bar_index,
                style=tagStyle,
                textcolor=tagTextColor,
                color=color.new(slColor, 0)
            )

    if sl2 > 0
        sl2Line := line.new(lineStartBar, sl2, lineEndBar, sl2, color=color.new(slColor, altOpacity), width=slWidth)

        if showLineTags
            sl2Tag := label.new(
                tagBar,
                sl2,
                f_tag_text("SL", sl2, sl2RemainingUsd, sl2TotalPnl),
                xloc=xloc.bar_index,
                style=tagStyle,
                textcolor=tagTextColor,
                color=color.new(slColor, altOpacity)
            )

    if tp1 > 0
        tp1Line := line.new(lineStartBar, tp1, lineEndBar, tp1, color=tpColor, width=tpWidth)

        if showLineTags
            tp1Tag := label.new(
                tagBar,
                tp1,
                f_tag_text("TP", tp1, tp1SizeUsd, f_pnl(isLong, tp1SizeUsd, entryPrice, tp1)),
                xloc=xloc.bar_index,
                style=tagStyle,
                textcolor=tagTextColor,
                color=color.new(tpColor, 0)
            )

    if tp2 > 0
        tp2Line := line.new(lineStartBar, tp2, lineEndBar, tp2, color=color.new(tpColor, altOpacity), width=tpWidth)

        if showLineTags
            tp2Tag := label.new(
                tagBar,
                tp2,
                f_tag_text("TP", tp2, tp2SizeUsd, f_pnl(isLong, tp2SizeUsd, entryPrice, tp2)),
                xloc=xloc.bar_index,
                style=tagStyle,
                textcolor=tagTextColor,
                color=color.new(tpColor, altOpacity)
            )
````
