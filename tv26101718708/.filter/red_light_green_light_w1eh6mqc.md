# Red Light / Green Light

- url: https://www.tradingview.com/script/W1Eh6MqC-Red-Light-Green-Light/
- type: indicator
- pine_id: PUB;86bf8d76021b4dc98d71ac090efd5eca
- version: 1.0

## Description

Red Light / Green Light (ATR Distribution & FTD Signals)

Pressing the gas when momentum favors you is easy, but the hard part is knowing when to hit the brakes before getting caught in a sharp distribution drop.

Red Light / Green Light is an overlay indicator designed to keep you on the right side of heavy market moves. It combines ATR-based volatility expansion on down days with Follow-Through Day (FTD) breakout logic to give clear visual entry and exit cues right on your chart.

How It Works

 Red Light (Bearish Exit Signal): Triggers on down-bars where the body size expands beyond a customizable ATR threshold (default: 1.5x 10-period ATR). This flags heavy institutional selling or distribution before a deeper pullback unfolds.

 Green Light (Bullish Entry Signal): Triggers on a custom Follow-Through Day setup requiring a minimum +1.5% single-day gain, higher volume than the prior bar, and structural price support off a 10-day lookback low.

Key Features & Customization

 Custom Emojis or Text: Choose from preset emojis (e.g., 🍆 / ☠️, 🚀 / 💥) or type in your own custom text labels (e.g., ⁠"BUY"⁠, ⁠"SELL"⁠, ⁠"GTFO"⁠, ⁠"DONT BE A HERO"⁠).

 Smart Wick Clearance: Uses ATR-based dynamic positioning so labels remain readable across all timeframes without crowding candle wicks.

 Directional Arrows: Optional toggleable pointer arrows (⁠↑⁠ / ⁠↓⁠) pointing directly at signal candles.

 Alert Ready: Includes native ⁠alertcondition⁠ triggers for both Red Light and Green Light signals so you can route them to webhooks, pop-ups, or SMS.

How to Use

1. Add to Chart: Works across standard timeframes (Daily recommended for standard swing trading logic).

2. Adjust Inputs: Fine-tune ATR length, percentage gain thresholds, or lookback periods in the settings menu to fit your asset class (Equities, Crypto, Futures).

3. Set Alerts: Create a TradingView alert selecting "Red Light Alert" or "Green Light Alert" for real-time notification.

Disclaimer: For educational and informational purposes only. Always manage risk and conduct your own analysis before entering any trade.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © chardogg74

//@version=6
//@version=6
indicator("Red Light Green Light", overlay=true)

// ==========================================
// === BEARISH ("RED LIGHT") INPUTS =========
// ==========================================
showHero        = input.bool(true, title="Enable 'Red Light' (Bearish) Signal", group="Bearish Signal")
heroAtrLength   = input.int(10, title="ATR Length", minval=1, group="Bearish Signal")
heroAtrMultiple = input.float(1.5, title="ATR Multiple Threshold", step=0.1, minval=0.1, group="Bearish Signal")
heroEmojiInput  = input.string("💥", title="Bearish Label", options=["💥", "☠️", "🚨", "SELL", "RUN", "GTFO", "Custom"], group="Bearish Signal")
heroCustomEmoji = input.string("SELL", title="Custom Bearish Text/Emoji", group="Bearish Signal")

heroText = (heroEmojiInput == "Custom") ? heroCustomEmoji : heroEmojiInput

// ==========================================
// === BULLISH ("GREEN LIGHT") INPUTS =======
// ==========================================
showGreenLight         = input.bool(true, title="Enable 'Green Light' (Bullish) Signal", group="Bullish Signal")
greenLightPctThreshold = input.float(1.5, title="Min % Gain from Prev Close (%)", minval=0.1, group="Bullish Signal")
greenLightLowLookback  = input.int(10, title="Lookback Period for Lowest Low Checks", minval=1, group="Bullish Signal")
greenLightEmojiInput   = input.string("🚀", title="Bullish Label", options=["🚀", "🍆", "🔥", "BUY", "PUMP", "SEND IT", "Custom"], group="Bullish Signal")
greenLightCustomEmoji  = input.string("BUY", title="Custom Bullish Text/Emoji", group="Bullish Signal")

greenLightText = (greenLightEmojiInput == "Custom") ? greenLightCustomEmoji : greenLightEmojiInput

// ==========================================
// === VISUAL & FORMATTING INPUTS ===========
// ==========================================
showArrowInput    = input.bool(true, title="Include Arrow Pointer", group="Visual Options")
textSizeInput     = input.string("normal", title="Label Text Size", options=["small", "normal", "large"], group="Visual Options")
bearishOffsetMult = input.float(0.3, title="Bearish Label Distance (ATR Mult)", step=0.1, group="Visual Options")
bullishOffsetMult = input.float(2.0, title="Bullish Label Distance (ATR Mult)", step=0.1, group="Visual Options")

// Convert string size input to Pine Script label size
labelSize = textSizeInput == "small" ? size.small : textSizeInput == "large" ? size.large : size.normal

// Append arrows pointing toward the candle wicks
heroDisplay       = heroText + (showArrowInput ? "\n↓" : "")
greenLightDisplay = (showArrowInput ? "↑\n" : "") + greenLightText

// ==========================================
// === BEARISH LOGIC ========================
// ==========================================
heroAtrValue  = ta.atr(heroAtrLength)[1]
bodyMove      = close - open
isDownBar     = bodyMove < 0
heroMoveSize  = math.abs(bodyMove)

heroSignal = showHero and isDownBar and (heroMoveSize >= (heroAtrValue * heroAtrMultiple))

// ==========================================
// === BULLISH LOGIC ========================
// ==========================================
priceGainCondition = close >= (1 + greenLightPctThreshold / 100) * close[1]
volumeCondition    = volume > volume[1]

notLowestToday     = low > ta.lowest(low, greenLightLowLookback)
notLowestYesterday = low[1] > ta.lowest(low, greenLightLowLookback)[1]
notLowest2DaysAgo  = low[2] > ta.lowest(low, greenLightLowLookback)[2]

positiveClose3DaysAgo = close[3] > open[3]
notLowest3DaysAgo     = low[3] > ta.lowest(low, greenLightLowLookback)[3]
low3Pass              = positiveClose3DaysAgo or notLowest3DaysAgo

greenLightSignal = showGreenLight and priceGainCondition and volumeCondition and notLowestToday and notLowestYesterday and notLowest2DaysAgo and low3Pass

// ==========================================
// === VISUALS (DYNAMIC LABEL CREATION) =====
// ==========================================
bearishOffset = ta.atr(10) * bearishOffsetMult
bullishOffset = ta.atr(10) * bullishOffsetMult

// Red Light Signal
if heroSignal
    label.new(x=bar_index, y=high + bearishOffset, text=heroDisplay, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=color.red, size=labelSize, textalign=text.align_center)

// Green Light Signal
if greenLightSignal
    label.new(x=bar_index, y=low - bullishOffset, text=greenLightDisplay, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=color.green, size=labelSize, textalign=text.align_center)

// ==========================================
// === ALERTS ===============================
// ==========================================
alertcondition(heroSignal, title="Red Light Alert", message="Red Light Signal triggered on {{ticker}}!")
alertcondition(greenLightSignal, title="Green Light Alert", message="Green Light Signal triggered on {{ticker}}!")
````
