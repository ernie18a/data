# Universal Trend Continuation Probability

- url: https://www.tradingview.com/script/FMukfcaQ/
- type: indicator
- pine_id: PUB;5c65319c858b4bcc8fab1207f4883121
- version: 1.0

## Description

TradingView publication description

Universal Trend Continuation Probability

This open-source indicator estimates whether the chart's **current structural
direction state** is likely to remain active after a completed bar. It is a
trend-survival model, not a price-target or profit-probability model.

The dashboard provides two coherent forecasts:

- **Next 1 bar (P1):** probability that the active UP or DOWN state remains
  active on the next completed bar.
- **Next 2 bars (P2):** probability that the same state remains active on both
  next completed bars.

P2 is calculated with the probability chain rule:

`P2 = P1 × P(second bar survives | first bar survives)`

Therefore `0 ≤ P2 ≤ P1 ≤ 1` by construction. The dashboard's main score is
`+100 × P2` for UP, `−100 × P2` for DOWN, and `0` when the direction engine is
neutral.

How the model works

The direction engine combines normalized HMA20 slope, DMI balance, and
regression slope. A fixed regularized logistic ensemble then evaluates 33
completed-bar, direction-relative features covering direction strength,
momentum change, MACD histogram, RSI state, regression quality, price pressure,
ATR regime, range expansion, pullback clustering, and episode age.

The model does not use the symbol name, absolute price, clock, session,
timezone, or chart timeframe as an input. It uses no future bar, future label,
or `request.security` look-ahead. On an unfinished real-time bar, the displayed
values stay frozen at the previous completed bar and update only at bar close.

Interface

- English is the default language.
- Choose `Türkçe` under `Language / Dil` for the Turkish dashboard.
- Blue/orange/gray colors are chosen for color-blind accessibility.
- Only a centered dashboard is drawn on the main price chart. The indicator
  creates no separate pane, plotted score line, horizontal levels, or chart
  shading.
- The limitation warning is displayed in a readable row below the dashboard.
- The dashboard shows direction, P1, P2, the `CONTINUES / DOES NOT CONTINUE`
  decision, and the signed main score.
- The fixed decision threshold is 50%.
- Optional alerts fire on completed-bar decision-state changes.

Reference historical cross-market evaluation

The frozen V5 selection and calibration process used chronological XU030
development blocks. A historical cross-market evaluation contained 112,590
completed directional events across these standard time-based OHLC series:

| Series | Timeframe | Data range (UTC dates) |
|---|---:|---:|
| FDXM | 1D | 2015-10-26 to 2026-08-10 |
| ES | 1D | 2013-11-27 to 2026-08-10 |
| RTY | 1D | 2017-07-10 to 2026-08-10 |
| FESX | 1D | 2014-03-25 to 2026-08-10 |
| NK225M | 1D | 2013-01-16 to 2026-08-10 |
| NQ | 15m | 2024-10-31 to 2026-07-31 |
| RTY | 15m | 2024-10-31 to 2026-08-10 |
| RTY | 3m | 2026-04-05 to 2026-08-10 |
| ES | 3m | 2026-04-05 to 2026-08-10 |

| Horizon | Correct / total | Accuracy | Error rate |
|---|---:|---:|---:|
| 1 bar | 106,458 / 112,590 | 94.55% | 5.45% |
| 2 bars | 99,752 / 112,590 | 88.60% | 11.40% |

“Correct” means that the model's 50% `CONTINUES / DOES NOT CONTINUE` decision
matched whether the existing direction engine remained active over the stated
horizon. It does **not** mean that price moved favorably or that a trade was
profitable.

In a separate NQ 15-minute diagnostic with 25,808 forecasts, most errors were
neutralization-timing errors rather than direct reversals. Of 1,396 one-bar
errors, 934 (66.9%) were `CONTINUES → NEUTRAL`, 456 (32.7%) were early
`DOES NOT CONTINUE` warnings followed by continuation, and only 6 (0.4%) were
direct reversals of the direction engine.

These figures are historical Python research results, not current-chart
performance. They do not guarantee future performance or exact results on
another symbol, timeframe, session, or data feed. Some foreign instruments had
been reviewed in earlier V1–V4 research; the results are therefore presented as
a historical cross-market evaluation relative to the frozen V5 selection
process, not as a permanently untouched blind universe.

Important limitations

- The foreign-market price-only AUC was approximately 0.49. A high survival
  score is not evidence of positive return, favorable MFE, or a safe new entry.
