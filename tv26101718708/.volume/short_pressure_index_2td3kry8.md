# Short Pressure Index

- url: https://www.tradingview.com/script/2Td3kRy8-Short-Pressure-Index/
- type: indicator
- pine_id: PUB;3c4dd3ed06584a7e9686e9628b391253
- version: 1.0

## Description

Overview
A composite 0-100 "short pressure" score built from three independently computed components (volume climax, MA deviation, and bearish-bar momentum), with optional automatic exchange routing for crypto and FINRA short-volume data substitution for stocks — so the same score means something comparable across very different asset classes.

How it's calculated
1. Volume pressure: the fraction of high-significance volume (climax or above-average bars, per a PVSRA-style multiplier check) that occurred on bearish closes over a rolling window. For US stocks with FINRA short volume enabled, this component is swapped for the actual reported short-volume ratio instead.
2. MA deviation pressure: how far below (in ATR multiples) price sits from its moving average, rescaled to 0-100 over a rolling window.
3. Momentum pressure: the % of the last N bars that closed bearish.

The three are averaged and smoothed with an EMA to produce the SPI line, which gets its own signal-line EMA and histogram. For crypto, price/volume can be routed to a more liquid exchange feed (e.g. Bitfinex) since the chart's native feed may be sparse; unsupported symbol types can be suppressed entirely rather than plotting a meaningless value.

How to use it
Readings above the high threshold (default 70) suggest broad short-side pressure building across all three components; below the low threshold (default 30) suggests minimal short pressure. The histogram and signal-line crosses give earlier, more granular entries than waiting for a threshold cross. For US equities, "Use FINRA Short Volume" swaps in real reported short-sale data for a more direct read than the volume-climax proxy alone.

## Source Code

````pine
//@version=6
indicator('SPI — Short Pressure Index', overlay = false, max_bars_back = 500)

// ═══════════════════════════════════════════════════════════════════════
// SPI SETTINGS
// ═══════════════════════════════════════════════════════════════════════
spiSmoothLen  = input.int(5,    'SPI Signal Smoothing',       minval = 1, maxval = 50,   group = 'SPI Core')
normWindow    = input.int(100,  'Normalization Window (bars)', minval = 20, maxval = 500, group = 'SPI Core')
momentumLen   = input.int(10,   'Momentum Lookback (bars)',   minval = 2,  maxval = 50,  group = 'SPI Core')

// ── Volume Component ─────────────────────────────────────────────────
volAvgLen      = input.int(20,   'Volume Average Length',      minval = 1,  group = 'Volume')
climaxMult     = input.float(2.0,'Climax Volume Multiplier',   step = 0.1,  group = 'Volume')
aboveAvgMult   = input.float(1.5,'Above Average Multiplier',   step = 0.1,  group = 'Volume')
volRollLen     = input.int(14,   'Volume Pressure Roll (bars)', minval = 2,  group = 'Volume')

// ── MA / ATR Component ───────────────────────────────────────────────
maLength = input.int(50,    'MA Length',  minval = 1, maxval = 5000, group = 'MA / ATR')
maType   = input.string('EMA', 'MA Type', options = ['SMA', 'EMA', 'RMA', 'WMA'], group = 'MA / ATR')
atrLen   = input.int(14,    'ATR Length', minval = 1,               group = 'MA / ATR')

// ── Thresholds & Colors ──────────────────────────────────────────────
highThresh  = input.int(70,  'High Pressure Zone (≥)',  minval = 51, maxval = 99, group = 'Display')
lowThresh   = input.int(30,  'Low Pressure Zone  (≤)',  minval = 1,  maxval = 49, group = 'Display')
showSignal  = input.bool(true, 'Show Signal Line (EMA of SPI)',                   group = 'Display')
signalLen   = input.int(9,   'Signal Line Length',     minval = 1,  maxval = 50,  group = 'Display')
showBg      = input.bool(true, 'Show Zone Background',                            group = 'Display')
showHisto   = input.bool(true, 'Show Histogram (SPI − Signal)',                   group = 'Display')

colHigh     = input.color(color.rgb(220, 50,  50),  'High Pressure Color',  group = 'Colors')
colLow      = input.color(color.rgb(50,  200, 100), 'Low Pressure Color',   group = 'Colors')
colMid      = input.color(color.rgb(220, 200, 60),  'Mid Pressure Color',   group = 'Colors')
colSignal   = input.color(color.rgb(255, 165,  0),  'Signal Line Color',    group = 'Colors')
colHistoPos = input.color(color.rgb(220, 80,  80),  'Histogram Bull Color', group = 'Colors')
colHistoNeg = input.color(color.rgb(80,  180, 100), 'Histogram Bear Color', group = 'Colors')

