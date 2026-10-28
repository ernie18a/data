# Previous Day Pivot Path - Intraday Support Resistance

- url: https://www.tradingview.com/script/Ut6UZYdO-Previous-Day-Pivot-Path-Intraday-Support-Resistance/
- type: indicator
- pine_id: PUB;39440c054e87409e869908724a492f3e
- version: 2.0

## Description

Previous Day Pivot Path - Intraday Support Resistance

Overview

Previous Day Pivot Path is an intraday reference-level study built from the confirmed OHLC values of the previous selected trading day. It plots the current day's central pivot and support/resistance levels, then records the first chart bar in which each level is reached and assigns a compact arrival rank.

The script is intended for traders and researchers who want to identify the current day's mathematically derived reference levels without converting them into buy/sell instructions. It does not predict whether a level will hold or break, and it does not present win-rate, profitability, or performance claims.

What makes this implementation different

1. First-arrival path instead of static lines only

Each tracked level begins the day as pending. When the selected price source first reaches it, the script records an arrival rank and can place a numbered badge at the corresponding time.

If more than one previously unreached level is reached in the same chart bar, those levels receive the same rank. OHLC bars do not reveal the true tick-by-tick order inside that bar, so the script deliberately avoids inventing an intrabar sequence that the available data cannot prove.

2. Reached-level fading and next-level focus

Reached levels can fade automatically. The nearest unreached level can receive stronger line emphasis and an optional translucent focus halo. After all displayed levels have been reached, the focus can fall back to the nearest level or remain inactive.

This visual hierarchy separates completed parts of the day's path from levels that remain unvisited, while preserving the exact horizontal prices.

3. Confirmed previous-day data

All daily formula inputs are requested from the last completed daily bar. Open time, close time, open, high, low, and close are all offset by one daily bar before they are used. The current developing daily high, low, or close is never used in the pivot formulas.

The script also checks that the completed daily session is chronologically aligned with the selected intraday source day before it initializes new levels or arrival events.

4. Source-session freshness protection

Three OHLC source modes are available:

- Automatic: uses chart-context OHLC on standard candles and standard-symbol OHLC on non-standard charts.
- Chart context: preserves the chart's ticker modifiers, session, adjustment, and chart-type context.
- Standard symbol: removes non-standard ticker modifiers and uses standard market OHLC.

When the selected standard source has no bar aligned with the current chart timestamp, the script does not reuse an old forward-filled OHLC value. Arrival events pause, and existing drawings remain fixed at the last valid source bar until aligned data becomes available again.

5. Session-aware day handling

The script uses a trading-day key suitable for markets whose sessions cross midnight. This prevents a simple calendar-date change from being treated as the session boundary on many overnight Forex and futures markets.

If the first loaded dataset begins after the selected source day's opening bar, the earlier first-arrival sequence is unknowable. For that one partial day, arrival tracking and open-dependent features are conservatively bypassed rather than reconstructed from incomplete history.

6. Time-anchored persistent drawings

Persistent lines, boxes, right-edge labels, and arrival badges use UNIX-time coordinates. This avoids relying on very old bar_index coordinates on dense second charts and keeps historical drawings independent of the number of bars elapsed since their creation.

7. Multiple formula families plus an editable research mode

The script includes:

- Traditional
- Classic
- Fibonacci
- Camarilla
- Custom research

The custom mode lets users select the pivot center and edit three previous-range multipliers. The multipliers are sorted from smallest to largest before assignment to R1/S1, R2/S2, and R3/S3.

8. Price-grid and duplicate-level controls

Calculated levels can remain raw, round to the nearest minimum tick, or round outward so resistance is rounded upward and support downward. When rounding produces the same price for multiple logical levels, the script can merge them into one line and one badge with a combined code such as P/R1.

9. Researchable arrival definitions

Users can define a first arrival with:

- Wick range
- Candle body range
- Confirmed close crossing

Optional tolerance can be exact, a number of ticks, or a percentage of the previous-day range. Gap crossings can be counted or ignored. Arrival ranking can follow only displayed levels, the selected depth, or all levels produced by the formula.

10. Deliberate chart hygiene

The default presentation prioritizes P, R1/S1, and then outer levels through width, line style, transparency, and optional reached-level fading. Right-edge labels support automatic text contrast and horizontal lane staggering when prices are close.

Optional context references include:

- Central Pivot Range (CPR)
- Previous-day high and low (PDH/PDL)
- Previous-day close (PDC)
- Current selected-source day open
- Opening bracket between the nearest displayed levels above and below the day open
- Compact session brief

All context elements can be disabled independently.

Formula reference

Let O, H, L, and C be the confirmed previous selected daily bar, and let Range = H - L.

Traditional

P  = (H + L + C) / 3
R1 = 2P - L
S1 = 2P - H
R2 = P + Range
S2 = P - Range
R3 = H + 2(P - L)
S3 = L - 2(H - P)

Classic

P  = (H + L + C) / 3
R1 = 2P - L
S1 = 2P - H
R2 = P + Range
S2 = P - Range
R3 = P + 2Range
S3 = P - 2Range

Fibonacci

P  = (H + L + C) / 3
R1/S1 = P +/- 0.382 x Range
R2/S2 = P +/- 0.618 x Range
R3/S3 = P +/- 1.000 x Range

Camarilla

P  = (H + L + C) / 3
R1/S1 = C +/- 1.1 x Range / 12
R2/S2 = C +/- 1.1 x Range / 6
R3/S3 = C +/- 1.1 x Range / 4


Custom research

The center can be HLC3, HLCC4, OHLC4, midpoint, or previous close. Three editable multipliers are applied symmetrically to the previous-day range after being sorted from smallest to largest.

Arrival timing

Confirmed bar

This is the reproducible default. An arrival is recorded only after the chart bar is confirmed.

Live bar

Live timing is available for wick arrivals. Intrabar-persistent state latches a wick touch across realtime updates of the open bar. Because all levels first reached inside the same chart bar share one rank, the script does not claim a tick-level order that bar data cannot establish.

Body and close-cross modes automatically use confirmed bars to avoid transient open-bar signals.

Non-standard charts

Heikin-Ashi, Renko, Kagi, Line Break, Point & Figure, and Range bars can be synthetic or approximate. Automatic mode uses standard-symbol OHLC for the level and event source on non-standard charts, but arrival events are paused by default. Users can explicitly allow them for research after accepting the chart-type limitation.

The script is designed for time-based intraday charts. Tick charts and daily-or-higher charts are intentionally rejected with a visible notice rather than processed with ambiguous session assumptions.

Language and user interface

English is the default dynamic chart language. Selecting 日本語 changes dynamic labels, tooltips, safety notices, session-brief text, and language-aware alert() messages. Input names remain short bilingual labels so both English and Japanese users can configure the study.

Key Japanese UI translations:

未到達 = Pending
到達 = Reached
確定足 = Confirmed bar
ライブ・ヒゲ保持 = Live wick latch
前日値幅 = Prior range
次の未到達 = Next unreached
準備完了 = Ready
ソース足なし = Source bar unavailable
日次データ整合待ち = Aligning daily data
合成足イベント停止 = Synthetic events paused

International level codes such as P, R1, S1, PDH, and PDL remain unchanged in both languages.

Alerts

Neutral alert conditions are available for:

- Any pivot's first arrival
- P, R1, S1, R2, S2, R3, and S3 first arrivals
- Confirmed close crossing above or below P

An optional language-aware alert() call can include the reached level codes, shared rank, symbol, timeframe, and selected calculation method. Alerts describe observable level events only; they are not trade recommendations.

Suggested workflow

1. Use a standard candlestick intraday chart for the most direct interpretation.
2. Keep Automatic, Traditional, Nearest tick, Confirmed bar, and Wick for the conservative defaults.
3. Select the desired level depth and optional previous-day references.
4. Enable live timing only when intrabar wick monitoring is required.
5. Create alerts from the neutral first-arrival or confirmed P-cross conditions as needed.
6. Use Market Replay and several symbols/session types before relying on customized settings.

Important limitations

- A previous-day pivot is a mathematical reference, not a prediction that price will reverse or continue.
- Data vendors can revise historical bars, and exchange session definitions can differ across instruments.
- Standard-symbol mode can intentionally have no aligned bar outside its selected session. In that case, events pause instead of carrying stale OHLC forward.
- The first loaded partial source day cannot provide a complete earlier arrival sequence.
- A chart bar cannot prove the order of multiple level touches inside that bar; those first touches share one rank.
- Live wick tracking reacts to realtime updates. Reloaded historical bars contain finalized OHLC, not the original tick stream.
- Synthetic chart bars may not represent executable market prices. Arrival tracking on such charts is disabled by default.
- The study does not provide entries, exits, position sizing, stop placement, or performance statistics.


日本語説明

概要

Previous Day Pivot Pathは、選択したデータソースの確定済み前日OHLCから、当日のP・R・Sを自動計算して描画する日中足向けインジケーターです。

単に水平線を表示するだけではなく、各水準へ当日初めて到達したチャート足を記録し、到達順を番号で表示できます。売買推奨、勝率、収益性、将来予測を提示するものではなく、当日の数理的な節目と到達経路を研究するためのツールです。

主な特徴

初回到達経路

各水準は当日開始時に未到達状態となり、選択した価格ソースが初めて到達すると順位を記録します。同じチャート足の中で複数水準へ初回到達した場合、その足の内部順序はOHLCだけでは証明できないため、すべて同順位とします。

確定前日OHLC

日足リクエストでは、時刻・始値・高値・安値・終値のすべてを1本前へオフセットして使用します。形成中の日足高安や終値はピボット計算に使いません。

ソース欠損時の安全処理

標準銘柄ソースに現在時刻と一致する足がない場合、過去のOHLCを現在足へ持ち越して判定しません。到達イベントを停止し、既存描画を最終有効ソース足で固定します。

夜間市場を考慮した日付管理

Forexや先物など、セッションが日付をまたぐ市場に対応するため、単純なカレンダー日ではなく取引日キーを使用します。

秒足で古くなった描画への耐性

長期間保持する線、ボックス、到達バッジ、右端ラベルはUNIX時刻座標で管理します。高密度な秒足でも、古いbar_index座標による制限へ近づきにくい設計です。

5種類の計算方式

Traditional、Classic、Fibonacci、Camarilla、Custom researchを選択できます。Custom researchでは中心値と3つの前日値幅倍率を変更できます。

到達判定の研究性

ヒゲ、実体、確定終値通過から選択でき、許容幅は厳密一致、ティック数、前日値幅比率から設定できます。ギャップ通過を到達扱いにするかも切替可能です。

視認性

到達済み水準のフェード、最寄り未到達水準の強調、フォーカスハロー、自動文字コントラスト、近接ラベルの横方向段組みを実装しています。

CPR、前日高安、前日終値、当日始値、始値ブラケット、セッション概要は個別に表示・非表示を変更できます。

推奨初期設定

OHLC source             Automatic
Pivot method            Traditional
Level rounding          Nearest tick
Arrival timing          Confirmed bar
Arrival basis           Wick
Touch tolerance         Exact
Arrival universe        Displayed levels
Synthetic chart events  Off
Auto-stagger labels     On
Auto contrast           On
Focus halo              On

ライブ中のヒゲ到達を監視するときだけ、Arrival timingをLive barへ変更してください。実体・終値通過は安全のため確定足判定になります。

言語切替

Language / 言語でEnglishまたは日本語を選択できます。日本語へ切り替えると、チャート上の動的ラベル、ツールチップ、安全性メッセージ、セッション概要、言語連動alert()が日本語になります。

P、R1、S1、PDH、PDLなどの国際共通コードは両言語で同じ表記です。

重要な注意事項