- `DOES NOT CONTINUE` means the current state may neutralize or reverse; it does
  not specifically predict the opposite direction.
- A low probability is better treated as structural end-risk information. It
  has not been validated as an automatic exit rule.
- V6's analogue catalogue could rank neutralization risk, but its direct
  probability override reduced correct forecasts in locked/blind tests and is
  intentionally excluded from this Pine decision engine.
- Data differences in continuous futures adjustment, sessions, or bar
  construction can change results.
- Use standard time-based OHLC candles. Heikin Ashi, Renko, Kagi, Point &
  Figure, and Range chart results have not been validated.

Before public publication, the source should be compiled as a private
TradingView draft and checked against the included NQ reference using a
TradingView CSV export. This hosted-runtime parity step is separate from the
completed Python/formula validation.

Research indicator only. Not an execution strategy or investment advice.
Historical results do not guarantee future performance.

---
Universal Trend Continuation Probability

Bu açık kaynak indikatör, kapanmış bir bardan sonra grafikteki **mevcut yapısal
yön durumunun** aktif kalıp kalmayacağını tahmin eder. Fiyat hedefi veya kâr
olasılığı modeli değil, trend/yön devam modelidir.

Tablo birbiriyle tutarlı iki tahmin gösterir:

- **Sonraki 1 bar (P1):** aktif YUKARI veya AŞAĞI durumunun sonraki kapanmış
  barda devam etme olasılığı.
- **Sonraki 2 bar (P2):** aynı durumun sonraki iki kapanmış barın ikisinde de
  devam etme olasılığı.

P2, olasılık zinciriyle hesaplanır:

`P2 = P1 × P(ilk bar sürdüyse ikinci barın da sürmesi)`

Bu nedenle yapı gereği `0 ≤ P2 ≤ P1 ≤ 1` olur. Tablodaki ana skor YUKARI
durumda `+100 × P2`, AŞAĞI durumda `−100 × P2`, yön motoru nötrken `0`dır.

Modelin çalışma biçimi

Yön motoru normalize HMA20 eğimi, DMI dengesi ve regresyon eğimini birleştirir.
Sabitlenmiş düzenlileştirilmiş lojistik topluluk modeli daha sonra yalnız
kapanmış barlardan üretilen 33 yön-göreli özelliği değerlendirir. Bu özellikler
yön gücü, momentum değişimi, MACD histogramı, RSI durumu, regresyon kalitesi,
fiyat baskısı, ATR rejimi, range genişlemesi, geri çekilme kümelenmesi ve yön
yaşını kapsar.

Model; sembol adı, mutlak fiyat, saat, seans, saat dilimi veya grafik zaman
dilimini girdi olarak kullanmaz. Gelecek bar, gelecek hedef etiketi veya
`request.security` look-ahead kullanılmaz. Açık gerçek zamanlı barda görünen
değerler önceki kapanmış barda sabit kalır ve yalnız bar kapanınca güncellenir.

Arayüz

- Varsayılan dil İngilizcedir.
- Türkçe tablo için `Language / Dil` ayarından `Türkçe` seçilir.
- Mavi/turuncu/gri renkler renk körlüğüne uygun seçilmiştir.
- Ana fiyat grafiğinin ortasında yalnız bilgi tablosu çizilir. Gösterge ayrı alt
  panel, skor çizgisi, yatay seviye veya grafik gölgelemesi oluşturmaz.
- Sınırlama uyarısı tablonun altında okunaklı bir satırda gösterilir.
- Tablo; yönü, P1 ve P2 olasılıklarını, `SÜRER / SÜRMEZ` tahminini ve ana
  işaretli skoru gösterir.
- Karar eşiği %50 olarak sabittir.
- İsteğe bağlı alarmlar yalnız kapanmış barlarda karar durumu değiştiğinde
  çalışır.

Referans tarihsel çapraz-piyasa değerlendirmesi

Sabitlenmiş V5 seçim ve kalibrasyon sürecinde kronolojik XU030 geliştirme
blokları kullanılmıştır. Tarihsel çapraz-piyasa değerlendirmesi, aşağıdaki
standart zaman bazlı OHLC serilerinde 112.590 kapanmış yönlü olay içerir:

