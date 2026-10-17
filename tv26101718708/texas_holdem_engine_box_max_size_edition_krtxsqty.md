# Texas Hold'em Engine [BOX Max Size Edition]

- url: https://www.tradingview.com/script/KrTXSQTy/
- type: indicator
- pine_id: PUB;786af475bad5441798393f1b92e6d3e1
- version: 5.0

## Description

[b]Texas Hold'em [BOX Max Size Edition][/b]

[b]NOTICE / DISCLAIMER[/b]


This architecture is NOT a mere entertainment tool. It is a highly advanced algorithmic multi-state logic simulation engine disguised as a Texas Hold'em framework, specifically designed to test the computational overhead, state persistence, and localized rendering boundaries of Pine Script v6 under live tick conditions.


[b]EXECUTIVE SUMMARY[/b]


This script is deployed as a Proof of Concept (PoC) to demonstrate the extreme limits of Pine Script v6's array processing, state evaluation capabilities, and localized UI rendering. It functions as a rigorous technical benchmark for developers building institutional-grade algorithmic dashboards directly on TradingView charts. By leveraging box.new() structures, this script successfully bypasses TradingView's native text scaling limits, allowing for massive UI components that seamlessly track price volatility.


[b]SYSTEM USAGE (How-To / Interactive Execution Flow)[/b]


Initialization: Apply the script to a chart. The system automatically initializes a deterministic pseudo-random array shuffle based on the Game Seed.


Phase Progression: The script executes across 6 distinct phases based on the bar index: Dealing, Pre-Flop, Flop, Turn, River, and Showdown.


Player Action Inputs: Using the Settings menu, manually override your decisions (FOLD, CALL/CHECK, RAISE) during the Pre-Flop, Flop, Turn, and River phases.


CPU State Engine: The opposing CPU evaluates the market's volatility via the True Range (ATR). If ta.tr / ta.sma(ta.tr, 14) > 1.5, the CPU assumes an aggressive posture and executes a "RAISE".


Stateful Transaction Engine: As actions are selected, the system calculates blind deductions, raise accumulations, and pot sizes. The var driven memory engine perfectly retains chip stack data across chart ticks and resets seamlessly upon determining a winner via Fold or Showdown.


Evaluation: At the Showdown phase, a localized combinatorics engine processes a 7-card array for both entities, scoring the best 5-card combinations using mathematical rank arrays to determine the victor and award the accumulated pot.


[b]ARCHITECTURE & QUANTITATIVE LOGIC (Technical Specifications)[/b]


Bounding Box Scaling Algorithm (Localized UI Vector Scaling)
Standard label.new() text strings are hard-capped at size.huge (approx. 36px), which fails to scale alongside chart zooming. To override this limitation, vector Unicode strings are injected into a box.new() container. The Y-axis boundaries are mathematically locked to the Average True Range (ATR).
Formula:
Top = Y_Position + (ATR / 2)
Bottom = Y_Position - (ATR / 2)
Calculation Example:
Given an asset trading at Y = 150.00 with an ATR = 2.0.
Top = 150.00 + (2.0 / 2) = 151.00
Bottom = 150.00 - (2.0 / 2) = 149.00


The resulting Y-axis width of the box is strictly 2.0. By enforcing a strict volatility-based bounding box, the text engine is overridden, forcing the Unicode vectors to dynamically scale in perfect proportion to market noise.


[b]Persistent State Memory (Transaction Logic)[/b]


TradingView charts inherently recalculate scripts on every new price tick. To prevent the chip stacks and pot sizes from resetting, the system employs Pine Script's var declaration alongside a custom last_calc_state tracker. This ensures that deductions and additions are mathematically locked only once per phase transition, proving that complex financial state machines can run cleanly alongside heavy visual rendering without consuming object limit quotas.


[b]Deterministic Pseudo-Random Array Shuffling (LCG Implementation)[/b]


To eliminate chart repainting across continuous tick streaming, a Linear Congruential Generator (LCG) loop reorganizes the 52-element primary array via modulo arithmetic:
Swap_Index = (Seed + i * 7) % (i + 1)
This math guarantees identical randomizations across every chart tick refresh, achieving absolute visual stability.
[b]
INPUT PARAMETERS REFERENCE[/b]


