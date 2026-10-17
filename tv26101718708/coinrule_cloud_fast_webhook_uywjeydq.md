# Coinrule Cloud Fast Webhook 

- url: https://www.tradingview.com/script/UYWJEYdQ-Coinrule-Cloud-Fast-Webhook/
- type: indicator
- pine_id: PUB;be6fca273a5944ae90e9bfd436df402a
- version: 1.0

## Description

Coinrule Cloud Fast Webhook  for testing the new platform build AI-first.

## Source Code

````pine
//@version=6
indicator("Coinrule Fast Webhook", shorttitle="CR-FAST", overlay=true, max_labels_count=50)

// ── Inputs ────────────────────────────────────────────────────────────────
fastLen  = input.int(9,  "Fast EMA", minval=1)
slowLen  = input.int(21, "Slow EMA", minval=2)
useClose = input.bool(false, "Confirm on bar close (safer, slower)")
secret   = input.string("REPLACE_WITH_YOUR_SECRET", "Coinrule secret")
symOv    = input.string("", "Symbol override (blank = chart ticker)")

// ── Signal logic ──────────────────────────────────────────────────────────
fast = ta.ema(close, fastLen)
slow = ta.ema(close, slowLen)

plot(fast, "Fast EMA", color.teal)
plot(slow, "Slow EMA", color.orange)

crossUp   = ta.crossover(fast, slow)
crossDown = ta.crossunder(fast, slow)

longCond  = useClose ? (crossUp   and barstate.isconfirmed) : crossUp
shortCond = useClose ? (crossDown and barstate.isconfirmed) : crossDown

// ── Payload builder ───────────────────────────────────────────────────────
symOut = symOv == "" ? syminfo.ticker : symOv

buildMsg(string side) =>
    '{"id":"' + str.tostring(time) + '-' + symOut + '","secret":"' + secret + '","symbol":"' + symOut + '","side":"' + side + '","price":"' + str.tostring(close, format.mintick) + '"}'

// ── Fire alerts ───────────────────────────────────────────────────────────
if longCond
    alert(buildMsg("buy"), alert.freq_all)
    label.new(bar_index, low, "BUY", style=label.style_label_up, color=color.teal, textcolor=color.white, size=size.tiny)

if shortCond
    alert(buildMsg("sell"), alert.freq_all)
    label.new(bar_index, high, "SELL", style=label.style_label_down, color=color.orange, textcolor=color.white, size=size.tiny)

alertcondition(longCond,  "CR Long",  "CR long cross")
alertcondition(shortCond, "CR Short", "CR short cross")
````
