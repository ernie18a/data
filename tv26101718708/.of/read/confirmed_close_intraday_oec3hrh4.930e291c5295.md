Calculation: Asia range = highest high and lowest low of chart bars in the most recent Asia session; reset when the next Asia session starts and retain the completed range until then.
Calculation: New York opening range = highest high and lowest low of completed lower-timeframe bars during the configured opening interval of the New York session; use chart bars if the chart timeframe is no greater than the configured lower timeframe. Reset at the next New York opening interval.
Long: Close > completed Asia range high.
Short: Close < completed Asia range low.
Long: During the London OR New York session AND outside the Asia session AND close > completed Asia range high AND no previous upside break since the Asia session started.
Short: During the London OR New York session AND outside the Asia session AND close < completed Asia range low AND no previous downside break since the Asia session started.
Short: During the London OR New York session AND outside the Asia session AND high > completed Asia range high AND close < completed Asia range high AND no previous high sweep since the Asia session started.
Long: During the London OR New York session AND outside the Asia session AND low < completed Asia range low AND close > completed Asia range low AND no previous low sweep since the Asia session started.
Long: Close > completed New York opening range high.
Short: Close < completed New York opening range low.
Long: After the New York opening range is complete AND before the configured deadline after the session open AND a completed lower-timeframe bar closes above the range high AND its preceding lower-timeframe close <= the range high AND no previous opening-range break in either direction since the range began; evaluate at the chart bar close. Use chart bars if the chart timeframe is no greater than the configured lower timeframe.
Short: After the New York opening range is complete AND before the configured deadline after the session open AND a completed lower-timeframe bar closes below the range low AND its preceding lower-timeframe close >= the range low AND no previous opening-range break in either direction since the range began; evaluate at the chart bar close. Use chart bars if the chart timeframe is no greater than the configured lower timeframe.
Long: Supertrend direction is up on the last completed shorter higher-timeframe bar.
Short: Supertrend direction is down on the last completed shorter higher-timeframe bar.
Long: Supertrend direction is up on the last completed longer higher-timeframe bar.
Short: Supertrend direction is down on the last completed longer higher-timeframe bar.
Long: Close > anchored VWAP.
Short: Close <= anchored VWAP.
Long: Close > the open of the still-forming higher-timeframe daily bar.
Short: Close <= the open of the still-forming higher-timeframe daily bar.
Long: Chart bar opens within a configured historically strong UTC hour window.
Short: Chart bar opens within a configured historically weak UTC hour window AND outside the configured historically strong UTC hour windows.