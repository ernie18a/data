共同指標：ATR14 為 14 期 RMA 的真實波幅。擺動點取左右各 3 根的嚴格極值 K 棒。高點 high[3] 須大於前後各 3 根的 high，低點 low[3] 須小於前後各 3 根的 low，並在 3 根後確認。新擺動點須與上一個同向擺動點相距超過 0.3×ATR 才採用。minorRefHigh、minorRefLow 為最近採用的擺動高點、低點，majorRefHigh、majorRefLow 為前一個。
趨勢 t：先取 close 與 close[10] 的差（沿用上一次的狀態），差大於 0.1×ATR 為 +1，小於 -0.1×ATR 為 -1；若尚未有值，改用最近兩個擺動高點與低點，皆抬高為 +1、皆降低為 -1，否則為 0。

做多：
1. BOS：t=+1，且 close>minorRefHigh、close[1]<=minorRefHigh。
2. CHoCH：t=-1，且 close>minorRefHigh、close[1]<=minorRefHigh。
3. MSS：t=-1，且 close>majorRefHigh、close[1]<=majorRefHigh，並且 |close-open|>=1.5×ATR。
4. 掃低：有未被掃過的低點池（擺動低點，彼此相距 0.05×ATR 內者合併取平均）。K 棒 low<池價、close>池價，且 high-池價>=0.3×ATR。每個池只觸發一次。
5. 多方 FVG：low>high[2]，且缺口 low-high[2]>=0.1×ATR。
6. 多方耗竭：volume>2×20 期量均線、close>open、下影線>實體，且最近 3 根內有新確認的擺動點。
7. 擺動低點確認（綠色標記）。

做空（與做多對稱）：
1. BOS：t=-1，且 close<minorRefLow、close[1]>=minorRefLow。
2. CHoCH：t=+1，且 close<minorRefLow、close[1]>=minorRefLow。
3. MSS：t=+1，且 close<majorRefLow、close[1]>=majorRefLow，並且 |close-open|>=1.5×ATR。
4. 掃高：high>池價、close<池價，且池價-low>=0.3×ATR。
5. 空方 FVG：high<low[2]，且缺口 low[2]-high>=0.1×ATR。
6. 空方耗竭：volume>2×20 期量均線、close<open、上影線>實體，且最近 3 根內有新確認的擺動點。
7. 擺動高點確認（紅色標記）。

出場：READ 沒有出場判斷。