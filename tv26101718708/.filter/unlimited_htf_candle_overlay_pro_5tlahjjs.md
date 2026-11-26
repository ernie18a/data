# Unlimited HTF Candle Overlay (Pro) 

- url: https://www.tradingview.com/script/5TlAHjjS-Unlimited-HTF-Candle-Overlay-Pro/
- type: indicator
- pine_id: PUB;04192e38ec8f4bcc83009eac2901908f
- version: 1.0

## Description

Multi HTF Candle Overlay (Pro) — Higher Timeframe Candles + Candle Close Countdown

Plot [b]higher timeframe candles [/b]directly on your chart, right next to live price. This **multi‑timeframe (MTF)** indicator projects the most recent HTF candles into the space to the right of current price, so you can read bigger‑picture trend and market structure without switching charts.

The right‑most candle in each group is the live, forming HTF candle — it updates in real time with a label showing the timeframe and a countdown to candle close (e.g. `4H  18:38`). The candles to its left are the most recent closed higher‑timeframe candles, oldest to newest.

Features
- Show up to 3 higher timeframes on one chart (e.g. 1H, 4H, Daily)
- 1–50 candles per timeframe — fully configurable, no fixed cap
- Live forming candle with candle‑close countdown timer and clean timeframe labels (`4H`, `15m`, `1D`…)
- 50% equilibrium level of the previous candle (premium/discount reference)
- Full control over colors, candle width, candle gap, and spacing
- Centered wicks at any width; non‑repainting (redraws on the live bar only)

Best for: multi‑timeframe analysis, top‑down bias, ICT / SMC trading, scalping and day trading with higher‑timeframe confluence — works on forex, gold (XAUUSD), crypto, indices, and stocks.

*Tip: enable your HTF slots, set how many candles to show, and use the countdown to time entries around higher‑timeframe closes.*

---

**SEO quick tips for publishing:**
- **Title:** lead with the primary keyword — *"HTF Candles — Multi Timeframe Overlay with Close Countdown"* ranks better than a brand‑only name.
- **First 1–2 lines matter most** — TradingView truncates previews, so the keywords up top do the heaviest lifting (already front‑loaded above).
- **Tags/categories:** add `Multiple Time Frame Analysis`, `Trend Analysis`, `Chart patterns` when publishing.

Want me to also generate a shorter one‑line summary for the title field?

## Source Code

