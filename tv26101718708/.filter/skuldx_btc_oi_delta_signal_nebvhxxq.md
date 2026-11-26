# [SkuldX] BTC OI Delta + Signal

- url: https://www.tradingview.com/script/neBVhXxq-SkuldX-BTC-OI-Delta-Signal/
- type: indicator
- pine_id: PUB;49f395c354d342e08382f9bcf5c4f49a
- version: 1.0

## Description

SkuldX BTC OI Delta + Signal — Institutional Positioning Intelligence
by SkuldX Trading Systems

What is it?
SkuldX BTC OI Delta + Signal goes beyond simply showing Open Interest numbers. It decodes the relationship between price movement and OI changes to identify the true nature of every market move — whether it's driven by real conviction or forced liquidations. This distinction is what separates high-probability entries from noise.

How it works
Open Interest Delta measures how many BTC contracts were opened or closed each bar. When combined with price direction, it reveals four distinct market states that form the core of this indicator's signal logic.

The Signal Matrix
🟢 Bullish Trend — price rising + OI increasing. New long positions are being opened. This is genuine buying conviction — the strongest long signal.
🟡 Short Squeeze — price rising + OI decreasing. Shorts are being forcibly closed. Price moves up but no new longs are entering — the move is weak and may not sustain.
🟠 Long Squeeze — price falling + OI increasing. Longs are being liquidated while new shorts open. Counterintuitively, this can precede a reversal once the squeeze exhausts itself.
🔴 Bearish Trend — price falling + OI decreasing. Positions are being closed into a falling market. Strong directional conviction to the downside.
Every histogram bar is color-coded by market state — giving you instant visual context without any manual analysis.

Two-panel layout
Panel 1 — OI Delta Histogram Shows the change in aggregated Open Interest per bar in BTC contracts. An EMA overlay tracks the trend of leverage in the market — rising MA means the market is consistently adding positions, falling MA means deleveraging.
Panel 2 — Z-Score Measures how statistically significant the current OI Delta is relative to recent history. A Z-Score above +2σ means an unusually large OI increase. Below -2σ means an unusually large OI decrease. These extremes often coincide with institutional activity, liquidation cascades, or the start of a significant directional move.
Z-Score levels at ±1σ and ±2σ are displayed with background highlighting for extreme zones.

Data sources
Aggregates perpetual futures Open Interest from five major exchanges — Binance USDT.P, Binance USD.P, Binance BUSD.P, Bybit USDT.P, and OKX USDT.P. Each source can be toggled independently. All values are normalized to BTC contracts for consistent cross-exchange comparison.

Settings
Data Sources — enable or disable each exchange independently
MA Length — EMA period for the delta trend line
Z-Score Lookback — historical window for statistical normalization
Z-Score Levels — configurable ±1σ and ±2σ thresholds
Colors — independent color control for each of the four market states

Signal flags in Data Window
When hovering over any bar, the Data Window shows four binary signal flags — Bullish Trend, Short Squeeze, Long Squeeze, Bearish Trend — alongside raw OI Delta, Total OI, MA, and Z-Score values. These flags are designed to be consumed programmatically in strategy scripts built on top of this indicator.

Notes
Best used on 15m to 4h timeframes where individual OI spikes are meaningful. On very low timeframes (under 5m) noise dominates. The Z-Score panel is most useful for identifying accumulation/distribution phases — sustained readings above +1σ while price consolidates often precede breakouts.

Built for SkuldX ecosystem
This indicator is a core component of the SkuldX signal layer. OI-based market state detection feeds directly into SkuldX automated trading logic for position entry confirmation, squeeze detection, and leverage-driven reversal setups.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © skuldxtrade

//@version=6
indicator("[SkuldX] BTC OI Delta + Signal", format = format.volume, overlay = false)


// ══════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════

useBinanceUSDT = input.bool(true,  "Binance USDT.P", group = "Data Sources")
useBinanceUSD  = input.bool(true,  "Binance USD.P",  group = "Data Sources")
useBinanceBUSD = input.bool(true,  "Binance BUSD.P", group = "Data Sources")
useBybit       = input.bool(true,  "Bybit USDT.P",   group = "Data Sources")
useOKX         = input.bool(true,  "OKX USDT.P",     group = "Data Sources")

maLength       = input.int(20,     "MA Length (Delta Trend)",  group = "Settings", minval = 2,  maxval = 200)
zLength        = input.int(200,    "Z-Score Lookback",         group = "Settings", minval = 10, maxval = 500)
zLevel1        = input.float(1.0,  "Z-Score Level 1 (±1σ)",    group = "Settings", step = 0.1)
zLevel2        = input.float(2.0,  "Z-Score Level 2 (±2σ)",    group = "Settings", step = 0.1)

