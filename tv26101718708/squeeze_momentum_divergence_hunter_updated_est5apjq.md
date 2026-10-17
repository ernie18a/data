# Squeeze Momentum + Divergence Hunter (Updated)

- url: https://www.tradingview.com/script/EST5APjQ-Squeeze-Momentum-Divergence-Hunter-Updated/
- type: indicator
- pine_id: PUB;a376c3dfd4b2449e86db2723c1343029
- version: 1.0

## Description

LazyBear Squeeze momentum indicator with alerts for state change. Changed default colors too

## Source Code

````pine
//@version=6
indicator(shorttitle="SQZMOM + DIV", title="Squeeze Momentum + Divergence Hunter", overlay=false)

// ========================================================================= //
// --- 1. SQUEEZE MOMENTUM SETTINGS & MATH ---
// ========================================================================= //
grp_sqz = "Squeeze Engine Settings"
length       = input.int(20, title="BB Length", group=grp_sqz)
mult         = input.float(2.0, title="BB MultFactor", group=grp_sqz)
lengthKC     = input.int(20, title="KC Length", group=grp_sqz)
multKC       = input.float(1.5, title="KC MultFactor", group=grp_sqz)
useTrueRange = input.bool(true, title="Use TrueRange (KC)", group=grp_sqz)

// Calculate Bollinger Bands
source  = close
basis   = ta.sma(source, length)
dev     = mult * ta.stdev(source, length)
upperBB = basis + dev
lowerBB = basis - dev

// Calculate Keltner Channels
ma      = ta.sma(source, lengthKC)
range_1 = useTrueRange ? ta.tr : (high - low)
rangema = ta.sma(range_1, lengthKC)
upperKC = ma + rangema * multKC
lowerKC = ma - rangema * multKC

// Squeeze States
sqzOn  = (lowerBB > lowerKC) and (upperBB < upperKC)
sqzOff = (lowerBB < lowerKC) and (upperBB > upperKC)
noSqz  = (not sqzOn) and (not sqzOff)

// Momentum Histogram Math
highestHigh = ta.highest(high, lengthKC)
lowestLow   = ta.lowest(low, lengthKC)
avg_hl      = (highestHigh + lowestLow) / 2.0
avg_price   = (avg_hl + ta.sma(close, lengthKC)) / 2.0
val         = ta.linreg(source - avg_price, lengthKC, 0)

// Colors
bcolor = val > 0 ? (val > nz(val[1]) ? color.lime : color.green) : (val < nz(val[1]) ? color.red : color.maroon)
scolor = noSqz ? color.blue : sqzOn ? color.black : color.gray 

// Plot Original Squeeze
plot(val, color=bcolor, style=plot.style_histogram, linewidth=4, title="Momentum Histogram")
plot(0, color=scolor, style=plot.style_cross, linewidth=2, title="Squeeze State")

// ========================================================================= //
// --- 2. DIVERGENCE HUNTER ENGINE ---
// ========================================================================= //
grp_div = "Divergence Toggles & Thresholds"
useRegBull = input.bool(true, "Detect Regular Bullish Div", group=grp_div)
useHidBull = input.bool(true, "Detect Hidden Bullish Div", group=grp_div)
useRegBear = input.bool(true, "Detect Regular Bearish Div", group=grp_div)
useHidBear = input.bool(true, "Detect Hidden Bearish Div", group=grp_div)

min_dist = input.int(5, "Min Distance Between Waves", group=grp_div)
max_dist = input.int(60, "Max Distance Between Waves", group=grp_div)

// Curl Detection (Finding the Pivot Points on the Histogram)
val_curls_up = val > val[1] and val[1] < val[2]
val_curls_dn = val < val[1] and val[1] > val[2]

// State Trackers
var int trough_bar     = na
var float trough_val   = na
var float trough_price = na

var int peak_bar     = na
var float peak_val   = na
var float peak_price = na

// Signal Triggers
bool regBull = false
bool hidBull = false
bool regBear = false
bool hidBear = false

