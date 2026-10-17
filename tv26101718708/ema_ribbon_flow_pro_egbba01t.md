# EMA Ribbon FLOW PRO

- url: https://www.tradingview.com/script/egBba01t/
- type: indicator
- pine_id: PUB;c338d70b2ee0421cb791c3c702b70164
- version: 1.0

## Description

# EMA Ribbon FLOW PRO

EMA Ribbon FLOW PRO is a multi-layer exponential moving average (EMA) ribbon designed to visualize market structure, trend direction, dynamic support/resistance, and momentum across different trading horizons.

Instead of using only one or two moving averages, the indicator combines several EMA ribbons into one clean visual layout. Each ribbon represents a different trend layer, allowing traders to quickly identify short-, medium-, and long-term market direction.

## Included EMA Ribbons

* **M1 Ribbon:** EMA 20–55
* **M5 Ribbon:** EMA 100–275
* **x15 Ribbon:** EMA 300–600
* **H1 Ribbon:** EMA 900–2100

Each ribbon uses its own color gradient, making it easy to distinguish between different market structures.

---

# How to Trade with EMA Ribbon FLOW PRO

The indicator can be used in many different ways depending on your trading style.

### Trend Identification

When all ribbons are aligned and pointing in the same direction, the market is usually trending.

* Rising ribbons → Bullish trend
* Falling ribbons → Bearish trend

The wider the ribbon becomes, the stronger the trend generally is.

---

### Dynamic Support and Resistance

The EMA ribbons often act as dynamic support and resistance zones.

Common approaches include:

* Buying pullbacks into bullish ribbons
* Selling pullbacks into bearish ribbons
* Watching for reactions when price touches an EMA cluster

Instead of focusing on a single moving average, traders can use the entire ribbon as an area of interest.

---

### Momentum

Ribbon expansion usually indicates increasing momentum.

Ribbon compression often signals:

* slowing momentum
* consolidation
* possible trend transitions

This allows traders to recognize changing market conditions before large moves develop.

---

### Multiple Trend Layers

The different ribbons help separate short-term market noise from the larger trend.

For example:

* M1 ribbon for short-term entries
* M5 ribbon for trend confirmation
* x15 ribbon for higher timeframe bias
* H1 ribbon for the overall market direction

Using multiple EMA groups together helps traders avoid trading against stronger trends.

---

# Fully Customizable

EMA Ribbon FLOW PRO was designed to be highly customizable.

You can:

* Show or hide every ribbon independently.
* Display only the EMA groups that fit your trading style.
* Customize line colors.
* Change ribbon fill colors.
* Disable fill colors completely.
* Adjust line width.
* Use your preferred price source.

Whether you prefer a clean chart with only a few EMAs or a complete multi-ribbon layout, the indicator can easily be adapted to your workflow.

---

# Suitable For

* Scalping
* Day Trading
* Swing Trading
* Crypto
* Forex
* Indices
* Stocks
* Commodities

The indicator works on every timeframe, although it is especially useful for traders who combine lower timeframe entries with higher timeframe trend confirmation.

---

# Disclaimer

EMA Ribbon FLOW PRO is a market structure and trend analysis tool. It does not predict future price movements and should be used together with proper risk management and your own trading strategy.

## Source Code

````pine
//@version=6
indicator("EMA Ribbon FLOW PRO", overlay=true)

//━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━
src = input.source(close, "Source")
w   = input.int(1, "Linienbreite", minval=1, maxval=5)

//━━━━━━━━━━━━━━━━━━
// TF TOGGLES
//━━━━━━━━━━━━━━━━━━
showM1  = input.bool(true, "SHOW M1 RIBBON")
showM5  = input.bool(true, "SHOW M5 RIBBON")
showX15 = input.bool(true, "SHOW x15 RIBBON")
showH1  = input.bool(true, "SHOW H1 RIBBON")

//━━━━━━━━━━━━━━━━━━
// M1 EMAS
//━━━━━━━━━━━━━━━━━━
ema20 = ta.ema(src, 20)
ema25 = ta.ema(src, 25)
ema30 = ta.ema(src, 30)
ema35 = ta.ema(src, 35)
ema40 = ta.ema(src, 40)
ema45 = ta.ema(src, 45)
ema50 = ta.ema(src, 50)
ema55 = ta.ema(src, 55)

