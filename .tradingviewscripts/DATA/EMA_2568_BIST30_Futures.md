<!-- tradingview-pine-id: PUB;118b22a980fe4a7faf7f417f3ef4bd61 -->
<!-- tradingviewscripts-format: 1 -->
# EMA 25/68 BIST30 Futures

Source: https://www.tradingview.com/script/Tbh1KPxq/

## Description

# EMA 25/68 BIST30 Futures

I developed this strategy to test a straightforward and easy-to-understand moving average system on the 15-minute chart of the BIST30 futures contract.

The system monitors crossovers between EMA 25 and EMA 68. A crossover alone is not sufficient to open a position. For a long setup, the highest price of the crossover candle is recorded. For a short setup, the lowest price of the crossover candle is recorded. The signal is confirmed only if price breaks this level within the following four bars. If confirmation does not occur within four bars, the setup is cancelled.

EMA 160 is used solely as a directional filter. Long positions are opened above EMA 160, while short positions are opened below EMA 160. The purpose of this filter is to avoid taking short- and medium-term moving average crossovers against the broader market trend.

If a position has not been stopped out before the end of the session, it is closed at the close of the 17:45 bar, which corresponds to the 18:00 session price. A new position, including one in the opposite direction, cannot be opened on the same bar in which an existing position is closed.

The strategy has been designed so that different parameter settings can be tested for educational and research purposes. Users can change the EMA lengths, the number of confirmation bars, the directional filter and the trailing stop percentage to examine how these variables affect the number of trades, win rate, profit factor and maximum drawdown.

When evaluating parameter changes, users should not focus solely on the highest net profit. It is also important to examine whether neighbouring parameter values produce similar results and whether performance remains consistent across different market periods.

The code avoids calculation methods that could introduce look-ahead bias. The entire entry bar is not treated as price movement that occurred after the position was opened. The trailing stop is calculated using data from a completed bar and becomes active no earlier than the following bar.

Commission and tax on commission are displayed as separate settings. By default, the strategy assumes a commission rate of 0.020% per order leg and a 5% tax applied to the commission. Together, these produce an effective cost of 0.021% per order leg.

If the commission or tax settings are changed, the effective cost per order leg displayed in the table at the top-right corner of the chart must also be entered under Strategy Settings → Properties → Commission.

The strategy was developed for the XU030D1! symbol on a 15-minute chart. Similar results should not be expected on different markets or timeframes. The data source, continuous contract settings, commission, slippage and Bar Magnifier preferences may all affect backtest results.

This strategy is shared for educational and research purposes only. Past performance does not guarantee similar results in the future and should not be used as the sole basis for making investment decisions.

EMA 25/68 BİST30 VADELİ

Bu stratejiyi BIST30 vadeli kontratın 15 dakikalık grafiğinde, mümkün olduğunca sade ve anlaşılır bir hareketli ortalama sistemi denemek için hazırladım.

Sistem EMA 25 ile EMA 68’in kesişmesini takip ediyor. Kesişim tek başına işlem açmak için yeterli değil. Long tarafta cross mumunun en yüksek, short tarafta ise en düşük fiyatı kaydediliyor. Fiyatın bu seviyeyi sonraki dört bar içinde geçmesi halinde sinyal teyit edilmiş sayılıyor. Dört bar içinde teyit gelmezse aday iptal ediliyor.

EMA 160 yalnızca yön filtresi olarak kullanılıyor. Long işlemler EMA 160’ın üzerinde, short işlemler EMA 160’ın altında açılıyor. Amaç, kısa ve orta vadeli ortalama kesişimlerini daha geniş trendin tersine kullanmamak.

Pozisyon seans sonuna kadar stop olmadıysa 17:45 barının kapanışında, yani 18:00 seans fiyatında kapatılır. Pozisyonun kapandığı bar içinde ters yönde yeni pozisyon açılmaz.

Strateji, eğitim ve araştırma amacıyla farklı parametrelerin sonuçlar üzerindeki etkisini incelemeye uygun olacak şekilde ayarlanabilir hazırlanmıştır. EMA uzunlukları, teyit barı sayısı, yön filtresi ve trailing stop oranı değiştirilerek işlem sayısı, kazanma oranı, kâr faktörü ve maksimum düşüş gibi ölçümlerin nasıl değiştiği karşılaştırılabilir. Parametreler değerlendirilirken yalnızca en yüksek net kâra odaklanmak yerine, komşu değerlerde de benzer sonuçların oluşup oluşmadığı ve farklı dönemlerde performansın korunup korunmadığı ayrıca incelenmelidir.