- ピボットは数理的な参照水準であり、反転やブレイクを保証しません。
- 読み込み初日が選択ソースの日中途中から始まる場合、それ以前の到達順は復元できないため、その日だけ経路追跡を停止します。
- 1本の足内で複数水準へ触れた正確な順序はOHLCから判定できないため、同順位になります。
- 標準銘柄ソースのセッション外では、古い価格を流用せず到達判定を停止します。
- Heikin-Ashi、Renko、Kagiなどの合成足では、到達イベントを既定で停止しています。
- Live barのヒゲ到達はリアルタイム更新に反応します。再読み込み後の履歴足には最終OHLCが残り、当時のティック列そのものは残りません。
- 本インジケーターはエントリー、決済、ストップ、ロット、成績表を提供しません。

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SG_Group
//@version=6
indicator(
     "Previous Day Pivot Path - Intraday Support Resistance",
     overlay = true,
     dynamic_requests = true,
     max_lines_count = 500,
     max_labels_count = 500,
     max_boxes_count = 100)

//==============================================================================
// Constants
//==============================================================================
const string GROUP_CORE    = "1. Core and data"
const string GROUP_METHOD  = "2. Pivot calculation"
const string GROUP_PATH    = "3. First-arrival path"
const string GROUP_CONTEXT = "4. Context references"
const string GROUP_VISUAL  = "5. Visual design"
const string GROUP_BRIEF   = "6. Session brief"
const string GROUP_ALERTS  = "7. Alerts"

const int LEVEL_COUNT   = 7
const int CONTEXT_COUNT = 6

const int IDX_P  = 0
const int IDX_R1 = 1
const int IDX_S1 = 2
const int IDX_R2 = 3
const int IDX_S2 = 4
const int IDX_R3 = 5
const int IDX_S3 = 6

const int CTX_CPR_HIGH = 0
const int CTX_CPR_LOW  = 1
const int CTX_PDH      = 2
const int CTX_PDL      = 3
const int CTX_PDC      = 4
const int CTX_OPEN     = 5

// Priority decides which logical level owns a same-price drawing after rounding.
var array<int> LEVEL_PRIORITY = array.from(IDX_P, IDX_R1, IDX_S1, IDX_R2, IDX_S2, IDX_R3, IDX_S3)

//==============================================================================
// Inputs
// Every input uses display.none, so the status line shows only the full indicator title.
//==============================================================================
string sourceModeInput = input.string(
     "Automatic",
     "OHLC source",
     options = ["Automatic", "Chart context", "Standard symbol"],
     tooltip = "Automatic follows chart-context OHLC on standard candles and uses standard-symbol OHLC on synthetic charts. Chart context preserves chart modifiers. Standard symbol removes non-standard chart, session, adjustment, and other ticker modifiers. When that source has no bar, stale prices are never carried forward; drawings freeze and events pause until its next valid bar.",
     group = GROUP_CORE,
     display = display.none)

int historyDaysInput = input.int(
     3,
     "Visible exchange days",
     minval = 1,
     maxval = 15,
     tooltip = "Includes the current exchange day. Historical right-edge labels are not retained to reduce clutter.",
     group = GROUP_CORE,
     display = display.none)

string methodInput = input.string(
     "Traditional",
     "Pivot method",
     options = ["Traditional", "Classic", "Fibonacci", "Camarilla", "Custom research"],
     tooltip = "All methods use the confirmed previous daily bar. Custom research exposes an editable pivot center and three previous-range multipliers.",
     group = GROUP_METHOD,
     display = display.none)

string depthInput = input.string(
     "Standard",
     "Level depth",
     options = ["Essential", "Standard", "Expanded"],
     tooltip = "Essential: P, R1, S1\nStandard: adds R2, S2\nExpanded: adds R3, S3",
     group = GROUP_METHOD,
     display = display.none)

bool showPivotInput = input.bool(
     true,
     "Show P",
     inline = "showLevels",
     group = GROUP_METHOD,
     display = display.none)

bool showResistanceInput = input.bool(
     true,
     "Show R",
     inline = "showLevels",
     group = GROUP_METHOD,
     display = display.none)

bool showSupportInput = input.bool(
     true,
     "Show S",
     inline = "showLevels",
     group = GROUP_METHOD,
     display = display.none)

float reachLimitInput = input.float(
     0.0,
     "Distance display filter in prior ranges",
     minval = 0.0,
     maxval = 10.0,
     step = 0.25,
     tooltip = "0 disables the filter. Otherwise, R/S levels farther than this many previous-day ranges from the selected fixed anchor are hidden. P is retained.",
     group = GROUP_METHOD,
     display = display.none)

string filterAnchorInput = input.string(
     "Day open",
     "Distance-filter anchor",
     options = ["Day open", "Pivot P", "Previous close"],
     tooltip = "Day open is frozen from the first available source bar of the exchange day. If a loaded dataset starts mid-day, the filter is safely bypassed for that first partial day.",
     group = GROUP_METHOD,
     active = reachLimitInput > 0.0,
     display = display.none)

string roundingModeInput = input.string(
     "Nearest tick",
     "Level rounding",
     options = ["Raw", "Nearest tick", "Outward tick"],
     tooltip = "Raw preserves the mathematical value. Nearest tick aligns every level to the symbol tick. Outward tick rounds R upward, S downward, and P to the nearest tick.",
     group = GROUP_METHOD,
     display = display.none)

bool suppressDuplicatesInput = input.bool(
     true,
     "Merge duplicate rounded levels",
     tooltip = "Same-price levels share one line and one badge, with a combined code such as P/R1. Hidden levels never suppress visible levels.",
     group = GROUP_METHOD,
     display = display.none)

string customBasisInput = input.string(
     "HLC3",
     "Custom pivot basis",
     options = ["HLC3", "HLCC4", "OHLC4", "Midpoint", "Previous close"],
     group = GROUP_METHOD,
     active = methodInput == "Custom research",
     display = display.none)

float customMultiplier1Input = input.float(
     0.382,
     "Custom range multiplier 1",
     minval = 0.0,
     maxval = 10.0,
     step = 0.001,
     group = GROUP_METHOD,
     active = methodInput == "Custom research",
     display = display.none)

float customMultiplier2Input = input.float(
     0.618,
     "Custom range multiplier 2",
     minval = 0.0,
     maxval = 10.0,
     step = 0.001,
     group = GROUP_METHOD,
     active = methodInput == "Custom research",
     display = display.none)

float customMultiplier3Input = input.float(
     1.000,
     "Custom range multiplier 3",
     minval = 0.0,
     maxval = 10.0,
     step = 0.001,
     tooltip = "The three values are sorted from smallest to largest before use.",
     group = GROUP_METHOD,
     active = methodInput == "Custom research",
     display = display.none)

bool trackArrivalInput = input.bool(
     true,
     "Track first-arrival path",
     group = GROUP_PATH,
     display = display.none)

string eventTimingInput = input.string(
     "Confirmed bar",
     "Arrival timing",
     options = ["Confirmed bar", "Live bar"],
     tooltip = "Confirmed bar is the reproducible default. Live bar latches wick touches across realtime updates with varip state. Body and close-cross modes automatically use confirmed bars to avoid transient signals.",
     group = GROUP_PATH,
     active = trackArrivalInput,
     display = display.none)

string touchBasisInput = input.string(
     "Wick",
     "Arrival basis",
     options = ["Wick", "Body", "Close cross"],
     tooltip = "Wick uses High/Low. Body uses the Open/Close range. Close cross requires a confirmed close crossing the level.",
     group = GROUP_PATH,
     active = trackArrivalInput,
     display = display.none)

string toleranceModeInput = input.string(
     "Exact",
     "Touch tolerance",
     options = ["Exact", "Ticks", "Prior range %"],
     group = GROUP_PATH,
     active = trackArrivalInput,
     display = display.none)

float toleranceTicksInput = input.float(
     0.0,
     "Tolerance ticks",
     minval = 0.0,
     maxval = 1000.0,
     step = 0.25,
     group = GROUP_PATH,
     active = trackArrivalInput and toleranceModeInput == "Ticks",
     display = display.none)

float toleranceRangePercentInput = input.float(
     0.0,
     "Tolerance as prior-range %",
     minval = 0.0,
     maxval = 25.0,
     step = 0.01,
     tooltip = "1.00 means one percent of the previous-day range on each side of the level.",
     group = GROUP_PATH,
     active = trackArrivalInput and toleranceModeInput == "Prior range %",
     display = display.none)

bool countGapCrossingsInput = input.bool(
     false,
     "Count opening gap crossings",
     tooltip = "When enabled, a gap from the previous source close to the current source open that jumps across a level counts as an arrival even if no trade prints at that price. Off is the stricter touch-only interpretation.",
     group = GROUP_PATH,
     active = trackArrivalInput,
     display = display.none)

string arrivalScopeInput = input.string(
     "Displayed levels",
     "Arrival universe",
     options = ["Displayed levels", "Selected depth", "All formula levels"],
     tooltip = "Displayed levels follows every display filter. Selected depth ignores only the distance filter. All formula levels also ignores depth and P/R/S visibility.",
     group = GROUP_PATH,
     active = trackArrivalInput,
     display = display.none)

bool allowSyntheticEventsInput = input.bool(
     false,
     "Allow events on synthetic charts",
     tooltip = "Off pauses path events on Heikin-Ashi, Renko, Kagi, Line Break, P&F, Range, and similar charts because their bar sequence can be synthetic. Levels still display.",
     group = GROUP_PATH,
     active = trackArrivalInput,
     display = display.none)

bool showArrivalBadgesInput = input.bool(
     true,
     "Show first-arrival sequence",
     tooltip = "All levels first reached within the same chart bar share one number. This rule is maintained in realtime, so the script does not create false intrabar precision.",
     group = GROUP_PATH,
     active = trackArrivalInput,
     display = display.none)

bool keepHistoricalBadgesInput = input.bool(
     true,
     "Keep historical arrival badges",
     group = GROUP_PATH,
     active = trackArrivalInput and showArrivalBadgesInput,
     display = display.none)

string arrivalBadgeDetailInput = input.string(
     "Rank only",
     "Arrival badge detail",
     options = ["Rank only", "Level + rank"],
     group = GROUP_PATH,
     active = trackArrivalInput and showArrivalBadgesInput,
     display = display.none)

string markerSizeInput = input.string(
     "Small",
     "Arrival badge size",
     options = ["Tiny", "Small", "Normal"],
     group = GROUP_PATH,
     active = trackArrivalInput and showArrivalBadgesInput,
     display = display.none)

int arrivalBadgeTransparencyInput = input.int(
     2,
     "Arrival badge transparency",
     minval = 0,
     maxval = 75,
     group = GROUP_PATH,
     active = trackArrivalInput and showArrivalBadgesInput,
     display = display.none)

string focusModeInput = input.string(
     "Nearest unreached",
     "Line focus",
     options = ["Nearest unreached", "Nearest level", "Off"],
     group = GROUP_PATH,
     display = display.none)

bool fallbackFocusInput = input.bool(
     true,
     "Fallback to nearest after all reached",
     group = GROUP_PATH,
     active = trackArrivalInput and focusModeInput == "Nearest unreached",
     display = display.none)

int reachedFadeInput = input.int(
     38,
     "Reached-level extra fade",
     minval = 0,
     maxval = 90,
     group = GROUP_PATH,
     active = trackArrivalInput,
     display = display.none)

bool showCprInput = input.bool(
     false,
     "Show central pivot range",
     tooltip = "CPR uses the conventional HLC3 pivot and previous-day midpoint, independent of the selected R/S method.",
     group = GROUP_CONTEXT,
     display = display.none)

bool showPdhPdlInput = input.bool(
     true,
     "Show previous high and low",
     group = GROUP_CONTEXT,
     display = display.none)

bool showPdcInput = input.bool(
     false,
     "Show previous close",
     group = GROUP_CONTEXT,
     display = display.none)

bool showDayOpenInput = input.bool(
     false,
     "Show current exchange-day open",
     group = GROUP_CONTEXT,
     display = display.none)

bool showContextLabelsInput = input.bool(
     true,
     "Show context labels",
     group = GROUP_CONTEXT,
     display = display.none)