| Seri | Zaman dilimi | Veri aralığı (UTC tarihleri) |
|---|---:|---:|
| FDXM | 1G | 2015-10-26 – 2026-08-10 |
| ES | 1G | 2013-11-27 – 2026-08-10 |
| RTY | 1G | 2017-07-10 – 2026-08-10 |
| FESX | 1G | 2014-03-25 – 2026-08-10 |
| NK225M | 1G | 2013-01-16 – 2026-08-10 |
| NQ | 15 dk | 2024-10-31 – 2026-07-31 |
| RTY | 15 dk | 2024-10-31 – 2026-08-10 |
| RTY | 3 dk | 2026-04-05 – 2026-08-10 |
| ES | 3 dk | 2026-04-05 – 2026-08-10 |

| Ufuk | Doğru / toplam | Doğruluk | Hata oranı |
|---|---:|---:|---:|
| 1 bar | 106.458 / 112.590 | %94,55 | %5,45 |
| 2 bar | 99.752 / 112.590 | %88,60 | %11,40 |

“Doğru”; modelin %50 eşiğindeki `SÜRER / SÜRMEZ` kararının mevcut yön motorunun
belirtilen ufukta aktif kalıp kalmamasıyla eşleşmesi demektir. Fiyatın olumlu
yönde hareket ettiği veya işlemin kârlı olduğu anlamına gelmez.

25.808 tahmin içeren ayrı NQ 15 dakika tanı testinde hataların çoğu doğrudan
ters dönüş değil, nötrleşme zamanlaması hatasıdır. 1.396 bir barlık hatanın
934'ü (%66,9) `SÜRER → NÖTR`, 456'sı (%32,7) erken `SÜRMEZ` uyarısından sonra
devam, yalnız 6'sı (%0,4) yön motorunun doğrudan ters yöne dönmesidir.

Bu rakamlar tarihsel Python araştırma sonuçlarıdır; mevcut grafiğin performansı
değildir. Gelecekteki performansı veya başka sembol, zaman dilimi, seans ya da
veri akışında aynı sonucu garanti etmez. Bazı yabancı araçlar V1–V4
araştırmasında daha önce incelenmiştir; bu nedenle rakamlar tamamen
dokunulmamış kör evren değil, sabit V5 seçim sürecine göre tarihsel
çapraz-piyasa değerlendirmesi olarak sunulmaktadır.

Önemli sınırlamalar

- Yabancı piyasalarda fiyat-only AUC yaklaşık 0,49'dur. Yüksek devam skoru;
  pozitif getiri, olumlu MFE veya güvenli yeni giriş kanıtı değildir.
- `SÜRMEZ`, mevcut durumun nötrleşebileceği veya tersine dönebileceği anlamına
  gelir; özellikle karşı yönü tahmin etmez.
- Düşük olasılık yapısal bitiş riski bilgisi olarak ele alınmalıdır. Otomatik
  çıkış kuralı olarak doğrulanmamıştır.
- V6 analog kataloğu nötrleşme riskini sıralayabilmiştir; fakat doğrudan
  olasılık düzeltmesi kilitli/kör testlerde doğru tahmin sayısını düşürdüğü için
  Pine karar motoruna bilerek eklenmemiştir.
- Sürekli vade düzeltmesi, seans veya bar üretimindeki veri farkları sonucu
  değiştirebilir.
- Standart zaman bazlı OHLC mumları kullanılmalıdır. Heikin Ashi, Renko, Kagi,
  Point & Figure ve Range grafik sonuçları doğrulanmamıştır.

Public yayından önce kaynak private TradingView taslağında derlenmeli ve
TradingView CSV ihracıyla paketteki NQ referansına karşı kontrol edilmelidir.
Bu gerçek platform paritesi adımı, tamamlanmış Python/formül doğrulamasından
ayrıdır.

Yalnız araştırma indikatörüdür. İşlem stratejisi veya yatırım tavsiyesi
değildir. Geçmiş sonuçlar gelecekteki performansı garanti etmez.

## Source Code

````pine
//@version=6
// Universal Trend Continuation Probability
// Prediction engine: frozen V5 structural direction-survival model.
// The model estimates structural direction survival, not profit probability.
// Designed for standard time-based OHLC charts. Synthetic chart types are not validated.
// Compatibility revision 2026-08-12 FIX3: forced main-chart dashboard placement and local tanh for Pine v6.
indicator("Universal Trend Continuation Probability", "UTCP Dashboard", overlay = true, scale = scale.none, precision = 1, max_bars_back = 500)

