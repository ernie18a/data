<!-- tradingview-pine-id: PUB;fb00368c641846928717a156811e255b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# SHK Adaptive Candle Price Strength

Source: https://www.tradingview.com/script/rAwDnB9Q-SHK-Adaptive-Candle-Price-Strength/

## Description

# SHK Adaptive Candle Price Strength (SHK ACPS)

**SHK Adaptive Candle Price Strength (SHK ACPS)** is a price-action strength indicator designed to estimate the strength of each price bar using its available price structure.

The indicator produces a simple **0–100 strength value** directly below the price, allowing traders to quickly evaluate whether the current price movement has relatively strong or weak momentum.

## How It Works

SHK ACPS analyzes the relationship between:

- Open
- High
- Low
- Close
- Candle body
- Upper wick
- Lower wick
- Recent price movement
- ATR-based volatility

The result is converted into a **0–100 strength scale**.

### Strength Scale

**0–20:** Very weak price strength  
**20–40:** Weak  
**40–60:** Moderate  
**60–80:** Strong  
**80–100:** Very strong

The number is displayed below the corresponding price area.

## Green and Red Strength

The indicator uses color instead of displaying unnecessary BUY/SELL text.

🟢 **Green** = bullish price strength

🔴 **Red** = bearish price strength

⚪ **Gray** = neutral or flat movement

The strength value and its color can therefore be read together.

For example:

**85 in green** → very strong bullish price movement

**72 in red** → strong bearish price movement

**28 in green** → weak bullish movement

**18 in red** → weak bearish movement

## Candle Structure Analysis

When meaningful OHLC structure is available, the indicator evaluates the candle body relative to the complete candle range.

A larger body relative to the total range generally indicates stronger directional participation.

The indicator also considers wick pressure.

For bullish candles:

- Larger lower wick can contribute positively.
- Larger upper wick can reduce bullish strength.

For bearish candles:

- Larger upper wick can contribute positively.
- Larger lower wick can reduce bearish strength.

This allows the strength value to consider more than simply whether the candle closed higher or lower.

## Adaptive Price-Movement Analysis

For price representations where traditional candle body/wick information is not meaningful, the indicator can use **close-to-close price movement relative to ATR**.

ATR provides a volatility reference.

A larger price movement relative to recent volatility produces a higher movement-strength reading, while a smaller movement produces a lower reading.

This makes the indicator useful across different chart representations, including:

- Candles
- Hollow Candles
- Heikin Ashi
- Line
- Step Line

## Current Candle

The strength value is designed to update with the **current developing price bar**.

This means the displayed number can change while the current candle is forming.

For example, a candle may begin with:

**35 → 48 → 67 → 82**

as price movement develops.

Therefore, the current value should be treated as a **live strength reading**, not a fixed value until the bar closes.

## ATR-Based Positioning

The strength value is positioned below the price using ATR rather than a fixed number of ticks.

This allows the distance to adapt to the instrument's volatility.

The result is more practical across instruments with different price scales.

## Optional Strength Bar

An optional strength-bar calculation is included in the script.

It can be enabled from the indicator settings if a visual strength representation is desired.

## Important Interpretation

SHK ACPS is a **strength measurement tool**, not a standalone trading system.

A high green value does not automatically mean that price must continue upward.

Likewise, a high red value does not guarantee that price will continue downward.

Strength can increase near the end of a move, during breakouts, or during volatile reversals.

For better decision-making, traders may combine the indicator with:

- Market structure
- Support and resistance
- Trend direction
- Moving averages
- Volume
- Momentum indicators
- Breakout confirmation
- Higher-timeframe analysis

## Example Usage

A trader may observe:

**Green 80–100**

This indicates strong bullish price structure or movement.

If this occurs together with a confirmed breakout and supportive market structure, it may indicate stronger bullish participation.

Similarly:

**Red 80–100**

indicates strong bearish price structure or movement.

When combined with a confirmed breakdown or bearish market structure, it may provide additional confirmation.

Lower readings can indicate that price movement is relatively weak and may warrant more caution.

## Designed for Simple Visual Reading

The main philosophy of SHK ACPS is simplicity.

Instead of filling the chart with multiple signals, arrows, or BUY/SELL labels, the indicator provides:

**One number + one color**

This allows the trader to visually judge the relative strength of the current price movement without adding excessive chart clutter.

### Quick Reference

