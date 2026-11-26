# FVG Magic

- url: https://www.tradingview.com/script/D6gpPxpX-FVG-Magic/
- type: indicator
- pine_id: PUB;f218fc2ca11844008c452e0749ea90d4
- version: 1.0

## Description

Hello,

This FVG is a copy of FVG Magic by @OakleyJM but his FVG is certainly used by only Premium Tradingview Subscribers while i removed a few barriers to make it useable by every free traders who can't afford to pay for the Premium subscription.

Almost everything kept default is applied everywhere but in a few scripts, you will need to Tick (Yes) to Auto-Tune by Timeframe and also Tick (Yes) to Remove on 50% SQ.

Check every way possible to find the FairValueGap possible. 

This is the best version of FVG available in the market and all thanks to OakleyJM for his generous efforts.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © OakleyJM
//@version=6

indicator("FVG Magic", overlay = true, max_boxes_count = 200, max_bars_back = 2000)

// ───────── Inputs
bool keepHistory    = input.bool(true, "Keep Historical FVG Fills?")
int  historyOffCap  = input.int(50, "Max FVGs when History is OFF", minval = 1, maxval = 50)

// Detection flexibility
bool   useStrictGap  = input.bool(true, "Use Strict FVG Filter")
bool   useSizeFilter = input.bool(true, "Enable Size Filter")

// Core behavior
string mitigationSrc = input.string("close", "Mitigation Source", ["close", "high/low"])
bool   bullGaps      = input.bool(true, "Show Bullish FVGs")
bool   bearGaps      = input.bool(true, "Show Bearish FVGs")
bool   volumeBars    = input.bool(true, "Show Volume Bars")

// Colors
bullColor         = input.color(color.rgb(26, 194, 216, 50), "Bullish Fill")
bearColor         = input.color(color.rgb(216, 118, 26, 50), "Bearish Fill")
inversedFillColor = input.color(color.new(color.black, 0), "Inversed Fill")

// Auto tuning
bool autoTF = input.bool(false, "Auto-tune by timeframe")

// Manual settings
int extendBars_in       = input.int(10, "Right Extension Bars", minval = 5)
int keepMax_in          = input.int(5, "Max FVGs to keep", minval = 1)
int confirmInv_in       = input.int(1, "Inversion Confirmation Bars", minval = 0, maxval = 3)
int pctThreshold_in     = input.int(10, "Min Size Percentile", minval = 1, maxval = 50)
int meterWidthInBars_in = input.int(10, "Meter Width", minval = 5, maxval = 25)
int invWindowBars_in    = input.int(0, "Inversion Window", minval = 0, maxval = 100)
int invCleanupBars_in   = input.int(0, "Remove Inversed After", minval = 0, maxval = 100)

// Cleanup
bool removeOnSQ   = input.bool(false, "Remove on 50% SQ")
int  sqDelayBars  = input.int(0, "Delay after 50%", minval = 0, maxval = 100)

// Visibility
int lookbackBars   = input.int(500, "Lookback Bars", minval = 100, maxval = 5000)
int nearestPerSide = input.int(0, "Nearest FVGs Per Side", minval = 0, maxval = 20)

// ───────── Auto tuning
int tfSec = timeframe.in_seconds("")
bool is15m = tfSec <= 30 * 60
bool isH1  = not is15m and tfSec <= 2 * 3600

int extendBars     = autoTF ? (is15m ? 20 : isH1 ? 15 : 10) : extendBars_in
int keepMax        = autoTF ? (is15m ? 8  : isH1 ? 6  : 5 ) : keepMax_in
int confirmInv     = confirmInv_in
int pctThreshold   = autoTF ? (is15m ? 15 : isH1 ? 10 : 8 ) : pctThreshold_in
int meterWidthBars = meterWidthInBars_in
int invWindowBars  = invWindowBars_in
int invCleanupBars = invCleanupBars_in

// ───────── Type
type VolumaticFVG
    box body
    box bullBar
    box bearBar
    bool isBull
    int status
    int createdAt
    int invCount
    int enteredAt
    int inversedAt
    int sqAt
    int bullPct
    int bearPct
    float totalVol

// ───────── Storage
var array<VolumaticFVG> fvgs = array.new<VolumaticFVG>()

// ───────── Size filter
float diff    = close[1] > open[1] ? (low - high[2]) / low * 100 : (low[2] - high) / high * 100
float denom   = ta.percentile_nearest_rank(diff, 500, 100)
float sizeFVG = denom != 0 ? (diff / denom) * 100 : 0
bool filterFVG = useSizeFilter ? sizeFVG > pctThreshold : true

// ───────── Detection
bool isBull_gap_strict = high[2] < low and high[2] < high[1] and low[2] < low and filterFVG
bool isBear_gap_strict = low[2] > high and low[2] > low[1] and high[2] > high and filterFVG

bool isBull_gap_min = low > high[2] and filterFVG
bool isBear_gap_min = high < low[2] and filterFVG

bool isBull_gap = useStrictGap ? isBull_gap_strict : isBull_gap_min
bool isBear_gap = useStrictGap ? isBear_gap_strict : isBear_gap_min

// ───────── Lightweight volume estimation
float bullVol = close > open ? volume : volume * 0.5
float bearVol = close < open ? volume : volume * 0.5
float totalVol = bullVol + bearVol

