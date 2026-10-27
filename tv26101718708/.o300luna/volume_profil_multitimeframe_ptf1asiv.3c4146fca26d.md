計算：成交量分布 POC、VAH、VAL＝將所選期間內每根 K 線的成交量平均分配至其 high-low 覆蓋的等寬價格列；總量最大的價格列中點為 POC。從 POC 列開始，逐次向相鄰列中成交量較大的一側擴展，直到累計成交量達設定比例；上、下邊界為 VAH、VAL。使用最近已完成期間的數值。
做多：連續回看期內最低收盤價高於 VAH，且回看期前一根收盤價不高於 VAH；low 不高於 VAL 且 close 高於 VAL，且前一根 close 不低於 VAL；close 高於 POC 且前一根 close 不高於 POC。
做空：連續回看期內最高收盤價低於 VAL，且回看期前一根收盤價不低於 VAL；high 高於 VAH 且 close 低於 VAH，且前一根 close 不高於 VAH；close 低於 POC 且前一根 close 不低於 POC。