【VA 計算】取最近 1650 根。每根 K 的成交量均分到 high~low 涵蓋的價格格（約 140 格，格寬=(區間最高-最低)/格數）。POC=量最大格。VA 從 POC 起、累積達總量 70% 為止，每次往量較大的相鄰格擴張（上方量>=下方量時往上）。VAH=VA 上緣，VAL=VA 下緣，寬度W=max(VAH-VAL, 最小跳動)。

【突破接受/失敗，每根收盤計算】
- 連續收盤在 VAH 之上的根數 up，連續收盤在 VAL 之下的根數 dn，價格回到 VAL~VAH 內則歸零。
- 做多：up 剛好等於 2（連續 2 根收在 VAH 上方）。
- 做空：dn 剛好等於 2（連續 2 根收在 VAL 下方）。
- 向上突破失敗：前一根 up 為 1 且本根收盤回到 VAL~VAH 內，視為向上假突破，指向做空。
- 向下突破失敗：前一根 dn 為 1 且本根收盤回到 VAL~VAH 內，視為向下假突破，指向做多。
- 從 VA 外收回 VA 內但不屬上述失敗者，無方向。

【偏向分數，每根收盤計算】
- 參考 VA 快照（POC、VAH、VAL）：第一次直接取當下值，之後每約 24 根更新一次。
- shift=clamp((POC-參考POC)/W, -1, 1)。
- overlap=兩個 VA 區間（現在與參考）的交集長度/聯集長度，overlap_comp=1-2*overlap。
- loc=clamp((收盤-POC)/W, -1, 1)。
- accept 項：做多事件為 +1，做空事件為 -1，其餘為 0。
- bias=round(100*(0.40*shift+0.25*overlap_comp+0.20*loc+0.15*accept))。
- bias>0 偏多，bias<0 偏空。
- bias>=35 為強偏多，bias<=-35 為強偏空。

【VA 位置】收盤>VAH 偏多，收盤<VAL 偏空，其餘無方向。

【CVD 背離】
- 每根 delta=成交量*sign(收盤-開盤)，平盤為 0，CVD 為累積 delta。
- 以左右各 3 根確認 pivot high（用 high）與 pivot low（用 low），訊號在 pivot 後 3 根才成立。
- 做空：新 pivot high 高於前一個 pivot high，且 pivot 當根 CVD 低於前一個 pivot high 當根 CVD。
- 做多：新 pivot low 低於前一個 pivot low，且 pivot 當根 CVD 高於前一個 pivot low 當根 CVD。
- 兩次背離訊號間隔須大於 20 根。

【出場】沒有獨立出場規則，反向訊號即為反向方向。