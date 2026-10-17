# Average Daily Ranges

- url: https://www.tradingview.com/script/S53mqLMA-Average-Daily-Ranges/
- type: indicator
- pine_id: PUB;8323ace9d7e84b3c98f6be9c59c4ac1c
- version: 2.0

## Description

Three Average Daily Ranges (High - Low)
Intraday trading (skip overnight gaps)

## Source Code

````pine
//@version=6
indicator("Average Daily Range - MTF 4-Period", shorttitle="ADR MTF 4", overlay=false)

// --- Inputs ---
tfInput = input.timeframe("D", title="ADR Timeframe")
len1    = input.int(1,  title="Length 1", minval=1)
len2    = input.int(5,  title="Length 2", minval=1)
len3    = input.int(10, title="Length 3", minval=1)
len4    = input.int(20, title="Length 4", minval=1)

// --- Calculations Function ---
get_adr(l1, l2, l3, l4) =>
    dRange = high - low
    a1 = ta.sma(dRange, l1)
    a2 = ta.sma(dRange, l2)
    a3 = ta.sma(dRange, l3)
    a4 = ta.sma(dRange, l4)
    [a1, a2, a3, a4]

// --- Security Call ---
[adr1, adr2, adr3, adr4] = request.security(syminfo.tickerid, tfInput, get_adr(len1, len2, len3, len4), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

// --- Plotting ---
plot(adr1, title="ADR 1", color=color.blue,   linewidth=1)
plot(adr2, title="ADR 2", color=color.orange, linewidth=1)
plot(adr3, title="ADR 3", color=color.green,   linewidth=1)
plot(adr4, title="ADR 4", color=color.red, linewidth=1)
````
