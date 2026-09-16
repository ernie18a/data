<!-- tradingview-pine-id: PUB;df1e61d0bb2a4831846d46bcedd8a8f1 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# TradingFlow: Market Cycle MA (MCMA) v1.3.0

Source: https://www.tradingview.com/script/CDLoM61d-TF-Market-Cycle-MA-MCMA/

## Description

TradingFlow: Market Cycle MA (MCMA)

MCMA plots two moving averages of the same length on the price chart: an EMA and a Wilder RMA. These two averages smooth price at different rates, so their relative position tells you about the current trend direction and momentum at a chosen cycle length.

Switch the chart timeframe and you'll see the broader market regime at each level, from intraday cycles up to weekly and monthly trends. This helps you stay aligned with the dominant direction while filtering out short-term noise.

The cycle length comes from a standard market calendar: up to 5 minutes maps to a trading day, 6–15 minutes to a trading week, 16–65 minutes to a trading month, up to 24 hours to a quarter, and weekly and above to a year. You can also use shorter cycle fractions (75% or 50%) for faster response.

How It Works

EMA uses a smoothing factor of 2/(N+1), while Wilder RMA uses 1/N. With the same period N, the EMA responds roughly twice as fast as the RMA. This difference is the core signal:
• When price is trending upward, the faster EMA pulls above the slower RMA.
• When price is trending downward, the faster EMA drops below the slower RMA.
• When price is flat, both averages converge and the spread narrows.

In practice, this behaves like a fast/slow EMA crossover system where the "slow" side is approximately twice the "fast" side's period, packed into a single setting.

How to Read the Chart

• Green line (thicker): EMA, the faster average.
• Fainter line (thinner): Wilder RMA, the slower average, same color family as the EMA but more transparent.
• Fill between lines: colored by the current trend regime. Green for bullish, red for bearish, gray for neutral.

The fill color changes as the regime shifts, giving you a continuous read on trend state.

Trend Classification

MCMA classifies each bar into one of three regimes based on multiple conditions:
• Bullish: EMA is above RMA, price is above RMA, EMA is rising, and RMA is not falling.
• Bearish: EMA is below RMA, price is below RMA, EMA is falling, and RMA is not rising.
• Neutral: Any other combination, such as small spread, flat slopes, or mixed price position.

You can raise the minimum EMA–RMA spread (in ATR units) to filter out low-confidence signals during choppy markets. A slope filter is also available to require the EMA to be moving decisively in the trend direction.

Important

MCMA is a trend-direction indicator. It does not predict reversals, generate entry signals, or measure volatility. The trend classification is a filtered interpretation of the two averages' relationship, not a confirmation of price action. Because both averages use the same nominal period, the EMA–RMA spread primarily reflects recent momentum rather than the full cycle's worth of data. For the best results, use MCMA as context alongside other tools rather than as a standalone signal.

---
TradingFlow: Market Cycle MA (MCMA)

MCMA 在價格圖上同時繪製兩條相同週期長度的均線：EMA 和 Wilder RMA。兩種均線對價格的平滑速率不同，因此它們之間的相對位置可以揭示市場在選定週期下的趨勢方向與動量狀態。

切換圖表時間框架，就能看到不同層級的市場狀態，從日內週期到週線和月線趨勢，幫助你在各個時間框架下識別主要趨勢方向，過濾掉短期雜訊。

週期長度來源於標準市場日曆：5m 及以下對應一個交易日，6–15m 對應一個交易週，16–65m 對應一個交易月，24h 及以下對應一個季度，週線以上對應一年。指標也支持較短的週期比例（75% 或 50%），以獲得更快的響應。

工作原理

EMA 使用 2/(N+1) 的平滑係數，Wilder RMA 使用 1/N。在相同週期 N 下，EMA 的響應速度大約是 RMA 的兩倍。這種差異就是核心訊號來源：
• 價格上漲時，較快的 EMA 會領先於較慢的 RMA。
• 價格下跌時，較快的 EMA 會落後於較慢的 RMA。
• 價格橫盤時，兩條均線趨於收斂，價差縮小。

