# ATR Trade Assistant

- url: https://www.tradingview.com/script/huh3dlpu-ATR-Trade-Assistant/
- type: indicator
- pine_id: PUB;acad95521993492f9dc599af492be1ef
- version: 2.0

## Description

A simple assistant that quickly calculates position size for those who use ATR money management rules.

## Source Code

````pine
// ShawJT

//@version=6
indicator('ATR Trade Assistant', overlay = true, dynamic_requests = true)

// =========================
// Inputs
// =========================
atrLen = input.int(14, 'ATR Length', minval = 1)
slMult = input.float(1.5, 'Stop Loss ATR Multiplier', minval = 0.01, step = 0.1)
tpMult = input.float(1.0, 'Take Profit ATR Multiplier', minval = 0.01, step = 0.1)
usePrevATR = input.bool(true, 'Use Previous Closed Candle (Prev Close). Uncheck for Live/current candle.')

accountSize = input.float(115000, 'Account Size', minval = 0, step = 100)

riskPct = input.float(1.0, 'Risk %', minval = 0.01, step = 0.01)

fxSource = input.string('OANDA', 'FX Conversion Source')

manualQuoteToUsd = input.float(0.0, 'Manual Quote-to-USD Override', minval = 0.0, tooltip = 'Use 0 for automatic conversion. ' + 'Example: for JPY/USD, enter 0.00625 if USDJPY is near 160.')

// =========================
// ATR + Entry reference
// =========================
// Both ATR and entry price are driven off the same toggle so they
// always describe the SAME point in time:
//   usePrevATR = true  -> filled at prior candle's close (planned entry)
//   usePrevATR = false -> entering now, at the live/current candle
atrRaw = ta.atr(atrLen)

atr = usePrevATR ? atrRaw[1] : atrRaw

entryRef = usePrevATR ? close[1] : close

// =========================
// Stop-loss and take-profit
// distances
// =========================
slDistance = atr * slMult
tpDistance = atr * tpMult

// Long levels
longSL = entryRef - slDistance
longTP = entryRef + tpDistance

// Short levels
shortSL = entryRef + slDistance
shortTP = entryRef - tpDistance

// =========================
// Symbol currency detection
// =========================
baseCur = syminfo.basecurrency
quoteCur = syminfo.currency

// Examples:
// BTCUSDT -> base BTC, quote USDT
// EURUSD  -> base EUR, quote USD
// NZDJPY  -> base NZD, quote JPY
// EURNZD  -> base EUR, quote NZD

// =========================
// USD-equivalent quote
// currencies
// =========================
// Treat common USD stablecoins as approximately $1.
// This allows BTCUSDT and similar pairs to size correctly.
isUsdEquivalent = quoteCur == 'USD' or quoteCur == 'USDT' or quoteCur == 'USDC' or quoteCur == 'BUSD' or quoteCur == 'FDUSD' or quoteCur == 'TUSD' or quoteCur == 'DAI' or quoteCur == 'USDCE' or quoteCur == 'USDP'

// =========================
// Quote currency to USD
// conversion
// =========================
// Forex and spot P&L are generally created in
// the quote currency.
//
// Examples:
// USD/USDT/USDC -> 1.0
// JPY -> JPYUSD or inverse USDJPY
// NZD -> NZDUSD
// CAD -> CADUSD or inverse USDCAD

directSymbol = fxSource + ':' + quoteCur + 'USD'

inverseSymbol = fxSource + ':USD' + quoteCur

directRate = request.security(directSymbol, timeframe.period, close, ignore_invalid_symbol = true)

inverseRate = request.security(inverseSymbol, timeframe.period, close, ignore_invalid_symbol = true)

autoQuoteToUsd = isUsdEquivalent ? 1.0 : not na(directRate) ? directRate : not na(inverseRate) and inverseRate != 0 ? 1.0 / inverseRate : na

quoteToUsd = manualQuoteToUsd > 0 ? manualQuoteToUsd : autoQuoteToUsd

// =========================
// Risk calculations
// =========================
riskUSD = accountSize * (riskPct / 100.0)

// Formula:
//
// USD risk = trade size × stop distance × quote-to-USD
//
// Therefore:
//
// trade size = USD risk /
//              (stop distance × quote-to-USD)
//
// For BTCUSDT:
//
// trade size = $1,150 / ATR stop distance
//
// The result is the number of BTC to buy or short.
tradeSize = slDistance > 0 and not na(quoteToUsd) and quoteToUsd > 0 ? riskUSD / (slDistance * quoteToUsd) : na

// =========================
// Notional position value
// =========================
tradeValueQuote = tradeSize * entryRef

tradeValueUSD = tradeValueQuote * quoteToUsd

// =========================
// Estimated P&L verification
// =========================
// These values should approximately equal the selected
// dollar risk and reward amounts.
estimatedLossUSD = tradeSize * slDistance * quoteToUsd

estimatedProfitUSD = tradeSize * tpDistance * quoteToUsd

rewardRiskRatio = slDistance > 0 ? tpDistance / slDistance : na

// =========================
// Display formatting
// =========================
modeText = usePrevATR ? 'Prev Close' : 'Live'

