# 4hr/ 1hr Highs & Lows - profdro

- url: https://www.tradingview.com/script/y3q1eFZ1-4hr-1hr-Highs-Lows-profdro/
- type: indicator
- pine_id: PUB;1f711619baf143069670c5b4a084548d
- version: 1.0

## Description

Marks highs and lows on 4hr and 1hr timeframes. Expiration of highs and lows can be adjusted in settings.

## Source Code

````pine
//@version=6
indicator("BSL/SSL Pivots (4h/1h)", overlay=true, max_lines_count=500, max_labels_count=500)

// ==================== INPUTS ====================
gTF    = "Timeframes"
gGen   = "General"
gColor = "Colors & Style"

show4h = input.bool(true, "Show 4h pivots", group=gTF)
show1h = input.bool(true, "Show 1h pivots", group=gTF)

expiry4hDays = input.int(7, "4h expiry (days)", minval=1, group=gGen)
expiry1hDays = input.int(2, "1h expiry (days)", minval=1, group=gGen)

highColor    = input.color(color.new(#089981, 0), "High (BSL) color",  group=gColor)
lowColor     = input.color(color.new(#f23645, 0), "Low (SSL) color",   group=gColor)
equalColor   = input.color(color.new(#22c55e, 0), "Equal color",       group=gColor)
useBold      = input.bool(true, "Bold",   inline="fmt", group=gColor)
useItalic    = input.bool(true, "Italic", inline="fmt", group=gColor)
lineStyleStr = input.string("Solid", "Line style", options=["Solid", "Dashed", "Dotted"], group=gColor)

// ==================== CONSTS / HELPERS ====================
TZ = syminfo.timezone

text_fmt = useBold and useItalic ? text.format_bold + text.format_italic : useBold ? text.format_bold : useItalic ? text.format_italic : text.format_none

lineStyle = lineStyleStr == "Dashed" ? line.style_dashed : lineStyleStr == "Dotted" ? line.style_dotted : line.style_solid

atrVal     = ta.atr(14)
yOff       = 0.15 * atrVal
expiry4hMs = expiry4hDays * 24 * 60 * 60 * 1000
expiry1hMs = expiry1hDays * 24 * 60 * 60 * 1000
DEDUP_FRAC = 0.0015  // 0.15% — 1h vs 4h cross-TF dedupe
EQUAL_FRAC = 0.0005  // 0.05% — same-TF equal-level merge

f_tf_match(simple string tf) => timeframe.in_seconds() <= timeframe.in_seconds(tf)
gate4h = f_tf_match("240")
gate1h = f_tf_match("60")

// ==================== UDT ====================
type Pivot
    line  ln
    label lbl
    int   t0
    float level
    bool  isHigh
    bool  isEqual

// ==================== STATE ====================
var array<Pivot> p4h = array.new<Pivot>()
var array<Pivot> p1h = array.new<Pivot>()

// ==================== HTF DATA ====================
[o1_4, c1_4, h1_4, l1_4, t1_4, o2_4, c2_4, h2_4, l2_4, t2_4] = request.security(syminfo.tickerid, "240", [open[1], close[1], high[1], low[1], time[1], open[2], close[2], high[2], low[2], time[2]], lookahead=barmerge.lookahead_on)

[o1_1, c1_1, h1_1, l1_1, t1_1, o2_1, c2_1, h2_1, l2_1, t2_1] = request.security(syminfo.tickerid, "60",  [open[1], close[1], high[1], low[1], time[1], open[2], close[2], high[2], low[2], time[2]], lookahead=barmerge.lookahead_on)

newBar4h = ta.change(t1_4) != 0
newBar1h = ta.change(t1_1) != 0

// ==================== FUNCTIONS ====================
f_add_pivot(array<Pivot> arr, bool isHigh, float level, int t0, color col, string lblText) =>
    ln  = line.new(t0, level, time, level, xloc=xloc.bar_time, color=col, extend=extend.right, width=1, style=lineStyle)
    yy  = isHigh ? level + yOff : level - yOff
    lbl = label.new(t0, yy, lblText, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_none, textcolor=color.black, size=size.tiny, text_formatting=text_fmt)
    p   = Pivot.new(ln, lbl, t0, level, isHigh, false)
    array.push(arr, p)

// If new pivot is within EQUAL_FRAC of an existing same-type pivot in same TF,
// upgrade that existing pivot to "Equal" at the more extreme price/anchor.
// Returns true if merged (so caller skips adding a new pivot).
f_check_equal(array<Pivot> arr, bool isHigh, float newLevel, int newT0, string lblEqual) =>
    matched = false
    sz = array.size(arr)
    if sz > 0
        for i = 0 to sz - 1
            if not matched
                p = array.get(arr, i)
                if p.isHigh == isHigh and math.abs(newLevel - p.level) / p.level <= EQUAL_FRAC
                    useNew = isHigh ? newLevel > p.level : newLevel < p.level
                    finalLevel = useNew ? newLevel : p.level
                    finalT0    = useNew ? newT0    : p.t0
                    p.level   := finalLevel
                    p.t0      := finalT0
                    p.isEqual := true
                    line.set_xy1(p.ln, finalT0, finalLevel)
                    line.set_xy2(p.ln, time, finalLevel)
                    line.set_color(p.ln, equalColor)
                    yy = isHigh ? finalLevel + yOff : finalLevel - yOff
                    label.set_xy(p.lbl, finalT0, yy)
                    label.set_text(p.lbl, lblEqual)
                    matched := true
    matched

f_check_pattern(bool show, bool gate, bool newBar, float o2, float c2, float h2, float l2, int t2, float o1, float c1, float h1, float l1, int t1, array<Pivot> arr, color colHigh, color colLow, string lblHigh, string lblLow, string lblEqual) =>
    if show and gate and newBar and not na(o2) and not na(o1)
        bull2 = c2 > o2
        bear2 = c2 < o2
        bull1 = c1 > o1
        bear1 = c1 < o1
        // High: bull -> bear (adjacent), level at higher wick of the two
        if bull2 and bear1
            level = math.max(h2, h1)
            t0    = h2 >= h1 ? t2 : t1
            if not f_check_equal(arr, true, level, t0, lblEqual)
                f_add_pivot(arr, true, level, t0, colHigh, lblHigh)
        // Low: bear -> bull (adjacent), level at lower wick of the two
        if bear2 and bull1
            level = math.min(l2, l1)
            t0    = l2 <= l1 ? t2 : t1
            if not f_check_equal(arr, false, level, t0, lblEqual)
                f_add_pivot(arr, false, level, t0, colLow, lblLow)

f_process(array<Pivot> arr, int expMs) =>
    sz = array.size(arr)
    if sz > 0
        toRemove = array.new<int>()
        for i = 0 to sz - 1
            p = array.get(arr, i)
            sweep   = (p.isHigh and high > p.level) or (not p.isHigh and low < p.level)
            expired = time - p.t0 > expMs
            if sweep or expired
                line.delete(p.ln)
                label.delete(p.lbl)
                array.push(toRemove, i)
        rsz = array.size(toRemove)
        if rsz > 0
            for j = 0 to rsz - 1
                idx = array.get(toRemove, rsz - 1 - j)
                array.remove(arr, idx)

// Delete any 1h pivot within DEDUP_FRAC of ANY 4h pivot (cross-type)
f_dedupe() =>
    sz1 = array.size(p1h)
    sz4 = array.size(p4h)
    if sz1 > 0 and sz4 > 0
        toRemove = array.new<int>()
        for i = 0 to sz1 - 1
            p1 = array.get(p1h, i)
            tooClose = false
            for j = 0 to sz4 - 1
                p4 = array.get(p4h, j)
                if math.abs(p1.level - p4.level) / p4.level <= DEDUP_FRAC
                    tooClose := true
                    break
            if tooClose
                line.delete(p1.ln)
                label.delete(p1.lbl)
                array.push(toRemove, i)
        rsz = array.size(toRemove)
        if rsz > 0
            for j = 0 to rsz - 1
                idx = array.get(toRemove, rsz - 1 - j)
                array.remove(p1h, idx)

// ==================== MAIN ====================
f_check_pattern(show4h, gate4h, newBar4h, o2_4, c2_4, h2_4, l2_4, t2_4, o1_4, c1_4, h1_4, l1_4, t1_4, p4h, highColor, lowColor, "4hr BSL", "4hr SSL", "4hr Equal")
f_check_pattern(show1h, gate1h, newBar1h, o2_1, c2_1, h2_1, l2_1, t2_1, o1_1, c1_1, h1_1, l1_1, t1_1, p1h, highColor, lowColor, "1hr BSL", "1hr SSL", "1hr Equal")

if newBar4h or newBar1h
    f_dedupe()

f_process(p4h, expiry4hMs)
f_process(p1h, expiry1hMs)
````