bool showOpeningBracketInput = input.bool(
     false,
     "Show opening bracket",
     tooltip = "Highlights the nearest displayed pivot interval strictly below and above the current exchange-day open.",
     group = GROUP_CONTEXT,
     display = display.none)

bool showOpeningBracketLabelInput = input.bool(
     true,
     "Show opening bracket label",
     group = GROUP_CONTEXT,
     active = showOpeningBracketInput,
     display = display.none)

color pivotColorInput = input.color(
     #FFC107,
     "Pivot color",
     group = GROUP_VISUAL,
     display = display.none)

color resistanceColorInput = input.color(
     #FF6B6B,
     "Resistance color",
     group = GROUP_VISUAL,
     display = display.none)

color supportColorInput = input.color(
     #2DD4BF,
     "Support color",
     group = GROUP_VISUAL,
     display = display.none)

color cprColorInput = input.color(
     #64B5F6,
     "CPR color",
     group = GROUP_VISUAL,
     display = display.none)

color previousHighColorInput = input.color(
     #FF9E9A,
     "Previous high color",
     group = GROUP_VISUAL,
     display = display.none)

color previousLowColorInput = input.color(
     #8FE3DA,
     "Previous low color",
     group = GROUP_VISUAL,
     display = display.none)

color previousCloseColorInput = input.color(
     #CFD8DC,
     "Previous close color",
     group = GROUP_VISUAL,
     display = display.none)

color dayOpenColorInput = input.color(
     #C471ED,
     "Day open color",
     group = GROUP_VISUAL,
     display = display.none)

string labelTextModeInput = input.string(
     "Auto contrast",
     "Label text contrast",
     options = ["Auto contrast", "Manual"],
     tooltip = "Auto contrast selects black or white text from the selected background color. Manual uses the colors below.",
     group = GROUP_VISUAL,
     display = display.none)

color pivotTextColorInput = input.color(
     color.black,
     "Manual P text color",
     group = GROUP_VISUAL,
     active = labelTextModeInput == "Manual",
     display = display.none)

color rsTextColorInput = input.color(
     color.white,
     "Manual R/S text color",
     group = GROUP_VISUAL,
     active = labelTextModeInput == "Manual",
     display = display.none)

color contextTextColorInput = input.color(
     color.black,
     "Manual context text color",
     group = GROUP_VISUAL,
     active = labelTextModeInput == "Manual",
     display = display.none)

int lineTransparencyInput = input.int(
     2,
     "Current-line transparency",
     minval = 0,
     maxval = 90,
     group = GROUP_VISUAL,
     display = display.none)

int outerLevelFadeInput = input.int(
     14,
     "Outer-level extra fade",
     minval = 0,
     maxval = 70,
     tooltip = "Applied progressively to R2/S2 and R3/S3 so the visual hierarchy remains clear.",
     group = GROUP_VISUAL,
     display = display.none)

int pivotWidthInput = input.int(
     3,
     "P line width",
     minval = 1,
     maxval = 4,
     group = GROUP_VISUAL,
     display = display.none)

int innerWidthInput = input.int(
     2,
     "R1/S1 line width",
     minval = 1,
     maxval = 4,
     group = GROUP_VISUAL,
     display = display.none)

int outerWidthInput = input.int(
     1,
     "Outer R/S line width",
     minval = 1,
     maxval = 4,
     group = GROUP_VISUAL,
     display = display.none)

string pivotStyleInput = input.string(
     "Solid",
     "P line style",
     options = ["Solid", "Dashed", "Dotted"],
     group = GROUP_VISUAL,
     display = display.none)

string tier1StyleInput = input.string(
     "Solid",
     "R1/S1 line style",
     options = ["Solid", "Dashed", "Dotted"],
     group = GROUP_VISUAL,
     display = display.none)

string tier2StyleInput = input.string(
     "Dashed",
     "R2/S2 line style",
     options = ["Solid", "Dashed", "Dotted"],
     group = GROUP_VISUAL,
     display = display.none)

string tier3StyleInput = input.string(
     "Dotted",
     "R3/S3 line style",
     options = ["Solid", "Dashed", "Dotted"],
     group = GROUP_VISUAL,
     display = display.none)

bool showFocusHaloInput = input.bool(
     true,
     "Show focus halo",
     tooltip = "Adds one wider translucent line behind the focused level without creating a price band.",
     group = GROUP_VISUAL,
     active = focusModeInput != "Off",
     display = display.none)

int focusHaloTransparencyInput = input.int(
     64,
     "Focus halo transparency",
     minval = 35,
     maxval = 95,
     group = GROUP_VISUAL,
     active = showFocusHaloInput and focusModeInput != "Off",
     display = display.none)

string labelModeInput = input.string(
     "Level + price",
     "Right label detail",
     options = ["Level", "Level + price", "Research detail", "Off"],
     group = GROUP_VISUAL,
     display = display.none)

int labelOffsetInput = input.int(
     4,
     "Right label offset bars",
     minval = 1,
     maxval = 50,
     group = GROUP_VISUAL,
     display = display.none)

bool autoLabelLanesInput = input.bool(
     true,
     "Auto-stagger close labels",
     tooltip = "Moves close labels into additional horizontal lanes, reducing overlap without shifting the actual price level.",
     group = GROUP_VISUAL,
     display = display.none)

float labelCollisionRangePercentInput = input.float(
     1.25,
     "Label collision threshold as prior-range %",
     minval = 0.0,
     maxval = 25.0,
     step = 0.05,
     group = GROUP_VISUAL,
     active = autoLabelLanesInput,
     display = display.none)

int labelLaneSpacingInput = input.int(
     5,
     "Label lane spacing bars",
     minval = 1,
     maxval = 20,
     group = GROUP_VISUAL,
     active = autoLabelLanesInput,
     display = display.none)

int contextLabelExtraOffsetInput = input.int(
     8,
     "Context label extra offset",
     minval = 0,
     maxval = 50,
     tooltip = "Separates PDH/PDL/CPR labels from P/R/S labels before automatic staggering.",
     group = GROUP_VISUAL,
     active = showContextLabelsInput,
     display = display.none)

string labelSizeInput = input.string(
     "Small",
     "Right label size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = GROUP_VISUAL,
     active = labelModeInput != "Off" or showContextLabelsInput,
     display = display.none)

int labelTransparencyInput = input.int(
     0,
     "Label background transparency",
     minval = 0,
     maxval = 75,
     group = GROUP_VISUAL,
     active = labelModeInput != "Off" or showContextLabelsInput,
     display = display.none)

int historyTransparencyInput = input.int(
     80,
     "Historical transparency",
     minval = 50,
     maxval = 98,
     group = GROUP_VISUAL,
     display = display.none)

int historicalArrivalBadgeTransparencyInput = input.int(
     76,
     "Historical arrival badge transparency",
     minval = 40,
     maxval = 95,
     tooltip = "Controls the retained historical first-arrival badge frame/background. Lower values are brighter.",
     group = GROUP_VISUAL,
     active = keepHistoricalBadgesInput and historyDaysInput > 1,
     display = display.none)

int cprFillTransparencyInput = input.int(
     89,
     "CPR fill transparency",
     minval = 75,
     maxval = 100,
     group = GROUP_VISUAL,
     active = showCprInput,
     display = display.none)

int openingBracketTransparencyInput = input.int(
     92,
     "Opening bracket transparency",
     minval = 80,
     maxval = 100,
     group = GROUP_VISUAL,
     active = showOpeningBracketInput,
     display = display.none)

bool showSessionBriefInput = input.bool(
     false,
     "Show session brief",
     tooltip = "Displays method, prior range, open relation, reached progress, and the nearest unreached level in a compact table.",
     group = GROUP_BRIEF,
     display = display.none)

string briefPositionInput = input.string(
     "Bottom right",
     "Session brief position",
     options = ["Top left", "Top right", "Bottom left", "Bottom right"],
     group = GROUP_BRIEF,
     active = showSessionBriefInput,
     display = display.none)

string briefSizeInput = input.string(
     "Small",
     "Session brief text size",
     options = ["Tiny", "Small", "Normal"],
     group = GROUP_BRIEF,
     active = showSessionBriefInput,
     display = display.none)

int briefTransparencyInput = input.int(
     16,
     "Session brief background transparency",
     minval = 0,
     maxval = 90,
     group = GROUP_BRIEF,
     active = showSessionBriefInput,
     display = display.none)

bool showSafetyNoticeInput = input.bool(
     true,
     "Show safety notices",
     group = GROUP_BRIEF,
     display = display.none)

bool enableArrivalAlertsInput = input.bool(
     true,
     "Enable arrival alert conditions",
     group = GROUP_ALERTS,
     active = trackArrivalInput,
     display = display.none)

bool enableDynamicArrivalAlertsInput = input.bool(
     false,
     "Enable dynamic alert() messages",
     tooltip = "When enabled, create a TradingView alert using 'Any alert() function call'. The message includes the newly reached codes and rank.",
     group = GROUP_ALERTS,
     active = enableArrivalAlertsInput and trackArrivalInput,
     display = display.none)

bool enablePivotCrossAlertsInput = input.bool(
     true,
     "Enable confirmed P-cross alerts",
     group = GROUP_ALERTS,
     display = display.none)

//==============================================================================
// Utility functions
//==============================================================================
f_levelCode(int index) =>
    switch index
        IDX_P  => "P"
        IDX_R1 => "R1"
        IDX_S1 => "S1"
        IDX_R2 => "R2"
        IDX_S2 => "S2"
        IDX_R3 => "R3"
        => "S3"

f_levelTier(int index) =>
    index == IDX_P ? 0 : index <= IDX_S1 ? 1 : index <= IDX_S2 ? 2 : 3

f_levelRole(int index) =>
    index == IDX_P ? 0 : index % 2 == 1 ? 1 : -1

f_levelColor(int index) =>
    index == IDX_P ? pivotColorInput : f_levelRole(index) > 0 ? resistanceColorInput : supportColorInput

f_autoTextColor(color backgroundColor) =>
    float luminance = 0.299 * color.r(backgroundColor) + 0.587 * color.g(backgroundColor) + 0.114 * color.b(backgroundColor)
    luminance >= 155.0 ? color.black : color.white

f_levelTextColor(int index) =>
    color backgroundColor = f_levelColor(index)
    labelTextModeInput == "Auto contrast" ? f_autoTextColor(backgroundColor) : index == IDX_P ? pivotTextColorInput : rsTextColorInput

f_contextTextColor(color backgroundColor) =>
    labelTextModeInput == "Auto contrast" ? f_autoTextColor(backgroundColor) : contextTextColorInput

f_lineStyle(string styleName) =>
    styleName == "Dashed" ? line.style_dashed : styleName == "Dotted" ? line.style_dotted : line.style_solid

f_levelStyle(int index) =>
    int tier = f_levelTier(index)
    f_lineStyle(tier == 0 ? pivotStyleInput : tier == 1 ? tier1StyleInput : tier == 2 ? tier2StyleInput : tier3StyleInput)

f_levelBaseWidth(int index) =>
    int tier = f_levelTier(index)
    tier == 0 ? pivotWidthInput : tier == 1 ? innerWidthInput : outerWidthInput

f_levelOuterFade(int index) =>
    int tier = f_levelTier(index)
    tier <= 1 ? 0 : tier == 2 ? outerLevelFadeInput : int(math.min(90, outerLevelFadeInput * 2))

f_labelSize(string selectedSize) =>
    selectedSize == "Tiny" ? size.tiny : selectedSize == "Normal" ? size.normal : selectedSize == "Large" ? size.large : size.small

f_markerSize(string selectedSize) =>
    selectedSize == "Tiny" ? size.tiny : selectedSize == "Normal" ? size.normal : size.small

// Converts a bar-count visual offset to an absolute timestamp. Persistent
// drawings use time coordinates so dense second charts cannot exceed Pine's
// historical bar-index positioning limit.
f_nominalBarMilliseconds() =>
    float timeframeSeconds = timeframe.isintraday ? timeframe.in_seconds(timeframe.period) : 60.0
    int(math.max(1000.0, nz(timeframeSeconds, 60.0) * 1000.0))

