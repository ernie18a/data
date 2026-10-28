# TF: Torque Flow Oscillator (TFO)

- url: https://www.tradingview.com/script/qxNq0VPU-TF-Torque-Flow-Oscillator-TFO/
- type: indicator
- pine_id: PUB;4fdaa5c51c3b4eefa94cbe6f32381cf1
- version: 3.0

## Description

[b]TradingFlow: Torque Flow Oscillator (TFO)[/b]

TFO shows whether recent candles are producing persistent upward or downward pressure. It combines candle bodies, upper and lower wick behavior, relative volume, and fading memory into one directional oscillator.

Its main value is simple: instead of judging one candle in isolation, TFO shows whether similar pressure has continued across several bars and whether that pressure is unusually strong compared with its own recent history.

[b]Quick Chart Guide[/b]

• [b]Teal columns above zero:[/b] Net upward pressure.
• [b]Red columns below zero:[/b] Net downward pressure.
• [b]Orange line:[/b] Smoothed TFO signal.
• [b]Upper extreme line:[/b] Threshold for unusually strong positive pressure.
• [b]Lower extreme line:[/b] Threshold for unusually strong negative pressure.
• [b]Light background:[/b] TFO has moved beyond a directional extreme line.

[b]How TFO Is Built[/b]

Each candle contributes three pieces of information:
• [b]Body direction:[/b] a bullish body adds positive pressure; a bearish body adds negative pressure.
• [b]Wick behavior:[/b] a lower wick means price traded lower and then recovered, so the model adds a positive contribution. An upper wick means price traded higher and then pulled back, so the model adds a negative contribution.
• [b]Relative volume:[/b] active candles receive more weight, while extreme volume is compressed so one bar cannot dominate the oscillator for too long.

Price geometry is normalized by the instrument's prior ATR, so readings are less dependent on price level or timeframe. Recent pressure is then accumulated with a gradually fading memory.

[b]How to Read the Columns[/b]

• TFO holding above zero means recent candle pressure is net positive.
• TFO holding below zero means recent candle pressure is net negative.
• Moving farther from zero means directional pressure is becoming larger in magnitude.
• Moving back toward zero means pressure is fading or becoming more balanced.

Column shade compares TFO with the previous bar. Dark teal means a rising positive reading; light teal means a falling positive reading. Dark red means a more negative reading; light red means a less negative reading.

The columns describe pressure within the observed candles. They do not guarantee the next price direction.

[b]Signal Line[/b]

The orange line is a smoother baseline for TFO:
• TFO moving above the signal means pressure has shifted upward relative to its smoothed baseline.
• TFO moving below the signal means pressure has shifted downward relative to its smoothed baseline.

Read signal-line changes together with the zero axis. A crossover is a change in pressure state, not an automatic trade signal.

[b]Directional Extreme Lines[/b]

The upper and lower lines are based on the recent percentile of absolute TFO readings. By default, they represent pressure magnitudes reached by only the strongest part of recent observations.

• Above the upper line means unusually strong positive pressure.
• Below the lower line means unusually strong negative pressure.

An extreme can indicate continuation, acceleration, panic, or exhaustion. It does not automatically mean overbought, oversold, or reversal.

[b]Practical Use[/b]

1. Use the zero axis to identify the current pressure direction.
2. Use the signal line to observe short-term changes in that pressure.
3. Use the extreme lines to recognize when pressure is unusually large.
4. Confirm all readings with price structure, support and resistance, and your own risk rules.

For realtime bars, TFO changes as the candle and volume develop. Use closed bars when confirmation matters.

[b]Important[/b]

TFO is an OHLCV-based candle-pressure model. It is not order flow, volume delta, or proof of institutional activity. It measures the current candle from open to close, so overnight gaps are not directly included in body direction. On symbols without volume data, TFO falls back to price geometry only. Standard candles and reliable traded volume provide the clearest interpretation.

---

[b]TradingFlow: Torque Flow Oscillator (TFO)[/b]

TFO 用來觀察近期 K 線是否持續產生向上或向下壓力。它把 K 線實體、上影線與下影線的形態、相對成交量，以及會逐漸消退的歷史影響，整合成一個方向性震盪指標。

它的主要價值很直接：不只判斷單獨一根 K 線，而是顯示相似方向的壓力是否持續了數根 K 線，以及目前壓力相對於近期是否異常強烈。

[b]快速讀圖[/b]

• [b]零軸上方的青綠色柱：[/b]整體壓力偏多。
• [b]零軸下方的紅色柱：[/b]整體壓力偏空。
• [b]橙色線：[/b]TFO 的平滑訊號線。
• [b]上方極值線：[/b]判斷正向壓力是否異常強烈的門檻。
• [b]下方極值線：[/b]判斷負向壓力是否異常強烈的門檻。
• [b]淡色背景：[/b]TFO 已超越其中一條方向極值線。

