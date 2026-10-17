# Auto Triangle Patterns [HexaTrades]

- url: https://www.tradingview.com/script/ZD289WO8-Auto-Triangle-Patterns-HexaTrades/
- type: indicator
- pine_id: PUB;665e5c834f814aae84e1e6184d279742
- version: 1.0

## Description

[b]Auto Triangle Patterns[/b] finds triangle chart patterns for you, draws them on the chart, and marks the candle where price breaks out. It works on any symbol (stocks, crypto, forex, indices) and any timeframe.

[b]What is a triangle pattern?[/b]

A triangle forms when price moves in a smaller and smaller range. The highs and the lows squeeze closer together, like a funnel. You can draw one line along the tops and one line along the bottoms. When the two lines get close, price usually breaks out of the triangle with a bigger move.

This indicator finds three types of triangle:

✏️Ascending triangle: flat top line, rising bottom line. Buyers keep pushing the lows higher while sellers hold the same price at the top.

✏️Descending triangle: falling top line, flat bottom line. Sellers keep pushing the highs lower while buyers hold the same price at the bottom.

✏️Symmetrical triangle: falling top line and rising bottom line at similar angles. Neither side is in control yet.


[b]Ascending triangle example
[/b]
https://www.tradingview.com/x/I5FhkJVI/
The top line stays nearly flat while the bottom line keeps rising, so price gets squeezed into a smaller and smaller range. Then a strong candle closes above the top line, and the indicator prints a small green ▲ under that candle. That is the breakout signal.
In this example the entry is taken only after the breakout candle closes, and the stop-loss sits below the triangle's rising support line. The entry, stop and target boxes are drawn with TradingView's Long Position tool for illustration; the indicator itself only draws the triangle and the ▲ / ▼ marks.


[b]Descending triangle example
[/b]
https://www.tradingview.com/x/GxSKSWyJ/
The top line keeps falling (each bounce makes a lower high) while the bottom line stays close to flat (buyers defend roughly the same support area). The range tightens until a candle closes below the support line, and the indicator prints a small red ▼ above that candle. That is the breakdown signal.

In this example the short entry is taken only after the breakdown candle closes, and the stop-loss sits above the last swing high inside the triangle. The entry, stop and target boxes are drawn with TradingView's Short Position tool for illustration; the indicator itself only draws the triangle and the ▲ / ▼ marks.

[b]Symmetrical triangle example
[/b]
https://www.tradingview.com/x/iF5e0xZo/
The top line falls (lower highs) and the bottom line rises (higher lows) at a similar angle, so price is squeezed from both sides and neither buyers nor sellers are in control. A symmetrical triangle can break either way, so the indicator waits for a candle to close outside the pattern. Here a candle closed below the rising support line, and a small red ▼ was printed above it. That is the breakdown signal.

In this example the short entry is taken after the breakdown candle closes, and the stop-loss sits above the last swing high (previous resistance) inside the triangle. Notice that price bounced back up close to the stop before the main move down. That's why the stop belongs beyond a real swing point and not right at the line. The entry, stop and target boxes are drawn with TradingView's Short Position tool for illustration; the indicator itself only draws the triangle and the ▲ / ▼ marks.

[b]How to read the chart[/b]

- Two coloured lines with a light fill: the triangle. Teal = ascending, red = descending, blue = symmetrical (you can change the colours).
- Label at the start of the pattern: the pattern type, for example "Ascending Triangle".
- Small green ▲ under a candle: breakout. The candle closed above the top line.
- Small red ▼ above a candle: breakdown. The candle closed below the bottom line.
- Dashed lines and "(expired)": price reached the end of the triangle without breaking out, so the pattern failed.
- Dashed lines and "(no breakout)": a newer triangle appeared before this one broke out, so the indicator stopped following the old one.

[b]How it works:[/b]

- Step 1: find swing points. A swing high is a candle whose high is higher than the candles around it. A swing low is the opposite.
- Step 2: draw the lines. The top line connects the latest swing highs. The bottom line connects the latest swing lows.
- Step 3: check the shape. The lines must squeeze together, price must stay inside them, and the pattern must not be too short or too long. Shapes that are not real triangles (wedges, rectangles, lopsided shapes) are skipped.
- Step 4: name the triangle. A line counts as "flat" if it moves less than 25% of the triangle's height. This only looks at the shape, so it works the same on every timeframe.
- Step 5: watch for the breakout. When a candle closes outside the triangle, a ▲ or ▼ is printed and an alert can fire.


[b]Settings explained:[/b]

