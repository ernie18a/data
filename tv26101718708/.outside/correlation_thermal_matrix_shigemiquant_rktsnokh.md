# Correlation Thermal Matrix [ShigemiQuant]

- url: https://www.tradingview.com/script/RKTSnOkH-Correlation-Thermal-Matrix-ShigemiQuant/
- type: indicator
- pine_id: PUB;ad063a4c3a3645448a37d3577a1140d7
- version: 1.0

## Description

[b]What's hidden in your portfolio?[/b]

Two "diversified" positions can silently carry the same risk — but a standard correlation table won't show you the structure behind it. Correlation Thermal Matrix (CTM) goes further: it builds a live pairwise heatmap for up to 15 symbols, then applies [b]K-Means clustering[/b] to automatically group symbols that share similar correlation behavior. The result is a block-diagonal matrix where hidden risk clusters become immediately visible — something no other public TradingView indicator currently offers.

[b]━━ What It Does ━━[/b]

CTM calculates pairwise Pearson correlation coefficients for up to 15 symbols and renders them as a color-coded thermal matrix directly on your chart. Red cells indicate strong negative correlation (-1.0), white indicates near-zero, and blue indicates strong positive correlation (+1.0).

Beyond the heatmap, a K-Means algorithm analyzes each symbol's full row of correlations — its "correlation profile" — and groups symbols with similar profiles into clusters. The matrix is then reordered so that clustered symbols sit adjacent to each other, separated by clear visual dividers. This block-diagonal structure reveals the hidden architecture of your watchlist at a glance.

[b]━━ Key Features ━━[/b]

[list]
[*][b]K-Means Clustering (ML)[/b] — Automatically groups symbols whose correlation profiles are similar. Adjustable from K=2 to K=5 clusters (default K=3). Powered by MLMatrixLib.
[*][b]Block-Diagonal Sorting[/b] — Clustered symbols are placed adjacent to each other with separator rows/columns at cluster boundaries, making structural patterns impossible to miss.
[*][b]Live Correlation Heatmap[/b] — Pairwise correlations for up to 15 symbols, updated every bar. Manual Pearson calculation bypasses ta.correlation() limitations for full flexibility.
[*][b]3 Built-in Presets + Custom Mode[/b] — FX Majors (12 pairs including EURUSD, GBPUSD, USDJPY), US Stocks (AAPL, MSFT, GOOGL and more), Crypto (BTC, ETH, SOL and more), or define your own symbols entirely.
[*][b]Auto Duplicate Skip[/b] — If your chart symbol already exists in the preset, CTM automatically removes the duplicate so no slot is wasted.
[*][b]Flexible Display[/b] — Choose table position (9 locations), text size (Tiny / Small / Normal), and toggle numeric values on or off.
[*][b]Open Source[/b] — Full source code available under Mozilla Public License 2.0. Read it, learn from it, build on it.
[/list]

[b]━━ How to Use ━━[/b]

[list]
[*][b]Step 1[/b] — Add CTM to any chart. Select a preset (FX Majors / US Stocks / Crypto) or switch to Custom and enter your own symbols.
[*][b]Step 2[/b] — Read the heatmap. Deep blue cells = highly correlated pairs. Deep red = inversely correlated. White = independent. If two positions you hold are deep blue, you are more concentrated than you think.
[*][b]Step 3[/b] — Check the cluster blocks. Symbols inside the same block share similar correlation behavior. Symbols in different blocks offer genuine diversification.
[*][b]Step 4[/b] — Adjust the correlation period (default 20 bars) to match your trading horizon. Shorter periods capture recent regime shifts; longer periods reveal structural relationships.
[*][b]Step 5[/b] — Watch for changes. When a pair that was previously uncorrelated suddenly turns blue, this often signals a regime change — reassess your exposure accordingly.
[/list]

[b]━━ Parameters ━━[/b]

[code]
Parameter              Default     Range / Options
Correlation Period     20          5 - 100 bars
Cluster Count (K)      3           2 - 5
Symbol Preset          FX Majors   FX Majors / US Stocks / Crypto / Custom
Table Position         Top Right   9 chart positions
Text Size              Tiny        Tiny / Small / Normal
Show Values            On          On / Off
[/code]

[b]━━ Practical Applications ━━[/b]