// ── Data Source Routing ──────────────────────────────────────────────
useExternalRouting   = input.bool(true,  'Use Asset-Class Routing',                        group = 'Data Routing')
cryptoExchange       = input.string('BITFINEX', 'Crypto Exchange Source', options = ['BITFINEX'], group = 'Data Routing')
useManualCryptoMap   = input.bool(false, 'Manual Crypto Mapping Override',                 group = 'Data Routing')
manualCryptoTicker   = input.string('BITFINEX:BTCUSD', 'Manual Crypto Ticker',             group = 'Data Routing')
allowFallbackToChart = input.bool(false, 'Fallback to Chart Data if Routed Source Missing', group = 'Data Routing')
useFINRAforStocks    = input.bool(true,  'Use FINRA Short Volume for Stocks',              group = 'Data Routing')
strictNoOutput        = input.bool(true, 'Unsupported Symbols => No Output',               group = 'Data Routing')

// ═══════════════════════════════════════════════════════════════════════
// HELPERS
// ═══════════════════════════════════════════════════════════════════════

getMA(src, len, t) =>
    switch t
        'EMA' => ta.ema(src, len)
        'RMA' => ta.rma(src, len)
        'WMA' => ta.wma(src, len)
        =>       ta.sma(src, len)

// Rescale any series to 0–100 over a rolling window
normalize(val, len) =>
    lo = ta.lowest(val,  len)
    hi = ta.highest(val, len)
    hi != lo ? math.max(0.0, math.min(100.0, (val - lo) / (hi - lo) * 100.0)) : 50.0

// ═══════════════════════════════════════════════════════════════════════
// SYMBOL CLASSIFICATION / ROUTING
// Crypto: pulls OHLCV from a routed exchange (BITFINEX by default, or a
// manual override) since the chart's own feed may be sparse/synthetic.
// Stocks: optionally swaps the volume-pressure component for FINRA
// reported short volume, a more direct measure of short-side activity.
// ═══════════════════════════════════════════════════════════════════════
mainTicker  = syminfo.ticker
mainType    = syminfo.type
isCrypto    = mainType == 'crypto'
isStockLike = mainType == 'stock' or mainType == 'fund'

cryptoSymbol = useManualCryptoMap ? manualCryptoTicker : cryptoExchange + ':' + mainTicker
finraSymbol  = 'FINRA:' + mainTicker + '_SHORT_VOLUME'

routedPriceSymbol = not useExternalRouting ? syminfo.tickerid : isCrypto ? cryptoSymbol : syminfo.tickerid

rOpen  = request.security(routedPriceSymbol, timeframe.period, open,  ignore_invalid_symbol = true)
rHigh  = request.security(routedPriceSymbol, timeframe.period, high,  ignore_invalid_symbol = true)
rLow   = request.security(routedPriceSymbol, timeframe.period, low,   ignore_invalid_symbol = true)
rClose = request.security(routedPriceSymbol, timeframe.period, close, ignore_invalid_symbol = true)
rVol   = request.security(routedPriceSymbol, timeframe.period, volume, ignore_invalid_symbol = true)

finraShortVol = request.security(finraSymbol,      'D', close,  ignore_invalid_symbol = true)
stockDailyVol = request.security(syminfo.tickerid,  'D', volume, ignore_invalid_symbol = true)

priceSourceValid = not na(rClose)
useFallbackNow    = isCrypto and allowFallbackToChart and not priceSourceValid

wOpen  = isCrypto and not useFallbackNow ? rOpen   : open
wHigh  = isCrypto and not useFallbackNow ? rHigh   : high
wLow   = isCrypto and not useFallbackNow ? rLow    : low
wClose = isCrypto and not useFallbackNow ? rClose  : close
wVol   = isCrypto and not useFallbackNow ? rVol    : volume

spiSourceSupported = isCrypto ? (useFallbackNow ? true : priceSourceValid) : isStockLike ? true : false
finalCanPlotSPI    = strictNoOutput ? spiSourceSupported : true

finraRatio    = not na(finraShortVol) and not na(stockDailyVol) and stockDailyVol > 0
     ? math.min(100.0, math.max(0.0, finraShortVol / stockDailyVol * 100.0)) : na
useFinraNow   = isStockLike and useFINRAforStocks and not na(finraRatio)

// ═══════════════════════════════════════════════════════════════════════
// COMPONENT 1 — VOLUME PRESSURE  (0–100)
// Fraction of high-significance volume that is BEARISH over the roll window,
// or the FINRA short-volume ratio directly when routed to a stock.
// ═══════════════════════════════════════════════════════════════════════
volAvg     = ta.sma(wVol, volAvgLen)
isClimax   = wVol >= volAvg * climaxMult
isAboveAvg = wVol >= volAvg * aboveAvgMult
isBearBar  = wClose < wOpen