實際上，這等於一個快/慢雙均線交叉系統，「慢」側的週期約為「快」側的兩倍，只是用單一設定就能實現。

如何閱讀圖表

• 綠色線（較粗）： EMA，較快的均線。
• 較淡的線（較細）： Wilder RMA，較慢的均線，與 EMA 同色系但透明度更高。
• 兩條線之間的填充區域： 顏色由當前趨勢狀態決定。綠色表示看漲，紅色表示看跌，灰色表示中性。

填充區域的顏色會隨趨勢狀態的變化而切換，提供持續的視覺趨勢讀取。

趨勢分類

MCMA 根據多個條件將每根 K 線分為三種狀態之一：
• 看漲： EMA 位於 RMA 上方，價格位於 RMA 上方，EMA 正在上升，且 RMA 未在下降。
• 看跌： EMA 位於 RMA 下方，價格位於 RMA 下方，EMA 正在下降，且 RMA 未在上升。
• 中性： 其他任何組合，例如價差較小、斜率平坦或價格位置不一致。

可調高最小 EMA–RMA 價差（以 ATR 為單位）來過濾震盪市中的低置信度訊號。還可使用斜率過濾器，要求 EMA 在趨勢方向上明確運動。

重要說明

MCMA 是一個趨勢方向指標。它不預測反轉、不生成進場訊號、也不衡量波動率。趨勢分類是對兩條均線關係的過濾解釋，而非價格行為的確認。由於兩條均線使用相同的名義週期，EMA–RMA 價差主要反映近期動量，而非完整週期的數據。為獲得更好的效果，建議將 MCMA 作為輔助背景工具，與其他分析方法配合使用，而非作為獨立訊號。

---
TradingFlow: Market Cycle MA (MCMA)

MCMAは、価格チャートに同じ期間の2本の移動平均線をプロットします。1本はEMA、もう1本はウィルダーRMAです。2本の線は異なる速度で値動きを平滑化するため、互いの位置関係から選択したサイクルにおけるトレンドの方向とモメンタムを読み取ることができます。

チャートのタイムフレームを切り替えれば、日中の短いサイクルから週足・月足のトレンドまで、各レベルでの市場のレジームを把握できます。主たる方向感覚を保ちつつ、短期的なノイズを排除するのに役立ちます。

サイクルの長さは標準的な市場カレンダーから算出されます。5分足以下は1営業日、6〜15分足は1営業週、16〜65分足は1営業月、24時間以下は四半期、週足以上は1年に対応します。より短いサイクル割合（75% or 50%）を選択すると、応答が速くなります。

仕組み

EMAの平滑化係数は2/(N+1)、ウィルダーRMAは1/Nです。同じ期間Nでも、EMAはRMAのおよそ2倍の速さで反応します。この差がシグナルの核となります。

• 価格が上昇トレンドにあるとき、速いEMAは遅いRMAの上に位置します。
• 価格が下降トレンドにあるとき、速いEMAは遅いRMAの下に位置します。
• 価格がレンジで推移するとき、2本の線は収束し、スプレッドは狭まります。

実質的にこれは、速いEMAと遅いEMAのクロスオーバーシステムと同じ動作をします。「遅い」側の期間が「速い」側の約2倍に相当し、1つの設定で実現しています。

チャートの見方

• 緑の線（太い方）： EMA。速い方の移動平均です。
• 薄い色の線（細い方）： ウィルダーRMA。遅い方の移動平均で、EMAと同じ色系統ですが透過率が高くなっています。
• 2本の線の間の塗りつぶし： 現在のトレンドレジームに応じて色が変わります。強気なら緑、弱気なら赤、中立ならグレーです。

レジームが切り替わると塗りつぶしの色も変わり、トレンドの状態を視覚的に把握できます。

トレンド分類

