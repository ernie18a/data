# Embedded Scaled Stochastic

- url: https://www.tradingview.com/script/R9y5ZQeu-Embedded-Scaled-Stochastic/
- type: indicator
- pine_id: PUB;316ba28e2cb644d08953e540d7e56e7e
- version: 1.0

## Description

Embedded Scaled Stochastic is a custom Pine Script (v6) indicator that "embeds" a Stochastic Oscillator (%K and %D) directly onto the price chart (overlay=true).Instead of displaying the Stochastic in a separate pane between 0–100, it scales the Stochastic values to the actual price range of a higher timeframe (default: Daily). The scaling uses the 20–80 levels from the Stochastic to map them between dynamic Bearish Exit Level (≈20) and Bullish Exit Level (≈80), which are calculated from the high/low range over the chosen Stochastic length on the higher timeframe.Key Features:Higher TF Levels (levelTF): Defines the price range (highest high / lowest low) used for scaling.
Stochastic TF (stochTF): The timeframe from which the actual %K/%D is taken (can be different from the chart TF).
Plots the scaled %K (blue) and scaled %D (fuchsia) as price lines.
Shows dynamic Bullish Embed Exit (80) (red line) and Bearish Embed Exit (20) (green line).
Optional midline (50), faint 0/100 lines, and background shading for:Danger Zone (20–80) — gray
Bullish Extreme (80–100) — red tint
Bearish Extreme (0–20) — green tint

In short: It turns the Stochastic into a price-based momentum ribbon anchored to higher-timeframe structure.Main Use CasesMulti-Timeframe Momentum Visualization (Primary Use)See higher-timeframe Stochastic momentum directly on your lower-timeframe chart without switching panes or timeframes.
Example: Chart on 15m or 1H, but embed Daily Stochastic scaled to Daily highs/lows.

Dynamic Overbought/Oversold Levels in Price TermsThe 80-level becomes a real price (Bullish Embed Exit) and the 20-level becomes another real price (Bearish Embed Exit).
These levels act as dynamic support/resistance or exit zones based on momentum.

Trend-Filtered Entries & ExitsBullish setup: Price above the green 20-line + scaled Stochastic rising/crossing up from oversold area.
Bearish setup: Price below the red 80-line + scaled Stochastic falling/crossing down from overbought area.
Crossovers between scaled %K and %D can generate signals, but now interpreted in actual price context.

Mean-Reversion vs. Momentum TradingWhen price is in the Danger Zone (between 20–80 lines) → ranging/choppy market.
When Stochastic pushes into Bullish Extreme (above 80) or Bearish Extreme (below 20) → strong momentum or potential exhaustion.

Scalping / Swing TradingUseful on lower timeframes (5m–1H) while keeping higher-timeframe context (D or W) for the levels.
Helps avoid fighting the higher-timeframe momentum.

How Traders Typically Use ItLook for confluence: Scaled Stochastic crossing + price reacting at the embedded 20/80 levels.
Use the shaded zones visually: Green tint below 20 often signals strong bearish momentum (or deep oversold), red tint above 80 signals strong bullish momentum.
Combine with price action, support/resistance, or other indicators (e.g., EMA, volume).

This indicator is especially powerful for traders who like Stochastic but want it visually integrated with price action instead of in a hidden sub-pane. It effectively creates "price-scaled momentum bands" using multi-timeframe data.

## Source Code

````pine
//@version=6
indicator("Embedded Scaled Stochastic", shorttitle="Embedded Stoch", overlay=true)

// ── User Inputs ─────────────────────────────────────────────────────────────
levelTF     = input.timeframe("D",  "Higher TF for Embedded Levels (20/80)", group="Timeframe Settings")
stochTF     = input.timeframe("1",  "Timeframe for Stochastic (%K & %D)",    group="Stochastic Settings")

kLength     = input.int(14, title="%K Length",          minval=1, group="Stochastic Settings")
slowSmooth  = input.int(3,  title="Slow %K Smoothing",  minval=1, group="Stochastic Settings")
dSmooth     = input.int(3,  title="Slow %D Smoothing",  minval=1, group="Stochastic Settings")

