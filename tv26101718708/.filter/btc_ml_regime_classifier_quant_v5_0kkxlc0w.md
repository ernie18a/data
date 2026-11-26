# BTC ML Regime Classifier (Quant V5)

- url: https://www.tradingview.com/script/0kkxLc0w-BTC-ML-Regime-Classifier-Quant-V5/
- type: indicator
- pine_id: PUB;6c475d543fb149d2b5e0f1fdcc83eab6
- version: 4.0

## Description

🧠 ML Quant V5: The Institutional Regime Classifier
ML Quant V5 is not a traditional technical indicator. It is a Machine Learning Market Regime Classifier (KNN Algorithm) specifically designed to isolate crypto market noise and detect institutional behavior.

Unlike RSI, MACD, or ADX (which are one-dimensional, static, and suffer from lag), this model processes 6 Quantitative Dimensions simultaneously in real-time, utilizing Lorentzian Distance to immunize itself against liquidity manipulation (wicks and fakeouts).

⚙️ Quantitative Engine (The 6 Dimensions):

Fractal Dimension: Measures the index of Chaos vs. Structure.
Kinematics: Calculates the real Velocity and Acceleration of price action.
Institutional Gravity: Measures the VWAP Z-Score to detect extreme statistical deviations.
Skewness: Predicts the probability of fat tails and directional volatility spikes.
Volatility: Detects the exact transition point between contraction and expansion.
Volume Anomaly (VSA): Tracks asymmetric Smart Money injections.
🧠 How Does the Artificial Intelligence Work? The model scans the current candle (its 6 dimensions) and searches its Historical Memory (Lookback) for the "K" exact moments in the past where the market had the exact same physical signature. Based on those historical precedents, it outputs a Pure Probability (0-100) that the current trend will sustain itself.

🎯 Minimalist Interface ("Sniper Mode"): Designed to prevent trader visual fatigue. The panel is 100% dark and only emits alerts when the math demands action:

Continuous Gray Line: The real-time probability percentage.
🟢 Green Dot (Long): Total confluence. The macro regime is bullish AND the micro acceleration trigger just fired.
🔴 Red Dot (Short): Confirmed bearish confluence.
🟡 Yellow Dots (Warning): The algorithm detects Extreme Euphoria (>85) or Capitulation (<15). Mathematical alert of impending "Exhaustion". Take profits or tighten your Stop Loss.
Stop trading by looking in the rearview mirror with moving averages from the 70s. Trade by reading the real physics of price.

## Source Code

````pine
//@version=6
indicator("BTC ML Regime Classifier (Quant V5)", shorttitle="ML Quant V5", overlay=false)

// -----------------------------------------------------------------------------
// V5: Arquitectura Cuantitativa Híbrida. Eliminación de indicadores tradicionales.
// Features: Fractalidad, Cinemática, Z-Scores (VWAP/ATR), Skewness y Volumen.
// -----------------------------------------------------------------------------

// ================= Configuración Sencilla para Usuarios =================
modo = input.string("Scalping (Rápido)", "Modo de Trading", options=["Scalping (Rápido)", "Normal (Balanceado)", "Preciso (Seguro)"])

// Lógica interna asignada automáticamente según el modo elegido
k_neighbors = modo == "Scalping (Rápido)" ? 3 : modo == "Normal (Balanceado)" ? 5 : 7
ema_rapida = modo == "Scalping (Rápido)" ? 1 : modo == "Normal (Balanceado)" ? 2 : 3
ema_lenta = modo == "Scalping (Rápido)" ? 8 : modo == "Normal (Balanceado)" ? 10 : 14
limite_bull = modo == "Scalping (Rápido)" ? 51.0 : modo == "Normal (Balanceado)" ? 52.0 : 53.0
limite_bear = modo == "Scalping (Rápido)" ? 49.0 : modo == "Normal (Balanceado)" ? 48.0 : 47.0

// Configuraciones fijas del modelo (Ocultas para mayor simplicidad)
lookback = 300
kernel_bandwidth = 1.0

// ================= 1. Dimensiones Matemáticas (Quant Features) =================

// 1.1 Dimensión Fractal (Choppiness Index) - Caos vs Tendencia
calc_chop(len) =>
    atr_sum = math.sum(ta.atr(1), len)
    high_h = ta.highest(high, len)
    low_l = ta.lowest(low, len)
    100 * math.log10(atr_sum / math.max(high_h - low_l, 0.0001)) / math.log10(len)

f1 = nz(calc_chop(14), 50.0)

// 1.2 Momentum Cinemático (Velocidad y Aceleración del Precio)
v_precio = close - nz(close[1], close)
a_precio = v_precio - nz(v_precio[1], v_precio)
f2 = v_precio + (a_precio * 0.5)

// 1.3 Z-Score del VWAP (Centro de Gravedad Institucional)
vwap_val = ta.vwap
std_vwap = ta.stdev(close, 20)
f3 = (close - nz(vwap_val, close)) / math.max(nz(std_vwap, 1.0), 0.0001)

