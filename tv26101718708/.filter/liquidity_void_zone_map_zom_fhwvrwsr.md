# Liquidity Void Zone Map [ZOM]

- url: https://www.tradingview.com/script/fhWVRwSR-Liquidity-Void-Zone-Map-ZOM/
- type: indicator
- pine_id: PUB;b3bb2292d53c407d9fd4037f1c7ad585
- version: 1.0

## Description

Liquidity Void Zone Map [ZOM] is a clean imbalance and fair-value-gap style zone mapper built to highlight where displacement left thin liquidity behind.

What it shows:
- Bull and bear liquidity void bands built from three-candle imbalance geometry
- Capped zone height so the bands stay readable instead of becoming huge slabs
- Active, tapped, and broken-state tracking
- Reclaim/rejection retest marks when price revisits a void with directional confirmation
- A compact dashboard showing active bull/bear zones, tapped count, broken count, state, and best quality score

How I use it:
The bands are context, not standalone entries. I look for price to return into a void, then watch the reclaim/rejection behavior around the band while considering trend, volatility, and broader market structure. It is designed for ES/NQ/crypto/forex intraday structure reads, but it can be adapted to other liquid markets.

Open-source [ZOM] script. Educational tool only; not financial advice.

## Source Code

````pine
//@version=6
indicator("Liquidity Void Zone Map [ZOM]", "LVZ [ZOM]", overlay=true, max_boxes_count=300, max_bars_back=500)

// ========================================================================= //
// Inputs
// ========================================================================= //
atrLen       = input.int(14, "ATR Length", minval=1, group="Detection")
volLen       = input.int(30, "Volume Baseline", minval=1, group="Detection")
minGapAtr    = input.float(0.05, "Minimum Void Size (ATR)", minval=0.01, step=0.01, group="Detection")
bodyAtr      = input.float(0.35, "Minimum Displacement Body (ATR)", minval=0.05, step=0.05, group="Detection")
volBoost     = input.float(0.75, "Volume Expansion", minval=0.10, step=0.05, group="Detection")
maxZoneAtr   = input.float(0.42, "Maximum Zone Height (ATR)", minval=0.05, step=0.05, group="Zone Management")
maxZones     = input.int(10, "Max Visible Zones", minval=1, maxval=40, group="Zone Management")
maxAge       = input.int(220, "Max Zone Age", minval=20, maxval=500, group="Zone Management")
extendBars   = input.int(64, "Forward Projection", minval=1, maxval=240, group="Zone Management")
showDash     = input.bool(true, "Show Dashboard", group="Display")
showSignals  = input.bool(true, "Show Retest Dots", group="Display")
showBroken   = input.bool(false, "Show Broken Context", group="Display")