// Display Options
showScaled   = input.bool(true,  "Show Scaled %K & %D",                    group="Display")
showMidline  = input.bool(true,  "Show Scaled 50 Midline",                 group="Display")
showExtremes = input.bool(true,  "Show Faint Scaled 0 & 100 Lines",        group="Display")

// Shading Controls
shadeDanger  = input.bool(true,  "Shade Danger Zone (20–80)",      group="Shading")
shadeBullExt = input.bool(true,  "Shade Bullish Extreme (80–100)", group="Shading")
shadeBearExt = input.bool(true,  "Shade Bearish Extreme (0–20)",   group="Shading")

kWidth       = input.int(2, "Scaled %K Width", minval=1, maxval=5, group="Display")
dWidth       = input.int(2, "Scaled %D Width", minval=1, maxval=5, group="Display")

// ── Embedded Price Levels ─────────────────────────────────────────────────
[higherHigh, higherLow] = request.security(syminfo.tickerid, levelTF, 
     [ta.highest(high, kLength), ta.lowest(low, kLength)],
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

hh      = higherHigh
ll      = higherLow
range14 = hh - ll

priceFor80 = ll + range14 * 0.80
priceFor20 = ll + range14 * 0.20
midpoint   = ll + range14 * 0.50

bullExitLevel = math.max(priceFor80, nz(priceFor80[1], priceFor80))
bearExitLevel = math.min(priceFor20, nz(priceFor20[1], priceFor20))

// ── Stochastic from chosen timeframe ───────────────────────────────────────
[rawK, k, d] = request.security(syminfo.tickerid, stochTF,
     [ta.stoch(close, high, low, kLength),
      ta.sma(ta.stoch(close, high, low, kLength), slowSmooth),
      ta.sma(ta.sma(ta.stoch(close, high, low, kLength), slowSmooth), dSmooth)],
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on)

// ── Scale Stochastic values ────────────────────────────────────────────────
priceRange20_80 = bullExitLevel - bearExitLevel

scaledK   = bearExitLevel + (k - 20) * (priceRange20_80 / 60)
scaledD   = bearExitLevel + (d - 20) * (priceRange20_80 / 60)
scaled50  = bearExitLevel + (50 - 20) * (priceRange20_80 / 60)
scaled0   = bearExitLevel + (0  - 20) * (priceRange20_80 / 60)
scaled100 = bearExitLevel + (100 - 20) * (priceRange20_80 / 60)

// ── Plotting ───────────────────────────────────────────────────────────────
plot(bullExitLevel, "Bullish Embed Exit (80)", color=color.new(color.red,    0), linewidth=2)
plot(bearExitLevel,"Bearish Embed Exit (20)",  color=color.new(color.green,  0), linewidth=2)

// Reference Lines
plot(showExtremes ? scaled0   : na, "Scaled 0",   color=color.new(color.gray, 80), linewidth=1)
plot(showMidline  ? scaled50  : na, "Scaled 50",  color=color.new(color.yellow, 70), linewidth=1)
plot(showExtremes ? scaled100 : na, "Scaled 100", color=color.new(color.gray, 80), linewidth=1)

// Scaled Stochastic
plot(showScaled ? scaledK : na, "Scaled %K", color=color.new(color.blue, 0), linewidth=kWidth)
plot(showScaled ? scaledD : na, "Scaled %D", color=color.new(color.fuchsia, 0), linewidth=dWidth)

// ── User-Controlled Shading ────────────────────────────────────────────────
fill(plot(bullExitLevel), plot(bearExitLevel), 
     color = shadeDanger ? color.new(color.gray, 92) : na, 
     title="Danger Zone (20–80)")

fill(plot(scaled100), plot(bullExitLevel), 
     color = shadeBullExt ? color.new(color.red, 88) : na, 
     title="Bullish Extreme (80–100)")

fill(plot(bearExitLevel), plot(scaled0), 
     color = shadeBearExt ? color.new(color.green, 88) : na, 
     title="Bearish Extreme (0–20)")
````
