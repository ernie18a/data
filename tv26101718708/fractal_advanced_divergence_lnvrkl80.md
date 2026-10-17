# Fractal Advanced Divergence

- url: https://www.tradingview.com/script/lnvrkL80-Fractal-Advanced-Divergence/
- type: indicator
- pine_id: PUB;54319d31138549c7b3809b1fcf78eba1
- version: 1.0

## Description

[b]FRACTAL ADVANCED DIVERGENCE — External Input (Raw): User Guide[/b]
[b]What It Is[/b]
This is a price-overlay divergence detector that uses [i]fractal pivot detection[/i] on the oscillator itself — rather than on price — to identify structurally significant turning points. It then checks whether price and the oscillator diverge at those fractals, applying OB/OS zone filtering and trendline intersection validation before confirming a signal.
The key differentiator is the [i]External Indicator[/i] input mode. Any indicator output on your chart can be piped directly into this script via TradingView’s source selector, and it will be used raw — no normalization, no rescaling. This means you can run divergence detection on custom oscillators, composite scores, or any numeric series without the script altering the values.
Lines and labels are drawn directly on the price chart (overlay mode), so divergences appear where you make trading decisions rather than in a separate pane.

[b]How It Works[/b]
[b][i]Step 1 — Fractal Detection on the Oscillator[/i][/b]
A fractal high is confirmed when the oscillator value at bar [i]n[/i] is strictly greater than the values on both sides for the specified lookback depth. A fractal low is the mirror — strictly less than all surrounding values. The default lookback is 2 bars on each side, meaning the fractal point must be the highest (or lowest) oscillator value in a 5-bar window.
This is different from most divergence detectors that use price-based pivot detection. By finding fractals on the oscillator, the pivots are anchored to momentum structure rather than price structure, which tends to produce cleaner divergence geometry.
[b][i]Step 2 — Pivot Storage and Comparison[/i][/b]
Each confirmed fractal is stored with its bar index, price value (high for tops, low for bottoms), and oscillator value. When a new fractal appears, it is compared against all stored historical pivots of the same type to find divergence candidates. The script searches backward through the stored pivots and checks for both regular and hidden divergence conditions.
[b][i]Step 3 — OB/OS Zone Filtering[/i][/b]
Both pivots (P1 and P2) must satisfy their respective overbought or oversold level requirements. For bullish divergences, both the first pivot’s oscillator value and the second pivot’s oscillator value must be below their oversold thresholds. For bearish divergences, both must be above their overbought thresholds. P1 and P2 have independent threshold inputs, allowing asymmetric filtering — for example, requiring P1 to be deeply oversold while allowing P2 to be only moderately oversold.
[b][i]Step 4 — Trendline Intersection Validation[/i][/b]
When enabled, the script draws a virtual line between P1 and P2 on both the price axis and the oscillator axis, then walks every bar in between checking whether the actual values cross the interpolated line. If a crossing is detected on either axis, the divergence is invalidated. This eliminates structurally broken divergences where price or the oscillator dipped through the connecting trendline mid-span, which would mean the divergence geometry was interrupted by an intermediate extreme.
[b][i]Step 5 — Visualization[/i][/b]
Valid divergences are drawn as solid lines on the price chart connecting the two pivot prices, with a label at P2. Invalidated divergences (those that failed the zone filter or intersection check) can optionally be shown as dim dotted ghost lines so you can see what was rejected.

[b]Divergence Types[/b]
[i]Regular Divergences[/i] — potential reversals:
[list]
[*] [b]Regular Bullish (B)[/b] — Price makes a lower low while the oscillator makes a higher low. Selling pressure is weakening. Labeled “B” below the bar.
[*] [b]Regular Bearish (S)[/b] — Price makes a higher high while the oscillator makes a lower high. Buying pressure is weakening. Labeled “S” above the bar.
[/list]

[i]Hidden Divergences[/i] — trend continuation (disabled by default):
[list]
[*] [b]Hidden Bullish (H)[/b] — Price makes a higher low while the oscillator makes a lower low. The uptrend is absorbing selling momentum. Labeled “H” below the bar.
[*] [b]Hidden Bearish (H)[/b] — Price makes a lower high while the oscillator makes a higher high. The downtrend is absorbing buying momentum. Labeled “H” above the bar.
[/list]

