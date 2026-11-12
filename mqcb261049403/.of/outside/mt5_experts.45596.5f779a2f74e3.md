Three independent strategies. All trade only market orders, with at most one position per instrument unless noted.

1) Oscillator-band reversal, driven by a signal instrument and timeframe. The signal instrument/timeframe may differ from the traded instrument.
- Build an OsMA series (MACD histogram, fast < slow, with a signal-line period) on the signal instrument and timeframe.
- Compute two indicators on the OsMA series itself, not on price: a Bollinger band (upper and lower, with its own period and deviation) and a simple moving average.
- Act only once per new bar of the signal instrument. Use the last two closed bars: 'older' is two bars back and 'newer' is one bar back. If any indicator data is unavailable, the signal is 0.
- Keep a persistent state, direction, in {+1, 0, -1}. On each evaluation:
  a) If direction is +1 and OsMA crosses down through its moving average (older >= MA older and newer < MA newer), set direction to 0. If direction is -1 and OsMA crosses up through its moving average (older <= MA older and newer > MA newer), set direction to 0.
  b) Then check for a new entry, which overrides (a). If older OsMA <= older lower band and newer OsMA > newer lower band, set direction to +1. Otherwise, if older OsMA >= older upper band and newer OsMA < newer upper band, set direction to -1.
  c) The signal is the resulting direction.
- Position handling:
  - If a long is open and the signal is not +1, close it.
  - If a short is open and the signal is not -1, close it.
  - If, after that, no position is open and the signal is +1, buy.
  - If, after that, no position is open and the signal is -1, sell.
  - A reversal therefore closes and re-opens on the same evaluation.
- Variant: the signal is computed on the chart's (possibly synthetic) instrument while orders are sent to a different named work instrument. The logic is otherwise identical.

2) Economic-calendar news trading on the chart instrument (currency pair).
- Periodically (about once per second) fetch newly changed calendar records within a window of roughly one day before to one day after the current server time.
- Keep only records that meet all of these:
  - the event's currency is the pair's base or quote currency
  - the event type is an economic indicator
  - importance is high
  - a forecast value exists
  - optionally, a text match on the event name
  - or, if a specific event id is configured, only that event
- Score each qualifying record by its impact classification: positive = +1, negative = -1, none/unknown = 0. Flip the sign when the record's currency is the quote (profit) currency. Sum the scores over all records in the batch.
- If the sum is 0, do nothing.
- If the number of open positions on the instrument has reached the allowed maximum (1 on netting accounts, a configured multiple on hedging accounts), close the instrument's position first.
- Then buy if the sum is > 0 and sell if it is < 0.

3) Trade copier (subscriber side).
- A subscriber receives trade messages from a publisher over a network channel. Each message holds the request (market-deal action, order type buy or sell, volume, symbol) and the resulting deal's entry type (in or out).
- Ignore messages whose symbol has no entry in a configured symbol-substitution map. Otherwise translate the symbol to the mapped local one.
- Entry-in with a buy or sell type: open a market position of the same direction and volume on the mapped symbol.
- Entry-out: find a local position on the mapped symbol, with the subscriber's own magic number, whose direction is opposite to the message's order type and whose volume equals the message volume, and close it. If none exists, do nothing.
- Other actions are ignored.