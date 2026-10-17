# Overlay Candles STG

- url: https://www.tradingview.com/script/0fuNTmJ0-Overlay-Candles-STG/
- type: indicator
- pine_id: PUB;fb0fcf6e2c1c4fb0b105b54df17ce880
- version: 1.0

## Description

Core Functions & Features
• Plots Higher Timeframes Side-by-Side: Instead of overlapping your normal chart bars, this script pulls historical and live data from a higher timeframe (e.g., Daily, Weekly, or Monthly data on a 15-minute chart) and displays a sequence of up to 8 custom HTF candles side-by-side in the right margin/blank space of your chart.
• Live Updates: It requests historical candle data using lookahead parameters (lookahead_on), meaning the very first candle on the far right updates in real-time as the live price ticks.
• Completely Customizable Geometry: Instead of relying on Pine Script’s automatic plot sizing, it manually draws boxes and lines. It forces an odd number for the bar width so that the candle wicks are perfectly centered on the box body.
• Configurable Colors: It allows you to quickly alter the interface visual parameters directly from the indicator settings window—defaulting to standard green for bullish candles and red for bearish candles with crisp black borders and wicks.

## Source Code

````pine
//@version=6
indicator("Overlay Candles — right side (live HTF, fixed bar width, centered wicks, N candles)", overlay=true, max_boxes_count=24, max_lines_count=260)

// === Colors ===
bullBodyColor  = input.color(color.green, "Bull body")
bearBodyColor  = input.color(color.red,   "Bear body")
borderColorInp = input.color(color.black, "Body border")
wickColor      = input.color(color.black, "Wick")

// === Thickness (px) ===
wickWidth     = input.int(2, "Wick width (px)",   minval=1, maxval=10)
borderWidthPx = input.int(2, "Border width (px)", minval=1, maxval=10)

// === Overlay timeframe (independent of chart TF) ===
tfInput = input.string("D", "Overlay timeframe", options=["5","15","30","60","240","D","W","M"])

// Always include CURRENT (unfinished) HTF candle
includeCurrent = true

// === How many candles to show ===
showCount = input.int(4, "Number of candles (1–8)", minval=1, maxval=8)

// === Positioning (in bars of the CURRENT chart) ===
widthBarsInput = input.int(5, "Body width (bars) — odd only", minval=1)
sepBars        = input.int(2, "Gap (bars)",                   minval=0)
leadBars       = input.int(5, "Right offset (bars)",          minval=0)

// Force odd width so the mid is an integer bar
widthBars = widthBarsInput % 2 == 0 ? widthBarsInput + 1 : widthBarsInput
halfBars  = int((widthBars - 1) / 2)

