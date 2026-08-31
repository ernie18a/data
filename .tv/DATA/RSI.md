<!-- tradingview-pine-id: PUB;82ecfdb8cf9e4b3fa773093e1f4d2225 -->
<!-- tradingviewscripts-format: 1 -->
# RSI 背离 [精简] · 二合一

Source: https://www.tradingview.com/script/bPIm3ie9-RSI-Divergence-Resonance-System-v1/

## Description

Trading opportunity marking system based on RSI's four divergences, overbought and oversold, key moving averages, Bollinger Band support and pressure eyes.
Comes with a complex but highly manual pseudo-quantitative scoring system.

---

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════
// RSI 背离 [精简] · 二合一（价格图 + RSI 副图）
//
// 全局严格度下拉框位于“设置 → 输入”的最上方；它不会在 RSI 副图绘制控制线、控制点或额外刻度。
//   先用“标准”：信号太杂或长连线可疑时改为“严格”；明显背离漏得多时改为“宽松”。
//   “标准”逐项等于下面各组的基础设置；其他档只调整回看数量、中间阻断、配对路径检查、
//   端点放宽和路径容差，不改变右侧确认口径、RSI 区间、枢轴定义、价格口径和显示选项。
//   每次只改一档，并在同一品种、同一周期、同一段行情比较新增或消失的连线。
//
// 确认与实时显示：
//   · 历史正式信号仍须通过完整左右 RSI 枢轴确认；价格端点也不能已被右侧确认 K 线实质突破。
//   · 混合价格模式独立检查高低点与收盘价；单口径按实际端点连线，同一枢轴对双口径成立时连高低点并加粗。
//   · 同一 RSI 低点或高点若对不同旧枢轴分别成立常规与隐性背离，只保留由近到远第一个完整通过的类别。
//   · 最右侧未收盘 K 线可暂作背离、支撑眼或压力眼的候选端点；条件成立就按正式样式显示。
//   · 实时状态会随价格更新、降级或消失，不作为历史正式信号，也不触发正式警报。
//   · 支撑眼 / 压力眼默认关闭；👁 表示眼，★ 表示该已有信号端点同时位于超卖 / 超买区。
//     单独超买 / 超卖不造标签；背离 + 区域、眼 + 区域、背离 + 眼 + 区域都会显示 ★。
//
//   · “关键 EMA 救回”只处理常规背离：左侧识别和最小间隔最多各减少 1 根（最低仍为 1），
//     只用收盘价；历史正式信号继续遵守固定右侧确认，历史与实时都遵守当前档位的端点放宽和路径容差。
//   · 买卖指数是既有信号标签的可选附注，不切换模式、不单独造标签；历史指数在信号可确认时
//     锁定并写回实际事件 K 线，最右侧未收盘信号则实时更新；支持 5m 至 2M。
//   · 同方向、同类型背离若以前一条的终点作为后一条的起点，会得到有上限且不可递归放大的
//     “连续背离”增强；高周期多空并存则作为冲突风险，不再被当成没有背景。
// 资源边界：最多保留 225 次正式背离、20 个独立眼，
// 并为同一实时 K 线的临时图形保留额度。
// ══════════════════════════════════════════════════════════════════════════════
indicator("RSI 背离 [精简] · 二合一", "RSI Div 精简 · 二合一", overlay = false, precision = 2, max_labels_count = 500, max_lines_count = 500)

// ══════════ 设置：按用户实际调整顺序排列 ══════════
gS = "1. 全局严格度"
S_LOOSE  = "宽松"
S_NORMAL = "标准"
S_STRICT = "严格"
strictChoice = input.string(S_NORMAL, "检测严格度", options = [S_LOOSE, S_NORMAL, S_STRICT], group = gS, display = display.none, tooltip = "建议先用『标准』，它完全采用下面各组的基础设置。\n宽松：回看较早枢轴多 1 个，端点附近多放宽 1 根，价格与 RSI 路径容差 ×1.5，并关闭『任一侧更强就阻断』；仍遵守你设置的中间阻断、路径开关和右侧确认，适合补回结构干净但只差一点通过的背离。\n严格：回看较早枢轴少 1 个，端点放宽减少 1 根（最低为 0），路径容差 ×0.5，并强制开启中间阻断与价格 / RSI 路径检查；『任一侧更强就阻断』仍由第 6 组开关决定，避免为降噪而过度漏报。\n选择方法：明显背离漏得多时用宽松；跨越结构的长连线或轻微毛刺信号偏多时用严格。每次只改一档，并在同一品种、周期和行情区间比较新增或消失的连线。\n三档共用同一套右侧确认口径，也不改变 RSI 区间、枢轴定义、价格口径或信号类别。严格度不是买卖信号强度评分。同一 RSI 低点或高点若常规与隐性背离分别成立，只保留离当前最近、最先完整通过的类别，不叠两组标签。\n已有警报继续使用创建时的脚本与设置快照；要采用新档位或新三档规则需重新创建。同一事件可能同时符合背离明细、方向汇总、眼和组合等警报条件，通常每个方向只创建一个所需层级。")

gB       = "2. 基础与确认"
rsiLen   = input.int(14, "RSI 长度", minval = 2, maxval = 500, group = gB, tooltip = "决定 RSI 对价格变化的反应速度，也会改变所有枢轴和背离。\n想更快捕捉短线变化可调小；RSI 转折过密、信号太杂时可调大。允许 2～500；更长的 RSI 会显著增加多周期预热和加载成本。\n不确定时保持 14。调整后重点观察：RSI 的高低点是否仍对应你肉眼认可的行情转折。")
rsiSrc   = input.source(close, "RSI 数据源", group = gB, tooltip = "选择用哪组价格计算 RSI。『收盘价』适合大多数情况。\n只有当你的交易规则明确依据开盘价、高点或低点时才建议更改。\n更改后全部 RSI、枢轴、历史信号和警报都会重新计算。")
pivLeft  = input.int(4, "左侧识别范围（K 线数）", minval = 1, maxval = 50, group = gB, display = display.none, tooltip = "候选 RSI 转折必须比左边这么多根 K 线更高或更低，才有资格成为枢轴。\n想识别更小的局部转折可调小；普通锯齿被大量当作连线端点时可调大。\n调整后观察背离线端点是否落在你认可的 RSI 转折处：明显转折不应总被略过，普通锯齿也不应大量入选。")
pivRight = input.int(1, "右侧确认范围（K 线数）", minval = 1, maxval = 50, group = gB, display = display.none, tooltip = "历史正式信号需要候选 RSI 枢轴右边这么多根 K 线收盘后才能确认；这些确认 K 线也不能已经把相应的影线 / 收盘价格端点实质突破。混合价格模式会分别检查两种口径，一种失效时仍可由另一种保留。轻微突破按第 6 组的基础价格容差处理，并限制在 ATR14 × 0.15 以内；该确认口径不随三档严格度改变。\n最右侧未收盘 K 线不必等待未来确认：实时条件暂时成立就按正常样式显示，但可能随价格变化而消失，也不作为历史正式信号或触发正式警报。\n想更快确认历史信号用 1；假转折较多时可调大。调整时观察临时标签能否在后续收盘并完成右侧确认后留下。")

gD       = "3. 信号类型"
uRB      = input.bool(true, "底背离：价格低点降低，RSI 低点抬高", group = gD, display = display.none, tooltip = "寻找价格继续创新低、但 RSI 已不再创新低的情况，通常用于观察下跌动能减弱。\n只想看顺势型隐性背离时可关闭。它不是买入指令，应结合趋势、支撑和后续价格确认。")
uHB      = input.bool(true, "隐性底背离：价格低点抬高，RSI 低点降低", group = gD, display = display.none, tooltip = "寻找价格守住更高低点、但 RSI 回撤更深的情况，通常用于观察上涨趋势是否可能延续。\n只关心反转型背离时可关闭。重点观察价格能否继续守住当前低点。")
uRS      = input.bool(true, "顶背离：价格高点抬高，RSI 高点降低", group = gD, display = display.none, tooltip = "寻找价格继续创新高、但 RSI 已不再创新高的情况，通常用于观察上涨动能减弱。\n只想看顺势型隐性背离时可关闭。它不是卖出指令，应结合趋势、阻力和后续价格确认。")
uHS      = input.bool(true, "隐性顶背离：价格高点降低，RSI 高点抬高", group = gD, display = display.none, tooltip = "寻找价格形成更低高点、但 RSI 反弹更强的情况，通常用于观察下跌趋势是否可能延续。\n只关心反转型背离时可关闭。重点观察价格能否继续受制于当前高点。")

gP       = "4. 配对范围"
nBack    = input.int(4, "最多尝试几个较早枢轴", minval = 1, maxval = 10, group = gP, display = display.none, tooltip = "这是三档的基础回看数量：标准直接使用；宽松增加 1；严格减少 1（最终限制在 1～10）。\n如果三档整体都容易漏掉远距离背离，可提高本项；三档都出现过多长连线时可降低。\n脚本从最近的旧枢轴开始向前寻找；同一当前低点或高点只保留第一个完整通过全部检查的背离类别。即使更远处还能形成另一类背离，也不会在同一端点重复标注。调整后观察保留的连线是否优先连接最近且结构清晰的旧枢轴。")
gapMin   = input.int(5, "最小间隔（K 线数）", minval = 1, maxval = 300, group = gP, display = display.none, tooltip = "两个枢轴间少于这么多根 K 线时，不参与配对。\n出现很多挤在一起的短线信号时调大；想捕捉更快的微型背离时调小。\n调整后观察连线是否只是同一小段波动内部的短连接。")
gapMax   = input.int(60, "最大间隔（K 线数）", minval = 2, maxval = 300, group = gP, display = display.none, tooltip = "两个枢轴间超过这么多根 K 线时，不参与配对。\n经常错过跨度较大的波段背离时调大；连线把不同阶段行情连在一起时调小。\n脚本会自动处理最小值大于最大值的情况，但为了易读，建议保持最小值小于最大值。")
strict   = input.bool(true, "启用中间枢轴阻断", group = gP, display = display.none, tooltip = "这是阻断的基础开关：宽松和标准依照本项，严格固定开启。\n开启后，脚本从近到远寻找配对；若同一个更近枢轴已按第 6 组口径支配当前候选，就停止继续向更远处搜索。\n宽松或标准仍常画出跨越明显结构的长连线时开启；标准漏掉肉眼成立且路径干净的背离时，可暂时关闭后对比。路径检查不受本开关直接控制。")

gA       = "5. 价格比较"
A_MIX    = "混合：高低点或收盘价任一成立"
A_HL     = "高低点：适合蜡烛图 / 条形图"
A_CL     = "收盘价：适合折线图 / 面积图"
anchor   = input.string(A_MIX, "价格使用哪组数据", options = [A_MIX, A_HL, A_CL], group = gA, display = display.none, tooltip = "决定比较两个价格端点时使用哪组数字。\n看蜡烛图通常选『高低点』；看折线图或面积图通常选『收盘价』。\n『混合』会让高低点与收盘价各自完成端点关系、右侧确认和价格路径检查：任一成立就保留；仅收盘价成立时连在收盘价上，其余情况连在高低点上；同一对枢轴两者都成立时只画一组线并自动加粗。\n如果图上连线斜率与你肉眼依据的图表形态不一致，应首先检查这里。")

gF        = "6. 结构过滤（进阶）"
strictAny = input.bool(false, "价格或 RSI 任一侧更强就阻断（额外严格）", group = gF, display = display.none, tooltip = "只有第 4 组『启用中间枢轴阻断』生效时才参与判定。档位规则：宽松固定关闭；标准和严格依照本项。严格档不会自动开启它，以免为了降噪而漏掉价格结构仍然成立的明显背离。\n关闭（建议）：同一个更近枢轴必须同时在 RSI 和当前端点仍可用的全部价格口径上都更强，才停止向更远处搜索。混合模式下，较近枢轴若只有高低点或只有收盘价口径有效，不会替另一口径一票否决。\n开启：同一个更近枢轴只要 RSI 更强，或当前端点仍可用的全部价格口径都更强，就停止搜索；因此信号更少，也更容易漏报。标准或严格漏掉路径干净的肉眼背离时关闭；仍有跨越明显结构的长连线时开启。")
chkPath   = input.bool(true, "检查两端之间是否穿线", group = gF, display = display.none, tooltip = "这是路径检查总开关：宽松和标准依照本项，严格固定开启。\n开启后会逐根检查两个端点之间的价格与 RSI；下方勾选的序列若越过连线和允许幅度，配对会被拒绝。\n建议保持开启。只有在诊断明显背离为何被过滤时才暂时关闭，并比较新增连线是否穿过原始曲线。")
chkOsc    = input.bool(true, "检查 RSI 路径", group = gF, display = display.none, tooltip = "这是 RSI 路径检查的基础开关：宽松和标准依照本项，严格固定开启。只有总开关『检查两端之间是否穿线』生效时才参与判定。\n开启可拦住跨过更深 RSI 低点或更高 RSI 高点的连线；关闭会增加信号。调整后重点观察副图连线是否穿过 RSI 曲线。")
chkPrc    = input.bool(true, "检查价格路径", group = gF, display = display.none, tooltip = "这是价格路径检查的基础开关：宽松和标准依照本项，严格固定开启。只有总开关『检查两端之间是否穿线』生效时，才检查两个端点之间的价格路径。\n开启可拦住穿过更低价格低点或更高价格高点的连线；关闭会增加信号。使用高低点还是收盘价由第 5 组决定。\n注意：关闭本项不会取消枢轴右侧确认；确认 K 线是否已实质突破端点，仍按下方基础价格容差检查。")
edgeSkip  = input.int(0, "端点附近放宽（每侧 K 线数）", minval = 0, maxval = 10, group = gF, display = display.none, tooltip = "这是三档的基础端点放宽值：宽松增加 1，标准直接使用，严格减少 1（最低为 0）。\n端点附近经常只差一点穿线时可逐步提高；通常保持 0。放宽数量最多为间隔的四分之一；中间值若超过两端极值加上相应允许容差，仍会被拒绝。\n调整后观察新增信号是否只解决端点附近的小毛刺，而没有放过中段明显穿线。")
tolOsc    = input.float(1.5, "RSI 穿线容差（点）", minval = 0, maxval = 20, step = 0.1, group = gF, display = display.none, tooltip = "这是三档的基础 RSI 容差：宽松 ×1.5，标准 ×1，严格 ×0.5。\n许多信号只因很小的 RSI 毛刺被过滤时可提高基础值；可疑跨线信号太多时降低。建议每次只改 0.5～1 点。\n填 0 时三档都不允许 RSI 穿出；调整后比较新增或消失的连线是否只是轻微毛刺造成。")
tolPrc    = input.float(0.5, "价格容差（路径 / 右侧确认，%）", minval = 0, maxval = 10, step = 0.05, group = gF, display = display.none, tooltip = "本数值有两个用途。\n配对路径：宽松 ×1.5，标准 ×1，严格 ×0.5；只差少量影线而被过滤时可提高，明显穿线仍被接受时降低。\n右侧确认：三档都直接采用这里的基础值，并再限制为不超过 ATR14 × 0.15，避免调档时改变哪些 RSI 枢轴进入历史池。即使关闭价格路径检查，本数值仍参与右侧确认。\n例如 0.5 表示约 0.5%；填 0 时只保留报价精度缓冲。调整后同时观察主图连线是否干净，以及确认 K 线是否已实质突破端点。")

gQ        = "7. 信号质量（可选）"
minRsiD   = input.float(0, "可选硬过滤：端点至少相差多少 RSI 点", minval = 0, maxval = 30, step = 0.5, group = gQ, display = display.none, tooltip = "这比较的是两个背离端点之间相差多少 RSI 点，不限制 RSI 必须位于 30 / 70 或任何区间。三个严格度档位都原样采用本数值，不会暗中提高。\n建议保持 0：只要方向正确，即使差距很小也先交给枢轴、阻断、价格与 RSI 路径、右侧价格确认等结构规则判断。只有在你明确想一刀切删除小差值时才提高；这可能漏掉有价值的早期背离。\n关键 EMA 救回因额外放宽了枢轴和最小间隔，仍单独要求至少 0.5 点作为补偿。")
obosOnly  = input.bool(false, "常规背离必须位于超买 / 超卖区", group = gQ, display = display.none, tooltip = "开启后，底背离要求新的 RSI 低点 ≤ 30，顶背离要求新的 RSI 高点 ≥ 70；隐性背离不受影响。\n只想保留极端区域的反转候选时开启；希望观察中性区域的动能背离时关闭。\n开启后信号会明显减少，应比较不同品种和周期是否仍有足够样本。\n★只表示当前已有底部信号的 RSI ≤30，或已有顶部信号的 RSI ≥70；可与背离、眼或两者组合出现。单独超买 / 超卖不会制造标签，星标也与本开关是否开启无关。")


gE        = "8. 支撑眼 / 压力眼（可选）"
E_WICK    = "影线越界：更灵敏"
E_CLOSE   = "收盘越界：更稳健"
useEye    = input.bool(false, "启用支撑眼 / 压力眼", group = gE, display = display.none, tooltip = "默认关闭，关闭时不改变背离、其他显示或警报。\n开启后，把连续越过同一侧布林带的 K 线视为一整段突破：上轨突破结束时，只在整段最高价处确认一个压力眼；下轨突破结束时，只在整段最低价处确认一个支撑眼。不会因突破段内出现多个局部转折而重复标眼。\n最右侧尚未收盘时会暂时标出当前突破段已经形成的极值；若随后出现更高或更低价格，临时眼会移动，回到带内后仍须等本根收盘才转为历史确认。\n独立眼只画在价格图；若最终极值 K 线同时存在背离，则合并进同一标签。叠加超卖 / 超买时追加 ★，命中关键 EMA 时另起一行显示 E21 等。")
eyeLen   = input.int(20, "布林带长度", minval = 2, maxval = 500, group = gE, display = display.none, tooltip = "决定布林带统计窗口。数值较小会更快适应行情、眼也更敏感；数值较大更平滑、信号更少。\n建议先用 20；调整后观察眼是否集中在你认可的价格扩张极值，而不是普通波动。")
eyeSrc   = input.source(close, "布林带数据源", group = gE, display = display.none, tooltip = "只用于计算布林带中轴和标准差，不改变 RSI 数据源。通常保持收盘价。\n即使选择影线越界，布林带本身仍按这里的数据源计算，再由最高价 / 最低价判断是否越轨。")
eyeMa    = input.string("SMA", "布林带中轴类型", options = ["SMA", "EMA", "RMA", "WMA", "VWMA"], group = gE, display = display.none, tooltip = "选择布林带中轴算法。SMA 是经典布林带；EMA / RMA 更重视近期价格；WMA / VWMA 分别按线性权重或成交量加权。\n不确定时保持 SMA。改变后眼的位置会重新计算。")
eyeMult  = input.float(2.0, "标准差倍数", minval = 0.1, maxval = 10, step = 0.1, group = gE, display = display.none, tooltip = "轨道距离中轴多少个标准差。调小会增加眼，调大只保留更极端的价格扩张。\n建议先用 2.0；眼太密时逐步调大，明显极端仍没有眼时逐步调小。")
eyeMode  = input.string(E_WICK, "越界口径", options = [E_WICK, E_CLOSE], group = gE, display = display.none, tooltip = "影线越界：最高价 / 最低价在轨外就属于连续突破段，反应更快。\n收盘越界：只有收盘价在轨外才延续突破段，数量更少；但眼仍标在这段突破 K 线中的实际最高价或最低价。\n历史眼在第一根不再越界的 K 线收盘后确认；最右侧未收盘状态只作临时显示。")
maxEye   = input.int(12, "最多保留最近几个独立眼", minval = 1, maxval = 20, group = gE, display = display.none, tooltip = "只限制没有与背离重合的独立眼标签；合并标签仍按背离的显示数量管理。\n压力眼与支撑眼合计保留最近这么多个。图面拥挤时调小，复盘需要更多历史极值时调大。")

gM          = "9. 关键 EMA 共振（可选）"
useEmaTouch = input.bool(false, "在已有信号上标注关键 EMA", group = gM, display = display.none, tooltip = "默认关闭；关闭时不改变任何背离、眼、超买 / 超卖、其他显示或警报。\n开启后，仅当当前端点已经形成背离或眼时，检查其是否接近 EMA21 / 55 / 100 / 200，并在同一个标签下一行追加 E21、E55 等；不会画均线，也不会单独在主图 / RSI 副图制造标签或触发正式警报。若同时开启下方『关键 EMA 可救回一档边缘背离』，EMA 还可在严格条件下救回短间隔常规背离。\n顶部事件用最高价检查从下方遇到均线，底部事件用最低价检查从上方遇到均线；历史使用端点 K 线当时的 EMA，最右侧未收盘状态实时更新。")
emaTolAtr   = input.float(0.25, "接近 / 轻微穿越容差（ATR14 倍数）", minval = 0, maxval = 1, step = 0.01, group = gM, display = display.none, tooltip = "端点最高价或最低价与 EMA 的距离不超过 ATR14 × 本数值，就视为『非常接近、刚好触碰或轻微穿过』。它只控制距离，不会把来自均线错误一侧的回测误当成支撑 / 压力。\n建议先用 0.25：标识过多、明显越过均线仍算触碰时调小；肉眼碰到或仅小幅穿过却未标出时逐步调大。填 0 时只保留 2 个最小跳动单位的数值缓冲；大于 0 时随品种和周期波动率自适应。\n本数值也用于下方救回规则；修改后应重点检查被救回信号是否确实在均线附近，而不是远离均线。")
emaRescue   = input.bool(true, "关键 EMA 可救回一档边缘背离", group = gM, display = display.none, tooltip = "仅在『在已有信号上标注关键 EMA』开启时生效。它不是降低全局严格度，也不会让 EMA 单独产生信号。\n只救回常规底 / 顶背离，并同时要求：收盘价口径已启用；右端 RSI 的左侧识别范围最多减少 1 根（最低仍为 1）；枢轴间隔最多比当前有效最小间隔少 1 根（最低仍为 1）；RSI 至少真实改变 0.5 点且满足第 7 组的 RSI 端点差值设置；端点命中关键 EMA；价格与 RSI 两条路径都逐根检查，并遵守端点放宽与当前档位容差。隐性背离、超过最大间隔、历史候选未通过右侧确认或路径检查未通过时不会被救回。\n三档均可使用；通常先在标准下观察它是否补回关键均线附近、结构仍干净的短周期双顶 / 双底。若新增信号仍不可靠，可关闭本项，不必改动全局严格度或其他参数。")
emaUse21    = input.bool(true, "检查 EMA21", group = gM, display = display.none, tooltip = "短中期关键均线。关闭后不会显示 E21，不影响其他 EMA、背离或眼。")
emaUse55    = input.bool(true, "检查 EMA55", group = gM, display = display.none, tooltip = "中期关键均线。关闭后不会显示 E55，不影响其他 EMA、背离或眼。")
emaUse100   = input.bool(true, "检查 EMA100", group = gM, display = display.none, tooltip = "中长期关键均线。关闭后不会显示 E100，不影响其他 EMA、背离或眼。")
emaUse200   = input.bool(true, "检查 EMA200", group = gM, display = display.none, tooltip = "长期关键均线。关闭后不会显示 E200，不影响其他 EMA、背离或眼。")

