# Divergence Map [FEELS]

- url: https://www.tradingview.com/script/XUezKaaA-Divergence-Map-FEELS/
- type: indicator
- pine_id: PUB;ec62ce80d87a49c0a9fc9b0acdb03b9e
- version: 1.0

## Description

Price up, strength not.

Divergence Map marks every spot where price made a new high or low but the volume delta behind it didn't agree. Across the whole chart, not just the right edge.

https://www.tradingview.com/x/KgIihR7b/

[b]OVERVIEW[/b]
Each divergence is drawn as a pair of crossing lines on the price pane: the line through the two price swings, and a second line whose opening reflects the volume delta behind those swings, widening in proportion to the strength gap so the disagreement is visible at a glance. A new high with weaker delta is marked at the top, a new low with weaker selling is marked at the bottom. Most divergence tools push a delta line into a separate panel and leave you to eyeball the slopes; this keeps the comparison on price, as one shape, for the whole chart.

[b]HOW IT WORKS[/b]
1. Per-bar delta uses the standard bar-direction proxy: a bar closing up counts its volume as positive, a bar closing down as negative, a flat bar as zero. These are summed into a cumulative volume delta. Pine has no true tick order flow on historical bars, so this proxy is what the calculation is built on, and the logic is designed around its limits.
2. The cumulative delta is measured against its own recent trend (its value minus a moving average of itself), so divergences are read against recent flow rather than the all-time drift of a running total.
3. Swing highs and lows are found with a symmetric pivot of configurable length. A swing is used only once it is confirmed by that many closed bars on each side.
4. A top divergence is recorded when a confirmed swing high is above the previous swing high while the trend-adjusted delta at the new swing sits below its reading at the previous one. A bottom divergence is the mirror. The test compares the relative direction of delta between two swings rather than an absolute value, which is what lets it tolerate the proxy.
5. Strength is the size of that delta gap, scaled by its recent range and reported 0 to 100. A minimum-strength input hides weak readings.
6. Each divergence is then tracked for an outcome. By default it is scored from the bar it actually becomes visible (one swing length after the swing, since a swing cannot be known before then), and judged symmetrically from there: whichever comes first within the window, a reversal of the set size in its direction is a check, the same move against it is a cross. The size is taken from volatility by default (a multiple of ATR), so it scales with the timeframe; it can be switched to a fixed percent. An event also fails if price closes back through the swing that defined it. This removes the look-back head start, so the hit rate in the dashboard is descriptive of how these divergences have actually behaved, not a promise about the next one.

https://www.tradingview.com/x/UC6Ui7nF/

HOW TO USE
- Read the shape, not a number. Two lines opening apart at a top means price rose while delta did not; at a bottom, price fell while selling did not.
- The check or cross on each past event shows whether the expected reversal followed, so the chart carries its own record on the symbol and timeframe you are viewing.
- During a strong, clean trend the map stays mostly empty. That is expected: divergences appear at exhaustion, not inside a healthy trend.
- Raise minimum strength to keep only the clearer events. Swing length sets how major the marked swings are. Reversal percent and window define what counts as a resolved reversal. Turn off Remove swing lag to see the look-back figure instead of the real-time one.

https://www.tradingview.com/x/9xlwQXdm/

[b]PARAMETERS[/b]
- Swing length: bars per side to confirm a swing.
- Min strength: hides divergences below this 0 to 100 score.
- Delta smoothing and strength window: detrend the delta and scale the strength score.
- ATR reversal and Reversal ATR: size the reversal by volatility so the threshold scales with the timeframe (about 5% daily, around 15% weekly); turn off to use the fixed Reversal percent.
- Reversal percent and reversal window: the fixed-percent threshold and the bars allowed for a resolved reversal.
- Remove swing lag: scores each event from the bar it becomes visible and judges it symmetrically, giving a realistic hit rate instead of the look-back one.
- Labels, label and dot size, line width, colors, strength line on or off, mark hit on chart, dashboard position.

[b]REPAINT NOTE[/b]
A swing is confirmed one swing length after it forms, which is how pivots work, and a divergence is recorded only on closed bars using that confirmed swing. Once a divergence and its lines are drawn they do not move, and the check or cross is added later on closed bars as the outcome settles. The only live element is the dashboard. No higher-timeframe or external data requests are used.

