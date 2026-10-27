# rules.tsv 欄位定義

每列＝一條規則行（`.o/*.md` 的一行）。規則類型取該行全形冒號前的字：計算／做多／做空／出場。

| 欄位 | 來源 | 值域 |
|---|---|---|
| file | 程式 | 原檔名 |
| line | 程式 | 行號（1 起算） |
| type | 程式 | 計算／做多／做空／出場 |
| side | 模型 | 單選，見下 |
| calc | 模型 | 單選；type 非「計算」時填 null |
| trig | 模型 | 單選 |
| ind | 模型 | 多選，`|` 連接 |
| flt | 模型 | 多選，`|` 連接 |
| exit | 模型 | 多選，`|` 連接 |
| intent | 模型 | 單選 |
| mtf | 模型 | 單選 |
| text | 程式 | 原句（整行） |

## side（單選）
- long：只涉及多方
- short：只涉及空方
- both：同時定義多空（含「多空」「所有持倉」或對稱定義於同一行）
- none：與方向無關的計算

## calc（單選，只用於 type＝計算）
- indicator：指標或中間序列（均線、振盪器、通道、量能序列等）
- state：方向／狀態／趨勢判定（多空狀態、regime、訊號布林值）
- score：多條件加權或計數的分數
- level：價位或區域（支撐阻力、區塊、開盤區間、擺動點、斐波那契位、錨點）
- pattern：K 線或價格型態定義
- risk：停損、停利、追蹤、保本、出場價位的計算
- sizing：部位大小、加碼、DCA、網格、資金分配
- other：以上皆非

## trig（單選，該行的核心觸發結構；計算行填其定義所用的核心結構，無則 none）
- cross：兩序列交叉（上穿／下穿）
- compare：序列與序列或門檻的高低比較（非交叉）
- breakout：價格突破回看高低點、通道、區間或價位
- retest：突破後回測／回踩後確認
- band_revert：觸及或超出通道／區間後回歸（均值回歸式）
- divergence：價格與指標背離
- candle：K 線型態（吞噬、pin bar、內包、連續 K 棒顏色等）
- sequence：連續 N 根條件或遞增遞減序列
- sweep：掃過流動性高低點後收回
- score：分數或投票達門檻
- state_flip：狀態或趨勢方向轉換
- price_touch：價格觸及固定計算價位（停損停利、目標價、掛單價）
- time：時間或時段、持倉根數
- level_grid：價格級距、DCA、網格加碼
- signal_ref：引用其他規則（反向訊號成立、進場條件反轉）
- none：無觸發（純計算）

## ind（多選）
ma, macd, rsi, stoch, stochrsi, cci, adx, atr, bb, kc, donchian, supertrend, psar, vwap, volume, obv, mfi, cmf, delta, ichimoku, alligator, ao, williams_r, roc, regression, stdev, swing, fib, pivot, session_range, sr_zone, orderblock, fvg, structure, candle, heikin_ashi, zscore, percentile, choppiness, vix_fix, wavetrend, hma, other, none

說明：ma＝任何均線（SMA／EMA／WMA／SMMA／TEMA／KAMA／ALMA 等；Hull 用 hma）；volume＝成交量本身及其均線；delta＝成交量差／CVD／多空量；swing＝擺動高低點、回看最高最低價；pivot＝樞軸點；session_range＝開盤區間／前日高低／時段高低；sr_zone＝支撐阻力區；structure＝BOS／CHoCH／市場結構；candle＝OHLC 型態與實體影線；regression＝線性回歸／LSMA；other＝清單外指標。

## flt（多選，附加濾網；無則 none）
trend_ma, htf, volume, volatility, adx, osc_range, session, cooldown, position, candle_color, rr_check, date_range, toggle, none

說明：trend_ma＝價格相對趨勢均線；htf＝較高週期條件；osc_range＝振盪器在區間內；session＝交易時段；cooldown＝平倉冷卻／訊號間隔；position＝持倉狀態（空倉才進）；candle_color＝收紅收黑；rr_check＝風險報酬或停損距離檢查；date_range＝日期／年份範圍；toggle＝該行含「若啟用」可開關條件。

## exit（多選，出場或風控機制；與出場無關填 none）
stop_fixed, stop_atr, stop_struct, tp_fixed, tp_atr, tp_rr, trailing, breakeven, partial, reverse_signal, indicator_exit, time_exit, bars_held, none

說明：stop_fixed／tp_fixed＝固定百分比或點數；stop_struct＝以擺動點、型態高低點、區間邊界為停損；tp_rr＝停損距離乘風險報酬比；reverse_signal＝反向進場訊號成立即出場；indicator_exit＝指標條件出場（交叉、跌破均線等）；time_exit＝時段或收盤前出場；bars_held＝持倉根數上限。

## intent（單選，該行在策略中的意圖）
trend, mean_revert, breakout, reversal, mixed, unknown

## mtf（單選）
yes：該行使用較高或較低週期資料；no：否