MCMAは複数の条件に基づき、各足を3つのレジームのいずれかに分類します。

• 強気： EMAがRMAの上、終値がRMAの上、EMAが上昇中、RMAが下降していない。
• 弱気： EMAがRMAの下、終値がRMAの下、EMAが下降中、RMAが上昇していない。
• 中立： 上記以外のすべての組み合わせ。スプレッドが小さい、傾きがフラット、価格の位置が混在する場合など。

EMA−RMAスプレッド（ATR単位）の最小値を上げれば、もみ合い相場での偽シグナルをフィルタリングできます。傾きフィルタを使えば、EMAがトレンド方向に明確に動いていることを条件として設定できます。

注意事項

MCMAはトレンド方向を示す指標です。反転の予測、エントリーシグナルの生成、ボラティリティの測定を行いません。トレンド分類は2本の移動平均の関係をフィルタリングして解釈したものであり、価格行動の確認ではありません。両方の平均が同じ名目の期間を使用しているため、EMA−RMAスプレッドはサイクル全体のデータよりも直近のモメンタムを反映します。より効果的に使うには、MCMA単体ではなく他のツールと併用して背景情報として活用してください。

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © realanthonyc https://www.tradingview.com/u/realanthonyc

//@version=6
// -----------------------------------------------------------------------------
// TradingFlow: Market Cycle MA
//
// Same-period EMA + Wilder RMA for market-cycle trend context.
//
// QUICK REFERENCE
//
//   Chart        Auto cycle        US RTH (390m)         US ETH (960m)
//   ----------   ---------------   -------------------   --------------------
//   3m / 5m      1 trading day     Exact                 Exact
//   15m          1 trading week    Exact                 Exact
//   1h           1 trading month   Approx.; prefer 65m   Exact
//   2h           1 quarter         Approx.; prefer 130m  Exact
//   D            1 quarter         Exact                 ETH not applicable
//   1W           1 year            Exact                 ETH not applicable
//   2D / 21D     1 year            Calendar approx.      ETH not applicable
//
//   RESPONSE PROFILE   COVERAGE    INTERPRETATION
//   ----------------   --------    -------------------------------------------
//   Full Cycle         100%        Core concept; default
//   Responsive         75%         Balanced earlier response
//   Fast               50%         Half-cycle context; more whipsaw
//   Custom             50%-100%    Same coverage applied to EMA and RMA
//
//   TREND STATE    REQUIRED CONDITIONS
//   ------------   -----------------------------------------------------------
//   Bullish        EMA > RMA; source > RMA; EMA rising; RMA not falling
//   Bearish        EMA < RMA; source < RMA; EMA falling; RMA not rising
//   Neutral        Small spread, flat/conflicting slopes, or mixed price
//
// NOTES
//   1. Uneven intraday sessions count the final partial bar and are flagged.
//   2. The session input must match the chart's displayed RTH/ETH data.
//   3. Auto session detection supports US equities, crypto, and forex only.
//   4. Futures/non-US instruments require a matching Custom session length.
//   5. Custom mode cannot detect split-session breaks; verify them manually.
//   6. Multi-day charts use calendar aggregation, so cycles are approximate.
//   7. Crypto uses 7/30.44/91.31/365.25-day calendar cycle equivalents.
//   8. Trend states add spread/slope filters to the core concept.
//   9. Use standard, time-based charts only; synthetic charts are rejected.
//  10. Response profiles shorten both averages equally.
// -----------------------------------------------------------------------------
indicator("TradingFlow: Market Cycle MA (MCMA) v1.3.0", "TF: MCMA", overlay = true)

// =============================================================
// Inputs
// =============================================================

string GP_VISUAL = "Visuals"
string GP_RESPONSE = "Responsiveness"
string GP_CYCLE = "Market Cycle"
string GP_REGIME = "Trend Classification"

