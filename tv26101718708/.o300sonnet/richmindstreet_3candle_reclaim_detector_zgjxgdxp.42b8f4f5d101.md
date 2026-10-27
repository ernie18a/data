【K線定義】多單setup(3C reclaim)在收盤確認的K線C3(當根)成立,條件:C1=前2根收黑(close[2]<open[2]);C2=前1根low[1]<low[2]且close[1]>low[2];C3=當根close>open且close>low[2]。空單setup鏡像:close[2]>open[2],high[1]>high[2],close[1]<high[2],close<open,close<high[2]。C1極值=low[2](空為high[2]),掃價極值=low[1](空為high[1])。

【結構位】Pivot high=high比左右各3根都高的K線(要3根後才確認),結構高位=該K線的收盤價(close,不是high),取最新一個。Pivot low同理,結構低位=其收盤價。setup成立當根就把當時最新結構高位(多)/結構低位(空)固定下來給此setup用。

【做多流程】
1. 失效:setup之後BOS前,任一根收盤close<C1的low,setup作廢。
2. BOS:setup成立後的某根K線,close>固定的結構高位,且該根close>open(收黑則作廢),即為BOS。BOS根的中點=(high+low)/2。進場價=BOS根close;停損=掃價low[1](須進場價>停損,否則不成立);R=進場價-停損。
3. 50%確認:BOS後緊接的下一根必須同時滿足:close>=BOS中點、close>open、實體|close-open|/(high-low)>0.5;任一不符則setup作廢。全過才開多,進場價仍為BOS根close。
4. 過濾:只有最新一個setup可開倉;該setup必須形成於上一筆交易平倉那根之後;已有持倉時不開新單(同方向),反向則見下方反轉。

【做空流程】完全鏡像:失效為close>C1的high;BOS為close<結構低位且close<open(收紅作廢);中點同上;停損=掃價high[1];R=停損-進場價;50%確認為close<=中點、close<open、實體比>0.5;開空,進場價=BOS根close。

【出場】進場後(從BOS根之後的K線起逐根檢查):
- 多單:low<=停損 → 出場(TP1未到全損-1R;TP1已到則剩餘半倉在停損價出場)。high>=進場+1R → TP1,平半倉。TP1後high>=進場+RR×R(RR預設2,最小1)→ TP2,平剩餘半倉。同根先判停損。
- 空單:high>=停損 出場;low<=進場-1R 為TP1平半倉;TP1後low<=進場-RR×R 為TP2全出。
- 反轉出場:持有多單時,若出現完整確認(BOS+50%通過)的空單setup且其進場價<目前多單進場價,則以該確認根close平掉多單並改做空;持有空單時,若多單setup確認且其進場價>目前空單進場價,以close平空並改做多。