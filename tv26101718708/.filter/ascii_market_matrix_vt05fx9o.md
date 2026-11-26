# ASCII Market Matrix

- url: https://www.tradingview.com/script/Vt05FX9O/
- type: indicator
- pine_id: PUB;0250c6e4f0424774a7a4ac3ee19fc125
- version: 4.0

## Description

ASCII Market Matrix [Volume x RSI Profile]

[ Overview ]

At its core, this indicator is built on two classic concepts: Volume Profile and RSI.

However, I faced a major issue in TradingView: the strict limit of "500 boxes per script". Traditional volume profiles easily hit this limit, causing visual bugs and disappearing blocks.

To completely bypass this system limitation, I created the "ASCII Market Matrix".

By rendering the entire multi-dimensional profile inside a single text label using ASCII characters, this script generates 0 box-count errors. It is incredibly lightweight, perfectly stable, and offers a unique "cyberpunk" aesthetic for your charts.

[ The 3-Dimensional Matrix ]

This tool compresses 3 dimensions of market data into a single text panel:
Y-Axis (Vertical): Price Levels
X-Axis (Length): Volume (How much was traded at that price)
Z-Axis (Texture): RSI Heat (The momentum during those trades)

[ How to Read the ASCII Blocks ]

The length of the block shows the volume (thickness of the wall). The texture of the block shows the RSI momentum:
███████ (Solid Block / Hot): RSI > 60. High volume with strong buying momentum. Acts as a heavy resistance or a strong breakout base.
▒▒▒▒▒▒▒ (Shaded Block / Neutral): RSI 40-60. Standard value area.
░░░░░░░ (Light Block / Cold): RSI < 40. High volume with panic selling / oversold momentum. Often acts as a strong bounce support.
[ Key Features ]

Zero Limits: Bypasses TV's 500 drawing limit by using a single dynamically updated text label.
Non-Repainting Anchors: Captures the true historical data without shifting.
Pro-Grade Minimal UI: No messy charts. Just pure data matrix on the side of your screen.
If you appreciate coding hacks and clean order block visualization, enjoy this matrix!

(Japanese )
[ 概要 ]
このインジケーターを構成する要素は非常にシンプルです。「出来高プロファイル」と「RSI」です。
しかし、TradingViewでこれらを同時に描画しようとすると、「1スクリプトにつきBox（図形）は最大500個まで」というシステムの限界に直面し、描画が消えたりバグったりしてしまいます。
その限界を完全に突破するために開発したのが、この「ASCII Market Matrix」です。 プロファイル全体を「たった1つのテキストラベルの中のASCIIアート（文字）」として描画することで、システム制限を無効化しました。極めて軽量で安定しており、チャート上にサイバーパンクなデータマトリックスを展開します。
[ 3次元データマトリックス ]
このツールは、たった1枚のテキストパネルの中に「3つの次元」のデータを圧縮しています。
Y軸（縦）：価格帯
X軸（横の長さ）：出来高（その価格でどれだけ取引されたか）
Z軸（文字の濃淡）：RSIの熱量（その取引が行われた際のモメンタム）
[ ブロック（壁）の見方 ]
ブロックの「長さ」は壁の分厚さを表します。そして、文字の「濃さ」が相場の熱量です。
███████ (真っ黒 / Hot): RSI 60以上。強い買いモメンタムを伴う大激戦区。強力なレジスタンス、またはブレイクアウトの起点になります。
▒▒▒▒▒▒▒ (網掛け / Neutral): RSI 40-60。通常の取引エリア。
░░░░░░░ (スカスカ / Cold): RSI 40以下。パニック売りや売られすぎを伴う大激戦区。強力な反発サポート（トランポリン）として機能しやすいです。
[ 主な特徴 ]
上限なしの安定性： 図形を使わず1つのラベルを更新し続けるため、表示崩れやエラーが絶対に起きません。
究極のシンプルさ： チャートのローソク足を一切邪魔せず、画面の端に静かに「過去の防護壁」を提示します。
TradingViewのシステムをハックしたこのマニアックな視覚化ツールが、あなたのトレードの新たな武器になれば幸いです。

