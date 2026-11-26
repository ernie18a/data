# InvestAI - Backtest Long Short v3

- url: https://www.tradingview.com/script/BJDRgy7z/
- type: strategy
- pine_id: PUB;691295b13b0d41b394544d04e3441ba0
- version: 1.0

## Description

[pine]<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>InvestAI – Backtest Long Short v3</title>
<link href="https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=Syne:wght@400;600;700;800&display=swap" rel="stylesheet">
<style>
  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  :root {
    --bg:       #0a0c0f;
    --panel:    #111318;
    --border:   #1e2128;
    --green:    #00e676;
    --red:      #ff3d5a;
    --blue:     #2979ff;
    --gold:     #ffc107;
    --purple:   #7c4dff;
    --text:     #e8eaf0;
    --muted:    #565c6e;
    --mono:     'Space Mono', monospace;
    --sans:     'Syne', sans-serif;
  }

  body {
    background: var(--bg);
    color: var(--text);
    font-family: var(--sans);
    min-height: 100vh;
    overflow-x: hidden;
  }

  /* ── GRID NOISE BACKGROUND ── */
  body::before {
    content: '';
    position: fixed; inset: 0;
    background-image:
      linear-gradient(rgba(41,121,255,.04) 1px, transparent 1px),
      linear-gradient(90deg, rgba(41,121,255,.04) 1px, transparent 1px);
    background-size: 40px 40px;
    pointer-events: none;
    z-index: 0;
  }

  .wrap {
    position: relative;
    z-index: 1;
    max-width: 780px;
    margin: 0 auto;
    padding: 60px 24px 80px;
  }

  /* ── HEADER ── */
  .header {
    border-left: 3px solid var(--green);
    padding-left: 20px;
    margin-bottom: 48px;
  }
  .tag {
    font-family: var(--mono);
    font-size: 11px;
    letter-spacing: .15em;
    color: var(--green);
    text-transform: uppercase;
    margin-bottom: 12px;
  }
  h1 {
    font-size: clamp(28px, 5vw, 46px);
    font-weight: 800;
    line-height: 1.1;
    letter-spacing: -.02em;
  }
  h1 span { color: var(--green); }
  .subtitle {
    margin-top: 12px;
    color: var(--muted);
    font-size: 15px;
    font-weight: 400;
    line-height: 1.6;
    max-width: 560px;
  }

  /* ── STATS ROW ── */
  .stats {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 12px;
    margin-bottom: 40px;
  }
  .stat {
    background: var(--panel);
    border: 1px solid var(--border);
    border-radius: 10px;
    padding: 16px 14px;
    position: relative;
    overflow: hidden;
  }
  .stat::after {
    content: '';
    position: absolute;
    top: 0; left: 0; right: 0;
    height: 2px;
    background: var(--accent, var(--green));
  }
  .stat-val {
    font-family: var(--mono);
    font-size: 22px;
    font-weight: 700;
    color: var(--accent, var(--green));
    display: block;
    margin-bottom: 4px;
  }
  .stat-label {
    font-size: 11px;
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: .08em;
  }

  /* ── SECTION ── */
  .section {
    margin-bottom: 36px;
  }
  .section-title {
    font-family: var(--mono);
    font-size: 11px;
    letter-spacing: .18em;
    text-transform: uppercase;
    color: var(--muted);
    margin-bottom: 16px;
    display: flex;
    align-items: center;
    gap: 10px;
  }
  .section-title::after {
    content: '';
    flex: 1;
    height: 1px;
    background: var(--border);
  }

  /* ── INDICATOR BLOCKS ── */
  .indicators {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
  }
  .ind {
    background: var(--panel);
    border: 1px solid var(--border);
    border-radius: 10px;
    padding: 18px 16px;
    display: flex;
    gap: 14px;
    align-items: flex-start;
  }
  .ind-icon {
    width: 36px; height: 36px;
    border-radius: 8px;
    display: flex; align-items: center; justify-content: center;
    font-size: 18px;
    flex-shrink: 0;
  }
  .ind-name {
    font-size: 13px;
    font-weight: 700;
    margin-bottom: 4px;
  }
  .ind-desc {
    font-size: 12px;
    color: var(--muted);
    line-height: 1.5;
  }

  /* ── SIGNAL LOGIC ── */
  .signal-box {
    background: var(--panel);
    border: 1px solid var(--border);
    border-radius: 12px;
    overflow: hidden;
  }
  .signal-row {
    display: grid;
    grid-template-columns: 80px 1fr;
    border-bottom: 1px solid var(--border);
  }
  .signal-row:last-child { border-bottom: none; }
  .signal-side {
    padding: 16px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-family: var(--mono);
    font-size: 12px;
    font-weight: 700;
    letter-spacing: .1em;
  }
  .signal-side.long  { color: var(--green); background: rgba(0,230,118,.05); }
  .signal-side.short { color: var(--red);   background: rgba(255,61,90,.05); }
  .signal-conditions {
    padding: 14px 18px;
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    align-items: center;
  }
  .cond {
    font-family: var(--mono);
    font-size: 11px;
    padding: 4px 10px;
    border-radius: 4px;
    background: rgba(255,255,255,.04);
    border: 1px solid var(--border);
    color: var(--text);
  }
  .cond.and {
    background: transparent;
    border: none;
    color: var(--muted);
    font-size: 10px;
    padding: 4px 2px;
  }

  /* ── RISK MANAGEMENT ── */
  .risk-grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 12px;
  }
  .risk-card {
    background: var(--panel);
    border: 1px solid var(--border);
    border-radius: 10px;
    padding: 18px 16px;
    text-align: center;
  }
  .risk-big {
    font-family: var(--mono);
    font-size: 28px;
    font-weight: 700;
    display: block;
    margin-bottom: 4px;
  }
  .risk-sub {
    font-size: 11px;
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: .08em;
    display: block;
    margin-bottom: 8px;
  }
  .risk-note {
    font-size: 11px;
    color: var(--muted);
    line-height: 1.4;
  }

  /* ── HUD TABLE ── */
  .hud {
    background: var(--panel);
    border: 1px solid var(--border);
    border-radius: 12px;
    overflow: hidden;
  }
  .hud-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    border-bottom: 1px solid var(--border);
  }
  .hud-row:last-child { border-bottom: none; }
  .hud-cell {
    padding: 12px 18px;
    font-family: var(--mono);
    font-size: 12px;
  }
  .hud-cell:first-child { color: var(--muted); border-right: 1px solid var(--border); }
  .hud-cell.green  { color: var(--green); }
  .hud-cell.red    { color: var(--red); }
  .hud-cell.gold   { color: var(--gold); }
  .hud-cell.blue   { color: var(--blue); }

  /* ── SETUP TABLE ── */
  .setup-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 13px;
  }
  .setup-table th {
    font-family: var(--mono);
    font-size: 10px;
    letter-spacing: .12em;
    text-transform: uppercase;
    color: var(--muted);
    text-align: left;
    padding: 10px 16px;
    border-bottom: 1px solid var(--border);
  }
  .setup-table td {
    padding: 12px 16px;
    border-bottom: 1px solid var(--border);
    color: var(--text);
  }
  .setup-table tr:last-child td { border-bottom: none; }
  .setup-table td:last-child {
    font-family: var(--mono);
    font-size: 12px;
    color: var(--green);
    text-align: right;
  }
  .setup-wrap {
    background: var(--panel);
    border: 1px solid var(--border);
    border-radius: 12px;
    overflow: hidden;
  }

  /* ── DISCLAIMER ── */
  .disclaimer {
    margin-top: 48px;
    padding: 18px 20px;
    border: 1px solid var(--border);
    border-radius: 10px;
    font-size: 11px;
    color: var(--muted);
    line-height: 1.7;
    font-family: var(--mono);
  }
  .disclaimer strong { color: var(--text); }

  /* ── FOOTER ── */
  .footer {
    margin-top: 40px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding-top: 24px;
    border-top: 1px solid var(--border);
  }
  .footer-brand {
    font-weight: 800;
    font-size: 18px;
    letter-spacing: -.01em;
  }
  .footer-brand span { color: var(--green); }
  .badge {
    font-family: var(--mono);
    font-size: 10px;
    padding: 5px 12px;
    border-radius: 20px;
    border: 1px solid var(--border);
    color: var(--muted);
    letter-spacing: .1em;
    text-transform: uppercase;
  }

  @media (max-width: 600px) {
    .stats { grid-template-columns: repeat(2, 1fr); }
    .indicators { grid-template-columns: 1fr; }
    .risk-grid { grid-template-columns: 1fr; }
  }
