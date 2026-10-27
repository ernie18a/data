只重現能由 OHLCV 算出的 FADE 逆勢單，其餘路徑用到 delta、買賣量、TICK、VIX、SPY、ES，無法重現。所有 session 調整一律略過，只用預設值。

【指標】
- atr=ATR14（RMA）。adx=DMI14 的 ADX。vwap=每日重置的 hlc3 成交量加權均價。
- ema21、ema100 為收盤價 EMA。rsi=RSI14。mfi=MFI(hlc3,14)。
- relVol=volume/SMA(volume,20)。
- BB=布林帶(20,1.5)。bbPos=(close-下軌)/(上軌-下軌)。
- 擠壓：BB 完全在 KC 內（KC=EMA20±1.5×ATR20）算 sqzOn。sqzFired=前一根 sqzOn 且當根不是。
- sqzMom=linreg(close-avg(avg(highest(high,20),lowest(low,20)),sma(close,20)),20)。
- momFlipBull=sqzMom>0 且前值<=0。momFlipBear=sqzMom<0 且前值>=0。
- momDecelBear=sqzMom<0 且 sqzMom>前值>前前值。momDecelBull=sqzMom>0 且 sqzMom<前值<前前值。
- 動能懲罰 mp：做多看 sqzMom<0 且非 momDecelBear，做空看 sqzMom>0 且非 momDecelBull。符合時 |sqzMom|>2 則 mp=2，>1 則 mp=1，否則 0。不符合時 mp=0。
- 趨勢效率 ER=|close-close[10]|/sum(|Δclose|,10)。門檻=min(0.25×atr/SMA(atr,50),0.65)。
- aerDowntrend=ER>門檻 且 close<close[10]。aerUptrend=ER>門檻 且 close>close[10]。
- 擺動點：pivothigh/pivotlow(5,5)。hhBullish=最近擺動高>前一個擺動高。llBearish=最近擺動低<前一個擺動低。
- hlBullish、lhBearish 同理。fullBullStruct=hhBullish 且 hlBullish。fullBearStruct=llBearish 且 lhBearish。
- chochBull=fullBearStruct 且 close>最近擺動高。chochBear=fullBullStruct 且 close<最近擺動低。
- 實體 body=|close-open|。上影=high-max(o,c)。下影=min(o,c)-low。avgBody=SMA(body,14)。
- bigLowerWick=下影>1.5×body 且 下影>0.3×atr。bigUpperWick 同理用上影。
- freeBarBelow=high<BB 下軌。freeBarAbove=low>BB 上軌。
- Hammer=下影>2×body 且 上影<0.3×body 且 body<avgBody 且 body>0。ShootingStar 反向。
- 多頭吞噬=陽線、前一根陰線、body>avgBody、close>前開、open<=前收。空頭吞噬反向。
- Doji=body<0.05×(high-low)。
- σ=stdev(close-vwap,20)。
- Hurst：取 1 根報酬 close-close[1]，在長度 50、25、12、6 的視窗各自計算 R/S。R/S 是累積離差的極差除以標準差。對 log(長度) 回歸 log(平均 R/S)，斜率限制在 0~1 即為 H。hurstPersist=H>0.55，hurstRevert=H<0.45。

【過熱分數】
- 共同門檻：emaTh 預設 1.5。aerTrending 時為 2.0（ER>門檻，不分方向）。順著趨勢方向且 adx>=30 時為 2.5。
- vwapTh：adx>=35 為 2.5，adx>=25 為 1.8，其餘 1.2。
- 做多分數（價格在均價下方）逐項相加：
  - (ema21-close)/atr>=1.5×emaTh 加 2，>=emaTh 加 1。
  - (vwap-close)/atr>=1.3×vwapTh 加 1.5，>=vwapTh 加 0.75。
  - hhBullish 加 1.5。
  - bigLowerWick 加 0.5。
  - freeBarBelow 加 1。
  - close<vwap-2σ 加 0.75，close<vwap-3σ 再加 0.5。
  - rsi<=30 加 0.5×min(1.5,|rsi-50|/30)。
  - mfi<=20 加 1.0×min(1.5,|mfi-50|/30)。
  - relVol<0.8 加 0.5。