- Swing strength (bars before): how many candles before a point it must beat to count as a swing high or low. Bigger number = bigger, fewer patterns.
- Swing confirmation (bars after): how many candles must close after a swing point to confirm it. Bigger number = more reliable but later.
- Touches per side: how many swing points each line must touch. 2 = more patterns, 3 = cleaner textbook patterns.
- Flat line tolerance (% of height): how flat a line must be to count as flat. Lower = stricter ascending and descending triangles.
- Symmetry ratio: how balanced a symmetrical triangle must be. Lower = more even angles.
- Touch / containment tolerance: how far price may poke outside the lines and still count. Measured in ATR (average candle size).
- Min / Max pattern length: shortest and longest triangle, in candles.
- Pattern types: switch each triangle type on or off.
- Style: colours, line width and fill.
- Breakout requires a close beyond the line: on = the candle must close outside (safer). Off = a wick outside is enough (earlier, more false signals).


[b]Alerts[/b]
You can get a notification when:
- a new triangle is found ("Triangle detected")
- price breaks out upwards ("Triangle bullish breakout")
- price breaks down ("Triangle bearish breakdown")
- How to set it up: click the Alert (clock) button, choose this indicator under "Condition", then pick the alert you want. Choose "Any alert() function call" to get one alert that also tells you the triangle type and the price.

[b]Tips for beginners[/b]
- Start on higher timeframes (4-hour, daily). Patterns there are usually cleaner than on 1-minute charts.
- Too few patterns? Lower "Swing strength" or raise the tolerances.
- Too many weak patterns? Set "Touches per side" to 3 or raise "Min pattern length".
- Wait for the candle to close. A breakout mark only appears on a closed candle.
- Use it together with your own analysis (trend, support and resistance, volume) and your own risk management.

[i]This indicator is for educational and analytical purposes only. It is not financial advice. Trading involves risk. Always use proper risk management and combine this indicator with your own analysis before taking any trade.[/i]

## Source Code

````pine
//@version=6
indicator("Auto Triangle Patterns [HexaTrades]", shorttitle = "HexaTrades Triangles", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 1000)

// ─────────────────────────────────────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────────────────────────────────────
grpD = "Detection"
pivLeft  = input.int(5, "Swing strength (bars before)", minval = 1, group = grpD, tooltip = "A swing high/low must be the highest/lowest point for this many bars before it.")
pivRight = input.int(5, "Swing confirmation (bars after)", minval = 1, group = grpD, tooltip = "A swing high/low is confirmed after this many bars, so patterns appear with this delay.")
touches  = input.int(2, "Touches per side", minval = 2, maxval = 4, group = grpD, tooltip = "Number of swing highs / swing lows each trendline must pass through.")
flatPct  = input.float(25, "Flat line tolerance (% of height)", minval = 5, maxval = 50, step = 5, group = grpD, tooltip = "A trendline counts as flat (horizontal) if it moves less than this % of the triangle's height over the whole pattern. Used for ascending (flat top) and descending (flat bottom) triangles.")
symRatio = input.float(3.0, "Symmetry ratio (max)", minval = 1.5, maxval = 10, step = 0.5, group = grpD, tooltip = "For a symmetrical triangle the steeper line may be at most this many times steeper than the other. Lower = stricter, more balanced triangles.")
fitTol   = input.float(0.5, "Touch / containment tolerance (× ATR)", minval = 0.05, step = 0.05, group = grpD, tooltip = "How far swing points may sit off the line, and how far price may poke outside the pattern before it is rejected.")
minBars  = input.int(15, "Min pattern length (bars)", minval = 5, group = grpD)
maxBars  = input.int(200, "Max pattern length (bars)", minval = 20, maxval = 900, group = grpD)
atrLen   = input.int(14, "ATR length", minval = 1, group = grpD)

grpT = "Pattern types"
showAsc  = input.bool(true, "Ascending", group = grpT)
showDesc = input.bool(true, "Descending", group = grpT)
showSym  = input.bool(true, "Symmetrical", group = grpT)

grpS = "Style"
colAsc   = input.color(color.teal, "Ascending", group = grpS)
colDesc  = input.color(color.red, "Descending", group = grpS)
colSym   = input.color(color.blue, "Symmetrical", group = grpS)
lineW    = input.int(2, "Line width", minval = 1, maxval = 5, group = grpS)
showFill = input.bool(true, "Fill pattern", group = grpS)

grpB = "Breakout"
useClose = input.bool(true, "Breakout requires a close beyond the line", group = grpB, tooltip = "Off = a wick through the line counts as a breakout.")
showBO   = input.bool(true, "Show breakout arrows", group = grpB)
colBull  = input.color(color.green, "Breakout arrow", group = grpB, inline = "arrows")
colBear  = input.color(color.red, "Breakdown arrow", group = grpB, inline = "arrows")

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────
type Pivot
    int   x
    float y

