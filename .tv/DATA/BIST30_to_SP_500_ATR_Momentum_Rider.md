<!-- tradingview-pine-id: PUB;b1838c70c00a4dc2b41d2852a2506496 -->
<!-- tradingviewscripts-format: 1 -->
# BIST30 to S&P 500 — ATR Momentum Rider

Source: https://www.tradingview.com/script/jd1KSVn7/

## Description

BIST30 to S&P 500 — ATR Momentum Rider

BIST30 to S&P 500 — ATR Momentum Rider is a long-only daily strategy built to test a compact and auditable trend-following structure across index futures.

The name describes the research scope—from BIST30 to S&P 500 and other major index futures. It does not mean that the public parameters were optimized on BIST30. Parameter selection used Mini-DAX, E-mini S&P 500, E-mini Russell 2000, EURO STOXX 50, and Nikkei 225 Mini futures. Turkish index futures were kept outside parameter selection and used only as transferability stress tests.

Entry logic

The raw SET event occurs when HMA 8 > HMA 9 > HMA 20 becomes true for the first time. On that same daily close, the strategy calculates the three-day HMA20 slope in ATR units:

(HMA20 - HMA20[3]) / (3 × ATR14)

The setup is accepted only when this value is at least -0.180 ATR per day. The threshold does not require a rising HMA20; it permits a mild decline and rejects setups where the slow trend is deteriorating more sharply. The filter is evaluated only on the first establishment of the HMA order. A rejected setup does not enter later inside the same uninterrupted regime.

An accepted setup creates a market order for the next available session open. The decision uses only values known at the daily close.

Exit logic

The strategy has one public exit stage:

K1-A: activation threshold. Maximum favorable excursion is divided by the ATR value known when the entry order is created. Default: 1.50 ATR.

K1-T: trail distance from the highest high observed during the campaign. Default: 5.75%.

K1-W: minimum waiting interval before a K1 close decision can act. Default: 4 sessions.

Once K1 is active, its absolute trail can only rise. An activation reached on the current bar becomes actionable from the next bar, so the activation bar cannot stop itself retroactively. A daily close at or below the active K1 line creates a market exit for the next available open. If a fresh accepted SET appears while a position is open, the campaign is refreshed at the next open.

Research process and held-out results

The K1 values were selected on January 2020–December 2023 data using equal-weight, percentage-normalized metrics across the five international contracts. Keeping the K1 engine fixed, the three-day slope threshold was then scanned from -0.400 to +0.050 ATR/day in 0.001 steps on the same development interval. The exact PF-priority plateau peak was -0.176; the operational value was rounded and locked at -0.180 to avoid publishing a fragile, over-precise threshold.

January 2024–July 2026 was not used to select the slope threshold. In this held-out interval:

Raw setups: 153

Accepted setups/trades: 102 (33.3% reduction)

Positive international instruments: 5 of 5

Median profit factor: 3.46 versus 1.94 without the slope filter

Median normalized net return: 39.3% versus 37.9% without the slope filter

Median return/max-drawdown ratio: 2.32 versus 2.16 without the slope filter

These figures use one adverse minimum tick per market fill and no commission, tax, funding, or roll cost. They are historical research results, not a forecast.

The held-out BIST stress test remained weak: the three Turkish contracts had a median profit factor of 0.77 with the slope filter. Therefore, this public version is better viewed as an international index-futures research strategy. It is not a replacement for a dedicated BIST30 live system.

Use the strategy on standard daily candles. Review each symbol's contract multiplier, session, continuous-contract construction, commissions, roll costs, and margin settings before interpreting Strategy Tester results. Changing the HMA, ATR, K1, or execution settings creates a different, unvalidated configuration.

This script is a research and educational tool, not investment advice. Past performance does not guarantee future results.

BIST30 to S&P 500 — ATR Momentum Rider

HMA 8/9/20 kuruluşunu, sabit ATR-normalize HMA20 eğim filtresini ve yalnız yukarı taşınan tek tepe trailini birleştiren açık kaynak, long yönlü günlük strateji.

BIST30 to S&P 500 — ATR Momentum Rider, farklı endeks vadelilerinde sade ve denetlenebilir bir trend takip yapısını sınamak amacıyla hazırlanmış, yalnız long çalışan günlük bir stratejidir.

