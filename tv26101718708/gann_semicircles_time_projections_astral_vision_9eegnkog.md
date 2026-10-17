# Gann Semicircles Time Projections | Astral Vision 

- url: https://www.tradingview.com/script/9eegnKog/
- type: indicator
- pine_id: PUB;1762582acdc64c9a88f7ccec37983d10
- version: 2.0

## Description

[b]Gann Semicircles Time Projections | Astral Vision 🌠💠[/b]

This indicator projects Bitcoin's market cycle structure forward in time using a geometric framework based on W.D. Gann's semicircle theory, which treats time as the primary axis of market analysis. The core premise is that significant market cycles repeat in proportional time intervals, and that within each cycle the key inflection points (the parabolic acceleration phase, the cycle top, and the cycle bottom) occur at geometrically predictable subdivisions of the total cycle duration.

[b]Calculation ⚙️[/b]

The model is anchored to two historically significant Bitcoin cycle bottoms: January 14, 2015 and December 16, 2018. The distance in bars between these two anchors defines the base cycle length R. This cycle is then projected forward three times from the second anchor, producing four complete cycles in total: one historical (2015 to 2018), and three projected forward from 2018 onward.

Within each cycle of length R, the indicator draws a hierarchy of semicircles at three levels of subdivision. The first level draws a single large semicircle spanning the full cycle length R with a peak height of 1.0. The second level splits the cycle at the midpoint R/2 and draws two semicircles each with half the peak height, marking the parabolic acceleration zone at the cycle midpoint. The third level splits each half further into quarters R/4 and draws four smaller semicircles each with one quarter of the peak height, marking the early and late phases of each sub-cycle.

Each semicircle is constructed by computing 101 points distributed along a sine curve. For each point at position i from 0 to 100, the horizontal fraction along the cycle is computed as (1 - cos(π × i/100)) / 2, which produces a smooth non-linear distribution that accelerates toward the center and decelerates at the edges. The vertical coordinate at each point is sin(π × i/100) multiplied by the peak height. This produces a true geometric semicircle in the time-price space of the sub-panel.

The key time projections within each cycle are: the cycle top, placed at the three-quarter mark of the cycle (R × 3/4 from the cycle start), the parabolic move marker at the midpoint (R/2), and the cycle bottom at the end of the cycle (R). Each projection is labeled directly on the price chart at the high of the nearest historical bar, or at the last available high for future projections.

Each semicircle is rendered with three layered polylines at decreasing transparency and increasing line width to create a glow effect.

[b]Plots 📊[/b]
[list]
[*]Full-cycle semicircle spanning each complete cycle period, colored with the positive theme color
[*]Two half-cycle semicircles at R/2 subdivision, colored with the negative theme color
[*]Four quarter-cycle semicircles at R/4 subdivision, colored with the positive theme color
[*]All semicircles rendered with a three-layer glow effect
[*]Labels on the price chart marking Cycle Top, Parabolic Move, and Cycle Bottom at each key time projection
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]No period or length inputs: the cycle structure is fully derived from the two fixed historical anchors
[/list]

[b]Colors 🎨[/b]
5 Astral Vision presets + custom override. Default: Hermes.

[b]Purpose 🎯[/b]
Standard cycle indicators use fixed bar counts or calendar-based periodicity, which do not adapt to the proportional structure of each individual cycle. This indicator derives its forward projections entirely from the geometry of the two anchor points, meaning the projected cycle length is empirically grounded in Bitcoin's own historical behavior rather than imposed from outside. The three-level semicircle hierarchy provides a visual map of the entire cycle structure simultaneously, making it possible to identify not just when a top or bottom might occur but also the parabolic acceleration zone that precedes it, which is absent from linear cycle tools.

[b]Disclaimer ⭕️[/b]
This indicator is for informational and educational purposes only. It does not constitute financial advice. Past performance is not indicative of future results. Always do your own research before making investment decisions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision

//@version=6
indicator("Gann Semicircles Time Projections | Astral Vision 🌠💠", overlay=false, max_polylines_count=100)

theme      = input.string("Hermes", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group="Colors")
usecustom  = input.bool(false, "Custom Colors", group="Colors")
custom_pos = input.color(color.rgb(0,255,180), "Custom Positive", group="Colors")
custom_neg = input.color(color.rgb(180,0,255), "Custom Negative", group="Colors")

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)    :
     theme == "Paradiso" ? color.rgb(0,210,255)  :
     theme == "Futura"   ? color.rgb(0,255,180)  :
     theme == "Infinito" ? color.rgb(180,120,255):
     color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)    :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80) :
     color.rgb(0,180,120)

anchor1 = input.time(timestamp("2015-01-14"), "Anchor 1", group="Settings")
anchor2 = input.time(timestamp("2018-12-16"), "Anchor 2", group="Settings")

var int bar1     = na
var int bar2     = na
var int firstBar = na
var array<float> highHistory = array.new<float>()
var array<int>   timeHistory = array.new<int>()

if na(firstBar)
    firstBar := bar_index
array.push(highHistory, high)
array.push(timeHistory, time)

if na(bar1) and time >= anchor1 and time[1] < anchor1
    bar1 := bar_index
