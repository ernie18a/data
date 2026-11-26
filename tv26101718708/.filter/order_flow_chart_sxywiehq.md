# Order Flow chart

- url: https://www.tradingview.com/script/SXYWiehq-Order-Flow-chart/
- type: indicator
- pine_id: PUB;59c5af730f2d4236ad222d68a7a26448
- version: 1.0

## Description

order flow chart . professional-grade order flow indicator built for TradingView that analyzes the battle between buyers and sellers on every single candle. Since TradingView doesn't give access to raw bid/ask tick data, this script uses a proven mathematical formula to estimate institutional order flow in real time.

## Source Code

````pine
//@version=5
indicator("Order Flow Suite", shorttitle="OFS", overlay=false, max_bars_back=500)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────
grp1 = "📊 Volume Delta"
showDelta      = input.bool(true,  "Show Volume Delta Bars",         group=grp1)
deltaSmooth    = input.int(3,      "Delta Smoothing (1 = raw)",      group=grp1, minval=1, maxval=20)

grp2 = "📈 Cumulative Delta"
showCumDelta   = input.bool(true,  "Show Cumulative Delta Line",     group=grp2)
resetCumDaily  = input.bool(true,  "Reset Cumulative Delta Daily",   group=grp2)

grp3 = "🐋 Block Trade Detection"
showBlocks     = input.bool(true,  "Highlight Block Trades",         group=grp3)
blockMult      = input.float(2.5,  "Block Volume Multiplier (×Avg)", group=grp3, minval=1.0, step=0.1)
blockLookback  = input.int(20,     "Volume Average Lookback",        group=grp3, minval=5,   maxval=100)

grp4 = "⚡ Imbalance Zones"
showImbalance  = input.bool(true,  "Show Buy/Sell Imbalance",        group=grp4)
imbalThresh    = input.float(60.0, "Imbalance Threshold (%)",        group=grp4, minval=50.0, maxval=95.0)

grp5 = "📐 VWAP & Bands"
showVWAP       = input.bool(true,  "Show VWAP on Main Chart",        group=grp5)
vwapBands      = input.bool(true,  "Show VWAP ± 1 & 2σ Bands",      group=grp5)

