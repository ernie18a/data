Signals to go long or short EURUSD and GBPUSD, driven by the direction of the current candle on a basket of currency pairs. The candle is the one at a configurable look-back offset, normally the current one. Candle direction is bullish if close > open, bearish if close < open, and neutral if equal (neutral adds nothing).

Build three currency-strength tallies, each a signed vote count. A bullish candle on a pair adds +1 to the currency that is the base of the pair. A bearish candle subtracts 1. For the quote currency the vote is inverted.
- EUR tally: sum of the candle directions of EURUSD, EURJPY, EURGBP, EURCHF, EURAUD, EURCAD (EUR is the base in all six).
- GBP tally: EURGBP counted inverted (bearish EURGBP = +1), plus GBPUSD, GBPJPY, GBPCHF, GBPAUD, GBPCAD as normal.
- USD tally: EURUSD inverted, GBPUSD inverted, AUDUSD inverted, plus USDJPY, USDCHF, USDCAD as normal.
Each tally is therefore in the range -6..+6. +6 means the currency is bullish against all six counterparts, and -6 means it is bearish against all six.

The tallies are persistent counters that are incremented or decremented on every evaluation and are never reset between evaluations. The original therefore compares the accumulated value, not a fresh per-bar value. To match it exactly, keep them as running totals across calls. For the intended per-bar behaviour, recompute them from zero each time.

Decisions, using exact equality on the tallies:
- BUY EURUSD when the EUR tally is at its maximum (+6, all agree bullish) and the USD tally is at its minimum (-6, all bearish).
- SELL EURUSD when the EUR tally is at its minimum (-6) and the USD tally is at its maximum (+6).
- BUY GBPUSD when the GBP tally is at its maximum (+6) and the USD tally is at its minimum (-6).
- SELL GBPUSD when the GBP tally is at its minimum (-6) and the USD tally is at its maximum (+6).

Each of the four signals fires at most once per bar. It is suppressed until the bar count on the chart increases. There is no exit logic, stop, or position management. The output is only an entry alert at the current price (bid for buys, ask for sells).