bool showRibbonInput = input.bool(true, "Fill Between Averages", group = GP_VISUAL)
bool showTableInput = input.bool(false, "Show Status Table", group = GP_VISUAL)
bool waitForCloseInput = input.bool(
     true,
     "Confirm Real-Time Trend Changes at Bar Close",
     group = GP_VISUAL,
     tooltip = "When enabled, line colors, the status table, and alerts keep the last confirmed regime until the current bar closes."
 )
color bullColorInput = input.color(color.rgb(92, 202, 152), "Bullish", group = GP_VISUAL, inline = "regimeColors")
color bearColorInput = input.color(color.rgb(242, 138, 146), "Bearish", group = GP_VISUAL, inline = "regimeColors")
color neutralColorInput = input.color(color.rgb(190, 197, 222), "Neutral", group = GP_VISUAL, inline = "regimeColors")

string responseProfileInput = input.string(
     "Full Cycle (100%)",
     "Response Profile",
     options = ["Full Cycle (100%)", "Responsive (75%)", "Fast (50%)", "Custom"],
     group = GP_RESPONSE,
     tooltip = "Full Cycle preserves the complete market-cycle lookback. Responsive and Fast intentionally measure 75% or 50% of that normalized cycle. Both EMA and Wilder RMA always use the same adjusted length."
 )
float customCycleCoverageInput = input.float(
     75.0,
     "Custom Cycle Coverage (%)",
     minval = 25.0,
     maxval = 100.0,
     step = 5.0,
     group = GP_RESPONSE,
     tooltip = "Percentage of the normalized market cycle used by both averages. Lower values react faster but represent less of the named cycle."
 )

string cycleInput = input.string(
     "Auto by Chart",
     "Target Cycle",
     options = ["Auto by Chart", "1 Trading Day", "1 Trading Week", "1 Trading Month", "1 Quarter", "1 Year", "Custom Trading Days"],
     group = GP_CYCLE,
     tooltip = "Auto by Chart: Day on charts up to 5m, week up to 15m, month up to 65m, quarter up to daily, and year above daily. For 24/7 crypto, longer cycles use calendar equivalents."
 )
float customTradingDays = input.float(
     10.0,
     "Custom Trading Days",
     minval = 0.1,
     maxval = 1000.0,
     step = 0.5,
     group = GP_CYCLE,
     active = cycleInput == "Custom Trading Days"
 )
string sessionModeInput = input.string(
     "Auto by Symbol",
     "Intraday Session Length",
     options = ["Auto by Symbol", "US Regular (390m)", "US Extended (960m)", "24 Hours (1440m)", "Custom"],
     group = GP_CYCLE,
     tooltip = "Used only on intraday charts. This setting does not change the chart's bars, so it must match the chart's displayed session. Auto supports US equities, crypto, and forex. Futures and non-US exchanges require Custom."
 )
float customSessionMinutes = input.float(
     390.0,
     "Custom Session Minutes",
     minval = 1.0,
     maxval = 1440.0,
     step = 1.0,
     group = GP_CYCLE,
     active = sessionModeInput == "Custom",
     tooltip = "Total active minutes in the chart session. For split sessions, prefer chart intervals that divide every segment evenly; Pine cannot infer the segment breaks from this value alone."
 )
float sourceInput = input.source(close, "Source", group = GP_CYCLE)

int atrLengthInput = input.int(14, "ATR Length", minval = 2, maxval = 200, group = GP_REGIME)
int slopeLookbackInput = input.int(3, "Slope Lookback", minval = 1, maxval = 50, group = GP_REGIME)
float minSpreadAtrInput = input.float(
     0.05,
     "Minimum EMA-RMA Spread (ATR)",
     minval = 0.0,
     maxval = 2.0,
     step = 0.01,
     group = GP_REGIME,
     tooltip = "Filtered regime enhancement: treats very small EMA-RMA separations as neutral to reduce whipsaw. Set to zero to remove the separation filter."
 )
