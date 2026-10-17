# Smart Mahjong Concepts

- url: https://www.tradingview.com/script/gxM00bD5/
- type: indicator
- pine_id: PUB;2999fed7cf87400d91c7be84aff2e5e4
- version: 6.0

## Description

[b]Smart Mahjong Concepts

NOTICE / DISCLAIMER[/b]

This architecture is NOT a mere entertainment tool or a superficial game. It is a highly advanced algorithmic volume allocation and multi-state logic simulation engine disguised as a traditional matching framework (Mahjong), specifically designed to test the computational overhead and localized rendering boundaries of Pine Script v6 under live tick conditions.
[b]
EXECUTIVE SUMMARY[/b]

This script is deployed as a Proof of Concept (PoC) to demonstrate the extreme limits of Pine Script v6's array processing, state evaluation capabilities, and localized UI rendering. This open-source architecture functions as a rigorous technical benchmark for developers building institutional-grade algorithmic dashboards and multi-state logic controllers directly on TradingView charts.

HOW TO PLAY (Mahjong Crash Course & Execution Flow)
Since TradingView doesn't allow direct mouse clicks on chart objects, we've engineered a dropdown-based state machine to play the game. Here is how you play and the basic rules of Mahjong:

1. The Goal of Mahjong:
Your objective is to draw and discard tiles to complete a 14-tile winning hand. A standard winning hand consists of four "Sets" (3 sequential tiles or 3 identical tiles) and one "Pair" (2 identical tiles). We also support special hands like "Seven Pairs" (7 different pairs) and "Thirteen Orphans" (one of each 1, 9, and honor tile).

2. Available Yaku (Winning Patterns) & Advanced Logic:
You need at least one "Yaku" to win. This engine automatically calculates the following built-in Yaku:
- Ready Hand (Riichi): Toggle the Riichi switch to declare your hand is 1 tile away from winning. This costs 1,000 points (deducted from your HUD score) and adds +1 Han to your final win.
- Dora (Bonus Tile): Check the "Dora Indicator" tile displayed at the top of your HUD. Every matching tile in your winning hand adds +1 Han.
- All Simples (Tanyao): A hand with NO 1s, 9s, or Honor/Letter tiles.
- Value Tiles (Yakuhai): A set of 3 matching Honor/Letter tiles.
- Half Flush (Honitsu): A hand using only one suit plus Honor/Letter tiles.
- Full Flush (Chinitsu): A hand using ONLY one suit.
- All Triplets (Toitoi): A hand where all 4 sets are identical triplets.
- Seven Pairs (Chiitoitsu): Exactly 7 different pairs.
- Thirteen Orphans (Kokushi Musou): The legendary hand containing all terminals and honors.

