# Moving Averages Trend

- url: https://www.tradingview.com/script/OilUSvU6-Moving-Averages-Trend/
- type: indicator
- pine_id: PUB;5157c26ede504848a30ad86d3f675e91
- version: 1.0

## Description

Four independently configurable moving averages (type, length, source, color each) let you build the classic multi-MA trend stack in one indicator — a long-term filter to define the overall regime, an intermediate MA for the broader trend, and a fast pair for tactical entries on pullbacks within it. Used purely as an overlay, this is a continuation tool: you only take trades in the direction the slower MAs already agree on, using the faster pair to time entries once price pulls back into alignment.

The MA3/MA4 cross-signal layer is what sets this apart from a plain crossover system. Instead of waiting for the two faster MAs to physically cross — which is already stale information by the time it happens — it takes each MA's recent slope and projects it forward by a configurable number of bars, firing the buy/sell label as soon as that projected path crosses rather than the actual one, giving you a signal a few bars earlier than a textbook crossover. A minimum-separation filter (scaled to ATR) throws out weak "touch and go" near-misses, and the signal only fires when price is already sitting on the correct side of both MAs and each MA is still actively moving in that direction on the current bar — all of which is meant to filter out low-conviction crosses in choppy conditions. An optional daily+-only restriction keeps the signal from firing on intraday noise for traders who only want to act on it at swing timeframes.

Best applied in trending or newly-trending markets, as a combined trend filter (from the 4 plotted MAs) and tactical entry trigger (from the cross signal) rather than as a mean-reversion tool — it has little to offer in a flat, range-bound market since the slope and separation conditions are designed specifically to avoid firing in that environment.

## Source Code

````pine
//@version=6
indicator('Moving Averages Trend', overlay = true)

// ═══════════════════════════════════════════════════════════════════════
// MOVING AVERAGE INPUTS
// ═══════════════════════════════════════════════════════════════════════
showMA1   = input.bool(true,   'Show MA 1', group = 'Moving Averages')
ma1Length = input.int(50,    'MA 1 Length', minval = 1, group = 'Moving Averages')
ma1Type   = input.string('SMA', 'MA 1 Type',
     options = ['SMA', 'EMA', 'RMA', 'VWMA', 'WMA'], group = 'Moving Averages')
ma1Source = input.source(close, 'MA 1 Source', group = 'Moving Averages')
ma1Color  = input.color(color.blue,   'MA 1 Color', group = 'Moving Averages')
ma1Width  = input.int(1, 'MA 1 Width', minval = 1, maxval = 4, group = 'Moving Averages')

showMA2   = input.bool(true,   'Show MA 2', group = 'Moving Averages')
ma2Length = input.int(200,   'MA 2 Length', minval = 1, group = 'Moving Averages')
ma2Type   = input.string('SMA', 'MA 2 Type',
     options = ['SMA', 'EMA', 'RMA', 'VWMA', 'WMA'], group = 'Moving Averages')
ma2Source = input.source(close, 'MA 2 Source', group = 'Moving Averages')
ma2Color  = input.color(color.yellow, 'MA 2 Color', group = 'Moving Averages')
ma2Width  = input.int(1, 'MA 2 Width', minval = 1, maxval = 4, group = 'Moving Averages')

showMA3   = input.bool(true,   'Show MA 3', group = 'Moving Averages')
ma3Length = input.int(9,     'MA 3 Length', minval = 1, group = 'Moving Averages')
ma3Type   = input.string('EMA', 'MA 3 Type',
     options = ['SMA', 'EMA', 'RMA', 'VWMA', 'WMA'], group = 'Moving Averages')
ma3Source = input.source(close, 'MA 3 Source', group = 'Moving Averages')
ma3Color  = input.color(color.purple, 'MA 3 Color', group = 'Moving Averages')
ma3Width  = input.int(1, 'MA 3 Width', minval = 1, maxval = 4, group = 'Moving Averages')

