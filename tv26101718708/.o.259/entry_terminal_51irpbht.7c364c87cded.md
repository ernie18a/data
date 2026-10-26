【共用定義】
- 結構樞紐：樞紐邊長 s=6（fractal 12 為偶數先加 1 得 13，再取整數除以 2）。用 high 做 s 根左右 pivot high，用 low 做 pivot low，pivot 在其後第 6 根收盤確認。記最新 pivot high 為 U、最新 pivot low 為 L，新 pivot 出現時該側重設為未被突破。
- 突破（收盤確認）：close>U 且 U 未被突破為向上突破；close<L 且 L 未被突破為向下突破。突破後該側標記為已突破。同一根兩側都突破時，close>=open 取向上，否則取向下。
- 市場方向 M 為最近一次突破的方向（初始為 0）。向上突破且 M=-1 為「看多 CHoCH」，向下突破且 M=1 為「看空 CHoCH」。M 與當前 CHoCH 方向 D 相同時，同向突破為 BOS。突破後 M 更新為突破方向。每次 CHoCH 設 D 為該方向，並把下面的序列重置為階段 0。

【做多／做空判斷】
1. CHoCH 與 BOS 的方向：看多 CHoCH、D=1 時的向上 BOS 指向做多；看空 CHoCH、D=-1 時的向下 BOS 指向做空。
2. BUY／SELL 進場（以看多為例，看空鏡像）。必須依序完成：
   - 階段0，拒絕塊：D=1 時，在 CHoCH 之後，以 pivotlow(low,12,12) 找到樞紐 K 棒 P，P 須晚於 CHoCH 棒。P 的 range=high-low>0，下影線=min(open,close)-low。下影線/range>=50%，且下影線>=0.5×P 當根的 ATR(14)。符合時在 P 之後第 12 根收盤確認，區間為 [low_P, min(open_P,close_P)]，進入階段1；若階段1已有舊區間，則被新區間取代。
   - 階段1，重測：確認棒之後，close<區間下緣則作廢並回到階段0。否則先等某根 low>區間上緣（上緣為 min(open_P,close_P)）作為待命，之後第一根滿足 low<=上緣 且 high>=下緣 的 K 棒為「RB 重測」，進入階段2，同時清除先前記錄的 BOS 與 FVG。
   - 階段2，BOS 加 FVG 配對：重測棒之後，出現同向 BOS（記錄其 bar index），且出現同向新 FVG（記錄其 bar index、上下緣）。看多 FVG 條件為：在當根 t 確認 low[1]>high[3]，且 close[2]>low[2]；上緣=low[1]，下緣=high[3]。看空 FVG 條件為：low[3]>high[1]，且 close[2]<high[2]；上緣=low[3]，下緣=high[1]。兩者 bar index 相差<=3（可任一在前）時，取最新 FVG 為最終 FVG，進入階段3。
   - 階段3，最終 FVG 重測：須晚於 BOS 與 FVG 兩棒中較晚者。先判斷失效：看多為 min(open,close)<FVG 下緣（看空為 max(open,close)>FVG 上緣），失效則清掉 FVG 與 BOS 記錄並回到階段2。未失效時，看多只要 low<FVG 上緣（看空為 high>FVG 下緣），該棒即觸發做多（看空則做空），完成後序列結束，等下一個 CHoCH 才重置。
3. 進場箱出場標記（方向標記）：看多 CHoCH 時，以 CHoCH 前最新未破 L 為 0、CHoCH 棒 high 為 1，單位=1-0；看空時以 U 為 0、CHoCH 棒 low 為 1。箱區為 0+單位×0.382 與 0+單位×0.618 之間。CHoCH 之後任一棒與箱區相交即視為已觸及。已觸及後第一次 close>箱上緣為做多標記，close<箱下緣為做空標記（依 D 決定，每個 CHoCH 只出現一次）。
4. IFVG 標記：看空 FVG 被 max(open,close)>其上緣突破時指向做多；看多 FVG 被 min(open,close)<其下緣跌破時指向做空。
5. 流動性趨勢線突破標記：看空 CHoCH 後，起點取前一段 regime 的最高點，等第一個低於起點價的 pivot high（6 根左右、時間晚於 CHoCH）連成線；之後 close 向上突破該線為做多。看多 CHoCH 後，起點取前一段 regime 最低點，等第一個高於起點價的 pivot low 連成線；之後 close 向下跌破該線為做空。連線成立的當根不判斷，每條線只標一次。

【過濾與分類條件】
- 看空 CHoCH 或看多 CHoCH 才能啟動序列，且序列方向固定為 CHoCH 方向。
- ATR 邊界：CHoCH 當根的 ATR(14) 記為 a，上界=high+0.5a，下界=low-0.5a。之後第一次 close>上界或 close<下界（兩者同時時 close>=open 取上）視為邊界突破。突破方向與 CHoCH 方向相同標 MATCH，相反標 COUNTER，僅為分類標示，不限制進場。