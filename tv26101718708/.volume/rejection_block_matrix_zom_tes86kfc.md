# Rejection Block Matrix [ZOM]

- url: https://www.tradingview.com/script/tEs86Kfc-Rejection-Block-Matrix-ZOM/
- type: indicator
- pine_id: PUB;edf79cd50e314290b97b42e7cd927b91
- version: 1.0

## Description

Rejection Block Matrix [ZOM] maps supply and demand rejection blocks from failed swing sweeps and confirmed pivot wick rejection.

What it shows:
- Demand and supply blocks built from wick/body rejection structure
- Failed high/low sweep blocks for tape-reading style reversal context
- Tested and broken block state tracking, with broken context hidden by default to reduce clutter
- Reclaim/rejection marks when price retests a live block
- A compact dashboard showing visible demand/supply blocks, tested count, latest source, bias, and quality

How I use it:
The blocks are structure zones, not automatic entries. I use them to see where price rejected prior liquidity, then watch how later candles behave when they revisit those blocks. It is especially useful on liquid intraday markets such as ES, NQ, crypto, and major FX pairs.

Open-source [ZOM] script. Educational tool only; not financial advice.

## Source Code

````pine
//@version=6
indicator("Rejection Block Matrix [ZOM]", "RBM [ZOM]", overlay=true, max_boxes_count=300, max_bars_back=500)

// ========================================================================= //
// Inputs
// ========================================================================= //
swingLen     = input.int(3, "Swing Confirmation", minval=2, maxval=20, group="Detection")
atrLen       = input.int(14, "ATR Length", minval=1, group="Detection")
volLen       = input.int(30, "Volume Baseline", minval=1, group="Detection")
wickMin      = input.float(0.20, "Minimum Wick Share", minval=0.05, maxval=0.90, step=0.01, group="Detection")
volBoost     = input.float(0.60, "Volume Confirmation", minval=0.10, step=0.05, group="Detection")
minBlockAtr  = input.float(0.10, "Minimum Block Height (ATR)", minval=0.02, step=0.02, group="Zone Management")
maxBlockAtr  = input.float(0.70, "Maximum Block Height (ATR)", minval=0.10, step=0.05, group="Zone Management")
maxBlocks    = input.int(14, "Max Visible Blocks", minval=1, maxval=40, group="Zone Management")
maxAge       = input.int(260, "Max Block Age", minval=20, maxval=600, group="Zone Management")
extendBars   = input.int(70, "Forward Projection", minval=1, maxval=260, group="Zone Management")
showDash     = input.bool(true, "Show Dashboard", group="Display")
showSignals  = input.bool(true, "Show Rejection Marks", group="Display")
showBroken   = input.bool(false, "Show Broken Context", group="Display")

