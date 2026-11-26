# CREA DOM v.1.0

- url: https://www.tradingview.com/script/pxPuOXkW-CREA-DOM-v-1-0/
- type: indicator
- pine_id: PUB;85f4515228f2433690a676c78551a275
- version: 1.0

## Description

A right-anchored Depth of Market ladder for the current pane, showing 10 price levels above and 10 below the current price. Bid and ask volume are estimated from bar data (buy/sell volume proxy) and displayed as horizontal bars growing outward from the centre price column — bids to the left in cyan, asks to the right in red. The current price row is always highlighted. Volume numbers are shown on each side, level spacing is ATR-derived and snapped to the instrument's tick size, and a bid/ask imbalance indicator is displayed at the bottom. Font sizes for row labels, the current price, and the header are independently configurable from the settings panel.

Note: True Level 2 data requires a broker-integrated feed or a premium TradingView plan with DOM access. This indicator synthesises depth from bar volume using exponential decay — it reflects directional pressure, not real order book data.

## Source Code

````pine
//@version=6
indicator("CREA DOM", overlay=false,
     max_labels_count=500, max_boxes_count=500, max_lines_count=500)

// ═══════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════
var g = "DOM Settings"
domLevels   = input.int(10,    "Levels above/below",  minval=5,  maxval=20, group=g)
volSmooth   = input.int(3,     "Volume smooth",        minval=1,  maxval=10, group=g)
showVolNums = input.bool(true, "Show volume numbers",  group=g)
showImb     = input.bool(true, "Show imbalance label", group=g)

// ── Font size inputs ───────────────────────────────────
// Pine's label sizes are an enum (tiny/small/normal/large/huge).
// We expose two separate controls:
//   • one for the regular rows (price + volume numbers)
//   • one for the current-price row so it can be kept larger
var gf = "Font Sizes"
fontRowStr  = input.string("tiny",   "Row labels",          
     options=["tiny","small","normal","large","huge"], group=gf,
     tooltip="Font size for all price/volume labels in the DOM ladder")
fontCurrStr = input.string("small",  "Current price label", 
     options=["tiny","small","normal","large","huge"], group=gf,
     tooltip="Font size for the highlighted current-price row")
fontHdrStr  = input.string("tiny",   "Header / footer",     
     options=["tiny","small","normal","large","huge"], group=gf,
     tooltip="Font size for the DEPTH OF MARKET header and imbalance footer")

// Convert string → Pine size constant via a helper function
sizeFromStr(s) =>
    switch s
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        "huge"   => size.huge
        => size.tiny   // fallback

szRow  = sizeFromStr(fontRowStr)
szCurr = sizeFromStr(fontCurrStr)
szHdr  = sizeFromStr(fontHdrStr)

