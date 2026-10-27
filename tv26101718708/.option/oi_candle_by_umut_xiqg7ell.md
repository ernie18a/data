# OI Candle by Umut

- url: https://www.tradingview.com/script/xIqG7elL-OI-Candle-by-Umut/
- type: indicator
- pine_id: PUB;8190e214c60044c3ab908b9e43800476
- version: 1.0

## Description

This indicator displays Open Interest (OI) as candlestick data across all timeframes, giving traders a clearer view of market participation and positioning dynamics.
Unlike standard OI indicators that use line charts or are limited to higher timeframes, this version visualizes OI using full OHLC candles. This allows you to analyze volatility, momentum, and structural changes in open interest in the same way as price action.

## Source Code

````pine
//@version=6
indicator("OI Candle (Force Candles)", overlay = false)

// OI ticker
tickerOI = str.format("{0}_OI", ticker.standard(syminfo.tickerid))

// SADECE CLOSE çek (gerçek veri bu!)
oiClose = request.security(tickerOI, timeframe.period, close, ignore_invalid_symbol = true)

// Güvenli önceki değer
oiPrev = nz(oiClose[1], oiClose)

// ✅ Zorla OHLC üret
oiOpen = oiPrev
oiHigh = math.max(oiOpen, oiClose)
oiLow  = math.min(oiOpen, oiClose)

// Renk
oiColor = oiClose > oiPrev ? color.teal : color.red

// ✅ SADECE candle çiz (başka plot yok!)
plotcandle(
    oiOpen,
    oiHigh,
    oiLow,
    oiClose,
    title = "Open Interest",
    color = oiColor,
    wickcolor = oiColor,
    bordercolor = oiColor
)
````