type Triangle
    string   kind
    int      xu          // anchor bar of upper line
    float    yu          // anchor price of upper line
    float    su          // upper slope (price per bar)
    int      xl
    float    yl
    float    sl
    int      startX
    int      lastPivotX
    int      apexX
    int      endX
    line     upper
    line     lower
    linefill fill
    label    tag
    bool     active = true

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
// Fits a line through the first and last of the last `n` pivots and checks
// that every pivot in between lies within `tol` of it.
fitLine(array<Pivot> pts, int n, float tol) =>
    int   sz = pts.size()
    bool  ok = sz >= n
    int   x1 = na
    float y1 = na
    float s  = na
    if ok
        Pivot a = pts.get(sz - n)
        Pivot b = pts.get(sz - 1)
        x1 := a.x
        y1 := a.y
        s  := (b.y - a.y) / (b.x - a.x)
        if n > 2
            for i = sz - n + 1 to sz - 2
                Pivot p = pts.get(i)
                if math.abs(p.y - (y1 + s * (p.x - x1))) > tol
                    ok := false
    [ok, x1, y1, s]

lineAt(int x0, float y0, float s, int x) => y0 + s * (x - x0)

kindColor(string kind) => kind == "Ascending" ? colAsc : kind == "Descending" ? colDesc : colSym

// ─────────────────────────────────────────────────────────────────────────────
// Swing high / low collection
// ─────────────────────────────────────────────────────────────────────────────
var array<Pivot> highs = array.new<Pivot>()
var array<Pivot> lows  = array.new<Pivot>()

atr = ta.atr(atrLen)
ph  = ta.pivothigh(high, pivLeft, pivRight)
pl  = ta.pivotlow(low, pivLeft, pivRight)

if not na(ph)
    highs.push(Pivot.new(bar_index - pivRight, ph))
    if highs.size() > 10
        highs.shift()
if not na(pl)
    lows.push(Pivot.new(bar_index - pivRight, pl))
    if lows.size() > 10
        lows.shift()

// ─────────────────────────────────────────────────────────────────────────────
// Pattern detection (runs only when a new swing high / low is confirmed)
// ─────────────────────────────────────────────────────────────────────────────
var Triangle tri = na

bool newPattern = false
bool bullBreak  = false
bool bearBreak  = false

if (not na(ph) or not na(pl)) and highs.size() >= touches and lows.size() >= touches and not na(atr)
    tol = fitTol * atr
    [okU, xu, yu, su] = fitLine(highs, touches, tol)
    [okL, xl, yl, sl] = fitLine(lows, touches, tol)
    if okU and okL
        int startX = math.min(xu, xl)
        int lastX  = math.max(highs.last().x, lows.last().x)
        int span   = lastX - startX

        float uStart = lineAt(xu, yu, su, startX)
        float lStart = lineAt(xl, yl, sl, startX)
        float uNow   = lineAt(xu, yu, su, bar_index)
        float lNow   = lineAt(xl, yl, sl, bar_index)

        // Textbook shape rules, measured against the triangle's own height
        // (widest point) so they don't depend on volatility or timeframe.
        float height = uStart - lStart
        bool upFlat = height > 0 and math.abs(su * span) <= flatPct / 100 * height
        bool loFlat = height > 0 and math.abs(sl * span) <= flatPct / 100 * height
        bool upFall = su < 0 and not upFlat
        bool loRise = sl > 0 and not loFlat
        // Symmetrical = both lines converge at similar angles
        bool balanced = upFall and loRise and math.max(-su, sl) / math.min(-su, sl) <= symRatio

        // Ascending   : flat top,     rising bottom
        // Descending  : falling top,  flat bottom
        // Symmetrical : falling top,  rising bottom, balanced slopes
        // Anything else (wedges, rectangles, lopsided shapes) is rejected.
        string kind = upFlat and loRise ? "Ascending" : upFall and loFlat ? "Descending" : balanced ? "Symmetrical" : na
        bool enabled = kind == "Ascending" ? showAsc : kind == "Descending" ? showDesc : kind == "Symmetrical" ? showSym : false

        // Apex = where the two lines intersect
        float apexF = su != sl ? (yl - sl * xl - yu + su * xu) / (su - sl) : na

        // Highs and lows must interleave (both lines cover the same stretch of time)
        bool overlap = xu < lows.last().x and xl < highs.last().x

        bool valid = enabled and overlap and span >= minBars and not na(apexF) and apexF > bar_index and apexF - startX <= maxBars and uStart > lStart and uNow > lNow

        // Price must have stayed inside the triangle from start until now
        if valid
            for k = 0 to bar_index - startX
                int   x = bar_index - k
                float u = lineAt(xu, yu, su, x)
                float l = lineAt(xl, yl, sl, x)
                if high[k] > u + tol or low[k] < l - tol
                    valid := false
                    break

        // Don't redraw over a pattern that already resolved
        if valid and not na(tri) and not tri.active and startX < tri.endX
            valid := false

        if valid
            color c = kindColor(kind)
            // Last whole bar before the lines cross (rounding could land past the true apex)
            int apexX = int(math.floor(apexF))
            if not na(tri) and tri.active and startX <= tri.lastPivotX
                // Same pattern got another touch — refine its geometry in place
                tri.kind       := kind
                tri.xu         := xu
                tri.yu         := yu
                tri.su         := su
                tri.xl         := xl
                tri.yl         := yl
                tri.sl         := sl
                tri.startX     := startX
                tri.lastPivotX := lastX
                tri.apexX      := apexX
                tri.upper.set_xy1(startX, uStart)
                tri.upper.set_xy2(bar_index, uNow)
                tri.upper.set_color(c)
                tri.lower.set_xy1(startX, lStart)
                tri.lower.set_xy2(bar_index, lNow)
                tri.lower.set_color(c)
                tri.fill.set_color(showFill ? color.new(c, 90) : na)
                tri.tag.set_xy(startX, uStart)
                tri.tag.set_text(kind + " Triangle")
                tri.tag.set_color(c)
            else
                if not na(tri) and tri.active
                    // A newer pattern replaces one that never broke out
                    tri.active := false
                    tri.endX := bar_index
                    tri.upper.set_style(line.style_dashed)
                    tri.lower.set_style(line.style_dashed)
                    tri.tag.set_color(color.new(kindColor(tri.kind), 60))
                    tri.tag.set_text(tri.kind + " Triangle (no breakout)")
                line up = line.new(startX, uStart, bar_index, uNow, color = c, width = lineW)
                line lo = line.new(startX, lStart, bar_index, lNow, color = c, width = lineW)
                linefill f = linefill.new(up, lo, showFill ? color.new(c, 90) : na)
                label t = label.new(startX, uStart, kind + " Triangle", style = label.style_label_down, color = c, textcolor = color.white, size = size.small)
                tri := Triangle.new(kind, xu, yu, su, xl, yl, sl, startX, lastX, apexX, na, up, lo, f, t)
                newPattern := true