[b]The External Input Mode[/b]
When “External Indicator” is selected as the oscillator type, the script reads whatever source is connected to the “External Indicator Input” dropdown and uses it with zero transformation. This opens up several workflows:
[list]
[*] Pipe in a custom oscillator you have built separately and run fractal divergence detection on it without duplicating logic.
[*] Attach a composite indicator (like a weighted multi-oscillator blend) and detect divergences on the fused output.
[*] Connect any numeric plot from any indicator — volume delta, orderflow imbalance, a custom momentum score — and the script will find fractals and divergences on it directly.
[/list]

When using external inputs, you will need to adjust the OB/OS levels to match the range of whatever indicator you connect. The defaults of 30/70 are appropriate for RSI and Stochastic but will need to be changed for indicators with different scales (CCI, MACD, or custom scores).

[b]Inputs[/b]
[i]Oscillator Settings[/i]
[list]
[*] [b]Oscillator Type[/b] — RSI, CCI, Stochastic, MACD, or External Indicator.
[*] [b]Length[/b] (default 14) — Period for the built-in oscillator types. Ignored when using External Indicator.
[*] [b]Source[/b] — Price source for RSI and CCI calculations.
[*] [b]External Indicator Input[/b] — The source selector for piping in any external indicator. Only active when “External Indicator” is selected as the type.
[/list]

[i]Fractal Settings[/i]
[list]
[*] [b]Fractal Lookback Bars[/b] (default 2) — How many bars on each side of the candidate must be strictly lower (for a top fractal) or higher (for a bottom fractal). A value of 2 means a 5-bar window. Higher values produce fewer but more structurally significant pivots.
[/list]

[i]OS/OB Filter Settings[/i]
[list]
[*] [b]Oversold Level for P1[/b] (default 30) — The first pivot in a bullish divergence must have an oscillator value below this.
[*] [b]Oversold Level for P2[/b] (default 30) — The second pivot in a bullish divergence must be below this.
[*] [b]Overbought Level for P1[/b] (default 70) — The first pivot in a bearish divergence must be above this.
[*] [b]Overbought Level for P2[/b] (default 70) — The second pivot in a bearish divergence must be above this.
[*] [b]Max Historical Pivots[/b] (default 30) — How many past pivots to store and compare against. Higher values find divergences across longer spans but increase computation.
[*] [b]Min Bars Between Pivots[/b] (default 5) — Minimum distance between P1 and P2 to prevent trivially close divergences.
[*] [b]Validate No Intersection[/b] (default on) — Enables the trendline crossing check between P1 and P2 on both price and oscillator axes.
[/list]

[i]Divergence Types[/i]
[list]
[*] [b]Regular Divergences[/b] (default on) — Enable detection of regular bullish and bearish divergences.
[*] [b]Hidden Divergences[/b] (default off) — Enable detection of hidden bullish and bearish divergences.
[/list]

[i]Visual Settings[/i]
[list]
[*] [b]Bullish/Bearish Color[/b] — Line and label colors for each divergence direction.
[*] [b]Show Invalidated Signals[/b] (default on) — When enabled, divergences that failed the OB/OS or intersection filter are drawn as faint dotted ghost lines.
[*] [b]Ghost Transparency[/b] (default 80) — How transparent the ghost lines appear. Higher = more faded.
[/list]

[b]Reading the Chart[/b]
[list]
[*] [b]Solid lines[/b] connecting two price points with a colored label = confirmed divergences that passed all filters.
[*] [b]Dotted faint lines[/b] without labels (or with ghost transparency) = invalidated divergences that failed the zone filter or intersection check. Only visible when “Show Invalidated Signals” is enabled.
[*] [b]“B” label below a bar[/b] = Regular Bullish divergence confirmed.
[*] [b]“S” label above a bar[/b] = Regular Bearish divergence confirmed.
[*] [b]“H” label[/b] = Hidden divergence confirmed (below bar for bullish, above for bearish), drawn with slightly more transparency than regular signals.
[/list]

The oscillator itself is plotted in a separate pane (display.pane) with the OB/OS reference lines so you can cross-reference the divergence geometry against the oscillator visually.
The info table in the top-right corner shows the active oscillator type, current oscillator value, and the OB/OS levels in use.