İsim, araştırmanın BIST30'dan S&P 500'e ve diğer büyük endeks vadelilerine uzanan kapsamını anlatır. Açık kaynak parametrelerinin BIST30 üzerinde optimize edildiği anlamına gelmez. Parametre seçiminde Mini-DAX, E-mini S&P 500, E-mini Russell 2000, EURO STOXX 50 ve Nikkei 225 Mini vadeli kontratları kullanılmıştır. Türkiye endeks vadelileri parametre seçiminin dışında tutulmuş ve yalnız taşınabilirlik stres testi olarak değerlendirilmiştir.

Giriş mantığı

Ham SET olayı, HMA 8 > HMA 9 > HMA 20 sıralamasının ilk kez oluştuğu günlük kapanışta doğar. Strateji aynı kapanışta HMA20'nin üç günlük eğimini ATR cinsinden hesaplar:

(HMA20 - HMA20[3]) / (3 × ATR14)

Kuruluş yalnız bu değer -0,180 ATR/gün veya daha yüksekse kabul edilir. Eşik HMA20'nin mutlaka yükselmesini istemez; hafif gerilemeye izin verir, yavaş trendin daha belirgin bozulduğu kuruluşları eler. Filtre yalnız HMA sıralamasının ilk kuruluşunda değerlendirilir. Reddedilen kuruluş, aynı kesintisiz rejimin sonraki günlerinde gecikmeli girişe dönüşmez.

Kabul edilen kuruluş, sonraki uygun seans açılışı için piyasa emri oluşturur. Karar yalnız günlük kapanışta bilinen değerlerle verilir.

Çıkış mantığı

Stratejide tek bir açık kaynak çıkış katmanı vardır:

K1-A: aktivasyon eşiği. Azami olumlu hareket, giriş emri oluşturulurken bilinen ATR değerine bölünür. Varsayılan: 1,50 ATR.

K1-T: kampanya boyunca görülen en yüksek fiyattan itibaren trail mesafesi. Varsayılan: %5,75.

K1-W: K1 kapanış kararının uygulanabilmesi için gereken asgari bekleme süresi. Varsayılan: 4 seans.

K1 aktif olduktan sonra mutlak trail seviyesi yalnız yukarı hareket eder. Bir barda ulaşılan aktivasyon eşiği sonraki bardan itibaren uygulanabilir; aktivasyon barı geriye dönük biçimde kendi kendisini durduramaz. Günlük kapanış aktif K1 çizgisinde veya altında gerçekleşirse sonraki uygun açılış için piyasa çıkışı oluşturulur. Pozisyon açıkken yeni ve kabul edilmiş bir SET doğarsa kampanya sonraki açılışta yenilenir.

Araştırma süreci ve ayrılmış dönem sonuçları

K1 değerleri Ocak 2020–Aralık 2023 döneminde beş yabancı kontrat üzerinde; endeksler eşit ağırlıklı ve fiyat ölçekleri yüzdeyle normalize edilerek seçildi. K1 motoru sabit tutulduktan sonra üç günlük eğim eşiği aynı geliştirme döneminde -0,400 ile +0,050 ATR/gün arasında 0,001 adımla tarandı. PF öncelikli platonun matematiksel tepe noktası -0,176 oldu; aşırı hassas bir değer yayımlamamak için operasyonel eşik -0,180 olarak yuvarlanıp sabitlendi.

Ocak 2024–Temmuz 2026 dönemi eğim eşiğinin seçiminde kullanılmadı. Bu ayrılmış dönemde:

Ham kuruluş: 153

Kabul edilen kuruluş/işlem: 102 (%33,3 azalış)

Pozitif yabancı endeks: 5/5

Medyan profit factor: eğim filtresi olmadan 1,94, filtreyle 3,46

Medyan normalize net getiri: filtresiz %37,9, filtreyle %39,3

Medyan getiri/azami düşüş oranı: filtresiz 2,16, filtreyle 2,32

Bu rakamlar her piyasa dolumunda bir minimum fiyat adımı ters slippage içerir; komisyon, vergi, fonlama ve vade geçiş maliyeti içermez. Tarihsel araştırma sonucudur, gelecek tahmini değildir.

