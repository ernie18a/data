# RDJ - Spike & Base Screener

- url: https://www.tradingview.com/script/p8ZYPo4V-RDJ-Spike-Base-Screener/
- type: indicator
- pine_id: PUB;f1b6f9321ad04ecd968b59145a4ac31b
- version: 1.0

## Description

Spike bar = a bar whose close-to-close move is ≥ your % threshold (so +10% vs the prior close; down bars are excluded automatically).
Within last N days = scan each of the last N bars as a candidate spike.
52-wk high = the spike bar's high is the highest high over ~252 trading days (toggleable).
"Stayed inside the move" / didn't undercut = every bar after the spike held above the spike bar's low. I made low-vs-close a toggle since "undercut" can mean either the wick or the close.
Pass = at least one spike bar in the window satisfies all of the above.

## Source Code

````pine
//@version=6
indicator("RD - Spike & Base Screener", overlay=true, max_bars_back=300)

// ---------- Inputs ----------
lookback    = input.int(5,     "Lookback window (days)", minval=1)
movePct     = input.float(10,  "Min single-bar move %",  minval=0)
minBaseDays = input.int(1,     "Min days basing since spike", minval=1)
useClose    = input.bool(false,"Undercut on close (off = low/wick)")

// ---------- Calcs ----------
bool  pass      = false
int   spikeAgo  = na
float spikeMove = na

// Scan each bar in the window as a candidate spike bar (i bars ago)
for i = minBaseDays to lookback
    mv = (close[i] - close[i + 1]) / close[i + 1] * 100   // single-bar move
    if mv >= movePct
        spikeLow = low[i]                                 // floor of the move
        held = true
        for j = 0 to i - 1                                // every bar after spike
            lvl = useClose ? close[j] : low[j]
            if lvl < spikeLow
                held := false
                break
        if held
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