[b]How to Use It[/b]
[i]As a standalone reversal detector:[/i] Enable only regular divergences with the default RSI settings. Bullish divergences at oversold extremes mark potential bottoms. Bearish divergences at overbought extremes mark potential tops. The intersection validation ensures the divergence geometry is clean.
[i]With an external composite indicator:[/i] Build a custom oscillator in a separate script (or use one of your existing indicators), select “External Indicator” as the type, and connect the output. Adjust OB/OS levels to match the indicator’s scale. This lets you run divergence detection on signals that no built-in oscillator can produce — volume-weighted momentum, multi-timeframe composites, or entropy-based measures.
[i]As a ghost signal researcher:[/i] Enable “Show Invalidated Signals” and study which divergences failed and why. If you see clusters of ghost divergences followed by a valid one, it often means the market tested the divergence setup multiple times before the conditions aligned — the valid signal after a ghost cluster tends to be higher conviction.
[i]Tuning P1/P2 levels independently:[/i] Setting P1 oversold deeper than P2 (for example, P1 at 25 and P2 at 35) allows the first pivot to anchor in a deeper extreme while the second pivot can be shallower. This captures the common pattern where the oscillator’s second low is higher but not necessarily still in the traditional oversold zone.

[b]Design Notes[/b]
[list]
[*] Fractal detection runs on the oscillator rather than on price. This produces pivots that are structurally meaningful to momentum rather than to price action, which is the relevant axis for divergence analysis.
[*] The intersection validation checks both the price trendline and the oscillator trendline independently. A crossing on either axis invalidates the divergence, since both axes must maintain clean geometry for the signal to be structurally sound.
[*] The External Indicator input applies zero transformation — no min-max rescaling, no percentile ranking, no Z-scoring. Whatever value the external source produces is the value used for fractal detection and OB/OS comparison. This means you are fully responsible for ensuring your OB/OS levels match the external indicator’s range.
[*] The script searches all stored historical pivots for each new fractal, not just the most recent one. This means it can find divergences that span longer timeframes when a suitable P1 exists further back in history, up to the Max Historical Pivots limit.
[/list]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Cmo22

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Fractal Divergence with Raw External Input

//@version=5
indicator("Fractal Advanced Divergence - External Input (Raw)", 
         overlay=true, 
         max_lines_count=500, 
         max_labels_count=500)

// ═════════════════════════════════════════════════════════════════════════════
// INPUTS
// ═════════════════════════════════════════════════════════════════════════════

grp_osc = "Oscillator Settings"
osc_type = input.string("RSI", "Oscillator Type", options=["RSI", "CCI", "Stochastic", "MACD", "External Indicator"], group=grp_osc)
osc_length = input.int(14, "Length (for built-in types)", minval=1, group=grp_osc)
src_custom = input.source(close, "Source (for RSI/CCI)", group=grp_osc)
// Raw external input - no processing applied
external_osc = input.source(close, "External Indicator Input", tooltip="Attach any external indicator output here - used raw without transformation", group=grp_osc)

grp_frac = "Fractal Settings"
fractal_bars = input.int(2, "Fractal Lookback Bars", minval=1, maxval=5, group=grp_frac)

grp_filt = "OS/OB Filter Settings (P1=First Pivot, P2=Second Pivot)"
os = input.float(30.0, "Oversold Level for P1 (Bullish)", group=grp_filt)
os2 = input.float(30.0, "Oversold Level for P2 (Bullish)", group=grp_filt)
ob = input.float(70.0, "Overbought Level for P1 (Bearish)", group=grp_filt)
ob2 = input.float(70.0, "Overbought Level for P2 (Bearish)", group=grp_filt)
maxPivotsToStore = input.int(30, "Max Historical Pivots", minval=2, group=grp_filt)
minBarsBetweenPivots = input.int(5, "Min Bars Between Pivots", minval=1, group=grp_filt)
checkIntersection = input.bool(true, "Validate No Intersection", group=grp_filt)

grp_div = "Divergence Types"
show_regular = input.bool(true, "Regular Divergences", group=grp_div)
show_hidden = input.bool(false, "Hidden Divergences", group=grp_div)

grp_vis = "Visual Settings"
bull_color = input.color(color.new(#00d084, 0), "Bullish Color", group=grp_vis)
bear_color = input.color(color.new(#ff4757, 0), "Bearish Color", group=grp_vis)
show_ghost = input.bool(true, "Show Invalidated Signals", group=grp_vis)
ghost_transp = input.int(80, "Ghost Transparency", minval=0, maxval=100, group=grp_vis)

// ═════════════════════════════════════════════════════════════════════════════
// FUNCTIONS
// ═════════════════════════════════════════════════════════════════════════════

f_top_fractal(_src, _len) =>
    bool is_fractal = true
    for i = 1 to _len
        is_fractal := is_fractal and _src[_len] > _src[_len + i] and _src[_len] > _src[_len - i]
    is_fractal

f_bot_fractal(_src, _len) =>
    bool is_fractal = true
    for i = 1 to _len
        is_fractal := is_fractal and _src[_len] < _src[_len + i] and _src[_len] < _src[_len - i]
    is_fractal

f_rma(_src, _len) =>
    alpha = 1.0 / _len
    sum = 0.0
    sum := nz(_src[1] * alpha + sum[1] * (1 - alpha), _src)

f_rsi(_src, _len) =>
    diff = ta.change(_src)
    up = f_rma(math.max(diff, 0), _len)
    down = f_rma(-math.min(diff, 0), _len)
    down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

// Get oscillator value - external indicator used RAW without modification
f_get_oscillator() =>
    float osc = na
    if osc_type == "RSI"
        osc := f_rsi(src_custom, osc_length)
    else if osc_type == "CCI"
        osc := ta.cci(src_custom, osc_length)
    else if osc_type == "Stochastic"
        osc := ta.stoch(close, high, low, osc_length)
    else if osc_type == "MACD"
        [macdLine, _, _] = ta.macd(close, 12, 26, 9)
        osc := macdLine
    else if osc_type == "External Indicator"
        osc := external_osc  // Used exactly as provided
    osc

// ═════════════════════════════════════════════════════════════════════════════
// CALCULATIONS
// ═════════════════════════════════════════════════════════════════════════════

float osc_value = f_get_oscillator()

// Fractal detection directly on oscillator value (no normalization)
osc_fractal_top = f_top_fractal(osc_value, fractal_bars)
osc_fractal_bot = f_bot_fractal(osc_value, fractal_bars)

int offset = fractal_bars

// Capture values at fractal confirmation
float curr_osc_top = osc_fractal_top ? osc_value[offset] : na
float curr_osc_bot = osc_fractal_bot ? osc_value[offset] : na
float curr_price_top = osc_fractal_top ? high[offset] : na
float curr_price_bot = osc_fractal_bot ? low[offset] : na
int curr_bar_top = osc_fractal_top ? bar_index[offset] : na
int curr_bar_bot = osc_fractal_bot ? bar_index[offset] : na

// ═════════════════════════════════════════════════════════════════════════════
// ARRAY STORAGE
// ═════════════════════════════════════════════════════════════════════════════

var int[]   pivotLow_bars   = array.new_int()
var float[] pivotLow_prices = array.new_float()
var float[] pivotLow_rsis   = array.new_float()

var int[]   pivotHigh_bars   = array.new_int()
var float[] pivotHigh_prices = array.new_float()
var float[] pivotHigh_rsis   = array.new_float()

var bool newBullishSignal = false
var bool newBearishSignal = false
newBullishSignal := false
newBearishSignal := false

// ═════════════════════════════════════════════════════════════════════════════
// BULLISH DIVERGENCE LOGIC
// ═════════════════════════════════════════════════════════════════════════════

if not na(curr_osc_bot)
    int P2_bar = curr_bar_bot
    float P2_price = curr_price_bot
    float P2_rsi = curr_osc_bot
    
    bool foundValid = false
    
    if array.size(pivotLow_bars) > 0
        for i = 0 to array.size(pivotLow_bars) - 1
            if i >= array.size(pivotLow_prices) or i >= array.size(pivotLow_rsis)
                continue
            
            int P1_bar = array.get(pivotLow_bars, i)
            float P1_price = array.get(pivotLow_prices, i)
            float P1_rsi = array.get(pivotLow_rsis, i)
            
            if P2_bar <= P1_bar or (P2_bar - P1_bar < minBarsBetweenPivots)
                continue
            
            bool isRegular = (P2_price < P1_price) and (P2_rsi > P1_rsi) and show_regular
            bool isHidden = (P2_price > P1_price) and (P2_rsi < P1_rsi) and show_hidden
            
            if not (isRegular or isHidden)
                continue
            
            // Raw comparison against user-defined levels
            bool p1_is_oversold = P1_rsi < os
            bool p2_is_oversold = P2_rsi < os2
            bool extremeFilter = p1_is_oversold and p2_is_oversold
            
            // Intersection validation
            bool noIntersection = true
            if checkIntersection
                delta_bars = P2_bar - P1_bar
                float price_slope = (P2_price - P1_price) / delta_bars
                float prev_dev = 0.0
                bool crossed = false
                
                for j = 1 to delta_bars - 1
                    int idx = bar_index - (P1_bar + j)
                    float expected_price = P1_price + price_slope * j
                    float actual_low = low[idx]
                    float dev = actual_low - expected_price
                    if j > 1 and math.sign(dev) != math.sign(prev_dev)
                        crossed := true
                    prev_dev := dev
                
                float rsi_slope = (P2_rsi - P1_rsi) / delta_bars
                prev_dev := 0.0
                for j = 1 to delta_bars - 1
                    int idx = bar_index - (P1_bar + j)
                    float expected_rsi = P1_rsi + rsi_slope * j
                    float actual_rsi = osc_value[idx]
                    float dev = actual_rsi - expected_rsi
                    if j > 1 and math.sign(dev) != math.sign(prev_dev)
                        crossed := true
                    prev_dev := dev
                
                noIntersection := not crossed
            
            if extremeFilter and noIntersection
                color lineColor = isRegular ? bull_color : color.new(bull_color, 40)
                string labelText = isRegular ? "B" : "H"
                
                line.new(P1_bar, P1_price, P2_bar, P2_price, xloc.bar_index, extend.none, 
                         color=lineColor, style=line.style_solid, width=2)
                label.new(P2_bar, P2_price, labelText, yloc=yloc.belowbar, 
                         style=label.style_label_up, color=color.new(bull_color, isRegular ? 0 : 50), 
                         textcolor=color.white, size=size.small)
                foundValid := true
                newBullishSignal := true
            else if show_ghost and (isRegular or isHidden)
                line.new(P1_bar, P1_price, P2_bar, P2_price, xloc.bar_index, extend.none, 
                         color=color.new(bull_color, ghost_transp), style=line.style_dotted, width=1)
    
    array.unshift(pivotLow_bars, P2_bar)
    array.unshift(pivotLow_prices, P2_price)
    array.unshift(pivotLow_rsis, P2_rsi)
    
    while array.size(pivotLow_bars) > maxPivotsToStore
        array.pop(pivotLow_bars)
        array.pop(pivotLow_prices)
        array.pop(pivotLow_rsis)

// ═════════════════════════════════════════════════════════════════════════════
// BEARISH DIVERGENCE LOGIC
// ═════════════════════════════════════════════════════════════════════════════

if not na(curr_osc_top)
    int P2_bar = curr_bar_top
    float P2_price = curr_price_top
    float P2_rsi = curr_osc_top
    
    bool foundValid = false
    
    if array.size(pivotHigh_bars) > 0
        for i = 0 to array.size(pivotHigh_bars) - 1
            if i >= array.size(pivotHigh_prices) or i >= array.size(pivotHigh_rsis)
                continue
            
            int P1_bar = array.get(pivotHigh_bars, i)
            float P1_price = array.get(pivotHigh_prices, i)
            float P1_rsi = array.get(pivotHigh_rsis, i)
            
            if P2_bar <= P1_bar or (P2_bar - P1_bar < minBarsBetweenPivots)
                continue
            
            bool isRegular = (P2_price > P1_price) and (P2_rsi < P1_rsi) and show_regular
            bool isHidden = (P2_price < P1_price) and (P2_rsi > P1_rsi) and show_hidden
            
            if not (isRegular or isHidden)
                continue
            
            // Raw comparison against user-defined levels
            bool p1_is_overbought = P1_rsi > ob
            bool p2_is_overbought = P2_rsi > ob2
            bool extremeFilter = p1_is_overbought and p2_is_overbought
            
            // Intersection validation
            bool noIntersection = true
            if checkIntersection
                delta_bars = P2_bar - P1_bar
                float price_slope = (P2_price - P1_price) / delta_bars
                float prev_dev = 0.0
                bool crossed = false
                
                for j = 1 to delta_bars - 1
                    int idx = bar_index - (P1_bar + j)
                    float expected_price = P1_price + price_slope * j
                    float actual_high = high[idx]
                    float dev = actual_high - expected_price
                    if j > 1 and math.sign(dev) != math.sign(prev_dev)
                        crossed := true
                    prev_dev := dev
                
                float rsi_slope = (P2_rsi - P1_rsi) / delta_bars
                prev_dev := 0.0
                for j = 1 to delta_bars - 1
                    int idx = bar_index - (P1_bar + j)
                    float expected_rsi = P1_rsi + rsi_slope * j
                    float actual_rsi = osc_value[idx]
                    float dev = actual_rsi - expected_rsi
                    if j > 1 and math.sign(dev) != math.sign(prev_dev)
                        crossed := true
                    prev_dev := dev
                
                noIntersection := not crossed
            
            if extremeFilter and noIntersection
                color lineColor = isRegular ? bear_color : color.new(bear_color, 40)
                string labelText = isRegular ? "S" : "H"
                
                line.new(P1_bar, P1_price, P2_bar, P2_price, xloc.bar_index, extend.none, 
                         color=lineColor, style=line.style_solid, width=2)
                label.new(P2_bar, P2_price, labelText, yloc=yloc.abovebar, 
                         style=label.style_label_down, color=color.new(bear_color, isRegular ? 0 : 50), 
                         textcolor=color.white, size=size.small)
                foundValid := true
                newBearishSignal := true
            else if show_ghost and (isRegular or isHidden)
                line.new(P1_bar, P1_price, P2_bar, P2_price, xloc.bar_index, extend.none, 
                         color=color.new(bear_color, ghost_transp), style=line.style_dotted, width=1)
    
    array.unshift(pivotHigh_bars, P2_bar)
    array.unshift(pivotHigh_prices, P2_price)
    array.unshift(pivotHigh_rsis, P2_rsi)
    
    while array.size(pivotHigh_bars) > maxPivotsToStore
        array.pop(pivotHigh_bars)
        array.pop(pivotHigh_prices)
        array.pop(pivotHigh_rsis)

// ═════════════════════════════════════════════════════════════════════════════
// DISPLAY
// ═════════════════════════════════════════════════════════════════════════════

// Plot raw oscillator value
plot(osc_value, "Oscillator Value", color=color.gray, display=display.pane)
hline(os, "OS Level", color=color.green, linestyle=hline.style_dashed)
hline(os2, "OS2 Level", color=color.new(color.green, 50), linestyle=hline.style_dotted)
hline(ob, "OB Level", color=color.red, linestyle=hline.style_dashed)
hline(ob2, "OB2 Level", color=color.new(color.red, 50), linestyle=hline.style_dotted)

// Info panel
var table info_table = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 80), 
     frame_width=1, frame_color=color.gray)

if barstate.islast
    table.cell(info_table, 0, 0, "Oscillator", text_color=color.white)
    table.cell(info_table, 1, 0, osc_type == "External Indicator" ? "External" : osc_type, text_color=color.yellow)
    table.cell(info_table, 0, 1, "Current Value", text_color=color.white)
    table.cell(info_table, 1, 1, str.tostring(osc_value, "#.##"), text_color=color.yellow)
    table.cell(info_table, 0, 2, "OS Levels", text_color=color.white)
    table.cell(info_table, 1, 2, str.tostring(os) + "/" + str.tostring(os2), text_color=color.green)
    table.cell(info_table, 0, 3, "OB Levels", text_color=color.white)
    table.cell(info_table, 1, 3, str.tostring(ob) + "/" + str.tostring(ob2), text_color=color.red)

// Alerts
alertcondition(newBullishSignal, "Bullish Divergence", "Bullish divergence confirmed")
alertcondition(newBearishSignal, "Bearish Divergence", "Bearish divergence confirmed")
alertcondition(newBullishSignal or newBearishSignal, "Any Divergence", "Divergence detected")
````
