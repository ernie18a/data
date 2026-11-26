# DC Trading - MTF Liquidity Raid

- url: https://www.tradingview.com/script/r6EN52js-DC-Trading-MTF-Liquidity-Raid/
- type: indicator
- pine_id: PUB;c782f526fc3e426aa63f99a363752ed1
- version: 1.0

## Description

DC Trading - MTF Liquidity Raid

OVERVIEW
MTF Liquidity Raid maps buyside and sellside liquidity on two timeframes at once: the chart timeframe and a higher timeframe of your choice. It tracks where resting liquidity sits, marks when it gets taken, and labels the moments where price sweeps a level and closes back inside — the classic liquidity raid used in ICT / Smart Money Concepts.

HOW IT WORKS
- Chart Liquidity: swing highs (buyside) and swing lows (sellside) are detected with a configurable swing length and drawn as dotted levels that extend to the right until price reaches them.
- Nearest Levels Only: the indicator keeps every valid level in memory but only displays the ones closest to current price (set by "Active Levels per Side"), keeping the chart clean.
- HTF Liquidity: swing levels from a higher timeframe (default 1H) are plotted in their own color. HTF levels are only drawn once the HTF swing is confirmed, so they do not repaint.
- Equal Highs / Lows: when two swings form at nearly the same price, they are merged into one level and labeled EQH (above) or EQL (below). The tolerance is based on ATR, so it adapts to any market.
- Taken Liquidity: when price trades through a level, the line stops, turns gray and dashed, and extends a few bars so the label stays clear of the candles.
- Sweeps: if price takes a level with a wick but closes back on the other side, the level is labeled "sweep" (or "EQH sweep", "EQL sweep", "HTF sweep").

SETTINGS
- Swing Length – sensitivity of swing detection.
- Max Level Age – how many bars a chart level stays valid.
- Active Levels per Side – how many levels are shown above and below price.
- Taken Levels to Keep per Side – how many taken levels stay visible.
- Extend Taken Line – bars the taken line extends after being hit.
- EQ Tolerance (x ATR) – how close two swings must be to count as equal.
- HTF Timeframe / HTF Swing Length / HTF Active Levels – higher timeframe settings.
- Fully customizable colors for each liquidity type.

ALERTS
Create an alert with the condition "Any alert() function call" to be notified of every sweep, including EQH/EQL and HTF sweeps.

HOW TO USE IT
Use HTF levels as the draw on liquidity — where price is likely heading. Use chart-timeframe levels and sweeps to time entries. A sweep that happens at or near an HTF level carries more weight than one in the middle of the range.

DISCLAIMER
This indicator is a visual tool for studying liquidity and market structure. It does not give buy or sell signals and does not guarantee any result. Always use your own analysis and risk management.

## Source Code

