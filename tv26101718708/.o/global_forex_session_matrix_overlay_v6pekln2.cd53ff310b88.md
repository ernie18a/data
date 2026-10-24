【均線雲】快線=EMA(close,50)，慢線=EMA(close,200)。快線>慢線偏多；快線<慢線偏空。快線上穿慢線為多方交叉，下穿為空方交叉。收盤價上穿慢線偏多，下穿慢線偏空。
【Pivot】pivot high：某根 high 等於其前後各20根(共41根)的最高 high，需等其後20根收完才確認，標示偏空(▼)。pivot low：某根 low 等於前後各20根的最低 low，確認同上，標示偏多(▲)。另有短版：前後各3根的 pivot，確認後同樣標示。
【結構突破】取最近一個已確認 pivot high 與 pivot low。close 首次收在 pivot high 之上為多方突破(BoS)，若前一次突破是向下則為多方 CHoCH。close 首次收在 pivot low 之下為空方突破，若前一次突破是向上則為空方 CHoCH。每個 pivot 只觸發一次。
【量能K棒色】量均=SMA(volume,21)。volume>=1.618*量均為高量，volume<=0.618*量均為低量。高量且 close>open 為強多，高量且 close<open 為強空；低量方向同上但屬弱訊號。其餘依 close>=open 為多、close<open 為空，若另外加入均線雲趨勢，則以快線>=慢線為趨勢多。
【日內位置】當日第一根K棒的 open 為日開盤價。close>=日開盤價偏多，否則偏空。當日開盤價之上且快線>慢線為多方 Flow；當日開盤價之下且快線<慢線為空方 Flow；其餘為混合，不做方向。前一日最高(PDH)與最低(PDL)取前一日全部K棒的 high/low：close>PDH 偏多(突破)，close<PDL 偏空(跌破)，介於兩者之間無方向。
【VWAP】若啟用，以 hlc3 依錨點(日或週)計算 VWAP，close>=VWAP 偏多，close<VWAP 偏空。
【過濾】均線雲內(收盤價介於快慢線之間)或無明確結構時不做方向。