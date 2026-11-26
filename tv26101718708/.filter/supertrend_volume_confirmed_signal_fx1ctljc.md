# Supertrend - Volume Confirmed Signal

- url: https://www.tradingview.com/script/fx1CtljC/
- type: indicator
- pine_id: PUB;77a9bb560f6d4d3b9ac6d1153a019a57
- version: 3.0

## Description

This indicator combines the classic Supertrend (by Olivier Seban) with a volume confirmation filter. It fires a signal only when two conditions are met on the same candle: the Supertrend has recently changed direction (within a configurable 1-3 bar window) AND the confirming candle closes in the direction of the new trend with volume above its moving average. This significantly reduces false signals compared to standard Supertrend.
Developed with the help of Claude AI. No repainting observed.
Observations on 60 and 90-min TFs on moderately volatile altcoins (SUI, DOT): signals appear selectively and tend to align with meaningful moves. Not backtested formally — use your own judgment. Always place your SL just beyond the Supertrend line.
Default settings: ATR 3, Factor 2, Volume lookback 20. Adjust to your instrument and timeframe.
Not financial advice.

## Source Code

````pine
// Supertrend - Volume Confirmed Signal
// Based on the Supertrend indicator concept by Olivier Seban.
// Extended with a volume confirmation filter — signals fire only when
// Supertrend changes direction AND the next candle confirms with above-average volume.
// Developed with the help of Claude AI (Anthropic).

//@version=5
indicator(title="Supertrend - Volume Confirmed Signal", shorttitle="ST VolumeConfirm", overlay=true)

// ── Supertrend Parameters ─────────────────────────────────────────────────────
atrPeriod   = input.int(3,    title="ATR Period",      minval=1)
factor      = input.float(2.0, title="ATR Factor",      minval=0.01, step=0.1)

// ── Volume Filter Parameters ─────────────────────────────────────────────
volLookback = input.int(20,   title="Volume Lookback (bars)", minval=5)
volMulti    = input.float(1.0, title="Min Volume Multiplier (e.g. 1.2 = 20% above avg)", minval=0.1, step=0.1)
confirmWindow = input.int(2, title="Confirmation Window (bars after change, 2-4)", minval=2, maxval=4)

// ── Supertrend Calculation ────────────────────────────────────────────────────
[supertrend, direction] = ta.supertrend(factor, atrPeriod)

// direction: -1 = uptrend (line below price, green)
//             1 = downtrend (line above price, red)

// Detect direction change
// LONG change: previously downtrend (1), now uptrend (-1)
// SHORT change: previously uptrend (-1), now downtrend (1)
dirChanged_toLong  = direction == -1 and direction[1] == 1
dirChanged_toShort = direction == 1  and direction[1] == -1

// ── Track direction change within confirmation window ────────────────────────────
// Looks back confirmWindow bars to see if a direction change occurred
// This makes the confirmation window configurable (1-3 bars)

confirmLong  = false
confirmShort = false
for i = 1 to confirmWindow
    if dirChanged_toLong[i]
        confirmLong := true
    if dirChanged_toShort[i]
        confirmShort := true

// ── Volume Filter ──────────────────────────────────────────────────────────
avgVol      = ta.sma(volume, volLookback)
highVolume  = volume >= avgVol * volMulti

// ── Candle Color Filter ─────────────────────────────────────────────────────────
// Bullish candle: close >= open
// Bearish candle: close < open
bullCandle  = close >= open
bearCandle  = close < open

// ── Final Signals ───────────────────────────────────────────────────────────
// LONG: direction changed within last confirmWindow bars
//       current bar = bullish candle + above-average volume
signalLong  = confirmLong  and bullCandle and highVolume and not dirChanged_toLong

// SHORT: direction changed within last confirmWindow bars
//        current bar = bearish candle + above-average volume
signalShort = confirmShort and bearCandle and highVolume and not dirChanged_toShort

// ── Plots ───────────────────────────────────────────────────────────────────
// Supertrend line
plot(supertrend,
     title="Supertrend",
     color=direction == -1 ? color.new(color.green, 0) : color.new(color.red, 0),
     linewidth=2)

// Small grey dot on first change bar (informational only)
plotshape(dirChanged_toLong,
          title="Direction change -> Long (1st bar)",
          location=location.belowbar,
          style=shape.circle,
          color=color.new(color.gray, 50),
          size=size.tiny)

plotshape(dirChanged_toShort,
          title="Direction change -> Short (1st bar)",
          location=location.abovebar,
          style=shape.circle,
          color=color.new(color.gray, 50),
          size=size.tiny)

// Large triangle on confirmed signal (2nd bar + above-average volume)
plotshape(signalLong,
          title="LONG - confirmed by volume",
          location=location.belowbar,
          style=shape.triangleup,
          color=color.new(color.lime, 0),
          size=size.normal,
          text="L✓")

plotshape(signalShort,
          title="SHORT - confirmed by volume",
          location=location.abovebar,
          style=shape.triangledown,
          color=color.new(color.red, 0),
          size=size.normal,
          text="S✓")

// ── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(signalLong,
     title="🟢 LONG - Supertrend change confirmed by volume",
     message="🟢 LONG SETUP: Supertrend flipped bullish. Confirming candle closed green with above-average volume. Consider entering LONG. Place SL below the Supertrend line.")

alertcondition(signalShort,
     title="🔴 SHORT - Supertrend change confirmed by volume",
     message="🔴 SHORT SETUP: Supertrend flipped bearish. Confirming candle closed red with above-average volume. Consider entering SHORT. Place SL above the Supertrend line.")

// ── Info Panel ────────────────────────────────────────────────────────
var table infoTable = table.new(position.top_right, 2, 6,
     bgcolor=color.new(color.black, 70),
     border_width=1)

if barstate.islast
    table.cell(infoTable, 0, 0, "Parameter",       text_color=color.gray,  text_size=size.small)
    table.cell(infoTable, 1, 0, "Value",           text_color=color.gray,  text_size=size.small)
    table.cell(infoTable, 0, 1, "ATR Period",       text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 1, str.tostring(atrPeriod), text_color=color.yellow, text_size=size.small)
    table.cell(infoTable, 0, 2, "ATR Factor",       text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 2, str.tostring(factor),    text_color=color.yellow, text_size=size.small)
    table.cell(infoTable, 0, 3, "Vol lookback",     text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 3, str.tostring(volLookback), text_color=color.yellow, text_size=size.small)
    table.cell(infoTable, 0, 4, "Vol min x avg",    text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 4, str.tostring(volMulti) + "x", text_color=color.yellow, text_size=size.small)
    table.cell(infoTable, 0, 5, "Confirm window",   text_color=color.white, text_size=size.small)
    table.cell(infoTable, 1, 5, str.tostring(confirmWindow) + " bar(s)", text_color=color.yellow, text_size=size.small)
````