- 做空分數鏡像：用 close-ema21、close-vwap、llBearish、bigUpperWick、freeBarAbove、close>vwap+2σ/3σ、rsi>=70、mfi>=80。
- 過熱門檻：做多 1.0，做空 3.5。
  - adx>=35 加 1.0，adx>=25 加 0.5。
  - hurstRevert 減 0.75，hurstPersist 加 0.75。
  - aerTrending 加 0.3。
  - 最後限制在 1.5~5.0。

【信心分 conf】
- 做多（鏡像為做空）逐項計 1 分，mfi 與 relVol 項可加到 2：
  - 過熱分數>=門檻+1.5。
  - hurstRevert。
  - mfi<=20（mfi<=10 計 2）。
  - relVol>=2（>=3 計 2）。
  - bigLowerWick 或 freeBarBelow。
  - bbPos<0.12（aerTrending 時 0.08）或 close<vwap-2σ。
  - momDecelBear 或 momFlipBull 或 (sqzFired 且 sqzMom>0)。
  - chochBull 計 1。
  - 錘子或多頭吞噬且非 Doji。
- 做空鏡像用 bbPos>0.88（aerTrending 時 0.92）、momDecelBull、momFlipBear、(sqzFired 且 sqzMom<0)、chochBear 等。

【進場閘門】
- 做多：
  - aerDowntrend。
  - adx>=20。
  - relVol>=0.5。
  - 做多過熱分數>=做多門檻。
  - conf>=1。
  - 非 hurstPersist。
  - 非 Doji。
  - 隱藏空頭背離（價格擺動高降低、RSI 擺動高升高）時不做多（adx>=20 或 aerTrending 時 adx>=15 才生效）。
- 做空：
  - aerUptrend。
  - adx>=20。
  - relVol>=0.5。
  - 做空過熱分數>=做空門檻。
  - conf>=3。
  - 非 hurstPersist。
  - 非 Doji。
  - 隱藏多頭背離時不做空。
- 不逆勢加碼：前述條件成立後，須通過下面的 FADE 確認與風報比檢查。

【FADE 確認】
- 做多 fadeConf 逐項計 1 分：
  - bigLowerWick。
  - momDecelBear。
  - momFlipBull。
  - sqzFired 且 sqzMom>0。
  - freeBarBelow。
  - 錘子或多頭吞噬。
  - chochBull 計 2。
- 做多要求 fadeConf>=2+mp+(adx>=35?1:0)+(hurstRevert?-1:0)，下限 1。
- 另加額外要求：aerTrending 且 adx>=30 時加 1，adx>=25 時加 0。
- 做空用鏡像項目（bigUpperWick、momDecelBull、momFlipBear、sqzFired 且 sqzMom<0、freeBarAbove、射擊之星或空頭吞噬、chochBear）。
- 做空額外要求：aerTrending 且 adx>=30 時加 2，adx>=25 時加 1。
- 以上都成立，於收盤價進場，做多或做空。

【停損停利（出場）】
- 做多停損：最近擺動低-1.0×atr，限制在 [close-3atr, close-1.5atr]。做空鏡像。
- 做多目標：只取高於 close 的 ema21、vwap、ema100，找最近與最遠者（都沒有則 close+atr）。
  - conf>=5 取最遠。
  - conf>=3 取兩者平均。
  - 其餘取最近。
  - 目標距離=(該目標-close)×0.85，至少 0.5atr。
- 做空目標：只取低於 close 的 ema21、vwap、ema100，鏡像處理。
- 風報比檢查：做多或做空的目標距離都要>=5 點，且>=停損距離×風報比下限。下限做多 0.8，做空 1.2。hurstRevert 時再減 0.15。
- 出場：持多單時 low<=停損 則停損出場，high>=目標 則停利出場。持空單時 high>=停損 則停損出場，low<=目標 則停利出場。進場同一根不檢查。
- 無其他出場條件。