var gc = "Colors"
colBid     = input.color(color.new(#00b4d8, 0),  "Bid color",      group=gc)
colAsk     = input.color(color.new(#ef4343, 0),  "Ask color",      group=gc)
colCurrent = input.color(color.new(#ffffff, 0),  "Current price",  group=gc)
colAbove   = input.color(color.new(#ef4343, 40), "Ask price text", group=gc)
colBelow   = input.color(color.new(#00b4d8, 40), "Bid price text", group=gc)
colHeader  = input.color(color.new(#5c6370, 0),  "Header color",   group=gc)

// ═══════════════════════════════════════════════════════
//  VOLUME DELTA ESTIMATION
// ═══════════════════════════════════════════════════════
candleRange = high - low
buyVol  = candleRange == 0 ? volume * 0.5 : volume * (close - low)  / candleRange
sellVol = candleRange == 0 ? volume * 0.5 : volume * (high - close) / candleRange
buyVolSm   = ta.ema(buyVol,  volSmooth)
sellVolSm  = ta.ema(sellVol, volSmooth)

// ═══════════════════════════════════════════════════════
//  ATR — level spacing
// ═══════════════════════════════════════════════════════
atr14   = ta.atr(14)
tickSz  = syminfo.mintick
lvlStep = math.max(math.round(atr14 * 0.012 / tickSz) * tickSz, tickSz)

// ═══════════════════════════════════════════════════════
//  PERSISTENT DRAWING OBJECTS
// ═══════════════════════════════════════════════════════
ROWS_MAX = 41

var bidBars     = array.new_box(ROWS_MAX,   na)
var askBars     = array.new_box(ROWS_MAX,   na)
var priceLabels = array.new_label(ROWS_MAX, na)
var bidLabels   = array.new_label(ROWS_MAX, na)
var askLabels   = array.new_label(ROWS_MAX, na)
var hdrLabel    = label(na)
var imbLabel    = label(na)
var sepLine     = line(na)

// ═══════════════════════════════════════════════════════
//  LAYOUT
// ═══════════════════════════════════════════════════════
DOM_X0    = 3
DOM_X1    = 17
DOM_MID_X = 10
BAR_HALF  = 6
PANE_TOP  = 96.0
PANE_BOT  = 4.0
HDR_Y     = 98.5

// ═══════════════════════════════════════════════════════
//  DRAW
// ═══════════════════════════════════════════════════════
if barstate.islast

    NOW  = bar_index
    ROWS = domLevels * 2 + 1
    rowH = (PANE_TOP - PANE_BOT) / ROWS
    maxVol = math.max(buyVolSm, sellVolSm, 1.0)

    // ── Header ────────────────────────────────────────
    label.delete(hdrLabel)
    hdrLabel := label.new(
         x         = NOW + DOM_MID_X,
         y         = HDR_Y,
         text      = "DEPTH  OF  MARKET",
         style     = label.style_none,
         color     = color.new(color.black, 100),
         textcolor = colHeader,
         size      = szHdr,
         xloc      = xloc.bar_index,
         textalign = text.align_center)

    line.delete(sepLine)
    sepLine := line.new(
         x1   = NOW + DOM_X0,
         y1   = HDR_Y - 1.2,
         x2   = NOW + DOM_X1,
         y2   = HDR_Y - 1.2,
         color= color.new(colHeader, 70),
         width= 1,
         xloc = xloc.bar_index)

    // ── Rows ──────────────────────────────────────────
    totalBid = 0.0
    totalAsk = 0.0

    for i = 0 to ROWS - 1
        lvlOffset = domLevels - i
        isCurrent = lvlOffset == 0
        rowPrice  = close + lvlOffset * lvlStep

        yTop = PANE_TOP - i * rowH
        yBot = yTop - rowH + 0.3
        yMid = (yTop + yBot) / 2

        decay  = math.pow(0.78, math.abs(lvlOffset))
        bidVol = isCurrent ? buyVolSm  * 0.9 :
                 lvlOffset < 0 ? buyVolSm  * decay * (1.0 + math.abs(lvlOffset) * 0.04) :
                                 buyVolSm  * decay * 0.12
        askVol = isCurrent ? sellVolSm * 0.9 :
                 lvlOffset > 0 ? sellVolSm * decay * (1.0 + math.abs(lvlOffset) * 0.04) :
                                 sellVolSm * decay * 0.12

        totalBid += bidVol
        totalAsk += askVol

        bW = math.max(bidVol / maxVol * BAR_HALF, 0.2)
        aW = math.max(askVol / maxVol * BAR_HALF, 0.2)

        // Bid bar
        box.delete(array.get(bidBars, i))
        array.set(bidBars, i, box.new(
             left         = NOW + DOM_MID_X - math.round(bW),
             top          = yTop,
             right        = NOW + DOM_MID_X - 1,
             bottom       = yBot,
             bgcolor      = isCurrent ? color.new(colBid, 50) : color.new(colBid, 72),
             border_color = isCurrent ? color.new(colBid, 20) : color.new(colBid, 55),
             border_width = isCurrent ? 1 : 0,
             xloc         = xloc.bar_index))

        // Ask bar
        box.delete(array.get(askBars, i))
        array.set(askBars, i, box.new(
             left         = NOW + DOM_MID_X + 1,
             top          = yTop,
             right        = NOW + DOM_MID_X + math.round(aW),
             bottom       = yBot,
             bgcolor      = isCurrent ? color.new(colAsk, 50) : color.new(colAsk, 72),
             border_color = isCurrent ? color.new(colAsk, 20) : color.new(colAsk, 55),
             border_width = isCurrent ? 1 : 0,
             xloc         = xloc.bar_index))

        // Price label — uses szCurr for current row, szRow for all others
        priceTextCol = isCurrent ? colCurrent : lvlOffset > 0 ? colAbove : colBelow

        label.delete(array.get(priceLabels, i))
        array.set(priceLabels, i, label.new(
             x         = NOW + DOM_MID_X,
             y         = yMid,
             text      = str.tostring(rowPrice, format.mintick),
             style     = label.style_none,
             color     = color.new(color.black, 100),
             textcolor = priceTextCol,
             size      = isCurrent ? szCurr : szRow,
             xloc      = xloc.bar_index,
             textalign = text.align_center))

        // Volume numbers — both use szRow
        if showVolNums
            label.delete(array.get(bidLabels, i))
            bidTxt = bidVol >= 1000
                 ? str.tostring(math.round(bidVol / 100) / 10) + "K"
                 : str.tostring(math.round(bidVol))
            array.set(bidLabels, i, label.new(
                 x         = NOW + DOM_X0 + 1,
                 y         = yMid,
                 text      = bidTxt,
                 style     = label.style_none,
                 color     = color.new(color.black, 100),
                 textcolor = color.new(colBid, isCurrent ? 10 : 40),
                 size      = szRow,
                 xloc      = xloc.bar_index,
                 textalign = text.align_left))

            label.delete(array.get(askLabels, i))
            askTxt = askVol >= 1000
                 ? str.tostring(math.round(askVol / 100) / 10) + "K"
                 : str.tostring(math.round(askVol))
            array.set(askLabels, i, label.new(
                 x         = NOW + DOM_X1 - 1,
                 y         = yMid,
                 text      = askTxt,
                 style     = label.style_none,
                 color     = color.new(color.black, 100),
                 textcolor = color.new(colAsk, isCurrent ? 10 : 40),
                 size      = szRow,
                 xloc      = xloc.bar_index,
                 textalign = text.align_right))

    // ── Imbalance footer ──────────────────────────────
    if showImb
        imbPct = totalBid + totalAsk > 0
             ? math.round((totalBid - totalAsk) / (totalBid + totalAsk) * 100)
             : 0
        imbAbs = str.tostring(math.abs(imbPct))
        imbStr = imbPct >  5 ? "▲ BID +" + imbAbs + "%" :
                 imbPct < -5 ? "▼ ASK +" + imbAbs + "%" : "≈  balanced"
        imbCol = imbPct >  5 ? colBid : imbPct < -5 ? colAsk : colHeader

        label.delete(imbLabel)
        imbLabel := label.new(
             x         = NOW + DOM_MID_X,
             y         = PANE_BOT - 1.5,
             text      = imbStr,
             style     = label.style_none,
             color     = color.new(color.black, 100),
             textcolor = imbCol,
             size      = szHdr,
             xloc      = xloc.bar_index,
             textalign = text.align_center)

// ═══════════════════════════════════════════════════════
//  SCALE ANCHOR
// ═══════════════════════════════════════════════════════
plot(100, display=display.none, title="Scale top")
plot(0,   display=display.none, title="Scale bottom")
````
