# Objective Hammer + Inverted Hammer - Candle Iron Core

- url: https://www.tradingview.com/script/Mun3pMzB-Objective-Hammer-Inverted-Hammer-Candle-Iron-Core/
- type: indicator
- pine_id: PUB;c4be5b41edfc45549cada41e0e5913b2
- version: 1.0

## Description

Objective Hammer + Inverted Hammer identifies Hammer and Inverted Hammer candles using fully objective, mathematics-based geometric rules instead of discretionary visual interpretation.

The indicator evaluates candle structure using configurable relationships between body size, total range, wick dominance, and optional volume confirmation.

Both Hammer and Inverted Hammer structures are supported simultaneously.

Unlike many traditional pattern detectors, every condition can be adjusted numerically, allowing the tool to be used for research, statistics, system development, or personal pattern calibration.

How candle geometry is defined

Body Size
= absolute difference between Open and Close.

Range
= High − Low.

Lower Wick
= min(Open, Close) − Low.

Upper Wick
= High − max(Open, Close).

A candle is classified as a Hammer or Inverted Hammer only when all enabled conditions are satisfied.

Hammer Requirements

• Small body relative to total candle range.
• Dominant lower wick.
• Limited upper wick.

Inverted Hammer Requirements

• Small body relative to total candle range.
• Dominant upper wick.
• Limited lower wick.

The indicator also includes optional directional colorimetry logic:

• Bullish Hammer:
Current low must sweep or match the previous candle low.

• Bearish Inverted Hammer:
Current high must sweep or match the previous candle high.

This allows the indicator to visually distinguish between neutral geometric patterns and structures interacting with prior liquidity.

────────────────────
PARAMETERS
────────────────────

Body Threshold (x of Range)

Controls how small the candle body must be relative to the candle’s full range.

Formula:
Body ≤ x × Range

Lower values:
• Stricter detection.
• Only very small-bodied candles qualify.
• Produces cleaner textbook-style structures.

Higher values:
• More permissive detection.
• Allows larger candle bodies.
• Produces more signals.

Recommended Ranges

Strict:
0.10 – 0.20

Balanced:
0.20 – 0.35

Loose:
0.35 – 0.60+

Default:
0.30

────────────────────

Dominant Wick Multiplier

Controls how dominant the main wick must be relative to the body size.

For Hammer:
Lower wick is evaluated.

For Inverted Hammer:
Upper wick is evaluated.

Formula:
Dominant Wick ≥ x × Body

Lower values:
• Easier qualification.
• More candles pass the filter.

Higher values:
• Requires stronger rejection.
• Produces cleaner structures with more pronounced wick imbalance.

Recommended Ranges

Loose:
1.0 – 1.5

Balanced:
1.5 – 2.5

Strict:
2.5 – 4.0+

Default:
2.0

────────────────────

Opposite Wick Limit

Controls the maximum allowed size of the opposite wick.

For Hammer:
Upper wick is evaluated.

For Inverted Hammer:
Lower wick is evaluated.

Formula:
Opposite Wick ≤ x × Body

Lower values:
• Cleaner structures.
• Opposite wick becomes nearly nonexistent.
• Very selective.

Higher values:
• More tolerant detection.
• Allows imperfect or visually broader structures.
• Better aligned with discretionary chart interpretation.

Recommended Ranges

Strict:
0.10 – 0.30

Balanced:
0.30 – 0.90

Loose:
0.90 – 1.50+

Default:
0.90

────────────────────
VOLUME FILTER
────────────────────

Optional volume confirmation can be enabled.

Condition:
Volume ≥ SMA(Volume, Length) × Multiplier

This allows filtering for patterns appearing with elevated participation relative to recent average volume.

Volume SMA Length

Controls the averaging period used for baseline volume.

Lower values:
• Faster adaptation.
• More reactive.

Higher values:
• Smoother volume baseline.
• More stable filtering.

Recommended:
10 – 50

Default:
20

Volume Multiplier

Controls how much larger current volume must be relative to average volume.

Lower values:
• More signals.

Higher values:
• Requires stronger volume expansion.

Recommended Ranges

Loose:
0.8 – 1.0

Balanced:
1.0 – 1.5

Strict:
1.5 – 3.0+

Default:
1.0

────────────────────
VISUALS
────────────────────

The indicator distinguishes between:

• Bullish Hammer
• Bearish Inverted Hammer
• Neutral Hammer
• Neutral Inverted Hammer

Labels are optional and disabled by default.