//━━━━━━━━━━━━━━━━━━
// M5 EMAS
//━━━━━━━━━━━━━━━━━━
ema100 = ta.ema(src, 100)
ema125 = ta.ema(src, 125)
ema150 = ta.ema(src, 150)
ema175 = ta.ema(src, 175)
ema200 = ta.ema(src, 200)
ema225 = ta.ema(src, 225)
ema250 = ta.ema(src, 250)
ema275 = ta.ema(src, 275)

//━━━━━━━━━━━━━━━━━━
// x15 EMAS
//━━━━━━━━━━━━━━━━━━
ema300 = ta.ema(src, 300)
ema375 = ta.ema(src, 375)
ema450 = ta.ema(src, 450)
ema525 = ta.ema(src, 525)
ema600 = ta.ema(src, 600)

//━━━━━━━━━━━━━━━━━━
// H1 EMAS
//━━━━━━━━━━━━━━━━━━
ema900  = ta.ema(src, 900)
ema1200 = ta.ema(src, 1200)
ema1500 = ta.ema(src, 1500)
ema1800 = ta.ema(src, 1800)
ema2100 = ta.ema(src, 2100)

//━━━━━━━━━━━━━━━━━━
// M1 COLORS
//━━━━━━━━━━━━━━━━━━
c20 = color.rgb(0, 255, 120)
c25 = color.rgb(0, 235, 150)
c30 = color.rgb(0, 215, 180)
c35 = color.rgb(0, 190, 210)

c40 = color.rgb(255, 210, 0)
c45 = color.rgb(255, 160, 0)
c50 = color.rgb(255, 100, 0)
c55 = color.rgb(255, 40, 40)

//━━━━━━━━━━━━━━━━━━
// M5 COLORS
// ORANGE FLOW
//━━━━━━━━━━━━━━━━━━
m100 = color.rgb(255, 220, 120)
m125 = color.rgb(255, 200, 90)
m150 = color.rgb(255, 180, 60)
m175 = color.rgb(255, 160, 30)

m200 = color.rgb(255, 140, 0)
m225 = color.rgb(255, 120, 0)
m250 = color.rgb(255, 90, 0)
m275 = color.rgb(255, 60, 0)

//━━━━━━━━━━━━━━━━━━
// x15 COLORS
//━━━━━━━━━━━━━━━━━━
x300 = color.rgb(0, 180, 255)
x375 = color.rgb(0, 140, 255)
x450 = color.rgb(0, 100, 255)
x525 = color.rgb(40, 70, 255)
x600 = color.rgb(90, 40, 255)

//━━━━━━━━━━━━━━━━━━
// H1 COLORS
//━━━━━━━━━━━━━━━━━━
h900  = color.rgb(120, 140, 255)
h1200 = color.rgb(150, 110, 255)
h1500 = color.rgb(190, 90, 255)
h1800 = color.rgb(230, 70, 220)
h2100 = color.rgb(255, 60, 170)

//━━━━━━━━━━━━━━━━━━
// M1 PLOTS
//━━━━━━━━━━━━━━━━━━
p20 = plot(showM1 ? ema20 : na, title="M1 EMA 20", color=c20, linewidth=w)
p25 = plot(showM1 ? ema25 : na, title="M1 EMA 25", color=c25, linewidth=w)
p30 = plot(showM1 ? ema30 : na, title="M1 EMA 30", color=c30, linewidth=w)
p35 = plot(showM1 ? ema35 : na, title="M1 EMA 35", color=c35, linewidth=w)

p40 = plot(showM1 ? ema40 : na, title="M1 EMA 40", color=c40, linewidth=w)
p45 = plot(showM1 ? ema45 : na, title="M1 EMA 45", color=c45, linewidth=w)
p50 = plot(showM1 ? ema50 : na, title="M1 EMA 50", color=c50, linewidth=w)
p55 = plot(showM1 ? ema55 : na, title="M1 EMA 55", color=c55, linewidth=w)

