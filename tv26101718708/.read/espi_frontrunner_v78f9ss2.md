# ESPI Front-Runner

- url: https://www.tradingview.com/script/V78F9SS2-ESPI-Front-Runner/
- type: indicator
- pine_id: PUB;bfe88313386c4ed2997753dbf723ee61
- version: 4.0

## Description

📰 ESPI Front-Runner — "The Leak"

Detects unusual price and volume behavior in the window BEFORE corporate filings (ESPI on Warsaw Stock Exchange) or broker recommendations are published. The footprint of someone trading on information that isn't public yet — front-running, pre-disclosure leaks, or coordinated positioning before a known catalyst.

---
🧠 WHY IT WORKS
---

If price moves in the news direction before the news goes public, someone knew. Insiders, leaked drafts circulating in narrow client circles, recommendations distributed before official publication, sell-side desks tipping favored accounts — the channels are many, the footprint is the same. Price drifts toward the eventual reaction, volume builds quietly, and when the announcement finally hits, half the move is already done. This indicator anchors the analysis to the known event time and quantifies what happened in the run-up.

---
🔍 WHAT IT DETECTS
---

For each event you paste, the script computes three windows and a baseline:

📐 PRE — N bars before the event (did price already move?)
📐 POST — short reaction immediately after (T+1)
📐 POST EXT — extended reaction window (T+5, used to detect reload patterns)
📊 BASELINE — N bars further back (what does "normal" volume look like?)

Then it classifies the event into one of 11 anomaly types based on price moves, volume ratios, sentiment alignment, and cluster context.

---
🎨 ANOMALY CLASSES
---

🌊 SYSTEMATIC — 3+ same-direction confirmed leaks in a cluster (systemic, not isolated)
🎓 REC LEAK — price aligned with broker recommendation direction (event type R)
🔄 RELOAD — pre+, post-, post EXT+ with elevated volume (insider took profit and is reloading on pullback — NOT a sell-the-news)
🎯 CONFIRMED LEAK — pre-move aligned with sentiment of the filing
↔ CONTRARIAN — pre-move opposite to sentiment (fakeout, hedge, mispricing)
🐢 SLOW LEAK — small short-term move but large multi-week drift from a retroactive anchor (slow accumulation candidate)
🔴 PUMP LEAK — coordinated buying before event (sentiment unknown)
🟣 DUMP LEAK — coordinated selling before event (sentiment unknown)
🟡 STEALTH VOL — high volume without price movement (quiet positioning)
🟢 POST REACTION — quiet pre, large post (healthy reaction, no front-running)
⚪ ESPI — nothing interesting (standard event with no anomaly)

---
📊 HOW IT LOOKS
---

🟢 Green vertical line — positive ESPI filing
🔴 Red vertical line — negative ESPI filing
🟡 Yellow vertical line — neutral filing
🟣 Purple dashed line — broker recommendation (event type R)

🟥 Red box — pre-event window
🟩 Green box — post-event window
🟦 Cyan box — post-extended window (optional, for RELOAD analysis)

Each event gets a colored label with the anomaly class, sentiment tag (POS/NEG/NEU), and metrics: pre/post/post-ext returns and volume ratios. Multiple events on the same bar are aggregated into one label with a counter (e.g. "(3 ESPI)").

A summary label in the top-right corner shows aggregate stats: total events, leak count, reload count, stealth count, contrarian count.

---
📥 INPUT FORMAT
---

Paste lines into the Events field, one per line:

  <unix> [sentiment] [type] # comment

Examples:
  1776668400 +1 R # Trigon target 11.50 PLN
  1776259860 -1 E # ESPI 23/2026 Q1 loss
  1776259860 +1 # contract 50M PLN
  1776259860 # bare timestamp — defaults to neutral, ESPI

Sentiment: -1 / 0 / +1 (optional, default 0)
Type: E (filing) or R (recommendation) — optional, default E

🐍 GET THE EVENTS — Companion Python scraper

Get the scraper here: https://pastebin.com/2XPrvH8G
Save as espi_scraper.py, then:

  pip3 install requests beautifulsoup4

  # Find company ID on biznes.pap.pl
  python3 espi_scraper.py --list-companies "polimex"

  # Generate paste-ready output for selected years (sentiment auto-classified
  # from filing title, output ready to paste into the Events field)
  python3 espi_scraper.py <ID> 2026 2025 2024 2023 --paste

  # Pipe straight to clipboard
  python3 espi_scraper.py <ID> 2026 2025 --paste | pbcopy   # macOS
  python3 espi_scraper.py <ID> 2026 2025 --paste | xclip    # Linux

Then in TradingView: indicator settings → Events field → paste.

For broker recommendations (event type R), add lines manually with the
publication date — those aren't scraped.

---
⚙️ INPUTS
---