Kodda geleceği görmeye yol açabilecek hesaplama seçenekleri kullanılmadı. Giriş barının tamamı, pozisyon açıldıktan sonra oluşmuş bir fiyat hareketi gibi kabul edilmez. Trail seviyesi tamamlanan barın verileriyle hesaplanır ve en erken sonraki barda çalışır.

Komisyon ve komisyon vergisi ayarlarda ayrı ayrı gösterilir. Varsayılan olarak bacak başına yüzde 0,020 komisyon ve komisyon üzerinden yüzde 5 vergi kabul edilmiştir. Bu ikisinin efektif bacak maliyeti yüzde 0,021’dir. TradingView’in yerleşik komisyon alanı Pine kodunda dinamik bir inputa bağlanamadığı için bu değer değiştirildiğinde, Strateji Ayarları > Özellikler bölümündeki komisyon oranının da tabloda gösterilen efektif oranla aynı yapılması gerekir.

Strateji XU030D1! üzerinde 15 dakikalık grafik için hazırlanmıştır. Farklı piyasalarda veya zaman aralıklarında aynı sonucu vermesi beklenmemelidir. Bar Magnifier kullanımı, veri kaynağı, sürekli vade ayarları, komisyon ve kayma tercihleri backtest sonuçlarını değiştirebilir.

Bu çalışma eğitim ve araştırma amacıyla paylaşılmıştır. Geçmiş performans gelecekte aynı sonucun alınacağını göstermez ve tek başına yatırım kararı için kullanılmamalıdır.

---

## Source Code

````pine
//@version=6
strategy(
     title                   = "EMA 25/68 BIST30 Futures",
     shorttitle              = "EMA 25/68 BIST30",
     overlay                 = true,
     pyramiding              = 0,
     initial_capital         = 10000000,
     default_qty_type        = strategy.fixed,
     default_qty_value       = 1,
     commission_type         = strategy.commission.percent,
     commission_value        = 0.021,
     slippage                = 4,
     calc_on_order_fills     = false,
     calc_on_every_tick      = false,
     process_orders_on_close = false
)

// ============================================================================
// EMA 25/68 BIST30 Futures
// Open-source version with a single tight trailing stop.
//
// Default transaction costs:
// - Commission per order leg: 0.020%
// - Tax on commission: 5%
// - Effective cost per order leg: 0.021%
//
// TradingView requires the Strategy Tester commission to be declared as a
// constant inside strategy(). The commission and tax inputs below calculate
// and display the effective cost selected by the user.
//
// When either input is changed, set Strategy Settings > Properties > Commission
// to the same "Effective cost per leg" value displayed in the information table.
// ============================================================================


// ─────────────────────────────────────────────────────────────────────────────
// INPUT GROUPS
// ─────────────────────────────────────────────────────────────────────────────
string GROUP_AVERAGES = "Moving Averages"
string GROUP_ENTRY    = "Entry and Session"
string GROUP_EXIT     = "Exit"
string GROUP_COSTS    = "Transaction Costs"
string GROUP_DISPLAY  = "Display"


// ─────────────────────────────────────────────────────────────────────────────
// USER INPUTS
// ─────────────────────────────────────────────────────────────────────────────
int fastEmaLength = input.int(
     25,
     "Fast EMA",
     minval = 1,
     group = GROUP_AVERAGES
)

int slowEmaLength = input.int(
     68,
     "Slow EMA",
     minval = 2,
     group = GROUP_AVERAGES
)

int trendEmaLength = input.int(
     160,
     "Trend filter EMA",
     minval = 2,
     group = GROUP_AVERAGES,
     tooltip = "Long entry prices must be above this EMA. Short entry prices must be below it."
)

int confirmationBars = input.int(
     4,
     "Maximum confirmation bars",
     minval = 1,
     maxval = 20,
     group = GROUP_ENTRY,
     tooltip = "The setup is cancelled if price does not break the crossover candle's high or low within this period."
)

int lastEntryHour = input.int(
     16,
     "Last entry hour",
     minval = 9,
     maxval = 17,
     inline = "lastEntry",
     group = GROUP_ENTRY
)

int lastEntryMinute = input.int(
     30,
     "Minute",
     minval = 0,
     maxval = 59,
     inline = "lastEntry",
     group = GROUP_ENTRY
)

int sessionExitHour = input.int(
     17,
     "Session exit bar",
     minval = 9,
     maxval = 23,
     inline = "sessionExit",
     group = GROUP_ENTRY
)

