# WaveTrend Divergence

- url: https://www.tradingview.com/script/UVQMUr7d-WaveTrend-Divergence/
- type: indicator
- pine_id: PUB;53faa32059c643848c9e5af935d8272e
- version: 1.0

## Description

WaveTrend Divergence
This indicator detects and draws regular and hidden divergences directly on your price chart, based on a WaveTrend oscillator (9/12, HLC3).
What it does
It identifies swing pivots on the WaveTrend oscillator and compares them against price to mark four divergence types:

Regular Bullish — price makes a lower low while the oscillator makes a higher low (potential reversal up)
Regular Bearish — price makes a higher high while the oscillator makes a lower high (potential reversal down)
Hidden Bullish — price makes a higher low while the oscillator makes a lower low (potential trend continuation up)
Hidden Bearish — price makes a lower high while the oscillator makes a higher high (potential trend continuation down)

Each divergence is drawn as a line connecting the two pivots, with an optional label, plotted as an overlay on price.
Customization
Everything is editable from the settings panel: line color, thickness, and style (solid/dashed/dotted) for each divergence type, label visibility, oscillator lengths, and pivot sensitivity. Built-in alerts are included for bullish and bearish signals.
How to use
Increase the pivot lookback to catch only larger swings, or decrease it for more frequent signals. Works on any market or timeframe. Best used as confirmation alongside your own analysis rather than as a standalone signal.
Note on repainting: Divergences confirm once the right-side pivot completes (after the lookback period), so a signal on the current forming candle is not final until that bar closes. Always wait for confirmation before acting.

## Source Code

````pine
//@version=6
indicator("WaveTrend Divergence", overlay=true, max_lines_count=500, max_labels_count=500)

// ─── WaveTrend Settings ───
n1  = input.int(9,  "WT Channel Length", group="WaveTrend")
n2  = input.int(12, "WT Average Length", group="WaveTrend")
src = input.source(hlc3, "WT Source", group="WaveTrend")

// ─── Divergence Detection ───
lbL = input.int(5, "Pivot Lookback Left",  minval=1, group="Detection")
lbR = input.int(5, "Pivot Lookback Right", minval=1, group="Detection")
showReg = input.bool(true, "Show Regular Divergence", group="Detection")
showHid = input.bool(true, "Show Hidden Divergence",  group="Detection")

// ─── Styles ───
cBull  = input.color(color.green, "Regular Bull", group="Bullish", inline="rb")
wBull  = input.int(2, "W", group="Bullish", inline="rb", minval=1, maxval=5)
sBull  = input.string("solid", "", options=["solid","dashed","dotted"], group="Bullish", inline="rb")
cHBull = input.color(color.green, "Hidden Bull", group="Bullish", inline="hb")
wHBull = input.int(1, "W", group="Bullish", inline="hb", minval=1, maxval=5)
sHBull = input.string("dashed", "", options=["solid","dashed","dotted"], group="Bullish", inline="hb")
cBear  = input.color(color.red, "Regular Bear", group="Bearish", inline="rr")
wBear  = input.int(2, "W", group="Bearish", inline="rr", minval=1, maxval=5)
sBear  = input.string("solid", "", options=["solid","dashed","dotted"], group="Bearish", inline="rr")
cHBear = input.color(color.red, "Hidden Bear", group="Bearish", inline="hr")
wHBear = input.int(1, "W", group="Bearish", inline="hr", minval=1, maxval=5)
sHBear = input.string("dashed", "", options=["solid","dashed","dotted"], group="Bearish", inline="hr")
showLabels = input.bool(true, "Show Labels", group="Labels")

_ls(s) => s == "solid" ? line.style_solid : s == "dashed" ? line.style_dashed : line.style_dotted

// ─── WaveTrend ───
esa = ta.ema(src, n1)
de  = ta.ema(math.abs(src - esa), n1)
ci  = (src - esa) / (0.015 * de)
osc = ta.ema(ci, n2)

// ─── Pivots ───
ph = ta.pivothigh(osc, lbL, lbR)
pl = ta.pivotlow(osc, lbL, lbR)

// store previous pivot: oscillator value, price, bar index
var float pOscL = na
var float pPriceL = na
var int pBarL = na
var float pOscH = na
var float pPriceH = na
var int pBarH = na

// ─── LOWS (bullish divergences) ───
if not na(pl)
    curOsc   = osc[lbR]
    curPrice = low[lbR]
    curBar   = bar_index - lbR
    if not na(pOscL)
        // Regular bull: price LL, osc HL
        if showReg and curPrice < pPriceL and curOsc > pOscL
            line.new(pBarL, pPriceL, curBar, curPrice, color=cBull, width=wBull, style=_ls(sBull))
            if showLabels
                label.new(curBar, curPrice, "Bull", style=label.style_label_up, color=cBull, textcolor=color.white, size=size.small)
        // Hidden bull: price HL, osc LL
        if showHid and curPrice > pPriceL and curOsc < pOscL
            line.new(pBarL, pPriceL, curBar, curPrice, color=cHBull, width=wHBull, style=_ls(sHBull))
            if showLabels
                label.new(curBar, curPrice, "H-Bull", style=label.style_label_up, color=cHBull, textcolor=color.white, size=size.small)
    pOscL := curOsc
    pPriceL := curPrice
    pBarL := curBar

// ─── HIGHS (bearish divergences) ───
if not na(ph)
    curOsc   = osc[lbR]
    curPrice = high[lbR]
    curBar   = bar_index - lbR
    if not na(pOscH)
        // Regular bear: price HH, osc LH
        if showReg and curPrice > pPriceH and curOsc < pOscH
            line.new(pBarH, pPriceH, curBar, curPrice, color=cBear, width=wBear, style=_ls(sBear))
            if showLabels
                label.new(curBar, curPrice, "Bear", style=label.style_label_down, color=cBear, textcolor=color.white, size=size.small)
        // Hidden bear: price LH, osc HH
        if showHid and curPrice < pPriceH and curOsc > pOscH
            line.new(pBarH, pPriceH, curBar, curPrice, color=cHBear, width=wHBear, style=_ls(sHBear))
            if showLabels
                label.new(curBar, curPrice, "H-Bear", style=label.style_label_down, color=cHBear, textcolor=color.white, size=size.small)
    pOscH := curOsc
    pPriceH := curPrice
    pBarH := curBar

alertcondition(not na(pl), "Bullish Divergence", "Bullish WaveTrend divergence")
alertcondition(not na(ph), "Bearish Divergence", "Bearish WaveTrend divergence")
````
