Calculation: Base high/low = highest high / lowest low over the base lookback, excluding the current bar
Calculation: Base width % = 100 × (base high − base low) / base low
Calculation: Average range % in base = mean of 100 × (high − low) / close over the base lookback, including the current bar
Calculation: Close location % = 100 × (current close − base low) / (base high − base low)
Calculation: Volume ratio = mean volume over the base lookback / mean volume over the longer volume-baseline lookback
Calculation: Prior advance % = 100 × (base high − lowest low over the prior-advance lookback ending before the base) / that lowest low
Calculation: Trend averages = simple moving averages of close over the shorter and longer trend lookbacks
Calculation: Daily gain % = 100 × (current close / previous close − 1)
Calculation: Stop = selected stop reference: lowest low over a recent-low lookback, base low, current close − ATR × ATR multiple, or current close × (1 − fixed stop % / 100)
Calculation: Risk % = 100 × (current close − stop) / current close
Calculation: Setup score = weighted sum of capped, normalized scores for base tightness, volume dry-up, prior advance, close location, range contraction (mean range % of the latest 3 bars relative to average range % in base), trend alignment, and risk distance
Long: base width % ≤ maximum AND average range % in base ≤ maximum AND volume ratio ≤ maximum AND prior advance % ≥ minimum AND close location % ≥ minimum AND current close > base high is false AND daily gain % < maximum AND current close ≥ minimum price AND mean volume over the volume-baseline lookback ≥ minimum average volume AND (trend filter disabled OR current close > shorter trend average AND current close > longer trend average) AND risk % ≤ maximum AND setup score ≥ minimum
