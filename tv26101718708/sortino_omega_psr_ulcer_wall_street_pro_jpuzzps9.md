# Sortino + Omega + PSR + Ulcer [Wall Street Pro

- url: https://www.tradingview.com/script/jPUzzPS9/
- type: indicator
- pine_id: PUB;d13b7ad70f884f75a35259990d5d0c44
- version: 1.0

## Description

[Script Introduction]
Within Quantamental and macro-hedging frameworks, the traditional mean-variance theory (such as the traditional Sharpe Ratio) possesses a fatal flaw: it penalizes "good" upside volatility and fails to identify the "black swan" DNA inherent in non-normal distributions.

This script, Sortino + Omega + PSR + Ulcer [Wall Street Pro], is an institutional-grade asset "personality" diagnostic and performance attribution system. By visualizing higher-order moment statistics (Skewness, Kurtosis) alongside path-dependent drawdown risk (Ulcer Index), it is designed to help traders identify pseudo-high-yield/pseudo-high-win-rate assets that are essentially "picking up pennies in front of a steamroller," and to discover true Alpha backed by genuine microstructure advantages.

[Core Parameters & Practical Significance]

Sortino vs. Sharpe Ratio: Debunks the volatility illusion. By only penalizing downside volatility, a Sortino ratio significantly higher than the Sharpe ratio indicates that the asset possesses immense upside explosive power.

Skewness & Kurtosis: The tail-risk detectors. Specifically designed to capture hidden "fat-tail" risks (e.g., gap-downs from unexpected blow-ups). Extreme skewness and high kurtosis often signal devastating losses during liquidity dry-ups.

PSR (Probabilistic Sharpe Ratio): The performance lie detector. By incorporating non-normal distribution parameters, it calculates the statistical probability that a strategy is genuinely effective, filtering out historical backtest illusions driven purely by luck.

Ulcer Index & Global Underwater Curve: Measures the integral of "drawdown depth × duration of distress." Paired with intuitive underwater region visualizations on the main chart, it evaluates the pressure the asset exerts on capital chains and traders' psychological defenses.

Omega Ratio: The overarching profit/loss scale, evaluating the overall quality of the winning probability across the entire return distribution.

[Application Scenarios]

Liquidity stress testing for broad market indices and high-Beta assets (e.g., microstructure comparisons between SPX and MSTR).

