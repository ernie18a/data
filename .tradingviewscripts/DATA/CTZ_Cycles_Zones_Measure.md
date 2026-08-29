<!-- tradingview-pine-id: PUB;85885ead3a164de3a2aba29ab0e853d3 -->
<!-- tradingviewscripts-format: 1 -->
# CTZ Cycles Zones + Measure

Source: https://www.tradingview.com/script/V0LpdOun-CTZ-Cycles-Zones-Measure/

## Description

Here's a TradingView-ready description. It's written for the publish box — plain, no markdown headers that TV won't render well — and it explains what the tool does, how each element works, and how to use it, without overpromising.

---

**CTZ Cycle Zones + Measure**

A forward-projection and measurement tool for cycle traders. It marks your key cycle pivots, measures the exact time and price move between them, and projects the next buy and sell windows ahead of price — so you can see where the cycle points next, not just where it has been.

WHAT IT DRAWS

Pivot tags — Label each confirmed cycle turn with its date and price. Tops are red, bottoms are green, matching how you read the structure.

Measure legs — Between each pivot the indicator draws a leg showing the number of days elapsed, the price change in dollars, and the percentage move. This is the same readout as the built-in trend-measure tool, but automatic and permanent, so you can compare one leg against another at a glance (top-to-bottom vs bottom-to-top, and so on).

Buy Zone — A projected accumulation window shaded green, placed a set number of days after your top pivot. A dashed centre line marks the average target date inside the window.

Sell Zone — A projected distribution window shaded red, placed a set number of days after the projected low. Its centre line marks the average date the next top is due.

Weekly and Yearly Lows — Automatic detection of weekly cycle lows (🚀 WCL) and yearly cycle lows (★ YCL) using pivot logic with cycle-spacing gates, so only genuine cycle turns are tagged. A lower low inside the yearly window supersedes the previous marker.

Next Low Projection — From the most recent detected weekly and yearly low, the tool projects the next low window forward as a shaded zone with a centre line on the average due date. As new lows confirm, the projections roll forward with them.

HOW TO USE IT

Enter your two real anchor pivots — the last major bottom and the last major top — in the settings, along with their prices. Set the buy-zone and sell-zone day ranges to your cycle's measured interval (defaults are tuned to a roughly one-year top-to-bottom and a longer bottom-to-top leg). The indicator then measures the legs between your pivots and projects the buy and sell windows into open chart space to the right of price.

The weekly and yearly low detection runs independently on the chart's own price action, so the WCL and YCL markers and their forward projections update on their own as the market prints new lows.

Everything is adjustable — pivot dates, prices, zone day-ranges, cycle lengths in weeks, lookbacks, and colours — so the same framework fits Bitcoin, other crypto, or any market with a repeating low-to-low rhythm.

NOTES

The zones are projections built from the intervals you supply and from historically measured cycle spacing. They mark where the cycle is due, not a guarantee of what price will do. Timing drifts from cycle to cycle, which is why each target is drawn as a window with a centre line rather than a single date. Use it as a timing framework alongside your own confirmation, not as a standalone signal.

For educational and analytical purposes only. Not financial advice.

---

## Source Code

````pine
//@version=6
indicator("CTZ Cycles Zones + Measure", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=100)

// ================= Real pivots =================
g1 = "Pivot 1 — Bottom (real)"
y1  = input.int(2022, "Year",  group=g1, inline="a")
m1  = input.int(11,   "Month", group=g1, inline="a", minval=1, maxval=12)
d1  = input.int(22,   "Day",   group=g1, inline="a", minval=1, maxval=31)
p1  = input.float(15476, "Price", group=g1)

g2 = "Pivot 2 — Top (real)"
y2  = input.int(2025, "Year",  group=g2, inline="b")
m2  = input.int(10,   "Month", group=g2, inline="b", minval=1, maxval=12)
d2  = input.int(6,    "Day",   group=g2, inline="b", minval=1, maxval=31)
p2  = input.float(126200, "Price", group=g2)

// ================= Buy zone (Top -> Low), in days =================
gB = "Buy Zone (Top → Low)"
buyStart = input.int(364, "Start (days)", group=gB, inline="bz")
buyEnd   = input.int(412, "End (days)",   group=gB, inline="bz")
pLow     = input.float(36193, "Projected Low Price", group=gB)

// ================= Sell zone (Low -> Top), in days =================
gS = "Sell Zone (Low → Top)"
sellStart = input.int(1020, "Start (days)", group=gS, inline="sz")
sellEnd   = input.int(1080, "End (days)",   group=gS, inline="sz")
pTop      = input.float(160970, "Projected Top Price", group=gS)