// Deliberately warm/gold vs LVZ cyan/magenta so RB zones read separately.
demandCol    = input.color(#2CFF88, "Demand Block", group="Palette")
supplyCol    = input.color(#FF9E2C, "Supply Block", group="Palette")
testedCol    = input.color(#F2D15C, "Tested Block", group="Palette")
brokenCol    = input.color(#656D78, "Broken Block", group="Palette")
demandSig    = input.color(#ACFFC8, "Demand Signal", group="Palette")
supplySig    = input.color(#FFC285, "Supply Signal", group="Palette")

// ========================================================================= //
// Metrics
// ========================================================================= //
atr = ta.atr(atrLen)
volBase = ta.sma(volume, volLen)
volOk = volume >= volBase * volBoost
rng = math.max(high - low, syminfo.mintick)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
upperShare = upperWick / rng
lowerShare = lowerWick / rng
flowRaw = ((close - low) - (high - close)) / rng * volume
cmf = ta.sma(flowRaw, 20) / math.max(ta.sma(volume, 20), 1)
rsi = ta.rsi(close, 14)
emaFast = ta.ema(close, 21)
emaSlow = ta.ema(close, 55)

// ========================================================================= //
// State
// status: 0 active, 1 tested, 2 broken
// ========================================================================= //
type RejectionBlock
    box id
    float top
    float btm
    int dir
    int born
    int status
    float score
    string source

var array<RejectionBlock> blocks = array.new<RejectionBlock>()
var float lastSwingHigh = na
var float lastSwingLow = na
var string lastSource = "Waiting"
var int lastDir = 0
var float lastScore = na

scoreBlock(_wickShare, _volOk, _flowOk, _rsiOk) =>
    wickScore = math.min(_wickShare / 0.62, 1.0) * 42
    volScore = _volOk ? 18 : 8
    flowScore = _flowOk ? 22 : 8
    momentumScore = _rsiOk ? 18 : 8
    math.round(wickScore + volScore + flowScore + momentumScore)

normalizeBlock(_dir, _extreme, _bodyEdge, _atr) =>
    minH = _atr * minBlockAtr
    maxH = _atr * maxBlockAtr
    rawH = math.abs(_extreme - _bodyEdge)
    h = math.min(math.max(rawH, minH), maxH)
    top = _dir == -1 ? _extreme : _extreme + h
    btm = _dir == -1 ? _extreme - h : _extreme
    [top, btm]

addBlock(_dir, _left, _top, _btm, _score, _source) =>
    col = _dir == 1 ? demandCol : supplyCol
    fill = color.new(col, _score >= 70 ? 72 : _score >= 45 ? 79 : 86)
    br = color.new(col, _score >= 70 ? 0 : 18)
    bx = box.new(left=_left, top=_top, right=bar_index + extendBars, bottom=_btm, bgcolor=fill, border_color=br, border_width=_score >= 70 ? 2 : 1)
    array.push(blocks, RejectionBlock.new(bx, _top, _btm, _dir, bar_index, 0, _score, _source))
    if array.size(blocks) > maxBlocks
        old = array.shift(blocks)
        box.delete(old.id)

// Confirmed pivot blocks: always create visible zones from meaningful wick rejection.
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)
if not na(ph)
    pRng = math.max(high[swingLen] - low[swingLen], syminfo.mintick)
    pShare = (high[swingLen] - math.max(open[swingLen], close[swingLen])) / pRng
    if pShare >= wickMin
        [top, btm] = normalizeBlock(-1, high[swingLen], math.max(open[swingLen], close[swingLen]), atr[swingLen])
        sc = scoreBlock(pShare, volume[swingLen] >= volBase[swingLen] * volBoost, cmf[swingLen] < 0.05, rsi[swingLen] < 62)
        addBlock(-1, bar_index - swingLen, top, btm, sc, "Pivot Supply")
        lastSource := "Pivot Supply"
        lastDir := -1
        lastScore := sc
    lastSwingHigh := ph

if not na(pl)
    pRng = math.max(high[swingLen] - low[swingLen], syminfo.mintick)
    pShare = (math.min(open[swingLen], close[swingLen]) - low[swingLen]) / pRng
    if pShare >= wickMin
        [top, btm] = normalizeBlock(1, low[swingLen], math.min(open[swingLen], close[swingLen]), atr[swingLen])
        sc = scoreBlock(pShare, volume[swingLen] >= volBase[swingLen] * volBoost, cmf[swingLen] > -0.05, rsi[swingLen] > 38)
        addBlock(1, bar_index - swingLen, top, btm, sc, "Pivot Demand")
        lastSource := "Pivot Demand"
        lastDir := 1
        lastScore := sc
    lastSwingLow := pl

// Live failed sweeps for sharper tape-reading style blocks.
liveSupply = not na(lastSwingHigh) and high > lastSwingHigh and close < lastSwingHigh and upperShare >= wickMin
liveDemand = not na(lastSwingLow) and low < lastSwingLow and close > lastSwingLow and lowerShare >= wickMin
if liveSupply
    [top, btm] = normalizeBlock(-1, high, math.max(open, close), atr)
    sc = scoreBlock(upperShare, volOk, cmf < 0.10, rsi < 65)
    addBlock(-1, bar_index, top, btm, sc, "Failed High Sweep")
    lastSource := "Failed High Sweep"
    lastDir := -1
    lastScore := sc
if liveDemand
    [top, btm] = normalizeBlock(1, low, math.min(open, close), atr)
    sc = scoreBlock(lowerShare, volOk, cmf > -0.10, rsi > 35)
    addBlock(1, bar_index, top, btm, sc, "Failed Low Sweep")
    lastSource := "Failed Low Sweep"
    lastDir := 1
    lastScore := sc

// ========================================================================= //
// Updates + Retests
// ========================================================================= //
demandSignalNow = false
supplySignalNow = false
int demandActive = 0
int supplyActive = 0
int tested = 0
int broken = 0
float bestScore = na
string retestState = "Idle"

if array.size(blocks) > 0
    for i = array.size(blocks) - 1 to 0
        rb = array.get(blocks, i)
        age = bar_index - rb.born
        if age > maxAge
            box.delete(rb.id)
            array.remove(blocks, i)
        else
            box.set_right(rb.id, bar_index + extendBars)
            touched = high >= rb.btm and low <= rb.top and bar_index > rb.born
            invalid = rb.dir == 1 ? close < rb.btm : close > rb.top
            removed = false
            if invalid and not showBroken
                box.delete(rb.id)
                array.remove(blocks, i)
                broken += 1
                removed := true
            if not removed
                if invalid and rb.status != 2
                    rb.status := 2
                    box.set_bgcolor(rb.id, color.new(brokenCol, 96))
                    box.set_border_color(rb.id, color.new(brokenCol, 84))
                else if touched and rb.status == 0
                    rb.status := 1
                    box.set_bgcolor(rb.id, color.new(testedCol, 84))
                    box.set_border_color(rb.id, color.new(testedCol, 28))
                demandSignal = rb.dir == 1 and touched and rb.status != 2 and close > rb.top and close > open
                supplySignal = rb.dir == -1 and touched and rb.status != 2 and close < rb.btm and close < open
                demandSignalNow := demandSignalNow or demandSignal
                supplySignalNow := supplySignalNow or supplySignal
                retestState := demandSignal ? "Demand Reclaim" : supplySignal ? "Supply Reject" : retestState
                demandActive += rb.dir == 1 and rb.status != 2 ? 1 : 0
                supplyActive += rb.dir == -1 and rb.status != 2 ? 1 : 0
                tested += rb.status == 1 ? 1 : 0
                broken += rb.status == 2 ? 1 : 0
                bestScore := na(bestScore) ? rb.score : math.max(bestScore, rb.score)
                array.set(blocks, i, rb)

plot(showSignals and demandSignalNow ? low : na, "Demand reclaim", color=demandSig, linewidth=5, style=plot.style_cross)
plot(showSignals and supplySignalNow ? high : na, "Supply rejection", color=supplySig, linewidth=5, style=plot.style_cross)

if showDash
    var table dash = table.new(position.bottom_right, 2, 8, bgcolor=color.new(#090909, 8), border_width=1, border_color=color.new(#71624A, 28))
    if barstate.islast
        bias = demandActive > supplyActive ? "Demand Lean" : supplyActive > demandActive ? "Supply Lean" : emaFast > emaSlow ? "Trend Bid" : emaFast < emaSlow ? "Trend Offer" : "Balanced"
        biasCol = demandActive > supplyActive ? demandCol : supplyActive > demandActive ? supplyCol : color.white
        q = na(bestScore) ? 0 : bestScore
        table.cell(dash, 0, 0, "RBM [ZOM]", text_color=color.white, text_size=size.small, bgcolor=color.new(#17130C, 0))
        table.cell(dash, 1, 0, "Visible Blocks", text_color=color.new(#FFD47C, 0), text_size=size.small, text_halign=text.align_right, bgcolor=color.new(#17130C, 0))
        table.cell(dash, 0, 1, "Demand", text_color=color.new(#EFE8D8, 0), text_size=size.small)
        table.cell(dash, 1, 1, str.tostring(demandActive), text_color=demandCol, text_size=size.small, text_halign=text.align_right)
        table.cell(dash, 0, 2, "Supply", text_color=color.new(#EFE8D8, 0), text_size=size.small)
        table.cell(dash, 1, 2, str.tostring(supplyActive), text_color=supplyCol, text_size=size.small, text_halign=text.align_right)
        table.cell(dash, 0, 3, "Tested", text_color=color.new(#EFE8D8, 0), text_size=size.small)
        table.cell(dash, 1, 3, str.tostring(tested), text_color=testedCol, text_size=size.small, text_halign=text.align_right)
        table.cell(dash, 0, 4, "Broken", text_color=color.new(#EFE8D8, 0), text_size=size.small)
        table.cell(dash, 1, 4, str.tostring(broken), text_color=brokenCol, text_size=size.small, text_halign=text.align_right)
        table.cell(dash, 0, 5, "Latest", text_color=color.new(#EFE8D8, 0), text_size=size.small)
        table.cell(dash, 1, 5, lastSource, text_color=lastDir == 1 ? demandCol : lastDir == -1 ? supplyCol : color.white, text_size=size.small, text_halign=text.align_right)
        table.cell(dash, 0, 6, "Bias", text_color=color.new(#EFE8D8, 0), text_size=size.small)
        table.cell(dash, 1, 6, bias, text_color=biasCol, text_size=size.small, text_halign=text.align_right)
        table.cell(dash, 0, 7, "Best", text_color=color.new(#EFE8D8, 0), text_size=size.small)
        table.cell(dash, 1, 7, str.tostring(q, "#") + "%", text_color=q >= 70 ? testedCol : q >= 45 ? color.new(#B9E66C, 0) : color.new(#F47C7C, 0), text_size=size.small, text_halign=text.align_right)

alertcondition(demandSignalNow, "RBM Demand Reclaim", "Rejection Block Matrix: demand block reclaim confirmed [ZOM]")
alertcondition(supplySignalNow, "RBM Supply Reject", "Rejection Block Matrix: supply block rejection confirmed [ZOM]")
````
