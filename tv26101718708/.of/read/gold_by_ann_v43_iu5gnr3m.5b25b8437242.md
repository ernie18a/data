Calculation: 1-minute price range = highest high minus lowest low over the selected recent 1-minute bars; 1-minute recent volume = average volume over those bars; 1-minute baseline volume = 20-bar average volume on the 1-minute timeframe
Calculation: Bullish 1-minute spike = 1-minute price range >= threshold AND 1-minute recent volume > 1-minute baseline volume × volume multiplier AND current 1-minute close > open of the first bar in the selected window
Calculation: Bearish 1-minute spike = 1-minute price range >= threshold AND 1-minute recent volume > 1-minute baseline volume × volume multiplier AND current 1-minute close <= open of the first bar in the selected window
Calculation: Daily range position = current close compared with the running day's low plus 95% of the running day's high-low range
Calculation: Two-hour price change = percentage change from the close 120 chart bars ago to the current close
Long: Bullish 1-minute spike
Short: Bearish 1-minute spike
Long: Flat position AND no cooldown, no tall-bar filter, trading day is Tuesday or Wednesday except Tuesday from 15:00 onward and Wednesday at 08:00 or 22:00 GMT+7, the last completed hourly bar's close > its open, 50-bar SMA slope (current SMA minus its value 5 bars ago) > -flat threshold, close is not above the running day's low plus 95% of its range, two-hour price change is not above the maximum, wait counter is zero AND squeeze-release wait is off AND a pivot low is confirmed
Short: Flat position AND no cooldown, no tall-bar filter, same trading-time restriction, the last completed hourly bar's close > its open, 50-bar SMA slope > -flat threshold, close is not above the running day's low plus 95% of its range, two-hour price change is not above the maximum, wait counter is zero AND squeeze-release wait is off AND a pivot high is confirmed AND close < 50-bar SMA AND RSI(14) < 50
Long: Wait counter reaches 1 after a long exit AND squeeze-release wait is off AND (close > 50-bar SMA AND RSI(14) > 55 AND volume > 20-bar average volume × volume multiplier AND close > last confirmed pivot high OR bullish breakout)
Short: Wait counter reaches 1 after a long exit AND squeeze-release wait is off AND (close < 50-bar SMA AND RSI(14) < 45 AND volume > 20-bar average volume × volume multiplier AND close < last confirmed pivot low OR bearish breakdown)
Short: Wait counter reaches 1 after a short exit AND squeeze-release wait is off AND (close < 50-bar SMA AND RSI(14) < 45 AND volume > 20-bar average volume × volume multiplier AND close < last confirmed pivot low OR bearish breakdown)
Long: Wait counter reaches 1 after a short exit AND squeeze-release wait is off AND (close > 50-bar SMA AND RSI(14) > 55 AND volume > 20-bar average volume × volume multiplier AND close > last confirmed pivot high OR bullish breakout)
Calculation: Bullish breakout = ADX > trend threshold AND close > 50-bar SMA AND RSI crosses above 55 AND volume > 20-bar average volume × volume multiplier AND close > last confirmed pivot high
Calculation: Bearish breakdown = ADX > trend threshold AND close < 50-bar SMA AND RSI crosses below 45 AND volume > 20-bar average volume × volume multiplier AND close < last confirmed pivot low
Exit: Long, close >= entry price + (30-bar SMA × regular take-profit percentage, or re-entry take-profit percentage for a re-entry)
Exit: Long, close >= entry price + (30-bar SMA × regular sub-take-profit percentage, or re-entry sub-take-profit percentage for a re-entry) AND sub-take-profit not already taken (close 50%)
Exit: Long, close <= entry price - (30-bar SMA × stop-loss percentage)
Exit: Long, close <= entry price - (30-bar SMA × re-entry stop percentage) when in a re-entry
Exit: Long, bearish 1-minute spike OR bearish breakdown
Exit: Long, bullish 1-minute spike
Exit: Short, close <= entry price - (30-bar SMA × regular take-profit percentage, or re-entry take-profit percentage for a re-entry)
Exit: Short, close <= entry price - (30-bar SMA × regular sub-take-profit percentage, or re-entry sub-take-profit percentage for a re-entry) AND sub-take-profit not already taken (close 50%)
Exit: Short, close >= entry price + (30-bar SMA × stop-loss percentage)
Exit: Short, close >= entry price + (30-bar SMA × re-entry stop percentage) when in a re-entry
Exit: Short, bearish 1-minute spike
Exit: Short, bullish 1-minute spike