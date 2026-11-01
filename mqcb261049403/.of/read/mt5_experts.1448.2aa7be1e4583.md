Long: CCI of typical price on the last completed indicator-timeframe bar > 0 AND CCI on the preceding indicator-timeframe bar <= 0. The indicator timeframe may be higher, lower, or equal to the chart timeframe.
Short: CCI of typical price on the last completed indicator-timeframe bar < 0 AND CCI on the preceding indicator-timeframe bar >= 0. The indicator timeframe may be higher, lower, or equal to the chart timeframe.
Long: CCI of typical price > 0 on every bar in a consecutive lookback ending at the current chart bar.
Short: CCI of typical price < 0 on every bar in a consecutive lookback ending at the current chart bar.
Exit: long, CCI of typical price on the last completed indicator-timeframe bar < 0 OR low <= entry price minus stop-loss distance OR high >= entry price plus take-profit distance.
Exit: short, CCI of typical price on the last completed indicator-timeframe bar > 0 OR high >= entry price plus stop-loss distance OR low <= entry price minus take-profit distance.