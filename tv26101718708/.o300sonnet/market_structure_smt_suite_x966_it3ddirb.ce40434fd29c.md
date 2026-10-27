【CISD 做多】
1. 掃低：把資料聚合成較高週期K（約為當前週期的數倍），取最近12根已完成的高週期K，只保留低點未被後續高週期K低點跌破的那些。當根 low < 該低點 - 1tick，且前一根 low >= 該門檻，才算新掃低。
2. 掃低後出現連續下跌K（close<open）作為 delivery。內含K（high<=前高且low>=前低）若緊鄰下跌K，也算 delivery 成員。最近一根 delivery 離當根最多隔1根。成員中至少2根為真下跌K。CISD = 這段 delivery 內下跌K的最高 open。
3. 往前找最近的 pivot high：左右各2根，high 嚴格大於左側、大於等於右側，在 delivery 之前，搜尋30根內，且該高點 > 當根 low，記為 swing。
4. 掃低後8根內任一根 close > CISD，即 CISD 確認。確認後再8根內任一根 close > swing 時，做多進場。
5. 若 CISD 沒在8根內確認，或 swing 沒在確認後8根內被突破，或候選已超過24根，則作廢。
6. 掃低期間若 low 再創更低，候選更新，並重算 delivery、CISD、swing，確認階段重置。
7. 做多出場：持多時 low < 掃低最低點，即停損失效。或 high >= swing + 4×(swing - 掃低最低點)，即目標達成。

【CISD 做空】
與做多相反。掃高：當根 high > 前方未被超越的高週期K高點 + 1tick，且前一根 high 未超過該門檻。接著連續上漲K（close>open，內含K同樣規則）至少2根，CISD = 上漲K的最低 open。往前找 pivot low（左右各2根）作為 swing。掃高後8根內 close < CISD，確認後再8根內 close < swing 時做空。
做空出場：持空時 high > 掃高最高點，或 low <= swing - 4×(掃高最高點 - swing)。

【高週期K收回掃蕩】
對聚合的高週期K：當根高週期K high > 前一根高點且 close < 前一根高點，指向做空。當根 low < 前一根低點且 close > 前一根低點，指向做多。