// ─────────────────────────────────────────────────────────────────────────────
// Extend active pattern & watch for breakout / expiry
// ─────────────────────────────────────────────────────────────────────────────
if not na(tri) and tri.active
    float uNow = lineAt(tri.xu, tri.yu, tri.su, bar_index)
    float lNow = lineAt(tri.xl, tri.yl, tri.sl, bar_index)
    tri.upper.set_xy2(bar_index, uNow)
    tri.lower.set_xy2(bar_index, lNow)

    if barstate.isconfirmed
        float upSrc = useClose ? close : high
        float dnSrc = useClose ? close : low
        color c = kindColor(tri.kind)
        bool upHit = upSrc > uNow
        bool dnHit = dnSrc < lNow
        if upHit and dnHit
            // Wick pierced both lines: let the close decide, or no breakout if it closed inside
            upHit := close > uNow
            dnHit := close < lNow
        if upHit
            bullBreak := true
            tri.active := false
            tri.endX := bar_index
            alert(tri.kind + " triangle: bullish breakout on " + syminfo.ticker + " at " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
        else if dnHit
            bearBreak := true
            tri.active := false
            tri.endX := bar_index
            alert(tri.kind + " triangle: bearish breakdown on " + syminfo.ticker + " at " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
        else if bar_index >= tri.apexX or bar_index - tri.startX > maxBars
            // Reached the apex without a breakout — pattern failed
            tri.active := false
            tri.endX := bar_index
            tri.upper.set_style(line.style_dashed)
            tri.lower.set_style(line.style_dashed)
            tri.tag.set_color(color.new(c, 60))
            tri.tag.set_text(tri.kind + " Triangle (expired)")

if newPattern
    alert(tri.kind + " triangle detected on " + syminfo.ticker, alert.freq_once_per_bar_close)

// ─────────────────────────────────────────────────────────────────────────────
// Alert conditions (for the "Create Alert" dialog)
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(newPattern, "Triangle detected", "Triangle pattern detected on {{ticker}}")
alertcondition(bullBreak, "Triangle bullish breakout", "Triangle bullish breakout on {{ticker}} at {{close}}")
alertcondition(bearBreak, "Triangle bearish breakdown", "Triangle bearish breakdown on {{ticker}} at {{close}}")

// Small arrows on breakout bars
plotshape(showBO and bullBreak, "Breakout", shape.triangleup, location.belowbar, colBull, size = size.tiny, display = display.all - display.status_line)
plotshape(showBO and bearBreak, "Breakdown", shape.triangledown, location.abovebar, colBear, size = size.tiny, display = display.all - display.status_line)
````
