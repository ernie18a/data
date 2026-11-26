# ATK/DEF Price Action Liquidity Mometum

- url: https://www.tradingview.com/script/31K3pQlM/
- type: indicator
- pine_id: PUB;9bc4f714b0534f4c96dbfe05b4c51213
- version: 1.0

## Description

PLM (Price Action Liquidity Momentum) is a custom market behavior analysis indicator designed to study the interaction between price action structure, liquidity conditions, and momentum characteristics through a multi-dimensional calcula framework.

The concept behind PLM is based on the observation that price movement contains multiple layers of information beyond simple direction. Each candle reflects internal market behavior through its body strength, range expansion, wick distribution, closing position, volume participation, and movement intensity.

Traditional indicators often analyze market conditions from a single perspective, such as trend, momentum, or volume. PLM takes a different approach by combining several independent measurements derived from raw candle data, volume behavior, and momentum calculat into one unified analytical structure.

The purpose of PLM is to transform different aspects of market behavior into measurable components, allowing users to observe how price structure, liquidity interaction, and momentum conditions change together across different market environments.

━━━━━━━━━━━━━━━━━━
PLM Core Framework
━━━━━━━━━━━━━━━━━━

PLM is built around three primary analytical dimensions:

1. Price Action
2. Liquidity
3. Momentum

Each component represents a different layer of market behavior.

━━━━━━━━━━━━━━━━━━
Price Action Analysis
━━━━━━━━━━━━━━━━━━

The Price Action component focuses on the internal structure of individual candles and recent candle sequences.

PLM evaluates:

• Candle body strength
• Candle range expansion
• Upper wick proportion
• Lower wick proportion
• Candle direction
• Multi-candle behavioral sequence

The candle body strength calculation measures the relationship between candle direction and total movement range.

The wick analysis observes how price interacts with different levels during candle formation, providing information about rejection characteristics and internal pressure distribution.

The three-candle classification system evaluate recent candle sequences by categorizing candle structures according to body percentag and directional strength.

This approach allows PLM to analyze how price movement is formed rather than only observing the final closing value.

━━━━━━━━━━━━━━━━━━
Liquidity Analysis
━━━━━━━━━━━━━━━━━━

The Liquidity component focuses on the relationship between price movement, volume participation, and internal market balance.

PLM incorporates:

• Chaikin Money Flow (CMF)
• Volume-weighted price positioning
• Wick pressure distribution
• Custom Whirlpool Index

The money flow calculation evaluates the relationship between candle closing location and volume activity.

The Whirlpool Index is a custom measurement developed within PLM to observe the interaction between upper and lower wick activity combined with candle strength.

This measurement represents the intensity of internal price competition and the balance between opposing market forces.

Higher values indicate stronger interaction and greater internal movement activity, while lower values represent relatively calmer conditions.

━━━━━━━━━━━━━━━━━━
Momentum Analysis
━━━━━━━━━━━━━━━━━━

The Momentum component evaluates the strength and condition of current market movement.

PLM combines:

• Price momentum measurement through RSI
• Volume momentum measurement through Volume RSI

The Momentum Index creates a combined numerical representation of movement characteristics by considering both price behavior and volume activity.

This allows momentum conditions to be viewed from both price-based and participation-based perspectives.

━━━━━━━━━━━━━━━━━━
Price and Flow Relationship Analysis
━━━━━━━━━━━━━━━━━━

PLM also includes a relationship measurement between price direction and mone flow behavior.

This component evaluates:

• Price movement direction
• Money flow direction
• Volatility condition
• Liquidity balance intensity

The purpose of this calculation is to observe differences between price behavior and volume-related conditions.

It is designed to highlight changes in market characteristics and internal behavior relationships rather than provide prediction-based output.

━━━━━━━━━━━━━━━━━━
Integrated Market Behavior Framework
━━━━━━━━━━━━━━━━━━

By combining Price Action, Liquidity, and Momentum analysis, PLM creates a structured framework that connects:

• Candle formation
• Volume participation
• Market pressure distribution
• Internal balance conditions
• Movement strength

Each measurement contributes a different perspective, allowing the indicator to display a broader view of market behavior compared with single-factor calculations.

The integrated dashboard presents these measurements in a compact format, including:

• Three-candle structure
• Body strength
• Money flow condition
• Liquidity balance intensity
• Momentum state
• Price and flow relationship

━━━━━━━━━━━━━━━━━━
Calculation Philosophy
━━━━━━━━━━━━━━━━━━

PLM is designed around the principle that market behavior can be studied through the interaction of multiple measurable factors.

Instead of relying on one calculation source, PLM combines independent observations from candle structure, volume information, and momentum characteristics to create a comprehensive visualization framework.

The indicator does not provide tradi instructions, does not generate finan advice, and does not attempt to predict future market movement.

PLM is intended as an analytical and visualization tool for studying price behavior, liquidity characteristics, and momentum conditions through objective calculations.