// ─────────────────────────────────────────────────────────────────────────────
// Settings / Ayarlar
// ─────────────────────────────────────────────────────────────────────────────
string language = input.string("English", "Language / Dil", options = ["English", "Türkçe"], group = "Display / Görünüm")
bool showTable = input.bool(true, "Show table / Tabloyu göster", group = "Display / Görünüm")
bool showHistoricalNote = input.bool(false, "Show historical test note / Tarihsel test notunu göster", group = "Display / Görünüm")

const float DECISION_THRESHOLD = 0.50
const float DIRECTION_THRESHOLD = 0.25
const int WARMUP_BARS = 220
const float EPS = 0.000001

color LONG_COLOR = color.rgb(0, 114, 178)
color SHORT_COLOR = color.rgb(213, 94, 0)
color NEUTRAL_COLOR = color.rgb(107, 114, 128)
color TEXT_COLOR = color.rgb(245, 247, 250)
color PANEL_COLOR = color.rgb(24, 28, 36)
color MUTED_PANEL = color.rgb(42, 48, 60)

// Frozen V5 direct coefficients. Feature order is documented in the package.
var array<float> P1_COEF_PHASE_0 = array.from(
    2.539827680558262, 2.539827680558262, -0.61983011748163397, 1.6017494621780943,
    2.021915217735228, -1.8594903524449111, 7.4360792595992642, 4.0565342113254168,
    -1.475463920122712, 3.0858905966103221, 0.69330046544118584, 0.16142269618236116,
    -0.18030316051841447, 5.1424194611282577, -0.2014416397034203, 0.6195207223846978,
    -0.5705109643031937, 1.5584720385498632, 12.229047766848844, 1.9274736134615111,
    -0.15078083963821762, 0.37985547302362355, 0.55320586411713024, -0.46457863488707662,
    0.72949949805240111, -0.81135077902329522, 0.21911314110408253, -0.085707785122448824,
    -0.45614269027790538, 0.99835397425339989, -0.13053897386843624, 0.45517576363347223,
    1.9226057349157233
)
var array<float> P1_COEF_PHASE_1 = array.from(
    3.602825761776546, 3.6028257617765531, -0.58176771680052219, 0.52140557356782302,
    4.8834472357930743, -1.745303150401561, 4.4533254819555141, 4.4920862291033492,
    -0.77925849113921508, 3.0329350230550993, 1.4034485343548744, 0.41581051700450683,
    -0.56023783489562207, 3.8405546566870656, -0.2146636556019085, 0.0020198364395072523,
    -0.32605841086317094, 1.5329921342425501, 8.2828634177094802, 1.5372302506941922,
    0.15924317637143151, 0.38883572151418422, 0.6058250720130568, -0.39235238879149548,
    0.38619351688375386, -0.038945035626168543, 0.0002578592855542611, -0.17978905684726171,
    0.1572107358741964, 1.0965528596434191, -0.72818636346745713, 0.040798957178660819,
    0.52330879060590885
)
var array<float> Q2_COEF = array.from(
    1.9912530069312073, 1.9912530069312198, -0.80339804697322093, -1.0908566280900092,
    3.6313424105032888, -2.4101941409196761, 1.4006264875601984, 0.35384224210449167,
    1.3094927794039812, 1.7724492635735853, 1.620173500409112, 0.10523596747433049,
    0.014074246933497106, 3.9073887985308855, 0.095429858208445087, 0.17857184133467505,
    0.069117937492766221, 1.4926904013592053, 10.437116889194129, 1.3594884523453026,
    -0.13707139471273125, -0.0065540935731534895, -0.039201118300532696, -0.46944350829743781,
    -0.58609999810610725, -0.31969995818137797, 0.082665323519719072, -0.2089045529369839,
    -0.15735080509133467, 1.3698460299377646, 0.058918473175952335, -0.54893146099244949,
    -2.4964365264670998
)

f_clip(float x, float lower, float upper) =>
    math.max(lower, math.min(upper, x))

// Pine v6 has no math.tanh() built-in. This stable identity is equivalent to
// tanh(x) and clips only where double-precision tanh is already saturated.
f_tanh(float x) =>
    float z = f_clip(x, -20.0, 20.0)
    float expTerm = math.exp(-2.0 * math.abs(z))
    math.sign(z) * (1.0 - expTerm) / (1.0 + expTerm)

f_sigmoid(float x) =>
    float z = f_clip(x, -40.0, 40.0)
    1.0 / (1.0 + math.exp(-z))

