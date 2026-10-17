# Rejection Blocks [ICT]

- url: https://www.tradingview.com/script/klFV2RA5/
- type: indicator
- pine_id: PUB;47571ba8afe34685933091399a262dc1
- version: 2.0

## Description

# Rejection Blocks [ICT]

**Rejection Blocks [ICT]** is a price action indicator designed to identify significant rejection candles and automatically draw dynamic bullish and bearish rejection zones.

The indicator detects swing highs and swing lows, then filters them using wick-to-body ratio and ATR distance to eliminate weak or insignificant signals. Only high-quality rejection candles are used to create support and resistance blocks.

### Features

* Automatic Bullish and Bearish Rejection Block detection
* Swing High / Swing Low based structure analysis
* Adjustable Wick-to-Body Ratio filter
* ATR-based significance filter to reduce market noise
* Dynamic block extension until invalidation
* Optional 50% midpoint line inside each block
* Customizable block colors, borders, and label sizes

### Retest Signals

When price revisits an active rejection block, the indicator generates a confirmation signal:

* **Retest Buy** → Price retests a Bullish Rejection Block.
* **Retest Sell** → Price retests a Bearish Rejection Block.

The retest distance can be adjusted using an ATR-based buffer, allowing either precise touches or more flexible retests.

### Break Signals

The indicator can also detect when price completely breaks through an active rejection block.

* **Break Buy** → Price closes above a Bearish Rejection Block.
* **Break Sell** → Price closes below a Bullish Rejection Block.

These signals indicate that the previous rejection zone has failed and market structure may be shifting.

### Alerts

Built-in alert conditions include:

* Bullish Rejection Block Formed
* Bearish Rejection Block Formed
* Retest Buy
* Retest Sell
* Break Buy
* Break Sell
* Any Buy Signal
* Any Sell Signal
* Any Rejection Block Signal

### Customization

The indicator offers extensive customization options, including:

* Swing Strength
* Wick-to-Body Ratio
* ATR Filter
* ATR Retest Distance
* Bullish / Bearish Block Visibility
* Block Colors
* Border Visibility & Width
* Midline Display
* Label Size

### How to Use

Bullish blocks often act as potential demand zones where buyers may re-enter after a pullback.

Bearish blocks often act as potential supply zones where sellers may become active after a retracement.

For best results, use the indicator together with market structure, trend analysis, liquidity concepts, and proper risk management rather than relying solely on individual signals.

**Note:** No indicator can predict the market with complete accuracy. Always confirm signals with your own trading strategy and risk management rules.

## Source Code