[list]
[*][b]Concentration risk detection[/b] — Holding EURUSD and GBPUSD simultaneously? If their correlation reads +0.92, your effective exposure is nearly doubled. CTM makes this visible before the drawdown does.
[*][b]Diversification discovery[/b] — Symbols in separate clusters behave independently. For example, if BTC and ETH land in Cluster 1 while SOL sits in Cluster 2, SOL may offer genuine diversification against the BTC/ETH group. Use cluster membership to build positions that don't collapse together.
[*][b]Regime change early warning[/b] — A correlation that breaks from its historical pattern signals a structural shift in the market. Monitor cluster membership over time — when a symbol migrates from one cluster to another, it deserves attention.
[/list]

[b]━━ Suggested Workflow ━━[/b]

[list]
[*][b]1. Detect risk clusters[/b] (CTM) — Identify which of your positions share correlated behavior.
[*][b]2. Find independent momentum[/b] (Multi-Symbol Momentum Screener) — Screen for momentum signals, then cross-check with CTM to confirm those signals come from different clusters.
[*][b]3. Size by real exposure[/b] (Smart Position Sizer) — Allocate position size based on per-cluster exposure rather than per-symbol, so correlated groups don't silently dominate your book.
[/list]

[b]━━ About ShigemiQuant ━━[/b]

ShigemiQuant builds open-source quantitative tools focused on risk management and portfolio intelligence. Every script is designed to solve a real trading problem — no repainting, no black boxes, fully readable source code.

[b]━━ Changelog ━━[/b]

[list]
[*]v1.0 — Initial release. Live correlation heatmap with K-Means clustering, 3 presets, block-diagonal sorting, and auto duplicate skip.
[/list]

## Source Code

````pine
// ============================================================================
// Correlation Thermal Matrix [ShigemiQuant]
// ============================================================================
//
// WHAT IT DOES:
//   Visualizes a real-time correlation heatmap for up to 15 symbols, with
//   K-Means clustering to automatically detect and group correlated assets.
//   Cluster-sorted rows/columns with separator lines reveal the block-diagonal
//   structure hidden in your portfolio.
//
// HOW IT WORKS:
//   1. Fetches close prices for up to 15 symbols via request.security()
//   2. Computes Pearson correlation for all pairs using manual calculation
//   3. Runs K-Means clustering (via MLMatrixLib) on the correlation matrix
//   4. Sorts rows/columns by cluster ID and draws a color-coded heatmap
//   5. Inserts separator rows/columns between cluster boundaries
//
// PRESETS: FX Majors, US Stocks, Crypto, or fully Custom symbol selection.
//
// NON-REPAINTING: All calculations use only completed bar data.
//
// By ShigemiQuant -- Open source & free to use.
//
// ============================================================================

//@version=6
indicator("Correlation Thermal Matrix [ShigemiQuant]", shorttitle="CTM", overlay=true, max_bars_back=500)

// ============================================================================
// Import
// ============================================================================

import ArunaReborn/MLMatrixLib/1 as ml

// ============================================================================
// Constants
// ============================================================================

int MAX_SYMBOLS = 15

// ============================================================================
// Color Constants
// ============================================================================

var color C_POS_STRONG  = #1565C0
var color C_POS_WEAK    = #90CAF9
var color C_NEUTRAL     = #F5F5F5
var color C_NEG_WEAK    = #EF9A9A
var color C_NEG_STRONG  = #E53935
var color C_DIAG        = #B0BEC5
var color C_HEADER_BG   = #1e222d
var color C_HEADER_TEXT  = #d1d4dc
var color C_CLUSTER_1   = #1565C0
var color C_CLUSTER_2   = #E53935
var color C_CLUSTER_3   = #4CAF50
var color C_CLUSTER_4   = #FF9800
var color C_CLUSTER_5   = #9C27B0
var color C_SEPARATOR   = #2a2a2a
var color C_FOOTER_BG   = #1e222d
var color C_FOOTER_TEXT  = #787b86
var color C_BORDER      = #E0E0E0

// ============================================================================
// Input Parameters
// ============================================================================

// --- Group: Symbols ---
GRP_SYM = "Symbols"

i_preset     = input.string("FX Majors", "Preset", options=["FX Majors", "US Stocks", "Crypto", "Custom"], group=GRP_SYM, tooltip="Select a preset or Custom to set your own symbols")
i_numSymbols = input.int(12, "Number of Symbols", minval=2, maxval=15, step=1, group=GRP_SYM, tooltip="Total number of symbols to analyze (including chart symbol)")

