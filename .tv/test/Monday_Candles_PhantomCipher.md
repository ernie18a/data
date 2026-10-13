<!-- tradingview-pine-id: PUB;f0ac283125ab4449abf03d5c9d09f060 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Monday Candles [PhantomCipher]

Source: https://www.tradingview.com/script/89Ekr8n1-Monday-Candles-PhantomCipher/

## Description

Monday Candles

Monday Candles colours every candle that opens on a Monday, so the start of each trading week is easy to spot. Many traders mark Monday's range and watch how price reacts to it through the rest of the week.

SNAPSHOT: the indicator on a clean daily chart, with several Mondays highlighted

How it works

[*]Spot and perpetual markets: a candle is highlighted when it opens on a Monday in UTC.
[*]Futures: a candle is highlighted when it opens on a Sunday in UTC. Futures sessions open on Sunday evening, and that session belongs to Monday's trading day.
[*]Timeframes: on the daily chart the Monday candle is highlighted. On intraday charts every candle that opens during Monday (UTC) is highlighted, so the whole day stands out.

The check for a spot or perpetual chart is:
[pine]
dayofweek(time, 'UTC') == dayofweek.monday
[/pine]

SNAPSHOT: an intraday chart (for example 1h) showing the full Monday session highlighted

Settings

[*]Highlight Monday? Turns the highlighting on or off.
[*]Highlight Color: the colour used for Monday candles (yellow by default).

Limitations
The day is always worked out in UTC. On markets with their own session times, such as gold (XAUUSD), silver (XAGUSD), some other commodities and some forex pairs, the highlighted candles may not line up with the market's actual Monday. The indicator is also not meant for weekly or higher timeframes, where one candle covers the whole week.

Example chart: [symbol="BYBIT:BTCUSDT.P"]BYBIT:BTCUSDT.P[/symbol]

This indicator marks days of the week. It's not a trading signal on its own, so combine it with your own analysis and risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © phantomcipher
//
// NOTE: This indicator might not work properly with gold (XAUUSD), silver (XAGUSD),
// and some other commodity or forex tickers due to timezone and trading session differences.
//
// Best viewed on the daily chart, where each week's Monday is a single highlighted candle.

//@version=6
indicator(shorttitle="Monday Candles [PhantomCipher]", title="Monday Candles [PhantomCipher]", overlay=true)

disMon = input.bool(true, title="Highlight Monday?")

// Detect if instrument is a futures/derivatives contract
// Futures tickers typically contain "!" or have continuous contract notation
isFutures = str.contains(syminfo.ticker, "!") or str.contains(syminfo.ticker, "1!") or syminfo.type == "futures"

// For futures, check for Sunday (which displays as Monday)
// For spot, check for Monday normally
isMon() => 
    if isFutures
        dayofweek(time, 'UTC') == dayofweek.sunday
    else
        dayofweek(time, 'UTC') == dayofweek.monday

monColor = input.color(#ffeb3b, title="Highlight Color")

barcolor(disMon and isMon() ? monColor : na)
````
