Calculation: volume clock = source-weighted average of the newest chart bars totaling window × SMA(volume, normal-volume lookback)[1], using only the volume still needed from the oldest bar; if that target is not reached within window × cap-multiplier chart bars, use VWMA(source, window × cap-multiplier chart bars)
Long: close crosses above volume clock
Short: close crosses below volume clock