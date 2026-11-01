Calculation: Session high and low = highest chart-bar high and lowest chart-bar low accumulated during the session in the current cycle, including the current bar when it is in that session; reset at the next Asia session opening. London levels combine London Pre-Open and London. Sessions use configurable clock windows and timezones, with an optional weekday filter based on the session start date.
Calculation: Eligible reference low or high = Asia session low or high during London Pre-Open, London, or New York; OR London session low or high during New York Pre-Open or New York.
Calculation: Reference volume = simple moving average of volume over a lookback ending on the preceding bar.
Calculation: Volume-range product = volume multiplied by high minus low.
Long: close >= open.
Short: close < open.
Long: volume >= reference volume multiplied by the climax multiplier OR volume-range product >= highest volume-range product over the reference-volume lookback ending on the preceding bar; AND close >= open.
Short: volume >= reference volume multiplied by the climax multiplier OR volume-range product >= highest volume-range product over the reference-volume lookback ending on the preceding bar; AND close < open.
Long: volume < reference volume multiplied by the climax multiplier AND volume-range product < highest volume-range product over the reference-volume lookback ending on the preceding bar AND volume >= reference volume multiplied by the rising-volume multiplier AND close >= open.
Short: volume < reference volume multiplied by the climax multiplier AND volume-range product < highest volume-range product over the reference-volume lookback ending on the preceding bar AND volume >= reference volume multiplied by the rising-volume multiplier AND close < open.
Long: eligible reference low exists AND close > eligible reference low AND (low < eligible reference low OR previous low < eligible reference low AND previous close < eligible reference low).
Short: eligible reference high exists AND close < eligible reference high AND (high > eligible reference high OR previous high > eligible reference high AND previous close > eligible reference high).