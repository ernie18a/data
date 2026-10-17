# Odds-Implied Price

- url: https://www.tradingview.com/script/USmDR7Nq-Odds-Implied-Price/
- type: indicator
- pine_id: PUB;1b0631db7653410daca8657cc0fc0b72
- version: 1.0

## Description

Odds-Implied Price

OVERVIEW
Odds-Implied Price turns a probability ("will this candle close above its open?") into a price level plotted directly on the chart. The line shows where price would need to be for that probability to be fair, measured from the candle's open. It works on any symbol and any timeframe.

THEORY
In binary-option pricing, the probability that price finishes above a strike K is:

    P(up) = Φ( (S − K) / σ )

where S is the current price, σ is volatility, and Φ is the normal CDF. Inverting this gives:

    S = K + σ · Φ⁻¹(P)

So any probability can be read as a distance from the strike, measured in standard deviations of volatility. The indicator applies this with the candle open as the strike and ATR as the volatility unit.

HOW IT WORKS
1. Probability input
   • External mode: feed an odds series (for example prediction-market or binary "UP" odds) through "Odds source". Values in 0–1 or 0–100 are detected automatically.
   • Built-in mode (default): a probability is derived from price itself, as 0.5 + 0.5·tanh((close − SMA20) / ATR20). Price stretched above its average reads as a high UP probability; stretched below reads as a low one.
2. Smoothing: an optional SMA over the probability, useful for steppy odds data.
3. Probit transform: the inverse normal CDF (Acklam approximation) converts the probability into a z-score. 50% = 0σ, ~84% = +1σ, ~16% = −1σ. Probabilities are clamped to 0.01%–99.99%.
4. Price conversion: z × k × ATR(20) / 50 gives a distance in price units, which adapts automatically to the timeframe and the asset's volatility.
5. Anchor: the distance is added to the candle open ("price to beat").

PLOTS
- Odds-Implied Price – teal when above the open (UP favored), red when below (DOWN favored).
- Open – stepped gray reference line.
- Odds-price rate – bar-to-bar change of the implied line (hidden by default; enable it and move it to a separate pane if wanted).
- Table – implied probability, ABOVE/BELOW the open, and distance from the open in %.
- Alert – fires when the implied price crosses the open, meaning the favored side has flipped.

HOW TO USE
- Compare the implied line with actual price. If the line sits above price, the probability is more bullish than the current price justifies; below means more bearish.
- A cross of the open line means the probability has crossed 50%.
- A fast-moving rate with little price movement means the probability is repricing faster than price.
- With external odds, tune "Price scale k" until the line tracks price on average. The gap that remains is the signal.

SETTINGS
- Price scale k – ATR multiple per 1σ of probability (default 10 = 0.2 ATR per σ).
- Smooth odds – SMA length on the probability.
- Use an odds source / Odds source – enables external odds input.
P.S It can work on any TF or assets I made for BINARY option of Low TF but it can be for any
NOTES
In built-in mode the probability comes from price itself, so the line shows trend and stretch relative to the open rather than independent market information. External odds input is what adds outside information.

This script is for analysis and education only and is not financial advice.

## Source Code

````pine
//@version=6
indicator('Odds-Implied Price', overlay = true)



kScale = input.float(10, 'Price scale k (displacement per 1σ of prob)', minval = 1.0)
smoothN = input.int(1, 'Smooth odds (SMA) — odds are discrete/steppy', minval = 1)
useSrc = input.bool(false, 'Use an odds source series on the chart')
oddsSrc = input.source(close, 'Odds source (0-1 or 0-100)')