</style>
</head>
<body>
<div class="wrap">

  <!-- HEADER -->
  <div class="header">
    <div class="tag">// TradingView Pine Script v6 · Crypto · Timeframe 1D</div>
    <h1>InvestAI – <span>Backtest</span><br>Long Short v3</h1>
    <p class="subtitle">Sistema de trading algorítmico basado en cruce de EMAs con confirmación MACD. Diseñado para operar en mercados crypto con gestión de riesgo asimétrica vía ATR.</p>
  </div>

  <!-- STATS -->
  <div class="stats">
    <div class="stat" style="--accent: var(--green)">
      <span class="stat-val">+34,6%</span>
      <span class="stat-label">Retorno anual</span>
    </div>
    <div class="stat" style="--accent: var(--blue)">
      <span class="stat-val">107</span>
      <span class="stat-label">Operaciones (9 años)</span>
    </div>
    <div class="stat" style="--accent: var(--gold)">
      <span class="stat-val">11,98%</span>
      <span class="stat-label">Drawdown máx.</span>
    </div>
    <div class="stat" style="--accent: var(--purple)">
      <span class="stat-val">4:1</span>
      <span class="stat-label">Ratio TP / SL</span>
    </div>
  </div>

  <!-- INDICADORES -->
  <div class="section">
    <div class="section-title">Indicadores utilizados</div>
    <div class="indicators">
      <div class="ind">
        <div class="ind-icon" style="background:rgba(41,121,255,.12); color:var(--blue)">📈</div>
        <div>
          <div class="ind-name">EMA 9 / EMA 21</div>
          <div class="ind-desc">Cruce de medias exponenciales rápida y lenta. Genera la señal de entrada primaria en ambas direcciones.</div>
        </div>
      </div>
      <div class="ind">
        <div class="ind-icon" style="background:rgba(0,230,118,.12); color:var(--green)">⚡</div>
        <div>
          <div class="ind-name">MACD (12, 26, 9)</div>
          <div class="ind-desc">Confirmador de momentum. Solo se opera si el MACD está alineado con la dirección del cruce de EMAs.</div>
        </div>
      </div>
      <div class="ind">
        <div class="ind-icon" style="background:rgba(255,193,7,.12); color:var(--gold)">🎯</div>
        <div>
          <div class="ind-name">RSI (14)</div>
          <div class="ind-desc">Filtro de zonas extremas. Evita entrar en longs con RSI >70 y en shorts con RSI &lt;30.</div>
        </div>
      </div>
      <div class="ind">
        <div class="ind-icon" style="background:rgba(255,61,90,.12); color:var(--red)">🔒</div>
        <div>
          <div class="ind-name">ATR (14)</div>
          <div class="ind-desc">Calcula el Stop Loss y Take Profit de forma dinámica según la volatilidad actual del mercado.</div>
        </div>
      </div>
    </div>
  </div>

  <!-- SEÑALES -->
  <div class="section">
    <div class="section-title">Lógica de señales</div>
    <div class="signal-box">
      <div class="signal-row">
        <div class="signal-side long">LONG</div>
        <div class="signal-conditions">
          <span class="cond">EMA9 cruza ↑ EMA21</span>
          <span class="cond and">+</span>
          <span class="cond">RSI entre 30–70</span>
          <span class="cond and">+</span>
          <span class="cond">MACD bull</span>
          <span class="cond and">+</span>
          <span class="cond">cierre vela confirmado</span>
        </div>
      </div>
      <div class="signal-row">
        <div class="signal-side short">SHORT</div>
        <div class="signal-conditions">
          <span class="cond">EMA9 cruza ↓ EMA21</span>
          <span class="cond and">+</span>
          <span class="cond">RSI entre 30–70</span>
          <span class="cond and">+</span>
          <span class="cond">MACD bear</span>
          <span class="cond and">+</span>
          <span class="cond">cierre vela confirmado</span>
        </div>
      </div>
    </div>
  </div>

  <!-- GESTIÓN DE RIESGO -->
  <div class="section">
    <div class="section-title">Gestión de riesgo</div>
    <div class="risk-grid">
      <div class="risk-card">
        <span class="risk-big" style="color:var(--red)">1× ATR</span>
        <span class="risk-sub">Stop Loss</span>
        <span class="risk-note">Se sitúa 1 ATR por debajo/encima del precio de entrada</span>
      </div>
      <div class="risk-card">
        <span class="risk-big" style="color:var(--green)">4× ATR</span>
        <span class="risk-sub">Take Profit</span>
        <span class="risk-note">Objetivo 4 veces la distancia del stop. Ratio 4:1</span>
      </div>
      <div class="risk-card">
        <span class="risk-big" style="color:var(--blue)">15%</span>
        <span class="risk-sub">Tamaño posición</span>
        <span class="risk-note">15% del equity por operación. Capital protegido en cada trade</span>
      </div>
    </div>
  </div>

  <!-- HUD EN GRÁFICO -->
  <div class="section">
    <div class="section-title">Panel HUD en tiempo real</div>
    <div class="hud">
      <div class="hud-row">
        <div class="hud-cell">RSI</div>
        <div class="hud-cell green">54.2 — zona neutra</div>
      </div>
      <div class="hud-row">
        <div class="hud-cell">MACD</div>
        <div class="hud-cell green">BULL — momentum alcista</div>
      </div>
      <div class="hud-row">
        <div class="hud-cell">Tendencia</div>
        <div class="hud-cell green">ALCISTA — EMA9 > EMA21</div>
      </div>
      <div class="hud-row">
        <div class="hud-cell">ATR</div>
        <div class="hud-cell gold">102.36 — volatilidad media</div>
      </div>
      <div class="hud-row">
        <div class="hud-cell">Señal</div>
        <div class="hud-cell blue">ESPERAR — sin cruce activo</div>
      </div>
    </div>
  </div>

  <!-- CONFIGURACIÓN RECOMENDADA -->
  <div class="section">
    <div class="section-title">Configuración recomendada</div>
    <div class="setup-wrap">
      <table class="setup-table">
        <thead>
          <tr>
            <th>Parámetro</th>
            <th>Descripción</th>
            <th>Valor</th>
          </tr>
        </thead>
        <tbody>
          <tr><td>Par</td><td>Activo de alta liquidez</td><td>ETH/USD · BTC/USD</td></tr>
          <tr><td>Timeframe</td><td>Velas diarias, señales limpias</td><td>1D</td></tr>
          <tr><td>EMA Rápida</td><td>Reactividad al precio</td><td>9</td></tr>
          <tr><td>EMA Lenta</td><td>Tendencia de corto plazo</td><td>21</td></tr>
          <tr><td>TP × ATR</td><td>Multiplicador take profit</td><td>4.0</td></tr>
          <tr><td>SL × ATR</td><td>Multiplicador stop loss</td><td>1.0</td></tr>
          <tr><td>Comisión simulada</td><td>Binance spot/futures</td><td>0.05%</td></tr>
          <tr><td>Backtest período</td><td>Incluye bear market 2022</td><td>2015 – 2026</td></tr>
        </tbody>
      </table>
    </div>
  </div>

  <!-- DISCLAIMER -->
  <div class="disclaimer">
    <strong>⚠️ Aviso importante.</strong> Los resultados del backtest son históricos y no garantizan rendimientos futuros. Este indicador es una herramienta de análisis técnico, no asesoramiento financiero. Opera siempre con capital que puedas permitirte perder y aplica tu propia gestión de riesgo. El trading de criptomonedas conlleva un riesgo elevado de pérdida de capital.
  </div>

  <!-- FOOTER -->
  <div class="footer">
    <div class="footer-brand">Invest<span>AI</span></div>
    <div style="display:flex; gap:8px;">
      <span class="badge">Pine Script v6</span>
      <span class="badge">Open Source</span>
    </div>
  </div>