bearVolRaw = (isClimax or isAboveAvg) and isBearBar  ? wVol : 0.0
bullVolRaw = (isClimax or isAboveAvg) and not isBearBar ? wVol : 0.0

bearVolSum = math.sum(bearVolRaw, volRollLen)
bullVolSum = math.sum(bullVolRaw, volRollLen)
totalHigh  = bearVolSum + bullVolSum
volPressureRaw = totalHigh > 0 ? bearVolSum / totalHigh * 100.0 : 50.0
volPressure    = useFinraNow ? finraRatio : volPressureRaw

// ═══════════════════════════════════════════════════════════════════════
// COMPONENT 2 — MA DEVIATION PRESSURE  (0–100)
// Higher when price is deeply BELOW the MA (in ATR multiples)
// ═══════════════════════════════════════════════════════════════════════
ma          = getMA(wClose, maLength, maType)
trueRange   = math.max(wHigh - wLow, math.max(math.abs(wHigh - wClose[1]), math.abs(wLow - wClose[1])))
atr         = ta.rma(trueRange, atrLen)
maDevRaw    = atr > 0 ? (ma - wClose) / atr : 0.0     // positive  = below MA
maDevNorm   = normalize(maDevRaw, normWindow)          // 0–100

// ═══════════════════════════════════════════════════════════════════════
// COMPONENT 3 — MOMENTUM PRESSURE  (0–100)
// Fraction of recent bars that closed bearish
// ═══════════════════════════════════════════════════════════════════════
bearCount = 0.0
for i = 0 to momentumLen - 1
    bearCount += wClose[i] < wOpen[i] ? 1.0 : 0.0
momentumPressure = bearCount / momentumLen * 100.0

// ═══════════════════════════════════════════════════════════════════════
// COMPOSITE SPI  (equal-weighted, then lightly smoothed)
// 0  = zero short pressure  |  100 = maximum short pressure
// ═══════════════════════════════════════════════════════════════════════
spiRaw    = (volPressure + maDevNorm + momentumPressure) / 3.0
spiSmooth = ta.ema(spiRaw, spiSmoothLen)
spi       = finalCanPlotSPI ? spiSmooth : na
signal    = ta.ema(spi, signalLen)
histo     = spi - signal

// ═══════════════════════════════════════════════════════════════════════
// DYNAMIC COLOR
// ═══════════════════════════════════════════════════════════════════════
spiColor = spi >= highThresh ? colHigh
         : spi <= lowThresh  ? colLow
         :                     colMid

// ═══════════════════════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════════════════════

// Zone backgrounds
bgcolor(showBg and spi >= highThresh ? color.new(colHigh, 88) : na, title = 'High Pressure BG')
bgcolor(showBg and spi <= lowThresh  ? color.new(colLow,  88) : na, title = 'Low Pressure BG')

// Histogram
plot(showHisto ? histo : na,
     title     = 'SPI Histogram',
     style     = plot.style_histogram,
     color     = histo >= 0 ? color.new(colHistoPos, 40) : color.new(colHistoNeg, 40),
     linewidth = 2)

// SPI line
plot(spi,
     title     = 'SPI',
     color     = spiColor,
     linewidth = 2)

// Signal line
plot(showSignal ? signal : na,
     title     = 'Signal',
     color     = colSignal,
     linewidth = 1,
     style     = plot.style_line)

// Reference lines
hline(highThresh, 'High Pressure',  color = color.new(colHigh, 50), linestyle = hline.style_dashed,  linewidth = 1)
hline(50,         'Midline',        color = color.new(color.gray, 60), linestyle = hline.style_dotted, linewidth = 1)
hline(lowThresh,  'Low Pressure',   color = color.new(colLow,  50), linestyle = hline.style_dashed,  linewidth = 1)

// ═══════════════════════════════════════════════════════════════════════
// HIDDEN OUTPUTS (for strategy use / alerts)
// ═══════════════════════════════════════════════════════════════════════
plot(spi,    title = 'SPI Value',    display = display.none)
plot(signal, title = 'Signal Value', display = display.none)

// ─── Alert Conditions ───────────────────────────────────────────────
alertcondition(ta.crossover(spi, highThresh),  'SPI Enters High Pressure',  'SPI crossed above high threshold — short pressure rising')
alertcondition(ta.crossunder(spi, highThresh), 'SPI Leaves High Pressure',  'SPI dropped below high threshold — pressure easing')
alertcondition(ta.crossunder(spi, lowThresh),  'SPI Enters Low Pressure',   'SPI dropped below low threshold — minimal short pressure')
alertcondition(ta.crossover(spi, signal),      'SPI Crosses Above Signal',  'SPI crossed above signal line — pressure building')
alertcondition(ta.crossunder(spi, signal),     'SPI Crosses Below Signal',  'SPI crossed below signal line — pressure fading')
````
