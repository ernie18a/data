# Support_V1

- url: https://www.tradingview.com/script/W3vffacd-Support-V1/
- type: indicator
- pine_id: PUB;d51528b7a2c3474ab7c0624797e4b399
- version: 1.0

## Description

Credit: Concept by TradingLion · Pine Script v6 implementation

[b][/b]What it does[/b][b]
Plots horizontal support/resistance lines only at volatility-qualified pivot highs and lows — pivots where price moved at least ADR × Multiplier from the previous pivot. Shallow, noise-level swings are ignored. Nearby levels within Merge Within % are automatically collapsed into one. Only the most recent Max Pivots levels stay visible.

[b][/b]Settings[/b][b]
[i]Setting[/i]	                   What it controls[i][/i]
Max                             Pivots Max lines on chart at any time
Breakout Threshold	   ADR or fixed % used for breakout arrow signals
Merge Within %	           Collapses two levels that are closer than this % apart
Breakout %	           Threshold when using Percent mode for breakout signals
ADR Lookback	           Bars used to compute Average Daily Range
ADR Multiplier	           Scales the ADR — higher = only larger moves qualify as pivots
Extend Bars Right	   How far the line projects to the right of the current bar

[b][b]How to use[/b][b][/b]
Paste into TradingView Pine Editor → Add to chart
Start with defaults (ADR Lookback 20, Multiplier 1, Max Pivots 2)
Raise ADR Multiplier (e.g. 2) on volatile stocks to filter out noise
Raise Merge Within % (e.g. 5–10) in tight consolidations to keep one clean level
Extend Bars Right controls how far ahead the line projects — set to match your typical hold period in bars

## Source Code

````pine
//@version=6
indicator("Support_V1", shorttitle="SV1", overlay=true, max_lines_count=500)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
int    maxPivots    = input.int   (2,      "Max Pivots",            minval=1, maxval=20,  group="SETTINGS")
string brkType      = input.string("ADR",  "Breakout Threshold",    options=["ADR","Percent"], group="SETTINGS")
float  mergePct     = input.float (0.5,    "Merge Within %",        minval=0.0, step=0.1, group="SETTINGS")
float  breakoutPct  = input.float (1.5,    "Breakout %",            minval=0.0, step=0.1, group="SETTINGS")
int    adrLen       = input.int   (20,     "ADR Lookback",          minval=2,              group="SETTINGS")
float  adrMult      = input.float (1.0,    "ADR Multiplier",        minval=0.1, step=0.1, group="SETTINGS")
color  lineCol      = input.color (color.blue, "Line Color",                               group="STYLE")
int    lineWid      = input.int   (4,          "Line Width",         minval=1, maxval=4,   group="STYLE")
string lineStyleStr = input.string("Solid",    "Line Style",         options=["Solid","Dashed","Dotted"], group="STYLE")
int    extendBars   = input.int   (20,         "Extend Bars Right",  minval=1, maxval=500, group="STYLE")

// ─── LINE STYLE ───────────────────────────────────────────────────────────────
lStyle = switch lineStyleStr
    "Dashed" => line.style_dashed
    "Dotted" => line.style_dotted
    =>          line.style_solid

// ─── ADR (series — can be referenced historically with [n]) ───────────────────
// adr[LB] = ADR value at the bar where the pivot actually formed
float adr = ta.sma(high - low, adrLen) * adrMult

// Breakout threshold (for signal arrows only)
float brkThresh = brkType == "ADR" ? adr : close * breakoutPct / 100.0

// ─── PIVOT DETECTION ─────────────────────────────────────────────────────────
int   LB = 5
float ph = ta.pivothigh(high, LB, LB)
float pl = ta.pivotlow (low,  LB, LB)

// ─── STATE ───────────────────────────────────────────────────────────────────
var float[] allLvl      = array.new_float()
var line[]  allLine     = array.new_line()
var float   lastPivotLvl = na   // price of the last accepted pivot (any direction)

// ─── HELPERS ─────────────────────────────────────────────────────────────────

// True if lvl is within mergePct% of any level already stored
f_isMerged(float lvl, float[] arr) =>
    bool m = false
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            if math.abs(lvl - array.get(arr, i)) / array.get(arr, i) * 100.0 <= mergePct
                m := true
                break
    m

// ─── REGISTER PIVOT HIGH ─────────────────────────────────────────────────────
if not na(ph)
    // ADR at the bar where the pivot formed (LB bars back)
    float adrAtPivot = adr[LB]
    // "Relative Measured" gate: move from last pivot must be >= ADR threshold
    bool  isSignif   = na(lastPivotLvl) or math.abs(ph - lastPivotLvl) >= adrAtPivot

    if isSignif and not f_isMerged(ph, allLvl)
        l = line.new(bar_index - LB, ph, bar_index + extendBars, ph,
                     color=lineCol, width=lineWid, style=lStyle, extend=extend.none)
        array.unshift(allLvl,  ph)
        array.unshift(allLine, l)
        lastPivotLvl := ph
        while array.size(allLvl) > maxPivots
            line.delete(array.pop(allLine))
            array.pop(allLvl)

// ─── REGISTER PIVOT LOW ───────────────────────────────────────────────────────
if not na(pl)
    float adrAtPivot = adr[LB]
    bool  isSignif   = na(lastPivotLvl) or math.abs(pl - lastPivotLvl) >= adrAtPivot

    if isSignif and not f_isMerged(pl, allLvl)
        l = line.new(bar_index - LB, pl, bar_index + extendBars, pl,
                     color=lineCol, width=lineWid, style=lStyle, extend=extend.none)
        array.unshift(allLvl,  pl)
        array.unshift(allLine, l)
        lastPivotLvl := pl
        while array.size(allLvl) > maxPivots
            line.delete(array.pop(allLine))
            array.pop(allLvl)

// ─── ROLL x2 EVERY BAR (keeps right edge = current bar + extendBars) ──────────
if array.size(allLine) > 0
    for i = 0 to array.size(allLine) - 1
        line.set_x2(array.get(allLine, i), bar_index + extendBars)

// ─── BREAKOUT SIGNALS ─────────────────────────────────────────────────────────
bool brkUp   = false
bool brkDown = false

if array.size(allLvl) > 0
    for i = 0 to array.size(allLvl) - 1
        float lvl = array.get(allLvl, i)
        if close > lvl + brkThresh
            brkUp   := true
        if close < lvl - brkThresh
            brkDown := true

plotshape(brkUp   and not brkUp[1],
          title="Bullish Breakout", style=shape.triangleup,
          location=location.belowbar, color=color.new(color.green, 0), size=size.small)

plotshape(brkDown and not brkDown[1],
          title="Bearish Breakout", style=shape.triangledown,
          location=location.abovebar, color=color.new(color.red, 0), size=size.small)
````