grp6 = "🎨 Colors"
bullCol        = input.color(color.new(#00e5ff, 0),  "Bull / Buy Color",  group=grp6)
bearCol        = input.color(color.new(#ff1744, 0),  "Bear / Sell Color", group=grp6)
neutCol        = input.color(color.new(#90a4ae, 40), "Neutral Color",     group=grp6)

// ─────────────────────────────────────────────
//  ESTIMATED VOLUME DELTA
// ─────────────────────────────────────────────
hlRange    = high - low
buyVol     = hlRange > 0 ? volume * ((close - low) / hlRange) : volume * 0.5
sellVol    = volume - buyVol
rawDelta   = buyVol - sellVol
smoothDelta = ta.ema(rawDelta, deltaSmooth)

// ─────────────────────────────────────────────
//  CUMULATIVE DELTA
// ─────────────────────────────────────────────
isNewDay = ta.change(time("D")) != 0
var float cumDelta = 0.0
if resetCumDaily and isNewDay
    cumDelta := 0.0
cumDelta += smoothDelta

// ─────────────────────────────────────────────
//  BLOCK TRADE DETECTION
// ─────────────────────────────────────────────
avgVol    = ta.sma(volume, blockLookback)
isBlock   = volume >= avgVol * blockMult
blockBull = isBlock and close >= open
blockBear = isBlock and close < open

// ─────────────────────────────────────────────
//  BUY / SELL PRESSURE
// ─────────────────────────────────────────────
buyPct    = buyVol / volume * 100
sellPct   = sellVol / volume * 100
smoothBuy = ta.ema(buyPct, 5)

isBuyImbalance  = smoothBuy >= imbalThresh
isSellImbalance = smoothBuy <= (100 - imbalThresh)

// ─────────────────────────────────────────────
//  VWAP + STANDARD DEVIATION BANDS
// ─────────────────────────────────────────────
[vwap, upper1, lower1] = ta.vwap(hlc3, isNewDay, 1)
[_,    upper2, lower2] = ta.vwap(hlc3, isNewDay, 2)

// ─────────────────────────────────────────────
//  PLOTS
// ─────────────────────────────────────────────
deltaColor = smoothDelta > 0 ? bullCol : bearCol

plot(showDelta ? smoothDelta : na,
     style=plot.style_columns,
     color=color.new(deltaColor, 30),
     title="Volume Delta")

hline(0, "Zero", color=color.new(color.white, 60), linestyle=hline.style_dashed)

plot(showCumDelta ? cumDelta : na,
     color=color.new(#ffeb3b, 10),
     linewidth=2,
     title="Cumulative Delta")

pressureSignal = (smoothBuy - 50) * math.abs(ta.highest(math.abs(smoothDelta), 50)) / 50

plot(showImbalance ? pressureSignal : na,
     style=plot.style_area,
     color=color.new(isBuyImbalance ? bullCol : isSellImbalance ? bearCol : neutCol, 75),
     title="Buy/Sell Pressure Zone")

plotshape(showBlocks and blockBull ? smoothDelta : na,
          style=shape.triangleup,
          location=location.bottom,
          color=bullCol,
          size=size.small,
          title="Block Buy")

plotshape(showBlocks and blockBear ? smoothDelta : na,
          style=shape.triangledown,
          location=location.top,
          color=bearCol,
          size=size.small,
          title="Block Sell")

// ─────────────────────────────────────────────
//  INFO TABLE
// ─────────────────────────────────────────────
var table infoTable = table.new(position.top_right, 2, 7,
     bgcolor=color.new(#1a1a2e, 10),
     border_color=color.new(#ffffff, 70),
     border_width=1,
     frame_color=color.new(#ffffff, 50),
     frame_width=1)

if barstate.islast
    table.cell(infoTable, 0, 0, "ORDER FLOW SUITE",
         text_color=color.new(#ffffff, 0),
         text_size=size.small,
         bgcolor=color.new(#0d47a1, 10),
         text_halign=text.align_center)
    table.cell(infoTable, 1, 0, syminfo.ticker + " · " + timeframe.period,
         text_color=color.new(#90caf9, 0),
         text_size=size.small,
         bgcolor=color.new(#0d47a1, 10),
         text_halign=text.align_center)
    table.cell(infoTable, 0, 1, "Volume Delta",
         text_color=color.new(#b0bec5, 0), text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(math.round(smoothDelta)),
         text_color=smoothDelta > 0 ? bullCol : bearCol, text_size=size.small)
    table.cell(infoTable, 0, 2, "Cumul. Delta",
         text_color=color.new(#b0bec5, 0), text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(math.round(cumDelta)),
         text_color=cumDelta > 0 ? bullCol : bearCol, text_size=size.small)
    table.cell(infoTable, 0, 3, "Buy Pressure",
         text_color=color.new(#b0bec5, 0), text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(math.round(smoothBuy, 1)) + "%",
         text_color=isBuyImbalance ? bullCol : isSellImbalance ? bearCol : neutCol,
         text_size=size.small)
    table.cell(infoTable, 0, 4, "Block Trade",
         text_color=color.new(#b0bec5, 0), text_size=size.small)
    table.cell(infoTable, 1, 4,
         isBlock ? (blockBull ? "🐋 BULL BLOCK" : "🐻 BEAR BLOCK") : "—",
         text_color=isBlock ? (blockBull ? bullCol : bearCol) : neutCol,
         text_size=size.small)
    table.cell(infoTable, 0, 5, "VWAP",
         text_color=color.new(#b0bec5, 0), text_size=size.small)
    table.cell(infoTable, 1, 5, str.tostring(math.round(vwap, 2)),
         text_color=close > vwap ? bullCol : bearCol, text_size=size.small)
    bias = cumDelta > 0 and smoothBuy > 50 ? "BULLISH" :
           cumDelta < 0 and smoothBuy < 50 ? "BEARISH" : "NEUTRAL"
    biasCol = bias == "BULLISH" ? bullCol : bias == "BEARISH" ? bearCol : neutCol
    table.cell(infoTable, 0, 6, "Overall Bias",
         text_color=color.new(#b0bec5, 0), text_size=size.small)
    table.cell(infoTable, 1, 6, bias,
         text_color=biasCol, text_size=size.small,
         bgcolor=color.new(biasCol, 80))

// ─────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────
alertcondition(blockBull,
     title="🐋 Bull Block Trade",
     message="BLOCK BUY detected on {{ticker}} — large institutional buy volume!")

alertcondition(blockBear,
     title="🐻 Bear Block Trade",
     message="BLOCK SELL detected on {{ticker}} — large institutional sell volume!")

alertcondition(isBuyImbalance and not isBuyImbalance[1],
     title="⚡ Buy Imbalance",
     message="BUY IMBALANCE on {{ticker}} — buyers overwhelming sellers!")

alertcondition(isSellImbalance and not isSellImbalance[1],
     title="⚡ Sell Imbalance",
     message="SELL IMBALANCE on {{ticker}} — sellers overwhelming buyers!")

alertcondition(ta.crossover(cumDelta, 0),
     title="📈 Cumul. Delta Turned Positive",
     message="Cumulative Delta crossed above zero on {{ticker}}")

alertcondition(ta.crossunder(cumDelta, 0),
     title="📉 Cumul. Delta Turned Negative",
     message="Cumulative Delta crossed below zero on {{ticker}}")
````
