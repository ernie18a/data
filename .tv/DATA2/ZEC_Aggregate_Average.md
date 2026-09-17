<!-- tradingview-pine-id: PUB;b2fb261f60d2423bad8127b3c6a5d5c7 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# ZEC Aggregate Average

Source: https://www.tradingview.com/script/KoO5DoNX-ZEC-Aggregate-Average/

## Description

**ZEC Aggregate Average** is a multi-exchange price aggregation indicator designed to provide a broader view of Zcash (ZEC) market pricing across multiple cryptocurrency exchanges.

Instead of relying on the price from a single exchange, the indicator pulls ZEC price and volume data from a range of major exchanges and calculates two separate aggregate prices:

### Equal-Weight Average

The **Equal-weight avg** calculates the simple average of all available ZEC prices across the supported exchanges.

Each exchange contributes equally to the calculation, regardless of its trading volume. If an exchange's symbol is unavailable or does not return a valid price, that exchange is automatically excluded from the calculation.

This provides a straightforward representation of the average ZEC price across the available markets.

### Volume-Weighted Average

The **Volume-weight avg** calculates a volume-weighted average price using the available exchange prices and their corresponding trading volumes.

Exchanges with greater reported volume therefore have a greater influence on the resulting aggregate price, while exchanges with lower volume have less influence.

Only valid prices with positive volume are included in the volume-weighted calculation.

### Supported Exchanges

The indicator currently aggregates data from:

* Binance
* Coinbase
* Bybit
* OKX
* Bitget
* Gate.io
* MEXC
* KuCoin
* HTX
* Kraken
* Crypto.com
* Bitstamp
* Bitfinex
* Gemini

The indicator automatically handles unavailable symbols, allowing the calculation to continue using the exchanges that are providing valid data.

### How It Can Be Used

ZEC Aggregate Average can be used as a reference for evaluating ZEC's broader market price rather than relying exclusively on a single exchange.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tyjkot

// Updated description

//@version=6
indicator("ZEC Aggregate Average", overlay=true, precision=2)

string tf = timeframe.period

[pBinance, vBinance]   = request.security("BINANCE:ZECUSDT",   tf, [close, volume], ignore_invalid_symbol=true)
[pCoinbase, vCoinbase] = request.security("COINBASE:ZECUSD",   tf, [close, volume], ignore_invalid_symbol=true)
[pBybit, vBybit]       = request.security("BYBIT:ZECUSDT",     tf, [close, volume], ignore_invalid_symbol=true)
[pOkx, vOkx]           = request.security("OKX:ZECUSDT",       tf, [close, volume], ignore_invalid_symbol=true)
[pBitget, vBitget]     = request.security("BITGET:ZECUSDT",    tf, [close, volume], ignore_invalid_symbol=true)
[pGate, vGate]         = request.security("GATEIO:ZECUSDT",    tf, [close, volume], ignore_invalid_symbol=true)
[pMexc, vMexc]         = request.security("MEXC:ZECUSDT",      tf, [close, volume], ignore_invalid_symbol=true)
[pKucoin, vKucoin]     = request.security("KUCOIN:ZECUSDT",    tf, [close, volume], ignore_invalid_symbol=true)
[pHtx, vHtx]           = request.security("HTX:ZECUSDT",       tf, [close, volume], ignore_invalid_symbol=true)
[pKraken, vKraken]     = request.security("KRAKEN:ZECUSD",     tf, [close, volume], ignore_invalid_symbol=true)
[pCro, vCro]           = request.security("CRYPTOCOM:ZECUSD",  tf, [close, volume], ignore_invalid_symbol=true)
[pStamp, vStamp]       = request.security("BITSTAMP:ZECUSD",   tf, [close, volume], ignore_invalid_symbol=true)
[pFinex, vFinex]       = request.security("BITFINEX:ZECUSD",   tf, [close, volume], ignore_invalid_symbol=true)
[pGemini, vGemini]     = request.security("GEMINI:ZECUSD",     tf, [close, volume], ignore_invalid_symbol=true)

float eqSum = 0.0
int n = 0
if not na(pBinance)
    eqSum += pBinance
    n += 1
if not na(pCoinbase)
    eqSum += pCoinbase
    n += 1
if not na(pBybit)
    eqSum += pBybit
    n += 1
if not na(pOkx)
    eqSum += pOkx
    n += 1
if not na(pBitget)
    eqSum += pBitget
    n += 1
if not na(pGate)
    eqSum += pGate
    n += 1
if not na(pMexc)
    eqSum += pMexc
    n += 1
if not na(pKucoin)
    eqSum += pKucoin
    n += 1
if not na(pHtx)
    eqSum += pHtx
    n += 1
if not na(pKraken)
    eqSum += pKraken
    n += 1
if not na(pCro)
    eqSum += pCro
    n += 1
if not na(pStamp)
    eqSum += pStamp
    n += 1
if not na(pFinex)
    eqSum += pFinex
    n += 1
if not na(pGemini)
    eqSum += pGemini
    n += 1
float eqAvg = n > 0 ? eqSum / n : na

float vwNum = 0.0
float vwDen = 0.0
if not na(pBinance) and not na(vBinance) and vBinance > 0
    vwNum += pBinance * vBinance
    vwDen += vBinance
if not na(pCoinbase) and not na(vCoinbase) and vCoinbase > 0
    vwNum += pCoinbase * vCoinbase
    vwDen += vCoinbase
if not na(pBybit) and not na(vBybit) and vBybit > 0
    vwNum += pBybit * vBybit
    vwDen += vBybit
if not na(pOkx) and not na(vOkx) and vOkx > 0
    vwNum += pOkx * vOkx
    vwDen += vOkx
if not na(pBitget) and not na(vBitget) and vBitget > 0
    vwNum += pBitget * vBitget
    vwDen += vBitget