f_logit(float p) =>
    float clipped = f_clip(p, EPS, 1.0 - EPS)
    math.log(clipped / (1.0 - clipped))

f_member_probability(array<float> x, array<float> beta, float intercept) =>
    float z = intercept
    for i = 0 to array.size(x) - 1
        z += array.get(x, i) * array.get(beta, i)
    f_sigmoid(z)

f_all_valid(array<float> x) =>
    bool valid = true
    for i = 0 to array.size(x) - 1
        valid := valid and not na(array.get(x, i))
    valid

// Returns slope and R² using x = 0..length-1 from oldest to newest.
f_regression(float source, int length) =>
    float sumX = length * (length - 1.0) / 2.0
    float sumXX = length * (length - 1.0) * (2.0 * length - 1.0) / 6.0
    float sumY = 0.0
    float sumYY = 0.0
    float sumXY = 0.0
    for i = 0 to length - 1
        float y = source[length - 1 - i]
        sumY += y
        sumYY += y * y
        sumXY += i * y
    float numerator = length * sumXY - sumX * sumY
    float denomX = length * sumXX - sumX * sumX
    float denomY = length * sumYY - sumY * sumY
    float slope = numerator / denomX
    float r2 = denomY > 0.0 ? f_clip(numerator * numerator / (denomX * denomY), 0.0, 1.0) : na
    [slope, r2]

f_text(string english, string turkish) =>
    language == "Türkçe" ? turkish : english

f_probability_text(float probability) =>
    na(probability) ? "—" : str.tostring(probability * 100.0, "#.0") + "%"

f_signed_text(int activeDirection, float probability) =>
    na(probability) or activeDirection == 0 ? "0.0" : (activeDirection > 0 ? "+" : "−") + str.tostring(probability * 100.0, "#.0")

// ─────────────────────────────────────────────────────────────────────────────
// Completed-bar OHLC feature engine
// ─────────────────────────────────────────────────────────────────────────────
float tr = ta.tr(true)
float atr14 = ta.rma(tr, 14)
float atr50 = ta.rma(tr, 50)

float hmaHalf = ta.wma(close, 10)
float hmaFull = ta.wma(close, 20)
float hma20 = ta.wma(2.0 * hmaHalf - hmaFull, 4)
float hmaSlope = (hma20 - hma20[3]) / (3.0 * atr14)

float upMove = high - high[1]
float downMove = low[1] - low
float plusDM = upMove > downMove and upMove > 0.0 ? upMove : 0.0
float minusDM = downMove > upMove and downMove > 0.0 ? downMove : 0.0
float plusDI = 100.0 * ta.rma(plusDM, 14) / atr14
float minusDI = 100.0 * ta.rma(minusDM, 14) / atr14
float dmiDenominator = plusDI + minusDI
float dmiDiff = dmiDenominator != 0.0 ? (plusDI - minusDI) / dmiDenominator : na

[lrSlope20, regressionR2] = f_regression(close, 20)
[lrSlope10, unusedR2_10] = f_regression(close, 10)
float lrSlopeNorm = lrSlope20 / atr14

float directionScore = 0.40 * f_tanh(hmaSlope / 0.25) + 0.35 * f_clip(dmiDiff, -1.0, 1.0) + 0.25 * f_tanh(lrSlopeNorm / 0.25)
int direction = directionScore >= DIRECTION_THRESHOLD ? 1 : directionScore <= -DIRECTION_THRESHOLD ? -1 : 0
float directionFloat = direction

float absChange = math.abs(ta.change(close))
float travel10 = ta.sma(absChange, 10) * 10.0
float efficiencyRatio = travel10 != 0.0 ? f_clip(math.abs(close - close[10]) / travel10, 0.0, 1.0) : na

float ema12 = ta.ema(close, 12)
float ema26 = ta.ema(close, 26)
float macd = ema12 - ema26
float macdSignal = ta.ema(macd, 9)
float macdHistogram = macd - macdSignal
float histLevel = macdHistogram / atr14
float histSlope = (macdHistogram - macdHistogram[3]) / (3.0 * atr14)

float delta = ta.change(close)
float avgGain = ta.rma(math.max(delta, 0.0), 14)
float avgLoss = ta.rma(math.max(-delta, 0.0), 14)
float rsi = avgLoss == 0.0 ? 100.0 : 100.0 - 100.0 / (1.0 + avgGain / avgLoss)