f_timeOffset(int baseTime, int barsForward) =>
    int safeBaseTime = na(baseTime) ? time : baseTime
    safeBaseTime + math.max(barsForward, 0) * f_nominalBarMilliseconds()

f_tablePosition(string selectedPosition) =>
    selectedPosition == "Top left" ? position.top_left : selectedPosition == "Top right" ? position.top_right : selectedPosition == "Bottom left" ? position.bottom_left : position.bottom_right

f_depthAllows(int index) =>
    int tier = f_levelTier(index)
    tier == 0 or depthInput == "Expanded" or (depthInput == "Standard" and tier <= 2) or (depthInput == "Essential" and tier <= 1)

f_userAllows(int index) =>
    int role = f_levelRole(index)
    role == 0 ? showPivotInput : role > 0 ? showResistanceInput : showSupportInput

f_roundLevel(float value, int role) =>
    float rounded = value
    if not na(value)
        if roundingModeInput == "Nearest tick"
            rounded := math.round_to_mintick(value)
        else if roundingModeInput == "Outward tick"
            float tick = syminfo.mintick
            float units = value / tick
            float epsilon = 1e-10
            float outward = role > 0 ? math.ceil(units - epsilon) * tick : role < 0 ? math.floor(units + epsilon) * tick : math.round_to_mintick(value)
            rounded := math.round_to_mintick(outward)
    rounded

f_methodName() =>
    methodInput

f_sourceName(bool useStandardSource) =>
    useStandardSource ? "Standard symbol" : "Chart context"

f_touchName() =>
    touchBasisInput

f_signedRatio(float value) =>
    na(value) ? "n/a" : (value > 0 ? "+" : "") + str.tostring(value, "#.###") + "R"

f_arrivalState(int rank) =>
    rank <= 0 ? "pending" : "#" + str.tostring(rank)

f_edgeLabelText(string code, float level, int rank, float distanceInRanges, bool focused) =>
    string prefix = focused ? "▶ " : ""
    string priceText = str.tostring(level, format.mintick)
    string stateText = f_arrivalState(rank)
    string distanceText = f_signedRatio(distanceInRanges)
    switch labelModeInput
        "Level"           => prefix + code
        "Level + price"   => prefix + code + "  " + priceText
        "Research detail" => prefix + code + "  " + priceText + " | " + stateText + " | Δ " + distanceText
        => ""

f_contextName(int index) =>
    switch index
        CTX_CPR_HIGH => "CPR-H"
        CTX_CPR_LOW  => "CPR-L"
        CTX_PDH      => "PDH"
        CTX_PDL      => "PDL"
        CTX_PDC      => "PDC"
        => "Day open"

f_contextColor(int index) =>
    switch index
        CTX_CPR_HIGH => cprColorInput
        CTX_CPR_LOW  => cprColorInput
        CTX_PDH      => previousHighColorInput
        CTX_PDL      => previousLowColorInput
        CTX_PDC      => previousCloseColorInput
        => dayOpenColorInput

f_contextStyle(int index) =>
    index == CTX_OPEN ? line.style_solid : index == CTX_PDC ? line.style_dotted : line.style_dashed

f_contextVisible(int index) =>
    switch index
        CTX_CPR_HIGH => showCprInput
        CTX_CPR_LOW  => showCprInput
        CTX_PDH      => showPdhPdlInput
        CTX_PDL      => showPdhPdlInput
        CTX_PDC      => showPdcInput
        => showDayOpenInput

f_reached(float level, float tolerance, float sourceOpenValue, float sourceHighValue, float sourceLowValue, float sourceCloseValue, float priorSourceClose) =>
    bool touched = false
    if touchBasisInput == "Wick"
        touched := sourceHighValue >= level - tolerance and sourceLowValue <= level + tolerance
    else if touchBasisInput == "Body"
        float bodyHigh = math.max(sourceOpenValue, sourceCloseValue)
        float bodyLow = math.min(sourceOpenValue, sourceCloseValue)
        touched := bodyHigh >= level - tolerance and bodyLow <= level + tolerance
    else
        touched := not na(priorSourceClose) and ((sourceCloseValue > level + tolerance and priorSourceClose <= level + tolerance) or (sourceCloseValue < level - tolerance and priorSourceClose >= level - tolerance))

    bool gapCrossed = countGapCrossingsInput and not na(priorSourceClose) and ((priorSourceClose < level - tolerance and sourceOpenValue > level + tolerance) or (priorSourceClose > level + tolerance and sourceOpenValue < level - tolerance))
    touched or gapCrossed

f_badgeText(string code, int rank) =>
    arrivalBadgeDetailInput == "Level + rank" ? code + " #" + str.tostring(rank) : str.tostring(rank)

//==============================================================================
// Source safeguards and confirmed previous-day OHLC
//==============================================================================
bool isIntradayChart = timeframe.isintraday
string standardTicker = ticker.standard(syminfo.tickerid)
bool useStandardSource = sourceModeInput == "Standard symbol" or (sourceModeInput == "Automatic" and not chart.is_standard)
string dailyTicker = useStandardSource ? standardTicker : syminfo.tickerid

// Every requested daily member is offset by one bar. The tuple therefore
// contains only the last completed daily session and never a developing daily
// price or timestamp.
[previousDailyOpenTime, previousDailyCloseTime, previousOpen, previousHigh, previousLow, previousClose] = request.security(
     dailyTicker,
     "D",
     [time[1], time_close[1], open[1], high[1], low[1], close[1]],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on,
     ignore_invalid_symbol = true)

// Tick charts are intentionally unsupported, but requests still use a valid
// time-based fallback so the script fails closed with a notice instead of halting.
string sourceRequestTimeframe = timeframe.isticks ? "1" : timeframe.period

// Nominal duration is used only for drawing-time projection and as a defensive
// fallback on chart types whose realtime time_close can be unavailable.
float chartTimeframeSeconds = timeframe.isintraday ? timeframe.in_seconds(timeframe.period) : 60.0
int nominalBarMs = int(math.max(1000.0, nz(chartTimeframeSeconds, 60.0) * 1000.0))

// Same-timeframe standard-symbol data uses gaps_off so developing realtime OHLC
// remains available. Time-based standard and Heikin-Ashi bars require exact open-
// time alignment. Price-based chart types accept a requested interval containing
// the synthetic timestamp. Both paths reject stale forward-filled values.
[standardOpen, standardHigh, standardLow, standardClose, standardPriorClose, standardBarTime, standardBarCloseTimeRaw, standardDayOpenTime, standardTradingDayKey] = request.security(
     standardTicker,
     sourceRequestTimeframe,
     [open, high, low, close, close[1], time, time_close, time("D"), time_tradingday],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     ignore_invalid_symbol = true)

int standardBarEndTime = not na(standardBarCloseTimeRaw) ? standardBarCloseTimeRaw : not na(standardBarTime) ? standardBarTime + nominalBarMs : na
bool standardBarExact = not na(standardBarTime) and standardBarTime == time
bool standardBarContained = not na(standardBarTime) and not na(standardBarEndTime) and standardBarTime <= time and time < standardBarEndTime
// Time-based standard and Heikin-Ashi bars must align exactly. Price-based chart
// types may use a standard bar whose interval contains the synthetic timestamp.
bool standardBarFresh = (chart.is_standard or chart.is_heikinashi) ? standardBarExact : standardBarContained

float sourceOpen = useStandardSource ? (standardBarFresh ? standardOpen : na) : open
float sourceHigh = useStandardSource ? (standardBarFresh ? standardHigh : na) : high
float sourceLow = useStandardSource ? (standardBarFresh ? standardLow : na) : low
float sourceClose = useStandardSource ? (standardBarFresh ? standardClose : na) : close
float priorValidSourceClose = useStandardSource ? (standardBarFresh ? standardPriorClose : na) : close[1]
int sourceBarTime = useStandardSource ? (standardBarFresh ? standardBarTime : na) : time
int sourceBarEndTime = useStandardSource ? (standardBarFresh ? standardBarEndTime : na) : not na(time_close) ? time_close : time + nominalBarMs
int sourceDayOpenTime = useStandardSource ? (standardBarFresh ? standardDayOpenTime : na) : time("D")
int sourceTradingDayKey = useStandardSource ? (standardBarFresh ? standardTradingDayKey : na) : time_tradingday

bool sourceBarAvailable = not na(sourceBarTime) and not na(sourceBarEndTime) and not na(sourceOpen) and not na(sourceHigh) and not na(sourceLow) and not na(sourceClose)
float previousRange = previousHigh - previousLow
bool validPreviousDay = not na(previousDailyOpenTime) and not na(previousDailyCloseTime) and not na(previousOpen) and not na(previousHigh) and not na(previousLow) and not na(previousClose) and previousHigh >= previousLow
// The selected source day must begin after the last completed daily session and
// the completed daily session must have closed no later than the current source
// bar. This guards day-roll latency without requesting any developing daily data.
bool dailyContextAligned = sourceBarAvailable and validPreviousDay and not na(sourceDayOpenTime) and previousDailyOpenTime < sourceDayOpenTime and previousDailyCloseTime <= sourceBarTime
bool validSourceBar = sourceBarAvailable and validPreviousDay and dailyContextAligned
int latestValidSourceEndTime = ta.valuewhen(validSourceBar, sourceBarEndTime, 0)
int priorValidSourceEndTime = ta.valuewhen(validSourceBar, sourceBarEndTime, 1)
float latestValidSourceClose = ta.valuewhen(validSourceBar, sourceClose, 0)
float displaySourceClose = validSourceBar ? sourceClose : latestValidSourceClose

// time_tradingday supplies a session-aware key for overnight markets. During a
// standard-source gap, the chart key retires the prior day's drawings; calculations
// and events still wait for a valid source bar.
int chartDayKey = not na(time_tradingday) ? time_tradingday : time("D")
int exchangeDayKey = not na(sourceTradingDayKey) ? sourceTradingDayKey : chartDayKey
bool newExchangeDay = barstate.isfirst or (not na(exchangeDayKey) and (na(exchangeDayKey[1]) or exchangeDayKey != exchangeDayKey[1]))

// Determine completeness from the first actual selected-source bar, not merely
// the first chart bar. If history starts after the selected day began, the unseen
// first-arrival path is unknowable and events pause for that one day.
var int firstDatasetDayKey = na
var bool firstDatasetDayPartial = false
var bool firstDatasetDayKnown = false
if not firstDatasetDayKnown and sourceBarAvailable
    firstDatasetDayKey := exchangeDayKey
    firstDatasetDayPartial := na(sourceDayOpenTime) or time > sourceDayOpenTime
    firstDatasetDayKnown := true
bool firstDatasetDayActive = firstDatasetDayKnown and exchangeDayKey == firstDatasetDayKey
bool firstDayEventsComplete = firstDatasetDayKnown and (not firstDatasetDayPartial or not firstDatasetDayActive)

// Intrabar-persistent state survives rollback on the open realtime bar.
varip int stateDayKey = na
varip float currentDayOpenState = na
varip int currentDayStartTimeState = na
varip int arrivalSequence = 0
varip int arrivalGroupBarIndex = na
varip int arrivalGroupRank = 0
varip array<int> arrivalRanks = array.new_int(LEVEL_COUNT, 0)
varip array<int> arrivalTimes = array.new_int(LEVEL_COUNT, na)

bool stateDayChanged = not na(exchangeDayKey) and (na(stateDayKey) or exchangeDayKey != stateDayKey)
if stateDayChanged
    stateDayKey := exchangeDayKey
    currentDayOpenState := na
    currentDayStartTimeState := na
    arrivalSequence := 0
    arrivalGroupBarIndex := bar_index
    arrivalGroupRank := 0
    for index = 0 to LEVEL_COUNT - 1
        array.set(arrivalRanks, index, 0)
        array.set(arrivalTimes, index, na)