[b]ORIGINALITY[/b]
This is original work and the source is open. It is not a wrapper around a built-in oscillator and it does not plot delta in a separate pane. The comparison is kept on the price pane as one crossing shape, applied across full history, with a built-in record of whether each marked divergence was followed by a reversal, scored from the bar it actually became visible. The honest treatment of the delta proxy, comparing relative slope rather than absolute flow, is part of the design.

Descriptive tool for studying divergence behaviour. It is not financial advice and does not predict price.

## Source Code

````pine
//@version=6
indicator("Divergence Map [FEELS]", overlay = true, max_bars_back = 5000, max_lines_count = 500, max_labels_count = 500)

//--- detection
pivotLen    = input.int(5, "Swing length", minval = 2, group = "Detection", tooltip = "Bars per side to confirm each swing. A swing locks only after this many closed bars, so marks never repaint. Larger = more major swings, fewer marks.")
minStrength = input.int(0, "Min strength", minval = 0, maxval = 100, group = "Detection", tooltip = "Only divergences at or above this 0-100 score are drawn. Raise it to keep the chart clean.")
oscLen      = input.int(50, "Delta smoothing", minval = 5, group = "Detection", tooltip = "Detrends cumulative delta against its own recent trend, so divergences are measured locally instead of against all-time drift. Lower = more events.")
rangeLen    = input.int(100, "Strength window", minval = 10, group = "Detection", tooltip = "Lookback used to scale how large a strength gap is into the 0-100 score.")

//--- track record
atrReversal = input.bool(true, "ATR reversal", group = "Track record", tooltip = "Sizes the reversal by volatility (ATR) instead of a fixed percent, so the threshold scales with the timeframe automatically: roughly 5% on a daily chart, around 15% on weekly, smaller on intraday. Turn off to use a fixed Reversal %.")
atrMult     = input.float(1.5, "Reversal ATR", minval = 0.1, step = 0.1, group = "Track record", tooltip = "Reversal distance as a multiple of ATR(14), used when ATR reversal is on.")
revPct      = input.float(5.0, "Reversal %", minval = 0.1, group = "Track record", tooltip = "Reversal distance as a percent of price, used when ATR reversal is off. A hit needs a move this large in the divergence's direction; with Remove swing lag on, the same move against it is a miss. An event also fails if price closes back through the swing that defined it.") / 100.0
revBars = input.int(30, "Reversal window", minval = 1, group = "Track record", tooltip = "Bars allowed for the reversal before the event is marked a miss, counted from the signal bar when Remove swing lag is on, otherwise from the swing.")
realTiming = input.bool(true, "Remove swing lag", group = "Track record", tooltip = "A divergence is only confirmed Swing length bars after the actual swing, so scoring it from the swing would give it a head start it never had in real time. On (default) scores each divergence from the bar it actually becomes visible and judges it symmetrically from there: whichever comes first, a move of Reversal % in its favor (hit) or the same against it (miss). Off shows the look-back figure instead, which reads higher.")

//--- labels
bearTxt      = input.string("Bearish Divergence", "Top label", group = "Labels", tooltip = "Text drawn at a top divergence (price higher high, delta lower high).")
bullTxt      = input.string("Bullish Divergence", "Bottom label", group = "Labels", tooltip = "Text drawn at a bottom divergence (price lower low, delta higher low).")
labelSize    = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal", "Large"], group = "Labels", tooltip = "Size of the divergence text label.")
appendResult = input.bool(true, "Append result to label", group = "Labels", tooltip = "Adds a check or cross to each label once the outcome settles.")
showHitMark  = input.bool(false, "Mark hit on chart", group = "Labels", tooltip = "Draws a separate check at the bar where price completed the reversal, so hits are visible on the chart, not only in the label.")

//--- visuals
showCvd  = input.bool(true, "Show strength line", group = "Visuals", tooltip = "Turns the dashed delta (strength) line and its dots on or off.")
showDots = input.bool(true, "Show pivot dots", group = "Visuals", tooltip = "Turns the dots on the swing and delta anchors on or off.")
dotSize  = input.string("Tiny", "Dot size", options = ["Tiny", "Small", "Normal"], group = "Visuals", tooltip = "Size of the anchor dots.")
lineW    = input.int(2, "Line width", minval = 1, group = "Visuals", tooltip = "Thickness of the price and delta lines.")
showDash = input.bool(true, "Dashboard", group = "Visuals", tooltip = "Turns the stats table on or off.")
dashPos  = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = "Visuals", tooltip = "Corner for the stats table.")
dashSize = input.string("Normal", "Dashboard size", options = ["Small", "Normal", "Large"], group = "Visuals", tooltip = "Text size of the stats table.")