// 1.4 RSI Momentum (14) — Alineado con TypeScript (mismo algoritmo RMA de Wilder)
// Reemplaza Skewness de Pearson: RSI es más informativo para crypto y es el estándar institucional
f4 = ta.rsi(close, 14)

// 1.5 Z-Score de Volatilidad (Contracción vs Expansión)
atr_val = ta.atr(14)
atr_mean = ta.sma(atr_val, 50)
atr_std = ta.stdev(atr_val, 50)
f5 = (atr_val - nz(atr_mean, atr_val)) / math.max(nz(atr_std, 1.0), 0.0001)

// 1.6 Anomalía de Volumen (Micro-estructura Smart Money)
safe_volume = nz(volume, 0.0)
f6 = safe_volume / math.max(nz(ta.sma(safe_volume, 20), 1.0), 0.0001)

// Normalización Min-Max adaptable y Segura contra NA
normalize(src, len) =>
    min_val = nz(ta.lowest(src, len), src)
    max_val = nz(ta.highest(src, len), src)
    diff = max_val - min_val
    diff == 0 ? 0.0 : (src - min_val) / diff

f1_n = normalize(f1, lookback)
f2_n = normalize(f2, lookback)
f3_n = normalize(f3, lookback)
f4_n = normalize(f4, lookback)
f5_n = normalize(f5, lookback)
f6_n = normalize(f6, lookback)

// Target Dinámico (Ignorar Ruido)
target_change = close - nz(close[4], close)
noise_threshold = nz(ta.atr(14), 0.0) * 0.5 // Bajamos a 0.5 para que el modelo tenga suficientes ejemplos de los que aprender
target_dir = target_change > noise_threshold ? 1 : target_change < -noise_threshold ? -1 : 0

// ================= Arrays (Memoria del Modelo) =================
var f1_history = array.new_float(0)
var f2_history = array.new_float(0)
var f3_history = array.new_float(0)
var f4_history = array.new_float(0)
var f5_history = array.new_float(0)
var f6_history = array.new_float(0)
var dir_history = array.new_int(0)

// Entrenamiento continuo (Asegurado contra valores NA)
if barstate.isconfirmed
    array.unshift(f1_history, nz(f1_n[4], 0.0))
    array.unshift(f2_history, nz(f2_n[4], 0.0))
    array.unshift(f3_history, nz(f3_n[4], 0.0))
    array.unshift(f4_history, nz(f4_n[4], 0.0))
    array.unshift(f5_history, nz(f5_n[4], 0.0))
    array.unshift(f6_history, nz(f6_n[4], 0.0))
    array.unshift(dir_history, target_dir)
    
    if array.size(f1_history) > lookback
        array.pop(f1_history)
        array.pop(f2_history)
        array.pop(f3_history)
        array.pop(f4_history)
        array.pop(f5_history)
        array.pop(f6_history)
        array.pop(dir_history)

// ================= Cálculo 6D de Distancia Lorentziana =================
lorentzian_distance(x1, y1, x2, y2, x3, y3, x4, y4, x5, y5, x6, y6) =>
    d1 = math.log(1 + math.abs(x1 - y1))
    d2 = math.log(1 + math.abs(x2 - y2))
    d3 = math.log(1 + math.abs(x3 - y3))
    d4 = math.log(1 + math.abs(x4 - y4))
    d5 = math.log(1 + math.abs(x5 - y5))
    d6 = math.log(1 + math.abs(x6 - y6))
    d1 + d2 + d3 + d4 + d5 + d6

// ================= 2. Votos Ponderados (Gaussian Kernel) =================
float bull_probability = 50.0

if array.size(f1_history) >= k_neighbors
    var distances = array.new_float(0)
    var indices = array.new_int(0)
    
    array.clear(distances)
    array.clear(indices)
    
    for i = 0 to array.size(f1_history) - 1
        dist = lorentzian_distance(f1_n, array.get(f1_history, i), f2_n, array.get(f2_history, i), f3_n, array.get(f3_history, i), f4_n, array.get(f4_history, i), f5_n, array.get(f5_history, i), f6_n, array.get(f6_history, i))
        array.push(distances, dist)
        array.push(indices, i)
        
    bull_votes = 0.0
    bear_votes = 0.0
    
    for i = 0 to k_neighbors - 1
        min_dist = 999999.9
        min_idx_pos = -1
        
        for j = 0 to array.size(distances) - 1
            d = array.get(distances, j)
            if d < min_dist
                min_dist := d
                min_idx_pos := j
                
        if min_idx_pos != -1
            hist_idx = array.get(indices, min_idx_pos)
            voto = array.get(dir_history, hist_idx)
            
            // Peso Kernel Gaussiano
            peso = math.exp(-(min_dist * min_dist) / math.max(kernel_bandwidth, 0.001))
            
            if voto > 0
                bull_votes += peso
            else if voto < 0
                bear_votes += peso
                
            array.set(distances, min_idx_pos, 999999.9)
        
    total_votes = bull_votes + bear_votes
    safe_total = total_votes == 0 ? 1.0 : total_votes
    bull_probability := total_votes > 0 ? (bull_votes / safe_total) * 100 : 50.0