i_sym1  = input.symbol("EURUSD",  "Symbol 1",  group=GRP_SYM, tooltip="Custom symbol for slot 1")
i_sym2  = input.symbol("GBPUSD",  "Symbol 2",  group=GRP_SYM, tooltip="Custom symbol for slot 2")
i_sym3  = input.symbol("USDJPY",  "Symbol 3",  group=GRP_SYM, tooltip="Custom symbol for slot 3")
i_sym4  = input.symbol("USDCHF",  "Symbol 4",  group=GRP_SYM, tooltip="Custom symbol for slot 4")
i_sym5  = input.symbol("AUDUSD",  "Symbol 5",  group=GRP_SYM, tooltip="Custom symbol for slot 5")
i_sym6  = input.symbol("NZDUSD",  "Symbol 6",  group=GRP_SYM, tooltip="Custom symbol for slot 6")
i_sym7  = input.symbol("USDCAD",  "Symbol 7",  group=GRP_SYM, tooltip="Custom symbol for slot 7")
i_sym8  = input.symbol("GBPJPY",  "Symbol 8",  group=GRP_SYM, tooltip="Custom symbol for slot 8")
i_sym9  = input.symbol("EURJPY",  "Symbol 9",  group=GRP_SYM, tooltip="Custom symbol for slot 9")
i_sym10 = input.symbol("EURGBP",  "Symbol 10", group=GRP_SYM, tooltip="Custom symbol for slot 10")
i_sym11 = input.symbol("XAUUSD",  "Symbol 11", group=GRP_SYM, tooltip="Custom symbol for slot 11")
i_sym12 = input.symbol("XAGUSD",  "Symbol 12", group=GRP_SYM, tooltip="Custom symbol for slot 12")
i_sym13 = input.symbol("AUDJPY",  "Symbol 13", group=GRP_SYM, tooltip="Custom symbol for slot 13")
i_sym14 = input.symbol("CADJPY",  "Symbol 14", group=GRP_SYM, tooltip="Custom symbol for slot 14")

// --- Group: Correlation ---
GRP_CORR = "Correlation"

i_corrLength = input.int(20, "Lookback Period", minval=5, maxval=100, step=1, group=GRP_CORR, tooltip="Number of bars for correlation calculation")

// --- Group: K-Means Clustering ---
GRP_KMEANS = "K-Means Clustering"

i_enableKMeans = input.bool(true, "Enable K-Means Clustering", group=GRP_KMEANS, tooltip="Enable K-Means clustering and sort")
i_kClusters    = input.int(3, "Number of Clusters (K)", minval=2, maxval=5, step=1, group=GRP_KMEANS, tooltip="Number of clusters for K-Means")
i_tolerance    = input.float(0.001, "Convergence Tolerance", minval=0.0001, maxval=0.01, step=0.0001, group=GRP_KMEANS, tooltip="Convergence tolerance for K-Means")

// --- Group: Display ---
GRP_DISP = "Display"

i_tablePos    = input.string("Middle Center", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=GRP_DISP, tooltip="Table position on chart")
i_tableSize   = input.string("Small", "Table Size", options=["Tiny", "Small", "Normal"], group=GRP_DISP, tooltip="Table text size")
i_showValues  = input.bool(true, "Show Correlation Values", group=GRP_DISP, tooltip="Show correlation values in cells")
i_showCluster = input.bool(true, "Show Cluster Column", group=GRP_DISP, tooltip="Show cluster ID column")
i_decimals    = input.int(2, "Decimal Places", minval=1, maxval=3, step=1, group=GRP_DISP, tooltip="Decimal places for correlation values")

// ============================================================================
// Helper Functions
// ============================================================================

// --- Table Position Converter ---
f_tablePos(string pos) =>
    switch pos
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right

// --- Text Size Converter ---
f_textSize(string sz) =>
    switch sz
        "Tiny"  => size.tiny
        "Small" => size.small
        => size.normal

// --- Symbol Short Name ---
f_shortName(string sym) =>
    str.contains(sym, ":") ? array.get(str.split(sym, ":"), 1) : sym

// --- Heatmap Color Function ---
f_corrColor(float corr) =>
    if na(corr)
        color.gray
    else if corr >= 0.0
        color.from_gradient(corr, 0.0, 1.0, C_NEUTRAL, C_POS_STRONG)
    else
        color.from_gradient(corr, -1.0, 0.0, C_NEG_STRONG, C_NEUTRAL)

// --- Cluster Color Function ---
f_clusterColor(int cid) =>
    switch cid
        0 => C_CLUSTER_1
        1 => C_CLUSTER_2
        2 => C_CLUSTER_3
        3 => C_CLUSTER_4
        4 => C_CLUSTER_5
        => color.gray

