# Gideons Gold - ADX Watchman

- url: https://www.tradingview.com/script/javZy74d-Gideons-Gold-ADX-Watchman/
- type: indicator
- pine_id: PUB;f502197b18874b3ca159075ef135d267
- version: 1.0

## Description

[b]Gideons Gold — ADX Watchman[/b]

Meet ADX Watchman, keeping watch on trend strength as part of Gideons Gold. We’re new to the space and want to bring value to the trading community through practical, easy-to-use tools. Our purpose is simple: Less Noise. Greater Focus.

ADX Watchman displays the standard Average Directional Index as a color-coded line, helping you follow changes in trend strength at a glance.

[b]Features:[/b]

- Color-coded ADX line for a clear view of trend strength.
- Adjustable ADX smoothing and DI length, both defaulting to 14.
- Timeframe selection to support your chart analysis.
- Open-source code to inspect, learn from, and adapt.

[b]Reading the colors:[/b]
- Red — ADX at or below 20: Lower trend strength.
- Yellow — ADX above 20 but below 22: Between the two strength thresholds.
- Green — ADX at or above 22: Higher trend strength relative to those thresholds.

ADX measures strength, not direction. Green can accompany an upward or downward trend. A rising line indicates increasing trend strength; a falling line indicates weakening strength, not necessarily a reversal.

Watchman uses the standard ADX calculation with a simple color treatment. These colors are visual guides, not standalone entry signals. ADX can lag, and its current value can change before the candle closes.

[b]The inspiration behind Gideons Gold[/b]
In Judges 7:2–7, God reduced Gideon’s army to 300 so Israel would not credit its own strength for the victory. That story inspires our emphasis on humility, purpose, and the idea that more is not always better—a perspective we bring to clearer charts and focused tools, not a promise of trading success.

[i][b]Less Noise. Greater Focus.[/b][/i]
Clearer charts. Focused tools. A rules-based approach.

## Source Code

````pine
//@version=6
indicator("Gideons Gold — ADX Watchman", shorttitle="Gideons Gold — ADX Watchman", format=format.price, precision=2, timeframe="", timeframe_gaps=true)

// ───────────── Settings ─────────────
adxlen = input.int(14, title="ADX Smoothing", minval=1)
dilen = input.int(14, title="DI Length", minval=1)

// ───────────── Directional Movement ─────────────
dirmov(len) =>
    up = ta.change(high)
    down = -ta.change(low)
    plusDM = na(up) ? na : (up > down and up > 0 ? up : 0)
    minusDM = na(down) ? na : (down > up and down > 0 ? down : 0)
    truerange = ta.rma(ta.tr, len)
    plus = fixnan(100 * ta.rma(plusDM, len) / truerange)
    minus = fixnan(100 * ta.rma(minusDM, len) / truerange)
    [plus, minus]

// ───────────── ADX Calculation ─────────────
adx(dilen, adxlen) =>
    [plus, minus] = dirmov(dilen)
    sum = plus + minus
    100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), adxlen)

sig = adx(dilen, adxlen)

// ───────────── Histogram ─────────────
histColor = sig <= 20 ? color.red : sig < 22 ? color.yellow : color.green

plot(sig, style=plot.style_columns, color=histColor, title="ADX Histogram", linewidth=2)
````