// Capture the first genuine selected-source open. A partial first loaded day stays
// unknown rather than inventing an opening price from the loaded subset.
bool currentDatasetDayPartial = firstDatasetDayKnown and firstDatasetDayPartial and exchangeDayKey == firstDatasetDayKey
if na(currentDayStartTimeState) and sourceBarAvailable
    currentDayStartTimeState := sourceBarTime
if na(currentDayOpenState) and sourceBarAvailable and not currentDatasetDayPartial
    currentDayOpenState := sourceOpen

if na(arrivalGroupBarIndex) or arrivalGroupBarIndex != bar_index
    arrivalGroupBarIndex := bar_index
    arrivalGroupRank := 0

//==============================================================================
// Pivot calculations
//==============================================================================
float rawP = na
float rawR1 = na
float rawS1 = na
float rawR2 = na
float rawS2 = na
float rawR3 = na
float rawS3 = na

if validPreviousDay
    float traditionalP = (previousHigh + previousLow + previousClose) / 3.0

    if methodInput == "Traditional"
        rawP := traditionalP
        rawR1 := 2.0 * rawP - previousLow
        rawS1 := 2.0 * rawP - previousHigh
        rawR2 := rawP + previousRange
        rawS2 := rawP - previousRange
        rawR3 := previousHigh + 2.0 * (rawP - previousLow)
        rawS3 := previousLow - 2.0 * (previousHigh - rawP)
    else if methodInput == "Classic"
        rawP := traditionalP
        rawR1 := 2.0 * rawP - previousLow
        rawS1 := 2.0 * rawP - previousHigh
        rawR2 := rawP + previousRange
        rawS2 := rawP - previousRange
        rawR3 := rawP + 2.0 * previousRange
        rawS3 := rawP - 2.0 * previousRange
    else if methodInput == "Fibonacci"
        rawP := traditionalP
        rawR1 := rawP + 0.382 * previousRange
        rawS1 := rawP - 0.382 * previousRange
        rawR2 := rawP + 0.618 * previousRange
        rawS2 := rawP - 0.618 * previousRange
        rawR3 := rawP + previousRange
        rawS3 := rawP - previousRange
    else if methodInput == "Camarilla"
        rawP := traditionalP
        rawR1 := previousClose + previousRange * 1.1 / 12.0
        rawS1 := previousClose - previousRange * 1.1 / 12.0
        rawR2 := previousClose + previousRange * 1.1 / 6.0
        rawS2 := previousClose - previousRange * 1.1 / 6.0
        rawR3 := previousClose + previousRange * 1.1 / 4.0
        rawS3 := previousClose - previousRange * 1.1 / 4.0
    else
        float customLow = math.min(customMultiplier1Input, math.min(customMultiplier2Input, customMultiplier3Input))
        float customHigh = math.max(customMultiplier1Input, math.max(customMultiplier2Input, customMultiplier3Input))
        float customMiddle = customMultiplier1Input + customMultiplier2Input + customMultiplier3Input - customLow - customHigh
        rawP := switch customBasisInput
            "HLCC4"          => (previousHigh + previousLow + 2.0 * previousClose) / 4.0
            "OHLC4"          => (previousOpen + previousHigh + previousLow + previousClose) / 4.0
            "Midpoint"       => (previousHigh + previousLow) / 2.0
            "Previous close" => previousClose
            => traditionalP
        rawR1 := rawP + customLow * previousRange
        rawS1 := rawP - customLow * previousRange
        rawR2 := rawP + customMiddle * previousRange
        rawS2 := rawP - customMiddle * previousRange
        rawR3 := rawP + customHigh * previousRange
        rawS3 := rawP - customHigh * previousRange

var array<float> calculatedLevels = array.new_float(LEVEL_COUNT, na)
array.set(calculatedLevels, IDX_P, f_roundLevel(rawP, 0))
array.set(calculatedLevels, IDX_R1, f_roundLevel(rawR1, 1))
array.set(calculatedLevels, IDX_S1, f_roundLevel(rawS1, -1))
array.set(calculatedLevels, IDX_R2, f_roundLevel(rawR2, 1))
array.set(calculatedLevels, IDX_S2, f_roundLevel(rawS2, -1))
array.set(calculatedLevels, IDX_R3, f_roundLevel(rawR3, 1))
array.set(calculatedLevels, IDX_S3, f_roundLevel(rawS3, -1))

float conventionalPivot = validPreviousDay ? (previousHigh + previousLow + previousClose) / 3.0 : na
float cprBaseRaw = validPreviousDay ? (previousHigh + previousLow) / 2.0 : na
float cprTopRaw = validPreviousDay ? 2.0 * conventionalPivot - cprBaseRaw : na
float cprHigh = validPreviousDay ? f_roundLevel(math.max(cprBaseRaw, cprTopRaw), 1) : na
float cprLow = validPreviousDay ? f_roundLevel(math.min(cprBaseRaw, cprTopRaw), -1) : na

float touchTolerance = toleranceModeInput == "Ticks" ? toleranceTicksInput * syminfo.mintick : toleranceModeInput == "Prior range %" and previousRange > 0 ? previousRange * toleranceRangePercentInput / 100.0 : 0.0
bool liveTimingEffective = eventTimingInput == "Live bar" and touchBasisInput == "Wick"
bool eventReadyNow = liveTimingEffective or barstate.isconfirmed
bool syntheticEventsAllowed = chart.is_standard or allowSyntheticEventsInput
bool pathEnvironmentReady = isIntradayChart and validPreviousDay and validSourceBar and syntheticEventsAllowed and firstDayEventsComplete

float pivotForFilter = array.get(calculatedLevels, IDX_P)
float filterAnchor = filterAnchorInput == "Pivot P" ? pivotForFilter : filterAnchorInput == "Previous close" ? previousClose : currentDayOpenState

//==============================================================================
// Stateful drawing collections
//==============================================================================
var array<float> activeLevels = array.new_float(LEVEL_COUNT, na)
var array<bool> activeDisplayCandidates = array.new_bool(LEVEL_COUNT, false)
var array<bool> activeDisplayVisible = array.new_bool(LEVEL_COUNT, false)
var array<int> activeDisplayOwners = array.new_int(LEVEL_COUNT, -1)
var array<string> activeDisplayCodes = array.new_string(LEVEL_COUNT, "")
var array<bool> activeTrackCandidates = array.new_bool(LEVEL_COUNT, false)
var array<bool> activeTrackOwners = array.new_bool(LEVEL_COUNT, false)
var array<int> activeTrackOwnerIndex = array.new_int(LEVEL_COUNT, -1)

var array<line> activeLevelLines = array.new_line(LEVEL_COUNT)
var array<label> activeEdgeLabels = array.new_label(LEVEL_COUNT)
var array<label> activeArrivalLabels = array.new_label(LEVEL_COUNT)
var array<int> activeLevelLanes = array.new_int(LEVEL_COUNT, 0)

var array<float> activeContextValues = array.new_float(CONTEXT_COUNT, na)
var array<line> activeContextLines = array.new_line(CONTEXT_COUNT)
var array<label> activeContextLabels = array.new_label(CONTEXT_COUNT)
var array<int> activeContextLanes = array.new_int(CONTEXT_COUNT, 0)

var array<line> historicalLines = array.new_line()
var array<int> historicalLineDays = array.new_int()
var array<label> historicalLabels = array.new_label()
var array<int> historicalLabelDays = array.new_int()
var array<box> historicalBoxes = array.new_box()
var array<int> historicalBoxDays = array.new_int()

var box activeCprBox = na
var box activeOpeningBox = na
var label activeOpeningLabel = na
var line activeFocusHalo = na
var label safetyNotice = na
var int daySerial = 0
var int activeDayStartTime = na
var bool activeDayInitialized = false

//==============================================================================
// Session-aware day rollover: finalize old objects and clear fixed daily state
//==============================================================================
if isIntradayChart and newExchangeDay
    int outgoingDay = daySerial
    int outgoingEndTimeCandidate = validSourceBar ? priorValidSourceEndTime : latestValidSourceEndTime
    int outgoingEndTime = not na(outgoingEndTimeCandidate) ? outgoingEndTimeCandidate : not na(sourceBarEndTime) ? sourceBarEndTime : time

    for index = 0 to LEVEL_COUNT - 1
        line outgoingLine = array.get(activeLevelLines, index)
        if not na(outgoingLine)
            if historyDaysInput > 1 and outgoingDay > 0
                line.set_x2(outgoingLine, math.max(outgoingEndTime, line.get_x1(outgoingLine)))
                line.set_color(outgoingLine, color.new(f_levelColor(index), historyTransparencyInput))
                line.set_width(outgoingLine, 1)
                array.push(historicalLines, outgoingLine)
                array.push(historicalLineDays, outgoingDay)
            else
                line.delete(outgoingLine)
            array.set(activeLevelLines, index, na)

        label edgeLabel = array.get(activeEdgeLabels, index)
        if not na(edgeLabel)
            label.delete(edgeLabel)
            array.set(activeEdgeLabels, index, na)

        label arrivalLabel = array.get(activeArrivalLabels, index)
        if not na(arrivalLabel)
            if historyDaysInput > 1 and outgoingDay > 0 and keepHistoricalBadgesInput
                color oldColor = f_levelColor(index)
                int historicalBadgeTextTransparency = int(math.min(90, historicalArrivalBadgeTransparencyInput + 8))
                label.set_color(arrivalLabel, color.new(oldColor, historicalArrivalBadgeTransparencyInput))
                label.set_textcolor(arrivalLabel, color.new(f_levelTextColor(index), historicalBadgeTextTransparency))
                array.push(historicalLabels, arrivalLabel)
                array.push(historicalLabelDays, outgoingDay)
            else
                label.delete(arrivalLabel)
            array.set(activeArrivalLabels, index, na)

        array.set(activeLevels, index, na)
        array.set(activeDisplayCandidates, index, false)
        array.set(activeDisplayVisible, index, false)
        array.set(activeDisplayOwners, index, -1)
        array.set(activeDisplayCodes, index, "")
        array.set(activeTrackCandidates, index, false)
        array.set(activeTrackOwners, index, false)
        array.set(activeTrackOwnerIndex, index, -1)
        array.set(activeLevelLanes, index, 0)

    for contextIndex = 0 to CONTEXT_COUNT - 1
        line outgoingContextLine = array.get(activeContextLines, contextIndex)
        if not na(outgoingContextLine)
            if historyDaysInput > 1 and outgoingDay > 0
                line.set_x2(outgoingContextLine, math.max(outgoingEndTime, line.get_x1(outgoingContextLine)))
                line.set_color(outgoingContextLine, color.new(f_contextColor(contextIndex), historyTransparencyInput))
                line.set_width(outgoingContextLine, 1)
                array.push(historicalLines, outgoingContextLine)
                array.push(historicalLineDays, outgoingDay)
            else
                line.delete(outgoingContextLine)
            array.set(activeContextLines, contextIndex, na)

        label contextLabel = array.get(activeContextLabels, contextIndex)
        if not na(contextLabel)
            label.delete(contextLabel)
            array.set(activeContextLabels, contextIndex, na)

        array.set(activeContextValues, contextIndex, na)
        array.set(activeContextLanes, contextIndex, 0)

    if not na(activeFocusHalo)
        line.delete(activeFocusHalo)
        activeFocusHalo := na

    if not na(activeCprBox)
        if historyDaysInput > 1 and outgoingDay > 0
            box.set_right(activeCprBox, math.max(outgoingEndTime, box.get_left(activeCprBox)))
            box.set_border_color(activeCprBox, color.new(cprColorInput, historyTransparencyInput))
            box.set_bgcolor(activeCprBox, color.new(cprColorInput, int(math.max(cprFillTransparencyInput, historyTransparencyInput))))
            array.push(historicalBoxes, activeCprBox)
            array.push(historicalBoxDays, outgoingDay)
        else
            box.delete(activeCprBox)
        activeCprBox := na

    if not na(activeOpeningBox)
        if historyDaysInput > 1 and outgoingDay > 0
            box.set_right(activeOpeningBox, math.max(outgoingEndTime, box.get_left(activeOpeningBox)))
            box.set_border_color(activeOpeningBox, color.new(pivotColorInput, historyTransparencyInput))
            box.set_bgcolor(activeOpeningBox, color.new(pivotColorInput, int(math.max(openingBracketTransparencyInput, historyTransparencyInput))))
            array.push(historicalBoxes, activeOpeningBox)
            array.push(historicalBoxDays, outgoingDay)
        else
            box.delete(activeOpeningBox)
        activeOpeningBox := na

    if not na(activeOpeningLabel)
        label.delete(activeOpeningLabel)
        activeOpeningLabel := na

    daySerial += 1
    activeDayStartTime := currentDayStartTimeState
    activeDayInitialized := false

    while array.size(historicalLines) > 0
        int storedDay = array.get(historicalLineDays, 0)
        if daySerial - storedDay >= historyDaysInput
            line oldLine = array.shift(historicalLines)
            array.shift(historicalLineDays)
            line.delete(oldLine)
        else
            break

    while array.size(historicalLabels) > 0
        int storedDay = array.get(historicalLabelDays, 0)
        if daySerial - storedDay >= historyDaysInput
            label oldLabel = array.shift(historicalLabels)
            array.shift(historicalLabelDays)
            label.delete(oldLabel)
        else
            break

    while array.size(historicalBoxes) > 0
        int storedDay = array.get(historicalBoxDays, 0)
        if daySerial - storedDay >= historyDaysInput
            box oldBox = array.shift(historicalBoxes)
            array.shift(historicalBoxDays)
            box.delete(oldBox)
        else
            break

