【做多/做空判斷，逐根計算；沒有獨立出場規則，反向訊號出現時反手或平倉】

通用定義：ATR=ATR(14)；pivot high=high 為左右各N根內最高、pivot low=low 為左右各N根內最低，要等右側N根收完才確認。

1. 擺動結構突破（BOS/CHoCH）
- N=7。記錄最近確認的 pivot high 為H、pivot low 為L。H、L 每次出現新 pivot 就更新並重新啟用，被突破一次後就失效，直到下一個新 pivot 出現。
- 做多：H 有效且 close>H。突破後將 H 設為失效，結構方向設為多。
- 做空：L 有效且 close<L。突破後將 L 設為失效，結構方向設為空。
- 若突破前結構方向與突破方向相反，該突破稱 CHoCH（轉向），否則稱 BOS（延續）。兩者都指向突破的方向。

2. 趨勢線突破
- N=14，斜率 s=ATR(14)/14。
- 上軌：新 pivot high（N=14）確認的那根，上軌設為該 pivot 高點，並鎖定 sH=s。之後每根上軌減 sH。
- 下軌：新 pivot low 確認的那根，下軌設為該 pivot 低點，並鎖定 sL=s。之後每根下軌加 sL。
- 上破狀態：新 pivot high 出現的那根設為 0；其他根若 close>上軌−sH×14 則設為 1，否則維持前值。
- 下破狀態：新 pivot low 出現的那根設為 0；其他根若 close<下軌+sL×14 則設為 1，否則維持前值。
- 做多：上破狀態由 0 變 1 的那根。
- 做空：下破狀態由 0 變 1 的那根。

3. 快速掃蕩（僅加密貨幣標的）
- 做多：low<前一根 low 且 close>前一根 low。
- 做空：high>前一根 high 且 close<前一根 high。

4. 公允價值缺口（FVG）
- 位移K棒定義（取前一根K棒）：實體=|close−open|，實體/ATR>=0.55，且實體/(high−low)>=0.55。
- 做多：low>high[2]，close[1]>high[2]，缺口 low−high[2]>=0.2×ATR，且前一根是實體符合上述條件的陽線位移K棒。
- 做空：high<low[2]，close[1]<low[2]，缺口 low[2]−high>=0.2×ATR，且前一根是實體符合上述條件的陰線位移K棒。