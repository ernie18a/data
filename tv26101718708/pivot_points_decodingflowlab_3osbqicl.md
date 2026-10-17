# Pivot Points [DecodingFlowLab]

- url: https://www.tradingview.com/script/3oSBqiCL-Pivot-Points-DecodingFlowLab/
- type: indicator
- pine_id: PUB;73f27d66dbbf47baa399cc6856c5d9ad
- version: 1.0

## Description

Pivot Points [DecodingFlowLab]

A clean and lightweight pivot structure indicator designed to detect significant swing highs and swing lows directly from market structure.

This tool uses a symmetric pivot detection model based on a configurable depth value to identify confirmed turning points in price action.

━━━━━━━━━━━━━━
How It Works
━━━━━━━━━━━━━━

• The indicator scans both sides of the candle using the selected “Depth” value.

• A Pivot High is confirmed only when the candle’s high is greater than the highs of surrounding candles.

• A Pivot Low is confirmed only when the candle’s low is lower than the lows of surrounding candles.

• Signals are plotted only after confirmation to reduce market noise and false swings.

━━━━━━━━━━━━━━
Smart Filtering Logic
━━━━━━━━━━━━━━

The script includes an internal directional filtering mechanism:

• If a new higher pivot high appears, the previous pivot high is automatically replaced.

• If a new lower pivot low appears, the previous pivot low is replaced as well.

This creates a cleaner market structure view and prevents unnecessary duplicate pivots.

━━━━━━━━━━━━━━
Features
━━━━━━━━━━━━━━

✔ Clean visual swing detection
✔ Dynamic replacement of weaker pivots
✔ Adjustable pivot sensitivity using “Depth”
✔ Offset plotting to avoid candle overlap
✔ Lightweight and optimized
✔ Useful for market structure analysis
✔ Can assist with:
• Swing Trading
• Trend Analysis
• Liquidity Mapping
• BOS / CHOCH concepts
• Support & Resistance identification

━━━━━━━━━━━━━━
Inputs
━━━━━━━━━━━━━━

• Depth
Controls pivot sensitivity.
Higher values = stronger but fewer pivots.

• plotShift
Moves pivot markers away from candles for better chart visibility.

• Pivot Colors
Custom colors for highs and lows.

━━━━━━━━━━━━━━
Best Use Cases
━━━━━━━━━━━━━━

This indicator works especially well for:

• Market Structure traders
• Smart Money Concept (SMC) traders
• Swing traders
• Liquidity-based analysis
• Manual chart markup

━━━━━━━━━━━━━━
Important Note
━━━━━━━━━━━━━━

Because pivots require future candle confirmation, signals appear after the structure is confirmed.
This behavior is intentional and helps filter out weak or temporary swings.

Built by DecodingFlowLab.

Disclaimer

This indicator is provided for educational and informational purposes only and should not be considered financial advice, investment advice, or a recommendation to buy or sell any financial instrument.

The indicator does not provide guaranteed entry or exit signals for trading positions. Financial markets involve significant risk, and past performance does not guarantee future results.

Users are solely responsible for their own trading decisions, risk management, and use of this indicator in any market or trading environment.

The publisher, developer, and distributor of this indicator assume no responsibility or liability for any financial losses, damages, or outcomes resulting from the use or misuse of this indicator.

## Source Code

````pine
//@version=6
indicator("Pivot Points [DecodingFlowLab]", shorttitle="[DF_Lab] - Pivots Points", overlay=true, max_labels_count=500)


//-------------------------
// Inputs
//-------------------------
depth = input.int(20, "Depth", minval = 1)
plotShift = input.int(100, "plotShift", minval = 100)

highColor = input.color(color.green, "Pivot High Color")
lowColor  = input.color(color.red, "Pivot Low Color")

//-------------------------
// Pivot Calculation
//-------------------------
ph = ta.pivothigh(high, depth, depth)
pl = ta.pivotlow(low, depth, depth)

//-------------------------
// Variables
//-------------------------
var int   lastDirection  = 0
var float lastPivotPrice = na
var label lastLabel      = na

pivotBarIndex  = bar_index - depth
pivotHighPrice = high[depth]
pivotLowPrice  = low[depth]

//-------------------------
// Pivot High
//-------------------------
if not na(ph)

    bool drawHigh = true

    if lastDirection > 0
        if pivotHighPrice > lastPivotPrice
            label.delete(lastLabel)
        else
            drawHigh := false

    if drawHigh
        lastLabel := label.new(
             pivotBarIndex,
             (pivotHighPrice + syminfo.mintick * plotShift),
             "●", // ▼
             style = label.style_none,
             textcolor = highColor,
             color = color.new(highColor, 100),
             size = size.tiny
        )

        lastDirection  := 1
        lastPivotPrice := pivotHighPrice

//-------------------------
// Pivot Low
//-------------------------
if not na(pl)

    bool drawLow = true

    if lastDirection < 0
        if pivotLowPrice < lastPivotPrice
            label.delete(lastLabel)
        else
            drawLow := false

    if drawLow
        lastLabel := label.new(
             pivotBarIndex,
             (pivotLowPrice - syminfo.mintick * 2.5*plotShift),
             "●", // ▲
             style = label.style_none,
             textcolor = lowColor,
             color = color.new(lowColor, 100),
             size = size.tiny
        )

        lastDirection  := -1
        lastPivotPrice := pivotLowPrice
````