bullFresh = input.color(#00D6B4, "Bull Void", group="Palette")
bearFresh = input.color(#FF4FA3, "Bear Void", group="Palette")
tappedCol = input.color(#D4B65A, "Tapped", group="Palette")
brokenCol = input.color(#56616D, "Broken", group="Palette")
bullSigCol = input.color(#75FFE7, "Bull Retest", group="Palette")
bearSigCol = input.color(#FF88C2, "Bear Retest", group="Palette")

// ========================================================================= //
// Metrics
// ========================================================================= //
atr = ta.atr(atrLen)
volBase = ta.sma(volume, volLen)
volRatio = volume / math.max(volBase, 1)
body = math.abs(close - open)
rng = math.max(high - low, syminfo.mintick)
closePos = (close - low) / rng
emaFast = ta.ema(close, 21)
emaSlow = ta.ema(close, 55)
rsi = ta.rsi(close, 14)

bullGap = low - high[2]
bearGap = low[2] - high
bullVoid = bar_index > 2 and low > high[2] and bullGap >= atr * minGapAtr and close > open and body >= atr * bodyAtr and closePos > 0.52 and volRatio >= volBoost
bearVoid = bar_index > 2 and high < low[2] and bearGap >= atr * minGapAtr and close < open and body >= atr * bodyAtr and closePos < 0.48 and volRatio >= volBoost

// ========================================================================= //
// Zone State
// status: 0 active, 1 tapped, 2 broken
// ========================================================================= //
type VoidZone
    box id
    float top
    float btm
    int dir
    int born
    int status
    float score

var array<VoidZone> zones = array.new<VoidZone>()
var string lastEvent = "Waiting"
var int lastDir = 0

scoreZone(_gap, _body, _vol, _trendOk) =>
    gapScore = math.min((_gap / math.max(atr, syminfo.mintick)) / 0.50, 1.0) * 34
    bodyScore = math.min((_body / math.max(atr, syminfo.mintick)) / 1.10, 1.0) * 30
    volScore = math.min(math.max(_vol - 0.75, 0) / 1.10, 1.0) * 20
    trendScore = _trendOk ? 16 : 7
    math.round(gapScore + bodyScore + volScore + trendScore)

addZone(_dir, _rawTop, _rawBtm, _score) =>
    maxH = atr * maxZoneAtr
    zTop = _dir == 1 ? _rawTop : math.min(_rawTop, _rawBtm + maxH)
    zBtm = _dir == 1 ? math.max(_rawBtm, _rawTop - maxH) : _rawBtm
    col = _dir == 1 ? bullFresh : bearFresh
    fill = color.new(col, _score >= 70 ? 78 : _score >= 48 ? 84 : 89)
    br = color.new(col, _score >= 70 ? 8 : 25)
    bx = box.new(left=bar_index - 2, top=zTop, right=bar_index + extendBars, bottom=zBtm, bgcolor=fill, border_color=br, border_width=_score >= 70 ? 2 : 1)
    array.push(zones, VoidZone.new(bx, zTop, zBtm, _dir, bar_index, 0, _score))
    if array.size(zones) > maxZones
        old = array.shift(zones)
        box.delete(old.id)

if bullVoid
    sc = scoreZone(bullGap, body, volRatio, emaFast >= emaSlow)
    addZone(1, low, high[2], sc)
    lastEvent := "Bull Void"
    lastDir := 1

if bearVoid
    sc = scoreZone(bearGap, body, volRatio, emaFast <= emaSlow)
    addZone(-1, low[2], high, sc)
    lastEvent := "Bear Void"
    lastDir := -1

// ========================================================================= //
// Update Zones
// ========================================================================= //
bullRetest = false
bearRetest = false
int activeBull = 0
int activeBear = 0
int tapped = 0
int broken = 0
float bestScore = na

if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        z = array.get(zones, i)
        age = bar_index - z.born
        if age > maxAge
            box.delete(z.id)
            array.remove(zones, i)
        else
            box.set_right(z.id, bar_index + extendBars)
            touched = high >= z.btm and low <= z.top and bar_index > z.born
            invalid = z.dir == 1 ? close < z.btm : close > z.top
            removed = false
            if invalid and not showBroken
                box.delete(z.id)
                array.remove(zones, i)
                broken += 1
                removed := true
            if not removed
                if invalid and z.status != 2
                    z.status := 2
                    box.set_bgcolor(z.id, color.new(brokenCol, 96))
                    box.set_border_color(z.id, color.new(brokenCol, 82))
                    lastEvent := z.dir == 1 ? "Bull Broken" : "Bear Broken"
                    lastDir := z.dir
                else if touched and z.status == 0
                    z.status := 1
                    box.set_bgcolor(z.id, color.new(tappedCol, 88))
                    box.set_border_color(z.id, color.new(tappedCol, 42))
                    lastEvent := z.dir == 1 ? "Bull Tap" : "Bear Tap"
                    lastDir := z.dir
                reclaim = z.dir == 1 and touched and z.status != 2 and close > z.top and close > open and rsi > 45
                reject = z.dir == -1 and touched and z.status != 2 and close < z.btm and close < open and rsi < 55
                bullRetest := bullRetest or reclaim
                bearRetest := bearRetest or reject
                activeBull += z.dir == 1 and z.status != 2 ? 1 : 0
                activeBear += z.dir == -1 and z.status != 2 ? 1 : 0
                tapped += z.status == 1 ? 1 : 0
                broken += z.status == 2 ? 1 : 0
                bestScore := na(bestScore) ? z.score : math.max(bestScore, z.score)
                array.set(zones, i, z)

if bullRetest
    lastEvent := "Bull Reclaim"
    lastDir := 1
if bearRetest
    lastEvent := "Bear Reject"
    lastDir := -1

plot(showSignals and bullRetest ? low : na, "Bull void reclaim", color=bullSigCol, linewidth=4, style=plot.style_circles)
plot(showSignals and bearRetest ? high : na, "Bear void rejection", color=bearSigCol, linewidth=4, style=plot.style_circles)

if showDash
    var table dash = table.new(position.top_right, 2, 7, bgcolor=color.new(#070B10, 8), border_color=color.new(#43505C, 35), border_width=1)
    if barstate.islast
        bias = activeBull > activeBear ? "Bull Void" : activeBear > activeBull ? "Bear Void" : emaFast > emaSlow ? "Bull Drift" : emaFast < emaSlow ? "Bear Drift" : "Balanced"
        biasCol = activeBull > activeBear ? bullFresh : activeBear > activeBull ? bearFresh : color.white
        q = na(bestScore) ? 0 : bestScore
        table.cell(dash, 0, 0, "LVZ [ZOM]", text_color=color.white, text_size=size.small, bgcolor=color.new(#121A22, 0))
        table.cell(dash, 1, 0, "Void Bands", text_color=color.new(#85FFF0, 0), text_size=size.small, text_halign=text.align_right, bgcolor=color.new(#121A22, 0))
        table.cell(dash, 0, 1, "Active Bull", text_color=color.new(#DDE8EC, 0), text_size=size.small)
        table.cell(dash, 1, 1, str.tostring(activeBull), text_color=bullFresh, text_size=size.small, text_halign=text.align_right)
        table.cell(dash, 0, 2, "Active Bear", text_color=color.new(#DDE8EC, 0), text_size=size.small)
        table.cell(dash, 1, 2, str.tostring(activeBear), text_color=bearFresh, text_size=size.small, text_halign=text.align_right)
        table.cell(dash, 0, 3, "Tapped", text_color=color.new(#DDE8EC, 0), text_size=size.small)
        table.cell(dash, 1, 3, str.tostring(tapped), text_color=tappedCol, text_size=size.small, text_halign=text.align_right)
        table.cell(dash, 0, 4, "Broken", text_color=color.new(#DDE8EC, 0), text_size=size.small)
        table.cell(dash, 1, 4, str.tostring(broken), text_color=brokenCol, text_size=size.small, text_halign=text.align_right)
        table.cell(dash, 0, 5, "State", text_color=color.new(#DDE8EC, 0), text_size=size.small)
        table.cell(dash, 1, 5, bias, text_color=biasCol, text_size=size.small, text_halign=text.align_right)
        table.cell(dash, 0, 6, "Best", text_color=color.new(#DDE8EC, 0), text_size=size.small)
        table.cell(dash, 1, 6, str.tostring(q, "#") + "%", text_color=q >= 70 ? bullSigCol : q >= 45 ? tappedCol : color.new(#F47C7C, 0), text_size=size.small, text_halign=text.align_right)

alertcondition(bullRetest, "LVZ Bull Reclaim", "Liquidity Void Zone Map: bullish void reclaim confirmed [ZOM]")
alertcondition(bearRetest, "LVZ Bear Reject", "Liquidity Void Zone Map: bearish void rejection confirmed [ZOM]")
````