//--- colors
cBear   = input.color(#ef5350, "Top color", group = "Colors", tooltip = "Color of top (bearish) divergences.")
cBull   = input.color(#26a69a, "Bottom color", group = "Colors", tooltip = "Color of bottom (bullish) divergences.")
cAccent = input.color(#f5c518, "Strength line", group = "Colors", tooltip = "Color of the dashed delta line.")

//--- size helper
sizeOf(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : size.large

bumpSize(s) =>
    s == "Small" ? size.normal : s == "Normal" ? size.large : size.huge

labelSizeV = sizeOf(labelSize)
dotSizeV   = sizeOf(dotSize)
dashBaseV  = sizeOf(dashSize)
dashBigV   = bumpSize(dashSize)

//--- cumulative volume delta (close-position proxy), detrended against its own trend
delta = close > open ? nz(volume) : close < open ? -nz(volume) : 0.0
var float cvd = 0.0
cvd := cvd + delta
cvdOsc = cvd - ta.ema(cvd, oscLen)

//--- series (every bar)
ph       = ta.pivothigh(high, pivotLen, pivotLen)
pl       = ta.pivotlow(low, pivotLen, pivotLen)
atr      = ta.atr(14)
cvdSpan  = ta.highest(cvdOsc, rangeLen) - ta.lowest(cvdOsc, rangeLen)
cvdSpanS = cvdSpan > 0 ? cvdSpan : 1.0

//--- prior pivot memory
var float prevHp = na
var float prevHc = na
var int   prevHx = na
var float prevLp = na
var float prevLc = na
var int   prevLx = na

//--- event store + counters
type Div
    int   x2
    float p2
    int   cbar
    float cpx
    float atrv
    bool  bear
    bool  resolved
    bool  hit
    label lbl

var array<Div> events = array.new<Div>()
var int  found    = 0
var int  resolved = 0
var int  hits     = 0
var bool hasLast  = false
var bool lastBear = false
var int  lastBar  = 0

//--- draw one divergence, return its text label (na if outside the drawable window)
drawDiv(x1, p1, x2, p2, bear, strength) =>
    mid  = (p1 + p2) / 2.0
    half = atr * (1.0 + strength / 50.0) / 2.0
    col  = bear ? cBear : cBull
    label lid = na
    if (bar_index - x1) < 4990
        line.new(x1, p1, x2, p2, xloc = xloc.bar_index, color = col, width = lineW)
        if showCvd
            c1y = bear ? mid + half : mid - half
            c2y = bear ? mid - half : mid + half
            line.new(x1, c1y, x2, c2y, xloc = xloc.bar_index, color = cAccent, width = lineW, style = line.style_dashed)
            if showDots
                label.new(x1, c1y, "", xloc = xloc.bar_index, style = label.style_circle, color = cAccent, size = dotSizeV)
                label.new(x2, c2y, "", xloc = xloc.bar_index, style = label.style_circle, color = cAccent, size = dotSizeV)
        if showDots
            label.new(x1, p1, "", xloc = xloc.bar_index, style = label.style_circle, color = col, size = dotSizeV)
            label.new(x2, p2, "", xloc = xloc.bar_index, style = label.style_circle, color = col, size = dotSizeV)
        stl = bear ? label.style_label_down : label.style_label_up
        lid := label.new(x2, p2, bear ? bearTxt : bullTxt, xloc = xloc.bar_index, yloc = yloc.price, style = stl, color = col, textcolor = color.white, size = labelSizeV)
    lid

//--- detection (only on closed bars so swings never repaint)
bool bearSig = false
bool bullSig = false

if not na(ph) and barstate.isconfirmed
    px = bar_index - pivotLen
    pv = ph
    cv = cvdOsc[pivotLen]
    if not na(prevHp) and pv > prevHp and cv < prevHc
        strength = math.min(100.0, math.max(0.0, (prevHc - cv) / cvdSpanS * 100.0))
        if strength >= minStrength
            lid = drawDiv(prevHx, prevHp, px, pv, true, strength)
            array.push(events, Div.new(px, pv, bar_index, close, atr, true, false, false, lid))
            found    += 1
            hasLast  := true
            lastBear := true
            lastBar  := px
            bearSig  := true
    prevHp := pv
    prevHc := cv
    prevHx := px

if not na(pl) and barstate.isconfirmed
    px = bar_index - pivotLen
    pv = pl
    cv = cvdOsc[pivotLen]
    if not na(prevLp) and pv < prevLp and cv > prevLc
        strength = math.min(100.0, math.max(0.0, (cv - prevLc) / cvdSpanS * 100.0))
        if strength >= minStrength
            lid = drawDiv(prevLx, prevLp, px, pv, false, strength)
            array.push(events, Div.new(px, pv, bar_index, close, atr, false, false, false, lid))
            found    += 1
            hasLast  := true
            lastBear := false
            lastBar  := px
            bullSig  := true
    prevLp := pv
    prevLc := cv
    prevLx := px

//--- resolve track record (hit if price reversed revPct within revBars and the level held, else miss)
if array.size(events) > 0 and barstate.isconfirmed
    for i = 0 to array.size(events) - 1
        d = array.get(events, i)
        if not d.resolved
            refP = realTiming ? d.cpx : d.p2
            ageR = realTiming ? bar_index - d.cbar : bar_index - d.x2
            dist = atrReversal ? atrMult * d.atrv : refP * revPct
            up   = refP + dist
            dn   = refP - dist
            if d.bear
                if close > d.p2
                    d.resolved := true
                    d.hit := false
                else if realTiming and high >= up
                    d.resolved := true
                    d.hit := false
                else if low <= dn
                    d.resolved := true
                    d.hit := true
                else if ageR >= revBars
                    d.resolved := true
                    d.hit := false
            else
                if close < d.p2
                    d.resolved := true
                    d.hit := false
                else if realTiming and low <= dn
                    d.resolved := true
                    d.hit := false
                else if high >= up
                    d.resolved := true
                    d.hit := true
                else if ageR >= revBars
                    d.resolved := true
                    d.hit := false
            if d.resolved
                resolved += 1
                hits += d.hit ? 1 : 0
                if appendResult and not na(d.lbl)
                    label.set_text(d.lbl, (d.bear ? bearTxt : bullTxt) + (d.hit ? "  ✓" : "  ✗"))
                if d.hit and showHitMark
                    mstl = d.bear ? label.style_label_up : label.style_label_down
                    label.new(bar_index, d.bear ? low : high, "✓", xloc = xloc.bar_index, style = mstl, color = d.bear ? cBear : cBull, textcolor = color.white, size = size.small)
            array.set(events, i, d)

//--- bound the resolution queue (drawings persist on chart)
if array.size(events) > 80
    array.shift(events)

//--- dashboard
hitTxt  = resolved > 0 ? str.tostring(math.round(hits / resolved * 100)) + "%  (" + str.tostring(resolved) + ")" : "-"
hitCol  = resolved == 0 ? color.silver : hits * 2 >= resolved ? cBull : cBear
lastTxt = hasLast ? (lastBear ? "Bearish" : "Bullish") + "  -  " + str.tostring(bar_index - lastBar) + " bars" : "-"

tablePos = dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.top_right

var table dash = table.new(position.top_right, 2, 4, border_width = 1, frame_color = color.new(color.gray, 60), frame_width = 1)
if barstate.islast and showDash
    table.clear(dash, 0, 0, 1, 3)
    dash.cell(0, 0, "DIVERGENCE MAP", text_color = color.white, text_size = dashBaseV, bgcolor = #0f1115)
    dash.cell(1, 0, "v1.0", text_color = color.silver, text_size = dashBaseV, bgcolor = #0f1115)
    dash.cell(0, 1, "Hit rate", text_color = color.silver, text_size = dashBigV, bgcolor = #15181e)
    dash.cell(1, 1, hitTxt, text_color = hitCol, text_size = dashBigV, bgcolor = #15181e)
    dash.cell(0, 2, "Found", text_color = color.silver, text_size = dashBaseV, bgcolor = #15181e)
    dash.cell(1, 2, str.tostring(found), text_color = color.white, text_size = dashBaseV, bgcolor = #15181e)
    dash.cell(0, 3, "Last", text_color = color.silver, text_size = dashBaseV, bgcolor = #15181e)
    dash.cell(1, 3, lastTxt, text_color = color.white, text_size = dashBaseV, bgcolor = #15181e)
    table.set_position(dash, tablePos)

//--- alerts
alertcondition(bearSig, "Bearish divergence", "Divergence Map: price made a higher high without strength")
alertcondition(bullSig, "Bullish divergence", "Divergence Map: price made a lower low without strength")
````
