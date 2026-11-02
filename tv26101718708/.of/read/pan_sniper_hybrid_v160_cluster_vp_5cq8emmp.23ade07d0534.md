Calculation: Bull volume fraction = 0.5 when volume is zero; otherwise 1 when close > open and 0 when close <= open.
Calculation: Gaussian line = EMA of close.
Calculation: Confirmed pivot high or low = a high or low that is respectively the highest or lowest over its specified left and right lookbacks, available when the right lookback has completed. Keep the latest confirmed high and low separately.
Calculation: Demand zone = latest confirmed pivot low through that low plus a multiple of ATR measured on the confirmation bar; supply zone = latest confirmed pivot high minus a multiple of ATR measured on the confirmation bar through that high. Maintain separate zones using longer and shorter pivot lookbacks. A zone remains active until replaced by the next pivot of the same type and lookback.
Calculation: Cluster proximity = absolute distance from close to any cluster point of control <= a multiple of ATR. On the last dataset bar only, cluster the lookback bars' (high + low) / 2 values by assigning each to the nearest of evenly spaced initial centroids and repeatedly replacing each centroid with its assigned volume-weighted mean. For each nonempty cluster, divide its assigned bars' total low-to-high range into equal price bins, distribute each bar's volume in proportion to its high-low overlap with each bin, and take the midpoint of the highest-volume bin as its point of control. On other historical bars cluster proximity is false.
Calculation: Bull score = count of close > Gaussian line, MACD line > signal line, bull volume fraction > bull threshold, close inside either demand zone, and cluster proximity. Bear score = count of close < Gaussian line, MACD line < signal line, bull volume fraction < bear threshold, close inside either supply zone, and cluster proximity.
Calculation: Strict filter = volume / SMA of volume >= minimum volume ratio, using 1 when the volume SMA is not positive, AND absolute percentage distance between close and Gaussian line <= maximum distance AND, if the optional volatility filter is enabled, ATR >= a multiple of its SMA.
Calculation: Bullish FVG block = a block from high two bars ago down by ATR when high two bars ago < current low, high two bars ago < previous high, low two bars ago < current low, and (current low - high two bars ago) / current low exceeds the gap threshold. Bearish FVG block = a block from low two bars ago up by ATR when low two bars ago > current high, low two bars ago > previous low, high two bars ago > current high, and (low two bars ago - current high) / low two bars ago exceeds the gap threshold. Create blocks only on confirmed bars within the configured lookback from the dataset end. Delete a bullish block when high < its bottom and a bearish block when low > its top unless retaining broken blocks is enabled. For either side, delete a block when another same-side block's top lies strictly inside it. After processing signals, remove the oldest same-side block whenever the block count reaches the configured limit.
Calculation: Nadaraya-Watson middle = weighted mean of up to the most recent lookback of confirmed closes, with weight at age i equal to (1 + i² / (2 × bandwidth² × weighting)) raised to -weighting. Upper and lower bands equal the middle plus and minus a multiple of ATR.
Calculation: Density zone = a zone centered on close and extending by a multiple of ATR on each side when volume reaches its rolling percentile threshold. Its direction is demand when close >= previous close and supply otherwise. Instead of creating a new zone, extend the expiry of the first existing zone whose center is within a multiple of current ATR of close. Delete a demand zone when close < its bottom and volume > a multiple of volume SMA, or a supply zone when close > its top and volume > that multiple; also delete it at expiry.
Calculation: Trend filter = comparison of shorter and longer EMAs of close, optionally using the last completed higher-timeframe close sampled onto chart bars before calculating the EMAs. If the ADX option is selected, ADX must also be >= its threshold; ADX uses the same last completed higher-timeframe bar when the higher timeframe is selected.
Long: MACD line crosses above its signal line AND close > Gaussian line AND bull volume fraction > bull threshold AND (strict mode is disabled OR bull score >= minimum confirmations AND strict filter holds).
Short: MACD line crosses below its signal line AND close < Gaussian line AND bull volume fraction < bear threshold AND (strict mode is disabled OR bear score >= minimum confirmations AND strict filter holds).
Long: low < latest confirmed pivot low AND close > latest confirmed pivot low AND bull volume fraction > shark bull threshold.
Short: high > latest confirmed pivot high AND close < latest confirmed pivot high AND bull volume fraction < shark bear threshold.
Long: current low > bullish FVG block top AND previous low <= that top AND no bullish FVG is created on the current bar.
Short: current high < bearish FVG block bottom AND previous high >= that bottom AND no bearish FVG is created on the current bar.
Long: close crosses above Gaussian line.
Short: close crosses below Gaussian line.
Long: low <= Nadaraya-Watson lower band AND high < Nadaraya-Watson upper band.
Short: high >= Nadaraya-Watson upper band.
Long: Nadaraya-Watson middle > its previous value.
Short: Nadaraya-Watson middle <= its previous value.
Long: MACD line > signal line.
Short: MACD line <= signal line.
Long: close > Gaussian line.
Short: close <= Gaussian line.
Long: bull volume fraction > 0.5.
Short: bull volume fraction <= 0.5.
Long: a newly confirmed pivot low > the preceding confirmed pivot low; retain this direction until a subsequent higher pivot low or lower pivot high changes it.
Short: a newly confirmed pivot high < the preceding confirmed pivot high; retain this direction until a subsequent higher pivot low or lower pivot high changes it.
Long: shorter trend-filter EMA > longer trend-filter EMA.
Short: shorter trend-filter EMA <= longer trend-filter EMA.
Long: a demand zone exists AND (show-only-in-trend is disabled OR trend filtering is off OR shorter trend-filter EMA > longer trend-filter EMA AND (ADX filtering is off OR ADX >= its threshold)).
Short: a supply zone exists AND (show-only-in-trend is disabled OR trend filtering is off OR shorter trend-filter EMA <= longer trend-filter EMA AND (ADX filtering is off OR ADX >= its threshold)).
Long: a demand density zone exists.
Short: a supply density zone exists.