int sessionExitMinute = input.int(
     45,
     "Minute",
     minval = 0,
     maxval = 59,
     inline = "sessionExit",
     group = GROUP_ENTRY,
     tooltip = "On a 15-minute chart, the 17:45 bar closes at the 18:00 session price."
)

float tightTrailPercent = input.float(
     0.60,
     "Tight trailing stop (%)",
     minval = 0.05,
     step = 0.025,
     group = GROUP_EXIT
)

float commissionPercent = input.float(
     0.020,
     "Commission per order leg (%)",
     minval = 0.0,
     step = 0.001,
     group = GROUP_COSTS
)

float taxOnCommissionPercent = input.float(
     5.0,
     "Tax on commission (%)",
     minval = 0.0,
     step = 0.5,
     group = GROUP_COSTS
)

bool showEmaLines = input.bool(
     true,
     "Show EMA lines",
     group = GROUP_DISPLAY
)

bool showConfirmationLevel = input.bool(
     true,
     "Show pending confirmation level",
     group = GROUP_DISPLAY
)

bool showTrailingStop = input.bool(
     true,
     "Show active trailing stop",
     group = GROUP_DISPLAY
)

bool showInformationTable = input.bool(
     true,
     "Show information table",
     group = GROUP_DISPLAY
)


// ─────────────────────────────────────────────────────────────────────────────
// CORE CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────
float fastEma  = ta.ema(close, fastEmaLength)
float slowEma  = ta.ema(close, slowEmaLength)
float trendEma = ta.ema(close, trendEmaLength)

bool bullishCross = ta.crossover(fastEma, slowEma)
bool bearishCross = ta.crossunder(fastEma, slowEma)

int currentMinuteOfDay = hour * 60 + minute
int lastEntryMinuteOfDay = lastEntryHour * 60 + lastEntryMinute
int sessionExitMinuteOfDay = sessionExitHour * 60 + sessionExitMinute

bool isFifteenMinuteChart =
     timeframe.isminutes and timeframe.multiplier == 15

// Orders are submitted after the bar closes and become active on the next bar.
// Therefore, no new order is submitted on the last permitted entry bar itself.
// For example, an order submitted after the 16:15 close can fill on the 16:30 bar.
bool nextBarEntryAllowed =
     isFifteenMinuteChart and
     currentMinuteOfDay >= 9 * 60 + 30 and
     currentMinuteOfDay < lastEntryMinuteOfDay

bool isSessionExitBar =
     currentMinuteOfDay == sessionExitMinuteOfDay

float effectiveCostPerLegPercent =
     commissionPercent * (1.0 + taxOnCommissionPercent / 100.0)

float effectiveCostPerLegRate =
     effectiveCostPerLegPercent / 100.0

float roundTripBreakEvenMultiplier =
     effectiveCostPerLegRate < 1.0
     ? (1.0 + effectiveCostPerLegRate) / (1.0 - effectiveCostPerLegRate)
     : na

// Fixed effective commission used by Strategy Tester with the default inputs.
float TESTER_DEFAULT_COMMISSION_PERCENT = 0.021

bool testerCommissionNeedsUpdate =
     math.abs(
          effectiveCostPerLegPercent - TESTER_DEFAULT_COMMISSION_PERCENT
     ) > 0.000001


// ─────────────────────────────────────────────────────────────────────────────
// PENDING CROSS SETUP
// ─────────────────────────────────────────────────────────────────────────────
var int setupDirection = 0
var float setupLevel = na
var int setupCrossBarIndex = na

bool newLongPosition =
     strategy.position_size > 0 and strategy.position_size[1] <= 0

bool newShortPosition =
     strategy.position_size < 0 and strategy.position_size[1] >= 0

bool positionClosedOnThisBar =
     strategy.position_size == 0 and strategy.position_size[1] != 0

bool isFlat =
     strategy.position_size == 0

// Remove any pending entries when a position opens or closes.
if strategy.position_size != 0 or positionClosedOnThisBar
    strategy.cancel("Long")
    strategy.cancel("Short")

    setupDirection     := 0
    setupLevel         := na
    setupCrossBarIndex := na


// ─────────────────────────────────────────────────────────────────────────────
// SINGLE TIGHT TRAILING STOP
// ─────────────────────────────────────────────────────────────────────────────
var float activeTrailingStop = na
var float highestPriceSinceEntry = na
var float lowestPriceSinceEntry = na

float trailRate =
     tightTrailPercent / 100.0

if newLongPosition
    highestPriceSinceEntry := strategy.position_avg_price
    lowestPriceSinceEntry  := strategy.position_avg_price
    activeTrailingStop :=
         strategy.position_avg_price * (1.0 - trailRate)

