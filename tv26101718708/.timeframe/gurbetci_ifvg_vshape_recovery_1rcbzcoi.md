# Gurbetci iFVG + V-Shape Recovery

- url: https://www.tradingview.com/script/1RCBZCOI-Gurbetci-iFVG-V-Shape-Recovery/
- type: indicator
- pine_id: PUB;3ac1ca8abc8b4228af99a905a883a79b
- version: 1.0

## Description

OVERVIEW

This open-source indicator combines two of the most widely known Smart Money / ICT concepts into a single, structured workflow: the V-Shape Recovery (liquidity sweep followed by a CISD reversal confirmation) and the Inversion Fair Value Gap (iFVG) retest model. Instead of printing isolated signals, every reversal is measured against an 8-point confluence checklist, so you always see not only WHAT fired but WHY it fired. Entries are visualized together with their invalidation level and an R-multiple target zone.

This tool was built and released for free on purpose: no indicator alone is a trading edge. An indicator can only describe what price has already done. Edge comes from a tested model, risk management and disciplined execution. This script gives you the same drawing and confluence engine that is often sold commercially, so you can focus on the part that actually matters.

BACKGROUND CONCEPTS

- Fair Value Gap (FVG): a three-candle imbalance where the wicks of candle 1 and candle 3 do not overlap, leaving an unfilled gap.
- Inversion FVG (iFVG): when price closes through an FVG against its original direction, the gap is considered invalidated and flips its role — a bearish gap becomes support, a bullish gap becomes resistance. The retest of this inverted zone is the core entry of the model.
- Consequent Encroachment (CE): the 50% midpoint of a gap, used as the fine-tuned entry/reaction level inside the zone.
- Liquidity Sweep: price wicks through an obvious swing high/low (where stop orders rest) but closes back beyond the level — a stop hunt rather than a genuine breakout.
- CISD (Change In State of Delivery): after a sweep, price closes through the opening price of the candle series that ran into the extreme, confirming that delivery has flipped direction. Sweep + CISD together form the V-Shape Recovery.
- SMT Divergence: two correlated instruments (e.g. NQ and ES) disagree at an extreme — one sweeps its swing while the other holds. This is checked in real time at the moment of the sweep.
- MSS (Market Structure Shift): a candle close through the most recent opposing swing point.
- Premium / Discount: position of price relative to the 50% equilibrium of the recent dealing range. Longs are favored in discount, shorts in premium.
- Killzone: the New York morning session window (customizable), when volatility and institutional participation are highest.

HOW IT WORKS

1. Swing highs/lows are tracked with pivots and treated as resting liquidity. Equal highs/lows (double tops/bottoms within an ATR tolerance) are detected and weighted as stronger liquidity.
2. When a swing is swept by a wick but the candle closes back beyond the level, a sweep is marked (x-cross) and the CISD level is calculated from the candle series that ran into the extreme.
3. If price closes through the CISD level within the configured window, and the confirming candle passes the ATR displacement filter, the V-Shape Recovery is confirmed and scored.
4. In parallel, all FVGs are tracked in the background. A gap that is closed through against its direction becomes an iFVG, drawn with a dashed border and its CE (50%) line.
5. ENTRY signal: after a V-Shape Recovery, when price retests an iFVG in the same direction and gets rejected (closes back beyond the zone edge), the entry marker prints, with the invalidation placed beyond the zone/sweep extreme and a configurable R-multiple target box.

CONFLUENCE SCORE (max 8)

Every V-Shape signal shows a score label (e.g. 5/8). Hover the label to see exactly which components were met:
1. Sweep + CISD (base condition, always 1 point)
2. Real-time SMT divergence against the correlated symbol at the sweep
3. Recent iFVG retest in the same direction
4. Market Structure Shift within the lookback window
5. Premium/Discount alignment (longs in discount, shorts in premium)
6. Higher-timeframe FVG bias alignment (default 15m)
7. Equal highs/lows sweep bonus
8. Killzone timing

The status panel (top right) shows the live state of every component: HTF bias, premium/discount position, killzone state, last sweep, last V-Shape, last MSS, last iFVG retest, last SMT and the score of the most recent signal.

CHART MARKERS

- x-cross: liquidity sweep (dotted line connects the swept swing)
- Small diamond: V-Shape confirmed but below your minimum score
- Score label "V-SHAPE 5/8": V-Shape at or above your minimum score
- Small triangle: iFVG retest
- ENTRY triangle: iFVG retest following a V-Shape Recovery, with SL/TP boxes
- Small circle: SMT divergence at a sweep
- Dashed boxes: inversion FVG zones with dotted CE midline
- Blue background: killzone session

ALERTS

