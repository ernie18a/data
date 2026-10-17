# Fixed-price range nested channels

- url: https://www.tradingview.com/script/u44LuMJU-Fixed-price-range-nested-channels/
- type: indicator
- pine_id: PUB;47af9f26dd94474cb079e6611ff767ff
- version: 1.0

## Description

[b]How to Use[/b]

Markets are fractal in nature—price does not move in a straight line, but in *waves within waves*. Each move contains smaller internal structures while also forming part of a larger structure.

This indicator is designed to help you visualize and track these multiple layers of movement simultaneously.

In forex markets, certain price expansions tend to recur frequently. Common intraday ranges include:
* 10, 20, 50, 100 pips
* or percentage equivalents such as 0.2%, 0.5%, 1%

Similarly, in indices like the S&P 500, larger timeframes often respect:
* 3%, 5%, 10% moves on the daily chart

These repeating expansions are not random—they reflect the natural rhythm of market participation and liquidity.



[b]What This Indicator Does[/b]

This tool plots nested fixed-width channels (Inner, Middle, Outer) to represent:

* Small moves (Inner band) → micro structure
* Medium moves (Middle band) → swing structure
* Large moves (Outer band) → macro structure

By doing so, it keeps short-, medium-, and large-scale price movements in perspective at all times, allowing you to better understand where price is within its broader context.



[b]Customization[/b]

Markets behave differently depending on:

* Instrument (e.g., EURUSD vs XAUUSD vs SPX)
* Timeframe
* Volatility conditions

For this reason, users can define their own width parameters in either:

* Points (pips)
* Percentage (%)

This flexibility allows the indicator to adapt to any market or trading style.

---
[b] How to Interpret[/b]

* Inside Inner Band → Low volatility / equilibrium
* Between Inner & Middle → Controlled movement
* Between Middle & Outer → Expansion phase
* At Outer Band → Potential exhaustion or breakout decision

This structure helps you:

* Identify mean reversion zones
* Recognize trend continuation
* Spot volatility expansion early



[b]Best Used With[/b]

This indicator is most effective when combined with other tools such as:

* Moving Averages (EMA) for trend direction
* Oscillators (RSI, Stochastic, etc.) for momentum and divergence
* Price action / liquidity concepts for entries

It provides the context, while other tools can help refine timing.


⚠️ Important Note

This is not a signal indicator.

It is a market structure tool designed to help you:

* Understand where price is
* Anticipate how it may behave next
* Stay aligned with the dominant scale of movement

## Source Code

````pine
//@version=6
indicator("Fixed-price range Nested channels", overlay=true)

// === Inputs ===
ctype=input.string("Points","Width type",options=["Points","Percent"])
fx1 = input.float(20, "Inner Width (fx1)", group="Width Settings-Points")
fx2 = input.float(50, "Middle Width (fx2)", group="Width Settings-Points")
fx3 = input.float(100, "Outer Width (fx3)", group="Width Settings-Points")

pfx1 = input.float(0.2, "Inner Width (fx1)", group="Width Settings-Percent")
pfx2 = input.float(0.5, "Middle Width (fx2)", group="Width Settings-Percent")
pfx3 = input.float(1, "Outer Width (fx3)", group="Width Settings-Percent")

midline  = input.bool(true, "Show Middle lines", group="Display settings")
qtrlines = input.bool(true, "Show Qtr divisions", group="Display settings")
overlap  = input.bool(false,"Overlap on inner band", group="Display settings")
lcolor1 = input.color(color.new(color.blue, 20), "Inner Color", group="Colors")
lcolor2 = input.color(color.new(color.green, 20), "Middle Color", group="Colors")
lcolor3 = input.color(color.new(color.red, 20), "Outer Color", group="Colors")

// Tick conversion
pnt1 = ctype=="Points"?fx1 * syminfo.mintick * 10.0:close*pfx1/100
pnt2 = ctype=="Points"?fx2 * syminfo.mintick * 10.0:close*pfx2/100
pnt3 = ctype=="Points"?fx3 * syminfo.mintick * 10.0:close*pfx3/100

// === Independent HILO Logic Function ===
calc_hilo(prev_h, prev_l, width) =>
    float h = na
    float l = na
    h := na(prev_h) ? high : (high >= prev_h ? high : (low[1] == prev_l ? prev_l + width : prev_h))
    l := na(prev_l) ? low  : (low  <= prev_l ? low  : (high[1] == prev_h ? prev_h - width : prev_l))
    [h, l]

// === Calculations ===
var float h1 = na, var float l1 = na
var float h2 = na, var float l2 = na
var float h3 = na, var float l3 = na

// Core FX1
[rawH1, rawL1] = calc_hilo(h1[1], l1[1], pnt1)
h1 := rawH1, l1 := rawL1
ph1=h1==h1[1]?h1:na,pl1=l1==l1[1]?l1:na

// Core FX2 (Forced no-cross)
[rawH2, rawL2] = calc_hilo(h2[1], l2[1], pnt2)
h2 := math.max(rawH2, h1), l2 := math.min(rawL2, l1)
ph2=h2==h2[1]?h2:na,pl2=l2==l2[1]?l2:na
// Core FX3 (Forced no-cross)
[rawH3, rawL3] = calc_hilo(h3[1], l3[1], pnt3)
h3 := math.max(rawH3, h2), l3 := math.min(rawL3, l2)
ph3=h3==h3[1]?h3:na,pl3=l3==l3[1]?l3:na
// === Derived Levels with Visibility Logic ===

