Calculation: Candle range = high − low
Calculation: Body percentage = 100 × abs(close − open) / candle range
Calculation: Average range = simple moving average of candle range
Calculation: Candle size percentage = 100 × candle range / close
Calculation: DEMA = 2 × EMA(close) − EMA(EMA(close))
Calculation: In session = datetime falls within the configured session window, days, and timezone
Calculation: Take-profit price = entry price + position direction × trigger candle range × configured target fraction
Calculation: Bars elapsed = current bar index − entry bar index
Long: In session AND (one-shot mode disabled OR session trade count = 0) AND no trade active AND close ≥ open AND close > DEMA AND body percentage ≥ configured minimum AND candle range ≥ average range AND candle range ≤ average range × configured maximum multiplier AND (minimum-size filter disabled OR candle size percentage ≥ configured minimum)
Short: In session AND (one-shot mode disabled OR session trade count = 0) AND no trade active AND close < open AND close < DEMA AND body percentage ≥ configured minimum AND candle range ≥ average range AND candle range ≤ average range × configured maximum multiplier AND (minimum-size filter disabled OR candle size percentage ≥ configured minimum)
Exit: long, high ≥ take-profit price OR (bars elapsed ≥ configured maximum trade duration AND high < take-profit price)
Exit: short, low ≤ take-profit price OR (bars elapsed ≥ configured maximum trade duration AND low > take-profit price)