Create ONE alert on this indicator and select "Any alert() function call" as the condition. You will receive dynamic notifications containing the symbol, timeframe, confluence breakdown and the entry/invalidation/target prices of ENTRY signals. Individual static alert conditions are also available for every event type (V-Shape long/short, ENTRY long/short, iFVG retest, SMT).

SETTINGS

- Zone display: "iFVG only" (clean chart, recommended) or all FVGs
- Minimum FVG width as an ATR multiple; inversion detection by close or wick
- Swing pivot length, sweep-to-CISD window, ATR displacement filter
- Every confluence component can be toggled individually (SMT symbol, MSS, premium/discount range length, HTF timeframe, equal H/L tolerance, killzone session)
- Killzone can be used as a score component or as a hard session filter
- Minimum score required for signal labels; R-multiple for the target box; alert toggle

LIMITATIONS - PLEASE READ

The higher-timeframe bias uses the developing HTF candle and may change before that candle closes. All signals are evaluated on bar close. The SL/TP boxes are visualizations of the model's logic, not trade recommendations. This indicator is a charting and educational tool: no indicator alone constitutes a profitable strategy, past behavior does not guarantee future results, and nothing here is financial advice.

Published free and open-source by Gurbetci Trader.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © GurbetciTrader
//
// ─────────────────────────────────────────────────────────────────────────────
//  iFVG + V-Shape Recovery [Gurbetçi Trader]  — v3
//
//  Free & open-source. Amaç: piyasada satılan indikatörlerin aynısını ücretsiz
//  vermek ve şunu göstermek — indikatör edge değildir. Edge; model, risk
//  yönetimi ve execution disiplinidir.
//
//  Model (kaynaklar):
//   - Josh's IFVG Model (TradeZella): HTF bias → liquidity sweep → displacement
//     → inversion → iFVG retest entry, SL sweep/zone arkasında, TP internal
//     liquidity. SMT confirmation.
//   - Triton/TTrades CISD entry model: V-shape reversal + reversal CISD
//   - Yüksek olasılık checklist: MSS + premium/discount + killzone + HTF FVG
//     hizası (LuxAlgo, innercircletrader.net, Prodigy Trading)
//
//  8 confluence bileşeni: Sweep+CISD (baz), SMT, iFVG retest, MSS,
//  Premium/Discount, HTF bias, Equal H/L sweep, Killzone.
//
//  Bu indikatör al/sat tavsiyesi DEĞİLDİR. Geçmiş veri gelecek performansı
//  garanti etmez.
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("iFVG + V-Shape Recovery [Gurbetçi Trader]",
     shorttitle      = "iFVG + V-Shape [GT]",
     overlay         = true,
     max_boxes_count  = 500,
     max_labels_count = 500,
     max_lines_count  = 500,
     max_bars_back    = 500)

// ════════════════════════════════ INPUTS ════════════════════════════════════

const string G_FVG = "FVG / iFVG"
const string G_VS  = "V-Shape Recovery (Sweep + CISD)"
const string G_CF  = "Confluence Bileşenleri"
const string G_SIG = "Sinyal & Risk"
const string G_UI  = "Görünüm"

// — FVG / iFVG
string zoneMode   = input.string("Sadece iFVG", "Zone görünümü", options = ["Sadece iFVG", "FVG + iFVG"], group = G_FVG,
     tooltip = "Sadece iFVG: normal FVG'ler arka planda takip edilir, sadece inversion'a dönüşenler çizilir (temiz chart). FVG + iFVG: her şey çizilir.")
float  fvgAtrMult = input.float(0.3, "Min FVG genişliği (ATR çarpanı)", minval = 0.0, step = 0.05, group = G_FVG)
string invPref    = input.string("Close", "Inversion tespiti", options = ["Close", "Wick"], group = G_FVG)
int    maxZones   = input.int(12, "Tutulacak zone sayısı", minval = 2, maxval = 100, group = G_FVG)
bool   showCE     = input.bool(true, "CE çizgisi (zone %50)", group = G_FVG,
     tooltip = "Consequent Encroachment: iFVG'nin %50 seviyesi. Modelin hassas giriş noktası.")

// — V-Shape Recovery
int    swingLen    = input.int(5, "Swing pivot uzunluğu", minval = 2, maxval = 50, group = G_VS)
int    cisdWindow  = input.int(25, "Sweep → CISD max bar", minval = 3, maxval = 100, group = G_VS)
float  dispAtrMult = input.float(0.5, "Displacement filtresi (ATR gövde)", minval = 0.0, step = 0.1, group = G_VS,
     tooltip = "CISD'yi onaylayan mumun gövdesi en az ATR(14) × bu çarpan olmalı. 0 = kapalı.")
bool   showSweeps  = input.bool(true, "Liquidity sweep işaretle (✕)", group = G_VS)
bool   showCISD    = input.bool(true, "CISD çizgisi", group = G_VS)