if not na(pGate) and not na(vGate) and vGate > 0
    vwNum += pGate * vGate
    vwDen += vGate
if not na(pMexc) and not na(vMexc) and vMexc > 0
    vwNum += pMexc * vMexc
    vwDen += vMexc
if not na(pKucoin) and not na(vKucoin) and vKucoin > 0
    vwNum += pKucoin * vKucoin
    vwDen += vKucoin
if not na(pHtx) and not na(vHtx) and vHtx > 0
    vwNum += pHtx * vHtx
    vwDen += vHtx
if not na(pKraken) and not na(vKraken) and vKraken > 0
    vwNum += pKraken * vKraken
    vwDen += vKraken
if not na(pCro) and not na(vCro) and vCro > 0
    vwNum += pCro * vCro
    vwDen += vCro
if not na(pStamp) and not na(vStamp) and vStamp > 0
    vwNum += pStamp * vStamp
    vwDen += vStamp
if not na(pFinex) and not na(vFinex) and vFinex > 0
    vwNum += pFinex * vFinex
    vwDen += vFinex
if not na(pGemini) and not na(vGemini) and vGemini > 0
    vwNum += pGemini * vGemini
    vwDen += vGemini
float vwAvg = vwDen > 0 ? vwNum / vwDen : na

plot(eqAvg, "Equal-weight avg", color.new(color.green, 0), 1)
plot(vwAvg, "Volume-weight avg", color.new(color.teal, 0), 2)

cellTxt(float px) =>
    na(px) ? "—" : str.tostring(px, format.mintick)

cellVol(float vol) =>
    na(vol) ? "—" : str.tostring(vol, format.volume)

// var table t = table.new(position.top_right, 3, 16, bgcolor=color.new(#363a45, 51))
// if barstate.islast
//     table.cell(t, 0, 0, "Venue", text_color=color.gray)
//     table.cell(t, 1, 0, "Price", text_color=color.gray)
//     table.cell(t, 2, 0, "Vol", text_color=color.gray)

//     table.cell(t, 0, 1, "Binance", text_color=color.white)
//     table.cell(t, 1, 1, cellTxt(pBinance), text_color=color.white)
//     table.cell(t, 2, 1, cellVol(vBinance), text_color=color.white)

//     table.cell(t, 0, 2, "Coinbase", text_color=color.white)
//     table.cell(t, 1, 2, cellTxt(pCoinbase), text_color=color.white)
//     table.cell(t, 2, 2, cellVol(vCoinbase), text_color=color.white)

//     table.cell(t, 0, 3, "Bybit", text_color=color.white)
//     table.cell(t, 1, 3, cellTxt(pBybit), text_color=color.white)
//     table.cell(t, 2, 3, cellVol(vBybit), text_color=color.white)

//     table.cell(t, 0, 4, "OKX", text_color=color.white)
//     table.cell(t, 1, 4, cellTxt(pOkx), text_color=color.white)
//     table.cell(t, 2, 4, cellVol(vOkx), text_color=color.white)

//     table.cell(t, 0, 5, "Bitget", text_color=color.white)
//     table.cell(t, 1, 5, cellTxt(pBitget), text_color=color.white)
//     table.cell(t, 2, 5, cellVol(vBitget), text_color=color.white)

//     table.cell(t, 0, 6, "Gate", text_color=color.white)
//     table.cell(t, 1, 6, cellTxt(pGate), text_color=color.white)
//     table.cell(t, 2, 6, cellVol(vGate), text_color=color.white)

//     table.cell(t, 0, 7, "MEXC", text_color=color.white)
//     table.cell(t, 1, 7, cellTxt(pMexc), text_color=color.white)
//     table.cell(t, 2, 7, cellVol(vMexc), text_color=color.white)

//     table.cell(t, 0, 8, "KuCoin", text_color=color.white)
//     table.cell(t, 1, 8, cellTxt(pKucoin), text_color=color.white)
//     table.cell(t, 2, 8, cellVol(vKucoin), text_color=color.white)

//     table.cell(t, 0, 9, "HTX", text_color=color.white)
//     table.cell(t, 1, 9, cellTxt(pHtx), text_color=color.white)
//     table.cell(t, 2, 9, cellVol(vHtx), text_color=color.white)

//     table.cell(t, 0, 10, "Kraken", text_color=color.white)
//     table.cell(t, 1, 10, cellTxt(pKraken), text_color=color.white)
//     table.cell(t, 2, 10, cellVol(vKraken), text_color=color.white)

//     table.cell(t, 0, 11, "Crypto.com", text_color=color.white)
//     table.cell(t, 1, 11, cellTxt(pCro), text_color=color.white)
//     table.cell(t, 2, 11, cellVol(vCro), text_color=color.white)

//     table.cell(t, 0, 12, "Bitstamp", text_color=color.white)
//     table.cell(t, 1, 12, cellTxt(pStamp), text_color=color.white)
//     table.cell(t, 2, 12, cellVol(vStamp), text_color=color.white)

//     table.cell(t, 0, 13, "Bitfinex", text_color=color.white)
//     table.cell(t, 1, 13, cellTxt(pFinex), text_color=color.white)
//     table.cell(t, 2, 13, cellVol(vFinex), text_color=color.white)

//     table.cell(t, 0, 14, "Gemini", text_color=color.white)
//     table.cell(t, 1, 14, cellTxt(pGemini), text_color=color.white)
//     table.cell(t, 2, 14, cellVol(vGemini), text_color=color.white)

//     table.cell(t, 0, 15, "Feeds", text_color=color.aqua)
//     table.cell(t, 1, 15, str.tostring(n), text_color=color.aqua)
//     table.cell(t, 2, 15, "", text_color=color.aqua)
````