</div>
</body>
</html>[/pine]

## Source Code

````pine
//@version=6
strategy("InvestAI - Backtest Long Short v3", overlay=true, max_bars_back=500,
         default_qty_type=strategy.percent_of_equity,
         default_qty_value=15,
         commission_type=strategy.commission.percent,
         commission_value=0.05,
         slippage=1)

// ── INPUTS ────────────────────────────────────────────────────────────────────
emaFast   = input.int(9,    "EMA Rápida")
emaSlow   = input.int(21,   "EMA Lenta")
rsiLen    = input.int(14,   "RSI Periodo")
rsiOB     = input.int(70,   "RSI Sobrecompra")
rsiOS     = input.int(30,   "RSI Sobreventa")
atrLen    = input.int(14,   "ATR Periodo")
slMult    = input.float(1.0,  "SL Multiplicador ATR", minval=0.5, maxval=5.0,  step=0.5)
tpMult    = input.float(4.0,  "TP Multiplicador ATR", minval=0.5, maxval=10.0, step=0.5)
useVol    = input.bool(false, "Filtro Volumen")
volMult   = input.float(1.2,  "Volumen mínimo vs media", minval=1.0, maxval=3.0, step=0.1)
useMacro  = input.bool(false, "Filtro EMA 200")
useConfirm = input.bool(true, "Confirmar cierre de vela")

