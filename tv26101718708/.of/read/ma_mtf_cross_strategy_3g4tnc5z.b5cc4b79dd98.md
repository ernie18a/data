Calculation: SlowMA = moving average of the Heikin Ashi close, long lookback
Calculation: FastMA = moving average of the Heikin Ashi close, shorter lookback than SlowMA
Calculation: TrendMA = moving average of the Heikin Ashi close, lookback longer than SlowMA (used only when the optional trend filter is enabled)
Long: FastMA crosses above SlowMA (FastMA[prev] <= SlowMA[prev] AND FastMA > SlowMA) AND (if trend filter enabled: close > TrendMA)
Exit: long, FastMA crosses below SlowMA (FastMA[prev] >= SlowMA[prev] AND FastMA < SlowMA) OR (if trend filter enabled: close < TrendMA)