# Volatility Squeeze & Momentum

- url: https://www.tradingview.com/script/QgvpOzTp/
- type: indicator
- pine_id: PUB;43ffb7d72cbd48f1aa57a7f7660c6cf3
- version: 1.0

## Description

This indicator flags low-volatility "squeeze" phases and pairs them with a momentum histogram, so that volatility expansions can be read together with direction. The squeeze concept was popularized by John Carter (TTM Squeeze); this script is an original open-source implementation of that public idea.

How it works

A squeeze is on when both Bollinger Bands (default 20, 2.0) sit inside the Keltner Channels (default 20, 1.5 x average true range) — a sign that recent volatility is unusually compressed. The zero line shows the state: orange dots while the squeeze is on, gray otherwise. Momentum is a linear-regression estimate of price relative to a midline (average of the Donchian midpoint and the SMA), shown as a four-color histogram: rising/falling shades above and below zero.

Three alert conditions are included: squeeze release, release with positive momentum, and release with negative momentum.

Notes and limitations

A squeeze marks compression, not direction — releases can resolve either way, and momentum at the moment of release is context, not a guarantee. All parameters are configurable; defaults follow common usage.

## Source Code

````pine
//@version=6
// ============================================================
//  Volatility Squeeze & Momentum
//  Flags low-volatility "squeeze" phases (Bollinger Bands
//  inside Keltner Channels) and pairs them with a momentum
//  histogram, so squeeze releases can be read with direction.
//  Squeeze concept popularized by John Carter (TTM Squeeze).
// ============================================================
indicator("Volatility Squeeze & Momentum", overlay = false)

// ---------- Inputs ----------
len    = input.int(20,   "Length",                minval = 2)
bbMult = input.float(2.0, "Bollinger multiplier", minval = 0.5, step = 0.1)
kcMult = input.float(1.5, "Keltner multiplier",   minval = 0.5, step = 0.1)

colUpS = input.color(#26a69a, "Momentum up (rising)")
colUpW = input.color(#b2dfdb, "Momentum up (falling)")
colDnS = input.color(#ef5350, "Momentum down (falling)")
colDnW = input.color(#f8bbd0, "Momentum down (rising)")

// ---------- Squeeze detection ----------
basis = ta.sma(close, len)
dev   = bbMult * ta.stdev(close, len)
bbU   = basis + dev
bbL   = basis - dev

rangeMa = ta.sma(ta.tr, len)
kcU     = basis + rangeMa * kcMult
kcL     = basis - rangeMa * kcMult

sqzOn      = bbU < kcU and bbL > kcL
sqzRelease = sqzOn[1] and not sqzOn

// ---------- Momentum ----------
mid = math.avg(math.avg(ta.highest(high, len), ta.lowest(low, len)), ta.sma(close, len))
mom = ta.linreg(close - mid, len, 0)

histCol = mom > 0 ? (mom > mom[1] ? colUpS : colUpW) : (mom < mom[1] ? colDnS : colDnW)

// ---------- Drawing ----------
plot(mom, "Momentum", histCol, style = plot.style_columns)
plot(0, "Squeeze state", sqzOn ? color.new(#ff9800, 0) : color.new(#787b86, 40),
     2, plot.style_circles)

// ---------- Alerts ----------
alertcondition(sqzRelease,           "Squeeze release",         "Squeeze released")
alertcondition(sqzRelease and mom > 0, "Squeeze release (up)",   "Squeeze released with positive momentum")
alertcondition(sqzRelease and mom < 0, "Squeeze release (down)", "Squeeze released with negative momentum")
````