// Histogram colors mapped to the Price × OI Delta signal matrix
colBullishTrend  = input.color(color.new(color.green,  10), "Bullish Trend  (↑price ↑OI)", group = "Colors")
colShortSqueeze  = input.color(color.new(color.yellow, 10), "Short Squeeze  (↑price ↓OI)", group = "Colors")
colLongSqueeze   = input.color(color.new(color.orange, 10), "Long Squeeze   (↓price ↑OI)", group = "Colors")
colBearishTrend  = input.color(color.new(color.red,    10), "Bearish Trend  (↓price ↓OI)", group = "Colors")
colMaUp          = input.color(color.new(color.teal,   20), "MA (rising)",                 group = "Colors")
colMaDown        = input.color(color.new(color.red,    40), "MA (falling)",                group = "Colors")


// ══════════════════════════════════════════════════════
// DATA — OI DELTA AND ABSOLUTE OI PER EXCHANGE
// Delta is fetched directly as close - close[1] inside request.security
// to avoid repainting and ensure bar-accurate calculation
// ══════════════════════════════════════════════════════

dBinanceUSDT = request.security("BINANCE:BTCUSDT.P_OI", timeframe.period, close - close[1], ignore_invalid_symbol = true)
dBinanceUSD  = request.security("BINANCE:BTCUSD.P_OI",  timeframe.period, close - close[1], ignore_invalid_symbol = true)
dBinanceBUSD = request.security("BINANCE:BTCBUSD.P_OI", timeframe.period, close - close[1], ignore_invalid_symbol = true)
dBybit       = request.security("BYBIT:BTCUSDT.P_OI",   timeframe.period, close - close[1], ignore_invalid_symbol = true)
dOKX         = request.security("OKX:BTCUSDT.P_OI",     timeframe.period, close - close[1], ignore_invalid_symbol = true)

// Absolute OI per exchange — used to calculate total market OI in BTC contracts
aiBinanceUSDT = request.security("BINANCE:BTCUSDT.P_OI", timeframe.period, close, ignore_invalid_symbol = true)
aiBinanceUSD  = request.security("BINANCE:BTCUSD.P_OI",  timeframe.period, close, ignore_invalid_symbol = true)
aiBinanceBUSD = request.security("BINANCE:BTCBUSD.P_OI", timeframe.period, close, ignore_invalid_symbol = true)
aiBybit       = request.security("BYBIT:BTCUSDT.P_OI",   timeframe.period, close, ignore_invalid_symbol = true)
aiOKX         = request.security("OKX:BTCUSDT.P_OI",     timeframe.period, close, ignore_invalid_symbol = true)

// BTC spot price — used to convert USD-denominated OI values into BTC contracts
btcPrice = request.security("BINANCE:BTCUSDT", timeframe.period, close, ignore_invalid_symbol = true)


// ══════════════════════════════════════════════════════
// AGGREGATION
// Combines all enabled exchange sources into a single delta and total OI
// Returns 0 for disabled or unavailable sources to avoid na contamination
// ══════════════════════════════════════════════════════

safe(float val, bool on) => on and not na(val) ? val : 0.0

// Sum raw USD delta across all enabled exchanges
rawDelta =
     safe(dBinanceUSDT, useBinanceUSDT) +
     safe(dBinanceUSD,  useBinanceUSD)  +
     safe(dBinanceBUSD, useBinanceBUSD) +
     safe(dBybit,       useBybit)       +
     safe(dOKX,         useOKX)

// Sum absolute OI across all enabled exchanges
totalOI =
     safe(aiBinanceUSDT, useBinanceUSDT) +
     safe(aiBinanceUSD,  useBinanceUSD)  +
     safe(aiBinanceBUSD, useBinanceBUSD) +
     safe(aiBybit,       useBybit)       +
     safe(aiOKX,         useOKX)

// Convert USD values to BTC contracts by dividing by spot price
oiDelta = not na(btcPrice) and btcPrice > 0 ? rawDelta / btcPrice : rawDelta
oiAbs   = not na(btcPrice) and btcPrice > 0 ? totalOI  / btcPrice : totalOI


// ══════════════════════════════════════════════════════
// SIGNAL MATRIX: Price Direction × OI Delta Direction
// Four market states derived from combining price and OI movement:
// Bullish Trend  — price up + OI up   → new longs opening, strong directional move
// Short Squeeze  — price up + OI down → shorts being closed, weak/unsustained move
// Long Squeeze   — price down + OI up → longs being liquidated, potential recovery
// Bearish Trend  — price down + OI down → new shorts opening, strong downside move
// ══════════════════════════════════════════════════════

priceUp   = close > close[1]
priceDown = close < close[1]
oiUp      = oiDelta > 0
oiDown    = oiDelta < 0

isBullishTrend = priceUp   and oiUp
isShortSqueeze = priceUp   and oiDown
isLongSqueeze  = priceDown and oiUp
isBearishTrend = priceDown and oiDown


