# RSI + ZC COG Candles + Buy Signal

- url: https://www.tradingview.com/script/ShlWB9mz-RSI-ZC-COG-Candles-Buy-Signal/
- type: indicator
- pine_id: PUB;75ccab9082fe4b46bc48d0c978ca7ef0
- version: 1.0

## Description

This script combines a normalized Center of Gravity (ZC COG) candle view with an RSI color regime and a context‑aware buy signal filter.

The RSI block builds a three‑state background:
[list]
[*]Green when RSI trades above an adaptive band around its SMA (strong momentum zone).
[*]Yellow when price is neither strongly oversold nor strongly overbought (neutral / transition zone).
[*]Red when RSI drops below a forced level or below the lower band (downtrending / risk zone).
[/list]

On top of that regime, the script plots ZC COG candles, where price is transformed into a normalized oscillator:
[list]
[*]COG is centered, scaled to a fixed half‑range, optionally quantized, then drawn as synthetic candles with body and wick.
[*]This gives a clean visual of swings and turning points, independent of the raw price scale.
[/list]

The buy signal layer is designed to look for potential mean‑reversion moves out of recent red RSI zones, while trying to avoid most obvious bad contexts:
[list]
[*]Candles must close positively in the COG space.
[*]A configurable number of bars back (default: 5) is optionally checked to ensure the current candle is closing below a previous reference candle.
[*]The RSI must be above a minimum level and above an offset‑adjusted RSI SMA, so you can allow a small margin under the SMA if needed.
[*]A “recent red zone” filter requires that a red RSI regime occurred within a user‑defined lookback window, to focus on bounce‑type setups rather than chasing extended trends.
[/list]

This indicator is meant to be used together with a standard RSI 14 for divergence work:
[list]
[*]The buy markers highlight structural contexts where a bounce could make sense.
[*]The separate RSI 14 helps you confirm bullish divergences and filter out false signals.
[*]Without that divergence layer, you should expect more noise and more traps around earnings, gaps, and fast news moves.
[/list]

How to use it
[list]
[*]Apply this script and a classic RSI 14 on your chart.
[*]Use the colored background and COG candles to understand the current regime and local swings.
[*]Treat the buy signals as potential bounce zones, not guaranteed entries.
[*]Confirm using RSI 14 divergences, higher‑timeframe structure, and your own risk management rules.
[/list]

Disclaimer
This script is provided for educational purposes only.
It does not constitute financial advice, trade recommendations, or a solicitation to buy or sell any security or instrument.

Markets can react unexpectedly to:earnings releases, macro events, company‑specific news, liquidity shocks, and overnight gaps.
No indicator, including this one, can fully protect you from those events, and there is always a risk of loss when trading or investing.

Past performance and historical patterns do not guarantee future results.
Always do your own research, adapt parameters to your own strategy, and consult a qualified financial professional if you need personalized advice. Your capital is at risk and you remain fully responsible for your decisions.

## Source Code

````pine
//@version=6
indicator("RSI + ZC COG Candles + Buy Signal", shorttitle="RSI+ZC COG", overlay=false)

//==================================================
// RSI COLOR REGIME
//==================================================
rsiSrc         = input.source(close, "RSI Source")
rsiLength      = input.int(14, "RSI Length", minval=1)
rsiSmaLength   = input.int(14, "RSI SMA Length", minval=1)
offsetBand     = input.float(5.0, "Offset From RSI SMA", minval=0.0, step=0.1)
redRsiLevel    = input.float(30.0, "Force Red RSI Level", minval=0.0, maxval=100.0, step=0.1)

showRSI        = input.bool(false, "Show RSI")
showRSISMA     = input.bool(false, "Show RSI SMA")
showBandLines  = input.bool(false, "Show Offset Bands")
bgRange        = input.float(12.0, "Background Range", minval=1.0, step=0.5)

colGreen       = color.new(color.green, 78)
colYellow      = color.new(color.yellow, 78)
colRed         = color.new(color.red, 78)

// RSI calculations
rsiVal         = ta.rsi(rsiSrc, rsiLength)
rsiSma         = ta.sma(rsiVal, rsiSmaLength)
upperBand      = rsiSma + offsetBand
lowerBand      = rsiSma - offsetBand

// Background state logic
rawRed         = rsiVal <= redRsiLevel or rsiVal <= lowerBand
bool isRed     = bar_index > 0 ? rawRed[1] : false
bool isGreen   = rsiVal >= upperBand
bool isYellow  = not isRed and not isGreen

bgCol =
     isGreen  ? colGreen :
     isYellow ? colYellow :
     colRed

// Background fill from +bgRange to -bgRange
bgTop    = plot(bgRange, title="BG Top", color=color.new(color.white, 100), linewidth=1)
bgBottom = plot(-bgRange, title="BG Bottom", color=color.new(color.white, 100), linewidth=1)
fill(bgTop, bgBottom, color=bgCol, title="RSI Color Regime")