## Source Code

````pine
//@version=6
indicator(" PLM ", overlay=false, precision=2)

// ============================================================
// 1. Raw Candle Data
// ============================================================
body = math.abs(close - open)
candleRange = high - low

upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low

upperWickRatio = candleRange > 0 ? upperWick / candleRange : 0
lowerWickRatio = candleRange > 0 ? lowerWick / candleRange : 0
bodyStrength = candleRange > 0 ? (close - open) / candleRange : 0

// ============================================================
// 2. 3-Candle Pattern
// ============================================================
getCandleType(bs, bp) =>
    string type = ""
    if bp < 0.15
        type := "Doji"
    else if bs > 0.6
        type := "Strong Bull"
    else if bs < -0.6
        type := "Strong Bear"
    else if bs > 0
        type := "Mild Bull"
    else
        type := "Mild Bear"
    type

bodyPct = candleRange > 0 ? body / candleRange : 0
candle1 = getCandleType(bodyStrength, bodyPct)
candle2 = getCandleType(bodyStrength[1], bodyPct[1])
candle3 = getCandleType(bodyStrength[2], bodyPct[2])

threeCandlePattern = candle3 + " → " + candle2 + " → " + candle1

// ============================================================
// 3. Money Flow (CMF)
// ============================================================
moneyFlowMultiplier = candleRange > 0 ? ((close - low) - (high - close)) / candleRange : 0
moneyFlowVolume = moneyFlowMultiplier * volume
cmf = math.sum(moneyFlowVolume, 20) / math.sum(volume, 20)

fundFlowLabel = "Neutral"
fundFlowColor = color.gray

if cmf > 0.15
    fundFlowLabel := "Strong Inflow"
    fundFlowColor := color.green
else if cmf > 0.05
    fundFlowLabel := "Mild Inflow"
    fundFlowColor := color.lime
else if cmf < -0.15
    fundFlowLabel := "Strong Outflow"
    fundFlowColor := color.red
else if cmf < -0.05
    fundFlowLabel := "Mild Outflow"
    fundFlowColor := color.maroon

// ============================================================
// 4. Whirlpool Battle Index
// ============================================================
struggleIndex = 1 - math.abs(upperWickRatio - lowerWickRatio)
whirlpoolIndex = struggleIndex * (1 + math.abs(bodyStrength))
whirlpoolNorm = whirlpoolIndex > 1 ? 1 : whirlpoolIndex

struggleLabel = ""
struggleColor = color.gray
if whirlpoolNorm > 0.7
    struggleLabel := "Intense"
    struggleColor := color.rgb(255, 100, 0)
else if whirlpoolNorm > 0.4
    struggleLabel := "Moderate"
    struggleColor := color.rgb(255, 200, 0)
else
    struggleLabel := "Calm"
    struggleColor := color.rgb(0, 200, 255)

// ============================================================
// 5. Momentum Index
// ============================================================
rsiValue = ta.rsi(close, 14)
volumeRSI = ta.rsi(volume, 14)
momentumIndex = (rsiValue * 0.6) + (volumeRSI * 0.4)

momentumLabel = ""
momentumColor = color.gray
if momentumIndex > 70
    momentumLabel := "Overbought"
    momentumColor := color.red
else if momentumIndex < 30
    momentumLabel := "Oversold"
    momentumColor := color.green
else if momentumIndex > 50
    momentumLabel := "Bullish"
    momentumColor := color.orange
else
    momentumLabel := "Bearish"
    momentumColor := color.blue

// ============================================================
// 6. Reverse Position Index
// ============================================================
priceDirection = close > close[1] ? 1 : (close < close[1] ? -1 : 0)
fundDirection = cmf > 0 ? 1 : (cmf < 0 ? -1 : 0)
divergence = priceDirection != fundDirection and priceDirection != 0 and fundDirection != 0 ? 1 : 0

volatilityFactor = ta.atr(14) / close * 100
volatilityNorm = volatilityFactor > 5 ? 1 : volatilityFactor / 5

reversePositionIndex = divergence * volatilityNorm * whirlpoolNorm

reverseLabel = ""
reverseColor = color.gray
if reversePositionIndex > 0.6
    reverseLabel := "High"
    reverseColor := color.rgb(255, 50, 200)
else if reversePositionIndex > 0.3
    reverseLabel := "Medium"
    reverseColor := color.rgb(255, 150, 50)
else if reversePositionIndex > 0.05
    reverseLabel := "Low"
    reverseColor := color.rgb(0, 200, 255)
else
    reverseLabel := "None"
    reverseColor := color.rgb(100, 120, 140)

// ============================================================
// 7. Plot Indicators
// ============================================================
hline(0.7, "Heavy Sell", color=color.new(color.white, 30), linestyle=hline.style_dashed)
plot(upperWickRatio, title="Upper Wick", color=color.new(color.red, 60), linewidth=2, style=plot.style_area)
hline(0, "Zero", color=color.gray, linestyle=hline.style_dotted)
plot(bodyStrength, title="Body Strength", color=color.new(color.blue, 60), linewidth=2, style=plot.style_histogram)
plot(cmf, title="CMF", color=color.rgb(237, 249, 8), linewidth=2)