float barRange = high - low
float closeLocation = barRange != 0.0 ? 2.0 * (close - low) / barRange - 1.0 : 0.0
float atrRegime = f_clip(math.log(atr14 / atr50), -1.5, 1.5)
float hmaDistance = directionFloat * (close - hma20) / atr14
float ret1Raw = ta.change(close) / atr14
float ret3Raw = (close - close[3]) / (3.0 * atr14)

float rangeMedian20 = ta.median(tr, 20)
float rangeRatio = rangeMedian20 != 0.0 ? tr / rangeMedian20 : na
float rangeExpansion = math.log(f_clip(rangeRatio, 0.20, 5.0))

float directionStrength = math.abs(directionScore)
float directionMargin = math.max(directionStrength - DIRECTION_THRESHOLD, 0.0)
float directionStrengthChange = directionFloat * (directionScore - directionScore[3])
float scoreVelocity1 = directionFloat * (directionScore - directionScore[1])
float scoreVelocity2 = directionFloat * (directionScore - directionScore[2]) / 2.0
float scoreVelocity3 = directionFloat * (directionScore - directionScore[3]) / 3.0
float scoreAcceleration = scoreVelocity1 - scoreVelocity3
float directionalScore = directionFloat * directionScore
float marginRatio = directionMargin / (math.abs(directionalScore) + DIRECTION_THRESHOLD)
float nearBoundary = math.exp(-directionMargin / 0.10)
float hmaSlopeDir = directionFloat * hmaSlope
float dmiDir = directionFloat * dmiDiff
float regressionSlope10Dir = directionFloat * lrSlope10 / atr14
float momentum1Dir = directionFloat * ret1Raw
float momentum3Dir = directionFloat * ret3Raw
float momentumAccelDir = directionFloat * (ret1Raw - ret3Raw)
float macdHistLevelDir = directionFloat * histLevel
float macdHistSlopeDir = directionFloat * histSlope
float rsiCenterDir = directionFloat * (rsi - 50.0) / 25.0
float rsiChangeDir = directionFloat * (rsi - rsi[3]) / 15.0
float closeLocationDir = directionFloat * closeLocation
float directionalSign = directionFloat * math.sign(ta.change(close))
float pressure4 = ta.sma(directionalSign, 4)
float pressure12 = ta.sma(directionalSign, 12)
float adverseBar = directionFloat * math.sign(ta.change(close)) < 0.0 ? 1.0 : 0.0
float adversePressure3 = ta.sma(adverseBar, 3)
float adversePressure6 = ta.sma(adverseBar, 6)
float climaxRisk = math.max(rangeExpansion, 0.0) * (1.0 - f_clip(closeLocationDir, -1.0, 1.0)) / 2.0
float pullbackDepth = math.max(-momentum1Dir, 0.0)
float pullbackCluster5 = ta.sma(pullbackDepth, 5)

var int episodeAge = 0
episodeAge := direction == 0 ? 0 : direction == direction[1] ? nz(episodeAge[1]) + 1 : 1
float episodeAgeLog = math.log(1.0 + episodeAge)
float episodeAgeInverse = episodeAge > 0 ? 1.0 / math.sqrt(episodeAge) : na

// Feature order must match the frozen JSON coefficient order. Reuse one array
// to avoid allocating a new collection on every chart bar.
var array<float> features = array.new<float>(33, na)
array.set(features, 0, directionStrength)
array.set(features, 1, directionMargin)
array.set(features, 2, directionStrengthChange)
array.set(features, 3, scoreVelocity1)
array.set(features, 4, scoreVelocity2)
array.set(features, 5, scoreVelocity3)
array.set(features, 6, scoreAcceleration)
array.set(features, 7, marginRatio)
array.set(features, 8, nearBoundary)
array.set(features, 9, hmaSlopeDir)
array.set(features, 10, dmiDir)
array.set(features, 11, efficiencyRatio)
array.set(features, 12, regressionR2)
array.set(features, 13, regressionSlope10Dir)
array.set(features, 14, momentum1Dir)
array.set(features, 15, momentum3Dir)
array.set(features, 16, momentumAccelDir)
array.set(features, 17, macdHistLevelDir)
array.set(features, 18, macdHistSlopeDir)
array.set(features, 19, rsiCenterDir)
array.set(features, 20, rsiChangeDir)
array.set(features, 21, closeLocationDir)
array.set(features, 22, pressure4)
array.set(features, 23, pressure12)
array.set(features, 24, adversePressure3)
array.set(features, 25, adversePressure6)
array.set(features, 26, atrRegime)
array.set(features, 27, rangeExpansion)
array.set(features, 28, climaxRisk)
array.set(features, 29, hmaDistance)
array.set(features, 30, pullbackCluster5)
array.set(features, 31, episodeAgeLog)
array.set(features, 32, episodeAgeInverse)

