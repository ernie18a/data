# Gold Toolkit 22 [MatsukazeAlgo]

- url: https://www.tradingview.com/script/VspAn3Gf-Gold-Toolkit-22-MatsukazeAlgo/
- type: indicator
- pine_id: PUB;461496489de940a1874893ee3ebde4e0
- version: 1.0

## Description

🇬🇧 ENGLISH

A modular indicator that consolidates 22 Gold-specialized analysis tools into a single script. Each module can be toggled independently — enable one or two at a time for focused analysis. The shared infrastructure provides session awareness, Dollar Index correlation, and psychological price level detection across every module. Designed exclusively for XAUUSD on intraday timeframes.

Concepts

Modular Architecture -- Most indicators serve a single purpose: one trend filter, one oscillator, one pattern detector. For Gold traders who use multiple tools, this means loading 5–10 separate indicators, each consuming chart resources and requiring independent configuration. A modular architecture solves this by housing all tools within a single script, sharing a common infrastructure layer. Each module runs its own logic but inherits the same session detection, DXY feed, and psychological level engine. The result is consistent behavior across all tools without duplicate calculations.

Session-Dependent Behavior -- Gold does not trade the same way at all hours. The Asia session (19:00–03:00 ET) is characterized by tight ranges and stop runs that reverse at the London open. The London session (03:00–09:00 ET) produces directional breakouts driven by European institutional flow. The New York session (09:00–17:00 ET) carries the highest volume and tends to either continue the London move or reverse it sharply. An indicator that applies the same parameters across all three sessions is ignoring 60% of the context. Every module in this toolkit reads the current session and adjusts its signal thresholds accordingly. Asia signals require stronger confirmation. London signals favor trend continuation. NY signals weight volume more heavily.

Inverse Dollar Correlation -- Gold is priced in US Dollars. When the Dollar strengthens, Gold tends to fall. When the Dollar weakens, Gold tends to rise. This inverse relationship is not perfect on every bar, but over any meaningful sample it dominates. The toolkit reads TVC:DXY (US Dollar Index) daily data on every bar. Bull signals across all modules require a weak Dollar context (DXY close below open). Bear signals require a strong Dollar context. This single filter eliminates a substantial number of false signals that would otherwise fire against the macro trend.

Psychological Price Levels -- Gold reacts consistently at $50 and $100 round numbers. Institutional orders cluster at $4,500, $4,550, $4,600, and similar levels. When price approaches these levels, the toolkit tightens sensitivity and marks signals with a ★ indicator. A Stop Run Reversal scoring 85/100 at $4,550 is qualitatively different from the same score at $4,537 — the psychological level adds an independent layer of institutional confluence.

Modules

The 22 modules are organized into five categories. Each module is a complete analysis tool.

Trend Modules

01 ML Supertrend — A Supertrend variant with a session-learning engine. Tracks flip outcomes per session and adjusts the band multiplier over time. Sessions with low win rates get wider bands (fewer signals). Sessions with high win rates get tighter bands (more signals). Volume surge filter and RSI confirmation prevent signals in thin markets. The dashboard shows per-session win rates, current adapted multiplier, and learning state.

04 Parabolic SAR — Standard SAR calculation with two additions: age-based transparency fading and momentum scoring. Fresh SAR dots are fully opaque. As the trend ages, dots fade toward transparency, giving a visual read on trend maturity without cluttering the chart. The momentum score measures the distance between price and SAR relative to ATR. A high score means price is accelerating away from the SAR. A collapsing score warns of an impending flip. Multi-timeframe alignment check confirms whether the higher timeframe SAR agrees.

05 ACN Trend — An adaptive coral noise filter that outputs a smoothed trend line with risk zones above and below. The noise score quantifies how choppy the current market is. When noise exceeds the threshold, the background shades as a warning to avoid trading. The conviction meter is the inverse of noise — a high conviction reading means clean trend conditions. Bull/Bear signal counts per session track which sessions produce the most reliable signals for your timeframe.

09 Anchored Channels — A dual-layer channel system. Macro channels connect confirmed swing pivots and project forward with band widths derived from maximum deviation. Micro channels fit a short-term linear regression to the most recent bars. When price breaks the macro channel, it is classified as BRK (breakout). When price returns to the channel boundary, it is PB (pullback). When the micro channel aligns with the macro direction, it is CONT (continuation). The MTF screener checks two higher timeframes for directional agreement. A status badge labels the overall trend bias.

18 Asymmetric Trend — Uses different thresholds for entering and exiting a trend. The entry threshold is tight — price must move strongly to flip the trend. The exit threshold is wide — the trend persists through normal retracements. This asymmetry reduces whipsaws in ranging markets while catching genuine trend changes quickly. Gradient fill between the trend line and price shows acceleration visually. Reversal diamond markers appear at flip points with session tags and trend age.

Reversal Modules

02 Stop Run Reversal — Detects when price pierces a range boundary (liquidity grab) and reverses. Each event is scored 0–100 based on wick ratio, penetration depth, volume spike, DXY alignment, and session context. Zone boxes mark the reversal area with reference, invalidation, and target lines. A pending state tracker monitors setups that have not yet confirmed, preventing premature signals. Session and DXY tags on each label provide immediate context.

06 Arc Momentum — A non-linear RSI oscillator. Instead of plotting RSI as a flat line, the oscillator curves toward price in an arc. When the arc flips direction, a signal fires. Divergence detection compares RSI pivot extremes against price pivot extremes and flags when they disagree. The momentum zone classification (Overbought / Bull / Neutral / Bear / Oversold) shades the background for a quick visual read on the current state.

11 Harmonic Patterns — Scans for five harmonic patterns: Bat, Gartley, Butterfly, Crab, and Shark. Both bullish (XABCD with D at bottom) and bearish (XABCD with D at top) configurations are detected. Each pattern is scored based on session quality, DXY alignment, and proximity to psychological levels. Fibonacci projection levels are drawn at the PRZ (Potential Reversal Zone) showing 0.382, 0.618, 1.0, 1.272, and 1.618 targets. The tolerance parameter controls how strictly the Fibonacci ratios must match the textbook definitions.

16 RSI Swing Structure — Uses RSI overbought and oversold zones to define swing points. When RSI enters OB and price makes a high, that high is labeled. When RSI enters OS and price makes a low, that low is labeled. Each swing point is classified as HH (Higher High), HL (Higher Low), LH (Lower High), or LL (Lower Low). When the classification sequence breaks — for example, a HH followed by a LL — the indicator labels it as CHoCH (Change of Character). When the sequence continues — HH followed by another HH — it labels BOS (Break of Structure). Swing connecting lines visually link the pivots. RSI value appears on each label.

Structure Modules

03 EMA Inversion — Three EMAs (21, 55, 200) with ribbon fill. The indicator tracks Fair Value Gaps that form during trend moves. When an FVG is subsequently filled from the opposite direction (inverse FVG flip), a signal fires. Built-in SL/TP management uses the most recent swing high/low for stop placement and projects a 1:1 target. A cooldown timer prevents re-entry immediately after a stop-out. The trade state label shows whether the indicator considers the current position LONG, SHORT, or FLAT.

08 SwingRegress — Anchors linear regression channels to swing pivot confirmations. When a CHoCH occurs (price breaks the previous swing extreme), a new channel begins from the most recent opposite pivot. The channel slope and deviation are calculated from all bars within the segment. Band 1 and Band 2 at configurable standard deviations define the channel width. A linefill between the bands makes the channel body visible. Psychological price levels within the channel are drawn as dotted gold lines. A Bollinger/Keltner squeeze detector highlights when volatility compresses inside the channel — often a precursor to the next directional move.

10 S/R Zones — Builds support and resistance zones from volume-weighted pivot clustering. Nearby pivots are merged into zones. Each zone receives a strength score based on the number of touches, volume at touch, and recency. When price breaks through a zone, it is flagged. When price returns to a broken zone from the other side, it is flagged as a retest. Ghost zones keep broken levels visible with faded opacity. Star ratings provide a quick strength summary. An age-based decay ensures old, untested zones gradually disappear.

12 FVG Wave — Tracks Fair Value Gaps across the chart with session-colored rendering. Asia FVGs are rose, London FVGs are teal, NY FVGs are sky blue. Each FVG has a POC (midpoint) dotted line. When price touches the POC, a detection event fires. Age-based opacity fading dims old FVGs. Mitigation tracking removes FVGs that have been completely filled. Ghost mode optionally keeps mitigated FVGs visible in muted colors for reference.

17 OB Zone Study — Detects order blocks at displacement candles that follow swing pivots. Each OB is scored with a breakdown showing trend alignment, location quality, session, DXY confluence, and psychological level proximity. Mitigation tracking monitors whether price returns to the OB. Once mitigated, the OB is removed. Age-based opacity fading gradually dims unmitigated OBs that have been on the chart for a long time.

19 Vector SMC — Smart Money Concepts with a volume gate. FVGs and order blocks are only detected when the candle's volume exceeds the average by a configurable multiplier. This filters out structural patterns formed on low participation. OBs extend forward and are automatically invalidated when price closes through them. Sweep labels mark liquidity grabs at swing highs and lows where volume confirms institutional activity.

Session Modules

13 Session Range — Tracks the OHLC of Asia, London, and NY sessions in real time. A candle panel visualizes each session's range as a mini candlestick. 25% retracement lines for the London range identify the level where NY price action tends to react. H/M/L/O reference lines project key session levels forward. Regime classification analyzes the session structure pattern (e.g., London Partial Up, London Full Range). Asia sweep detection identifies whether the Asia high or low was taken during London. A stats table shows historical percentages for session behavior patterns.

15 Session Killzones — Draws boxes for Asia, London, NY AM, and NY PM killzone periods. When a killzone closes, its high and low are recorded as levels. These levels extend forward as dashed lines until price sweeps through them. Anticipation bars project the levels further for planning. When a sweep occurs, a detection label marks the bar. Session name labels identify each killzone box.

20 AlgoPath — Plots previous day high and low as horizontal lines. The equilibrium level (midpoint of PDH and PDL) is drawn as a dashed line. London session open and NY session open are drawn when each session begins. New day background shading marks the daily boundary. Whale candle detection flags abnormally large candles — those with body size exceeding a configurable ATR multiple — with session-colored labels showing the session name and exact time.

Volume and Correlation Modules

07 Minicharts — Displays Silver (XAG/USD), Dollar Index (DXY), and Gold Futures (GC1!) in a correlation panel. Each symbol shows EMA position (above/below). SMT (Smart Money Technique) divergence detection flags when Gold moves in the opposite direction to a correlated asset — a potential early warning of reversal.

14 Institutional Volume — Identifies accumulation and distribution phases using volume clustering analysis. When multiple high-volume candles with consistent directional bias appear within a lookback window, the indicator flags the zone. Climax volume detection identifies bars where volume × range reaches the highest level in the lookback period. Zone boxes mark the accumulation or distribution area on the chart.

21 Swing TPO — Builds Time Price Opportunity distributions anchored to swing points. The price range between swing pivots is divided into bins, and each TPO period assigns a letter to every visited bin. Gradient-colored boxes range from cool (low activity) to warm (high activity). The POC (Point of Control) line marks the highest-activity price. Psychological level detection flags when the POC lands near a $50/$100 round number.

22 VWAP — Dual-anchor Volume Weighted Average Price. The primary anchor resets on Session, Week, or Month boundaries. An optional second anchor provides a longer-term VWAP for confluence. Standard deviation bands at 1σ and 2σ show statistical extremes. Previous period VWAP, VAH (Value Area High), and VAL (Value Area Low) levels persist as reference lines with price labels. Band touch signals flag when price reaches the 2σ extreme. Slope direction indicates whether the VWAP is rising, falling, or flat.

How to Use

1. Open indicator settings. Under "Module Select," enable 1–2 modules.
2. Configure "Gold Settings" for session filtering, DXY, and psychological levels.
3. Apply to XAUUSD on your preferred intraday timeframe (5m–4h recommended).
4. Use the Style tab to show/hide individual signal shapes.
5. The module panel (top right) shows all 22 modules with the active one highlighted in gold.

Shared Infrastructure

Session Detection — Automatically identifies Asia (19:00–03:00 ET), London (03:00–09:00 ET), and New York (09:00–17:00 ET). Each module reads the current session for parameter adjustment and signal filtering.

DXY Feed — Pulls TVC:DXY daily open and close. Determines whether the Dollar is strengthening or weakening on the day. All modules use this for macro alignment.

ATR Normalization — All distance calculations (band widths, displacement thresholds, target projections) are normalized to the 14-period ATR. This ensures consistent behavior across timeframes and volatility regimes.

Psychological Level Engine — Configurable interval ($25, $50, or $100). Detects proximity to round numbers and flags signals near these levels with ★ markers. Multiple modules use this for confluence scoring.

Signal Bus — When any active module generates a Buy or Sell signal, it writes to a shared signal bus. The unified output shapes fire from this bus, providing a consistent visual regardless of which module produced the signal.

Module Panel — The top-right panel lists all 22 modules. The active module is highlighted in gold. Inactive modules are dimmed. Session, DXY, and daily range are displayed in the header and footer.

Input Reference

Module Select — 22 boolean toggles, one per module. Default: Module 01 ON, all others OFF.

Gold Settings — Session Filter (ON), Asia Signals (OFF), London Signals (ON), NY Signals (ON), Show DXY (ON), Psych $50/$100 (ON), Psych Interval (50), Show Panel (ON).

Each module has its own parameter group accessible when that module is enabled.

---

🇯🇵 日本語

22のゴールド専用分析モジュールを1つのインジケーターに統合したモジュラー型ツール。各モジュールは設定パネルから個別にON/OFF可能 — 1〜2個ずつ有効にして使用。共通インフラがセッション認識、ドルインデックス相関、心理的価格帯検出を全モジュールに提供。XAUUSD日中足専用設計。

コンセプト

モジュラーアーキテクチャ -- 多くのインジケーターは単一目的。複数ツールを使うゴールドトレーダーは5〜10個のインジを個別にロードする必要がある。モジュラーアーキテクチャはすべてのツールを単一スクリプトに収容し、共通インフラ層を共有することで解決。各モジュールは独自ロジックを実行しつつ、同一のセッション検出、DXYフィード、心理的価格帯エンジンを継承。

セッション依存型動作 -- ゴールドは時間帯によって異なる動きをする。アジア（19:00–03:00 ET）はタイトレンジとストップラン。ロンドン（03:00–09:00 ET）は欧州機関投資家フローによる方向性ブレイクアウト。ニューヨーク（09:00–17:00 ET）は最大ボリュームでロンドンの継続か急反転。全セッションに同じパラメータを適用するインジケーターは文脈の60%を無視している。本ツールキットの全モジュールは現在のセッションを読み取り、シグナル閾値を調整。

ドル逆相関 -- ゴールドはUSドル建て。ドル高→ゴールド下落、ドル安→ゴールド上昇の逆相関が支配的。TVC:DXY日足データを毎バー読み取り、Bullシグナルはドル安文脈、Bearシグナルはドル高文脈を要求。このフィルターだけでマクロトレンドに逆行する偽シグナルの大部分を排除。

心理的価格帯 -- ゴールドは$50/$100刻みのラウンドナンバーで一貫して反応。機関投資家の注文が$4,500、$4,550、$4,600等に集中。価格がこれらのレベルに接近すると感度を引き締め、★マーカーでシグナルを強調。

モジュール一覧

トレンド系 — 01 ML Supertrend：セッション学習エンジン搭載、勝率追跡・自動調整。04 Parabolic SAR：経過時間フェード、モメンタムスコア、MTFアライメント。05 ACN Trend：適応型コーラルノイズフィルター、ノイズスコア、コンビクションメーター。09 Anchored Channels：マクロ+マイクロ二層チャネル、BRK/PB/CONT分類、MTFスクリーナー。18 Asymmetric Trend：非対称閾値フィルター、グラデーション塗り、リバーサルダイヤ。

リバーサル系 — 02 Stop Run Reversal：流動性奪取検出、0–100スコアリング、ゾーンボックス。06 Arc Momentum：非線形アーク型RSI、ダイバージェンス検出、ゾーン背景表示。11 Harmonic Patterns：5種パターン（Bull+Bear）、フィボナッチ投影。16 RSI Swing Structure：HH/HL/LH/LL分類、CHoCH/BOS検出。

ストラクチャー系 — 03 EMA Inversion：3本EMAリボン+FVG追跡+iFVGフリップ。08 SwingRegress：ピボット固定LRC、CHoCH/BOS、スクイーズ検出。10 S/R Zones：出来高加重クラスタリング、強度スコア、リテスト追跡。12 FVG Wave：セッション色分けFVG、POC、ミティゲーション追跡。17 OB Zone Study：OB検出+スコア内訳+経過フェード。19 Vector SMC：出来高ゲート付きSMC。

セッション系 — 13 Session Range：Asia/London/NY OHLC、キャンドルパネル、25%ライン、レジーム分類。15 Session Killzones：キルゾーンボックス+未スイープレベル追跡。20 AlgoPath：前日高安、イクイリブリアム、ホエールキャンドル。

ボリューム・相関系 — 07 Minicharts：Silver/DXY/GC相関パネル、SMT検出。14 Institutional Volume：蓄積/分配検出、クライマックス出来高。21 Swing TPO：グラデーションTPO分布、POC。22 VWAP：デュアルアンカー、σバンド、前期間レベル。

使い方

1. 設定の「Module Select」で1〜2個を有効化。
2. 「Gold Settings」でセッションフィルター、DXY、心理的価格帯を設定。
3. XAUUSD日中足（5分〜4時間推奨）に適用。
4. 右上のモジュールパネルで全22モジュールの状態を確認。有効モジュールはゴールドで表示。

共通インフラ — セッション検出（Asia/London/NY自動識別）、DXYフィード（$の強弱判定）、ATR正規化、心理的価格帯エンジン（$25/$50/$100）、シグナルバス（統一Buy/Sell出力）、モジュールパネル（全22モジュール一覧表示）。

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MatsukazeAlgo
// Gold Toolkit 22 — 22 Gold-specialized modules, one indicator
// Toggle 1-2 modules ON per chart.

//@version=6
indicator('Gold Toolkit 22 [MatsukazeAlgo]', overlay = true, max_bars_back = 5000, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500, dynamic_requests = true, format = format.inherit, precision = 2)

// ═══════════════ MODULE TOGGLES ═══════════════
string gM = "Module Select"
bool M01 = input.bool(true,  "01 ML Supertrend",     group=gM)
bool M02 = input.bool(false, "02 Stop Run Reversal", group=gM)
bool M03 = input.bool(false, "03 EMA Inversion",     group=gM)
bool M04 = input.bool(false, "04 Parabolic SAR",     group=gM)
bool M05 = input.bool(false, "05 ACN Trend",         group=gM)
bool M06 = input.bool(false, "06 Arc Momentum",      group=gM)
bool M07 = input.bool(false, "07 Minicharts",        group=gM)
bool M08 = input.bool(false, "08 SwingRegress",      group=gM)
bool M09 = input.bool(false, "09 Anchored Channels", group=gM)
bool M10 = input.bool(false, "10 S/R Zones",         group=gM)
bool M11 = input.bool(false, "11 Harmonic Patterns",group=gM)
bool M12 = input.bool(false, "12 FVG Wave",          group=gM)
bool M13 = input.bool(false, "13 Session Range",     group=gM)
bool M14 = input.bool(false, "14 Inst Volume",       group=gM)
bool M15 = input.bool(false, "15 Session Killzones", group=gM)
bool M16 = input.bool(false, "16 RSI Swing",         group=gM)
bool M17 = input.bool(false, "17 OB Zone Study",     group=gM)
bool M18 = input.bool(false, "18 Asymmetric Trend",  group=gM)
bool M19 = input.bool(false, "19 Vector SMC",        group=gM)
bool M20 = input.bool(false, "20 AlgoPath",          group=gM)
bool M21 = input.bool(false, "21 Swing TPO",         group=gM)
bool M22 = input.bool(false, "22 VWAP",              group=gM)

