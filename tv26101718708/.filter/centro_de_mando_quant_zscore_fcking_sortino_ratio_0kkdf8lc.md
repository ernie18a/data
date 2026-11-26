# Centro de Mando Quant: Z-Score & F*cking Sortino Ratio

- url: https://www.tradingview.com/script/0KKdF8Lc-Centro-de-Mando-Quant-Z-Score-F-cking-Sortino-Ratio/
- type: indicator
- pine_id: PUB;987d2caa5b7041f6ac4879eabfdec5e8
- version: 1.0

## Description

What the f*ck is up, traders? Listen to me. If you are looking for a magical indicator that paints little green and red arrows to tell you when to buy and sell like a toddler, keep walking. This tool is not for you.

90% of retail traders get absolutely slaughtered in the markets because they trade based on emotions, hope, and imaginary lines drawn blindly on a chart. This script was forged with a strictly military and quantitative mindset. We don't guess here; we calculate probabilities, standard deviations, and asymmetric risk.

I present to you the Quant Command Center, a rolling tactical dashboard designed specifically to measure the guts of  any highly volatile crypto, without cluttering your price action.

⚙️ THE QUANTITATIVE ARSENAL (Under the Hood)
This panel does NOT give automated signals. It gives you raw data so YOU can make the decision to pull the trigger.

Price Z-Score (Statistical Anomalies): Calculates how many standard deviations the current price is from its mean. If the Z-Score breaks +2.5 or drops below -2.5, you are looking at an unsustainable parabolic move. It tells you exactly when the market is overextended so you stop buying the top out of pure FOMO.

Volume Z-Score: Confirms if the current move is backed by heavy artillery (institutional money) or if it's just a weekend skirmish with zero real volume.

Rolling Sharpe Ratio: Measures the performance of price action against total volatility over the selected period.

The Sortino Ratio (Asymmetric Risk): The real survival filter. Unlike the Sharpe ratio, Sortino ONLY penalizes downside volatility. If the Sortino is red, the trend will tear you apart. If it's green, the bullish momentum has a clear, clean path.

🛠️ TACTICAL INSTRUCTIONS
Apply the indicator on 1H or 4H timeframes to filter out market noise.

Keep your eyes locked on the Statistical Context in the bottom right panel.

Use extreme Z-Scores to hunt for Mean Reversions or to lock in your profits.

Use positive Sortino ratios to confirm your entries on Breakouts.

"In war and in the markets, hope is not a tactical strategy. Cold data and discipline are your only salvation."

If you aren't willing to manage your risk, this dashboard won't save you. But if you have the discipline to read the numbers, plan your trade, and execute without hesitation, this tool will give you an unfair statistical advantage over the rest of the market.

Lock and load. Do your backtesting, execute your plan, and stop giving your money away to the market. Dismissed!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Ciberclaudio

//@version=6
indicator("ETH Quant Dashboard - Sargento", overlay=true)

// --- PARÁMETROS TÁCTICOS ---
length = input.int(50, title="Periodo de Lookback (Ventanilla de Datos)")
target_return = input.float(0.0, title="Retorno Objetivo % (Para Sortino/Sharpe)")

// --- 1. Z-SCORE: PRECIO Y VOLUMEN ---
// Mide la anomalía estadística. Si el precio se aleja demasiado, tiende a regresar.
price_mean = ta.sma(close, length)
price_std = ta.stdev(close, length)
z_score_price = price_std == 0 ? 0 : (close - price_mean) / price_std

vol_mean = ta.sma(volume, length)
vol_std = ta.stdev(volume, length)
z_score_vol = vol_std == 0 ? 0 : (volume - vol_mean) / vol_std

// --- 2. RETORNOS Y RATIOS RODANTES DEL ACTIVO ---
// Calculamos la acción del precio como si fuera una curva de equity.
ret = (close - close[1]) / close[1] * 100 // Retorno porcentual por vela

mean_ret = ta.sma(ret, length)
std_ret = ta.stdev(ret, length)

// Sharpe Ratio del activo (Mide retorno vs volatilidad total)
sharpe = std_ret == 0 ? na : (mean_ret - target_return) / std_ret

// Sortino Ratio del activo (Mide retorno vs volatilidad a la baja, el "Fucking Sortino" que pediste)
downside_ret = ret < target_return ? (ret - target_return) : 0.0
downside_variance = ta.sma(math.pow(downside_ret, 2), length)
downside_dev = math.sqrt(downside_variance)
sortino = downside_dev == 0 ? na : (mean_ret - target_return) / downside_dev

// --- 3. CONSTRUCCIÓN DEL DASHBOARD DE INTELIGENCIA ---
// Aquí se imprime la tabla en tu gráfico sin ensuciar la acción del precio.
var table matrix = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

if barstate.islast
    // Encabezados
    table.cell(matrix, 0, 0, "MÉTRICA QUANT", text_color=color.white, bgcolor=color.new(color.maroon, 10))
    table.cell(matrix, 1, 0, "DATO ACTUAL", text_color=color.white, bgcolor=color.new(color.maroon, 10))
    
    // Z-Score Precio
    table.cell(matrix, 0, 1, "Z-Score Precio (Desviación)", text_color=color.white)
    table.cell(matrix, 1, 1, str.tostring(z_score_price, "#.##"), text_color= z_score_price > 2.5 ? color.red : z_score_price < -2.5 ? color.lime : color.white)
    
    // Z-Score Volumen
    table.cell(matrix, 0, 2, "Z-Score Volumen", text_color=color.white)
    table.cell(matrix, 1, 2, str.tostring(z_score_vol, "#.##"), text_color= z_score_vol > 2 ? color.orange : color.white)
    
    // Sharpe Ratio
    table.cell(matrix, 0, 3, "Sharpe Ratio (Momentum)", text_color=color.white)
    table.cell(matrix, 1, 3, str.tostring(sharpe, "#.##"), text_color= sharpe > 0 ? color.lime : color.red)
    
    // Sortino Ratio
    table.cell(matrix, 0, 4, "Sortino Ratio (Riesgo Asimétrico)", text_color=color.white)
    table.cell(matrix, 1, 4, str.tostring(sortino, "#.##"), text_color= sortino > 0 ? color.lime : color.red)
    
    // Evaluación Táctica (Tu guía para decidir)
    bias = z_score_price <= -2.5 ? "ANOMALÍA BAJISTA (Ojo Long)" : z_score_price >= 2.5 ? "ANOMALÍA ALCISTA (Ojo Short)" : "DENTRO DE RANGO (Espera)"
    table.cell(matrix, 0, 5, "Contexto Estadístico", text_color=color.white)
    table.cell(matrix, 1, 5, bias, text_color=color.yellow)
````
