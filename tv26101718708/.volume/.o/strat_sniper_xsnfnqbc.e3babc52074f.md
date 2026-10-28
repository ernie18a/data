Calculation: Inside bar = high is less than or equal to the previous bar’s high AND low is greater than or equal to the previous bar’s low
Calculation: Down bar = low is below the previous bar’s low AND high is less than or equal to the previous bar’s high
Calculation: Up bar = high is above the previous bar’s high AND low is greater than or equal to the previous bar’s low
Calculation: Long stop = low of the setup bar; long target = entry price + (entry price − long stop) × reward-to-risk multiple
Calculation: Short stop = high of the setup bar; short target = entry price − (short stop − entry price) × reward-to-risk multiple
Long: On the execution timeframe (configured timeframe, or chart timeframe if unspecified), the previous completed bar is a Down bar AND the current forming bar is an Inside bar AND its high is reached AND the session filter is disabled or the time is within the configured session
Short: On the execution timeframe (configured timeframe, or chart timeframe if unspecified), the previous completed bar is an Up bar AND the current forming bar is an Inside bar AND its low is reached AND the session filter is disabled or the time is within the configured session
Exit: long, low is less than or equal to long stop OR high is greater than or equal to long target
Exit: short, high is greater than or equal to short stop OR low is less than or equal to short target