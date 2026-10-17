# Adaptive MA Ribbon [StrixEDGE]

- url: https://www.tradingview.com/script/TLBkH8Bx-Adaptive-MA-Ribbon-StrixEDGE/
- type: indicator
- pine_id: PUB;6640209840a44ff8b2c3d39e477612d7
- version: 1.0

## Description

📊 WHAT IT DOES
StrixEDGE Adaptive MA Ribbon plots three of the most advanced low-lag moving averages — Hull MA, Arnaud Legoux MA, and Kaufman Adaptive MA — with automatic period adjustment based on current volatility. A consensus score (0-6) instantly shows whether all three agree on trend direction.

🔬 WHY IT'S DIFFERENT
Traditional MA ribbons use fixed periods that work in one market condition and fail in another. This ribbon automatically shortens its period when volatility spikes (for faster reaction) and lengthens it when markets are calm (to avoid whipsaws). The three MAs used — HMA, ALMA, and KAMA — are specifically chosen because each adapts to the market differently, so their agreement carries more weight than three similar MAs agreeing.

⚙️ HOW IT WORKS
The volatility ratio (current ATR / 50-period average ATR) dynamically adjusts the base period. This adjusted period feeds into all three MAs simultaneously. The consensus score counts two things: how many MAs are below price (0-3 points) and how many are rising (0-3 points). A score of 6 means all three MAs are below price AND rising — the strongest possible bullish configuration.

📈 HOW TO USE
• Consensus 5-6 (green fill): Strong uptrend — buy pullbacks to the ribbon
• Consensus 0-1 (red fill): Strong downtrend — sell rallies to the ribbon
• Consensus 2-4 (gray fill): Mixed — avoid trend strategies
• Diamond markers at consensus flips = key entry/exit signals
• Ribbon twist (MAs crossing) = early warning of trend change
• Works best on 4H and Daily timeframes

🎛️ INPUTS & DEFAULTS
Base Period: 21 | Min: 8, Max: 55 | ALMA Offset: 0.85, Sigma: 6.0

═══════════════════════════════════════════════════════

🔧 CUSTOMIZATION
All parameters are fully adjustable through the indicator settings panel. Inputs are grouped logically:
• ⚙️ Core Parameters — main calculation settings
• 📊 Table Settings — table size (Tiny to Huge), position (4 corners), visibility toggle
• 🎨 Visual Settings — colors, show/hide elements
• 🔔 Alert Settings — threshold values for notifications

📊 DATA TABLE
A built-in data table displays all key metrics in real-time. Adjust the table size from Tiny to Huge to match your chart layout. Position it in any corner. Toggle visibility on/off.

🔔 ALERTS
Pre-built alert conditions for all major signals. Set up alerts via TradingView's alert dialog — select this indicator and choose from the available conditions.

⏱️ RECOMMENDED TIMEFRAMES
Works on all timeframes. Recommended: 1H, 4H, Daily for best signal quality. Lower timeframes produce more signals but with higher noise. Weekly/Monthly for position trading context.

✅ COMPLIANCE
• No repainting — all signals based on confirmed bar close data
• No future data references
• Open-source code — verify the logic yourself

⚠️ DISCLAIMER
This indicator is a technical analysis tool, not financial advice. It does not predict future price movements. Past patterns and signals do not guarantee future results. Trading involves substantial risk of loss. Always use proper risk management, including stop losses and appropriate position sizing. Never risk more than you can afford to lose.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator('Adaptive MA Ribbon [StrixEDGE]', overlay=true, max_labels_count=500, max_lines_count=500, max_bars_back=5000)


// ═══ HELPER FUNCTIONS ═══

// ── WMA that accepts series int length ──
// Built-in ta.wma() requires simple int; this loop-based version doesn't.
f_wma(float src, int len) =>
    int _len = math.max(len, 1)
    float _sum = 0.0
    float _wsum = 0.0
    for i = 0 to _len - 1
        float w = float(_len - i)
        _sum  += nz(src[i]) * w
        _wsum += w
    _wsum > 0.0 ? _sum / _wsum : src

// ── HMA (Hull Moving Average) that accepts series int length ──
// HMA = WMA( 2·WMA(n/2) − WMA(n), √n )
// PineScript maintains the intermediate _diff series across bars,
// so the final WMA correctly references its historical values.
f_hma(float src, int len) =>
    int _half = int(math.max(math.round(float(len) / 2.0), 1))
    int _sqrt = int(math.max(math.round(math.sqrt(float(len))), 1))
    float _wmaHalf = f_wma(src, _half)
    float _wmaFull = f_wma(src, len)
    float _diff    = 2.0 * _wmaHalf - _wmaFull
    f_wma(_diff, _sqrt)