// ── INDICADORES ───────────────────────────────────────────────────────────────
eFast  = ta.ema(close, emaFast)
eSlow  = ta.ema(close, emaSlow)
eMacro = ta.ema(close, 200)
rsi    = ta.rsi(close, rsiLen)
atr    = ta.atr(atrLen)
vol20  = ta.sma(volume, 20)

[macdLine, signalLine, _] = ta.macd(close, 12, 26, 9)
macdBull = macdLine > signalLine
macdBear = macdLine < signalLine

// ── SEÑALES ───────────────────────────────────────────────────────────────────
bullCross = ta.crossover(eFast, eSlow)
bearCross = ta.crossunder(eFast, eSlow)

volOk      = useVol   ? volume > vol20 * volMult : true
macroLong  = useMacro ? close > eMacro           : true
macroShort = useMacro ? close < eMacro           : true

longRaw  = bullCross and rsi > rsiOS and rsi < rsiOB and macdBull and volOk and macroLong
shortRaw = bearCross and rsi < rsiOB and rsi > rsiOS and macdBear and volOk and macroShort

longSig  = useConfirm ? longRaw[1]  : longRaw
shortSig = useConfirm ? shortRaw[1] : shortRaw

// ── ENTRADAS ──────────────────────────────────────────────────────────────────
if longSig
    strategy.entry("LONG", strategy.long)
    strategy.exit("EXIT LONG", from_entry="LONG",
                  stop  = close - atr * slMult,
                  limit = close + atr * tpMult)

