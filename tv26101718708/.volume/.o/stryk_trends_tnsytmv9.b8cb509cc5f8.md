Calculation: eVWMA = recursively volume-weighted hlc3, blended with an EMA of hlc3 using the configured EMA-floor mix; each bar’s weight is min(volume × gain / trailing volume sum, 1)
Calculation: Master ATR distance = (close − eVWMA) / master ATR
Calculation: Smoothed ATR distance = EMA of Master ATR distance using the configured smoothing length
Long: Smoothed ATR distance > the configured flat-band distance
Short: Smoothed ATR distance < −the configured flat-band distance
Calculation: Coil percentile = 100 × (SMA of true range over the coil ATR length − its lowest value over the percentile lookback) / (its highest value − its lowest value) over that lookback; use 50 if highest equals lowest
Calculation: Coil release = prior bar’s Coil percentile was at or below the coil threshold and current bar’s percentile is above it
Calculation: Stretch = Master ATR distance
Long: Coil release occurred within the configured fire window, no fade has fired since that release, Stretch is between −the configured maximum and −the configured minimum, and long fades are allowed
Short: Coil release occurred within the configured fire window, no fade has fired since that release, Stretch is between the configured minimum and maximum, and short fades are allowed
Calculation: Reversal confluence = count of matching checks: RSI rollover (prior RSI at/above overbought and current RSI below prior RSI for a short; prior RSI at/below oversold and current RSI above prior RSI for a long); band re-entry (prior high at/above prior upper band and current close below current upper band for a short; prior low at/below prior lower band and current close above current lower band for a long); confirmed pivot high/low using configured left and right bars; volume at/above configured multiple of its moving average
Calculation: Reversal upper/lower bands = eVWMA ± configured band multiple × master ATR
Long: Since Stretch last returned within the configured reset distance of zero, its minimum reached at least the configured negative leg-stretch distance, the long reversal has not fired, and long Reversal confluence is at least the configured minimum
Short: Since Stretch last returned within the configured reset distance of zero, its maximum reached at least the configured positive leg-stretch distance, the short reversal has not fired, and short Reversal confluence is at least the configured minimum
Long: A prior long coil fade fired, the configured confirmation window has not expired, no volume confirmation has fired for it, and recent average volume is at least the configured surge percentage above the volume average captured on the bar before that fade
Short: A prior short coil fade fired, the configured confirmation window has not expired, no volume confirmation has fired for it, and recent average volume is at least the configured surge percentage above the volume average captured on the bar before that fade
Calculation: Trail ATR = SMA of true range over the selected trail ATR length; if higher-timeframe ATR is enabled, use the last completed bar of the selected higher timeframe
Calculation: Trail stop = ratcheting stop at configured ATR multiple × Trail ATR from close; while long, it can only rise, and while short, it can only fall
Calculation: Band-opening gap average = mean of the configured number of prior trailing-stop band-opening gaps, after the configured minimum number of gaps has been collected
Long: A trailing-stop band opens on the long side and its gap from the prior stop exceeds the configured multiple of Band-opening gap average
Short: A trailing-stop band opens on the short side and its gap from the prior stop exceeds the configured multiple of Band-opening gap average
Exit: Long, signal-armed trailing stop is active and current close is below the prior bar’s stop
Exit: Short, signal-armed trailing stop is active and current close is above the prior bar’s stop