Validation of macro-hedge allocations (e.g., testing the reduction in a portfolio's Ulcer Index after incorporating safe-haven assets like precious metals).

"Mine-sweeping" for CTA and high-dividend strategies (identifying assets with deep negative skewness).量化基本面（Quantamental）与宏观对冲框架下，传统的均值-方差理论（如传统夏普比率）存在致命缺陷：它惩罚了向上的好波动，且无法识别非正态分布下的“黑天鹅”基因。

本脚本 Sortino + Omega + PSR + Ulcer [Wall Street Pro] 是一套机构级的资产“性格”体检与业绩归因系统。它将高阶矩统计（偏度、峰度）与路径回撤风险（溃疡指数）可视化，旨在帮助交易者识别出那些“在推土机前捡硬币”的伪高息/伪高胜率资产，寻找真正具备微观结构优势的Alpha。

【核心参数与实战意义】

Sortino (索提诺比率) vs Sharpe (夏普比率)： 破解波动率错觉。只惩罚下行波动，当 Sortino 显著大于 Sharpe 时，标明该资产具备极强的向上爆发力。

Skew (偏度) & Kurt (峰度)： 尾部风险照妖镜。专门捕捉隐藏的“肥尾”风险（如暴雷跳空）。高偏度/高峰度往往意味着流动性枯竭时的毁灭性打击。

PSR (概率夏普比率)： 业绩测谎仪。引入非正态分布参数，计算策略真实有效的统计学概率，过滤掉纯靠运气的历史回测幻觉。

Ulcer Index (溃疡指数) & 全局水下曲线： 衡量“套牢深度 × 煎熬时间”的积分。配合主图直观的水下区域可视化，评估资产对资金链和交易者心理防线的压迫程度。

Omega Ratio (全分布比率)： 统揽全局的盈亏天平，评估整体赢面质量。

【适用场景】

大盘指数与高Beta资产的流动性压力测试（如 SPX 与 MSTR 的微观结构对比）。

宏观对冲配置的有效性验证（测试加入贵金属等避险资产后，组合溃疡指数的下降程度）。

CTA及高股息策略的“排雷”（识别深负偏度资产）。

【使用建议】
建议配合多锚点 VWAP (Anchored VWAP) 使用。当资产价格跌破核心机构成本线，且本指标面板中的 Sortino 出现倒挂、Ulcer 快速攀升时，往往是微观结构恶化、宏观流动性退潮的右侧确认信号。

## Source Code

````pine
//@version=6
indicator("Sortino + Omega + PSR + Ulcer [Wall Street Pro]", overlay=false, precision=3)

// === 输入 ===
period = input.int(252, "评估窗口(交易日)", minval=60)
rfAnn  = input.float(4.5, "无风险利率(年化 %)", step=0.1) / 100
mar    = input.float(0.0, "最低可接受收益 MAR(年化 %)", step=0.1) / 100
useLog = input.bool(true, "使用对数收益")

// === 日收益 ===
ret    = useLog ? math.log(close / close[1]) : (close / close[1] - 1)
rfDay  = rfAnn / 252
marDay = mar / 252
excess = ret - rfDay

// === 1) 年化收益 & 夏普 ===
meanR   = ta.sma(ret, period)
stdR    = ta.stdev(ret, period)
annRet  = meanR * 252
annVol  = stdR * math.sqrt(252)
sharpe  = stdR > 0 ? (meanR - rfDay) / stdR * math.sqrt(252) : na

// === 2) Sortino Ratio:只惩罚下行波动 ===
// 下行偏差 DD = sqrt( mean( min(ret - MAR, 0)^2 ) )
downside2 = math.pow(math.min(ret - marDay, 0), 2)
downDev   = math.sqrt(ta.sma(downside2, period))
sortino   = downDev > 0 ? (meanR - marDay) / downDev * math.sqrt(252) : na

// === 3) Omega Ratio:全分布信息,无正态假设 ===
// Omega(τ) = E[max(ret - τ, 0)] / E[max(τ - ret, 0)]
gainTau = math.max(ret - marDay, 0)
lossTau = math.max(marDay - ret, 0)
omega   = ta.sma(lossTau, period) > 0 ? ta.sma(gainTau, period) / ta.sma(lossTau, period) : na

// === 4) Probabilistic Sharpe Ratio (PSR, Bailey-López de Prado 2012)===
// PSR = Φ( (SR - SR*) × √(N-1) / √(1 - γ3·SR + (γ4-1)/4·SR²) )
// γ3 = 偏度,γ4 = 峰度;这里取 SR* = 0 → 测试"真实 SR > 0"的概率
sr     = sharpe / math.sqrt(252)               // 日 SR
skew   = ta.sma(math.pow((ret - meanR) / stdR, 3), period)
kurt   = ta.sma(math.pow((ret - meanR) / stdR, 4), period)
denom  = math.sqrt(math.max(1 - skew * sr + (kurt - 1) / 4 * sr * sr, 1e-10))
psrArg = sr * math.sqrt(period - 1) / denom

// 标准正态 CDF 近似(Abramowitz & Stegun 7.1.26,误差 < 7.5e-8)
normCDF(x) =>
    a1 =  0.254829592
    a2 = -0.284496736
    a3 =  1.421413741
    a4 = -1.453152027
    a5 =  1.061405429
    p  =  0.3275911
    sign = x < 0 ? -1.0 : 1.0
    xAbs = math.abs(x) / math.sqrt(2)
    tt   = 1.0 / (1.0 + p * xAbs)
    y    = 1.0 - (((((a5 * tt + a4) * tt) + a3) * tt + a2) * tt + a1) * tt * math.exp(-xAbs * xAbs)
    0.5 * (1.0 + sign * y)

psr = normCDF(psrArg)

// === 5) Ulcer Index (Martin & McCann 1989)===
// UI = sqrt( mean( drawdown%² ) ),衡量回撤深度×持续时间
peak = ta.highest(close, period)
ddPct = (close - peak) / peak * 100
ulcer = math.sqrt(ta.sma(math.pow(ddPct, 2), period))

// Martin Ratio = (R - Rf) / Ulcer:超额收益 / 回撤痛苦
martin = ulcer > 0 ? (annRet - rfAnn) / ulcer * 100 : na

// === 6) 综合评级 ===
score = 0
score := sortino > 1.5  ? score + 1 : (sortino < 0.5 ? score - 1 : score)
score := omega   > 1.5  ? score + 1 : (omega   < 1.0 ? score - 1 : score)
score := psr     > 0.95 ? score + 1 : (psr     < 0.50 ? score - 1 : score)
score := martin  > 5.0  ? score + 1 : (martin  < 1.0 ? score - 1 : score)

grade = score >= 3 ? "A 级:机构可投" : score >= 1 ? "B 级:合格" : score == 0 ? "C 级:平庸" : "D 级:差/避免"
gradeCol = score >= 3 ? color.new(color.green, 70) : score >= 1 ? color.new(color.lime, 80) : score == 0 ? color.new(color.gray, 90) : color.new(color.red, 70)
bgcolor(gradeCol)

// === 绘图(只画 Ulcer DD 曲线供参考)===
plot(ddPct, "回撤 %", color=color.red, linewidth=2)
hline(0,    "无回撤",   color=color.white, linestyle=hline.style_dashed)
hline(-10,  "-10%",     color=color.orange, linestyle=hline.style_dotted)
hline(-20,  "-20% 熊市", color=color.red, linestyle=hline.style_dotted)

// === 表格 ===
if barstate.islast
    var table t = table.new(position.top_right, 2, 11, bgcolor=color.new(color.black, 70), border_width=1)
    table.cell(t, 0, 0,  "风险调整指标",  text_color=color.yellow, bgcolor=color.new(color.gray, 40))
    table.cell(t, 1, 0,  "读数",          text_color=color.yellow, bgcolor=color.new(color.gray, 40))
    table.cell(t, 0, 1,  "年化收益",      text_color=color.white)
    table.cell(t, 1, 1,  str.tostring(annRet * 100, "#.##") + "%", text_color = annRet > 0 ? color.lime : color.red)
    table.cell(t, 0, 2,  "年化波动率",    text_color=color.white)
    table.cell(t, 1, 2,  str.tostring(annVol * 100, "#.##") + "%", text_color=color.silver)
    table.cell(t, 0, 3,  "Sharpe(传统)", text_color=color.white)
    table.cell(t, 1, 3,  str.tostring(sharpe, "#.##"),  text_color = sharpe > 1 ? color.lime : color.red)
    table.cell(t, 0, 4,  "Sortino(下行)",  text_color=color.white)
    table.cell(t, 1, 4,  str.tostring(sortino, "#.##"), text_color = sortino > 1.5 ? color.lime : (sortino < 0.5 ? color.red : color.yellow))
    table.cell(t, 0, 5,  "Omega(全分布)",  text_color=color.white)
    table.cell(t, 1, 5,  str.tostring(omega, "#.##"),   text_color = omega > 1.5 ? color.lime : (omega < 1 ? color.red : color.yellow))
    table.cell(t, 0, 6,  "PSR 概率",      text_color=color.white)
    table.cell(t, 1, 6,  str.tostring(psr * 100, "#.#") + "%", text_color = psr > 0.95 ? color.lime : (psr < 0.5 ? color.red : color.yellow))
    table.cell(t, 0, 7,  "偏度 Skew",     text_color=color.silver)
    table.cell(t, 1, 7,  str.tostring(skew, "#.##"),    text_color = skew > 0 ? color.lime : color.red)
    table.cell(t, 0, 8,  "峰度 Kurt",     text_color=color.silver)
    table.cell(t, 1, 8,  str.tostring(kurt, "#.##"),    text_color = kurt > 5 ? color.red : color.silver)
    table.cell(t, 0, 9,  "Ulcer Index",   text_color=color.white)
    table.cell(t, 1, 9,  str.tostring(ulcer, "#.##"),   text_color = ulcer > 10 ? color.red : color.lime)
    table.cell(t, 0, 10, "评级",           text_color=color.aqua, bgcolor=color.new(color.navy, 60))
    table.cell(t, 1, 10, grade,           text_color=color.aqua, bgcolor=color.new(color.navy, 60))
````
