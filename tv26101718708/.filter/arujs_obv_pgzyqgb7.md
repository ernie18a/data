# Aruj's OBV 

- url: https://www.tradingview.com/script/PGzYqgB7-Aruj-s-OBV/
- type: indicator
- pine_id: PUB;5d229488b0ed4698982dda9ca1c20eab
- version: 1.0

## Description

On-Balance Volume (OBV) is a momentum indicator that adds volume on up-closes and subtracts it on down-closes, giving you a running measure of whether volume is flowing into or out of an instrument. The idea: volume often moves before price, so OBV can hint at conviction behind a move — or warn of divergence when price and OBV disagree.
This indicator does one thing differently: instead of sitting in a separate pane, OBV is rescaled and plotted directly on the price chart as an overlay. You read volume flow and candles in the same glance — useful for intraday, where switching focus between panes costs you.
How it works
The raw OBV is normalized to a 0–1 range over a configurable lookback, then mapped onto a band that's anchored to a short 20-EMA of price and sized using ATR. The result is an OBV "wave" that hugs the candles and auto-adjusts to recent volatility, so it stays readable whether the instrument is quiet or trending hard.
Settings
Scaling & Position

Lookback Period — bars used to normalize OBV. Smaller is more reactive; ~100 for 5m, ~150 for 15m.
Anchor Position — place the OBV wave above, below, or centered on price.
Auto-Fit Height (ATR) — sizes the wave to recent volatility. Recommended ON for intraday.
Height Multiplier / Height % — controls wave amplitude (ATR mode vs. manual mode).
Offset Distance — how far the wave sits from the candles.

Smoothing

Optional moving average over OBV — SMA, EMA, SMMA (RMA), WMA, or VWMA.
SMA + Bollinger Bands adds volatility bands around the OBV MA to flag when volume flow is stretched.

How to read it
Watch the shape, not the absolute value (it's normalized). OBV rising while price stalls = accumulation building. OBV falling into a price high = bearish divergence, momentum may be hollow. The smoothing MA helps filter noise on lower timeframes.
Notes
Requires an instrument with real volume data — won't work on feeds that don't supply volume. Tuned for intraday but works on any timeframe. Open-source — feel free to learn from it or adapt it.

## Source Code

````pine
//@version=6
indicator(title="OBV on Price Chart (Intraday)", shorttitle="OBV-Intraday", overlay=true, timeframe="", timeframe_gaps=true)

var cumVol = 0.
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("No volume is provided by the data vendor.")

// === OBV Calculation ===
src = close
obv = ta.cum(math.sign(ta.change(src)) * volume)

// === Scaling Inputs ===
GRP_SCALE = "Scaling & Position"
lookback   = input.int(150, "Lookback Period (bars)", minval=20, group=GRP_SCALE, tooltip="Smaller = more reactive (good for intraday). Try 100 for 5m, 150 for 15m.")
anchorMode = input.string("Above Price", "Anchor Position", options=["Above Price", "Below Price", "Centered on Price"], group=GRP_SCALE, tooltip="Where to place OBV relative to candles.")
autoFit    = input.bool(true, "Auto-Fit Height (uses ATR)", group=GRP_SCALE, tooltip="Automatically sizes OBV based on recent volatility. Recommended ON for intraday.")
heightMult = input.float(3.0, "Height Multiplier (ATR mode)", minval=0.5, step=0.5, group=GRP_SCALE, tooltip="Used when Auto-Fit is ON. Higher = taller OBV wave.")
heightPerc = input.float(2.0, "Height % (manual mode)", minval=0.1, step=0.5, group=GRP_SCALE, tooltip="Used when Auto-Fit is OFF.")
offsetMult = input.float(1.5, "Offset Distance (ATR units)", step=0.5, group=GRP_SCALE, tooltip="Distance from price. Higher = farther from candles.")

// === Anchor to recent price (not long SMA) ===
priceAnchor = ta.ema(close, 20)   // Short EMA hugs the candles
atr         = ta.atr(20)

// === Normalize OBV to 0..1 ===
obvHigh  = ta.highest(obv, lookback)
obvLow   = ta.lowest(obv,  lookback)
obvRange = obvHigh - obvLow
obvNorm  = obvRange != 0 ? (obv - obvLow) / obvRange : 0.5

// === Calculate height (ATR-based or manual) ===
height = autoFit ? atr * heightMult : priceAnchor * (heightPerc / 100)

// === Calculate offset based on anchor mode ===
offset = switch anchorMode
    "Above Price"        =>  atr * offsetMult + height / 2
    "Below Price"        => -atr * offsetMult - height / 2
    "Centered on Price"  =>  0.0

// === Final OBV scaled position ===
obvScaled = priceAnchor + offset + (obvNorm - 0.5) * height

plot(obvScaled, color=#FF1493, title="OBV (Scaled)", linewidth=2)

// === Smoothing MA ===
GRP = "Smoothing"
TT_BB = "Only applies when 'SMA + Bollinger Bands' is selected."
maTypeInput  = input.string("None", "Type", options=["None","SMA","SMA + Bollinger Bands","EMA","SMMA (RMA)","WMA","VWMA"], group=GRP)
maLengthInput = input.int(14, "Length", group=GRP)
bbMultInput   = input.float(2.0, "BB StdDev", minval=0.001, maxval=50, step=0.5, tooltip=TT_BB, group=GRP)

isBB     = maTypeInput == "SMA + Bollinger Bands"
enableMA = maTypeInput != "None"

ma(source, length, MAtype) =>
    switch MAtype
        "SMA"                   => ta.sma(source, length)
        "SMA + Bollinger Bands" => ta.sma(source, length)
        "EMA"                   => ta.ema(source, length)
        "SMMA (RMA)"            => ta.rma(source, length)
        "WMA"                   => ta.wma(source, length)
        "VWMA"                  => ta.vwma(source, length)

smoothingMA_raw = enableMA ? ma(obv, maLengthInput, maTypeInput) : na
smoothingMA = enableMA and obvRange != 0 ? priceAnchor + offset + ((smoothingMA_raw - obvLow) / obvRange - 0.5) * height : na
smoothingStDevRaw = isBB ? ta.stdev(obv, maLengthInput) * bbMultInput : na
smoothingStDev = isBB and obvRange != 0 ? (smoothingStDevRaw / obvRange) * height : na

plot(smoothingMA, "OBV MA", color=color.yellow, display = enableMA ? display.all : display.none)
bbUpper = plot(smoothingMA + smoothingStDev, "Upper BB", color=color.green, display = isBB ? display.all : display.none)
bbLower = plot(smoothingMA - smoothingStDev, "Lower BB", color=color.green, display = isBB ? display.all : display.none)
fill(bbUpper, bbLower, color = isBB ? color.new(color.green, 90) : na, title="BB Fill")
````