Pre / Post / Post EXT bars — analysis windows (HTF or auto-converted from minutes)
Baseline bars — background for volume ratio (default 20)
Recommendation pre-window multiplier — rec leaks earlier, default ×5 vs ESPI
Volume × baseline threshold — default 3.0×
Return % threshold — default 0.5%
Cluster N / K — search window and SYSTEMATIC threshold (default 3-of-5)
Slow leak anchor — optional retroactive anchor N bars back (default off)
Label size — tiny / small / normal (default) / large / huge

---
🎯 WHAT TO LOOK FOR
---

A single CONFIRMED LEAK is anecdotal. Look for clusters — that's what the SYSTEMATIC tag is for. Three or more same-direction leaks within five recent events on the same ticker is the strongest pattern this indicator surfaces.

REC LEAK with a 5-15 day pre-window means a recommendation circulated before publication. If the rally already covered most of the analyst's price target before the report went public, the report itself is no longer the catalyst — it's the exit liquidity.

RELOAD pattern (pre+/post-/post EXT+ with elevated post-ext volume) tells you the initial sell-off was a partial profit-take, not full distribution. Insiders who reload on the pullback are still long. The opposite — pre+/post-/post EXT- with collapsing volume — is a real sell-the-news.

SLOW LEAK with a 10-20 bar lookback catches multi-week accumulation that the standard pre-window misses. Useful for spotting recommendation front-running where the rally builds over a month, not days.

---
💡 PRO TIPS
---

Combine with VW Drift (Silent Accumulator) — a cluster of CONFIRMED LEAKs on a stock also flagging ACCUM means the same actor is positioning patiently AND timing news catalysts. Strongest dual signal in the toolkit.

Combine with Volume Profile Change Detector — a new cluster forming during the pre-window of a confirmed leak tells you the position is being built right now, at a specific price level.

Combine with AutomatOff — algos pulling away in the bars right before publication is a tell. Someone in the know is clearing the field.

Sentiment classification is rule-based on the filing title. Complex annexes (contract value increase vs cession vs scope change) can be misclassified. Edit sentiment manually in your paste if you spot one.

Broker recommendations are not publicly scraped — enter them manually with the publication date as event type R. The ×5 pre-window multiplier compensates for earlier circulation.

---
🌍 BUILT FOR
---

Warsaw Stock Exchange (GPW). The companion Python scraper (linked above) pulls filings from biznes.pap.pl and outputs the paste format directly. The indicator itself is market-agnostic — paste any event timestamps from any source on any ticker.

---
⚠️ DISCLAIMER
---

Research tool. Anomaly classifications are time correlations, not proof of manipulation. A single CONFIRMED LEAK is not a trade signal. Look for clusters, repeats, and confirmation across multiple toolkit indicators. Past performance doesn't guarantee future results. Not financial advice.

---

Open source. Part of the Smart Money Hunter / GPW Anomaly Detection toolkit.

## Source Code

````pine
// @version=6
// ESPI Front-Runner - "Przeciek"
// Wykrywa anomalie kursu/wolumenu w oknie T-N barow PRZED publikacja ESPI / rekomendacji.
//
// DANE:
//   Wklej w polu "ESPI events" linie w formacie:
//     <unix> [sentiment] [type] # komentarz
//   gdzie:
//     unix      - sekundy UTC
//     sentiment - -1 / 0 / +1 (opcjonalne, default 0)
//     type      - E (ESPI, default) lub R (Rekomendacja)
//
//   Przyklady:
//     1776668400 +1 R # Trigon target 11.50 PLN
//     1776259860 -1 E # ESPI 23/2026 strata na Q1
//     1776259860 # bez sentymentu i typu
//
//   Scraper: espi_scraper.py - pobiera z biznes.pap.pl
//     Online: https://pastebin.com/2XPrvH8G
//     python3 espi_scraper.py <ID_spolki> <rok> [rok2 ...] --paste
//     python3 espi_scraper.py --link <URL>   # pojedynczy artykul -> 1 linia paste
//
// TRYBY:
//   Auto:    Intraday <15m, HTF >=15m
//   Intraday: okna w minutach
//   HTF bars: okna w barach

