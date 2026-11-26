Calculation: fast trend = selected trend(price source, fast selector, shorter lookback)
Calculation: slow trend = selected trend(price source, slow selector, longer lookback)
Long: long trades enabled AND datetime within configured date range AND fast trend > slow trend
Short: short trades enabled AND datetime within configured date range AND fast trend < slow trend
Exit: long, datetime outside configured date range OR (short trades disabled AND fast trend < slow trend)
Exit: short, datetime outside configured date range OR (long trades disabled AND fast trend > slow trend)