3. Step-by-Step Execution:
- Initialization: Apply the script to a chart. The system automatically deals 13 tiles to you and the CPU.
- Read Your Hand: Look at the grey index numbers (1 to 14) displayed right below your tiles.
- Your First Turn: Open the settings. The Turn 1 parameter is pre-set to "14" (your first drawn tile index) to ensure the engine initializes seamlessly without triggering any unselected or error standby states. If you want to discard a different tile, simply change this dropdown to match the grey index number (1 to 14) of the tile you want to drop. Click OK.
- CPU Turn: The moment you hit OK, the engine moves your tile to the River, sorts your hand, and triggers the CPU. The CPU draws, thinks using a retro AI algorithm, and discards.
- Subsequent Turns: A new tile is drawn for you. Open settings, go to Turn 2, pick the index of your next discard, and hit OK. Repeat up to Turn 18.
- Declaring a Win: When your 14 tiles form a valid hand with at least one Yaku, check the Tsumo (self-draw) or Ron (win on opponent's discard) box at the bottom of the settings. The HUD will lock in your score! (Warning: Checking these without a valid hand results in a "Chombo" penalty).

CONFIGURATION & FILTERING OPTIONS
- Fixed Screen Table Compression: The layout uses a highly optimized 12-column matrix for discard streams (River arrays). By packing tiles tightly across rows 1-2 (Opponent) and 6-7 (Player), it completely aligns with the horizontal hand width, eliminating redundant dead space.
- Hand Guide Indices: Dynamic, real-time index markers (1 to 14) map directly below the Player hand elements. This provides structural input verification, eliminating input errors when executing parameters.
- SMC Volume Profile Filtering: A toggle-driven threshold filter isolates significant volume nodes. Users can specify a threshold percentage (0.0% to 100.0%). Any price bucket whose volume does not meet the specified percentage relative to the Point of Control (POC) node volume is skipped during the rendering loop.
- Standardized Price Coordination: Every individual row of the Mahjong Volume Profile displays its absolute price boundary, formatted using format.mintick inside structural brackets (e.g., [152.37]). The maximum volume bar is automatically prefixed with a distinct 'POC' string asset tracker.

SYSTEM CAPABILITIES AND LIMITATIONS
Capabilities:
1. Complete Replication of Identical States: Given an identical Game Seed, the script guarantees 100% stable replication of all wall shuffles, initial tile distributions, and CPU discard paths across any device or chart timeframe.
2. Visual Synthesis of Financial Volume Data: The horizontal length of the rendered profile tracks live traded volume metrics pro-rata, allowing traders to confirm institutional support levels while running state logic simulation.
3. Clean Pro-Rata Volume Extraction: Noise reduction filtering eliminates low-volume spikes, cleanly isolating key supply/demand clusters on the chart.

Limitations:
1. Strict Monzen (Concealed Hand) Architecture: To preserve absolute computational efficiency and prevent Abstract Syntax Tree (AST) node exhaustion, this engine enforces a strict "Concealed Hand Only" constraints. By omitting open-meld variables (Meelee / Pon, Chii, Kan), the system optimizes recursive backtracking matrix pipelines, shifting the structural meta towards maximizing full-flush and terminal anomalous state logic (e.g., Thirteen Orphans) directly on live charts.
2. No Direct Mouse-Click Tile Interaction: TradingView does not expose coordinate click events to Pine Script. Discards must be executed through parameter dropdowns.
3. No Asynchronous Network Multi-Player: Pine Script lacks external socket capabilities. Synchronization between human players across machines is impossible; gameplay is Player-vs-CPU local simulation.
4. Hardware Object Limits: TradingView enforces a strict cap of 500 max labels/boxes per indicator. Scaling VP resolution too high with filtering off will cause automated visual clipping.

ARCHITECTURE & QUANTITATIVE LOGIC (Technical Specifications)

1. Volume Allocation Engine (Pro-Rata Range Overlap Distribution)
Instead of simple volume summation based on close prices, the script calculates the exact geometric intersection between each bar's High-Low range and the discrete price bins. Volume is distributed across multiple bins according to the overlap percentage.
Let bar high be H, bar low be L, and bar volume be V. Let a specific bin b have an upper bound BinTop and lower bound BinBot. The distributed volume delta dV for bin b from bar i is computed as follows:
If H > L: Overlap = max(0, min(H, BinTop) - max(L, BinBot)), Ratio = Overlap / (H - L), dV = V * Ratio.
If H = L: BinIdx = floor((H - LL) / BinSize). If BinIdx equals b, dV = V; else, dV = 0.

2. Bounding Box Scaling Algorithm (Localized UI Vector Scaling)
Standard label.new() text strings are hard-capped at size.huge (approx. 36px). To override this, vector Unicode strings are injected into a box.new() container. The Y-axis boundaries are mathematically locked using Top = Y + 0.5 and Bottom = Y - 0.5 units. By enforcing a strict coordinate bounding box, the text engine is overridden, forcing the vectors to dynamically scale up to 100px+ relative to the visual layout.

3. Floating Relative Coordinate System
To prevent visual collision with candlestick series, the UI baseline is decoupled from absolute historical coordinates via the formula: Base_Y = Close + Global_Shift.

4. Deterministic Pseudo-Random Array Shuffling (LCG Implementation)
To eliminate chart repainting, a secure Linear Congruential Generator (LCG) loop reorganizes the 136-element primary array via modulo arithmetic: Swap_Index = (Seed + i * 7) % (i + 1).

5. Trigonometric Color Matrix Generation
To eliminate computational rigidity, sine waves handle multi-phase shift conversions for RGB gradients: R = floor(sin(Freq * Index) * 127 + 128).

6. Modular State Evaluation Engine (AST Optimization)
To circumvent server-side compilation timeouts, all scoring algorithms are entirely externalized across four custom libraries.

INPUT PARAMETERS REFERENCE & CRITICAL WARNINGS
- UI Mode: Fixed Screen (Table) / Off for Chart-Linked (Label). Default is false.
- Game Seed: Default is 777. The seed for the LCG algorithm. Warning: Changing this value mid-game completely breaks transaction state history.
- Declare Riichi: Default is false. Deducts 1,000 pts from the HUD and adds +1 Han to a valid win.
- Turn 1 (t1): Default is "14". Pre-set to 14 (the first drawn tile index) to eliminate application-stage state mismatch faults.
- Turn 2 to Turn 18 (t2 to t18): Default is "0". Warning: Inputs must be executed sequentially.
- Tsumo / Ron (is_tsumo / is_ron): Boolean (bool). Default is false. Warning: Do not toggle both to true simultaneously.
- VP Volume Threshold (%) (vp_thresh): Range: 0.0 to 100.0. Default is 20.0. CRITICAL WARNING: Setting filter_vp to true with a very low threshold (e.g., 0.0% to 1.0%) on low-volume assets exhausts the 500 max boxes limit, triggering clipping faults. Keep at 20.0%+ on live charts.

=======================================================

📝 日本語説明（Japanese Description）

注意／免責事項
本アーキテクチャは、単なるエンターテインメントツールや表面的なゲームではありません。ライブティック条件下におけるPine Script v6の計算負荷と局所的レンダリングの限界をテストするために、伝統的なマッチングフレームワーク（麻雀）に偽装した、高度なアルゴリズム出来高按分および多状態ロジックシミュレーションエンジンです。

エグゼクティブ・サマリー
本スクリプトは、Pine Script v6における配列処理、状態評価、および局所的なUIレンダリングの極限を実証するための概念実証モデル（Proof of Concept）です。TradingView上で機関投資家レベルのアルゴリズム・ダッシュボードや多状態ロジックコントローラを構築する開発者に向けた、オープンソースの技術的ベンチマークです。

遊び方とゲームの流れ（麻雀ルール超簡易ガイド付き）
TradingViewの仕様上、画面の牌を直接マウスでクリックすることはできません。そのため、設定画面の「プルダウン」を使ってゲームを進めます。麻雀を知らない方でも直感的に遊べるように設計しています。

1. 麻雀のクリア条件（アガリの形）
14枚の牌を使って、「3枚セット×4つ」＋「2枚のペア×1つ」を作るのが基本ルールです。（セット＝連番、または同じ牌3枚）。例外として「ペアを7つ作る（七対子）」などの特殊な形もあります。

2. 実装されている役（ヤク）と拡張ロジック
アガるためには「役」が最低1つ必要です。本エンジンは以下の役およびボーナスを自動計算します。
- リーチ (Riichi): テンパイ（あと1枚でアガリ）の時に設定画面でリーチを宣言できます。HUDの点棒が1,000点減り、アガった時に「+1飜（Han）」が加算されます。
- 現物ドラ (Dora): HUDの最上部に「Dora Indicator」としてドラ表示牌が1枚表示されています。アガった時、自分の手牌の中にこの表示牌と「全く同じ牌（現物）」があれば、その枚数分だけ「+X飜」が加算されます。
- 断么九（タンヤオ）: 1、9、字牌を使わず、2〜8の牌だけで作る。
- 役牌（ヤクハイ）: 東南西北白發中のどれかを3枚揃える。
- 混一色（ホンイツ）: 1つの色（例：萬子だけ）と字牌だけで作る。
- 清一色（チンイツ）: 1つの色だけで作る。
- 対々和（トイトイ）: 3枚セットをすべて「同じ牌3枚」で作る。
- 七対子（チートイツ）: 2枚のペアを7種類作る。
- 国士無双（コクシムソウ）: 1、9、字牌の全13種類を揃える最強の役。

3. 対局の進め方
- 初期化: チャートに入れると、自動的に13枚の牌が配られます。
- 手牌の確認: 自分の牌のすぐ下に「1〜14」のグレーの番号が振られています。これが捨てる時の「指定番号」です。
- 1巡目（Turn 1）: 最初のツモ牌が引かれ、手牌が14枚になります。設定画面を開くと、初期エラー状態（インジケーター適用直後の未選択によるスタンドバイ不整合）を構造的に回避するため、`Turn 1` はデフォルトで「14（一番右のツモ牌のインデックス）」がプリセットされています。これにより、適用した瞬間に有効な初期トランザクションが確立されます。もし別の牌を捨てたい場合は、捨てたい牌の下にある番号（1〜14）をプルダウンで選び、「OK」を押します。
- CPUのターン: OKを押した瞬間、選んだ牌が河（捨て場）に移動し、即座にCPUがツモって、レトロなAI思考で最適な牌を捨ててきます。
- 2巡目以降: あなたに新しい牌が配られます。設定画面の `Turn 2` で捨てる番号を選び、OKを押す。これを18巡目まで繰り返します。
- アガリの宣言: 手牌がアガリの形になり、役が完成したら、設定画面の一番下にある `Tsumo（ツモ）` または `Ron（ロン）` にチェックを入れてください。画面中央に役と点数（飜数）がドン！と表示されます。（※役がないのにチェックを入れると「チョンボ」と怒られます）。

構成およびフィルタリングオプション
- 固定画面テーブルの凝縮レイアウト: 捨牌（河）の格納に高度に最適化された12列マトリックスを採用。対面とプレイヤーの河を手牌の横幅と完璧に同調させ、画面上の無駄なデッドスペースを完全に排除しました。
- SMCボリュームプロファイルの閾値フィルタ: 出来高ノイズをカットするスイッチ。出来高閾値％を指定し、最大出来高（POC）に対して指定割合に満たない価格帯は描画ループからスキップされ、チャートから完全に非表示になります。
- 精密な価格帯およびPOCの数値可視化: プロファイルの各行の左側に、市場価格座標が format.mintick を用いて正確に計算・ブラケット表示されます（例: [152.37]）。POCには専用の識別文字列が付与されます。

システムの技術的限界（達成可能な事項と不可能な事項）
達成可能な事項:
1. 完全決定論的な同一状態の再現: Game Seedが同一であれば、どの端末・時間足でも、完全に同一の山牌、CPU打牌経路がミリ秒単位の狂いもなく100%再現されます。
2. 市場出来高データとの視覚的融合: バックグラウンドのプロファイル横幅は実際の取引高にプロラタ（比例配分）で連動しており、機関投資家のサポート価格帯（POC）を確認しながら状態シミュレーションを進めることができます。
3. ノイズレスな出来高ノードの抽出: 閾値フィルタリングにより、価格アクション上の微小な出来高スパイクをクレンジングします。

不可能な事項:
1. 厳格な門前仕様アーキテクチャ（鳴きの排除）: 絶対的な計算効率を維持し、ASTノードの枯渇を防止するため、本エンジンは厳格な「門前限定制約」を強制しています。鳴き変数（ポン、チー、カン）を省略することで、システムは再帰的なバックトラッキング行列パイプラインを最適化し、清一色や国士無双などの大物手状態ロジックの最大化へと構造的メタをシフトさせています。
2. マウスクリックによる直接的な牌選択: TradingViewの仕様上、画面クリックの座標取得が不可能なため、打牌は設定画面のプルダウンから番号指定で行う必要があります。
3. 非同期ネットワーク通信対戦: Pine Scriptは外部サーバーとのソケット通信機能を備えていません。よって対人ネットワーク対戦は不可能であり、対CPU戦のローカルシミュレーション限定となります。
4. オブジェクト上限による描画の消去: 1つのインジケーターが保持できるオブジェクト数は500個が限界です。プロファイルの行数を極大値に設定しフィルタリングをオフにすると、自動消去（クリッピング）が発生します。

アーキテクチャおよび定量的ロジック（技術仕様）
1. 出来高按分エンジン（プロラタ値幅オーバーラップ配分ロジック）
終値に基づく単純な出来高の加算ではなく、各バーの高値・安値レンジと、事前定義された価格帯ビンとの幾何学的な重複を計算し、そのオーバーラップ率に基づいて出来高を複数のビンへ比例配分（プロラタ処理）します。
H > L の場合：Overlap = max(0, min(H, BinTop) - max(L, BinBot)), Ratio = Overl
ap / (H - L), dV = V * Ratio。
H = L の場合：BinIdx = floor((H - LL) / BinSize)。BinIdx が b と等しい場合、dV = V。

2. Bounding Boxスケーリング・アルゴリズム（局所的UIベクタースケーリング）
標準の label.new() は最大サイズが制限されておりチャートの拡大縮小に追従しません。この制限を打破するため、ベクターテキストを box.new() に注入し、Y軸の価格単位（Top = Y + 0.5、Bottom = Y - 0.5）で空間境界を固定。内部レンダリングエンジンを強制オーバーライドし、100pxを超える動的スケーリングを実現します。

3. フローティング相対座標系
静的なインターフェースがローソク足と衝突するのを防ぐため、UIのベースラインを絶対価格から分離する数式：Base_Y = Close + Global_Shift を採用しています。

4. 決定論的疑似乱数による配列シャッフル（LCGの実装）
ティック更新におけるリペイントを防ぐため、剰余演算を用いた線形合同法（LCG）アルゴリズムが配列を並び替えます：Swap_Index = (Seed + i * 7) % (i + 1)。

5. 三角関数を利用したRGBカラーマトリックス生成
サイン波による連続的な位相シフト計算を実装し、RGB値を 2 * PI / 3 ラジアン（120度）ずつオフセットさせ、動的なカラーグラデーションを生成します。

6. モジュール化された状態評価エンジン（AST最適化）
コンパイルタイムアウトを回避するため、スコアリングロジックは4つのカスタムライブラリへと完全に分散（モジュール化）されています。

全入力パラメーターの仕様と注意事項
- UI Mode: Fixed Screen (Table) / Off for Chart-Linked (Label): デフォルトは false。描画モードの切り替え。
- Game Seed: デフォルトは 777。注意事項: 途中で数値を変更すると再シャッフルされ、整合性が破壊されます。
- Declare Riichi: デフォルトは false。リーチ宣言。HUDから1,000点を減算し、アガリ時に+1飜を加算します。
- Turn 1 (t1): 初期値は "14"。インジケーター適用時のエラーを防止するため、デフォルトで14番目の要素（ツモ牌）が選択されています。
- Turn 2 〜 Turn 18 (t2 〜 t18): 初期値は "0"。注意事項: パラメーターは必ず順番通りに入力してください。
- Tsumo / Ron: 和了宣言スイッチ。注意事項: 同時に両方を true に設定しないでください。
- VP Volume Threshold (%) (vp_thresh): デフォルトは 20.0。
【重大な警告】 流動性の低い相場で filter_vp を true にしつつ、vp_thresh を極めて低い値（0.0%〜1.0%等）に設定すると、TradingViewの「500個のBox/Label制限」を瞬時に突破し、描画が完全に消失するクリッピングバグが誘発されます。実戦チャートでは必ず「20.0%」以上に設定してください。

## Source Code

````pine
//@version=6
indicator("[DEPRECATED] Support Ended", overlay = true)

// Display the message label only on the last bar
if barstate.islast
    label.new(
         x = bar_index, 
         y = high, 
         text = "[Notice]\nSupport and feature updates for this script have ended.\nThank you for using it over the time.\nPlease look forward to my upcoming analysis tools.", 
         color = color.new(color.gray, 50), 
         textcolor = color.white, 
         size = size.large,
         style = label.style_label_down
     )
````
