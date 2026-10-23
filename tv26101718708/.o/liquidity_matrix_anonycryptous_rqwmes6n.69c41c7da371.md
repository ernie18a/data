【做多/做空】
1. 掃單反轉（預設啟用，三角形標示）：
- 先算 ATR14、volMA=SMA(volume,20)、swH=前一根為止的最近10根最高價、swL=前一根為止的最近10根最低價。
- 做多：low<swL，且 close>swL，且 swL-low>=0.1*ATR14，且下影線 (min(open,close)-low)/(high-low)*100>=5，且 volume>1.2*volMA，且距上次做多掃單至少3根。
- 做空：high>swH，且 close<swH，且 high-swH>=0.1*ATR14，且上影線 (high-max(open,close))/(high-low)*100>=5，且 volume>1.2*volMA，且距上次做空掃單至少3根。
- 選用過濾（預設關）：做多需 close<EMA200，做空需 close>EMA200。
- 另有選用模式：收盤突破前一個 pivot 高點（左右各5根）後，若又有一根 close<該高點但 high>該高點，判做空。收盤跌破 pivot 低點後，若有一根 close>該低點但 low<該低點，判做多。

2. 流動性區塊被掃（圓點標示）：
- 做空：出現 pivot 高點（左10右2），且該點 volume>1.5*SMA(volume,20)，該高點即區塊上緣。之後某根收盤確認時 high>上緣，判做空。
- 做多：出現 pivot 低點（左10右2），且該點 volume>1.5*SMA(volume,20)，該低點即區塊下緣。之後某根收盤確認時 low<下緣，判做多。

3. 趨勢方向：
- basis=SMA(EMA(close,12),12)，dev=EMA(|close-basis|,36)*2，上軌=basis+dev，下軌=basis-dev。
- close>上軌，趨勢轉多；close<下軌，趨勢轉空；其間維持前一狀態。
- 區塊買賣的顏色與機率過濾，及掃單可用的趨勢過濾，都依這個趨勢判斷。

4. RSI背離（預設關）：
- 取 RSI14，pivot 窗口 w=5（高敏感3，低敏感10）。
- 做空：RSI 出現 pivot 高點（左右各w根），其 RSI 值低於前一個 RSI pivot 高點的 RSI 值，且該 pivot 那根的 high 高於前一個 pivot 那根的 high。
- 做多：RSI 出現 pivot 低點，其 RSI 值高於前一個 RSI pivot 低點的 RSI 值，且該 pivot 那根的 low 低於前一個 pivot 那根的 low。

5. 結構突破 BOS（預設關）：
- 取 pivot 高點（左右各10根）作壓力區上緣，pivot 低點作支撐區下緣。
- close>=上緣，判做多。
- close<=下緣，判做空。

【出場】
- 掃單停損：做多停損=掃單K的 low-0.5*ATR14，做空停損=掃單K的 high+0.5*ATR14。做多持倉時 low<=停損就出場，做空持倉時 high>=停損就出場。
- 背離追蹤停損（預設關）：
  - 做多背離後，RSI 上穿50時啟動，停損=low-2*ATR14。RSI 在50到70之間時，每根停損取 max(前停損, low-2*ATR14)。close<停損，或 RSI>=70，多單出場。
  - 做空背離後，RSI 下穿50時啟動，停損=high+2*ATR14。RSI 在30到50之間時，每根停損取 min(前停損, high+2*ATR14)。close>停損，或 RSI<=30，空單出場。
  - 若 RSI 回到 OB/OS 以外（>=70 或 <=30），停損關閉。