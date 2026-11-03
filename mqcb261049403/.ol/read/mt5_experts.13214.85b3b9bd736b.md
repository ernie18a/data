Calculation: Fast line = weighted sum of five TRIX values on the configured indicator timeframe, with lookbacks ordered shortest to longest; the second weight is also used for the third TRIX.
Calculation: Slow line = fast line / smoothing period + prior slow line × (smoothing period − 1) / smoothing period, calculated on the configured indicator timeframe.
Long: Fast line > slow line on the latest completed indicator bar AND fast line < slow line on the preceding completed indicator bar.
Short: Fast line < slow line on the latest completed indicator bar AND fast line > slow line on the preceding completed indicator bar.
Exit: Long, fast line < slow line on the latest completed indicator bar AND fast line > slow line on the preceding completed indicator bar.
Exit: Short, fast line > slow line on the latest completed indicator bar AND fast line < slow line on the preceding completed indicator bar.