// probit (inverse normal CDF) — Acklam approximation
probit(p) =>
    pp = math.min(math.max(p, 0.0001), 0.9999)
    a1 = -39.6968302866538
    a2 = 220.946098424521
    a3 = -275.928510446969
    a4 = 138.357751867269
    a5 = -30.6647980661472
    a6 = 2.50662827745924
    b1 = -54.4760987982241
    b2 = 161.585836858041
    b3 = -155.698979859887
    b4 = 66.8013118877197
    b5 = -13.2806815528857
    c1 = -0.00778489400243029
    c2 = -0.322396458041136
    c3 = -2.40075827716184
    c4 = -2.54973253934373
    c5 = 4.37466414146497
    c6 = 2.93816398269878
    d1 = 0.00778469570904146
    d2 = 0.32246712907004
    d3 = 2.445134137143
    d4 = 3.75440866190742
    plow = 0.02425
    phigh = 1 - 0.02425
    float z = na
    if pp < plow
        q = math.sqrt(-2 * math.log(pp))
        z := (((((c1 * q + c2) * q + c3) * q + c4) * q + c5) * q + c6) / ((((d1 * q + d2) * q + d3) * q + d4) * q + 1)
        z
    else if pp <= phigh
        q = pp - 0.5
        r = q * q
        z := (((((a1 * r + a2) * r + a3) * r + a4) * r + a5) * r + a6) * q / (((((b1 * r + b2) * r + b3) * r + b4) * r + b5) * r + 1)
        z
    else
        q = math.sqrt(-2 * math.log(1 - pp))
        z := -(((((c1 * q + c2) * q + c3) * q + c4) * q + c5) * q + c6) / ((((d1 * q + d2) * q + d3) * q + d4) * q + 1)
        z
    z

// Get the probability in 0-1. In live use, feed real UP odds via oddsSrc.
// For demonstration without an odds source, synthesize a probability from
// where price sits inside a recent range (so you can see the transform).
rawOdds = useSrc ? oddsSrc > 1.5 ? oddsSrc / 100.0 : oddsSrc : na
// Pine v5 has no math.tanh — define it via exp: tanh(x) = (e^2x-1)/(e^2x+1).
// Clamp the argument so exp() can't overflow on large inputs.
tanh(x) =>
    xc = math.max(math.min(x, 20.0), -20.0)
    e2 = math.exp(2.0 * xc)
    (e2 - 1.0) / (e2 + 1.0)

demoProb = na(rawOdds) ? 0.5 + 0.5 * tanh((close - ta.sma(close, 20)) / (ta.atr(20) + 1e-9)) : rawOdds
prob = ta.sma(demoProb, smoothN)

// candle open = the "price to beat"; here use the 5m open as the anchor line.
openRef = request.security(syminfo.tickerid, '5', open, lookahead = barmerge.lookahead_on)

// For a clean OVERLAY on the price chart, express the odds displacement in real
// price units: scale by ATR so probit(prob) maps to a sensible number of price
// points. kScale is now "ATR multiples per 1σ of implied probability".
atrUnit = ta.atr(20)
synthetic = openRef + kScale * atrUnit * probit(prob) / 50.0

// ── derived signals ON the odds-price ──
rate = synthetic - synthetic[1] // odds-price velocity
firstMovePct = (synthetic - openRef) / openRef * 100

col = synthetic >= openRef ? color.teal : color.red
plot(synthetic, 'Odds-implied price', color = col, linewidth = 2)
plot(openRef, 'Open (price to beat)', color = color.new(color.gray, 40), style = plot.style_stepline)

// rate is kept as a plot you can add to a separate pane via "Move to" if wanted,
// but hidden by default so it doesn't distort the price overlay scale.
plot(rate, 'Odds-price rate', color = color.new(color.orange, 0), display = display.none)

// ── readout ──
var table t = table.new(position.top_right, 2, 4, border_width = 1)
if barstate.islast
    table.cell(t, 0, 0, 'Odds-price', bgcolor = color.new(color.gray, 70), text_color = color.white, text_size = size.small)
    table.cell(t, 1, 0, 'Value', bgcolor = color.new(color.gray, 70), text_color = color.white, text_size = size.small)
    table.cell(t, 0, 1, 'Implied prob', text_size = size.small)
    table.cell(t, 1, 1, str.tostring(prob * 100, '#.#') + '%', text_size = size.small)
    table.cell(t, 0, 2, 'vs open', text_size = size.small)
    table.cell(t, 1, 2, synthetic >= openRef ? 'ABOVE' : 'BELOW', text_size = size.small, text_color = col)
    table.cell(t, 0, 3, 'move %', text_size = size.small)
    table.cell(t, 1, 3, str.tostring(firstMovePct, '#.###') + '%', text_size = size.small, text_color = col)

alertcondition(ta.cross(synthetic, openRef), 'Odds-price crossed open', 'Odds-implied price crossed the open line')
````