BIST stres testi zayıf kalmıştır: eğim filtresiyle üç Türkiye kontratının medyan profit factor değeri 0,77 olmuştur. Bu nedenle açık kaynak sürümü yabancı endeks vadelileri için bir araştırma stratejisi olarak değerlendirmek daha doğrudur; özel BIST30 canlı motorunun yerine geçmez.

Stratejiyi standart günlük mumlarda kullanın. Strategy Tester sonucunu yorumlamadan önce sembolün kontrat çarpanını, seansını, sürekli-vade oluşturma yöntemini, komisyonunu, vade geçiş maliyetini ve teminat ayarlarını kontrol edin. HMA, ATR, K1 veya emir yürütme ayarlarını değiştirmek doğrulanmamış farklı bir model oluşturur.

Bu kod araştırma ve eğitim amaçlıdır; yatırım tavsiyesi değildir. Geçmiş performans gelecekteki sonuçları garanti etmez.

---

## Source Code

````pine
//@version=6
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0.
// Copyright (c) newton61
// Release 2.0: Locks the PF-priority HMA-S 3-day slope filter at -0.180 ATR/day.
strategy(
     "BIST30 to S&P 500 — ATR Momentum Rider",
     shorttitle = "ATR Rider",
     overlay = true,
     initial_capital = 100000,
     default_qty_type = strategy.fixed,
     default_qty_value = 1,
     pyramiding = 2,
     commission_type = strategy.commission.percent,
     commission_value = 0,
     slippage = 1,
     margin_long = 1,
     close_entries_rule = "ANY",
     calc_on_every_tick = false,
     calc_on_order_fills = false,
     process_orders_on_close = false)

// -----------------------------------------------------------------------------
// Inputs
// -----------------------------------------------------------------------------
string GROUP_SIGNAL = "Signal"
string GROUP_K1 = "K1"
string GROUP_TEST = "Backtest"
string GROUP_VIEW = "Display"

int fastLength = input.int(8, "HMA-F", minval = 2, group = GROUP_SIGNAL)
int midLength = input.int(9, "HMA-M", minval = 3, group = GROUP_SIGNAL)
int slowLength = input.int(20, "HMA-S", minval = 5, group = GROUP_SIGNAL)
int atrLength = input.int(14, "ATR-L", minval = 2, group = GROUP_SIGNAL)

// Locked research values. With the default HMA-S length of 20, this is the
// HMA20 three-day ATR-normalized slope filter selected on 2020-2023 data.
const int SLOPE_LOOKBACK = 3
const float SLOPE_MIN_ATR_PER_DAY = -0.18

float k1A = input.float(1.50, "K1-A · ATR activation", minval = 0.25, step = 0.25, group = GROUP_K1)
float k1T = input.float(5.75, "K1-T · Peak trail (%)", minval = 0.25, step = 0.25, group = GROUP_K1)
int k1W = input.int(4, "K1-W · Wait sessions", minval = 0, group = GROUP_K1)

// The backtest window is defined with simple year inputs.
int startYear = input.int(2020, "Start year", minval = 1970, maxval = 2098, group = GROUP_TEST)
int endYear = input.int(2099, "End year", minval = 1971, maxval = 2099, group = GROUP_TEST)

bool showHMAs = input.bool(true, "Show HMA set", group = GROUP_VIEW)
bool showK1 = input.bool(true, "Show active K1 trail", group = GROUP_VIEW)
bool shadeRegime = input.bool(false, "Shade active regime", group = GROUP_VIEW)

// -----------------------------------------------------------------------------
// Signal engine
// -----------------------------------------------------------------------------
hma(float source, int length) =>
    int halfLength = math.max(1, int(math.floor(length / 2.0)))
    int rootLength = math.max(1, int(math.round(math.sqrt(length))))
    ta.wma(2.0 * ta.wma(source, halfLength) - ta.wma(source, length), rootLength)

float hmaF = hma(close, fastLength)
float hmaM = hma(close, midLength)
float hmaS = hma(close, slowLength)
float atrValue = ta.atr(atrLength)

bool regime = hmaF > hmaM and hmaM > hmaS
bool rawSetup = regime and not regime[1]
float hmaSSlope3 = atrValue > 0 ? (hmaS - hmaS[SLOPE_LOOKBACK]) / SLOPE_LOOKBACK / atrValue : na
bool slopeAllowed = not na(hmaSSlope3) and hmaSSlope3 >= SLOPE_MIN_ATR_PER_DAY
// The filter is evaluated only on the first establishment of the HMA order.
// A rejected raw setup does not enter later inside the same regime.
bool setup = rawSetup and slopeAllowed
bool inDateRange = year >= startYear and year <= endYear