float minSlopeAtrInput = input.float(
     0.0,
     "Minimum EMA Slope (ATR)",
     minval = 0.0,
     maxval = 2.0,
     step = 0.01,
     group = GP_REGIME,
     tooltip = "Minimum absolute EMA change over the slope lookback. Zero requires only that the EMA is moving in the trend direction."
 )

// =============================================================
// Cycle and timeframe normalization
// =============================================================

float chartSeconds = timeframe.in_seconds()
bool timeBasedChart = not na(chartSeconds) and chartSeconds > 0.0

if barstate.isfirst and not chart.is_standard
    runtime.error("Market Cycle MA requires a standard chart. Heikin-Ashi, Renko, Range, Kagi, Line Break, and Point & Figure bars do not provide suitable market-cycle price observations.")
if barstate.isfirst and not timeBasedChart
    runtime.error("Market Cycle MA requires a time-based chart. Tick and other non-time-based charts cannot represent calendar market cycles reliably.")

string autoCycle = chartSeconds <= 5.0 * 60.0 ? "1 Trading Day" :
     chartSeconds <= 15.0 * 60.0 ? "1 Trading Week" :
     chartSeconds <= 65.0 * 60.0 ? "1 Trading Month" :
     chartSeconds <= 24.0 * 60.0 * 60.0 ? "1 Quarter" :
     "1 Year"
string selectedCycle = cycleInput == "Auto by Chart" ? autoCycle : cycleInput
float cycleCoveragePct = switch responseProfileInput
    "Responsive (75%)" => 75.0
    "Fast (50%)"       => 50.0
    "Custom"           => customCycleCoverageInput
    => 100.0
float cycleCoverageFactor = cycleCoveragePct / 100.0
bool fractionalCycle = cycleCoveragePct < 99.9999

bool cryptoMarket = syminfo.type == "crypto"
bool cryptoOrForex = cryptoMarket or syminfo.type == "forex"
bool equityLike = syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "dr" or syminfo.type == "index"
bool knownUsExchange = str.startswith(syminfo.prefix, "NASDAQ") or str.startswith(syminfo.prefix, "NYSE") or
     str.startswith(syminfo.prefix, "AMEX") or str.startswith(syminfo.prefix, "ARCA") or
     str.startswith(syminfo.prefix, "BATS") or str.startswith(syminfo.prefix, "CBOE")
bool knownUsEquity = equityLike and knownUsExchange

// Crypto has no non-trading weekends, so its active-day counts use equivalent calendar periods instead.
float cycleActiveDays = switch selectedCycle
    "1 Trading Day"   => 1.0
    "1 Trading Week"  => cryptoMarket ? 7.0 : 5.0
    "1 Trading Month" => cryptoMarket ? 365.25 / 12.0 : 21.0
    "1 Quarter"       => cryptoMarket ? 365.25 / 4.0 : 63.0
    "1 Year"          => cryptoMarket ? 365.25 : 252.0
    => customTradingDays

// Weekly or monthly conversions use calendar-market conventions.
// This preserves 52-week and 12-month one-year averages instead of approximating them as 252/5 weeks or 252/21 months.
float cycleCalendarDays = switch selectedCycle
    "1 Trading Day"   => 1.0
    "1 Trading Week"  => 7.0
    "1 Trading Month" => 365.25 / 12.0
    "1 Quarter"       => 365.25 / 4.0
    "1 Year"          => 365.25
    => cryptoMarket ? customTradingDays : customTradingDays * 365.25 / 252.0
float cycleWeeks = cryptoMarket ? cycleCalendarDays / 7.0 : selectedCycle == "1 Year" ? 52.0 : cycleActiveDays / 5.0
float cycleMonths = cryptoMarket ? cycleCalendarDays / (365.25 / 12.0) : selectedCycle == "1 Year" ? 12.0 : cycleActiveDays / 21.0

