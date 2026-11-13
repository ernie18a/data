Trade BTC using a futures-vs-spot spread z-score computed on three different timeframes (short, medium, long). Evaluate everything on each bar.

1. Spread per timeframe: for each timeframe, take the close at that timeframe of six BTC series: three perpetual futures (Binance coin-margined, Binance USDT-margined, OKX USDT-margined) and three matching spot pairs (Binance USD, Binance USDT, OKX USDT). Build a weighted average futures price and a weighted average spot price. The two Binance instruments get equal, larger weights and OKX gets a smaller weight, using the same weights for futures and spot. Spread = weighted futures price minus weighted spot price.

2. Z-score per timeframe: over a fixed rolling lookback of that timeframe's spread series, compute the simple moving average and the standard deviation. Z = (current spread - mean) / stdev.

3. Entry signals (composite, all three timeframes must agree):
- Long signal: the z-scores of all three timeframes are simultaneously above a positive threshold.
- Short signal: the z-scores of all three timeframes are simultaneously below a negative threshold.
- A user setting restricts trading to long only, short only, or both. A signal in a disallowed direction is ignored.

4. Position handling:
- On an allowed long signal, close any open short and open a long.
- On an allowed short signal, close any open long and open a short.
- An opposite signal therefore exits and reverses the position.
- Each bar on which a signal is true records the current time as the entry time for that direction. A persistent signal therefore keeps refreshing the entry time and extends the hold timer.

5. Exits (optional, configurable):
- Time exit: if enabled, close a long or short once the current time is at least a set number of days past the recorded entry time for that side.
- Optional take profit and stop loss, selectable as none, TP only, SL only, or both. They are percentages from the average entry price. For a long, TP is above and SL is below entry. For a short, TP is below and SL is above entry. Both are off by default.

No other filters apply. Position size is a fixed percentage of equity.