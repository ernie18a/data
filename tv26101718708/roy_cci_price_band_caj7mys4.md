# Roy CCI Price Band

- url: https://www.tradingview.com/script/Caj7mYs4/
- type: indicator
- pine_id: PUB;1b45d2e1a08f41908c93ae17befce495
- version: 1.0

## Description

Roy CCI Price Band

Roy CCI Price Band is a momentum-volatility indicator that combines the strength of the Commodity Channel Index (CCI) with a dynamic Bollinger-style price band system to help traders identify bullish pressure, bearish pressure, volatility expansion, and potential reversal zones directly on the price chart.

Unlike traditional CCI indicators that appear in a separate lower panel, this indicator transforms CCI momentum into a live adaptive price wave that reacts dynamically to market conditions.

The bands expand during strong momentum and volatility, and contract during slow or sideways market conditions.

This indicator is highly suitable for:

Trend following
Momentum breakout trading
Pullback trading
Volatility analysis
Scalping and intraday trading
Mobile TradingView users

━━━━━━━━━━━━━━━━━━
FEATURES
━━━━━━━━━━━━━━━━━━

• Dynamic CCI Price Band
• Bullish & Bearish Volatility Wave
• Adaptive ATR Expansion System
• Dynamic Momentum Pressure Detection
• Trend Balance Middle Line
• Reversal Dot Signals
• Mobile Friendly Visualization
• Adjustable Opacity & Color System
• Smooth Cinematic Band Display

━━━━━━━━━━━━━━━━━━
HOW TO READ THE INDICATOR
━━━━━━━━━━━━━━━━━━

GREEN BAND = BULLISH MOMENTUM

When the band turns green, it indicates bullish momentum is dominating the market.

The larger and wider the green band becomes:
→ the stronger the buying pressure.

━━━━━━━━━━━━━━━━━━

RED BAND = BEARISH MOMENTUM

When the band turns red, it indicates bearish momentum is dominating the market.

The larger and wider the red band becomes:
→ the stronger the selling pressure.

━━━━━━━━━━━━━━━━━━

EXPANDING BAND

When the upper and lower bands move further apart:
→ market volatility is increasing.
→ this often happens during strong trends or breakout movements.

━━━━━━━━━━━━━━━━━━

CONTRACTING BAND

When the band becomes narrow:
→ the market is slowing down or moving sideways.

This condition often appears before a major breakout occurs.

━━━━━━━━━━━━━━━━━━

WHITE MIDDLE LINE

The white middle line represents the equilibrium or trend balance area.

Price above the white line:
→ bullish bias.

Price below the white line:
→ bearish bias.

━━━━━━━━━━━━━━━━━━

SIGNAL DOTS

Green dot:
→ potential bullish momentum recovery.

Red dot:
→ potential bullish weakness or bearish reversal.

━━━━━━━━━━━━━━━━━━
SUGGESTED USAGE
━━━━━━━━━━━━━━━━━━

• Use together with market structure or support & resistance
• Highly effective when combined with EMA or trend filters
• Suitable for XAUUSD, Forex, Crypto, and Indices
• Works best in trending market conditions
• Recommended timeframes:

Scalping: M1–M5
Intraday: M15–H1
Swing Trading: H4–D1

━━━━━━━━━━━━━━━━━━
RECOMMENDED SETTINGS
━━━━━━━━━━━━━━━━━━

Band Fill Opacity: 85
Band Line Opacity: 50
Middle Line Opacity: 40
Band Strength: 1.5

━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━

This indicator is designed to assist market analysis and does not guarantee profits. Always apply proper risk management before entering any trade.

## Source Code

````pine
//@version=6
indicator("Roy CCI Price Band", overlay=true)

// ================= INPUT =================
cciLen   = input.int(20, "CCI Length")
basisLen = input.int(20, "Price Basis Length")
atrLen   = input.int(14, "ATR Length")
mult     = input.float(1.5, "Band Strength", step=0.1)

bullColor = input.color(color.lime, "Bullish Band Color")
bearColor = input.color(color.red, "Bearish Band Color")

fillOpacity = input.int(85, "Band Fill Opacity", minval=0, maxval=100)
lineOpacity = input.int(50, "Band Line Opacity", minval=0, maxval=100)
basisOpacity = input.int(40, "Middle Line Opacity", minval=0, maxval=100)

showSignal = input.bool(true, "Show Signal Dot")

// ================= CALCULATION =================
cci = ta.cci(hlc3, cciLen)
basis = ta.ema(close, basisLen)
atr = ta.atr(atrLen)

cciPower = math.abs(cci) / 100
bandSize = atr * cciPower * mult

upper = basis + bandSize
lower = basis - bandSize

bandColor = cci >= 0 ? bullColor : bearColor

// ================= PLOT BAND =================
pBasis = plot(
     basis,
     "Middle Price Band",
     color=color.new(color.white, basisOpacity),
     linewidth=1
)

pUpper = plot(
     upper,
     "Upper CCI Price Band",
     color=color.new(bandColor, lineOpacity),
     linewidth=2
)

pLower = plot(
     lower,
     "Lower CCI Price Band",
     color=color.new(bandColor, lineOpacity),
     linewidth=2
)

fill(
     pUpper,
     pLower,
     color=color.new(bandColor, fillOpacity),
     title="CCI Price Band Fill"
)

// ================= SIGNAL =================
buySignal = ta.crossover(cci, -100)
sellSignal = ta.crossunder(cci, 100)

plotshape(
     showSignal and buySignal,
     title="CCI Recovery Buy",
     style=shape.circle,
     location=location.belowbar,
     color=color.new(bullColor, 20),
     size=size.tiny
)

plotshape(
     showSignal and sellSignal,
     title="CCI Weakness Sell",
     style=shape.circle,
     location=location.abovebar,
     color=color.new(bearColor, 20),
     size=size.tiny
)
````
