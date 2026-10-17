# Buy/Sell-Side Liquidity

- url: https://www.tradingview.com/script/KoeheSkp-Buy-Sell-Side-Liquidity/
- type: indicator
- pine_id: PUB;1a39bdd664d94ea5bf6180204d427208
- version: 1.0

## Description

Buy-Side / Sell-Side Liquidity (BSL / SSL)
 
Maps the resting liquidity that price hunts — the swing highs where buy-side liquidity sits and the swing lows where sell-side liquidity sits — and tracks each level through its full life cycle: untested, swept, and reclaimed. Built for traders who work from liquidity and market structure.
 
 
🔵 WHAT IT PLOTS
 
• Buy-Side Liquidity (BSL) — drawn at confirmed swing highs, the pool of short stops and breakout buy orders resting above price.
• Sell-Side Liquidity (SSL) — drawn at confirmed swing lows, the pool of long stops and breakout sell orders resting below price.
• Each level extends to the right until price reaches it, so the chart only ever shows live, untested liquidity.
 
 
⚡ SWEEP DETECTION
 
A level is swept when price takes it. You choose how strict:
• Wick — swept on any penetration (catches stop runs).
• Close — swept only when a candle closes beyond the level (filters noise).
 
When swept, the level freezes at the point it was taken and recolors, or is removed entirely — your choice.
 
 
🔄 SWEEP + RECLAIM
 
The piece that turns a sweep into a signal. After a level is swept, if price closes back through it — a failed sweep / stop-run reversal — the level flips:
• A buy-side level swept and then reclaimed to the downside recolors bearish (failed high).
• A sell-side level swept and then reclaimed to the upside recolors bullish (failed low).
 
Each reclaim carries its own alert, so you can be notified on the failed sweep specifically, not on every sweep.
 
 
⚖️ EQUAL HIGHS / LOWS
 
Consecutive swings at nearly the same price are tagged EQH / EQL and drawn with added weight — the stronger liquidity pools that price tends to target. Tolerance is set in ticks, so it adapts to any instrument.
 
 
📋 NEAREST-LEVEL DASHBOARD (optional)
 
A compact table showing the nearest un-swept buy-side level above price and sell-side level below, each with its distance in ticks — a quick read on where the closest pools sit without measuring.
 
 
🔔 ALERTS
 
• Buy-Side Liquidity Swept
• Sell-Side Liquidity Swept
• Any Liquidity Swept
• Buy-Side Reclaim (bearish)
• Sell-Side Reclaim (bullish)
 
 
⚙️ SETTINGS
 
• Swing Strength — sensitivity of the swing detection (higher = fewer, more significant levels).
• Show Buy-Side / Sell-Side independently.
• Max Levels per Side — keeps the chart clean.
• Sweep Trigger (Wick / Close) and On Sweep (Keep & recolor / Delete).
• Equal High/Low detection with adjustable tick tolerance.
• Full control of colors, line width and style, labels, and dashboard position.
 
 
🧭 HOW TO USE IT
 
Liquidity is a target, not a signal on its own. Price is drawn toward untested BSL above and SSL below; the read comes from the reaction once it gets there. A sweep that continues is a breakout using the liquidity as fuel. A sweep that reclaims is a stop-run reversal. Use the levels to frame where to expect a reaction, the reclaim to confirm a turn, and your own bias and structure tools to decide whether to trust it. Stops typically sit just beyond the swept extreme.
 
Works on any market and any timeframe.
 
 
⚠️ Note: not every sweep reverses — many run straight through on trend days, which is exactly what the reclaim flag is there to distinguish. This indicator is a tool for analysis and education and is not financial advice.

## Source Code

