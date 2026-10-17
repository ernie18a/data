# Sigma Heatmap

- url: https://www.tradingview.com/script/d8zSBwjN-Sigma-Heatmap/
- type: indicator
- pine_id: PUB;029baf3df63040e9a72a89085d7af667
- version: 4.0

## Description

[symbol="CME_MINI:NQ1!"]CME_MINI:NQ1![/symbol] [symbol="CME_MINI:ES1!"]CME_MINI:ES1![/symbol] [symbol="NASDAQ:QQQ"]NASDAQ:QQQ[/symbol] [symbol="AMEX:SPY"]AMEX:SPY[/symbol] [symbol="NASDAQ:NDX"]NASDAQ:NDX[/symbol] [symbol="SPCFD:SPX"]SPCFD:SPX[/symbol] [symbol="CBOE:VXN"]CBOE:VXN[/symbol] [symbol="CBOE:VIX"]CBOE:VIX[/symbol] 
Sigma Heatmap
Colours each candle by how far price (ohlc4) is stretched from its rolling mean, measured in standard deviations (σ).
• Grey – within 2σ (normal)
• Light grey – between 2σ and 3σ (stretched)
• White – beyond 3σ (statistical extreme)
The lookback adapts to volatility: 50 bars in a normal ATR regime, shorter when ATR (14) runs above its 200-bar average, longer when it runs below (clamped 15–100). σ is always calculated from 24h (ETH) back-adjusted data, so the colours are the same on RTH and ETH charts. Levels, colours and window settings are adjustable. The current σ value is shown in the Data Window.
This is a visual context tool, not a buy/sell signal.

## Source Code

````pine
//@version=6
// Sigma Heatmap — colours candles by how far price (ohlc4) is stretched from its
// rolling mean, measured in standard deviations.
// The window adapts to volatility: `Base length` bars in a normal ATR regime,
// shorter when ATR runs above its long-term average, longer when it runs below.
// σ is always computed from 24h (ETH) back-adjusted data, so an RTH chart shows
// the same values, just fewer bars.
indicator("Sigma Stretch", shorttitle = "σ Stretch", overlay = true, max_bars_back = 500)

// ── Inputs ──────────────────────────────────────────────────────────────────
sig2 = input.float(2.0, "Sigma 2 level", minval = 0.5, step = 0.1, group = "Levels")
sig3 = input.float(3.0, "Sigma 3 level", minval = 0.5, step = 0.1, group = "Levels")

colNeutral = input.color(color.rgb(51, 51, 51),    "Neutral", group = "Colors")
colSig2    = input.color(color.rgb(110, 110, 110), "Sigma 2", group = "Colors")
colSig3    = input.color(color.rgb(255, 255, 255), "Sigma 3", group = "Colors")

setupNote = input.text_area("Move σ Stretch to the TOP of Object Tree,\nabove the main price series.\nOtherwise, chart candles can hide the heatmap.", "Chart setup (read-only)", group = "Important — visibility", display = display.none, active = false)

baseLen   = 50
minLen    = 15
maxLen    = 100
atrLen    = 14
atrAvgLen = 200

if sig3 <= sig2
    runtime.error("Sigma 3 level must be above Sigma 2 level.")
if minLen > maxLen
    runtime.error("Min length must not exceed Max length.")

// ── Stretch in sigmas ──────────────────────────────────────────────────────
// Until the ATR average is available the regime counts as normal (1.0).
f_sigma() =>
    atrNow = ta.atr(atrLen)
    regime = nz(atrNow / ta.sma(atrNow, atrAvgLen), 1.0)
    winLen = int(math.max(minLen, math.min(maxLen, math.round(baseLen / regime))))
    nz((ohlc4 - ta.sma(ohlc4, winLen)) / ta.stdev(ohlc4, winLen))

// Always computed on 24h (ETH), back-adjusted data, so switching the chart to
// RTH or toggling B-ADJ does not change the values.
ethTick = ticker.modify(syminfo.tickerid, session = session.extended, backadjustment = backadjustment.on)
sigma   = nz(request.security(ethTick, timeframe.period, f_sigma(), lookahead = barmerge.lookahead_off))
stretch = math.abs(sigma)

// Between the levels the colour only drifts 35 % of the way towards Sigma 3,
// so a full Sigma 3 bar is a clear step up rather than the end of a smooth fade.
SIG2_DRIFT = 0.35
mixCh(a, b) => a + (b - a) * SIG2_DRIFT
colSig2Top = color.rgb(mixCh(color.r(colSig2), color.r(colSig3)), mixCh(color.g(colSig2), color.g(colSig3)), mixCh(color.b(colSig2), color.b(colSig3)))

barCol = stretch >= sig3 ? colSig3 :
         stretch >= sig2 ? color.from_gradient(stretch, sig2, sig3, colSig2, colSig2Top) :
         colNeutral

plotcandle(open, high, low, close, "σ Candles", color = barCol, wickcolor = barCol, bordercolor = barCol, editable = false)

plot(sigma, "σ", display = display.data_window, editable = false)
// Setup: move Sigma Heatmap (σ Stretch) to the top of Object Tree, above the price series, so its candle colors remain visible.
````