[b]TFO 如何形成[/b]

每根 K 線提供三部分資料：
• [b]實體方向：[/b]陽線增加正向壓力，陰線增加負向壓力。
• [b]影線形態：[/b]下影線表示價格曾經跌至較低位置，其後有所回升，因此模型計入正值；上影線表示價格曾經升至較高位置，其後有所回落，因此模型計入負值。
• [b]相對成交量：[/b]成交較活躍的 K 線獲得較高權重；極端成交量會被壓縮，避免單根 K 線長時間主導指標。

K 線幾何會使用該標的此前的 ATR 作標準化，降低股價水平與時間週期對讀數的影響。其後，近期壓力會透過逐漸衰減的記憶累積起來。

[b]如何閱讀柱狀圖[/b]

• TFO 持續位於零軸上方，表示近期 K 線的淨壓力偏多。
• TFO 持續位於零軸下方，表示近期 K 線的淨壓力偏空。
• 柱狀圖離零軸愈遠，代表方向壓力幅度愈大。
• 柱狀圖返回零軸，代表壓力正在減弱，或買賣力量變得較平衡。

柱色會把 TFO 與前一根 K 線比較：深青綠表示正值上升，淺青綠表示正值下降；深紅表示讀數變得更負，淺紅表示負值正在回升。

柱狀圖描述的是 K 線所反映的壓力，不保證價格下一步的方向。

[b]訊號線[/b]

橙色線是 TFO 的平滑比較基準：
• TFO 移至訊號線上方，表示壓力相對於平滑基準向上轉移。
• TFO 移至訊號線下方，表示壓力相對於平滑基準向下轉移。

訊號線應與零軸一起閱讀。交叉代表壓力狀態正在轉變，不是自動買賣訊號。

[b]方向極值線[/b]

上下兩條線根據近期 TFO 絕對值的百分位數計算。預設情況下，它們代表近期只有最強一部分讀數才會到達的壓力幅度。

• 超越上線，表示正向壓力異常強烈。
• 跌破下線，表示負向壓力異常強烈。

極值可能代表延續、加速、恐慌或衰竭，不等於超買、超賣或必然反轉。

[b]實際使用方法[/b]

1. 使用零軸判斷目前的壓力方向。
2. 使用訊號線觀察壓力的短期變化。
3. 使用極值線判斷壓力是否異常強烈。
4. 配合價格結構、支撐阻力及自己的風險規則作最終判斷。

實時 K 線尚未收盤時，TFO 會隨價格與成交量變化。需要確認時，應以已收盤 K 線為準。

[b]重要說明[/b]

TFO 是基於 OHLCV 的 K 線壓力模型，不是訂單流、Volume Delta 或機構活動證明。它以當前 K 線的開盤至收盤計算實體方向，因此不會直接把隔夜跳空計入實體方向。若標的沒有成交量資料，TFO 會只使用價格幾何。使用標準 K 線及具可靠實際成交量的標的，解讀會最清晰。

---

[b]TradingFlow: Torque Flow Oscillator (TFO)[/b]

TFOは、直近のローソク足に上方向または下方向への圧力が継続して表れているかを可視化する方向性オシレーターです。ローソク足の実体、上ヒゲ・下ヒゲの形状、相対出来高、そして時間とともに減衰する過去の影響を一つの指標にまとめています。

一つのローソク足だけを個別に評価するのではなく、同じ方向の圧力が複数の足にわたって続いているか、また現在の圧力が直近の推移と比べてどの程度強いかを確認できる点が、TFOの主な特徴です。

[b]チャートの見方[/b]

• [b]ゼロラインより上の青緑色の柱：[/b]上方向への圧力が優勢。
• [b]ゼロラインより下の赤色の柱：[/b]下方向への圧力が優勢。
• [b]オレンジ色のライン：[/b]TFOを平滑化したシグナルライン。
• [b]上側の極値ライン：[/b]上方向の圧力が異常に強いかを判断する基準。
• [b]下側の極値ライン：[/b]下方向の圧力が異常に強いかを判断する基準。
• [b]薄い背景色：[/b]TFOがいずれかの方向の極値ラインを超えた状態。

[b]TFOの仕組み[/b]

