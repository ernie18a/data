Goal: produce a directional macro bias (long / short / neutral) for one chosen currency from external rate and yield data. For an FX pair, combine the biases of its base and quote currencies.

Inputs, all sampled at the chart's timeframe using closing values:
1. The currency's short-maturity (2-year) government bond yield.
2. The currency's long-maturity (10-year) government bond yield.
3. A front-month short-term interest-rate futures price for that currency's money market (a futures price moves inversely to the expected policy rate).
4. An FX proxy price for the currency, such as the dollar index for USD or the pair against USD for the others.

Each input has an on/off switch. If an input is disabled or its data is unavailable or invalid, it contributes 0.

Momentum: for each input, momentum is the current value minus its value a fixed number of bars earlier. Use the same lookback for all inputs.

Per-input score, each +1, 0 or -1:
- Yields (2Y and 10Y): momentum > 0 scores +1 (bullish for the currency), momentum < 0 scores -1, zero scores 0.
- Rate future (inverted): momentum < 0 scores +1 (higher expected rates, bullish), momentum > 0 scores -1 (lower expected rates, bearish), zero scores 0.
- FX proxy: if the currency is the base or the index (USD via the dollar index, EUR, GBP, AUD, NZD against USD), momentum > 0 scores +1 and momentum < 0 scores -1. If the proxy is quoted with USD first (CHF, JPY, CAD via USDCHF, USDJPY, USDCAD), invert it: momentum < 0 scores +1 and momentum > 0 scores -1. Zero scores 0.

Total score = sum of the four per-input scores, ranging from -4 to +4.

Classification of the currency:
- Total score >= a positive threshold: bullish (long bias, currency strong).
- Total score <= a negative threshold: bearish (short bias, currency weak).
- Otherwise: neutral (mixed signals, no bias, stay flat or exit).
The thresholds are user-adjustable and set at a moderate magnitude, requiring agreement from more than one input. The bullish and bearish zones are symmetric by default.

Using it on a pair: go long the pair when the base currency is bullish and the quote currency is bearish. Go short when the base is bearish and the quote is bullish. If both are bullish, both bearish, or either is neutral, the relative edge is unclear, so take no directional bias. This is a bias filter, not an entry trigger. Re-evaluate every bar, so the bias changes whenever the total score crosses a threshold.