## Source Code

````pine
// © ALT_analyst_experimental
// ASCII Market Matrix (Pro Edition)
//@version=6
indicator("ASCII Market Matrix", overlay=true, max_labels_count=10)

// ==========================================
// 1. Settings & Parameters
// ==========================================
grp_sys   = " [ SYSTEM SETTINGS ] "
lookback  = input.int(150, "Scan Period (Lookback Bars)", group=grp_sys)
row_count = input.int(30, "Price Resolution (Rows)", minval=10, maxval=50, group=grp_sys)
max_width = input.int(40, "Max Block Width (Chars)", minval=10, maxval=100, group=grp_sys)
rsi_len   = input.int(14, "Heat Calculation (RSI Length)", group=grp_sys)

grp_col   = " [ STYLE ] "
text_col  = input.color(color.rgb(0, 200, 255), "Text Color", group=grp_col)
bg_col    = input.color(color.new(color.black, 15), "Background Color", group=grp_col)

// ==========================================
// 2. Core Calculations
// ==========================================
float current_rsi = ta.rsi(close, rsi_len)

if barstate.islast
    float h_max = ta.highest(high, lookback)
    float l_min = ta.lowest(low, lookback)
    float step  = (h_max - l_min) / row_count
    
    float[] vol_bins     = array.new_float(row_count, 0.0)
    float[] rsi_vol_bins = array.new_float(row_count, 0.0)
    
    if step > 0
        for i = 0 to lookback - 1
            float c_price = close[i]
            float c_vol   = volume[i] > 0 ? volume[i] : 1.0
            float c_rsi   = current_rsi[i]
            
            int bin_idx = math.floor((c_price - l_min) / step)
            bin_idx := math.max(0, math.min(row_count - 1, bin_idx))
            
            array.set(vol_bins, bin_idx, array.get(vol_bins, bin_idx) + c_vol)
            array.set(rsi_vol_bins, bin_idx, array.get(rsi_vol_bins, bin_idx) + (c_rsi * c_vol))

    float max_vol = array.max(vol_bins)
    max_vol := max_vol > 0 ? max_vol : 1.0

    // ==========================================
    // 3. ASCII Art (Text) Generation
    // ==========================================
    string final_str = "[ ASCII MARKET MATRIX ]\n"
    final_str := final_str + " HEAT: [█]Hot  [▒]Mid  [░]Cold\n"
    final_str := final_str + "--------------------------------------\n"

    for i = row_count - 1 to 0
        float v = array.get(vol_bins, i)
        float avg_rsi = v > 0 ? (array.get(rsi_vol_bins, i) / v) : 50.0
        int num_blocks = math.round((v / max_vol) * max_width)
        
        string block_char = "▒"
        if avg_rsi >= 60
            block_char := "█"
        else if avg_rsi <= 40
            block_char := "░"
            
        float price_lvl = l_min + (i * step)
        string price_str = str.tostring(price_lvl, format.mintick)
        string blocks_str = num_blocks > 0 ? str.repeat(block_char, num_blocks) : ""
        
        final_str := final_str + price_str + " | " + blocks_str + "\n"

    // ==========================================
    // 4. Single Label Rendering (Prevents Overlap)
    // ==========================================
    var label matrix_label = na
    
    if na(matrix_label)
        matrix_label := label.new(
             x = bar_index + 5, 
             y = (h_max + l_min) / 2, 
             text = final_str, 
             color = bg_col, 
             textcolor = text_col, 
             style = label.style_label_left, 
             text_font_family = font.family_monospace, 
             size = size.small
             )
    else
        label.set_xy(matrix_label, bar_index + 5, (h_max + l_min) / 2)
        label.set_text(matrix_label, final_str)
````