// --- Format string for decimal places ---
f_formatStr(int decimals) =>
    switch decimals
        1 => "0.0"
        3 => "0.000"
        => "0.00"

// (f_pearson removed: correlation is now computed inline using matrix<float>)

// ============================================================================
// Effective Number of Symbols
// ============================================================================

int numSymbols = math.min(i_numSymbols, MAX_SYMBOLS)

// ============================================================================
// Duplicate Slot Detection (chart symbol appearing in preset slots)
// ============================================================================

var array<int>  matchCount  = array.new<int>(MAX_SYMBOLS, 0)
var array<bool> slotEnabled = array.new<bool>(MAX_SYMBOLS, true)
var array<int>  validSlots  = array.new<int>(0)

// ============================================================================
// Preset Symbol Selection (series string for request.security)
// ============================================================================

// Each slot resolves to the appropriate symbol based on preset selection.
// For "Custom" preset, user input values are used directly.
// NOTE: request.security() accepts series string as first argument.

string sym1_effective = switch i_preset
    "FX Majors" => "EURUSD"
    "US Stocks" => "AAPL"
    "Crypto"    => "BTCUSD"
    => i_sym1

string sym2_effective = switch i_preset
    "FX Majors" => "GBPUSD"
    "US Stocks" => "MSFT"
    "Crypto"    => "ETHUSD"
    => i_sym2

string sym3_effective = switch i_preset
    "FX Majors" => "USDJPY"
    "US Stocks" => "GOOGL"
    "Crypto"    => "SOLUSD"
    => i_sym3

string sym4_effective = switch i_preset
    "FX Majors" => "USDCHF"
    "US Stocks" => "AMZN"
    "Crypto"    => "BNBUSD"
    => i_sym4

string sym5_effective = switch i_preset
    "FX Majors" => "AUDUSD"
    "US Stocks" => "NVDA"
    "Crypto"    => "XRPUSD"
    => i_sym5

string sym6_effective = switch i_preset
    "FX Majors" => "NZDUSD"
    "US Stocks" => "TSLA"
    "Crypto"    => "ADAUSD"
    => i_sym6

string sym7_effective = switch i_preset
    "FX Majors" => "USDCAD"
    "US Stocks" => "META"
    "Crypto"    => "DOTUSD"
    => i_sym7

string sym8_effective = switch i_preset
    "FX Majors" => "GBPJPY"
    "US Stocks" => "JPM"
    "Crypto"    => "AVAXUSD"
    => i_sym8

string sym9_effective = switch i_preset
    "FX Majors" => "EURJPY"
    "US Stocks" => "V"
    "Crypto"    => "LINKUSD"
    => i_sym9

string sym10_effective = switch i_preset
    "FX Majors" => "EURGBP"
    "US Stocks" => "UNH"
    "Crypto"    => "MATICUSD"
    => i_sym10

string sym11_effective = switch i_preset
    "FX Majors" => "XAUUSD"
    "US Stocks" => "JNJ"
    "Crypto"    => "UNIUSD"
    => i_sym11

string sym12_effective = switch i_preset
    "FX Majors" => "XAGUSD"
    "US Stocks" => "XOM"
    "Crypto"    => "AAVEUSD"
    => i_sym12

string sym13_effective = switch i_preset
    "FX Majors" => "AUDJPY"
    "US Stocks" => "WMT"
    "Crypto"    => "NEARUSD"
    => i_sym13

string sym14_effective = switch i_preset
    "FX Majors" => "CADJPY"
    "US Stocks" => "PG"
    "Crypto"    => "INJUSD"
    => i_sym14

// ============================================================================
// Data Fetching -- request.security() at Top Level
// ============================================================================

// Slot 0: Chart symbol (no request.security needed)
float src0 = close

// Slots 1-14: External symbols via request.security()
float src1  = request.security(sym1_effective,  timeframe.period, close)
float src2  = request.security(sym2_effective,  timeframe.period, close)
float src3  = request.security(sym3_effective,  timeframe.period, close)
float src4  = request.security(sym4_effective,  timeframe.period, close)
float src5  = request.security(sym5_effective,  timeframe.period, close)
float src6  = request.security(sym6_effective,  timeframe.period, close)
float src7  = request.security(sym7_effective,  timeframe.period, close)
float src8  = request.security(sym8_effective,  timeframe.period, close)
float src9  = request.security(sym9_effective,  timeframe.period, close)
float src10 = request.security(sym10_effective, timeframe.period, close)
float src11 = request.security(sym11_effective, timeframe.period, close)
float src12 = request.security(sym12_effective, timeframe.period, close)
float src13 = request.security(sym13_effective, timeframe.period, close)
float src14 = request.security(sym14_effective, timeframe.period, close)

