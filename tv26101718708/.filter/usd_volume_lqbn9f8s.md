# USD Volume

- url: https://www.tradingview.com/script/LqbN9F8s-USD-Volume/
- type: indicator
- pine_id: PUB;4d4253cea23849649c96f83cf91b7e52
- version: 1.0

## Description

This is the VWAP used for xauusd with my trading style. 

Trust me it works and use this with liquidity. 

This is how institutions play and we ride on trends with them not against them or at worser entries.

Perfect for higher time frame as well.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © yturth

// This Pine Script™ indicator is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/

//@version=6
indicator('USD Volume', format=format.volume)

// ─── Generic USD Conversion ──────────────────────────────────────────────────
f_isUSD(string cur) =>
    cur == 'USD'  or cur == 'USDT' or cur == 'USDC' or cur == 'BUSD' or cur == 'DAI'  or cur == 'TUSD' or cur == 'FDUSD'

string quoteCur = syminfo.currency

// Crypto: try current exchange first, then Binance as fallback
string cryptoLocal    = syminfo.prefix + ':' + quoteCur + 'USDT'
float  cryptoLocalRate = request.security(cryptoLocal, timeframe.period, hl2, ignore_invalid_symbol=true)

string cryptoFallback     = 'BINANCE:' + quoteCur + 'USDT'
float  cryptoFallbackRate = request.security(cryptoFallback, timeframe.period, hl2, ignore_invalid_symbol=true)

// Forex
string forexTicker = 'FX_IDC:' + quoteCur + 'USD'
float  forexRate   = request.security(forexTicker, timeframe.period, hl2, ignore_invalid_symbol=true)

float quotePriceUSD = f_isUSD(quoteCur) ? 1.0 :
  not na(cryptoLocalRate)    ? cryptoLocalRate    :
  not na(cryptoFallbackRate) ? cryptoFallbackRate :
  not na(forexRate)          ? forexRate          :
  1.0

// ─── USD Volume ──────────────────────────────────────────────────────────────
float usdVolume = volume * hl2 * quotePriceUSD

color colorVolume = usdVolume > usdVolume[1] ? color.green : color.red

plot(usdVolume, color=colorVolume, style=plot.style_columns)
````
