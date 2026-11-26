# HTF Fair Value Gaps - ICT

- url: https://www.tradingview.com/script/OHd8QoQK-HTF-Fair-Value-Gaps-ICT/
- type: indicator
- pine_id: PUB;ccfe4a11d8714cb3a8ce861fa8003c2b
- version: 1.0

## Description

Displays Fair Value Gaps (FVGs) from a higher timeframe — default 15m — directly on your lower timeframe execution chart (e.g. 3m). Built for traders who identify FVGs on the 15m and execute on the 3m.

FVG detection is based on the ICT concept and mirrors the logic used in ICT Concepts [LuxAlgo]:

A Fair Value Gap is identified using a 3-candle pattern. The middle candle must be a displacement candle — a large-bodied, small-wick candle showing strong directional intent. A gap must exist between the first candle's high/low and the third candle's low/high.

Bullish FVG (green): candle 3's low is above candle 1's high
Bearish FVG (red): candle 3's high is below candle 1's low
Dashed border when price enters the zone
Zone is removed or grayed out when price trades through the far side
No repainting — only confirmed, closed HTF bars are used.

Works on any symbol and any timeframe combination. Change the Higher Timeframe input to show 1H FVGs on a 5m chart, for example.

## Source Code

````pine
// =============================================================================
//  HTF FAIR VALUE GAPS
//
//  Detects Fair Value Gaps from a higher timeframe (default 15m) and draws
//  them on your current lower timeframe chart (e.g. 3m execution chart).
//
//  FVG logic is identical to ICT Concepts [LuxAlgo]:
//    • 3-candle pattern: gap between candle A and candle C
//    • Candle B (middle) must be a displacement candle (large body, small wicks)
//    • BULLISH FVG: candle C's low > candle A's high  (gap above)
//    • BEARISH FVG: candle C's high < candle A's low  (gap below)
//    • Dashed border when price enters zone
//    • Zone "breaks" when price trades through the far side
//
//  No repainting: only confirmed, closed HTF bars are used.
// =============================================================================
//@version=6
indicator("HTF Fair Value Gaps", "HTF FVG", overlay=true,
     max_boxes_count=500, max_labels_count=100)

string GRP_DET  = "▸ Detection"
string GRP_DISP = "▸ Display"

htfTF         = input.timeframe("15",  "Higher Timeframe",
     tooltip   = "FVGs are detected on this timeframe and drawn on your current chart.",
     group     = GRP_DET)
fvgType       = input.string("FVG",   "Type",
     options   = ["FVG", "IFVG"],
     tooltip   = "FVG = standard gap between candles\nIFVG = Implied (inverted gap)",
     group     = GRP_DET)
useBodyFilter = input.bool(true,      "Displacement candle filter",
     tooltip   = "Middle candle must have a large body with small wicks — matches the ICT Concepts indicator.",
     group     = GRP_DET)
bodyLen       = input.int(5,          "Body SMA length",             group=GRP_DET, minval=2)

showBull      = input.bool(true,      "Show Bullish FVGs",           group=GRP_DISP)
showBear      = input.bool(true,      "Show Bearish FVGs",           group=GRP_DISP)
maxFVGs       = input.int(5,          "Max FVGs per side",           group=GRP_DISP, minval=1, maxval=20)
extendBars    = input.int(50,         "Extend right N bars",         group=GRP_DISP, minval=5, maxval=500)
showBroken    = input.bool(false,     "Show broken FVGs (grayed)",   group=GRP_DISP)

