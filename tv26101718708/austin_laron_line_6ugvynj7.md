# Austin (LaR$$on) Line

- url: https://www.tradingview.com/script/6UgVyNJ7-Austin-LaR-on-Line/
- type: indicator
- pine_id: PUB;1ffe66f3632648b1b855e71302ce498d
- version: 1.0

## Description

I'm tired of these trading scammers charging for indicators that should be free... If you know you know. 
The guy who is selling this indicator just shills his product and adds zero value to his community so I'm making it free. 
This the Exact indicator.
(I will it admit it is the most reliable indicator for momentum)

GOLD (entry permitted)
BLUE (no-buy)
GRAY (chop)

## Source Code

````pine
//@version=5
// Larsson Line — replica of CTO Larsson's "Larsson Line" indicator.
// Original is closed-source / paid-access via TradingView (script id: VaY7PmRo).
// Math reverse-engineered from the publicly described logic and a v4 community
// implementation (gist basnijholt/a78fe8deafe76bf3cc1f7e9817f9169e):
// - Four SMMAs (Wilder smoothing, == ta.rma in Pine v5) on hl2.
// - Lengths 15, 19, 25, 29.
// - Three states from the relative ordering of fast/slow:
// GOLD → clean uptrend, entry permitted.
// BLUE → clean downtrend, absolute no-buy.
// GRAY → chop / disagreement, no signal.
// Saved 2026-05-14 for Austin (replaces paid subscription).
indicator("Larsson Line", shorttitle="LL", overlay=true)

src = hl2
v1 = ta.rma(src, 15) // fast
m1 = ta.rma(src, 19)
m2 = ta.rma(src, 25)
v2 = ta.rma(src, 29) // slow

// "Disagreement" check: if any of the middle SMMAs sit on the wrong side
// of the fast/slow relationship, we're in chop.
chop = ((v1 < m1) != (v1 < v2)) or ((m2 < v2) != (v1 < v2))
down = not chop and v1 < v2
up = not chop and not down

gold = color.new(#FFB300, 0) // entry permitted
navy = color.new(#1A237E, 0) // no-buy
gray = color.new(color.silver, 0) // chop

c = up ? gold : chop ? gray : navy

l1 = plot(v1, "Fast SMMA(15)", color=c, linewidth=2)
l2 = plot(v2, "Slow SMMA(29)", color=c, linewidth=2)
fill(l1, l2, color=color.new(c, 80), title="Band")

// Alerts on state flips.
alertcondition(up and not up[1], title="Larsson GOLD (entry permitted)", message="Larsson Line flipped GOLD")
alertcondition(down and not down[1], title="Larsson BLUE (no-buy)", message="Larsson Line flipped BLUE")
alertcondition(chop and not chop[1], title="Larsson GRAY (chop)", message="Larsson Line flipped GRAY")
````