````pine
//@version=6
// Multi HTF Candle Overlay (Pro)
// Projects the most recent higher-timeframe candles to the right of live price.
// Re-creates the "Multi HTF Candle Overlay (Minimal)" feature set with:
//   * configurable candle count (no 5-candle cap)
//   * candle gap + spacing controls
//   * 3 HTF slots, per-TF colors, HTF labels w/ time remaining, 50% level of previous candle
indicator("Multi HTF Candle Overlay (Pro)", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ============================ GENERAL ============================
gGen = "General"
spacingFromPrice = input.int(10,  "Spacing From Current Price (bars)", minval = 0, group = gGen)
spacingBetween   = input.int(10,  "Spacing Between Timeframes (bars)", minval = 0, group = gGen)
candleGap        = input.int(1,   "Gap Between Candles (bars)",        minval = 0, group = gGen)
showLabels       = input.bool(true,  "Show HTF Labels",                group = gGen)
showTimeRem      = input.bool(true,  "Show Time Remaining in Label",   group = gGen)
lblSizeStr       = input.string("normal", "Label Size", options = ["tiny", "small", "normal", "large", "huge"], group = gGen)
show50           = input.bool(true,  "Show 50% Level of Previous Candle", group = gGen)
col50            = input.color(color.yellow, "50% Level Color",        group = gGen)
style50Str       = input.string("dotted", "50% Level Style", options = ["dotted", "dashed", "solid"], group = gGen)
width50          = input.int(1,   "50% Level Width", minval = 1,       group = gGen)

// ---- helpers ----
f_lblSize(s) =>
    s == "tiny" ? size.tiny : s == "small" ? size.small : s == "large" ? size.large : s == "huge" ? size.huge : size.normal

f_lineStyle(s) =>
    s == "dotted" ? line.style_dotted : s == "dashed" ? line.style_dashed : line.style_solid

f_textColor(bg) =>
    lum = color.r(bg) * 0.299 + color.g(bg) * 0.587 + color.b(bg) * 0.114
    lum > 140 ? color.black : color.white

f_fmtRemain(ms) =>
    s  = math.max(0, math.floor(ms / 1000))
    hh = math.floor(s / 3600)
    mm = math.floor((s % 3600) / 60)
    ss = s % 60
    hPart = hh > 0 ? str.tostring(hh) + ":" : ""
    mPart = (hh > 0 and mm < 10 ? "0" : "") + str.tostring(mm) + ":"
    sPart = (ss < 10 ? "0" : "") + str.tostring(ss)
    hPart + mPart + sPart

// turn a raw timeframe string ("240", "60", "15", "1D"...) into a readable label ("4H", "1H", "15m", "1D")
f_tfLabel(_tf) =>
    int    len   = str.length(_tf)
    string lastc = str.substring(_tf, len - 1, len)
    string out   = _tf
    if lastc == "S"
        out := str.tostring(int(str.tonumber(str.substring(_tf, 0, len - 1)))) + "s"
    else if lastc == "D"
        out := str.tostring(int(str.tonumber(str.substring(_tf, 0, len - 1)))) + "D"
    else if lastc == "W"
        out := str.tostring(int(str.tonumber(str.substring(_tf, 0, len - 1)))) + "W"
    else if lastc == "M"
        out := str.tostring(int(str.tonumber(str.substring(_tf, 0, len - 1)))) + "M"
    else
        int m = int(str.tonumber(_tf))
        if m >= 60
            int hh2 = int(m / 60)
            int rem = m - hh2 * 60
            out := rem == 0 ? str.tostring(hh2) + "H" : str.tostring(hh2) + "H" + str.tostring(rem)
        else
            out := str.tostring(m) + "m"
    out

lblSize = f_lblSize(lblSizeStr)
style50 = f_lineStyle(style50Str)

// ============================ TIMEFRAME 1 ============================
g1 = "Timeframe 1"
en1   = input.bool(true,        "Enable HTF 1",      group = g1)
tf1   = input.timeframe("60",   "Timeframe 1",       group = g1)
cnt1  = input.int(5,            "Number of Candles", minval = 1, maxval = 50, group = g1)
wid1  = input.int(5,            "Candle Width",      minval = 1, group = g1)
bull1 = input.color(#3a8f3a,    "Bullish Candle",    group = g1)
bear1 = input.color(#000000,    "Bearish Candle",    group = g1)
wick1 = input.color(#434651,    "Wick Color",        group = g1)
bord1 = input.color(#434651,    "Border Color",      group = g1)
lcol1 = input.color(#000000,    "Label Color",       group = g1)

// ============================ TIMEFRAME 2 ============================
g2 = "Timeframe 2"
en2   = input.bool(false,       "Enable HTF 2",      group = g2)
tf2   = input.timeframe("1W",   "Timeframe 2",       group = g2)
cnt2  = input.int(3,            "Number of Candles", minval = 1, maxval = 50, group = g2)
wid2  = input.int(7,            "Candle Width",      minval = 1, group = g2)
bull2 = input.color(#5cb85c,    "Bullish Candle",    group = g2)
bear2 = input.color(#e8505b,    "Bearish Candle",    group = g2)
wick2 = input.color(#434651,    "Wick Color",        group = g2)
bord2 = input.color(#434651,    "Border Color",      group = g2)
lcol2 = input.color(#ffffff,    "Label Color",       group = g2)

// ============================ TIMEFRAME 3 ============================
g3 = "Timeframe 3"
en3   = input.bool(false,       "Enable HTF 3",      group = g3)
tf3   = input.timeframe("1M",   "Timeframe 3",       group = g3)
cnt3  = input.int(2,            "Number of Candles", minval = 1, maxval = 50, group = g3)
wid3  = input.int(9,            "Candle Width",      minval = 1, group = g3)
bull3 = input.color(#34c8c8,    "Bullish Candle",    group = g3)
bear3 = input.color(#c834c8,    "Bearish Candle",    group = g3)
wick3 = input.color(#434651,    "Wick Color",        group = g3)
bord3 = input.color(#434651,    "Border Color",      group = g3)
lcol3 = input.color(#ffffff,    "Label Color",       group = g3)

// ============================ CORE ============================
// Returns the next horizontal cursor offset (in bars) so timeframes stack left->right.
f_drawHTF(_enable, _tf, _count, _width, _gap, _bull, _bear, _wick, _border, _lblCol, _startOff) =>
    // persistent rolling store of CLOSED htf candles
    var array<float> ao  = array.new_float()
    var array<float> ah  = array.new_float()
    var array<float> al  = array.new_float()
    var array<float> ac  = array.new_float()
    // persistent drawing handles (so we can wipe & redraw every tick)
    var array<box>   bxs = array.new<box>()
    var array<line>  lns = array.new<line>()
    var array<label> lbs = array.new<label>()

    [o, h, l, c, t] = request.security(syminfo.tickerid, _tf, [open, high, low, close, time], lookahead = barmerge.lookahead_off)

    // when the HTF rolls to a new bar, the prior LTF values held the just-closed HTF candle
    bool rolled = not na(t) and not na(t[1]) and t != t[1] and not na(o[1])
    if rolled
        array.push(ao, o[1])
        array.push(ah, h[1])
        array.push(al, l[1])
        array.push(ac, c[1])
        if array.size(ao) > 200
            array.shift(ao)
            array.shift(ah)
            array.shift(al)
            array.shift(ac)

    int _nextOff = _startOff

    if _enable and barstate.islast
        // wipe previous frame
        for b in bxs
            box.delete(b)
        for ln in lns
            line.delete(ln)
        for lb in lbs
            label.delete(lb)
        array.clear(bxs)
        array.clear(lns)
        array.clear(lbs)

        int   slot     = _width + _gap
        int   sz       = array.size(ao)
        int   wantComp = _count - 1
        int   showComp = math.min(wantComp, sz)
        int   lastIdx  = bar_index
        int   limitX   = lastIdx + 500           // Pine forward-drawing ceiling

        // --- closed candles, oldest -> newest, left to right ---
        for p = 0 to showComp - 1
            int   aIdx  = sz - showComp + p
            float co    = array.get(ao, aIdx)
            float ch    = array.get(ah, aIdx)
            float cl    = array.get(al, aIdx)
            float cc    = array.get(ac, aIdx)
            int   half  = int(_width / 2)
            int   left  = lastIdx + _startOff + p * slot
            int   mid   = left + half
            int   right = mid + half          // body symmetric around the wick
            if right > limitX
                break
            color body  = cc >= co ? _bull : _bear
            array.push(lns, line.new(mid, ch, mid, cl, xloc = xloc.bar_index, color = _wick, width = 1))
            array.push(bxs, box.new(left, math.max(co, cc), right, math.min(co, cc), xloc = xloc.bar_index, border_color = _border, bgcolor = body, border_width = 1))

        // --- live / forming candle (rightmost) ---
        int  fhalf  = int(_width / 2)
        int  fp     = showComp
        int  fleft  = lastIdx + _startOff + fp * slot
        int  fmid   = fleft + fhalf
        int  fright = fmid + fhalf            // body symmetric around the wick
        if fright <= limitX
            color fbody = c >= o ? _bull : _bear
            array.push(lns, line.new(fmid, h, fmid, l, xloc = xloc.bar_index, color = _wick, width = 1))
            array.push(bxs, box.new(fleft, math.max(o, c), fright, math.min(o, c), xloc = xloc.bar_index, border_color = _border, bgcolor = fbody, border_width = 1))

            if showLabels
                string txt = f_tfLabel(_tf)
                if showTimeRem
                    txt := txt + "  " + f_fmtRemain(time_close(_tf) - timenow)
                array.push(lbs, label.new(fright + 1, h, txt, xloc = xloc.bar_index, style = label.style_label_left, color = _lblCol, textcolor = f_textColor(_lblCol), size = lblSize))

        // --- 50% level of the previous (most recent closed) candle ---
        if show50 and sz > 0
            float midPrice = (array.get(ah, sz - 1) + array.get(al, sz - 1)) / 2.0
            array.push(lns, line.new(lastIdx, midPrice, lastIdx + 1, midPrice, xloc = xloc.bar_index, color = col50, style = style50, width = width50, extend = extend.both))

        _nextOff := _startOff + (showComp + 1) * slot + spacingBetween

    _nextOff

// stack the three timeframes left -> right
int off = spacingFromPrice
off := f_drawHTF(en1, tf1, cnt1, wid1, candleGap, bull1, bear1, wick1, bord1, lcol1, off)
off := f_drawHTF(en2, tf2, cnt2, wid2, candleGap, bull2, bear2, wick2, bord2, lcol2, off)
off := f_drawHTF(en3, tf3, cnt3, wid3, candleGap, bull3, bear3, wick3, bord3, lcol3, off)
````