showMA4   = input.bool(true,    'Show MA 4', group = 'Moving Averages')
ma4Length = input.int(21,     'MA 4 Length', minval = 1, group = 'Moving Averages')
ma4Type   = input.string('EMA', 'MA 4 Type',
     options = ['SMA', 'EMA', 'RMA', 'VWMA', 'WMA'], group = 'Moving Averages')
ma4Source = input.source(close, 'MA 4 Source', group = 'Moving Averages')
ma4Color  = input.color(color.lime,   'MA 4 Color', group = 'Moving Averages')
ma4Width  = input.int(1, 'MA 4 Width', minval = 1, maxval = 4, group = 'Moving Averages')

// ═══════════════════════════════════════════════════════════════════════
// MA3 / MA4 CROSS SIGNAL INPUTS
// ═══════════════════════════════════════════════════════════════════════
showMACross        = input.bool(true,  'Enable MA3/MA4 Cross Signals',       group = 'MA Cross Signals')
maCrossSlopeLen    = input.int(3,      'Slope Lookback (bars)',
     minval = 1, maxval = 20, group = 'MA Cross Signals')
maCrossBuyColor    = input.color(color.new(color.lime, 0), 'Buy Label Color',  group = 'MA Cross Signals')
maCrossSellColor   = input.color(color.new(color.red,  0), 'Sell Label Color', group = 'MA Cross Signals')
maCrossLabelSize   = input.string('tiny', 'Label Size',
     options = ['tiny', 'small', 'normal', 'large', 'huge'], group = 'MA Cross Signals')
maCrossLabelOffset = input.float(0.5,  'Label Offset (ATR multiples)',
     minval = 0.0, step = 0.1, group = 'MA Cross Signals')
maCrossMinSepATR   = input.float(0.015,  'Min Cross Separation (ATR multiples)',
     minval = 0.0, step = 0.01, group = 'MA Cross Signals')
maCrossBarsAhead   = input.int(2,      'Preemptive Bars Ahead (0 = fire on actual cross)',
     minval = 0, maxval = 10, group = 'MA Cross Signals')
maCrossDailyOnly   = input.bool(true,  'Restrict Signals to Daily+ Timeframes', group = 'MA Cross Signals')

// ═══════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════
getMA(src, length, maType) =>
    _ema  = ta.ema(src, length)
    _rma  = ta.rma(src, length)
    _vwma = na(volume) or volume == 0 ? ta.ema(src, length) : ta.vwma(src, length)
    _wma  = ta.wma(src, length)
    _sma  = ta.sma(src, length)
    switch maType
        'EMA'  => _ema
        'RMA'  => _rma
        'VWMA' => _vwma
        'WMA'  => _wma
        =>        _sma

f_getSize(s) =>
    switch s
        'tiny'   => size.tiny
        'small'  => size.small
        'normal' => size.normal
        'large'  => size.large
        'huge'   => size.huge
        =>          size.tiny

atr = nz(ta.atr(14), 1.0)

// ═══════════════════════════════════════════════════════════════════════
// MOVING AVERAGES
// ═══════════════════════════════════════════════════════════════════════
ma1 = getMA(ma1Source, ma1Length, ma1Type)
ma2 = getMA(ma2Source, ma2Length, ma2Type)
ma3 = getMA(ma3Source, ma3Length, ma3Type)
ma4 = getMA(ma4Source, ma4Length, ma4Type)
plot(showMA1 ? ma1 : na, title = 'MA 1', color = ma1Color, linewidth = ma1Width)
plot(showMA2 ? ma2 : na, title = 'MA 2', color = ma2Color, linewidth = ma2Width)
plot(showMA3 ? ma3 : na, title = 'MA 3', color = ma3Color, linewidth = ma3Width)
plot(showMA4 ? ma4 : na, title = 'MA 4', color = ma4Color, linewidth = ma4Width)

