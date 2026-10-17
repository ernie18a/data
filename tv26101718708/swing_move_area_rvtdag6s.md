# Swing Move Area

- url: https://www.tradingview.com/script/rvTdaG6s-Swing-Move-Area/
- type: indicator
- pine_id: PUB;d95d7f1ca7b845bb84d85124c3396e45
- version: 2.0

## Description

Highlights sustained directional price swings — stretches where a stock has moved significantly in one direction over several days or weeks — while filtering out normal day-to-day noise.

[b]How it works:[/b]

The indicator tracks price in one of two states: an up-swing or a down-swing. While in an up-swing, it continuously records the highest close reached. If price pulls back from that high by more than your Reversal Threshold (default 25%), the swing is considered over — a new down-swing begins, and the indicator starts tracking the low from there. The same logic applies in reverse for down-swings. Small retracements that don't exceed the threshold are ignored, so the swing keeps building through normal volatility instead of resetting on every wiggle.
The plotted area shows the cumulative % change from the start of the current swing to the current close — so a stock that ran from ₹100 to ₹432 over 54 days will show as one continuous green area reaching +332%, and a decline from ₹443 to ₹32 will show as one continuous red area reaching -93%.

[b]Reading the chart:[/b]

[b]Green area (above zero)[/b] — active up-swing; height = % gained from the swing's starting point
[b]Red area (below zero)[/b] — active down-swing; height (depth) = % lost from the swing's starting point
[b]Tall towers[/b] — large, sustained moves, exactly the kind of high-momentum stretches worth investigating
[b]Flat/shallow ripples[/b] — normal chop that stayed within the reversal threshold

[b]Inputs:[/b]

[b]Reversal Threshold (%)[/b] — how much of a pullback from the peak/trough is needed to flip the swing direction. Lower = more sensitive, flips more often. Higher = smoother, only flags major trend changes.
[b]Up/Down Swing Fill colors[/b] — customizable.

[b]Note:[/b] This is a pane-only indicator (no chart overlay). It's a confirmed/lagging signal by design — a swing's full height is only known once it reverses, so use it for identifying and studying historical high-momentum moves rather than as a real-time entry trigger.

## Source Code

````pine
//@version=6
indicator("Swing Move Area (srshah)", overlay=false)

// ─── Inputs ───────────────────────────────────────────────
reversalPct  = input.float(25.0, "Reversal Threshold (%)", minval=1.0, step=1.0, tooltip="Pullback from peak/trough exceeding this flips direction.")
upColor      = input.color(color.new(color.green, 60), "Up Swing Fill")
downColor    = input.color(color.new(color.red, 60), "Down Swing Fill")

// ─── State (persists bar to bar) ──────────────────────────
var bool  isUpTrend  = true
var float swingStart = close
var float extreme    = close   // highest close in uptrend, lowest close in downtrend

// ─── Step 1: Extend the current extreme ───────────────────
if isUpTrend
    extreme := math.max(extreme, close)
else
    extreme := math.min(extreme, close)

// ─── Step 2: Check for reversal from the extreme ──────────
if isUpTrend
    pullback = (extreme - close) / extreme * 100
    if pullback >= reversalPct
        isUpTrend  := false
        swingStart := extreme    // peak becomes start of new down swing
        extreme    := close      // begin tracking new trough
else
    bounce = (close - extreme) / extreme * 100
    if bounce >= reversalPct
        isUpTrend  := true
        swingStart := extreme    // trough becomes start of new up swing
        extreme    := close      // begin tracking new peak

// ─── Cumulative % from swing start ───────────────────────
pctMove = (close - swingStart) / swingStart * 100

// ─── Plot ─────────────────────────────────────────────────
col = isUpTrend ? upColor : downColor
plot(pctMove, title="Swing % Move", style=plot.style_area, color=col, linewidth=1)
hline(0, "Zero", color=color.new(color.gray, 60))

// ─── Alerts ───────────────────────────────────────────────
alertcondition(isUpTrend and not isUpTrend[1], title="Swing Flipped Up", message="Swing flipped UP on {{ticker}} ({{interval}})")
alertcondition(not isUpTrend and isUpTrend[1], title="Swing Flipped Down", message="Swing flipped DOWN on {{ticker}} ({{interval}})")
````
