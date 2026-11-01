Long: On the chart timeframe, shorter-lookback MFI > longer-lookback MFI AND longer-lookback MFI > signal level.
Short: On the chart timeframe, shorter-lookback MFI < longer-lookback MFI AND longer-lookback MFI < 100 − signal level.
Long: On a configurable indicator timeframe, which may be higher or lower than the chart timeframe, shorter-lookback MFI > longer-lookback MFI AND longer-lookback MFI > signal level AND (on the preceding indicator bar, shorter-lookback MFI <= longer-lookback MFI OR longer-lookback MFI <= signal level). Use the last completed indicator bar or the still-forming indicator bar, as configured.
Short: On the same indicator timeframe and selected bar, shorter-lookback MFI < longer-lookback MFI AND longer-lookback MFI < 100 − signal level AND (on the preceding indicator bar, shorter-lookback MFI >= longer-lookback MFI OR longer-lookback MFI >= 100 − signal level).
Exit: long, on the same indicator timeframe and selected bar, shorter-lookback MFI < longer-lookback MFI AND longer-lookback MFI < 100 − signal level.
Exit: short, on the same indicator timeframe and selected bar, shorter-lookback MFI > longer-lookback MFI AND longer-lookback MFI > signal level.
Exit: long, low <= entry price − stop-loss distance OR high >= entry price + take-profit distance.
Exit: short, high >= entry price + stop-loss distance OR low <= entry price − take-profit distance.