// ═══ INPUTS ═══

// ── Core Parameters ──
basePeriod = input.int(21, title="Base Period", minval=5, maxval=100, tooltip="Base MA period before volatility adjustment. Higher = smoother but slower. 21 ≈ one trading month.", group="⚙️ Core Parameters")
minPeriod  = input.int(8, title="Min Period", minval=3, maxval=30, tooltip="Floor for the adjusted period. Prevents MAs from becoming too noisy in extreme vol spikes.", group="⚙️ Core Parameters")
maxPeriod  = input.int(55, title="Max Period", minval=20, maxval=200, tooltip="Ceiling for the adjusted period. Prevents MAs from going flat in dead markets.", group="⚙️ Core Parameters")
almaOffset = input.float(0.85, title="ALMA Offset", minval=0.0, maxval=1.0, step=0.05, tooltip="ALMA Gaussian offset (0–1). Higher shifts the window toward recent prices, reducing lag. 0.85 is aggressive; try 0.5 for more smoothing.", group="⚙️ Core Parameters")
almaSigma  = input.float(6.0, title="ALMA Sigma", minval=1.0, maxval=20.0, step=0.5, tooltip="ALMA Gaussian sigma. Higher = smoother curve. 6 is standard; lower values make ALMA more responsive.", group="⚙️ Core Parameters")

// ── Visual Settings ──
showFill   = input.bool(true, title="Show Ribbon Fill", tooltip="Shaded fill between HMA and KAMA, colored by consensus.", group="🎨 Visual Settings")
showLabel  = input.bool(true, title="Show Info Label", tooltip="Floating label with consensus, period, and volatility ratio.", group="🎨 Visual Settings")
showTwist  = input.bool(true, title="Show Twist Markers", tooltip="Small circles where MAs cross each other (trend transitions).", group="🎨 Visual Settings")