if shortSig
    strategy.entry("SHORT", strategy.short)
    strategy.exit("EXIT SHORT", from_entry="SHORT",
                  stop  = close + atr * slMult,
                  limit = close - atr * tpMult)

// ── VISUALIZACIÓN ─────────────────────────────────────────────────────────────
p1 = plot(eFast,  "EMA Rápida", color=#0066ff, linewidth=1)
p2 = plot(eSlow,  "EMA Lenta",  color=#6d4aff, linewidth=2)
plot(useMacro ? eMacro : na, "EMA 200", color=color.new(#f5a623, 50), linewidth=2)
fill(p1, p2, color = eFast > eSlow ? color.new(#00a86b, 90) : color.new(#e63946, 90))

plotshape(longSig,  "LONG",  shape.labelup,   location.belowbar, color.new(#00a86b, 0), text="LONG",  textcolor=color.white, size=size.small)
plotshape(shortSig, "SHORT", shape.labeldown, location.abovebar, color.new(#e63946, 0), text="SHORT", textcolor=color.white, size=size.small)

// ── HUD ───────────────────────────────────────────────────────────────────────
var table hud = table.new(position.top_right, 2, 5, bgcolor=color.new(#1a1d23, 10), border_color=#e2e6ed, border_width=1)
table.cell(hud, 0, 0, "RSI",      text_color=#7a8499, text_size=size.small)
table.cell(hud, 1, 0, str.tostring(math.round(rsi,1)), text_color = rsi>rsiOB ? #e63946 : rsi<rsiOS ? #00a86b : #ffffff, text_size=size.small)
table.cell(hud, 0, 1, "MACD",     text_color=#7a8499, text_size=size.small)
table.cell(hud, 1, 1, macdBull ? "BULL" : "BEAR", text_color = macdBull ? #00a86b : #e63946, text_size=size.small)
table.cell(hud, 0, 2, "Tendencia",text_color=#7a8499, text_size=size.small)
table.cell(hud, 1, 2, eFast > eSlow ? "ALCISTA" : "BAJISTA", text_color = eFast > eSlow ? #00a86b : #e63946, text_size=size.small)
table.cell(hud, 0, 3, "ATR",      text_color=#7a8499, text_size=size.small)
table.cell(hud, 1, 3, str.tostring(math.round(atr,2)), text_color=#d4870a, text_size=size.small)
table.cell(hud, 0, 4, "Señal",    text_color=#7a8499, text_size=size.small)
table.cell(hud, 1, 4, longSig ? "LONG ✓" : shortSig ? "SHORT ✓" : "ESPERAR", text_color = longSig ? #00a86b : shortSig ? #e63946 : #7a8499, text_size=size.small)
````
