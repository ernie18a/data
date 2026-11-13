Long-only entry framework. No short or exit rules are defined. The only action is to go long on the traded instrument. It uses a broad-market benchmark index ETF (e.g. SPY) as outside data for relative strength.

Indicators, all on the traded instrument's closes unless stated:
- Three simple moving averages of close: short, medium and long.
- RSI of close, with two thresholds: a midline level and a higher 'strong' level.
- Stochastic RSI: the raw value is (RSI - lowest RSI over a window) / (highest RSI - lowest RSI), scaled to 0-100, and 0 if the range is zero. K is a short SMA of the raw value. D is a short SMA of K.
- Relative strength momentum: take the ratio of the instrument's close to the benchmark's close on the same timeframe, with no lookahead. RS momentum is the percent change of that ratio over a lookback. It is undefined until enough history exists. It has two thresholds: zero and a modestly positive 'strong' level.
- Volume is 'elevated' when current volume exceeds a multiple (somewhat above 1x) of its simple moving average.

Score: sum of 11 binary points, each worth 1 when true:
1. close > short MA
2. close > medium MA
3. close > long MA
4. short MA > medium MA
5. medium MA > long MA
6. RSI > midline
7. RSI > strong level
8. RS momentum > 0
9. RS momentum > strong level
10. K > D
11. volume elevated

Signal tiers:
- STRONG BUY: the score is at or near the maximum (high threshold), AND full bullish alignment (close > short MA > medium MA > long MA), AND RS momentum > 0, AND RSI > midline.
- BUY: the score is at or above a lower, moderately high threshold, AND close is above both the short and medium MAs, AND RS momentum > 0.
- STRONG BUY takes precedence over BUY. A bar can satisfy both conditions, but STRONG BUY is the stronger tier.

Entry trigger: enter long on a bar when the STRONG BUY condition is true and was false on the previous bar. Likewise, enter long when the BUY condition is true and was false on the previous bar (a fresh transition only, not on every bar the condition persists). Evaluate on bar close.

Lower scores or bearish structure (close below both the short and medium MAs) are only 'watch' or 'avoid' labels. They produce no trade action and no exit.