// — Confluence bileşenleri
bool   useSMT  = input.bool(true, "SMT divergence", group = G_CF, inline = "smt")
string smtSym  = input.symbol("CME_MINI:ES1!", "", group = G_CF, inline = "smt",
     tooltip = "NQ grafiğindeysen ES seç, ES'teysen NQ. Sweep anında gerçek zamanlı kontrol edilir.")
bool   useMSS  = input.bool(true, "MSS (Market Structure Shift)", group = G_CF,
     tooltip = "Kapanışın son swing high/low'u kırması. MSS sonrası oluşan iFVG çok daha güçlüdür.")
bool   usePD   = input.bool(true, "Premium / Discount", group = G_CF, inline = "pd",
     tooltip = "Dealing range'in %50 equilibrium'u. Long sinyaller discount'ta, short sinyaller premium'da puan alır.")
int    rangeLen = input.int(60, "", minval = 20, maxval = 500, group = G_CF, inline = "pd")
bool   useHTF  = input.bool(true, "HTF bias (üst zaman dilimi FVG yönü)", group = G_CF, inline = "htf")
string htfTF   = input.timeframe("15", "", group = G_CF, inline = "htf",
     tooltip = "Üst zaman dilimindeki son FVG'nin yönü = bias. 1-5m chart için 15m veya 60 önerilir.")
bool   useEQ   = input.bool(true, "Equal High/Low sweep bonusu", group = G_CF, inline = "eq",
     tooltip = "Süpürülen seviye equal lows/highs (çift dip/tepe likiditesi) ise ekstra puan.")
float  eqTol   = input.float(0.25, "", minval = 0.05, step = 0.05, group = G_CF, inline = "eq")
bool   useKZ   = input.bool(true, "Killzone puanı", group = G_CF, inline = "kz",
     tooltip = "Seans içindeki sinyaller +1 puan alır (filtre değil, puan).")
string kzSes   = input.session("0930-1100", "", group = G_CF, inline = "kz")
bool   kzHard  = input.bool(false, "Killzone SERT filtre (seans dışı sinyal yok)", group = G_CF)
bool   showKZ  = input.bool(true, "Killzone arka planı", group = G_CF)

// — Sinyal & Risk
int    minScore   = input.int(3, "V-Shape etiketi için min skor (1-8)", minval = 1, maxval = 8, group = G_SIG,
     tooltip = "Baz: Sweep + CISD = 1. Diğer 7 bileşenin her biri +1. Düşür = daha çok sinyal.")
int    confWindow = input.int(40, "Confluence geriye bakış (bar)", minval = 5, maxval = 200, group = G_SIG)
bool   showEntry  = input.bool(true, "ENTRY sinyali (V-shape sonrası iFVG retest)", group = G_SIG)
bool   showRisk   = input.bool(true, "ENTRY'de SL/TP kutuları", group = G_SIG,
     tooltip = "Model kuralı: SL zone/sweep dibinin arkasında, TP = R çarpanı.")
float  rrMult     = input.float(2.0, "TP (R çarpanı)", minval = 0.5, step = 0.5, group = G_SIG)
bool   useAlerts  = input.bool(true, "alert() mesajları (dinamik, fiyatlı)", group = G_SIG,
     tooltip = "Alarm kurarken 'Any alert() function call' seç — sinyaller sembol/fiyat/SL/TP detayıyla telefona düşer.")
bool   showDash   = input.bool(true, "Durum paneli", group = G_SIG)

