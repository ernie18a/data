Calculation: fast line = selected moving average(CCI(close, CCI lookback), shorter lookback, smoothing method, phase) on T1 bars
Calculation: slow line = selected moving average(fast line, longer lookback, smoothing method, phase) on T1 bars
Long: fast line on the last completed T1 bar > slow line on the last completed T1 bar AND fast line on the T1 bar still forming <= slow line on the T1 bar still forming
Short: fast line on the last completed T1 bar < slow line on the last completed T1 bar AND fast line on the T1 bar still forming >= slow line on the T1 bar still forming
Exit: long, fast line on the last completed T1 bar < slow line on the last completed T1 bar
Exit: short, fast line on the last completed T1 bar > slow line on the last completed T1 bar