//==============================================================================
// Initialize the current selected-source day once aligned source data is available
//==============================================================================
if isIntradayChart and daySerial > 0 and not activeDayInitialized and validSourceBar
    activeDayStartTime := na(activeDayStartTime) ? (not na(currentDayStartTimeState) ? currentDayStartTimeState : sourceBarTime) : activeDayStartTime
    for index = 0 to LEVEL_COUNT - 1
        float level = array.get(calculatedLevels, index)
        array.set(activeLevels, index, level)

        bool selectedCandidate = f_userAllows(index) and f_depthAllows(index) and not na(level)
        bool withinReach = index == IDX_P or reachLimitInput == 0.0 or previousRange <= 0.0 or na(filterAnchor) or math.abs(level - filterAnchor) <= reachLimitInput * previousRange
        bool displayCandidate = selectedCandidate and withinReach
        bool trackCandidate = arrivalScopeInput == "Displayed levels" ? displayCandidate : arrivalScopeInput == "Selected depth" ? selectedCandidate : not na(level)

        array.set(activeDisplayCandidates, index, displayCandidate)
        array.set(activeTrackCandidates, index, trackCandidate)
        array.set(activeDisplayOwners, index, displayCandidate ? index : -1)
        array.set(activeTrackOwnerIndex, index, trackCandidate ? index : -1)

    if suppressDuplicatesInput
        for priorityPosition = 1 to LEVEL_COUNT - 1
            int candidateIndex = array.get(LEVEL_PRIORITY, priorityPosition)
            if array.get(activeDisplayCandidates, candidateIndex)
                float candidateLevel = array.get(activeLevels, candidateIndex)
                int ownerIndex = candidateIndex
                for earlierPosition = 0 to priorityPosition - 1
                    int earlierIndex = array.get(LEVEL_PRIORITY, earlierPosition)
                    bool earlierCandidate = array.get(activeDisplayCandidates, earlierIndex)
                    float earlierLevel = array.get(activeLevels, earlierIndex)
                    if ownerIndex == candidateIndex and earlierCandidate and math.abs(candidateLevel - earlierLevel) < syminfo.mintick * 0.5
                        ownerIndex := array.get(activeDisplayOwners, earlierIndex)
                array.set(activeDisplayOwners, candidateIndex, ownerIndex)

        for priorityPosition = 1 to LEVEL_COUNT - 1
            int candidateIndex = array.get(LEVEL_PRIORITY, priorityPosition)
            if array.get(activeTrackCandidates, candidateIndex)
                float candidateLevel = array.get(activeLevels, candidateIndex)
                int ownerIndex = candidateIndex
                for earlierPosition = 0 to priorityPosition - 1
                    int earlierIndex = array.get(LEVEL_PRIORITY, earlierPosition)
                    bool earlierCandidate = array.get(activeTrackCandidates, earlierIndex)
                    float earlierLevel = array.get(activeLevels, earlierIndex)
                    if ownerIndex == candidateIndex and earlierCandidate and math.abs(candidateLevel - earlierLevel) < syminfo.mintick * 0.5
                        ownerIndex := array.get(activeTrackOwnerIndex, earlierIndex)
                array.set(activeTrackOwnerIndex, candidateIndex, ownerIndex)

    for index = 0 to LEVEL_COUNT - 1
        bool displayOwner = array.get(activeDisplayCandidates, index) and array.get(activeDisplayOwners, index) == index
        bool trackOwner = array.get(activeTrackCandidates, index) and array.get(activeTrackOwnerIndex, index) == index
        array.set(activeDisplayVisible, index, displayOwner)
        array.set(activeTrackOwners, index, trackOwner)

        if displayOwner
            string combinedCode = ""
            for memberIndex = 0 to LEVEL_COUNT - 1
                if array.get(activeDisplayCandidates, memberIndex) and array.get(activeDisplayOwners, memberIndex) == index
                    combinedCode := combinedCode == "" ? f_levelCode(memberIndex) : combinedCode + "/" + f_levelCode(memberIndex)
            array.set(activeDisplayCodes, index, combinedCode)

            color baseColor = f_levelColor(index)
            int initialTransparency = int(math.min(95, lineTransparencyInput + f_levelOuterFade(index)))
            line newLine = line.new(
                 activeDayStartTime,
                 array.get(activeLevels, index),
                 f_timeOffset(sourceBarTime, labelOffsetInput),
                 array.get(activeLevels, index),
                 xloc = xloc.bar_time,
                 extend = extend.none,
                 color = color.new(baseColor, initialTransparency),
                 style = f_levelStyle(index),
                 width = f_levelBaseWidth(index))
            array.set(activeLevelLines, index, newLine)

    array.set(activeContextValues, CTX_CPR_HIGH, cprHigh)
    array.set(activeContextValues, CTX_CPR_LOW, cprLow)
    array.set(activeContextValues, CTX_PDH, f_roundLevel(previousHigh, 1))
    array.set(activeContextValues, CTX_PDL, f_roundLevel(previousLow, -1))
    array.set(activeContextValues, CTX_PDC, f_roundLevel(previousClose, 0))
    array.set(activeContextValues, CTX_OPEN, f_roundLevel(currentDayOpenState, 0))

    for contextIndex = 0 to CONTEXT_COUNT - 1
        float contextValue = array.get(activeContextValues, contextIndex)
        if f_contextVisible(contextIndex) and not na(contextValue)
            color contextColor = f_contextColor(contextIndex)
            line contextLine = line.new(
                 activeDayStartTime,
                 contextValue,
                 f_timeOffset(sourceBarTime, labelOffsetInput + contextLabelExtraOffsetInput),
                 contextValue,
                 xloc = xloc.bar_time,
                 extend = extend.none,
                 color = color.new(contextColor, 12),
                 style = f_contextStyle(contextIndex),
                 width = 1)
            array.set(activeContextLines, contextIndex, contextLine)

    if showCprInput and not na(cprHigh) and not na(cprLow)
        activeCprBox := box.new(
             activeDayStartTime,
             cprHigh,
             sourceBarTime,
             cprLow,
             xloc = xloc.bar_time,
             border_color = color.new(cprColorInput, 24),
             bgcolor = color.new(cprColorInput, cprFillTransparencyInput))

    if showOpeningBracketInput and not na(currentDayOpenState)
        float lowerLevel = na
        float upperLevel = na
        int lowerIndex = -1
        int upperIndex = -1
        for index = 0 to LEVEL_COUNT - 1
            if array.get(activeDisplayVisible, index)
                float level = array.get(activeLevels, index)
                if level < currentDayOpenState and (na(lowerLevel) or level > lowerLevel)
                    lowerLevel := level
                    lowerIndex := index
                if level > currentDayOpenState and (na(upperLevel) or level < upperLevel)
                    upperLevel := level
                    upperIndex := index
        if lowerIndex >= 0 and upperIndex >= 0
            activeOpeningBox := box.new(
                 activeDayStartTime,
                 upperLevel,
                 sourceBarTime,
                 lowerLevel,
                 xloc = xloc.bar_time,
                 border_color = color.new(pivotColorInput, 66),
                 border_style = line.style_dotted,
                 bgcolor = color.new(pivotColorInput, openingBracketTransparencyInput))
            if showOpeningBracketLabelInput
                string openingText = "OPEN " + array.get(activeDisplayCodes, lowerIndex) + "–" + array.get(activeDisplayCodes, upperIndex)
                string openingTooltip = "Nearest displayed pivot interval around the exchange-day open\nOpen: " + str.tostring(currentDayOpenState, format.mintick)
                color openingTextColor = labelTextModeInput == "Auto contrast" ? f_autoTextColor(pivotColorInput) : pivotTextColorInput
                activeOpeningLabel := label.new(
                     activeDayStartTime,
                     upperLevel,
                     openingText,
                     xloc = xloc.bar_time,
                     yloc = yloc.price,
                     style = label.style_label_down,
                     color = color.new(pivotColorInput, 20),
                     textcolor = openingTextColor,
                     size = size.tiny,
                     tooltip = openingTooltip)

    activeDayInitialized := true

//==============================================================================
// First-arrival path events
//==============================================================================
bool arrivalAnyEvent = false
bool arrivalPEvent = false
bool arrivalR1Event = false
bool arrivalS1Event = false
bool arrivalR2Event = false
bool arrivalS2Event = false
bool arrivalR3Event = false
bool arrivalS3Event = false
float arrivalAnyLevel = na
string dynamicArrivalCodes = ""

if trackArrivalInput and activeDayInitialized and pathEnvironmentReady and eventReadyNow
    for ownerIndex = 0 to LEVEL_COUNT - 1
        if array.get(activeTrackOwners, ownerIndex) and array.get(arrivalRanks, ownerIndex) == 0
            float level = array.get(activeLevels, ownerIndex)
            bool reachedNow = not na(level) and f_reached(level, touchTolerance, sourceOpen, sourceHigh, sourceLow, sourceClose, priorValidSourceClose)
            if reachedNow
                if arrivalGroupRank == 0
                    arrivalSequence += 1
                    arrivalGroupRank := arrivalSequence

                for memberIndex = 0 to LEVEL_COUNT - 1
                    if array.get(activeTrackCandidates, memberIndex) and array.get(activeTrackOwnerIndex, memberIndex) == ownerIndex and array.get(arrivalRanks, memberIndex) == 0
                        array.set(arrivalRanks, memberIndex, arrivalGroupRank)
                        array.set(arrivalTimes, memberIndex, sourceBarTime)
                        arrivalPEvent := arrivalPEvent or memberIndex == IDX_P
                        arrivalR1Event := arrivalR1Event or memberIndex == IDX_R1
                        arrivalS1Event := arrivalS1Event or memberIndex == IDX_S1
                        arrivalR2Event := arrivalR2Event or memberIndex == IDX_R2
                        arrivalS2Event := arrivalS2Event or memberIndex == IDX_S2
                        arrivalR3Event := arrivalR3Event or memberIndex == IDX_R3
                        arrivalS3Event := arrivalS3Event or memberIndex == IDX_S3

                arrivalAnyEvent := true
                arrivalAnyLevel := na(arrivalAnyLevel) ? level : arrivalAnyLevel
                string ownerCode = array.get(activeDisplayCodes, ownerIndex)
                ownerCode := ownerCode == "" ? f_levelCode(ownerIndex) : ownerCode
                dynamicArrivalCodes := dynamicArrivalCodes == "" ? ownerCode : dynamicArrivalCodes + ", " + ownerCode