// Optional RSI plots
plot(showRSI ? rsiVal : na, "RSI", color=color.new(color.purple, 0), linewidth=1)
plot(showRSISMA ? rsiSma : na, "RSI SMA", color=color.new(color.yellow, 0), linewidth=1)
plot(showBandLines ? upperBand : na, "Upper Offset", color=color.new(color.green, 0), linewidth=1)
plot(showBandLines ? lowerBand : na, "Lower Offset", color=color.new(color.red, 0), linewidth=1)

//==================================================
// ZC COG CANDLES
//==================================================
cogLength      = input.int(10, "COG Length", minval=1)
cogSource      = input.source(close, "COG Source")
centerLength   = input.int(21, "Centering Length", minval=2)
smoothLength   = input.int(2, "Smoothing Length", minval=1)

normLookback   = input.int(120, "Normalization Lookback", minval=10)
targetRange    = input.float(10.0, "Target Half Range", minval=0.5, step=0.5)

bodyScale      = input.float(1.00, "Body Scale", minval=0.2, step=0.05)
wickMult       = input.float(0.08, "Wick Multiplier", minval=0.0, step=0.01)
quantStep      = input.float(0.00, "Quantization Step", minval=0.0, step=0.05)

showCandles    = input.bool(true, "Show Candles")
showLine       = input.bool(false, "Show Output Line")
showRawCog     = input.bool(false, "Show Raw COG")
showZeroLine   = input.bool(true, "Show Zero Line")

float cogRaw   = ta.cog(cogSource, cogLength)
float cogSm    = smoothLength > 1 ? ta.sma(cogRaw, smoothLength) : cogRaw
float center   = ta.sma(cogSm, centerLength)
float cogZero  = cogSm - center

float maxAbs   = ta.highest(math.abs(cogZero), normLookback)
float out      = maxAbs != 0 ? (cogZero / maxAbs) * targetRange : 0.0

if quantStep > 0
    out := math.round(out / quantStep) * quantStep

float o        = nz(out[1], out)
float c        = out

float delta    = (c - o) * bodyScale
c := o + delta

float bodyHi   = math.max(o, c)
float bodyLo   = math.min(o, c)

float avgMove  = ta.sma(math.abs(out - nz(out[1], out)), 5)
float wick     = nz(avgMove, 0) * wickMult

float h        = bodyHi + wick
float l        = bodyLo - wick

color candleColor = c >= o ? color.lime : color.red

plot(showZeroLine ? 0 : na, title="Zero", color=color.new(color.gray, 72), linewidth=1)
plot(showLine ? out : na, title="Output Line", color=color.blue, linewidth=2)
plot(showRawCog ? cogRaw : na, title="Raw COG", color=color.new(color.gray, 75), linewidth=1)

plotcandle(
    showCandles ? o : na,
    showCandles ? h : na,
    showCandles ? l : na,
    showCandles ? c : na,
    title="COG Candles",
    color=candleColor,
    wickcolor=candleColor,
    bordercolor=na
)

//==================================================
// BUY SIGNAL
//==================================================
showBuySignals      = input.bool(true, "Show Buy Signals")
buyPlotLevel        = input.float(-12.0, "Buy Plot Level", step=0.1)
buyMinRsi           = input.float(41.0, "Minimum RSI For Buy", minval=0.0, maxval=100.0, step=0.1)
zoneLookback        = input.int(2, "Red Zone Lookback", minval=1, maxval=10)
rsiSmaOffset        = input.float(-1.5, "RSI vs SMA Offset For Buy", step=0.1)

// Optional previous candle structure filter
usePrevCandleCheck  = input.bool(false, "Use Previous Candle Check")
prevCandleBarsBack  = input.int(5, "Previous Candle Bars Back", minval=1, maxval=20)

// Core candle condition
isPositiveCandle = c > o

// Previous candle comparison filter
prevCandleHigher = bar_index >= prevCandleBarsBack ? c[prevCandleBarsBack] > c : false
prevCandleFilter = not usePrevCandleCheck or prevCandleHigher

// Zone filter: buy is allowed only if a red zone happened recently
barsSinceRed  = ta.barssince(isRed)
recentRedZone = barsSinceRed >= 0 and barsSinceRed <= zoneLookback

// RSI filter: RSI must be above the minimum level
// and above the SMA threshold adjusted by the offset
rsiBuyFilter = rsiVal >= buyMinRsi and rsiVal >= (rsiSma + rsiSmaOffset)

// Final buy condition
buySignal =
     isPositiveCandle and
     prevCandleFilter and
     recentRedZone and
     rsiBuyFilter

plotshape(
    showBuySignals ? (buySignal ? buyPlotLevel : na) : na,
    title="Buy Signal",
    style=shape.triangleup,
    location=location.absolute,
    color=color.lime,
    size=size.small,
    text="Buy"
)
````
