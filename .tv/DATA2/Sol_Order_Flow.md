<!-- tradingview-pine-id: PUB;2853ddfe070e4682b5798b2604b46fa7 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Sol Order Flow

Source: https://www.tradingview.com/script/aXtEsJak-Sol-Order-Flow/

## Description

ol Order Flow is a simplified intraday flow indicator designed to show the market’s current directional pressure without cluttering the chart with traditional order-flow data.

The indicator analyzes recent price and volume behavior over a short rolling window and continuously classifies market flow into four states:

STRONG BULL — sustained bullish pressure
BULLISH REVERSAL — bearish pressure is weakening and shifting bullish
STRONG BEAR — sustained bearish pressure
BEARISH REVERSAL — bullish pressure is weakening and shifting bearish

Traders can use the status as a directional context/filter rather than a standalone entry signal. For example, bullish flow can add confirmation to long setups or upside breakouts, while bearish flow can support shorts. When price moves in one direction while the flow indicator shifts in the opposite direction, traders can watch for a potential failed breakout or reversal.

The default settings are designed to react to relatively fast intraday changes, making the indicator particularly useful alongside Opening Range Breakouts, session trading, support/resistance, and other short-term setups.

Important: Sol Order Flow estimates directional buying and selling pressure using price and volume data. It is not true bid/ask order-flow or Level 2 data and should be used as a contextual tool rather than a buy/sell signal.

---

## Source Code

````pine
//@version=6
indicator("Sol Order Flow", shorttitle="Sol Flow", overlay=true)

//────────────────────────────────────────────────────────────────────
// INPUTS
//────────────────────────────────────────────────────────────────────

// Flow calculation
flowTimeframe = input.timeframe("15", "Flow Timeframe")
flowLength    = input.int(14, "Flow Lookback", minval=3, maxval=100)
smoothLength  = input.int(5, "Flow Smoothing", minval=1, maxval=50)

// Threshold required before flow is considered "strong"
strongThreshold = input.float(0.35, "Strong Flow Threshold", minval=0.05, maxval=1.00, step=0.05)

// Display
boxBgColor    = input.color(color.black, "Box Background")
textColor     = input.color(color.white, "Text Color")
borderColor   = input.color(color.gray, "Border Color")
borderWidth   = input.int(1, "Border Width", minval=0, maxval=5)

boxSizeInput = input.string(
     "Large",
     "Box Size",
     options=["Tiny", "Small", "Normal", "Large", "Huge"]
)

// Convert size input into TradingView text size
textSize = switch boxSizeInput
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large
    "Huge"   => size.huge


//────────────────────────────────────────────────────────────────────
// ORDER-FLOW PROXY
//────────────────────────────────────────────────────────────────────
//
// TradingView Plus does not expose true bid/ask footprint information
// to Pine.
//
// Instead, we estimate directional pressure from:
//     1. candle location
//     2. candle range
//     3. volume
//
// Closing near the high = bullish volume pressure.
// Closing near the low  = bearish volume pressure.
//
// Result ranges roughly from:
//     -volume → strong selling pressure
//     +volume → strong buying pressure
//

calcFlow() =>

    candleRange = math.max(high - low, syminfo.mintick)

    // Close Location Value:
    // +1 = close at high
    // -1 = close at low
    pressure = ((close - low) - (high - close)) / candleRange

    estimatedDelta = volume * pressure

    // Normalize delta against average volume.
    avgVolume = ta.sma(volume, flowLength)

    normalizedDelta =
         avgVolume > 0
         ? estimatedDelta / avgVolume
         : 0.0

    // Smooth the raw pressure
    flow = ta.ema(normalizedDelta, smoothLength)

    // Short-term flow momentum
    momentum = flow - flow[1]

    [flow, momentum]


// Always calculate from selected flow timeframe.
[flow, momentum] = request.security(
     syminfo.tickerid,
     flowTimeframe,
     calcFlow(),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
)


//────────────────────────────────────────────────────────────────────
// FLOW STATE
//────────────────────────────────────────────────────────────────────
//
// STRONG BULL
//     Positive pressure above our threshold.
//
// STRONG BEAR
//     Negative pressure below our threshold.
//
// BULLISH REVERSAL
//     Flow is not strongly bullish yet,
//     but momentum has turned upward.
//
// BEARISH REVERSAL
//     Flow is not strongly bearish yet,
//     but momentum has turned downward.
//

string flowState = ""

if flow >= strongThreshold
    flowState := "STRONG BULL"

else if flow <= -strongThreshold
    flowState := "STRONG BEAR"

else if momentum > 0
    flowState := "BULLISH REVERSAL"

else
    flowState := "BEARISH REVERSAL"


//────────────────────────────────────────────────────────────────────
// STATUS BOX
//────────────────────────────────────────────────────────────────────

var table statusBox = table.new(
     position.bottom_right,
     1,
     1,
     bgcolor=boxBgColor,
     frame_color=borderColor,
     frame_width=borderWidth,
     border_color=borderColor,
     border_width=borderWidth
)

if barstate.islast
    table.cell(
         statusBox,
         0,
         0,
         flowState,
         text_color=textColor,
         text_size=textSize,
         bgcolor=boxBgColor
    )

    table.set_bgcolor(statusBox, boxBgColor)
    table.set_frame_color(statusBox, borderColor)
    table.set_frame_width(statusBox, borderWidth)
    table.set_border_color(statusBox, borderColor)
    table.set_border_width(statusBox, borderWidth)
````