indicator("ESPI Front-Runner", shorttitle="ESPI-FR", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ============== INPUTS ==============

grpPreset = "📋 Market Preset"
presetStr = input.string("Mid Cap (mWIG40 / sWIG80)", "Market preset",
     options=["Large Cap (WIG20)", "Mid Cap (mWIG40 / sWIG80)", "Small Cap (NewConnect)", "— Custom —"],
     group=grpPreset,
     tooltip="Auto-configures leak detection thresholds (volume multiplier, return %) for the selected segment.\nWindow sizes stay manual — they depend on chart timeframe, not market segment.")

_pL = presetStr == "Large Cap (WIG20)"
_pM = presetStr == "Mid Cap (mWIG40 / sWIG80)"
_pS = presetStr == "Small Cap (NewConnect)"
_pC = presetStr == "— Custom —"

grpData = "Dane ESPI / Rec"
espiRaw = input.text_area(defval="", title="Eventy (Unix sec UTC, jeden per linia)", group=grpData, tooltip="Format: <unix> [sentiment] [type=E|R] # komentarz. Sentiment: -1/0/+1. Type: E=ESPI, R=Rekomendacja.")

grpMode = "Tryb"
modeSel = input.string("Auto", "Tryb analizy", options=["Auto", "Intraday (minuty)", "HTF bars (bary)"], group=grpMode)

grpWindow  = "Okno analizy - Intraday"
leadMin    = input.int(5,   "Okno pre-ESPI (minuty)",   minval=1, maxval=60,  group=grpWindow)
postMin    = input.int(5,   "Okno post-ESPI (minuty)",  minval=1, maxval=60,  group=grpWindow)
postExtMin = input.int(60,  "Post EXT (minuty - reload check)", minval=15, maxval=600, group=grpWindow)
baseMin    = input.int(60,  "Baseline lookback (minuty)",minval=15,maxval=600, group=grpWindow)

grpHtf = "Okno analizy - HTF"
preBarsIn   = input.int(1,  "Pre bars",     minval=1, maxval=20, group=grpHtf)
postBarsIn  = input.int(1,  "Post bars (krotki)",    minval=1, maxval=20, group=grpHtf)
postExtBarsIn = input.int(2,"Post EXT bars (T+N reload check)", minval=2, maxval=30, group=grpHtf, tooltip="Drugie okno post liczace zachowanie 5-10 dni po evencie. Wylapuje RELOAD pattern (insider wraca po pullbacku).")
baseBarsIn  = input.int(20, "Baseline bars",minval=5, maxval=200,group=grpHtf)

grpRec = "Rekomendacje (event type=R)"
recPreMult = input.float(5.0, "Mnoznik pre-window dla R",  minval=1.0, maxval=20.0, step=0.5, group=grpRec, tooltip="Rekomendacje wycieka wczesniej - pre-window x5 vs ESPI")

grpThresh  = "Progi anomalii"
volMult_   = input.float(3.0, "Volume x baseline do alertu (Custom)", minval=1.5, step=0.5, group=grpThresh,
     tooltip="Preset values — WIG20: 2.5x  mWIG40: 3.0x  NewConnect: 4.0x")
retPct_    = input.float(0.5, "Return %  do alertu - |pre ret| (Custom)", minval=0.1, step=0.1, group=grpThresh,
     tooltip="Preset values — WIG20: 0.3%  mWIG40: 0.5%  NewConnect: 1.0%")
clusterN   = input.int(5,    "Klaster - przeszukaj ostatnie N eventow", minval=2, maxval=20, group=grpThresh)
clusterK   = input.int(3,    "Klaster - prog SYSTEMATIC (K leakow z N)", minval=2, maxval=10, group=grpThresh)

// ── Preset resolver ─────────────────────
// WIG20 = high liquidity, small moves significant → tighter thresholds
// mWIG40 = balanced default
// NewConnect = noisy / illiquid → require bigger spikes & moves to filter noise
volMult = _pC ? volMult_ : _pL ? 2.5 : _pM ? 3.0 : _pS ? 4.0 : volMult_
retPct  = _pC ? retPct_  : _pL ? 0.3 : _pM ? 0.5 : _pS ? 1.0 : retPct_

grpSlow = "Slow leak (opcjonalne)"
slowLookbackBars = input.int(0, "Slow leak anchor (bars wstecz, 0=off)", minval=0, maxval=30, group=grpSlow, tooltip="Liczy dodatkowy retPreSlow z anchora N barow wczesniej. Wylapuje wieloletnia akumulacja / rec front-run.")
slowMinPct       = input.float(5.0, "Slow leak min %", minval=1.0, step=0.5, group=grpSlow)

grpFilter = "Filtr wyswietlania"
onlySuspicious = input.bool(false, "Pokaz tylko podejrzane (⚠)", group=grpFilter)
hideBoxIfSilent= input.bool(false, "Ukryj boxy dla zwyklych eventow", group=grpFilter)
hideRec        = input.bool(false, "Ukryj rec eventy",     group=grpFilter)

grpView    = "Wyglad"
showBox    = input.bool(true,  "Rysuj box okna pre",  group=grpView)
showPost   = input.bool(true,  "Rysuj box okna post", group=grpView)
showPostExt= input.bool(false, "Rysuj box okna post EXT", group=grpView)
showLabel  = input.bool(true,  "Etykieta z metrykami",group=grpView)
showLine   = input.bool(true,  "Pionowa linia ESPI",  group=grpView)
labelStyle = input.string("Kompaktowy", "Styl etykiety", options=["Pelny", "Kompaktowy", "Minimal (ikona)"], group=grpView)
labelSize  = input.string("normal", "Rozmiar etykiety", options=["tiny", "small", "normal", "large", "huge"], group=grpView)
colPre     = input.color(color.new(color.red, 75),    "Kolor box pre",    group=grpView)
colPost    = input.color(color.new(color.green, 80),  "Kolor box post",   group=grpView)
colPostExt = input.color(color.new(color.aqua, 85),   "Kolor box post EXT", group=grpView)
colLine    = input.color(color.new(color.yellow, 50), "Kolor linii ESPI", group=grpView)
colRecLine = input.color(color.new(color.purple,40),  "Kolor linii REC",  group=grpView)

grpColors = "Kolory etykiet"
colConfirmed = input.color(color.new(#c0392b, 10), "🎯 CONFIRMED LEAK (kier. zgodny z newsem)", group=grpColors)
colSystematic= input.color(color.new(#7b241c, 0),  "🌊 SYSTEMATIC (klaster leakow)",            group=grpColors)
colReload    = input.color(color.new(#1abc9c, 10), "🔄 RELOAD (sell-then-buy)",                  group=grpColors)
colContrarian= input.color(color.new(#2980b9, 20), "↔ CONTRARIAN (kier. przeciwny)",            group=grpColors)
colPump      = input.color(color.new(#e74c3c, 30), "🔴 Pump leak (pre ⬆)",                       group=grpColors)
colDump      = input.color(color.new(#8e44ad, 30), "🟣 Dump leak (pre ⬇)",                       group=grpColors)
colStealth   = input.color(color.new(#f39c12, 20), "🟡 Stealth vol (sam wolumen)",               group=grpColors)
colMixed     = input.color(color.new(#16a085, 30), "🟢 Post reaction",                            group=grpColors)
colSlowLeak  = input.color(color.new(#34495e, 20), "🐢 Slow leak (rec kandydat)",                group=grpColors)
colRec       = input.color(color.new(#9b59b6, 10), "🎓 REC LEAK",                                 group=grpColors)
colQuiet     = input.color(color.new(color.gray, 60), "⚪ Nic ciekawego",                         group=grpColors)
colPosNews   = input.color(color.new(color.green, 60), "🟢 Linia pozytywnego ESPI",               group=grpColors)
colNegNews   = input.color(color.new(color.red,   60), "🔴 Linia negatywnego ESPI",               group=grpColors)

// ============== PARSE EVENTS ==============
// Format linii: <unix> [sentiment] [type] [# komentarz]
//   sentiment: -1 / 0 / +1 / +2 (opcjonalne, default 0)
//   type: E (ESPI) / R (Rekomendacja) - opcjonalne, default E
// Trzymamy 3 rownolegle tablice: timestamps, sentiments, types (0=E, 1=R)

f_parseEvents(string raw) =>
    tsArr   = array.new_int()
    sentArr = array.new_int()
    typeArr = array.new_int()
    if str.length(raw) > 0
        lines = str.split(raw, "\n")
        for i = 0 to array.size(lines) - 1
            ln = str.replace_all(array.get(lines, i), "\r", "")
            hashIdx = str.pos(ln, "#")
            work = not na(hashIdx) ? str.substring(ln, 0, hashIdx) : ln
            work := str.replace_all(work, "\t", " ")
            work := str.replace_all(work, ",",  " ")
            tokens = str.split(work, " ")
            clean = array.new_string()
            for j = 0 to array.size(tokens) - 1
                t = array.get(tokens, j)
                if str.length(t) > 0
                    array.push(clean, t)
            if array.size(clean) > 0
                tsVal = str.tonumber(array.get(clean, 0))
                if not na(tsVal) and tsVal > 946684800
                    sentVal = 0
                    typeVal = 0  // E
                    // Token 1: sentyment (jesli liczba) lub typ (jesli litera)
                    if array.size(clean) > 1
                        tok1 = array.get(clean, 1)
                        sv = str.tonumber(tok1)
                        if not na(sv)
                            sentVal := int(sv)
                            // Token 2 mogl byc typem
                            if array.size(clean) > 2
                                tok2 = str.upper(array.get(clean, 2))
                                if tok2 == "R"
                                    typeVal := 1
                                else if tok2 == "E"
                                    typeVal := 0
                        else
                            // Token 1 to typ
                            tu = str.upper(tok1)
                            if tu == "R"
                                typeVal := 1
                    array.push(tsArr,   int(tsVal))
                    array.push(sentArr, sentVal)
                    array.push(typeArr, typeVal)
    [tsArr, sentArr, typeArr]

var int[] events     = na
var int[] sentiments = na
var int[] eventTypes = na
if barstate.isfirst
    [ts, sn, tp] = f_parseEvents(espiRaw)
    events     := ts
    sentiments := sn
    eventTypes := tp

// ============== TRYB ==============
tfSec = timeframe.in_seconds(timeframe.period)
htfAuto  = tfSec >= 15 * 60
useHtf   = modeSel == "HTF bars (bary)" or (modeSel == "Auto" and htfAuto)

preBars     = useHtf ? preBarsIn     : math.max(1, math.round(leadMin    * 60 / tfSec))
postBars    = useHtf ? postBarsIn    : math.max(1, math.round(postMin    * 60 / tfSec))
postExtBars = useHtf ? postExtBarsIn : math.max(2, math.round(postExtMin * 60 / tfSec))
baseBars    = useHtf ? baseBarsIn    : math.max(1, math.round(baseMin    * 60 / tfSec))

barSizeMs = tfSec * 1000

// ============== STATE ==============

var line[]  lns     = array.new_line()
var box[]   bxPre   = array.new_box()
var box[]   bxPost  = array.new_box()
var box[]   bxPostX = array.new_box()
var label[] lbls    = array.new_label()
var int[]   drawnTs = array.new_int()        // E. dedup tracker
var int[]   drawnBars = array.new_int()      // D. dedup PER BAR (HTF agregacja)

// klasyfikacja rezultatu (dla cluster detection - zapisujemy wynik kazdego eventu)
// 0 = unknown / quiet, 1 = CONFIRMED POS, -1 = CONFIRMED NEG, 2 = CONTRARIAN, 3 = PUMP, -3 = DUMP, 4 = RELOAD, 5 = STEALTH
var int[] eventClass = array.new_int()
var int[] eventTsResolved = array.new_int()  // ts dla ktorego policzono klase

f_alreadyDrawn(int ts) =>
    found = false
    if array.size(drawnTs) > 0
        for i = 0 to array.size(drawnTs) - 1
            if array.get(drawnTs, i) == ts
                found := true
                break
    found

f_barAlreadyHasLabel(int barStartMs) =>
    found = false
    if array.size(drawnBars) > 0
        for i = 0 to array.size(drawnBars) - 1
            if array.get(drawnBars, i) == barStartMs
                found := true
                break
    found

// Liczy ile eventow dokladnie w tym samym barze (HTF agregacja)
f_countEventsInBar(int barStartMs) =>
    cnt = 0
    if not na(events) and array.size(events) > 0
        for i = 0 to array.size(events) - 1
            ts = array.get(events, i)
            tsMs = ts * 1000
            evBarStart = tsMs - (tsMs % barSizeMs)
            if evBarStart == barStartMs
                cnt += 1
    cnt

// Cluster check: ile CONFIRMED LEAK tego samego znaku w ostatnich N
f_clusterStreak(int currentClass) =>
    if currentClass != 1 and currentClass != -1
        0
    else
        cnt = 1
        sz = array.size(eventClass)
        if sz > 1
            from_idx = math.max(0, sz - clusterN)
            for k = sz - 1 to from_idx
                if k >= 0 and k < sz
                    cls = array.get(eventClass, k)
                    if cls == currentClass
                        cnt += 1
        cnt

// ============== LOGIKA GLOWNA ==============

// Alert flags — reset każdego bara, ustawiane gdy event jest przetwarzany po raz pierwszy
var bool _alertConfirmed  = false
var bool _alertContrarian = false
var bool _alertReload     = false
var bool _alertSystematic = false
var bool _alertStealth    = false
var bool _alertPump       = false
var bool _alertDump       = false
var bool _alertPostReact  = false
var bool _alertSlowLeak   = false
var bool _alertRecLeak    = false
var bool _alertSuspicious = false
_alertConfirmed  := false
_alertContrarian := false
_alertReload     := false
_alertSystematic := false
_alertStealth    := false
_alertPump       := false
_alertDump       := false
_alertPostReact  := false
_alertSlowLeak   := false
_alertRecLeak    := false
_alertSuspicious := false

if not na(events) and array.size(events) > 0
    for i = 0 to array.size(events) - 1
        ts = array.get(events, i)
        sent = not na(sentiments) and array.size(sentiments) > i ? array.get(sentiments, i) : 0
        evType = not na(eventTypes) and array.size(eventTypes) > i ? array.get(eventTypes, i) : 0
        isRec = evType == 1
        tsMs = ts * 1000

        // Dla rec - rozszerzony pre-window
        effPreBars = isRec ? math.max(1, math.round(preBars * recPreMult)) : preBars

        eventBarStart = tsMs - (tsMs % barSizeMs)
        postEnd       = eventBarStart + postBars * barSizeMs
        postExtEnd    = eventBarStart + (postBars + postExtBars) * barSizeMs
        preStart      = eventBarStart - effPreBars * barSizeMs

        // Czekamy az minie cale post-EXT okno - dopiero wtedy rysujemy (z RELOAD info)
        // Brak gornego limitu okna: gdy postExtEnd wypada na weekend/swieto GPW (brak baru),
        // nastepny bar tradingowy moglby przekroczyc postExtEnd + barSizeMs i event przepadal.
        // f_alreadyDrawn() zapobiega duplikatom - rysujemy na PIERWSZYM barze po postExtEnd.
        if time >= postExtEnd and not f_alreadyDrawn(ts) and not (isRec and hideRec)
            // Sprawdz czy ten bar juz ma labelke (D - agregacja per-bar)
            if f_barAlreadyHasLabel(eventBarStart)
                array.push(drawnTs, ts)  // mark as processed but skip drawing
                continue

            postExtFirst = 1
            postExtLast  = postExtBars
            postFirst    = postExtBars + 1
            postLast     = postExtBars + postBars
            preFirst     = postExtBars + postBars + 1
            preLast      = postExtBars + postBars + effPreBars
            baseFirst    = postExtBars + postBars + effPreBars + 1
            baseLast     = postExtBars + postBars + effPreBars + baseBars

            // Volumes
            baseVolSum = 0.0
            for k = baseFirst to baseLast
                baseVolSum += nz(volume[k])
            baseVolAvg = baseVolSum / baseBars

            preVolSum = 0.0
            for k = preFirst to preLast
                preVolSum += nz(volume[k])
            preVolAvg = preVolSum / effPreBars

            postVolSum = 0.0
            for k = postFirst to postLast
                postVolSum += nz(volume[k])
            postVolAvg = postVolSum / postBars

            postExtVolSum = 0.0
            for k = postExtFirst to postExtLast
                postExtVolSum += nz(volume[k])
            postExtVolAvg = postExtVolSum / postExtBars

            // Returns
            pPreAnchor  = close[preLast + 1]
            pPreEnd     = close[preFirst]
            retPre      = (pPreEnd / pPreAnchor - 1) * 100

            pPostAnchor = close[postLast + 1]
            pPostEnd    = close[postFirst]
            retPost     = (pPostEnd / pPostAnchor - 1) * 100

            pPostExtAnchor = close[postExtLast + 1]
            pPostExtEnd    = close[postExtFirst]
            retPostExt     = (pPostExtEnd / pPostExtAnchor - 1) * 100

            // F. Slow leak retroactive anchor
            retPreSlow = 0.0
            slowActive = slowLookbackBars > 0
            if slowActive
                slowAnchorIdx = preLast + 1 + slowLookbackBars
                pSlowAnchor = close[slowAnchorIdx]
                retPreSlow := (pPreEnd / pSlowAnchor - 1) * 100

            volRatio        = baseVolAvg > 0 ? preVolAvg     / baseVolAvg : 0.0
            volRatioPost    = baseVolAvg > 0 ? postVolAvg    / baseVolAvg : 0.0
            volRatioPostExt = baseVolAvg > 0 ? postExtVolAvg / baseVolAvg : 0.0

            // ========== KLASYFIKACJA ==========
            priceMove     = math.abs(retPre) >= retPct
            volSpike      = volRatio >= volMult
            suspicious    = priceMove or volSpike
            sameDirection = (retPre > 0 and retPost > 0) or (retPre < 0 and retPost < 0)

            sentimentKnown = sent != 0
            sentimentMatch = sentimentKnown and ((sent > 0 and retPre > 0) or (sent < 0 and retPre < 0))
            sentimentOpp   = sentimentKnown and ((sent > 0 and retPre < 0) or (sent < 0 and retPre > 0))

            sentStr = sent > 0 ? "📈 POS" : sent < 0 ? "📉 NEG" : "⏺ NEU"

            // RELOAD: pre+, post-, postExt+ z elevated vol
            isReloadUp   = retPre > 0 and retPost < 0 and retPostExt > 0 and volRatioPostExt > 1.0
            isReloadDown = retPre < 0 and retPost > 0 and retPostExt < 0 and volRatioPostExt > 1.0
            isReload     = priceMove and (isReloadUp or isReloadDown)

            // Slow leak detection
            isSlowLeak = slowActive and math.abs(retPreSlow) >= slowMinPct and math.abs(retPre) < retPct and volRatio > 1.0

            // Klasa numeryczna (do clustering)
            classNum = 0
            anomColor = colQuiet
            anomIcon  = "ESPI (" + sentStr + ")"

            if isRec and priceMove and ((sent > 0 and retPre > 0) or sent == 0 and retPre > 0)
                anomColor := colRec
                anomIcon  := "🎓 REC LEAK (" + sentStr + ")"
                classNum  := retPre > 0 ? 1 : -1
            else if isReload
                anomColor := colReload
                anomIcon  := "🔄 RELOAD (" + sentStr + ")"
                classNum  := 4
            else if priceMove and sentimentMatch
                anomColor := colConfirmed
                anomIcon  := "🎯 CONFIRMED LEAK (" + sentStr + ")"
                classNum  := retPre > 0 ? 1 : -1
            else if priceMove and sentimentOpp
                anomColor := colContrarian
                anomIcon  := "↔ CONTRARIAN (" + sentStr + ")"
                classNum  := 2
            else if priceMove and sameDirection and retPre > 0
                anomColor := colPump
                anomIcon  := "🔴 PUMP LEAK (" + sentStr + ")"
                classNum  := 3
            else if priceMove and sameDirection and retPre < 0
                anomColor := colDump
                anomIcon  := "🟣 DUMP LEAK (" + sentStr + ")"
                classNum  := -3
            else if volSpike and not priceMove
                anomColor := colStealth
                anomIcon  := "🟡 STEALTH VOL (" + sentStr + ")"
                classNum  := 5
            else if not priceMove and math.abs(retPost) >= retPct
                anomColor := colMixed
                anomIcon  := "🟢 POST REACTION (" + sentStr + ")"
                classNum  := 0
            else if priceMove
                anomColor := colPump
                anomIcon  := "⚠ MIXED LEAK (" + sentStr + ")"
                classNum  := retPre > 0 ? 3 : -3

            if isSlowLeak
                anomColor := colSlowLeak
                anomIcon  := "🐢 SLOW LEAK " + str.tostring(retPreSlow, "#.#") + "% / " + str.tostring(slowLookbackBars) + "b (" + sentStr + ")"
                classNum  := retPreSlow > 0 ? 1 : -1

            // Zapisz klasyfikacje do tablicy (do clustering)
            array.push(eventClass, classNum)
            array.push(eventTsResolved, ts)

            // B. Cluster / streak detection
            streak = f_clusterStreak(classNum)
            isSystematic = (classNum == 1 or classNum == -1) and streak >= clusterK
            if isSystematic
                anomColor := colSystematic
                anomIcon  := "🌊 SYSTEMATIC " + str.tostring(streak) + "/" + str.tostring(clusterN) + " " + (classNum > 0 ? "POS" : "NEG") + "\n" + anomIcon

            // ========== ALERT FLAGS ==========
            if suspicious or isReload or isSystematic or isSlowLeak
                _alertSuspicious := true
            if isSystematic
                _alertSystematic := true
            else if isRec and priceMove
                _alertRecLeak := true
            else if classNum == 4
                _alertReload := true
            else if classNum == 1 or classNum == -1
                _alertConfirmed := true
            else if classNum == 2
                _alertContrarian := true
            else if classNum == 3
                _alertPump := true
            else if classNum == -3
                _alertDump := true
            else if classNum == 5
                _alertStealth := true
            else if classNum == 0 and math.abs(retPost) >= retPct
                _alertPostReact := true
            if isSlowLeak
                _alertSlowLeak := true

            // ========== RYSOWANIE ==========
            lineCol = isRec ? colRecLine : (sent > 0 ? colPosNews : sent < 0 ? colNegNews : colLine)

            labelSz = labelSize == "tiny" ? size.tiny : labelSize == "small" ? size.small : labelSize == "normal" ? size.normal : labelSize == "large" ? size.large : size.huge

            eventCntInBar = f_countEventsInBar(eventBarStart)
            barSuffix = eventCntInBar > 1 ? " (" + str.tostring(eventCntInBar) + " ESPI)" : ""

            if not onlySuspicious or suspicious or isReload or isSystematic or isSlowLeak
                if showLine
                    lineStyle = isRec ? line.style_dashed : line.style_dotted
                    ln = line.new(tsMs, low - (high-low), tsMs, high + (high-low), xloc=xloc.bar_time, extend=extend.both, color=lineCol, width=isRec ? 2 : 1, style=lineStyle)
                    array.push(lns, ln)

                if showBox and (suspicious or not hideBoxIfSilent)
                    priceHi = ta.highest(high, effPreBars)[preFirst]
                    priceLo = ta.lowest (low,  effPreBars)[preFirst]
                    b = box.new(preStart, priceHi, eventBarStart, priceLo, xloc=xloc.bar_time, bgcolor=colPre, border_color=color.new(color.red, 30))
                    array.push(bxPre, b)

                if showPost and (suspicious or not hideBoxIfSilent)
                    priceHi2 = ta.highest(high, postBars)[postFirst]
                    priceLo2 = ta.lowest (low,  postBars)[postFirst]
                    b2 = box.new(eventBarStart, priceHi2, postEnd, priceLo2, xloc=xloc.bar_time, bgcolor=colPost, border_color=color.new(color.green, 30))
                    array.push(bxPost, b2)

                if showPostExt and (suspicious or isReload)
                    priceHi3 = ta.highest(high, postExtBars)[postExtFirst]
                    priceLo3 = ta.lowest (low,  postExtBars)[postExtFirst]
                    b3 = box.new(postEnd, priceHi3, postExtEnd, priceLo3, xloc=xloc.bar_time, bgcolor=colPostExt, border_color=color.new(color.aqua, 40))
                    array.push(bxPostX, b3)

                if showLabel
                    txt = ""
                    if labelStyle == "Minimal (ikona)"
                        txt := anomIcon + barSuffix
                    else if labelStyle == "Kompaktowy"
                        txt := anomIcon + barSuffix + "\n" +
                             "ret: " + str.tostring(retPre, "#.#") + "% → " + str.tostring(retPost, "#.#") + "% → " + str.tostring(retPostExt, "#.#") + "%\n" +
                             "vol: " + str.tostring(volRatio, "#.#") + "x → " + str.tostring(volRatioPost, "#.#") + "x → " + str.tostring(volRatioPostExt, "#.#") + "x"
                    else  // Pelny
                        modeStr = useHtf ? "HTF" : "INTRA"
                        unit    = useHtf ? "bars" : "min"
                        slowLine = slowActive ? "\nslow ret: " + str.tostring(retPreSlow, "#.##") + "% / " + str.tostring(slowLookbackBars) + "b" : ""
                        txt := anomIcon + barSuffix + "\n" +
                             "[" + modeStr + " " + str.tostring(effPreBars) + "/" + str.tostring(postBars) + "/" + str.tostring(postExtBars) + " " + unit + "]\n" +
                             "pre ret: "  + str.tostring(retPre,     "#.##") + "%\n" +
                             "post ret: " + str.tostring(retPost,    "#.##") + "%\n" +
                             "post EXT: " + str.tostring(retPostExt, "#.##") + "%\n" +
                             "pre vol: "      + str.tostring(volRatio,        "#.##") + "x\n" +
                             "post vol: "     + str.tostring(volRatioPost,    "#.##") + "x\n" +
                             "post EXT vol: " + str.tostring(volRatioPostExt, "#.##") + "x" +
                             slowLine

                    // Kotwica Y w high baru eventu (offset = postExtBars + postBars wstecz),
                    // a nie w high CURRENT baru — inaczej etykiety lataja po wykresie
                    // zaleznie od tego gdzie kurs aktualnie sie znajduje.
                    eventBarOffset = postExtBars + postBars
                    labelY = high[eventBarOffset]
                    lb = label.new(tsMs, labelY, txt, xloc=xloc.bar_time, style=label.style_label_down, color=anomColor, textcolor=color.white, size=labelSz)
                    array.push(lbls, lb)

                array.push(drawnBars, eventBarStart)

            array.push(drawnTs, ts)

// ============== INFO LABEL ==============
if barstate.islast and not na(events)
    var label infoLbl = na
    if not na(infoLbl)
        label.delete(infoLbl)

    // Statystyki agregowane
    nTotal = array.size(events)
    nProcessed = array.size(eventClass)
    nConfirmed = 0
    nReload = 0
    nStealth = 0
    nContrarian = 0
    if nProcessed > 0
        for i = 0 to nProcessed - 1
            cls = array.get(eventClass, i)
            if cls == 1 or cls == -1
                nConfirmed += 1
            else if cls == 4
                nReload += 1
            else if cls == 5
                nStealth += 1
            else if cls == 2
                nContrarian += 1

    infoTxt = "ESPI: " + str.tostring(nTotal) + " events\n" +
              "🎯 leak: " + str.tostring(nConfirmed) + "  🔄 reload: " + str.tostring(nReload) + "\n" +
              "🟡 stealth: " + str.tostring(nStealth) + "  ↔ contrarian: " + str.tostring(nContrarian)
    infoLbl := label.new(bar_index, high, infoTxt, style=label.style_label_left, color=color.new(color.blue, 50), textcolor=color.white, size=size.small)

// ============== ALERTS ==============

alertcondition(_alertSystematic,
     title   = "ESPI-FR — Systematic Cluster",
     message = "🌊 ESPI-FR SYSTEMATIC: repeated leak pattern — {{ticker}} @ {{close}}")

alertcondition(_alertConfirmed,
     title   = "ESPI-FR — Confirmed Leak",
     message = "🎯 ESPI-FR CONFIRMED LEAK: pre-ESPI move matches news direction — {{ticker}} @ {{close}}")

alertcondition(_alertRecLeak,
     title   = "ESPI-FR — Recommendation Leak",
     message = "🎓 ESPI-FR REC LEAK: pre-rec move detected — {{ticker}} @ {{close}}")

alertcondition(_alertReload,
     title   = "ESPI-FR — Reload Pattern",
     message = "🔄 ESPI-FR RELOAD: sell-then-buy or buy-then-sell pattern — {{ticker}} @ {{close}}")

alertcondition(_alertContrarian,
     title   = "ESPI-FR — Contrarian",
     message = "↔ ESPI-FR CONTRARIAN: pre-move opposite to news — {{ticker}} @ {{close}}")

alertcondition(_alertPump,
     title   = "ESPI-FR — Pump Leak",
     message = "🔴 ESPI-FR PUMP LEAK: pre-ESPI upward move — {{ticker}} @ {{close}}")

alertcondition(_alertDump,
     title   = "ESPI-FR — Dump Leak",
     message = "🟣 ESPI-FR DUMP LEAK: pre-ESPI downward move — {{ticker}} @ {{close}}")

alertcondition(_alertStealth,
     title   = "ESPI-FR — Stealth Volume",
     message = "🟡 ESPI-FR STEALTH: volume spike without price move — {{ticker}} @ {{close}}")

alertcondition(_alertSlowLeak,
     title   = "ESPI-FR — Slow Leak",
     message = "🐢 ESPI-FR SLOW LEAK: multi-session drift before ESPI — {{ticker}} @ {{close}}")

alertcondition(_alertSuspicious,
     title   = "ESPI-FR — Any Suspicious",
     message = "⚠️ ESPI-FR: suspicious activity detected around ESPI event — {{ticker}} @ {{close}}")
````
