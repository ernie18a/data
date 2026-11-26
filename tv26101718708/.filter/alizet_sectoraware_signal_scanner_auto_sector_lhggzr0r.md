# ALIZET - Sector-Aware Signal Scanner Auto Sector

- url: https://www.tradingview.com/script/LhGGZr0r-ALIZET-Sector-Aware-Signal-Scanner-Auto-Sector/
- type: indicator
- pine_id: PUB;fb584595302a405f947387e3f9749b0f
- version: 1.0

## Description

This Pine Script v6 indicator is a sector-aware entry signal tool that combines stock-level momentum with its sector’s trend. It first calculates fast and slow EMAs on the current symbol and looks for bullish and bearish crossovers; those crossovers can be gated by an RSI filter so that long signals only fire when RSI is above 50 and short signals only fire when RSI is below 50.

To make the signals “sector-aware,” the script automatically detects the stock’s sector and maps it to a corresponding SPDR sector ETF (for example, technology stocks to XLK, financials to XLF), with an option to override this via a manual sector-ETF input. It then pulls the sector ETF’s price and computes an EMA on that ETF; a buy signal only appears when the stock’s bullish EMA crossover happens while the sector ETF is trading above its EMA (sector in an uptrend), and a sell signal only appears when the stock’s bearish crossover occurs while the sector ETF is below its EMA (sector in a downtrend).

Visually, the indicator plots the fast and slow EMAs on the price chart and marks qualifying entries with “BUY” triangles below bars and “SELL” triangles above bars. It also draws an optional label on the most recent bar showing which sector was detected and which ETF is being used for confirmation, and defines alert conditions for both buy and sell events so you can create real-time alerts aligned with sector momentum.

## Source Code

````pine
//@version=6
indicator("ALIZET - Sector-Aware Signal Scanner Auto Sector", overlay=true, dynamic_requests=true)

// Inputs
useAutoSector = input.bool(true, "Auto-detect Sector ETF")
manualSector  = input.string("AMEX:XLK", "Manual Sector ETF")
fastLen       = input.int(10, "Fast EMA", minval=1)
slowLen       = input.int(20, "Slow EMA", minval=1)
rsiLen        = input.int(14, "RSI Length", minval=1)
useRSI        = input.bool(true, "Use RSI Filter")
sectorEmaLen  = input.int(20, "Sector EMA Length", minval=1)
showSectorLbl = input.bool(true, "Show Sector Label")

// Detect sector from current chart symbol
sectorName = syminfo.sector

// Map sector names to SPDR sector ETFs
autoSectorETF =
     sectorName == "Technology"                    ? "AMEX:XLK" :
     sectorName == "Electronic Technology"         ? "AMEX:XLK" :
     sectorName == "Finance"                       ? "AMEX:XLF" :
     sectorName == "Financial Services"            ? "AMEX:XLF" :
     sectorName == "Health Technology"             ? "AMEX:XLV" :
     sectorName == "Healthcare"                    ? "AMEX:XLV" :
     sectorName == "Health Services"               ? "AMEX:XLV" :
     sectorName == "Energy Minerals"               ? "AMEX:XLE" :
     sectorName == "Process Industries"            ? "AMEX:XLB" :
     sectorName == "Consumer Non-Durables"         ? "AMEX:XLP" :
     sectorName == "Consumer Durables"             ? "AMEX:XLY" :
     sectorName == "Retail Trade"                  ? "AMEX:XLY" :
     sectorName == "Consumer Services"             ? "AMEX:XLY" :
     sectorName == "Communications"                ? "AMEX:XLC" :
     sectorName == "Commercial Services"           ? "AMEX:XLC" :
     sectorName == "Utilities"                     ? "AMEX:XLU" :
     sectorName == "Transportation"                ? "AMEX:XLI" :
     sectorName == "Producer Manufacturing"        ? "AMEX:XLI" :
     sectorName == "Industrial Services"           ? "AMEX:XLI" :
     sectorName == "Distribution Services"         ? "AMEX:XLI" :
     sectorName == "Real Estate Development"       ? "AMEX:XLRE" :
     sectorName == "Real Estate Investment Trusts" ? "AMEX:XLRE" :
     "AMEX:SPY"

// Final sector ETF selection
sectorETF = useAutoSector ? autoSectorETF : manualSector

// Stock logic
fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)
rsiVal  = ta.rsi(close, rsiLen)

stockLong  = ta.crossover(fastEMA, slowEMA) and (not useRSI or rsiVal > 50)
stockShort = ta.crossunder(fastEMA, slowEMA) and (not useRSI or rsiVal < 50)

// Sector filter
sectorClose = request.security(sectorETF, timeframe.period, close)
sectorEMA   = request.security(sectorETF, timeframe.period, ta.ema(close, sectorEmaLen))

sectorBull = sectorClose > sectorEMA
sectorBear = sectorClose < sectorEMA

// Final signals
buySignal  = stockLong and sectorBull
sellSignal = stockShort and sectorBear

// Visuals
plot(fastEMA, "Fast EMA", color=color.new(color.green, 0), linewidth=2)
plot(slowEMA, "Slow EMA", color=color.new(color.red, 0), linewidth=2)

plotshape(buySignal,  title="Buy",  style=shape.triangleup,   location=location.belowbar, color=color.lime, size=size.small, text="BUY")
plotshape(sellSignal, title="Sell", style=shape.triangledown, location=location.abovebar, color=color.red,  size=size.small, text="SELL")

// Optional label showing detected sector/ETF
var label sectorLabel = na
if barstate.islast and showSectorLbl
    label.delete(sectorLabel)
    sectorLabel := label.new(
         bar_index,
         high,
         "Sector: " + str.tostring(sectorName) + "\nETF: " + sectorETF,
         style=label.style_label_down,
         textcolor=color.white,
         color=color.new(color.blue, 65)
     )

// Alerts
alertcondition(buySignal, "Buy Signal", "BUY signal | Sector aligned")
alertcondition(sellSignal, "Sell Signal", "SELL signal | Sector aligned")
````