gV       = "10. 线条与标签"
cRsi     = input.color(#7E57C2, "RSI 线条颜色", group = gV, display = display.none, tooltip = "只改变 RSI 曲线颜色，不影响计算和信号。")
wRsi     = input.int(1, "RSI 线条粗细", minval = 1, maxval = 4, group = gV, display = display.none, tooltip = "只改变 RSI 曲线粗细。曲线不易辨认时调大；遮挡枢轴和背离线时调小。")
cBull    = input.color(#0B8457, "底部信号颜色", group = gV, display = display.none, tooltip = "用于底背离和隐性底背离的线与正式标签，只影响显示。")
cBear    = input.color(#C62A38, "顶部信号颜色", group = gV, display = display.none, tooltip = "用于顶背离和隐性顶背离的线与正式标签，只影响显示。")
hidAlpha = input.int(82, "隐性背离标签透明度", minval = 0, maxval = 95, group = gV, display = display.none, tooltip = "控制隐性背离标签背景的透明度：0 完全不透明，95 几乎透明。\n隐性信号抢眼时调大；难以看清时调小。只影响显示。")
lwReg    = input.int(1, "常规背离基础线宽", minval = 1, maxval = 4, group = gV, display = display.none, tooltip = "控制底背离和顶背离的基础实线宽度，默认 1。\n混合价格模式下，如果同一对枢轴的高低点和收盘价各自通过完整检测，主图与 RSI 副图会在本数值上自动加粗 1。线条变粗只表示两种价格口径同时确认，不改变信号或提醒。")
lwHid    = input.int(1, "隐性背离基础线宽", minval = 1, maxval = 4, group = gV, display = display.none, tooltip = "控制隐性底背离和隐性顶背离的基础虚线宽度，默认 1。\n混合价格模式下，如果同一对枢轴的高低点和收盘价各自通过完整检测，主图与 RSI 副图会在本数值上自动加粗 1。常规与隐性背离仍主要用实线 / 虚线区分。")
showLine = input.bool(true, "显示背离连线", group = gV, display = display.none, tooltip = "关闭后不画主图和 RSI 副图的背离线，但信号判定、标签和警报仍然运行。")
showLbl  = input.bool(true, "显示信号标签", group = gV, display = display.none, tooltip = "关闭后不画主图和 RSI 副图的背离标签，也不画独立眼；连线、判定和警报仍然运行。\n正式背离及其合并标签会同时显示在主图与 RSI 副图。独立眼是纯价格事件，只显示在主图。实时未收盘状态与历史正式状态共用本开关和同一外观。")
lsize    = input.string("极小", "信号标签字号", options = ["极小", "小", "正常", "大"], group = gV, display = display.none, tooltip = "调整背离及其组合标签的字号；独立眼固定使用最小字号，避免盖过更重要的组合信号。标签互相遮挡时调小，难以辨认时调大。第 12 组的指数数字会跟随同一标签显示，详细依据请把鼠标移到标签上查看。")
txtReg   = input.bool(false, "常规背离标签显示名称", group = gV, display = display.none, tooltip = "关闭时标签只显示 ▲ 或 ▼；开启后同时写出『底背离』或『顶背离』；历史正式状态与最右侧实时状态一致。\n图面拥挤时关闭，需要截图或复盘辨认时开启。")
txtHid   = input.bool(false, "隐性背离标签显示名称", group = gV, display = display.none, tooltip = "关闭时标签只显示 △ 或 ▽；开启后同时写出隐性背离名称；历史正式状态与最右侧实时状态一致。\n图面拥挤时关闭，需要截图或复盘辨认时开启。")

gN       = "11. 显示数量"
maxSig   = input.int(50, "最多保留最近几次历史标注", minval = 1, maxval = 225, group = gN, display = display.none, tooltip = "主图和 RSI 副图合计保留最近这么多次已确认背离；更早的背离线与标签会被删除。\n最右侧实时状态不占用该数量；没有与背离重合的独立眼由第 8 组单独限制。第 12 组的指数只写进这些既有标签，不会另占一套数量。图面太乱或加载较慢时调小，复盘需要更多历史事件时调大。")

gX              = "12. 信号标签上的买卖指数（可选）"
showSignalScore = input.bool(false, "在信号标签上显示买卖指数", group = gX, display = display.none, tooltip = "默认关闭：标签、连线与现在的信号标注完全相同。\n\n开启：保留已经成立的背离或独立支撑眼 / 压力眼标注，并把 0–100 的方向指数放在同一标签的最下方；若标签还显示关键 EMA，则顺序固定为『符号 → EMA → 分值』。不会切换显示模式，也不会增加第二套标签。超买 / 超卖与关键 EMA 只作为同一事件的评分依据，不会因为评分而单独制造标签。\n\n指数只用于同一品种、同一图表周期内比较。切换周期后会按新周期重新检测、评分并读取它自己的更大周期背景；不要把 1H 的 40 与 1D 的 40 直接排序。更大周期只影响当前周期机会的背景判断，不会因为周期更大就给它自己的标签额外加分。\n\n把鼠标移到带数字的标签上，可以直接看到：这是什么类型的做多 / 做空机会；当前 K 线是否已经收盘确认；本周期有哪些条件、各自贡献多大；更大周期的均线方向是否配合；每个更大周期最近仍有效的做多、做空条件，以及它们最终让当前指数增加或减少了多少。\n\n连续背离只在同方向、同类型且前一条终点正好成为后一条起点时增强一次；同一端点的眼即使晚几根才确认，也会与此前背离合并后重新计算，不会用眼单项覆盖原分数。背离程度分别按价格相对 ATR、RSI 差相对近期 RSI 波动量化，不因跨度更长或图表周期更大自动增减。超买 / 超卖只在 70 / 30 以外参与，并按 RSI 背后的相对强弱比量化；30–70 普通区间不会被放缩。影线与收盘价都成立仍显示双口径，但不会把同一结构重复算成两条背离。EMA 触碰质量会参与，多条重合均线自动降低重复计算。\n\n5m 自动参考 1H / 4H / 1D，15m 自动参考 1H / 4H / 1D；其他周期同样按入场、机会和战略背景三层自动选择。历史只读取当时已经确认的信息；最右侧未收盘信号会实时变化。支持 5m 至 2M；3M 及以上不显示数字，但原信号照常显示。")
scoreLiveHtf     = input.bool(true, "实时指数采用尚未收盘的更大周期信号", group = gX, display = display.none, tooltip = "仅在上方指数开关已开启、且最右侧尚未收盘的信号标签出现时生效。\n\n开启：三层更大周期若正在形成背离、眼、超买卖或 EMA 事件，实时指数会按该周期已经走完的比例逐步纳入；刚开盘影响很小，越接近收盘越完整，临时条件仍可能在收盘前增强、减弱或消失。\n关闭：三层更大周期都只采用已经收盘确认的条件，适合复盘对照。\n\n均线趋势方向始终只使用上一根已收盘的大周期 K 线；历史标签也只读取当时已经出现的信息。本项不会改变信号检测或 12 条正式提醒。")


// 派生设置
// 下拉框映射为 0～2；标准逐项等于基础设置。
strictLevel = strictChoice == S_LOOSE ? 0 : strictChoice == S_NORMAL ? 1 : 2
// 有效配对参数构成单调收紧轴；右侧确认固定使用基础价格容差，避免档位变化重排枢轴池。
effNBack = math.max(1, math.min(10, nBack + (strictLevel == 0 ? 1 : strictLevel == 1 ? 0 : -1)))
effStrict = strictLevel == 2 ? true : strict
effStrictAny = strictLevel == 0 ? false : strictAny
effChkPath = strictLevel == 2 ? true : chkPath
effChkOsc = strictLevel == 2 ? true : chkOsc
effChkPrc = strictLevel == 2 ? true : chkPrc
effEdgeSkip = strictLevel == 0 ? math.min(10, edgeSkip + 1) : strictLevel == 1 ? edgeSkip : math.max(0, edgeSkip - 1)
effTolOsc = strictLevel == 0 ? math.min(20.0, tolOsc * 1.5) : strictLevel == 1 ? tolOsc : tolOsc * 0.5
effTolPrc = strictLevel == 0 ? math.min(10.0, tolPrc * 1.5) : strictLevel == 1 ? tolPrc : tolPrc * 0.5
// 严格度不替用户添加 RSI 差值硬门槛；RSI 所在区间和差值大小都不是档位的隐含定义。
effMinRsiD = minRsiD
detClose = anchor == A_CL
useE     = anchor != A_CL
useC     = anchor != A_HL
hiSrc    = detClose ? close : high
loSrc    = detClose ? close : low
mnGap    = math.min(gapMin, gapMax)
mxGap    = math.max(gapMin, gapMax)
rescueLeft    = math.max(1, pivLeft - 1)
rescueMnGap   = math.max(1, mnGap - 1)
rescueMinRsiD = math.max(0.5, minRsiD)
// 只处理报价精度 / 浮点边界；ATR 和百分比容差另行计算。
PRICE_EPS = math.max(syminfo.mintick * 2.0, 1e-10)
RIGHT_ATR_CAP = 0.15
f_lsize(string s) =>
    switch s
        "极小" => size.tiny
        "小"   => size.small
        "正常" => size.normal
        => size.large

f_eyeMa(float s, int n, string typ) =>
    switch typ
        "EMA"  => ta.ema(s, n)
        "RMA"  => ta.rma(s, n)
        "WMA"  => ta.wma(s, n)
        "VWMA" => ta.vwma(s, n)
        => ta.sma(s, n)

// 关键 EMA 只附着在已有信号上且不绘制均线。评分内核会把 EMA 当作事件属性，
// 但第 12 组开启后也只能把指数写回已存在的背离 / 眼标签，不能由 EMA 单独造标签。
ema21v   = ta.ema(close, 21)
ema55v   = ta.ema(close, 55)
ema100v  = ta.ema(close, 100)
ema200v  = ta.ema(close, 200)
emaAtr14 = ta.atr(14)

f_maTouch(bool isLow, float px, float prevClose, float maNow, float maPrev, float tolNow) =>
    ready    = not na(px) and not na(prevClose) and not na(maNow) and not na(maPrev) and not na(tolNow)
    near     = ready and math.abs(px - maNow) <= tolNow
    // 距离可按 ATR 放宽；来自支撑 / 压力的方向只容许报价精度误差，不能借 ATR 跨到均线另一侧。
    approach = ready and (isLow ? prevClose >= maPrev - PRICE_EPS : prevClose <= maPrev + PRICE_EPS)
    near and approach

f_emaTag(bool isLow, int off) =>
    tag = ""
    if useEmaTouch and bar_index > off
        tolNow    = math.max(syminfo.mintick * 2.0, emaAtr14[off] * emaTolAtr)
        px        = isLow ? low[off] : high[off]
        prevClose = close[off + 1]
        if emaUse21 and f_maTouch(isLow, px, prevClose, ema21v[off], ema21v[off + 1], tolNow)
            tag := "21"
        if emaUse55 and f_maTouch(isLow, px, prevClose, ema55v[off], ema55v[off + 1], tolNow)
            tag := tag + (tag == "" ? "" : "/") + "55"
        if emaUse100 and f_maTouch(isLow, px, prevClose, ema100v[off], ema100v[off + 1], tolNow)
            tag := tag + (tag == "" ? "" : "/") + "100"
        if emaUse200 and f_maTouch(isLow, px, prevClose, ema200v[off], ema200v[off + 1], tolNow)
            tag := tag + (tag == "" ? "" : "/") + "200"
    tag == "" ? "" : "E" + tag

f_sigText(bool isLow, bool isHid, bool hasEye, bool inZone, string emaTag) =>
    base = isLow ? (isHid ? "△" : "▲") : (isHid ? "▽" : "▼")
    // 👁 与 ★ 是两项相互独立的证据：没有眼的超买 / 超卖背离也应显示 ★。
    mark = (hasEye ? "👁" : "") + (inZone ? "★" : "")
    name = isLow ? (isHid ? "隐性底背离" : "底背离") : (isHid ? "隐性顶背离" : "顶背离")
    withName = isHid ? txtHid : txtReg
    core = base + mark + (withName ? " " + name : "")
    core + (emaTag == "" ? "" : "\n" + emaTag)

// RSI 枢轴的右侧确认区间若已把价格端点实质突破，则相应价格通道失效。
// 轻微报价毛刺可容忍，但容差不会大于 0.15 ATR，避免较大的基础容差把明显破坏也放过去。
f_rightPrcOk(bool isHigh, float endpoint, float rightExtreme, float atrAtEndpoint) =>
    pctTol = math.abs(endpoint) * tolPrc / 100.0
    atrTol = not na(atrAtEndpoint) ? atrAtEndpoint * RIGHT_ATR_CAP : pctTol
    tol    = math.max(PRICE_EPS, math.min(pctTol, atrTol))
    not na(endpoint) and not na(rightExtreme) and (isHigh ? rightExtreme <= endpoint + tol : rightExtreme >= endpoint - tol)

// ══════════ 计算 ══════════
rsi = ta.rsi(rsiSrc, rsiLen)
rsiStep14 = ta.rma(math.abs(ta.change(rsi)), 14)
pl  = ta.pivotlow(rsi, pivLeft, pivRight)
ph  = ta.pivothigh(rsi, pivLeft, pivRight)
plEmaRescue = ta.pivotlow(rsi, rescueLeft, pivRight)
phEmaRescue = ta.pivothigh(rsi, rescueLeft, pivRight)

// 当前确认柱上的 ta.lowest / ta.highest 恰好覆盖端点右侧的 pivRight 根 K 线，不含端点本身。
rightLowW  = ta.lowest(low, pivRight)
rightLowC  = ta.lowest(close, pivRight)
rightHighW = ta.highest(high, pivRight)
rightHighC = ta.highest(close, pivRight)
pivotLoEValid = f_rightPrcOk(false, low[pivRight],   rightLowW,  emaAtr14[pivRight])
pivotLoCValid = f_rightPrcOk(false, close[pivRight], rightLowC,  emaAtr14[pivRight])
pivotHiEValid = f_rightPrcOk(true,  high[pivRight],  rightHighW, emaAtr14[pivRight])
pivotHiCValid = f_rightPrcOk(true,  close[pivRight], rightHighC, emaAtr14[pivRight])

// 超买 / 超卖参考位：Wilder 原始设定，也与副图画出的两条参考线一致
OB_LV = 70.0
OS_LV = 30.0

// 支撑眼 / 压力眼的“突破段”只由是否连续越过同一侧布林带定义；最终标记
// 位于整段实际最高价 / 最低价，而不是任意局部枢轴。
isLiveOpen = barstate.isrealtime and not barstate.isconfirmed
eyeBasis = f_eyeMa(eyeSrc, eyeLen, eyeMa)
eyeDev   = eyeMult * ta.stdev(eyeSrc, eyeLen)
eyeUpper = eyeBasis + eyeDev
eyeLower = eyeBasis - eyeDev
eyeHiSer = eyeMode == E_WICK ? high : close
eyeLoSer = eyeMode == E_WICK ? low  : close
rsiLeftLow  = ta.lowestbars(rsi, pivLeft + 1) == 0
rsiLeftHigh = ta.highestbars(rsi, pivLeft + 1) == 0
rsiRescueLeftLow  = ta.lowestbars(rsi, rescueLeft + 1) == 0
rsiRescueLeftHigh = ta.highestbars(rsi, rescueLeft + 1) == 0

// ══════════ RSI 本体 ══════════
plot(rsi, "RSI", color = cRsi, linewidth = wRsi)
// 70 / 50 / 30 是固定参考位：保留视觉参考，但不在“样式”中提供调整项。
ob = hline(OB_LV, "超买 70", color = color.new(color.gray, 55), linestyle = hline.style_dashed, editable = false)
md = hline(50, "中轴 50", color = color.new(color.gray, 80), linestyle = hline.style_dotted, editable = false)
os = hline(OS_LV, "超卖 30", color = color.new(color.gray, 55), linestyle = hline.style_dashed, editable = false)
fill(ob, os, color = color.new(#7E57C2, 94), title = "RSI 区间", editable = false)

// ══════════ 原始序列缓冲 ══════════
// 用逐柱数组代替动态历史索引 rsi[k]，既避开 max_bars_back 限制，也让越界可控。
bufN = mxGap + pivRight + 6
var sbH = array.new<float>()
var sbL = array.new<float>()
var sbC = array.new<float>()
var sbR = array.new<float>()
var sbI = array.new<int>()
array.push(sbH, high)
array.push(sbL, low)
array.push(sbC, close)
array.push(sbR, rsi)
array.push(sbI, bar_index)
while array.size(sbI) > bufN
    array.shift(sbH)
    array.shift(sbL)
    array.shift(sbC)
    array.shift(sbR)
    array.shift(sbI)

// 线段 (b1,y1)-(b2,y2) 在两端之间是否被 ser 穿透。
// isHigh = true  线段作上边界，序列高出线段即穿透（高点侧配对）
// isHigh = false 线段作下边界，序列低于线段即穿透（低点侧配对）
f_path(array<float> ser, int b1, float y1, int b2, float y2, bool isHigh, float tol) =>
    clean = true
    n     = array.size(sbI)
    if n > 0 and b2 - b1 >= 2
        base = array.get(sbI, 0)
        span = (b2 - b1) * 1.0
        // 端点豁免按跨度比例收缩：固定豁免会在短跨度上吃掉整个区间，导致校验被整体跳过。
        // sk = 0 时开区间内每一根都参与判定，与输入项"0 = 全区间校验"的说明一致。
        sk   = math.max(0, math.min(effEdgeSkip, int(math.floor((b2 - b1 - 1) / 4.0))))
        yMax = math.max(y1, y2)
        yMin = math.min(y1, y2)
        for k = b1 + 1 to b2 - 1
            idx = k - base
            if idx < 0 or idx >= n
                // 环形缓冲没覆盖到这一根，无法证明连线干净：按未通过处理（宁可漏报，不可误报）。
                // 正常情况下 bufN = mxGap + pivRight + 6 足以覆盖，这里只是兜底不让校验静默失效。
                clean := false
                break
            v   = array.get(ser, idx)
            mid = k >= b1 + 1 + sk and k <= b2 - 1 - sk
            yl  = y1 + (y2 - y1) * ((k - b1) / span)
            if isHigh
                // 硬性规则：中间任何一根都不得高于两端中的更高者（不受豁免影响）
                if v > yMax + tol
                    clean := false
                    break
                if mid and v > yl + tol
                    clean := false
                    break
            else
                if v < yMin - tol
                    clean := false
                    break
                if mid and v < yl - tol
                    clean := false
                    break
    clean

f_oscOk(int b1, float y1, int b2, float y2, bool isHigh) =>
    effChkPath and effChkOsc ? f_path(sbR, b1, y1, b2, y2, isHigh, effTolOsc) : true

f_prcOk(array<float> ser, int b1, float y1, int b2, float y2, bool isHigh) =>
    effChkPath and effChkPrc ? f_path(ser, b1, y1, b2, y2, isHigh, math.abs(y1) * effTolPrc / 100.0) : true

// 阻断组合：bE / bC 是较近枢轴在对应价格口径上的支配结果，bR 是 RSI 支配结果。
// pairE / pairC 表示该较近枢轴能否参与对应口径；curE / curC 表示当前端点仍可用的口径。
f_blkFor(bool bE, bool bC, bool bR, bool pairE, bool pairC, bool curE, bool curC) =>
    // 混合模式的两个价格口径可以独立寻找配对。只有当前仍可用的全部口径都被同一个
    // 较近枢轴实际支配，才允许价格维度整体阻断；候选口径无效不能被当成“已经支配”。
    prcB = (not curE or (pairE and bE)) and (not curC or (pairC and bC))
    effStrictAny ? (bR or prcB) : (bR and prcB)

// 枢轴历史（只保留当前档位允许回看的 effNBack 个）：E = 高低点，C = 收盘价，R = 枢轴处 RSI，B = bar_index
var loE = array.new<float>()
var loC = array.new<float>()
var loR = array.new<float>()
var loB = array.new<int>()
var loEV = array.new<bool>()
var loCV = array.new<bool>()
var hiE = array.new<float>()
var hiC = array.new<float>()
var hiR = array.new<float>()
var hiB = array.new<int>()
var hiEV = array.new<bool>()
var hiCV = array.new<bool>()


// 背离图形和独立眼分别登记：眼不会挤掉背离标签，二者共同受 500 个图形的资源上限约束。
var array<line>  dLn   = array.new<line>()
var array<label> dLb   = array.new<label>()
var array<label> eyeLb = array.new<label>()
var array<int> dLbOrigin = array.new<int>()
var array<int> dLbSide = array.new<int>()
var array<string> dLbBase = array.new<string>()
var array<int> eyeLbOrigin = array.new<int>()
var array<int> eyeLbSide = array.new<int>()
var array<string> eyeLbBase = array.new<string>()
// 已确认眼的事件位置独立保留；即使独立眼因显示数量上限被清理，后来确认的
// 同端点背离仍能正确合并，而不是重新叠一张标签。
var array<int> eyeLowHistory = array.new<int>()
var array<int> eyeHighHistory = array.new<int>()
// 实时标签由 TradingView 在每次跳动前回滚；只登记当前计算轮次，供后面的
// 评分结果原位补数字与 tooltip，不计入历史保留数量。
var array<label> liveLb = array.new<label>()
var array<int> liveLbOrigin = array.new<int>()
var array<int> liveLbSide = array.new<int>()
var array<string> liveLbBase = array.new<string>()
array.clear(liveLb)
array.clear(liveLbOrigin)
array.clear(liveLbSide)
array.clear(liveLbBase)
capDraw = maxSig * 2

f_keepLn(line ln) =>
    array.push(dLn, ln)
    while array.size(dLn) > capDraw
        line.delete(array.shift(dLn))
    0

f_keepLb(label lb, int origin, int side, string baseTxt) =>
    array.push(dLb, lb)
    array.push(dLbOrigin, origin)
    array.push(dLbSide, side)
    array.push(dLbBase, baseTxt)
    while array.size(dLb) > capDraw
        label.delete(array.shift(dLb))
        array.shift(dLbOrigin)
        array.shift(dLbSide)
        array.shift(dLbBase)
    0

f_keepEye(label lb, int origin, int side, string baseTxt) =>
    array.push(eyeLb, lb)
    array.push(eyeLbOrigin, origin)
    array.push(eyeLbSide, side)
    array.push(eyeLbBase, baseTxt)
    while array.size(eyeLb) > maxEye
        label.delete(array.shift(eyeLb))
        array.shift(eyeLbOrigin)
        array.shift(eyeLbSide)
        array.shift(eyeLbBase)
    0

f_eyeKnown(array<int> origins, int origin) =>
    found = false
    n = array.size(origins)
    if origin > 0 and n > 0
        for i = n - 1 to 0
            if array.get(origins, i) == origin
                found := true
                break
    found

f_rememberEye(array<int> origins, int origin) =>
    if origin > 0 and not f_eyeKnown(origins, origin)
        array.push(origins, origin)
        while array.size(origins) > 128
            array.shift(origins)
    0

f_addEyeMark(string txt) =>
    str.contains(txt, "👁") ? txt : str.substring(txt, 0, 1) + "👁" + str.substring(txt, 1)

f_removeStandaloneEye(int origin, int side) =>
    removed = false
    i = array.size(eyeLb) - 1
    while i >= 0
        if array.get(eyeLbOrigin, i) == origin and array.get(eyeLbSide, i) == side
            label.delete(array.remove(eyeLb, i))
            array.remove(eyeLbOrigin, i)
            array.remove(eyeLbSide, i)
            array.remove(eyeLbBase, i)
            removed := true
        i -= 1
    removed

// 眼比背离晚确认时，直接升级同端点既有背离标签；评分层随后仍按同一 origin
// 原位更新数字和悬停说明，不会制造第二张标签。
f_upgradeLabelsWithEye(array<label> lbs, array<int> origins, array<int> sides, array<string> bases, int origin, int side) =>
    upgraded = false
    n = array.size(lbs)
    if origin > 0 and n > 0
        for i = 0 to n - 1
            if array.get(origins, i) == origin and array.get(sides, i) == side
                lb = array.get(lbs, i)
                base = f_addEyeMark(array.get(bases, i))
                array.set(bases, i, base)
                label.set_text(lb, base)
                hidden = str.startswith(base, "△") or str.startswith(base, "▽")
                hasStar = str.contains(base, "★")
                col = side > 0 ? cBull : cBear
                label.set_color(lb, hidden ? color.new(col, hasStar ? math.max(10, hidAlpha - 45) : math.max(25, hidAlpha - 25)) : col)
                label.set_textcolor(lb, hasStar ? color.rgb(255, 213, 79) : color.rgb(255, 248, 225))
                upgraded := true
    upgraded

f_keepLive(label lb, int origin, int side, string baseTxt) =>
    array.push(liveLb, lb)
    array.push(liveLbOrigin, origin)
    array.push(liveLbSide, side)
    array.push(liveLbBase, baseTxt)
    0

// ovr = true：图形推到主图（价格）窗格；false：留在本窗格（RSI）。dualPrc = 同一对枢轴的影线与收盘价均独立成立。
f_draw(int x1, float y1, int x2, float y2, string txt, color col, bool isLow, bool isHid, bool ovr, bool dualPrc) =>
    baseW = isHid ? lwHid : lwReg
    lnW = baseW + (dualPrc ? 1 : 0)
    lnS = isHid ? line.style_dashed : line.style_solid
    hasEye  = str.contains(txt, "👁")
    hasStar = str.contains(txt, "★")
    // 组合越强，隐性标签越不透明；普通背离仍完全沿用原来的颜色与透明度。
    comboAlpha = hasStar ? math.max(10, hidAlpha - 45) : hasEye ? math.max(25, hidAlpha - 25) : hidAlpha
    lbC = isHid ? color.new(col, comboAlpha) : col
    baseT = isHid ? (hidAlpha >= 55 ? col : color.white) : color.white
    lbT = hasStar ? color.rgb(255, 213, 79) : hasEye ? color.rgb(255, 248, 225) : baseT
    lbS = isLow ? label.style_label_up : label.style_label_down
    lbZ = f_lsize(lsize)
    origin = time[bar_index - x2]
    side = isLow ? 1 : -1
    if showLine
        if ovr
            f_keepLn(line.new(x1, y1, x2, y2, xloc = xloc.bar_index, color = col, width = lnW, style = lnS, force_overlay = true))
        else
            f_keepLn(line.new(x1, y1, x2, y2, xloc = xloc.bar_index, color = col, width = lnW, style = lnS, force_overlay = false))
    if showLbl
        if ovr
            f_keepLb(label.new(x2, y2, txt, xloc = xloc.bar_index, yloc = yloc.price, color = lbC, textcolor = lbT, style = lbS, size = lbZ, force_overlay = true), origin, side, txt)
        else
            f_keepLb(label.new(x2, y2, txt, xloc = xloc.bar_index, yloc = yloc.price, color = lbC, textcolor = lbT, style = lbS, size = lbZ, force_overlay = false), origin, side, txt)
    0

f_drawLive(int x1, float y1, int x2, float y2, string txt, color col, bool isLow, bool isHid, bool ovr, bool dualPrc) =>
    baseW = isHid ? lwHid : lwReg
    lnW = baseW + (dualPrc ? 1 : 0)
    lnS = isHid ? line.style_dashed : line.style_solid
    hasEye  = str.contains(txt, "👁")
    hasStar = str.contains(txt, "★")
    comboAlpha = hasStar ? math.max(10, hidAlpha - 45) : hasEye ? math.max(25, hidAlpha - 25) : hidAlpha
    lbC = isHid ? color.new(col, comboAlpha) : col
    baseT = isHid ? (hidAlpha >= 55 ? col : color.white) : color.white
    lbT = hasStar ? color.rgb(255, 213, 79) : hasEye ? color.rgb(255, 248, 225) : baseT
    lbS = isLow ? label.style_label_up : label.style_label_down
    lbZ = f_lsize(lsize)
    origin = time[bar_index - x2]
    side = isLow ? 1 : -1
    if showLine
        if ovr
            line.new(x1, y1, x2, y2, xloc = xloc.bar_index, color = col, width = lnW, style = lnS, force_overlay = true)
        else
            line.new(x1, y1, x2, y2, xloc = xloc.bar_index, color = col, width = lnW, style = lnS, force_overlay = false)
    if showLbl
        if ovr
            f_keepLive(label.new(x2, y2, txt, xloc = xloc.bar_index, yloc = yloc.price, color = lbC, textcolor = lbT, style = lbS, size = lbZ, force_overlay = true), origin, side, txt)
        else
            f_keepLive(label.new(x2, y2, txt, xloc = xloc.bar_index, yloc = yloc.price, color = lbC, textcolor = lbT, style = lbS, size = lbZ, force_overlay = false), origin, side, txt)
    0

// 独立眼只画在主图；与背离重合时由背离的单一组合标签取代。
f_drawEye(int x, int origin, float y, bool isLow, bool inZone, bool live, string emaTag) =>
    if showLbl
        eyeCol = isLow ? cBull : cBear
        sty    = isLow ? label.style_label_up : label.style_label_down
        // 独立眼沿用底部 / 顶部信号色；叠加超卖 / 超买时只增加 ★ 并适度提亮。
        eyeTxt = "👁" + (inZone ? "★" : "") + (emaTag == "" ? "" : "\n" + emaTag)
        side = isLow ? 1 : -1
        eyeBg = color.new(eyeCol, inZone ? 64 : 78)
        eyeFg = inZone ? color.rgb(255, 213, 79) : color.new(eyeCol, 5)
        lb = label.new(x, y, eyeTxt, xloc = xloc.bar_index, yloc = yloc.price, color = eyeBg, textcolor = eyeFg, style = sty, size = size.tiny, force_overlay = true)
        if live
            f_keepLive(lb, origin, side, eyeTxt)
        else
            f_keepEye(lb, origin, side, eyeTxt)
    0

f_push(array<float> aE, array<float> aC, array<float> aR, array<int> aB, array<bool> aEV, array<bool> aCV, float e, float c, float r, int b, bool eValid, bool cValid) =>
    array.push(aE, e)
    array.push(aC, c)
    array.push(aR, r)
    array.push(aB, b)
    array.push(aEV, eValid)
    array.push(aCV, cValid)
    while array.size(aB) > effNBack
        array.shift(aE)
        array.shift(aC)
        array.shift(aR)
        array.shift(aB)
        array.shift(aEV)
        array.shift(aCV)
    0

// ══════════ 多周期评分：无绘图事件内核 ══════════
// 位掩码只描述一条已合并事件的原子证据；提醒层级绝不参与计分。
SC_REG    = 1
SC_HID    = 2
SC_EYE    = 4
SC_ZONE   = 8
SC_E21    = 16
SC_E55    = 32
SC_E100   = 64
SC_E200   = 128
SC_DUAL   = 256
SC_RESCUE = 512
SC_CHAIN  = 1024
// 超买卖旅程结束后才开始自然衰减；2.5 根既能跨过短暂回抽，又不会让
// 已离开极值区的背景长期滞留。所有事件池与实时高周期快照共用这一常数。
ZONE_HALF_LIFE = 2.5

f_hasBit(int mask, int bit) =>
    int(math.floor(mask / bit)) % 2 == 1

f_scoreEmaMask(bool isLow, int off) =>
    mask = 0
    if useEmaTouch and bar_index > off
        tolNow    = math.max(syminfo.mintick * 2.0, emaAtr14[off] * emaTolAtr)
        px        = isLow ? low[off] : high[off]
        prevClose = close[off + 1]
        if emaUse21 and f_maTouch(isLow, px, prevClose, ema21v[off], ema21v[off + 1], tolNow)
            mask += SC_E21
        if emaUse55 and f_maTouch(isLow, px, prevClose, ema55v[off], ema55v[off + 1], tolNow)
            mask += SC_E55
        if emaUse100 and f_maTouch(isLow, px, prevClose, ema100v[off], ema100v[off + 1], tolNow)
            mask += SC_E100
        if emaUse200 and f_maTouch(isLow, px, prevClose, ema200v[off], ema200v[off + 1], tolNow)
            mask += SC_E200
    mask

// EMA 作为原标签属性时沿用上面的“接近”定义；作为独立评分事件时再要求
// 当前收盘没有实质穿过均线，避免把正在直接击穿均线的一根 K 线当成支撑 / 压力。
f_scoreEmaTriggerMask(bool isLow) =>
    mask = 0
    if useEmaTouch and bar_index > 0
        tolNow = math.max(syminfo.mintick * 2.0, emaAtr14 * emaTolAtr)
        if emaUse21 and f_maTouch(isLow, isLow ? low : high, close[1], ema21v, ema21v[1], tolNow) and (isLow ? close >= ema21v - tolNow : close <= ema21v + tolNow)
            mask += SC_E21
        if emaUse55 and f_maTouch(isLow, isLow ? low : high, close[1], ema55v, ema55v[1], tolNow) and (isLow ? close >= ema55v - tolNow : close <= ema55v + tolNow)
            mask += SC_E55
        if emaUse100 and f_maTouch(isLow, isLow ? low : high, close[1], ema100v, ema100v[1], tolNow) and (isLow ? close >= ema100v - tolNow : close <= ema100v + tolNow)
            mask += SC_E100
        if emaUse200 and f_maTouch(isLow, isLow ? low : high, close[1], ema200v, ema200v[1], tolNow) and (isLow ? close >= ema200v - tolNow : close <= ema200v + tolNow)
            mask += SC_E200
    mask

f_scoreSat(float x) =>
    v = math.max(0.0, x)
    v / (1.0 + v)

f_scoreEmaOne(int mask, int bit, float length, float ma, bool isLow, int off) =>
    p = 0.0
    if f_hasBit(mask, bit) and not na(ma) and not na(emaAtr14[off])
        atr = math.max(emaAtr14[off], syminfo.mintick * 2.0)
        tolAtr = math.max(2.0 * syminfo.mintick / atr, emaTolAtr)
        px = isLow ? low[off] : high[off]
        d = math.abs(px - ma) / atr
        nearQ = 0.5 + 0.5 * math.max(0.0, 1.0 - d / math.max(tolAtr, 1e-10))
        side = (isLow ? close[off] - ma : ma - close[off]) / atr
        holdQ = math.max(0.0, math.min(1.0, 0.5 + side / math.max(2.0 * tolAtr, 1e-10)))
        touchQ = math.sqrt(nearQ * (0.5 + 0.5 * holdQ))
        // 四条关键 EMA 的即时触碰质量使用同一尺度；更长均线的影响通过
        // 下方更长的事件半衰期体现，不再把“长度”本身重复当成强度。
        cap = 12.0
        p := cap * touchQ
    p

// EMA 的级别、接近程度和收盘后是否守住都连续参与质量。多条均线若本身
// 聚成一束，只保留少量补充；真正彼此分离的关键位置才提供更多独立信息。
// 分数与等效寿命必须使用同一份“实际边际贡献”，避免一条计分为 0 的重合
// 快线仍把 E200 的寿命错误拉短。
f_scoreEmaPack(int mask, bool isLow, int off) =>
    p21  = f_scoreEmaOne(mask, SC_E21, 21.0, ema21v[off], isLow, off)
    p55  = f_scoreEmaOne(mask, SC_E55, 55.0, ema55v[off], isLow, off)
    p100 = f_scoreEmaOne(mask, SC_E100, 100.0, ema100v[off], isLow, off)
    p200 = f_scoreEmaOne(mask, SC_E200, 200.0, ema200v[off], isLow, off)
    main = math.max(math.max(p21, p55), math.max(p100, p200))
    mainMa = main == p200 ? ema200v[off] : main == p100 ? ema100v[off] : main == p55 ? ema55v[off] : ema21v[off]
    h21  = 1.0
    h55  = 1.0 + math.log(55.0 / 21.0) / math.log(2.0)
    h100 = 1.0 + math.log(100.0 / 21.0) / math.log(2.0)
    h200 = 1.0 + math.log(200.0 / 21.0) / math.log(2.0)
    mainH = main == p200 ? h200 : main == p100 ? h100 : main == p55 ? h55 : h21
    atr = math.max(nz(emaAtr14[off]), syminfo.mintick * 2.0)
    q = main / 16.0
    invLife = main > 0 ? main / mainH : 0.0
    if main > 0
        // Pine 中 0 * na 仍是 na；只有该 EMA 本身有效时才计算距离，避免预热早期
        // E21 已可用、较慢 EMA 尚为 na 时把整份位置质量污染成 na。
        if p21 > 0 and not na(ema21v[off])
            qNext = 1.0 - (1.0 - q) * (1.0 - p21 / 16.0 * math.min(1.0, math.abs(ema21v[off] - mainMa) / atr))
            invLife += 16.0 * math.max(0.0, qNext - q) / h21
            q := qNext
        if p55 > 0 and not na(ema55v[off])
            qNext = 1.0 - (1.0 - q) * (1.0 - p55 / 16.0 * math.min(1.0, math.abs(ema55v[off] - mainMa) / atr))
            invLife += 16.0 * math.max(0.0, qNext - q) / h55
            q := qNext
        if p100 > 0 and not na(ema100v[off])
            qNext = 1.0 - (1.0 - q) * (1.0 - p100 / 16.0 * math.min(1.0, math.abs(ema100v[off] - mainMa) / atr))
            invLife += 16.0 * math.max(0.0, qNext - q) / h100
            q := qNext
        if p200 > 0 and not na(ema200v[off])
            qNext = 1.0 - (1.0 - q) * (1.0 - p200 / 16.0 * math.min(1.0, math.abs(ema200v[off] - mainMa) / atr))
            invLife += 16.0 * math.max(0.0, qNext - q) / h200
            q := qNext
    points = math.min(16.0, 16.0 * q)
    [points, points > 0 and invLife > 0 ? points / invLife : 1.0]

f_scoreEmaPoints(int mask, bool isLow, int off) =>
    [points, _] = f_scoreEmaPack(mask, isLow, off)
    points

f_scoreEmaHalfLife(int mask, bool isLow, int off) =>
    [_, halfLife] = f_scoreEmaPack(mask, isLow, off)
    halfLife

f_scoreZonePoints(float r, bool isLow) =>
    // RSI = 100*RS/(1+RS)。顶部比较 RS 与 70 对应的 70/30，底部比较
    // 其倒数；对数把“强弱比扩大了多少倍”变成可加尺度，再无参数有界化。
    // 30～70 不会调用本函数，因此普通区间不被人为拉伸。
    edge = isLow and r <= 0.0 or not isLow and r >= 100.0
    rr = math.max(1e-9, math.min(100.0 - 1e-9, r))
    rs = rr / (100.0 - rr)
    relative = (isLow ? 1.0 / rs : rs) / (70.0 / 30.0)
    excess = math.max(0.0, math.log(math.max(1.0, relative)))
    extremeQ = edge ? 1.0 : excess / (1.0 + excess)
    24.0 * (0.50 + 0.50 * extremeQ)

f_scoreEyePoints(bool isLow, int off) =>
    dev = math.max(nz(eyeDev[off]), syminfo.mintick * 2.0)
    // 越界口径决定某根 K 线是否属于突破段；眼的强度和标记位置始终依据
    // 该段真正的最低价 / 最高价，避免“收盘越界”模式丢失影线极值语义。
    excursion = isLow ? math.max(0.0, eyeLower[off] - low[off]) : math.max(0.0, high[off] - eyeUpper[off])
    z = excursion / dev
    // z=1 就是越出一个布林半宽，直接作为自然半饱和尺度。
    18.0 * (0.50 + 0.50 * z / (1.0 + z))

// 一次连续越轨只产生一个眼。历史在首根回到带内的 K 线收盘后确认；实时
// 尚未收盘时，不论突破仍在延续还是暂时回到带内，都显示当前整段极值候选。
// 函数内 var 在每个静态调用点及各 request.security 上下文中分别保存状态。
f_eyeRun(bool isLow, bool commit, bool preview) =>
    outside = useEye and (isLow ? eyeLoSer < eyeLower : eyeHiSer > eyeUpper)
    px = isLow ? low : high
    var bool active = false
    var float extreme = na
    var int extremeBar = 0
    var int extremeTime = 0
    var float extremeRsi = na
    var float extremeY = 0.0
    var float extremeZ = 0.0
    var int extremeEm = 0
    var float extremeE = 0.0
    var float extremeEh = 1.0
    var string extremeEmaTag = ""
    wasActive = active
    better = outside and (not active or na(extreme) or (isLow ? px < extreme : px > extreme))
    if better
        extreme := px
        extremeBar := bar_index
        extremeTime := time
        extremeRsi := rsi
        extremeY := f_scoreEyePoints(isLow, 0)
        extremeZ := isLow ? (rsi <= OS_LV ? f_scoreZonePoints(rsi, true) : 0.0) : (rsi >= OB_LV ? f_scoreZonePoints(rsi, false) : 0.0)
        extremeEm := f_scoreEmaMask(isLow, 0)
        extremeE := f_scoreEmaPoints(extremeEm, isLow, 0)
        extremeEh := f_scoreEmaHalfLife(extremeEm, isLow, 0)
        extremeEmaTag := f_emaTag(isLow, 0)
    ended = useEye and wasActive and not outside
    event = useEye and ((preview and (outside or ended)) or (commit and ended))
    if commit
        active := useEye and outside
    else if outside
        active := true
    if not useEye and commit
        active := false
    [event, extremeTime, extremeBar, extreme, extremeRsi, extremeY, extremeZ, extremeEm, extremeE, extremeEh, extremeEmaTag]

[eyeLowHit, eyeLowOrigin, eyeLowBar, eyeLowPrice, eyeLowRsi, eyeLowY, eyeLowZ, eyeLowEm, eyeLowE, eyeLowEh, eyeLowEmaTag] = f_eyeRun(true, barstate.isconfirmed, isLiveOpen)
[eyeHighHit, eyeHighOrigin, eyeHighBar, eyeHighPrice, eyeHighRsi, eyeHighY, eyeHighZ, eyeHighEm, eyeHighE, eyeHighEh, eyeHighEmaTag] = f_eyeRun(false, barstate.isconfirmed, isLiveOpen)

// 未收盘高周期事件的成熟度。这里只衡量“本根新出现的信息”已经走完多少；
// 已经由更早收盘 K 线建立的旅程不会在每根新柱开盘时重新从 15% 起算。
f_scorePreviewMaturity() =>
    te = barstate.isrealtime ? math.min(timenow, time_close) : time_close
    phase = not na(time) and not na(time_close) and not na(te) and time_close > time ? math.max(0.0, math.min(1.0, (te - time) / (time_close - time))) : 0.0
    // 只知道本源周期 K 线的起点与终点时，线性是最少额外形状假设。
    phase

// 多周期评分只需保存极值事件的时间、眼强度与当时的超买卖深度；均线触及
// 继续由既有 EMA 事件通道记录，避免在每个 request 中复制标签与价格字段。
f_eyeScoreRun(bool isLow, bool commit, int previewMode) =>
    preview = previewMode > 0
    outside = useEye and (isLow ? eyeLoSer < eyeLower : eyeHiSer > eyeUpper)
    px = isLow ? low : high
    var bool active = false
    var float extreme = na
    var int origin = 0
    var float y = 0.0
    var float z = 0.0
    var int em = 0
    var float e = 0.0
    var float eh = 1.0
    wasActive = active
    previousY = y
    moved = outside and (not active or na(extreme) or (isLow ? px < extreme : px > extreme))
    if moved
        extreme := px
        origin := time
        y := f_scoreEyePoints(isLow, 0)
        z := isLow ? (rsi <= OS_LV ? f_scoreZonePoints(rsi, true) : 0.0) : (rsi >= OB_LV ? f_scoreZonePoints(rsi, false) : 0.0)
        em := f_scoreEmaMask(isLow, 0)
        e := f_scoreEmaPoints(em, isLow, 0)
        eh := f_scoreEmaHalfLife(em, isLow, 0)
    ended = useEye and wasActive and not outside
    event = useEye and ((preview and (outside or ended)) or (commit and ended))
    if commit
        active := useEye and outside
    else if outside
        active := true
    if not useEye and commit
        active := false
    // 眼本体描述同一次连续越轨：旅程此前已由收盘 K 线建立时，旧强度保持
    // 完整；当前未收盘柱若把极值推远，只让新增幅度随本柱成熟。超买卖与 EMA
    // 是“当前极值端点”的局部属性，端点一旦移动便重新成熟，绝不把旧端点的
    // 共振或均线 mask 搬到新端点。
    m = previewMode == 2 ? f_scorePreviewMaturity() : 1.0
    shownY = preview ? not wasActive ? y * m : moved ? previousY + (y - previousY) * m : y : y
    shownZ = preview and (not wasActive or moved) ? z * m : z
    shownE = preview and (not wasActive or moved) ? e * m : e
    [event, origin, shownY, shownZ, em, shownE, eh]

// 超买卖不是“第一次碰线”的一次性脉冲，而是一整段极值旅程。进入 30/70
// 后持续追踪最深 RSI 及其真实 K 线；回到 35/65 才结束，避免在阈值附近反复
// 拆成多个事件。进行中的已收盘部分可作为高周期背景，未收盘部分保持临时态；
// 旅程结束后才写入正式事件池并开始衰减。
f_scoreZoneRun(bool isLow, bool commit, int previewMode) =>
    preview = previewMode > 0
    enter = isLow ? rsi <= OS_LV : rsi >= OB_LV
    hold = isLow ? rsi < 35.0 : rsi > 65.0
    var bool active = false
    var float extremeRsi = na
    var int extremeOrigin = 0
    var float extremeZ = 0.0
    wasActive = active
    previousZ = extremeZ
    inRun = wasActive ? hold : enter
    better = inRun and (not wasActive or na(extremeRsi) or (isLow ? rsi < extremeRsi : rsi > extremeRsi))
    if better
        extremeRsi := rsi
        extremeOrigin := time
        extremeZ := f_scoreZonePoints(rsi, isLow)
    // 若旅程早已由收盘 K 线建立，本根盘中只对“新加深的部分”使用成熟度；
    // 旧的已确认深度保持完整，避免每根高周期刚开盘时整体强度骤降。
    m = previewMode == 2 ? f_scorePreviewMaturity() : 1.0
    shownZ = preview ? not wasActive ? extremeZ * m : better ? previousZ + (extremeZ - previousZ) * m : extremeZ : extremeZ
    ended = wasActive and not inRun
    event = inRun or ended
    if commit
        active := inRun
    else if preview and inRun
        active := true
    [event, ended, extremeOrigin, shownZ, wasActive]

f_scoreDivPoints(bool isReg, bool isHid, bool dualPrc, bool rescued, float rsiDelta, float priceDelta, int gap, int off) =>
    // 常规 / 隐性都先回答“本周期这条结构有多明显”；反转或顺势价值留给
    // 趋势层。gap 已用于配对、路径和阻断，不再把长跨度背离重复降权。
    base = isReg or isHid ? 44.0 : 0.0
    rScale = math.max(1e-6, nz(rsiStep14[off], 1.0))
    pScale = math.max(syminfo.mintick * 2.0, nz(emaAtr14[off], syminfo.mintick * 2.0))
    ampQ = math.sqrt(f_scoreSat(math.abs(rsiDelta) / rScale) * f_scoreSat(math.abs(priceDelta) / pScale))
    // 有效性与程度分离：结构再轻微也是背离，但指数可以如实很低。双价仍
    // 作为稳健性标识；救回已通过自己的严格条件，二者都不再乘任意固定系数。
    base * ampQ

// 连续背离只奖励“前一条终点 = 后一条起点”的同方向、同类型链。奖励取前后
// 两条基础质量的较弱者，且只把未含链奖励的基础分写入状态，所以不会递归滚大。
f_scoreChainBonus(float currentDivPts, float previousDivPts, bool regular, bool rescuedNow, bool rescuedBefore) =>
    curQ = math.max(0.0, math.min(1.0, currentDivPts / 44.0))
    prevQ = math.max(0.0, math.min(1.0, previousDivPts / 44.0))
    // 两条连续背离共享一个枢轴，因此前一条按半独立证据填充当前 D 的剩余空间。
    combined = 44.0 * (1.0 - (1.0 - curQ) * (1.0 - 0.5 * prevQ))
    math.max(0.0, combined - currentDivPts)

// 动量组（背离 / RSI 极值）与位置组（眼 / EMA）先各自处理相关性，再在
// 两组之间作有界并集。加入真实同向原子永不减分，边际贡献自然递减。
f_scoreBundle(float divPts, float zonePts, float eyePts, float emaPts) =>
    momentum = math.max(divPts, zonePts) + 0.5 * math.min(divPts, zonePts)
    location = math.max(eyePts, emaPts) + 0.5 * math.min(eyePts, emaPts)
    math.max(0.0, math.min(70.0, momentum + location - momentum * location / 70.0))

// 逆势保留能力必须来自至少两类反转证据的连续共振，而不是把三个原子直接
// 相加成最高约 3 倍。任一类为零时对应配对贡献也为零，结果严格限制在 0～1。
f_scoreReversalQuality(float divPts, float zonePts, float eyePts, float emaPts, int mask) =>
    dQ = f_hasBit(mask, SC_REG) ? math.max(0.0, math.min(1.0, divPts / 44.0)) : 0.0
    zQ = f_hasBit(mask, SC_ZONE) ? math.max(0.0, math.min(1.0, zonePts / 24.0)) : 0.0
    yQ = f_hasBit(mask, SC_EYE) ? math.max(0.0, math.min(1.0, eyePts / 18.0)) : 0.0
    hasE = f_hasBit(mask, SC_E21) or f_hasBit(mask, SC_E55) or f_hasBit(mask, SC_E100) or f_hasBit(mask, SC_E200)
    eQ = hasE ? math.max(0.0, math.min(1.0, emaPts / 16.0)) : 0.0
    1.0 - (1.0 - dQ * zQ) * (1.0 - dQ * yQ) * (1.0 - dQ * eQ) *
      (1.0 - zQ * yQ) * (1.0 - zQ * eQ) * (1.0 - yQ * eQ)

// 一个端点先打包、后计分。最强原子证据完整计入，其余原子只计一半，
// 既让“越多越强”成立，也避免背离、眼、区间和 EMA 机械相加造成虚高。
f_scoreDivHalfLife(int mask) =>
    f_hasBit(mask, SC_REG) or f_hasBit(mask, SC_HID) ? 4.0 : 1.0

f_kPath(array<float> ser, array<int> ids, int b1, float y1, int b2, float y2, bool isHigh, float tol) =>
    clean = true
    n = array.size(ids)
    if n > 0 and b2 - b1 >= 2
        base = array.get(ids, 0)
        span = (b2 - b1) * 1.0
        sk = math.max(0, math.min(effEdgeSkip, int(math.floor((b2 - b1 - 1) / 4.0))))
        yMax = math.max(y1, y2)
        yMin = math.min(y1, y2)
        for k = b1 + 1 to b2 - 1
            idx = k - base
            if idx < 0 or idx >= n
                clean := false
                break
            v = array.get(ser, idx)
            mid = k >= b1 + 1 + sk and k <= b2 - 1 - sk
            yl = y1 + (y2 - y1) * ((k - b1) / span)
            if isHigh
                if v > yMax + tol or (mid and v > yl + tol)
                    clean := false
                    break
            else
                if v < yMin - tol or (mid and v < yl - tol)
                    clean := false
                    break
    clean

f_kOscOk(array<float> rs, array<int> ids, int b1, float y1, int b2, float y2, bool isHigh) =>
    effChkPath and effChkOsc ? f_kPath(rs, ids, b1, y1, b2, y2, isHigh, effTolOsc) : true

f_kPrcOk(array<float> ser, array<int> ids, int b1, float y1, int b2, float y2, bool isHigh) =>
    effChkPath and effChkPrc ? f_kPath(ser, ids, b1, y1, b2, y2, isHigh, math.abs(y1) * effTolPrc / 100.0) : true

// 关键 EMA 救回只有这一份纯判定。主绘图与多周期内核分别传入自己的、
// 但应当逐柱相同的候选池和原始序列；这样不会因两份近似代码日后漂移。
// 返回：是否命中、候选数组下标、旧收盘价、旧 RSI、RSI 端点差。
f_rescueCore(bool isLow, array<float> aC, array<float> aR, array<int> aB, array<bool> aCV, array<float> rawC, array<float> rawR, array<int> rawI, int bNow, float cNow, float rNow, bool currentCloseValid, bool emaHit) =>
    bool hit = false
    int hitI = -1
    float oldC = na
    float oldR = na
    float delta = 0.0
    enabled = emaRescue and useEmaTouch and (isLow ? uRB : uRS) and useC and currentCloseValid and emaHit and (not obosOnly or (isLow ? rNow <= OS_LV : rNow >= OB_LV))
    if enabled
        n = array.size(aB)
        if n > 0
            for i = n - 1 to 0
                bOld = array.get(aB, i)
                gap = bNow - bOld
                if gap > mxGap
                    break
                if gap > 0 and gap >= rescueMnGap and array.get(aCV, i)
                    cOld = array.get(aC, i)
                    rOld = array.get(aR, i)
                    rsiClean = isLow ? (rNow > rOld and rNow - rOld >= rescueMinRsiD and f_kPath(rawR, rawI, bOld, rOld, bNow, rNow, false, effTolOsc)) : (rNow < rOld and rOld - rNow >= rescueMinRsiD and f_kPath(rawR, rawI, bOld, rOld, bNow, rNow, true, effTolOsc))
                    prcClean = isLow ? (cNow < cOld and f_kPath(rawC, rawI, bOld, cOld, bNow, cNow, false, math.abs(cOld) * effTolPrc / 100.0)) : (cNow > cOld and f_kPath(rawC, rawI, bOld, cOld, bNow, cNow, true, math.abs(cOld) * effTolPrc / 100.0))
                    if rsiClean and prcClean
                        hit := true
                        hitI := i
                        oldC := cOld
                        oldR := rOld
                        delta := isLow ? rNow - rOld : rOld - rNow
                    // 最近一个达到放宽后最小间隔且收盘端点有效的候选拥有唯一裁决权。
                    break
    [hit, hitI, oldC, oldR, delta]

f_kPush(array<float> aE, array<float> aC, array<float> aR, array<int> aB, array<int> aT, array<bool> aEV, array<bool> aCV, float e, float c, float r, int b, int t, bool eValid, bool cValid) =>
    array.push(aE, e)
    array.push(aC, c)
    array.push(aR, r)
    array.push(aB, b)
    array.push(aT, t)
    array.push(aEV, eValid)
    array.push(aCV, cValid)
    while array.size(aB) > effNBack
        array.shift(aE)
        array.shift(aC)
        array.shift(aR)
        array.shift(aB)
        array.shift(aT)
        array.shift(aEV)
        array.shift(aCV)
    0

f_scoreMaskUnion(int a, int b) =>
    out = a
    out += not f_hasBit(out, SC_REG) and f_hasBit(b, SC_REG) ? SC_REG : 0
    out += not f_hasBit(out, SC_HID) and f_hasBit(b, SC_HID) ? SC_HID : 0
    out += not f_hasBit(out, SC_EYE) and f_hasBit(b, SC_EYE) ? SC_EYE : 0
    out += not f_hasBit(out, SC_ZONE) and f_hasBit(b, SC_ZONE) ? SC_ZONE : 0
    out += not f_hasBit(out, SC_E21) and f_hasBit(b, SC_E21) ? SC_E21 : 0
    out += not f_hasBit(out, SC_E55) and f_hasBit(b, SC_E55) ? SC_E55 : 0
    out += not f_hasBit(out, SC_E100) and f_hasBit(b, SC_E100) ? SC_E100 : 0
    out += not f_hasBit(out, SC_E200) and f_hasBit(b, SC_E200) ? SC_E200 : 0
    out += not f_hasBit(out, SC_DUAL) and f_hasBit(b, SC_DUAL) ? SC_DUAL : 0
    out += not f_hasBit(out, SC_RESCUE) and f_hasBit(b, SC_RESCUE) ? SC_RESCUE : 0
    out += not f_hasBit(out, SC_CHAIN) and f_hasBit(b, SC_CHAIN) ? SC_CHAIN : 0
    out

f_kAddEvent(array<float> aD, array<float> aZ, array<float> aY, array<float> aE, array<float> aEH, array<int> aB, array<int> aO, array<int> aM, float divPts, float zonePts, float eyePts, float emaPts, float emaHalfLife, int origin, int mask) =>
    found = false
    n = array.size(aD)
    if n > 0 and origin != 0
        for i = n - 1 to 0
            if array.get(aO, i) == origin
                age = math.max(0, bar_index - array.get(aB, i))
                oldMask = array.get(aM, i)
                oldD = array.get(aD, i) * math.pow(0.5, age / f_scoreDivHalfLife(oldMask))
                oldZ = array.get(aZ, i) * math.pow(0.5, age / ZONE_HALF_LIFE)
                oldY = array.get(aY, i) * math.pow(0.5, age / 2.0)
                oldE = array.get(aE, i) * math.pow(0.5, age / array.get(aEH, i))
                oldHasD = f_hasBit(oldMask, SC_REG) or f_hasBit(oldMask, SC_HID)
                oldHasZ = f_hasBit(oldMask, SC_ZONE)
                oldHasY = f_hasBit(oldMask, SC_EYE)
                oldHasE = f_hasBit(oldMask, SC_E21) or f_hasBit(oldMask, SC_E55) or f_hasBit(oldMask, SC_E100) or f_hasBit(oldMask, SC_E200)
                // 同一端点可能先以“超买卖/EMA 当前事件”出生，若干根后才完成
                // 枢轴确认并补入背离/眼。旧原子先衰减到现在，新出现的原子才
                // 取出生值，再整体以当前柱重定基；旧 zone/EMA 不会随背离确认返老还童。
                array.set(aD, i, oldHasD ? oldD : divPts)
                array.set(aZ, i, oldHasZ ? oldZ : zonePts)
                array.set(aY, i, oldHasY ? oldY : eyePts)
                array.set(aE, i, oldHasE ? oldE : emaPts)
                array.set(aEH, i, oldHasE ? array.get(aEH, i) : emaHalfLife)
                array.set(aB, i, bar_index)
                array.set(aM, i, f_scoreMaskUnion(oldMask, mask))
                found := true
                break
    if not found
        array.push(aD, divPts)
        array.push(aZ, zonePts)
        array.push(aY, eyePts)
        array.push(aE, emaPts)
        array.push(aEH, emaHalfLife)
        array.push(aB, bar_index)
        array.push(aO, origin)
        array.push(aM, mask)
    // 先清掉已经自然衰减到 1 分以下的事件，再保留最多 32 条。旧上限 12
    // 在震荡期可能早于半衰期把仍有效事件 FIFO 挤掉；32 足以覆盖当前最长
    // 原子寿命的大多数重叠窗口，同时避免每个高周期请求无限扫描历史事件。
    pruneI = array.size(aD) - 1
    while pruneI >= 0
        pruneAge = math.max(0, bar_index - array.get(aB, pruneI))
        pruneMask = array.get(aM, pruneI)
        pruneD = array.get(aD, pruneI) * math.pow(0.5, pruneAge / f_scoreDivHalfLife(pruneMask))
        pruneZ = array.get(aZ, pruneI) * math.pow(0.5, pruneAge / ZONE_HALF_LIFE)
        pruneY = array.get(aY, pruneI) * math.pow(0.5, pruneAge / 2.0)
        pruneEH = array.get(aEH, pruneI)
        pruneE = array.get(aE, pruneI) * math.pow(0.5, pruneAge / pruneEH)
        if f_scoreBundle(pruneD, pruneZ, pruneY, pruneE) < 1.0
            array.remove(aD, pruneI)
            array.remove(aZ, pruneI)
            array.remove(aY, pruneI)
            array.remove(aE, pruneI)
            array.remove(aEH, pruneI)
            array.remove(aB, pruneI)
            array.remove(aO, pruneI)
            array.remove(aM, pruneI)
        pruneI -= 1
    while array.size(aD) > 32
        array.shift(aD)
        array.shift(aZ)
        array.shift(aY)
        array.shift(aE)
        array.shift(aEH)
        array.shift(aB)
        array.shift(aO)
        array.shift(aM)
    0

// 标签分数必须读取“这个真实端点目前已经拥有的全部原子”，不能只看本根
// 新确认的那一项。同一端点的背离、眼、超买卖和 EMA 可能相隔数根才确认；
// 旧原子先按自己的半衰期衰减，再与新原子合并，避免更强组合反而覆盖成单项。
f_kOriginState(array<float> aD, array<float> aZ, array<float> aY, array<float> aE, array<float> aEH, array<int> aB, array<int> aO, array<int> aM, int origin, int ageOffset) =>
    found = false
    d = 0.0
    z = 0.0
    y = 0.0
    e = 0.0
    eh = 1.0
    mask = 0
    n = array.size(aD)
    if origin > 0 and n > 0
        for i = n - 1 to 0
            if array.get(aO, i) == origin
                age = math.max(0, bar_index - array.get(aB, i) - ageOffset)
                mask := array.get(aM, i)
                d := array.get(aD, i) * math.pow(0.5, age / f_scoreDivHalfLife(mask))
                z := array.get(aZ, i) * math.pow(0.5, age / ZONE_HALF_LIFE)
                y := array.get(aY, i) * math.pow(0.5, age / 2.0)
                eh := array.get(aEH, i)
                e := array.get(aE, i) * math.pow(0.5, age / eh)
                found := true
                break
    [found, d, z, y, e, eh, mask]

f_kAggregate(array<float> aD, array<float> aZ, array<float> aY, array<float> aE, array<float> aEH, array<int> aB, array<int> aO, array<int> aM, int ageOffset) =>
    v1 = 0.0
    m1 = 0
    age1 = 100000
    origin1 = 0
    d1 = 0.0
    z1 = 0.0
    y1 = 0.0
    e1 = 0.0
    eh1 = 1.0
    n = array.size(aD)
    if n > 0
        for i = 0 to n - 1
            // 当前源周期尚未收盘时，不把正在形成的这一根提前算成完整的一根衰减。
            age = math.max(0, bar_index - array.get(aB, i) - ageOffset)
            mask = array.get(aM, i)
            d = array.get(aD, i) * math.pow(0.5, age / f_scoreDivHalfLife(mask))
            z = array.get(aZ, i) * math.pow(0.5, age / ZONE_HALF_LIFE)
            y = array.get(aY, i) * math.pow(0.5, age / 2.0)
            eh = array.get(aEH, i)
            e = array.get(aE, i) * math.pow(0.5, age / eh)
            v = f_scoreBundle(d, z, y, e)
            // 不设三倍半衰期硬截止；低于 1 分后才自然忽略，避免周线背景断崖。
            if v >= 1.0 and v > v1
                v1 := v
                // mask 表示事件出生时的证据家族，必须保持稳定。若按某个衰减后
                // 原子是否刚好高于 0.5 改写 mask，会令同波相似度和背离半衰期在
                // 阈值处跳变；强度是否仍有效由连续的 d/z/y/e 自身表达。
                m1 := mask
                age1 := age
                origin1 := array.get(aO, i)
                d1 := d
                z1 := z
                y1 := y
                e1 := e
                eh1 := eh
    // 同一源周期只暴露当前最强、仍有效的一条原始事件背景。
    // 旧事件不会彼此堆叠，也不会在低周期再次递归复利。
    [v1, m1, age1, origin1, d1, z1, y1, e1, eh1]

// 复制正式检测的判定顺序，但不创建线、标签、表格或提醒。
// 当前周期与 request.security 的源周期都消费这一份事件内核；输出只含原始事件背景，
// 不含任何已经叠加过的高周期综合分，避免低周期递归重复计分。
f_scoreKernel(bool kCommit, int kPreviewMode) =>
    // request.security 的 calc_bars_count 可能只让本内核从最近一段历史开始运行，
    // 不能用全图绝对 bar_index 冒充“本状态机已经看过多少根”。
    var int kSeen = 0
    kSeen += 1
    // 0=正式路径，1=本图表实时预览（全额），2=高周期实时预览（新生原子成熟）。
    // 复用原有第二个参数，避免大型内核因新增形参在 7 个上下文中膨胀。
    kPreview = kPreviewMode > 0
    kM = kPreviewMode == 2 ? f_scorePreviewMaturity() : 1.0
    [kEyeB, kEyeOriginB, kEyeYB, kEyeZB, kEyeEmB, kEyeEB, kEyeEhB] = f_eyeScoreRun(true, kCommit, kPreviewMode)
    [kEyeS, kEyeOriginS, kEyeYS, kEyeZS, kEyeEmS, kEyeES, kEyeEhS] = f_eyeScoreRun(false, kCommit, kPreviewMode)
    [kZoneB, kZoneEndedB, kZoneOriginB, kZoneZB, kZoneWasActiveB] = f_scoreZoneRun(true, kCommit, kPreviewMode)
    [kZoneS, kZoneEndedS, kZoneOriginS, kZoneZS, kZoneWasActiveS] = f_scoreZoneRun(false, kCommit, kPreviewMode)
    var kH = array.new<float>()
    var kL = array.new<float>()
    var kC = array.new<float>()
    var kR = array.new<float>()
    var kI = array.new<int>()
    array.push(kH, high)
    array.push(kL, low)
    array.push(kC, close)
    array.push(kR, rsi)
    array.push(kI, bar_index)
    while array.size(kI) > bufN
        array.shift(kH)
        array.shift(kL)
        array.shift(kC)
        array.shift(kR)
        array.shift(kI)

    var kloE = array.new<float>()
    var kloC = array.new<float>()
    var kloR = array.new<float>()
    var kloB = array.new<int>()
    var kloT = array.new<int>()
    var kloEV = array.new<bool>()
    var kloCV = array.new<bool>()
    var khiE = array.new<float>()
    var khiC = array.new<float>()
    var khiR = array.new<float>()
    var khiB = array.new<int>()
    var khiT = array.new<int>()
    var khiEV = array.new<bool>()
    var khiCV = array.new<bool>()

    var buyD = array.new<float>()
    var buyZ = array.new<float>()
    var buyY = array.new<float>()
    var buyE = array.new<float>()
    var buyEH = array.new<float>()
    var buyB = array.new<int>()
    var buyO = array.new<int>()
    var buyM = array.new<int>()
    var sellD = array.new<float>()
    var sellZ = array.new<float>()
    var sellY = array.new<float>()
    var sellE = array.new<float>()
    var sellEH = array.new<float>()
    var sellB = array.new<int>()
    var sellO = array.new<int>()
    var sellM = array.new<int>()
    var bool emaBuyArmed = true
    var bool emaSellArmed = true
    var int lastEmaBuyBar = na
    var int lastEmaSellBar = na
    // 每个 f_scoreKernel 调用域（本周期或某个 request.security 源周期）各自保留
    // 最近一条已确认背离的终点和“未含连续奖励”的基础质量。
    var int lastBuyDivEnd = 0
    var int lastSellDivEnd = 0
    var float lastBuyDivBase = 0.0
    var float lastSellDivBase = 0.0
    var int lastBuyDivMask = 0
    var int lastSellDivMask = 0

    kRegB = false
    kHidB = false
    kRegS = false
    kHidS = false
    kDualB = false
    kDualS = false
    kRescueB = false
    kRescueS = false
    kBuyDelta = 0.0
    kSellDelta = 0.0
    kBuyPriceDelta = 0.0
    kSellPriceDelta = 0.0
    kBuyGap = 1
    kSellGap = 1
    kBuyOrigin = 0
    kSellOrigin = 0
    buyPulse = false
    sellPulse = false
    buyPulsePts = 0.0
    sellPulsePts = 0.0
    buyPulseMask = 0
    sellPulseMask = 0
    buyPulseOrigin = 0
    sellPulseOrigin = 0
    buyPulseD = 0.0
    buyPulseZ = 0.0
    buyPulseY = 0.0
    buyPulseE = 0.0
    buyPulseEH = 1.0
    buyPulseEstablishedRun = false
    sellPulseD = 0.0
    sellPulseZ = 0.0
    sellPulseY = 0.0
    sellPulseE = 0.0
    sellPulseEH = 1.0
    sellPulseEstablishedRun = false
    if not na(pl)
        bL = bar_index - pivRight
        eL = loSrc[pivRight]
        cL = close[pivRight]
        rL = pl
        curCanE = useE and pivotLoEValid
        curCanC = useC and pivotLoCValid
        doneR = not uRB or not (curCanE or curCanC)
        doneH = not uHB or not (curCanE or curCanC)
        nLo = array.size(kloB)
        if nLo > 0
            for i = nLo - 1 to 0
                if doneR and doneH
                    break
                bC = array.get(kloB, i)
                gap = bL - bC
                if gap > mxGap
                    break
                eC = array.get(kloE, i)
                cC = array.get(kloC, i)
                rC = array.get(kloR, i)
                pairE = curCanE and array.get(kloEV, i)
                pairC = curCanC and array.get(kloCV, i)
                ok = gap >= mnGap
                if not doneR
                    wickOk = false
                    closeOk = false
                    if ok and (not obosOnly or rL <= OS_LV) and rL > rC and rL - rC >= effMinRsiD and f_kOscOk(kR, kI, bC, rC, bL, rL, false)
                        wickOk := pairE and eL < eC and f_kPrcOk(kL, kI, bC, eC, bL, eL, false)
                        closeOk := pairC and cL < cC and f_kPrcOk(kC, kI, bC, cC, bL, cL, false)
                    if wickOk or closeOk
                        doneR := true
                        doneH := true
                        if kCommit or kPreview
                            kRegB := true
                            kDualB := wickOk and closeOk
                            kBuyDelta := rL - rC
                            kBuyPriceDelta := math.max(wickOk ? eC - eL : 0.0, closeOk ? cC - cL : 0.0)
                            kBuyGap := gap
                            kBuyOrigin := array.get(kloT, i)
                    else
                        bE = pairE and eC < eL
                        bCl = pairC and cC < cL
                        bR = rC > rL
                        if effStrict and f_blkFor(bE, bCl, bR, pairE, pairC, curCanE, curCanC)
                            doneR := true
                if not doneH
                    wickOk = false
                    closeOk = false
                    if ok and rL < rC and rC - rL >= effMinRsiD and f_kOscOk(kR, kI, bC, rC, bL, rL, false)
                        wickOk := pairE and eL > eC and f_kPrcOk(kL, kI, bC, eC, bL, eL, false)
                        closeOk := pairC and cL > cC and f_kPrcOk(kC, kI, bC, cC, bL, cL, false)
                    if wickOk or closeOk
                        doneH := true
                        doneR := true
                        if kCommit or kPreview
                            kHidB := true
                            kDualB := wickOk and closeOk
                            kBuyDelta := rC - rL
                            kBuyPriceDelta := math.max(wickOk ? eL - eC : 0.0, closeOk ? cL - cC : 0.0)
                            kBuyGap := gap
                            kBuyOrigin := array.get(kloT, i)
                    else
                        bE = pairE and eC > eL
                        bCl = pairC and cC > cL
                        bR = rC < rL
                        if effStrict and f_blkFor(bE, bCl, bR, pairE, pairC, curCanE, curCanC)
                            doneH := true

    if not na(ph)
        bH = bar_index - pivRight
        eH = hiSrc[pivRight]
        cH = close[pivRight]
        rH = ph
        curCanE = useE and pivotHiEValid
        curCanC = useC and pivotHiCValid
        doneR = not uRS or not (curCanE or curCanC)
        doneH = not uHS or not (curCanE or curCanC)
        nHi = array.size(khiB)
        if nHi > 0
            for i = nHi - 1 to 0
                if doneR and doneH
                    break
                bC = array.get(khiB, i)
                gap = bH - bC
                if gap > mxGap
                    break
                eC = array.get(khiE, i)
                cC = array.get(khiC, i)
                rC = array.get(khiR, i)
                pairE = curCanE and array.get(khiEV, i)
                pairC = curCanC and array.get(khiCV, i)
                ok = gap >= mnGap
                if not doneR
                    wickOk = false
                    closeOk = false
                    if ok and (not obosOnly or rH >= OB_LV) and rH < rC and rC - rH >= effMinRsiD and f_kOscOk(kR, kI, bC, rC, bH, rH, true)
                        wickOk := pairE and eH > eC and f_kPrcOk(kH, kI, bC, eC, bH, eH, true)
                        closeOk := pairC and cH > cC and f_kPrcOk(kC, kI, bC, cC, bH, cH, true)
                    if wickOk or closeOk
                        doneR := true
                        doneH := true
                        if kCommit or kPreview
                            kRegS := true
                            kDualS := wickOk and closeOk
                            kSellDelta := rC - rH
                            kSellPriceDelta := math.max(wickOk ? eH - eC : 0.0, closeOk ? cH - cC : 0.0)
                            kSellGap := gap
                            kSellOrigin := array.get(khiT, i)
                    else
                        bE = pairE and eC > eH
                        bCl = pairC and cC > cH
                        bR = rC < rH
                        if effStrict and f_blkFor(bE, bCl, bR, pairE, pairC, curCanE, curCanC)
                            doneR := true
                if not doneH
                    wickOk = false
                    closeOk = false
                    if ok and rH > rC and rH - rC >= effMinRsiD and f_kOscOk(kR, kI, bC, rC, bH, rH, true)
                        wickOk := pairE and eH < eC and f_kPrcOk(kH, kI, bC, eC, bH, eH, true)
                        closeOk := pairC and cH < cC and f_kPrcOk(kC, kI, bC, cC, bH, cH, true)
                    if wickOk or closeOk
                        doneH := true
                        doneR := true
                        if kCommit or kPreview
                            kHidS := true
                            kDualS := wickOk and closeOk
                            kSellDelta := rH - rC
                            kSellPriceDelta := math.max(wickOk ? eC - eH : 0.0, closeOk ? cC - cH : 0.0)
                            kSellGap := gap
                            kSellOrigin := array.get(khiT, i)
                    else
                        bE = pairE and eC < eH
                        bCl = pairC and cC < cH
                        bR = rC > rH
                        if effStrict and f_blkFor(bE, bCl, bR, pairE, pairC, curCanE, curCanC)
                            doneH := true

    // 与主检测相同：普通检测未成立时，关键 EMA 只救回最近一档边缘常规背离。
    if not (kRegB or kHidB) and not na(plEmaRescue) and (kCommit or kPreview)
        bL = bar_index - pivRight
        rL = plEmaRescue
        cL = close[pivRight]
        [hit, hitI, oldC, _, delta] = f_rescueCore(true, kloC, kloR, kloB, kloCV, kC, kR, kI, bL, cL, rL, pivotLoCValid, f_scoreEmaMask(true, pivRight) != 0)
        if hit
            kRegB := true
            kRescueB := true
            kBuyDelta := delta
            kBuyPriceDelta := math.max(0.0, oldC - cL)
            kBuyGap := bL - array.get(kloB, hitI)
            kBuyOrigin := array.get(kloT, hitI)

    if not (kRegS or kHidS) and not na(phEmaRescue) and (kCommit or kPreview)
        bH = bar_index - pivRight
        rH = phEmaRescue
        cH = close[pivRight]
        [hit, hitI, oldC, _, delta] = f_rescueCore(false, khiC, khiR, khiB, khiCV, kC, kR, kI, bH, cH, rH, pivotHiCValid, f_scoreEmaMask(false, pivRight) != 0)
        if hit
            kRegS := true
            kRescueS := true
            kSellDelta := delta
            kSellPriceDelta := math.max(0.0, cH - oldC)
            kSellGap := bH - array.get(khiB, hitI)
            kSellOrigin := array.get(khiT, hitI)

    if not na(pl) and kCommit and ((useE and pivotLoEValid) or (useC and pivotLoCValid))
        f_kPush(kloE, kloC, kloR, kloB, kloT, kloEV, kloCV, loSrc[pivRight], close[pivRight], pl, bar_index - pivRight, time[pivRight], pivotLoEValid, pivotLoCValid)
    if not na(ph) and kCommit and ((useE and pivotHiEValid) or (useC and pivotHiCValid))
        f_kPush(khiE, khiC, khiR, khiB, khiT, khiEV, khiCV, hiSrc[pivRight], close[pivRight], ph, bar_index - pivRight, time[pivRight], pivotHiEValid, pivotHiCValid)

    buyDiv = kRegB or kHidB
    sellDiv = kRegS or kHidS
    buyChain = buyDiv and kBuyOrigin > 0 and kBuyOrigin == lastBuyDivEnd and ((kRegB and f_hasBit(lastBuyDivMask, SC_REG)) or (kHidB and f_hasBit(lastBuyDivMask, SC_HID)))
    sellChain = sellDiv and kSellOrigin > 0 and kSellOrigin == lastSellDivEnd and ((kRegS and f_hasBit(lastSellDivMask, SC_REG)) or (kHidS and f_hasBit(lastSellDivMask, SC_HID)))
    if buyDiv
        origin = time[pivRight]
        zoneNow = rsi[pivRight] <= OS_LV
        emaNow = f_scoreEmaMask(true, pivRight)
        dBase = f_scoreDivPoints(kRegB, kHidB, kDualB, kRescueB, kBuyDelta, kBuyPriceDelta, kBuyGap, pivRight)
        chainBonus = buyChain ? f_scoreChainBonus(dBase, lastBuyDivBase, kRegB, kRescueB, f_hasBit(lastBuyDivMask, SC_RESCUE)) : 0.0
        // 右侧确认柱尚未收盘时，枢轴背离本身仍是本根新信息。背离、链奖励
        // 以及随这次确认才建立的端点属性先逐原子成熟，再与同 origin 的历史池合并。
        newD = (dBase + chainBonus) * kM
        newZ = (zoneNow ? f_scoreZonePoints(rsi[pivRight], true) : 0.0) * kM
        newY = 0.0
        newE = (kRescueB ? 0.0 : f_scoreEmaPoints(emaNow, true, pivRight)) * kM
        newEh = f_scoreEmaHalfLife(emaNow, true, pivRight)
        newMask = (kRegB ? SC_REG : SC_HID) + (zoneNow ? SC_ZONE : 0) + emaNow + (kDualB ? SC_DUAL : 0) + (kRescueB ? SC_RESCUE : 0) + (buyChain ? SC_CHAIN : 0)
        dPts = newD
        zPts = newZ
        yPts = newY
        ePts = newE
        eHl = newEh
        mask = newMask
        if kCommit
            f_kAddEvent(buyD, buyZ, buyY, buyE, buyEH, buyB, buyO, buyM, newD, newZ, newY, newE, newEh, origin, newMask)
            lastBuyDivEnd := origin
            lastBuyDivBase := dBase
            lastBuyDivMask := newMask - (buyChain ? SC_CHAIN : 0)
        [hasOrigin, poolD, poolZ, poolY, poolE, poolEh, poolMask] = f_kOriginState(buyD, buyZ, buyY, buyE, buyEH, buyB, buyO, buyM, origin, kPreview ? 1 : 0)
        if hasOrigin
            dPts := math.max(dPts, poolD)
            zPts := math.max(zPts, poolZ)
            yPts := math.max(yPts, poolY)
            eHl := poolE >= ePts ? poolEh : eHl
            ePts := math.max(ePts, poolE)
            mask := f_scoreMaskUnion(mask, poolMask)
        buyPulse := true
        buyPulsePts := f_scoreBundle(dPts, zPts, yPts, ePts)
        buyPulseMask := mask
        buyPulseOrigin := origin
        buyPulseD := dPts
        buyPulseZ := zPts
        buyPulseY := yPts
        buyPulseE := ePts
        buyPulseEH := eHl
    if sellDiv
        origin = time[pivRight]
        zoneNow = rsi[pivRight] >= OB_LV
        emaNow = f_scoreEmaMask(false, pivRight)
        dBase = f_scoreDivPoints(kRegS, kHidS, kDualS, kRescueS, kSellDelta, kSellPriceDelta, kSellGap, pivRight)
        chainBonus = sellChain ? f_scoreChainBonus(dBase, lastSellDivBase, kRegS, kRescueS, f_hasBit(lastSellDivMask, SC_RESCUE)) : 0.0
        newD = (dBase + chainBonus) * kM
        newZ = (zoneNow ? f_scoreZonePoints(rsi[pivRight], false) : 0.0) * kM
        newY = 0.0
        newE = (kRescueS ? 0.0 : f_scoreEmaPoints(emaNow, false, pivRight)) * kM
        newEh = f_scoreEmaHalfLife(emaNow, false, pivRight)
        newMask = (kRegS ? SC_REG : SC_HID) + (zoneNow ? SC_ZONE : 0) + emaNow + (kDualS ? SC_DUAL : 0) + (kRescueS ? SC_RESCUE : 0) + (sellChain ? SC_CHAIN : 0)
        dPts = newD
        zPts = newZ
        yPts = newY
        ePts = newE
        eHl = newEh
        mask = newMask
        if kCommit
            f_kAddEvent(sellD, sellZ, sellY, sellE, sellEH, sellB, sellO, sellM, newD, newZ, newY, newE, newEh, origin, newMask)
            lastSellDivEnd := origin
            lastSellDivBase := dBase
            lastSellDivMask := newMask - (sellChain ? SC_CHAIN : 0)
        [hasOrigin, poolD, poolZ, poolY, poolE, poolEh, poolMask] = f_kOriginState(sellD, sellZ, sellY, sellE, sellEH, sellB, sellO, sellM, origin, kPreview ? 1 : 0)
        if hasOrigin
            dPts := math.max(dPts, poolD)
            zPts := math.max(zPts, poolZ)
            yPts := math.max(yPts, poolY)
            eHl := poolE >= ePts ? poolEh : eHl
            ePts := math.max(ePts, poolE)
            mask := f_scoreMaskUnion(mask, poolMask)
        sellPulse := true
        sellPulsePts := f_scoreBundle(dPts, zPts, yPts, ePts)
        sellPulseMask := mask
        sellPulseOrigin := origin
        sellPulseD := dPts
        sellPulseZ := zPts
        sellPulseY := yPts
        sellPulseE := ePts
        sellPulseEH := eHl

    // “能否独立出生”和“同端点真实属性”必须分开：rearm 只防止连续停留在
    // 极值区 / 同一 EMA 上逐根重复造事件；只要本根由任一原子建立了新事件，
    // 仍应完整携带当时实际存在的超买卖与 EMA 属性。
    inBuyZoneNow = rsi <= OS_LV
    inSellZoneNow = rsi >= OB_LV
    emaBuyMaskNow = f_scoreEmaTriggerMask(true)
    emaSellMaskNow = f_scoreEmaTriggerMask(false)
    emaBuyPulse = emaBuyArmed and emaBuyMaskNow != 0 and (na(lastEmaBuyBar) or bar_index - lastEmaBuyBar >= 3)
    emaSellPulse = emaSellArmed and emaSellMaskNow != 0 and (na(lastEmaSellBar) or bar_index - lastEmaSellBar >= 3)
    currentBuyEvent = emaBuyPulse or kEyeB
    currentSellEvent = emaSellPulse or kEyeS
    currentBuyOrigin = kEyeB ? kEyeOriginB : time
    currentSellOrigin = kEyeS ? kEyeOriginS : time
    currentBuyEmaAttr = kEyeB ? kEyeEmB : currentBuyEvent ? f_scoreEmaMask(true, 0) : 0
    currentSellEmaAttr = kEyeS ? kEyeEmS : currentSellEvent ? f_scoreEmaMask(false, 0) : 0
    currentBuyMask = (kEyeB ? SC_EYE : 0) + (kEyeZB > 0 or not kEyeB and inBuyZoneNow ? SC_ZONE : 0) + currentBuyEmaAttr
    currentSellMask = (kEyeS ? SC_EYE : 0) + (kEyeZS > 0 or not kEyeS and inSellZoneNow ? SC_ZONE : 0) + currentSellEmaAttr
    if currentBuyEvent and kCommit
        same = buyPulse and buyPulseOrigin == currentBuyOrigin
        dPts = same ? buyPulseD : 0.0
        zPts = math.max(same ? buyPulseZ : 0.0, kEyeB ? kEyeZB : inBuyZoneNow ? f_scoreZonePoints(rsi, true) : 0.0)
        yPts = math.max(same ? buyPulseY : 0.0, kEyeB ? kEyeYB : 0.0)
        ePts = same ? math.max(buyPulseE, kEyeB ? kEyeEB : 0.0) : kEyeB ? kEyeEB : f_scoreEmaPoints(currentBuyEmaAttr, true, 0)
        eHl = same ? (kEyeB and kEyeEB > buyPulseE ? kEyeEhB : buyPulseEH) : kEyeB ? kEyeEhB : f_scoreEmaHalfLife(currentBuyEmaAttr, true, 0)
        currentBuyMask := same ? f_scoreMaskUnion(buyPulseMask, currentBuyMask) : currentBuyMask
        pts = f_scoreBundle(dPts, zPts, yPts, ePts)
        f_kAddEvent(buyD, buyZ, buyY, buyE, buyEH, buyB, buyO, buyM, dPts, zPts, yPts, ePts, eHl, currentBuyOrigin, currentBuyMask)
        [hasOrigin, poolD, poolZ, poolY, poolE, poolEh, poolMask] = f_kOriginState(buyD, buyZ, buyY, buyE, buyEH, buyB, buyO, buyM, currentBuyOrigin, 0)
        if hasOrigin
            dPts := math.max(dPts, poolD)
            zPts := math.max(zPts, poolZ)
            yPts := math.max(yPts, poolY)
            eHl := poolE >= ePts ? poolEh : eHl
            ePts := math.max(ePts, poolE)
            currentBuyMask := f_scoreMaskUnion(currentBuyMask, poolMask)
            pts := f_scoreBundle(dPts, zPts, yPts, ePts)
        if not buyPulse or buyPulseOrigin == currentBuyOrigin
            buyPulse := true
            buyPulsePts := pts
            buyPulseMask := currentBuyMask
            buyPulseOrigin := currentBuyOrigin
            buyPulseD := dPts
            buyPulseZ := zPts
            buyPulseY := yPts
            buyPulseE := ePts
            buyPulseEH := eHl
    if currentSellEvent and kCommit
        same = sellPulse and sellPulseOrigin == currentSellOrigin
        dPts = same ? sellPulseD : 0.0
        zPts = math.max(same ? sellPulseZ : 0.0, kEyeS ? kEyeZS : inSellZoneNow ? f_scoreZonePoints(rsi, false) : 0.0)
        yPts = math.max(same ? sellPulseY : 0.0, kEyeS ? kEyeYS : 0.0)
        ePts = same ? math.max(sellPulseE, kEyeS ? kEyeES : 0.0) : kEyeS ? kEyeES : f_scoreEmaPoints(currentSellEmaAttr, false, 0)
        eHl = same ? (kEyeS and kEyeES > sellPulseE ? kEyeEhS : sellPulseEH) : kEyeS ? kEyeEhS : f_scoreEmaHalfLife(currentSellEmaAttr, false, 0)
        currentSellMask := same ? f_scoreMaskUnion(sellPulseMask, currentSellMask) : currentSellMask
        pts = f_scoreBundle(dPts, zPts, yPts, ePts)
        f_kAddEvent(sellD, sellZ, sellY, sellE, sellEH, sellB, sellO, sellM, dPts, zPts, yPts, ePts, eHl, currentSellOrigin, currentSellMask)
        [hasOrigin, poolD, poolZ, poolY, poolE, poolEh, poolMask] = f_kOriginState(sellD, sellZ, sellY, sellE, sellEH, sellB, sellO, sellM, currentSellOrigin, 0)
        if hasOrigin
            dPts := math.max(dPts, poolD)
            zPts := math.max(zPts, poolZ)
            yPts := math.max(yPts, poolY)
            eHl := poolE >= ePts ? poolEh : eHl
            ePts := math.max(ePts, poolE)
            currentSellMask := f_scoreMaskUnion(currentSellMask, poolMask)
            pts := f_scoreBundle(dPts, zPts, yPts, ePts)
        if not sellPulse or sellPulseOrigin == currentSellOrigin
            sellPulse := true
            sellPulsePts := pts
            sellPulseMask := currentSellMask
            sellPulseOrigin := currentSellOrigin
            sellPulseD := dPts
            sellPulseZ := zPts
            sellPulseY := yPts
            sellPulseE := ePts
            sellPulseEH := eHl
    if kCommit
        // 进行中的超买卖旅程由下面的实时/已收盘状态直接参与背景；只有旅程
        // 真正结束时才固化一条事件，随后从结束柱开始按统一半衰期衰减。
        if kZoneEndedB and kZoneOriginB > 0
            f_kAddEvent(buyD, buyZ, buyY, buyE, buyEH, buyB, buyO, buyM, 0.0, kZoneZB, 0.0, 0.0, 1.0, kZoneOriginB, SC_ZONE)
        if kZoneEndedS and kZoneOriginS > 0
            f_kAddEvent(sellD, sellZ, sellY, sellE, sellEH, sellB, sellO, sellM, 0.0, kZoneZS, 0.0, 0.0, 1.0, kZoneOriginS, SC_ZONE)
        if emaBuyPulse
            lastEmaBuyBar := bar_index
            emaBuyArmed := false
        else if emaBuyMaskNow == 0
            emaBuyArmed := true
        if emaSellPulse
            lastEmaSellBar := bar_index
            emaSellArmed := false
        else if emaSellMaskNow == 0
            emaSellArmed := true

    ageOffset = kPreview ? 1 : 0
    [buyScore, buyTopMask, buyAge, buyOrigin, buyTopD, buyTopZ, buyTopY, buyTopE, buyTopEH] = f_kAggregate(buyD, buyZ, buyY, buyE, buyEH, buyB, buyO, buyM, ageOffset)
    [sellScore, sellTopMask, sellAge, sellOrigin, sellTopD, sellTopZ, sellTopY, sellTopE, sellTopEH] = f_kAggregate(sellD, sellZ, sellY, sellE, sellEH, sellB, sellO, sellM, ageOffset)
    buyTopPreview = false
    sellTopPreview = false
    // 旅程尚未结束时不反复写池，但其“目前已经确认/实时形成的最深状态”仍与
    // 其他事件公平竞争成为当前高周期背景；结束柱已写池，比较仍保持连续。
    kZoneBuyScore = kZoneB and kZoneOriginB > 0 ? f_scoreBundle(0.0, kZoneZB, 0.0, 0.0) : 0.0
    kZoneSellScore = kZoneS and kZoneOriginS > 0 ? f_scoreBundle(0.0, kZoneZS, 0.0, 0.0) : 0.0
    if kZoneBuyScore > buyScore
        buyScore := kZoneBuyScore
        buyTopMask := SC_ZONE
        // -1 只表示“旅程已由更早的收盘柱建立、当前仍在进行”。显示层仍把
        // 当前柱写成临时态，但不会把此前已确认的整段深度重新打成熟度折扣。
        buyAge := kPreview and kZoneWasActiveB ? -1 : 0
        buyOrigin := kZoneOriginB
        buyTopD := 0.0
        buyTopZ := kZoneZB
        buyTopY := 0.0
        buyTopE := 0.0
        buyTopEH := 1.0
        buyTopPreview := kPreview
    if kZoneSellScore > sellScore
        sellScore := kZoneSellScore
        sellTopMask := SC_ZONE
        sellAge := kPreview and kZoneWasActiveS ? -1 : 0
        sellOrigin := kZoneOriginS
        sellTopD := 0.0
        sellTopZ := kZoneZS
        sellTopY := 0.0
        sellTopE := 0.0
        sellTopEH := 1.0
        sellTopPreview := kPreview

    // 最右侧未收盘源周期只产生临时快照，不写入正式事件数组。
    // 强度按当前事实计算；显示层会明确写“实时临时”，历史与提醒永远不用它。
    if kPreview
        lRegB = false
        lHidB = false
        lRegS = false
        lHidS = false
        lDualB = false
        lDualS = false
        lRescueB = false
        lRescueS = false
        lDeltaB = 0.0
        lDeltaS = 0.0
        lPriceDeltaB = 0.0
        lPriceDeltaS = 0.0
        lGapB = 1
        lGapS = 1
        lBuyStart = 0
        lSellStart = 0

        if bar_index >= pivLeft and rsiLeftLow
            doneR = not uRB
            doneH = not uHB
            nLo = array.size(kloB)
            if nLo > 0
                for i = nLo - 1 to 0
                    if doneR and doneH
                        break
                    bC = array.get(kloB, i)
                    gap = bar_index - bC
                    if gap > mxGap
                        break
                    eC = array.get(kloE, i)
                    cC = array.get(kloC, i)
                    rC = array.get(kloR, i)
                    pairE = useE and array.get(kloEV, i)
                    pairC = useC and array.get(kloCV, i)
                    ok = gap >= mnGap
                    if not doneR
                        wickOk = false
                        closeOk = false
                        if ok and (not obosOnly or rsi <= OS_LV) and rsi > rC and rsi - rC >= effMinRsiD and f_kOscOk(kR, kI, bC, rC, bar_index, rsi, false)
                            wickOk := pairE and loSrc < eC and f_kPrcOk(kL, kI, bC, eC, bar_index, loSrc, false)
                            closeOk := pairC and close < cC and f_kPrcOk(kC, kI, bC, cC, bar_index, close, false)
                        if wickOk or closeOk
                            doneR := true
                            doneH := true
                            lRegB := true
                            lDualB := wickOk and closeOk
                            lDeltaB := rsi - rC
                            lPriceDeltaB := math.max(wickOk ? eC - loSrc : 0.0, closeOk ? cC - close : 0.0)
                            lGapB := gap
                            lBuyStart := array.get(kloT, i)
                        else
                            bE = pairE and eC < loSrc
                            bCl = pairC and cC < close
                            bR = rC > rsi
                            if effStrict and f_blkFor(bE, bCl, bR, pairE, pairC, useE, useC)
                                doneR := true
                    if not doneH
                        wickOk = false
                        closeOk = false
                        if ok and rsi < rC and rC - rsi >= effMinRsiD and f_kOscOk(kR, kI, bC, rC, bar_index, rsi, false)
                            wickOk := pairE and loSrc > eC and f_kPrcOk(kL, kI, bC, eC, bar_index, loSrc, false)
                            closeOk := pairC and close > cC and f_kPrcOk(kC, kI, bC, cC, bar_index, close, false)
                        if wickOk or closeOk
                            doneH := true
                            doneR := true
                            lHidB := true
                            lDualB := wickOk and closeOk
                            lDeltaB := rC - rsi
                            lPriceDeltaB := math.max(wickOk ? loSrc - eC : 0.0, closeOk ? close - cC : 0.0)
                            lGapB := gap
                            lBuyStart := array.get(kloT, i)
                        else
                            bE = pairE and eC > loSrc
                            bCl = pairC and cC > close
                            bR = rC < rsi
                            if effStrict and f_blkFor(bE, bCl, bR, pairE, pairC, useE, useC)
                                doneH := true

        if bar_index >= pivLeft and rsiLeftHigh
            doneR = not uRS
            doneH = not uHS
            nHi = array.size(khiB)
            if nHi > 0
                for i = nHi - 1 to 0
                    if doneR and doneH
                        break
                    bC = array.get(khiB, i)
                    gap = bar_index - bC
                    if gap > mxGap
                        break
                    eC = array.get(khiE, i)
                    cC = array.get(khiC, i)
                    rC = array.get(khiR, i)
                    pairE = useE and array.get(khiEV, i)
                    pairC = useC and array.get(khiCV, i)
                    ok = gap >= mnGap
                    if not doneR
                        wickOk = false
                        closeOk = false
                        if ok and (not obosOnly or rsi >= OB_LV) and rsi < rC and rC - rsi >= effMinRsiD and f_kOscOk(kR, kI, bC, rC, bar_index, rsi, true)
                            wickOk := pairE and hiSrc > eC and f_kPrcOk(kH, kI, bC, eC, bar_index, hiSrc, true)
                            closeOk := pairC and close > cC and f_kPrcOk(kC, kI, bC, cC, bar_index, close, true)
                        if wickOk or closeOk
                            doneR := true
                            doneH := true
                            lRegS := true
                            lDualS := wickOk and closeOk
                            lDeltaS := rC - rsi
                            lPriceDeltaS := math.max(wickOk ? hiSrc - eC : 0.0, closeOk ? close - cC : 0.0)
                            lGapS := gap
                            lSellStart := array.get(khiT, i)
                        else
                            bE = pairE and eC > hiSrc
                            bCl = pairC and cC > close
                            bR = rC < rsi
                            if effStrict and f_blkFor(bE, bCl, bR, pairE, pairC, useE, useC)
                                doneR := true
                    if not doneH
                        wickOk = false
                        closeOk = false
                        if ok and rsi > rC and rsi - rC >= effMinRsiD and f_kOscOk(kR, kI, bC, rC, bar_index, rsi, true)
                            wickOk := pairE and hiSrc < eC and f_kPrcOk(kH, kI, bC, eC, bar_index, hiSrc, true)
                            closeOk := pairC and close < cC and f_kPrcOk(kC, kI, bC, cC, bar_index, close, true)
                        if wickOk or closeOk
                            doneH := true
                            doneR := true
                            lHidS := true
                            lDualS := wickOk and closeOk
                            lDeltaS := rsi - rC
                            lPriceDeltaS := math.max(wickOk ? eC - hiSrc : 0.0, closeOk ? cC - close : 0.0)
                            lGapS := gap
                            lSellStart := array.get(khiT, i)
                        else
                            bE = pairE and eC < hiSrc
                            bCl = pairC and cC < close
                            bR = rC > rsi
                            if effStrict and f_blkFor(bE, bCl, bR, pairE, pairC, useE, useC)
                                doneH := true

        // 实时 EMA 救回沿用主检测：仅常规、收盘价、最近一档、强制完整路径。
        if not (lRegB or lHidB) and bar_index >= rescueLeft and rsiRescueLeftLow
            [hit, hitI, oldC, _, delta] = f_rescueCore(true, kloC, kloR, kloB, kloCV, kC, kR, kI, bar_index, close, rsi, true, f_scoreEmaMask(true, 0) != 0)
            if hit
                lRegB := true
                lRescueB := true
                lDeltaB := delta
                lPriceDeltaB := math.max(0.0, oldC - close)
                lGapB := bar_index - array.get(kloB, hitI)
                lBuyStart := array.get(kloT, hitI)
        if not (lRegS or lHidS) and bar_index >= rescueLeft and rsiRescueLeftHigh
            [hit, hitI, oldC, _, delta] = f_rescueCore(false, khiC, khiR, khiB, khiCV, kC, kR, kI, bar_index, close, rsi, true, f_scoreEmaMask(false, 0) != 0)
            if hit
                lRegS := true
                lRescueS := true
                lDeltaS := delta
                lPriceDeltaS := math.max(0.0, close - oldC)
                lGapS := bar_index - array.get(khiB, hitI)
                lSellStart := array.get(khiT, hitI)

        liveBuyEvent = lRegB or lHidB or emaBuyPulse or kEyeB
        liveSellEvent = lRegS or lHidS or emaSellPulse or kEyeS
        liveBuyOrigin = kEyeB and not (lRegB or lHidB) ? kEyeOriginB : time
        liveSellOrigin = kEyeS and not (lRegS or lHidS) ? kEyeOriginS : time
        liveBuyChain = (lRegB or lHidB) and lBuyStart > 0 and lBuyStart == lastBuyDivEnd and ((lRegB and f_hasBit(lastBuyDivMask, SC_REG)) or (lHidB and f_hasBit(lastBuyDivMask, SC_HID)))
        liveSellChain = (lRegS or lHidS) and lSellStart > 0 and lSellStart == lastSellDivEnd and ((lRegS and f_hasBit(lastSellDivMask, SC_REG)) or (lHidS and f_hasBit(lastSellDivMask, SC_HID)))
        liveBuyEyeHere = kEyeB and kEyeOriginB == liveBuyOrigin
        liveSellEyeHere = kEyeS and kEyeOriginS == liveSellOrigin
        liveBuyEmaMask = liveBuyEyeHere ? kEyeEmB : liveBuyEvent and liveBuyOrigin == time ? f_scoreEmaMask(true, 0) : 0
        liveSellEmaMask = liveSellEyeHere ? kEyeEmS : liveSellEvent and liveSellOrigin == time ? f_scoreEmaMask(false, 0) : 0
        // 超买卖与 EMA 一样是端点局部属性。眼的极值若仍在较早 K 线，不能把
        // 当前 K 线的 RSI 区域状态反向挂到旧眼端点；眼自身只采用 run 保存的 Z。
        liveBuyZone = liveBuyEvent and liveBuyOrigin == time and inBuyZoneNow
        liveSellZone = liveSellEvent and liveSellOrigin == time and inSellZoneNow
        liveBuyMask = (lRegB ? SC_REG : 0) + (lHidB ? SC_HID : 0) + (liveBuyEyeHere ? SC_EYE : 0) + (liveBuyZone or liveBuyEyeHere and kEyeZB > 0 ? SC_ZONE : 0) + liveBuyEmaMask + (lDualB ? SC_DUAL : 0) + (lRescueB ? SC_RESCUE : 0) + (liveBuyChain ? SC_CHAIN : 0)
        liveSellMask = (lRegS ? SC_REG : 0) + (lHidS ? SC_HID : 0) + (liveSellEyeHere ? SC_EYE : 0) + (liveSellZone or liveSellEyeHere and kEyeZS > 0 ? SC_ZONE : 0) + liveSellEmaMask + (lDualS ? SC_DUAL : 0) + (lRescueS ? SC_RESCUE : 0) + (liveSellChain ? SC_CHAIN : 0)
        liveBuyDBase = lRegB or lHidB ? f_scoreDivPoints(lRegB, lHidB, lDualB, lRescueB, lDeltaB, lPriceDeltaB, lGapB, 0) : 0.0
        liveBuyD = (liveBuyDBase + (liveBuyChain ? f_scoreChainBonus(liveBuyDBase, lastBuyDivBase, lRegB, lRescueB, f_hasBit(lastBuyDivMask, SC_RESCUE)) : 0.0)) * kM
        liveBuyZ = math.max((liveBuyZone ? f_scoreZonePoints(rsi, true) : 0.0) * kM, liveBuyEyeHere ? kEyeZB : 0.0)
        liveBuyY = liveBuyEyeHere ? kEyeYB : 0.0
        liveBuyE = lRescueB ? 0.0 : liveBuyEyeHere ? kEyeEB : f_scoreEmaPoints(liveBuyEmaMask, true, 0) * kM
        liveBuyEH = liveBuyEyeHere ? kEyeEhB : f_scoreEmaHalfLife(liveBuyEmaMask, true, 0)
        liveSellDBase = lRegS or lHidS ? f_scoreDivPoints(lRegS, lHidS, lDualS, lRescueS, lDeltaS, lPriceDeltaS, lGapS, 0) : 0.0
        liveSellD = (liveSellDBase + (liveSellChain ? f_scoreChainBonus(liveSellDBase, lastSellDivBase, lRegS, lRescueS, f_hasBit(lastSellDivMask, SC_RESCUE)) : 0.0)) * kM
        liveSellZ = math.max((liveSellZone ? f_scoreZonePoints(rsi, false) : 0.0) * kM, liveSellEyeHere ? kEyeZS : 0.0)
        liveSellY = liveSellEyeHere ? kEyeYS : 0.0
        liveSellE = lRescueS ? 0.0 : liveSellEyeHere ? kEyeES : f_scoreEmaPoints(liveSellEmaMask, false, 0) * kM
        liveSellEH = liveSellEyeHere ? kEyeEhS : f_scoreEmaHalfLife(liveSellEmaMask, false, 0)
        // 未收盘的新原子也必须与这个端点此前已确认、且已自然衰减的原子合并；
        // 否则实时眼晚于背离时会暂时把组合标签改回单项。
        [hasPoolB, poolBD, poolBZ, poolBY, poolBE, poolBEh, poolBM] = f_kOriginState(buyD, buyZ, buyY, buyE, buyEH, buyB, buyO, buyM, liveBuyOrigin, 1)
        if hasPoolB
            liveBuyD := math.max(liveBuyD, poolBD)
            liveBuyZ := math.max(liveBuyZ, poolBZ)
            liveBuyY := math.max(liveBuyY, poolBY)
            liveBuyEH := poolBE >= liveBuyE ? poolBEh : liveBuyEH
            liveBuyE := math.max(liveBuyE, poolBE)
            liveBuyMask := f_scoreMaskUnion(liveBuyMask, poolBM)
        [hasPoolS, poolSD, poolSZ, poolSY, poolSE, poolSEh, poolSM] = f_kOriginState(sellD, sellZ, sellY, sellE, sellEH, sellB, sellO, sellM, liveSellOrigin, 1)
        if hasPoolS
            liveSellD := math.max(liveSellD, poolSD)
            liveSellZ := math.max(liveSellZ, poolSZ)
            liveSellY := math.max(liveSellY, poolSY)
            liveSellEH := poolSE >= liveSellE ? poolSEh : liveSellEH
            liveSellE := math.max(liveSellE, poolSE)
            liveSellMask := f_scoreMaskUnion(liveSellMask, poolSM)
        liveBuyScore = liveBuyEvent ? f_scoreBundle(liveBuyD, liveBuyZ, liveBuyY, liveBuyE) : 0.0
        liveSellScore = liveSellEvent ? f_scoreBundle(liveSellD, liveSellZ, liveSellY, liveSellE) : 0.0
        if liveBuyEvent
            if not buyPulse or buyPulseOrigin == liveBuyOrigin
                buyPulse := true
                buyPulsePts := liveBuyScore
                buyPulseMask := liveBuyMask
                buyPulseOrigin := liveBuyOrigin
                buyPulseD := liveBuyD
                buyPulseZ := liveBuyZ
                buyPulseY := liveBuyY
                buyPulseE := liveBuyE
                buyPulseEH := liveBuyEH
                // 已由收盘柱建立且本柱未移动极值时，眼的 origin 必然早于当前柱；
                // 直接由 origin 判定 tooltip 状态，避免为显示文案扩大内核返回元组。
                buyPulseEstablishedRun := liveBuyEyeHere and kEyeOriginB != time and not (lRegB or lHidB)
        if liveSellEvent
            if not sellPulse or sellPulseOrigin == liveSellOrigin
                sellPulse := true
                sellPulsePts := liveSellScore
                sellPulseMask := liveSellMask
                sellPulseOrigin := liveSellOrigin
                sellPulseD := liveSellD
                sellPulseZ := liveSellZ
                sellPulseY := liveSellY
                sellPulseE := liveSellE
                sellPulseEH := liveSellEH
                sellPulseEstablishedRun := liveSellEyeHere and kEyeOriginS != time and not (lRegS or lHidS)

        // “最强有效事件”和“当前新事件”是两条独立轨道；只有临时新事件
        // 本身更强时，才替换持续背景，并同时返回真实的临时来源标志。
        if buyPulse and buyPulsePts > buyScore
            buyScore := buyPulsePts
            buyTopMask := buyPulseMask
            buyAge := buyPulseEstablishedRun ? -1 : 0
            buyOrigin := buyPulseOrigin
            buyTopD := buyPulseD
            buyTopZ := buyPulseZ
            buyTopY := buyPulseY
            buyTopE := buyPulseE
            buyTopEH := buyPulseEH
            buyTopPreview := true
        if sellPulse and sellPulsePts > sellScore
            sellScore := sellPulsePts
            sellTopMask := sellPulseMask
            sellAge := sellPulseEstablishedRun ? -1 : 0
            sellOrigin := sellPulseOrigin
            sellTopD := sellPulseD
            sellTopZ := sellPulseZ
            sellTopY := sellPulseY
            sellTopE := sellPulseE
            sellTopEH := sellPulseEH
            sellTopPreview := true

    // 同一确认柱若同时产生两个不同 origin 的可见事件，主 pulse 只能携带其一。
    // 为独立眼标签额外回读一次该眼真实端点的事件池，确保罕见碰撞路径也不会
    // 丢掉此前已确认并自然衰减的背离、超买卖或 EMA 原子。
    eyeFullBOrigin = 0
    eyeFullBMask = 0
    eyeFullBD = 0.0
    eyeFullBZ = 0.0
    eyeFullBY = 0.0
    eyeFullBE = 0.0
    eyeFullBEH = 1.0
    if kEyeB and kEyeOriginB > 0
        eyeFullBOrigin := kEyeOriginB
        eyeFullBMask := SC_EYE + (kEyeZB > 0 ? SC_ZONE : 0) + kEyeEmB
        eyeFullBZ := kEyeZB
        eyeFullBY := kEyeYB
        eyeFullBE := kEyeEB
        eyeFullBEH := kEyeEhB
        [hasEyePoolB, eyePoolBD, eyePoolBZ, eyePoolBY, eyePoolBE, eyePoolBEH, eyePoolBM] = f_kOriginState(buyD, buyZ, buyY, buyE, buyEH, buyB, buyO, buyM, kEyeOriginB, kPreview ? 1 : 0)
        if hasEyePoolB
            eyeFullBD := eyePoolBD
            eyeFullBZ := math.max(eyeFullBZ, eyePoolBZ)
            eyeFullBY := math.max(eyeFullBY, eyePoolBY)
            eyeFullBEH := eyePoolBE >= eyeFullBE ? eyePoolBEH : eyeFullBEH
            eyeFullBE := math.max(eyeFullBE, eyePoolBE)
            eyeFullBMask := f_scoreMaskUnion(eyeFullBMask, eyePoolBM)
    eyeFullSOrigin = 0
    eyeFullSMask = 0
    eyeFullSD = 0.0
    eyeFullSZ = 0.0
    eyeFullSY = 0.0
    eyeFullSE = 0.0
    eyeFullSEH = 1.0
    if kEyeS and kEyeOriginS > 0
        eyeFullSOrigin := kEyeOriginS
        eyeFullSMask := SC_EYE + (kEyeZS > 0 ? SC_ZONE : 0) + kEyeEmS
        eyeFullSZ := kEyeZS
        eyeFullSY := kEyeYS
        eyeFullSE := kEyeES
        eyeFullSEH := kEyeEhS
        [hasEyePoolS, eyePoolSD, eyePoolSZ, eyePoolSY, eyePoolSE, eyePoolSEH, eyePoolSM] = f_kOriginState(sellD, sellZ, sellY, sellE, sellEH, sellB, sellO, sellM, kEyeOriginS, kPreview ? 1 : 0)
        if hasEyePoolS
            eyeFullSD := eyePoolSD
            eyeFullSZ := math.max(eyeFullSZ, eyePoolSZ)
            eyeFullSY := math.max(eyeFullSY, eyePoolSY)
            eyeFullSEH := eyePoolSE >= eyeFullSE ? eyePoolSEH : eyeFullSEH
            eyeFullSE := math.max(eyeFullSE, eyePoolSE)
            eyeFullSMask := f_scoreMaskUnion(eyeFullSMask, eyePoolSM)
    // 事件预热与 EMA200 趋势预热分离：长周期历史不足时仍可显示本级事件，
    // 只是持续结构保持中性，不能因为缺少 EMA200 把真实事件一起屏蔽。
    eventReady = kSeen >= math.max(rsiLen + mxGap + pivLeft + pivRight + 10, 40)
    trendReady = kSeen >= 220 and not na(ema200v) and not na(ema200v[14])
    [buyTopMask, sellTopMask, buyAge, sellAge, eventReady, trendReady, buyPulsePts, sellPulsePts, buyPulseMask, sellPulseMask, buyOrigin, sellOrigin, buyPulseOrigin, sellPulseOrigin, buyTopPreview, sellTopPreview, buyTopD, buyTopZ, buyTopY, buyTopE, buyTopEH, sellTopD, sellTopZ, sellTopY, sellTopE, sellTopEH, buyPulseD, buyPulseZ, buyPulseY, buyPulseE, buyPulseEH, sellPulseD, sellPulseZ, sellPulseY, sellPulseE, sellPulseEH, eyeFullBOrigin, eyeFullBMask, eyeFullBD, eyeFullBZ, eyeFullBY, eyeFullBE, eyeFullBEH, eyeFullSOrigin, eyeFullSMask, eyeFullSD, eyeFullSZ, eyeFullSY, eyeFullSE, eyeFullSEH]

// 关键 EMA 共振救回：只看最近一个达到放宽后最小间隔且收盘端点仍有效的正式枢轴；强制使用收盘价和逐根路径检查。
f_rescueLow(int bL, float cL, float rL, bool hasEye, string emaTag, bool currentCloseValid, bool live) =>
    [hit, hitI, cOld, rOld, _] = f_rescueCore(true, loC, loR, loB, loCV, sbC, sbR, sbI, bL, cL, rL, currentCloseValid, emaTag != "")
    if hit
        bOld = array.get(loB, hitI)
        txt = f_sigText(true, false, hasEye, rL <= OS_LV, emaTag)
        if live
            f_drawLive(bOld, rOld, bL, rL, txt, cBull, true, false, false, false)
            f_drawLive(bOld, cOld, bL, cL, txt, cBull, true, false, true, false)
        else
            f_draw(bOld, rOld, bL, rL, txt, cBull, true, false, false, false)
            f_draw(bOld, cOld, bL, cL, txt, cBull, true, false, true, false)
    hit

f_rescueHigh(int bH, float cH, float rH, bool hasEye, string emaTag, bool currentCloseValid, bool live) =>
    [hit, hitI, cOld, rOld, _] = f_rescueCore(false, hiC, hiR, hiB, hiCV, sbC, sbR, sbI, bH, cH, rH, currentCloseValid, emaTag != "")
    if hit
        bOld = array.get(hiB, hitI)
        txt = f_sigText(false, false, hasEye, rH >= OB_LV, emaTag)
        if live
            f_drawLive(bOld, rOld, bH, rH, txt, cBear, false, false, false, false)
            f_drawLive(bOld, cOld, bH, cH, txt, cBear, false, false, true, false)
        else
            f_draw(bOld, rOld, bH, rH, txt, cBear, false, false, false, false)
            f_draw(bOld, cOld, bH, cH, txt, cBear, false, false, true, false)
    hit

// 最右侧未收盘 K 线暂作 RSI 枢轴右端点；配对、路径和阻断规则与正式检测完全相同。
f_liveLow(int bL, float eL, float cL, float rL, bool hasEye, string emaTag) =>
    hitR = false
    hitH = false
    doneR = not uRB
    doneH = not uHB
    nLo = array.size(loB)
    if nLo > 0
        for i = nLo - 1 to 0
            if doneR and doneH
                break
            bC = array.get(loB, i)
            gap = bL - bC
            if gap > mxGap
                break
            eC = array.get(loE, i)
            cC = array.get(loC, i)
            rC = array.get(loR, i)
            pairE = useE and array.get(loEV, i)
            pairC = useC and array.get(loCV, i)
            ok = gap >= mnGap
            if not doneR
                wickOkR = false
                closeOkR = false
                q = not obosOnly or rL <= OS_LV
                if ok and q and rL > rC and rL - rC >= effMinRsiD and f_oscOk(bC, rC, bL, rL, false)
                    wickOkR := pairE and eL < eC and f_prcOk(sbL, bC, eC, bL, eL, false)
                    closeOkR := pairC and cL < cC and f_prcOk(sbC, bC, cC, bL, cL, false)
                sig = wickOkR or closeOkR
                viaC = closeOkR and not wickOkR
                dualPrc = wickOkR and closeOkR
                if sig
                    doneR := true
                    doneH := true
                    hitR := true
                    txt = f_sigText(true, false, hasEye, rL <= OS_LV, emaTag)
                    // 双口径成立时沿用完整价格极值（影线）作为锚点，并以加粗表示收盘价也独立确认。
                    f_drawLive(bC, rC, bL, rL, txt, cBull, true, false, false, dualPrc)
                    f_drawLive(bC, viaC ? cC : eC, bL, viaC ? cL : eL, txt, cBull, true, false, true, dualPrc)
                else
                    bE = pairE and eC < eL
                    bCl = pairC and cC < cL
                    bR = rC > rL
                    if effStrict and f_blkFor(bE, bCl, bR, pairE, pairC, useE, useC)
                        doneR := true
            if not doneH
                wickOkH = false
                closeOkH = false
                if ok and rL < rC and rC - rL >= effMinRsiD and f_oscOk(bC, rC, bL, rL, false)
                    wickOkH := pairE and eL > eC and f_prcOk(sbL, bC, eC, bL, eL, false)
                    closeOkH := pairC and cL > cC and f_prcOk(sbC, bC, cC, bL, cL, false)
                sig = wickOkH or closeOkH
                viaC = closeOkH and not wickOkH
                dualPrc = wickOkH and closeOkH
                if sig
                    doneH := true
                    doneR := true
                    hitH := true
                    txt = f_sigText(true, true, hasEye, rL <= OS_LV, emaTag)
                    f_drawLive(bC, rC, bL, rL, txt, cBull, true, true, false, dualPrc)
                    f_drawLive(bC, viaC ? cC : eC, bL, viaC ? cL : eL, txt, cBull, true, true, true, dualPrc)
                else
                    bE = pairE and eC > eL
                    bCl = pairC and cC > cL
                    bR = rC < rL
                    if effStrict and f_blkFor(bE, bCl, bR, pairE, pairC, useE, useC)
                        doneH := true
    [hitR, hitH]

f_liveHigh(int bH, float eH, float cH, float rH, bool hasEye, string emaTag) =>
    hitR = false
    hitH = false
    doneR = not uRS
    doneH = not uHS
    nHi = array.size(hiB)
    if nHi > 0
        for i = nHi - 1 to 0
            if doneR and doneH
                break
            bC = array.get(hiB, i)
            gap = bH - bC
            if gap > mxGap
                break
            eC = array.get(hiE, i)
            cC = array.get(hiC, i)
            rC = array.get(hiR, i)
            pairE = useE and array.get(hiEV, i)
            pairC = useC and array.get(hiCV, i)
            ok = gap >= mnGap
            if not doneR
                wickOkR = false
                closeOkR = false
                q = not obosOnly or rH >= OB_LV
                if ok and q and rH < rC and rC - rH >= effMinRsiD and f_oscOk(bC, rC, bH, rH, true)
                    wickOkR := pairE and eH > eC and f_prcOk(sbH, bC, eC, bH, eH, true)
                    closeOkR := pairC and cH > cC and f_prcOk(sbC, bC, cC, bH, cH, true)
                sig = wickOkR or closeOkR
                viaC = closeOkR and not wickOkR
                dualPrc = wickOkR and closeOkR
                if sig
                    doneR := true
                    doneH := true
                    hitR := true
                    txt = f_sigText(false, false, hasEye, rH >= OB_LV, emaTag)
                    f_drawLive(bC, rC, bH, rH, txt, cBear, false, false, false, dualPrc)
                    f_drawLive(bC, viaC ? cC : eC, bH, viaC ? cH : eH, txt, cBear, false, false, true, dualPrc)
                else
                    bE = pairE and eC > eH
                    bCl = pairC and cC > cH
                    bR = rC < rH
                    if effStrict and f_blkFor(bE, bCl, bR, pairE, pairC, useE, useC)
                        doneR := true
            if not doneH
                wickOkH = false
                closeOkH = false
                if ok and rH > rC and rH - rC >= effMinRsiD and f_oscOk(bC, rC, bH, rH, true)
                    wickOkH := pairE and eH < eC and f_prcOk(sbH, bC, eC, bH, eH, true)
                    closeOkH := pairC and cH < cC and f_prcOk(sbC, bC, cC, bH, cH, true)
                sig = wickOkH or closeOkH
                viaC = closeOkH and not wickOkH
                dualPrc = wickOkH and closeOkH
                if sig
                    doneH := true
                    doneR := true
                    hitH := true
                    txt = f_sigText(false, true, hasEye, rH >= OB_LV, emaTag)
                    f_drawLive(bC, rC, bH, rH, txt, cBear, false, true, false, dualPrc)
                    f_drawLive(bC, viaC ? cC : eC, bH, viaC ? cH : eH, txt, cBear, false, true, true, dualPrc)
                else
                    bE = pairE and eC < eH
                    bCl = pairC and cC < cH
                    bR = rC > rH
                    if effStrict and f_blkFor(bE, bCl, bR, pairE, pairC, useE, useC)
                        doneH := true
    [hitR, hitH]

emaTagPivotLow  = f_emaTag(true, pivRight)
emaTagPivotHigh = f_emaTag(false, pivRight)
emaTagLiveLow   = f_emaTag(true, 0)
emaTagLiveHigh  = f_emaTag(false, 0)

regBull = false
hidBull = false
regBear = false
hidBear = false
previewRB = false
previewHB = false
previewRS = false
previewHS = false
bullEye = false
bearEye = false
bullEyeZone = false
bearEyeZone = false
supportEye = eyeLowHit and barstate.isconfirmed
pressureEye = eyeHighHit and barstate.isconfirmed
if supportEye
    f_rememberEye(eyeLowHistory, eyeLowOrigin)
if pressureEye
    f_rememberEye(eyeHighHistory, eyeHighOrigin)
eyeAtPivotLow = useEye and (f_eyeKnown(eyeLowHistory, time[pivRight]) or eyeLowHit and eyeLowOrigin == time[pivRight])
eyeAtPivotHigh = useEye and (f_eyeKnown(eyeHighHistory, time[pivRight]) or eyeHighHit and eyeHighOrigin == time[pivRight])

isPending = isLiveOpen

// ── 低点侧：底背离 / 隐性底背离
if not na(pl)
    bL    = bar_index - pivRight
    eL    = loSrc[pivRight]
    cL    = close[pivRight]
    rL    = pl
    qRB   = not obosOnly or rL <= OS_LV
    curCanE = useE and pivotLoEValid
    curCanC = useC and pivotLoCValid
    doneR = not uRB or not (curCanE or curCanC)
    doneH = not uHB or not (curCanE or curCanC)
    bkER  = false
    bkCR  = false
    bkRR  = false
    bkEH  = false
    bkCH  = false
    bkRH  = false
    nLo   = array.size(loB)
    if nLo > 0
        for i = nLo - 1 to 0
            if doneR and doneH
                break
            bC  = array.get(loB, i)
            gap = bL - bC
            if gap > mxGap
                break
            eC  = array.get(loE, i)
            cC  = array.get(loC, i)
            rC  = array.get(loR, i)
            pairE = curCanE and array.get(loEV, i)
            pairC = curCanC and array.get(loCV, i)
            ok  = gap >= mnGap
            // 底背离：价格更低 + RSI 更高
            if not doneR
                wickOkRB = false
                closeOkRB = false
                if ok and qRB and rL > rC and rL - rC >= effMinRsiD and f_oscOk(bC, rC, bL, rL, false)
                    wickOkRB := pairE and eL < eC and f_prcOk(sbL, bC, eC, bL, eL, false)
                    closeOkRB := pairC and cL < cC and f_prcOk(sbC, bC, cC, bL, cL, false)
                sigRB = wickOkRB or closeOkRB
                viaC1 = closeOkRB and not wickOkRB
                dualPrc1 = wickOkRB and closeOkRB
                if sigRB
                    doneR := true
                    doneH := true
                    txt = f_sigText(true, false, eyeAtPivotLow, rL <= OS_LV, emaTagPivotLow)
                    if eyeAtPivotLow
                        f_removeStandaloneEye(time[pivRight], 1)
                    if isPending
                        previewRB := true
                        f_drawLive(bC, rC, bL, rL, txt, cBull, true, false, false, dualPrc1)
                        f_drawLive(bC, viaC1 ? cC : eC, bL, viaC1 ? cL : eL, txt, cBull, true, false, true, dualPrc1)
                    else
                        regBull := true
                        if eyeAtPivotLow
                            bullEye := true
                            bullEyeZone := bullEyeZone or rL <= OS_LV
                        f_draw(bC, rC, bL, rL, txt, cBull, true, false, false, dualPrc1)
                        f_draw(bC, viaC1 ? cC : eC, bL, viaC1 ? cL : eL, txt, cBull, true, false, true, dualPrc1)
                else
                    bkER := pairE and eC < eL
                    bkCR := pairC and cC < cL
                    bkRR := rC > rL
                    if effStrict and f_blkFor(bkER, bkCR, bkRR, pairE, pairC, curCanE, curCanC)
                        doneR := true
            // 隐性底背离：价格更高 + RSI 更低
            if not doneH
                wickOkHB = false
                closeOkHB = false
                if ok and rL < rC and rC - rL >= effMinRsiD and f_oscOk(bC, rC, bL, rL, false)
                    wickOkHB := pairE and eL > eC and f_prcOk(sbL, bC, eC, bL, eL, false)
                    closeOkHB := pairC and cL > cC and f_prcOk(sbC, bC, cC, bL, cL, false)
                sigHB = wickOkHB or closeOkHB
                viaC2 = closeOkHB and not wickOkHB
                dualPrc2 = wickOkHB and closeOkHB
                if sigHB
                    doneH := true
                    doneR := true
                    txt = f_sigText(true, true, eyeAtPivotLow, rL <= OS_LV, emaTagPivotLow)
                    if eyeAtPivotLow
                        f_removeStandaloneEye(time[pivRight], 1)
                    if isPending
                        previewHB := true
                        f_drawLive(bC, rC, bL, rL, txt, cBull, true, true, false, dualPrc2)
                        f_drawLive(bC, viaC2 ? cC : eC, bL, viaC2 ? cL : eL, txt, cBull, true, true, true, dualPrc2)
                    else
                        hidBull := true
                        if eyeAtPivotLow
                            bullEye := true
                            bullEyeZone := bullEyeZone or rL <= OS_LV
                        f_draw(bC, rC, bL, rL, txt, cBull, true, true, false, dualPrc2)
                        f_draw(bC, viaC2 ? cC : eC, bL, viaC2 ? cL : eL, txt, cBull, true, true, true, dualPrc2)
                else
                    bkEH := pairE and eC > eL
                    bkCH := pairC and cC > cL
                    bkRH := rC < rL
                    if effStrict and f_blkFor(bkEH, bkCH, bkRH, pairE, pairC, curCanE, curCanC)
                        doneH := true

// ── 高点侧：顶背离 / 隐性顶背离
if not na(ph)
    bH    = bar_index - pivRight
    eH    = hiSrc[pivRight]
    cH    = close[pivRight]
    rH    = ph
    qRS   = not obosOnly or rH >= OB_LV
    curCanE = useE and pivotHiEValid
    curCanC = useC and pivotHiCValid
    doneR = not uRS or not (curCanE or curCanC)
    doneH = not uHS or not (curCanE or curCanC)
    bkER  = false
    bkCR  = false
    bkRR  = false
    bkEH  = false
    bkCH  = false
    bkRH  = false
    nHi   = array.size(hiB)
    if nHi > 0
        for i = nHi - 1 to 0
            if doneR and doneH
                break
            bC  = array.get(hiB, i)
            gap = bH - bC
            if gap > mxGap
                break
            eC  = array.get(hiE, i)
            cC  = array.get(hiC, i)
            rC  = array.get(hiR, i)
            pairE = curCanE and array.get(hiEV, i)
            pairC = curCanC and array.get(hiCV, i)
            ok  = gap >= mnGap
            // 顶背离：价格更高 + RSI 更低
            if not doneR
                wickOkRS = false
                closeOkRS = false
                if ok and qRS and rH < rC and rC - rH >= effMinRsiD and f_oscOk(bC, rC, bH, rH, true)
                    wickOkRS := pairE and eH > eC and f_prcOk(sbH, bC, eC, bH, eH, true)
                    closeOkRS := pairC and cH > cC and f_prcOk(sbC, bC, cC, bH, cH, true)
                sigRS = wickOkRS or closeOkRS
                viaC3 = closeOkRS and not wickOkRS
                dualPrc3 = wickOkRS and closeOkRS
                if sigRS
                    doneR := true
                    doneH := true
                    txt = f_sigText(false, false, eyeAtPivotHigh, rH >= OB_LV, emaTagPivotHigh)
                    if eyeAtPivotHigh
                        f_removeStandaloneEye(time[pivRight], -1)
                    if isPending
                        previewRS := true
                        f_drawLive(bC, rC, bH, rH, txt, cBear, false, false, false, dualPrc3)
                        f_drawLive(bC, viaC3 ? cC : eC, bH, viaC3 ? cH : eH, txt, cBear, false, false, true, dualPrc3)
                    else
                        regBear := true
                        if eyeAtPivotHigh
                            bearEye := true
                            bearEyeZone := bearEyeZone or rH >= OB_LV
                        f_draw(bC, rC, bH, rH, txt, cBear, false, false, false, dualPrc3)
                        f_draw(bC, viaC3 ? cC : eC, bH, viaC3 ? cH : eH, txt, cBear, false, false, true, dualPrc3)
                else
                    bkER := pairE and eC > eH
                    bkCR := pairC and cC > cH
                    bkRR := rC < rH
                    if effStrict and f_blkFor(bkER, bkCR, bkRR, pairE, pairC, curCanE, curCanC)
                        doneR := true
            // 隐性顶背离：价格更低 + RSI 更高
            if not doneH
                wickOkHS = false
                closeOkHS = false
                if ok and rH > rC and rH - rC >= effMinRsiD and f_oscOk(bC, rC, bH, rH, true)
                    wickOkHS := pairE and eH < eC and f_prcOk(sbH, bC, eC, bH, eH, true)
                    closeOkHS := pairC and cH < cC and f_prcOk(sbC, bC, cC, bH, cH, true)
                sigHS = wickOkHS or closeOkHS
                viaC4 = closeOkHS and not wickOkHS
                dualPrc4 = wickOkHS and closeOkHS
                if sigHS
                    doneH := true
                    doneR := true
                    txt = f_sigText(false, true, eyeAtPivotHigh, rH >= OB_LV, emaTagPivotHigh)
                    if eyeAtPivotHigh
                        f_removeStandaloneEye(time[pivRight], -1)
                    if isPending
                        previewHS := true
                        f_drawLive(bC, rC, bH, rH, txt, cBear, false, true, false, dualPrc4)
                        f_drawLive(bC, viaC4 ? cC : eC, bH, viaC4 ? cH : eH, txt, cBear, false, true, true, dualPrc4)
                    else
                        hidBear := true
                        if eyeAtPivotHigh
                            bearEye := true
                            bearEyeZone := bearEyeZone or rH >= OB_LV
                        f_draw(bC, rC, bH, rH, txt, cBear, false, true, false, dualPrc4)
                        f_draw(bC, viaC4 ? cC : eC, bH, viaC4 ? cH : eH, txt, cBear, false, true, true, dualPrc4)
                else
                    bkEH := pairE and eC < eH
                    bkCH := pairC and cC < cH
                    bkRH := rC > rH
                    if effStrict and f_blkFor(bkEH, bkCH, bkRH, pairE, pairC, curCanE, curCanC)
                        doneH := true

// 常规检测未成形时，允许关键 EMA 在严格条件下救回一档边缘背离。
mainRescueBull = false
mainRescueBear = false
if not (regBull or hidBull or previewRB or previewHB) and not na(plEmaRescue)
    bLR = bar_index - pivRight
    rLR = plEmaRescue
    cLR = close[pivRight]
    hitLR = f_rescueLow(bLR, cLR, rLR, eyeAtPivotLow, emaTagPivotLow, pivotLoCValid, isPending)
    if hitLR
        if eyeAtPivotLow
            f_removeStandaloneEye(time[pivRight], 1)
        if isPending
            previewRB := true
        else
            regBull := true
            mainRescueBull := true
            if eyeAtPivotLow
                bullEye := true
                bullEyeZone := bullEyeZone or rLR <= OS_LV

if not (regBear or hidBear or previewRS or previewHS) and not na(phEmaRescue)
    bHR = bar_index - pivRight
    rHR = phEmaRescue
    cHR = close[pivRight]
    hitHR = f_rescueHigh(bHR, cHR, rHR, eyeAtPivotHigh, emaTagPivotHigh, pivotHiCValid, isPending)
    if hitHR
        if eyeAtPivotHigh
            f_removeStandaloneEye(time[pivRight], -1)
        if isPending
            previewRS := true
        else
            regBear := true
            mainRescueBear := true
            if eyeAtPivotHigh
                bearEye := true
                bearEyeZone := bearEyeZone or rHR >= OB_LV

// 先完成普通检测与救回，再写入当前正式枢轴；避免数组已满时先挤掉救回所需的最老候选。
if not na(pl) and barstate.isconfirmed and ((useE and pivotLoEValid) or (useC and pivotLoCValid))
    f_push(loE, loC, loR, loB, loEV, loCV, loSrc[pivRight], close[pivRight], pl, bar_index - pivRight, pivotLoEValid, pivotLoCValid)
if not na(ph) and barstate.isconfirmed and ((useE and pivotHiEValid) or (useC and pivotHiCValid))
    f_push(hiE, hiC, hiR, hiB, hiEV, hiCV, hiSrc[pivRight], close[pivRight], ph, bar_index - pivRight, pivotHiEValid, pivotHiCValid)

// 突破段在本根正式结束：若极值 K 线已有背离，原位升级；否则只画一张独立眼。
if supportEye
    eyeMerged = f_upgradeLabelsWithEye(dLb, dLbOrigin, dLbSide, dLbBase, eyeLowOrigin, 1)
    if eyeMerged
        bullEye := true
        bullEyeZone := eyeLowRsi <= OS_LV
    else
        f_drawEye(eyeLowBar, eyeLowOrigin, eyeLowPrice, true, eyeLowRsi <= OS_LV, false, eyeLowEmaTag)
if pressureEye
    eyeMerged = f_upgradeLabelsWithEye(dLb, dLbOrigin, dLbSide, dLbBase, eyeHighOrigin, -1)
    if eyeMerged
        bearEye := true
        bearEyeZone := eyeHighRsi >= OB_LV
    else
        f_drawEye(eyeHighBar, eyeHighOrigin, eyeHighPrice, false, eyeHighRsi >= OB_LV, false, eyeHighEmaTag)

// 最右侧未收盘 K 线：跳过右侧等待，但保留全部配对、严格度、阻断与逐根路径检查。
liveRB = false
liveHB = false
liveRS = false
liveHS = false
liveLowCandidate  = isLiveOpen and bar_index >= pivLeft and rsiLeftLow
liveHighCandidate = isLiveOpen and bar_index >= pivLeft and rsiLeftHigh
eyeLiveLow = eyeLowHit and isLiveOpen and eyeLowOrigin == time
eyeLiveHigh = eyeHighHit and isLiveOpen and eyeHighOrigin == time
if liveLowCandidate
    [lr, lh] = f_liveLow(bar_index, loSrc, close, rsi, eyeLiveLow, emaTagLiveLow)
    liveRB := lr
    liveHB := lh
if liveHighCandidate
    [lr, lh] = f_liveHigh(bar_index, hiSrc, close, rsi, eyeLiveHigh, emaTagLiveHigh)
    liveRS := lr
    liveHS := lh
liveRescueLowCandidate  = emaRescue and isLiveOpen and bar_index >= rescueLeft and rsiRescueLeftLow and not (liveRB or liveHB)
liveRescueHighCandidate = emaRescue and isLiveOpen and bar_index >= rescueLeft and rsiRescueLeftHigh and not (liveRS or liveHS)
if liveRescueLowCandidate
    liveRB := f_rescueLow(bar_index, close, rsi, eyeLiveLow, emaTagLiveLow, true, true)
if liveRescueHighCandidate
    liveRS := f_rescueHigh(bar_index, close, rsi, eyeLiveHigh, emaTagLiveHigh, true, true)

// 未收盘突破段的眼随已形成极值移动；可暂时升级同端点历史或实时背离，
// 否则显示一张临时独立眼。TradingView 下一次跳动会先回滚本轮修改。
if eyeLowHit and isLiveOpen
    eyeMerged = f_upgradeLabelsWithEye(dLb, dLbOrigin, dLbSide, dLbBase, eyeLowOrigin, 1)
    eyeMerged := f_upgradeLabelsWithEye(liveLb, liveLbOrigin, liveLbSide, liveLbBase, eyeLowOrigin, 1) or eyeMerged
    if not eyeMerged
        f_drawEye(eyeLowBar, eyeLowOrigin, eyeLowPrice, true, eyeLowRsi <= OS_LV, true, eyeLowEmaTag)
if eyeHighHit and isLiveOpen
    eyeMerged = f_upgradeLabelsWithEye(dLb, dLbOrigin, dLbSide, dLbBase, eyeHighOrigin, -1)
    eyeMerged := f_upgradeLabelsWithEye(liveLb, liveLbOrigin, liveLbSide, liveLbBase, eyeHighOrigin, -1) or eyeMerged
    if not eyeMerged
        f_drawEye(eyeHighBar, eyeHighOrigin, eyeHighPrice, false, eyeHighRsi >= OB_LV, true, eyeHighEmaTag)

// ══════════ 多周期买卖指数 ══════════
// 持续趋势结构与“某一根发生的衰竭/反转事件”分开。
// 三个均线队列间距与三条慢线斜率形成慢结构；价格相对 EMA55、EMA21/55
// 队列和 EMA21 的 sqrt(21) 窗口斜率只构成“过渡证据”。只有三项快速证据
// 合计与慢结构相反时才连续削弱旧结构，绝不凭一次穿线直接翻向。全部使用 ATR
// 与 EMA 长度归一化，不读取未来收益、不使用币种阈值。
f_scoreSignedGap(float a, float b, float scale) =>
    x = not na(a) and not na(b) and not na(scale) and scale > 0 ? (a - b) / scale : 0.0
    x / (1.0 + math.abs(x))

f_scoreTrendNet() =>
    scale = math.max(nz(emaAtr14), syminfo.mintick * 2.0)
    // 不同 EMA 跨度按周期比的平方根校正；慢线斜率窗口取 sqrt(N)，并按
    // 随机波动随 sqrt(时间) 扩张的尺度归一化。常数全部由 EMA 长度推导。
    stack1 = f_scoreSignedGap(ema21v, ema55v, scale * math.sqrt(55.0 / 21.0))
    stack2 = f_scoreSignedGap(ema55v, ema100v, scale * math.sqrt(100.0 / 55.0))
    stack3 = f_scoreSignedGap(ema100v, ema200v, scale * math.sqrt(200.0 / 100.0))
    slope55  = f_scoreSignedGap(ema55v, ema55v[7], scale * math.sqrt(7.0))
    slope100 = f_scoreSignedGap(ema100v, ema100v[10], scale * math.sqrt(10.0))
    slope200 = f_scoreSignedGap(ema200v, ema200v[14], scale * math.sqrt(14.0))
    slow = (stack1 + stack2 + stack3 + slope55 + slope100 + slope200) / 6.0
    fastPos = f_scoreSignedGap(close, ema55v, scale * math.sqrt(55.0 / 21.0))
    fastStack = stack1
    fastSlope = f_scoreSignedGap(ema21v, ema21v[5], scale * math.sqrt(5.0))
    transition = (fastPos + fastStack + fastSlope) / 3.0
    stale = math.sqrt(math.max(0.0, math.min(1.0, -slow * transition)))
    slow * (1.0 - stale)

[_, _, _, _, curScoreReady, curTrendReady0, curBuyPulsePts, curSellPulsePts, curBuyPulseMask, curSellPulseMask, _, _, curBuyPulseOrigin0, curSellPulseOrigin0, _, _, _, _, _, _, _, _, _, _, _, _, curBuyPulseD0, curBuyPulseZ0, curBuyPulseY0, curBuyPulseE0, curBuyPulseEH0, curSellPulseD0, curSellPulseZ0, curSellPulseY0, curSellPulseE0, curSellPulseEH0, curEyeBOrigin0, curEyeBMask0, curEyeBD0, curEyeBZ0, curEyeBY0, curEyeBE0, curEyeBEH0, curEyeSOrigin0, curEyeSMask0, curEyeSD0, curEyeSZ0, curEyeSY0, curEyeSE0, curEyeSEH0] = f_scoreKernel(barstate.isconfirmed, isLiveOpen ? 1 : 0)
curBuyPulse = curBuyPulseOrigin0 > 0
curSellPulse = curSellPulseOrigin0 > 0
curBuyPulseRev0 = f_scoreReversalQuality(curBuyPulseD0, curBuyPulseZ0, curBuyPulseY0, curBuyPulseE0, curBuyPulseMask)
curSellPulseRev0 = f_scoreReversalQuality(curSellPulseD0, curSellPulseZ0, curSellPulseY0, curSellPulseE0, curSellPulseMask)

// 已确认与实时高周期共用同一个内核调用点。off=1 读取上一根已收盘源柱；
// off=0 让当前源柱按 time_close 决定正式推进还是只生成临时预览。
f_scoreMtf(int off) =>
    sourceClosed = na(time_close) ? true : time_close <= timenow
    commit = off == 1 or sourceClosed
    preview = off == 0 and not sourceClosed
    previewMode = preview ? 2 : 0
    [bm, sm, ba, sa, ready, trendReady, _, _, _, _, bo, so, _, _, bp, sp, bd, bz, bEye, be, beh, sd, sz, sEye, se, seh, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _] = f_scoreKernel(commit, previewMode)
    tr = f_scoreTrendNet()
    [bm[off], sm[off], ba[off], sa[off], ready[off], trendReady[off], bo[off], so[off], tr[off], bp[off], sp[off], bd[off], bz[off], bEye[off], be[off], beh[off], sd[off], sz[off], sEye[off], se[off], seh[off]]

f_autoScoreTf(int slot) =>
    sec = timeframe.in_seconds()
    string tf = ""
    if na(sec)
        tf := slot == 1 ? "15" : slot == 2 ? "60" : "240"
    else if sec <= 5 * 60
        // 5m 是最终入场层：优先读取 1H / 4H 机会结构，并保留 1D 战略背景；
        // 不让 15m 占掉唯一三个背景槽中的一个。
        tf := slot == 1 ? "60" : slot == 2 ? "240" : "1D"
    else if sec <= 15 * 60
        tf := slot == 1 ? "60" : slot == 2 ? "240" : "1D"
    else if sec <= 30 * 60
        tf := slot == 1 ? "120" : slot == 2 ? "240" : "1D"
    else if sec <= 60 * 60
        tf := slot == 1 ? "240" : slot == 2 ? "720" : "1D"
    else if sec <= 2 * 60 * 60
        tf := slot == 1 ? "240" : slot == 2 ? "720" : "1D"
    else if sec <= 3 * 60 * 60
        tf := slot == 1 ? "360" : slot == 2 ? "720" : "1D"
    else if sec <= 6 * 60 * 60
        tf := slot == 1 ? "720" : slot == 2 ? "1D" : "1W"
    else if sec <= 12 * 60 * 60
        tf := slot == 1 ? "1D" : slot == 2 ? "1W" : "1M"
    else if sec <= 24 * 60 * 60
        tf := slot == 1 ? "1W" : slot == 2 ? "1M" : "3M"
    else if sec <= 7 * 24 * 60 * 60
        tf := slot == 1 ? "1M" : slot == 2 ? "3M" : "12M"
    else if sec < timeframe.in_seconds("3M")
        tf := slot == 1 ? "3M" : slot == 2 ? "6M" : "12M"
    else
        // 3M 及以上不启用评分，避免把等周期或更低周期伪装成高周期背景。
        tf := "12M"
    tf

f_scoreSupported() =>
    sec = timeframe.in_seconds()
    not na(sec) and sec >= 5 * 60 and sec < timeframe.in_seconds("3M")

f_scoreTfName(string tf) =>
    switch tf
        "60"  => "1H"
        "120" => "2H"
        "240" => "4H"
        "360" => "6H"
        "720" => "12H"
        => tf

// 三个高周期已由入场 / 机会 / 战略角色梯子筛选；事件又在各自源周期内独立
// 衰减。这里不再用 ratio^-0.25 重复削弱较远层，尤其避免日线背景在 5m 上
// 仅因跨度大而失去意义。不同图表周期的最终数字仍不互相比较。
f_scoreSpanRelevance(string tf) =>
    1.0

f_scoreWaveOverlap(int originA, string tfA, int originB, string tfB) =>
    secA = timeframe.in_seconds(tfA)
    secB = timeframe.in_seconds(tfB)
    valid = originA > 0 and originB > 0 and not na(secA) and not na(secB)
    if not valid
        0.0
    else
        // origin 是 K 线开盘时间。只比较开盘时刻会让同一个物理低点仅因落在
        // 高周期柱的前段或后段而得到不同相关性；改用两根 K 线覆盖区间。
        endA = originA + int(secA * 1000.0)
        endB = originB + int(secB * 1000.0)
        boundaryGap = math.max(0.0, math.max(originA, originB) - math.min(endA, endB))
        bigMs = math.max(1.0, math.max(secA, secB) * 1000.0)
        math.max(0.0, 1.0 - boundaryGap / (1.5 * bigMs))

f_scoreFamilySimilarity(int maskA, int maskB) =>
    aD = f_hasBit(maskA, SC_REG) or f_hasBit(maskA, SC_HID)
    aZ = f_hasBit(maskA, SC_ZONE)
    aY = f_hasBit(maskA, SC_EYE)
    aE = f_hasBit(maskA, SC_E21) or f_hasBit(maskA, SC_E55) or f_hasBit(maskA, SC_E100) or f_hasBit(maskA, SC_E200)
    bD = f_hasBit(maskB, SC_REG) or f_hasBit(maskB, SC_HID)
    bZ = f_hasBit(maskB, SC_ZONE)
    bY = f_hasBit(maskB, SC_EYE)
    bE = f_hasBit(maskB, SC_E21) or f_hasBit(maskB, SC_E55) or f_hasBit(maskB, SC_E100) or f_hasBit(maskB, SC_E200)
    inter = (aD and bD ? 1.0 : 0.0) + (aZ and bZ ? 1.0 : 0.0) + (aY and bY ? 1.0 : 0.0) + (aE and bE ? 1.0 : 0.0)
    union = (aD or bD ? 1.0 : 0.0) + (aZ or bZ ? 1.0 : 0.0) + (aY or bY ? 1.0 : 0.0) + (aE or bE ? 1.0 : 0.0)
    union > 0 ? 0.35 + 0.65 * inter / union : 0.0

f_scoreCorrelation(int originA, string tfA, int maskA, int originB, string tfB, int maskB) =>
    f_scoreWaveOverlap(originA, tfA, originB, tfB) * f_scoreFamilySimilarity(maskA, maskB)

f_scoreHtfPhase(string tf) =>
    t0 = time(tf)
    t1 = time_close(tf)
    te = barstate.isrealtime ? math.min(timenow, t1) : time_close
    not na(t0) and not na(t1) and not na(te) and t1 > t0 ? math.max(0.0, math.min(1.0, (te - t0) / (t1 - t0))) : 0.0

f_scoreAgedBundle(float d, float z, float y, float e, float eHalfLife, int mask, int age, bool preview, float phase) =>
    p = math.max(0.0, math.min(1.0, phase))
    // 实时高周期快照在内核中已经按原子出处折算：本根新生部分成熟一次，池中
    // 历史原子和已由收盘柱建立的旅程保持原值。这里不得再整包打折。非实时
    // 路径仍按各原子半衰期做柱内连续衰减，跨柱边界保持原有连续性。
    dd = preview ? d : d * math.pow(0.5, p / f_scoreDivHalfLife(mask))
    zz = preview ? z : z * math.pow(0.5, p / ZONE_HALF_LIFE)
    yy = preview ? y : y * math.pow(0.5, p / 2.0)
    ee = preview ? e : e * math.pow(0.5, p / math.max(1.0, eHalfLife))
    f_scoreBundle(dd, zz, yy, ee)

f_scoreCtxEvidence(float d, float z, float y, float e, float eHalfLife, int mask, int age, string tf, bool ready, bool preview, float phase) =>
    q = ready ? f_scoreAgedBundle(d, z, y, e, eHalfLife, mask, age, preview, phase) / 70.0 : 0.0
    math.max(0.0, math.min(1.0, q * f_scoreSpanRelevance(tf)))

f_scoreSeq3(float a, float b, float c, float corrAB, float corrAC, float corrBC) =>
    // 每一步只把本项“未与既有证据重复”的部分填入剩余空间；不会倒扣已有支持。
    p = a + (1.0 - a) * b * (1.0 - corrAB)
    p + (1.0 - p) * c * (1.0 - math.max(corrAC, corrBC))

// 对三个层级的 6 种加入顺序全部计算并取最大：结果与参数排列无关、对每一项
// 同向证据单调；零相关退化为 noisy-OR，完全同波同机制退化为最强一项。
// 弱“桥接层”出现或消失都不能反向抬高/压低另外两层已有的支持。
f_scoreCtxPool(float v1, float v2, float v3, int o1, int o2, int o3, int m1, int m2, int m3, string tf1, string tf2, string tf3) =>
    c12 = f_scoreCorrelation(o1, tf1, m1, o2, tf2, m2)
    c13 = f_scoreCorrelation(o1, tf1, m1, o3, tf3, m3)
    c23 = f_scoreCorrelation(o2, tf2, m2, o3, tf3, m3)
    p123 = f_scoreSeq3(v1, v2, v3, c12, c13, c23)
    p132 = f_scoreSeq3(v1, v3, v2, c13, c12, c23)
    p213 = f_scoreSeq3(v2, v1, v3, c12, c23, c13)
    p231 = f_scoreSeq3(v2, v3, v1, c23, c12, c13)
    p312 = f_scoreSeq3(v3, v1, v2, c13, c23, c12)
    p321 = f_scoreSeq3(v3, v2, v1, c23, c13, c12)
    math.max(math.max(math.max(p123, p132), math.max(p213, p231)), math.max(p312, p321))

// 同一份高周期内在证据，要针对“当前正在评分的真实事件端点”分别去重。
// 同一确认柱若同时有 pivot 与 current 两个 origin，不能沿用较强那条的同波
// 折扣给另一条，否则两张标签会在相同高周期背景下得到错误的相同上下文。
f_scoreTargetPool(float base1, float base2, float base3, int o1, int o2, int o3, int m1, int m2, int m3, string tf1, string tf2, string tf3, int targetOrigin, string targetTf, int targetMask, float targetQ) =>
    tq = math.max(0.0, math.min(1.0, targetQ))
    // 完全同波且本级很强时，高周期仍保留约 1/3，表达“聚合级别也确认”；
    // 不再保留一半，避免同一对高低点在多个周期被近似重复计分。
    r1 = 1.0 / (1.0 + 2.0 * f_scoreCorrelation(o1, tf1, m1, targetOrigin, targetTf, targetMask) * tq)
    r2 = 1.0 / (1.0 + 2.0 * f_scoreCorrelation(o2, tf2, m2, targetOrigin, targetTf, targetMask) * tq)
    r3 = 1.0 / (1.0 + 2.0 * f_scoreCorrelation(o3, tf3, m3, targetOrigin, targetTf, targetMask) * tq)
    v1 = base1 * r1
    v2 = base2 * r2
    v3 = base3 * r3
    f_scoreCtxPool(v1, v2, v3, o1, o2, o3, m1, m2, m3, tf1, tf2, tf3)

// 最强事件选择在不同半衰期交叉时可能切回旧 origin。把这段状态转移集中在
// 一处：age=0 / preview 是真实新 epoch；普通回退只能连续衰减，不能靠更换
// correlation metadata 抬分；层暂时为空时保留 anchor、但输出证据与相关性为 0。
f_scoreContinuity(float raw, int origin, int mask, int age, bool preview, float prevBase, int anchorOrigin, int anchorMask) =>
    has = origin > 0 and raw > 0
    fresh = has and (preview or age == 0)
    accept = has and (anchorOrigin == 0 or fresh)
    fallback = has and anchorOrigin > 0 and origin != anchorOrigin and not fresh
    nextOrigin = accept ? origin : anchorOrigin
    nextMask = accept ? (origin == anchorOrigin ? f_scoreMaskUnion(anchorMask, mask) : mask) : has and origin == anchorOrigin ? f_scoreMaskUnion(anchorMask, mask) : anchorMask
    value = not has ? 0.0 : fallback ? math.min(raw, nz(prevBase, raw)) : raw
    corrOrigin = not has ? 0 : fallback ? nextOrigin : origin
    corrMask = not has ? 0 : fallback ? nextMask : mask
    [value, nextOrigin, nextMask, corrOrigin, corrMask]

f_scoreOpportunity(float localScore, float reversalQuality, float sameEvent, float oppositeEvent, float alignedTrend, float opposingTrend) =>
    local = math.max(0.0, math.min(70.0, localScore))
    localQ = local / 70.0
    sameE = math.max(0.0, math.min(1.0, sameEvent))
    oppE = math.max(0.0, math.min(1.0, oppositeEvent))
    trendA = math.max(0.0, math.min(1.0, alignedTrend))
    trendO = math.max(0.0, math.min(1.0, opposingTrend))
    // 同 / 反向事件分别只进入支持与风险一次，避免先互相折半、下游又惩罚
    // 一遍。所有背景都按本级质量线性门控，不能凭背景制造高分事件。
    eventSupport = sameE * localQ
    trendSupport = trendA * localQ
    alignedSupport = 1.0 - (1.0 - eventSupport) * (1.0 - trendSupport)
    beforeRisk = local + (100.0 - local) * alignedSupport

    // 反向离散事件是直接风险，不能被本级反转质量抹掉；持续反向趋势则可能
    // 正是超跌反弹 / 超涨回调的背景，可由多类反转共振逐步化解。
    reversal = math.max(0.0, math.min(1.0, reversalQuality))
    eventRisk = oppE
    trendRisk = trendO * (1.0 - reversal)
    opposingRisk = 1.0 - (1.0 - eventRisk) * (1.0 - trendRisk)
    adjusted = beforeRisk / (1.0 + opposingRisk)
    math.max(0.0, math.min(100.0, adjusted))

f_scoreContextText(bool isBuy, float sameEvt, float oppositeEvt, float fullIdx, float noEventIdx, float netTrend, float disagreement) =>
    sideTrend = isBuy ? netTrend : -netTrend
    sameShown = int(math.round(math.max(0.0, sameEvt) * 100.0))
    oppositeShown = int(math.round(math.max(0.0, oppositeEvt) * 100.0))
    impact = int(math.round(fullIdx - noEventIdx))
    trendTxt = math.abs(netTrend) < 0.05 ? "均线方向：当前周期和更大周期暂不明确。" : sideTrend > 0 ? "均线方向：总体支持这次机会。" : "均线方向：总体不支持这次机会。"
    if disagreement >= 0.05
        trendTxt += " 周期分歧 " + str.tostring(int(math.round(disagreement * 100.0))) + "/100。"
    impactTxt = impact > 0 ? "本次指数 +" + str.tostring(impact) + " 分。" : impact < 0 ? "本次指数 -" + str.tostring(math.abs(impact)) + " 分。" : "取整后未改变指数。"
    eventTxt = sameShown == 0 and oppositeShown == 0 ? "更大周期信号：暂无仍在影响当前行情的同向或反向信号；" + impactTxt : "更大周期信号：同向 " + str.tostring(sameShown) + "/100，反向 " + str.tostring(oppositeShown) + "/100；" + impactTxt
    trendTxt + "\n" + eventTxt

f_scoreSideState(bool isBuy, float netTrend, float sameEvt, float oppositeEvt, int mask, float d, float z, float y, float e) =>
    sideTrend = isBuy ? netTrend : -netTrend
    hasReversal = f_hasBit(mask, SC_REG) or f_hasBit(mask, SC_EYE) or f_hasBit(mask, SC_ZONE)
    transition = math.abs(netTrend) < 0.05
    localConfluence = f_scoreReversalQuality(d, z, y, e, mask)
    reversalPressure = (1.0 - (1.0 - localConfluence) * (1.0 - sameEvt)) * (1.0 - oppositeEvt)
    counterPressure = 1.0 - (1.0 - oppositeEvt) * (1.0 - math.max(0.0, -sideTrend))
    reversalWatch = hasReversal and reversalPressure > counterPressure
    transition ? (reversalWatch ? (isBuy ? "可能由跌转涨，观察做多" : "可能由涨转跌，观察做空") : (isBuy ? "均线方向尚不明确，观察做多" : "均线方向尚不明确，观察做空")) : sideTrend > 0 ? (hasReversal ? (isBuy ? "上涨趋势中的回踩做多" : "下跌趋势中的反弹做空") : (isBuy ? "上涨趋势延续做多" : "下跌趋势延续做空")) : reversalWatch ? (isBuy ? "可能由跌转涨，观察做多" : "可能由涨转跌，观察做空") : (isBuy ? "下跌趋势中的反弹做多" : "上涨趋势中的回调做空")

f_scoreReasons(int mask, bool isLow) =>
    txt = f_hasBit(mask, SC_REG) ? (isLow ? "底背离" : "顶背离") : f_hasBit(mask, SC_HID) ? (isLow ? "隐性底背离" : "隐性顶背离") : ""
    if f_hasBit(mask, SC_EYE)
        txt += (txt == "" ? "" : "；") + (isLow ? "支撑眼" : "压力眼")
    if f_hasBit(mask, SC_ZONE)
        txt += (txt == "" ? "" : "；") + (isLow ? "RSI 超卖" : "RSI 超买")
    ema = ""
    if f_hasBit(mask, SC_E21)
        ema := "EMA21"
    if f_hasBit(mask, SC_E55)
        ema := ema + (ema == "" ? "" : " / ") + "EMA55"
    if f_hasBit(mask, SC_E100)
        ema := ema + (ema == "" ? "" : " / ") + "EMA100"
    if f_hasBit(mask, SC_E200)
        ema := ema + (ema == "" ? "" : " / ") + "EMA200"
    if ema != ""
        txt += (txt == "" ? "" : "；") + "触及 " + ema
    if f_hasBit(mask, SC_DUAL)
        txt += (txt == "" ? "" : "；") + "影线与收盘价都确认背离"
    if f_hasBit(mask, SC_RESCUE)
        txt += (txt == "" ? "" : "；") + "关键 EMA 附近的边缘背离通过额外检查"
    if f_hasBit(mask, SC_CHAIN)
        txt += (txt == "" ? "" : "；") + "与上一段组成连续背离"
    txt == "" ? "暂无" : txt

f_scorePoint(float v) =>
    str.tostring(math.round(v * 10.0) / 10.0)

f_scoreAtomText(float d, float z, float y, float e, int mask) =>
    txt = d >= 0.05 ? "  背离贡献：" + f_scorePoint(d) : ""
    if z >= 0.05
        txt += (txt == "" ? "" : "\n") + "  RSI 极端程度贡献：" + f_scorePoint(z)
    if y >= 0.05
        txt += (txt == "" ? "" : "\n") + "  支撑眼 / 压力眼贡献：" + f_scorePoint(y)
    if e >= 0.05
        txt += (txt == "" ? "" : "\n") + "  关键 EMA 贡献：" + f_scorePoint(e)
    if f_hasBit(mask, SC_RESCUE)
        txt += (txt == "" ? "" : "\n") + "  说明：EMA 已用于确认边缘背离，因此没有再重复增加 EMA 分。"
    txt == "" ? "  暂无可列出的分项" : txt

f_scoreLayerSideText(bool isBuy, float nowScore, float evidence, int mask, int age, bool preview, float phase) =>
    txt = ""
    if nowScore >= 1.0
        side = isBuy ? "做多背景" : "做空背景"
        status = preview and age < 0 ? "这个连续信号已在此前收盘时成立；当前 K 线仍未收盘" : preview ? "当前 K 线尚未收盘，已走完约 " + str.tostring(int(math.round(phase * 100.0))) + "%" : age <= 0 ? "刚刚收盘确认" : "在 " + str.tostring(age) + " 根该周期 K 线前确认"
        txt := side + "：本周期 " + str.tostring(int(math.round(nowScore))) + "/70 → 本次背景 " + str.tostring(int(math.round(evidence * 100.0))) + "/100\n       " + status + "｜" + f_scoreReasons(mask, isBuy)
    txt

f_scoreLayerText(string tf, float buyNow, float sellNow, float buyEv, float sellEv, int buyMask, int sellMask, int buyAge, int sellAge, bool buyPreview, bool sellPreview, float phase) =>
    b = f_scoreLayerSideText(true, buyNow, buyEv, buyMask, buyAge, buyPreview, phase)
    s = f_scoreLayerSideText(false, sellNow, sellEv, sellMask, sellAge, sellPreview, phase)
    body = b + (b != "" and s != "" ? "\n     " : "") + s
    "【" + f_scoreTfName(tf) + "】\n" + (body == "" ? "  暂无仍有效的做多或做空事件" : "  " + body)

f_scoreLabelTooltip(bool isBuy, float fullIdx, float localScore, float d, float z, float y, float e, float netTrend, float sameEvt, float oppositeEvt, int mask, string contextTxt, string layersTxt, bool live) =>
    side = isBuy ? "买入" : "卖出"
    confirmTxt = live ? "实时临时：当前 K 线尚未收盘，条件可能增强、减弱或消失。" : "历史信号已经收盘确认；数字只使用当时已经出现的信息，标签放在实际信号 K 线上。"
    "【" + side + "指数】 " + str.tostring(int(math.round(fullIdx))) + " / 100\n" +
      "比较口径：只和同一品种、同一图表周期的其他信号比较；不同周期的数字不直接排序。\n" +
      "机会类型：" + f_scoreSideState(isBuy, netTrend, sameEvt, oppositeEvt, mask, d, z, y, e) + "\n" +
      "确认状态：" + confirmTxt + "\n\n" +
      "【当前图表周期】\n" +
      "本周期条件强度：" + str.tostring(int(math.round(localScore))) + " / 70\n" +
      "成立条件：" + f_scoreReasons(mask, isBuy) + "\n" +
      "各项贡献（相关条件不会简单相加）：\n" + f_scoreAtomText(d, z, y, e, mask) + "\n\n" +
      "【更大周期怎样影响这次机会】\n" + contextTxt + "\n\n" +
      "【各个更大周期的最近有效条件】\n" + layersTxt

f_scoreLabelText(string baseTxt, float idx) =>
    scoreTxt = str.tostring(int(math.round(idx)))
    // 原标签可能是“符号”或“符号\nEMA”；指数一律追加在最后一行，
    // 保持图面顺序为“符号 → EMA → 分值”，不把数字插进两者之间。
    baseTxt + "\n" + scoreTxt

f_applyScoreTo(array<label> lbs, array<int> origins, array<int> sides, array<string> bases, int origin, int side, float idx, string tip) =>
    n = array.size(lbs)
    if origin > 0 and not na(idx) and n > 0
        for i = 0 to n - 1
            if array.get(origins, i) == origin and array.get(sides, i) == side
                lb = array.get(lbs, i)
                label.set_text(lb, f_scoreLabelText(array.get(bases, i), idx))
                label.set_tooltip(lb, tip)
    0

f_applySignalScore(bool isBuy, int origin, float fullIdx, float localScore, float d, float z, float y, float e, float netTrend, float sameEvt, float oppositeEvt, int mask, string contextTxt, string layersTxt, bool live) =>
    if showSignalScore and origin > 0 and not na(fullIdx)
        side = isBuy ? 1 : -1
        tip = f_scoreLabelTooltip(isBuy, fullIdx, localScore, d, z, y, e, netTrend, sameEvt, oppositeEvt, mask, contextTxt, layersTxt, live)
        f_applyScoreTo(dLb, dLbOrigin, dLbSide, dLbBase, origin, side, fullIdx, tip)
        f_applyScoreTo(eyeLb, eyeLbOrigin, eyeLbSide, eyeLbBase, origin, side, fullIdx, tip)
        f_applyScoreTo(liveLb, liveLbOrigin, liveLbSide, liveLbBase, origin, side, fullIdx, tip)
    0

scoreTf1 = f_autoScoreTf(1)
scoreTf2 = f_autoScoreTf(2)
scoreTf3 = f_autoScoreTf(3)
// 先完整预热 EMA200 / 慢斜率，再为当前最大配对跨度保留事件历史。
scoreInputWarmup = math.max(math.max(rsiLen, useEye ? eyeLen : 2), useEmaTouch ? 220 : 14) + mxGap + pivLeft + pivRight + 30
// 确认请求承担历史复盘，默认覆盖最近 1600 根源柱；扣除预热后，常用图上
// 最近一层约覆盖 5m→1H 与 15m→1H 54～62 天、1H→4H 214～249 天、
// 4H→12H 1.76～2.04 年。实时请求只需把当前状态机完整预热。
scoreHistoryBars = math.max(1600, scoreInputWarmup + 300)
scoreLiveBars = math.max(360, scoreInputWarmup + 40)
// Pine 对单个脚本全部 request.* 返回元组合计限制为 127 个字段：下面 6 次
// f_scoreMtf 各返回 21 项，总计 126。任何新增导出字段都必须先压缩或复用现有项。
[tf1BuyMask, tf1SellMask, tf1BuyAge, tf1SellAge, tf1Ready, tf1TrendReady, tf1BuyOrigin, tf1SellOrigin, tf1Trend, _, _, tf1BuyD, tf1BuyZ, tf1BuyY, tf1BuyE, tf1BuyEH, tf1SellD, tf1SellZ, tf1SellY, tf1SellE, tf1SellEH] = request.security(syminfo.tickerid, scoreTf1, f_scoreMtf(1), lookahead = barmerge.lookahead_on, calc_bars_count = scoreHistoryBars)
[tf2BuyMask, tf2SellMask, tf2BuyAge, tf2SellAge, tf2Ready, tf2TrendReady, tf2BuyOrigin, tf2SellOrigin, tf2Trend, _, _, tf2BuyD, tf2BuyZ, tf2BuyY, tf2BuyE, tf2BuyEH, tf2SellD, tf2SellZ, tf2SellY, tf2SellE, tf2SellEH] = request.security(syminfo.tickerid, scoreTf2, f_scoreMtf(1), lookahead = barmerge.lookahead_on, calc_bars_count = scoreHistoryBars)
[tf3BuyMask, tf3SellMask, tf3BuyAge, tf3SellAge, tf3Ready, tf3TrendReady, tf3BuyOrigin, tf3SellOrigin, tf3Trend, _, _, tf3BuyD, tf3BuyZ, tf3BuyY, tf3BuyE, tf3BuyEH, tf3SellD, tf3SellZ, tf3SellY, tf3SellE, tf3SellEH] = request.security(syminfo.tickerid, scoreTf3, f_scoreMtf(1), lookahead = barmerge.lookahead_on, calc_bars_count = scoreHistoryBars)
[tf1BuyMaskLive, tf1SellMaskLive, tf1BuyAgeLive, tf1SellAgeLive, tf1ReadyLive, _, tf1BuyOriginLive, tf1SellOriginLive, _, tf1BuyPreviewLive, tf1SellPreviewLive, tf1BuyDLive, tf1BuyZLive, tf1BuyYLive, tf1BuyELive, tf1BuyEHLive, tf1SellDLive, tf1SellZLive, tf1SellYLive, tf1SellELive, tf1SellEHLive] = request.security(syminfo.tickerid, scoreTf1, f_scoreMtf(0), lookahead = barmerge.lookahead_off, calc_bars_count = scoreLiveBars)
[tf2BuyMaskLive, tf2SellMaskLive, tf2BuyAgeLive, tf2SellAgeLive, tf2ReadyLive, _, tf2BuyOriginLive, tf2SellOriginLive, _, tf2BuyPreviewLive, tf2SellPreviewLive, tf2BuyDLive, tf2BuyZLive, tf2BuyYLive, tf2BuyELive, tf2BuyEHLive, tf2SellDLive, tf2SellZLive, tf2SellYLive, tf2SellELive, tf2SellEHLive] = request.security(syminfo.tickerid, scoreTf2, f_scoreMtf(0), lookahead = barmerge.lookahead_off, calc_bars_count = scoreLiveBars)
[tf3BuyMaskLive, tf3SellMaskLive, tf3BuyAgeLive, tf3SellAgeLive, tf3ReadyLive, _, tf3BuyOriginLive, tf3SellOriginLive, _, tf3BuyPreviewLive, tf3SellPreviewLive, tf3BuyDLive, tf3BuyZLive, tf3BuyYLive, tf3BuyELive, tf3BuyEHLive, tf3SellDLive, tf3SellZLive, tf3SellYLive, tf3SellELive, tf3SellEHLive] = request.security(syminfo.tickerid, scoreTf3, f_scoreMtf(0), lookahead = barmerge.lookahead_off, calc_bars_count = scoreLiveBars)

scoreSupportedNow = f_scoreSupported()
useHtfLive = scoreLiveHtf and isLiveOpen
h1BuyMask = useHtfLive ? tf1BuyMaskLive : tf1BuyMask
h1SellMask = useHtfLive ? tf1SellMaskLive : tf1SellMask
h1BuyAge = useHtfLive ? tf1BuyAgeLive : tf1BuyAge
h1SellAge = useHtfLive ? tf1SellAgeLive : tf1SellAge
h1Ready = useHtfLive ? tf1ReadyLive : tf1Ready
h1BuyOrigin = useHtfLive ? tf1BuyOriginLive : tf1BuyOrigin
h1SellOrigin = useHtfLive ? tf1SellOriginLive : tf1SellOrigin
h1BuyPreview = useHtfLive ? tf1BuyPreviewLive : false
h1SellPreview = useHtfLive ? tf1SellPreviewLive : false
h1BuyD = useHtfLive ? tf1BuyDLive : tf1BuyD
h1BuyZ = useHtfLive ? tf1BuyZLive : tf1BuyZ
h1BuyY = useHtfLive ? tf1BuyYLive : tf1BuyY
h1BuyE = useHtfLive ? tf1BuyELive : tf1BuyE
h1BuyEH = useHtfLive ? tf1BuyEHLive : tf1BuyEH
h1SellD = useHtfLive ? tf1SellDLive : tf1SellD
h1SellZ = useHtfLive ? tf1SellZLive : tf1SellZ
h1SellY = useHtfLive ? tf1SellYLive : tf1SellY
h1SellE = useHtfLive ? tf1SellELive : tf1SellE
h1SellEH = useHtfLive ? tf1SellEHLive : tf1SellEH
// 趋势结构只使用上一根已收盘高周期；“实时”开关只预览离散事件，避免未收盘
// 均线位置在盘中来回翻转，把顺势/逆势类型也反复改写。
h1Trend = tf1Trend
h2BuyMask = useHtfLive ? tf2BuyMaskLive : tf2BuyMask
h2SellMask = useHtfLive ? tf2SellMaskLive : tf2SellMask
h2BuyAge = useHtfLive ? tf2BuyAgeLive : tf2BuyAge
h2SellAge = useHtfLive ? tf2SellAgeLive : tf2SellAge
h2Ready = useHtfLive ? tf2ReadyLive : tf2Ready
h2BuyOrigin = useHtfLive ? tf2BuyOriginLive : tf2BuyOrigin
h2SellOrigin = useHtfLive ? tf2SellOriginLive : tf2SellOrigin
h2BuyPreview = useHtfLive ? tf2BuyPreviewLive : false
h2SellPreview = useHtfLive ? tf2SellPreviewLive : false
h2BuyD = useHtfLive ? tf2BuyDLive : tf2BuyD
h2BuyZ = useHtfLive ? tf2BuyZLive : tf2BuyZ
h2BuyY = useHtfLive ? tf2BuyYLive : tf2BuyY
h2BuyE = useHtfLive ? tf2BuyELive : tf2BuyE
h2BuyEH = useHtfLive ? tf2BuyEHLive : tf2BuyEH
h2SellD = useHtfLive ? tf2SellDLive : tf2SellD
h2SellZ = useHtfLive ? tf2SellZLive : tf2SellZ
h2SellY = useHtfLive ? tf2SellYLive : tf2SellY
h2SellE = useHtfLive ? tf2SellELive : tf2SellE
h2SellEH = useHtfLive ? tf2SellEHLive : tf2SellEH
h2Trend = tf2Trend
h3BuyMask = useHtfLive ? tf3BuyMaskLive : tf3BuyMask
h3SellMask = useHtfLive ? tf3SellMaskLive : tf3SellMask
h3BuyAge = useHtfLive ? tf3BuyAgeLive : tf3BuyAge
h3SellAge = useHtfLive ? tf3SellAgeLive : tf3SellAge
h3Ready = useHtfLive ? tf3ReadyLive : tf3Ready
h3BuyOrigin = useHtfLive ? tf3BuyOriginLive : tf3BuyOrigin
h3SellOrigin = useHtfLive ? tf3SellOriginLive : tf3SellOrigin
h3BuyPreview = useHtfLive ? tf3BuyPreviewLive : false
h3SellPreview = useHtfLive ? tf3SellPreviewLive : false
h3BuyD = useHtfLive ? tf3BuyDLive : tf3BuyD
h3BuyZ = useHtfLive ? tf3BuyZLive : tf3BuyZ
h3BuyY = useHtfLive ? tf3BuyYLive : tf3BuyY
h3BuyE = useHtfLive ? tf3BuyELive : tf3BuyE
h3BuyEH = useHtfLive ? tf3BuyEHLive : tf3BuyEH
h3SellD = useHtfLive ? tf3SellDLive : tf3SellD
h3SellZ = useHtfLive ? tf3SellZLive : tf3SellZ
h3SellY = useHtfLive ? tf3SellYLive : tf3SellY
h3SellE = useHtfLive ? tf3SellELive : tf3SellE
h3SellEH = useHtfLive ? tf3SellEHLive : tf3SellEH
h3Trend = tf3Trend

// 高周期只提供各自尚未合并的分项。已经确认的旧信号按各自周期逐步减弱；
// 当前未收盘 K 线新增加的部分，按这根 K 线已经走完的比例逐步纳入。
// 已由此前收盘 K 线确认的连续超买卖或连续越轨保留原有强度，只让当前柱新增
// 的极端程度逐步加入。
// 已结束并确认的事件则在一根高周期内部连续衰减。
h1BuyOriginActive = h1Ready and nz(h1BuyD) + nz(h1BuyZ) + nz(h1BuyY) + nz(h1BuyE) > 0 ? h1BuyOrigin : 0
h2BuyOriginActive = h2Ready and nz(h2BuyD) + nz(h2BuyZ) + nz(h2BuyY) + nz(h2BuyE) > 0 ? h2BuyOrigin : 0
h3BuyOriginActive = h3Ready and nz(h3BuyD) + nz(h3BuyZ) + nz(h3BuyY) + nz(h3BuyE) > 0 ? h3BuyOrigin : 0
h1SellOriginActive = h1Ready and nz(h1SellD) + nz(h1SellZ) + nz(h1SellY) + nz(h1SellE) > 0 ? h1SellOrigin : 0
h2SellOriginActive = h2Ready and nz(h2SellD) + nz(h2SellZ) + nz(h2SellY) + nz(h2SellE) > 0 ? h2SellOrigin : 0
h3SellOriginActive = h3Ready and nz(h3SellD) + nz(h3SellZ) + nz(h3SellY) + nz(h3SellE) > 0 ? h3SellOrigin : 0
phase1 = f_scoreHtfPhase(scoreTf1)
phase2 = f_scoreHtfPhase(scoreTf2)
phase3 = f_scoreHtfPhase(scoreTf3)
h1BuyNow = h1Ready ? f_scoreAgedBundle(h1BuyD, h1BuyZ, h1BuyY, h1BuyE, h1BuyEH, h1BuyMask, h1BuyAge, h1BuyPreview, phase1) : 0.0
h2BuyNow = h2Ready ? f_scoreAgedBundle(h2BuyD, h2BuyZ, h2BuyY, h2BuyE, h2BuyEH, h2BuyMask, h2BuyAge, h2BuyPreview, phase2) : 0.0
h3BuyNow = h3Ready ? f_scoreAgedBundle(h3BuyD, h3BuyZ, h3BuyY, h3BuyE, h3BuyEH, h3BuyMask, h3BuyAge, h3BuyPreview, phase3) : 0.0
h1SellNow = h1Ready ? f_scoreAgedBundle(h1SellD, h1SellZ, h1SellY, h1SellE, h1SellEH, h1SellMask, h1SellAge, h1SellPreview, phase1) : 0.0
h2SellNow = h2Ready ? f_scoreAgedBundle(h2SellD, h2SellZ, h2SellY, h2SellE, h2SellEH, h2SellMask, h2SellAge, h2SellPreview, phase2) : 0.0
h3SellNow = h3Ready ? f_scoreAgedBundle(h3SellD, h3SellZ, h3SellY, h3SellE, h3SellEH, h3SellMask, h3SellAge, h3SellPreview, phase3) : 0.0

// 先稳定每层“内在证据”，再针对当前被评分的事件做同波去重。事件池按当前
// 最强项输出；不同原子的半衰期交叉时，选中项可能退回旧事件。旧项不得仅因
// origin / mask 改变而解除相关性并反向抬分，但刚确认或刚补强（age=0）的
// 真实新证据必须立即生效——即使枢轴端点时间早于中间某个 EMA 事件。
h1BuyBaseRaw = f_scoreCtxEvidence(h1BuyD, h1BuyZ, h1BuyY, h1BuyE, h1BuyEH, h1BuyMask, h1BuyAge, scoreTf1, h1Ready, h1BuyPreview, phase1)
h2BuyBaseRaw = f_scoreCtxEvidence(h2BuyD, h2BuyZ, h2BuyY, h2BuyE, h2BuyEH, h2BuyMask, h2BuyAge, scoreTf2, h2Ready, h2BuyPreview, phase2)
h3BuyBaseRaw = f_scoreCtxEvidence(h3BuyD, h3BuyZ, h3BuyY, h3BuyE, h3BuyEH, h3BuyMask, h3BuyAge, scoreTf3, h3Ready, h3BuyPreview, phase3)
h1SellBaseRaw = f_scoreCtxEvidence(h1SellD, h1SellZ, h1SellY, h1SellE, h1SellEH, h1SellMask, h1SellAge, scoreTf1, h1Ready, h1SellPreview, phase1)
h2SellBaseRaw = f_scoreCtxEvidence(h2SellD, h2SellZ, h2SellY, h2SellE, h2SellEH, h2SellMask, h2SellAge, scoreTf2, h2Ready, h2SellPreview, phase2)
h3SellBaseRaw = f_scoreCtxEvidence(h3SellD, h3SellZ, h3SellY, h3SellE, h3SellEH, h3SellMask, h3SellAge, scoreTf3, h3Ready, h3SellPreview, phase3)

var int h1BuyAnchorOrigin = 0
var int h2BuyAnchorOrigin = 0
var int h3BuyAnchorOrigin = 0
var int h1SellAnchorOrigin = 0
var int h2SellAnchorOrigin = 0
var int h3SellAnchorOrigin = 0
var int h1BuyAnchorMask = 0
var int h2BuyAnchorMask = 0
var int h3BuyAnchorMask = 0
var int h1SellAnchorMask = 0
var int h2SellAnchorMask = 0
var int h3SellAnchorMask = 0
var float h1BuyBase = 0.0
var float h2BuyBase = 0.0
var float h3BuyBase = 0.0
var float h1SellBase = 0.0
var float h2SellBase = 0.0
var float h3SellBase = 0.0
[h1BuyBaseNext, h1BuyAnchorOriginNext, h1BuyAnchorMaskNext, h1BuyCorrOrigin, h1BuyCorrMask] = f_scoreContinuity(h1BuyBaseRaw, h1BuyOriginActive, h1BuyMask, h1BuyAge, h1BuyPreview, h1BuyBase[1], h1BuyAnchorOrigin, h1BuyAnchorMask)
[h2BuyBaseNext, h2BuyAnchorOriginNext, h2BuyAnchorMaskNext, h2BuyCorrOrigin, h2BuyCorrMask] = f_scoreContinuity(h2BuyBaseRaw, h2BuyOriginActive, h2BuyMask, h2BuyAge, h2BuyPreview, h2BuyBase[1], h2BuyAnchorOrigin, h2BuyAnchorMask)
[h3BuyBaseNext, h3BuyAnchorOriginNext, h3BuyAnchorMaskNext, h3BuyCorrOrigin, h3BuyCorrMask] = f_scoreContinuity(h3BuyBaseRaw, h3BuyOriginActive, h3BuyMask, h3BuyAge, h3BuyPreview, h3BuyBase[1], h3BuyAnchorOrigin, h3BuyAnchorMask)
[h1SellBaseNext, h1SellAnchorOriginNext, h1SellAnchorMaskNext, h1SellCorrOrigin, h1SellCorrMask] = f_scoreContinuity(h1SellBaseRaw, h1SellOriginActive, h1SellMask, h1SellAge, h1SellPreview, h1SellBase[1], h1SellAnchorOrigin, h1SellAnchorMask)
[h2SellBaseNext, h2SellAnchorOriginNext, h2SellAnchorMaskNext, h2SellCorrOrigin, h2SellCorrMask] = f_scoreContinuity(h2SellBaseRaw, h2SellOriginActive, h2SellMask, h2SellAge, h2SellPreview, h2SellBase[1], h2SellAnchorOrigin, h2SellAnchorMask)
[h3SellBaseNext, h3SellAnchorOriginNext, h3SellAnchorMaskNext, h3SellCorrOrigin, h3SellCorrMask] = f_scoreContinuity(h3SellBaseRaw, h3SellOriginActive, h3SellMask, h3SellAge, h3SellPreview, h3SellBase[1], h3SellAnchorOrigin, h3SellAnchorMask)
h1BuyBase := h1BuyBaseNext
h2BuyBase := h2BuyBaseNext
h3BuyBase := h3BuyBaseNext
h1SellBase := h1SellBaseNext
h2SellBase := h2SellBaseNext
h3SellBase := h3SellBaseNext
h1BuyAnchorOrigin := h1BuyAnchorOriginNext
h2BuyAnchorOrigin := h2BuyAnchorOriginNext
h3BuyAnchorOrigin := h3BuyAnchorOriginNext
h1SellAnchorOrigin := h1SellAnchorOriginNext
h2SellAnchorOrigin := h2SellAnchorOriginNext
h3SellAnchorOrigin := h3SellAnchorOriginNext
h1BuyAnchorMask := h1BuyAnchorMaskNext
h2BuyAnchorMask := h2BuyAnchorMaskNext
h3BuyAnchorMask := h3BuyAnchorMaskNext
h1SellAnchorMask := h1SellAnchorMaskNext
h2SellAnchorMask := h2SellAnchorMaskNext
h3SellAnchorMask := h3SellAnchorMaskNext

// 本级与高周期同属一波时，只压缩可解释的重复残余。稳定后的 correlation
// metadata 同时用于本级去重和三层事件池，避免切回旧事件时相关性突然释放。
htfBuyIntrinsic = f_scoreTargetPool(h1BuyBase, h2BuyBase, h3BuyBase, h1BuyCorrOrigin, h2BuyCorrOrigin, h3BuyCorrOrigin, h1BuyCorrMask, h2BuyCorrMask, h3BuyCorrMask, scoreTf1, scoreTf2, scoreTf3, 0, timeframe.period, 0, 0.0)
htfSellIntrinsic = f_scoreTargetPool(h1SellBase, h2SellBase, h3SellBase, h1SellCorrOrigin, h2SellCorrOrigin, h3SellCorrOrigin, h1SellCorrMask, h2SellCorrMask, h3SellCorrMask, scoreTf1, scoreTf2, scoreTf3, 0, timeframe.period, 0, 0.0)
// 反向池不按另一侧本级事件去重：否则增强一个未显式计分的本级卖证据，反而
// 会抹掉高周期卖压并抬高买分。全局上下文也只陈述两侧内在池，便于解释。

// 结构趋势与离散事件分别融合。当前周期占一份，三个高周期按实际跨度衰减；
// 未预热层按 0 进入固定分母，不会把仅剩的一层重新归一化成“满强度”。
curTrendCalc = f_scoreTrendNet()
curTrend = isLiveOpen ? nz(curTrendCalc[1], curTrendCalc) : curTrendCalc
curTrendReady = isLiveOpen ? curTrendReady0[1] : curTrendReady0
trendW1 = f_scoreSpanRelevance(scoreTf1)
trendW2 = f_scoreSpanRelevance(scoreTf2)
trendW3 = f_scoreSpanRelevance(scoreTf3)
trendDen = 1.0 + trendW1 + trendW2 + trendW3
trendR0 = curTrendReady ? nz(curTrend) : 0.0
// 结构固定来自确认请求，所以也必须配确认请求的 ready；实时事件的 ready
// 只控制离散事件，不能让尚未预热完成的上一根结构提前一柱参与。
trendR1 = tf1TrendReady ? nz(h1Trend) : 0.0
trendR2 = tf2TrendReady ? nz(h2Trend) : 0.0
trendR3 = tf3TrendReady ? nz(h3Trend) : 0.0
trendRaw = (trendR0 + trendW1 * trendR1 + trendW2 * trendR2 + trendW3 * trendR3) / trendDen
trendMass = (math.abs(trendR0) + trendW1 * math.abs(trendR1) + trendW2 * math.abs(trendR2) + trendW3 * math.abs(trendR3)) / trendDen
trendDisagreement = math.max(0.0, math.min(1.0, trendMass - math.abs(trendRaw)))
structureNet = trendRaw * (1.0 - trendDisagreement)
structureBuy = math.max(0.0, structureNet)
structureSell = math.max(0.0, -structureNet)

// 评分只消费“本根新建立的事件”，再按 origin / 方向寻找已经画出的背离或眼
// 标签并原位补数字与 tooltip。RSI 区域或 EMA 可参与评分，但没有经典信号标签
// 时无处写入，因此绝不会因为开启指数而新增一张标签。
scoreContextReady = h1Ready
b1Active = showSignalScore and scoreSupportedNow and curScoreReady and scoreContextReady and curBuyPulse and curBuyPulsePts > 0
s1Active = showSignalScore and scoreSupportedNow and curScoreReady and scoreContextReady and curSellPulse and curSellPulsePts > 0
eyeBActive = showSignalScore and scoreSupportedNow and curScoreReady and scoreContextReady and eyeLowHit and eyeLowOrigin > 0 and eyeLowOrigin != curBuyPulseOrigin0
eyeSActive = showSignalScore and scoreSupportedNow and curScoreReady and scoreContextReady and eyeHighHit and eyeHighOrigin > 0 and eyeHighOrigin != curSellPulseOrigin0
eyeBPoolMatched = curEyeBOrigin0 == eyeLowOrigin
eyeSPoolMatched = curEyeSOrigin0 == eyeHighOrigin
eyeBD = eyeBPoolMatched ? curEyeBD0 : 0.0
eyeBZ = eyeBPoolMatched ? curEyeBZ0 : eyeLowZ
eyeBY = eyeBPoolMatched ? curEyeBY0 : eyeLowY
eyeBE = eyeBPoolMatched ? curEyeBE0 : eyeLowE
eyeBMask = eyeBPoolMatched ? curEyeBMask0 : SC_EYE + (eyeLowZ > 0 ? SC_ZONE : 0) + eyeLowEm
eyeSD = eyeSPoolMatched ? curEyeSD0 : 0.0
eyeSZ = eyeSPoolMatched ? curEyeSZ0 : eyeHighZ
eyeSY = eyeSPoolMatched ? curEyeSY0 : eyeHighY
eyeSE = eyeSPoolMatched ? curEyeSE0 : eyeHighE
eyeSMask = eyeSPoolMatched ? curEyeSMask0 : SC_EYE + (eyeHighZ > 0 ? SC_ZONE : 0) + eyeHighEm
eyeBPts = f_scoreBundle(eyeBD, eyeBZ, eyeBY, eyeBE)
eyeSPts = f_scoreBundle(eyeSD, eyeSZ, eyeSY, eyeSE)
b1Q = b1Active ? math.max(0.0, math.min(1.0, curBuyPulsePts / 70.0)) : 0.0
s1Q = s1Active ? math.max(0.0, math.min(1.0, curSellPulsePts / 70.0)) : 0.0
eyeBQ = eyeBActive ? math.max(0.0, math.min(1.0, eyeBPts / 70.0)) : 0.0
eyeSQ = eyeSActive ? math.max(0.0, math.min(1.0, eyeSPts / 70.0)) : 0.0
b1Same = f_scoreTargetPool(h1BuyBase, h2BuyBase, h3BuyBase, h1BuyCorrOrigin, h2BuyCorrOrigin, h3BuyCorrOrigin, h1BuyCorrMask, h2BuyCorrMask, h3BuyCorrMask, scoreTf1, scoreTf2, scoreTf3, curBuyPulseOrigin0, timeframe.period, curBuyPulseMask, b1Q)
s1Same = f_scoreTargetPool(h1SellBase, h2SellBase, h3SellBase, h1SellCorrOrigin, h2SellCorrOrigin, h3SellCorrOrigin, h1SellCorrMask, h2SellCorrMask, h3SellCorrMask, scoreTf1, scoreTf2, scoreTf3, curSellPulseOrigin0, timeframe.period, curSellPulseMask, s1Q)
eyeBSame = f_scoreTargetPool(h1BuyBase, h2BuyBase, h3BuyBase, h1BuyCorrOrigin, h2BuyCorrOrigin, h3BuyCorrOrigin, h1BuyCorrMask, h2BuyCorrMask, h3BuyCorrMask, scoreTf1, scoreTf2, scoreTf3, eyeLowOrigin, timeframe.period, eyeBMask, eyeBQ)
eyeSSame = f_scoreTargetPool(h1SellBase, h2SellBase, h3SellBase, h1SellCorrOrigin, h2SellCorrOrigin, h3SellCorrOrigin, h1SellCorrMask, h2SellCorrMask, h3SellCorrMask, scoreTf1, scoreTf2, scoreTf3, eyeHighOrigin, timeframe.period, eyeSMask, eyeSQ)
b1Index = b1Active ? f_scoreOpportunity(curBuyPulsePts, curBuyPulseRev0, b1Same, htfSellIntrinsic, structureBuy, structureSell) : na
s1Index = s1Active ? f_scoreOpportunity(curSellPulsePts, curSellPulseRev0, s1Same, htfBuyIntrinsic, structureSell, structureBuy) : na
eyeBIndex = eyeBActive ? f_scoreOpportunity(eyeBPts, f_scoreReversalQuality(eyeBD, eyeBZ, eyeBY, eyeBE, eyeBMask), eyeBSame, htfSellIntrinsic, structureBuy, structureSell) : na
eyeSIndex = eyeSActive ? f_scoreOpportunity(eyeSPts, f_scoreReversalQuality(eyeSD, eyeSZ, eyeSY, eyeSE, eyeSMask), eyeSSame, htfBuyIntrinsic, structureSell, structureBuy) : na
b1NoEvent = b1Active ? f_scoreOpportunity(curBuyPulsePts, curBuyPulseRev0, 0.0, 0.0, structureBuy, structureSell) : na
s1NoEvent = s1Active ? f_scoreOpportunity(curSellPulsePts, curSellPulseRev0, 0.0, 0.0, structureSell, structureBuy) : na
eyeBNoEvent = eyeBActive ? f_scoreOpportunity(eyeBPts, f_scoreReversalQuality(eyeBD, eyeBZ, eyeBY, eyeBE, eyeBMask), 0.0, 0.0, structureBuy, structureSell) : na
eyeSNoEvent = eyeSActive ? f_scoreOpportunity(eyeSPts, f_scoreReversalQuality(eyeSD, eyeSZ, eyeSY, eyeSE, eyeSMask), 0.0, 0.0, structureSell, structureBuy) : na

// 可见徽标保持一行；只有真实事件柱才组装详细悬浮说明。每个 origin 使用
// 自己的同波折扣，反向高周期池保持内在值，不受另一侧本级事件“隐形去重”。
b1Context = ""
s1Context = ""
eyeBContext = ""
eyeSContext = ""
scoreLayersIntrinsic = ""
if b1Active or s1Active or eyeBActive or eyeSActive
    scoreLayersIntrinsic := "说明：若更大周期和当前信号反映的是同一次涨跌，重复信息不会再次完整计分。\n" +
      f_scoreLayerText(scoreTf1, h1BuyNow, h1SellNow, h1BuyBase, h1SellBase, h1BuyMask, h1SellMask, h1BuyAge, h1SellAge, h1BuyPreview, h1SellPreview, phase1) + "\n" +
      f_scoreLayerText(scoreTf2, h2BuyNow, h2SellNow, h2BuyBase, h2SellBase, h2BuyMask, h2SellMask, h2BuyAge, h2SellAge, h2BuyPreview, h2SellPreview, phase2) + "\n" +
      f_scoreLayerText(scoreTf3, h3BuyNow, h3SellNow, h3BuyBase, h3SellBase, h3BuyMask, h3SellMask, h3BuyAge, h3SellAge, h3BuyPreview, h3SellPreview, phase3)
if b1Active
    b1Context := f_scoreContextText(true, b1Same, htfSellIntrinsic, b1Index, b1NoEvent, structureNet, trendDisagreement)
if s1Active
    s1Context := f_scoreContextText(false, s1Same, htfBuyIntrinsic, s1Index, s1NoEvent, structureNet, trendDisagreement)
if eyeBActive
    eyeBContext := f_scoreContextText(true, eyeBSame, htfSellIntrinsic, eyeBIndex, eyeBNoEvent, structureNet, trendDisagreement)
if eyeSActive
    eyeSContext := f_scoreContextText(false, eyeSSame, htfBuyIntrinsic, eyeSIndex, eyeSNoEvent, structureNet, trendDisagreement)

if b1Active or s1Active or eyeBActive or eyeSActive
    liveScoreEvent = isLiveOpen
    if b1Active
        f_applySignalScore(true, curBuyPulseOrigin0, b1Index, curBuyPulsePts, curBuyPulseD0, curBuyPulseZ0, curBuyPulseY0, curBuyPulseE0, structureNet, b1Same, htfSellIntrinsic, curBuyPulseMask, b1Context, scoreLayersIntrinsic, liveScoreEvent)
    if s1Active
        f_applySignalScore(false, curSellPulseOrigin0, s1Index, curSellPulsePts, curSellPulseD0, curSellPulseZ0, curSellPulseY0, curSellPulseE0, structureNet, s1Same, htfBuyIntrinsic, curSellPulseMask, s1Context, scoreLayersIntrinsic, liveScoreEvent)
    if eyeBActive
        f_applySignalScore(true, eyeLowOrigin, eyeBIndex, eyeBPts, eyeBD, eyeBZ, eyeBY, eyeBE, structureNet, eyeBSame, htfSellIntrinsic, eyeBMask, eyeBContext, scoreLayersIntrinsic, liveScoreEvent)
    if eyeSActive
        f_applySignalScore(false, eyeHighOrigin, eyeSIndex, eyeSPts, eyeSD, eyeSZ, eyeSY, eyeSE, structureNet, eyeSSame, htfBuyIntrinsic, eyeSMask, eyeSContext, scoreLayersIntrinsic, liveScoreEvent)

// ══════════ 警报 ══════════
// 只使用历史正式事件；最右侧未收盘状态不会触发。已有警报是创建时的脚本与设置快照，改代码或输入后需重建。
// 警报条件按层级独立：背离明细、方向汇总、眼、二重组合和三重组合可在同一端点同时成立。
// 通常每个方向只创建所需的一层；同时创建多层会分别通知，不是脚本重复计算。
alertcondition(regBull, "【背离明细】底背离", "{{ticker}} {{interval}} RSI 底背离已收盘确认（标记位于实际枢轴 K 线）")
alertcondition(hidBull, "【背离明细】隐性底背离", "{{ticker}} {{interval}} RSI 隐性底背离已收盘确认（标记位于实际枢轴 K 线）")
alertcondition(regBear, "【背离明细】顶背离", "{{ticker}} {{interval}} RSI 顶背离已收盘确认（标记位于实际枢轴 K 线）")
alertcondition(hidBear, "【背离明细】隐性顶背离", "{{ticker}} {{interval}} RSI 隐性顶背离已收盘确认（标记位于实际枢轴 K 线）")
alertcondition(regBull or hidBull, "【方向汇总】任一底部背离", "{{ticker}} {{interval}} RSI 底部背离已收盘确认（底背离或隐性底背离）")
alertcondition(regBear or hidBear, "【方向汇总】任一顶部背离", "{{ticker}} {{interval}} RSI 顶部背离已收盘确认（顶背离或隐性顶背离）")
alertcondition(supportEye, "【眼】支撑眼", "{{ticker}} {{interval}} 支撑眼已确认｜连续下轨突破结束，标记位于整段最低价 K 线")
alertcondition(pressureEye, "【眼】压力眼", "{{ticker}} {{interval}} 压力眼已确认｜连续上轨突破结束，标记位于整段最高价 K 线")
alertcondition(bullEye, "【二重组合】底部背离 + 支撑眼", "{{ticker}} {{interval}} 底部背离 + 支撑眼已确认（同一极值 K 线；两项可能先后确认）")
alertcondition(bearEye, "【二重组合】顶部背离 + 压力眼", "{{ticker}} {{interval}} 顶部背离 + 压力眼已确认（同一极值 K 线；两项可能先后确认）")
alertcondition(bullEyeZone, "【三重组合】底部背离 + 支撑眼 + 超卖", "{{ticker}} {{interval}} 底部背离 + 支撑眼 + 超卖已确认（位于同一极值 K 线）")
alertcondition(bearEyeZone, "【三重组合】顶部背离 + 压力眼 + 超买", "{{ticker}} {{interval}} 顶部背离 + 压力眼 + 超买已确认（位于同一极值 K 线）")
````
