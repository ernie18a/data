# 9 EMA Bounce + FVG + Volume Pressure

- url: https://www.tradingview.com/script/c3y3rJfW-9-EMA-Bounce-FVG-Volume-Pressure/
- type: indicator
- pine_id: PUB;c8ab23e5a3eb4fa68e49a3d641ca5e1e
- version: 1.0

## Description

Scalp + Intraday  pattern day trading off the 9 ema test

## Source Code

````pine
// ============================================================
// 9 EMA Bounce + FVG + Volume Pressure — Bullish Alert Bot
// Markets: Stocks / Equities
// Timeframes: Scalping (1m/5m) and Swing (1H/4H)
// Pine Script v6
// Author: Built with Claude
// ============================================================

//@version=6
indicator(title = "9 EMA Bounce + FVG + Volume Pressure", shorttitle = "EMA9·FVG·VOL", overlay = true, max_bars_back = 500)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
grp_ema      = "9 EMA Settings"
emaLen       = input.int(9, "EMA Length", group = grp_ema)
emaTouchPct  = input.float(0.1, "EMA Touch Tolerance (%)", step = 0.05, group = grp_ema, tooltip = "How close the candle low must come to the EMA to count as a touch (% of price).")

grp_fvg      = "Fair Value Gap (FVG)"
fvgLookback  = input.int(30, "FVG Lookback (bars)", group = grp_fvg, tooltip = "How many bars back to scan for an open bullish FVG.")
showFVGBoxes = input.bool(true, "Highlight FVG Zone", group = grp_fvg)

grp_vol      = "Volume Confirmation"
volMethod    = input.string("Any", "Volume Method", options = ["Spike (20-MA)", "Candle-over-Candle", "OBV Rising", "Any"], group = grp_vol)
volMaLen     = input.int(20, "Volume MA Length", group = grp_vol)
volMulti     = input.float(1.5, "Spike Multiplier (x MA)", step = 0.1, group = grp_vol, tooltip = "Volume must exceed this multiple of the MA to count as a spike.")

grp_display  = "Display"
showSignals  = input.bool(true, "Show Buy Signals on Chart", group = grp_display)
showEMA      = input.bool(true, "Show 9 EMA Line", group = grp_display)

// ─────────────────────────────────────────
// 1. 9 EMA
// ─────────────────────────────────────────
ema9 = ta.ema(close, emaLen)
plot(showEMA ? ema9 : na, color = color.new(color.yellow, 0), linewidth = 2, title = "9 EMA")

// ─────────────────────────────────────────
// 2. EMA TOUCH + BULLISH BOUNCE
// ─────────────────────────────────────────
tolerance       = ema9 * (emaTouchPct / 100.0)
emaTouched      = low <= ema9 + tolerance and low >= ema9 - tolerance
emaBounce       = close > ema9
bullishCandle   = close > open
emaBounceSignal = emaTouched and emaBounce and bullishCandle

// ─────────────────────────────────────────
// 3. FAIR VALUE GAP DETECTION
// ─────────────────────────────────────────
var bool  fvgActive = false
var float fvgTopVal = na
var float fvgBotVal = na

fvgActive := false
fvgTopVal := na
fvgBotVal := na

for i = 1 to fvgLookback
    gapBot = high[i + 1]
    gapTop = low[i - 1]
    if gapTop > gapBot
        if close >= gapBot and close <= gapTop
            fvgActive := true
            fvgTopVal := gapTop
            fvgBotVal := gapBot
            break
        if close >= gapBot * 0.998 and close < gapBot * 1.005
            fvgActive := true
            fvgTopVal := gapTop
            fvgBotVal := gapBot
            break

bgcolor(showFVGBoxes and fvgActive ? color.new(color.teal, 88) : na, title = "FVG Zone")

// ─────────────────────────────────────────
// 4. VOLUME CONFIRMATION
// ─────────────────────────────────────────
volMA     = ta.sma(volume, volMaLen)
obvVal    = ta.obv
obvMA     = ta.ema(obvVal, 5)
obvRising = obvVal > obvMA
volSpike  = volume > volMA * volMulti
volCoc    = volume > volume[1]

volumeOK = switch volMethod
    "Spike (20-MA)"      => volSpike
    "Candle-over-Candle" => volCoc
    "OBV Rising"         => obvRising
    "Any"                => volSpike or volCoc or obvRising
    => false

// ─────────────────────────────────────────
// 5. COMBINED SIGNAL
// ─────────────────────────────────────────
buySignal = emaBounceSignal and fvgActive and volumeOK

// ─────────────────────────────────────────
// 6. PLOT SIGNALS
// ─────────────────────────────────────────
plotshape(showSignals and buySignal,
     title    = "Buy Signal",
     location = location.belowbar,
     style    = shape.labelup,
     color    = color.new(color.lime, 0),
     textcolor = color.black,
     text     = "BUY",
     size     = size.normal)

plotshape(showSignals and emaBounceSignal and not buySignal,
     title    = "EMA Touch (unconfirmed)",
     location = location.belowbar,
     style    = shape.triangleup,
     color    = color.new(color.orange, 50),
     size     = size.tiny)

// ─────────────────────────────────────────
// 7. INFO TABLE
// ─────────────────────────────────────────
var table infoTable = table.new(position.top_right, 2, 6,
     bgcolor      = color.new(color.black, 70),
     border_color = color.new(color.gray, 60),
     border_width = 1,
     frame_color  = color.new(color.gray, 40),
     frame_width  = 1)

if barstate.islast
    table.cell(infoTable, 0, 0, "CONDITION",       text_color = color.silver, text_size = size.small, bgcolor = color.new(color.navy, 40))
    table.cell(infoTable, 1, 0, "STATUS",          text_color = color.silver, text_size = size.small, bgcolor = color.new(color.navy, 40))
    table.cell(infoTable, 0, 1, "9 EMA Touch",     text_color = color.white,  text_size = size.small)
    table.cell(infoTable, 1, 1, emaTouched      ? "YES" : "NO", text_color = emaTouched      ? color.lime : color.red, text_size = size.small)
    table.cell(infoTable, 0, 2, "Bullish Bounce",  text_color = color.white,  text_size = size.small)
    table.cell(infoTable, 1, 2, emaBounceSignal ? "YES" : "NO", text_color = emaBounceSignal ? color.lime : color.red, text_size = size.small)
    table.cell(infoTable, 0, 3, "Inside FVG",      text_color = color.white,  text_size = size.small)
    table.cell(infoTable, 1, 3, fvgActive       ? "YES" : "NO", text_color = fvgActive       ? color.lime : color.red, text_size = size.small)
    table.cell(infoTable, 0, 4, "Volume OK",       text_color = color.white,  text_size = size.small)
    table.cell(infoTable, 1, 4, volumeOK        ? "YES" : "NO", text_color = volumeOK        ? color.lime : color.red, text_size = size.small)
    table.cell(infoTable, 0, 5, "SIGNAL",          text_color = color.white,  text_size = size.small, bgcolor = color.new(color.navy, 20))
    table.cell(infoTable, 1, 5, buySignal       ? "BUY" : "WAIT", text_color = buySignal     ? color.lime : color.gray, text_size = size.small, bgcolor = color.new(color.navy, 20))

// ─────────────────────────────────────────
// 8. ALERTS
// ─────────────────────────────────────────
alertcondition(buySignal,
     title   = "9EMA Bounce + FVG + Volume - BUY SETUP",
     message = "BUY ALERT - {ticker} {interval}: Price bounced off 9 EMA inside a bullish FVG with strong volume pressure. Check your risk levels before entering!")
````