if enableDynamicArrivalAlertsInput and enableArrivalAlertsInput and arrivalAnyEvent
    string dynamicMessage = syminfo.ticker + " " + timeframe.period + " | Previous-day pivot first arrival: " + dynamicArrivalCodes + " | rank #" + str.tostring(arrivalGroupRank) + " | method " + f_methodName()
    alert(dynamicMessage, alert.freq_all)

//==============================================================================
// Focus selection and collision-resistant label lanes
//==============================================================================
int focusIndex = -1
float focusDistance = na
bool useUnreachedFocus = trackArrivalInput and focusModeInput == "Nearest unreached"

if isIntradayChart and activeDayInitialized and not na(displaySourceClose) and focusModeInput != "Off"
    for index = 0 to LEVEL_COUNT - 1
        if array.get(activeDisplayVisible, index)
            int rank = array.get(arrivalRanks, index)
            bool eligible = not useUnreachedFocus or rank == 0
            if eligible
                float level = array.get(activeLevels, index)
                float distance = math.abs(displaySourceClose - level)
                if na(focusDistance) or distance < focusDistance
                    focusDistance := distance
                    focusIndex := index

    if useUnreachedFocus and focusIndex == -1 and fallbackFocusInput
        for index = 0 to LEVEL_COUNT - 1
            if array.get(activeDisplayVisible, index)
                float level = array.get(activeLevels, index)
                float distance = math.abs(displaySourceClose - level)
                if na(focusDistance) or distance < focusDistance
                    focusDistance := distance
                    focusIndex := index

float collisionThreshold = math.max(syminfo.mintick * 2.0, previousRange > 0 ? previousRange * labelCollisionRangePercentInput / 100.0 : 0.0)

for index = 0 to LEVEL_COUNT - 1
    int lane = 0
    if autoLabelLanesInput and array.get(activeDisplayVisible, index) and index > 0
        float level = array.get(activeLevels, index)
        for earlierIndex = 0 to index - 1
            if array.get(activeDisplayVisible, earlierIndex)
                float earlierLevel = array.get(activeLevels, earlierIndex)
                if math.abs(level - earlierLevel) <= collisionThreshold
                    lane := math.max(lane, array.get(activeLevelLanes, earlierIndex) + 1)
    array.set(activeLevelLanes, index, lane)

for contextIndex = 0 to CONTEXT_COUNT - 1
    int lane = 0
    float contextValue = array.get(activeContextValues, contextIndex)
    if autoLabelLanesInput and not na(contextValue) and not na(array.get(activeContextLines, contextIndex)) and contextIndex > 0
        for earlierContext = 0 to contextIndex - 1
            float earlierValue = array.get(activeContextValues, earlierContext)
            if not na(earlierValue) and not na(array.get(activeContextLines, earlierContext)) and math.abs(contextValue - earlierValue) <= collisionThreshold
                lane := math.max(lane, array.get(activeContextLanes, earlierContext) + 1)
    array.set(activeContextLanes, contextIndex, lane)

//==============================================================================
// Drawing maintenance: lines, readable badges, labels, halo, and context rails
//==============================================================================
if isIntradayChart and activeDayInitialized
    int drawingAnchorTime = na(latestValidSourceEndTime) ? (not na(sourceBarEndTime) ? sourceBarEndTime : time) : latestValidSourceEndTime

    for index = 0 to LEVEL_COUNT - 1
        if array.get(activeDisplayVisible, index)
            float level = array.get(activeLevels, index)
            int rank = array.get(arrivalRanks, index)
            bool focused = index == focusIndex
            color baseColor = f_levelColor(index)
            int baseTransparency = int(math.min(95, lineTransparencyInput + f_levelOuterFade(index)))
            int reachedTransparency = rank > 0 ? int(math.min(95, baseTransparency + reachedFadeInput)) : baseTransparency
            int finalTransparency = focused ? math.max(0, baseTransparency - 4) : reachedTransparency
            int finalWidth = int(math.min(4, f_levelBaseWidth(index) + (focused ? 1 : 0)))
            int lane = array.get(activeLevelLanes, index)
            int labelXTime = f_timeOffset(drawingAnchorTime, labelOffsetInput + lane * labelLaneSpacingInput)
            int lineX2Time = labelXTime

            line activeLine = array.get(activeLevelLines, index)
            if not na(activeLine)
                line.set_x2(activeLine, labelModeInput == "Off" ? f_timeOffset(drawingAnchorTime, labelOffsetInput) : lineX2Time)
                line.set_y1(activeLine, level)
                line.set_y2(activeLine, level)
                line.set_color(activeLine, color.new(baseColor, finalTransparency))
                line.set_width(activeLine, finalWidth)
                line.set_style(activeLine, f_levelStyle(index))

            // State-driven creation makes the badge reappear after each realtime
            // rollback while the varip rank/time state remains latched.
            label arrivalLabel = array.get(activeArrivalLabels, index)
            int arrivalTime = array.get(arrivalTimes, index)
            if showArrivalBadgesInput and rank > 0 and not na(arrivalTime)
                string badgeCode = array.get(activeDisplayCodes, index)
                badgeCode := badgeCode == "" ? f_levelCode(index) : badgeCode
                string badgeText = f_badgeText(badgeCode, rank)
                string badgeTooltip = badgeCode + " first-arrival group #" + str.tostring(rank) + "\nLevels first reached in the same chart bar share one rank."
                if na(arrivalLabel)
                    arrivalLabel := label.new(
                         arrivalTime,
                         level,
                         badgeText,
                         xloc = xloc.bar_time,
                         yloc = yloc.price,
                         style = label.style_label_center,
                         color = color.new(baseColor, arrivalBadgeTransparencyInput),
                         textcolor = f_levelTextColor(index),
                         size = f_markerSize(markerSizeInput),
                         tooltip = badgeTooltip)
                    array.set(activeArrivalLabels, index, arrivalLabel)
                else
                    label.set_xy(arrivalLabel, arrivalTime, level)
                    label.set_text(arrivalLabel, badgeText)
                    label.set_color(arrivalLabel, color.new(baseColor, arrivalBadgeTransparencyInput))
                    label.set_textcolor(arrivalLabel, f_levelTextColor(index))
                    label.set_size(arrivalLabel, f_markerSize(markerSizeInput))
                    label.set_tooltip(arrivalLabel, badgeTooltip)
            else if not na(arrivalLabel)
                label.delete(arrivalLabel)
                array.set(activeArrivalLabels, index, na)

            label edgeLabel = array.get(activeEdgeLabels, index)
            if barstate.islast and labelModeInput != "Off" and not na(displaySourceClose)
                float distanceInRanges = previousRange > 0 ? (level - displaySourceClose) / previousRange : na
                string code = array.get(activeDisplayCodes, index)
                string labelText = f_edgeLabelText(code, level, rank, distanceInRanges, focused)
                string effectiveTimingText = liveTimingEffective ? "Live wick latch" : eventTimingInput == "Live bar" and touchBasisInput != "Wick" ? "Confirmed safeguard" : "Confirmed bar"
                string tooltipText = "Method: " + f_methodName() +
                     "\nPrice: " + str.tostring(level, format.mintick) +
                     "\nPrevious open: " + str.tostring(previousOpen, format.mintick) +
                     "\nPrevious high: " + str.tostring(previousHigh, format.mintick) +
                     "\nPrevious low: " + str.tostring(previousLow, format.mintick) +
                     "\nPrevious close: " + str.tostring(previousClose, format.mintick) +
                     "\nFirst arrival: " + f_arrivalState(rank) +
                     "\nArrival basis: " + f_touchName() +
                     "\nEffective timing: " + effectiveTimingText

                if na(edgeLabel)
                    edgeLabel := label.new(
                         labelXTime,
                         level,
                         labelText,
                         xloc = xloc.bar_time,
                         yloc = yloc.price,
                         style = label.style_label_left,
                         color = color.new(baseColor, focused ? math.max(0, labelTransparencyInput - 5) : labelTransparencyInput),
                         textcolor = f_levelTextColor(index),
                         size = f_labelSize(labelSizeInput),
                         textalign = text.align_left,
                         tooltip = tooltipText)
                    array.set(activeEdgeLabels, index, edgeLabel)
                else
                    label.set_xy(edgeLabel, labelXTime, level)
                    label.set_text(edgeLabel, labelText)
                    label.set_color(edgeLabel, color.new(baseColor, focused ? math.max(0, labelTransparencyInput - 5) : labelTransparencyInput))
                    label.set_textcolor(edgeLabel, f_levelTextColor(index))
                    label.set_size(edgeLabel, f_labelSize(labelSizeInput))
                    label.set_textalign(edgeLabel, text.align_left)
                    label.set_tooltip(edgeLabel, tooltipText)
            else if labelModeInput == "Off" and not na(edgeLabel)
                label.delete(edgeLabel)
                array.set(activeEdgeLabels, index, na)

    if showFocusHaloInput and focusIndex >= 0
        float focusLevel = array.get(activeLevels, focusIndex)
        int focusLane = array.get(activeLevelLanes, focusIndex)
        int focusX2Time = f_timeOffset(drawingAnchorTime, labelOffsetInput + focusLane * labelLaneSpacingInput)
        color focusColor = f_levelColor(focusIndex)
        if na(activeFocusHalo)
            activeFocusHalo := line.new(
                 activeDayStartTime,
                 focusLevel,
                 focusX2Time,
                 focusLevel,
                 xloc = xloc.bar_time,
                 extend = extend.none,
                 color = color.new(focusColor, focusHaloTransparencyInput),
                 style = line.style_solid,
                 width = 4)
        else
            line.set_xy1(activeFocusHalo, activeDayStartTime, focusLevel)
            line.set_xy2(activeFocusHalo, focusX2Time, focusLevel)
            line.set_color(activeFocusHalo, color.new(focusColor, focusHaloTransparencyInput))
            line.set_style(activeFocusHalo, line.style_solid)
            line.set_width(activeFocusHalo, 4)
    else if not na(activeFocusHalo)
        line.delete(activeFocusHalo)
        activeFocusHalo := na

    for contextIndex = 0 to CONTEXT_COUNT - 1
        float contextValue = array.get(activeContextValues, contextIndex)
        line contextLine = array.get(activeContextLines, contextIndex)
        int lane = array.get(activeContextLanes, contextIndex)
        int contextXTime = f_timeOffset(drawingAnchorTime, labelOffsetInput + contextLabelExtraOffsetInput + lane * labelLaneSpacingInput)
        int contextLineX2Time = showContextLabelsInput ? contextXTime : f_timeOffset(drawingAnchorTime, labelOffsetInput)
        if not na(contextLine)
            line.set_x2(contextLine, contextLineX2Time)
            line.set_y1(contextLine, contextValue)
            line.set_y2(contextLine, contextValue)
            line.set_color(contextLine, color.new(f_contextColor(contextIndex), 12))
            line.set_style(contextLine, f_contextStyle(contextIndex))

        label contextLabel = array.get(activeContextLabels, contextIndex)
        if barstate.islast and showContextLabelsInput and not na(contextLine)
            string contextText = f_contextName(contextIndex) + "  " + str.tostring(contextValue, format.mintick)
            color contextColor = f_contextColor(contextIndex)
            if na(contextLabel)
                contextLabel := label.new(
                     contextXTime,
                     contextValue,
                     contextText,
                     xloc = xloc.bar_time,
                     yloc = yloc.price,
                     style = label.style_label_left,
                     color = color.new(contextColor, labelTransparencyInput),
                     textcolor = f_contextTextColor(contextColor),
                     size = f_labelSize(labelSizeInput),
                     textalign = text.align_left)
                array.set(activeContextLabels, contextIndex, contextLabel)
            else
                label.set_xy(contextLabel, contextXTime, contextValue)
                label.set_text(contextLabel, contextText)
                label.set_color(contextLabel, color.new(contextColor, labelTransparencyInput))
                label.set_textcolor(contextLabel, f_contextTextColor(contextColor))
                label.set_size(contextLabel, f_labelSize(labelSizeInput))
        else if not showContextLabelsInput and not na(contextLabel)
            label.delete(contextLabel)
            array.set(activeContextLabels, contextIndex, na)

    if not na(activeCprBox)
        box.set_right(activeCprBox, drawingAnchorTime)
        box.set_top(activeCprBox, array.get(activeContextValues, CTX_CPR_HIGH))
        box.set_bottom(activeCprBox, array.get(activeContextValues, CTX_CPR_LOW))

    if not na(activeOpeningBox)
        box.set_right(activeOpeningBox, drawingAnchorTime)