// ══════════════════════════════════════════════════════
// OI DELTA MA — LEVERAGE TREND
// EMA applied to OI delta to smooth noise and reveal
// whether the market is consistently adding or reducing leverage
// ══════════════════════════════════════════════════════

oiDeltaMA = ta.ema(oiDelta, maLength)
maRising  = oiDeltaMA > oiDeltaMA[1]


// ══════════════════════════════════════════════════════
// Z-SCORE — STATISTICAL SIGNIFICANCE OF OI DELTA
// Measures how many standard deviations the current delta
// is from its historical mean over the lookback window
// Extreme readings (beyond ±2σ) often coincide with
// institutional activity, liquidation cascades, or trend starts
// ══════════════════════════════════════════════════════

zMean   = ta.sma(oiDelta,   zLength)
zStdDev = ta.stdev(oiDelta, zLength)
zScore  = zStdDev != 0 ? (oiDelta - zMean) / zStdDev : 0.0


// ══════════════════════════════════════════════════════
// HISTOGRAM COLOR — mapped from signal matrix
// Each bar is colored by its market state for instant visual context
// ══════════════════════════════════════════════════════

histColor = isBullishTrend ? colBullishTrend :
             isShortSqueeze ? colShortSqueeze :
             isLongSqueeze  ? colLongSqueeze  :
             isBearishTrend ? colBearishTrend :
             color.gray


// ══════════════════════════════════════════════════════
// PANEL 1: OI DELTA HISTOGRAM + MA
// Histogram bars show per-bar change in aggregated OI
// MA overlay shows the trend direction of leverage in the market
// ══════════════════════════════════════════════════════

plot(oiDelta,
     title     = "OI Delta (BTC contracts)",
     style     = plot.style_histogram,
     color     = histColor,
     linewidth = 1)

plot(oiDeltaMA,
     title     = "OI Delta MA",
     color     = maRising ? colMaUp : colMaDown,
     linewidth = 2)

hline(0, "Zero", color = color.new(color.gray, 50), linestyle = hline.style_solid, linewidth = 1)


// ══════════════════════════════════════════════════════
// PANEL 2: Z-SCORE
// Rendered in a separate pane via display = display.pane
// Color-coded by the same signal matrix as the histogram
// Background highlights extreme zones beyond ±2σ
// ══════════════════════════════════════════════════════

// Z-Score line — color follows signal matrix state
plot(zScore,
     title     = "OI Z-Score",
     color     = isBullishTrend ? colBullishTrend :
                 isShortSqueeze ? colShortSqueeze :
                 isLongSqueeze  ? colLongSqueeze  :
                 isBearishTrend ? colBearishTrend :
                 color.gray,
     linewidth  = 2,
     display    = display.pane)

// Static sigma reference lines
hline( zLevel2,  "+2σ", color = color.new(color.green,  40), linestyle = hline.style_dashed)
hline( zLevel1,  "+1σ", color = color.new(color.green,  60), linestyle = hline.style_dotted)
hline(0,         "0",   color = color.new(color.gray,   50), linestyle = hline.style_solid)
hline(-zLevel1,  "-1σ", color = color.new(color.red,    60), linestyle = hline.style_dotted)
hline(-zLevel2,  "-2σ", color = color.new(color.red,    40), linestyle = hline.style_dashed)

// Background highlight for statistically extreme OI delta readings
bgcolor(zScore >  zLevel2 ? color.new(color.green, 90) :
        zScore < -zLevel2 ? color.new(color.red,   90) : na,
        title = "Extreme Zone")


// ══════════════════════════════════════════════════════
// DATA WINDOW
// All key values visible on hover — designed for use
// in strategy scripts and manual signal confirmation
// ══════════════════════════════════════════════════════

plot(oiDelta,   "OI Delta (BTC)",   color = color.new(color.blue, 100), display = display.data_window)
plot(oiAbs,     "Total OI (BTC)",   color = color.new(color.blue, 100), display = display.data_window)
plot(oiDeltaMA, "OI Delta MA",      color = color.new(color.blue, 100), display = display.data_window)
plot(zScore,    "Z-Score",          color = color.new(color.blue, 100), display = display.data_window)

// Binary signal flags for programmatic consumption in strategy scripts
plot(isBullishTrend ? 1.0 : 0.0, "Signal: Bullish Trend", color = color.new(color.blue, 100), display = display.data_window)
plot(isShortSqueeze ? 1.0 : 0.0, "Signal: Short Squeeze", color = color.new(color.blue, 100), display = display.data_window)
plot(isLongSqueeze  ? 1.0 : 0.0, "Signal: Long Squeeze",  color = color.new(color.blue, 100), display = display.data_window)
plot(isBearishTrend ? 1.0 : 0.0, "Signal: Bearish Trend", color = color.new(color.blue, 100), display = display.data_window)
````