各ローソク足から、次の三つの要素を評価します。
• [b]実体の方向：[/b]陽線の実体はプラス方向、陰線の実体はマイナス方向に加算されます。
• [b]ヒゲの形状：[/b]下ヒゲは、いったん安値を付けた後に価格が戻した動きを示すため、モデルではプラス方向に加算されます。上ヒゲは、いったん高値を付けた後に価格が押し戻された動きを示すため、マイナス方向に加算されます。
• [b]相対出来高：[/b]出来高が通常より多いローソク足ほど重みが大きくなります。一方、極端な出来高は圧縮されるため、一つの足が長期間にわたって指標を支配しにくい設計です。

ローソク足の値幅は、その銘柄の直前までのATRで正規化されます。これにより、価格水準や時間軸の違いによる影響を抑えています。その後、直近の方向性圧力を、過去の影響が徐々に小さくなる形で蓄積します。

[b]柱状表示の読み方[/b]

• TFOがゼロラインより上で推移している場合、直近のローソク足に表れた圧力は全体として上向きです。
• TFOがゼロラインより下で推移している場合、直近のローソク足に表れた圧力は全体として下向きです。
• ゼロラインから離れるほど、方向性圧力の大きさが増しています。
• ゼロラインへ戻る動きは、圧力の弱まり、または買いと売りの力が均衡に近づいていることを示します。

柱の色の濃淡は、現在のTFOを一つ前の足と比較したものです。濃い青緑色はプラス値の上昇、薄い青緑色はプラス値の低下、濃い赤色はマイナス幅の拡大、薄い赤色はマイナス値がゼロへ戻る動きを示します。

柱状表示はローソク足から推定した圧力を表すものであり、次の価格方向を保証するものではありません。

[b]シグナルライン[/b]

オレンジ色のラインは、TFOを平滑化した比較基準です。
• TFOがシグナルラインを上回ると、圧力が平滑化された基準に対して上方向へ変化したことを示します。
• TFOがシグナルラインを下回ると、圧力が平滑化された基準に対して下方向へ変化したことを示します。

シグナルラインはゼロラインと併せて確認してください。交差は圧力状態の変化を示しますが、それ自体が自動的な売買シグナルになるわけではありません。

[b]方向性の極値ライン[/b]

上下の極値ラインは、直近のTFOの絶対値をパーセンタイルで評価して算出します。初期設定では、直近の観測値の中でも特に強い圧力だけが到達する水準を示します。

• TFOが上側のラインを超えると、上方向の圧力が通常より著しく強い状態です。
• TFOが下側のラインを下回ると、下方向の圧力が通常より著しく強い状態です。

極端な圧力は、トレンドの継続、加速、パニック的な値動き、または勢いの限界を示す可能性があります。極値への到達だけで、買われ過ぎ、売られ過ぎ、あるいは反転を意味するものではありません。

[b]実践的な使い方[/b]

1. ゼロラインで現在の圧力方向を確認します。
2. シグナルラインで圧力の短期的な変化を確認します。
3. 極値ラインで圧力が通常より大きいかを判断します。
4. 最終的な判断には、価格構造、サポート・レジスタンス、ご自身のリスク管理ルールを組み合わせてください。

リアルタイムのローソク足では、価格と出来高の変化に伴ってTFOも変動します。確認を重視する場合は、確定したローソク足の値を使用してください。

[b]重要事項[/b]

TFOはOHLCVデータに基づくローソク足圧力モデルです。オーダーフローや出来高デルタではなく、機関投資家の活動を直接示すものでもありません。実体の方向は当該ローソク足の始値から終値までで計算するため、前の足の終値からのギャップは直接反映されません。出来高データがない銘柄では、ローソク足の価格形状のみを使用します。通常のローソク足と信頼できる出来高データを持つ銘柄で、最も明確に解釈できます。

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © realanthonyc https://www.tradingview.com/u/realanthonyc

//@version=6
// -------------------------------------------------------------------------------
//  TradingFlow: Torque Flow Oscillator
// -------------------------------------------------------------------------------
indicator("TradingFlow: Torque Flow Oscillator (TFO) v3.1.8", shorttitle="TF: TFO", overlay=false, precision=1, max_bars_back=600)

// -------------------------------------
// Inputs
// -------------------------------------

group_geo  = "Geometry & Mass"
atr_len    = input.int(14, "ATR Length (Normalization)", minval=5, maxval=200, group=group_geo)
body_w     = input.float(1.0, "Body Force Weight", minval=0.1, step=0.1, group=group_geo)
wick_w     = input.float(1.3, "Wick Torque Weight", minval=0.1, step=0.1, group=group_geo)
vol_len    = input.int(20, "Relative Volume Length", minval=5, maxval=200, group=group_geo)

group_flow = "Flow Dynamics"
mem_len    = input.int(12, "Flow Memory Length", minval=3, maxval=100, group=group_flow, tooltip="Higher = longer memory / slower decay")
sig_len    = input.int(5, "Signal Smoothing", minval=1, maxval=50, group=group_flow)