colBull       = input.color(color.new(#00e676, 85), "Bullish FVG",       group=GRP_DISP, inline="b")
colBullBroke  = input.color(color.new(#808000, 95), "Bullish Broken",    group=GRP_DISP, inline="b")
colBear       = input.color(color.new(#ff5252, 85), "Bearish FVG",       group=GRP_DISP, inline="r")
colBearBroke  = input.color(color.new(#FF0000, 95), "Bearish Broken",    group=GRP_DISP, inline="r")

[h0, l0, t0] = request.security(syminfo.tickerid, htfTF,
     [high[1], low[1], time[1]], lookahead = barmerge.lookahead_on)

[o1, h1, l1, c1] = request.security(syminfo.tickerid, htfTF,
     [open[2], high[2], low[2], close[2]], lookahead = barmerge.lookahead_on)

[h2, l2] = request.security(syminfo.tickerid, htfTF,
     [high[3], low[3]], lookahead = barmerge.lookahead_on)

htfMeanBody = request.security(syminfo.tickerid, htfTF,
     ta.sma(math.abs(close - open), bodyLen)[2], lookahead = barmerge.lookahead_on)

newHTFBar = ta.change(t0) > 0

body1      = math.abs(c1 - o1)
mx1        = math.max(c1, o1)
mn1        = math.min(c1, o1)
perc       = 0.36
L_body1    = (h1 - mx1) < body1 * perc and (mn1 - l1) < body1 * perc
L_bodyUP1  = body1 > htfMeanBody and L_body1 and c1 > o1
L_bodyDN1  = body1 > htfMeanBody and L_body1 and c1 < o1

bullMid    = useBodyFilter ? L_bodyUP1 : c1 > o1
bearMid    = useBodyFilter ? L_bodyDN1 : c1 < o1

isFVG = fvgType == "FVG"

isBullFVG = isFVG ? l0 > h2 and bullMid : l0 < h2 and bullMid
bullTop   = isFVG ? l0 : h2
bullBot   = isFVG ? h2 : l0

isBearFVG = isFVG ? h0 < l2 and bearMid : h0 > l2 and bearMid
bearTop   = isFVG ? l2 : h0
bearBot   = isFVG ? h0 : l2

type FVGZone
    float top
    float bot
    bool  active
    bool  isBull
    box   bx

var array<FVGZone> bullArr = array.new<FVGZone>()
var array<FVGZone> bearArr = array.new<FVGZone>()

if newHTFBar
    if isBullFVG and showBull and bullTop > bullBot
        bx = box.new(bar_index, bullTop, bar_index + extendBars, bullBot,
             bgcolor      = colBull,
             border_color = color.new(#00e676, 65),
             border_width = 1,
             text         = "FVG " + htfTF,
             text_color   = color.new(#00e676, 30),
             text_size    = size.tiny,
             text_halign  = text.align_left,
             text_valign  = text.align_bottom)
        array.push(bullArr, FVGZone.new(bullTop, bullBot, true, true, bx))
        while array.size(bullArr) > maxFVGs
            old = array.shift(bullArr)
            if not na(old.bx)
                box.delete(old.bx)

    if isBearFVG and showBear and bearTop > bearBot
        bx = box.new(bar_index, bearTop, bar_index + extendBars, bearBot,
             bgcolor      = colBear,
             border_color = color.new(#ff5252, 65),
             border_width = 1,
             text         = "FVG " + htfTF,
             text_color   = color.new(#ff5252, 30),
             text_size    = size.tiny,
             text_halign  = text.align_left,
             text_valign  = text.align_top)
        array.push(bearArr, FVGZone.new(bearTop, bearBot, true, false, bx))
        while array.size(bearArr) > maxFVGs
            old = array.shift(bearArr)
            if not na(old.bx)
                box.delete(old.bx)

f_update(array<FVGZone> arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            z = array.get(arr, i)
            if z.active and not na(z.bx)
                box.set_right(z.bx, bar_index + extendBars)
                if z.isBull
                    if low < z.top
                        box.set_border_style(z.bx, line.style_dashed)
                    if low < z.bot
                        z.active := false
                        box.set_right(z.bx, bar_index)
                        if showBroken
                            box.set_bgcolor(z.bx, colBullBroke)
                            box.set_border_style(z.bx, line.style_dotted)
                        else
                            box.delete(z.bx)
                else
                    if high > z.bot
                        box.set_border_style(z.bx, line.style_dashed)
                    if high > z.top
                        z.active := false
                        box.set_right(z.bx, bar_index)
                        if showBroken
                            box.set_bgcolor(z.bx, colBearBroke)
                            box.set_border_style(z.bx, line.style_dotted)
                        else
                            box.delete(z.bx)

f_update(bullArr)
f_update(bearArr)

bool inBull = false
bool inBear = false

if array.size(bullArr) > 0
    for i = 0 to array.size(bullArr) - 1
        z = array.get(bullArr, i)
        if z.active and low <= z.top and high >= z.bot
            inBull := true

if array.size(bearArr) > 0
    for i = 0 to array.size(bearArr) - 1
        z = array.get(bearArr, i)
        if z.active and high >= z.bot and low <= z.top
            inBear := true

alertcondition(inBull, "Price in HTF Bullish FVG", "Price entered a 15m Bullish FVG")
alertcondition(inBear, "Price in HTF Bearish FVG", "Price entered a 15m Bearish FVG")
````