Chip & Betting System: Configure initial starting stacks, blind amounts, and default raise sizes.
UI Mode: Toggles between a static Table grid and the dynamic Chart-Linked Box rendering.
Force Enlarge Cards with Box Text: Activates the bounding box algorithm mentioned above.
Y-Axis Reference Price: Anchors the floating UI to High, Low, or Close prices to prevent visual collision with candlestick series.








テキサスホールデム [BOX Max Size Edition]


免責事項


本アーキテクチャは単なる娯楽ツールではありません。これは、テキサスホールデムのフレームワークを模した、高度な多状態ロジックシミュレーションエンジンであり、Pine Script v6におけるライブティック更新下の計算オーバーヘッド、状態変数の永続性（メモリ保持）、および局所的レンダリングの限界を検証するために特別に設計されています。


エグゼクティブ・サマリー


本スクリプトは、Pine Script v6の配列処理、状態評価、およびUI描画の極限を実証するための概念実証（PoC）モデルです。TradingView上でクォンツレベルのアルゴリズム・ダッシュボードを構築する開発者に向けた技術的ベンチマークとして機能します。box.new()構造体を応用することで、TradingViewネイティブのテキスト縮尺制限を突破し、ボラティリティに追従する巨大なUIコンポーネントの描画を実現しています。


システム実行手順（インタラクティブ実行フローの詳細）


初期化: スクリプトをチャートに適用すると、Game Seedに基づく決定論的疑似乱数アルゴリズムにより、配列のシャッフルが初期化されます。
フェーズ進行: バーインデックスに基づき、Dealing、Pre-Flop、Flop、Turn、River、Showdownの6つのフェーズが自動進行します。


プレイヤーアクション: 設定画面のプルダウンから、各フェーズ（Pre-Flop〜River）における自身のアクション（FOLD, CALL/CHECK, RAISE）を手動でオーバーライドします。


CPU状態エンジン: 対面（CPU）は、True Range (ATR)を用いて市場のボラティリティを評価します。ta.tr / ta.sma(ta.tr, 14) > 1.5の場合、CPUはアグレッシブな状態と判断し「RAISE」を実行します。


状態記憶トランザクションエンジン: アクションが選択されると、システムはブラインドの徴収、レイズによる資金移動、POTの合計を瞬時に計算します。var変数で構築されたメモリエンジンにより、ティックが更新されてもチップスタックは完璧に保持され、勝敗確定時に正確に清算されます。


役の評価: Showdownフェーズにて、ローカルの組み合わせ評価エンジンが双方の7要素配列を処理し、ランク配列を用いて最適な5枚の組み合わせをスコアリングし、勝敗の決定とPOTの分配を行います。


アーキテクチャおよび定量的ロジック（技術仕様）


Bounding Boxスケーリング・アルゴリズム（局所的UIベクタースケーリング）
標準の label.new() オブジェクトは最大フォントサイズが size.huge（約36px）に制限されており、チャートの拡大縮小に追従しません。この制限をオーバーライドするため、ベクターテキストを box.new() 構造体に注入し、Y軸の境界をAverage True Range (ATR)に同期させます。
計算式:
Top = Y座標 + (ATR / 2)
Bottom = Y座標 - (ATR / 2)
実際の計算例:
現在価格 Y = 150.00、ATR = 2.0 の資産の場合。
Top = 150.00 + (2.0 / 2) = 151.00
Bottom = 150.00 - (2.0 / 2) = 149.00


出力されるBoxのY軸幅は正確に 2.0 となります。価格変動（ボラティリティ）に基づく厳格な境界ボックスを強制することで内部レンダリングエンジンをハックし、市場のノイズに完全に比例したダイナミックなテキストスケーリングを実現しています。


永続的状態メモリ（トランザクションロジック）


TradingViewのチャートは、価格ティックが動くたびにスクリプト全体を再計算します。この挙動によってチップスタックやPOTがリセットされるのを防ぐため、Pine Scriptの var 宣言と独自の last_calc_state トラッカーを組み合わせています。これにより、各フェーズの移行時に一度だけ確実な資金移動計算がロックされます。これは、高度な描画処理と並行して、複雑な金融ステートマシンが制限オブジェクト（BoxやLabel）を消費することなくクリーンに動作することを証明しています。
]
決定論的疑似乱数による配列シャッフル（LCGの実装）


