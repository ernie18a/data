# Hybrid Regression Screener 

- url: https://www.tradingview.com/script/pTEcCHHl/
- type: indicator
- pine_id: PUB;0c86aef9c53d4809b739c3c851b5e9cb
- version: 1.0

## Description

This script is a dedicated companion filter and multi-symbol screener designed to expand the capabilities of our core "Hybrid Regression & Dual PVT Flow" indicator system.

Instead of manually flipping through charts, this helper dashboard allows you to filter and monitor the real-time regression trends of 10 customizable assets simultaneously from a single screen.

📈 Key Filter Features:
10-Symbol Simultaneous Scanning: Runs background Linear Regression analysis for 10 user-defined symbols (Crypto, Stocks, or Forex) in real-time.

Trend Phase & Timing Indicator: Displays whether an asset is in a "Bullish" or "Bearish" cycle, while accurately calculating the exact number of bars passed since the bullish reversal.

Fresh Reversal Filtering: By checking the "Bars Ago" metric, you can easily filter out overextended moves and pinpoint assets that have just triggered a fresh trend shift aligned with your main trading strategy.

## Source Code

````pine
//@version=6
indicator("Hybrid Regression Screener (v6)", overlay=true)

// --- Girdiler (Inputs) ---
regLength = input.int(55, title="Regression Period (Length)", minval=5)

// --- Taratmak İstediğiniz Coin Listesi ---
s01 = input.symbol("BINANCE:BTCUSDT",  title="Symbol 1")
s02 = input.symbol("BINANCE:ETHUSDT",  title="Symbol 2")
s03 = input.symbol("BINANCE:BNBUSDT",  title="Symbol 3")
s04 = input.symbol("BINANCE:SOLUSDT",  title="Symbol 4")
s05 = input.symbol("BINANCE:XRPUSDT",  title="Symbol 5")
s06 = input.symbol("BINANCE:ADAUSDT",  title="Symbol 6")
s07 = input.symbol("BINANCE:AVAXUSDT", title="Symbol 7")
s08 = input.symbol("BINANCE:DOTUSDT",  title="Symbol 8")
s09 = input.symbol("BINANCE:LINKUSDT", title="Symbol 9")
s10 = input.symbol("BINANCE:DOGEUSDT", title="Symbol 10")

// --- Regresyon ve Yeşil Dönüş Hesaplamaları (Global Alanda) ---
// Pine Script'in geçmiş verileri doğru sayması için hesaplamaları global seriler olarak yapıyoruz.
rc = ta.linreg(close, regLength, 0)
isBullish = rc > rc[1]
barsSinceGreen = ta.barssince(isBullish and not isBullish[1])

// --- Verileri Diğer Sembollerden Güvenli Çekme ---
// request.security içinde direkt global serileri çağırıyoruz
[b01, bars01] = request.security(s01, timeframe.period, [isBullish, barsSinceGreen])
[b02, bars02] = request.security(s02, timeframe.period, [isBullish, barsSinceGreen])
[b03, bars03] = request.security(s03, timeframe.period, [isBullish, barsSinceGreen])
[b04, bars04] = request.security(s04, timeframe.period, [isBullish, barsSinceGreen])
[b05, bars05] = request.security(s05, timeframe.period, [isBullish, barsSinceGreen])
[b06, bars06] = request.security(s06, timeframe.period, [isBullish, barsSinceGreen])
[b07, bars07] = request.security(s07, timeframe.period, [isBullish, barsSinceGreen])
[b08, bars08] = request.security(s08, timeframe.period, [isBullish, barsSinceGreen])
[b09, bars09] = request.security(s09, timeframe.period, [isBullish, barsSinceGreen])
[b10, bars10] = request.security(s10, timeframe.period, [isBullish, barsSinceGreen])

// --- Hücre Çizim Yardımcı Fonksiyonu ---
drawRow(table tab, int row, string symName, bool isBull, int barsAgo) =>
    // İç içe str.replace_all kullanarak v6'daki reassignment hatasını önlüyoruz.
    cleanName = str.replace_all(str.replace_all(symName, "BINANCE:", ""), "USDT", "")
    
    table.cell(tab, 0, row, cleanName, text_color=color.white, text_size=size.small)
    
    if isBull
        msg = "BULLISH (Green) - " + str.tostring(barsAgo) + " bars ago"
        table.cell(tab, 1, row, msg, bgcolor=color.new(color.green, 20), text_color=color.white, text_size=size.small)
    else
        table.cell(tab, 1, row, "BEARISH (Red)", bgcolor=color.new(color.red, 20), text_color=color.white, text_size=size.small)

// =========================================================================
// --- SCREENER DASHBOARD ÇİZİMİ (SAĞ ALT KÖŞE) ---
// =========================================================================
var table screenerTable = table.new(position = position.bottom_right, columns = 2, rows = 11, bgcolor = color.new(color.black, 15), border_width = 1, border_color = color.gray)

if barstate.islast
    // Başlıklar
    table.cell(screenerTable, 0, 0, "COIN", bgcolor=color.purple, text_color=color.white, text_size=size.small)
    table.cell(screenerTable, 1, 0, "REGRESSION STATUS / AGE", bgcolor=color.purple, text_color=color.white, text_size=size.small)
    
    // Satırları Doldurma
    drawRow(screenerTable, 1, s01, b01, bars01)
    drawRow(screenerTable, 2, s02, b02, bars02)
    drawRow(screenerTable, 3, s03, b03, bars03)
    drawRow(screenerTable, 4, s04, b04, bars04)
    drawRow(screenerTable, 5, s05, b05, bars05)
    drawRow(screenerTable, 6, s06, b06, bars06)
    drawRow(screenerTable, 7, s07, b07, bars07)
    drawRow(screenerTable, 8, s08, b08, bars08)
    drawRow(screenerTable, 9, s09, b09, bars09)
    drawRow(screenerTable, 10, s10, b10, bars10)
````
