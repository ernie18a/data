# Simple MA TPO

- url: https://www.tradingview.com/script/oAl2nD1a/
- type: indicator
- pine_id: PUB;dfc0529b888043f1a4532dde961ca4ea
- version: 6.0

## Description

[b]Simple MA TPO[/b]

[b]■Description[/b]

[b]■Concept & Purpose[/b]
This indicator was developed with a single core concept: to discover the "true power" and foster a deeper understanding of the Time Price Opportunity (TPO) profile—often considered a super-tool in market analysis. By combining traditional TPO mechanics with market gravity (Moving Averages), this script aims to provide traders with a clearer, more visual representation of value and price deviation over time.

[b]■Originality & How It Works[/b]
While traditional TPO profiles use letters (A, B, C...) to denote time periods and static colors for volume/time areas, this script introduces two highly original mechanics to add value to the community:

Sequential Numbering: Instead of letters, each TPO block is numbered sequentially (1, 2, 3...) based on its formation order. This drastically simplifies reading the flow of time within a session.

MA Deviation Gradient Coloring: The most unique feature is its coloring logic. TPO blocks are not colored randomly. Instead, their color is determined by their deviation from a baseline Moving Average (acting as the market's center of gravity).

[b]■Calculations & Output[/b]

To ensure complete transparency in how the visual data is generated, here is the specific calculation used for the block colors:
Formula: Deviation % = ((Price / MA) - 1.0) * 100.0

Why this calculation? This calculates the exact percentage distance between the TPO block's price level and the baseline Moving Average at the time that specific block was formed. It visualizes how "overextended" the market was when time was spent at that price.

Actual Output: The output is a percentage float value (e.g., if the MA is $100 and the block price is $102, the output is 2.0 or 2%). This value is then clamped by the user-defined Max Deviation % input (default 2.0%).
Color Mapping: The clamped percentage is fed into a gradient. Negative deviations (undervalued relative to MA) shift towards Cyan, while positive deviations (overvalued) shift towards Magenta.

[b]■How to Use[/b]

Identify Value Areas: Look for the "POC" (Point of Control) line, which indicates the price level where the most time (highest number of blocks) was spent.

Assess Reversion Risk: Blocks that are bright Magenta or bright Cyan indicate that time was spent far away from the Moving Average. Traders can use this to visually gauge if a breakout is sustainable or if a mean-reversion is likely.

Customize Your View: You can adjust the TPO timeframes (Daily/Weekly/Monthly), the block interval (e.g., 30 minutes), and choose your preferred MA type (SMA, EMA, WMA, HMA).

Disclaimer: This indicator is designed for educational and analytical purposes. TPO is a tool for understanding market structure and time spent at price levels, not a standalone trading signal generator. Past performance of price around value areas does not guarantee future results.

[b]説明文

コンセプトと開発目的[/b]

このインジケーターは「相場分析におけるスーパーツールであるTPO（マーケットプロファイル）の真の力を見出し、深い理解を得る」というコアコンセプトのもとに開発されました。伝統的なTPOの仕組みと相場の重心（移動平均線）を融合させることで、時間の経過に伴う価値の推移と価格の乖離を、より視覚的かつ明確にトレーダーに提供します。

[b]オリジナリティと機能[/b]

従来のTPOプロファイルは時間枠をアルファベット（A、B、C...）で表し、静的な色を使用しますが、このスクリプトはコミュニティに新たな付加価値を提供するために2つの独自機能を備えています。

連番表示: アルファベットの代わりに、各TPOブロックは形成された順番に沿って（1、2、3...）と連番で表示されます。これにより、セッション内での時間の流れを直感的に読み取ることが劇的に容易になります。
MA乖離率によるグラデーション着色: 最大の特徴はその着色ロジックです。TPOブロックは、相場の重心として機能する基準移動平均線（MA）からの「乖離率」に基づいて色が決定されます。

[b]計算式と出力値の根拠[/b]

視覚データがどのように生成されているかを完全に透明化するため、ブロックの着色に使用されている具体的な計算式を明記します：

計算式: 乖離率(%) = ((価格 / MA) - 1.0) * 100.0

なぜこの計算なのか？ この式は、特定のTPOブロックが形成された瞬間において、その価格水準が基準となる移動平均線からパーセンテージでどの程度離れているか（価格がどれほど伸びきっているか）を正確に測定するために使用されます。

実際の出力値: 出力はパーセンテージの浮動小数点数になります（例：MAが100ドルで、ブロックの価格が102ドルの場合、出力は 2.0 つまり2%になります）。この値は、ユーザーが設定した「最大の限界乖離率」（デフォルト2.0%）によって制限されます。

カラーマッピング: 制限されたパーセンテージはグラデーション関数に渡されます。マイナスの乖離（MAに対して割安）はシアン（水色）に近づき、プラスの乖離（割高）はマゼンタ（赤紫）に近づくように色が変化します。

[b]使用方法[/b]

バリューエリアの特定: 最も多くの時間（ブロック数）が費やされた価格帯を示す「POC（Point of Control）」ラインを探し、相場の中心的価値を把握します。

平均回帰リスクの評価: 鮮やかなマゼンタやシアンのブロックは、移動平均線から遠く離れた場所で時間が費やされたことを示します。トレーダーはこれを視覚的な基準として、ブレイクアウトが持続可能か、あるいは平均回帰（MAへの戻り）が起こりやすいかを判断できます。

柔軟なカスタマイズ: TPOの期間（日/週/月）、ブロックの区切り（例：30分）、そして好みのMAタイプ（SMA、EMA、WMA、HMA）を自由に変更できます。

免責事項：このインジケーターは教育および分析目的で設計されています。TPOは市場構造と価格帯での滞在時間を理解するためのツールであり、単独の売買シグナルではありません。バリューエリア周辺での過去の価格動向は、将来の結果を保証するものではありません。

## Source Code

````pine
// © ALT_analyst_experimental
// Educational TPO: Standard Period & MA Deviation (Replay Safe)
//@version=6
indicator("Simple MA TPO - V2", overlay=true, max_boxes_count=5000, max_lines_count=500, max_labels_count=500)

// ~~ Constants {
const string GRP_TPO = "★ 1. TPO Period & Size Settings"
const string TITLE_TPO_PER = "Profile Period (Day/Week/Month)"
const string TITLE_TPO_BLK = "Block Interval (Minutes)"
const string TITLE_LTF = "LTF (Footprint)"
const string TT_LTF = "Must specify a timeframe lower than the chart"
const string TITLE_TICK = "Price Row Height (Ticks)"
const string TITLE_AUTO = "Auto Scale Price Rows"
const string TITLE_TXT_MOD = "TPO Text Mode"
const string OPT_ALPHA = "Alphabet (A-Z, a-z)"
const string OPT_NUM = "Numbers (1, 2, 3...)"

const string GRP_VA = "★ 2. Value Area & IB Settings"
const string TITLE_VA_PCT = "Value Area %"
const string TITLE_IB_BLK = "Initial Balance Blocks"
const string TT_IB_BLK = "Number of blocks for IB calculation"
const string TITLE_EXT = "Extend POC/VA/IB Lines"

const string GRP_SP = "★ 3. Single Prints Settings"
const string TITLE_SHOW_SP = "Show Single Prints"
const string TITLE_C_SP = "Single Print Color"

const string GRP_MA = "★ 4. Baseline Moving Average (Center of Gravity)"
const string TITLE_MA_TYP = "MA Type"
const string OPT_SMA = "SMA"
const string OPT_EMA = "EMA"
const string OPT_WMA = "WMA"
const string OPT_HMA = "HMA"
const string TITLE_MA_LEN = "MA Length"

const string GRP_COLOR = "★ 5. Gradient Settings"
const string TITLE_DEV = "Max Deviation % for Color Saturation"

const string GRP_OPT = "★ 6. Performance Settings"
const string TITLE_MAX_SESS = "Max Past Sessions to Display"

const string GRP_STYLE = "★ 7. Styling & Visuals"
const string TITLE_TBOX_SZ = "TPO Box Text Size"
const string OPT_TINY = "Tiny"
const string OPT_SMALL = "Small"
const string OPT_NORM = "Normal"
const string OPT_LARGE = "Large"
const string TITLE_LBL_SZ = "Line Label Size"
const string TITLE_CPOC = "POC Color"
const string TITLE_CVA = "VAH / VAL Color"
const string TITLE_CIB = "IB Range Color"
//~~~~~}

// ~~ Inputs {
string tpo_period = input.timeframe("D", TITLE_TPO_PER, group=GRP_TPO)
string tpo_block_size = input.timeframe("30", TITLE_TPO_BLK, group=GRP_TPO)
string ltf_res = input.timeframe("5", TITLE_LTF, group=GRP_TPO, tooltip=TT_LTF)
int tpo_ticks = input.int(10, TITLE_TICK, minval=1, group=GRP_TPO)
bool tpo_auto_scale = input.bool(true, TITLE_AUTO, group=GRP_TPO)
string tpo_text_mode = input.string(OPT_ALPHA, TITLE_TXT_MOD, options=[OPT_ALPHA, OPT_NUM], group=GRP_TPO)

float va_pct = input.float(70.0, TITLE_VA_PCT, minval=1.0, maxval=100.0, group=GRP_VA)
int ib_blocks = input.int(2, TITLE_IB_BLK, minval=1, group=GRP_VA, tooltip=TT_IB_BLK)
bool extend_lines = input.bool(true, TITLE_EXT, group=GRP_VA)

bool show_sp = input.bool(true, TITLE_SHOW_SP, group=GRP_SP)
color c_sp = input.color(color.new(color.fuchsia, 30), TITLE_C_SP, group=GRP_SP)

string ma_type = input.string(OPT_EMA, TITLE_MA_TYP, options=[OPT_SMA, OPT_EMA, OPT_WMA, OPT_HMA], group=GRP_MA)
int ma_len = input.int(20, TITLE_MA_LEN, group=GRP_MA)

float dev_limit = input.float(2.0, TITLE_DEV, step=0.5, group=GRP_COLOR)

int max_sess = input.int(3, TITLE_MAX_SESS, minval=1, maxval=5, group=GRP_OPT)

string tpo_txt_size = input.string(OPT_TINY, TITLE_TBOX_SZ, options=[OPT_TINY, OPT_SMALL, OPT_NORM, OPT_LARGE], group=GRP_STYLE)
string lbl_txt_size = input.string(OPT_SMALL, TITLE_LBL_SZ, options=[OPT_TINY, OPT_SMALL, OPT_NORM, OPT_LARGE], group=GRP_STYLE)

color c_poc = input.color(color.white, TITLE_CPOC, group=GRP_STYLE)
color c_va = input.color(color.aqua, TITLE_CVA, group=GRP_STYLE)
color c_ib = input.color(color.orange, TITLE_CIB, group=GRP_STYLE)
//~~~~~}

// ~~ Helpers {
var string[] alpha_arr = array.from("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")

f_get_tpo_char(int idx) =>
    array.get(alpha_arr, idx % 52)

f_ma(series float _src, simple int _len, simple string _type) =>
    float _res = _src
    switch _type
        OPT_SMA => _res := ta.sma(_src, _len)
        OPT_EMA => _res := ta.ema(_src, _len)
        OPT_WMA => _res := ta.wma(_src, _len)
        OPT_HMA => _res := ta.hma(_src, _len)
        => _res := ta.sma(_src, _len)
    _res

f_get_size(string s) =>
    s == OPT_TINY ? size.tiny : s == OPT_SMALL ? size.small : s == OPT_NORM ? size.normal : size.large

f_get_color_from_dev(float p_val, float ma_val, float dev_lmt) =>
    float dev_pct = (ma_val != 0 and not na(ma_val)) ? ((p_val / ma_val) - 1.0) * 100.0 : 0.0
    float c_dev = math.max(-dev_lmt, math.min(dev_lmt, nz(dev_pct, 0.0))) 
    color.from_gradient(c_dev, -dev_lmt, dev_lmt, color.rgb(0, 255, 255, 40), color.rgb(255, 0, 128, 40))
//~~~~~}

// ~~ Calculation & Drawing {
var string applied_tpo_size = f_get_size(tpo_txt_size)
var string applied_lbl_size = f_get_size(lbl_txt_size)

float baseline_ma = f_ma(close, ma_len, ma_type)
plot(baseline_ma, "Baseline MA", color=color.new(color.white, 0), linewidth=2)

type TPO_Col
    float[] prices
    float ma_val 

type TPO_Session
    int start_x
    int end_x
    float h
    float l
    TPO_Col[] cols

var TPO_Session[] sessions = array.new<TPO_Session>()

bool is_new_period = ta.change(time(tpo_period)) != 0
bool is_new_block  = ta.change(time(tpo_block_size)) != 0

if is_new_period or array.size(sessions) == 0
    array.push(sessions, TPO_Session.new(bar_index, bar_index, high, low, array.new<TPO_Col>()))
    if array.size(sessions) > max_sess
        array.shift(sessions)

TPO_Session current_session = array.get(sessions, array.size(sessions) - 1)
current_session.end_x := bar_index
current_session.h := math.max(current_session.h, high)
current_session.l := math.min(current_session.l, low)

if is_new_block or array.size(current_session.cols) == 0
    array.push(current_session.cols, TPO_Col.new(array.new_float(), nz(baseline_ma, close)))

TPO_Col current_col = array.get(current_session.cols, array.size(current_session.cols) - 1)

[ltf_closes] = request.security_lower_tf(syminfo.tickerid, ltf_res, [close])
if array.size(ltf_closes) > 0
    for i = 0 to array.size(ltf_closes) - 1
        array.push(current_col.prices, array.get(ltf_closes, i))

var box[] drawn_boxes = array.new_box()
var line[] drawn_lines = array.new_line()
var label[] drawn_labels = array.new_label()

float global_atr = ta.atr(14)

if barstate.islast
    while array.size(drawn_boxes) > 0
        box.delete(array.shift(drawn_boxes))
    while array.size(drawn_lines) > 0
        line.delete(array.shift(drawn_lines))
    while array.size(drawn_labels) > 0
        label.delete(array.shift(drawn_labels))

    int total_boxes = 0

    for s_idx = array.size(sessions) - 1 to 0
        TPO_Session sess = array.get(sessions, s_idx)
        int c_len = array.size(sess.cols)
        if c_len == 0
            continue
            
        float g_high = sess.h
        float g_low  = sess.l
        
        float step_price = syminfo.mintick * tpo_ticks
        if tpo_auto_scale
            float s_range = g_high - g_low
            float safe_atr = nz(global_atr, syminfo.mintick * 10)
            float auto_step = s_range > 0 ? (s_range / 30.0) : (safe_atr * 0.05)
            step_price := math.max(auto_step, syminfo.mintick)
            
        if na(step_price) or step_price <= 0
            step_price := syminfo.mintick
            
        int tbl_rows = math.ceil((g_high - g_low) / step_price) + 1
        tbl_rows := math.max(1, math.min(tbl_rows, 500)) 
        
        int base_x = sess.start_x

        int[] row_block_counts = array.new_int(tbl_rows, 0)
        int[] current_stack = array.new_int(tbl_rows, 0)

        float ib_high = -999999.0
        float ib_low  = 999999.0
        int ib_loop_max = math.min(c_len - 1, ib_blocks - 1)

        for c_idx = 0 to c_len - 1
            TPO_Col col = array.get(sess.cols, c_idx)
            int d_len = array.size(col.prices)
            float current_base_ma = col.ma_val 
            
            string block_text = tpo_text_mode == OPT_ALPHA ? f_get_tpo_char(c_idx) : str.tostring(c_idx + 1)
            
            int[] row_filled_in_col = array.new_int(tbl_rows, 0)
            
            if d_len > 0
                for i = 0 to d_len - 1
                    float p_val = array.get(col.prices, i)
                    
                    if c_idx <= ib_loop_max
                        ib_high := math.max(ib_high, p_val)
                        ib_low  := math.min(ib_low, p_val)

                    int r_idx = step_price > 0 ? math.floor((g_high - p_val) / step_price) : 0
                    r_idx := math.max(0, math.min(tbl_rows - 1, r_idx))
                    
                    if array.get(row_filled_in_col, r_idx) == 0
                        array.set(row_filled_in_col, r_idx, 1)
                        array.set(row_block_counts, r_idx, array.get(row_block_counts, r_idx) + 1)
                        
                        int stack_count = array.get(current_stack, r_idx)
                        int left_x = base_x + stack_count
                        float top_y = g_high - (r_idx * step_price)
                        float bottom_y = top_y - step_price
                        float mid_y = (top_y + bottom_y) / 2.0
                        
                        color block_col = f_get_color_from_dev(mid_y, current_base_ma, dev_limit)
                        
                        if total_boxes < 4900
                            box b = box.new(left=left_x, top=top_y, right=left_x+1, bottom=bottom_y, border_width=1, border_color=color.new(color.white, 80), bgcolor=block_col, text=block_text, text_size=applied_tpo_size, text_color=color.white)
                            array.push(drawn_boxes, b)
                            total_boxes += 1
                            array.set(current_stack, r_idx, stack_count + 1)

        int max_count = -1
        int poc_idx = 0
        int max_right_x = base_x
        int total_tpo_blocks = 0

        for r_idx = 0 to tbl_rows - 1
            int c_count = array.get(row_block_counts, r_idx)
            total_tpo_blocks += c_count
            if c_count > max_count
                max_count := c_count
                poc_idx := r_idx
            max_right_x := math.max(max_right_x, base_x + c_count)

        int target_va = math.round(total_tpo_blocks * (va_pct / 100.0))
        int current_va = array.get(row_block_counts, poc_idx)
        int upper_idx = poc_idx - 1 
        int lower_idx = poc_idx + 1 
        int vah_idx = poc_idx
        int val_idx = poc_idx

        while current_va < target_va and (upper_idx >= 0 or lower_idx < tbl_rows)
            int up_count = upper_idx >= 0 ? array.get(row_block_counts, upper_idx) : -1
            int dn_count = lower_idx < tbl_rows ? array.get(row_block_counts, lower_idx) : -1

            if up_count >= dn_count and up_count != -1
                current_va += up_count
                vah_idx := upper_idx
                upper_idx -= 1
            else if dn_count != -1
                current_va += dn_count
                val_idx := lower_idx
                lower_idx += 1
            else
                break

        float poc_y = g_high - (poc_idx * step_price) - (step_price / 2.0)
        float vah_y = g_high - (vah_idx * step_price)
        float val_y = g_high - (val_idx * step_price) - step_price
        
        int line_end_x = extend_lines ? max_right_x + 10 : max_right_x

        array.push(drawn_lines, line.new(base_x, poc_y, line_end_x, poc_y, color=c_poc, width=2))
        array.push(drawn_labels, label.new(line_end_x, poc_y, "POC", style=label.style_label_left, color=color.new(color.white, 100), textcolor=c_poc, size=applied_lbl_size))

        array.push(drawn_lines, line.new(base_x, vah_y, line_end_x, vah_y, color=color.new(c_va, 20), width=1, style=line.style_dashed))
        array.push(drawn_labels, label.new(line_end_x, vah_y, "VAH", style=label.style_label_left, color=color.new(color.white, 100), textcolor=c_va, size=applied_lbl_size))
        array.push(drawn_lines, line.new(base_x, val_y, line_end_x, val_y, color=color.new(c_va, 20), width=1, style=line.style_dashed))
        array.push(drawn_labels, label.new(line_end_x, val_y, "VAL", style=label.style_label_left, color=color.new(color.white, 100), textcolor=c_va, size=applied_lbl_size))

        if ib_high != -999999.0 and ib_low != 999999.0
            array.push(drawn_lines, line.new(base_x, ib_high, line_end_x, ib_high, color=color.new(c_ib, 0), width=1, style=line.style_dotted))
            array.push(drawn_labels, label.new(line_end_x, ib_high, "IBH", style=label.style_label_left, color=color.new(color.white, 100), textcolor=c_ib, size=applied_lbl_size))
            array.push(drawn_lines, line.new(base_x, ib_low, line_end_x, ib_low, color=color.new(c_ib, 0), width=1, style=line.style_dotted))
            array.push(drawn_labels, label.new(line_end_x, ib_low, "IBL", style=label.style_label_left, color=color.new(color.white, 100), textcolor=c_ib, size=applied_lbl_size))

        if show_sp
            for r_idx = 0 to tbl_rows - 1
                if array.get(row_block_counts, r_idx) == 1
                    float sp_y = g_high - (r_idx * step_price) - (step_price / 2.0)
                    array.push(drawn_lines, line.new(base_x, sp_y, line_end_x, sp_y, color=c_sp, width=1, style=line.style_dotted))
//~~~~~}
````