if newShortPosition
    highestPriceSinceEntry := strategy.position_avg_price
    lowestPriceSinceEntry  := strategy.position_avg_price
    activeTrailingStop :=
         strategy.position_avg_price * (1.0 + trailRate)

// The full entry bar is not treated as post-entry MFE.
// The trailing stop begins updating from the first completed bar after entry.
if strategy.position_size > 0 and not newLongPosition and not isSessionExitBar
    highestPriceSinceEntry :=
         math.max(highestPriceSinceEntry, high)

    lowestPriceSinceEntry :=
         math.min(lowestPriceSinceEntry, low)

    float updatedLongTrail =
         highestPriceSinceEntry * (1.0 - trailRate)

    activeTrailingStop :=
         math.max(activeTrailingStop, updatedLongTrail)

if strategy.position_size < 0 and not newShortPosition and not isSessionExitBar
    lowestPriceSinceEntry :=
         math.min(lowestPriceSinceEntry, low)

    highestPriceSinceEntry :=
         math.max(highestPriceSinceEntry, high)

    float updatedShortTrail =
         lowestPriceSinceEntry * (1.0 + trailRate)

    activeTrailingStop :=
         math.min(activeTrailingStop, updatedShortTrail)

// A stop calculated at the current bar close can become active no earlier
// than the following bar.
if strategy.position_size > 0 and not isSessionExitBar and not na(activeTrailingStop)
    strategy.exit(
         "Long Tight Trail",
         from_entry = "Long",
         stop = math.round_to_mintick(activeTrailingStop),
         comment = "Tight Trailing Stop"
    )

if strategy.position_size < 0 and not isSessionExitBar and not na(activeTrailingStop)
    strategy.exit(
         "Short Tight Trail",
         from_entry = "Short",
         stop = math.round_to_mintick(activeTrailingStop),
         comment = "Tight Trailing Stop"
    )


// ─────────────────────────────────────────────────────────────────────────────
// SESSION CLOSE
// ─────────────────────────────────────────────────────────────────────────────
// The position is closed at the close of the 17:45 bar, corresponding to the
// 18:00 session price. No new or reverse entry is prepared on the same bar.
if isSessionExitBar
    strategy.cancel("Long")
    strategy.cancel("Short")

    if strategy.position_size > 0
        strategy.close(
             "Long",
             comment = "Session Close",
             immediately = true
        )

    if strategy.position_size < 0
        strategy.close(
             "Short",
             comment = "Session Close",
             immediately = true
        )

    setupDirection     := 0
    setupLevel         := na
    setupCrossBarIndex := na


// ─────────────────────────────────────────────────────────────────────────────
// NEW CROSS SETUP
// ─────────────────────────────────────────────────────────────────────────────
// A new or reverse setup is not prepared on a bar where a position has closed.
if isFlat and
   not positionClosedOnThisBar and
   not isSessionExitBar and
   nextBarEntryAllowed

    if bullishCross
        strategy.cancel("Short")

        setupDirection     := 1
        setupLevel         := high
        setupCrossBarIndex := bar_index

    else if bearishCross
        strategy.cancel("Long")

        setupDirection     := -1
        setupLevel         := low
        setupCrossBarIndex := bar_index


// ─────────────────────────────────────────────────────────────────────────────
// FOUR-BAR PRICE CONFIRMATION
// ─────────────────────────────────────────────────────────────────────────────
int setupAge =
     not na(setupCrossBarIndex)
     ? bar_index - setupCrossBarIndex
     : na

// The stop entry submitted after the crossover bar close can fill during the
// first, second, third or fourth following bar. It is cancelled after the
// fourth confirmation bar has closed.
bool setupIsValid =
     setupDirection != 0 and
     not na(setupAge) and
     setupAge < confirmationBars

bool longSetupReady =
     isFlat and
     setupDirection == 1 and
     setupIsValid and
     nextBarEntryAllowed and
     setupLevel > trendEma

bool shortSetupReady =
     isFlat and
     setupDirection == -1 and
     setupIsValid and
     nextBarEntryAllowed and
     setupLevel < trendEma

if longSetupReady
    strategy.cancel("Short")

    strategy.entry(
         "Long",
         strategy.long,
         stop = math.round_to_mintick(setupLevel),
         comment = "EMA Cross Long"
    )
else
    strategy.cancel("Long")

if shortSetupReady
    strategy.cancel("Long")

    strategy.entry(
         "Short",
         strategy.short,
         stop = math.round_to_mintick(setupLevel),
         comment = "EMA Cross Short"
    )
else
    strategy.cancel("Short")

