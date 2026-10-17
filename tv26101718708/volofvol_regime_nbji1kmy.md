# Vol-of-Vol Regime

- url: https://www.tradingview.com/script/nbjI1KmY/
- type: indicator
- pine_id: PUB;27eb4f3d8d024d518d4a6391e95181e1
- version: 1.0

## Description

Tracks how stable realized volatility itself is. It computes a short rolling realized volatility, then the standard deviation of that volatility over a longer window (the vol-of-vol), and ranks both into Low / Normal / High / Extreme percentile buckets. Useful for spotting periods where the volatility regime itself is unstable. It does NOT generate buy or sell signals.

What it shows
- Vol-of-vol value and its percentile rank, with a regime label
- The underlying short realized volatility and its percentile

Honest by design
- No buy/sell signals. This is a regime-measurement panel.
- Non-repainting: rolling standard deviations on confirmed bars.

Open-source and MIT licensed.

Disclaimer: impersonal educational and analytics tool. This is not investment advice, not a personalised recommendation, and carries no performance guarantee. Past results do not predict future results. You are solely responsible for your own trading decisions.

## Source Code

````pine
//@version=6
// Volatility-of-Volatility Regime
// Track how stable the realized volatility itself is. Computes a
// short rolling RV, then the stdev of that RV over a longer window
// (the vol-of-vol), and ranks both into Low / Normal / High / Extreme
// percentile buckets. Useful for spotting periods where the very
// regime is unstable. Analytics panel. No signals, non-repainting.
indicator("Vol-of-Vol Regime", overlay = false)
// Disclaimer: impersonal educational/analytics tool, not investment advice, no
// performance guarantees, no buy/sell signals, no auto-execution.

rvLen     = input.int(20, "RV window", minval = 2, group = "Windows")
volOfVol  = input.int(60, "Vol-of-vol window", minval = 5, group = "Windows")
rankLen   = input.int(252, "Percentile lookback",
     minval = 30, group = "Regime")
warnPct   = input.float(75.0, "High threshold", minval = 50.0,
     maxval = 95.0, step = 1.0, group = "Regime")
extPct    = input.float(90.0, "Extreme threshold", minval = 70.0,
     maxval = 99.0, step = 1.0, group = "Regime")

logRet = math.log(close / close[1])
rv = ta.stdev(logRet, rvLen)
vov = ta.stdev(rv, volOfVol)

rvRank  = ta.percentrank(rv,  rankLen)
vovRank = ta.percentrank(vov, rankLen)

vovRegime = vovRank >= extPct ? "Extreme" : vovRank >= warnPct ? "High" :
     vovRank >= (100.0 - warnPct) ? "Normal" : "Low"
vovColor = vovRank >= extPct ? color.red : vovRank >= warnPct ? color.orange :
     vovRank >= (100.0 - warnPct) ? color.green : color.gray

plot(vov, title = "Vol-of-Vol",
     color = color.new(vovColor, 0), linewidth = 2)
plot(rv,  title = "RV (short)",
     color = color.new(color.gray, 50))

var table t = table.new(position.top_right, 2, 5, border_width = 1)
if barstate.islast
    table.cell(t, 0, 0, "Vol-of-Vol Regime",
         text_color = color.white, bgcolor = color.new(color.black, 0))
    table.cell(t, 1, 0, "", bgcolor = color.new(color.black, 0))
    table.cell(t, 0, 1, "VoV value")
    table.cell(t, 1, 1, str.tostring(vov, "#.######"))
    table.cell(t, 0, 2, "VoV percentile")
    table.cell(t, 1, 2, str.tostring(vovRank, "#.#") + "%")
    table.cell(t, 0, 3, "VoV regime")
    table.cell(t, 1, 3, vovRegime, text_color = color.white,
         bgcolor = color.new(vovColor, 30))
    table.cell(t, 0, 4, "RV percentile")
    table.cell(t, 1, 4, str.tostring(rvRank, "#.#") + "%")
````