group_lv   = "Dynamic Levels"
level_len  = input.int(80, "Extreme Lookback", minval=30, maxval=500, group=group_lv)
level_pct  = input.float(90.0, "Extreme Percentile", minval=70.0, maxval=99.0, step=1.0, group=group_lv, tooltip="Higher values identify rarer directional-pressure extremes")
show_fill  = input.bool(true, "Background on Extremes", group=group_lv)

// -------------------------------------
// Normalized Geometry (Dimensionless)
// -------------------------------------

// Use the completed prior-bar ATR so the current bar does not raise its own
// normalization baseline. A one-tick floor prevents unstable division after
// very quiet or zero-range periods. Until enough ATR history exists, output is na.
atr_value   = ta.atr(atr_len)
atr_base    = atr_value[1]
tick_floor  = syminfo.mintick > 0.0 ? syminfo.mintick : 1e-10
atr_safe    = not na(atr_base) ? math.max(atr_base, tick_floor) : na

body        = (close - open) / atr_safe
upper_wick  = (high - math.max(open, close)) / atr_safe
lower_wick  = (math.min(open, close) - low) / atr_safe

// Compare current participation with the prior rolling median. Median is less
// distorted by isolated volume spikes than an SMA. Square-root compression and
// a fixed cap prevent one exceptional print from dominating flow for many bars.
vol_base    = ta.median(volume[1], vol_len)
has_volume  = not na(volume) and volume > 0.0 and not na(vol_base) and vol_base > 0.0
rel_vol_raw = has_volume ? volume / vol_base : na
rel_vol     = has_volume ? math.max(0.25, math.min(rel_vol_raw, 4.0)) : na
// Symbols with no volume series fall back to price geometry. A genuine
// zero-volume bar contributes no new torque; a warming baseline remains na.
mass        = na(volume) ? 1.0 : has_volume ? math.sqrt(rel_vol) : volume == 0.0 ? 0.0 : na

// -------------------------------------
// Net Torque (The Core Idea)
// -------------------------------------

body_force  = body * body_w * mass
wick_torque = (lower_wick - upper_wick) * wick_w * mass
raw_torque  = body_force + wick_torque

// -------------------------------------
// Damped Flow
// -------------------------------------

// Scaling each new observation by (1 - damp) makes memory length control decay
// without mechanically increasing the oscillator's steady-state amplitude.
damp        = math.exp(-1.0 / mem_len)

var float flow = na
flow := not na(raw_torque) ? (na(flow[1]) ? raw_torque : damp * flow[1] + (1.0 - damp) * raw_torque) : flow[1]

// Gentle output smoothing preserves the directional zero line.
tfo         = ta.ema(flow, 3)
tfo_sig     = ta.ema(tfo, sig_len)

// -------------------------------------
// Dynamic Directional Extremes
// -------------------------------------

// TFO is directional and anchored at zero.
// A percentile of prior absolute TFO values therefore creates
// statistically coherent, symmetric magnitude levels.
extreme_level = ta.percentile_nearest_rank(math.abs(tfo[1]), level_len, level_pct)
upper_level   = extreme_level
lower_level   = -extreme_level

// Display the dimensionless model output as index points for easier reading.
// This changes only the visible scale; it is not a percentage or a bounded range.
display_scale = 100.0
tfo_index     = tfo * display_scale
signal_index  = tfo_sig * display_scale
upper_index   = upper_level * display_scale
lower_index   = lower_level * display_scale

// -------------------------------------
// Visuals
// -------------------------------------

// Hue communicates direction; shade communicates whether the positive/negative reading
// is rising or falling relative to the previous bar.
bull_strong = #32B8AD
bull_weak   = #79C9C2
bear_strong = #E56773
bear_weak   = #EBA2AA
bull_line   = #248D84
bear_line   = #C4515C
signal_col  = #F28A00
zero_col    = #8493a8AA

hist_col    = tfo >= 0.0 ? (tfo > tfo[1] ? bull_strong : bull_weak) :
              tfo > tfo[1] ? bear_weak : bear_strong
bg_col      = not na(upper_level) and tfo > upper_level ? #DCF1EE :
              not na(lower_level) and tfo < lower_level ? #F7E1E4 : na

plot(tfo_index,    "TFO Index", color=hist_col, style=plot.style_columns)
plot(signal_index, "Signal",    color=signal_col, linewidth=2)

hline(0, "Zero", color=zero_col, display=display.none)
plot(upper_index, "Positive Pressure Extreme", color=bull_line, linewidth=1)
plot(lower_index, "Negative Pressure Extreme", color=bear_line, linewidth=1)

bgcolor(show_fill ? bg_col : na)
````
