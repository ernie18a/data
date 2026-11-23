Calculation: Source = close of chart bars, or if MTF enabled, close of T1 bars (last completed bar)
Calculation: FlatLength = the L from lookback minimum to lookback maximum by lookback step that minimizes ABS(PearsonCorrelation(last L values of Source, sequence number))
Calculation: FlatR = ABS(PearsonCorrelation(last FlatLength values of Source, sequence number))
Calculation: RangeUpper = LinearRegressionChannelUpper(last FlatLength values of Source, deviation multiplier), updated only on bars where FlatR <= threshold
Calculation: RangeLower = LinearRegressionChannelLower(last FlatLength values of Source, deviation multiplier), updated only on bars where FlatR <= threshold
Long: MIN(open, close) > RangeUpper
Short: MAX(open, close) < RangeLower