````pine
//@version=6
indicator("DC Trading - MTF Liquidity Raid", shorttitle = "DC MTF Raid", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ───────── Inputs ─────────
swingLen  = input.int(10, "Swing Length", minval = 2, group = "Liquidity")
maxAge    = input.int(500, "Max Level Age (bars)", minval = 20, group = "Liquidity")
maxShow   = input.int(2, "Active Levels per Side", minval = 1, maxval = 10, group = "Liquidity")
keepTaken = input.int(1, "Taken Levels to Keep per Side", minval = 0, maxval = 20, group = "Liquidity")
takenExt  = input.int(5, "Extend Taken Line (bars)", minval = 0, maxval = 50, group = "Liquidity", tooltip = "Cuántas velas se extiende la línea después de ser tomada, para que la etiqueta no quede encima de la vela.")

confMode  = input.string("Candle Break", "Sweep Confirmation", options = ["Wick", "Candle Break"], group = "Sweep", tooltip = "Wick: marca el sweep apenas la mecha barre y cierra de vuelta.\nCandle Break: espera a que el precio cierre más allá del extremo opuesto de la vela del barrido.")
confBars  = input.int(3, "Max Bars to Confirm", minval = 1, maxval = 20, group = "Sweep")

showEq    = input.bool(true, "Detect EQH / EQL", group = "Equal Highs / Lows")
eqTol     = input.float(0.1, "EQ Tolerance (x ATR)", minval = 0.01, step = 0.05, group = "Equal Highs / Lows", tooltip = "Qué tan cerca deben estar dos swings para considerarse iguales. Más alto = detecta más EQH/EQL.")

showHTF   = input.bool(true, "Show HTF Levels", group = "HTF Liquidity")
htf       = input.timeframe("60", "HTF Timeframe", group = "HTF Liquidity")
htfLen    = input.int(5, "HTF Swing Length", minval = 2, group = "HTF Liquidity")
htfShow   = input.int(2, "HTF Active Levels per Side", minval = 1, maxval = 10, group = "HTF Liquidity")

colHigh  = input.color(color.new(#ef5350, 0), "Buyside Liquidity", group = "Style")
colLow   = input.color(color.new(#26a69a, 0), "Sellside Liquidity", group = "Style")
colTaken = input.color(color.new(#787b86, 30), "Taken Liquidity", group = "Style")
htfHigh  = input.color(color.new(#ff9800, 0), "HTF Buyside", group = "Style")
htfLow   = input.color(color.new(#2962ff, 0), "HTF Sellside", group = "Style")

// ───────── Types ─────────
type Liq
    float price
    int   left
    bool  isHigh
    bool  isHTF
    bool  isEq
    line  ln
    label lb
    label eqLb
    bool  alive = true

type Pend
    Liq   q
    float ext
    float trig
    int   bar
    bool  isHigh

var array<Liq>  highs   = array.new<Liq>()
var array<Liq>  lows    = array.new<Liq>()
var array<Liq>  takenH  = array.new<Liq>()
var array<Liq>  takenL  = array.new<Liq>()
var array<Liq>  hHighs  = array.new<Liq>()
var array<Liq>  hLows   = array.new<Liq>()
var array<Liq>  hTakenH = array.new<Liq>()
var array<Liq>  hTakenL = array.new<Liq>()
var array<Pend> pend    = array.new<Pend>()

ph    = ta.pivothigh(high, swingLen, swingLen)
pl    = ta.pivotlow(low, swingLen, swingLen)
atrV  = ta.atr(14)
barMs = timeframe.in_seconds() * 1000

// ───────── HTF Data (sin repintado) ─────────
f_htfData() =>
    float h = ta.pivothigh(high, htfLen, htfLen)
    float l = ta.pivotlow(low, htfLen, htfLen)
    [h[1], l[1], time[htfLen + 1]]

[hph, hpl, hpt] = request.security(syminfo.tickerid, htf, f_htfData(), lookahead = barmerge.lookahead_on)
htfOn = showHTF and timeframe.in_seconds(htf) > timeframe.in_seconds()

var int lastHT = na
var int lastLT = na

// ───────── Functions ─────────
f_color(Liq q) =>
    q.isHTF ? (q.isHigh ? htfHigh : htfLow) : (q.isHigh ? colHigh : colLow)

f_deleteLiq(Liq q) =>
    q.alive := false
    if not na(q.ln)
        q.ln.delete()
    if not na(q.lb)
        q.lb.delete()
    if not na(q.eqLb)
        q.eqLb.delete()

f_markSweep(Liq q, bool isHigh, int x) =>
    string tag = q.isHTF ? "HTF sweep" : q.isEq ? (isHigh ? "EQH sweep" : "EQL sweep") : "sweep"
    q.lb := label.new(x + takenExt, q.price, tag, style = label.style_label_left, color = color.new(color.black, 100), textcolor = q.isHTF ? f_color(q) : colTaken, size = size.tiny)
    string side = q.isEq ? (isHigh ? "EQH" : "EQL") : (isHigh ? "Buyside" : "Sellside")
    alert((q.isHTF ? "HTF " : "") + side + " sweep @ " + str.tostring(q.price, format.mintick), alert.freq_once_per_bar_close)

f_addPivot(array<Liq> arr, float p, int x, bool isHigh, float tol) =>
    color c   = isHigh ? colHigh : colLow
    float lvl = p
    int   x1  = x
    bool  eq  = false
    if showEq and arr.size() > 0
        for i = arr.size() - 1 to 0
            Liq q = arr.get(i)
            if math.abs(q.price - p) <= tol
                lvl := isHigh ? math.max(p, q.price) : math.min(p, q.price)
                x1  := q.ln.get_x1()
                eq  := true
                f_deleteLiq(q)
                arr.remove(i)
                break
    line  ln  = line.new(x1, lvl, bar_index, lvl, extend = extend.right, color = color.new(c, 45), style = line.style_dotted, width = 1)
    label eLb = na
    if eq
        eLb := label.new(math.round((x1 + x) / 2.0), lvl, isHigh ? "EQH" : "EQL", style = isHigh ? label.style_label_down : label.style_label_up, color = color.new(color.black, 100), textcolor = color.new(c, 20), size = size.tiny)
    arr.push(Liq.new(price = lvl, left = x, isHigh = isHigh, isHTF = false, isEq = eq, ln = ln, eqLb = eLb))
    if arr.size() > 50
        f_deleteLiq(arr.shift())

f_addHTF(array<Liq> arr, float p, int t, bool isHigh) =>
    color c  = isHigh ? htfHigh : htfLow
    line  ln = line.new(t, p, time, p, xloc = xloc.bar_time, extend = extend.right, color = color.new(c, 45), style = line.style_dotted, width = 1)
    arr.push(Liq.new(price = p, left = bar_index, isHigh = isHigh, isHTF = true, isEq = false, ln = ln))
    if arr.size() > 20
        f_deleteLiq(arr.shift())

f_checkTaken(array<Liq> arr, array<Liq> taken, bool isHigh) =>
    if arr.size() > 0
        for i = arr.size() - 1 to 0
            Liq q = arr.get(i)
            bool hit = isHigh ? high > q.price : low < q.price
            if hit
                bool sweep = isHigh ? close < q.price : close > q.price
                arr.remove(i)
                q.ln.set_extend(extend.none)
                q.ln.set_x2(q.isHTF ? time + takenExt * barMs : bar_index + takenExt)
                q.ln.set_color(colTaken)
                q.ln.set_style(line.style_dashed)
                if not na(q.eqLb)
                    q.eqLb.set_textcolor(colTaken)
                if sweep
                    if confMode == "Wick"
                        f_markSweep(q, isHigh, bar_index)
                    else
                        pend.push(Pend.new(q, isHigh ? high : low, isHigh ? low : high, bar_index, isHigh))
                taken.push(q)
                while taken.size() > keepTaken
                    f_deleteLiq(taken.shift())
            else if not q.isHTF and bar_index - q.left > maxAge
                arr.remove(i)
                f_deleteLiq(q)

f_processPend() =>
    if pend.size() > 0
        for i = pend.size() - 1 to 0
            Pend p = pend.get(i)
            if bar_index > p.bar
                bool fail = p.isHigh ? close > p.ext : close < p.ext
                bool conf = p.isHigh ? close < p.trig : close > p.trig
                if not p.q.alive or fail
                    pend.remove(i)
                else if conf
                    f_markSweep(p.q, p.isHigh, p.bar)
                    pend.remove(i)
                else if bar_index - p.bar >= confBars
                    pend.remove(i)

f_rank(array<Liq> arr, int show) =>
    int n = arr.size()
    if n > 0
        array<float> d = array.new<float>()
        for q in arr
            d.push(math.abs(q.price - close))
        array<int> idx = d.sort_indices(order.ascending)
        for k = 0 to n - 1
            Liq   q   = arr.get(idx.get(k))
            color c   = f_color(q)
            bool  vis = k < show
            q.ln.set_color(vis ? color.new(c, 45) : color.new(c, 100))
            if not na(q.eqLb)
                q.eqLb.set_textcolor(vis ? color.new(c, 20) : color.new(c, 100))

// ───────── Logic ─────────
if barstate.isconfirmed
    f_processPend()
    f_checkTaken(highs, takenH, true)
    f_checkTaken(lows, takenL, false)
    f_checkTaken(hHighs, hTakenH, true)
    f_checkTaken(hLows, hTakenL, false)
    if not na(ph)
        f_addPivot(highs, ph, bar_index - swingLen, true, atrV * eqTol)
    if not na(pl)
        f_addPivot(lows, pl, bar_index - swingLen, false, atrV * eqTol)
    if htfOn and not na(hph) and (na(lastHT) or hpt != lastHT)
        lastHT := hpt
        f_addHTF(hHighs, hph, hpt, true)
    if htfOn and not na(hpl) and (na(lastLT) or hpt != lastLT)
        lastLT := hpt
        f_addHTF(hLows, hpl, hpt, false)

if barstate.islast
    f_rank(highs, maxShow)
    f_rank(lows, maxShow)
    f_rank(hHighs, htfShow)
    f_rank(hLows, htfShow)
````