| Color | Strength | General Interpretation |
|---|---:|---|
| 🟢 Green | 80–100 | Very strong bullish |
| 🟢 Green | 60–79 | Strong bullish |
| 🟢 Green | 40–59 | Moderate bullish |
| 🟢 Green | 0–39 | Weak bullish |
| 🔴 Red | 80–100 | Very strong bearish |
| 🔴 Red | 60–79 | Strong bearish |
| 🔴 Red | 40–59 | Moderate bearish |
| 🔴 Red | 0–39 | Weak bearish |

**SHK Adaptive Candle Price Strength (SHK ACPS)** is intended to give traders a clean, adaptive view of price strength while keeping the chart visually simple.

---

## Source Code

````pine
//@version=6
indicator("SHK Adaptive Candle Price Strength", "SHK ACPS", overlay=true, max_labels_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
GROUP_DISPLAY = "Display Settings"

showValue = input.bool(true, "Show Strength Value", group=GROUP_DISPLAY)
showBar   = input.bool(false, "Show Strength Bar", group=GROUP_DISPLAY)

atrLength = input.int(14, "ATR Length", minval=1, group=GROUP_DISPLAY)
distance  = input.float(0.35, "Distance Below Price", minval=0.05, step=0.05, group=GROUP_DISPLAY)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CURRENT CHART PRICE DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

srcOpen  = open
srcHigh  = high
srcLow   = low
srcClose = close

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RANGE & BODY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

barRange = srcHigh - srcLow
barBody  = math.abs(srcClose - srcOpen)

upperWick = srcHigh - math.max(srcOpen, srcClose)
lowerWick = math.min(srcOpen, srcClose) - srcLow

safeRange = math.max(barRange, syminfo.mintick)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BODY STRENGTH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bodyStrength = (barBody / safeRange) * 100

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WICK PRESSURE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullStrength =
     srcClose > srcOpen ?
     bodyStrength +
     (lowerWick / safeRange) * 25 -
     (upperWick / safeRange) * 25 :
     0

bearStrength =
     srcClose < srcOpen ?
     bodyStrength +
     (upperWick / safeRange) * 25 -
     (lowerWick / safeRange) * 25 :
     0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FINAL CANDLE STRENGTH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullFinal = math.min(math.max(bullStrength, 0), 100)
bearFinal = math.min(math.max(bearStrength, 0), 100)

candleStrength =
     srcClose > srcOpen ? bullFinal :
     srcClose < srcOpen ? bearFinal :
     0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRICE MOVEMENT STRENGTH
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

priceChange = srcClose - srcClose[1]

atrValue = ta.atr(atrLength)
safeATR  = math.max(atrValue, syminfo.mintick)

movementStrength =
     math.min(
         math.abs(priceChange) / safeATR * 100,
         100
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// AUTOMATIC STRENGTH SELECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

hasCandleStructure = barRange > syminfo.mintick

strength =
     hasCandleStructure ?
     candleStrength :
     movementStrength

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DIRECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

isBull = srcClose > srcOpen
isBear = srcClose < srcOpen

movementBull = priceChange > 0
movementBear = priceChange < 0

isBullFinal =
     hasCandleStructure ?
     isBull :
     movementBull

isBearFinal =
     hasCandleStructure ?
     isBear :
     movementBear

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STRENGTH COLOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

strengthColor =
     isBullFinal ? color.green :
     isBearFinal ? color.red :
     color.gray

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VALUE POSITION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

labelY = srcLow - safeATR * distance

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HISTORICAL + LIVE LABEL SYSTEM
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Every historical candle gets its own label.
//
// The current candle has ONE label that updates
// continuously while the candle is forming.
//
// When a new candle begins, its own label is created
// and the previous candle's value remains where it was.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var label currentLabel = na

if showValue

    // New bar:
    // Create a new label for this candle.
    if barstate.isnew
        currentLabel := label.new(
             x=bar_index,
             y=labelY,
             text=str.tostring(math.round(strength)),
             style=label.style_none,
             textcolor=strengthColor,
             size=size.tiny
         )

    // Existing realtime bar:
    // Update only the current candle's label.
    else if not na(currentLabel)
        label.set_xy(
             currentLabel,
             bar_index,
             labelY
         )

        label.set_text(
             currentLabel,
             str.tostring(math.round(strength))
         )

        label.set_textcolor(
             currentLabel,
             strengthColor
         )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OPTIONAL STRENGTH BAR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

barValue =
     strength > 0 ?
     strength :
     na

plot(
     showBar ? barValue : na,
     title="SHK Adaptive Strength",
     color=strengthColor,
     style=plot.style_columns,
     display=display.none
)
````
