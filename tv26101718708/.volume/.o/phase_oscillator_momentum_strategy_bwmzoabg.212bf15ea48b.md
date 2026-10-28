Calculation: Phase Oscillator = short-lookback EMA of ((close − long-lookback EMA(close)) ÷ (ATR over a separate lookback × normalization factor) × 100); the smoothing EMA lookback is shorter than the pivot EMA lookback
Long: Phase Oscillator crosses above the selected signal level AND within the configured entry session and date range AND long entries are enabled AND either the VWAP filter is disabled or |close − session VWAP| ≤ configured ATR multiple × ATR
Short: Phase Oscillator crosses below the negative selected signal level AND within the configured entry session and date range AND short entries are enabled AND either the VWAP filter is disabled or |close − session VWAP| ≤ configured ATR multiple × ATR
Exit: long, Phase Oscillator crosses below the selected exit level (negative entry level for opposite-level mode, zero for zero-return mode, or positive entry level for leave-entry-zone mode)
Exit: short, Phase Oscillator crosses above the selected exit level (positive entry level for opposite-level mode, zero for zero-return mode, or negative entry level for leave-entry-zone mode)
Exit: either, configured flat time is reached or position is outside the regular session, unless overnight holding is enabled
Exit: either, current time is outside the configured backtest date range
Exit: long, close ≤ entry price × (1 − configured hard-stop percentage) when hard stop is enabled
Exit: short, close ≥ entry price × (1 + configured hard-stop percentage) when hard stop is enabled
Exit: long, after price reaches entry price × (1 + configured trail percentage), close ≤ highest high since entry − entry price × configured trail percentage
Exit: short, after price reaches entry price × (1 − configured trail percentage), close ≥ lowest low since entry + entry price × configured trail percentage