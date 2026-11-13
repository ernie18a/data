Calculation: Gap% = (open of the current higher-timeframe bar (the bar still forming, evaluated when it opens) - close of the previous completed higher-timeframe bar) / that previous close * 100. The higher timeframe is a daily-scale timeframe above the chart timeframe.
Calculation: Weekend gap = the time between the start of the current higher-timeframe bar and the start of the previous one is longer than the normal consecutive-bar spacing (weekend or holiday closure).
Calculation: Gap range = top and bottom are the larger and smaller of the signal bar's higher-timeframe open and the previous completed higher-timeframe close. The range is fixed at signal time.
Long: Weekend gap AND Gap% > 0 AND |Gap%| >= minimum gap size AND higher-timeframe open != previous higher-timeframe close
Short: Weekend gap AND Gap% < 0 AND |Gap%| >= minimum gap size AND higher-timeframe open != previous higher-timeframe close
Exit: long, chart low <= bottom of the Gap range
Exit: short, chart high >= top of the Gap range