以下 CC=當前K棒，C1=前一根，C2=前二根，皆用回測K棒本身。

【K棒分類（X 對前一根 P）】
- 內包(1)：X.high<=P.high 且 X.low>=P.low。
- 2u：X.high>P.high 且 X.low>=P.low。
- 2d：X.low<P.low 且 X.high<=P.high。
- 3(外包)：X.high>P.high 且 X.low<P.low；收盤>開盤為3u，否則為3d。
- 「收紅」指 close>open，「收黑」指 close<open。
- 突破與否都以 C1 的高低點為基準。

【做多】滿足下列任一項。
1. 內包反轉：C1 對 C2 為內包，且 C2 不是收紅（C2.close<=C2.open），CC 為 2u（CC.high>C1.high 且 CC.low>=C1.low）。
2. 內包延續：C1 為內包，C2 收紅，CC 為 2u。
3. 2-2 反轉：C1 對 C2 為 2d，CC 為 2u。
4. 2-2 延續：C1 對 C2 為 2u，CC 為 2u。
5. 3-2 擴張：C1 對 C2 為 3，CC 為 2u。
6. 外包擴張：CC 對 C1 為 3 且收紅（3u）。
7. 失敗2d（範圍收復）：CC 為 2d，且依所選方法成立。
   - Reclaim：CC.close 回到 C1 區間內（C1.low<=close<=C1.high）。
   - Open：CC 收紅。
   - Reclaim+Open：兩者同時成立。
   - Reclaim OR Open：任一成立。

第 1 到 5 項還要 CC.close>C1.high 才算成立。一般多單要求收盤站上 C1 高點。

【做空】多單的鏡像，任一項成立即可。
1. 內包反轉：C1 為內包，C2 不是收黑（C2.close>=C2.open），CC 為 2d。
2. 內包延續：C1 為內包，C2 收黑，CC 為 2d。
3. 2-2 反轉：C1 為 2u，CC 為 2d。
4. 2-2 延續：C1 為 2d，CC 為 2d。
5. 3-2 擴張：C1 為 3，CC 為 2d。
6. 外包擴張：CC 為 3d（CC 對 C1 為 3 且收黑）。
7. 失敗2u：CC 為 2u，且依所選方法成立。
   - Reclaim：CC.close 回到 C1 區間內。
   - Open：CC 收黑。
   - Reclaim+Open：兩者同時成立。
   - Reclaim OR Open：任一成立。

第 1 到 5 項還要 CC.close<C1.low 才算成立。一般空單要求收盤跌破 C1 低點。

【多空衝突】
- 若 CC 是 2u 且 C1 為 3，只留做多（排除做空）。
- 若 CC 是 2d 且 C1 為 3，只留做空（排除做多）。
- 若 C1 為內包且 CC 向上突破但不是失敗2，不做空。
- 若 C1 為內包且 CC 向下突破但不是失敗2，不做多。
- CC 為 3u 時不做空，CC 為 3d 時不做多。

【可選過濾】
- 各訊號可要求 C1 為錘子或射擊之星。
- 2-2 反轉可要求 C1 本身是失敗2。

【出場】
- 多單停損：價格跌破停損價就出場。停損價用突破K棒（CC）的最低價，且隨 CC 形成持續更新、收棒後鎖定；或用 C1 低點（在多單成立時鎖定）。失敗2d 一律用 CC 低點。
- 空單停損：價格漲破停損價就出場。停損價用 CC 最高價，或 C1 高點；失敗2u 一律用 CC 高點。
- 保本（可選）：多單的 high>=C2.high（幅度目標）後，停損上移到 C1.high（進場觸發價）。空單的 low<=C2.low 後，停損下移到 C1.low。
- 目標：多單目標為 C2.high，空單目標為 C2.low；延伸目標為更早的轉折高點或低點。
- 反向訊號成立時，反向出場。