bool chartUsesExtendedHours = knownUsEquity and syminfo.session == session.extended
bool customSessionRequired = not cryptoOrForex and not knownUsEquity
bool invalidUsSessionChoice = knownUsEquity and (
     sessionModeInput == "24 Hours (1440m)" or
     (sessionModeInput == "US Regular (390m)" and chartUsesExtendedHours) or
     (sessionModeInput == "US Extended (960m)" and not chartUsesExtendedHours)
 )
bool invalidContinuousMarketChoice = cryptoOrForex and (
     sessionModeInput == "US Regular (390m)" or sessionModeInput == "US Extended (960m)"
 )

if barstate.isfirst and timeframe.isintraday and customSessionRequired and sessionModeInput != "Custom"
    runtime.error("Auto/fixed session presets are not reliable for this instrument. Select Custom and enter the active chart session's total trading minutes.")
if barstate.isfirst and timeframe.isintraday and invalidUsSessionChoice
    runtime.error("The selected session length does not match the US equity session displayed by the chart. Change the chart session or the indicator setting.")
if barstate.isfirst and timeframe.isintraday and invalidContinuousMarketChoice
    runtime.error("US equity session presets are not valid for crypto/forex. Use Auto by Symbol, 24 Hours, or Custom.")

float automaticSessionMinutes = cryptoOrForex ? 1440.0 :
     knownUsEquity and chartUsesExtendedHours ? 960.0 :
     knownUsEquity ? 390.0 : na
float sessionMinutes = switch sessionModeInput
    "US Regular (390m)"  => 390.0
    "US Extended (960m)" => 960.0
    "24 Hours (1440m)"   => 1440.0
    "Custom"             => customSessionMinutes
    => automaticSessionMinutes

float nominalBarsPerSession = timeframe.isintraday ? sessionMinutes * 60.0 / chartSeconds : na
float effectiveBarsPerSession = timeframe.isintraday ? math.ceil(nominalBarsPerSession - 0.0000001) : na

float baseRawLength = if timeframe.isintraday
    cycleActiveDays * effectiveBarsPerSession
else if timeframe.isdaily
    timeframe.multiplier == 1 ? cycleActiveDays : cycleCalendarDays / timeframe.multiplier
else if timeframe.isweekly
    cycleWeeks / timeframe.multiplier
else if timeframe.ismonthly
    cycleMonths / timeframe.multiplier
else
    na

if barstate.isfirst and (na(baseRawLength) or baseRawLength <= 0.0)
    runtime.error("The selected chart timeframe cannot be converted into a market-cycle lookback.")

float adjustedRawLength = baseRawLength * cycleCoverageFactor
int maLength = math.max(1, int(math.round(adjustedRawLength)))
float representationErrorPct = adjustedRawLength > 0.0 ? math.abs(maLength - adjustedRawLength) / adjustedRawLength * 100.0 : na
bool cycleUnderResolved = adjustedRawLength < 1.0
bool noSmoothingPossible = maLength == 1
bool multiDayCalendarApproximation = timeframe.isdaily and timeframe.multiplier > 1
bool cryptoCalendarApproximation = cryptoMarket and (selectedCycle == "1 Trading Month" or selectedCycle == "1 Quarter" or selectedCycle == "1 Year")
bool customSessionNeedsVerification = timeframe.isintraday and sessionModeInput == "Custom"
bool sessionMisaligned = timeframe.isintraday and math.abs(nominalBarsPerSession - math.round(nominalBarsPerSession)) > 0.0001
bool nearExactConversion = representationErrorPct > 0.0001 and representationErrorPct < 0.5

// =============================================================
// Same-period EMA and Wilder RMA
// =============================================================

float cycleEma = ta.ema(sourceInput, maLength)
float cycleRma = ta.rma(sourceInput, maLength)

float atrRaw = ta.atr(atrLengthInput)
float atrSafe = math.max(nz(atrRaw, syminfo.mintick), syminfo.mintick)
float spreadAtr = math.abs(cycleEma - cycleRma) / atrSafe
float emaSlopeAtr = (cycleEma - cycleEma[slopeLookbackInput]) / atrSafe
float rmaSlopeAtr = (cycleRma - cycleRma[slopeLookbackInput]) / atrSafe