ティック更新におけるリペイントを防ぐため、剰余演算を用いた線形合同法（LCG）アルゴリズムが52要素のプライマリ配列を並び替えます。
Swap_Index = (Seed + i * 7) % (i + 1)
この数理モデルにより、すべてのティック再計算において完全に同一の配列並び順が維持されます。


主要入力パラメーター仕様


Chip & Betting System: 初期スタック量、ブラインド額、デフォルトのレイズ額を設定します。
UI Mode: 固定テーブル描画と、チャート連動型のBOX描画を切り替えます。
Force Enlarge Cards with Box Text: 上記のバウンディングボックス・アルゴリズムを有効化します。
Y-Axis Reference Price: ローソク足との視覚的な衝突を避けるため、フローティングUIの基準アンカーをHigh, Low, Closeのいずれかに固定します。

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// ©ALT_analyst

//@version=6
indicator("3D: Texas Hold'em [Serialized Memory Engine]", overlay=true, max_labels_count=500, max_boxes_count=500, max_polylines_count=100, max_lines_count=500, max_bars_back = 1)

// ==========================================
// 1. Library Imports
// ==========================================
import ALT_analyst/MarketPokerEnginev2/1 as poker

// ==========================================
// 2. System & Game Settings
// ==========================================
var string G_SYS = "System & Game ID"
bool use_random = input.bool(false, "🔀 Daily Random Seed", tooltip="ON: Use today's date as seed", group=G_SYS)
int game_id = input.int(1, "Game ID (Increase to play next hand!)", minval=1, group=G_SYS)

var string G_CHIPS = "Chip & Betting System"
int starting_stack = input.int(10000, "Starting Stack", minval=1000, step=1000, group=G_CHIPS)
int sb_amount      = input.int(50, "Small Blind", minval=10, group=G_CHIPS)
int bb_amount      = input.int(100, "Big Blind", minval=20, group=G_CHIPS)
int raise_amount   = input.int(300, "Default Raise Amount", minval=50, step=50, group=G_CHIPS)

var string G_ACT = "Player Actions (Strict Sequential Lock)"
bool start_game = input.bool(false, "▶️ START GAME", tooltip="*Turn ON to start the game", group=G_ACT)

// --- 16 Action Toggles (Default OFF) ---
var string G_ACT_PF = "1. Pre-Flop Action"
bool pf_wait  = input.bool(false, "WAIT", inline="pf", group=G_ACT_PF)
bool pf_fold  = input.bool(false, "FOLD", inline="pf", group=G_ACT_PF)
bool pf_call  = input.bool(false, "CALL", inline="pf", group=G_ACT_PF)
bool pf_raise = input.bool(false, "RAISE", inline="pf", group=G_ACT_PF)

var string G_ACT_F = "2. Flop Action"
bool f_wait   = input.bool(false, "WAIT", inline="f", group=G_ACT_F)
bool f_fold   = input.bool(false, "FOLD", inline="f", group=G_ACT_F)
bool f_call   = input.bool(false, "CALL", inline="f", group=G_ACT_F)
bool f_raise  = input.bool(false, "RAISE", inline="f", group=G_ACT_F)

var string G_ACT_T = "3. Turn Action"
bool t_wait   = input.bool(false, "WAIT", inline="t", group=G_ACT_T)
bool t_fold   = input.bool(false, "FOLD", inline="t", group=G_ACT_T)
bool t_call   = input.bool(false, "CALL", inline="t", group=G_ACT_T)
bool t_raise  = input.bool(false, "RAISE", inline="t", group=G_ACT_T)

var string G_ACT_R = "4. River Action"
bool r_wait   = input.bool(false, "WAIT", inline="r", group=G_ACT_R)
bool r_fold   = input.bool(false, "FOLD", inline="r", group=G_ACT_R)
bool r_call   = input.bool(false, "CALL", inline="r", group=G_ACT_R)
bool r_raise  = input.bool(false, "RAISE", inline="r", group=G_ACT_R)