// — Görünüm
color  bullCol = input.color(#089981, "Bull", group = G_UI, inline = "c")
color  bearCol = input.color(#f23645, "Bear", group = G_UI, inline = "c")
bool   showEq  = input.bool(false, "Equilibrium çizgisi", group = G_UI)

// ═══════════════════════════════ ORTAK ══════════════════════════════════════

float atr  = ta.atr(14)
float body = math.abs(close - open)
bool  inKZ = not na(time(timeframe.period, kzSes, "America/New_York"))
bool  kzOK = not kzHard or inKZ

bgcolor(showKZ and inKZ ? color.new(color.blue, 95) : na)

var int lastBullIFVG  = -99999
var int lastBearIFVG  = -99999
var int lastBullSMT   = -99999
var int lastBearSMT   = -99999
var int lastBullMSS   = -99999
var int lastBearMSS   = -99999
var int lastBullSweep = -99999
var int lastBearSweep = -99999
var int lastBullV     = -99999
var int lastBearV     = -99999

// ═══════════════════════ HTF BIAS + DEALING RANGE ═══════════════════════════

int htfSig = request.security(syminfo.tickerid, htfTF,
     low > high[2] ? 1 : high < low[2] ? -1 : 0)
var int htfBias = 0
if useHTF and htfSig != 0
    htfBias := htfSig

float eqMid = (ta.highest(high, rangeLen) + ta.lowest(low, rangeLen)) / 2
plot(showEq ? eqMid : na, "Equilibrium", color.new(color.gray, 50), 1, plot.style_line)

// ══════════════════════════════ FVG / iFVG ══════════════════════════════════

type Zone
    box   bx
    line  ln
    int   leftBar
    float top
    float bot
    int   dir       // 1 = bullish FVG, -1 = bearish FVG
    bool  inverted
    bool  signaled

var array<Zone> zones = array.new<Zone>()

bool drawFresh  = zoneMode == "FVG + iFVG"
bool newBullFVG = low > high[2] and (low - high[2]) >= fvgAtrMult * atr
bool newBearFVG = high < low[2] and (low[2] - high) >= fvgAtrMult * atr

if newBullFVG
    box b = drawFresh ?
         box.new(bar_index - 2, low, bar_index, high[2],
             border_color = color.new(bullCol, 65), border_width = 1,
             bgcolor = color.new(bullCol, 92)) : box(na)
    zones.push(Zone.new(b, line(na), bar_index - 2, low, high[2], 1, false, false))
if newBearFVG
    box b = drawFresh ?
         box.new(bar_index - 2, low[2], bar_index, high,
             border_color = color.new(bearCol, 65), border_width = 1,
             bgcolor = color.new(bearCol, 92)) : box(na)
    zones.push(Zone.new(b, line(na), bar_index - 2, low[2], high, -1, false, false))

while zones.size() > maxZones
    Zone old = zones.shift()
    if not na(old.bx)
        box.delete(old.bx)
    if not na(old.ln)
        line.delete(old.ln)

bool  bullIFVGretest = false
bool  bearIFVGretest = false
var float retBullTop = na
var float retBullBot = na
var float retBearTop = na
var float retBearBot = na

float upBreak   = invPref == "Close" ? close : high
float downBreak = invPref == "Close" ? close : low

if zones.size() > 0
    for i = zones.size() - 1 to 0
        Zone z = zones.get(i)
        if not na(z.bx)
            box.set_right(z.bx, bar_index)
        if not na(z.ln)
            line.set_x2(z.ln, bar_index)
        if not z.inverted
            // FVG kendi yönünün tersine kırılırsa → inversion zone
            if z.dir == 1 and downBreak < z.bot
                z.inverted := true
                if na(z.bx)
                    z.bx := box.new(z.leftBar, z.top, bar_index, z.bot)
                box.set_bgcolor(z.bx, color.new(bearCol, 84))
                box.set_border_color(z.bx, color.new(bearCol, 40))
                box.set_border_style(z.bx, line.style_dashed)
                box.set_border_width(z.bx, 1)
                if showCE
                    z.ln := line.new(z.leftBar, (z.top + z.bot) / 2, bar_index, (z.top + z.bot) / 2,
                         color = color.new(bearCol, 60), style = line.style_dotted)
            else if z.dir == -1 and upBreak > z.top
                z.inverted := true
                if na(z.bx)
                    z.bx := box.new(z.leftBar, z.top, bar_index, z.bot)
                box.set_bgcolor(z.bx, color.new(bullCol, 84))
                box.set_border_color(z.bx, color.new(bullCol, 40))
                box.set_border_style(z.bx, line.style_dashed)
                box.set_border_width(z.bx, 1)
                if showCE
                    z.ln := line.new(z.leftBar, (z.top + z.bot) / 2, bar_index, (z.top + z.bot) / 2,
                         color = color.new(bullCol, 60), style = line.style_dotted)
        else
            if z.dir == -1
                // eski bearish FVG → şimdi bullish iFVG (support)
                if not z.signaled and low <= z.top and close > z.top
                    z.signaled := true
                    bullIFVGretest := true
                    lastBullIFVG := bar_index
                    retBullTop := z.top
                    retBullBot := z.bot
                if close < z.bot
                    box.delete(z.bx)
                    if not na(z.ln)
                        line.delete(z.ln)
                    zones.remove(i)
            else
                // eski bullish FVG → şimdi bearish iFVG (resistance)
                if not z.signaled and high >= z.bot and close < z.bot
                    z.signaled := true
                    bearIFVGretest := true
                    lastBearIFVG := bar_index
                    retBearTop := z.top
                    retBearBot := z.bot
                if close > z.top
                    box.delete(z.bx)
                    if not na(z.ln)
                        line.delete(z.ln)
                    zones.remove(i)

// ═══════════════════════════════ SMT VERİSİ ═════════════════════════════════

[corrHigh, corrLow] = request.security(smtSym, timeframe.period, [high, low])

float corrWinLow  = ta.lowest(corrLow, swingLen * 2 + 1)
float corrWinHigh = ta.highest(corrHigh, swingLen * 2 + 1)

// ═══════════════ PIVOTLAR: SWING, STRUCTURE (MSS), EQUAL H/L ════════════════

float ph = ta.pivothigh(swingLen, swingLen)
float pl = ta.pivotlow(swingLen, swingLen)

var float swHi       = na
var int   swHiBar    = na
var float swLo       = na
var int   swLoBar    = na
var float corrAtSwHi = na
var float corrAtSwLo = na
var float structHi   = na
var float structLo   = na
var float prevPH     = na
var float prevPL     = na
var bool  swHiIsEQ   = false
var bool  swLoIsEQ   = false

if not na(ph)
    swHi       := ph
    swHiBar    := bar_index - swingLen
    corrAtSwHi := corrWinHigh
    structHi   := ph
    swHiIsEQ   := not na(prevPH) and math.abs(ph - prevPH) <= eqTol * atr
    prevPH     := ph
if not na(pl)
    swLo       := pl
    swLoBar    := bar_index - swingLen
    corrAtSwLo := corrWinLow
    structLo   := pl
    swLoIsEQ   := not na(prevPL) and math.abs(pl - prevPL) <= eqTol * atr
    prevPL     := pl

// MSS: kapanış son swing'i kırar
bool bullMSS = useMSS and not na(structHi) and close > structHi and close[1] <= structHi
bool bearMSS = useMSS and not na(structLo) and close < structLo and close[1] >= structLo
if bullMSS
    lastBullMSS := bar_index
    structHi := na
if bearMSS
    lastBearMSS := bar_index
    structLo := na

// ═══════════════════ LIQUIDITY SWEEP + CISD (V-SHAPE) ═══════════════════════

// Sweep: swing fitille alınır ama kapanış seviyenin gerisinde kalır
bool bullSweep = not na(swLo) and low < swLo and close > swLo
bool bearSweep = not na(swHi) and high > swHi and close < swHi

// SMT sweep anında gerçek zamanlı: biz süpürdük, korele sembol süpüremedi
bool bullSMT = bullSweep and useSMT and not na(corrAtSwLo) and corrLow > corrAtSwLo
bool bearSMT = bearSweep and useSMT and not na(corrAtSwHi) and corrHigh < corrAtSwHi

var float pendBullCISD = na
var int   pendBullBar  = na
var bool  pendBullEQ   = false
var float pendBearCISD = na
var int   pendBearBar  = na
var bool  pendBearEQ   = false

if bullSweep
    lastBullSweep := bar_index
    if bullSMT
        lastBullSMT := bar_index
    if showSweeps
        line.new(swLoBar, swLo, bar_index, swLo,
             color = color.new(bullCol, 55), style = line.style_dotted)
    // CISD seviyesi: dibe koşan ardışık bearish mum serisinin ilk open'ı
    int j = close > open ? 1 : 0
    int cnt = 0
    while (j + cnt) < 30 and close[j + cnt] < open[j + cnt]
        cnt += 1
    pendBullCISD := cnt > 0 ? open[j + cnt - 1] : open[j]
    pendBullBar  := bar_index
    pendBullEQ   := useEQ and swLoIsEQ
    swLo := na

if bearSweep
    lastBearSweep := bar_index
    if bearSMT
        lastBearSMT := bar_index
    if showSweeps
        line.new(swHiBar, swHi, bar_index, swHi,
             color = color.new(bearCol, 55), style = line.style_dotted)
    // CISD seviyesi: tepeye koşan ardışık bullish mum serisinin ilk open'ı
    int j = close < open ? 1 : 0
    int cnt = 0
    while (j + cnt) < 30 and close[j + cnt] > open[j + cnt]
        cnt += 1
    pendBearCISD := cnt > 0 ? open[j + cnt - 1] : open[j]
    pendBearBar  := bar_index
    pendBearEQ   := useEQ and swHiIsEQ
    swHi := na

// Seviye kapanışla kırılırsa artık sweep değil — düşür
if not na(swLo) and close < swLo
    swLo := na
if not na(swHi) and close > swHi
    swHi := na

// Zaman aşımı
if not na(pendBullCISD) and bar_index - pendBullBar > cisdWindow
    pendBullCISD := na
if not na(pendBearCISD) and bar_index - pendBearBar > cisdWindow
    pendBearCISD := na

// CISD onayı = V-Shape Recovery tamam
bool dispOK     = dispAtrMult == 0.0 or body >= dispAtrMult * atr
bool bullVShape = not na(pendBullCISD) and close > pendBullCISD and dispOK and kzOK
bool bearVShape = not na(pendBearCISD) and close < pendBearCISD and dispOK and kzOK

// ═════════════════════ CONFLUENCE SKORU (8 BİLEŞEN) ═════════════════════════

int bullScore = 0
int bearScore = 0
var int    lastScore    = 0
var int    lastScoreDir = 0
var string lastChecks   = ""

if bullVShape
    bool cSMT  = lastBullSMT  >= pendBullBar - confWindow
    bool cIFVG = lastBullIFVG >= pendBullBar - confWindow
    bool cMSS  = lastBullMSS  >= pendBullBar - confWindow
    bool cPD   = usePD and close < eqMid
    bool cHTF  = useHTF and htfBias == 1
    bool cEQ   = pendBullEQ
    bool cKZ   = useKZ and inKZ
    bullScore := 1 + (cSMT ? 1 : 0) + (cIFVG ? 1 : 0) + (cMSS ? 1 : 0) +
         (cPD ? 1 : 0) + (cHTF ? 1 : 0) + (cEQ ? 1 : 0) + (cKZ ? 1 : 0)
    lastScore    := bullScore
    lastScoreDir := 1
    lastChecks := "Sweep+CISD ✓" + (cSMT ? "  SMT ✓" : "") + (cIFVG ? "  iFVG ✓" : "") +
         (cMSS ? "  MSS ✓" : "") + (cPD ? "  Discount ✓" : "") + (cHTF ? "  HTF ✓" : "") +
         (cEQ ? "  EQL ✓" : "") + (cKZ ? "  KZ ✓" : "")
    lastBullV := bar_index
    if showCISD
        line.new(pendBullBar, pendBullCISD, bar_index, pendBullCISD,
             color = bullCol, style = line.style_dashed)
    pendBullCISD := na

if bearVShape
    bool cSMT  = lastBearSMT  >= pendBearBar - confWindow
    bool cIFVG = lastBearIFVG >= pendBearBar - confWindow
    bool cMSS  = lastBearMSS  >= pendBearBar - confWindow
    bool cPD   = usePD and close > eqMid
    bool cHTF  = useHTF and htfBias == -1
    bool cEQ   = pendBearEQ
    bool cKZ   = useKZ and inKZ
    bearScore := 1 + (cSMT ? 1 : 0) + (cIFVG ? 1 : 0) + (cMSS ? 1 : 0) +
         (cPD ? 1 : 0) + (cHTF ? 1 : 0) + (cEQ ? 1 : 0) + (cKZ ? 1 : 0)
    lastScore    := bearScore
    lastScoreDir := -1
    lastChecks := "Sweep+CISD ✓" + (cSMT ? "  SMT ✓" : "") + (cIFVG ? "  iFVG ✓" : "") +
         (cMSS ? "  MSS ✓" : "") + (cPD ? "  Premium ✓" : "") + (cHTF ? "  HTF ✓" : "") +
         (cEQ ? "  EQH ✓" : "") + (cKZ ? "  KZ ✓" : "")
    lastBearV := bar_index
    if showCISD
        line.new(pendBearBar, pendBearCISD, bar_index, pendBearCISD,
             color = bearCol, style = line.style_dashed)
    pendBearCISD := na

bool bullConfluence = bullVShape and bullScore >= minScore
bool bearConfluence = bearVShape and bearScore >= minScore

if bullConfluence
    label.new(bar_index, low - atr * 0.5,
         "V-SHAPE ▲ " + str.tostring(bullScore) + "/8",
         style = label.style_label_up, size = size.small,
         color = color.new(bullCol, 15), textcolor = color.white,
         tooltip = lastChecks)
if bearConfluence
    label.new(bar_index, high + atr * 0.5,
         "V-SHAPE ▼ " + str.tostring(bearScore) + "/8",
         style = label.style_label_down, size = size.small,
         color = color.new(bearCol, 15), textcolor = color.white,
         tooltip = lastChecks)

// ═══════════════ ENTRY: V-SHAPE SONRASI iFVG RETEST + RİSK ══════════════════

bool bullEntry = showEntry and bullIFVGretest and (bar_index - lastBullV) <= confWindow and kzOK
bool bearEntry = showEntry and bearIFVGretest and (bar_index - lastBearV) <= confWindow and kzOK

float entrySL = na
float entryTP = na

if bullEntry
    entrySL := math.min(retBullBot, low) - 0.1 * atr
    entryTP := close + rrMult * (close - entrySL)
    if showRisk
        box.new(bar_index, close, bar_index + 12, entrySL,
             border_color = color.new(color.gray, 100), bgcolor = color.new(bearCol, 88))
        box.new(bar_index, entryTP, bar_index + 12, close,
             border_color = color.new(color.gray, 100), bgcolor = color.new(bullCol, 88))
        label.new(bar_index + 12, entryTP, "TP " + str.tostring(entryTP, format.mintick),
             style = label.style_label_left, color = color.new(color.black, 100),
             textcolor = bullCol, size = size.tiny)
        label.new(bar_index + 12, entrySL, "SL " + str.tostring(entrySL, format.mintick),
             style = label.style_label_left, color = color.new(color.black, 100),
             textcolor = bearCol, size = size.tiny)

if bearEntry
    entrySL := math.max(retBearTop, high) + 0.1 * atr
    entryTP := close - rrMult * (entrySL - close)
    if showRisk
        box.new(bar_index, entrySL, bar_index + 12, close,
             border_color = color.new(color.gray, 100), bgcolor = color.new(bearCol, 88))
        box.new(bar_index, close, bar_index + 12, entryTP,
             border_color = color.new(color.gray, 100), bgcolor = color.new(bullCol, 88))
        label.new(bar_index + 12, entryTP, "TP " + str.tostring(entryTP, format.mintick),
             style = label.style_label_left, color = color.new(color.black, 100),
             textcolor = bullCol, size = size.tiny)
        label.new(bar_index + 12, entrySL, "SL " + str.tostring(entrySL, format.mintick),
             style = label.style_label_left, color = color.new(color.black, 100),
             textcolor = bearCol, size = size.tiny)

// ═════════════════════════════ PLOTLAR ══════════════════════════════════════

plotshape(showSweeps and bullSweep, "Sweep ▲", shape.xcross, location.belowbar, color.new(bullCol, 30), size = size.tiny)
plotshape(showSweeps and bearSweep, "Sweep ▼", shape.xcross, location.abovebar, color.new(bearCol, 30), size = size.tiny)

plotshape(bullVShape and not bullConfluence, "V-Shape ▲", shape.diamond, location.belowbar, color.new(bullCol, 40), size = size.tiny)
plotshape(bearVShape and not bearConfluence, "V-Shape ▼", shape.diamond, location.abovebar, color.new(bearCol, 40), size = size.tiny)

plotshape(bullIFVGretest and not bullEntry, "iFVG Retest ▲", shape.triangleup, location.belowbar, color.new(bullCol, 45), size = size.tiny)
plotshape(bearIFVGretest and not bearEntry, "iFVG Retest ▼", shape.triangledown, location.abovebar, color.new(bearCol, 45), size = size.tiny)

plotshape(bullEntry, "ENTRY Long", shape.triangleup, location.belowbar, bullCol, size = size.small, text = "ENTRY", textcolor = bullCol)
plotshape(bearEntry, "ENTRY Short", shape.triangledown, location.abovebar, bearCol, size = size.small, text = "ENTRY", textcolor = bearCol)

plotshape(bullSMT, "SMT ▲", shape.circle, location.belowbar, color.new(bullCol, 55), size = size.tiny)
plotshape(bearSMT, "SMT ▼", shape.circle, location.abovebar, color.new(bearCol, 55), size = size.tiny)

// ═════════════════════════════ DURUM PANELİ ═════════════════════════════════

f_state(int bBar, int sBar) =>
    bBar == -99999 and sBar == -99999 ? "—" :
         bBar >= sBar ? "▲  " + str.tostring(bar_index - bBar) + " bar önce" :
         "▼  " + str.tostring(bar_index - sBar) + " bar önce"

f_col(int bBar, int sBar) =>
    bBar == -99999 and sBar == -99999 ? color.gray : bBar >= sBar ? bullCol : bearCol

var table tb = table.new(position.top_right, 2, 10,
     bgcolor = color.new(#131722, 5), border_width = 1,
     border_color = color.new(color.gray, 65),
     frame_width = 2, frame_color = color.new(color.gray, 45))

if showDash and barstate.islast
    color hdrBg = #0b0e14
    table.cell(tb, 0, 0, "  iFVG + V-SHAPE  ", text_color = color.white, text_size = size.small, bgcolor = hdrBg)
    table.cell(tb, 1, 0, "  Gurbetçi Trader  ", text_color = color.new(color.gray, 10), text_size = size.small, bgcolor = hdrBg)
    table.cell(tb, 0, 1, "  HTF Bias", text_color = color.new(color.gray, 15), text_size = size.small)
    table.cell(tb, 1, 1, htfBias == 1 ? "▲  BULLISH" : htfBias == -1 ? "▼  BEARISH" : "—",
         text_color = htfBias == 1 ? bullCol : htfBias == -1 ? bearCol : color.gray, text_size = size.small)
    table.cell(tb, 0, 2, "  Zone (P/D)", text_color = color.new(color.gray, 15), text_size = size.small)
    table.cell(tb, 1, 2, close < eqMid ? "DISCOUNT" : "PREMIUM",
         text_color = close < eqMid ? bullCol : bearCol, text_size = size.small)
    table.cell(tb, 0, 3, "  Killzone", text_color = color.new(color.gray, 15), text_size = size.small)
    table.cell(tb, 1, 3, inKZ ? "AKTİF" : "KAPALI",
         text_color = inKZ ? color.white : color.gray, text_size = size.small,
         bgcolor = inKZ ? color.new(bullCol, 60) : color.new(color.gray, 90))
    table.cell(tb, 0, 4, "  Sweep", text_color = color.new(color.gray, 15), text_size = size.small)
    table.cell(tb, 1, 4, f_state(lastBullSweep, lastBearSweep), text_color = f_col(lastBullSweep, lastBearSweep), text_size = size.small)
    table.cell(tb, 0, 5, "  V-Shape / CISD", text_color = color.new(color.gray, 15), text_size = size.small)
    table.cell(tb, 1, 5, f_state(lastBullV, lastBearV), text_color = f_col(lastBullV, lastBearV), text_size = size.small)
    table.cell(tb, 0, 6, "  MSS", text_color = color.new(color.gray, 15), text_size = size.small)
    table.cell(tb, 1, 6, f_state(lastBullMSS, lastBearMSS), text_color = f_col(lastBullMSS, lastBearMSS), text_size = size.small)
    table.cell(tb, 0, 7, "  iFVG Retest", text_color = color.new(color.gray, 15), text_size = size.small)
    table.cell(tb, 1, 7, f_state(lastBullIFVG, lastBearIFVG), text_color = f_col(lastBullIFVG, lastBearIFVG), text_size = size.small)
    table.cell(tb, 0, 8, "  SMT", text_color = color.new(color.gray, 15), text_size = size.small)
    table.cell(tb, 1, 8, f_state(lastBullSMT, lastBearSMT), text_color = f_col(lastBullSMT, lastBearSMT), text_size = size.small)
    table.cell(tb, 0, 9, "  SON SKOR", text_color = color.white, text_size = size.small, bgcolor = hdrBg)
    table.cell(tb, 1, 9, lastScore == 0 ? "—" : str.tostring(lastScore) + " / 8",
         text_color = color.white, text_size = size.small,
         bgcolor = lastScoreDir == 1 ? color.new(bullCol, 55) : lastScoreDir == -1 ? color.new(bearCol, 55) : hdrBg)

// ═══════════════════════ KULLANICIYA SİNYAL GÖNDERİMİ ═══════════════════════
// Alarm kurulumu: chart → Alert → Condition: bu indikatör →
// "Any alert() function call" → telefon push / e-posta / webhook.

if useAlerts and bullConfluence
    alert("🔵 V-SHAPE LONG | " + syminfo.ticker + " " + timeframe.period +
         " | Fiyat: " + str.tostring(close, format.mintick) +
         " | Skor: " + str.tostring(bullScore) + "/8 | " + lastChecks,
         alert.freq_once_per_bar_close)
if useAlerts and bearConfluence
    alert("🔴 V-SHAPE SHORT | " + syminfo.ticker + " " + timeframe.period +
         " | Fiyat: " + str.tostring(close, format.mintick) +
         " | Skor: " + str.tostring(bearScore) + "/8 | " + lastChecks,
         alert.freq_once_per_bar_close)
if useAlerts and bullEntry
    alert("🟢 ENTRY LONG (iFVG retest) | " + syminfo.ticker + " " + timeframe.period +
         " | E: " + str.tostring(close, format.mintick) +
         " | SL: " + str.tostring(entrySL, format.mintick) +
         " | TP " + str.tostring(rrMult, "#.#") + "R: " + str.tostring(entryTP, format.mintick),
         alert.freq_once_per_bar_close)
if useAlerts and bearEntry
    alert("🟠 ENTRY SHORT (iFVG retest) | " + syminfo.ticker + " " + timeframe.period +
         " | E: " + str.tostring(close, format.mintick) +
         " | SL: " + str.tostring(entrySL, format.mintick) +
         " | TP " + str.tostring(rrMult, "#.#") + "R: " + str.tostring(entryTP, format.mintick),
         alert.freq_once_per_bar_close)

alertcondition(bullConfluence, "Bullish V-Shape", "Bullish V-Shape Recovery (sweep + CISD + confluences)")
alertcondition(bearConfluence, "Bearish V-Shape", "Bearish V-Shape Recovery (sweep + CISD + confluences)")
alertcondition(bullEntry, "ENTRY Long (iFVG retest)", "Bullish iFVG retest after V-Shape Recovery")
alertcondition(bearEntry, "ENTRY Short (iFVG retest)", "Bearish iFVG retest after V-Shape Recovery")
alertcondition(bullIFVGretest, "Bullish iFVG Retest", "Price rejected from bullish inversion FVG")
alertcondition(bearIFVGretest, "Bearish iFVG Retest", "Price rejected from bearish inversion FVG")
alertcondition(bullSMT, "Bullish SMT (sweep)", "Bullish SMT divergence at liquidity sweep")
alertcondition(bearSMT, "Bearish SMT (sweep)", "Bearish SMT divergence at liquidity sweep")
````