int loadedBars = bar_index + 1
int requiredBars = math.max(atrLengthInput, maLength + slopeLookbackInput)
bool sufficientLoadedHistory = loadedBars >= requiredBars
bool averagesReady = not noSmoothingPossible and sufficientLoadedHistory and not na(atrRaw) and
     not na(cycleEma) and not na(cycleRma) and not na(emaSlopeAtr) and not na(rmaSlopeAtr)
bool separationReady = spreadAtr >= minSpreadAtrInput
bool bullishRegime = averagesReady and separationReady and cycleEma > cycleRma and sourceInput > cycleRma and emaSlopeAtr > minSlopeAtrInput and rmaSlopeAtr >= 0.0
bool bearishRegime = averagesReady and separationReady and cycleEma < cycleRma and sourceInput < cycleRma and emaSlopeAtr < -minSlopeAtrInput and rmaSlopeAtr <= 0.0
int regime = bullishRegime ? 1 : bearishRegime ? -1 : 0

int priorRegime = nz(regime[1], 0)
int displayedRegime = waitForCloseInput and not barstate.isconfirmed ? priorRegime : regime
bool confirmationReady = not waitForCloseInput or barstate.isconfirmed
bool bullishTrendStart = confirmationReady and regime == 1 and priorRegime != 1
bool bearishTrendStart = confirmationReady and regime == -1 and priorRegime != -1

// =============================================================
// Visual output
// =============================================================

color regimeColor = displayedRegime == 1 ? bullColorInput : displayedRegime == -1 ? bearColorInput : neutralColorInput
color emaColor = color.new(regimeColor, 10)
color rmaColor = color.new(regimeColor, 45)

cycleEmaPlot = plot(cycleEma, "Cycle EMA", color = emaColor, linewidth = 2)
cycleRmaPlot = plot(cycleRma, "Cycle Wilder RMA", color = rmaColor, linewidth = 1)
fill(cycleEmaPlot, cycleRmaPlot, title = "Cycle Trend Ribbon", color = showRibbonInput ? color.new(regimeColor, 90) : na)

// =============================================================
// Last-bar status only; negligible runtime cost
// =============================================================

f_regimeText(_regime, _ready, _noSmoothing, _loaded, _required) =>
    _noSmoothing ? "Unavailable: length 1" :
     _loaded < _required ? "Need " + str.tostring(_required) + " bars; " + str.tostring(_loaded) + " loaded" :
     not _ready ? "Warming up" :
     _regime == 1 ? "Bullish" : _regime == -1 ? "Bearish" : "Neutral / Range"

f_regimeBackground(_regime, _ready) =>
    not _ready ? color.rgb(255, 245, 222) :
     _regime == 1 ? color.rgb(226, 246, 237) :
     _regime == -1 ? color.rgb(253, 233, 233) :
     color.rgb(240, 242, 245)

string precisionText = cycleUnderResolved ? "Cycle shorter than one chart bar" :
     noSmoothingPossible ? "Unavailable: one chart bar cannot be smoothed" :
     multiDayCalendarApproximation ? "Approximate: multi-day calendar bars" :
     cryptoCalendarApproximation ? "Approximate: average calendar cycle" :
     customSessionNeedsVerification and sessionMisaligned ? "Custom: verify breaks; partial session bar" :
     customSessionNeedsVerification ? "Custom: verify session breaks/alignment" :
     sessionMisaligned ? "Approximate: partial end-of-session bar" :
     representationErrorPct >= 0.5 ? "Approximate: " + str.tostring(representationErrorPct, "#.##") + "% rounding" :
     nearExactConversion ? "Near exact: " + str.tostring(representationErrorPct, "#.###") + "% rounding" :
     fractionalCycle ? str.tostring(cycleCoveragePct, "#") + "% cycle: Exact" :
     "Exact"