// ================= Visualización y Sistema Híbrido =================
smooth_prob = ta.wma(bull_probability, 3)

// 1. EL CEREBRO (Sesgo ML Quant)
// Definimos el régimen macro usando el modelo predictivo
ml_bull = smooth_prob >= limite_bull
ml_bear = smooth_prob <= limite_bear

// 2. VISUALIZACIÓN PROFESIONAL Y LIMPIA (Estilo Institucional)

// Colores sobrios y profesionales (Estilo Material Design)
color_bull = color.new(#00897b, 0) // Teal oscuro
color_bear = color.new(#e53935, 0) // Rojo oscuro
color_dyn = color.from_gradient(smooth_prob, 15, 85, color_bear, color_bull)

// Línea base central discreta
p_mid = plot(50, "Línea Base", color=color.new(color.gray, 85), linewidth=1)

// Línea principal nítida, sin brillos adicionales
p_main = plot(smooth_prob, "Fuerza Probabilística", color=color_dyn, linewidth=2)

// Relleno muy sutil que no fatiga la vista (90% transparencia)
fill(p_main, p_mid, color=color.new(color_dyn, 92), title="Relleno Suave")

// 3. SEÑAL DE ENTRADA ÓPTIMA (El Gatillo Híbrido)
// Usamos el cruce ultrarrápido de EMAs para detectar el fin de los retrocesos
fast_ema = ta.ema(close, ema_rapida)
slow_ema = ta.ema(close, ema_lenta)

trigger_long = ta.crossover(fast_ema, slow_ema)
trigger_short = ta.crossunder(fast_ema, slow_ema)

// Máquina de estados para evitar SPAM (Solo 1 señal por ola)
var int last_signal = 0
bool optimal_long = false
bool optimal_short = false

// Condiciones: Debe estar en zona saludable, el gatillo debe disparar, y no puede repetir la misma señal
// Se añade barstate.isconfirmed para evitar que la señal parpadee y desaparezca (Repainting)
if smooth_prob >= limite_bull and smooth_prob <= 85 and trigger_long and last_signal != 1 and barstate.isconfirmed
    optimal_long := true
    last_signal := 1

if smooth_prob <= limite_bear and smooth_prob >= 15 and trigger_short and last_signal != -1 and barstate.isconfirmed
    optimal_short := true
    last_signal := -1

// Señales de Entrada Muy Visibles (Etiquetas flotantes)
plotshape(optimal_long ? smooth_prob : na, title="Señal Long", style=shape.labelup, location=location.absolute, color=color_bull, text="L", textcolor=color.white, size=size.small)
plotshape(optimal_short ? smooth_prob : na, title="Señal Short", style=shape.labeldown, location=location.absolute, color=color_bear, text="S", textcolor=color.white, size=size.small)

// 4. ALERTA DE AGOTAMIENTO (Zona de Peligro)
// Dispara una advertencia cuando entra por primera vez a la zona de Euforia/Pánico
alerta_agotamiento_bull = ta.crossover(smooth_prob, 85) and barstate.isconfirmed
alerta_agotamiento_bear = ta.crossunder(smooth_prob, 15) and barstate.isconfirmed

// Marcador de advertencia visual (Oculto a petición del usuario para dejar solo L y S)
// plotshape(alerta_agotamiento_bull or alerta_agotamiento_bear ? smooth_prob : na, title="Alerta Agotamiento", style=shape.xcross, location=location.absolute, color=color.new(#fb8c00, 0), size=size.small)

// Líneas de umbral limpias y punteadas para enmarcar las zonas extremas (Color neutro)
hline(85, "Nivel Sobrecompra", color=color.new(color.gray, 50), linestyle=hline.style_dashed)
hline(15, "Nivel Sobreventa", color=color.new(color.gray, 50), linestyle=hline.style_dashed)

// ================= 5. SISTEMA DE ALERTAS (Notificaciones al Móvil/PC) =================
// Estas funciones permiten a TradingView enviarte un PUSH a la app, un email o un Webhook.

// Alertas Sencillas
alertcondition(optimal_long, title="🟢 ML Quant V5 Long", message="ML Quant V5 Long")
alertcondition(optimal_short, title="🔴 ML Quant V5 Short", message="ML Quant V5 Short")
alertcondition(alerta_agotamiento_bull, title="⚠️ ML Quant V5 Alerta Sobrecompra", message="ML Quant V5 Alerta Sobrecompra")
alertcondition(alerta_agotamiento_bear, title="⚠️ ML Quant V5 Alerta Sobreventa", message="ML Quant V5 Alerta Sobreventa")
````