//==============================================================================
// Compact session brief
//==============================================================================
var table sessionBrief = table.new(
     f_tablePosition(briefPositionInput),
     2,
     7,
     bgcolor = color.new(chart.bg_color, briefTransparencyInput),
     frame_color = color.new(chart.fg_color, 75),
     frame_width = 1,
     border_color = color.new(chart.fg_color, 86),
     border_width = 1)

if barstate.islast
    if showSessionBriefInput
        int visibleCount = 0
        int reachedCount = 0
        int nearestUnreachedIndex = -1
        float nearestUnreachedDistance = na
        for index = 0 to LEVEL_COUNT - 1
            if array.get(activeDisplayVisible, index)
                visibleCount += 1
                int rank = array.get(arrivalRanks, index)
                reachedCount += rank > 0 ? 1 : 0
                if rank == 0 and not na(displaySourceClose)
                    float level = array.get(activeLevels, index)
                    float distance = math.abs(displaySourceClose - level)
                    if na(nearestUnreachedDistance) or distance < nearestUnreachedDistance
                        nearestUnreachedDistance := distance
                        nearestUnreachedIndex := index

        float pivotLevel = array.get(activeLevels, IDX_P)
        string openRelation = na(pivotLevel) or na(currentDayOpenState) ? "n/a" : math.abs(currentDayOpenState - pivotLevel) < syminfo.mintick * 0.5 ? "At P" : currentDayOpenState > pivotLevel ? "Above P" : "Below P"
        string nextText = not trackArrivalInput ? "Tracking off" : nearestUnreachedIndex >= 0 ? array.get(activeDisplayCodes, nearestUnreachedIndex) + "  " + str.tostring(array.get(activeLevels, nearestUnreachedIndex), format.mintick) : visibleCount > 0 and reachedCount >= visibleCount ? "All reached" : "n/a"
        string timingText = liveTimingEffective ? "Live wick latch" : eventTimingInput == "Live bar" and touchBasisInput != "Wick" ? "Confirmed safeguard" : "Confirmed bar"
        string readinessText = not isIntradayChart ? "Use intraday" : not validPreviousDay ? "Waiting for prior day" : not sourceBarAvailable ? "Source bar unavailable" : not dailyContextAligned ? "Aligning daily data" : not syntheticEventsAllowed ? "Synthetic events paused" : not firstDayEventsComplete ? "First day partial" : "Ready"
        color panelBg = color.new(chart.bg_color, briefTransparencyInput)
        color headerBg = color.new(pivotColorInput, 14)
        string panelTextSize = f_labelSize(briefSizeInput)
        color headerText = labelTextModeInput == "Auto contrast" ? f_autoTextColor(pivotColorInput) : pivotTextColorInput

        table.cell(sessionBrief, 0, 0, "Previous Day Pivot Path", text_color = headerText, text_size = panelTextSize, bgcolor = headerBg)
        table.cell(sessionBrief, 1, 0, readinessText, text_color = chart.fg_color, text_size = panelTextSize, bgcolor = panelBg)
        table.cell(sessionBrief, 0, 1, "Method", text_color = chart.fg_color, text_size = panelTextSize, bgcolor = panelBg)
        table.cell(sessionBrief, 1, 1, f_methodName(), text_color = chart.fg_color, text_size = panelTextSize, bgcolor = panelBg)
        table.cell(sessionBrief, 0, 2, "Prior range", text_color = chart.fg_color, text_size = panelTextSize, bgcolor = panelBg)
        table.cell(sessionBrief, 1, 2, validPreviousDay ? str.tostring(previousRange, format.mintick) : "n/a", text_color = chart.fg_color, text_size = panelTextSize, bgcolor = panelBg)
        table.cell(sessionBrief, 0, 3, "Open relation", text_color = chart.fg_color, text_size = panelTextSize, bgcolor = panelBg)
        table.cell(sessionBrief, 1, 3, openRelation, text_color = chart.fg_color, text_size = panelTextSize, bgcolor = panelBg)
        table.cell(sessionBrief, 0, 4, "Reached", text_color = chart.fg_color, text_size = panelTextSize, bgcolor = panelBg)
        table.cell(sessionBrief, 1, 4, str.tostring(reachedCount) + "/" + str.tostring(visibleCount), text_color = chart.fg_color, text_size = panelTextSize, bgcolor = panelBg)
        table.cell(sessionBrief, 0, 5, "Next unreached", text_color = chart.fg_color, text_size = panelTextSize, bgcolor = panelBg)
        table.cell(sessionBrief, 1, 5, nextText, text_color = chart.fg_color, text_size = panelTextSize, bgcolor = panelBg)
        table.cell(sessionBrief, 0, 6, "Timing / source", text_color = chart.fg_color, text_size = panelTextSize, bgcolor = panelBg)
        table.cell(sessionBrief, 1, 6, timingText + " / " + f_sourceName(useStandardSource), text_color = chart.fg_color, text_size = panelTextSize, bgcolor = panelBg)
    else
        table.clear(sessionBrief, 0, 0, 1, 6)

//==============================================================================
// Safety notices
//==============================================================================
if barstate.islast
    string noticeText = ""
    if not isIntradayChart
        noticeText := "This indicator is designed for time-based intraday charts.\nSwitch to a seconds or minutes timeframe."
    else if not validPreviousDay
        noticeText := "Confirmed previous-day OHLC is not available."
    else if not sourceBarAvailable
        noticeText := "No selected-source bar aligns with the current chart timestamp.\nDrawings are frozen at the last valid bar; arrival events are paused."
    else if not dailyContextAligned
        noticeText := "Waiting for daily data to align with the current source day.\nNew levels and arrival events remain paused until alignment."
    else if not chart.is_standard and sourceModeInput == "Chart context"
        noticeText := "Chart-context OHLC is selected.\nOn synthetic charts, formula values also use synthetic prices."
    else if trackArrivalInput and not syntheticEventsAllowed
        noticeText := "Arrival events are paused on this synthetic chart.\nLevels remain visible."
    else if not firstDayEventsComplete
        noticeText := "The first loaded day starts mid-session.\nArrival tracking is paused and open-dependent features are safely bypassed for that day."

    if showSafetyNoticeInput and noticeText != ""
        float noticeY = validSourceBar ? sourceHigh : high
        if na(safetyNotice)
            safetyNotice := label.new(
                 bar_index,
                 noticeY,
                 noticeText,
                 xloc = xloc.bar_index,
                 yloc = yloc.abovebar,
                 style = label.style_label_down,
                 color = color.new(color.gray, 12),
                 textcolor = color.white,
                 size = size.small)
        else
            label.set_xy(safetyNotice, bar_index, noticeY)
            label.set_text(safetyNotice, noticeText)
    else if not na(safetyNotice)
        label.delete(safetyNotice)
        safetyNotice := na

//==============================================================================
// Neutral alerts and hidden payloads
//==============================================================================
float activePivotValue = array.get(activeLevels, IDX_P)
bool pivotCrossUpRaw = not na(activePivotValue) and not na(priorValidSourceClose) and sourceClose > activePivotValue and priorValidSourceClose <= activePivotValue
bool pivotCrossDownRaw = not na(activePivotValue) and not na(priorValidSourceClose) and sourceClose < activePivotValue and priorValidSourceClose >= activePivotValue
bool confirmedPivotCrossUp = enablePivotCrossAlertsInput and isIntradayChart and activeDayInitialized and validSourceBar and not newExchangeDay and barstate.isconfirmed and pivotCrossUpRaw
bool confirmedPivotCrossDown = enablePivotCrossAlertsInput and isIntradayChart and activeDayInitialized and validSourceBar and not newExchangeDay and barstate.isconfirmed and pivotCrossDownRaw

float arrivalPLevel = arrivalPEvent ? array.get(activeLevels, IDX_P) : na
float arrivalR1Level = arrivalR1Event ? array.get(activeLevels, IDX_R1) : na
float arrivalS1Level = arrivalS1Event ? array.get(activeLevels, IDX_S1) : na
float arrivalR2Level = arrivalR2Event ? array.get(activeLevels, IDX_R2) : na
float arrivalS2Level = arrivalS2Event ? array.get(activeLevels, IDX_S2) : na
float arrivalR3Level = arrivalR3Event ? array.get(activeLevels, IDX_R3) : na
float arrivalS3Level = arrivalS3Event ? array.get(activeLevels, IDX_S3) : na

plot(arrivalAnyLevel, title = "Any arrival level", display = display.none, editable = false)
plot(arrivalPLevel, title = "P arrival level", display = display.none, editable = false)
plot(arrivalR1Level, title = "R1 arrival level", display = display.none, editable = false)
plot(arrivalS1Level, title = "S1 arrival level", display = display.none, editable = false)
plot(arrivalR2Level, title = "R2 arrival level", display = display.none, editable = false)
plot(arrivalS2Level, title = "S2 arrival level", display = display.none, editable = false)
plot(arrivalR3Level, title = "R3 arrival level", display = display.none, editable = false)
plot(arrivalS3Level, title = "S3 arrival level", display = display.none, editable = false)
plot(confirmedPivotCrossUp or confirmedPivotCrossDown ? activePivotValue : na, title = "Pivot cross level", display = display.none, editable = false)

bool arrivalAlertGate = enableArrivalAlertsInput and pathEnvironmentReady

alertcondition(arrivalAlertGate and arrivalAnyEvent, "Any pivot first reached", 'One or more previous-day pivot levels recorded a first arrival near {{plot("Any arrival level")}}.')
alertcondition(arrivalAlertGate and arrivalPEvent, "Pivot P first reached", 'Previous-day central pivot P recorded its first arrival near {{plot("P arrival level")}}.')
alertcondition(arrivalAlertGate and arrivalR1Event, "R1 first reached", 'Previous-day R1 recorded its first arrival near {{plot("R1 arrival level")}}.')
alertcondition(arrivalAlertGate and arrivalS1Event, "S1 first reached", 'Previous-day S1 recorded its first arrival near {{plot("S1 arrival level")}}.')
alertcondition(arrivalAlertGate and arrivalR2Event, "R2 first reached", 'Previous-day R2 recorded its first arrival near {{plot("R2 arrival level")}}.')
alertcondition(arrivalAlertGate and arrivalS2Event, "S2 first reached", 'Previous-day S2 recorded its first arrival near {{plot("S2 arrival level")}}.')
alertcondition(arrivalAlertGate and arrivalR3Event, "R3 first reached", 'Previous-day R3 recorded its first arrival near {{plot("R3 arrival level")}}.')
alertcondition(arrivalAlertGate and arrivalS3Event, "S3 first reached", 'Previous-day S3 recorded its first arrival near {{plot("S3 arrival level")}}.')
alertcondition(confirmedPivotCrossUp, "Confirmed close crossed above P", 'A confirmed close crossed above previous-day pivot P near {{plot("Pivot cross level")}}.')
alertcondition(confirmedPivotCrossDown, "Confirmed close crossed below P", 'A confirmed close crossed below previous-day pivot P near {{plot("Pivot cross level")}}.')
````