bool featureReady = bar_index >= WARMUP_BARS and direction != 0 and atr14 > 0.0 and f_all_valid(features)
float p1Member0 = featureReady ? f_member_probability(features, P1_COEF_PHASE_0, -2.693732163007958) : na
float p1Member1 = featureReady ? f_member_probability(features, P1_COEF_PHASE_1, -2.1311654103149014) : na
float p1Raw = featureReady ? (p1Member0 + p1Member1) / 2.0 : na
float p1Model = featureReady ? f_sigmoid(-0.042571711266038217 + 0.983440091923654 * f_logit(p1Raw)) : na

float q2Raw = featureReady ? f_member_probability(features, Q2_COEF, 0.66519548190123778) : na
float q2Model = featureReady ? f_sigmoid(0.034891348299912944 + 0.96599509383924687 * f_logit(q2Raw)) : na
float p2Model = featureReady ? p1Model * q2Model : na

// Freeze the visible output during an unfinished real-time bar.
int shownDirection = barstate.isconfirmed ? direction : direction[1]
bool shownReady = barstate.isconfirmed ? featureReady : featureReady[1]
float shownP1 = barstate.isconfirmed ? p1Model : p1Model[1]
float shownP2 = barstate.isconfirmed ? p2Model : p2Model[1]
float signedScore = shownReady ? shownDirection * shownP2 * 100.0 : shownDirection == 0 ? 0.0 : na

color activeColor = shownDirection > 0 ? LONG_COLOR : shownDirection < 0 ? SHORT_COLOR : NEUTRAL_COLOR
// Keep parity/export values in the Data Window without drawing a separate
// indicator pane, price-chart lines, horizontal levels, or background shading.
plot(signedScore, "Signed 2-bar continuation score", display = display.data_window, force_overlay = true)
plot(shownReady ? shownP1 * 100.0 : na, "P1 probability (%)", display = display.data_window, force_overlay = true)
plot(shownReady ? shownP2 * 100.0 : na, "P2 probability (%)", display = display.data_window, force_overlay = true)
plot(shownDirection, "Direction engine (+1/0/-1)", display = display.data_window, force_overlay = true)

string directionText = shownDirection > 0 ? f_text("UP", "YUKARI") : shownDirection < 0 ? f_text("DOWN", "AŞAĞI") : f_text("NO DIRECTION", "YÖN YOK")
string decision1 = not shownReady ? f_text("WAIT", "BEKLE") : shownP1 >= DECISION_THRESHOLD ? f_text("CONTINUES", "SÜRER") : f_text("DOES NOT CONTINUE", "SÜRMEZ")
string decision2 = not shownReady ? f_text("WAIT", "BEKLE") : shownP2 >= DECISION_THRESHOLD ? f_text("CONTINUES", "SÜRER") : f_text("DOES NOT CONTINUE", "SÜRMEZ")
color decisionColor1 = not shownReady ? NEUTRAL_COLOR : shownP1 >= DECISION_THRESHOLD ? activeColor : NEUTRAL_COLOR
color decisionColor2 = not shownReady ? NEUTRAL_COLOR : shownP2 >= DECISION_THRESHOLD ? activeColor : NEUTRAL_COLOR

var table dashboard = table.new(position.middle_center, 3, 7, bgcolor = PANEL_COLOR, border_color = color.new(NEUTRAL_COLOR, 30), border_width = 1, force_overlay = true)
if barstate.isfirst
    table.merge_cells(dashboard, 0, 0, 2, 0)
    table.merge_cells(dashboard, 1, 5, 2, 5)
    table.merge_cells(dashboard, 0, 6, 2, 6)
