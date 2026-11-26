# Bitcoin CME Gaps [Andrea]

- url: https://www.tradingview.com/script/yHE9Enbe/
- type: indicator
- pine_id: PUB;98d2a64d04ac44728aeda7d7e75a4d2e
- version: 1.0

## Description

GAP CME ANALISI -Bitcoin CME Gaps [Andrea]-Bitcoin CME Gaps [Andrea]-Bitcoin CME Gaps [Andrea]Bitcoin CME Gaps [Andrea]Bitcoin CME Gaps [Andrea]

## Source Code

````pine
//@version=5
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Andrea Bigarani

title = 'Bitcoin CME Gaps [Andrea]'
stitle = 'Bitcoin CME Gaps [Andrea]'

indicator(title, stitle, 1, format.price, 0)

showReal = input(true, '[On]Chart Price | [Off] CME Price')
showClean = input(false, 'Only Show Weekend Gaps (Cleaner But Misses Holidays/Etc.)')
hi_chews = input(false, 'Show +/-1% From Close')

not_in_sess = na(request.security('CME:BTC1!', timeframe.period, close, gaps=barmerge.gaps_on))
in_sess = request.security('CME:BTC1!', timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

cmePrice = ta.valuewhen(not_in_sess, in_sess, 0)
chartPrice = ta.valuewhen(not_in_sess and ta.change(cmePrice), open, 0)
price = showReal ? chartPrice : cmePrice


// Only plot it when CME futures are not in session over the weekend and the current chart uses UTC.
// Does not account for trading breaks during the weekdays, even if they are caused by hitting the limit breaker or holidays
only_wkend = (syminfo.timezone == 'Etc/UTC' or syminfo.type == 'crypto' or syminfo.type == 'index') and (hour >= 21 and dayofweek == 6 or dayofweek == 7 or hour < 22 and dayofweek == 1) ? true : false

derty = showClean ? only_wkend : not_in_sess ? true : false

Gray = #708090
Gray_ = #708090
Gray__ = #708090
Gray___ = #708090


a = plot(derty ? price : na, 'CME Gap', color.new(Gray, 0), 2, plot.style_linebr)
b = plot(derty ? hlc3 : na, ' ', color.new(Gray, 100), 1, plot.style_linebr, display=display.none, editable=false)

plot(derty and hi_chews ? price * 1.01 : na, '+1%', color.new(Gray, 0), 2, plot.style_linebr)
plot(derty and hi_chews ? price * 0.99 : na, '-1%', color.new(Gray, 0), 2, plot.style_linebr)

fill(a, b, close > price ? Gray : Gray, transp=70)
````
