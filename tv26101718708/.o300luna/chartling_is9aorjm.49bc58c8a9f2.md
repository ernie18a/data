計算：Wave 上界、下界＝將 OHLC 各自以較短回看期的移動平均平滑，轉換為 Heikin-Ashi 高低價，再以較長回看期的移動平均平滑
計算：Flow 線＝對「2×（前一根 open＋前一根 close）－當根 high－當根 low－當根 open」依序在低於當根 low 時取其與 low 的平均、在高於當根 high 時取其與 high 的平均，再以移動平均平滑
做多：close ≥ Flow 線，或當根 low > Wave 上界
做空：close < Flow 線，或當根 high < Wave 下界