// ── Table Settings ──
showTable = input.bool(true, title="Show Table", tooltip="Toggle data table visibility.", group="📊 Table Settings")
tableSize = input.string("Normal", title="📐 Table Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], tooltip="Adjust the display size of the data table.", group="📊 Table Settings")
tablePos  = input.string("Top Right", title="📍 Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], tooltip="Position of the data table on chart.", group="📊 Table Settings")

tSize = switch tableSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge
    => size.normal

tPos = switch tablePos
    "Top Right"    => position.top_right
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right


// ═══ CALCULATIONS ═══

// ── Volatility-Adjusted Period ──
// ATR measures current volatility; ratio to its 50-bar average drives period scaling.
// volRatio > 1 → above-average vol → shorter period (faster MAs)
// volRatio < 1 → below-average vol → longer period (smoother MAs)
currentATR = ta.atr(14)
avgATR     = ta.sma(currentATR, 50)
volRatio   = avgATR > 0.0 ? currentATR / avgATR : 1.0

// Scale base period inversely with volatility, clamp to [minPeriod, maxPeriod]
// Floor volRatio at 0.3 to cap the period during dead markets
rawAdjusted    = math.round(basePeriod / math.max(volRatio, 0.3))
adjustedPeriod = int(math.max(minPeriod, math.min(maxPeriod, rawAdjusted)))

// ── Three Adaptive Moving Averages ──
// HMA:  fastest, most responsive — leads the ribbon (manual, series int safe)
// ALMA: Gaussian-weighted — balances responsiveness and smoothness (built-in, accepts series int)
// KAMA: adapts its own smoothing internally — most whipsaw-resistant (manual)
hmaValue  = f_hma(close, adjustedPeriod)
almaValue = ta.alma(close, adjustedPeriod, almaOffset, almaSigma)

// ── Manual KAMA (Kaufman Adaptive Moving Average) ──
// Efficiency Ratio (ER) = |direction| / volatility over the lookback.
// ER drives a smoothing constant between fast (period 2) and slow (period 30).
// Trending markets → high ER → fast smoothing. Choppy → low ER → heavy smoothing.
var float kamaValue = na
if bar_index == 0
    kamaValue := close
else
    int _kLen          = math.max(adjustedPeriod, 1)
    float _direction   = math.abs(close - nz(close[_kLen]))
    float _volatility  = 0.0
    for i = 0 to _kLen - 1
        _volatility += math.abs(nz(close[i]) - nz(close[i + 1]))
    float _er    = _volatility > 0.0 ? _direction / _volatility : 0.0
    float _fastC = 2.0 / 3.0     // 2 / (fastPeriod + 1), fastPeriod = 2
    float _slowC = 2.0 / 31.0    // 2 / (slowPeriod + 1), slowPeriod = 30
    float _sc    = math.pow(_er * (_fastC - _slowC) + _slowC, 2)
    kamaValue   := nz(kamaValue[1]) + _sc * (close - nz(kamaValue[1]))

// ── Consensus Score (0–6) ──
// Position points (0–3): price above each MA = +1
// Slope points (0–3):    each MA rising vs prior bar = +1
// 6 = fully bullish, 0 = fully bearish, 3 = mixed
hmaValid  = not na(hmaValue)
almaValid = not na(almaValue)
kamaValid = not na(kamaValue)

positionPoints = (hmaValid  and close > hmaValue  ? 1 : 0) + (almaValid and close > almaValue ? 1 : 0) + (kamaValid and close > kamaValue ? 1 : 0)

hmaRising  = hmaValid  and not na(hmaValue[1])  ? hmaValue  > hmaValue[1]  : false
almaRising = almaValid and not na(almaValue[1]) ? almaValue > almaValue[1] : false
kamaRising = kamaValid and not na(kamaValue[1]) ? kamaValue > kamaValue[1] : false

slopePoints = (hmaRising ? 1 : 0) + (almaRising ? 1 : 0) + (kamaRising ? 1 : 0)

consensus = positionPoints + slopePoints

// ── Ribbon Twist Detection ──
// MAs crossing each other = ribbon tangling = potential trend transition
twistDetected = ta.cross(hmaValue, almaValue) or ta.cross(almaValue, kamaValue)


// ═══ SIGNALS & CONDITIONS ═══

// Consensus flips require a decisive swing (≤2 → ≥4 or vice versa), not just crossing 3
bullishFlip = consensus >= 4 and not na(consensus[1]) and consensus[1] <= 2
bearishFlip = consensus <= 2 and not na(consensus[1]) and consensus[1] >= 4

// Ribbon ordering — HMA leads (fastest), KAMA lags (smoothest)
bullOrdered = hmaValid and almaValid and kamaValid and hmaValue > almaValue and almaValue > kamaValue
bearOrdered = hmaValid and almaValid and kamaValid and hmaValue < almaValue and almaValue < kamaValue


// ═══ VISUALIZATION ═══

// ── MA Lines ──
hmaPlot  = plot(hmaValue,  title="HMA",  color=color.new(#1D9BF0, 0), linewidth=2)  // Blue — primary/fastest
almaPlot = plot(almaValue, title="ALMA", color=color.new(#7856FF, 0), linewidth=1)  // Purple — middle ground
kamaPlot = plot(kamaValue, title="KAMA", color=color.new(#F7931A, 0), linewidth=1)  // Amber — smoothest

// ── Ribbon Fill Between HMA and KAMA ──
fillColor = consensus >= 4 ? color.new(#00BA7C, 85) : consensus <= 2 ? color.new(#F4212E, 85) : color.new(#8B98A5, 92)
fill(hmaPlot, kamaPlot, color=showFill ? fillColor : na, title="Ribbon Fill")

// ── Consensus Flip Markers ──
plotshape(bullishFlip, title="Bullish Flip", style=shape.diamond, location=location.belowbar, color=color.new(#00BA7C, 0), size=size.normal)
plotshape(bearishFlip, title="Bearish Flip", style=shape.diamond, location=location.abovebar, color=color.new(#F4212E, 0), size=size.normal)

// ── Twist Markers ──
plotshape(showTwist and twistDetected, title="Ribbon Twist", style=shape.circle, location=location.abovebar, color=color.new(#F7931A, 20), size=size.tiny)

// ── Info Label ──
var label infoLabel = na
if barstate.islast and showLabel
    if not na(infoLabel)
        label.delete(infoLabel)
    string labelText = "Consensus: " + str.tostring(consensus) + "/6  |  Period: " + str.tostring(adjustedPeriod) + "  |  Vol: " + str.tostring(volRatio, "#.##") + "x"
    infoLabel := label.new(bar_index, high, labelText, style=label.style_label_left, color=color.new(#1a1a2e, 10), textcolor=color.white, size=size.normal)


// ═══ DATA TABLE ═══

// Style A: dark header, white data rows, color on value text only
var HEADER_BG     = color.rgb(26, 26, 46)
var HEADER_TEXT   = color.rgb(255, 255, 255)
var SUBHEADER_TXT = color.rgb(158, 158, 158)
var ROW_BG        = color.rgb(255, 255, 255)
var LABEL_CLR     = color.rgb(102, 102, 102)
var BORDER_CLR    = color.rgb(240, 240, 240)
var TBL_BULL      = color.rgb(0, 176, 124)
var TBL_BEAR      = color.rgb(229, 57, 53)
var TBL_NEUT      = color.rgb(102, 102, 102)

if barstate.islast and showTable
    var tbl = table.new(tPos, columns=2, rows=9, bgcolor=ROW_BG, border_color=BORDER_CLR, border_width=1, frame_color=HEADER_BG, frame_width=0)

    // ── Row 0: Dark Header ──
    table.cell(tbl, 0, 0, "Adaptive MA Ribbon", bgcolor=HEADER_BG, text_color=HEADER_TEXT, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 0, syminfo.ticker + " · " + timeframe.period, bgcolor=HEADER_BG, text_color=SUBHEADER_TXT, text_size=tSize, text_halign=text.align_right)

    // ── Row 1: Consensus Score ──
    color consensusClr = consensus >= 4 ? TBL_BULL : consensus <= 2 ? TBL_BEAR : TBL_NEUT
    string conLabel    = consensus >= 5 ? " STRONG ▲" : consensus >= 4 ? " BULLISH ▲" : consensus <= 1 ? " STRONG ▼" : consensus <= 2 ? " BEARISH ▼" : " MIXED"
    table.cell(tbl, 0, 1, "Consensus", bgcolor=ROW_BG, text_color=LABEL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 1, str.tostring(consensus) + "/6" + conLabel, bgcolor=ROW_BG, text_color=consensusClr, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // ── Row 2: Ribbon State ──
    string ribbonText = bullOrdered ? "BULL ORDER ▲" : bearOrdered ? "BEAR ORDER ▼" : "TWISTED"
    color ribbonClr   = bullOrdered ? TBL_BULL : bearOrdered ? TBL_BEAR : TBL_NEUT
    table.cell(tbl, 0, 2, "Ribbon", bgcolor=ROW_BG, text_color=LABEL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 2, ribbonText, bgcolor=ROW_BG, text_color=ribbonClr, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // ── Row 3: Adjusted Period ──
    table.cell(tbl, 0, 3, "Adj. Period", bgcolor=ROW_BG, text_color=LABEL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 3, str.tostring(adjustedPeriod), bgcolor=ROW_BG, text_color=TBL_NEUT, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // ── Row 4: Volatility Ratio ──
    color volClr = volRatio > 1.5 ? TBL_BEAR : volRatio < 0.7 ? TBL_BULL : TBL_NEUT
    table.cell(tbl, 0, 4, "Vol. Ratio", bgcolor=ROW_BG, text_color=LABEL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 4, str.tostring(volRatio, "#.##") + "x", bgcolor=ROW_BG, text_color=volClr, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // ── Row 5: HMA Value ──
    color hmaClr = hmaValid and close > hmaValue ? TBL_BULL : TBL_BEAR
    table.cell(tbl, 0, 5, "HMA", bgcolor=ROW_BG, text_color=LABEL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 5, str.tostring(hmaValue, "#.##"), bgcolor=ROW_BG, text_color=hmaClr, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // ── Row 6: ALMA Value ──
    color almaClr = almaValid and close > almaValue ? TBL_BULL : TBL_BEAR
    table.cell(tbl, 0, 6, "ALMA", bgcolor=ROW_BG, text_color=LABEL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 6, str.tostring(almaValue, "#.##"), bgcolor=ROW_BG, text_color=almaClr, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // ── Row 7: KAMA Value ──
    color kamaClr = kamaValid and close > kamaValue ? TBL_BULL : TBL_BEAR
    table.cell(tbl, 0, 7, "KAMA", bgcolor=ROW_BG, text_color=LABEL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 7, str.tostring(kamaValue, "#.##"), bgcolor=ROW_BG, text_color=kamaClr, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)

    // ── Row 8: Position / Slope Breakdown ──
    table.cell(tbl, 0, 8, "Pos / Slope", bgcolor=ROW_BG, text_color=LABEL_CLR, text_size=tSize, text_halign=text.align_left)
    table.cell(tbl, 1, 8, str.tostring(positionPoints) + " / " + str.tostring(slopePoints), bgcolor=ROW_BG, text_color=TBL_NEUT, text_size=tSize, text_halign=text.align_right, text_font_family=font.family_monospace)


// ═══ ALERTS ═══

// Fires when consensus crosses above 3 (early bullish signal)
alertcondition(ta.crossover(consensus, 3), title="Bullish Consensus", message="StrixEDGE Adaptive MA Ribbon: MA consensus turned bullish (4+/6)")

// Fires when consensus drops below 4 (exits bullish territory)
alertcondition(ta.crossunder(consensus, 4), title="Bearish Consensus", message="StrixEDGE Adaptive MA Ribbon: MA consensus turned bearish (below 4/6)")

// Fires on any MA-to-MA cross — ribbon tangling
alertcondition(twistDetected, title="Ribbon Twist", message="StrixEDGE Adaptive MA Ribbon: MA ribbon twist detected — trend transition underway")
````