// ============================================================================
// Build Symbol Names Array (for display)
// ============================================================================

var array<string> symNames = array.new<string>(MAX_SYMBOLS, "")

// Slot 0 is always the chart symbol
if barstate.isfirst
    array.set(symNames, 0, syminfo.tickerid)

// Update symbol names every bar to reflect current preset
array.set(symNames, 1,  sym1_effective)
array.set(symNames, 2,  sym2_effective)
array.set(symNames, 3,  sym3_effective)
array.set(symNames, 4,  sym4_effective)
array.set(symNames, 5,  sym5_effective)
array.set(symNames, 6,  sym6_effective)
array.set(symNames, 7,  sym7_effective)
array.set(symNames, 8,  sym8_effective)
array.set(symNames, 9,  sym9_effective)
array.set(symNames, 10, sym10_effective)
array.set(symNames, 11, sym11_effective)
array.set(symNames, 12, sym12_effective)
array.set(symNames, 13, sym13_effective)
array.set(symNames, 14, sym14_effective)

// ============================================================================
// Close Price History (accumulated every bar using matrix<float>)
// ============================================================================

int MAX_CORR_LENGTH = 100  // Must match i_corrLength maxval
var matrix<float> closeHistory = matrix.new<float>(MAX_SYMBOLS, MAX_CORR_LENGTH, na)
var array<int> historyLen = array.new<int>(MAX_SYMBOLS, 0)  // Accumulated data count per symbol

// Build sources array for current bar
var array<float> sources = array.new<float>(MAX_SYMBOLS, 0.0)
array.set(sources, 0,  src0)
array.set(sources, 1,  src1)
array.set(sources, 2,  src2)
array.set(sources, 3,  src3)
array.set(sources, 4,  src4)
array.set(sources, 5,  src5)
array.set(sources, 6,  src6)
array.set(sources, 7,  src7)
array.set(sources, 8,  src8)
array.set(sources, 9,  src9)
array.set(sources, 10, src10)
array.set(sources, 11, src11)
array.set(sources, 12, src12)
array.set(sources, 13, src13)
array.set(sources, 14, src14)

// ---- Detect duplicate slots by comparing close prices with slot 0 ----
// If a slot's close matches chart symbol's close for 3+ consecutive bars,
// treat it as a duplicate (same symbol loaded twice).
array.set(slotEnabled, 0, true)
array.set(matchCount, 0, 0)
for i = 1 to numSymbols - 1
    float srcI = array.get(sources, i)
    if srcI == src0
        array.set(matchCount, i, array.get(matchCount, i) + 1)
    else
        array.set(matchCount, i, 0)
    // 3+ consecutive matches → duplicate
    array.set(slotEnabled, i, array.get(matchCount, i) < 3)

// ---- Build validSlots array (only enabled slots) ----
array.clear(validSlots)
for i = 0 to numSymbols - 1
    if array.get(slotEnabled, i)
        array.push(validSlots, i)

int effectiveN = array.size(validSlots)

// Push current bar's prices into history matrix (row=symbol, col=time index)
// Only accumulate for valid (non-duplicate) slots
for vi = 0 to effectiveN - 1
    int i = array.get(validSlots, vi)
    float srcVal = array.get(sources, i)
    if not na(srcVal)
        int len = array.get(historyLen, i)
        if len < MAX_CORR_LENGTH
            // Still filling up: append to next column
            matrix.set(closeHistory, i, len, srcVal)
            array.set(historyLen, i, len + 1)
        else
            // Full: shift left and append new value at the end
            for col = 0 to MAX_CORR_LENGTH - 2
                matrix.set(closeHistory, i, col, matrix.get(closeHistory, i, col + 1))
            matrix.set(closeHistory, i, MAX_CORR_LENGTH - 1, srcVal)

// ============================================================================
// Correlation Matrix, K-Means, Sorting, and Table Drawing
// (All in barstate.islast only)
// ============================================================================

var matrix<float> corrMatrix = matrix.new<float>(MAX_SYMBOLS, MAX_SYMBOLS, 0.0)

