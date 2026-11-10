Calculation: Bollinger basis = SMA or EMA of a selected price source over the Bollinger lookback.
Calculation: Oscillator = short-lookback SMA of (high + low) / 2 minus long-lookback SMA of (high + low) / 2.
Calculation: Buy signal = fast EMA of the selected price source crosses above the Bollinger basis AND close > Bollinger basis AND oscillator > previous oscillator AND the previous signal state is not buy. After a buy signal, set the signal state to buy; after a sell signal, set it to sell. Initially the signal state is neither.
Calculation: Sell signal = fast EMA of the selected price source crosses below the Bollinger basis AND close < Bollinger basis AND oscillator <= previous oscillator AND the previous signal state is not sell.
Calculation: Entry period = (start date filter disabled OR datetime > start date) AND (end date filter disabled OR datetime < end date).
Long: fast EMA of the selected price source > Bollinger basis.
Short: fast EMA of the selected price source < Bollinger basis.
Long: buy signal.
Short: sell signal.
Long: buy signal AND SuperTrend indicates uptrend AND (ADX filter disabled OR ADX > threshold) AND entry period AND long trading enabled AND position side is not long.
Short: sell signal AND SuperTrend indicates downtrend AND (ADX filter disabled OR ADX > threshold) AND entry period AND short trading enabled AND position side is not short.
Exit: long, entry period AND close < entry price * (1 - stop-loss percentage).
Exit: short, entry period AND close > entry price * (1 + stop-loss percentage).
Exit: long, entry period AND high >= entry price * (1 + take-profit percentage), for each of four independently configured targets; the first three close their configured position percentages and the fourth closes the remainder.
Exit: short, entry period AND low <= entry price * (1 - take-profit percentage), for each of four independently configured targets; the first three close their configured position percentages and the fourth closes the remainder.
Exit: long, sell signal AND SuperTrend indicates downtrend AND (ADX filter disabled OR ADX > threshold) AND entry period AND short trading enabled.
Exit: short, buy signal AND SuperTrend indicates uptrend AND (ADX filter disabled OR ADX > threshold) AND entry period AND long trading enabled.