````pine
//@version=6
indicator("Rejection Blocks [ICT]", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
int   swingStrength     = input.int(3,     "Swing Strength",           minval=1, maxval=10)
float wickBodyRatio     = input.float(2.0, "Wick-to-Body Ratio",       minval=1.0, step=0.1)
float atrMultiple       = input.float(0.5, "ATR Filter Multiple",      minval=0.1, step=0.1)
int   atrLength         = input.int(14,    "ATR Length",               minval=1)
float retestDistance    = input.float(0.0, "Retest Distance (ATR multiplier)", minval=0.0, step=0.1, tooltip="How far price can be from the block and still trigger a retest signal. 0 = price must touch the block.")
bool  showBullish       = input.bool(true, "Show Bullish Blocks")
bool  showBearish       = input.bool(true, "Show Bearish Blocks")
color bullColor         = input.color(color.new(color.green, 75), "Bullish Block Color")
color bearColor         = input.color(color.new(color.red,   75), "Bearish Block Color")
bool  showBorder        = input.bool(true, "Show Border")
int   borderWidth       = input.int(1,     "Border Width",             minval=1, maxval=5)
bool  showMidline       = input.bool(true, "Show 50% Midline")
string labelSize        = input.string("small", "Label Size", options=["tiny","small","normal","large","huge"])

// ─── LABEL SIZE MAP ───────────────────────────────────────────────────────────
size_val(s) =>
    s == "tiny"   ? size.tiny   :
     s == "small"  ? size.small  :
     s == "normal" ? size.normal :
     s == "large"  ? size.large  :
     size.huge

// ─── PIVOT DETECTION ──────────────────────────────────────────────────────────
float ph = ta.pivothigh(high, swingStrength, swingStrength)
float pl = ta.pivotlow(low,   swingStrength, swingStrength)

// ─── WICK / BODY HELPERS ──────────────────────────────────────────────────────
body(offset)      => math.abs(close[offset] - open[offset])
upperWick(offset) => high[offset]  - math.max(close[offset], open[offset])
lowerWick(offset) => math.min(close[offset], open[offset]) - low[offset]

// ─── LAST CONFIRMED PIVOTS FOR ATR GATE ───────────────────────────────────────
var float lastConfirmedPH = na
var float lastConfirmedPL = na

// ─── PERSISTENT BLOCK STORAGE ─────────────────────────────────────────────────
var box[]   bullBoxes    = array.new_box()
var line[]  bullMidlines = array.new_line()
var float[] bullTops     = array.new_float()
var float[] bullBots     = array.new_float()
var bool[]  bullRetested = array.new_bool()

var box[]   bearBoxes    = array.new_box()
var line[]  bearMidlines = array.new_line()
var float[] bearTops     = array.new_float()
var float[] bearBots     = array.new_float()
var bool[]  bearRetested = array.new_bool()

// ─── SIGNAL VARS FOR ALERTS ───────────────────────────────────────────────────
var bool bullRetestSignal  = false
var bool bearRetestSignal  = false
var bool bullBreakSignal   = false
var bool bearBreakSignal   = false

bullRetestSignal := false
bearRetestSignal := false
bullBreakSignal  := false
bearBreakSignal  := false

// ─── RETEST DISTANCE IN PRICE ─────────────────────────────────────────────────
float atrCurrent    = ta.atr(atrLength)
float retestBuffer  = retestDistance * atrCurrent

// ─── DETECTION & REGISTRATION (confirmed bars only) ───────────────────────────
if barstate.isconfirmed
    // BULLISH REJECTION BLOCK
    if not na(pl) and showBullish
        float bdy  = body(swingStrength)
        float lwck = lowerWick(swingStrength)
        float uwck = upperWick(swingStrength)
        bool  isRejection = lwck >= wickBodyRatio * math.max(bdy, syminfo.mintick) and lwck >= uwck
        float atrAtPivot  = ta.atr(atrLength)[swingStrength]
        bool  isImportant = na(lastConfirmedPL) or math.abs(pl - lastConfirmedPL) >= atrMultiple * atrAtPivot
        if isRejection and isImportant
            float blockTop = math.min(close[swingStrength], open[swingStrength])
            float blockBot = low[swingStrength]
            int   pivotBar = bar_index - swingStrength
            color borderCol = showBorder ? color.new(color.green, 0) : na
            box b = box.new(pivotBar, blockTop, bar_index + 1, blockBot,
                 border_color=borderCol, border_width=borderWidth,
                 bgcolor=bullColor)
            array.push(bullBoxes,    b)
            array.push(bullTops,     blockTop)
            array.push(bullBots,     blockBot)
            array.push(bullRetested, false)
            float mid = (blockTop + blockBot) / 2.0
            line ml = showMidline ? line.new(pivotBar, mid, bar_index + 1, mid, color=color.new(color.green, 20), style=line.style_dashed, width=1) : na
            array.push(bullMidlines, ml)
            lastConfirmedPL := pl

    // BEARISH REJECTION BLOCK
    if not na(ph) and showBearish
        float bdy  = body(swingStrength)
        float uwck = upperWick(swingStrength)
        float lwck = lowerWick(swingStrength)
        bool  isRejection = uwck >= wickBodyRatio * math.max(bdy, syminfo.mintick) and uwck >= lwck
        float atrAtPivot  = ta.atr(atrLength)[swingStrength]
        bool  isImportant = na(lastConfirmedPH) or math.abs(ph - lastConfirmedPH) >= atrMultiple * atrAtPivot
        if isRejection and isImportant
            float blockTop = high[swingStrength]
            float blockBot = math.max(close[swingStrength], open[swingStrength])
            int   pivotBar = bar_index - swingStrength
            color borderCol = showBorder ? color.new(color.red, 0) : na
            box b = box.new(pivotBar, blockTop, bar_index + 1, blockBot,
                 border_color=borderCol, border_width=borderWidth,
                 bgcolor=bearColor)
            array.push(bearBoxes,    b)
            array.push(bearTops,     blockTop)
            array.push(bearBots,     blockBot)
            array.push(bearRetested, false)
            float mid = (blockTop + blockBot) / 2.0
            line ml = showMidline ? line.new(pivotBar, mid, bar_index + 1, mid, color=color.new(color.red, 20), style=line.style_dashed, width=1) : na
            array.push(bearMidlines, ml)
            lastConfirmedPH := ph

// ─── EXTEND ACTIVE BOXES, MITIGATION, RETESTS, BREAKS ────────────────────────
if barstate.isconfirmed
    // BULLISH BLOCKS
    if array.size(bullBoxes) > 0
        int i = array.size(bullBoxes) - 1
        while i >= 0
            float bTop      = array.get(bullTops, i)
            float bBot      = array.get(bullBots, i)
            box   bx        = array.get(bullBoxes, i)
            line  ml        = array.get(bullMidlines, i)
            bool  retested  = array.get(bullRetested, i)

            // Break: close below block bottom — bearish break of bull block → sell signal
            if close < bBot
                box.delete(bx)
                if not na(ml)
                    line.delete(ml)
                array.remove(bullBoxes,    i)
                array.remove(bullTops,     i)
                array.remove(bullBots,     i)
                array.remove(bullMidlines, i)
                array.remove(bullRetested, i)
                bearBreakSignal := true
                label.new(bar_index, high, "▼ Break Sell", style=label.style_label_down, color=color.new(color.red, 10), textcolor=color.white, size=size_val(labelSize))
            else
                // Retest: price approaches zone within retestBuffer distance from above
                bool nearBlock = low <= bTop + retestBuffer and high >= bBot - retestBuffer and close >= bBot
                if not retested and nearBlock
                    array.set(bullRetested, i, true)
                    bullRetestSignal := true
                    label.new(bar_index, low, "▲ Retest Buy", style=label.style_label_up, color=color.new(color.green, 10), textcolor=color.white, size=size_val(labelSize))
                box.set_right(bx, bar_index + 1)
                if not na(ml)
                    line.set_x2(ml, bar_index + 1)
            i -= 1

    // BEARISH BLOCKS
    if array.size(bearBoxes) > 0
        int j = array.size(bearBoxes) - 1
        while j >= 0
            float bTop      = array.get(bearTops, j)
            float bBot      = array.get(bearBots, j)
            box   bx        = array.get(bearBoxes, j)
            line  ml        = array.get(bearMidlines, j)
            bool  retested  = array.get(bearRetested, j)

            // Break: close above block top — bullish break of bear block → buy signal
            if close > bTop
                box.delete(bx)
                if not na(ml)
                    line.delete(ml)
                array.remove(bearBoxes,    j)
                array.remove(bearTops,     j)
                array.remove(bearBots,     j)
                array.remove(bearMidlines, j)
                array.remove(bearRetested, j)
                bullBreakSignal := true
                label.new(bar_index, low, "▲ Break Buy", style=label.style_label_up, color=color.new(color.green, 10), textcolor=color.white, size=size_val(labelSize))
            else
                // Retest: price approaches zone within retestBuffer distance from below
                bool nearBlock = high >= bBot - retestBuffer and low <= bTop + retestBuffer and close <= bTop
                if not retested and nearBlock
                    array.set(bearRetested, j, true)
                    bearRetestSignal := true
                    label.new(bar_index, high, "▼ Retest Sell", style=label.style_label_down, color=color.new(color.red, 10), textcolor=color.white, size=size_val(labelSize))
                box.set_right(bx, bar_index + 1)
                if not na(ml)
                    line.set_x2(ml, bar_index + 1)
            j -= 1

// ─── ALERTS ───────────────────────────────────────────────────────────────────
float atrAtPivotAlert = ta.atr(atrLength)[swingStrength]

bool bullFormAlert = barstate.isconfirmed and not na(ta.pivotlow(low, swingStrength, swingStrength)) and
     lowerWick(swingStrength) >= wickBodyRatio * math.max(body(swingStrength), syminfo.mintick) and
     lowerWick(swingStrength) >= upperWick(swingStrength) and showBullish and
     (na(lastConfirmedPL) or math.abs(ta.pivotlow(low, swingStrength, swingStrength) - lastConfirmedPL) >= atrMultiple * atrAtPivotAlert)

bool bearFormAlert = barstate.isconfirmed and not na(ta.pivothigh(high, swingStrength, swingStrength)) and
     upperWick(swingStrength) >= wickBodyRatio * math.max(body(swingStrength), syminfo.mintick) and
     upperWick(swingStrength) >= lowerWick(swingStrength) and showBearish and
     (na(lastConfirmedPH) or math.abs(ta.pivothigh(high, swingStrength, swingStrength) - lastConfirmedPH) >= atrMultiple * atrAtPivotAlert)

alertcondition(bullFormAlert,    "Bullish Rejection Block Formed",  "Bullish Rejection Block formed")
alertcondition(bearFormAlert,    "Bearish Rejection Block Formed",  "Bearish Rejection Block formed")
alertcondition(bullRetestSignal, "Green Block Retest — Buy",        "Price retested a Bullish Rejection Block (Buy)")
alertcondition(bearRetestSignal, "Red Block Retest — Sell",         "Price retested a Bearish Rejection Block (Sell)")
alertcondition(bullBreakSignal,  "Red Block Break — Buy",           "Price broke above a Bearish Rejection Block (Buy)")
alertcondition(bearBreakSignal,  "Green Block Break — Sell",        "Price broke below a Bullish Rejection Block (Sell)")
alertcondition(bullRetestSignal or bullBreakSignal, "Any Buy Signal",  "Rejection Block Buy Signal")
alertcondition(bearRetestSignal or bearBreakSignal, "Any Sell Signal", "Rejection Block Sell Signal")
alertcondition(bullFormAlert or bearFormAlert or bullRetestSignal or bearRetestSignal or bullBreakSignal or bearBreakSignal, "Any Rejection Block Signal", "Rejection Block Signal")
````