// --- Evaluate Bullish Divergences (Troughs) ---
if val_curls_up
    int cur_trough_bar     = bar_index - 1
    float cur_trough_val   = val[1]
    float cur_trough_price = low[1]
    
    if not na(trough_bar)
        int bars_passed = cur_trough_bar - trough_bar
        if bars_passed >= min_dist and bars_passed <= max_dist
            // Both troughs should ideally be below the zero line for a valid bottom setup
            if cur_trough_val < 0 and trough_val < 0
                // Regular Bullish: Price makes Lower Low, Momentum makes Higher Low
                if cur_trough_price < trough_price and cur_trough_val > trough_val
                    regBull := true
                // Hidden Bullish: Price makes Higher Low, Momentum makes Lower Low
                if cur_trough_price > trough_price and cur_trough_val < trough_val
                    hidBull := true

    // Save current trough for the next wave
    trough_bar   := cur_trough_bar
    trough_val   := cur_trough_val
    trough_price := cur_trough_price

// --- Evaluate Bearish Divergences (Peaks) ---
if val_curls_dn
    int cur_peak_bar     = bar_index - 1
    float cur_peak_val   = val[1]
    float cur_peak_price = high[1]
    
    if not na(peak_bar)
        int bars_passed = cur_peak_bar - peak_bar
        if bars_passed >= min_dist and bars_passed <= max_dist
            // Both peaks should ideally be above the zero line for a valid top setup
            if cur_peak_val > 0 and peak_val > 0
                // Regular Bearish: Price makes Higher High, Momentum makes Lower High
                if cur_peak_price > peak_price and cur_peak_val < peak_val
                    regBear := true
                // Hidden Bearish: Price makes Lower High, Momentum makes Higher High
                if cur_peak_price < peak_price and cur_peak_val > peak_val
                    hidBear := true

    // Save current peak for the next wave
    peak_bar   := cur_peak_bar
    peak_val   := cur_peak_val
    peak_price := cur_peak_price

// ========================================================================= //
// --- 3. VISUALS & ALERTS ---
// ========================================================================= //
// Using absolute location & an offset of -1 so the labels paint directly on the peak/trough bar
plotshape(useRegBull and regBull ? val[1] : na, title="Reg Bull Div", text="DIV", style=shape.labelup, location=location.absolute, color=color.new(color.lime, 0), textcolor=color.black, size=size.tiny, offset=-1)
plotshape(useHidBull and hidBull ? val[1] : na, title="Hid Bull Div", text="HDIV", style=shape.labelup, location=location.absolute, color=color.new(color.orange, 0), textcolor=color.black, size=size.tiny, offset=-1)

plotshape(useRegBear and regBear ? val[1] : na, title="Reg Bear Div", text="DIV", style=shape.labeldown, location=location.absolute, color=color.new(color.red, 0), textcolor=color.white, size=size.tiny, offset=-1)
plotshape(useHidBear and hidBear ? val[1] : na, title="Hid Bear Div", text="HDIV", style=shape.labeldown, location=location.absolute, color=color.new(color.fuchsia, 0), textcolor=color.white, size=size.tiny, offset=-1)

alertcondition(regBull, title="Regular Bullish Div", message="Regular Bullish Divergence on Squeeze Mom")
alertcondition(hidBull, title="Hidden Bullish Div",  message="Hidden Bullish Divergence on Squeeze Mom")
alertcondition(regBear, title="Regular Bearish Div", message="Regular Bearish Divergence on Squeeze Mom")
alertcondition(hidBear, title="Hidden Bearish Div",  message="Hidden Bearish Divergence on Squeeze Mom")
// ========================================================================= //
// --- 4. SQUEEZE STATE ALERTS ---
// ========================================================================= //
// Detecting the transition from Color 1 (Black/sqzOn) to Color 2 (Gray/sqzOff)
sqz_fired   = sqzOn[1] and sqzOff

// Detecting the transition from Color 2 (Gray/sqzOff) back to Color 1 (Black/sqzOn)
sqz_started = sqzOff[1] and sqzOn

alertcondition(sqz_fired, title="Squeeze Fired (Black to Gray)", message="Squeeze Momentum has fired! (Black to Gray)")
alertcondition(sqz_started, title="Squeeze Started (Gray to Black)", message="New Squeeze is forming! (Gray to Black)")
````