// ================= Weekly / Yearly lows (from CTZ logic) =================
gWY = "Weekly / Yearly Cycle Lows"
show_wcl = input.bool(true, "Show Weekly Lows (WCL)",  group=gWY)
wcl_lb   = input.int(21, "WCL Pivot Lookback (bars)", minval=5, group=gWY)
wcl_col  = input.color(color.new(#3b82f6, 0), "WCL Colour", group=gWY)
show_ycl = input.bool(true, "Show Yearly Lows (YCL)",  group=gWY)
ycl_lb   = input.int(60, "YCL Pivot Lookback (bars)", minval=20, group=gWY)
ycl_gap  = input.float(0.75, "YCL Min Spacing (× cycle length)", step=0.05, minval=0.3, maxval=1.0, group=gWY)
ycl_col  = input.color(color.new(#f59e0b, 0), "YCL Colour", group=gWY)

// ================= Weekly / Yearly highs (mirror of low logic) =================
gWYH = "Weekly / Yearly Cycle Highs"
show_wch = input.bool(true, "Show Weekly Highs (WCH)",  group=gWYH)
wch_lb   = input.int(21, "WCH Pivot Lookback (bars)", minval=5, group=gWYH)
wch_col  = input.color(color.new(#ef4444, 0), "WCH Colour", group=gWYH)
show_ych = input.bool(true, "Show Yearly Highs (YCH)",  group=gWYH)
ych_lb   = input.int(60, "YCH Pivot Lookback (bars)", minval=20, group=gWYH)
ych_gap  = input.float(0.75, "YCH Min Spacing (× cycle length)", step=0.05, minval=0.3, maxval=1.0, group=gWYH)
ych_col  = input.color(color.new(#dc2626, 0), "YCH Colour", group=gWYH)

// ================= Next-low projection windows =================
gNP = "Next Low Projection"
proj_wcl = input.bool(true, "Project Next Weekly Low",  group=gNP)
w_lo     = input.int(24, "WCL cycle min (weeks)", minval=1, group=gNP, inline="wp")
w_hi     = input.int(34, "WCL cycle max (weeks)", minval=1, group=gNP, inline="wp")
proj_ycl = input.bool(true, "Project Next Yearly Low",  group=gNP)
y_lo     = input.int(48, "YCL cycle min (weeks)", minval=1, group=gNP, inline="yp")
y_hi     = input.int(56, "YCL cycle max (weeks)", minval=1, group=gNP, inline="yp")

// ================= Next-high projection windows =================
gNPH = "Next High Projection"
proj_wch = input.bool(true, "Project Next Weekly High",  group=gNPH)
wh_lo    = input.int(24, "WCH cycle min (weeks)", minval=1, group=gNPH, inline="whp")
wh_hi    = input.int(34, "WCH cycle max (weeks)", minval=1, group=gNPH, inline="whp")
proj_ych = input.bool(true, "Project Next Yearly High",  group=gNPH)
yh_lo    = input.int(48, "YCH cycle min (weeks)", minval=1, group=gNPH, inline="yhp")
yh_hi    = input.int(56, "YCH cycle max (weeks)", minval=1, group=gNPH, inline="yhp")

// ================= Colours =================
greenCol = input.color(color.green, "Green (bottoms & up moves)")
redCol   = input.color(color.red,   "Red (tops & down moves)")
buyFill  = input.color(color.new(color.green, 88), "Buy Zone Fill")
sellFill = input.color(color.new(color.red,   88), "Sell Zone Fill")

// ================= Globals =================
msPerDay = 86400000
t1 = timestamp(y1, m1, d1, 0, 0)
t2 = timestamp(y2, m2, d2, 0, 0)

buyMid  = int((buyStart  + buyEnd)  / 2)
sellMid = int((sellStart + sellEnd) / 2)

t3 = t2 + buyMid  * msPerDay          // projected low  (centre of buy zone)
t4 = t3 + sellMid * msPerDay          // projected top  (centre of sell zone)

buyL  = t2 + buyStart  * msPerDay
buyR  = t2 + buyEnd    * msPerDay
sellL = t3 + sellStart * msPerDay
sellR = t3 + sellEnd   * msPerDay

var float hiTrack = na
var float loTrack = na
hiTrack := na(hiTrack) ? high : math.max(hiTrack, high)
loTrack := na(loTrack) ? low  : math.min(loTrack, low)

int dpw = syminfo.type == "crypto" ? 7 : 5
int dpy = syminfo.type == "crypto" ? 365 : 252
adr = ta.sma(high - low, 14)

var line[]  lns = array.new_line()
var label[] lbs = array.new_label()
var box[]   bxs = array.new_box()

// ================= Helpers =================
clearAll() =>
    for l in lns
        line.delete(l)
    array.clear(lns)
    for lb in lbs
        label.delete(lb)
    array.clear(lbs)
    for b in bxs
        box.delete(b)
    array.clear(bxs)

drawPivot(t, p, isTop) =>
    col   = isTop ? redCol : greenCol
    style = isTop ? label.style_label_down : label.style_label_up
    txt   = str.format_time(t, "dd MMM yyyy", "GMT") + "\n" + str.tostring(p, "#,###") + " USDT"
    array.push(lbs, label.new(t, p, txt, xloc=xloc.bar_time, yloc=yloc.price, style=style, color=col, textcolor=color.white, size=size.normal))

drawMeasure(tA, pA, tB, pB) =>
    up  = pB >= pA
    col = up ? greenCol : redCol
    hiT = up ? tB : tA
    hiP = math.max(pA, pB)
    loP = math.min(pA, pB)
    array.push(lns, line.new(hiT, loP, hiT, hiP, xloc=xloc.bar_time, color=col, width=2))
    array.push(lns, line.new(tA, loP, tB, loP, xloc=xloc.bar_time, color=col, width=1, style=line.style_dashed))
    days = int((tB - tA) / msPerDay)
    dp   = pB - pA
    pct  = dp / pA * 100
    sign = dp >= 0 ? "+" : ""
    txt  = str.tostring(days) + " days\n" + sign + str.tostring(dp, "#,###") + " USDT\n" + sign + str.tostring(pct, "#.##") + "%"
    array.push(lbs, label.new(int((tA + tB) / 2), hiP, txt, xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_center, color=color.new(color.black, 100), textcolor=chart.fg_color, size=size.normal))

drawZone(l, r, centreT, fill, borderC, tag) =>
    array.push(bxs, box.new(l, hiTrack, r, loTrack, xloc=xloc.bar_time, bgcolor=fill, border_color=borderC))
    array.push(lns, line.new(centreT, loTrack, centreT, hiTrack, xloc=xloc.bar_time, color=borderC, width=1, style=line.style_dashed))
    array.push(lbs, label.new(centreT, loTrack, tag + "\n" + str.format_time(centreT, "dd MMM yyyy", "GMT"), xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_up, color=borderC, textcolor=color.white, size=size.small))

// low-projection zone: from a confirmed low, project the next low window forward
drawLowZone(lowT, wksLo, wksHi, fill, borderC, tag) =>
    wk = 7 * msPerDay
    l  = lowT + wksLo * wk
    r  = lowT + wksHi * wk
    c  = int((l + r) / 2)
    array.push(bxs, box.new(l, hiTrack, r, loTrack, xloc=xloc.bar_time, bgcolor=fill, border_color=borderC))
    array.push(lns, line.new(c, loTrack, c, hiTrack, xloc=xloc.bar_time, color=borderC, width=1, style=line.style_dashed))
    array.push(lbs, label.new(c, loTrack, tag + "\n" + str.format_time(c, "dd MMM yyyy", "GMT"), xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_up, color=borderC, textcolor=color.white, size=size.small))

// high-projection zone: from a confirmed high, project the next high window forward
drawHighZone(hiT, wksLo, wksHi, fill, borderC, tag) =>
    wk = 7 * msPerDay
    l  = hiT + wksLo * wk
    r  = hiT + wksHi * wk
    c  = int((l + r) / 2)
    array.push(bxs, box.new(l, hiTrack, r, loTrack, xloc=xloc.bar_time, bgcolor=fill, border_color=borderC))
    array.push(lns, line.new(c, loTrack, c, hiTrack, xloc=xloc.bar_time, color=borderC, width=1, style=line.style_dashed))
    array.push(lbs, label.new(c, hiTrack, tag + "\n" + str.format_time(c, "dd MMM yyyy", "GMT"), xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_down, color=borderC, textcolor=color.white, size=size.small))

// ================= Weekly low detection (persistent markers) =================
wcl_piv = ta.pivotlow(low, wcl_lb, wcl_lb)
var int   wcl_bar   = na
var int   wcl_low_t = na
var array<label> wcl_q = array.new<label>()
int wcl_min_gap = math.max(20, math.round(24 * dpw * 0.6))

if show_wcl and not na(wcl_piv) and (na(wcl_bar) or (bar_index - wcl_lb) - wcl_bar >= wcl_min_gap)
    wcl_bar   := bar_index - wcl_lb
    wcl_low_t := time[wcl_lb]
    label wl = label.new(wcl_bar, low[wcl_lb] - adr * 3.0, "🚀 WCL",
         style=label.style_label_up, color=color.new(wcl_col, 10), textcolor=color.white, size=size.normal)
    array.push(wcl_q, wl)
    if array.size(wcl_q) > 20
        label.delete(array.shift(wcl_q))

// ================= Yearly low detection (lower low supersedes) =================
ycl_piv = ta.pivotlow(low, ycl_lb, ycl_lb)
var int   ycl_conf_bar = na
var float ycl_px       = na
var int   ycl_low_t    = na
var array<label> ycl_q = array.new<label>()
int ycl_min_gap = math.round(1 * dpy * ycl_gap)

if show_ycl and not na(ycl_piv)
    int   pbar = bar_index - ycl_lb
    float ppx  = low[ycl_lb]
    bool  new_window = na(ycl_conf_bar) or pbar - ycl_conf_bar >= ycl_min_gap
    bool  lower_low  = not new_window and not na(ycl_px) and ppx < ycl_px
    if new_window or lower_low
        if lower_low and array.size(ycl_q) > 0
            label.delete(array.pop(ycl_q))
        ycl_conf_bar := pbar
        ycl_px       := ppx
        ycl_low_t    := time[ycl_lb]
        label yl = label.new(ycl_conf_bar, ycl_px - adr * 6.0, "★ YCL",
             style=label.style_label_up, color=color.new(ycl_col, 5), textcolor=color.black, size=size.large)
        array.push(ycl_q, yl)
        if array.size(ycl_q) > 8
            label.delete(array.shift(ycl_q))

// ================= Weekly high detection (persistent markers) =================
wch_piv = ta.pivothigh(high, wch_lb, wch_lb)
var int   wch_bar    = na
var int   wch_high_t = na
var array<label> wch_q = array.new<label>()
int wch_min_gap = math.max(20, math.round(24 * dpw * 0.6))

if show_wch and not na(wch_piv) and (na(wch_bar) or (bar_index - wch_lb) - wch_bar >= wch_min_gap)
    wch_bar    := bar_index - wch_lb
    wch_high_t := time[wch_lb]
    label wh = label.new(wch_bar, high[wch_lb] + adr * 3.0, "🔴 WCH",
         style=label.style_label_down, color=color.new(wch_col, 10), textcolor=color.white, size=size.normal)
    array.push(wch_q, wh)
    if array.size(wch_q) > 20
        label.delete(array.shift(wch_q))

// ================= Yearly high detection (higher high supersedes) =================
ych_piv = ta.pivothigh(high, ych_lb, ych_lb)
var int   ych_conf_bar = na
var float ych_px       = na
var int   ych_high_t   = na
var array<label> ych_q = array.new<label>()
int ych_min_gap = math.round(1 * dpy * ych_gap)

if show_ych and not na(ych_piv)
    int   pbar = bar_index - ych_lb
    float ppx  = high[ych_lb]
    bool  new_window = na(ych_conf_bar) or pbar - ych_conf_bar >= ych_min_gap
    bool  higher_high = not new_window and not na(ych_px) and ppx > ych_px
    if new_window or higher_high
        if higher_high and array.size(ych_q) > 0
            label.delete(array.pop(ych_q))
        ych_conf_bar := pbar
        ych_px       := ppx
        ych_high_t   := time[ych_lb]
        label yh = label.new(ych_conf_bar, ych_px + adr * 6.0, "▼ YCH",
             style=label.style_label_down, color=color.new(ych_col, 5), textcolor=color.white, size=size.large)
        array.push(ych_q, yh)
        if array.size(ych_q) > 8
            label.delete(array.shift(ych_q))

// ================= Draw once, on the last bar =================
if barstate.islast
    clearAll()
    // zones
    drawZone(buyL,  buyR,  t3, buyFill,  greenCol, "Buy Zone (avg)")
    drawZone(sellL, sellR, t4, sellFill, redCol,   "Sell Zone (avg)")
    // measures across pivots
    drawMeasure(t1, p1, t2, p2)
    drawMeasure(t2, p2, t3, pLow)
    drawMeasure(t3, pLow, t4, pTop)
    // pivot tags
    drawPivot(t1, p1,   false)
    drawPivot(t2, p2,   true)
    drawPivot(t3, pLow, false)
    drawPivot(t4, pTop, true)
    // next-low projections from the most recent detected lows
    if proj_wcl and not na(wcl_low_t)
        drawLowZone(wcl_low_t, w_lo, w_hi, buyFill, wcl_col, "Next WCL")
    if proj_ycl and not na(ycl_low_t)
        drawLowZone(ycl_low_t, y_lo, y_hi, buyFill, ycl_col, "Next YCL")
    // next-high projections from the most recent detected highs
    if proj_wch and not na(wch_high_t)
        drawHighZone(wch_high_t, wh_lo, wh_hi, sellFill, wch_col, "Next WCH")
    if proj_ych and not na(ych_high_t)
        drawHighZone(ych_high_t, yh_lo, yh_hi, sellFill, ych_col, "Next YCH")
````