if barstate.islast
    if showTable
        table.cell(dashboard, 0, 0, f_text("TREND CONTINUATION", "TREND DEVAM OLASILIĞI"), text_color = TEXT_COLOR, bgcolor = MUTED_PANEL, text_size = size.small)
        table.cell(dashboard, 0, 1, f_text("Direction", "Yön"), text_color = color.silver)
        table.cell(dashboard, 1, 1, directionText, text_color = TEXT_COLOR, bgcolor = color.new(activeColor, 35))
        table.cell(dashboard, 2, 1, f_text("Closed bar", "Kapanmış bar"), text_color = color.silver)
        table.cell(dashboard, 0, 2, f_text("Horizon", "Ufuk"), text_color = color.silver, bgcolor = MUTED_PANEL)
        table.cell(dashboard, 1, 2, f_text("Probability", "Olasılık"), text_color = color.silver, bgcolor = MUTED_PANEL)
        table.cell(dashboard, 2, 2, f_text("Decision", "Tahmin"), text_color = color.silver, bgcolor = MUTED_PANEL)
        table.cell(dashboard, 0, 3, f_text("Next 1 bar", "Sonraki 1 bar"), text_color = TEXT_COLOR)
        table.cell(dashboard, 1, 3, shownReady ? f_probability_text(shownP1) : "—", text_color = TEXT_COLOR)
        table.cell(dashboard, 2, 3, shownDirection == 0 ? directionText : decision1, text_color = TEXT_COLOR, bgcolor = color.new(decisionColor1, 35))
        table.cell(dashboard, 0, 4, f_text("Next 2 bars", "Sonraki 2 bar"), text_color = TEXT_COLOR)
        table.cell(dashboard, 1, 4, shownReady ? f_probability_text(shownP2) : "—", text_color = TEXT_COLOR)
        table.cell(dashboard, 2, 4, shownDirection == 0 ? directionText : decision2, text_color = TEXT_COLOR, bgcolor = color.new(decisionColor2, 35))
        table.cell(dashboard, 0, 5, f_text("Main score", "Ana skor"), text_color = color.silver)
        table.cell(dashboard, 1, 5, shownReady ? f_signed_text(shownDirection, shownP2) : "0.0", text_color = TEXT_COLOR, bgcolor = color.new(activeColor, 45))
        string note = showHistoricalNote ? f_text("Historical cross-market reference error: 1B 5.45% | 2B 11.40%\nNot current-chart performance", "Tarihsel çapraz-piyasa referans hatası: 1B %5,45 | 2B %11,40\nMevcut grafik performansı değildir") : f_text("Structural survival ≠ profit probability", "Yapısal devam ≠ kâr olasılığı")
        table.cell(dashboard, 0, 6, note, text_color = color.silver, text_size = size.small)
    else
        table.clear(dashboard, 0, 0, 2, 6)

// Alerts are evaluated only at completed bars.
bool oneBarContinueEvent = barstate.isconfirmed and featureReady and p1Model >= DECISION_THRESHOLD and (na(p1Model[1]) or p1Model[1] < DECISION_THRESHOLD or direction != direction[1])
bool oneBarEndRiskEvent = barstate.isconfirmed and featureReady and p1Model < DECISION_THRESHOLD and (na(p1Model[1]) or p1Model[1] >= DECISION_THRESHOLD or direction != direction[1])
bool twoBarContinueEvent = barstate.isconfirmed and featureReady and p2Model >= DECISION_THRESHOLD and (na(p2Model[1]) or p2Model[1] < DECISION_THRESHOLD or direction != direction[1])
bool twoBarEndRiskEvent = barstate.isconfirmed and featureReady and p2Model < DECISION_THRESHOLD and (na(p2Model[1]) or p2Model[1] >= DECISION_THRESHOLD or direction != direction[1])
bool neutralEvent = barstate.isconfirmed and direction == 0 and direction[1] != 0

alertcondition(oneBarContinueEvent, "1-bar continuation / 1 bar devam", "UTCP: The active direction is forecast to continue for the next bar. / Aktif yönün sonraki barda sürmesi bekleniyor.")
alertcondition(oneBarEndRiskEvent, "1-bar end risk / 1 bar bitiş riski", "UTCP: The active direction is not forecast to continue for the next bar. / Aktif yönün sonraki barda sürmesi beklenmiyor.")
alertcondition(twoBarContinueEvent, "2-bar continuation / 2 bar devam", "UTCP: The active direction is forecast to continue across the next two bars. / Aktif yönün sonraki iki bar boyunca sürmesi bekleniyor.")
alertcondition(twoBarEndRiskEvent, "2-bar end risk / 2 bar bitiş riski", "UTCP: The active direction is not forecast to survive both next bars. / Aktif yönün sonraki iki barın ikisinde de sürmesi beklenmiyor.")
alertcondition(neutralEvent, "Direction neutralized / Yön nötrleşti", "UTCP: The direction engine became neutral. / Yön motoru nötrleşti.")
````
