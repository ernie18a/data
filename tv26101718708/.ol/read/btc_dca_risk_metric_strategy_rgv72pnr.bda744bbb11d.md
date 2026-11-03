Calculation: Composite risk metric = ((daily close − 1460-bar daily SMA of close) / 1460-bar daily standard deviation of close / (−38.12 × ln(current time in milliseconds) + 1078.5) + (ln(daily close / 20-bar weekly SMA of close) + (−3.719 × ln(current time in milliseconds) + 105)) / (−6 × 10⁻¹² × current time in milliseconds + 10.93) + (50-bar daily SMA of close / 50-bar weekly SMA of close) / (−12.55 × ln(current time in milliseconds) + 355.15)) / 3; weekly calculations use the higher timeframe’s latest available bar
Long: Composite risk metric ≤ highest buy threshold
Exit: long, Composite risk metric ≥ first sell threshold
Exit: long, Composite risk metric ≥ second sell threshold after the first sell
Exit: long, Composite risk metric ≥ third sell threshold after the second sell