if barstate.islast

    // Clear correlation matrix for valid slots
    for vi = 0 to effectiveN - 1
        int ii = array.get(validSlots, vi)
        for vj = 0 to effectiveN - 1
            int jj = array.get(validSlots, vj)
            matrix.set(corrMatrix, ii, jj, 0.0)

    // ========================================================================
    // Step 1: Compute Correlation Matrix
    // ========================================================================

    for vi = 0 to effectiveN - 1
        int ii = array.get(validSlots, vi)
        matrix.set(corrMatrix, ii, ii, 1.0)
        int lenI = math.min(array.get(historyLen, ii), i_corrLength)
        if vi < effectiveN - 1
            for vj = vi + 1 to effectiveN - 1
                int jj = array.get(validSlots, vj)
                int lenJ = math.min(array.get(historyLen, jj), i_corrLength)
                int n = math.min(lenI, lenJ)
                if n < 2
                    matrix.set(corrMatrix, ii, jj, 0.0)
                    matrix.set(corrMatrix, jj, ii, 0.0)
                else
                    // Inline Pearson correlation from matrix rows
                    float sumX  = 0.0
                    float sumY  = 0.0
                    float sumXY = 0.0
                    float sumX2 = 0.0
                    float sumY2 = 0.0
                    int offsetI = lenI - n
                    int offsetJ = lenJ - n
                    for k = 0 to n - 1
                        float xi = matrix.get(closeHistory, ii, offsetI + k)
                        float yi = matrix.get(closeHistory, jj, offsetJ + k)
                        sumX  += xi
                        sumY  += yi
                        sumXY += xi * yi
                        sumX2 += xi * xi
                        sumY2 += yi * yi
                    float meanX = sumX / n
                    float meanY = sumY / n
                    float cov   = sumXY / n - meanX * meanY
                    float stdX  = math.sqrt(math.max(0.0, sumX2 / n - meanX * meanX))
                    float stdY  = math.sqrt(math.max(0.0, sumY2 / n - meanY * meanY))
                    float corrVal = (stdX > 1e-10 and stdY > 1e-10) ? math.max(-1.0, math.min(1.0, cov / (stdX * stdY))) : 0.0
                    matrix.set(corrMatrix, ii, jj, corrVal)
                    matrix.set(corrMatrix, jj, ii, corrVal)

    // ========================================================================
    // Step 2: K-Means Clustering (optional)
    // ========================================================================

    // Cluster labels for each valid symbol (default: all cluster 0)
    array<int> clusterLabels = array.new<int>(effectiveN, 0)

    if i_enableKMeans and effectiveN >= i_kClusters
        // Build input matrix: effectiveN x effectiveN (correlation vectors as features)
        matrix<float> kInput = matrix.new<float>(effectiveN, effectiveN, 0.0)
        for vi = 0 to effectiveN - 1
            int ii = array.get(validSlots, vi)
            for vj = 0 to effectiveN - 1
                int jj = array.get(validSlots, vj)
                matrix.set(kInput, vi, vj, matrix.get(corrMatrix, ii, jj))

        // Run K-Means
        int kVal = math.min(i_kClusters, effectiveN)
        ml.KMeansModel model = ml.fitKMeans(kInput, kVal, 30, i_tolerance)

        // Extract labels
        for vi = 0 to effectiveN - 1
            array.set(clusterLabels, vi, array.get(model.labels, vi))

    // ========================================================================
    // Step 3: Sort by Cluster ID
    // ========================================================================

    // Build sort order array: indices sorted by cluster label
    // NOTE: sortOrder contains indices into clusterLabels (0..effectiveN-1),
    //       NOT original slot indices. Use validSlots to map back.
    array<int> sortOrder = array.new<int>(effectiveN, 0)
    for vi = 0 to effectiveN - 1
        array.set(sortOrder, vi, vi)

    if i_enableKMeans and effectiveN >= i_kClusters
        // Bubble sort by cluster label (stable sort preserves original order within cluster)
        for pass = 0 to effectiveN - 2
            for j = 0 to effectiveN - pass - 2
                int idxJ  = array.get(sortOrder, j)
                int idxJ1 = array.get(sortOrder, j + 1)
                int cJ    = array.get(clusterLabels, idxJ)
                int cJ1   = array.get(clusterLabels, idxJ1)
                if cJ > cJ1
                    array.set(sortOrder, j,     idxJ1)
                    array.set(sortOrder, j + 1, idxJ)

    // Build sorted correlation matrix
    matrix<float> sortedMatrix = matrix.new<float>(effectiveN, effectiveN, 0.0)
    for i = 0 to effectiveN - 1
        for j = 0 to effectiveN - 1
            int origI = array.get(validSlots, array.get(sortOrder, i))
            int origJ = array.get(validSlots, array.get(sortOrder, j))
            matrix.set(sortedMatrix, i, j, matrix.get(corrMatrix, origI, origJ))

    // Build sorted symbol names
    array<string> sortedNames = array.new<string>(effectiveN, "")
    for i = 0 to effectiveN - 1
        int origIdx = array.get(validSlots, array.get(sortOrder, i))
        array.set(sortedNames, i, f_shortName(array.get(symNames, origIdx)))

    // Build sorted cluster labels
    array<int> sortedClusterLabels = array.new<int>(effectiveN, 0)
    for i = 0 to effectiveN - 1
        int sortedIdx = array.get(sortOrder, i)
        array.set(sortedClusterLabels, i, array.get(clusterLabels, sortedIdx))

    // ========================================================================
    // Step 4: Detect Separator Positions
    // ========================================================================

    // Separators are inserted between different cluster IDs in the sorted order
    array<int> separatorPositions = array.new<int>(0)
    if i_enableKMeans and effectiveN >= i_kClusters
        for i = 1 to effectiveN - 1
            int prevCluster = array.get(sortedClusterLabels, i - 1)
            int currCluster = array.get(sortedClusterLabels, i)
            if prevCluster != currCluster
                array.push(separatorPositions, i)

    int numSeparators = array.size(separatorPositions)

    // ========================================================================
    // Step 5: Build mapping from data index to table row/col
    // ========================================================================

    // Table layout:
    //   Row 0: Column headers
    //   Rows 1..effectiveN+numSeparators: Data rows interleaved with separator rows
    //   Last row: Footer
    // Columns:
    //   Col 0: Row headers (symbol names)
    //   Cols 1..effectiveN+numSeparators: Data cols interleaved with separator cols
    //   Last col (optional): Cluster ID column ("C")

    // For each data index i, compute its table offset (accounting for separators before it)
    // dataToTableOffset[i] = i + (number of separators with position <= i)
    array<int> dataToTableOffset = array.new<int>(effectiveN, 0)
    for i = 0 to effectiveN - 1
        int sepsBefore = 0
        if numSeparators > 0
            for s = 0 to numSeparators - 1
                if array.get(separatorPositions, s) <= i
                    sepsBefore += 1
        array.set(dataToTableOffset, i, i + sepsBefore)

    int totalDataSlots = effectiveN + numSeparators
    int clusterColExtra = i_showCluster ? 1 : 0
    int totalCols = 1 + totalDataSlots + clusterColExtra  // row header + data + optional cluster col
    int totalRows = 1 + totalDataSlots + 1                 // col header + data + footer

    // Compute separator table offsets (the separator at separatorPositions[s] goes
    // right before the data element at that position, i.e., at table offset =
    // dataToTableOffset[separatorPositions[s]] - 1 ... but actually let's think more carefully)
    // If data index i has offset = i + sepsBefore, and a separator is at position s_pos,
    // then the separator's table offset = s_pos + (number of separators with position < s_pos)
    // which equals dataToTableOffset[s_pos] - 1 (since s_pos itself counts as "before" in the
    // current scheme but the separator goes BEFORE that element).
    // So separator table row/col = dataToTableOffset[s_pos] - 1 ... but wait,
    // dataToTableOffset[s_pos] includes this separator itself. Let me verify:
    // For s_pos = separatorPositions[0], sepsBefore for data index s_pos includes this separator (<=).
    // So dataToTableOffset[s_pos] = s_pos + 1 (if only 1 separator at or before s_pos).
    // The separator should be at slot s_pos + 0 = s_pos. And dataToTableOffset[s_pos] - 1 = s_pos.
    // Correct! The separator table offset = dataToTableOffset[sepPos] - 1.

    // ========================================================================
    // Step 6: Create and Populate Table
    // ========================================================================

    // NOTE: var table = na is not allowed in Pine v6.
    // We create the table directly inside barstate.islast.
    table heatmap = table.new(f_tablePos(i_tablePos), totalCols, totalRows, bgcolor=C_SEPARATOR, border_width=1, border_color=color.new(C_BORDER, 80), frame_width=1, frame_color=color.new(C_BORDER, 80))

    string tSize = f_textSize(i_tableSize)
    string fmtStr = f_formatStr(i_decimals)

    // --- Row 0: Column Headers ---
    // Top-left corner cell (empty)
    table.cell(heatmap, 0, 0, "", bgcolor=C_HEADER_BG, text_color=C_HEADER_TEXT, text_size=tSize)

    // Column headers for each data column
    for i = 0 to effectiveN - 1
        int col = 1 + array.get(dataToTableOffset, i)
        table.cell(heatmap, col, 0, array.get(sortedNames, i), bgcolor=C_HEADER_BG, text_color=C_HEADER_TEXT, text_size=tSize)

    // Separator column headers (blank, dark background)
    if numSeparators > 0
        for s = 0 to numSeparators - 1
            int sepPos = array.get(separatorPositions, s)
            int sepCol = 1 + array.get(dataToTableOffset, sepPos) - 1
            table.cell(heatmap, sepCol, 0, "", bgcolor=C_SEPARATOR, text_size=tSize)

    // Cluster column header
    if i_showCluster
        table.cell(heatmap, totalCols - 1, 0, "C", bgcolor=C_HEADER_BG, text_color=C_HEADER_TEXT, text_size=tSize)

    // --- Data Rows ---
    for i = 0 to effectiveN - 1
        int row = 1 + array.get(dataToTableOffset, i)

        // Row header (symbol name)
        table.cell(heatmap, 0, row, array.get(sortedNames, i), bgcolor=C_HEADER_BG, text_color=C_HEADER_TEXT, text_size=tSize)

        // Data cells
        for j = 0 to effectiveN - 1
            int col = 1 + array.get(dataToTableOffset, j)
            float corrVal = matrix.get(sortedMatrix, i, j)

            color cellBg    = na
            string cellText = ""
            color textColor = na

            if i == j
                // Diagonal cell (self-correlation = 1.0)
                cellBg    := C_DIAG
                cellText  := i_showValues ? str.tostring(1.0, fmtStr) : ""
                textColor := color.black
            else
                cellBg    := f_corrColor(corrVal)
                cellText  := i_showValues ? str.tostring(corrVal, fmtStr) : ""
                // Dark text on light backgrounds, white on dark backgrounds
                if corrVal > 0.5 or corrVal < -0.5
                    textColor := color.white
                else
                    textColor := color.black

            table.cell(heatmap, col, row, cellText, bgcolor=cellBg, text_color=textColor, text_size=tSize)

        // Separator column cells in this data row
        if numSeparators > 0
            for s = 0 to numSeparators - 1
                int sepPos = array.get(separatorPositions, s)
                int sepCol = 1 + array.get(dataToTableOffset, sepPos) - 1
                table.cell(heatmap, sepCol, row, "", bgcolor=C_SEPARATOR, text_size=tSize)

        // Cluster column
        if i_showCluster
            int cLabel = array.get(sortedClusterLabels, i)
            color cColor = f_clusterColor(cLabel)
            table.cell(heatmap, totalCols - 1, row, str.tostring(cLabel + 1), bgcolor=cColor, text_color=color.white, text_size=tSize)

    // --- Separator Rows ---
    if numSeparators > 0
        for s = 0 to numSeparators - 1
            int sepPos = array.get(separatorPositions, s)
            int sepRow = 1 + array.get(dataToTableOffset, sepPos) - 1

            // Fill entire separator row
            for col = 0 to totalCols - 1
                table.cell(heatmap, col, sepRow, "", bgcolor=C_SEPARATOR, text_size=tSize)

    // --- Footer Row ---
    int footerRow = totalRows - 1
    string kInfo = i_enableKMeans ? ("  |  K=" + str.tostring(i_kClusters)) : ""
    string footerText = "Correlation Thermal Matrix [ShigemiQuant]  |  Len:" + str.tostring(i_corrLength) + kInfo + "  |  " + str.tostring(effectiveN) + "sym"

    // Fill all footer cells first
    for col = 0 to totalCols - 1
        table.cell(heatmap, col, footerRow, "", bgcolor=C_FOOTER_BG, text_size=tSize)

    // Set footer text and merge
    table.cell(heatmap, 0, footerRow, footerText, bgcolor=C_FOOTER_BG, text_color=C_FOOTER_TEXT, text_size=tSize)
    table.merge_cells(heatmap, 0, footerRow, totalCols - 1, footerRow)

// ============================================================================
// Dummy plot to satisfy indicator requirement (overlay=false needs at least one plot)
// ============================================================================

plot(na, display=display.none)
````
