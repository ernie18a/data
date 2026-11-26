# open interest with volume

- url: https://www.tradingview.com/script/RJSxjNvX-open-interest-with-volume/
- type: indicator
- pine_id: PUB;41a49e04cf7b4ca68a558a123a25e784
- version: 1.0

## Description

oi vs vol ........................................................................

## Source Code

````pine
//@version=6
indicator("CME Institutional Volume + Open Interest", overlay=false)

//====================================================
// CME-STYLE OPEN INTEREST SOURCE
//====================================================

// Official TradingView OI symbol
oiTicker = ticker.standard(syminfo.tickerid) + "_OI"

// CME-style daily OI
oiRaw = request.security(
     oiTicker,
     timeframe.period,
     close,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

//====================================================
// CME-STYLE VOLUME SOURCE
//====================================================

// Exchange-traded futures volume
volRaw = volume

//====================================================
// CME NORMALIZATION METHOD
//====================================================

// Institutional smoothing
oiAvg  = ta.sma(oiRaw, 30)
volAvg = ta.sma(volRaw, 30)

// Normalize volume into OI magnitude
volNormalized =
     volRaw * (oiAvg / volAvg)

//====================================================
// COLORS
//====================================================

volColor = color.new(#036efa, 0)

//====================================================
// CME-STYLE PLOTS
//====================================================

// Volume histogram
plot(
     volNormalized,
     title = "Normalized Volume",
     style = plot.style_columns,
     color = volColor,
     linewidth = 4
)

// Open Interest line
plot(
     oiRaw,
     title = "Open Interest",
     color = color.yellow,
     linewidth = 3
)



//====================================================
// MARKET PARTICIPATION LOGIC
//====================================================

// Rising participation
participationUp =
     oiRaw > oiRaw[1] and
     volNormalized > volNormalized[1]

// Falling participation
participationDown =
     oiRaw < oiRaw[1] and
     volNormalized < volNormalized[1]
````