if setupDirection != 0 and not setupIsValid
    strategy.cancel("Long")
    strategy.cancel("Short")

    setupDirection     := 0
    setupLevel         := na
    setupCrossBarIndex := na


// ─────────────────────────────────────────────────────────────────────────────
// RESET TRAILING VARIABLES AFTER THE POSITION CLOSES
// ─────────────────────────────────────────────────────────────────────────────
if positionClosedOnThisBar
    activeTrailingStop   := na
    highestPriceSinceEntry := na
    lowestPriceSinceEntry  := na


// ─────────────────────────────────────────────────────────────────────────────
// CHART DISPLAY
// ─────────────────────────────────────────────────────────────────────────────
plot(
     showEmaLines ? fastEma : na,
     "EMA 25",
     color = color.new(color.teal, 0),
     linewidth = 2
)

plot(
     showEmaLines ? slowEma : na,
     "EMA 68",
     color = color.new(color.orange, 0),
     linewidth = 2
)

plot(
     showEmaLines ? trendEma : na,
     "EMA 160",
     color = color.new(color.gray, 15),
     linewidth = 2
)

plot(
     showConfirmationLevel and isFlat and setupIsValid
     ? setupLevel
     : na,
     "Pending Confirmation Level",
     color = setupDirection == 1
             ? color.new(color.lime, 0)
             : color.new(color.red, 0),
     linewidth = 2,
     style = plot.style_linebr
)

plot(
     showTrailingStop and strategy.position_size != 0
     ? activeTrailingStop
     : na,
     "Active Tight Trailing Stop",
     color = color.new(color.fuchsia, 0),
     linewidth = 2,
     style = plot.style_linebr
)

plotshape(
     bullishCross and isFlat,
     title = "Bullish Cross",
     style = shape.triangleup,
     location = location.belowbar,
     color = color.new(color.lime, 0),
     size = size.tiny,
     text = "C"
)

plotshape(
     bearishCross and isFlat,
     title = "Bearish Cross",
     style = shape.triangledown,
     location = location.abovebar,
     color = color.new(color.red, 0),
     size = size.tiny,
     text = "C"
)

bgcolor(
     not isFifteenMinuteChart
     ? color.new(color.red, 88)
     : na,
     title = "15-Minute Chart Warning"
)


// ─────────────────────────────────────────────────────────────────────────────
// INFORMATION TABLE
// ─────────────────────────────────────────────────────────────────────────────
var table informationTable = table.new(
     position.top_right,
     2,
     7,
     border_width = 1
)

if barstate.islast
    if showInformationTable
        table.cell(
             informationTable,
             0,
             0,
             "EMA 25/68 BIST30 Futures",
             text_color = color.white,
             bgcolor = color.new(color.blue, 25)
        )

        table.cell(
             informationTable,
             1,
             0,
             "Open Source",
             text_color = color.white,
             bgcolor = color.new(color.blue, 25)
        )

        table.cell(
             informationTable,
             0,
             1,
             "Timeframe"
        )

        table.cell(
             informationTable,
             1,
             1,
             isFifteenMinuteChart
             ? "15 minutes"
             : "Use 15 minutes",
             text_color = isFifteenMinuteChart
                          ? color.white
                          : color.yellow
        )

        table.cell(
             informationTable,
             0,
             2,
             "Tight trail"
        )

        table.cell(
             informationTable,
             1,
             2,
             str.tostring(tightTrailPercent, "#.###") + "%"
        )

        table.cell(
             informationTable,
             0,
             3,
             "Commission"
        )

        table.cell(
             informationTable,
             1,
             3,
             str.tostring(commissionPercent, "#.###") + "%"
        )

        table.cell(
             informationTable,
             0,
             4,
             "Tax on commission"
        )

        table.cell(
             informationTable,
             1,
             4,
             str.tostring(taxOnCommissionPercent, "#.##") + "%"
        )

        table.cell(
             informationTable,
             0,
             5,
             "Effective cost per leg"
        )

        table.cell(
             informationTable,
             1,
             5,
             str.tostring(effectiveCostPerLegPercent, "#.#####") + "%",
             text_color = testerCommissionNeedsUpdate
                          ? color.yellow
                          : color.white
        )

        table.cell(
             informationTable,
             0,
             6,
             "Round-trip break-even"
        )

        table.cell(
             informationTable,
             1,
             6,
             str.tostring(roundTripBreakEvenMultiplier, "#.########"),
             text_color = testerCommissionNeedsUpdate
                          ? color.yellow
                          : color.white
        )
    else
        table.clear(
             informationTable,
             0,
             0,
             1,
             6
        )
````
