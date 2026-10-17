# RHODL Z-Score [TheSnake3Run]

- url: https://www.tradingview.com/script/Nj0sSuJx-RHODL-Z-Score-TheSnake3Run/
- type: indicator
- pine_id: PUB;61f5852ad16a4bcb8513dfb478b96ea9
- version: 1.0

## Description

The original RHODL Ratio, created by Philip Swift, is an on-chain metric that compares the cost basis of coins last moved in the past week against the cost basis of coins last moved 1–2 years ago, weighted by total market age. It identifies macro cycle tops and bottoms in Bitcoin. The true metric requires UTXO-level realized-cap data not available inside Pine Script, so this indicator approximates the dynamic using price alone and standardises the output as a z-score.

How the calculation works

1. Short cohort — 7-bar SMA of price (≈ 1 week on daily). Proxy for recently-transacted cost basis.
2. Long cohort — SMA of price from 365 to 730 bars ago (≈ 1–2 years back). Proxy for long-term holder cost basis.
3. Ratio — short ÷ long. Above 1 means recent price is elevated versus long-term basis.
4. Age weighting — ratio × bar index, mirroring RHODL's market-age adjustment, then log-transformed.
5. Z-score — the log value is normalised against its own 365-bar rolling mean and standard deviation. The plot shows how many standard deviations the current reading sits from its one-year average.

How to read it

Above +2 — stretched high; overheated. Shaded red.
−1 to +1 — normal range.
Below −2 — stretched low; accumulation. Shaded green.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TheSnake3Run

//@version=6
indicator("RHODL Z-Score [TheSnake3Run]", shorttitle="RHODL Z", overlay=false, precision=2)

// ============================================================
// WHAT THIS DOES
// True RHODL needs on-chain data Pine can't access, so we proxy
// it with price:
//   short cohort  = average price over last week
//   long  cohort  = average price from 1–2 years ago
//   ratio         = short / long  (age-weighted, then logged)
// Then we plot a rolling Z-SCORE of that ratio, so the scale is
// universal: +2 = stretched high (overheated),
//            -2 = stretched low  (accumulation),
//             0 = average.
// Use on BTCUSD, 1D timeframe.
// ============================================================

// --- Inputs ---
shortLen = input.int(7,   "Short cohort (bars)")            // 1 week on daily
longLen  = input.int(365, "Long cohort length (bars)")      // 1-year span
longLag  = input.int(365, "Long cohort starts N bars ago")  // starts 1yr back → covers prices that are 1–2yrs old
zLen     = input.int(365, "Z-score lookback (bars)")        // normalize against last ~1yr

// --- the two cohort averages ---
shortMA = ta.sma(close, shortLen)             // avg of the last `shortLen` closes
longMA  = ta.sma(close[longLag], longLen)     // avg of closes from longLag..(longLag+longLen) bars ago

// --- Raw ratio, age-weighted, log-scaled ---
ratio    = shortMA / longMA                   // >1 = recent price above long-term cost basis
weighted = ratio * (bar_index + 1)            // RHODL weights by market age; we use bar_index as a proxy
logVal   = math.log(weighted)                 // log keeps the series well-behaved over long histories

// --- Rolling Z-score ---
// Z = (current value − rolling mean) / rolling stdev
mean  = ta.sma(logVal, zLen)
stdev = ta.stdev(logVal, zLen)
z     = (logVal - mean) / stdev

// --- Plot ---
plot(z, "Z-Score", color=color.orange, linewidth=2)

// Reference bands at ±1 and ±2 standard deviations
hline(2,  "Overheated (+2)",   color=color.red,   linestyle=hline.style_dashed)
hline(1,  "Warning (+1)",      color=color.new(color.red, 60))
hline(0,  "Mean",              color=color.gray)
hline(-1, "Opportunity (-1)",  color=color.new(color.green, 60))
hline(-2, "Accumulation (-2)", color=color.green, linestyle=hline.style_dashed)

// Shade the chart when we're in the extreme zones
bgcolor(z >  2 ? color.new(color.red,   85) : na, title="Overheated zone")
bgcolor(z < -2 ? color.new(color.green, 85) : na, title="Accumulation zone")
````
