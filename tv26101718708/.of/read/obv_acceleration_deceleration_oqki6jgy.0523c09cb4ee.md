Calculation: Master average = the mean of six simple moving averages of close, using progressively longer lookbacks
Calculation: Custom OBV = cumulative sum of volume when the master average rises from the previous bar, minus volume when it falls, and zero when unchanged
Calculation: OBV average = simple moving average of custom OBV
Calculation: Average OBV change = simple moving average of the absolute bar-to-bar change in custom OBV, using a longer lookback than the OBV average
Long: custom OBV > OBV average OR (custom OBV > previous custom OBV AND absolute bar-to-bar change in custom OBV > average OBV change × the expansion factor OR absolute bar-to-bar change in custom OBV > average OBV change × the compression factor)
Short: custom OBV <= OBV average OR (custom OBV <= previous custom OBV AND absolute bar-to-bar change in custom OBV > average OBV change × the expansion factor OR absolute bar-to-bar change in custom OBV > average OBV change × the compression factor)