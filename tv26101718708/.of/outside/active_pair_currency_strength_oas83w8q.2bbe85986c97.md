Applies only to a forex chart pair. Trade the chart pair using relative currency strength computed from seven USD-based pairs, none of which need to be the traded instrument.

1. Data: on a chosen calculation timeframe (the chart timeframe by default, or a fixed daily/weekly one), fetch closes for EURUSD, GBPUSD, AUDUSD, NZDUSD, USDCAD, USDCHF and USDJPY. Use the same broker prefix as the chart, or alternatively CME currency futures.

2. Raw return per currency, in percent, against an anchor price taken on the calculation timeframe. The anchor is either the close N bars back (rolling mode) or the current week's open (weekly mode).
- For EUR, GBP, AUD and NZD, which are quoted as X/USD: (close - anchor) / anchor * 100.
- For CAD, CHF and JPY, which are quoted as USD/X, invert the move: (anchor / close - 1) * 100.
- USD's raw return is 0.
- Any division by zero or missing denominator gives 0.
- With CME futures, every currency uses (close - anchor) / anchor * 100 and nothing is inverted.

3. Normalise: average the eight raw returns (seven currencies plus USD at 0). Each currency's strength is its raw return minus that average. USD therefore moves too.

4. Select: take the strength of the chart pair's base currency and of its quote currency.

5. Optional smoothing: apply an EMA to each of the two series, updated once per calculation-timeframe period rather than once per chart bar. When a new period starts, update the EMA memory with the previous period's value. The smoothed output is alpha * current + (1 - alpha) * memory, with alpha = 2 / (length + 1). The first value seeds the memory.

6. Signals, evaluated only on confirmed (closed) bars:
- LONG the chart pair (bullish base momentum) when the base strength line crosses above the quote strength line.
- SHORT the chart pair (bearish base momentum) when the base strength line crosses below the quote strength line.
- The opposite cross exits the existing position and reverses it. There is no other exit rule.

7. Caution only, not directional: when the absolute gap between the base and quote strength first rises to or above a threshold, the pair is flagged as overextended. This is a warning for a possible retracement, not a long, short or exit trigger.