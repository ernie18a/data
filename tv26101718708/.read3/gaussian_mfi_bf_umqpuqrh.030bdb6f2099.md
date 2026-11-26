Long: GaussianFilter(hlc3, pole-count parameter, sampling-period parameter, reduced-lag setting, fast-response setting) > GaussianFilter(hlc3, pole-count parameter, sampling-period parameter, reduced-lag setting, fast-response setting)[1] AND abs(EMA(ROC(close, ROC lookback), half the ROC lookback)) > half the ROC threshold AND MFI(hlc3, volume, MFI lookback) > MFI(hlc3, volume, MFI lookback)[1]
Short: GaussianFilter(hlc3, pole-count parameter, sampling-period parameter, reduced-lag setting, fast-response setting) < GaussianFilter(hlc3, pole-count parameter, sampling-period parameter, reduced-lag setting, fast-response setting)[1] AND abs(EMA(ROC(close, ROC lookback), half the ROC lookback)) > half the ROC threshold AND MFI(hlc3, volume, MFI lookback) < MFI(hlc3, volume, MFI lookback)[1]
Calculation: latest long-condition time = most recent datetime for which the Long entry condition holds
Calculation: latest short-condition time = most recent datetime for which the Short entry condition holds
Long: crossover(latest long-condition time, latest short-condition time)
Short: crossover(latest short-condition time, latest long-condition time)
Calculation: latest long-marking open = open on the latest long marking, carried forward otherwise
Calculation: latest short-marking open = open on the latest short marking, carried forward otherwise
Exit: long, bars_since(latest long-marking open != latest long-marking open[1]) > 0 AND (low <= entry price * (1 - stop-loss percentage) OR high >= entry price * (1 + take-profit percentage))
Exit: short, bars_since(latest short-marking open != latest short-marking open[1]) > 0 AND (high >= entry price * (1 + stop-loss percentage) OR low <= entry price * (1 - take-profit percentage))