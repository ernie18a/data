<!-- tradingview-pine-id: PUB;4e262d44b5cc408db872a87656cae970 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Daily BB (Historical Plotting with RTH/ETH/24H)

Source: https://www.tradingview.com/script/gCwZe6Vs-Daily-BB-Historical-Plotting-with-RTH-ETH-24H/

## Description

Daily BB (RTH/ETH/24H) projects Daily Bollinger Bands onto intraday charts using Regular Trading Hours (RTH) daily data as the underlying daily reference.

The script plots a projected Daily Bollinger Band basis together with projected upper and lower bands. By default, the basis uses a 20-day calculation and the bands use ±2 standard deviations. The length, standard-deviation multiplier, and band fill can be adjusted in the indicator settings.

Unlike a standard Bollinger Band calculated from the chart’s intraday bars, this indicator maintains a Daily calculation. Completed RTH daily closes provide the historical portion of the Daily window, while the current intraday price is used as the projected close for the unfinished Daily period. This allows the Daily basis and bands to update throughout the trading day rather than remaining fixed until the Daily candle closes.

The indicator is designed for use on intraday charts with TradingView’s RTH, ETH, or 24H session settings. Daily history is sourced from the symbol’s regular trading session, so overnight and extended-hours prices can update the projected Daily values without becoming separate completed Daily observations.

Daily rollover is based on the New York calendar date. On normal 24H weekdays, the projected Daily window advances at 00:00 ET. After a weekend, TradingView has no intervening Saturday bars and does not resume data until Sunday evening. Sunday 20:00 ET is therefore the first available Sunday candle, so the projection can reseed there using Friday’s completed RTH close. This does not create a Sunday RTH Daily candle. At Monday 00:00 ET, there may be no additional visible seed change because Sunday did not produce a completed RTH Daily candle.

At the first RTH bar, the script synchronizes the projection with the confirmed RTH Daily history. Higher-timeframe data requests are structured so unfinished Daily values are not inserted into earlier historical bars.

How to use it: The projected bands show where the Daily Bollinger Band would be if the current intraday price were the Daily close. They can therefore be used to view the developing Daily BB structure before the session has finished. The values remain projections until the applicable RTH Daily candle is complete.

This script uses the same RTH-based projected Daily framework as my Daily SMA indicator, but performs a distinct Bollinger Band calculation. In addition to the projected Daily mean, it calculates projected Daily variance and standard-deviation bands to produce the upper and lower envelope. This provides functionality beyond a moving-average variation and is intended for traders who want developing Daily Bollinger Band context visible directly on an intraday RTH, ETH, or 24H chart.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
//TradingView: tgunne

indicator("Daily BB (Historical Plotting with RTH/ETH/24H)", shorttitle="Daily BB (RTH/ETH/24H)", overlay=true)

length = input.int(20, "Length", minval=2)
mult = input.float(2.0, "StdDev", minval=0.001, maxval=50)
showFill = input.bool(true, "Show Fill")

// RTH detection
inRTH = session.ismarket

// RTH-only symbol (daily truth source)
symRTH = ticker.new(
     syminfo.prefix,
     syminfo.ticker,
     session=session.regular)

// True ET calendar-date detection.
ET_TZ = "America/New_York"

etDate =
     year(time, ET_TZ) * 10000 +
     month(time, ET_TZ) * 100 +
     dayofmonth(time, ET_TZ)

isNewETDay = bar_index > 0 and etDate != etDate[1]

// First available non-RTH candle of a new ET calendar date.
isNewCalendarDay =
     not inRTH and
     isNewETDay

// First RTH candle.
// Works across RTH, ETH, and 24H chart sessions.
isRTHOpen = session.isfirstbar_regular

// Pre-RTH/new-day seeds.
// These non-offset expressions use lookahead_off, so historical bars
// cannot receive the final value of an unfinished daily bar early.
// These values are used to reseed the projection only outside RTH.
getSeedsC0(_len) =>
    request.security(
         symRTH,
         "D",
         [
              math.sum(close, _len - 1),
              math.sum(close * close, _len - 1)
         ],
         lookahead=barmerge.lookahead_off)

// RTH-open seeds.
// These expressions are offset by one confirmed daily bar, so
// lookahead_on does not introduce historical lookahead bias.
getSeedsC1(_len) =>
    request.security(
         symRTH,
         "D",
         [
              math.sum(close[1], _len - 1),
              math.sum(close[1] * close[1], _len - 1)
         ],
         lookahead=barmerge.lookahead_on)

calcProjectedBB(_len, _mult) =>
    [sumC0, sumSqC0] = getSeedsC0(_len)
    [sumC1, sumSqC1] = getSeedsC1(_len)

    var float seedSum = na
    var float seedSq = na

    if bar_index == 0
        seedSum := inRTH ? sumC1 : sumC0
        seedSq := inRTH ? sumSqC1 : sumSqC0
    else if isNewCalendarDay
        seedSum := sumC0
        seedSq := sumSqC0
    else if isRTHOpen
        seedSum := sumC1
        seedSq := sumSqC1

    basis = not na(seedSum) ? (seedSum + close) / _len : na

    seedDev =
         not na(basis) and not na(seedSum) and not na(seedSq) ?
         seedSq - 2.0 * basis * seedSum + (_len - 1) * basis * basis :
         na

    liveDiff = not na(basis) ? close - basis : na
    liveDev = not na(liveDiff) ? liveDiff * liveDiff : na

    variance =
         not na(seedDev) and not na(liveDev) ?
         (seedDev + liveDev) / _len :
         na

    stdev = not na(variance) ? math.sqrt(math.max(variance, 0)) : na
    dev = _mult * stdev

    upper = basis + dev
    lower = basis - dev

    [basis, upper, lower]

[basis, upper, lower] = calcProjectedBB(length, mult)

plot(
     basis,
     color=color.new(#e91e63, 35),
     linewidth=2,
     title="Projected Daily BB Basis")

p1 = plot(
     upper,
     color=color.new(#2962ff, 35),
     linewidth=2,
     title="Projected Daily BB Upper")

p2 = plot(
     lower,
     color=color.new(#2962ff, 35),
     linewidth=2,
     title="Projected Daily BB Lower")

fill(
     p1,
     p2,
     title="Projected Daily BB Fill",
     color=showFill ? color.rgb(33, 150, 243, 95) : na)
````
