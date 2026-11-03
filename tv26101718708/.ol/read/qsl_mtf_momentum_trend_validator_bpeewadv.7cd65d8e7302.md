Calculation: Moving averages = four moving averages of close, ordered from shortest to longest lookback.
Calculation: Candle return (%) = 100 × (close − open) / open on the configured momentum timeframe, using its last completed bar; that timeframe may be higher or lower than the chart timeframe.
Calculation: Candle turnover = volume × close when volume is base-asset volume, otherwise volume.
Calculation: Relative turnover (%) = 100 × (candle turnover ÷ average turnover per bar over the preceding 24 hours − 1), calculated on the configured momentum timeframe using completed bars.
Long: Chart-timeframe moving averages are strictly ordered shortest > next-shortest > next-longest > longest.
Long: On every enabled dashboard timeframe, the last completed bar has moving averages strictly ordered shortest > next-shortest > next-longest > longest.
Long: A completed momentum-timeframe candle has return ≥ the configured positive threshold AND candle turnover ≥ its configured minimum (or the minimum is zero) AND relative turnover ≥ its configured minimum (or the minimum is zero).
Short: Chart-timeframe moving averages are strictly ordered shortest < next-shortest < next-longest < longest.
Short: On every enabled dashboard timeframe, the last completed bar has moving averages strictly ordered shortest < next-shortest < next-longest < longest.
Short: A completed momentum-timeframe candle has return ≤ the negative configured threshold AND candle turnover ≥ its configured minimum (or the minimum is zero) AND relative turnover ≥ its configured minimum (or the minimum is zero).
Exit: 