tradeSizeText = na(tradeSize) ? 'N/A' : str.tostring(tradeSize, '#.########')

quoteToUsdText = na(quoteToUsd) ? 'N/A' : str.tostring(quoteToUsd, '#.#####')

notionalText = na(tradeValueUSD) ? 'N/A' : '$' + str.tostring(tradeValueUSD, '#,###.##')

estimatedLossText = na(estimatedLossUSD) ? 'N/A' : '$' + str.tostring(estimatedLossUSD, '#,###.##')

estimatedProfitText = na(estimatedProfitUSD) ? 'N/A' : '$' + str.tostring(estimatedProfitUSD, '#,###.##')

rrText = na(rewardRiskRatio) ? 'N/A' : str.tostring(rewardRiskRatio, '#.##') + 'R'

longLevelsText = 'TP ' + str.tostring(longTP, format.mintick) + '   SL ' + str.tostring(longSL, format.mintick)

shortLevelsText = 'TP ' + str.tostring(shortTP, format.mintick) + '   SL ' + str.tostring(shortSL, format.mintick)

// =========================
// Table color palette
// =========================
colBg = color.new(#131722, 0) // base panel background (dark slate, not pure black)
colHeaderBg = color.new(#1e2230, 0) // section header background
colTitleBg = color.new(#2962ff, 0) // title strip accent
colBorder = color.new(#2a2e39, 0)

colLabel = color.new(#9598a1, 0) // muted gray for labels
colValue = color.new(#d1d4dc, 0) // near-white for primary values
colLong = color.new(#26a69a, 0) // teal/green for long & profit
colShort = color.new(#ef5350, 0) // red for short & loss
colAccent = color.new(#2962ff, 0) // blue accent for mode/ATR

// =========================
// Table
// =========================
var table atrTable = table.new(position.top_right, 2, 11, border_width = 1, border_color = colBorder, frame_width = 1, frame_color = colBorder)

if barstate.islast

    // ---- Title bar ----
    table.cell(atrTable, 0, 0, 'ATR TRADE ASSISTANT', text_color = color.white, bgcolor = colTitleBg, text_size = size.small, text_halign = text.align_left)
    table.cell(atrTable, 1, 0, modeText, text_color = color.white, bgcolor = colTitleBg, text_size = size.small, text_halign = text.align_right)

    // ---- ATR row ----
    table.cell(atrTable, 0, 1, 'ATR (' + str.tostring(atrLen) + ')', text_color = colLabel, bgcolor = colBg, text_halign = text.align_left)
    table.cell(atrTable, 1, 1, str.tostring(atr, format.mintick), text_color = colAccent, bgcolor = colBg, text_halign = text.align_right)

    // ---- LEVELS section header ----
    table.cell(atrTable, 0, 2, 'LEVELS', text_color = colLabel, bgcolor = colHeaderBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(atrTable, 1, 2, '', bgcolor = colHeaderBg)

    table.cell(atrTable, 0, 3, 'LONG', text_color = colLong, bgcolor = colBg, text_halign = text.align_left)
    table.cell(atrTable, 1, 3, longLevelsText, text_color = colLong, bgcolor = colBg, text_halign = text.align_right)

    table.cell(atrTable, 0, 4, 'SHORT', text_color = colShort, bgcolor = colBg, text_halign = text.align_left)
    table.cell(atrTable, 1, 4, shortLevelsText, text_color = colShort, bgcolor = colBg, text_halign = text.align_right)

    // ---- SIZING section header ----
    table.cell(atrTable, 0, 5, 'SIZING', text_color = colLabel, bgcolor = colHeaderBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(atrTable, 1, 5, '', bgcolor = colHeaderBg)

    table.cell(atrTable, 0, 6, 'Risk', text_color = colLabel, bgcolor = colBg, text_halign = text.align_left)
    table.cell(atrTable, 1, 6, '$' + str.tostring(riskUSD, '#,###.##') + '  (' + str.tostring(riskPct, '#.##') + '%)', text_color = colValue, bgcolor = colBg, text_halign = text.align_right)

    table.cell(atrTable, 0, 7, 'Trade Size', text_color = colLabel, bgcolor = colBg, text_halign = text.align_left)
    table.cell(atrTable, 1, 7, tradeSizeText + ' ' + baseCur, text_color = colValue, bgcolor = colBg, text_halign = text.align_right)

    table.cell(atrTable, 0, 8, 'Notional', text_color = colLabel, bgcolor = colBg, text_halign = text.align_left)
    table.cell(atrTable, 1, 8, notionalText, text_color = colValue, bgcolor = colBg, text_halign = text.align_right)

    // ---- VERIFICATION section header ----
    table.cell(atrTable, 0, 9, 'VERIFY', text_color = colLabel, bgcolor = colHeaderBg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(atrTable, 1, 9, '', bgcolor = colHeaderBg)

    table.cell(atrTable, 0, 10, 'Loss / Profit', text_color = colLabel, bgcolor = colBg, text_halign = text.align_left)
    table.cell(atrTable, 1, 10, estimatedLossText + '  /  ' + estimatedProfitText + ' (' + rrText + ')', text_color = colValue, bgcolor = colBg, text_halign = text.align_right)
````
