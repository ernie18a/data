Calculation: Trigger = clamp(sign(shorter-period moving average of close − longer-period moving average of close) + sign(shorter-period RSI of weighted price − longer-period RSI of median price), −1, 1); weighted price = (high + low + 2 × close) / 4; median price = (high + low) / 2. Moving-average methods and periods are configurable; long and short systems can use independent parameters.
Long: Chart-timeframe trigger > 0
Short: Chart-timeframe trigger < 0
Long: Long-system trigger on the selected higher- or lower-timeframe bar > 0 AND trigger on the preceding bar <= 0; the selected bar is the last completed bar by default, with a configurable lag that may instead select the forming bar or an older completed bar.
Short: Short-system trigger on the selected higher- or lower-timeframe bar < 0 AND trigger on the preceding bar >= 0; the selected bar is the last completed bar by default, with a configurable lag that may instead select the forming bar or an older completed bar.
Exit: long, long-system trigger on the selected higher- or lower-timeframe bar < 0; use the same bar selection as the long entry.
Exit: short, short-system trigger on the selected higher- or lower-timeframe bar > 0; use the same bar selection as the short entry.
Exit: long, low <= entry price − configured stop-loss distance OR high >= entry price + configured take-profit distance.
Exit: short, high >= entry price + configured stop-loss distance OR low <= entry price − configured take-profit distance.