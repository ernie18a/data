<!-- tradingview-pine-id: PUB;586ba1512e794e08bb7e96329a6a3101 -->
<!-- tradingviewscripts-format: 1 -->
# Piece of Shit Detector

Source: https://www.tradingview.com/script/9HJ9jEd3-Piece-of-Shit-Detector/

## Description

If its below the 200 EMA, you will know. Its a great indicator for swingtraders, almost as good as Nick's: Drendel Gaps. Key word "almost".

---

## Source Code

````pine
//@version=6
indicator("Piece of Shit Detector", overlay=true)

// --- Settings ---
len       = input.int(200, "SMA Length")
showShadow = input.bool(true, "Shade region below SMA")
customMsg  = input.string("This thing is a piece of shit", "Message")

// --- 200 SMA ---
sma200 = ta.sma(close, len)
plot(sma200, "SMA", color=color.orange, linewidth=2)

belowSMA = close < sma200

// --- Red "shadow" over the bad region ---
bgcolor(showShadow and belowSMA ? color.new(color.red, 90) : na)

// --- The verdict on the last bar ---
var label verdict = na
if barstate.islast
    label.delete(verdict)
    if belowSMA
        verdict := label.new(bar_index, high, '"' + customMsg + '"',
             yloc=yloc.abovebar, style=label.style_label_down,
             color=color.red, textcolor=color.white, size=size.large)
````