// Convert toggle state to action string (Empty if unselected)
string act_pf = pf_raise ? "RAISE" : pf_call ? "CALL / CHECK" : pf_fold ? "FOLD" : pf_wait ? "WAIT (Hold)" : ""
string act_f  = f_raise ? "RAISE" : f_call ? "CALL / CHECK" : f_fold ? "FOLD" : f_wait ? "WAIT (Hold)" : ""
string act_t  = t_raise ? "RAISE" : t_call ? "CALL / CHECK" : t_fold ? "FOLD" : t_wait ? "WAIT (Hold)" : ""
string act_r  = r_raise ? "RAISE" : r_call ? "CALL / CHECK" : r_fold ? "FOLD" : r_wait ? "WAIT (Hold)" : ""

// --- Debug Settings ---
var string G_DEBUG = "🛠 Debug Settings"
bool debug_table_on = input.bool(true, "Show Debug Table", group=G_DEBUG)

var string G_CAMERA  = "3D Casino Settings"
float  cameraYaw       = input.float(20, "Camera Yaw (°)", group = G_CAMERA, minval=0, maxval=90)
float  cameraPitch     = input.float(35, "Camera Pitch (°)", group = G_CAMERA, minval=10, maxval=80)
float  scaleTime       = input.float(3.0, "Scale: Width (X-Axis)", group = G_CAMERA)
float  scaleDepth      = input.float(5.0, "Scale: Depth (Y-Axis)", group = G_CAMERA)
float  scalePrice      = input.float(1.0, "Scale: Height (Z-Axis)", group = G_CAMERA)
string ui_size_inp     = input.string("Large", "Card Text Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=G_CAMERA)

get_pine_size(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : size.huge
var string applied_size = get_pine_size(ui_size_inp)

// ==========================================
// 3. 3D Engine Definitions
// ==========================================
type Point3D
    float x
    float y
    float z

type Camera
    int   anchorX
    float anchorY
    float cosYaw
    float sinYaw
    float sinPit
    float cosPit
    float sX
    float sY
    float sZ

method project(Camera this, Point3D p) =>
    float xRotated = p.x * this.cosYaw - p.y * this.sinYaw
    float yRotated = p.x * this.sinYaw + p.y * this.cosYaw
    float screenX  = xRotated * this.sX
    float screenY  = yRotated * this.sinPit * this.sY - p.z * this.cosPit * this.sZ
    chart.point.from_index(this.anchorX + int(screenX), this.anchorY - screenY)

f_drawFace(cam, p1, p2, p3, p4, cFill, cLine) =>
    array<chart.point> pts = array.new<chart.point>()
    pts.push(cam.project(p1))
    pts.push(cam.project(p2))
    pts.push(cam.project(p3))
    pts.push(cam.project(p4))
    polyline.new(pts, closed=true, line_color=cLine, line_width=1, fill_color=cFill)

string BACK_CARD = "🂠\n?"
get_card_str(int id) => id < 0 ? BACK_CARD : poker.get_card_vertical((id % 13) + 1, math.floor(id / 13) + 1)
get_card_color(int id) => id < 0 ? color.silver : ((math.floor(id / 13) + 1 == 1 or math.floor(id / 13) + 1 == 2) ? color.white : color.red)

f_drawCard3D(cam, x, y, z, id, show) =>
    if show
        chart.point pt = cam.project(Point3D.new(x, y, z))
        label.new(pt, text=get_card_str(id), textcolor=get_card_color(id), color=color.new(#1e222d, 10), style=label.style_label_center, size=applied_size)

f_drawChipStack(cam, x, y, z, amount, cText, label_text) =>
    if amount > 0
        int num_chips = math.min(8, math.max(1, math.floor(amount / 500)))
        string stack_str = ""
        for i = 1 to num_chips
            stack_str += "🪙\n"
        stack_str += label_text
        chart.point pt = cam.project(Point3D.new(x, y, z))
        label.new(pt, text=stack_str, textcolor=cText, color=color.new(color.black, 100), style=label.style_label_center, size=applied_size)

f_drawActionBubble(cam, x, y, z, text_str, txt_color) =>
    if text_str != ""
        chart.point pt = cam.project(Point3D.new(x, y, z))
        label.new(pt, text=text_str, textcolor=txt_color, color=color.new(color.black, 40), style=label.style_label_down, size=size.small)

// ==========================================
// 4. Deck & Seed Generation
// ==========================================
int date_seed = year * 10000 + month * 100 + dayofmonth
int active_seed = use_random ? (date_seed + game_id * 777) : (game_id * 1337)

int[] deck = array.new_int(52)
for i = 0 to 51
    array.set(deck, i, i)
for i = 51 to 1
    int swap_idx = (active_seed + i * 7) % (i + 1)
    int temp = array.get(deck, i)
    array.set(deck, i, array.get(deck, swap_idx))
    array.set(deck, swap_idx, temp)

int cpu_c1 = array.get(deck, 0), cpu_c2 = array.get(deck, 1)
int p_c1   = array.get(deck, 2), p_c2   = array.get(deck, 3)
int[] comm = array.new_int(5, -1)
for i = 0 to 4
    array.set(comm, i, array.get(deck, i + 4))

get_cpu_act(phase_num) =>
    int r = (active_seed * 13 + phase_num * 37) % 100
    r > 85 ? "RAISE" : r < 15 ? "FOLD" : "CALL / CHECK"

string raw_cpu_pf = get_cpu_act(1)
string raw_cpu_f  = get_cpu_act(2)
string raw_cpu_t  = get_cpu_act(3)
string raw_cpu_r  = get_cpu_act(4)

// ==========================================
// 5. Stateless Memory Engine (Strict Variable Management)
// ==========================================
// Removed 'var' to deterministically calculate state from inputs on every execution
int game_step = 0 
bool is_paid = false
bool is_folded = false
string winner_by_fold = ""

int p_stack = starting_stack - bb_amount
int c_stack = starting_stack - sb_amount
int pot = bb_amount + sb_amount

// Count toggle UI states (for multiple selection check)
int ui_pf_count = (pf_wait ? 1 : 0) + (pf_fold ? 1 : 0) + (pf_call ? 1 : 0) + (pf_raise ? 1 : 0)
int ui_f_count  = (f_wait ? 1 : 0) + (f_fold ? 1 : 0) + (f_call ? 1 : 0) + (f_raise ? 1 : 0)
int ui_t_count  = (t_wait ? 1 : 0) + (t_fold ? 1 : 0) + (t_call ? 1 : 0) + (t_raise ? 1 : 0)
int ui_r_count  = (r_wait ? 1 : 0) + (r_fold ? 1 : 0) + (r_call ? 1 : 0) + (r_raise ? 1 : 0)

bool custom_error = false
string custom_err_msg = ""
string current_cpu_speech = "WAITING..."
string current_p_speech = "WAITING..."
color cpu_speech_col = color.gray

add_bets(p_action, c_action) =>
    int p_a = p_action == "RAISE" ? raise_amount : p_action == "CALL / CHECK" ? math.floor(raise_amount/2) : 0
    int c_a = c_action == "RAISE" ? raise_amount : c_action == "CALL / CHECK" ? math.floor(raise_amount/2) : 0
    [p_a, c_a]

// ------------------------------------------
// Strict Error Detection Lock
// ------------------------------------------
if start_game
    // 1. Prohibit multiple selections within the same phase
    if ui_pf_count > 1 or ui_f_count > 1 or ui_t_count > 1 or ui_r_count > 1
        custom_error := true
        custom_err_msg := "Error: Please select only ONE action per phase."

    // 2. Phase sequence lock (prevent progression with unselected prior phases)
    if not custom_error
        if ui_f_count == 1 and ui_pf_count == 0
            custom_error := true
            custom_err_msg := "Error: Pre-Flop action is not selected."
        else if ui_t_count == 1 and (ui_pf_count == 0 or ui_f_count == 0)
            custom_error := true
            custom_err_msg := "Error: A previous phase action is not selected."
        else if ui_r_count == 1 and (ui_pf_count == 0 or ui_f_count == 0 or ui_t_count == 0)
            custom_error := true
            custom_err_msg := "Error: A previous phase action is not selected."

// ------------------------------------------
// Game Progression Logic (Only when error-free and stepping correctly)
// ------------------------------------------
if start_game
    if custom_error
        game_step := 99
    else
        // Pre-Flop Progression
        if act_pf != ""
            [p_a, c_a] = add_bets(act_pf, raw_cpu_pf)
            p_stack -= p_a, c_stack -= c_a, pot += p_a + c_a
            
            if raw_cpu_pf == "FOLD" or act_pf == "FOLD"
                game_step := 5, is_folded := true, winner_by_fold := act_pf == "FOLD" ? "CPU" : "PLAYER"
            else
                game_step := 1 // Move to next phase

        // Flop Progression
        if game_step == 1 and act_f != ""
            [p_a2, c_a2] = add_bets(act_f, raw_cpu_f)
            p_stack -= p_a2, c_stack -= c_a2, pot += p_a2 + c_a2
            
            if raw_cpu_f == "FOLD" or act_f == "FOLD"
                game_step := 5, is_folded := true, winner_by_fold := act_f == "FOLD" ? "CPU" : "PLAYER"
            else
                game_step := 2

        // Turn Progression
        if game_step == 2 and act_t != ""
            [p_a3, c_a3] = add_bets(act_t, raw_cpu_t)
            p_stack -= p_a3, c_stack -= c_a3, pot += p_a3 + c_a3
            
            if raw_cpu_t == "FOLD" or act_t == "FOLD"
                game_step := 5, is_folded := true, winner_by_fold := act_t == "FOLD" ? "CPU" : "PLAYER"
            else
                game_step := 3

        // River Progression
        if game_step == 3 and act_r != ""
            [p_a4, c_a4] = add_bets(act_r, raw_cpu_r)
            p_stack -= p_a4, c_stack -= c_a4, pot += p_a4 + c_a4
            
            if raw_cpu_r == "FOLD" or act_r == "FOLD"
                game_step := 5, is_folded := true, winner_by_fold := act_r == "FOLD" ? "CPU" : "PLAYER"
            else
                game_step := 5 // Move to Showdown

// Speech Bubble Settings
if game_step == 0
    current_cpu_speech := "Thinking...", current_p_speech := "Your Move"
else if game_step == 1
    current_cpu_speech := "Flop. Thinking...", current_p_speech := "Your Move"
else if game_step == 2
    current_cpu_speech := "Turn. Thinking...", current_p_speech := "Your Move"
else if game_step == 3
    current_cpu_speech := "River. Thinking...", current_p_speech := "Your Move"
else if game_step == 5
    current_p_speech := is_folded ? "Game Over" : "Showdown!"
    if is_folded
        current_cpu_speech := winner_by_fold == "PLAYER" ? "I Fold..." : "I WIN!", cpu_speech_col := winner_by_fold == "PLAYER" ? color.gray : color.lime
    else
        current_cpu_speech := "Showdown!", cpu_speech_col := color.yellow
else if game_step == 99
    current_cpu_speech := "ERROR", current_p_speech := "ERROR", cpu_speech_col := color.red

get_best_hand(int[] seven_cards) =>
    int best_score = -1
    string best_name = ""
    for drop1 = 0 to 5
        for drop2 = drop1 + 1 to 6
            int[] temp_ranks = array.new_int(5)
            int[] temp_suits = array.new_int(5)
            int idx = 0
            for i = 0 to 6
                if i != drop1 and i != drop2
                    int card_id = array.get(seven_cards, i)
                    array.set(temp_ranks, idx, card_id < 0 ? 0 : (card_id % 13) + 1)
                    array.set(temp_suits, idx, card_id < 0 ? 0 : math.floor(card_id / 13) + 1)
                    idx += 1
            [f_royal, f_st_fl, f_quads, f_fh, f_flush, f_str, f_trips, f_2p, f_1p, jokers] = poker.evaluate_hand(temp_ranks, temp_suits)
            int c_score = f_royal ? 9 : f_st_fl ? 8 : f_quads ? 7 : f_fh ? 6 : f_flush ? 5 : f_str ? 4 : f_trips ? 3 : f_2p ? 2 : f_1p ? 1 : 0
            string c_name = f_royal ? "ROYAL FLUSH" : f_st_fl ? "STR FLUSH" : f_quads ? "4 OF A KIND" : f_fh ? "FULL HOUSE" : f_flush ? "FLUSH" : f_str ? "STRAIGHT" : f_trips ? "3 OF A KIND" : f_2p ? "TWO PAIR" : f_1p ? "ONE PAIR" : "High Card"
            if c_score > best_score
                best_score := c_score, best_name := c_name
    [best_score, best_name]

// --- Win/Loss Evaluation ---
int cpu_score_eval = 0, p_score_eval = 0
string cpu_name_eval = "", p_name_eval = ""

if game_step == 5 and start_game
    [c_s, c_n] = get_best_hand(array.from(cpu_c1, cpu_c2, array.get(comm, 0), array.get(comm, 1), array.get(comm, 2), array.get(comm, 3), array.get(comm, 4)))
    [p_s, p_n] = get_best_hand(array.from(p_c1, p_c2, array.get(comm, 0), array.get(comm, 1), array.get(comm, 2), array.get(comm, 3), array.get(comm, 4)))
    cpu_score_eval := c_s, cpu_name_eval := c_n
    p_score_eval := p_s, p_name_eval := p_n

    if not is_paid
        if is_folded
            if winner_by_fold == "PLAYER"
                p_stack += pot
            else
                c_stack += pot
        else
            if p_score_eval > cpu_score_eval
                p_stack += pot
                current_cpu_speech := "I Lost...", cpu_speech_col := color.red
            else if p_score_eval < cpu_score_eval
                c_stack += pot
                current_cpu_speech := "I WIN!", cpu_speech_col := color.lime
            else
                p_stack += math.floor(pot / 2), c_stack += math.floor(pot / 2)
                current_cpu_speech := "Chop Pot.", cpu_speech_col := color.white
        pot := 0
        is_paid := true

// ==========================================
// 6. 3D Rendering Pipeline & Debug UI
// ==========================================
var table debug_tb = table.new(position.top_right, 2, 2, bgcolor=color.new(color.black, 70), border_color=color.white, border_width=1)
if barstate.islast and debug_table_on
    table.cell(debug_tb, 0, 0, "Current Phase", text_color=color.white)
    table.cell(debug_tb, 1, 0, str.tostring(game_step), text_color=game_step == 99 ? color.red : color.yellow)
    
if barstate.islast
    for l in line.all
        l.delete()
    for p in polyline.all
        p.delete()
    for lb in label.all
        lb.delete()

    string result_text = ""
    color result_col = color.gray
    if game_step == 5
        if is_folded
            result_text := "🏁 WIN BY FOLD (" + winner_by_fold + ")"
            result_col := winner_by_fold == "PLAYER" ? color.yellow : color.red
        else
            if p_score_eval > cpu_score_eval
                result_text := "🏆 WIN (" + p_name_eval + ")", result_col := color.yellow
            else if p_score_eval < cpu_score_eval
                result_text := "💀 LOSE (" + cpu_name_eval + ")", result_col := color.red
            else
                result_text := "🤝 DRAW (" + p_name_eval + ")", result_col := color.white

    string state_str = game_step == 0 ? "PRE-FLOP" : game_step == 1 ? "FLOP" : game_step == 2 ? "TURN" : game_step == 3 ? "RIVER" : game_step == 99 ? "LOCKED" : "SHOWDOWN"
    if not start_game
        state_str := "WAITING TO START"

    float radYaw = math.toradians(cameraYaw)
    float radPit = math.toradians(cameraPitch)
    
    Camera mainCam = Camera.new(bar_index - 30, close, math.cos(radYaw), math.sin(radYaw), math.sin(radPit), math.cos(radPit), scaleTime, scaleDepth, scalePrice)

    Point3D m1 = Point3D.new(-25, -20, -0.5)
    Point3D m2 = Point3D.new(25, -20, -0.5)
    Point3D m3 = Point3D.new(25, 20, -0.5)
    Point3D m4 = Point3D.new(-25, 20, -0.5)
    f_drawFace(mainCam, m1, m2, m3, m4, color.new(#1b5e20, 40), color.new(#4caf50, 10)) 
    
    label.new(mainCam.project(Point3D.new(0, 22, 0)), text="[ 🎲 3D CASINO ZONE ]\nGAME ID: " + str.tostring(game_id) + " | PHASE: " + state_str, textcolor=color.lime, style=label.style_none, size=size.normal)

    if start_game
        f_drawChipStack(mainCam, 0, 10, 0, pot, color.orange, "$" + str.tostring(pot))
        f_drawChipStack(mainCam, 12, -10, 0, p_stack, color.aqua, "$" + str.tostring(p_stack))
        f_drawChipStack(mainCam, 12, 10, 0, c_stack, color.fuchsia, "$" + str.tostring(c_stack))

        string history_log = "=== ACTION HISTORY ===\n"
        if act_pf != ""
            history_log += "[1. PF] YOU: " + act_pf + " | CPU: " + raw_cpu_pf + "\n"
        else
            history_log += "[1. PF] ⏳ Waiting...\n"
            
        if game_step >= 1
            if act_f != ""
                history_log += "[2. FL] YOU: " + act_f + " | CPU: " + raw_cpu_f + "\n"
            else
                history_log += "[2. FL] ⏳ Waiting...\n"
                
        if game_step >= 2
            if act_t != ""
                history_log += "[3. TN] YOU: " + act_t + " | CPU: " + raw_cpu_t + "\n"
            else
                history_log += "[3. TN] ⏳ Waiting...\n"
                
        if game_step >= 3
            if act_r != ""
                history_log += "[4. RV] YOU: " + act_r + " | CPU: " + raw_cpu_r + "\n"
            else
                history_log += "[4. RV] ⏳ Waiting...\n"
            
        label.new(mainCam.project(Point3D.new(-20, 20, 5)), text=history_log, textcolor=color.new(color.white, 30), color=color.new(color.black, 100), style=label.style_label_right, size=size.small)

        if custom_error
            label.new(mainCam.project(Point3D.new(0, 0, 15)), text="🚫 " + custom_err_msg, textcolor=color.red, color=color.new(color.black, 20), style=label.style_label_center, size=size.large)

        f_drawActionBubble(mainCam, -5, 17, 3, "CPU: " + current_cpu_speech, cpu_speech_col)
        f_drawActionBubble(mainCam, -5, -17, 3, "YOU: " + current_p_speech, color.aqua)

        bool show_cpu = (game_step == 5)
        
        f_drawCard3D(mainCam, -8, 12, 0, show_cpu ? cpu_c1 : -1, true)
        f_drawCard3D(mainCam, -2, 12, 0, show_cpu ? cpu_c2 : -1, true)
        
        if game_step == 5 and not is_folded
            label.new(mainCam.project(Point3D.new(-5, 17, 0)), text="\n\n" + cpu_name_eval, textcolor=color.silver, style=label.style_none, size=size.normal)

        f_drawCard3D(mainCam, -14, 0, 0, array.get(comm, 0), game_step >= 1)
        f_drawCard3D(mainCam, -7, 0, 0, array.get(comm, 1), game_step >= 1)
        f_drawCard3D(mainCam, 0, 0, 0, array.get(comm, 2), game_step >= 1)
        f_drawCard3D(mainCam, 7, 0, 0, array.get(comm, 3), game_step >= 2)
        f_drawCard3D(mainCam, 14, 0, 0, array.get(comm, 4), game_step >= 3)

        f_drawCard3D(mainCam, -8, -12, 0, p_c1, true)
        f_drawCard3D(mainCam, -2, -12, 0, p_c2, true)
        
        if game_step == 5 and not is_folded
            label.new(mainCam.project(Point3D.new(-5, -17, 0)), text="\n\n" + p_name_eval, textcolor=color.aqua, style=label.style_none, size=size.normal)

        if game_step == 5 or game_step == 99
            label.new(mainCam.project(Point3D.new(0, 0, 10)), text=result_text, textcolor=result_col, style=label.style_label_down, color=color.new(color.black, 20), size=size.large)
            
            label.new(mainCam.project(Point3D.new(0, -10, 10)), text="[ NEXT HAND: Set actions to OFF, increase Game ID ]", textcolor=color.gray, style=label.style_none, size=size.small)
````