// ═══════════════════════════════════════════════════════════════════════
// MA3/MA4 CROSS SIGNALS (with preemptive projection)
// ═══════════════════════════════════════════════════════════════════════
// Per-bar slope of each MA (delta per bar over the lookback)
ma3Slope = not na(ma3) and not na(ma3[maCrossSlopeLen]) ?
     (ma3 - ma3[maCrossSlopeLen]) / maCrossSlopeLen : 0.0
ma4Slope = not na(ma4) and not na(ma4[maCrossSlopeLen]) ?
     (ma4 - ma4[maCrossSlopeLen]) / maCrossSlopeLen : 0.0

// Project each MA forward by N bars using its current slope
ma3Proj = not na(ma3) ? ma3 + ma3Slope * maCrossBarsAhead : float(na)
ma4Proj = not na(ma4) ? ma4 + ma4Slope * maCrossBarsAhead : float(na)

// Cross event on the *projected* series — fires when the projection
// first flips from non-crossed to crossed. At N=0 this collapses to
// the actual MA cross; at N=2 it fires ~2 bars before the cross.
projCrossUp   = ta.crossover(ma3Proj,  ma4Proj)
projCrossDown = ta.crossunder(ma3Proj, ma4Proj)

// Proper separation at the projected point — kills "touch" setups
projSeparation      = not na(ma3Proj) and not na(ma4Proj) ? math.abs(ma3Proj - ma4Proj) : 0.0
validProjSeparation = projSeparation >= atr * maCrossMinSepATR

// Lookback slope — established trend direction
ma3SlopeUp = ma3Slope > 0
ma4SlopeUp = ma4Slope > 0
ma3SlopeDn = ma3Slope < 0
ma4SlopeDn = ma4Slope < 0

// Bar-over-bar slope — MAs still moving in direction on *this* bar
ma3RisingNow  = not na(ma3) and not na(ma3[1]) and ma3 > ma3[1]
ma4RisingNow  = not na(ma4) and not na(ma4[1]) and ma4 > ma4[1]
ma3FallingNow = not na(ma3) and not na(ma3[1]) and ma3 < ma3[1]
ma4FallingNow = not na(ma4) and not na(ma4[1]) and ma4 < ma4[1]

// Price position — kept on the current close, not the projection
priceAboveMAs = not na(ma3) and not na(ma4) and close > ma3 and close > ma4
priceBelowMAs = not na(ma3) and not na(ma4) and close < ma3 and close < ma4

_maCrossTFOk = not maCrossDailyOnly or timeframe.in_seconds(timeframe.period) >= 86400
isMABuy  = showMACross and _maCrossTFOk and showMA3 and showMA4 and projCrossUp   and validProjSeparation and ma3SlopeUp and ma4SlopeUp and ma3RisingNow  and ma4RisingNow  and priceAboveMAs
isMASell = showMACross and _maCrossTFOk and showMA3 and showMA4 and projCrossDown and validProjSeparation and ma3SlopeDn and ma4SlopeDn and ma3FallingNow and ma4FallingNow and priceBelowMAs

if isMABuy
    label.new(bar_index, low - atr * maCrossLabelOffset, 'Buy',
         color     = color.new(maCrossBuyColor, 20),
         textcolor = color.white,
         style     = label.style_label_up,
         size      = f_getSize(maCrossLabelSize),
         yloc      = yloc.belowbar)
if isMASell
    label.new(bar_index, high + atr * maCrossLabelOffset, 'Sell',
         color     = color.new(maCrossSellColor, 20),
         textcolor = color.white,
         style     = label.style_label_down,
         size      = f_getSize(maCrossLabelSize),
         yloc      = yloc.abovebar)

alertcondition(isMABuy,  'MA3/MA4 Cross Buy',  'MA3 crossed above MA4 with upward slope; price above both')
alertcondition(isMASell, 'MA3/MA4 Cross Sell', 'MA3 crossed below MA4 with downward slope; price below both')
````
