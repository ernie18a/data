<!-- tradingview-pine-id: PUB;19865461c5074149a8738902667bf47f -->
<!-- tradingviewscripts-format: 1 -->
# Rainbow Regime

Source: https://www.tradingview.com/script/2xnT2tgr-Rainbow-Regime/

## Description

This is a companion to the Rainbow Yearly SMAs indicator. It takes the whole rainbow (the 200 day plus the 1 through 10 year simple moving averages) and turns it into one bottom pane readout with three modes you can switch between in settings.

Regime Score counts how many of the 11 SMAs price is above, from 0 to 11. Green columns at the top mean price is riding above the entire rainbow. Red at the bottom means price has dropped below everything, which has historically only happened near major bottoms. The interesting part is watching the score stair-step through the middle. That's the regime actually changing, not just a dip.

Stretch % shows how far price is from whichever SMA you pick, as a percentage. Teal when above, red when below. Set it to the 1 year and scroll back through history. The big spikes line up with cycle tops and the deep red troughs line up with bear market lows.

Days Since Touch counts how many days it's been since price actually traded through the SMA you picked (wicks count). When this column gets tall, price has been floating away from its anchor for a long time. Those reunions tend to be dramatic.

Everything is calculated on daily data no matter what timeframe your chart is on, so a 1 year SMA is always 365 days whether you're looking at daily, weekly, or monthly. Works best on assets with a lot of price history, like Bitcoin.

---

## Source Code

````pine
//@version=6
indicator("Rainbow Regime", shorttitle="Rainbow Regime", overlay=false)

mode = input.string("Regime Score", "Display Mode",
     options=["Regime Score", "Stretch %", "Days Since Touch"])
pick = input.string("1 Year", "SMA for Stretch / Days Since Touch",
     options=["200 Day", "1 Year", "2 Year", "3 Year", "4 Year", "5 Year",
              "6 Year", "7 Year", "8 Year", "9 Year", "10 Year"])

// Everything is computed on DAILY data so it works on any timeframe
f_all() =>
    s0  = ta.sma(close, 200)
    s1  = ta.sma(close, 365)
    s2  = ta.sma(close, 730)
    s3  = ta.sma(close, 1095)
    s4  = ta.sma(close, 1460)
    s5  = ta.sma(close, 1825)
    s6  = ta.sma(close, 2190)
    s7  = ta.sma(close, 2555)
    s8  = ta.sma(close, 2920)
    s9  = ta.sma(close, 3285)
    s10 = ta.sma(close, 3650)
    score = (close > s0 ? 1 : 0) + (close > s1 ? 1 : 0) + (close > s2 ? 1 : 0) +
         (close > s3 ? 1 : 0) + (close > s4 ? 1 : 0) + (close > s5 ? 1 : 0) +
         (close > s6 ? 1 : 0) + (close > s7 ? 1 : 0) + (close > s8 ? 1 : 0) +
         (close > s9 ? 1 : 0) + (close > s10 ? 1 : 0)
    t0  = ta.barssince(low <= s0  and high >= s0)
    t1  = ta.barssince(low <= s1  and high >= s1)
    t2  = ta.barssince(low <= s2  and high >= s2)
    t3  = ta.barssince(low <= s3  and high >= s3)
    t4  = ta.barssince(low <= s4  and high >= s4)
    t5  = ta.barssince(low <= s5  and high >= s5)
    t6  = ta.barssince(low <= s6  and high >= s6)
    t7  = ta.barssince(low <= s7  and high >= s7)
    t8  = ta.barssince(low <= s8  and high >= s8)
    t9  = ta.barssince(low <= s9  and high >= s9)
    t10 = ta.barssince(low <= s10 and high >= s10)
    [s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, score, t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10]

[s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, score, t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10] =
     request.security(syminfo.tickerid, "D", f_all())

// Selected SMA for the stretch and touch modes
selSma = switch pick
    "200 Day" => s0
    "1 Year"  => s1
    "2 Year"  => s2
    "3 Year"  => s3
    "4 Year"  => s4
    "5 Year"  => s5
    "6 Year"  => s6
    "7 Year"  => s7
    "8 Year"  => s8
    "9 Year"  => s9
    "10 Year" => s10

selDays = switch pick
    "200 Day" => t0
    "1 Year"  => t1
    "2 Year"  => t2
    "3 Year"  => t3
    "4 Year"  => t4
    "5 Year"  => t5
    "6 Year"  => t6
    "7 Year"  => t7
    "8 Year"  => t8
    "9 Year"  => t9
    "10 Year" => t10

stretch = (close - selSma) / selSma * 100

// Colors
scoreCol = score <= 5 ?
     color.from_gradient(score, 0, 5, color.red, color.yellow) :
     color.from_gradient(score, 5, 11, color.yellow, color.lime)
stretchCol = stretch >= 0 ? color.teal : color.red

// Plots (only the active mode draws)
plot(mode == "Regime Score" ? score : na, "Regime Score",
     style=plot.style_columns, color=scoreCol)
plot(mode == "Stretch %" ? stretch : na, "Stretch %",
     color=stretchCol, linewidth=2)
plot(mode == "Stretch %" ? 0 : na, "Zero Line",
     color=color.new(color.gray, 50))
plot(mode == "Days Since Touch" ? selDays : na, "Days Since Touch",
     style=plot.style_columns, color=color.new(color.aqua, 0))
````