// === HTF OHLC (LIVE current candle): fetch per-offset INSIDE security ===
float o0 = request.security(syminfo.tickerid, tfInput, open,    gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float h0 = request.security(syminfo.tickerid, tfInput, high,    gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float l0 = request.security(syminfo.tickerid, tfInput, low,     gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float c0 = request.security(syminfo.tickerid, tfInput, close,   gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

float o1 = request.security(syminfo.tickerid, tfInput, open[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float h1 = request.security(syminfo.tickerid, tfInput, high[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float l1 = request.security(syminfo.tickerid, tfInput, low[1],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float c1 = request.security(syminfo.tickerid, tfInput, close[1],gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

float o2 = request.security(syminfo.tickerid, tfInput, open[2], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float h2 = request.security(syminfo.tickerid, tfInput, high[2], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float l2 = request.security(syminfo.tickerid, tfInput, low[2],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float c2 = request.security(syminfo.tickerid, tfInput, close[2],gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

float o3 = request.security(syminfo.tickerid, tfInput, open[3], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float h3 = request.security(syminfo.tickerid, tfInput, high[3], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float l3 = request.security(syminfo.tickerid, tfInput, low[3],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float c3 = request.security(syminfo.tickerid, tfInput, close[3],gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

float o4 = request.security(syminfo.tickerid, tfInput, open[4], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float h4 = request.security(syminfo.tickerid, tfInput, high[4], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float l4 = request.security(syminfo.tickerid, tfInput, low[4],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float c4 = request.security(syminfo.tickerid, tfInput, close[4],gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

float o5 = request.security(syminfo.tickerid, tfInput, open[5], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float h5 = request.security(syminfo.tickerid, tfInput, high[5], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float l5 = request.security(syminfo.tickerid, tfInput, low[5],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float c5 = request.security(syminfo.tickerid, tfInput, close[5],gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

float o6 = request.security(syminfo.tickerid, tfInput, open[6], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float h6 = request.security(syminfo.tickerid, tfInput, high[6], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float l6 = request.security(syminfo.tickerid, tfInput, low[6],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float c6 = request.security(syminfo.tickerid, tfInput, close[6],gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

float o7 = request.security(syminfo.tickerid, tfInput, open[7], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float h7 = request.security(syminfo.tickerid, tfInput, high[7], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float l7 = request.security(syminfo.tickerid, tfInput, low[7],  gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
float c7 = request.security(syminfo.tickerid, tfInput, close[7],gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// Selectors 0..7 (0 = LIVE current HTF candle)
fO(int i) => i==0?o0:i==1?o1:i==2?o2:i==3?o3:i==4?o4:i==5?o5:i==6?o6:o7
fH(int i) => i==0?h0:i==1?h1:i==2?h2:i==3?h3:i==4?h4:i==5?h5:i==6?h6:h7
fL(int i) => i==0?l0:i==1?l1:i==2?l2:i==3?l3:i==4?l4:i==5?l5:i==6?l6:l7
fC(int i) => i==0?c0:i==1?c1:i==2?c2:i==3?c3:i==4?c4:i==5?c5:i==6?c6:c7

// Count how many HTF candles are actually available
f_available() =>
    int cnt = 0
    for i = 0 to 7
        cnt += na(fO(i)) or na(fH(i)) or na(fL(i)) or na(fC(i)) ? 0 : 1
    cnt

int available = f_available()
int slotsToDraw = math.min(showCount, available, 8)

// === Drawing objects (arrays updated to v6 syntax) ===
var array<box>  bodies = array.new<box>()
var array<line> wTop   = array.new<line>()
var array<line> wBot   = array.new<line>()
var array<line> bTop   = array.new<line>()
var array<line> bBot   = array.new<line>()
var array<line> bLeft  = array.new<line>()
var array<line> bRight = array.new<line>()

if barstate.isfirst
    for _ = 0 to 7
        array.push(bodies, box.new(bar_index, close, bar_index, close, xloc=xloc.bar_index, border_color=color.new(borderColorInp, 100)))
        array.push(wTop,   line.new(bar_index, close, bar_index, close, xloc=xloc.bar_index, extend=extend.none))
        array.push(wBot,   line.new(bar_index, close, bar_index, close, xloc=xloc.bar_index, extend=extend.none))
        array.push(bTop,   line.new(bar_index, close, bar_index, close, xloc=xloc.bar_index))
        array.push(bBot,   line.new(bar_index, close, bar_index, close, xloc=xloc.bar_index))
        array.push(bLeft,  line.new(bar_index, close, bar_index, close, xloc=xloc.bar_index))
        array.push(bRight, line.new(bar_index, close, bar_index, close, xloc=xloc.bar_index))

// Draw single candle (box + wicks + border)
f_draw(box b, line wT, line wB, line t, line bt, line bl, line br, int slot, float o, float h, float l, float c) =>
    if not na(o) and not na(h) and not na(l) and not na(c)
        // Draw reverse order so newer candles are positioned on the far right
        int invSlot = slotsToDraw - 1 - slot
        int left  = bar_index + leadBars + invSlot * (widthBars + sepBars)
        int right = left + widthBars - 1
        int mid   = left + halfBars

        float hiBody  = math.max(o, c)
        float loBody  = math.min(o, c)
        color bodyCol = c >= o ? bullBodyColor : bearBodyColor

        box.set_lefttop(b,  left,  hiBody)
        box.set_rightbottom(b, right, loBody)
        box.set_bgcolor(b, bodyCol)

        line.set_xy1(wT, mid, h)
        line.set_xy2(wT, mid, hiBody)
        line.set_color(wT, wickColor)
        line.set_width(wT, wickWidth)

        line.set_xy1(wB, mid, loBody)
        line.set_xy2(wB, mid, l)
        line.set_color(wB, wickColor)
        line.set_width(wB, wickWidth)

        line.set_xy1(t,  left,  hiBody)
        line.set_xy2(t,  right, hiBody)
        line.set_color(t, borderColorInp)
        line.set_width(t, borderWidthPx)

        line.set_xy1(bt, left,  loBody)
        line.set_xy2(bt, right, loBody)
        line.set_color(bt, borderColorInp)
        line.set_width(bt, borderWidthPx)

        line.set_xy1(bl, left,  hiBody)
        line.set_xy2(bl, left,  loBody)
        line.set_color(bl, borderColorInp)
        line.set_width(bl, borderWidthPx)

        line.set_xy1(br, right, hiBody)
        line.set_xy2(br, right, loBody)
        line.set_color(br, borderColorInp)
        line.set_width(br, borderWidthPx)

// Live rendering cycle execution
if barstate.islast and slotsToDraw > 0
    for i = 0 to slotsToDraw - 1
        f_draw(
             array.get(bodies, i), 
             array.get(wTop,   i), array.get(wBot,   i), 
             array.get(bTop,   i), array.get(bBot,   i), 
             array.get(bLeft,  i), array.get(bRight, i), 
             i, fO(i), fH(i), fL(i), fC(i)
             )
````
