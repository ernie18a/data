Calculation: Hull moving average (HMA) = linearly weighted moving average of (2 × linearly weighted moving average of close over floor(period / 2) bars − linearly weighted moving average of close over period bars), using floor(sqrt(period)) bars for the final average.
Long: Chart-timeframe HMA > previous chart-timeframe HMA.
Short: Chart-timeframe HMA < previous chart-timeframe HMA.
Long: HMA on the selected signal bar > HMA on the preceding bar AND HMA on the preceding bar < HMA two bars before the signal bar. The indicator timeframe is selectable as higher than, lower than, or equal to the chart timeframe; the signal bar is selectable as the forming bar or a completed bar.
Short: HMA on the selected signal bar < HMA on the preceding bar AND HMA on the preceding bar > HMA two bars before the signal bar. The indicator timeframe is selectable as higher than, lower than, or equal to the chart timeframe; the signal bar is selectable as the forming bar or a completed bar.
Exit: long, HMA on the selected signal bar < HMA on the preceding bar, using the same indicator timeframe and signal-bar selection as the entry decisions.
Exit: short, HMA on the selected signal bar > HMA on the preceding bar, using the same indicator timeframe and signal-bar selection as the entry decisions.
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance.