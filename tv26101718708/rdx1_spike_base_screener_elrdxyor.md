# RDX1 --Spike & Base Screener

- url: https://www.tradingview.com/script/ElrDxyOr-RDX1-Spike-Base-Screener/
- type: indicator
- pine_id: PUB;86ffbf497d5d4bbab8c87d7983794abc
- version: 3.0

## Description

Spike bar = a bar whose close-to-close move is ≥ your % threshold (so +10% vs the prior close; down bars are excluded automatically).
Within last N days = scan each of the last N bars as a candidate spike.
52-wk high = the spike bar's high is the highest high over ~252 trading days (toggleable).
"Stayed inside the move" / didn't undercut = every bar after the spike held above the spike bar's low. I made low-vs-close a toggle since "undercut" can mean either the wick or the close.
Pass = at least one spike bar in the window satisfies all of the above.

## Source Code

````pine
//@version=6
indicator("RDX1 -- Spike & Base Screener", overlay=true, max_bars_back=300)

// ---------- Inputs ----------
lookbackDays = input.int(5,  "Spike must be within last N days", minval=1)
minBaseBars  = input.int(1,  "Min bars holding inside since spike", minval=1)
movePct      = input.float(10, "Min single-bar move %", minval=0)
useClose     = input.bool(false, "Use close for containment (off = wicks)")

// ---------- Calcs ----------
bool  pass      = false
int   spikeAgo  = na
float spikeMove = na

// Scan most-recent (i=minBaseBars) outward to N days; first qualifier wins
for i = minBaseBars to lookbackDays
    mv = (close[i] - close[i + 1]) / close[i + 1] * 100   // single-bar move
    if mv >= movePct
        spikeHigh = high[i]
        spikeLow  = low[i]
        inside = true
        for j = 0 to i - 1                                // every bar AFTER the spike
            hi = useClose ? close[j] : high[j]
            lo = useClose ? close[j] : low[j]
            if hi > spikeHigh or lo < spikeLow
                inside := false
                break
        if inside
            pass      := true
            spikeAgo  := i
            spikeMove := mv
            break

// ---------- Outputs (become screener columns) ----------
plot(pass ? 1 : 0, "Pass",         display = display.data_window)
plot(spikeAgo,     "SpikeDaysAgo", display = display.data_window)
plot(spikeMove,    "SpikeMove_%",  display = display.data_window)

bgcolor(pass ? color.new(color.green, 85) : na)
````