// FX1 (Always visible within its own band)
mid1 = midline ? (h1 + l1) / 2 : na
u1   = qtrlines ? l1 + (h1 - l1) * 0.75 : na
d1   = qtrlines ? l1 + (h1 - l1) * 0.25 : na
pmid1=mid1==mid1[1]?mid1:na,pu1=u1==u1[1]?u1:na,pd1=d1==d1[1]?d1:na
// FX2 (Only visible if OUTSIDE FX1 boundaries)
is_outside_fx1(val) => not overlap?val > h1 or val < l1:true

mid2 = midline  and is_outside_fx1((h2 + l2) / 2) ? (h2 + l2) / 2 : na
u2   = qtrlines and is_outside_fx1(l2 + (h2 - l2) * 0.75) ? l2 + (h2 - l2) * 0.75 : na
d2   = qtrlines and is_outside_fx1(l2 + (h2 - l2) * 0.25) ? l2 + (h2 - l2) * 0.25 : na
pmid2=mid2==mid2[1]?mid2:na,pu2=u2==u2[1]?u2:na,pd2=d2==d2[1]?d2:na
// FX3 (Only visible if OUTSIDE FX2 boundaries)
is_outside_fx2(val) => not overlap?val > h2 or val < l2:true

mid3 = midline  and is_outside_fx2((h3 + l3) / 2) ? (h3 + l3) / 2 : na
u3   = qtrlines and is_outside_fx2(l3 + (h3 - l3) * 0.75) ? l3 + (h3 - l3) * 0.75 : na
d3   = qtrlines and is_outside_fx2(l3 + (h3 - l3) * 0.25) ? l3 + (h3 - l3) * 0.25 : na
pmid3=mid3==mid3[1]?mid3:na,pu3=u3==u3[1]?u3:na,pd3=d3==d3[1]?d3:na
// === Plotting ===

// FX3
plot(ph3, color=lcolor3, title="H3",linewidth=2, style=plot.style_linebr,display=display.all-display.status_line)
plot(pl3, color=lcolor3, title="L3",linewidth=2, style=plot.style_linebr,display=display.all-display.status_line)
p3h = plot(h3, color=color.new(lcolor3,90), title="H3",linewidth=2, style=plot.style_linebr,display=display.all-display.status_line)
p3l = plot(l3, color=color.new(lcolor3,90), title="L3",linewidth=2, style=plot.style_linebr,display=display.all-display.status_line)
plot(pmid3, color=lcolor3, title="M3", linewidth=2,style=plot.style_linebr,display=display.all-display.status_line)
plot(pu3, color=lcolor3, title="U3", style=plot.style_linebr,display=display.all-display.status_line)
plot(pd3, color=lcolor3, title="D3", style=plot.style_linebr,display=display.all-display.status_line)

// FX2
plot(ph2, color=lcolor2, title="H2", linewidth=2,style=plot.style_linebr,display=display.all-display.status_line)
plot(pl2, color=lcolor2, title="L2",linewidth=2, style=plot.style_linebr,display=display.all-display.status_line)
p2h = plot(h2, color=color.new(lcolor2,90), title="H2", linewidth=2,style=plot.style_linebr,display=display.all-display.status_line)
p2l = plot(l2, color=color.new(lcolor2,90), title="L2",linewidth=2, style=plot.style_linebr,display=display.all-display.status_line)
plot(pmid2, color=lcolor2, title="M2",linewidth=2, style=plot.style_linebr,display=display.all-display.status_line)
plot(pu2, color=lcolor2, title="U2", style=plot.style_linebr,display=display.all-display.status_line)
plot(pd2, color=lcolor2, title="D2", style=plot.style_linebr,display=display.all-display.status_line)

// FX1
plot(ph1, color=lcolor1, title="H1", linewidth=2, style=plot.style_linebr,display=display.all-display.status_line)
plot(pl1, color=lcolor1, title="L1", linewidth=2, style=plot.style_linebr,display=display.all-display.status_line)
p1h = plot(h1, color=color.new(lcolor1,90), title="H1", linewidth=2, style=plot.style_linebr,display=display.all-display.status_line)
p1l = plot(l1, color=color.new(lcolor1,90), title="L1", linewidth=2, style=plot.style_linebr,display=display.all-display.status_line)
fill(p1h, p1l, color=color.new(lcolor1, 95))
plot(pmid1, color=lcolor1, title="M1", linewidth=2, style=plot.style_linebr,display=display.all-display.status_line)
plot(pu1, color=lcolor1, title="U1", style=plot.style_linebr,display=display.all-display.status_line)
plot(pd1, color=lcolor1, title="D1", style=plot.style_linebr,display=display.all-display.status_line)

fill(p3h, p2h, color=color.new(lcolor3, 90))
fill(p3l, p2l, color=color.new(lcolor3, 90))

fill(p2h, p1h, color=color.new(lcolor2, 95))
fill(p2l, p1l, color=color.new(lcolor2, 95))
````