// -----------------------------------------------------------------------------
// Single-stage K1 state
// -----------------------------------------------------------------------------
var string activeEntryId = "L-A"
var bool resetOnNextBar = false
var int resetOrderBar = na
var float pendingEntryATR = na

var float entryPrice = na
var float entryATR = na
var float peakPrice = na
var float k1Trail = na
var bool k1Active = false
var int entryBar = na

// Market orders created at a bar close fill at the next available open because
// process_orders_on_close is false.  After that fill, initialize the new state
// with the ATR that was known when the setup order was created.
if resetOnNextBar and bar_index > resetOrderBar and strategy.position_size > 0
    entryPrice := strategy.position_avg_price
    entryATR := pendingEntryATR
    peakPrice := high
    k1Trail := na
    k1Active := false
    entryBar := bar_index
    resetOnNextBar := false

if strategy.position_size == 0 and not resetOnNextBar
    entryPrice := na
    entryATR := na
    peakPrice := na
    k1Trail := na
    k1Active := false
    entryBar := na

bool k1ExitSignal = false

if strategy.position_size > 0 and not resetOnNextBar
    peakPrice := math.max(nz(peakPrice, high), high)

    // A previously activated K1 can act on the current close.  The absolute
    // trail can only rise.  A close breach creates a next-open market exit.
    if k1Active
        float candidateTrail = peakPrice * (1.0 - k1T / 100.0)
        k1Trail := math.max(nz(k1Trail, candidateTrail), candidateTrail)
        k1ExitSignal := bar_index >= entryBar + k1W and close <= k1Trail

    // Activation is evaluated after the exit test, so the activation bar
    // cannot stop itself retroactively.
    float mfeATR = entryATR > 0 ? (peakPrice - entryPrice) / entryATR : na
    if not k1Active and not na(mfeATR) and mfeATR >= k1A
        k1Active := true
        k1Trail := na

// A fresh setup refreshes the campaign at the next open.  Alternating entry
// IDs allow the old trade to close and the new trade to open on that same tick.
if inDateRange and setup and not na(atrValue)
    float knownATR = atrValue
    if strategy.position_size > 0
        string nextEntryId = activeEntryId == "L-A" ? "L-B" : "L-A"
        strategy.close(activeEntryId, comment = "SET-R", alert_message = "SET-R EXIT", immediately = false)
        strategy.entry(nextEntryId, strategy.long, comment = "SET", alert_message = "SET LONG")
        activeEntryId := nextEntryId
    else
        strategy.entry(activeEntryId, strategy.long, comment = "SET", alert_message = "SET LONG")
    pendingEntryATR := knownATR
    resetOrderBar := bar_index
    resetOnNextBar := true
else if k1ExitSignal
    strategy.close(activeEntryId, comment = "K1", alert_message = "K1 EXIT", immediately = false)

if year > endYear and strategy.position_size > 0
    strategy.close(activeEntryId, comment = "DATE", alert_message = "DATE EXIT", immediately = false)

// -----------------------------------------------------------------------------
// Display
// -----------------------------------------------------------------------------
plot(showHMAs ? hmaF : na, "HMA-F", color = color.new(color.aqua, 0), linewidth = 2)
plot(showHMAs ? hmaM : na, "HMA-M", color = color.new(color.blue, 10), linewidth = 1)
plot(showHMAs ? hmaS : na, "HMA-S", color = color.new(color.orange, 0), linewidth = 2)
plot(showK1 and k1Active ? k1Trail : na, "K1", color = color.new(color.fuchsia, 0), linewidth = 2, style = plot.style_linebr)

plotshape(inDateRange and setup, title = "SET", text = "SET", style = shape.labelup, location = location.belowbar, color = color.new(color.teal, 0), textcolor = color.white, size = size.tiny)
plotshape(k1ExitSignal and not setup, title = "K1", text = "K1", style = shape.labeldown, location = location.abovebar, color = color.new(color.fuchsia, 0), textcolor = color.white, size = size.tiny)

bgcolor(shadeRegime and regime ? color.new(color.teal, 90) : na, title = "Regime")
````
