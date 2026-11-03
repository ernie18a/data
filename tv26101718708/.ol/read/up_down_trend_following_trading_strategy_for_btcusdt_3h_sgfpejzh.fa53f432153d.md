Calculation: Decile score = 10 × floor(indicator value / 10), for RSI and RVI at short, medium, and long lookbacks; the long lookback exceeds the medium, which exceeds the short.
Calculation: Balance of power = 50 + 100 × (close − open) / (high − low); use its medium-lookback simple moving average.
Calculation: General-bottom condition = long-lookback RSI score ≤ lower RSI threshold AND medium RSI score < long RSI score AND short RSI score ≤ medium RSI score; apply the same ordering to RVI and MFI scores, using ≤ for both comparisons, and require long-lookback RVI and MFI scores ≤ their lower thresholds; require balance-of-power average ≤ lower BOP threshold.
Calculation: Critical-bottom condition = general-bottom condition with long-lookback RSI, RVI, and MFI scores ≤ 30 and balance-of-power average ≤ 50.
Calculation: General-up condition = long-lookback RSI score ≥ higher RSI threshold AND medium RSI score > long RSI score AND short RSI score ≥ medium RSI score; apply the same ordering to RVI and MFI scores, using ≥ for both comparisons, and require long-lookback RVI and MFI scores ≥ their higher thresholds; require balance-of-power average ≥ higher BOP threshold.
Calculation: Critical-up condition = general-up condition with long-lookback RSI, RVI, and MFI scores ≥ 60 and balance-of-power average ≥ 60.
Calculation: General-bottom onset = general-bottom condition was true on the previous bar and is false on this bar.
Calculation: Rising/falling ALMA condition = the 10-bar Arnaud Legoux moving average of open is higher/lower than on the previous bar.
Calculation: Lower-low trigger = the rolling lookback-period lowest low crosses the current low while that rolling lowest low is lower than its previous value.
Calculation: Lower-low sequence state = set to 1 on a lower-low trigger; from state 1, set to 2 when open > close or open from two bars ago > current close; from state 2, set to 3 when open < close; from state 3, reset to 0 when open < close or open > close; otherwise reset to 0.
Calculation: Smoothed up/down Supertrend lines = the Supertrend line separated by its up/down direction, with a simple moving average applied to each separated series.
Calculation: Long trend condition for a line = open ≥ line OR high ≥ line OR open crosses above line OR high crosses above line.
Calculation: Short trend condition for a line = close < line OR low < line OR close crosses below line OR low crosses below line.
Calculation: Buy trend composite A = long trend condition for the down and up Supertrend lines, SMA of high, and SAR, AND rising ALMA condition.
Calculation: Buy trend composite B = short trend condition for SMA of high AND long trend condition for both Supertrend lines and SAR.
Calculation: Buy trend composite C = short trend condition for the down and up Supertrend lines AND long trend condition for SMA of high and SAR AND rising ALMA condition.
Calculation: Sell trend composite A = short trend condition for both Supertrend lines, SMA of high, and SAR, AND falling ALMA condition.
Calculation: Sell trend composite B = short trend condition for SMA of high and SAR AND long trend condition for both Supertrend lines.
Calculation: Sell trend composite C = short trend condition for SAR AND long trend condition for the down Supertrend line and SMA of high.
Calculation: Sell trend composite D = long trend condition for the up Supertrend line AND short trend condition for the down Supertrend line, SAR, and SMA of high.
Calculation: Sell trend composite E = long trend condition for the up Supertrend line AND short trend condition for the down Supertrend line and SAR.
Calculation: Trend-composite onset = a composite is true on this bar and false on the previous bar.
Calculation: 9-bar close average falling condition = the 9-bar simple moving average of close is falling over a 4-bar lookback.
Calculation: Profit level = average entry price × (1 + expected profit percentage).
Calculation: Stop level = average entry price × (1 − stop-loss percentage).
Calculation: Add-buy price trigger = low crosses below average entry price multiplied by any of 0.95, 0.90, 0.85, or 0.80.
Calculation: Recent-position cooldown = a long position existed on any of the preceding 10 bars.
Long: Flat position AND (lower-low sequence state = 2 OR general-bottom onset) AND within configured date window AND NOT recent-position cooldown
Long: Long position AND (general-bottom onset OR add-buy price trigger OR onset of buy trend composite A OR onset of buy trend composite B OR onset of buy trend composite C) AND low-based 1-bar simple moving average < average entry price × 0.99 AND 9-bar close average falling condition AND within configured date window
Long: Long position AND lower-low sequence state = 2 AND previous bar's high < average entry price
Exit: Long, (sell trend composite A OR sell trend composite B OR sell trend composite C OR sell trend composite D OR sell trend composite E OR low crosses below profit level) AND within configured date window AND profit level < low-based 1-bar simple moving average AND open trade count ≥ 8
Exit: Long, general-up condition AND within configured date window AND profit level < low-based 1-bar simple moving average AND open trade count < 8
Exit: Long, low crosses below stop level AND open trade count ≥ 90% of the configured maximum entries AND stop loss enabled
Exit: Long, (close > average entry price OR general-up condition) AND NOT recent-position cooldown AND partial profit taking enabled