````pine
// Buy-Side / Sell-Side Liquidity
// Detects swing highs (buy-side liquidity) and swing lows (sell-side liquidity),
// extends each level until price takes it, flags sweeps and sweep+reclaims, and alerts.
//@version=6
indicator(title = "Buy/Sell-Side Liquidity", shorttitle = "BSL/SSL", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ---------------- Detection ----------------
g_det = "Detection"
i_len     = input.int(5, "Swing Strength", minval = 1, maxval = 50, group = g_det, tooltip = "Bars required on each side to confirm a swing high/low. Higher = fewer, more significant levels. Levels confirm this many bars after the actual pivot.")
i_showBSL = input.bool(true, "Show Buy-Side Liquidity (highs)", group = g_det)
i_showSSL = input.bool(true, "Show Sell-Side Liquidity (lows)", group = g_det)
i_maxLvls = input.int(8, "Max Levels per Side", minval = 1, maxval = 50, group = g_det, tooltip = "Oldest level on a side is removed once this many are drawn.")

// ---------------- Sweep ----------------
g_sweep = "Sweep"
i_sweepMode = input.string("Wick", "Sweep Trigger", options = ["Wick", "Close"], group = g_sweep, tooltip = "Wick: swept when price trades through (any penetration). Close: swept only when a candle closes beyond.")
i_onSweep   = input.string("Keep & recolor", "On Sweep", options = ["Keep & recolor", "Delete"], group = g_sweep, tooltip = "Keep & recolor freezes the line where taken and recolors it; Delete removes it.")
i_reclaimOn = input.bool(true, "Flag Sweep + Reclaim", group = g_sweep, tooltip = "After a level is swept, if price closes back through it (failed sweep / stop-run reversal) the line is recolored to the opposite side and alerts. Buy-side reclaim = bearish, sell-side reclaim = bullish. Requires 'Keep & recolor'.")

// ---------------- Equal Highs / Lows ----------------
g_eq = "Equal Highs / Lows"
i_eqOn    = input.bool(true, "Detect Equal Highs/Lows", group = g_eq, tooltip = "Marks a swing at nearly the same level as the prior same-side swing as EQH/EQL — a stronger liquidity pool.")
i_eqTicks = input.int(4, "Equal Tolerance (ticks)", minval = 0, maxval = 200, group = g_eq, tooltip = "How close two swings must be, in ticks, to count as equal.")

// ---------------- Dashboard ----------------
g_dash = "Dashboard"
i_dash    = input.bool(false, "Show Nearest-Level Table", group = g_dash, tooltip = "Compact table showing the nearest un-swept buy-side level above price and sell-side level below price, with distance in ticks.")
i_dashPos = input.string("Top Right", "Position", options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Bottom Left"], group = g_dash)

// ---------------- Style ----------------
g_style = "Style"
i_bslCol   = input.color(color.new(#26a69a, 0), "Buy-Side", inline = "c1", group = g_style)
i_sslCol   = input.color(color.new(#ef5350, 0), "Sell-Side", inline = "c1", group = g_style)
i_sweptCol = input.color(color.new(color.gray, 35), "Swept", inline = "c1", group = g_style)
i_width    = input.int(1, "Line Width", minval = 1, maxval = 4, group = g_style)
i_style    = input.string("Solid", "Active Line Style", options = ["Solid", "Dashed", "Dotted"], group = g_style)
i_labels   = input.bool(true, "Show Labels", group = g_style)
i_labelSz  = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal"], group = g_style)

styleConst = i_style == "Solid" ? line.style_solid : i_style == "Dashed" ? line.style_dashed : line.style_dotted
labelSzConst = i_labelSz == "Tiny" ? size.tiny : i_labelSz == "Small" ? size.small : size.normal
dashPosConst = i_dashPos == "Top Right" ? position.top_right : i_dashPos == "Middle Right" ? position.middle_right : i_dashPos == "Bottom Right" ? position.bottom_right : i_dashPos == "Top Left" ? position.top_left : position.bottom_left
float eqTol = i_eqTicks * syminfo.mintick

// ---------------- State ----------------
var array<float> bslPx    = array.new<float>()
var array<line>  bslLn    = array.new<line>()
var array<label> bslLb    = array.new<label>()
var array<bool>  bslSwept = array.new<bool>()
var array<bool>  bslEq    = array.new<bool>()
var array<bool>  bslRecl  = array.new<bool>()

var array<float> sslPx    = array.new<float>()
var array<line>  sslLn    = array.new<line>()
var array<label> sslLb    = array.new<label>()
var array<bool>  sslSwept = array.new<bool>()
var array<bool>  sslEq    = array.new<bool>()
var array<bool>  sslRecl  = array.new<bool>()

bool bslTakenNow = false
bool sslTakenNow = false
bool bslReclNow  = false
bool sslReclNow  = false

// ---------------- Pivots ----------------
float ph = ta.pivothigh(i_len, i_len)
float pl = ta.pivotlow(i_len, i_len)
int pivotBar = bar_index - i_len

// ---------------- New Buy-Side level ----------------
if i_showBSL and not na(ph)
    bool isEq = false
    if i_eqOn and array.size(bslPx) > 0
        int last = array.size(bslPx) - 1
        if not array.get(bslSwept, last) and math.abs(ph - array.get(bslPx, last)) <= eqTol
            isEq := true
            array.set(bslEq, last, true)
            line.set_width(array.get(bslLn, last), i_width + 1)
            if i_labels and not na(array.get(bslLb, last))
                label.set_text(array.get(bslLb, last), "EQH")
    line ln = line.new(pivotBar, ph, bar_index, ph, color = i_bslCol, width = isEq ? i_width + 1 : i_width, style = styleConst)
    label lb = na
    if i_labels
        lb := label.new(bar_index, ph, isEq ? "EQH" : "BSL", style = label.style_none, textcolor = i_bslCol, size = labelSzConst, color = color.new(color.white, 100))
    array.push(bslPx, ph), array.push(bslLn, ln), array.push(bslLb, lb), array.push(bslSwept, false), array.push(bslEq, isEq), array.push(bslRecl, false)
    if array.size(bslPx) > i_maxLvls
        line.delete(array.get(bslLn, 0)), label.delete(array.get(bslLb, 0))
        array.shift(bslPx), array.shift(bslLn), array.shift(bslLb), array.shift(bslSwept), array.shift(bslEq), array.shift(bslRecl)

// ---------------- New Sell-Side level ----------------
if i_showSSL and not na(pl)
    bool isEq = false
    if i_eqOn and array.size(sslPx) > 0
        int last = array.size(sslPx) - 1
        if not array.get(sslSwept, last) and math.abs(pl - array.get(sslPx, last)) <= eqTol
            isEq := true
            array.set(sslEq, last, true)
            line.set_width(array.get(sslLn, last), i_width + 1)
            if i_labels and not na(array.get(sslLb, last))
                label.set_text(array.get(sslLb, last), "EQL")
    line ln = line.new(pivotBar, pl, bar_index, pl, color = i_sslCol, width = isEq ? i_width + 1 : i_width, style = styleConst)
    label lb = na
    if i_labels
        lb := label.new(bar_index, pl, isEq ? "EQL" : "SSL", style = label.style_none, textcolor = i_sslCol, size = labelSzConst, color = color.new(color.white, 100))
    array.push(sslPx, pl), array.push(sslLn, ln), array.push(sslLb, lb), array.push(sslSwept, false), array.push(sslEq, isEq), array.push(sslRecl, false)
    if array.size(sslPx) > i_maxLvls
        line.delete(array.get(sslLn, 0)), label.delete(array.get(sslLb, 0))
        array.shift(sslPx), array.shift(sslLn), array.shift(sslLb), array.shift(sslSwept), array.shift(sslEq), array.shift(sslRecl)

// ---------------- Extend / sweep / reclaim: Buy-Side ----------------
if array.size(bslPx) > 0
    for i = array.size(bslPx) - 1 to 0
        line ln = array.get(bslLn, i)
        float px = array.get(bslPx, i)
        if not array.get(bslSwept, i)
            line.set_x2(ln, bar_index)
            if i_labels and not na(array.get(bslLb, i))
                label.set_x(array.get(bslLb, i), bar_index)
            bool taken = i_sweepMode == "Wick" ? high > px : close > px
            if taken
                array.set(bslSwept, i, true)
                bslTakenNow := true
                if i_onSweep == "Delete"
                    line.delete(ln), label.delete(array.get(bslLb, i))
                    array.remove(bslPx, i), array.remove(bslLn, i), array.remove(bslLb, i), array.remove(bslSwept, i), array.remove(bslEq, i), array.remove(bslRecl, i)
                else
                    line.set_x2(ln, bar_index)
                    line.set_color(ln, i_sweptCol)
                    line.set_style(ln, line.style_dashed)
                    if i_labels and not na(array.get(bslLb, i))
                        label.set_text(array.get(bslLb, i), (array.get(bslEq, i) ? "EQH" : "BSL") + " swept")
                        label.set_textcolor(array.get(bslLb, i), i_sweptCol)
        else if i_reclaimOn and i_onSweep != "Delete" and not array.get(bslRecl, i)
            if close < px
                array.set(bslRecl, i, true)
                bslReclNow := true
                line.set_x2(ln, bar_index)
                line.set_color(ln, i_sslCol)
                line.set_style(ln, line.style_solid)
                if i_labels and not na(array.get(bslLb, i))
                    label.set_text(array.get(bslLb, i), "BSL reclaim")
                    label.set_textcolor(array.get(bslLb, i), i_sslCol)
                    label.set_x(array.get(bslLb, i), bar_index)

// ---------------- Extend / sweep / reclaim: Sell-Side ----------------
if array.size(sslPx) > 0
    for i = array.size(sslPx) - 1 to 0
        line ln = array.get(sslLn, i)
        float px = array.get(sslPx, i)
        if not array.get(sslSwept, i)
            line.set_x2(ln, bar_index)
            if i_labels and not na(array.get(sslLb, i))
                label.set_x(array.get(sslLb, i), bar_index)
            bool taken = i_sweepMode == "Wick" ? low < px : close < px
            if taken
                array.set(sslSwept, i, true)
                sslTakenNow := true
                if i_onSweep == "Delete"
                    line.delete(ln), label.delete(array.get(sslLb, i))
                    array.remove(sslPx, i), array.remove(sslLn, i), array.remove(sslLb, i), array.remove(sslSwept, i), array.remove(sslEq, i), array.remove(sslRecl, i)
                else
                    line.set_x2(ln, bar_index)
                    line.set_color(ln, i_sweptCol)
                    line.set_style(ln, line.style_dashed)
                    if i_labels and not na(array.get(sslLb, i))
                        label.set_text(array.get(sslLb, i), (array.get(sslEq, i) ? "EQL" : "SSL") + " swept")
                        label.set_textcolor(array.get(sslLb, i), i_sweptCol)
        else if i_reclaimOn and i_onSweep != "Delete" and not array.get(sslRecl, i)
            if close > px
                array.set(sslRecl, i, true)
                sslReclNow := true
                line.set_x2(ln, bar_index)
                line.set_color(ln, i_bslCol)
                line.set_style(ln, line.style_solid)
                if i_labels and not na(array.get(sslLb, i))
                    label.set_text(array.get(sslLb, i), "SSL reclaim")
                    label.set_textcolor(array.get(sslLb, i), i_bslCol)
                    label.set_x(array.get(sslLb, i), bar_index)

// ---------------- Dashboard ----------------
var table dash = na
if i_dash and barstate.islast
    float nBsl = na
    if array.size(bslPx) > 0
        for i = 0 to array.size(bslPx) - 1
            if not array.get(bslSwept, i) and array.get(bslPx, i) >= close
                float p = array.get(bslPx, i)
                nBsl := na(nBsl) ? p : math.min(nBsl, p)
    float nSsl = na
    if array.size(sslPx) > 0
        for i = 0 to array.size(sslPx) - 1
            if not array.get(sslSwept, i) and array.get(sslPx, i) <= close
                float p = array.get(sslPx, i)
                nSsl := na(nSsl) ? p : math.max(nSsl, p)
    if na(dash)
        dash := table.new(dashPosConst, 3, 3, border_width = 1)
    table.cell(dash, 0, 0, "Liquidity", text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 60))
    table.cell(dash, 1, 0, "Price",     text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 60))
    table.cell(dash, 2, 0, "Ticks",     text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 60))
    table.cell(dash, 0, 1, "Buy-side",  text_color = i_bslCol, text_size = size.small, bgcolor = color.new(color.black, 30))
    table.cell(dash, 1, 1, na(nBsl) ? "—" : str.tostring(nBsl, format.mintick), text_color = i_bslCol, text_size = size.small, bgcolor = color.new(color.black, 30))
    table.cell(dash, 2, 1, na(nBsl) ? "—" : str.tostring(math.round((nBsl - close) / syminfo.mintick)), text_color = i_bslCol, text_size = size.small, bgcolor = color.new(color.black, 30))
    table.cell(dash, 0, 2, "Sell-side", text_color = i_sslCol, text_size = size.small, bgcolor = color.new(color.black, 30))
    table.cell(dash, 1, 2, na(nSsl) ? "—" : str.tostring(nSsl, format.mintick), text_color = i_sslCol, text_size = size.small, bgcolor = color.new(color.black, 30))
    table.cell(dash, 2, 2, na(nSsl) ? "—" : str.tostring(math.round((close - nSsl) / syminfo.mintick)), text_color = i_sslCol, text_size = size.small, bgcolor = color.new(color.black, 30))

// ---------------- Alerts ----------------
alertcondition(bslTakenNow, title = "Buy-Side Liquidity Swept", message = "BSL swept on {{ticker}} {{interval}}")
alertcondition(sslTakenNow, title = "Sell-Side Liquidity Swept", message = "SSL swept on {{ticker}} {{interval}}")
alertcondition(bslTakenNow or sslTakenNow, title = "Any Liquidity Swept", message = "Liquidity swept on {{ticker}} {{interval}}")
alertcondition(bslReclNow, title = "Buy-Side Reclaim (bearish)", message = "Buy-side reclaim on {{ticker}} {{interval}} — failed high")
alertcondition(sslReclNow, title = "Sell-Side Reclaim (bullish)", message = "Sell-side reclaim on {{ticker}} {{interval}} — failed low")
````
