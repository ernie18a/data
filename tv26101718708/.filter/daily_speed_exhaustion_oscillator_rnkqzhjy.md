# Daily Speed Exhaustion Oscillator

- url: https://www.tradingview.com/script/RNkQZhJY/
- type: indicator
- pine_id: PUB;7bc115e806644ee9b721e799a947b7c2
- version: 1.0

## Description

Daily Speed Exhaustion Oscillator

OVERVIEW

The Daily Speed Exhaustion Oscillator is a momentum tool that measures how far price has traveled from the daily open relative to how much the asset typically moves in a full day. Its single purpose is to detect speed exhaustion: the moment when a fast directional move has spent its typical daily range and is likely to lose momentum.

This indicator does not measure direction or predict reversals. It measures the velocity of the current move relative to the asset's normal daily behavior.

WHAT IT IS MADE OF

The oscillator is built from three components:

1. Daily open reference. The indicator captures the opening price of the current daily session and uses it as the zero line. All measurement is relative to this point.

2. Average daily range. Each asset has its own typical daily range. The indicator stores a configurable average daily range per asset (Gold and EURUSD), with market-based default values that can be adjusted manually.

3. Normalized distance. The current distance of price from the daily open is divided by the average daily range and expressed as a percentage.

CALCULATION

The core formula is:

oscillator = (close - daily open) / average daily range * 100

A reading of 0% means price is sitting at the daily open. A reading of +100% means price has moved away from the open by an amount equal to one full typical day, entirely to the upside. A reading of -100% means the same to the downside. Readings beyond +/-150% indicate the move has exceeded one and a half times the normal daily range.

The daily open is captured directly on the chart by detecting the change of the daily session, which keeps the value stable across any intraday timeframe without repainting.

BANDS

Two band pairs are drawn:

- Upper and lower bands at +/-100%: price has covered a full typical day in one direction.
- Extreme bands at +/-150%: price has covered one and a half typical days in one direction.

The asset is auto-detected from the chart symbol, or can be selected manually. Each asset uses its own average daily range, so the same percentage scale is comparable regardless of the instrument.

HOW TO INTERPRET IT

The interpretation is simple and focused on one idea: when the oscillator line enters a band, expect the price to decelerate.

Once price has traveled more than its normal daily range, it cannot keep accelerating indefinitely. Reaching a band means the fast portion of the move has been spent. From that point, the move is statistically likely to slow down.

The line returning toward the center after touching a band is the signal that the fast move has ended and speed is normalizing. Because the indicator measures speed and not direction, the line returning to the center simply confirms that the sprint is over, regardless of what price does next.

The deeper the penetration into a band (especially beyond the extreme +/-150% level), the stronger the signal that the current pace will not continue.

HOW TO USE IT

Use this indicator to identify deceleration. When the oscillator enters a band, treat it as a signal that the rapid move is exhausting and is likely to slow down. This is useful as a filter to avoid chasing a move that has already covered its typical daily range and is about to lose momentum.

Watch for the line touching or penetrating a band, then observe price decelerate as the line returns toward the center.

NOTES

Default ranges are set for Gold (30 USD) and EURUSD (0.0070), based on typical average daily range values. These can be adjusted in the settings to match current volatility. For best results, observe the values your asset reaches and calibrate the average daily range so the bands are reached only on genuinely fast moves.

## Source Code

````pine
//@version=6
indicator("Daily Speed Exhaustion Oscillator", overlay=false)

// ─── ASSET AUTO-DETECTION ─────────────────────────────────────────────────────
mode = input.string("Auto", "Asset", options=["Auto","Gold","EURUSD"], tooltip="Auto detects the asset from the chart symbol")

bool isGold = str.contains(str.upper(syminfo.ticker), "XAU") or str.contains(str.upper(syminfo.ticker), "GOLD") or str.contains(str.upper(syminfo.ticker), "GC")
string asset = mode == "Gold" ? "Gold" : mode == "EURUSD" ? "EURUSD" : (isGold ? "Gold" : "EURUSD")

// ─── PER-ASSET CONFIGURATION (market-based values) ────────────────────────────
// Gold: ADR ~200-500 pips = ~20-50 USD in price. Center: 30 USD
// EURUSD: ADR 50-80 pips = 0.0050-0.0080. Center: 0.0070
goldRange   = input.float(30.0,   "Gold: average daily range (USD)", minval=0.0, step=1.0,    group="Gold settings")
eurusdRange = input.float(0.0070, "EURUSD: average daily range",     minval=0.0, step=0.0001, group="EURUSD settings")

// ─── LEVELS ───────────────────────────────────────────────────────────────────
obLevel = input.float(100,  "Upper band (%)",          minval=10, step=10, group="Levels")
osLevel = input.float(-100, "Lower band (%)",          maxval=-10, step=10, group="Levels")
extOB   = input.float(150,  "Extreme upper band (%)",  minval=10, step=10, group="Levels")
extOS   = input.float(-150, "Extreme lower band (%)",  maxval=-10, step=10, group="Levels")

colUp   = input.color(#26a69a, "Positive color", group="Visual")
colDn   = input.color(#ef5350, "Negative color", group="Visual")
fillTransp = input.int(70, "Band fill transparency", minval=0, maxval=95, step=5, group="Visual", tooltip="Lower = more intense bands")

// ─── ASSET AVERAGE DAILY RANGE ────────────────────────────────────────────────
float avgDailyRange = asset == "Gold" ? goldRange : eurusdRange
avgDailyRange := avgDailyRange <= 0 ? syminfo.mintick : avgDailyRange

// ─── DAILY OPEN (captured on the chart itself) ────────────────────────────────
var float dayOpen = na
bool newDay = ta.change(time("D")) != 0
if newDay
    dayOpen := open
if na(dayOpen)
    dayOpen := open

// ─── OSCILLATOR ───────────────────────────────────────────────────────────────
float movedFromOpen = close - dayOpen
float osc = movedFromOpen / avgDailyRange * 100

// ─── COLOR ────────────────────────────────────────────────────────────────────
colOsc = osc >= 0 ? colUp : colDn

// ─── PLOTS ────────────────────────────────────────────────────────────────────
plot(osc, "Oscillator", color=colOsc, linewidth=2)

hline(0, "Zero", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
hOB  = hline(obLevel, "Upper band", color=color.new(colDn, 0), linestyle=hline.style_dotted)
hOS  = hline(osLevel, "Lower band", color=color.new(colUp, 0), linestyle=hline.style_dotted)
hEOB = hline(extOB, "Extreme upper", color=color.new(colDn, 30), linestyle=hline.style_dotted)
hEOS = hline(extOS, "Extreme lower", color=color.new(colUp, 30), linestyle=hline.style_dotted)

fill(hOB, hEOB, color=color.new(colDn, fillTransp))
fill(hOS, hEOS, color=color.new(colUp, fillTransp))

// ─── ALERTS ───────────────────────────────────────────────────────────────────
alertcondition(ta.crossover(osc, obLevel),  "Upper band reached", "Price has moved more than its average daily range to the upside")
alertcondition(ta.crossunder(osc, osLevel), "Lower band reached", "Price has moved more than its average daily range to the downside")
alertcondition(ta.crossover(osc, extOB),  "Extreme upper band reached", "Extreme daily move to the upside")
alertcondition(ta.crossunder(osc, extOS), "Extreme lower band reached", "Extreme daily move to the downside")
````
