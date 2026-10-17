# Inversion Fair Value Gaps with Volatility & Sweeps AT

- url: https://www.tradingview.com/script/h9sM79zq-Inversion-Fair-Value-Gaps-with-Volatility-Sweeps-AT/
- type: indicator
- pine_id: PUB;1ecd0dd79c3b44b697b927493048f18f
- version: 1.0

## Description

The IFVG & Liquidity Sweep indicator is an advanced market structure and liquidity analysis tool, specifically developed based on modern price action and smart money concepts. The indicator aims to help traders identify the traces left by larger players, with a particular focus on inefficiencies and liquidity-seeking moves.
The IFVG (Inverse Fair Value Gap) component focuses on identifying market imbalances. These are zones where rapid price movements have not been adequately backtested, leaving a "blank area" on the chart. The indicator automatically identifies these zones and then highlights them, paying special attention to cases where the market returns to these levels — often a reaction or reversal occurs.
The Liquidity Sweep module monitors key areas of market liquidity. The indicator is able to identify movements where the price breaks through previous peaks or troughs and then quickly reverses. These "liquidity sweeps" are often associated with stop hunting and can provide excellent entry opportunities for counter-trend trades.
Key benefits of the indicator:
Automatic IFVG zone detection
Liquidity sweep (high/low sweep) detection
Structured, clear visual display
Combined signals for higher probability setups
Can be used on all timeframes and instruments
The system is particularly useful for those who seek a deeper understanding of the market structure and are not just looking for indicator-based entries, but think in context. The combination of IFVG and liquidity sweep allows the trader to identify manipulative moves and then take advantage of the subsequent direction.
Usage recommendation:
The indicator is worth using in conjunction with other confluences, such as trend direction, order blocks or key levels. The best results are achieved when a liquidity sweep coincides with an IFVG zone, especially on higher timeframes.
It is important to note that the indicator does not provide guaranteed signals — proper risk management and strategy are essential for long-term success.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuxAlgo

//@version=6
indicator("Inversion Fair Value Gaps with Volatility & Sweeps", shorttitle="IFVG + Sweeps", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// --- Group Name --- Settings
int atrLengthInput    = input.int(14, "ATR Length", minval=1, tooltip="Length for the ATR-based volatility filter.")
float atrMultInput    = input.float(0.5, "ATR Multiplier", minval=0, step=0.1, tooltip="The FVG size must be greater than ATR * Multiplier to be considered.")
int showLastInput     = input.int(20, "Show Last IFVGs", minval=1, tooltip="Maximum number of inversion FVGs to display on the chart.")
string mitigationType = input.string("Close", "Mitigation Type", options=["Close", "Wick"], tooltip="Whether to consider the IFVG mitigated on candle close or wick touch.")
bool showOriginal     = input.bool(true, "Show Original FVG Segment", tooltip="If enabled, shows the FVG box from its origin until the point of inversion.")

// --- Group Name --- Liquidity Sweep Settings
bool showSweeps       = input.bool(true, "Show Liquidity Sweeps", tooltip="Display lines when price sweeps previous swing highs or lows.")
int sweepLookback     = input.int(10, "Swing Lookback", minval=2, tooltip="Period to find swing highs/lows for liquidity levels.")

// --- Group Name --- Style
color bullFvgColor     = input.color(color.new(#089981, 80), "Bullish FVG", group="Style")
color bearFvgColor     = input.color(color.new(#f23645, 80), "Bearish FVG", group="Style")
color bullIfvgColor    = input.color(color.new(#089981, 40), "Bullish IFVG (from Bear)", group="Style")
color bearIfvgColor    = input.color(color.new(#f23645, 40), "Bearish IFVG (from Bull)", group="Style")
color bullBorderColor  = input.color(color.new(#089981, 50), "Bullish Border", group="Style")
color bearBorderColor  = input.color(color.new(#f23645, 50), "Bearish Border", group="Style")
color sweepColor       = input.color(#5b9cf6, "Sweep Line Color", group="Style")

// --- User-defined types ---
type Fvg
    float top
    float bottom
    int   startBar
    int   inversionBar = na
    int   endBar       = na
    bool  isBullish
    bool  isInverted   = false
    bool  isMitigated  = false

type LiqLevel
    float price
    int   index

// --- Logic ---
var fvgArray = array.new<Fvg>()
atr = ta.atr(atrLengthInput)

// FVG Detection (3-candle pattern)
bullFvgDetected = low > high[2] and close[1] > high[2]
bearFvgDetected = high < low[2] and close[1] < low[2]

// Volatility Filter
gapSize = bullFvgDetected ? low - high[2] : bearFvgDetected ? low[2] - high : 0.0
isSignificant = gapSize > atr * atrMultInput

if bullFvgDetected and isSignificant
    fvgArray.push(Fvg.new(low, high[2], bar_index - 1, isBullish=true))

if bearFvgDetected and isSignificant
    fvgArray.push(Fvg.new(low[2], high, bar_index - 1, isBullish=false))

// Track and update FVGs
if fvgArray.size() > 0
    for i = fvgArray.size() - 1 to 0
        Fvg f = fvgArray.get(i)
        
        if not f.isInverted
            // Check for Inversion (Confirmed on Close)
            if f.isBullish
                if close < f.bottom
                    f.isInverted   := true
                    f.inversionBar := bar_index
            else
                if close > f.top
                    f.isInverted   := true
                    f.inversionBar := bar_index
        else if not f.isMitigated
            // Check for Mitigation of IFVG
            float testPriceClose = close
            float testPriceWick  = not f.isBullish ? low : high 
            float testValue      = mitigationType == "Close" ? testPriceClose : testPriceWick
            
            if not f.isBullish // Bearish FVG turned Bullish IFVG
                if testValue < f.bottom
                    f.isMitigated := true
                    f.endBar      := bar_index
            else // Bullish FVG turned Bearish IFVG
                if testValue > f.top
                    f.isMitigated := true
                    f.endBar      := bar_index
    
    if fvgArray.size() > 200
        fvgArray.shift()

// --- Visuals: IFVG Boxes ---
var boxArray = array.new<box>()

if barstate.islast
    for b in boxArray
        b.delete()
    boxArray.clear()

    int displayedCount = 0
    for i = fvgArray.size() - 1 to 0
        Fvg f = fvgArray.get(i)
        
        if f.isInverted
            int end = na(f.endBar) ? bar_index : f.endBar
            
            if showOriginal
                boxArray.push(box.new(f.startBar, f.top, f.inversionBar, f.bottom, 
                     bgcolor=f.isBullish ? bullFvgColor : bearFvgColor, 
                     border_color=color.new(chart.fg_color, 100)))
            
            boxArray.push(box.new(f.inversionBar, f.top, end, f.bottom, 
                 bgcolor=f.isBullish ? bearIfvgColor : bullIfvgColor, 
                 border_color=f.isBullish ? bearBorderColor : bullBorderColor,
                 border_style=line.style_dashed))
            
            displayedCount += 1
            if displayedCount >= showLastInput
                break

// --- Liquidity Sweeps ---
if showSweeps
    // Detect Pivot Highs and Lows
    float ph = ta.pivothigh(sweepLookback, sweepLookback)
    float pl = ta.pivotlow(sweepLookback, sweepLookback)
    
    // Maintain a list of recent liquidity levels
    var LiqLevel[] bslLevels = array.new<LiqLevel>() // Buy-side Liquidity
    var LiqLevel[] sslLevels = array.new<LiqLevel>() // Sell-side Liquidity
    
    if not na(ph)
        bslLevels.unshift(LiqLevel.new(ph, bar_index - sweepLookback))
        if bslLevels.size() > 20
            bslLevels.pop()
            
    if not na(pl)
        sslLevels.unshift(LiqLevel.new(pl, bar_index - sweepLookback))
        if sslLevels.size() > 20
            sslLevels.pop()
            
    // Check for sweeps of tracked levels
    if bslLevels.size() > 0
        for i = bslLevels.size() - 1 to 0
            LiqLevel level = bslLevels.get(i)
            if high > level.price and close < level.price
                line.new(level.index, level.price, bar_index, level.price, color=sweepColor, style=line.style_solid, width=1)
                bslLevels.remove(i)
                break
                
    if sslLevels.size() > 0
        for i = sslLevels.size() - 1 to 0
            LiqLevel level = sslLevels.get(i)
            if low < level.price and close > level.price
                line.new(level.index, level.price, bar_index, level.price, color=sweepColor, style=line.style_solid, width=1)
                sslLevels.remove(i)
                break

// Alerts
if fvgArray.size() > 0
    for i = fvgArray.size() - 1 to 0
        Fvg f = fvgArray.get(i)
        if f.isInverted and f.inversionBar == bar_index
            alert("Inversion FVG Confirmed: " + (f.isBullish ? "Bearish IFVG" : "Bullish IFVG"), alert.freq_once_per_bar_close)
            break
````
