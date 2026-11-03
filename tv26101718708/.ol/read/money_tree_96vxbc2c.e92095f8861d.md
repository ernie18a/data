Calculation: Open and close series = the selected moving-average type and lookback applied to open and close, respectively, with the configured bar delay; sampled from a higher timeframe using its last completed bar
Calculation: Chop Zone = color classification of the EMA slope angle normalized by the recent high-low range; choppy status is true when its color is configured as choppy
Long: close series crosses above open series AND choppy status is false
Short: close series crosses below open series AND choppy status is true
Exit: long, close series crosses below open series when long-only mode is selected OR high reaches entry price plus the configured profit target OR low reaches entry price minus the configured stop loss
Exit: short, close series crosses above open series when short-only mode is selected OR low reaches entry price minus the configured profit target OR high reaches entry price plus the configured stop loss