//━━━━━━━━━━━━━━━━━━
// M5 PLOTS
//━━━━━━━━━━━━━━━━━━
pm100 = plot(showM5 ? ema100 : na, title="M5 EMA 100", color=m100, linewidth=w)
pm125 = plot(showM5 ? ema125 : na, title="M5 EMA 125", color=m125, linewidth=w)
pm150 = plot(showM5 ? ema150 : na, title="M5 EMA 150", color=m150, linewidth=w)
pm175 = plot(showM5 ? ema175 : na, title="M5 EMA 175", color=m175, linewidth=w)

pm200 = plot(showM5 ? ema200 : na, title="M5 EMA 200", color=m200, linewidth=w)
pm225 = plot(showM5 ? ema225 : na, title="M5 EMA 225", color=m225, linewidth=w)
pm250 = plot(showM5 ? ema250 : na, title="M5 EMA 250", color=m250, linewidth=w)
pm275 = plot(showM5 ? ema275 : na, title="M5 EMA 275", color=m275, linewidth=w)

//━━━━━━━━━━━━━━━━━━
// x15 PLOTS
//━━━━━━━━━━━━━━━━━━
px300 = plot(showX15 ? ema300 : na, title="x15 EMA 300", color=x300, linewidth=w)
px375 = plot(showX15 ? ema375 : na, title="x15 EMA 375", color=x375, linewidth=w)
px450 = plot(showX15 ? ema450 : na, title="x15 EMA 450", color=x450, linewidth=w)
px525 = plot(showX15 ? ema525 : na, title="x15 EMA 525", color=x525, linewidth=w)
px600 = plot(showX15 ? ema600 : na, title="x15 EMA 600", color=x600, linewidth=w)

//━━━━━━━━━━━━━━━━━━
// H1 PLOTS
//━━━━━━━━━━━━━━━━━━
ph900  = plot(showH1 ? ema900 : na, title="H1 EMA 900", color=h900, linewidth=w)
ph1200 = plot(showH1 ? ema1200 : na, title="H1 EMA 1200", color=h1200, linewidth=w)
ph1500 = plot(showH1 ? ema1500 : na, title="H1 EMA 1500", color=h1500, linewidth=w)
ph1800 = plot(showH1 ? ema1800 : na, title="H1 EMA 1800", color=h1800, linewidth=w)
ph2100 = plot(showH1 ? ema2100 : na, title="H1 EMA 2100", color=h2100, linewidth=w)

//━━━━━━━━━━━━━━━━━━
// M1 FILLS
//━━━━━━━━━━━━━━━━━━
fill(p20, p25, color=color.new(c20, 88))
fill(p25, p30, color=color.new(c25, 88))
fill(p30, p35, color=color.new(c30, 88))
fill(p35, p40, color=color.new(c35, 88))
fill(p40, p45, color=color.new(c40, 88))
fill(p45, p50, color=color.new(c45, 88))
fill(p50, p55, color=color.new(c50, 88))

//━━━━━━━━━━━━━━━━━━
// M5 FILLS
//━━━━━━━━━━━━━━━━━━
fill(pm100, pm125, color=color.new(m100, 90))
fill(pm125, pm150, color=color.new(m125, 90))
fill(pm150, pm175, color=color.new(m150, 90))
fill(pm175, pm200, color=color.new(m175, 90))
fill(pm200, pm225, color=color.new(m200, 90))
fill(pm225, pm250, color=color.new(m225, 90))
fill(pm250, pm275, color=color.new(m250, 90))

//━━━━━━━━━━━━━━━━━━
// x15 FILLS
//━━━━━━━━━━━━━━━━━━
fill(px300, px375, color=color.new(x300, 90))
fill(px375, px450, color=color.new(x375, 90))
fill(px450, px525, color=color.new(x450, 90))
fill(px525, px600, color=color.new(x525, 90))

//━━━━━━━━━━━━━━━━━━
// H1 FILLS
//━━━━━━━━━━━━━━━━━━
fill(ph900, ph1200, color=color.new(h900, 90))
fill(ph1200, ph1500, color=color.new(h1200, 90))
fill(ph1500, ph1800, color=color.new(h1500, 90))
fill(ph1800, ph2100, color=color.new(h1800, 90))
````
