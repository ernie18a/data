<!-- tradingview-pine-id: PUB;ef141cf5920f44a7baa4678315ba21df -->
<!-- tradingviewscripts-format: 1 -->
# Ccs Traders EMA 20

Source: https://www.tradingview.com/script/i1NKsxYV/

## Description

La EMA 20 (Media Móvil Exponencial de 20 períodos) es un indicador técnico que se representa como una línea dinámica sobre el gráfico de precios. Funciona como un promedio inteligente del precio de las últimas 20 velas, dándole mayor importancia a los precios más recientes para reaccionar rápidamente a los cambios del mercado.

¿Para qué utilidad sirve en el mercado?

1. Identificar la tendencia inmediata.

Actúa como una brújula rápida para saber quién tiene el control del mercado:

Tendencia Alcista: Si las velas del precio están por encima de la EMA 20 y la línea apunta hacia arriba, el mercado tiene fuerza compradora.

Tendencia Bajista: Si las velas están por debajo de la EMA 20 y la línea apunta hacia abajo, el mercado tiene fuerza vendedora.

2. Soporte y resistencia dinámica

En mercados con tendencias fuertes, el precio suele rebotar en esta línea como si fuera un piso o un techo elástico:

En una subida, el precio suele caer a tocar la EMA 20 y vuelve a subir (funciona como soporte).
En una bajada, el precio sube a buscar la EMA 20 y vuelve a caer (funciona como resistencia).

3. Señal de entrada o salida (Gatillo) Muchos operadores la usan para tomar decisiones rápidas:
 
Compra: Cuando una vela rompe la EMA 20 de abajo hacia arriba con fuerza.
Venta: Cuando el precio cruza la línea de arriba hacia abajo, indicando debilidad.

---

## Source Code

````pine
//@version=6
indicator('Ccs Traders EMA 20', overlay = true)

// --- Configuración EMA 20 ---
ema20 = ta.ema(close, 20)
plot(ema20, color = color.blue, linewidth = 2, title = 'EMA 20')
````
