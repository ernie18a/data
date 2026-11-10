Calculation: Trading-day average return = for each chart-bar ordinal since the first bar in January, average (close - open) / open across all available years, including the current year; ignore ordinals beyond the assumed trading-year length.
Calculation: Seasonal return = the trading-day average return for the current ordinal, or the sum of consecutive trading-day average returns in the selected longer period's block; the longer period may be a month or a quarter, with a quarter containing more chart bars than a month. Select the block using the current calendar period.
Calculation: Current return = (close - open) / open for the chart bar or the selected higher-timeframe bar still forming; on historical bars use that higher-timeframe bar's final close, as the source uses lookahead.
Calculation: Seasonal projection = start at 1 and, for each successive trading-day ordinal, record the current value and then multiply it by 1 plus that ordinal's trading-day average return. Recalculate using all data available at the evaluation bar.
Calculation: Seasonal low = a seasonal projection value less than or equal to every value within the pivot-strength number of ordinals on both sides, except the neighbor whose offset equals the candidate's zero-based ordinal. Seasonal high = the corresponding value greater than or equal to those neighbors. Evaluate only candidates with the full window available; map each candidate ordinal to the corresponding chart bar from the first bar in January.
Long: Seasonal return > 0
Short: Seasonal return <= 0
Long: Current return > 0
Short: Current return <= 0
Long: Seasonal projection at the mapped chart bar is a seasonal low
Short: Seasonal projection at the mapped chart bar is a seasonal high