────────────────────
NOTES & LIMITATIONS
────────────────────

• Works with standard candlesticks only.
• No repainting from future data.
• Does not generate buy/sell signals.
• Does not evaluate market structure, trend, support/resistance, or context.
• Candle classification is purely geometric and parameter-based.
• Intended for visualization, research, and system development only.

## Source Code

````pine
//@version=6
indicator("Objective Hammer + Inverted Hammer - Candle Iron Core", overlay=true)

// ─────────────────────────────────────────────
// Inputs: Candle Geometry
// ─────────────────────────────────────────────
bodyThreshold = input.float(0.30, "Body Threshold (x of Range)", minval=0.01, maxval=1.0, step=0.01, group="Candle Geometry")
wickMultiplier = input.float(2.0, "Dominant Wick Multiplier", minval=0.1, step=0.1, group="Candle Geometry")
oppositeWickLimit = input.float(0.50, "Opposite Wick Limit", minval=0.0, step=0.1, group="Candle Geometry")

// ─────────────────────────────────────────────
// Inputs: Volume Filter
// ─────────────────────────────────────────────
useVolumeFilter = input.bool(false, "Use Volume Filter", group="Volume Filter")
volumeLength = input.int(20, "Volume SMA Length", minval=1, group="Volume Filter")
volumeMultiplier = input.float(1.0, "Volume Multiplier", minval=0.1, step=0.1, group="Volume Filter")

// ─────────────────────────────────────────────
// Inputs: Visuals
// ─────────────────────────────────────────────
bullishHammerColor = input.color(color.rgb(11, 240, 23), "Bullish Hammer Color", group="Visuals")
bearishInvertedColor = input.color(color.rgb(252, 8, 8), "Bearish Inverted Hammer Color", group="Visuals")

neutralHammerColor = input.color(color.rgb(0, 228, 209), "Neutral Hammer Color", group="Visuals")
neutralInvertedColor = input.color(color.rgb(0, 228, 209), "Neutral Inverted Hammer Color", group="Visuals")

showLabels = input.bool(false, "Show Labels", group="Visuals")

// ─────────────────────────────────────────────
// Candle Geometry
// ─────────────────────────────────────────────
bodySize = math.abs(open - close)
barRange = high - low

lowerWick = math.min(open, close) - low
upperWick = high - math.max(open, close)

validRange = barRange > 0
validBody = bodySize > 0

// ─────────────────────────────────────────────
// Volume Logic
// ─────────────────────────────────────────────
volumeSMA = ta.sma(volume, volumeLength)

volumeCondition =
     not useVolumeFilter or
     volume >= volumeSMA * volumeMultiplier

// ─────────────────────────────────────────────
// Shared Rule
// ─────────────────────────────────────────────
smallBody =
     validRange and
     bodySize <= bodyThreshold * barRange

// ─────────────────────────────────────────────
// Hammer Detection
// ─────────────────────────────────────────────
isHammer =
     smallBody and
     validBody and
     lowerWick >= wickMultiplier * bodySize and
     upperWick <= oppositeWickLimit * bodySize and
     volumeCondition

isInvertedHammer =
     smallBody and
     validBody and
     upperWick >= wickMultiplier * bodySize and
     lowerWick <= oppositeWickLimit * bodySize and
     volumeCondition

// ─────────────────────────────────────────────
//  Colorimetry Rules
// ─────────────────────────────────────────────
isBullishHammer =
     isHammer and
     low[1] >= low

isBearishInvertedHammer =
     isInvertedHammer and
     high[1] <= high

// ─────────────────────────────────────────────
// Final Candle Color
// ─────────────────────────────────────────────
finalColor =
     isBullishHammer ? bullishHammerColor :
     isBearishInvertedHammer ? bearishInvertedColor :
     isHammer ? neutralHammerColor :
     isInvertedHammer ? neutralInvertedColor :
     na

barcolor(finalColor)

// ─────────────────────────────────────────────
// Optional Labels
// ─────────────────────────────────────────────
plotshape(
     showLabels and isBullishHammer,
     title="Bullish Hammer",
     style=shape.labelup,
     text="Bull Hammer",
     location=location.belowbar,
     color=bullishHammerColor,
     textcolor=color.black,
     size=size.tiny
)

plotshape(
     showLabels and isBearishInvertedHammer,
     title="Bearish Inverted Hammer",
     style=shape.labeldown,
     text="Bear Inv",
     location=location.abovebar,
     color=bearishInvertedColor,
     textcolor=color.white,
     size=size.tiny
)
````