bool approximateConversion = cycleUnderResolved or noSmoothingPossible or multiDayCalendarApproximation or cryptoCalendarApproximation or customSessionNeedsVerification or sessionMisaligned or representationErrorPct >= 0.5
string cycleText = selectedCycle + (fractionalCycle ? " × " + str.tostring(cycleCoveragePct, "#") + "%" : "")
string lengthText = str.tostring(maLength)
string automaticSessionText = knownUsEquity ? (chartUsesExtendedHours ? "960 min (ETH, Auto)" : "390 min (RTH, Auto)") :
     cryptoMarket ? "1440 min (24/7, Auto)" :
     syminfo.type == "forex" ? "1440 min (24h, Auto)" :
     "Unavailable"
string sessionText = if not timeframe.isintraday
    "N/A"
else
    switch sessionModeInput
        "US Regular (390m)"  => "390 min (RTH)"
        "US Extended (960m)" => "960 min (ETH)"
        "24 Hours (1440m)"   => "1440 min (24h)"
        "Custom"             => str.tostring(sessionMinutes, "#") + " min (Custom)"
        => automaticSessionText
color tableHeaderBackground = color.rgb(225, 228, 234)
color tableHeaderText = color.rgb(35, 38, 45)
color tableBodyBackground = color.rgb(247, 248, 250)
color tableBodyText = color.rgb(45, 48, 55)
color tableNearExactText = color.rgb(70, 95, 145)
color tableWarningText = color.rgb(180, 105, 0)

var table statusTable = table.new(
     position.top_right,
     2,
     5,
     border_width = 1,
     border_color = color.new(chart.fg_color, 35),
     frame_width = 1,
     frame_color = color.new(chart.fg_color, 15)
 )

if showTableInput and barstate.islast
    table.cell(statusTable, 0, 0, "Cycle", bgcolor = tableHeaderBackground, text_color = tableHeaderText, text_size = size.tiny)
    table.cell(statusTable, 1, 0, cycleText, bgcolor = tableHeaderBackground, text_color = tableHeaderText, text_size = size.tiny)
    table.cell(statusTable, 0, 1, "Length", bgcolor = tableBodyBackground, text_color = tableBodyText, text_size = size.tiny)
    table.cell(statusTable, 1, 1, lengthText, bgcolor = tableBodyBackground, text_color = tableBodyText, text_size = size.tiny)
    table.cell(statusTable, 0, 2, "Regime", bgcolor = tableBodyBackground, text_color = tableBodyText, text_size = size.tiny)
    table.cell(statusTable, 1, 2, f_regimeText(displayedRegime, averagesReady, noSmoothingPossible, loadedBars, requiredBars), bgcolor = f_regimeBackground(displayedRegime, averagesReady), text_color = tableBodyText, text_size = size.tiny)
    table.cell(statusTable, 0, 3, "Conversion", bgcolor = tableBodyBackground, text_color = tableBodyText, text_size = size.tiny)
    table.cell(statusTable, 1, 3, precisionText, bgcolor = tableBodyBackground, text_color = approximateConversion ? tableWarningText : (nearExactConversion or fractionalCycle) ? tableNearExactText : tableBodyText, text_size = size.tiny)
    table.cell(statusTable, 0, 4, "Intraday session", bgcolor = tableBodyBackground, text_color = tableBodyText, text_size = size.tiny)
    table.cell(statusTable, 1, 4, sessionText, bgcolor = tableBodyBackground, text_color = tableBodyText, text_size = size.tiny)
else if not showTableInput and barstate.islast
    table.clear(statusTable, 0, 0, 1, 4)

// =============================================================
// Alerts
// =============================================================

alertcondition(bullishTrendStart, "Bullish Cycle Trend Start", "The market cycle changed to bullish.")
alertcondition(bearishTrendStart, "Bearish Cycle Trend Start", "The market cycle changed to bearish.")
````
