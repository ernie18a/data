Calculation: bar count = previous bar count + 1 when volume > -1; otherwise previous bar count; treat missing prior count as 0
Calculation: trajectory drift = (previous close − close two bars ago + smoothing parameter × previous trajectory drift) / (smoothing parameter + 1); treat missing prior values as 0
Calculation: gravitational step = scale parameter / sqrt(close × close)
Calculation: gyroscopic line = provisional line is close when bar count ≤ 5, otherwise previous gyroscopic line; if provisional line < close, previous gyroscopic line + gravitational step + trajectory drift, otherwise previous gyroscopic line − gravitational step + trajectory drift; treat missing previous gyroscopic line as 0
Long: close > gyroscopic line
Short: close < gyroscopic line
Exit: long, close ≤ gyroscopic line
Exit: short, close ≥ gyroscopic line