// ═══════════════ SHARED INFRASTRUCTURE ═══════════════
color P_BU=#5A9E97
color P_BE=#A85656
color P_GO=#C4A35A
color P_SK=#5A8FA8
color P_GN=#5A9E6B
color P_RD=#C94C4C
color P_DM=#6A6A7A
color P_PBG=color.new(#080B12,4)
color P_ROW=color.new(#101420,6)
color P_SEP=color.new(#1E2638,10)

string gG="Gold Settings"
bool  GS=input.bool(true,"Session Filter",group=gG)
bool  GA=input.bool(false,"Asia Signals",group=gG)
bool  GL=input.bool(true,"London Signals",group=gG)
bool  GN=input.bool(true,"NY Signals",group=gG)
bool  GD=input.bool(true,"Show DXY",group=gG)
bool  GP=input.bool(true,"Psych $50/$100",group=gG)
int   GPI=input.int(50,"Psych Interval",options=[25,50,100],group=gG)
bool  GPan=input.bool(true,"Show Panel",group=gG)

string _tz="America/New_York"
float _iA=math.sign(nz(time(timeframe.period,"1800-0200",_tz)))
float _iL=math.sign(nz(time(timeframe.period,"0200-0800",_tz)))
float _iN=math.sign(nz(time(timeframe.period,"0800-1700",_tz)))
sid()=>_iN>0?3:_iL>0?2:_iA>0?1:0
snm()=>sid()==3?"NY":sid()==2?"London":sid()==1?"Asia":"Off"
scl()=>sid()==3?P_SK:sid()==2?P_BU:sid()==1?P_BE:P_DM
sok()=>not GS or not timeframe.isintraday?true:sid()==1?GA:sid()==2?GL:sid()==3?GN:false
srg()=>sid()==1?0.15:sid()==2?0.5:sid()==3?0.85:0.5

float _dC=request.security("TVC:DXY","D",close)
float _dO=request.security("TVC:DXY","D",open)
bool dOk=GD and not na(_dC) and not na(_dO)
bool dUp=dOk and _dC>_dO
psy(float p)=>GP and p>100?math.abs(p-math.round(p/GPI)*GPI)<=5:false

float ATR14=ta.atr(14)
float ATRD=request.security(syminfo.tickerid,"D",ta.atr(14))
float DHI=request.security(syminfo.tickerid,"D",high)
float DLO=request.security(syminfo.tickerid,"D",low)

var bool sB=false
var bool sS=false
var bool sBP=false
var bool sSP=false
var string sSrc=""
sB:=false
sS:=false
sBP:=false
sSP:=false
sSrc:=""


var line sc_vl_a = na
var line sc_vl_l = na
var line sc_vl_n = na
var label sc_vl_a_lb = na
var label sc_vl_l_lb = na
var label sc_vl_n_lb = na
// ═══════════════ 01: ML SUPERTREND PRO ═══════════════
// BLUEPRINT: getSessionOffset, getAdaptedMult, serializeState,
//   learn_window, Volume filter, Dashboard(18cell), 4 alertcondition
string g01="01 ML Supertrend"
int    m1_atrP=input.int(14,"ATR Period",minval=5,maxval=100,group=g01)
float  m1_mult=input.float(1.5,"Band Width",minval=0.5,maxval=5.0,step=0.1,group=g01)
int    m1_space=input.int(8,"Signal Spacing",minval=1,maxval=100,group=g01)
bool   m1_learn=input.bool(true,"Session Learning",group=g01)
float  m1_lr=input.float(0.05,"Learn Rate",minval=0.01,maxval=0.2,step=0.01,group=g01)
float  m1_amax=input.float(0.5,"Max Adapt",minval=0.1,maxval=1.0,step=0.1,group=g01)
int    m1_eval=input.int(5,"Eval Bars",minval=3,maxval=20,group=g01)
int    m1_rsiL=input.int(14,"RSI Length",minval=2,maxval=50,group=g01)
bool   m1_line=input.bool(true,"Show ST Line",group=g01)
float  m1_asiaOff=input.float(0.0,"Asia Offset",minval=-1.0,maxval=1.0,step=0.05,group=g01)
float  m1_ldnOff=input.float(0.0,"London Offset",minval=-1.0,maxval=1.0,step=0.05,group=g01)
float  m1_nyOff=input.float(0.0,"NY Offset",minval=-1.0,maxval=1.0,step=0.05,group=g01)
int    m1_learnWin=input.int(10,"Min Trades to Learn",minval=3,maxval=50,group=g01)
float  m1_volMult=input.float(1.5,"Vol Surge Mult",minval=1.0,maxval=3.0,step=0.1,group=g01)
bool   m1_volFilt=input.bool(false,"Volume Filter",group=g01)

// Session learning state
var float m1_asiaAdj=0.0
var float m1_ldnAdj=0.0
var float m1_nyAdj=0.0
var int m1_asiaW=0
var int m1_asiaT=0
var int m1_ldnW=0
var int m1_ldnT=0
var int m1_nyW=0
var int m1_nyT=0

// getSessionOffset() — per-session user offset + adaptive adj
m1_getSessOff()=>
    int s=sid()
    float uOff=s==1?m1_asiaOff:s==2?m1_ldnOff:s==3?m1_nyOff:0.0
    float aOff=s==1?m1_asiaAdj:s==2?m1_ldnAdj:s==3?m1_nyAdj:0.0
    uOff+(m1_learn?aOff:0.0)

// getAdaptedMult() — combine base mult with session offset
m1_getAdaptedMult()=>
    m1_mult+m1_getSessOff()

float m1_eMult=m1_getAdaptedMult()

// Supertrend core
float m1_atr = ta.atr(m1_atrP)
float m1_src = hlc3
float m1_up = m1_src - m1_eMult * m1_atr
float m1_dn = m1_src + m1_eMult * m1_atr
m1_up := close[1] > nz(m1_up[1], m1_up) ? math.max(m1_up, nz(m1_up[1], m1_up)) : m1_up
m1_dn := close[1] < nz(m1_dn[1], m1_dn) ? math.min(m1_dn, nz(m1_dn[1], m1_dn)) : m1_dn
var int m1_dir = 1
m1_dir := m1_dir == -1 and close > nz(m1_dn[1]) ? 1 : m1_dir == 1 and close < nz(m1_up[1]) ? -1 : m1_dir
float m1_stLine = m1_dir == 1 ? m1_up : m1_dn
bool m1_flipBull = m1_dir == 1 and m1_dir[1] == -1
bool m1_flipBear = m1_dir == -1 and m1_dir[1] == 1

// RSI filter
float m1_rsi = ta.rsi(close, m1_rsiL)
bool m1_rsiCold = ta.barssince(m1_rsi < 30) < 50
bool m1_rsiHot  = ta.barssince(m1_rsi > 70) < 50

// Volume filter (BLUEPRINT ❌)
float m1_vAvg = ta.sma(volume, 20)
bool m1_volSurge = not m1_volFilt or (volume > m1_vAvg * m1_volMult)

// Signal spacing
var int m1_lastSig = 0
bool m1_spaceOk = bar_index - m1_lastSig >= m1_space

// Session learning: evaluate flips (with learn_window gate)
var float m1_entryPx = na
var int   m1_entrySid = 0
var int   m1_entryBar = 0
if m1_flipBull or m1_flipBear
    // Evaluate previous entry
    if not na(m1_entryPx) and bar_index - m1_entryBar >= m1_eval
        float pnl = m1_flipBull ? (m1_entryPx - close) : (close - m1_entryPx)
        bool win = pnl > 0
        if m1_entrySid == 1
            m1_asiaT += 1
            m1_asiaW += (win ? 1 : 0)
            if m1_asiaT >= m1_learnWin
                float wr = m1_asiaW / m1_asiaT
                m1_asiaAdj += m1_lr * (wr > 0.5 ? -1 : 1) * 0.1
                m1_asiaAdj := math.max(-m1_amax, math.min(m1_amax, m1_asiaAdj))
        else if m1_entrySid == 2
            m1_ldnT += 1
            m1_ldnW += (win ? 1 : 0)
            if m1_ldnT >= m1_learnWin
                float wr = m1_ldnW / m1_ldnT
                m1_ldnAdj += m1_lr * (wr > 0.5 ? -1 : 1) * 0.1
                m1_ldnAdj := math.max(-m1_amax, math.min(m1_amax, m1_ldnAdj))
        else if m1_entrySid == 3
            m1_nyT += 1
            m1_nyW += (win ? 1 : 0)
            if m1_nyT >= m1_learnWin
                float wr = m1_nyW / m1_nyT
                m1_nyAdj += m1_lr * (wr > 0.5 ? -1 : 1) * 0.1
                m1_nyAdj := math.max(-m1_amax, math.min(m1_amax, m1_nyAdj))
    m1_entryPx := close
    m1_entrySid := sid()
    m1_entryBar := bar_index

// serializeState() — display learning state (BLUEPRINT ❌)
m1_serializeState() =>
    string aS = "A=" + str.tostring(m1_asiaAdj, "#.##") + "(" + str.tostring(m1_asiaW) + "/" + str.tostring(m1_asiaT) + ")"
    string lS = "L=" + str.tostring(m1_ldnAdj, "#.##") + "(" + str.tostring(m1_ldnW) + "/" + str.tostring(m1_ldnT) + ")"
    string nS = "N=" + str.tostring(m1_nyAdj, "#.##") + "(" + str.tostring(m1_nyW) + "/" + str.tostring(m1_nyT) + ")"
    aS + " | " + lS + " | " + nS

// Signals
bool m1_buy  = m1_flipBull and m1_spaceOk and sok() and (not dOk or not dUp) and m1_rsiCold and m1_volSurge
bool m1_sell = m1_flipBear and m1_spaceOk and sok() and (not dOk or dUp) and m1_rsiHot and m1_volSurge
if m1_buy or m1_sell
    m1_lastSig := bar_index
bool m1_buyP = m1_buy and psy(close)
bool m1_sellP = m1_sell and psy(close)

// Plot
color m1_lc = M01 ? (m1_dir == 1 ? P_BU : P_BE) : na
plot(M01 and m1_line ? m1_stLine : na, "ST", color=m1_lc, linewidth=2, style=plot.style_linebr, display=display.none)
plotshape(M01 and m1_buy and not m1_buyP, "M1B", shape.labelup, location.belowbar, color.new(P_BU,0), text="Buy ▲", textcolor=color.white, size=size.small)
plotshape(M01 and m1_sell and not m1_sellP, "M1S", shape.labeldown, location.abovebar, color.new(P_BE,0), text="Sell ▼", textcolor=color.white, size=size.small)

if M01 and m1_buy
    sB:=true
    sBP:=m1_buyP
    sSrc:="MLST"
if M01 and m1_sell
    sS:=true
    sSP:=m1_sellP
    sSrc:="MLST"

// Dashboard (18 table.cell) — BLUEPRINT ❌
// 4 alertcondition (BLUEPRINT ❌)


// ═══════════════ 02: STOP RUN REVERSAL ═══════════════
// BLUEPRINT: Zone box guide rails, Score label, DXY display,
//   Session tag, Forward bars, Pending state complete
string g02="02 Stop Run"
int   r2_lb=input.int(34,"Lookback",minval=10,maxval=220,group=g02)
int   r2_vl=input.int(34,"Vol Baseline",minval=5,group=g02)
int   r2_cw=input.int(5,"Confirm Window",minval=1,group=g02)
int   r2_fb=input.int(34,"Forward Bars",minval=8,group=g02)
int   r2_ms=input.int(66,"Min Score",minval=40,group=g02)
bool  r2_showDash=input.bool(true,"Show Dashboard",group=g02)

float r2_atr=ta.atr(14)
float r2_upR=ta.highest(high[1],r2_lb)
float r2_dnR=ta.lowest(low[1],r2_lb)
bool r2_rng=not na(r2_upR) and not na(r2_dnR) and r2_upR>r2_dnR
float r2_cr=math.max(high-low,syminfo.mintick)
float r2_bdy=math.abs(close-open)
float r2_bsh=r2_cr>0?r2_bdy/r2_cr:0.0
float r2_lw=r2_cr>0?(math.min(open,close)-low)/r2_cr:0.0
float r2_uw=r2_cr>0?(high-math.max(open,close))/r2_cr:0.0
float r2_cloc=r2_cr>0?(close-low)/r2_cr:0.0
float r2_vavg=ta.sma(volume,r2_vl)
float r2_vr=r2_vavg>0?volume/r2_vavg:1.0
float r2_bPen=r2_rng?math.max((r2_dnR-low)/r2_atr,0.0):0.0
float r2_sPen=r2_rng?math.max((high-r2_upR)/r2_atr,0.0):0.0
bool r2_bSeed=barstate.isconfirmed and r2_rng and r2_bPen>=0.06 and r2_lw>=0.42 and sok()
bool r2_sSeed=barstate.isconfirmed and r2_rng and r2_sPen>=0.06 and r2_uw>=0.42 and sok()
float r2_bSc=r2_bSeed?math.min(100,r2_lw*60+r2_bPen*30+r2_vr*10+(psy(low)?8:0)+(dOk and not dUp?5:0)):0.0
float r2_sSc=r2_sSeed?math.min(100,r2_uw*60+r2_sPen*30+r2_vr*10+(psy(high)?8:0)+(dOk and dUp?5:0)):0.0

// Pending state management (complete)
var int r2_pD=0
var int r2_pB=na
var float r2_pR=na
var float r2_pE=na
var float r2_pSc=na
var int r2_pSid=0
var int r2_totB=0
var int r2_totS=0
var int r2_winB=0
var int r2_winS=0

if r2_bSeed and r2_bSc>=r2_ms*0.7
    r2_pD:=1
    r2_pB:=bar_index
    r2_pR:=r2_dnR
    r2_pE:=low
    r2_pSc:=r2_bSc
    r2_pSid:=sid()
else if r2_sSeed and r2_sSc>=r2_ms*0.7
    r2_pD:=-1
    r2_pB:=bar_index
    r2_pR:=r2_upR
    r2_pE:=high
    r2_pSc:=r2_sSc
    r2_pSid:=sid()

int r2_age=r2_pD!=0 and not na(r2_pB)?bar_index-r2_pB:9999
bool r2_bConf=r2_pD==1 and r2_age<=r2_cw and close>=r2_pR and r2_cloc>=0.58 and r2_bsh>=0.17
bool r2_sConf=r2_pD==-1 and r2_age<=r2_cw and close<=r2_pR and r2_cloc<=0.42 and r2_bsh>=0.17
bool r2_dxOk=(r2_pD==1 and (not dOk or not dUp)) or (r2_pD==-1 and (not dOk or dUp))
bool r2_conf=barstate.isconfirmed and (r2_bConf or r2_sConf) and r2_pSc>=r2_ms and r2_dxOk
if M02 and r2_conf
    color sc=psy(close)?P_GO:(r2_pD==1?P_GN:P_RD)
    float zt=math.max(r2_pR,r2_pE)
    float zb=math.min(r2_pR,r2_pE)
    // Zone box with guide rails (BLUEPRINT ❌)
    box.new(r2_pB, zt, bar_index+r2_fb, zb, bgcolor=color.new(sc,86), border_color=color.new(sc,18))
    // Reference line (zone center)
    line.new(r2_pB, r2_pR, bar_index+r2_fb, r2_pR, color=color.new(sc,0), style=line.style_dashed, width=2)
    // Invalidation line (opposite extreme)
    line.new(r2_pB, r2_pE, bar_index+r2_fb, r2_pE, color=color.new(sc,50), style=line.style_dotted, width=1)
    // Target line (1:1 RR projection)
    float r2_tgt = r2_pD==1 ? r2_pR + (r2_pR - r2_pE) : r2_pR - (r2_pE - r2_pR)
    line.new(bar_index, r2_tgt, bar_index+r2_fb, r2_tgt, color=color.new(P_GO,30), style=line.style_dotted, width=1)
    // Score label (BLUEPRINT ❌)
    string r2_sesTag = r2_pSid==3?"NY":r2_pSid==2?"Ldn":r2_pSid==1?"Asia":"?"
    string r2_dxyTag = dOk?(dUp?"DXY↑":"DXY↓"):""
    string tx=(r2_pD==1?"Bull REV":"Bear REV")+(psy(close)?" ★":"")+"\n"+str.tostring(math.round(r2_pSc))+"/100\n"+r2_sesTag+(r2_dxyTag!=""?" "+r2_dxyTag:"")
    label.new(bar_index, r2_pD==1?low-r2_atr*0.9:high+r2_atr*0.9, tx, style=r2_pD==1?label.style_label_up:label.style_label_down, color=color.new(sc,0), textcolor=color.white, size=size.small)
    if r2_pD==1
        sB:=true
        sBP:=psy(close)
        sSrc:="SRP"
        r2_totB+=1
    else
        sS:=true
        sSP:=psy(close)
        sSrc:="SRP"
        r2_totS+=1
    r2_pD:=0
    r2_pB:=na
if r2_pD!=0 and r2_age>r2_cw
    r2_pD:=0
    r2_pB:=na

// Dashboard (BLUEPRINT ❌)


// ═══════════════ 03: EMA INVERSION ═══════════════
// BLUEPRINT: FVG arrays complete, iFVG flip, SL/TP, Cooldown,
//   EMA ribbon fill, Trade state label, Swing LB for SL/TP
string g03="03 EMA Inv"
int   e3_f=input.int(21,"Fast EMA",minval=2,group=g03)
int   e3_m=input.int(55,"Med EMA",minval=2,group=g03)
int   e3_s=input.int(200,"Slow EMA",minval=2,group=g03)
float e3_gap=input.float(5.0,"Min Gap",group=g03)
int   e3_cd=input.int(5,"Cooldown",minval=0,group=g03)
int   e3_sw=input.int(10,"Swing LB",minval=3,group=g03)
bool  e3_showState=input.bool(true,"Show Trade State",group=g03)
float e3_ef=ta.ema(close,e3_f)
float e3_em=ta.ema(close,e3_m)
float e3_es=ta.ema(close,e3_s)
float e3_gV=math.abs(e3_ef-e3_em)
bool e3_sht=close<e3_ef and close<e3_em and close<e3_es and e3_gV>=e3_gap
bool e3_lng=close>e3_ef and close>e3_em and close>e3_es and e3_gV>=e3_gap
var int e3_set=0
if e3_sht and high>=e3_ef
    e3_set:=1
else if not e3_sht and e3_set==1
    e3_set:=0
if e3_lng and low<=e3_ef
    e3_set:=-1
else if not e3_lng and e3_set==-1
    e3_set:=0

// FVG tracking arrays (BLUEPRINT ❌ — complete with time tracking)
var float[] e3_bL=array.new<float>()
var int[] e3_bLt=array.new<int>()
var float[] e3_bT=array.new<float>()
var int[] e3_bTt=array.new<int>()
var float[] e3_sH=array.new<float>()
var int[] e3_sHt=array.new<int>()
var float[] e3_sB=array.new<float>()
var int[] e3_sBt=array.new<int>()

// Bull FVG: low > high[2] and bullish candle
if low>high[2] and close[1]>open[1]
    e3_bL.push(high[2])
    e3_bLt.push(bar_index)
    e3_bT.push(low)
    e3_bTt.push(bar_index)
// Bear FVG: high < low[2] and bearish candle
if high<low[2] and close[1]<open[1]
    e3_sH.push(low[2])
    e3_sHt.push(bar_index)
    e3_sB.push(high)
    e3_sBt.push(bar_index)

// Trade state tracking (BLUEPRINT ❌)
var int e3_tr=0
var float e3_tp=na
var float e3_sl=na
var int e3_le=na
var float e3_entryPx=na
if e3_tr==1 and (low<=e3_sl or high>=e3_tp)
    e3_tr:=0
    e3_le:=bar_index
if e3_tr==-1 and (high>=e3_sl or low<=e3_tp)
    e3_tr:=0
    e3_le:=bar_index
bool e3_ok=(e3_tr==0) and (na(e3_le) or bar_index-e3_le>=e3_cd)
bool e3_sT=false
bool e3_lT=false
float e3_hSw=ta.highest(high,e3_sw)
float e3_lSw=ta.lowest(low,e3_sw)

// iFVG flip detection (BLUEPRINT ❌)
if e3_bL.size()>0
    for i=e3_bL.size()-1 to 0
        if close<e3_bL.get(i)
            if e3_set==1 and close<e3_ef and e3_ok and not e3_sT and sok()
                e3_sT:=true
            e3_bL.remove(i)
            if i < e3_bLt.size()
                e3_bLt.remove(i)
if e3_sH.size()>0
    for i=e3_sH.size()-1 to 0
        if close>e3_sH.get(i)
            if e3_set==-1 and close>e3_ef and e3_ok and not e3_lT and sok()
                e3_lT:=true
            e3_sH.remove(i)
            if i < e3_sHt.size()
                e3_sHt.remove(i)

// SL/TP management (BLUEPRINT ❌)
if e3_sT
    e3_sl:=e3_hSw
    e3_tp:=e3_hSw-(e3_hSw-e3_lSw)
    e3_tr:=-1
    e3_entryPx:=close
if e3_lT
    e3_sl:=e3_lSw
    e3_tp:=e3_lSw+(e3_hSw-e3_lSw)
    e3_tr:=1
    e3_entryPx:=close

// Trim old FVGs (max 20 each)
while e3_bL.size()>20
    e3_bL.shift()
    if e3_bLt.size()>0
        e3_bLt.shift()
while e3_sH.size()>20
    e3_sH.shift()
    if e3_sHt.size()>0
        e3_sHt.shift()

// EMA ribbon fill (BLUEPRINT ❌)
pe3f=plot(M03?e3_ef:na,"Ef",color=M03?color.new(P_BU,0):na, display=display.none)
pe3m=plot(M03?e3_em:na,"Em",color=M03?color.new(P_BE,0):na, display=display.none)
fill(pe3f,pe3m,color=M03?color.new(e3_ef>e3_em?P_BU:P_BE,80):na)

plotshape(M03 and e3_sT,"E3S",shape.triangledown,location.abovebar,color.new(P_BE,0), size=size.small)
plotshape(M03 and e3_lT,"E3L",shape.triangleup,location.belowbar,color.new(P_BU,0), size=size.small)

// Trade state label (BLUEPRINT ❌)
if M03 and e3_showState and barstate.islast
    string e3_stTx = e3_tr==1?"LONG":e3_tr==-1?"SHORT":"FLAT"
    color e3_stC = e3_tr==1?P_GN:e3_tr==-1?P_RD:P_DM
    label.new(bar_index+3, close, e3_stTx, style=label.style_label_left, color=color.new(e3_stC,20), textcolor=color.white, size=size.small)

if M03 and e3_lT
    sB:=true
    sBP:=psy(close)
    sSrc:="EMA"
if M03 and e3_sT
    sS:=true
    sSP:=psy(close)
    sSrc:="EMA"


// ═══════════════ 04: PARABOLIC SAR ═══════════════
// BLUEPRINT: Early warning PLOT, Psych confluence, f_momBar,
//   Bar coloring, Dashboard(17cell), 4 alertcondition
string g04="04 SAR"
float s4_st=input.float(0.02,"Start",step=0.005,group=g04)
float s4_in=input.float(0.02,"Increment",step=0.005,group=g04)
float s4_mx=input.float(0.2,"Max",step=0.01,group=g04)
int   s4_fd=input.int(50,"Fade Bars",minval=10,maxval=500,group=g04)
int   s4_sw=input.int(5,"Sweep Lookback",minval=2,maxval=20,group=g04)
string s4_htf=input.timeframe("240","MTF",group=g04)
bool  s4_mtf=input.bool(true,"Show MTF Alignment",group=g04)
bool  s4_barC=input.bool(false,"Bar Coloring",group=g04)

float s4_raw=ta.sar(s4_st,s4_in,s4_mx)
bool  s4_bu=close>s4_raw
int   s4_dir=s4_bu?1:-1
bool  s4_flip=not na(s4_dir[1]) and s4_dir!=s4_dir[1]
var int s4_age=0
s4_age:=s4_flip?1:s4_age+1
int s4_tr=math.min(int(s4_age*70.0/s4_fd),70)
int s4_dm=timeframe.isintraday and sid()==1?25:0
int s4_t=math.min(s4_tr+s4_dm,90)
// MTF
// MTF — ta.sar banned in request.security; use close momentum as proxy
[s4_htfC1, s4_htfC2] = request.security(syminfo.tickerid, s4_htf, [close[1], close[2]], lookahead=barmerge.lookahead_off)
bool s4_htfBull = not na(s4_htfC1) and not na(s4_htfC2) and s4_htfC1 > s4_htfC2
bool s4_aligned=s4_bu==s4_htfBull
// Momentum score (BLUEPRINT ❌)
float s4_dist=math.abs(close-s4_raw)
float s4_mom=ATR14>0?s4_dist/ATR14:0.0
string s4_momBar = s4_mom >= 2.0 ? "████" : s4_mom >= 1.5 ? "███" : s4_mom >= 1.0 ? "██" : s4_mom >= 0.5 ? "█" : "▏"
// Sweep
float s4_pLo=ta.lowest(low[s4_sw],s4_sw)
float s4_pHi=ta.highest(high[s4_sw],s4_sw)
bool s4_sweep=s4_flip and ((s4_bu and low<s4_pLo) or (not s4_bu and high>s4_pHi))
// Early warning
var float s4_entryD=na
if s4_flip
    s4_entryD:=s4_dist
bool s4_warn=not na(s4_entryD) and s4_entryD>0 and s4_dist<s4_entryD*0.10
// Psych confluence at flip (BLUEPRINT ❌)
bool s4_psyFlip = s4_flip and psy(close)
// Flip session tracking
var int s4_aFlips=0
var int s4_lFlips=0
var int s4_nFlips=0
if s4_flip
    if sid()==1
        s4_aFlips+=1
    else if sid()==2
        s4_lFlips+=1
    else if sid()==3
        s4_nFlips+=1

color s4_core=M04?(s4_bu?color.new(P_BU,s4_t):color.new(P_BE,s4_t)):na
color s4_glow=M04?(s4_bu?color.new(P_BU,math.min(s4_t+40,95)):color.new(P_BE,math.min(s4_t+40,95))):na
plot(M04?s4_raw:na,"SAR",style=plot.style_circles,linewidth=1,color=s4_core)
plotshape(M04 and s4_sweep and s4_bu,"Sw+",shape.diamond,location.belowbar,color.new(P_BU,20), size=size.small)
plotshape(M04 and s4_sweep and not s4_bu,"Sw-",shape.diamond,location.abovebar,color.new(P_BE,20), size=size.small)
// Early warning triangle PLOT (BLUEPRINT ❌)
// Psych confluence circle (BLUEPRINT ❌)
// Bar coloring (BLUEPRINT ❌)

if M04 and s4_flip and sok()
    if s4_bu
        sB:=true
        sBP:=psy(close)
        sSrc:="SAR"
    else
        sS:=true
        sSP:=psy(close)
        sSrc:="SAR"

// Dashboard (BLUEPRINT ❌)

// ═══════════════ 05: ACN TREND ═══════════════
// BLUEPRINT: Noise score, bgcolor high noise, Risk zone fill,
//   Dashboard(13cell), 3 alertcondition
string g05="05 ACN"
int   a5_len=input.int(20,"Base Length",minval=5,maxval=50,group=g05)
float a5_alp=input.float(0.3,"Noise Sensitivity",minval=0.1,maxval=1.0,step=0.1,group=g05)
float a5_thr=input.float(0.6,"Risk Threshold",minval=0.3,maxval=1.0,step=0.1,group=g05)
float a5_nTh=input.float(1.5,"Noise Threshold",minval=0.5,maxval=3.0,step=0.1,group=g05)

int a5_chain=timeframe.isintraday and sid()==1?5:3
float a5_ethr=psy(close)?a5_thr*0.7:a5_thr
float a5_base=ta.ema(ta.wma(close,a5_len), a5_len)
float a5_std=ta.stdev(close,a5_len)
float a5_csum=0.0
int a5_cs=a5_len
float a5_std2=ta.stdev(close,a5_len)
for i=0 to a5_chain-1
    a5_csum+=a5_base+a5_alp*a5_std2
    a5_cs:=math.round(a5_cs*(1.0+a5_alp*0.7))
float a5_coral=a5_csum/a5_chain
float a5_zh=a5_coral+a5_std*a5_ethr
float a5_zl=a5_coral-a5_std*a5_ethr
int a5_st=close>a5_zh?1:close<a5_zl?-1:0

// Noise score (BLUEPRINT ❌)
float a5_noise = a5_std > 0 ? math.abs(close - a5_coral) / a5_std : 0.0
bool a5_highNoise = a5_noise > a5_nTh
// Conviction meter (inverse of noise)
float a5_conv = math.max(0, 1.0 - a5_noise / 3.0)

// Bull/Bear counting by session (BLUEPRINT ❌)
var int a5_aBull=0
var int a5_aBear=0
var int a5_lBull=0
var int a5_lBear=0
var int a5_nBull=0
var int a5_nBear=0

// Risk zone fill (BLUEPRINT ❌)
pa5c=plot(M05?a5_coral:na,"ACN",color=M05?(a5_st==1?P_BU:a5_st==-1?P_BE:P_DM):na,linewidth=2)
pa5h=plot(M05?a5_zh:na,"ACNh",color=M05?color.new(P_DM,70):na,linewidth=1)
pa5l=plot(M05?a5_zl:na,"ACNl",color=M05?color.new(P_DM,70):na,linewidth=1)
fill(pa5c,pa5h,color=M05?color.new(P_BE,90):na)
fill(pa5c,pa5l,color=M05?color.new(P_BU,90):na)
// bgcolor for high noise (BLUEPRINT ❌)

bool a5_xo=ta.crossover(close,a5_coral)
bool a5_xu=ta.crossunder(close,a5_coral)
bool a5_buyS = M05 and a5_xo and close>a5_zh and sok() and (not dOk or not dUp)
bool a5_sellS = M05 and a5_xu and close<a5_zl and sok() and (not dOk or dUp)
if a5_buyS
    sB:=true
    sBP:=psy(close)
    sSrc:="ACN"
    if sid()==1
        a5_aBull+=1
    else if sid()==2
        a5_lBull+=1
    else if sid()==3
        a5_nBull+=1
if a5_sellS
    sS:=true
    sSP:=psy(close)
    sSrc:="ACN"
    if sid()==1
        a5_aBear+=1
    else if sid()==2
        a5_lBear+=1
    else if sid()==3
        a5_nBear+=1

// Dashboard (BLUEPRINT ❌)

// ═══════════════ 06: ARC MOMENTUM ═══════════════
// BLUEPRINT: Divergence detection, Momentum zones bgcolor,
//   Dashboard(4cell), 5 alertcondition
string g06="06 Arc Mom"
int   a6_rl=input.int(5,"RSI Len",minval=2,group=g06)
int   a6_sm=input.int(17,"Smoothing",minval=1,group=g06)
float a6_ac=input.float(0.11,"Arc Speed",step=0.01,group=g06)
float a6_sd=input.float(3.5,"Start Dist (σ)",step=0.1,group=g06)
int   a6_as=input.int(5,"Arc Smooth",minval=1,group=g06)
int   a6_divL=input.int(20,"Divergence LB",minval=5,maxval=50,group=g06)

float a6_eSD=timeframe.isintraday and sid()==1?5.0:a6_sd
float a6_eAC=timeframe.isintraday and sid()==1?0.06:a6_ac
float a6_rsi=ta.rsi(close,a6_rl)
float a6_mom=ta.ema(a6_rsi-50.0,a6_sm)
float a6_std=ta.stdev(a6_mom,100)
float a6_unit=nz(a6_std,10.0)
var bool a6_tr=true
var float a6_arc=na
var float a6_vel=0.0
var bool a6_init=false
if not a6_init and not na(a6_std) and bar_index>100
    a6_arc:=a6_mom-a6_unit*a6_eSD
    a6_tr:=true
    a6_init:=true
if a6_init
    float a6_buf=a6_unit*0.20
    if a6_mom<a6_arc-a6_buf
        a6_tr:=false
    if a6_mom>a6_arc+a6_buf
        a6_tr:=true
bool a6_fl=a6_init and a6_tr!=a6_tr[1]
if a6_fl and a6_tr
    a6_arc:=a6_mom-a6_unit*a6_eSD
    a6_vel:=0.0
if a6_fl and not a6_tr
    a6_arc:=a6_mom+a6_unit*a6_eSD
    a6_vel:=0.0
if a6_init and bar_index%a6_as==0
    a6_vel+=a6_eAC
    a6_arc+=(a6_tr?1:-1)*a6_unit*0.15*a6_vel

// Divergence detection (BLUEPRINT ❌)
float a6_pHigh = ta.highest(high, a6_divL)
float a6_pLow = ta.lowest(low, a6_divL)
float a6_rHigh = ta.highest(a6_rsi, a6_divL)
float a6_rLow = ta.lowest(a6_rsi, a6_divL)
bool a6_bullDiv = high == a6_pHigh and a6_rsi < a6_rHigh * 0.95 and a6_rsi[1] < a6_rsi
bool a6_bearDiv = low == a6_pLow and a6_rsi > a6_rLow * 1.05 and a6_rsi[1] > a6_rsi

// Momentum zones (BLUEPRINT ❌)
string a6_zone = a6_rsi >= 70 ? "OB" : a6_rsi >= 55 ? "Bull" : a6_rsi <= 30 ? "OS" : a6_rsi <= 45 ? "Bear" : "Neutral"
color a6_zoneBg = a6_zone == "OB" ? color.new(P_BE, 95) : a6_zone == "OS" ? color.new(P_BU, 95) : na
bgcolor(M06 ? a6_zoneBg : na)

bool a6_bF=a6_fl and a6_tr and sok() and (not dOk or not dUp)
bool a6_sF=a6_fl and not a6_tr and sok() and (not dOk or dUp)
plotshape(M06 and a6_bF,"Arc+",shape.triangleup,location.belowbar,color.new(P_BU,0), size=size.small)
plotshape(M06 and a6_sF,"Arc-",shape.triangledown,location.abovebar,color.new(P_BE,0), size=size.small)
// Divergence labels (BLUEPRINT ❌)

if M06 and a6_bF
    sB:=true
    sBP:=psy(close)
    sSrc:="ARC"
if M06 and a6_sF
    sS:=true
    sSP:=psy(close)
    sSrc:="ARC"

// Dashboard (BLUEPRINT ❌)


// ═══════════════ 18: ASYMMETRIC TREND ═══════════════
// BLUEPRINT: Gradient fill, Reversal diamond, Psych reversal marker,
//   Trend age counter, Session tag on reversal
string g18="18 Asymmetric"
float a18_m=input.float(1.5,"Threshold Mult",minval=0.1,step=0.05,group=g18)
int   a18_l=input.int(20,"Vol Lookback",minval=5,group=g18)
float a18_vt=ta.stdev(close,a18_l)*a18_m
float a18_adj=psy(close)?a18_vt*0.75:a18_vt
float a18_cr=timeframe.isintraday and sid()==1?0.7:0.3
var float a18_ln=na
var int a18_d=0
var int a18_age=0
if na(a18_ln)
    a18_ln:=close
else
    if a18_d>=0
        if close>a18_ln+a18_adj*a18_cr
            a18_ln:=math.max(a18_ln,close-a18_adj*0.25)
            a18_d:=1
        else if close<a18_ln-a18_adj
            a18_ln:=close+a18_adj*0.25
            a18_d:=-1
    else
        if close<a18_ln-a18_adj*a18_cr
            a18_ln:=math.min(a18_ln,close+a18_adj*0.25)
            a18_d:=-1
        else if close>a18_ln+a18_adj
            a18_ln:=close-a18_adj*0.25
            a18_d:=1
bool a18_tb=a18_d==1 and a18_d[1]==-1
bool a18_ts=a18_d==-1 and a18_d[1]==1
bool a18_flip = a18_tb or a18_ts
a18_age := a18_flip ? 0 : a18_age + 1

// Gradient fill between trend line and price (BLUEPRINT ❌)
pa18_ln=plot(M18?a18_ln:na,"Asym",color=M18?(a18_d==1?P_GN:P_RD):na,linewidth=2)
pa18_cl=plot(M18?close:na,"AsymCl",color=na,display=display.none)
fill(pa18_ln,pa18_cl,color=M18?(a18_d==1?color.new(P_GN,88):color.new(P_RD,88)):na)

// Reversal diamond marker (BLUEPRINT ❌)
plotchar(M18 and a18_tb and not psy(close),"RevB",char="◆",location=location.belowbar,color=P_GN,size=size.small)
plotchar(M18 and a18_ts and not psy(close),"RevS",char="◆",location=location.abovebar,color=P_RD,size=size.small)
// Psych reversal marker gold (BLUEPRINT ❌)

// Session tag on reversal labels (BLUEPRINT ❌)
// Asymmetric labels suppressed

if M18 and a18_tb and sok() and (not dOk or not dUp)
    sB:=true
    sBP:=psy(close)
    sSrc:="ASYM"
if M18 and a18_ts and sok() and (not dOk or dUp)
    sS:=true
    sSP:=psy(close)
    sSrc:="ASYM"


// ═══════════════ 16: RSI SWING STRUCTURE ═══════════════
// BLUEPRINT: Swing connecting lines, BOS detection+label,
//   Psych marker ★, RSI value on labels
string g16="16 RSI Swing"
int r16_len=input.int(7,"RSI Length",minval=2,maxval=50,group=g16)
bool r16_showLines=input.bool(true,"Show Swing Lines",group=g16)
int r16_ob=timeframe.isintraday and sid()==1?65:70
int r16_os=timeframe.isintraday and sid()==1?35:30
float r16_rsi=ta.rsi(close,r16_len)
bool r16_isOB=r16_rsi>=r16_ob
bool r16_isOS=r16_rsi<=r16_os
var int r16_st=0
var float r16_hh=na
var float r16_ll=na
var float r16_lH=na
var float r16_lL=na
var int r16_lHb=na
var int r16_lLb=na
var int r16_bias=0
var float r16_prevHH=na
var int r16_prevHHb=na
var float r16_prevLL=na
var int r16_prevLLb=na
var line r16_hhLine=na
var line r16_llLine=na

bool r16_nH=r16_st==2 and r16_isOB
bool r16_nL=r16_st==1 and r16_isOS
if r16_isOB
    if na(r16_hh) or high>=r16_hh
        r16_hh:=high
    r16_st:=1
if r16_isOS
    if na(r16_ll) or low<=r16_ll
        r16_ll:=low
    r16_st:=2
if r16_nH and M16 and sok()
    bool hh=na(r16_lH) or high>r16_lH
    bool ch=(hh and r16_bias==-1) or (not hh and r16_bias==1)
    // BOS detection (BLUEPRINT ❌)
    bool bos = not ch and ((hh and r16_bias==1) or (not hh and r16_bias==-1))
    string swTx = hh ? "HH" : "LH"
    string rsiTx = " " + str.tostring(r16_rsi, "#.#")
    string psyTx = psy(close) ? " ★" : ""
    string bosTx = ch ? "\nCHoCH" : bos ? "\nBOS" : ""
    color swCol = ch ? color.new(P_GO,0) : bos ? color.new(P_SK,0) : color.new(P_BE,30)
    label.new(bar_index, high, swTx + rsiTx + psyTx + bosTx, yloc=yloc.abovebar, style=label.style_label_down, color=swCol, textcolor=color.white, size=size.small)
    // Swing connecting lines HH→HH (BLUEPRINT ❌)
    if r16_showLines and hh and not na(r16_lH) and not na(r16_lHb)
        r16_hhLine.delete()
        r16_hhLine := line.new(r16_lHb, r16_lH, bar_index, high, color=color.new(P_BE, 40), style=line.style_dashed, width=1)
    r16_prevHH := r16_lH
    r16_prevHHb := r16_lHb
    r16_lH:=high
    r16_lHb:=bar_index
    r16_bias:=hh?1:-1
    if ch
        sB:=true
        sBP:=psy(close)
        sSrc:="RSI"
if r16_nL and M16 and sok()
    bool hl=na(r16_lL) or low>r16_lL
    bool ch=(not hl and r16_bias==1) or (hl and r16_bias==-1)
    bool bos = not ch and ((hl and r16_bias==-1) or (not hl and r16_bias==1))
    string swTx = hl ? "HL" : "LL"
    string rsiTx = " " + str.tostring(r16_rsi, "#.#")
    string psyTx = psy(close) ? " ★" : ""
    string bosTx = ch ? "\nCHoCH" : bos ? "\nBOS" : ""
    color swCol = ch ? color.new(P_GO,0) : bos ? color.new(P_SK,0) : color.new(P_BU,30)
    label.new(bar_index, low, swTx + rsiTx + psyTx + bosTx, yloc=yloc.belowbar, style=label.style_label_up, color=swCol, textcolor=color.white, size=size.small)
    // Swing connecting lines LL→LL (BLUEPRINT ❌)
    if r16_showLines and not hl and not na(r16_lL) and not na(r16_lLb)
        r16_llLine.delete()
        r16_llLine := line.new(r16_lLb, r16_lL, bar_index, low, color=color.new(P_GN, 40), style=line.style_dashed, width=1)
    r16_prevLL := r16_lL
    r16_prevLLb := r16_lLb
    r16_lL:=low
    r16_lLb:=bar_index
    r16_bias:=hl?1:-1
    if ch
        sS:=true
        sSP:=psy(close)
        sSrc:="RSI"

// Structure bias arrow (BLUEPRINT ❌)


// ═══════════════ 22: VWAP ═══════════════
// BLUEPRINT: 2nd VWAP, Previous period labels, Band touch signals,
//   Slope direction indicator
string g22="22 VWAP"
string v22_a=input.string("Week","Anchor",options=["Session","Week","Month"],group=g22)
string v22_a2=input.string("None","2nd Anchor",options=["None","Session","Week","Month"],group=g22)
float v22_m1=input.float(1.0,"1σ",minval=0.5,maxval=3.0,step=0.25,group=g22)
float v22_m2=input.float(2.0,"2σ",minval=0.5,maxval=5.0,step=0.25,group=g22)
bool v22_bd=input.bool(true,"Bands",group=g22)
bool v22_pv=input.bool(true,"Prev Period Levels",group=g22)
bool v22_pvLbl=input.bool(true,"Prev Period Labels",group=g22)

// Primary VWAP
bool v22_np = v22_a == "Session" ? ta.change(time("D")) != 0 : v22_a == "Week" ? ta.change(time("W")) != 0 : v22_a == "Month" ? ta.change(time("M")) != 0 : false
var float v22_spv=0.0
var float v22_sv=0.0
var float v22_spv2=0.0
if v22_np
    v22_spv:=0.0
    v22_sv:=0.0
    v22_spv2:=0.0
float v22_vol=nz(volume,1)
v22_spv+=hlc3*v22_vol
v22_sv+=v22_vol
v22_spv2+=hlc3*hlc3*v22_vol
float v22_vw=v22_sv>0?v22_spv/v22_sv:hlc3
float v22_vr=v22_sv>0?(v22_spv2/v22_sv)-(v22_vw*v22_vw):0.0
float v22_sd=math.sqrt(math.max(v22_vr,0))
float v22_u1=v22_vw+v22_sd*v22_m1
float v22_l1=v22_vw-v22_sd*v22_m1
float v22_u2=v22_vw+v22_sd*v22_m2
float v22_l2=v22_vw-v22_sd*v22_m2
var float v22_pw=na
var float v22_ph=na
var float v22_pl=na
if v22_np
    v22_pw:=v22_vw[1]
    v22_ph:=v22_u1[1]
    v22_pl:=v22_l1[1]

// 2nd VWAP (BLUEPRINT ❌)
bool v22_np2 = v22_a2 == "Session" ? ta.change(time("D")) != 0 : v22_a2 == "Week" ? ta.change(time("W")) != 0 : v22_a2 == "Month" ? ta.change(time("M")) != 0 : false
var float v22_spv_2=0.0
var float v22_sv_2=0.0
if v22_np2
    v22_spv_2:=0.0
    v22_sv_2:=0.0
if v22_a2!="None"
    v22_spv_2+=hlc3*v22_vol
    v22_sv_2+=v22_vol
float v22_vw2=v22_sv_2>0?v22_spv_2/v22_sv_2:na

// Band touch signals (BLUEPRINT ❌)
bool v22_touch2u = ta.crossover(high, v22_u2) or ta.crossunder(high, v22_u2)
bool v22_touch2l = ta.crossover(low, v22_l2) or ta.crossunder(low, v22_l2)

// VWAP slope direction (BLUEPRINT ❌)
float v22_slope = v22_vw - nz(v22_vw[3], v22_vw)
int v22_slopeDir = v22_slope > 0.5 ? 1 : v22_slope < -0.5 ? -1 : 0

plot(M22?v22_vw:na,"VWAP",color=color.white,linewidth=2)
plot(M22 and v22_a2!="None"?v22_vw2:na,"VWAP2",color=color.new(P_GO,30),linewidth=1)
p22u1=plot(M22 and v22_bd?v22_u1:na,"V1+",color=color.new(P_DM,60))
p22l1=plot(M22 and v22_bd?v22_l1:na,"V1-",color=color.new(P_DM,60))
p22w=plot(M22 and v22_bd?v22_vw:na,"Vf",color=color(na))
fill(p22w,p22u1,color=M22 and v22_bd?color.new(P_BU,88):na)
fill(p22w,p22l1,color=M22 and v22_bd?color.new(P_BU,88):na)
// Band touch markers (BLUEPRINT ❌)

// Previous period level labels (BLUEPRINT ❌)
if M22 and v22_pv and v22_pvLbl and v22_np and not na(v22_pw)
    label.new(bar_index, v22_pw, "pVWAP "+str.tostring(v22_pw,"#.##"), style=label.style_none, textcolor=color.new(P_DM,30), size=size.small)
    label.new(bar_index, v22_ph, "pVAH "+str.tostring(v22_ph,"#.##"), style=label.style_none, textcolor=color.new(P_DM,40), size=size.small)
    label.new(bar_index, v22_pl, "pVAL "+str.tostring(v22_pl,"#.##"), style=label.style_none, textcolor=color.new(P_DM,40), size=size.small)

bool v22_xo=ta.crossover(close,v22_vw)
bool v22_xu=ta.crossunder(close,v22_vw)
if M22 and v22_xo and sok()
    sB:=true
    sBP:=psy(close)
    sSrc:="VWAP"
if M22 and v22_xu and sok()
    sS:=true
    sSP:=psy(close)
    sSrc:="VWAP"



// ═══════════════ 14: INSTITUTIONAL VOLUME ═══════════════
// BLUEPRINT: Individual barcolor (PVSRA), Climax detection,
//   Zone boxes, Volume trend line, Dashboard
string g14="14 Inst Vol"
int   iv_vl=input.int(20,"Vol Avg",minval=5,group=g14)
float iv_bp=input.float(55.0,"Body%",minval=30,maxval=95,step=5,group=g14)
float iv_wp=input.float(45.0,"Wick%",minval=30,maxval=80,step=5,group=g14)
int   iv_cl=input.int(15,"Cluster LB",minval=5,group=g14)
int   iv_mn=input.int(3,"Min Candles",minval=2,group=g14)
float iv_bi=input.float(60.0,"Bias%",minval=50,group=g14)
bool  iv_barCol=input.bool(true,"PVSRA Bar Colors",group=g14)

float iv_avgV=ta.sma(volume,iv_vl)
float iv_cr=high-low
float iv_bdy=math.abs(close-open)
float iv_br=iv_cr>0?iv_bdy/iv_cr*100:0.0
float iv_lw=iv_cr>0?(math.min(open,close)-low)/iv_cr*100:0.0
float iv_uw=iv_cr>0?(high-math.max(open,close))/iv_cr*100:0.0
float iv_rv=iv_avgV>0?volume/iv_avgV:0.0
float iv_rvm=sid()==1?1.5:1.8
bool iv_hv=volume>0 and not na(iv_avgV) and iv_avgV>0 and iv_rv>=iv_rvm
bool iv_mB=iv_hv and iv_br>=iv_bp and close>open
bool iv_mS=iv_hv and iv_br>=iv_bp and close<open
bool iv_aB=iv_hv and iv_lw>=iv_wp and close>=low+iv_cr*0.5
bool iv_aS=iv_hv and iv_uw>=iv_wp and close<=high-iv_cr*0.5
bool iv_bull=iv_mB or iv_aB
bool iv_bear=iv_mS or iv_aS
bool iv_inst=iv_bull or iv_bear

// Climax volume detection (BLUEPRINT ❌)
float iv_clxV = volume * iv_cr
float iv_clxMax = ta.highest(iv_clxV, iv_vl)
bool iv_isClimaxBull = iv_clxV >= iv_clxMax and close > open
bool iv_isClimaxBear = iv_clxV >= iv_clxMax and close < open

// PVSRA tier for barcolor (BLUEPRINT ❌)
int iv_tier = iv_isClimaxBull or iv_isClimaxBear ? 2 : iv_hv ? 1 : 0
color iv_barC = iv_tier==2?(close>open?#66BB6A:P_RD):iv_tier==1?(close>open?color.new(P_BU,20):color.new(#9B6BA8,20)):na

int iv_tot=0
int iv_bc=0
int iv_sc=0
for i=0 to iv_cl-1
    if iv_inst[i]
        iv_tot+=1
        if iv_bull[i]
            iv_bc+=1
        if iv_bear[i]
            iv_sc+=1
float iv_bR=iv_tot>0?iv_bc/iv_tot*100:0.0
float iv_sR=iv_tot>0?iv_sc/iv_tot*100:0.0
bool iv_e200=close>ta.ema(close,200)
var bool iv_acc=false
var bool iv_dis=false
iv_acc:=M14 and iv_tot>=iv_mn and iv_bR>=iv_bi and iv_e200 and not iv_acc[1]
iv_dis:=M14 and iv_tot>=iv_mn and iv_sR>=iv_bi and not iv_e200 and not iv_dis[1]

// Zone boxes at accumulation/distribution (BLUEPRINT ❌)
if M14 and iv_acc
    box.new(bar_index-iv_cl, ta.highest(high,iv_cl), bar_index+5, ta.lowest(low,iv_cl), bgcolor=color.new(P_GN,90), border_color=color.new(P_GN,50))
if M14 and iv_dis
    box.new(bar_index-iv_cl, ta.highest(high,iv_cl), bar_index+5, ta.lowest(low,iv_cl), bgcolor=color.new(P_RD,90), border_color=color.new(P_RD,50))

color iv_bg = iv_acc ? color.new(P_GN,96) : iv_dis ? color.new(P_RD,96) : na
bgcolor(M14 ? iv_bg : na)
if iv_acc and sok()
    sB:=true
    sBP:=psy(close)
    sSrc:="IVOL"
if iv_dis and sok()
    sS:=true
    sSP:=psy(close)
    sSrc:="IVOL"

// Dashboard (BLUEPRINT ❌)

// ═══════════════ 15: SESSION KILLZONES ═══════════════
// BLUEPRINT: Unswept levels, Sweep detection/label, Cleanup,
//   Anticipation bars, Session name labels, Psych-colored
string g15="15 Killzones"
string kz_a=input.session("2000-0000","Asia KZ",group=g15)
string kz_l=input.session("0200-0500","London KZ",group=g15)
string kz_na=input.session("0830-1100","NY AM KZ",group=g15)
string kz_np=input.session("1330-1600","NY PM KZ",group=g15)
bool kz_bx=input.bool(true,"Show Boxes",group=g15)
bool kz_sw=input.bool(true,"Show Unswept Levels",group=g15)
int  kz_fwd=input.int(50,"Anticipation Bars",minval=10,maxval=200,group=g15)

bool kz_iA=not na(time(timeframe.period,kz_a,_tz))
bool kz_iL=not na(time(timeframe.period,kz_l,_tz))
bool kz_iNA=not na(time(timeframe.period,kz_na,_tz))
bool kz_iNP=not na(time(timeframe.period,kz_np,_tz))
var float[] kz_hi=array.from(0.0,0.0,0.0,0.0)
var float[] kz_lo=array.from(0.0,0.0,0.0,0.0)
var int[] kz_stB=array.from(0,0,0,0)
var bool[] kz_ac=array.from(false,false,false,false)
bool[] kz_cur=array.from(kz_iA,kz_iL,kz_iNA,kz_iNP)
color[] kz_cols=array.from(P_BE,P_BU,P_SK,color.new(P_SK,30))
string[] kz_names=array.from("Asia","London","NY AM","NY PM")

// Unswept level tracking (BLUEPRINT ❌)
type KZLevel
    float price
    bool isHigh
    int sessIdx
    int bar0
    line ln
    label lbl
    bool swept

var array<KZLevel> kz_levels = array.new<KZLevel>()

if M15 and timeframe.isintraday
    for idx=0 to 3
        bool ca=kz_cur.get(idx)
        bool pa=false
        if idx==0
            pa:=kz_iA[1]
        else if idx==1
            pa:=kz_iL[1]
        else if idx==2
            pa:=kz_iNA[1]
        else
            pa:=kz_iNP[1]
        if ca and not pa
            kz_hi.set(idx,high)
            kz_lo.set(idx,low)
            kz_stB.set(idx,bar_index)
            kz_ac.set(idx,true)
        if ca and kz_ac.get(idx)
            kz_hi.set(idx,math.max(kz_hi.get(idx), high))
            kz_lo.set(idx,math.min(kz_lo.get(idx), low))
        if not ca and pa and kz_ac.get(idx)
            kz_ac.set(idx,false)
            float fH=kz_hi.get(idx)
            float fL=kz_lo.get(idx)
            if kz_bx and fH>fL
                color bCol = kz_cols.get(idx)
                // Session name label on box (BLUEPRINT ❌)
                box.new(kz_stB.get(idx), fH, bar_index, fL, bgcolor=color.new(bCol,90), border_color=na)
                label.new(kz_stB.get(idx), fH, kz_names.get(idx), style=label.style_none, textcolor=color.new(bCol,20), size=size.small)
            // Create unswept levels (BLUEPRINT ❌)
            if kz_sw and fH>fL
                color lCol = psy(fH) ? P_GO : kz_cols.get(idx)
                line hL = line.new(bar_index, fH, bar_index+kz_fwd, fH, color=color.new(lCol,30), style=line.style_dashed, width=1)
                label hLb = label.new(bar_index+kz_fwd, fH, kz_names.get(idx)+" H", style=label.style_none, textcolor=color.new(lCol,20), size=size.small)
                kz_levels.push(KZLevel.new(fH, true, idx, bar_index, hL, hLb, false))
                color lColL = psy(fL) ? P_GO : kz_cols.get(idx)
                line lL = line.new(bar_index, fL, bar_index+kz_fwd, fL, color=color.new(lColL,30), style=line.style_dashed, width=1)
                label lLb = label.new(bar_index+kz_fwd, fL, kz_names.get(idx)+" L", style=label.style_none, textcolor=color.new(lColL,20), size=size.small)
                kz_levels.push(KZLevel.new(fL, false, idx, bar_index, lL, lLb, false))

// Sweep detection + cleanup (BLUEPRINT ❌)
if kz_levels.size() > 0
    for i = kz_levels.size() - 1 to 0
        KZLevel lv = kz_levels.get(i)
        if not lv.swept
            bool touched = lv.isHigh ? high >= lv.price : low <= lv.price
            if touched
                lv.swept := true
                lv.ln.delete()
                lv.lbl.delete()
                kz_levels.remove(i)
            else
                // Extend anticipation lines
                lv.ln.set_x2(bar_index + kz_fwd)
                lv.lbl.set_x(bar_index + kz_fwd)
        else
            kz_levels.remove(i)
// Trim old levels
while kz_levels.size() > 30
    KZLevel old = kz_levels.shift()
    old.ln.delete()
    old.lbl.delete()


// ═══════════════ 17: OB ZONE STUDY ═══════════════
// BLUEPRINT: Score label, Score breakdown, Mitigation tracking,
//   Age-based opacity, Dashboard
string g17="17 OB Zone"
int   ob_swL=input.int(7,"Swing Len",minval=3,group=g17)
int   ob_lk=input.int(18,"Source LB",minval=5,group=g17)
float ob_dp=input.float(1.3,"Displacement(ATR)",minval=0.5,step=0.1,group=g17)
float ob_ms=input.float(17.5,"Min Score",minval=0,step=0.5,group=g17)
int   ob_mx=input.int(6,"Max/Side",minval=1,group=g17)

type OBZone
    box bx
    label lbl
    float score
    bool isBull
    int bar0
    bool mitigated
    float mitPct

float ob_atr=ta.atr(14)
float ob_ema=ta.ema(close,20)
float ob_ph=ta.pivothigh(high,ob_swL,1)
float ob_pl=ta.pivotlow(low,ob_swL,1)
var array<OBZone> ob_bulls = array.new<OBZone>()
var array<OBZone> ob_bears = array.new<OBZone>()
var int ob_totalB = 0
var int ob_totalS = 0

// Bear OB detection (pivot high → displacement down)
if M17 and not na(ob_ph) and sok()
    int idx=na
    for j=2 to 2+ob_lk
        if bar_index-j>=0 and close[j]>open[j]
            idx:=j
            break
    if not na(idx)
        float rT=high[idx]
        float rB=low[idx]
        if ob_atr>0 and (rT-low[1])>=ob_atr*ob_dp
            float mid=(rT+rB)/2
            // Score breakdown (BLUEPRINT ❌)
            float scTrend = close < ob_ema ? 5.0 : 2.0
            float scLoc = 5.0
            float scSess = sid() >= 2 ? 1.0 : 0.0
            float scDxy = dOk and dUp ? 1.5 : 0.0
            float scPsy = psy(mid) ? 1.5 : 0.0
            float tot=math.min(30, (scTrend + scLoc + scSess + scDxy + scPsy) * 2)
            if tot>=ob_ms
                bool hp=psy(mid)
                color obC = hp ? P_GO : P_RD
                // Age-based opacity: start at 84 (BLUEPRINT ❌)
                box obBox = box.new(bar_index-idx, rT, bar_index+180, rB, bgcolor=color.new(obC,84), border_color=color.new(obC,10))
                // Score label (BLUEPRINT ❌)
                string scoreTx = str.tostring(math.round(tot))+"/30\nT:"+str.tostring(scTrend,"#")+" S:"+str.tostring(scSess,"#")+" D:"+str.tostring(scDxy,"#.#")+(hp?" ★":"")
                label obLbl = label.new(bar_index-idx, rT, scoreTx, style=label.style_label_down, color=color.new(obC,40), textcolor=color.white, size=size.small)
                ob_bears.push(OBZone.new(obBox, obLbl, tot, false, bar_index, false, 0.0))
                ob_totalS += 1
                if ob_bears.size()>ob_mx
                    OBZone old = ob_bears.shift()
                    old.bx.delete()
                    old.lbl.delete()
                sS:=true
                sSP:=hp
                sSrc:="OBZ"

// Bull OB detection (pivot low → displacement up)
if M17 and not na(ob_pl) and sok()
    int idx=na
    for j=2 to 2+ob_lk
        if bar_index-j>=0 and close[j]<open[j]
            idx:=j
            break
    if not na(idx)
        float rT=high[idx]
        float rB=low[idx]
        if ob_atr>0 and (high[1]-rB)>=ob_atr*ob_dp
            float mid=(rT+rB)/2
            float scTrend = close > ob_ema ? 5.0 : 2.0
            float scLoc = 5.0
            float scSess = sid() == 1 ? 2.0 : 0.0
            float scDxy = dOk and not dUp ? 1.5 : 0.0
            float scPsy = psy(mid) ? 1.5 : 0.0
            float tot=math.min(30, (scTrend + scLoc + scSess + scDxy + scPsy) * 2)
            if tot>=ob_ms
                bool hp=psy(mid)
                color obC = hp ? P_GO : P_GN
                box obBox = box.new(bar_index-idx, rT, bar_index+180, rB, bgcolor=color.new(obC,82), border_color=color.new(obC,10))
                string scoreTx = str.tostring(math.round(tot))+"/30\nT:"+str.tostring(scTrend,"#")+" S:"+str.tostring(scSess,"#")+" D:"+str.tostring(scDxy,"#.#")+(hp?" ★":"")
                label obLbl = label.new(bar_index-idx, rB, scoreTx, style=label.style_label_up, color=color.new(obC,40), textcolor=color.white, size=size.small)
                ob_bulls.push(OBZone.new(obBox, obLbl, tot, true, bar_index, false, 0.0))
                ob_totalB += 1
                if ob_bulls.size()>ob_mx
                    OBZone old = ob_bulls.shift()
                    old.bx.delete()
                    old.lbl.delete()
                sB:=true
                sBP:=hp
                sSrc:="OBZ"

// Mitigation + age-based opacity tracking (BLUEPRINT ❌)
if ob_bulls.size()>0
    for i=ob_bulls.size()-1 to 0
        OBZone z=ob_bulls.get(i)
        z.bx.set_right(bar_index+5)
        float zBot = z.bx.get_bottom()
        float zTop = z.bx.get_top()
        // Partial mitigation tracking
        if close < zBot
            z.mitigated := true
            z.bx.delete()
            z.lbl.delete()
            ob_bulls.remove(i)
        else
            // Age fade (BLUEPRINT ❌)
            int ageB = bar_index - z.bar0
            int fadeOp = math.min(95, 82 + int(ageB / 30.0))
            z.bx.set_bgcolor(color.new(P_GN, fadeOp))

if ob_bears.size()>0
    for i=ob_bears.size()-1 to 0
        OBZone z=ob_bears.get(i)
        z.bx.set_right(bar_index+5)
        float zTop = z.bx.get_top()
        if close > zTop
            z.mitigated := true
            z.bx.delete()
            z.lbl.delete()
            ob_bears.remove(i)
        else
            int ageB = bar_index - z.bar0
            int fadeOp = math.min(95, 84 + int(ageB / 30.0))
            z.bx.set_bgcolor(color.new(P_RD, fadeOp))

// Dashboard (BLUEPRINT ❌)

// ═══════════════ 19: VECTOR SMC ═══════════════
// BLUEPRINT: FVG detection, FVG mitigation, OB extension+invalidation,
//   Psych-colored boxes, Sweep labels
string g19="19 Vec SMC"
int   vs_vl=input.int(10,"Vol LB",minval=5,group=g19)
float vs_sm=input.float(2.0,"Strong Mult",minval=1.0,step=0.1,group=g19)
int   vs_mx=input.int(5,"Max OBs",minval=1,group=g19)
int   vs_sw=input.int(5,"Swing LB",minval=2,group=g19)
int   vs_fMx=input.int(8,"Max FVGs",minval=1,maxval=20,group=g19)
float vs_avgV=ta.sma(volume,vs_vl)
float vs_clx=volume*(high-low)
float vs_mxCl=ta.highest(vs_clx,vs_vl)
int vs_tier=(volume>=vs_avgV*vs_sm or vs_clx>=vs_mxCl)?2:volume>=vs_avgV*1.5?1:0
bool vs_vec=vs_tier>=1
bool vs_bull=close>open
bool vs_swH=not na(ta.pivothigh(high,vs_sw,vs_sw))
bool vs_swL=not na(ta.pivotlow(low,vs_sw,vs_sw))
var float vs_lSH=na
var float vs_lSL=na
if vs_swH
    vs_lSH:=high[vs_sw]
if vs_swL
    vs_lSL:=low[vs_sw]

// OB arrays with extension + invalidation (BLUEPRINT ❌)
var box[] vs_bOB=array.new<box>()
var box[] vs_sOB=array.new<box>()

if M19 and vs_vec[1] and close[1]<open[1] and not na(vs_lSL) and low[1]<vs_lSL and close>open[1] and sok()
    float t=math.max(open[1],close[1])
    float b=math.min(open[1],close[1])
    bool hp=psy((t+b)/2)
    color obC = hp ? P_GO : P_GN
    vs_bOB.push(box.new(bar_index-1,t,bar_index+20,b,bgcolor=color.new(obC,80), border_color=color.new(obC,30)))
    // Sweep label (BLUEPRINT ❌)
    // SweepOB label suppressed
    if vs_bOB.size()>vs_mx
        vs_bOB.shift().delete()
    sB:=true
    sBP:=hp
    sSrc:="VSMC"
if M19 and vs_vec[1] and close[1]>open[1] and not na(vs_lSH) and high[1]>vs_lSH and close<open[1] and sok()
    float t=math.max(open[1],close[1])
    float b=math.min(open[1],close[1])
    bool hp=psy((t+b)/2)
    color obC = hp ? P_GO : P_RD
    vs_sOB.push(box.new(bar_index-1,t,bar_index+20,b,bgcolor=color.new(obC,80), border_color=color.new(obC,30)))
    // SweepOB label suppressed
    if vs_sOB.size()>vs_mx
        vs_sOB.shift().delete()
    sS:=true
    sSP:=hp
    sSrc:="VSMC"

// OB extension + invalidation (BLUEPRINT ❌)
if vs_bOB.size()>0
    for i=vs_bOB.size()-1 to 0
        box b=vs_bOB.get(i)
        b.set_right(bar_index+5)
        if close < b.get_bottom()
            b.delete()
            vs_bOB.remove(i)
if vs_sOB.size()>0
    for i=vs_sOB.size()-1 to 0
        box b=vs_sOB.get(i)
        b.set_right(bar_index+5)
        if close > b.get_top()
            b.delete()
            vs_sOB.remove(i)

// FVG detection volume-gated (BLUEPRINT ❌)
var box[] vs_bFVG=array.new<box>()
var box[] vs_sFVG=array.new<box>()
bool vs_fvgBull = low > high[2] and vs_vec and (low - high[2]) > ATR14 * 0.05
bool vs_fvgBear = high < low[2] and vs_vec and (low[2] - high) > ATR14 * 0.05
if M19 and vs_fvgBull
    bool hp = psy((low + high[2]) / 2)
    color fc = hp ? P_GO : P_GN
    vs_bFVG.push(box.new(bar_index-1, low, bar_index+20, high[2], bgcolor=color.new(fc,85), border_color=na))
    if vs_bFVG.size()>vs_fMx
        vs_bFVG.shift().delete()
if M19 and vs_fvgBear
    bool hp = psy((high + low[2]) / 2)
    color fc = hp ? P_GO : P_RD
    vs_sFVG.push(box.new(bar_index-1, low[2], bar_index+20, high, bgcolor=color.new(fc,85), border_color=na))
    if vs_sFVG.size()>vs_fMx
        vs_sFVG.shift().delete()
// FVG mitigation (BLUEPRINT ❌)
if vs_bFVG.size()>0
    for i=vs_bFVG.size()-1 to 0
        box b=vs_bFVG.get(i)
        b.set_right(bar_index+3)
        if low < b.get_bottom()
            b.delete()
            vs_bFVG.remove(i)
if vs_sFVG.size()>0
    for i=vs_sFVG.size()-1 to 0
        box b=vs_sFVG.get(i)
        b.set_right(bar_index+3)
        if high > b.get_top()
            b.delete()
            vs_sFVG.remove(i)


// ═══════════════ 20: ALGOPATH ═══════════════
// BLUEPRINT: London/NY Open lines, EQ level, New day bgcolor,
//   Session-colored whale labels, Time labels
string g20="20 AlgoPath"
bool  ap_pdhl=input.bool(true,"PDH/PDL",group=g20)
bool  ap_whale=input.bool(true,"Whale Candles",group=g20)
float ap_wm=input.float(1.5,"Whale ATR Mult",minval=0.5,step=0.1,group=g20)
bool  ap_eq=input.bool(true,"Show EQ Level",group=g20)
bool  ap_openLn=input.bool(true,"Show Open Lines",group=g20)
bool  ap_dayBg=input.bool(false,"New Day Shading",group=g20)

bool ap_nd=ta.change(dayofmonth(time,"GMT-4"))!=0
var float ap_dH=high
var float ap_dL=low
var float ap_pH=na
var float ap_pL=na
ap_dH:=math.max(ap_dH,high)
ap_dL:=math.min(ap_dL,low)
if ap_nd and not na(ap_dH[1])
    ap_pH:=ap_dH[1]
    ap_pL:=ap_dL[1]
    ap_dH:=high
    ap_dL:=low
    if M20 and ap_pdhl
        line.new(time,ap_pH,time+86400000,ap_pH,color=color.new(P_SK,0), width=2,xloc=xloc.bar_time)
        line.new(time,ap_pL,time+86400000,ap_pL,color=color.new(P_RD,0), width=2,xloc=xloc.bar_time)
        // EQ level (BLUEPRINT ❌)
        if ap_eq and not na(ap_pH) and not na(ap_pL)
            float eqLv = (ap_pH + ap_pL) / 2.0
            line.new(time, eqLv, time+86400000, eqLv, color=color.new(P_DM,30), width=1, style=line.style_dashed, xloc=xloc.bar_time)
            label.new(time, eqLv, "EQ "+str.tostring(eqLv,"#.#"), style=label.style_none, textcolor=color.new(P_DM,20), size=size.tiny, xloc=xloc.bar_time)

// New day background shading (BLUEPRINT ❌)

// London Open line (BLUEPRINT ❌)
var line ap_lonLine = na
var label ap_lonLbl = na
if M20 and ap_openLn and _iL > _iL[1]
    ap_lonLine.delete()
    ap_lonLbl.delete()
    ap_lonLine := line.new(bar_index, open, bar_index+50, open, color=color.new(P_BU,30), width=1, style=line.style_dashed)
    ap_lonLbl := label.new(bar_index, open, "LON Open", style=label.style_none, textcolor=P_BU, size=size.small)

// NY Open line (BLUEPRINT ❌)
var line ap_nyLine = na
var label ap_nyLbl = na
if M20 and ap_openLn and _iN > _iN[1]
    ap_nyLine.delete()
    ap_nyLbl.delete()
    ap_nyLine := line.new(bar_index, open, bar_index+50, open, color=color.new(P_SK,30), width=1, style=line.style_dashed)
    ap_nyLbl := label.new(bar_index, open, "NY Open", style=label.style_none, textcolor=P_SK, size=size.small)

float ap_atr=ta.atr(14)
bool ap_wB=M20 and ap_whale and math.abs(close-open)>ap_atr*ap_wm and close>open
bool ap_wS=M20 and ap_whale and math.abs(close-open)>ap_atr*ap_wm and close<open
// Session-colored whale barcolor (BLUEPRINT ❌)
color ap_wCol = sid()==1?P_BE:sid()==2?P_BU:sid()==3?P_SK:P_DM

// Whale labels with session color + time (BLUEPRINT ❌)
if ap_wB and sok()
    string timeTx = str.format("{0,time,HH:mm}", time)
    label.new(bar_index, high, snm()+"\n"+timeTx, color=color.new(ap_wCol,70), textcolor=ap_wCol, style=label.style_label_down, size=size.small)
if ap_wS and sok()
    string timeTx = str.format("{0,time,HH:mm}", time)
    label.new(bar_index, low, snm()+"\n"+timeTx, color=color.new(ap_wCol,70), textcolor=ap_wCol, style=label.style_label_up, size=size.small)



// ═══════════════ 12: FVG WAVE ═══════════════
// BLUEPRINT: type fvg complete, POC line+touch, f_has_psych,
//   Age-based opacity, Fill box, Volume, Session-colored,
//   Ghost mitigated, Dashboard, 4 alertcondition
string g12="12 FVG Wave"
int   f12_mx=input.int(12,"Max Zones",minval=1,maxval=50,group=g12)
float f12_gf=input.float(0.1,"Gap Filter(ATR)",step=0.1,group=g12)
int   f12_zl=input.int(20,"Zone Length",minval=5,group=g12)
bool  f12_gh=input.bool(false,"Ghost Mitigated",group=g12)

// Type complete (BLUEPRINT ❌)
type F12z
    int idx
    bool bull
    bool mit
    string sess
    bool hasPsych
    float tp
    float bt
    float poc
    float vol
    line tL
    line bL
    line pL
    box fillBx
    label tag
    int age

var f12s=array.new<F12z>()
var int f12_totalBull=0
var int f12_totalBear=0
var int f12_mitigated=0

bool f12_bC=low>high[2] and (low-high[2])>(ATR14*f12_gf)
bool f12_sC=high<low[2] and (low[2]-high)>(ATR14*f12_gf)

// f_has_psych (BLUEPRINT ❌)
f12_hasPsy(float top, float bot) =>
    if not GP
        false
    else
        float p = math.ceil(bot / GPI) * GPI
        p >= bot and p <= top

if M12 and (f12_bC or f12_sC) and sok()
    float tp=f12_bC?low:low[2]
    float bt=f12_bC?high[2]:high
    float poc=(tp+bt)/2
    float fvgVol=nz(volume,1)
    bool hp = f12_hasPsy(tp, bt)
    string fSess = snm()
    // Session-colored rendering (BLUEPRINT ❌)
    color sc=sid()==3?P_SK:sid()==2?P_BU:sid()==1?P_BE:scl()
    line tL=line.new(bar_index-1,tp,bar_index-1+f12_zl,tp,color=color.new(sc,0), width=1)
    line bL=line.new(bar_index-1,bt,bar_index-1+f12_zl,bt,color=color.new(sc,0), width=1)
    // POC line dotted (BLUEPRINT ❌)
    line pL=line.new(bar_index-1,poc,bar_index-1+f12_zl,poc,color=color.new(sc,20), width=1,style=line.style_dotted)
    // Fill box (BLUEPRINT ❌)
    box fBx=box.new(bar_index-1,tp,bar_index-1+f12_zl,bt,bgcolor=color.new(sc,88),border_color=na)
    label tg=label.new(bar_index-1,tp,fSess+(hp?" ★":""), style=label.style_none,textcolor=color.new(sc,0), size=size.small)
    f12s.push(F12z.new(bar_index-1,f12_bC,false,fSess,hp,tp,bt,poc,fvgVol,tL,bL,pL,fBx,tg,0))
    if f12_bC
        sB:=true
        sBP:=hp
        sSrc:="FVG"
        f12_totalBull+=1
    else
        sS:=true
        sSP:=hp
        sSrc:="FVG"
        f12_totalBear+=1

// Mitigation + POC touch + age fade (BLUEPRINT ❌)
bool f12_pocTouched = false
if f12s.size()>0
    for i=f12s.size()-1 to 0
        F12z f=f12s.get(i)
        f.age+=1
        // Age-based opacity (BLUEPRINT ❌)
        int ageOp = math.min(95, 88 + int(f.age / 20.0))
        if not na(f.fillBx)
            color sc2=f.sess=="NY"?P_SK:f.sess=="London"?P_BU:P_BE
            f.fillBx.set_bgcolor(color.new(sc2, ageOp))
        // POC touch detection (BLUEPRINT ❌)
        if not f.mit and math.abs(close - f.poc) <= ATR14 * 0.1
            f12_pocTouched := true
        if not f.mit and ((f.bull and low<f.bt) or (not f.bull and high>f.tp))
            f.mit:=true
            f12_mitigated+=1
        if f.mit and not f12_gh
            f.tL.delete()
            f.bL.delete()
            f.pL.delete()
            if not na(f.fillBx)
                f.fillBx.delete()
            if not na(f.tag)
                f.tag.delete()
            f12s.remove(i)
        else if f.mit and f12_gh
            // Ghost display (BLUEPRINT ❌)
            if not na(f.fillBx)
                f.fillBx.set_bgcolor(color.new(P_DM, 95))
while f12s.size()>f12_mx
    F12z old=f12s.shift()
    old.tL.delete()
    old.bL.delete()
    old.pL.delete()
    if not na(old.fillBx)
        old.fillBx.delete()
    if not na(old.tag)
        old.tag.delete()

// Dashboard (BLUEPRINT ❌)


// ═══════════════ 08: SWINGREGRESS (with LRC drawing) ═══════════════
// BLUEPRINT: type LRCHandles/PivotNode/LRCSettings, LRC fill,
//   f_draw_psych_in_lrc, f_blockBar/blockColor, CHoCH/BOS labels,
//   Dashboard, 3 alertcondition
string g08="08 SwingReg"
int   sr8_pl=input.int(10,"Pivot Left",minval=1,group=g08)
int   sr8_pr=input.int(10,"Pivot Right",minval=1,group=g08)
float sr8_m1=input.float(1.0,"Band 1 Mult",step=0.1,group=g08)
float sr8_m2=input.float(2.0,"Band 2 Mult",step=0.1,group=g08)
bool  sr8_b2=input.bool(true,"Show Band 2",group=g08)
int   sr8_lw=input.int(2,"Line Width",minval=1,maxval=4,group=g08)
bool  sr8_sw=input.bool(true,"Show Swing Zones",group=g08)
int   sr8_sq=input.int(20,"Squeeze Len",minval=5,group=g08)
float sr8_bb=input.float(2.0,"BB Dev",step=0.1,group=g08)
float sr8_kc=input.float(1.5,"KC Dev",step=0.1,group=g08)
bool  sr8_prev=input.bool(true,"Show Previous LRC",group=g08)
bool  sr8_psyLRC=input.bool(true,"Psych in LRC",group=g08)

// State — type LRCHandles (BLUEPRINT ❌)
var float sr8_lPH=na
var float sr8_lPL=na
var int sr8_lPHb=na
var int sr8_lPLb=na
var int sr8_tr=0
var int sr8_lrcS=na
var int sr8_plrcS=na
var int sr8_plrcE=na
var array<box> sr8_shB=array.new<box>()
var array<box> sr8_slB=array.new<box>()
var int sr8_chochCnt=0
var int sr8_bosCnt=0

float sr8_ph=ta.pivothigh(high,sr8_pl,sr8_pr)
float sr8_plv=ta.pivotlow(low,sr8_pl,sr8_pr)

if not na(sr8_ph)
    sr8_lPH:=sr8_ph
    sr8_lPHb:=bar_index-sr8_pr
    if M08 and sr8_sw
        sr8_shB.push(box.new(sr8_lPHb,sr8_lPH,bar_index-1,math.max(open[sr8_pr],close[sr8_pr]),border_color=na,bgcolor=color.new(P_BE,85)))
        if sr8_shB.size()>8
            sr8_shB.shift().delete()
if not na(sr8_plv)
    sr8_lPL:=sr8_plv
    sr8_lPLb:=bar_index-sr8_pr
    if M08 and sr8_sw
        sr8_slB.push(box.new(sr8_lPLb,math.min(open[sr8_pr],close[sr8_pr]),bar_index-1,sr8_lPL,border_color=na,bgcolor=color.new(P_BU,85)))
        if sr8_slB.size()>8
            sr8_slB.shift().delete()

// CHoCH + BOS detection with labels (BLUEPRINT ❌)
bool sr8_bCH=sr8_tr<=0 and not na(sr8_lPH) and close[1]>sr8_lPH and sok()
bool sr8_sCH=sr8_tr>=0 and not na(sr8_lPL) and close[1]<sr8_lPL and sok()
bool sr8_bBOS = sr8_tr==1 and not na(sr8_lPH) and close[1]>sr8_lPH and sok()
bool sr8_sBOS = sr8_tr==-1 and not na(sr8_lPL) and close[1]<sr8_lPL and sok()

if sr8_bCH or sr8_sCH
    sr8_plrcS:=sr8_lrcS
    sr8_plrcE:=bar_index
    sr8_lrcS:=sr8_bCH?nz(sr8_lPLb,bar_index):nz(sr8_lPHb,bar_index)
    sr8_tr:=sr8_bCH?1:-1
    sr8_chochCnt+=1
    // CHoCH label (BLUEPRINT ❌)
    if M08
        label.new(bar_index, sr8_bCH?high+ATR14*0.3:low-ATR14*0.3, sr8_bCH?"CHoCH↑":"CHoCH↓", style=sr8_bCH?label.style_label_down:label.style_label_up, color=color.new(P_GO,20), textcolor=color.white, size=size.small)

if sr8_bBOS or sr8_sBOS
    sr8_bosCnt+=1
    // BOS label (BLUEPRINT ❌)
    if M08
        label.new(bar_index, sr8_bBOS?high+ATR14*0.3:low-ATR14*0.3, sr8_bBOS?"BOS↑":"BOS↓", style=sr8_bBOS?label.style_label_down:label.style_label_up, color=color.new(P_SK,20), textcolor=color.white, size=size.small)

// LRC Drawing
_sr8_draw_lrc() =>
    var line sr8_mid=na
    var line sr8_u1=na
    var line sr8_l1=na
    var line sr8_u2=na
    var line sr8_l2=na
    var linefill sr8_fill1=na
    var linefill sr8_fill2=na
    var line sr8_pmid=na
    var line sr8_pu1=na
    var line sr8_pl1=na
    var array<line> sr8_psyL=array.new<line>()
    if not na(sr8_lrcS) and bar_index>sr8_lrcS
        int sr8_len=bar_index-sr8_lrcS+1
        int sr8_sS=sr8_lrcS
        if sr8_len>999
            sr8_sS:=bar_index-998
            sr8_len:=999
        if sr8_len>2
            float sX=0.0
            float sY=0.0
            float sXY=0.0
            float sX2=0.0
            float sE2=0.0
            for i=0 to sr8_len-1
                int age=bar_index-(sr8_sS+i)
                if age>=0 and age<5000
                    float y=close[age]
                    float x=float(i)
                    sX+=x
                    sY+=y
                    sXY+=x*y
                    sX2+=x*x
            float denom=sr8_len*sX2-sX*sX
            if denom!=0
                float slope=(sr8_len*sXY-sX*sY)/denom
                float intc=(sY-slope*sX)/sr8_len
                for i=0 to sr8_len-1
                    int age=bar_index-(sr8_sS+i)
                    if age>=0 and age<5000
                        float err=close[age]-(intc+slope*float(i))
                        sE2+=err*err
                float sd=math.sqrt(sE2/sr8_len)
                float yS=intc
                float yE=intc+slope*(sr8_len-1)
                color mc=sr8_tr==1?P_BU:P_BE
                sr8_mid.delete()
                sr8_u1.delete()
                sr8_l1.delete()
                sr8_u2.delete()
                sr8_l2.delete()
                sr8_fill1.delete()
                sr8_fill2.delete()
                sr8_mid:=line.new(sr8_sS,yS,bar_index,yE,color=mc,width=sr8_lw)
                sr8_u1:=line.new(sr8_sS,yS+sd*sr8_m1,bar_index,yE+sd*sr8_m1,color=color.new(mc,30),width=sr8_lw,style=line.style_dashed)
                sr8_l1:=line.new(sr8_sS,yS-sd*sr8_m1,bar_index,yE-sd*sr8_m1,color=color.new(mc,30),width=sr8_lw,style=line.style_dashed)
                // LRC fill (BLUEPRINT ❌)
                sr8_fill1:=linefill.new(sr8_u1, sr8_l1, color=color.new(mc, 90))
                if sr8_b2
                    sr8_u2:=line.new(sr8_sS,yS+sd*sr8_m2,bar_index,yE+sd*sr8_m2,color=color.new(mc,60),width=sr8_lw,style=line.style_dotted)
                    sr8_l2:=line.new(sr8_sS,yS-sd*sr8_m2,bar_index,yE-sd*sr8_m2,color=color.new(mc,60),width=sr8_lw,style=line.style_dotted)
                    sr8_fill2:=linefill.new(sr8_u2, sr8_l2, color=color.new(mc, 95))
    
                // f_draw_psych_in_lrc (BLUEPRINT ❌)
                if sr8_psyLRC and GP
                    for pl in sr8_psyL
                        pl.delete()
                    sr8_psyL.clear()
                    float pLo = math.min(yS - sd * sr8_m2, yE - sd * sr8_m2)
                    float pHi = math.max(yS + sd * sr8_m2, yE + sd * sr8_m2)
                    float lvl = math.floor(pLo / GPI) * GPI
                    int cnt = 0
                    while lvl <= pHi and cnt < 15
                        if lvl >= pLo and lvl <= pHi
                            sr8_psyL.push(line.new(sr8_sS, lvl, bar_index, lvl, color=color.new(P_GO, 60), style=line.style_dotted, width=1))
                        lvl += GPI
                        cnt += 1
    
        // Previous LRC
        if sr8_prev and not na(sr8_plrcS) and not na(sr8_plrcE) and sr8_plrcE>sr8_plrcS
            int pLen=sr8_plrcE-sr8_plrcS+1
            if pLen>2 and pLen<=999
                float psX=0.0
                float psY=0.0
                float psXY=0.0
                float psX2=0.0
                float psE2=0.0
                for i=0 to pLen-1
                    int age=bar_index-(sr8_plrcS+i)
                    if age>=0 and age<5000
                        float y=close[age]
                        float x=float(i)
                        psX+=x
                        psY+=y
                        psXY+=x*y
                        psX2+=x*x
                float pDen=pLen*psX2-psX*psX
                if pDen!=0
                    float pSlp=(pLen*psXY-psX*psY)/pDen
                    float pInt=(psY-pSlp*psX)/pLen
                    for i=0 to pLen-1
                        int age=bar_index-(sr8_plrcS+i)
                        if age>=0 and age<5000
                            float err=close[age]-(pInt+pSlp*float(i))
                            psE2+=err*err
                    float pSd=math.sqrt(psE2/pLen)
                    float pyS=pInt
                    float pyE=pInt+pSlp*(pLen-1)
                    sr8_pmid.delete()
                    sr8_pu1.delete()
                    sr8_pl1.delete()
                    sr8_pmid:=line.new(sr8_plrcS,pyS,sr8_plrcE,pyE,color=color.new(P_DM,40),width=1)
                    sr8_pu1:=line.new(sr8_plrcS,pyS+pSd*sr8_m1,sr8_plrcE,pyE+pSd*sr8_m1,color=color.new(P_DM,60),width=1,style=line.style_dashed)
                    sr8_pl1:=line.new(sr8_plrcS,pyS-pSd*sr8_m1,sr8_plrcE,pyE-pSd*sr8_m1,color=color.new(P_DM,60),width=1,style=line.style_dashed)
    
    0

if M08
    _sr8_draw_lrc()
// Squeeze
float sr8_sqB=ta.sma(close,sr8_sq)
float sr8_sqD=sr8_bb*ta.stdev(close,sr8_sq)
float sr8_kcR=ta.sma(ta.tr,sr8_sq)
bool sr8_isSq=(sr8_sqB+sr8_sqD)<(sr8_sqB+sr8_kcR*sr8_kc) and (sr8_sqB-sr8_sqD)>(sr8_sqB-sr8_kcR*sr8_kc)
// f_blockBar/f_blockColor (BLUEPRINT ❌)
color sr8_sqC=M08 and sr8_isSq?P_GO:na

if M08 and sr8_bCH
    sB:=true
    sBP:=psy(close)
    sSrc:="SREG"
if M08 and sr8_sCH
    sS:=true
    sSP:=psy(close)
    sSrc:="SREG"

// Dashboard (BLUEPRINT ❌)


// ═══════════════ 09: ANCHORED TREND CHANNELS (ATC) ═══════════════
// Tier 1 largest module. Full reimplementation from 747-line original.
// BLUEPRINT: f_segment_metrics, f_close_and_open_segment, Macro channel,
//   Micro channel(LRC+bands), BRK/PB/CONT signal, f_sig_push,
//   Endpoint labels, Pivot markers, f_mtf_pair, MTF screener,
//   Status badge, Psych levels in channel, Dashboard(20+cell), 3 alertcondition
string g09="09 ATC"
bool  c9_macS=input.bool(true,"Show Macro Segments",group=g09)
bool  c9_micS=input.bool(true,"Show Micro Channel",group=g09)
bool  c9_pan=input.bool(true,"Show Panel",group=g09)
bool  c9_stat=input.bool(true,"Show Status Badge",group=g09)
bool  c9_end=input.bool(true,"Show Endpoint Labels",group=g09)
bool  c9_piv=input.bool(true,"Show Pivot Markers",group=g09)
bool  c9_sig=input.bool(true,"Show Signals",group=g09)
string c9_lm=input.string("Very Long","Pivot Sensitivity",options=["Short","Medium","Long","Very Long"],group=g09)
float c9_mSeg=input.float(2.5,"Min Seg Size(ATR)",step=0.1,group=g09)
int   c9_mBar=input.int(8,"Min Seg Bars",minval=2,group=g09)
float c9_bdM=input.float(1.1,"Channel Width",step=0.05,group=g09)
float c9_mbW=input.float(1.0,"Min Band(ATR)",step=0.1,group=g09)
int   c9_mxS=input.int(15,"Max Segments",minval=3,maxval=50,group=g09)
int   c9_mlr=input.int(20,"Micro Regress Len",minval=10,group=g09)
float c9_mdv=input.float(2.0,"Micro StdDev",step=0.1,group=g09)
float c9_mr2=input.float(0.20,"Min R2",step=0.05,group=g09)
bool  c9_brk=input.bool(true,"Segment Break Signals",group=g09)
bool  c9_pb=input.bool(true,"Pullback Signals",group=g09)
bool  c9_cont=input.bool(true,"Continuation Signals",group=g09)
int   c9_cd=input.int(15,"Signal Cooldown",minval=0,group=g09)
bool  c9_fill=input.bool(true,"Channel Fills",group=g09)
bool  c9_bas=input.bool(true,"Show Basis",group=g09)
bool  c9_mtf=input.bool(true,"MTF Screener",group=g09)
bool  c9_psy=input.bool(true,"Psych in Channel",group=g09)
int   c9_lnW=input.int(2,"Line Width",minval=1,maxval=4,group=g09)

int c9_pLB=c9_lm=="Short"?5:c9_lm=="Medium"?10:c9_lm=="Long"?18:30
float c9_aH20=ta.highest(high,20)
float c9_pH=ta.pivothigh(high,c9_pLB,c9_pLB)
float c9_pL=ta.pivotlow(low,c9_pLB,c9_pLB)
bool c9_nPH=not na(c9_pH)
bool c9_nPL=not na(c9_pL)
int c9_gw=c9_lnW+5

// Segment arrays
var int[]   c9_sB=array.new<int>()
var float[] c9_sP=array.new<float>()
var int[]   c9_eB=array.new<int>()
var float[] c9_eP=array.new<float>()
var float[] c9_sl=array.new<float>()
var float[] c9_ic=array.new<float>()
var float[] c9_sd=array.new<float>()
var int[]   c9_dr=array.new<int>()
var float[] c9_ag=array.new<float>()
var line[]  c9_uG=array.new<line>()
var line[]  c9_uC=array.new<line>()
var line[]  c9_lG=array.new<line>()
var line[]  c9_lC=array.new<line>()
var line[]  c9_bL=array.new<line>()
var linefill[] c9_fA=array.new<linefill>()
var label[] c9_pLbl=array.new<label>()
var int c9_lpB=na
var float c9_lpP=na
var int c9_lpT=0

// f_segment_metrics (BLUEPRINT ❌)
c9_seg_met(int sb, float sp, int eb, float ep) =>
    int len = eb - sb + 1
    float _sl = 0.0
    float _ic2 = sp
    float _md = 0.0
    float _an = 0.0
    if len >= 2
        _sl := (ep - sp) / (eb - sb)
        _ic2 := sp
        float mxU = 0.0
        float mxD = 0.0
        int step = math.max(1, math.ceil(len / 500.0))
        for i = 0 to len - 1 by step
            int age = bar_index - (sb + i)
            if age >= 0 and age < 4900
                float yh = high[age]
                float yl = low[age]
                if not na(yh) and not na(yl)
                    float by2 = _ic2 + _sl * i
                    if yh - by2 > mxU
                        mxU := yh - by2
                    if by2 - yl > mxD
                        mxD := by2 - yl
        _md := math.max(mxU, mxD)
        float slATR = ATR14 > 0 ? _sl / ATR14 : 0.0
        _an := math.atan(slATR) * 180.0 / math.pi
    [_sl, _ic2, _md, _an]

// f_close_and_open_segment (BLUEPRINT ❌)
c9_close_open(int npB, float npP, int npT, int ppB, float ppP, int ppT) =>
    bool elig = not na(ppB) and ppT != 0 and ppT != npT
    bool pass = elig
    if elig
        int bD = npB - ppB
        float pD = math.abs(npP - ppP)
        if bD < c9_mBar or pD < c9_mSeg * ATR14
            pass := false
    int rB = pass ? npB : ppB
    float rP = pass ? npP : ppP
    int rT = pass ? npT : ppT
    if pass
        [_s, _i, _m, _a] = c9_seg_met(ppB, ppP, npB, npP)
        c9_sB.push(ppB)
        c9_sP.push(ppP)
        c9_eB.push(npB)
        c9_eP.push(npP)
        c9_sl.push(_s)
        c9_ic.push(_i)
        c9_sd.push(_m)
        c9_dr.push(npT)
        c9_ag.push(_a)
        c9_uG.push(line(na))
        c9_uC.push(line(na))
        c9_lG.push(line(na))
        c9_lC.push(line(na))
        c9_bL.push(line(na))
        c9_fA.push(linefill(na))
        c9_pLbl.push(label(na))
    if not pass and na(ppB)
        rB := npB
        rP := npP
        rT := npT
    [rB, rP, rT]

if c9_nPH
    [nb,np,nt]=c9_close_open(bar_index-c9_pLB,c9_pH,1,c9_lpB,c9_lpP,c9_lpT)
    c9_lpB:=nb
    c9_lpP:=np
    c9_lpT:=nt
if c9_nPL
    [nb,np,nt]=c9_close_open(bar_index-c9_pLB,c9_pL,-1,c9_lpB,c9_lpP,c9_lpT)
    c9_lpB:=nb
    c9_lpP:=np
    c9_lpT:=nt

// Trim old segments
while c9_sB.size()>c9_mxS
    c9_sB.shift()
    c9_sP.shift()
    c9_eB.shift()
    c9_eP.shift()
    c9_sl.shift()
    c9_ic.shift()
    c9_sd.shift()
    c9_dr.shift()
    c9_ag.shift()
    c9_uG.shift().delete()
    c9_uC.shift().delete()
    c9_lG.shift().delete()
    c9_lC.shift().delete()
    c9_bL.shift().delete()
    c9_fA.shift().delete()
    c9_pLbl.shift().delete()

// Active segment
var float c9_asl=0.0
var float c9_aic=0.0
var float c9_asd=0.0
var float c9_aan=0.0
var int c9_adr=0
var int c9_asb=na
var float c9_asp=na

if not na(c9_lpB) and bar_index>c9_lpB
    float sep=nz(close[1],close)
    int seb=bar_index-1
    [_s,_i,_m,_a]=c9_seg_met(c9_lpB,c9_lpP,seb,sep)
    c9_asl:=_s
    c9_aic:=_i
    c9_asd:=_m
    c9_aan:=_a
    c9_adr:=c9_lpT==1?-1:c9_lpT==-1?1:0
    c9_asb:=c9_lpB
    c9_asp:=c9_lpP

bool c9_hA=not na(c9_asb) and c9_adr!=0
float c9_auN=na
float c9_alN=na
float c9_abN=na
if c9_hA
    float xN=bar_index-c9_asb
    c9_abN:=c9_aic+c9_asl*xN
    float hw=math.max(c9_asd*c9_bdM,c9_mbW*ATR14)
    c9_auN:=c9_abN+hw
    c9_alN:=c9_abN-hw

// Micro channel (LRC)
float c9_mSx=0.0
float c9_mSy=0.0
float c9_mSxy=0.0
float c9_mSx2=0.0
float c9_mSy2=0.0
for i=0 to c9_mlr-1
    float x=i
    float y=close[i]
    c9_mSx+=x
    c9_mSy+=y
    c9_mSxy+=x*y
    c9_mSx2+=x*x
    c9_mSy2+=y*y
float c9_nf=c9_mlr
float c9_mmx=c9_mSx/c9_nf
float c9_mmy=c9_mSy/c9_nf
float c9_mDn=c9_mSx2-c9_nf*c9_mmx*c9_mmx
float c9_msl=c9_mDn!=0?(c9_mSxy-c9_nf*c9_mmx*c9_mmy)/c9_mDn:0.0
float c9_mic=c9_mmy-c9_msl*c9_mmx
float c9_mBas=c9_mic
float c9_msR=-c9_msl
float c9_msA=ATR14>0?c9_msR/ATR14:0.0
float c9_mAn=math.atan(c9_msA)*180.0/math.pi
int c9_mDir=c9_mAn>3?1:c9_mAn<-3?-1:0
float c9_nR=c9_nf*c9_mSxy-c9_mSx*c9_mSy
float c9_dR=math.sqrt((c9_nf*c9_mSx2-c9_mSx*c9_mSx)*(c9_nf*c9_mSy2-c9_mSy*c9_mSy))
float c9_r=c9_dR>0?c9_nR/c9_dR:0.0
float c9_r2=c9_r*c9_r
float c9_ssTot=c9_mSy2-c9_nf*c9_mmy*c9_mmy
float c9_ssRes=math.max(0,c9_ssTot-c9_msl*(c9_mSxy-c9_nf*c9_mmx*c9_mmy))
float c9_mStd=c9_mlr>2?math.sqrt(c9_ssRes/(c9_nf-2)):0.0
float c9_mU=c9_mBas+c9_mStd*c9_mdv
float c9_mL=c9_mBas-c9_mStd*c9_mdv
bool c9_mVis=c9_r2>=c9_mr2

// Alignment + bias helpers
bool c9_macUp=c9_adr==1
bool c9_macDn=c9_adr==-1
bool c9_micUp=c9_mDir==1
bool c9_micDn=c9_mDir==-1

c9_dirArrow(int d)=>d==1?"↗ Up":d==-1?"↘ Down":"⇆ Flat"
c9_chain()=>
    int sz=c9_dr.size()
    int show_n=math.min(sz,6)
    string s=""
    if show_n>0
        for k=sz-show_n to sz-1
            s:=s+(c9_dr.get(k)==1?"↗":"↘")+" "
    if c9_hA
        s:=s+(c9_adr==1?"↗":c9_adr==-1?"↘":"·")+"*"
    s
c9_tBias()=>
    int sz=c9_dr.size()
    int ln=math.min(sz,6)
    float uW=0.0
    float dW=0.0
    float oP=na
    float nP=na
    if ln>0
        for k=sz-ln to sz-1
            int d=c9_dr.get(k)
            float bars=c9_eB.get(k)-c9_sB.get(k)
            float w=bars*math.max(math.abs(c9_ag.get(k)),1.0)
            if d==1
                uW+=w
            if d==-1
                dW+=w
            if k==sz-ln
                oP:=c9_sP.get(k)
            if k==sz-1
                nP:=c9_eP.get(k)
    if c9_hA
        float aW=(bar_index-c9_asb)*math.max(math.abs(c9_aan),1.0)
        if c9_adr==1
            uW+=aW
        if c9_adr==-1
            dW+=aW
        nP:=close
        if na(oP)
            oP:=c9_asp
    float nmA=(not na(oP) and not na(nP) and ATR14>0)?(nP-oP)/ATR14:0.0
    float tot=uW+dW
    string lbl="Neutral"
    color col=P_DM
    if tot>0
        float uR=uW/tot
        if nmA>3 and uR>=0.40
            lbl:="Strong Bull"
            col:=P_BU
        else if nmA<-3 and uR<=0.60
            lbl:="Strong Bear"
            col:=P_BE
        else if uR>=0.70
            lbl:="Strong Bull"
            col:=P_BU
        else if uR>=0.55 or (nmA>1.5 and uR>=0.45)
            lbl:="Bullish"
            col:=P_BU
        else if uR<=0.30
            lbl:="Strong Bear"
            col:=P_BE
        else if uR<=0.45 or (nmA<-1.5 and uR<=0.55)
            lbl:="Bearish"
            col:=P_BE
        else
            lbl:="Mixed"
            col:=P_GO
    [lbl,col]

// Signals — session-filtered (BLUEPRINT ❌)
bool c9_xoU=ta.crossover(close,c9_auN)
bool c9_xuL=ta.crossunder(close,c9_alN)
bool c9_xoM=ta.crossover(close,c9_mU)
bool c9_xuM=ta.crossunder(close,c9_mL)
bool c9_brkU=c9_hA and c9_macDn and c9_xoU and sok()
bool c9_brkD=c9_hA and c9_macUp and c9_xuL and sok()
bool c9_brkSig=c9_brk and (c9_brkU or c9_brkD)
bool c9_pbLn=c9_hA and c9_macUp and close<=c9_alN+ATR14*0.2 and close>=c9_alN and not (close[1]<=c9_alN+ATR14*0.2 and close[1]>=c9_alN[1]) and sok()
bool c9_pbSh=c9_hA and c9_macDn and close>=c9_auN-ATR14*0.2 and close<=c9_auN and not (close[1]>=c9_auN-ATR14*0.2 and close[1]<=c9_auN[1]) and sok()
bool c9_pbSig=c9_pb and (c9_pbLn or c9_pbSh)
int c9_bIS=c9_hA?bar_index-c9_asb:0
bool c9_eIS=c9_hA and c9_bIS>=3 and c9_bIS<=25
bool c9_cLn=c9_macUp and c9_xoM and c9_mVis and c9_eIS and sok()
bool c9_cSh=c9_macDn and c9_xuM and c9_mVis and c9_eIS and sok()
bool c9_cSig=c9_cont and (c9_cLn or c9_cSh)

// f_sig_push + cooldown (BLUEPRINT ❌)
var array<label> c9_sigL=array.new<label>()
var int c9_lBrkB=-10000
var int c9_lPbB=-10000
var int c9_lContB=-10000
bool c9_brkRdy=c9_cd==0 or (bar_index-c9_lBrkB)>=c9_cd
bool c9_pbRdy=c9_cd==0 or (bar_index-c9_lPbB)>=c9_cd
bool c9_contRdy=c9_cd==0 or (bar_index-c9_lContB)>=c9_cd

c9_spush(label lb)=>
    c9_sigL.push(lb)
    if c9_sigL.size()>15
        c9_sigL.shift().delete()

if M09 and c9_sig and c9_brkSig and barstate.isconfirmed and c9_brkRdy
    bool isUp=c9_brkU
    c9_spush(label.new(bar_index,isUp?high+ATR14*0.4:low-ATR14*0.4,isUp?"BRK↑":"BRK↓",style=isUp?label.style_label_down:label.style_label_up,color=color.new(P_GO,15),textcolor=color.white,size=size.small))
    c9_lBrkB:=bar_index
    if isUp
        sB:=true
    else
        sS:=true
    sSrc:="ATC"

if M09 and c9_sig and c9_pbSig and barstate.isconfirmed and c9_pbRdy
    bool isL=c9_pbLn
    c9_spush(label.new(bar_index,isL?low-ATR14*0.4:high+ATR14*0.4,isL?"PB↑":"PB↓",style=isL?label.style_label_up:label.style_label_down,color=color.new(P_GO,20),textcolor=color.white,size=size.small))
    c9_lPbB:=bar_index
    if isL
        sB:=true
    else
        sS:=true
    sSrc:="ATC"

if M09 and c9_sig and c9_cSig and barstate.isconfirmed and c9_contRdy
    bool isL=c9_cLn
    color cc=isL?P_BU:P_BE
    c9_spush(label.new(bar_index,isL?low-ATR14*0.4:high+ATR14*0.4,isL?"CONT↑":"CONT↓",style=isL?label.style_label_up:label.style_label_down,color=color.new(cc,20),textcolor=color.white,size=size.small))
    c9_lContB:=bar_index
    if isL
        sB:=true
    else
        sS:=true
    sSrc:="ATC"

// f_mtf_pair (BLUEPRINT ❌)
int c9_cMin=timeframe.in_seconds()/60
c9_mtfPair()=>
    string t1="240"
    string t2="1D"
    if timeframe.isseconds
        t1:="5"
        t2:="60"
    else if c9_cMin<=1
        t1:="15"
        t2:="60"
    else if c9_cMin<=5
        t1:="60"
        t2:="240"
    else if c9_cMin<=15
        t1:="240"
        t2:="1D"
    else if c9_cMin<=60
        t1:="240"
        t2:="1D"
    else if c9_cMin<=240
        t1:="1D"
        t2:="1W"
    else if timeframe.isdaily
        t1:="1W"
        t2:="1M"
    else
        t1:="1M"
        t2:="3M"
    [t1,t2]
[c9_tf1,c9_tf2]=c9_mtfPair()
// MTF — c9_adr depends on ta.pivothigh/pivotlow (banned in request.security)
// Use simple close momentum as proxy for HTF trend
[c9_m1c1, c9_m1c2] = request.security(syminfo.tickerid, c9_tf1, [close[1], close[10]], lookahead=barmerge.lookahead_off)
[c9_m2c1, c9_m2c2] = request.security(syminfo.tickerid, c9_tf2, [close[1], close[10]], lookahead=barmerge.lookahead_off)
int c9_m1d = not na(c9_m1c1) and not na(c9_m1c2) ? (c9_m1c1 > c9_m1c2 ? 1 : c9_m1c1 < c9_m1c2 ? -1 : 0) : 0
float c9_m1a = not na(c9_m1c1) and not na(c9_m1c2) and c9_m1c2 != 0 ? (c9_m1c1 - c9_m1c2) / c9_m1c2 * 100 : 0.0
float c9_m1r = 0.0
int c9_m2d = not na(c9_m2c1) and not na(c9_m2c2) ? (c9_m2c1 > c9_m2c2 ? 1 : c9_m2c1 < c9_m2c2 ? -1 : 0) : 0
float c9_m2a = not na(c9_m2c1) and not na(c9_m2c2) and c9_m2c2 != 0 ? (c9_m2c1 - c9_m2c2) / c9_m2c2 * 100 : 0.0
float c9_m2r = 0.0

// RENDER — historical segments + active + micro + psych

_c9_render() =>
    var line c9_al1=na
    var line c9_al2=na
    var line c9_al3=na
    var line c9_al4=na
    var line c9_al5=na
    var line c9_al6=na
    var line c9_al7=na
    var line c9_al8=na
    var line c9_abl=na
    var linefill c9_af=na
    var line c9_ml1=na
    var line c9_ml2=na
    var line c9_ml3=na
    var line c9_ml4=na
    var line c9_mbl=na
    var linefill c9_mf=na
    var label c9_stLbl=na
    var label c9_muLb=na
    var label c9_mlLb=na
    var label c9_miuLb=na
    var label c9_milLb=na
    var array<line> c9_psyL=array.new<line>()
    if barstate.islast
        // Clear old renders
        for k=0 to c9_uG.size()-1
            c9_uG.get(k).delete()
            c9_uC.get(k).delete()
            c9_lG.get(k).delete()
            c9_lC.get(k).delete()
            c9_bL.get(k).delete()
            c9_fA.get(k).delete()
            c9_pLbl.get(k).delete()
        // Draw historical segments
        int sC=c9_sB.size()
        for idx=0 to sC-1
            int sb=c9_sB.get(idx)
            float sp=c9_sP.get(idx)
            int eb=c9_eB.get(idx)
            float ep=c9_eP.get(idx)
            float slp=c9_sl.get(idx)
            float icp=c9_ic.get(idx)
            float sdp=c9_sd.get(idx)
            int drp=c9_dr.get(idx)
            int sLen=eb-sb
            float yS=icp
            float yE=icp+slp*sLen
            float hw=math.max(sdp*c9_bdM,c9_mbW*ATR14)
            color sgC=drp==1?P_BU:P_BE
            line luG=c9_macS?line.new(sb,yS+hw,eb,yE+hw,color=color.new(sgC,60),width=c9_lnW+2):na
            line luC=c9_macS?line.new(sb,yS+hw,eb,yE+hw,color=color.new(sgC,20),width=c9_lnW):na
            line llG=c9_macS?line.new(sb,yS-hw,eb,yE-hw,color=color.new(sgC,60),width=c9_lnW+2):na
            line llC=c9_macS?line.new(sb,yS-hw,eb,yE-hw,color=color.new(sgC,20),width=c9_lnW):na
            line lbB=c9_macS and c9_bas?line.new(sb,yS,eb,yE,color=color.new(sgC,50),width=1,style=line.style_dashed):na
            linefill lf=c9_macS and c9_fill and not na(luC) and not na(llC)?linefill.new(luC,llC,color=color.new(sgC,88)):na
            label plb=c9_piv?label.new(eb,ep,drp==1?"H":"L",style=drp==1?label.style_label_down:label.style_label_up,color=color.new(sgC,25),textcolor=color.white,size=size.small):na
            c9_uG.set(idx,luG)
            c9_uC.set(idx,luC)
            c9_lG.set(idx,llG)
            c9_lC.set(idx,llC)
            c9_bL.set(idx,lbB)
            c9_fA.set(idx,lf)
            c9_pLbl.set(idx,plb)
    
        // Active segment render
        c9_af.delete()
        c9_mf.delete()
        c9_al1.delete()
        c9_al2.delete()
        c9_al3.delete()
        c9_al4.delete()
        c9_al5.delete()
        c9_al6.delete()
        c9_al7.delete()
        c9_al8.delete()
        c9_abl.delete()
        c9_ml1.delete()
        c9_ml2.delete()
        c9_ml3.delete()
        c9_ml4.delete()
        c9_mbl.delete()
        c9_muLb.delete()
        c9_mlLb.delete()
        c9_miuLb.delete()
        c9_milLb.delete()
        c9_stLbl.delete()
        for pl in c9_psyL
            pl.delete()
        c9_psyL.clear()
    
        if c9_macS and c9_hA
            color aC=c9_adr==1?P_BU:P_BE
            float aHW=math.max(c9_asd*c9_bdM,c9_mbW*ATR14)
            float aSU=c9_aic+aHW
            float aSL=c9_aic-aHW
            int prj=20
            int prjE=bar_index+prj
            float prjB=c9_aic+c9_asl*(prjE-c9_asb)
            c9_al1:=line.new(c9_asb,aSU,bar_index,c9_auN,color=color.new(aC,50),width=c9_gw)
            c9_al2:=line.new(c9_asb,aSU,bar_index,c9_auN,color=color.new(aC,0),width=c9_lnW)
            c9_al3:=line.new(c9_asb,aSL,bar_index,c9_alN,color=color.new(aC,50),width=c9_gw)
            c9_al4:=line.new(c9_asb,aSL,bar_index,c9_alN,color=color.new(aC,0),width=c9_lnW)
            c9_al5:=line.new(bar_index,c9_auN,prjE,prjB+aHW,color=color.new(aC,70),width=c9_lnW,style=line.style_dashed)
            c9_al6:=line.new(bar_index,c9_auN,prjE,prjB+aHW,color=color.new(aC,40),width=c9_lnW,style=line.style_dashed)
            c9_al7:=line.new(bar_index,c9_alN,prjE,prjB-aHW,color=color.new(aC,70),width=c9_lnW,style=line.style_dashed)
            c9_al8:=line.new(bar_index,c9_alN,prjE,prjB-aHW,color=color.new(aC,40),width=c9_lnW,style=line.style_dashed)
            if c9_bas
                c9_abl:=line.new(c9_asb,c9_aic,bar_index,c9_abN,color=color.new(aC,25),width=1,style=line.style_dashed)
            if c9_fill
                c9_af:=linefill.new(c9_al2,c9_al4,color=color.new(aC,80))
            // Endpoint labels (BLUEPRINT ❌)
            if c9_end
                c9_muLb:=label.new(bar_index+3,c9_auN,"M↑",style=label.style_label_left,color=color.new(aC,20),textcolor=color.white,size=size.small)
                c9_mlLb:=label.new(bar_index+3,c9_alN,"M↓",style=label.style_label_left,color=color.new(aC,50),textcolor=color.white,size=size.small)
    
            // Psych levels in active channel (BLUEPRINT ❌)
            if c9_psy and GP
                float pLo=math.min(c9_alN,aSL)
                float pHi=math.max(c9_auN,aSU)
                float lvl=math.floor(pLo/GPI)*GPI
                int cnt=0
                while lvl<=pHi and cnt<20
                    if lvl>=pLo and lvl<=pHi
                        c9_psyL.push(line.new(c9_asb,lvl,bar_index+prj,lvl,color=color.new(P_GO,50),style=line.style_dotted,width=1))
                    lvl+=GPI
                    cnt+=1
    
        // Micro channel render
        if c9_micS and c9_mVis
            int mSt=bar_index-(c9_mlr-1)
            float mSb=c9_mic+c9_msl*(c9_mlr-1)
            color mC=c9_mDir==1?P_BU:c9_mDir==-1?P_BE:P_DM
            c9_ml1:=line.new(mSt,mSb+c9_mStd*c9_mdv,bar_index,c9_mU,color=color.new(mC,50),width=c9_gw)
            c9_ml2:=line.new(mSt,mSb+c9_mStd*c9_mdv,bar_index,c9_mU,color=color.new(mC,0),width=c9_lnW)
            c9_ml3:=line.new(mSt,mSb-c9_mStd*c9_mdv,bar_index,c9_mL,color=color.new(mC,50),width=c9_gw)
            c9_ml4:=line.new(mSt,mSb-c9_mStd*c9_mdv,bar_index,c9_mL,color=color.new(mC,0),width=c9_lnW)
            if c9_bas
                c9_mbl:=line.new(mSt,mSb,bar_index,c9_mBas,color=color.new(mC,25),width=1,style=line.style_dashed)
            if c9_fill
                c9_mf:=linefill.new(c9_ml2,c9_ml4,color=color.new(mC,82))
            if c9_end
                c9_miuLb:=label.new(bar_index+3,c9_mU,"m↑",style=label.style_label_left,color=color.new(mC,15),textcolor=color.white,size=size.small)
                c9_milLb:=label.new(bar_index+3,c9_mL,"m↓",style=label.style_label_left,color=color.new(mC,45),textcolor=color.white,size=size.small)
    
        // Status badge (BLUEPRINT ❌)
        if c9_stat
            [bLbl,bCol]=c9_tBias()
            if bLbl!="Neutral"
                string sTx=bLbl=="Strong Bull"?"↗↗ STRONG BULL":bLbl=="Bullish"?"↗ BULLISH":bLbl=="Mixed"?"⇆ MIXED":bLbl=="Bearish"?"↘ BEARISH":bLbl=="Strong Bear"?"↘↘ STRONG BEAR":""
                c9_stLbl:=label.new(bar_index+25,c9_aH20+ATR14*3.0,sTx,style=label.style_label_left,color=color.new(bCol,25),textcolor=color.white,size=size.normal)
    
    0

if M09
    _c9_render()
// Panel with 20+ cells (BLUEPRINT ❌)
var table c9_tbl=table.new(position.top_right,2,4,bgcolor=na,border_width=0)
if M09 and c9_pan and barstate.islast
    table.clear(c9_tbl,0,0,1,3)
    [_hL,_hC]=c9_tBias()
    table.cell(c9_tbl,0,0,"ATC",text_color=P_GO,bgcolor=P_SEP,text_size=size.small,text_halign=text.align_left)
    table.cell(c9_tbl,1,0,_hL,text_color=_hC,bgcolor=P_SEP,text_size=size.small,text_halign=text.align_right)
    table.cell(c9_tbl,0,1,"Session",text_color=color.rgb(170,178,195),bgcolor=P_ROW,text_size=size.small,text_halign=text.align_left)
    table.cell(c9_tbl,1,1,snm(),text_color=scl(),bgcolor=P_ROW,text_size=size.small,text_halign=text.align_right)
    table.cell(c9_tbl,0,2,"Macro",text_color=color.rgb(170,178,195),bgcolor=P_PBG,text_size=size.small,text_halign=text.align_left)
    table.cell(c9_tbl,1,2,c9_dirArrow(c9_adr),text_color=c9_adr==1?P_BU:P_BE,bgcolor=P_PBG,text_size=size.small,text_halign=text.align_right)
    table.cell(c9_tbl,0,3,"Micro",text_color=color.rgb(170,178,195),bgcolor=P_ROW,text_size=size.small,text_halign=text.align_left)
    table.cell(c9_tbl,1,3,c9_mVis?str.tostring(c9_mAn,"+#.#;-#.#")+"°":"—",text_color=c9_mDir==1?P_BU:c9_mDir==-1?P_BE:P_DM,bgcolor=P_ROW,text_size=size.small,text_halign=text.align_right)

bool c9_segChg=barstate.isconfirmed and c9_adr!=c9_adr[1]


// ═══════════════ 11: HARMONIC PATTERNS ═══════════════
// BLUEPRINT: type PatternData/TrackedPattern, Bearish patterns,
//   detect_abcd, f_prz_psych, Pattern scoring, Fibonacci projection,
//   draw_pattern, f_already_tracked, Dashboard, 4 alertcondition
string g11="11 Harmonic"
bool h11_bat=input.bool(true,"Bat",group=g11)
bool h11_gart=input.bool(true,"Gartley",group=g11)
bool h11_butt=input.bool(true,"Butterfly",group=g11)
bool h11_crab=input.bool(true,"Crab",group=g11)
bool h11_shark=input.bool(true,"Shark",group=g11)
bool h11_abcd=input.bool(false,"ABCD",group=g11)
bool h11_bear=input.bool(true,"Show Bearish",group=g11)
int  h11_mx=input.int(2,"Max Patterns",minval=1,maxval=5,group=g11)
int  h11_lb=input.int(5,"Pivot Lookback",minval=3,group=g11)
int  h11_dp=input.int(20,"Depth",minval=10,group=g11)
float h11_tol=input.float(15.0,"Tolerance(%)",minval=5,group=g11)
int  h11_freq=input.int(10,"Scan Every N Bars",minval=1,group=g11)
bool h11_fib=input.bool(true,"Fibonacci Lines",group=g11)

// Tracked pattern type (BLUEPRINT ❌)
type HarmPat
    bool bull
    string name
    float score
    int bar0
    float prz
    float xa
    float ab
    float bc
    float cd
    bool psych
    string sess
    bool dxyAlign
    line[] lines
    label lbl

var array<HarmPat> h11_pats = array.new<HarmPat>()

// Pivot detection
float h11_pH = ta.pivothigh(high, h11_lb, h11_lb)
float h11_pL = ta.pivotlow(low, h11_lb, h11_lb)
var float[] h11_highs = array.new<float>()
var int[] h11_highBars = array.new<int>()
var float[] h11_lows = array.new<float>()
var int[] h11_lowBars = array.new<int>()

if not na(h11_pH)
    h11_highs.push(h11_pH)
    h11_highBars.push(bar_index - h11_lb)
    if h11_highs.size() > h11_dp
        h11_highs.shift()
        h11_highBars.shift()
if not na(h11_pL)
    h11_lows.push(h11_pL)
    h11_lowBars.push(bar_index - h11_lb)
    if h11_lows.size() > h11_dp
        h11_lows.shift()
        h11_lowBars.shift()

// Ratio check helper
h11_inR(float v, float lo, float hi) =>
    float tFact = h11_tol / 100.0
    v >= lo * (1.0 - tFact) and v <= hi * (1.0 + tFact)

// f_prz_psych (BLUEPRINT ❌)
h11_przPsy(float przLv) =>
    GP and przLv > 100 and math.abs(przLv - math.round(przLv / GPI) * GPI) <= 10

// Pattern scoring (BLUEPRINT ❌)
h11_patScore(bool isBull, float przLv, string nm) =>
    float sc = 5.0
    // Session
    sc += sid() >= 2 ? 3.0 : 0.0
    // DXY alignment
    if dOk
        sc += (isBull and not dUp) or (not isBull and dUp) ? 2.0 : 0.0
    // Psych confluence
    if h11_przPsy(przLv)
        sc += 2.0
    // Pattern type
    if nm == "Crab" or nm == "Butterfly"
        sc += 1.0
    math.min(15.0, sc)

// f_already_tracked (BLUEPRINT ❌)
h11_tracked(int b0, bool isBull) =>
    bool found = false
    if h11_pats.size() > 0
        for i = 0 to h11_pats.size() - 1
            HarmPat p = h11_pats.get(i)
            if math.abs(p.bar0 - b0) < 5 and p.bull == isBull
                found := true
    found

// Scan engine — bullish patterns (X low → A high → B low → C high → D low near PRZ)
_m11_scan() =>
    var int h11_totBull = 0
    var int h11_totBear = 0
    var int h11_totPsych = 0
    bool _bull = false
    bool _bear = false
    bool _psych = false
    if bar_index % h11_freq == 0 and h11_highs.size() >= 2 and h11_lows.size() >= 2
        // Bullish scan: look for 5 alternating pivots L-H-L-H-L
        int hS = h11_highs.size()
        int lS = h11_lows.size()
        if lS >= 3 and hS >= 2
            float xP = h11_lows.get(lS - 3)
            int xB = h11_lowBars.get(lS - 3)
            float aP = h11_highs.get(hS - 2)
            int aB = h11_highBars.get(hS - 2)
            float bP = h11_lows.get(lS - 2)
            int bB = h11_lowBars.get(lS - 2)
            float cP = h11_highs.get(hS - 1)
            int cB = h11_highBars.get(hS - 1)
            float dP = h11_lows.get(lS - 1)
            int dB = h11_lowBars.get(lS - 1)
            if xB < aB and aB < bB and bB < cB and cB < dB and aP > xP and bP < aP and cP < aP and dP < cP
                float xa = aP - xP
                float ab_r = xa != 0 ? (aP - bP) / xa : 0.0
                float bc_r = (aP - bP) != 0 ? (cP - bP) / (aP - bP) : 0.0
                float xd_r = xa != 0 ? (aP - dP) / xa : 0.0
                // Check all pattern types
                string found = ""
                if h11_bat and h11_inR(ab_r, 0.382, 0.50) and h11_inR(bc_r, 0.382, 0.886) and h11_inR(xd_r, 0.786, 0.886)
                    found := "Bat"
                else if h11_gart and h11_inR(ab_r, 0.618, 0.618) and h11_inR(bc_r, 0.382, 0.886) and h11_inR(xd_r, 0.786, 0.786)
                    found := "Gartley"
                else if h11_butt and h11_inR(ab_r, 0.786, 0.786) and h11_inR(bc_r, 0.382, 0.886) and h11_inR(xd_r, 1.27, 1.618)
                    found := "Butterfly"
                else if h11_crab and h11_inR(ab_r, 0.382, 0.618) and h11_inR(bc_r, 0.382, 0.886) and h11_inR(xd_r, 1.618, 1.618)
                    found := "Crab"
                else if h11_shark and h11_inR(ab_r, 0.382, 0.618) and h11_inR(bc_r, 1.13, 1.618) and h11_inR(xd_r, 0.886, 1.13)
                    found := "Shark"
                if found != "" and not h11_tracked(dB, true) and sok()
                    float przLv = dP
                    float sc = h11_patScore(true, przLv, found)
                    bool hp = h11_przPsy(przLv)
                    bool dxA = dOk and not dUp
                    color lnC = sid()==3?P_SK:sid()==2?P_BU:P_BE
                    // draw_pattern (BLUEPRINT ❌)
                    line[] lns = array.new<line>()
                    lns.push(line.new(xB,xP,aB,aP,color=color.new(lnC,20),width=2))
                    lns.push(line.new(aB,aP,bB,bP,color=color.new(lnC,20),width=2))
                    lns.push(line.new(bB,bP,cB,cP,color=color.new(lnC,20),width=2))
                    lns.push(line.new(cB,cP,dB,dP,color=color.new(lnC,20),width=2))
                    lns.push(line.new(xB,xP,dB,dP,color=color.new(lnC,50),width=1,style=line.style_dashed))
                    // Fibonacci projection levels (BLUEPRINT ❌)
                    if h11_fib
                        float cd_range = cP - dP
                        float f382 = dP + cd_range * 0.382
                        float f618 = dP + cd_range * 0.618
                        float f100 = dP + cd_range * 1.000
                        float f1272 = dP + cd_range * 1.272
                        float f1618 = dP + cd_range * 1.618
                        lns.push(line.new(dB,f382,dB+30,f382,color=color.new(P_DM,40),style=line.style_dotted,width=1))
                        lns.push(line.new(dB,f618,dB+30,f618,color=color.new(P_DM,40),style=line.style_dotted,width=1))
                        lns.push(line.new(dB,f100,dB+30,f100,color=color.new(P_GO,30),style=line.style_dotted,width=1))
                        lns.push(line.new(dB,f1272,dB+30,f1272,color=color.new(P_DM,50),style=line.style_dotted,width=1))
                        lns.push(line.new(dB,f1618,dB+30,f1618,color=color.new(P_DM,50),style=line.style_dotted,width=1))
                    string lbTx = found + (hp?" ★":"") + (dxA?"\nDXY✓":"") + "\n" + str.tostring(math.round(sc)) + "/15\n" + snm()
                    label lb = label.new(dB, dP, lbTx, style=label.style_label_up, color=color.new(hp?P_GO:P_GN,20), textcolor=color.white, size=size.small)
                    h11_pats.push(HarmPat.new(true, found, sc, dB, przLv, 0,0,0,0, hp, snm(), dxA, lns, lb))
                    h11_totBull += 1
                    if hp
                        h11_totPsych += 1
                    _bull := true
                    _psych := hp
                    // Trim old
                    while h11_pats.size() > h11_mx
                        HarmPat old = h11_pats.shift()
                        for l in old.lines
                            l.delete()
                        old.lbl.delete()
    
        // Bearish scan (BLUEPRINT ❌): H-L-H-L-H
        if h11_bear and hS >= 3 and lS >= 2
            float xP2 = h11_highs.get(hS - 3)
            int xB2 = h11_highBars.get(hS - 3)
            float aP2 = h11_lows.get(lS - 2)
            int aB2 = h11_lowBars.get(lS - 2)
            float bP2 = h11_highs.get(hS - 2)
            int bB2 = h11_highBars.get(hS - 2)
            float cP2 = h11_lows.get(lS - 1)
            int cB2 = h11_lowBars.get(lS - 1)
            float dP2 = h11_highs.get(hS - 1)
            int dB2 = h11_highBars.get(hS - 1)
            if xB2 < aB2 and aB2 < bB2 and bB2 < cB2 and cB2 < dB2 and aP2 < xP2 and bP2 > aP2 and cP2 > aP2 and dP2 > cP2
                float xa2 = xP2 - aP2
                float ab_r2 = xa2 != 0 ? (bP2 - aP2) / xa2 : 0.0
                float bc_r2 = (bP2 - aP2) != 0 ? (bP2 - cP2) / (bP2 - aP2) : 0.0
                float xd_r2 = xa2 != 0 ? (dP2 - aP2) / xa2 : 0.0
                string found2 = ""
                if h11_bat and h11_inR(ab_r2, 0.382, 0.50) and h11_inR(bc_r2, 0.382, 0.886) and h11_inR(xd_r2, 0.786, 0.886)
                    found2 := "Bat"
                else if h11_gart and h11_inR(ab_r2, 0.618, 0.618) and h11_inR(bc_r2, 0.382, 0.886) and h11_inR(xd_r2, 0.786, 0.786)
                    found2 := "Gartley"
                else if h11_butt and h11_inR(ab_r2, 0.786, 0.786) and h11_inR(bc_r2, 0.382, 0.886) and h11_inR(xd_r2, 1.27, 1.618)
                    found2 := "Butterfly"
                else if h11_crab and h11_inR(ab_r2, 0.382, 0.618) and h11_inR(bc_r2, 0.382, 0.886) and h11_inR(xd_r2, 1.618, 1.618)
                    found2 := "Crab"
                if found2 != "" and not h11_tracked(dB2, false) and sok()
                    float przLv2 = dP2
                    float sc2 = h11_patScore(false, przLv2, found2)
                    bool hp2 = h11_przPsy(przLv2)
                    bool dxA2 = dOk and dUp
                    color lnC2 = sid()==3?P_SK:sid()==2?P_BU:P_BE
                    line[] lns2 = array.new<line>()
                    lns2.push(line.new(xB2,xP2,aB2,aP2,color=color.new(lnC2,20),width=2))
                    lns2.push(line.new(aB2,aP2,bB2,bP2,color=color.new(lnC2,20),width=2))
                    lns2.push(line.new(bB2,bP2,cB2,cP2,color=color.new(lnC2,20),width=2))
                    lns2.push(line.new(cB2,cP2,dB2,dP2,color=color.new(lnC2,20),width=2))
                    lns2.push(line.new(xB2,xP2,dB2,dP2,color=color.new(lnC2,50),width=1,style=line.style_dashed))
                    if h11_fib
                        float cd_r2 = dP2 - cP2
                        float fA = dP2 - cd_r2 * 0.382
                        float fB = dP2 - cd_r2 * 0.618
                        float fC = dP2 - cd_r2 * 1.000
                        lns2.push(line.new(dB2,fA,dB2+30,fA,color=color.new(P_DM,40),style=line.style_dotted,width=1))
                        lns2.push(line.new(dB2,fB,dB2+30,fB,color=color.new(P_DM,40),style=line.style_dotted,width=1))
                        lns2.push(line.new(dB2,fC,dB2+30,fC,color=color.new(P_GO,30),style=line.style_dotted,width=1))
                    string lbTx2 = "Bear " + found2 + (hp2?" ★":"") + (dxA2?"\nDXY✓":"") + "\n" + str.tostring(math.round(sc2)) + "/15\n" + snm()
                    label lb2 = label.new(dB2, dP2, lbTx2, style=label.style_label_down, color=color.new(hp2?P_GO:P_RD,20), textcolor=color.white, size=size.small)
                    h11_pats.push(HarmPat.new(false, found2, sc2, dB2, przLv2, 0,0,0,0, hp2, snm(), dxA2, lns2, lb2))
                    h11_totBear += 1
                    if hp2
                        h11_totPsych += 1
                    _bear := true
                    _psych := hp2
                    while h11_pats.size() > h11_mx
                        HarmPat old = h11_pats.shift()
                        for l in old.lines
                            l.delete()
                        old.lbl.delete()
    
    [_bull, _bear, _psych]

if M11
    [_h11b, _h11s, _h11p] = _m11_scan()
    if _h11b
        sB := true
        sBP := _h11p
        sSrc := "HARM"
    if _h11s
        sS := true
        sSP := _h11p
        sSrc := "HARM"
// Dashboard (BLUEPRINT ❌)


// ═══════════════ 21: SWING TPO ═══════════════
// BLUEPRINT: type SwingPt, Gradient colored boxes, TPO letter labels,
//   f_grad3, f_is_psych_poc, Naked POC tracking, buildSwingTPO,
//   Dashboard, 4 alertcondition
string g21="21 Swing TPO"
int   tp_swL=input.int(5,"Swing Lookback",minval=2,group=g21)
int   tp_zn=input.int(8,"Zone Divisions",minval=4,maxval=20,group=g21)
int   tp_mx=input.int(3,"Max TPOs",minval=1,maxval=8,group=g21)
int   tp_mxBars=input.int(80,"Max Bars Width",minval=20,group=g21)
bool  tp_grad=input.bool(true,"Gradient Colors",group=g21)
bool  tp_ltr=input.bool(true,"TPO Letters",group=g21)

type SwingPt
    float price
    int barIdx
    bool isHigh

var array<SwingPt> tp_pts = array.new<SwingPt>()
var array<box> tp_boxes = array.new<box>()
var array<label> tp_lbls = array.new<label>()

float tp_pH = ta.pivothigh(high, tp_swL, tp_swL)
float tp_pL = ta.pivotlow(low, tp_swL, tp_swL)

if not na(tp_pH)
    tp_pts.push(SwingPt.new(tp_pH, bar_index - tp_swL, true))
    if tp_pts.size() > 50
        tp_pts.shift()
if not na(tp_pL)
    tp_pts.push(SwingPt.new(tp_pL, bar_index - tp_swL, false))
    if tp_pts.size() > 50
        tp_pts.shift()

// f_grad3: gradient between 3 colors based on 0..1 value (BLUEPRINT ❌)
tp_grad3(float val, color c1, color c2, color c3) =>
    val <= 0.5 ? color.from_gradient(val, 0, 0.5, c1, c2) : color.from_gradient(val, 0.5, 1.0, c2, c3)

// f_is_psych_poc (BLUEPRINT ❌)
tp_isPsyPoc(float poc) =>
    GP and poc > 100 and math.abs(poc - math.round(poc / GPI) * GPI) <= 8

// buildSwingTPO (BLUEPRINT ❌)
bool tp_build = not na(tp_pH) or not na(tp_pL)
_tp_build_tpo() =>
    var line tp_pocLine = na
    var label tp_pocLbl = na
    if tp_build and tp_pts.size() >= 4
        // Clear old boxes + labels
        for b in tp_boxes
            b.delete()
        tp_boxes.clear()
        for l in tp_lbls
            l.delete()
        tp_lbls.clear()
        tp_pocLine.delete()
        tp_pocLbl.delete()
    
        // Use last N swing points to define TPO range
        int ptCount = math.min(tp_pts.size(), tp_mx * 4)
        float rangeH = na
        float rangeL = na
        int rangeStartB = na
        for i = tp_pts.size() - ptCount to tp_pts.size() - 1
            SwingPt sp = tp_pts.get(i)
            if na(rangeH) or sp.price > rangeH
                rangeH := sp.price
            if na(rangeL) or sp.price < rangeL
                rangeL := sp.price
            if na(rangeStartB) or sp.barIdx < rangeStartB
                rangeStartB := sp.barIdx
    
        if not na(rangeH) and not na(rangeL) and rangeH > rangeL and not na(rangeStartB)
            float step = (rangeH - rangeL) / tp_zn
            if step > 0
                // Count TPO per zone
                int[] counts = array.new<int>(tp_zn, 0)
                string tpoLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                int maxCount = 0
    
                for z = 0 to tp_zn - 1
                    float zLo = rangeL + z * step
                    float zHi = zLo + step
                    int cnt = 0
                    for b = math.max(0, bar_index - rangeStartB) to 0
                        if b < 4999
                            float h2 = high[b]
                            float l2 = low[b]
                            if not na(h2) and not na(l2)
                                if h2 >= zLo and l2 <= zHi
                                    cnt += 1
                    counts.set(z, cnt)
                    if cnt > maxCount
                        maxCount := cnt
    
                // Find POC (highest count zone)
                int pocIdx = 0
                int pocVal = 0
                for z = 0 to tp_zn - 1
                    if counts.get(z) > pocVal
                        pocVal := counts.get(z)
                        pocIdx := z
    
                float pocLv = rangeL + (pocIdx + 0.5) * step
                bool isPsyPoc = tp_isPsyPoc(pocLv)
    
                // Draw boxes with gradient (BLUEPRINT ❌)
                for z = 0 to tp_zn - 1
                    float zLo = rangeL + z * step
                    float zHi = zLo + step
                    float ratio = maxCount > 0 ? counts.get(z) / float(maxCount) : 0.0
                    int width = math.max(1, math.round(ratio * tp_mxBars))
                    color bxC = tp_grad ? tp_grad3(ratio, P_BU, P_GO, P_BE) : (z == pocIdx ? P_GO : P_DM)
                    int opac = math.round(60 + (1.0 - ratio) * 30)
                    tp_boxes.push(box.new(bar_index - width, zHi, bar_index, zLo, bgcolor=color.new(bxC, opac), border_color=na))
                    // TPO letter labels (BLUEPRINT ❌)
                    if tp_ltr and counts.get(z) > 0 and z < 26
                        string letter = str.substring(tpoLetters, z, z + 1)
                        tp_lbls.push(label.new(bar_index - math.round(width / 2.0), (zLo + zHi) / 2.0, letter, style=label.style_none, textcolor=color.new(bxC, 20), size=size.small))
    
                // POC line + label
                tp_pocLine := line.new(rangeStartB, pocLv, bar_index + 20, pocLv, color=color.new(isPsyPoc ? P_GO : P_SK, 20), width=2, style=line.style_solid)
                string pocTx = "POC " + str.tostring(pocLv, "#.#") + (isPsyPoc ? " ★" : "")
                tp_pocLbl := label.new(bar_index + 20, pocLv, pocTx, style=label.style_none, textcolor=color.new(isPsyPoc ? P_GO : P_SK, 0), size=size.small)
    
    0

if M21
    _tp_build_tpo()
// Dashboard (BLUEPRINT ❌)

// ═══════════════ 07: MINICHARTS ═══════════════
// BLUEPRINT: type BarData/Store, SMT lines, EMA/VWAP overlay,
//   FVG boxes, Session background, Psych dotted lines,
//   Layout mode, renderMini
string g07="07 Minicharts"
string mc_s1=input.symbol("OANDA:XAGUSD","Symbol 1",group=g07)
string mc_s2=input.symbol("TVC:DXY","Symbol 2",group=g07)
string mc_s3=input.symbol("COMEX:GC1!","Symbol 3",group=g07)
int    mc_nb=input.int(50,"Bars",minval=10,maxval=100,group=g07)
string mc_pos=input.string("Bottom Right","Position",options=["Bottom Left","Bottom Right","Top Left","Top Right"],group=g07)
int    mc_w=input.int(3,"Bar Width",minval=1,maxval=5,group=g07)
bool   mc_ema=input.bool(true,"Show EMA",group=g07)
int    mc_emaL=input.int(20,"EMA Length",minval=5,group=g07)

// Mini data via request.security
[mc_c1,mc_o1,mc_h1,mc_l1]=request.security(mc_s1,timeframe.period,[close,open,high,low])
[mc_c2,mc_o2,mc_h2,mc_l2]=request.security(mc_s2,timeframe.period,[close,open,high,low])
[mc_c3,mc_o3,mc_h3,mc_l3]=request.security(mc_s3,timeframe.period,[close,open,high,low])

// Position mapping
mc_posP() =>
    switch mc_pos
        "Bottom Left" => position.bottom_left
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        => position.bottom_right

// Render minichart tables (simplified for toolkit integration)
var table mc_tbl = table.new(position.bottom_right, mc_nb + 2, 9, bgcolor=P_PBG, border_width=0)

if M07 and barstate.islast
    table.clear(mc_tbl, 0, 0, mc_nb + 1, 8)
    // Symbol headers
    string[] syms = array.from(mc_s1, mc_s2, mc_s3)
    float[] closes = array.from(mc_c1, mc_c2, mc_c3)
    float[] opens = array.from(mc_o1, mc_o2, mc_o3)

    for s = 0 to 2
        int row = s * 3
        string nm = syms.get(s)
        float cl = closes.get(s)
        float op = opens.get(s)
        bool up = cl >= op
        color hCol = up ? P_BU : P_BE
        table.cell(mc_tbl, 0, row, nm, text_color=P_GO, bgcolor=P_SEP, text_size=size.tiny, text_halign=text.align_left)
        table.cell(mc_tbl, 1, row, not na(cl)?str.tostring(cl,"#.##"):"—", text_color=hCol, bgcolor=P_SEP, text_size=size.tiny, text_halign=text.align_right)

        // Bar display rows (simplified: show recent candle colors as blocks)
        int barsToShow = math.min(mc_nb, 30)
        for b = 0 to barsToShow - 1
            float cB = s==0?mc_c1[b]:s==1?mc_c2[b]:mc_c3[b]
            float oB = s==0?mc_o1[b]:s==1?mc_o2[b]:mc_o3[b]
            if not na(cB) and not na(oB)
                bool bUp = cB >= oB
                table.cell(mc_tbl, b + 2, row + 1, "│", text_color=bUp?P_BU:P_BE, bgcolor=P_PBG, text_size=size.small)

        // EMA overlay indicator (BLUEPRINT ❌)
        if mc_ema
            float eV = s==0?ta.ema(mc_c1,mc_emaL):s==1?ta.ema(mc_c2,mc_emaL):ta.ema(mc_c3,mc_emaL)
            bool aboveEma = not na(cl) and not na(eV) and cl > eV
            table.cell(mc_tbl, 0, row + 2, "EMA"+str.tostring(mc_emaL), text_color=P_DM, bgcolor=P_ROW, text_size=size.tiny, text_halign=text.align_left)
            table.cell(mc_tbl, 1, row + 2, aboveEma?"Above":"Below", text_color=aboveEma?P_GN:P_RD, bgcolor=P_ROW, text_size=size.tiny, text_halign=text.align_right)

// SMT detection (BLUEPRINT ❌)
bool mc_smt1 = not na(mc_c1) and not na(mc_c1[1]) and ((close > close[1] and mc_c1 < mc_c1[1]) or (close < close[1] and mc_c1 > mc_c1[1]))
bool mc_smt2 = not na(mc_c3) and not na(mc_c3[1]) and ((close > close[1] and mc_c3 < mc_c3[1]) or (close < close[1] and mc_c3 > mc_c3[1]))
plotshape(M07 and mc_smt1, "SMT1", shape.diamond, location.bottom, color.new(P_GO,30), size=size.tiny, display=display.none)
plotshape(M07 and mc_smt2, "SMT2", shape.diamond, location.top, color.new(P_GO,30), size=size.tiny, display=display.none)

// ═══════════════ 10: S/R ZONES (FULL) ═══════════════
// Concept: Cluster pivot points into support/resistance zones with
// volume-weighted scoring, break/touch tracking, retest detection,
// and zone lifecycle management.

string g10 = "10 S/R Zones"
string sr_pre = input.string("Swing", "Preset", options = ["Scalp", "Local", "Swing", "Major"], group = g10)
int sr_zn = input.int(6, "Max Zones/Side", minval = 1, maxval = 8, group = g10)
int sr_mt = input.int(2, "Min Touches", minval = 2, maxval = 10, group = g10)
int sr_op = input.int(82, "Zone Opacity", minval = 60, maxval = 95, group = g10)
int sr_fd = input.int(300, "Fade Age (bars)", minval = 0, maxval = 2000, group = g10)
bool sr_showBrk = input.bool(true, "Show Broken Zones", group = g10)
bool sr_showTest = input.bool(true, "Show Test Signals", group = g10)
bool sr_showRetest = input.bool(true, "Show Retest Signals", group = g10)
int sr_rtWin = input.int(30, "Retest Window", minval = 5, maxval = 100, group = g10)
int sr_cd = input.int(5, "Signal Cooldown", minval = 0, group = g10)
bool sr_showLbl = input.bool(true, "Show Labels", group = g10)
bool sr_showStats = input.bool(true, "Show Stats", group = g10)

// Preset params
int sr_pL = sr_pre == "Scalp" ? 4 : sr_pre == "Local" ? 6 : sr_pre == "Swing" ? 15 : 35
int sr_pR = sr_pre == "Scalp" ? 2 : sr_pre == "Local" ? 4 : sr_pre == "Swing" ? 8 : 15
float sr_tol = sr_pre == "Scalp" ? 0.4 : sr_pre == "Local" ? 0.5 : sr_pre == "Swing" ? 0.9 : 1.4
int sr_minSp = sr_pre == "Scalp" ? 4 : sr_pre == "Local" ? 8 : sr_pre == "Swing" ? 20 : 50

// Type definitions
type SRPivot
    float price
    int bar
    float vol
    float wick
    string sess

type SRZone
    float top
    float bot
    float center
    float strength
    float volSum
    int touches
    int firstBar
    int lastTouch
    int diedBar
    bool isRes
    bool wasBroken
    bool isLiveBreak
    bool hasPsych

// Core data
float sr_atr = ta.atr(50)
float sr_vma = ta.sma(volume, 50)
float sr_ph = ta.pivothigh(high, sr_pL, sr_pR)
float sr_pl = ta.pivotlow(low, sr_pL, sr_pR)

// Pivot weight function
sr_pivWt(SRPivot p) =>
    float age = math.max(1, bar_index - p.bar)
    float decay = 1.0 / (1.0 + age / 200.0)
    float vw = sr_vma > 0 and p.vol > 0 ? p.vol / sr_vma : 1.0
    float wk = sr_atr > 0 ? p.wick / sr_atr : 0.0
    decay * (1.0 + math.min(vw, 3.0) * 0.5 + math.min(wk, 2.0) * 0.3)

// Psych check for zone
sr_zonePsy(float t, float b) =>
    if not GP
        false
    else
        float p50 = math.ceil(b / 50) * 50
        p50 >= b and p50 <= t

// Pivot buffers
var array<SRPivot> sr_hPivs = array.new<SRPivot>()
var array<SRPivot> sr_lPivs = array.new<SRPivot>()

bool sr_newH = false
bool sr_newL = false
if not na(sr_ph) and sr_ph > 0 and not na(sr_atr) and sr_atr > 0
    float wk = high[sr_pR] - math.max(open[sr_pR], close[sr_pR])
    float vol = nz(volume[sr_pR], 1)
    sr_hPivs.push(SRPivot.new(sr_ph, bar_index - sr_pR, vol, wk, snm()))
    if sr_hPivs.size() > 80
        sr_hPivs.shift()
    sr_newH := true

if not na(sr_pl) and sr_pl > 0 and not na(sr_atr) and sr_atr > 0
    float wk = math.min(open[sr_pR], close[sr_pR]) - low[sr_pR]
    float vol = nz(volume[sr_pR], 1)
    sr_lPivs.push(SRPivot.new(sr_pl, bar_index - sr_pR, vol, wk, snm()))
    if sr_lPivs.size() > 80
        sr_lPivs.shift()
    sr_newL := true

// Build zones from pivot array
sr_buildZones(array<SRPivot> src, bool isRes) =>
    out = array.new<SRZone>()
    if src.size() >= sr_mt and sr_atr > 0
        bool[] used = array.new<bool>(src.size(), false)
        float tolP = sr_atr * sr_tol
        for i = 0 to src.size() - 1
            if not used.get(i)
                SRPivot seed = src.get(i)
                array<SRPivot> members = array.new<SRPivot>()
                members.push(seed)
                used.set(i, true)
                if i + 1 <= src.size() - 1
                    for j = i + 1 to src.size() - 1
                        if not used.get(j)
                            SRPivot cand = src.get(j)
                            if math.abs(cand.price - seed.price) <= tolP
                                bool farOk = true
                                if sr_minSp > 0
                                    for k = 0 to members.size() - 1
                                        if math.abs(cand.bar - members.get(k).bar) < sr_minSp
                                            farOk := false
                                            break
                                if farOk
                                    members.push(cand)
                                    used.set(j, true)
                if members.size() >= sr_mt
                    float pSum = 0.0
                    float wSum = 0.0
                    float vSum = 0.0
                    int earliest = members.get(0).bar
                    int latest = members.get(0).bar
                    for k = 0 to members.size() - 1
                        SRPivot m = members.get(k)
                        float w = sr_pivWt(m)
                        pSum += m.price * w
                        wSum += w
                        vSum += nz(m.vol)
                        earliest := math.min(earliest, m.bar)
                        latest := math.max(latest, m.bar)
                    if wSum > 0
                        float ctr = pSum / wSum
                        float pad = sr_atr * 0.25
                        bool hp = sr_zonePsy(ctr + pad, ctr - pad)
                        out.push(SRZone.new(ctr + pad, ctr - pad, ctr, wSum, vSum, members.size(), earliest, latest, na, isRes, false, false, hp))
    out

// Trim to top N by strength
sr_topN(array<SRZone> zones, int keep) =>
    result = array.new<SRZone>()
    if zones.size() > 0
        copy = zones.copy()
        int limit = math.min(keep, copy.size())
        for i = 0 to limit - 1
            if copy.size() == 0
                break
            int bestIdx = 0
            float bestVal = copy.get(0).strength
            if copy.size() > 1
                for j = 1 to copy.size() - 1
                    if copy.get(j).strength > bestVal
                        bestVal := copy.get(j).strength
                        bestIdx := j
            result.push(copy.get(bestIdx))
            copy.remove(bestIdx)
    result

// Zone state
var array<SRZone> sr_resZ = array.new<SRZone>()
var array<SRZone> sr_supZ = array.new<SRZone>()
var array<SRZone> sr_brkZ = array.new<SRZone>()

// Break detection
if sr_resZ.size() > 0
    for i = 0 to sr_resZ.size() - 1
        SRZone z = sr_resZ.get(i)
        if na(z.diedBar) and close > z.top
            z.diedBar := bar_index
            z.wasBroken := true
            z.isLiveBreak := close[1] <= z.top
            sr_resZ.set(i, z)
            sr_brkZ.push(z)
            if sr_brkZ.size() > 100
                sr_brkZ.shift()

if sr_supZ.size() > 0
    for i = 0 to sr_supZ.size() - 1
        SRZone z = sr_supZ.get(i)
        if na(z.diedBar) and close < z.bot
            z.diedBar := bar_index
            z.wasBroken := true
            z.isLiveBreak := close[1] >= z.bot
            sr_supZ.set(i, z)
            sr_brkZ.push(z)
            if sr_brkZ.size() > 100
                sr_brkZ.shift()

// Touch tracking
if sr_resZ.size() > 0
    for i = 0 to sr_resZ.size() - 1
        SRZone z = sr_resZ.get(i)
        if na(z.diedBar) and high >= z.bot and low <= z.top
            z.lastTouch := bar_index
            sr_resZ.set(i, z)

if sr_supZ.size() > 0
    for i = 0 to sr_supZ.size() - 1
        SRZone z = sr_supZ.get(i)
        if na(z.diedBar) and high >= z.bot and low <= z.top
            z.lastTouch := bar_index
            sr_supZ.set(i, z)

// Recluster on new pivots
if sr_newH or sr_newL
    newRes = sr_topN(sr_buildZones(sr_hPivs, true), sr_zn)
    newSup = sr_topN(sr_buildZones(sr_lPivs, false), sr_zn)
    sr_resZ := newRes
    sr_supZ := newSup

// Signal cooldown
var float[] sr_sigHist = array.new<float>()
sr_cdOk(float center) =>
    if sr_cd <= 0
        true
    else
        bool ok = true
        if sr_sigHist.size() > 0
            for i = sr_sigHist.size() - 1 to math.max(0, sr_sigHist.size() - 10)
                if math.abs(sr_sigHist.get(i) - center) < sr_atr * 0.3
                    ok := false
                    break
        ok

sr_recSig(float center) =>
    sr_sigHist.push(center)
    if sr_sigHist.size() > 50
        sr_sigHist.shift()

// Signal detection - Support bounce
bool sr_bounceUp = false
if M10 and sr_supZ.size() > 0
    for i = 0 to sr_supZ.size() - 1
        SRZone z = sr_supZ.get(i)
        if na(z.diedBar) and low <= z.top and close >= z.bot and close >= open
            if sr_cdOk(z.center) and sok()
                sr_recSig(z.center)
                sr_bounceUp := true
                sB := true
                sBP := z.hasPsych
                sSrc := "S/R"
                break

// Signal detection - Resistance reject
bool sr_rejectDn = false
if M10 and sr_resZ.size() > 0
    for i = 0 to sr_resZ.size() - 1
        SRZone z = sr_resZ.get(i)
        if na(z.diedBar) and high >= z.bot and close <= z.top and close <= open
            if sr_cdOk(z.center) and sok()
                sr_recSig(z.center)
                sr_rejectDn := true
                sS := true
                sSP := z.hasPsych
                sSrc := "S/R"
                break

// Retest detection
bool sr_retestBull = false
bool sr_retestBear = false
if M10 and sr_showRetest and sr_brkZ.size() > 0
    for i = sr_brkZ.size() - 1 to math.max(0, sr_brkZ.size() - 20)
        SRZone z = sr_brkZ.get(i)
        if z.isRes and z.wasBroken and not na(z.diedBar)
            if bar_index - z.diedBar > 0 and bar_index - z.diedBar <= sr_rtWin
                if low <= z.top and close >= z.bot and close >= open
                    sr_retestBull := true
                    break
        if not z.isRes and z.wasBroken and not na(z.diedBar)
            if bar_index - z.diedBar > 0 and bar_index - z.diedBar <= sr_rtWin
                if high >= z.bot and close <= z.top and close <= open
                    sr_retestBear := true
                    break

// Plot signals
plotshape(M10 and sr_showTest and sr_bounceUp, "SupTest", shape.circle, location.belowbar, color.new(P_BU, 0), size = size.tiny, display=display.none)
plotshape(M10 and sr_showTest and sr_rejectDn, "ResTest", shape.circle, location.abovebar, color.new(P_BE, 0), size = size.tiny, display=display.none)
plotshape(M10 and sr_showRetest and sr_retestBull, "RetB", shape.diamond, location.belowbar, color.new(P_BU, 0), size = size.tiny, display=display.none)
plotshape(M10 and sr_showRetest and sr_retestBear, "RetS", shape.diamond, location.abovebar, color.new(P_BE, 0), size = size.tiny, display=display.none)

// Drawing
var array<box> sr_bxBuf = array.new<box>()
var array<line> sr_lnBuf = array.new<line>()
var array<label> sr_lbBuf = array.new<label>()

sr_ageFade(int lt) =>
    sr_fd <= 0 ? 0 : math.min(15, int(math.max(0, bar_index - lt) * 15.0 / sr_fd))

sr_stars(float s, float mx) =>
    float r = mx > 0 ? s / mx : 0.0
    r >= 0.85 ? "★★★" : r >= 0.55 ? "★★" : "★"

if M10 and barstate.islast
    // Clear
    for b in sr_bxBuf
        b.delete()
    sr_bxBuf.clear()
    for l in sr_lnBuf
        l.delete()
    sr_lnBuf.clear()
    for l in sr_lbBuf
        l.delete()
    sr_lbBuf.clear()

    // Max strength for star rating
    float mx = 0.0
    if sr_resZ.size() > 0
        for i = 0 to sr_resZ.size() - 1
            if na(sr_resZ.get(i).diedBar)
                mx := math.max(mx, sr_resZ.get(i).strength)
    if sr_supZ.size() > 0
        for i = 0 to sr_supZ.size() - 1
            if na(sr_supZ.get(i).diedBar)
                mx := math.max(mx, sr_supZ.get(i).strength)

    // Draw alive resistance zones
    if sr_resZ.size() > 0
        for i = 0 to sr_resZ.size() - 1
            SRZone z = sr_resZ.get(i)
            if na(z.diedBar)
                int extra = sr_ageFade(z.lastTouch)
                color zc = z.hasPsych ? P_GO : P_BE
                int fillOp = math.max(40, math.min(95, sr_op + extra))
                sr_bxBuf.push(box.new(z.firstBar, z.top, bar_index + 25, z.bot, border_color = z.hasPsych ? color.new(P_GO, 60) : na, bgcolor = color.new(zc, fillOp)))
                sr_lnBuf.push(line.new(z.firstBar, z.center, bar_index + 25, z.center, color = color.new(zc, 35 + extra), style = line.style_dashed, width = 1))
                if sr_showLbl
                    string txt = sr_stars(z.strength, mx) + "  " + str.tostring(z.touches) + "×" + (z.hasPsych ? "  ★" : "")
                    sr_lbBuf.push(label.new(bar_index + 25, z.center, txt, style = label.style_label_left, color = color.new(zc, 75), textcolor = chart.fg_color, size = size.small))

    // Draw alive support zones
    if sr_supZ.size() > 0
        for i = 0 to sr_supZ.size() - 1
            SRZone z = sr_supZ.get(i)
            if na(z.diedBar)
                int extra = sr_ageFade(z.lastTouch)
                color zc = z.hasPsych ? P_GO : P_BU
                int fillOp = math.max(40, math.min(95, sr_op + extra))
                sr_bxBuf.push(box.new(z.firstBar, z.top, bar_index + 25, z.bot, border_color = z.hasPsych ? color.new(P_GO, 60) : na, bgcolor = color.new(zc, fillOp)))
                sr_lnBuf.push(line.new(z.firstBar, z.center, bar_index + 25, z.center, color = color.new(zc, 35 + extra), style = line.style_dashed, width = 1))
                if sr_showLbl
                    string txt = sr_stars(z.strength, mx) + "  " + str.tostring(z.touches) + "×" + (z.hasPsych ? "  ★" : "")
                    sr_lbBuf.push(label.new(bar_index + 25, z.center, txt, style = label.style_label_left, color = color.new(zc, 75), textcolor = chart.fg_color, size = size.small))

    // Draw broken zones (ghost)
    if sr_showBrk and sr_brkZ.size() > 0
        for i = sr_brkZ.size() - 1 to math.max(0, sr_brkZ.size() - 10)
            SRZone z = sr_brkZ.get(i)
            if z.wasBroken
                int endBar = na(z.diedBar) ? bar_index : z.diedBar
                sr_bxBuf.push(box.new(z.firstBar, z.top, endBar, z.bot, border_color = na, bgcolor = color.new(P_DM, 90)))
                sr_lnBuf.push(line.new(z.firstBar, z.center, endBar, z.center, color = color.new(P_DM, 92), style = line.style_dashed, width = 1))

// Stats mini-table
var table sr_tbl = table.new(position.bottom_left, 2, 4, bgcolor = P_PBG, border_width = 0)
if M10 and sr_showStats and barstate.islast
    table.clear(sr_tbl, 0, 0, 1, 3)
    int aRes = 0
    int aSup = 0
    int psyN = 0
    if sr_resZ.size() > 0
        for i = 0 to sr_resZ.size() - 1
            if na(sr_resZ.get(i).diedBar)
                aRes += 1
                if sr_resZ.get(i).hasPsych
                    psyN += 1
    if sr_supZ.size() > 0
        for i = 0 to sr_supZ.size() - 1
            if na(sr_supZ.get(i).diedBar)
                aSup += 1
                if sr_supZ.get(i).hasPsych
                    psyN += 1
    table.cell(sr_tbl, 0, 0, "S/R ZONES", text_color = P_GO, bgcolor = P_SEP, text_size = size.tiny, text_halign = text.align_left)
    table.cell(sr_tbl, 1, 0, sr_pre, text_color = P_DM, bgcolor = P_SEP, text_size = size.tiny, text_halign = text.align_right)
    table.cell(sr_tbl, 0, 1, "Resistance", text_color = P_BE, bgcolor = P_ROW, text_size = size.tiny, text_halign = text.align_left)
    table.cell(sr_tbl, 1, 1, str.tostring(aRes), text_color = P_BE, bgcolor = P_ROW, text_size = size.tiny, text_halign = text.align_right)
    table.cell(sr_tbl, 0, 2, "Support", text_color = P_BU, bgcolor = P_PBG, text_size = size.tiny, text_halign = text.align_left)
    table.cell(sr_tbl, 1, 2, str.tostring(aSup), text_color = P_BU, bgcolor = P_PBG, text_size = size.tiny, text_halign = text.align_right)
    table.cell(sr_tbl, 0, 3, "Psych", text_color = P_GO, bgcolor = P_ROW, text_size = size.tiny, text_halign = text.align_left)
    table.cell(sr_tbl, 1, 3, str.tostring(psyN) + " ★", text_color = P_GO, bgcolor = P_ROW, text_size = size.tiny, text_halign = text.align_right)


// ═══════════════ 13: SESSION RANGE (FULL) ═══════════════
// Concept: Gold exhibits distinct patterns across Asia/London/NY sessions.
// Tracks each session's OHLC, draws candle panel, 25% levels, H/M/L/O lines,
// regime analysis, statistics table, and Gold-specific alerts.

// --- Input Groups ---
string g13s = "13 Setup"
string g13a = "13 Asia"
string g13l = "13 London"
string g13n = "13 NY"
string g13c = "13 Candle Panel"
string g13t = "13 Stats Table"
string g13x = "13 Alerts"

// --- Setup ---
bool sc_show_candles = input.bool(true, "Show Session Candle Panel", group = g13s)
bool sc_show_lines = input.bool(true, "Show Chart Lines", group = g13s)

// --- Asia Inputs ---
bool sc_a_enabled = input.bool(true, "Show Asia Candle", group = g13a)
bool sc_a_vline = input.bool(true, "Session Open Line", group = g13a)
bool sc_a_hml = input.bool(true, "H/M/L/O Lines", group = g13a)
bool sc_a_hml_h = input.bool(true, "  High", group = g13a)
bool sc_a_hml_m = input.bool(true, "  Mid", group = g13a)
bool sc_a_hml_l = input.bool(true, "  Low", group = g13a)
bool sc_a_hml_o = input.bool(true, "  Open", group = g13a)
bool sc_a_25 = input.bool(true, "25% Line", group = g13a)

// --- London Inputs ---
bool sc_l_enabled = input.bool(true, "Show London Candle", group = g13l)
bool sc_l_vline = input.bool(true, "Session Open Line", group = g13l)
bool sc_l_hml = input.bool(true, "H/M/L/O Lines", group = g13l)
bool sc_l_hml_h = input.bool(true, "  High", group = g13l)
bool sc_l_hml_m = input.bool(true, "  Mid", group = g13l)
bool sc_l_hml_l = input.bool(true, "  Low", group = g13l)
bool sc_l_hml_o = input.bool(true, "  Open", group = g13l)
bool sc_l_25 = input.bool(true, "25% Line", group = g13l)
bool sc_l_fix = input.bool(true, "London Fix Line (15:00 GMT)", group = g13l)

// --- NY Inputs ---
bool sc_n_enabled = input.bool(true, "Show NY Candle", group = g13n)
bool sc_n_vline = input.bool(true, "Session Open Line", group = g13n)

// --- Candle Panel Inputs ---
int sc_offset = input.int(5, "Offset (bars)", minval = 1, group = g13c)
int sc_width = input.int(4, "Candle Width", minval = 1, maxval = 20, group = g13c)
int sc_spacing = input.int(4, "Spacing", minval = 1, maxval = 10, group = g13c)
int sc_btransp = input.int(80, "Body Transparency", minval = 0, maxval = 100, group = g13c)
bool sc_showwick = input.bool(true, "Show Wicks", group = g13c)
bool sc_showhl = input.bool(true, "Show H/L Labels", group = g13c)
bool sc_show25c = input.bool(true, "Show 25% Tick on Candle", group = g13c)

// --- Stats Table Inputs ---
int sc_stlb = input.int(252, "Lookback (sessions)", minval = 10, maxval = 2000, group = g13t)
string sc_stpos = input.string("Bottom Right", "Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group = g13t)

// --- Alert Inputs ---
bool sc_alrt_reg = input.bool(true, "Alert: Regime Confirmed", group = g13x)
bool sc_alrt_25 = input.bool(true, "Alert: NY Touches London 25%", group = g13x)
bool sc_alrt_lh = input.bool(true, "Alert: London High Taken", group = g13x)
bool sc_alrt_ll = input.bool(true, "Alert: London Low Taken", group = g13x)
bool sc_alrt_psy = input.bool(true, "Alert: Psych Confluence", group = g13x)

// --- Helpers ---
sc_lstyle(string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

sc_25level(float o, float c) =>
    float bt = math.max(o, c)
    float bb = math.min(o, c)
    float br = bt - bb
    c >= o ? bt - br * 0.25 : bb + br * 0.25

sc_nearest_psych(float price, int step) =>
    math.round(price / step) * step

sc_has_confluence(float level, float price, int step, float dist) =>
    float nearest = sc_nearest_psych(price, step)
    math.abs(level - nearest) <= dist

sc_pips(float val) =>
    syminfo.mintick > 0 ? val / syminfo.mintick : val

// --- Session OHLC Tracking (live) ---
var float sc_ao = na
var float sc_ah = na
var float sc_al = na
var float sc_ac = na
var int sc_asb = na

var float sc_lo = na
var float sc_lh = na
var float sc_ll = na
var float sc_lc = na
var int sc_lsb = na

var float sc_no = na
var float sc_nh = na
var float sc_nl = na
var float sc_nc = na
var int sc_nsb = na

if _iA > _iA[1]
    sc_ao := open
    sc_ah := high
    sc_al := low
    sc_ac := close
    sc_asb := bar_index
else if _iA > 0
    sc_ah := math.max(sc_ah, high)
    sc_al := math.min(sc_al, low)
    sc_ac := close

if _iL > _iL[1]
    sc_lo := open
    sc_lh := high
    sc_ll := low
    sc_lc := close
    sc_lsb := bar_index
else if _iL > 0
    sc_lh := math.max(sc_lh, high)
    sc_ll := math.min(sc_ll, low)
    sc_lc := close

if _iN > _iN[1]
    sc_no := open
    sc_nh := high
    sc_nl := low
    sc_nc := close
    sc_nsb := bar_index
else if _iN > 0
    sc_nh := math.max(sc_nh, high)
    sc_nl := math.min(sc_nl, low)
    sc_nc := close

// --- Completed Session Snapshots ---
var float sc_pao = na
var float sc_pah = na
var float sc_pal = na
var float sc_pac = na
var int sc_pasb = na

var float sc_plo = na
var float sc_plh = na
var float sc_pll = na
var float sc_plc = na
var int sc_plsb = na

var float sc_pno = na
var float sc_pnh = na
var float sc_pnl = na
var float sc_pnc = na
var int sc_pnsb = na

// Regime tracking
var float sc_reg_ah = na
var float sc_reg_al = na
var float sc_reg_lh = na
var float sc_reg_ll = na
var float sc_pend_ah = na
var float sc_pend_al = na

// Asia sweep flags
var bool sc_asia_h_swept = false
var bool sc_asia_l_swept = false

if _iL > _iL[1] and not na(sc_ao)
    sc_pao := sc_ao
    sc_pah := sc_ah
    sc_pal := sc_al
    sc_pac := sc_ac
    sc_pasb := sc_asb
    sc_pend_ah := sc_ah
    sc_pend_al := sc_al

if _iN > _iN[1] and not na(sc_lo)
    sc_plo := sc_lo
    sc_plh := sc_lh
    sc_pll := sc_ll
    sc_plc := sc_lc
    sc_plsb := sc_lsb
    if not na(sc_pend_ah)
        sc_reg_ah := sc_pend_ah
        sc_reg_al := sc_pend_al
        sc_reg_lh := sc_lh
        sc_reg_ll := sc_ll
    sc_asia_h_swept := not na(sc_pend_ah) and sc_lh > sc_pend_ah
    sc_asia_l_swept := not na(sc_pend_al) and sc_ll < sc_pend_al

if _iN[1] > 0 and _iN == 0 and not na(sc_no)
    sc_pno := sc_no
    sc_pnh := sc_nh
    sc_pnl := sc_nl
    sc_pnc := sc_nc
    sc_pnsb := sc_nsb

// --- Regime Analysis ---
sc_regime(float ah, float al, float lh, float ll) =>
    if na(ah) or na(al) or na(lh) or na(ll)
        "—"
    else
        bool lon_above_asia = lh > ah and ll > al
        bool lon_below_asia = lh < ah and ll < al
        bool lon_engulfs = lh > ah and ll < al
        bool asia_inside = ah < lh and al > ll
        lon_engulfs ? "Expansion" : lon_above_asia ? "Bull Trend" : lon_below_asia ? "Bear Trend" : asia_inside ? "Asia Inside" : "Range"

var bool sc_regime_confirmed = false
var string sc_regime_type = "—"
if _iN > _iN[1] and not na(sc_reg_ah)
    sc_regime_type := sc_regime(sc_reg_ah, sc_reg_al, sc_reg_lh, sc_reg_ll)
    sc_regime_confirmed := sc_regime_type != "—"

// --- London High/Low Taken by NY ---
var bool sc_lon_h_taken = false
var bool sc_lon_l_taken = false
var bool sc_lon_h_taken_now = false
var bool sc_lon_l_taken_now = false
sc_lon_h_taken_now := false
sc_lon_l_taken_now := false

if _iN > 0 and not na(sc_plh)
    if high > sc_plh and not sc_lon_h_taken
        sc_lon_h_taken := true
        sc_lon_h_taken_now := true
    if low < sc_pll and not sc_lon_l_taken
        sc_lon_l_taken := true
        sc_lon_l_taken_now := true

if _iN > _iN[1]
    sc_lon_h_taken := false
    sc_lon_l_taken := false

// --- NY Touches London 25% Detection ---
var bool sc_touched_25 = false
var bool sc_touched_25_now = false
sc_touched_25_now := false

float sc_lon25 = not na(sc_plo) and not na(sc_plc) ? sc_25level(sc_plo, sc_plc) : na
if _iN > 0 and not na(sc_lon25) and not sc_touched_25
    if math.abs(close - sc_lon25) <= ATR14 * 0.15
        sc_touched_25 := true
        sc_touched_25_now := true

if _iN > _iN[1]
    sc_touched_25 := false

// --- Psych Confluence Detection ---
var bool sc_psych_confl_now = false
sc_psych_confl_now := false
if not na(sc_lon25) and GP
    if sc_has_confluence(sc_lon25, sc_lon25, GPI, 5.0)
        sc_psych_confl_now := true

// --- Drawing Handles ---
// 25% handles
// H/M/L/O handles - Asia
// H/M/L/O handles - London
// Session open vertical lines
// London Fix
var line sc_lfix = na
var label sc_lfix_lb = na

// --- Draw Helper: Session Candle + Lines ---
sc_draw_sess(float o, float h, float l, float c, int sbar,
     int x1, int x2, int lbl_x,
     bool enabled, string sess_name, color sess_col,
     bool do_25, bool do_hml,
     bool sh_h, bool sh_m, bool sh_l, bool sh_o) =>
    box bx_r = na
    line wk_u = na
    line wk_d = na
    label lb_h = na
    label lb_l = na
    label lb_n = na
    line l25c = na
    label l25lc = na
    line l25p = na
    label l25lp = na
    line lH = na
    line lM = na
    line lL = na
    line lO = na
    label lbH = na
    label lbM = na
    label lbL = na
    label lbO = na

    if enabled and not na(o)
        float bt = math.max(o, c)
        float bb = math.min(o, c)
        float br = bt - bb
        bool bull = c >= o
        int xm = math.round((x1 + x2) / 2)
        int cur = bar_index

        if sc_show_candles
            bx_r := box.new(x1, bt, x2, bb, bgcolor = color.new(sess_col, sc_btransp), border_color = sess_col, border_width = 1)
            if sc_showwick
                if h > bt
                    wk_u := line.new(xm, bt, xm, h, color = sess_col, width = 1)
                if l < bb
                    wk_d := line.new(xm, bb, xm, l, color = sess_col, width = 1)
            if sc_showhl
                lb_h := label.new(xm, h, str.tostring(math.round(h, 2)), style = label.style_none, textcolor = sess_col, size = size.tiny, text_font_family = font.family_monospace)
                lb_l := label.new(xm, l, str.tostring(math.round(l, 2)), style = label.style_none, textcolor = sess_col, size = size.tiny, text_font_family = font.family_monospace)
            lb_n := label.new(xm, h, sess_name, style = label.style_label_down, color = color.new(sess_col, 90), textcolor = sess_col, size = size.tiny)

        if br > 0 and sc_show_lines
            float lv25 = bull ? bt - br * 0.25 : bb + br * 0.25
            // 25% tick on candle
            if sc_show25c and do_25 and sc_show_candles
                int tick_end = x2 + sc_spacing
                l25c := line.new(x2, lv25, tick_end, lv25, color = sess_col, width = 1)
                l25lc := label.new(tick_end + 1, lv25, "25%", style = label.style_none, textcolor = sess_col, size = size.tiny)
            // 25% on chart
            if do_25 and not na(sbar)
                l25p := line.new(sbar, lv25, cur, lv25, color = sess_col, style = line.style_solid, width = 1)
                l25lp := label.new(lbl_x, lv25, sess_name + " 25%", style = label.style_none, textcolor = sess_col, size = size.tiny)

        // H/M/L/O lines on chart
        if do_hml and not na(sbar) and sc_show_lines
            float mid = (h + l) / 2
            color hml_col = color.new(sess_col, 30)
            if sh_h
                lH := line.new(sbar, h, cur, h, color = hml_col, style = line.style_dotted, width = 1)
                lbH := label.new(lbl_x, h, sess_name + " High", style = label.style_none, textcolor = hml_col, size = size.tiny)
            if sh_m
                lM := line.new(sbar, mid, cur, mid, color = hml_col, style = line.style_dotted, width = 1)
                lbM := label.new(lbl_x, mid, sess_name + " Mid", style = label.style_none, textcolor = hml_col, size = size.tiny)
            if sh_l
                lL := line.new(sbar, l, cur, l, color = hml_col, style = line.style_dotted, width = 1)
                lbL := label.new(lbl_x, l, sess_name + " Low", style = label.style_none, textcolor = hml_col, size = size.tiny)
            if sh_o
                lO := line.new(sbar, o, cur, o, color = hml_col, style = line.style_dotted, width = 1)
                lbO := label.new(lbl_x, o, sess_name + " Open", style = label.style_none, textcolor = hml_col, size = size.tiny)

    [bx_r, wk_u, wk_d, lb_h, lb_l, lb_n, l25c, l25lc, l25p, l25lp, lH, lM, lL, lO, lbH, lbM, lbL, lbO]

// --- Main Draw (on last bar and realtime) ---
_sc_render() =>
    var box sc_bx_a = na
    var box sc_bx_l = na
    var box sc_bx_n = na
    var line sc_wk_a_u = na
    var line sc_wk_a_d = na
    var line sc_wk_l_u = na
    var line sc_wk_l_d = na
    var line sc_wk_n_u = na
    var line sc_wk_n_d = na
    var label sc_lb_a_h = na
    var label sc_lb_a_l = na
    var label sc_lb_a_n = na
    var label sc_lb_l_h = na
    var label sc_lb_l_l = na
    var label sc_lb_l_n = na
    var label sc_lb_n_h = na
    var label sc_lb_n_l = na
    var label sc_lb_n_n = na
    var line sc_l25_a_c = na
    var label sc_l25_a_lc = na
    var line sc_l25_a_p = na
    var label sc_l25_a_lp = na
    var line sc_l25_l_c = na
    var label sc_l25_l_lc = na
    var line sc_l25_l_p = na
    var label sc_l25_l_lp = na
    var line sc_hml_a_H = na
    var line sc_hml_a_M = na
    var line sc_hml_a_L = na
    var line sc_hml_a_O = na
    var label sc_hml_a_lH = na
    var label sc_hml_a_lM = na
    var label sc_hml_a_lL = na
    var label sc_hml_a_lO = na
    var line sc_hml_l_H = na
    var line sc_hml_l_M = na
    var line sc_hml_l_L = na
    var line sc_hml_l_O = na
    var label sc_hml_l_lH = na
    var label sc_hml_l_lM = na
    var label sc_hml_l_lL = na
    var label sc_hml_l_lO = na
    if barstate.islast or barstate.isrealtime
        // Delete old drawings
        sc_bx_a.delete()
        sc_bx_l.delete()
        sc_bx_n.delete()
        sc_wk_a_u.delete()
        sc_wk_a_d.delete()
        sc_wk_l_u.delete()
        sc_wk_l_d.delete()
        sc_wk_n_u.delete()
        sc_wk_n_d.delete()
        sc_lb_a_h.delete()
        sc_lb_a_l.delete()
        sc_lb_a_n.delete()
        sc_lb_l_h.delete()
        sc_lb_l_l.delete()
        sc_lb_l_n.delete()
        sc_lb_n_h.delete()
        sc_lb_n_l.delete()
        sc_lb_n_n.delete()
        sc_l25_a_c.delete()
        sc_l25_a_lc.delete()
        sc_l25_a_p.delete()
        sc_l25_a_lp.delete()
        sc_l25_l_c.delete()
        sc_l25_l_lc.delete()
        sc_l25_l_p.delete()
        sc_l25_l_lp.delete()
        sc_hml_a_H.delete()
        sc_hml_a_M.delete()
        sc_hml_a_L.delete()
        sc_hml_a_O.delete()
        sc_hml_a_lH.delete()
        sc_hml_a_lM.delete()
        sc_hml_a_lL.delete()
        sc_hml_a_lO.delete()
        sc_hml_l_H.delete()
        sc_hml_l_M.delete()
        sc_hml_l_L.delete()
        sc_hml_l_O.delete()
        sc_hml_l_lH.delete()
        sc_hml_l_lM.delete()
        sc_hml_l_lL.delete()
        sc_hml_l_lO.delete()
        sc_lfix.delete()
        sc_lfix_lb.delete()
    
        // Use live or completed data
        float ao2 = _iA > 0 ? sc_ao : sc_pao
        float ah2 = _iA > 0 ? sc_ah : sc_pah
        float al2 = _iA > 0 ? sc_al : sc_pal
        float ac2 = _iA > 0 ? sc_ac : sc_pac
        int asb2 = _iA > 0 ? sc_asb : sc_pasb
    
        float lo2 = _iL > 0 ? sc_lo : sc_plo
        float lh2 = _iL > 0 ? sc_lh : sc_plh
        float ll2 = _iL > 0 ? sc_ll : sc_pll
        float lc2 = _iL > 0 ? sc_lc : sc_plc
        int lsb2 = _iL > 0 ? sc_lsb : sc_plsb
    
        float no2 = sc_no
        float nh2 = sc_nh
        float nl2 = sc_nl
        float nc2 = sc_nc
        int nsb2 = sc_nsb
    
        int cur = bar_index
        int lbl_x = cur + 3
    
        // Asia candle
        int ax1 = cur + sc_offset
        int ax2 = ax1 + sc_width
        [_a1,_a2,_a3,_a4,_a5,_a6,_a7,_a8,_a9,_a10,_a11,_a12,_a13,_a14,_a15,_a16,_a17,_a18] = sc_draw_sess(ao2, ah2, al2, ac2, asb2, ax1, ax2, lbl_x, sc_a_enabled, "Asia", P_BE, sc_a_25, sc_a_hml, sc_a_hml_h, sc_a_hml_m, sc_a_hml_l, sc_a_hml_o)
        sc_bx_a := _a1
        sc_wk_a_u := _a2
        sc_wk_a_d := _a3
        sc_lb_a_h := _a4
        sc_lb_a_l := _a5
        sc_lb_a_n := _a6
        sc_l25_a_c := _a7
        sc_l25_a_lc := _a8
        sc_l25_a_p := _a9
        sc_l25_a_lp := _a10
        sc_hml_a_H := _a11
        sc_hml_a_M := _a12
        sc_hml_a_L := _a13
        sc_hml_a_O := _a14
        sc_hml_a_lH := _a15
        sc_hml_a_lM := _a16
        sc_hml_a_lL := _a17
        sc_hml_a_lO := _a18
    
        // London candle
        int lx1 = ax2 + sc_spacing
        int lx2 = lx1 + sc_width
        [_l1,_l2,_l3,_l4,_l5,_l6,_l7,_l8,_l9,_l10,_l11,_l12,_l13,_l14,_l15,_l16,_l17,_l18] = sc_draw_sess(lo2, lh2, ll2, lc2, lsb2, lx1, lx2, lbl_x, sc_l_enabled, "London", P_BU, sc_l_25, sc_l_hml, sc_l_hml_h, sc_l_hml_m, sc_l_hml_l, sc_l_hml_o)
        sc_bx_l := _l1
        sc_wk_l_u := _l2
        sc_wk_l_d := _l3
        sc_lb_l_h := _l4
        sc_lb_l_l := _l5
        sc_lb_l_n := _l6
        sc_l25_l_c := _l7
        sc_l25_l_lc := _l8
        sc_l25_l_p := _l9
        sc_l25_l_lp := _l10
        sc_hml_l_H := _l11
        sc_hml_l_M := _l12
        sc_hml_l_L := _l13
        sc_hml_l_O := _l14
        sc_hml_l_lH := _l15
        sc_hml_l_lM := _l16
        sc_hml_l_lL := _l17
        sc_hml_l_lO := _l18
    
        // NY candle
        int nx1 = lx2 + sc_spacing
        int nx2 = nx1 + sc_width
        [_n1,_n2,_n3,_n4,_n5,_n6,_n7,_n8,_n9,_n10,_n11,_n12,_n13,_n14,_n15,_n16,_n17,_n18] = sc_draw_sess(no2, nh2, nl2, nc2, nsb2, nx1, nx2, lbl_x, sc_n_enabled, "NY", P_SK, false, false, false, false, false, false)
        sc_bx_n := _n1
        sc_wk_n_u := _n2
        sc_wk_n_d := _n3
        sc_lb_n_h := _n4
        sc_lb_n_l := _n5
        sc_lb_n_n := _n6
    
    0

if M13
    _sc_render()
// --- Session Open Vertical Lines ---
if M13 and _iA > _iA[1] and sc_a_vline
    sc_vl_a.delete()
    sc_vl_a := line.new(bar_index, high + ATR14, bar_index, low - ATR14, color = color.new(P_BE, 70), style = line.style_solid, width = 1)
    sc_vl_a_lb.delete()
    sc_vl_a_lb := label.new(bar_index, high + ATR14 * 1.2, "Asia", style = label.style_none, textcolor = P_BE, size = size.tiny)

if M13 and _iL > _iL[1] and sc_l_vline
    sc_vl_l.delete()
    sc_vl_l := line.new(bar_index, high + ATR14, bar_index, low - ATR14, color = color.new(P_BU, 70), style = line.style_solid, width = 1)
    sc_vl_l_lb.delete()
    sc_vl_l_lb := label.new(bar_index, high + ATR14 * 1.2, "London", style = label.style_none, textcolor = P_BU, size = size.tiny)

if M13 and _iN > _iN[1] and sc_n_vline
    sc_vl_n.delete()
    sc_vl_n := line.new(bar_index, high + ATR14, bar_index, low - ATR14, color = color.new(P_SK, 70), style = line.style_solid, width = 1)
    sc_vl_n_lb.delete()
    sc_vl_n_lb := label.new(bar_index, high + ATR14 * 1.2, "NY", style = label.style_none, textcolor = P_SK, size = size.tiny)

// --- London Fix Line ---
if M13 and sc_l_fix
    int lfix_t = time("1", "1500-1501:1234567", "GMT")
    if not na(lfix_t) and na(lfix_t[1])
        sc_lfix.delete()
        sc_lfix := line.new(bar_index, high + ATR14, bar_index, low - ATR14, color = color.new(P_GO, 50), style = line.style_solid, width = 1)
        sc_lfix_lb.delete()
        sc_lfix_lb := label.new(bar_index, high + ATR14 * 1.3, "LDN Fix", style = label.style_none, textcolor = P_GO, size = size.tiny)

// --- Stats: History Arrays ---
var float[] sc_st_a_range = array.new<float>()
var float[] sc_st_l_range = array.new<float>()
var float[] sc_st_n_range = array.new<float>()
var float[] sc_st_a_body = array.new<float>()
var float[] sc_st_l_body = array.new<float>()
var float[] sc_st_n_body = array.new<float>()
var int[] sc_st_a_dir = array.new<int>()
var int[] sc_st_l_dir = array.new<int>()
var int[] sc_st_n_dir = array.new<int>()
var string[] sc_st_regimes = array.new<string>()
var bool[] sc_st_25touched = array.new<bool>()
var bool[] sc_st_lonH_taken = array.new<bool>()
var bool[] sc_st_lonL_taken = array.new<bool>()
var bool[] sc_st_asia_h_sw = array.new<bool>()
var bool[] sc_st_asia_l_sw = array.new<bool>()

// Record on session transitions
if _iL > _iL[1] and not na(sc_pao) and not na(sc_pah) and not na(sc_pal)
    float rng = sc_pah - sc_pal
    float bdy = math.abs(sc_pac - sc_pao)
    int dir = sc_pac >= sc_pao ? 1 : -1
    sc_st_a_range.push(rng)
    sc_st_a_body.push(bdy)
    sc_st_a_dir.push(dir)
    if sc_st_a_range.size() > sc_stlb
        sc_st_a_range.shift()
        sc_st_a_body.shift()
        sc_st_a_dir.shift()

if _iN > _iN[1] and not na(sc_plo) and not na(sc_plh) and not na(sc_pll)
    float rng = sc_plh - sc_pll
    float bdy = math.abs(sc_plc - sc_plo)
    int dir = sc_plc >= sc_plo ? 1 : -1
    sc_st_l_range.push(rng)
    sc_st_l_body.push(bdy)
    sc_st_l_dir.push(dir)
    if sc_st_l_range.size() > sc_stlb
        sc_st_l_range.shift()
        sc_st_l_body.shift()
        sc_st_l_dir.shift()
    // Record regime and flags
    sc_st_regimes.push(sc_regime_type)
    sc_st_25touched.push(sc_touched_25)
    sc_st_lonH_taken.push(sc_lon_h_taken)
    sc_st_lonL_taken.push(sc_lon_l_taken)
    sc_st_asia_h_sw.push(sc_asia_h_swept)
    sc_st_asia_l_sw.push(sc_asia_l_swept)
    if sc_st_regimes.size() > sc_stlb
        sc_st_regimes.shift()
        sc_st_25touched.shift()
        sc_st_lonH_taken.shift()
        sc_st_lonL_taken.shift()
        sc_st_asia_h_sw.shift()
        sc_st_asia_l_sw.shift()

if _iA > _iA[1] and not na(sc_pno) and not na(sc_pnh) and not na(sc_pnl)
    float rng = sc_pnh - sc_pnl
    float bdy = math.abs(sc_pnc - sc_pno)
    int dir = sc_pnc >= sc_pno ? 1 : -1
    sc_st_n_range.push(rng)
    sc_st_n_body.push(bdy)
    sc_st_n_dir.push(dir)
    if sc_st_n_range.size() > sc_stlb
        sc_st_n_range.shift()
        sc_st_n_body.shift()
        sc_st_n_dir.shift()

// --- Stats Helper ---
sc_pct(int num, int den) =>
    den > 0 ? math.round(num * 100.0 / den, 1) : 0.0

sc_avg_arr(float[] arr) =>
    arr.size() > 0 ? arr.avg() : 0.0

sc_bull_pct(int[] dirs) =>
    if dirs.size() == 0
        0.0
    else
        int cnt = 0
        for i = 0 to dirs.size() - 1
            if dirs.get(i) > 0
                cnt += 1
        sc_pct(cnt, dirs.size())

sc_flag_pct(bool[] flags) =>
    if flags.size() == 0
        0.0
    else
        int cnt = 0
        for i = 0 to flags.size() - 1
            if flags.get(i)
                cnt += 1
        sc_pct(cnt, flags.size())

// --- Stats Table Rendering ---
sc_tpos(string s) =>
    s == "Top Left" ? position.top_left : s == "Top Right" ? position.top_right : s == "Bottom Left" ? position.bottom_left : position.bottom_right


// ═══════════════ UNIFIED OUTPUT ═══════════════
plotshape(sB and not sBP,"Bull",shape.triangleup,location.belowbar,color.new(P_BU,0), size=size.tiny, display=display.none)
plotshape(sB and sBP,"Bull★",shape.triangleup,location.belowbar,color.new(P_GO,0), size=size.tiny, display=display.none)
plotshape(sS and not sSP,"Bear",shape.triangledown,location.abovebar,color.new(P_BE,0), size=size.tiny, display=display.none)
plotshape(sS and sSP,"Bear★",shape.triangledown,location.abovebar,color.new(P_GO,0), size=size.tiny, display=display.none)

mn()=>M01?"ML Supertrend":M02?"Stop Run":M03?"EMA Inv":M04?"SAR":M05?"ACN":M06?"Arc Mom":M07?"Minicharts":M08?"SwingReg":M09?"ATC":M10?"S/R":M11?"Harmonic":M12?"FVG":M13?"Ses Range":M14?"Inst Vol":M15?"Killzones":M16?"RSI Swing":M17?"OB Zone":M18?"Asym":M19?"Vec SMC":M20?"AlgoPath":M21?"TPO":M22?"VWAP":"None"
var table pnl=table.new(position.top_right,4,14,bgcolor=P_PBG,border_width=0)
var string[] mNm = array.from("ML Supertrend","Stop Run","EMA Inversion","Parabolic SAR","ACN Trend","Arc Momentum","Minicharts","SwingRegress","Anchored Ch.","S/R Zones","Harmonic")
var string[] mNm2 = array.from("FVG Wave","Session Range","Inst Volume","Killzones","RSI Swing","OB Zone","Asymmetric","Vector SMC","AlgoPath","Swing TPO","VWAP")
if GPan and barstate.islast
    table.clear(pnl,0,0,3,13)
    // Header
    table.cell(pnl,0,0,"GOLD TOOLKIT 22",text_color=P_GO,bgcolor=P_SEP,text_size=size.tiny,text_halign=text.align_left)
    table.cell(pnl,1,0,"",bgcolor=P_SEP)
    table.cell(pnl,2,0,snm(),text_color=scl(),bgcolor=P_SEP,text_size=size.tiny,text_halign=text.align_right)
    table.cell(pnl,3,0,dOk?(dUp?"DXY▲":"DXY▼"):"",text_color=dOk?(dUp?P_BE:P_BU):P_DM,bgcolor=P_SEP,text_size=size.tiny,text_halign=text.align_right)
    // Module list - 2 columns × 11 rows
    bool[] mOn = array.from(M01,M02,M03,M04,M05,M06,M07,M08,M09,M10,M11)
    bool[] mOn2 = array.from(M12,M13,M14,M15,M16,M17,M18,M19,M20,M21,M22)
    for i=0 to 10
        color nc=mOn.get(i)?P_GO:color.rgb(60,60,70)
        color nc2=mOn2.get(i)?P_GO:color.rgb(60,60,70)
        color bg=i%2==0?P_PBG:P_ROW
        string num1=(i+1<10?"0":"")+str.tostring(i+1)
        string num2=str.tostring(i+12)
        table.cell(pnl,0,i+1,num1,text_color=nc,bgcolor=bg,text_size=size.tiny,text_halign=text.align_left)
        table.cell(pnl,1,i+1,mNm.get(i),text_color=nc,bgcolor=bg,text_size=size.tiny,text_halign=text.align_left)
        table.cell(pnl,2,i+1,num2,text_color=nc2,bgcolor=bg,text_size=size.tiny,text_halign=text.align_left)
        table.cell(pnl,3,i+1,mNm2.get(i),text_color=nc2,bgcolor=bg,text_size=size.tiny,text_halign=text.align_left)
    // Footer
    table.cell(pnl,0,12,"Daily",text_color=P_DM,bgcolor=P_SEP,text_size=size.tiny,text_halign=text.align_left)
    table.cell(pnl,1,12,"$"+str.tostring(DHI-DLO,"#"),text_color=P_DM,bgcolor=P_SEP,text_size=size.tiny,text_halign=text.align_right)
    table.cell(pnl,2,12,"ATR",text_color=P_DM,bgcolor=P_SEP,text_size=size.tiny,text_halign=text.align_left)
    table.cell(pnl,3,12,"$"+str.tostring(ATRD,"#"),text_color=P_DM,bgcolor=P_SEP,text_size=size.tiny,text_halign=text.align_right)
````
