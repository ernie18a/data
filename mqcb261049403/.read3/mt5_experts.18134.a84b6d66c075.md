Calculation: fast line = smoothing(FATL(close), method A, shorter lookback, phase A)
Calculation: slow line = smoothing(SATL(close), method B, longer lookback, phase B)
Long: fast line[1] > slow line[1] AND fast line[0] <= slow line[0]
Short: fast line[1] < slow line[1] AND fast line[0] >= slow line[0]