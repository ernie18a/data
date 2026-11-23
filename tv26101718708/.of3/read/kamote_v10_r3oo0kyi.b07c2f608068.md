Calculation: ATR percentile = PERCENTRANK(ATR(ATR length), ATR window) on T1 bars, last completed bar
Calculation: ATR hysteresis = MIN(ATR hysteresis band, (ATR high percentile - ATR low percentile) / 2)
Calculation: ATR extreme = IF ATR extreme[1] THEN ATR percentile >= ATR high percentile - ATR hysteresis ELSE ATR percentile > ATR high percentile + ATR hysteresis
Calculation: Bullish slope = LINREG_SLOPE(close, slope lookback, T1, last completed bar) > slope factor * ATR(ATR length, T1, last completed bar)
Calculation: Bearish slope = LINREG_SLOPE(close, slope lookback, T1, last completed bar) < -slope factor * ATR(ATR length, T1, last completed bar)
Calculation: Flat slope = ABS(LINREG_SLOPE(close, slope lookback, T1, last completed bar)) < slope factor * ATR(ATR length, T1, last completed bar)
Calculation: Blended ER = (1 - HTF weight) * KaufmanER(close, ER length) + HTF weight * KaufmanER(close, ER length, T1, last completed bar)
Calculation: Volume percentile = PERCENTRANK(volume, volume lookback)
Calculation: Volume hysteresis = MIN(volume hysteresis band, (volume high percentile - volume low percentile) / 2)
Calculation: Volume expanding = IF Volume expanding[1] THEN Volume percentile >= volume high percentile - Volume hysteresis ELSE Volume percentile > volume high percentile + Volume hysteresis
Calculation: Volume contracting = IF Volume contracting[1] THEN Volume percentile <= volume low percentile + Volume hysteresis ELSE Volume percentile < volume low percentile - Volume hysteresis
Calculation: Stay-out state = (ATR extreme AND Blended ER < ER minimum AND NOT (Flat slope AND Volume expanding)) OR (Flat slope AND Blended ER < ER minimum AND NOT Volume expanding AND NOT Volume contracting) OR (swing horizon AND Flat slope AND ATR extreme)
Long: Bullish slope
Long: Bullish slope AND Volume expanding
Long: NOT intraday horizon AND Bullish slope AND Blended ER >= ER minimum
Long: NOT intraday horizon AND Bullish slope AND Blended ER < ER minimum AND NOT ATR extreme
Long: intraday horizon AND Bullish slope AND ATR extreme AND Blended ER >= ER minimum AND Volume expanding
Short: Bearish slope
Short: Bearish slope AND Volume expanding
Short: NOT intraday horizon AND Bearish slope AND Blended ER >= ER minimum
Short: NOT intraday horizon AND Bearish slope AND Blended ER < ER minimum AND NOT ATR extreme
Short: intraday horizon AND Bearish slope AND ATR extreme AND Blended ER >= ER minimum AND Volume expanding
Exit: long, Stay-out state
Exit: short, Stay-out state
Exit: long, Bullish slope AND Volume contracting
Exit: short, Bearish slope AND Volume contracting