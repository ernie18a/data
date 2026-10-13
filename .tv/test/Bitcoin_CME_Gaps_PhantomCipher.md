<!-- tradingview-pine-id: PUB;5efdf9943e844032810bfda2f038d5c6 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Bitcoin CME Gaps [PhantomCipher]

Source: https://www.tradingview.com/script/Ef0OMyFT-Bitcoin-CME-Gaps-PhantomCipher/

## Description

Bitcoin CME Gaps

Bitcoin trades around the clock, but CME Bitcoin futures stop trading over the weekend. When CME reopens, its chart often opens away from Friday's close, leaving a "CME gap". This indicator draws the CME closing level on your Bitcoin chart for the whole weekend, so you can see how far price has moved from it while CME is closed.

SNAPSHOT: a 15m Bitcoin chart over one weekend, with the blue CME line and the shading between it and price

Recommended timeframe: 15 minutes
The weekend window is worked out from each candle's opening time, so the line needs candles small enough to start when CME closes and end when it reopens. The 15-minute chart is what this indicator is designed and tested for.

How it works

[*]Weekend window: from Friday 21:00 UTC to Sunday 22:00 UTC. That matches CME Bitcoin futures hours while US daylight saving time is in effect. In winter, CME closes and reopens one hour later.
[*]CME line: a blue line at the price where the weekend began. It's drawn only during the weekend and stops when CME reopens.
[*]Shading: the area between the line and price is green while price is above the line and pink while it's below, so you can see the direction of the gap as it forms.

The weekend window check, with the day and hour in the chart's timezone (UTC for crypto):
[pine]
(hour >= 21 and dayofweek == 6) or (dayofweek == 7) or (hour < 22 and dayofweek == 1)
[/pine]

SNAPSHOT: close-up of Sunday's reopen, with the line ending where CME resumes trading

Settings

[*][On]Chart Price | [Off] CME Price: on by default, and the line uses your chart's own price at the start of the weekend. Turn it off to use CME:BTC1!'s last price instead, which can differ from spot or perpetual prices.
[*]Only Show Weekend Gaps: on by default, and the line appears only in the weekend window above. Turn it off to draw a line whenever CME:BTC1! has no candle, which also covers CME's daily one-hour break and exchange holidays, at the cost of a busier chart.
[*]Show +/-1% From Close: off by default. Adds yellow lines 1% above and 1% below the CME line.

Limitations

[*]With "Only Show Weekend Gaps" on, lines appear only on crypto charts, index charts and charts in the UTC timezone.
[*]The weekend window uses fixed UTC hours, so in winter it starts and ends one hour before CME's actual close and reopen.
[*]The line marks the level while CME is closed. It does not keep drawing gaps that are still unfilled after CME reopens.

Example chart: [symbol="BYBIT:BTCUSDT.P"]BYBIT:BTCUSDT.P[/symbol]

This indicator marks where CME closed. It's not a trading signal on its own, and a gap is not guaranteed to fill, so combine it with your own analysis and risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © phantomcipher

//@version=6
indicator("Bitcoin CME Gaps [PhantomCipher]", shorttitle="Bitcoin CME Gaps [PhantomCipher]", overlay=true, format=format.price, precision=0)

showReal  = input.bool(true,  "[On]Chart Price | [Off] CME Price")
showClean = input.bool(true,  "Only Show Weekend Gaps (Cleaner But Misses Holidays/Etc.)")
hi_chews  = input.bool(false, "Show +/-1% From Close")

not_in_sess = na(request.security("CME:BTC1!", timeframe.period, close, gaps=barmerge.gaps_on))
in_sess     = request.security("CME:BTC1!", timeframe.period, close, gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

only_wkend = (syminfo.timezone == "Etc/UTC" or syminfo.type == "crypto" or syminfo.type == "index") and
             ((hour >= 21 and dayofweek == dayofweek.friday) or dayofweek == dayofweek.saturday or (hour < 22 and dayofweek == dayofweek.sunday))

derty = showClean ? only_wkend : not_in_sess

// Capture price exactly once at the start of each gap window - prevents
// CME artifact candles from resetting the reference line mid-gap
gap_start  = derty and not derty[1]
cmePrice   = ta.valuewhen(gap_start, in_sess, 0)
chartPrice = ta.valuewhen(gap_start, close, 0)
price      = showReal ? chartPrice : cmePrice

blue  = #077EFB
pink  = #F8BBD0
green = #4CAF50
peach = #FFD831

a = plot(derty ? price : na, "CME Gap", blue, 2, plot.style_linebr)
b = plot(derty ? hlc3 : na, " ", color.new(blue, 100), 1, plot.style_linebr, display=display.none, editable=false)

plot(derty and hi_chews ? price * 1.01 : na, "+1%", peach, 2, plot.style_linebr)
plot(derty and hi_chews ? price * 0.99 : na, "-1%", peach, 2, plot.style_linebr)

// v4's fill() took transparency as its own argument; v6 carries it in the colour
fill(a, b, close > price ? color.new(green, 70) : color.new(pink, 70))
````
