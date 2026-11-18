Calculation: Adjusted net advances = 1000 × (daily advancing-issues close − daily declining-issues close) / (daily advancing-issues close + daily declining-issues close), using the daily bar still forming; undefined when either close is missing or their sum is zero
Calculation: NYSI = cumulative sum of (shorter-lookback EMA of adjusted net advances − longer-lookback EMA of adjusted net advances), treating undefined values as zero, plus a separately tunable offset
Long: NYSI ≥ prior bar NYSI
Short: NYSI < prior bar NYSI