int bullPct = totalVol > 0 ? int((bullVol / totalVol) * 100) : 50
int bearPct = totalVol > 0 ? int((bearVol / totalVol) * 100) : 50

// ───────── Create FVGs
if bar_index > 2

    if isBull_gap and bullGaps
        box body = box.new(
             bar_index - 1,
             low,
             bar_index + extendBars,
             high[2],
             bgcolor = bullColor,
             border_color = na)

        float mid = math.avg(low, high[2])

        box bearBar = box.new(
             bar_index - 1,
             low,
             bar_index - 1,
             mid,
             bgcolor = bearColor,
             border_color = na)

        box bullBar = box.new(
             bar_index - 1,
             mid,
             bar_index - 1,
             high[2],
             bgcolor = bullColor,
             border_color = na)

        array.push(
             fvgs,
             VolumaticFVG.new(
             body,
             bullBar,
             bearBar,
             true,
             0,
             bar_index,
             0,
             na,
             na,
             na,
             bullPct,
             bearPct,
             totalVol))

    if isBear_gap and bearGaps
        box body = box.new(
             bar_index - 1,
             low[2],
             bar_index + extendBars,
             high,
             bgcolor = bearColor,
             border_color = na)

        float mid = math.avg(low[2], high)

        box bearBar = box.new(
             bar_index - 1,
             low[2],
             bar_index - 1,
             mid,
             bgcolor = bearColor,
             border_color = na)

        box bullBar = box.new(
             bar_index - 1,
             mid,
             bar_index - 1,
             high,
             bgcolor = bullColor,
             border_color = na)

        array.push(
             fvgs,
             VolumaticFVG.new(
             body,
             bullBar,
             bearBar,
             false,
             0,
             bar_index,
             0,
             na,
             na,
             na,
             bullPct,
             bearPct,
             totalVol))

// ───────── Helpers
hit50(bool isBull, float top, float bot) =>
    float mid = (top + bot) * 0.5
    mitigationSrc == "close" ?
     (isBull ? close <= mid : close >= mid) :
     (isBull ? low <= mid : high >= mid)

fullMitigated(bool isBull, float top, float bot) =>
    mitigationSrc == "close" ?
     (isBull ? close <= bot : close >= top) :
     (isBull ? low <= bot : high >= top)

inversedHit(bool isBull, float top, float bot) =>
    isBull ? close < bot : close > top

// ───────── Update
int sz = array.size(fvgs)

if sz > 0

    for i = sz - 1 to 0

        VolumaticFVG f = array.get(fvgs, i)

        float top = f.body.get_top()
        float bot = f.body.get_bottom()
        float mid = (top + bot) * 0.5

        f.body.set_right(bar_index + extendBars)

        // States
        if f.status < 1 and hit50(f.isBull, top, bot)
            f.status := 1
            f.sqAt := bar_index

        if f.status < 2 and fullMitigated(f.isBull, top, bot)
            f.status := 2

        if f.status >= 2 and inversedHit(f.isBull, top, bot)

            if confirmInv == 0
                f.status := 3
            else
                f.invCount += 1

                if f.invCount >= confirmInv
                    f.status := 3

        // Remove conditions
        bool removeNow = false

        if removeOnSQ and f.status == 1
            removeNow := true

        if f.status == 3
            removeNow := invCleanupBars == 0 ? true : false

        // Draw
        if removeNow
            f.body.delete()
            f.bullBar.delete()
            f.bearBar.delete()
            array.remove(fvgs, i)

        else

            if f.status == 0

                int leftPos = f.body.get_left()

                int bullRight = leftPos + int(meterWidthBars * f.bullPct / 100)
                int bearRight = leftPos + int(meterWidthBars * f.bearPct / 100)

                f.bullBar.set_left(leftPos)
                f.bullBar.set_right(bullRight)
                f.bullBar.set_top(mid)
                f.bullBar.set_bottom(bot)

                f.bearBar.set_left(leftPos)
                f.bearBar.set_right(bearRight)
                f.bearBar.set_top(top)
                f.bearBar.set_bottom(mid)

                if volumeBars
                    f.bullBar.set_text(str.tostring(f.bullPct) + "%")
                    f.bearBar.set_text(str.tostring(f.bearPct) + "%")
                else
                    f.bullBar.set_text("")
                    f.bearBar.set_text("")

            else

                string tag =
                     f.status == 1 ? "SQ" :
                     f.status == 2 ? "MITIGATED" :
                     "INVERSED"

                f.body.set_text(tag)
                f.body.set_text_color(chart.fg_color)

                if f.status == 3
                    f.body.set_bgcolor(inversedFillColor)

            array.set(fvgs, i, f)

// ───────── Lookback cleanup
int s2 = array.size(fvgs)

if s2 > 0

    for i = s2 - 1 to 0

        VolumaticFVG f = array.get(fvgs, i)

        if bar_index - f.createdAt > lookbackBars

            f.body.delete()
            f.bullBar.delete()
            f.bearBar.delete()

            array.remove(fvgs, i)

// ───────── Hard cap
while array.size(fvgs) > (keepHistory ? keepMax : historyOffCap)

    VolumaticFVG x = array.shift(fvgs)

    x.body.delete()
    x.bullBar.delete()
    x.bearBar.delete()
````
