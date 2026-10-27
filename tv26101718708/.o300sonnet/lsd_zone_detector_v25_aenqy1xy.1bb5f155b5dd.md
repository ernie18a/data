【共用定義】offset 0=當根已收盤K，offset n=往前n根。陽線=close>open，陰線=close<open。ATR為14期ATR。

【一、建立做多區(需求區)】每根收盤K，m從2到30由近到遠找，取第一個同時符合者：
1. K[m]為陰線。
2. K[m-1]為陽線。
3. winStart=max(m-3,1)，offset winStart到m-1中的陽線數>=2。
4. 區間 top=high[m]，bottom=min(low[m],low[m-1])。(外匯可改：high[m]>high[m-1]時top=max(open[m],close[m])，否則top=high[m]。)
5. 乾淨：offset 0到m-1中，任何非陽線(close<=open)的K若 high>=bottom 且 low<=top，則此m淘汰，繼續找下一個m。
6. 區間成立條件：top>bottom，且 top-bottom<=10×ATR；與現存有效區重疊(重疊高度/新區高度>=0.7)不建；與30根內剛結束的區重疊>=0.7不建。
7. 建立後記下建立K、setupHi=建立當根往回到K[m]的最高high。

【二、建立做空區(供給區)】完全鏡像：K[m]為陽線，K[m-1]為陰線，winStart到m-1的陰線數>=2；top=max(high[m],high[m-1])，bottom=low[m]；(外匯：low[m]<low[m-1]時bottom=min(open[m],close[m])，否則low[m])；乾淨條件改為：offset 0到m-1中非陰線(close>=open)的K若 high>=bottom 且 low<=top則淘汰；其餘同上，setupLo=最低low。

【三、需求區狀態(每根收盤K，建立K之後才處理，依序判斷)】狀態0→1→2→3。
- 建立後超過108根：刪區。
- close<bottom：刪區。
- 狀態0或1時 low<=top：刪區(未武裝先被碰)。
- 狀態0：setupHi=max(setupHi,high)。找流動性：j從1到40由近到遠，K[j]為陽線，其前(更舊)連續陰線(>=1根)為回調段，取該段最低low=liq；再往更舊連續陽線段的最高high=origin(須存在)；回調段最舊那根的bar須晚於區建立K；且 liq>top 且 liq<=bottom+0.5×(setupHi-bottom)。取第一個符合者，記下liq與origin，轉狀態1。
- 狀態1：若 high>origin → 轉狀態2(武裝)；否則更新setupHi，若再找到liq更低的合格回調段，則更新liq與origin。
- 狀態2(已武裝，僅在 low<=top 的K評估)：
  a. close在[bottom,top]內：刪區，無訊號。
  b. high>high[1]：做多，進場價=high[1]，止損=當根low。
  c. close>top 且 close>open：做多，進場價=close，止損=當根low。
  d. close>top 但為陰線或平盤：轉狀態3，deepWick=當根low。
- 狀態3(每根)：close在[bottom,top]內→刪區；若 low<=top 則deepWick=min(deepWick,low)；然後
  a. low<=top 且 high>high[1]：做多，進場價=high[1]，止損=deepWick。
  b. close>top 且 close>open：做多，進場價=close，止損=deepWick。
- 一旦出現做多進場，該區即結束。止損<bottom(穿區)者不計為有效交易。

【四、供給區狀態】鏡像：
- 超過108根刪區；close>top刪區；狀態0/1時 high>=bottom刪區。
- 狀態0：setupLo=min(setupLo,low)；找流動性：K[j]為陰線，其前連續陽線(>=1根)為回調段，liq=該段最高high；再往更舊連續陰線段最低low=origin；回調段最舊根晚於建立K；liq<bottom 且 liq>=top-0.5×(top-setupLo)。取最近合格者，轉狀態1。
- 狀態1：low<origin → 轉狀態2；否則更新setupLo，若找到liq更高的合格回調段則更新。
- 狀態2(僅在 high>=bottom 的K評估)：
  a. close在[bottom,top]內：刪區。
  b. low<low[1]：做空，進場價=low[1]，止損=當根high。
  c. close<bottom 且 close<open：做空，進場價=close，止損=當根high。
  d. close<bottom 但為陽線或平盤：轉狀態3，deepWick=當根high。
- 狀態3(每根)：close在區內→刪區；若 high>=bottom 則deepWick=max(deepWick,high)；然後
  a. high>=bottom 且 low<low[1]：做空，進場價=low[1]，止損=deepWick。
  b. close<bottom 且 close<open：做空，進場價=close，止損=deepWick。
- 止損>top者不計為有效交易。

【五、出場(進場後從下一根起逐根判斷)】R=|進場價-止損|。
- 多單：low<=止損 → 停損出場；high>=進場價+2R → 停利出場。
- 空單：high>=止損 → 停損出場；low<=進場價-2R → 停利出場。
- 同一根同時觸及止損與停利，以停損為準。