if na(bar2) and time >= anchor2 and time[1] < anchor2
    bar2 := bar_index

f_addSemiPoints(array<chart.point> pts, int bLeft, int bRight, float yPeak, int fBar, array<int> tHist) =>
    int n         = bRight - bLeft
    int maxIdx    = array.size(tHist) - 1
    int lastTime  = array.get(tHist, maxIdx)
    int firstTime = array.get(tHist, 0)
    int msPerBar  = (lastTime - firstTime) / maxIdx
    for i = 0 to 100
        float t     = i / 100.0
        float angle = math.pi * t
        float xFrac = (1 - math.cos(angle)) / 2
        float y     = math.sin(angle) * yPeak
        int b       = bLeft + math.round(xFrac * n)
        int idx     = b - fBar
        int barTime = idx <= maxIdx ? array.get(tHist, math.max(idx, 0)) : lastTime + (idx - maxIdx) * msPerBar
        array.push(pts, chart.point.from_time(barTime, y))

f_drawSemi(int bLeft, int bRight, float yPeak, int fBar, array<int> tHist, color baseCol) =>
    color g1 = color.new(baseCol, 55)
    color g2 = color.new(baseCol, 78)
    pts_a = array.new<chart.point>()
    f_addSemiPoints(pts_a, bLeft, bRight, yPeak, fBar, tHist)
    polyline.new(pts_a, curved=false, line_color=g2,      line_width=6, xloc=xloc.bar_time)
    pts_b = array.new<chart.point>()
    f_addSemiPoints(pts_b, bLeft, bRight, yPeak, fBar, tHist)
    polyline.new(pts_b, curved=false, line_color=g1,      line_width=3, xloc=xloc.bar_time)
    pts_c = array.new<chart.point>()
    f_addSemiPoints(pts_c, bLeft, bRight, yPeak, fBar, tHist)
    polyline.new(pts_c, curved=false, line_color=baseCol, line_width=1, xloc=xloc.bar_time)

f_label(int b, float hVal, string lbl, color txtCol, bool isTop, int fBar, array<int> tHist) =>
    int maxIdx    = array.size(tHist) - 1
    int lastTime  = array.get(tHist, maxIdx)
    int firstTime = array.get(tHist, 0)
    int msPerBar  = (lastTime - firstTime) / maxIdx
    int idx       = b - fBar
    int barTime   = idx <= maxIdx ? array.get(tHist, math.max(idx, 0)) : lastTime + (idx - maxIdx) * msPerBar
    lStyle = isTop ? label.style_label_down : label.style_label_up
    label.new(chart.point.from_time(barTime, hVal), lbl,
         color=txtCol, textcolor=color.white,
         style=lStyle, size=size.normal, force_overlay=true, xloc=xloc.bar_time)

f_drawCycle(int cBar1, int cBar2, float peak, int fBar, array<float> hHist, array<int> tHist, color pCol, color nCol, bool future) =>
    int R      = cBar2 - cBar1
    int midBar = cBar1 + R / 2
    int q1     = cBar1 + R / 4
    int q3     = cBar1 + R * 3 / 4

    f_drawSemi(cBar1, cBar2, peak, fBar, tHist, pCol)

    f_drawSemi(cBar1,  midBar, peak / 2, fBar, tHist, nCol)
    f_drawSemi(midBar, cBar2,  peak / 2, fBar, tHist, nCol)

    f_drawSemi(cBar1,  q1,     peak / 4, fBar, tHist, pCol)
    f_drawSemi(q1,     midBar, peak / 4, fBar, tHist, pCol)
    f_drawSemi(midBar, q3,     peak / 4, fBar, tHist, pCol)
    f_drawSemi(q3,     cBar2,  peak / 4, fBar, tHist, pCol)

    int maxIdx   = array.size(hHist) - 1
    float hQ3    = array.get(hHist, math.min(math.max(q3     - fBar, 0), maxIdx))
    float hMid   = array.get(hHist, math.min(math.max(midBar - fBar, 0), maxIdx))
    float hCBar2 = array.get(hHist, math.min(math.max(cBar2  - fBar, 0), maxIdx))

    f_label(q3,     hQ3,    "Cycle Top",      pCol,                   true,  fBar, tHist)
    f_label(midBar, hMid,   "Parabolic Move", color.rgb(120,120,120), true,  fBar, tHist)
    f_label(cBar2,  hCBar2, "Cycle Bottom",   nCol,                   false, fBar, tHist)

if barstate.islastconfirmedhistory and not na(bar1) and not na(bar2) and not na(firstBar)
    int R        = bar2 - bar1
    int todayBar = bar_index

    f_drawCycle(bar1,         bar2,         1.0, firstBar, highHistory, timeHistory, pos_col, neg_col, false)
    f_drawCycle(bar2,         bar2 + R,     1.0, firstBar, highHistory, timeHistory, pos_col, neg_col, bar2 >= todayBar)
    f_drawCycle(bar2 + R,     bar2 + R * 2, 1.0, firstBar, highHistory, timeHistory, pos_col, neg_col, true)
    f_drawCycle(bar2 + R * 2, bar2 + R * 3, 1.0, firstBar, highHistory, timeHistory, pos_col, neg_col, true)
````