// ============================================================
// 8. Info Panel
// ============================================================
color border = color.rgb(60, 100, 140, 60)
color cyan = color.rgb(0, 220, 255)
color dim = color.rgb(140, 165, 185)

var table info = table.new(position.bottom_right, 2, 11, 
     bgcolor=color.new(color.black, 0), 
     border_width=1, 
     border_color=border)

if barstate.islast
    // Header
    table.cell(info, 0, 0, "◆ LIQUIDITY", 
         text_color=cyan, bgcolor=color.new(color.black, 0), 
         text_size=size.small, text_halign=text.align_right)
    table.cell(info, 1, 0, " MONITOR", 
         text_color=cyan, bgcolor=color.new(color.black, 0), 
         text_size=size.small, text_halign=text.align_left)
    
    // 3-CANDLE
    table.cell(info, 0, 1, "3-CANDLE", 
         text_color=dim, bgcolor=color.new(color.black, 0), 
         text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 1, threeCandlePattern, 
         text_color=color.white, bgcolor=color.new(color.black, 0), 
         text_size=size.small, text_halign=text.align_right)
    
    // BODY
    table.cell(info, 0, 2, "BODY", 
         text_color=dim, bgcolor=color.new(color.black, 0), 
         text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 2, str.tostring(bodyStrength, "#0.00"), 
         text_color=bodyStrength > 0 ? color.rgb(0, 200, 255) : color.rgb(255, 120, 120), 
         bgcolor=color.new(color.black, 0), 
         text_size=size.small, text_halign=text.align_right)
    
    // FUND
    table.cell(info, 0, 3, "FUND", 
         text_color=dim, bgcolor=color.new(color.black, 0), 
         text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 3, fundFlowLabel, 
         text_color=fundFlowColor, bgcolor=color.new(color.black, 0), 
         text_size=size.small, text_halign=text.align_right)
    
    // WHIRLPOOL
    table.cell(info, 0, 4, "WHIRLPOOL", 
         text_color=dim, bgcolor=color.new(color.black, 0), 
         text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 4, str.tostring(whirlpoolNorm, "#0.00") + " " + struggleLabel, 
         text_color=struggleColor, bgcolor=color.new(color.black, 0), 
         text_size=size.small, text_halign=text.align_right)
    
    // MOMENTUM
    table.cell(info, 0, 5, "MOMENTUM", 
         text_color=dim, bgcolor=color.new(color.black, 0), 
         text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 5, str.tostring(momentumIndex, "#0") + " " + momentumLabel, 
         text_color=momentumColor, bgcolor=color.new(color.black, 0), 
         text_size=size.small, text_halign=text.align_right)
    
    // REVERSE
    table.cell(info, 0, 6, "REVERSE", 
         text_color=dim, bgcolor=color.new(color.black, 0), 
         text_size=size.small, text_halign=text.align_left)
    table.cell(info, 1, 6, str.tostring(reversePositionIndex, "#0.00") + " " + reverseLabel, 
         text_color=reverseColor, bgcolor=color.new(color.black, 0), 
         text_size=size.small, text_halign=text.align_right)
    
    // Separator
    table.cell(info, 0, 7, "─────────────────────", 
         text_color=dim, bgcolor=color.new(color.black, 0), 
         text_size=size.small, text_halign=text.align_right)
    table.cell(info, 1, 7, "─────────────────────", 
         text_color=dim, bgcolor=color.new(color.black, 0), 
         text_size=size.small, text_halign=text.align_left)
    
    // Status
    statusColor = color.white
    statusText = ""
    if momentumIndex > 70 and cmf > 0
        statusText := "OVERBOUGHT · CAUTION"
        statusColor := color.rgb(255, 60, 60)
    else if momentumIndex < 30 and cmf < 0
        statusText := "OVERSOLD · WATCH"
        statusColor := color.rgb(0, 230, 140)
    else if cmf > 0 and bodyStrength > 0
        statusText := "BULLISH · ACTIVE"
        statusColor := color.rgb(0, 230, 140)
    else if cmf < 0 and bodyStrength < 0
        statusText := "BEARISH · ALERT"
        statusColor := color.rgb(255, 60, 60)
    else
        statusText := "NEUTRAL · MONITOR"
        statusColor := color.rgb(255, 200, 0)
    
    table.cell(info, 0, 8, "◆", 
         text_color=statusColor, bgcolor=color.new(color.black, 0),
         text_size=size.small, text_halign=text.align_right)
    table.cell(info, 1, 8, statusText, 
         text_color=statusColor, bgcolor=color.new(color.black, 0),
         text_size=size.small, text_halign=text.align_left)
````
