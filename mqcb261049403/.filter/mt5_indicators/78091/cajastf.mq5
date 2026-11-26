//+------------------------------------------------------------------+
//|                                                     CajasTF.mq5  |
//|  Panel lateral (derecha del gráfico) que muestra la evolución    |
//|  de las velas de un timeframe elegido por input.                 |
//|  El panel hereda los colores del propio gráfico: fondo, rejilla, |
//|  texto, velas alcistas/bajistas, doji y línea Bid.               |
//+------------------------------------------------------------------+
#property copyright   "CajasTF"
#property version     "1.00"
#property description "Panel lateral con las velas de otro timeframe, usando los colores del gráfico."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- Inputs
input group "Timeframe"
input ENUM_TIMEFRAMES InpTF            = PERIOD_M1;  // Timeframe del panel
input int             InpBars          = 30;         // Número de velas a mostrar
input group "Panel"
input int             InpPanelWidth    = 260;        // Ancho del panel (px)
input int             InpMargin        = 6;          // Margen respecto al borde (px)
input double          InpBodyRatio     = 0.70;       // Ancho del cuerpo respecto al hueco (0.3 - 0.9)
input bool            InpAutoShift     = true;       // Desplazar el gráfico para que el panel no tape velas
input bool            InpShowPriceLine = true;       // Mostrar línea de precio actual
input bool            InpShowInfo      = true;       // Mostrar OHLC de la vela en curso
input int             InpFontSize      = 8;          // Tamaño de fuente

//--- Constantes
#define PFX "CajasTF_"

//--- Colores heredados del gráfico
color g_bg, g_fg, g_grid, g_bullFill, g_bearFill, g_up, g_down, g_doji, g_bid;
bool  g_showGrid = true;

//--- Estado
ENUM_TIMEFRAMES g_tf;
int    g_bars;
int    g_maxCreated   = 0;
uint   g_lastDrawMs   = 0;
bool   g_origShift    = false;
double g_origShiftSz  = 0.0;

//--- Geometría del área de velas
int    g_ay = 0, g_ah = 1;
double g_hi = 0.0, g_lo = 0.0;

//+------------------------------------------------------------------+
int OnInit() {
   g_tf   = (InpTF == PERIOD_CURRENT) ? (ENUM_TIMEFRAMES)_Period : InpTF;
   g_bars = MathMax(5, MathMin(300, InpBars));

   g_origShift   = (bool)ChartGetInteger(0, CHART_SHIFT);
   g_origShiftSz = ChartGetDouble(0, CHART_SHIFT_SIZE);

   IndicatorSetString(INDICATOR_SHORTNAME, "CajasTF(" + TFName(g_tf) + ")");

   ApplyShift();
   EventSetTimer(1);
   DrawPanel();
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   EventKillTimer();
   ObjectsDeleteAll(0, PFX);
   if(InpAutoShift) {
      ChartSetInteger(0, CHART_SHIFT, g_origShift);
      ChartSetDouble(0, CHART_SHIFT_SIZE, g_origShiftSz);
   }
   ChartRedraw();
}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
                const datetime &time[], const double &open[],
                const double &high[], const double &low[],
                const double &close[], const long &tick_volume[],
                const long &volume[], const int &spread[]) {
   //--- Throttle: como máximo un redibujado cada 200 ms
   uint now = GetTickCount();
   if(prev_calculated == 0 || now - g_lastDrawMs > 200) {
      DrawPanel();
   }
   return rates_total;
}

//+------------------------------------------------------------------+
void OnTimer() {
   //--- Mantiene la cuenta atrás viva aunque no lleguen ticks
   DrawPanel();
}

//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   //--- Redimensionado, zoom o cambio de colores del gráfico
   if(id == CHARTEVENT_CHART_CHANGE) {
      ApplyShift();
      DrawPanel();
   }
}

//+------------------------------------------------------------------+
//| Lee los colores actuales del gráfico                             |
//+------------------------------------------------------------------+
void ReadChartColors() {
   g_bg       = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   g_fg       = (color)ChartGetInteger(0, CHART_COLOR_FOREGROUND);
   g_grid     = (color)ChartGetInteger(0, CHART_COLOR_GRID);
   g_grid     = clrRed;
   g_bullFill = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BULL);
   g_bearFill = (color)ChartGetInteger(0, CHART_COLOR_CANDLE_BEAR);
   g_up       = (color)ChartGetInteger(0, CHART_COLOR_CHART_UP);
   g_down     = (color)ChartGetInteger(0, CHART_COLOR_CHART_DOWN);
   g_doji     = (color)ChartGetInteger(0, CHART_COLOR_CHART_LINE);
   g_bid      = (color)ChartGetInteger(0, CHART_COLOR_BID);
   g_showGrid = (bool)ChartGetInteger(0, CHART_SHOW_GRID);
}

//+------------------------------------------------------------------+
//| Reserva espacio a la derecha para que el panel no tape velas     |
//+------------------------------------------------------------------+
void ApplyShift() {
   if(!InpAutoShift) {
      return;
   }
   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   if(chartW <= 0) {
      return;
   }

   double pct = 100.0 * (InpPanelWidth + 2 * InpMargin + 10) / chartW;
   pct = MathMax(10.0, MathMin(50.0, MathCeil(pct)));   // MT5 admite 10% - 50%

   //--- Solo se escribe si cambia, para no provocar bucles de CHART_CHANGE
   if(!(bool)ChartGetInteger(0, CHART_SHIFT)) {
      ChartSetInteger(0, CHART_SHIFT, true);
   }
   if(MathAbs(ChartGetDouble(0, CHART_SHIFT_SIZE) - pct) > 0.5) {
      ChartSetDouble(0, CHART_SHIFT_SIZE, pct);
   }
}

//+------------------------------------------------------------------+
//| Dibujo principal del panel                                       |
//+------------------------------------------------------------------+
void DrawPanel() {
   g_lastDrawMs = GetTickCount();
   ReadChartColors();

   int chartW = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   int chartH = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);
   if(chartW <= 0 || chartH <= 0) {
      return;
   }

   int pw = MathMin(InpPanelWidth, chartW - 2 * InpMargin);
   int ph = chartH - 2 * InpMargin;
   if(pw < 100 || ph < 100) {
      return;
   }
   int px = chartW - pw - InpMargin;
   int py = InpMargin;

   //--- Distribución interna
   int lineH   = InpFontSize + 7;
   int headerH = lineH + 8;
   int footerH = InpShowInfo ? lineH * 2 + 10 : 6;
   int scaleW  = InpFontSize * 8;                 // columna de precios
   int ax      = px + 6;
   int aw      = pw - 12 - scaleW;
   g_ay        = py + headerH + 4;
   g_ah        = ph - headerH - footerH - 8;
   if(aw < 30 || g_ah < 30) {
      return;
   }

   //--- Fondo del panel: mismo color que el gráfico, borde con el color de rejilla
   RectLabel(PFX + "bg", px, py, pw, ph, g_bg, g_grid);

   //--- Cabecera
   TextLabel(PFX + "title", px + 8, py + 5, _Symbol + "  ·  " + TFName(g_tf), g_fg, ANCHOR_LEFT_UPPER);
   RectLabel(PFX + "sepTop", px + 1, py + headerH, pw - 2, 1, g_grid, g_grid);

   //--- Datos del timeframe seleccionado
   MqlRates r[];
   int n = CopyRates(_Symbol, g_tf, 0, g_bars, r);
   if(n <= 0) {
      TextLabel(PFX + "msg", px + pw / 2, py + ph / 2, "Cargando datos " + TFName(g_tf) + "...", g_fg, ANCHOR_CENTER);
      HideCandlesFrom(0);
      ChartRedraw();
      return;
   }
   HideObj(PFX + "msg");

   //--- Rango de precios visible (+5% de margen)
   g_hi = r[0].high;
   g_lo = r[0].low;
   for(int i = 1; i < n; i++) {
      g_hi = MathMax(g_hi, r[i].high);
      g_lo = MathMin(g_lo, r[i].low);
   }
   double range = g_hi - g_lo;
   if(range <= 0) {
      range = _Point * 10;
   }
   g_hi += range * 0.05;
   g_lo -= range * 0.05;

   //--- Rejilla y escala de precios (5 niveles)
   for(int k = 0; k <= 4; k++) {
      double p = g_hi - (g_hi - g_lo) * k / 4.0;
      int    y = PriceToY(p);
      if(g_showGrid) {
         RectLabel(PFX + "g" + IntegerToString(k), ax, y, aw, 1, g_grid, g_grid);
      } else {
         HideObj(PFX + "g" + IntegerToString(k));
      }
      TextLabel(PFX + "gT" + IntegerToString(k), ax + aw + 6, y, DoubleToString(p, _Digits), g_fg, ANCHOR_LEFT);
   }

   //--- Velas (alineadas a la derecha, la última es la vela en formación)
   double slot  = (double)aw / g_bars;
   int    bodyW = (int)MathMax(1.0, MathFloor(slot * MathMax(0.3, MathMin(0.9, InpBodyRatio))));
   if(bodyW > 2 && bodyW % 2 == 0) {
      bodyW--;                                    // impar para centrar la mecha
   }
   int offset = g_bars - n;

   for(int i = 0; i < n; i++) {
      int cx = ax + (int)MathRound((offset + i + 0.5) * slot);
      int yH = PriceToY(r[i].high);
      int yL = PriceToY(r[i].low);
      int yO = PriceToY(r[i].open);
      int yC = PriceToY(r[i].close);

      color fill, line;
      if(r[i].close > r[i].open) {
         fill = g_bullFill;
         line = g_up;
      } else if(r[i].close < r[i].open) {
         fill = g_bearFill;
         line = g_down;
      } else {
         fill = g_doji;
         line = g_doji;
      }

      string id = IntegerToString(i);
      RectLabel(PFX + "w" + id, cx, yH, 1, MathMax(1, yL - yH), line, line);
      RectLabel(PFX + "b" + id, cx - bodyW / 2, MathMin(yO, yC), bodyW, MathMax(1, MathAbs(yO - yC)), fill, line);
   }
   HideCandlesFrom(n);
   g_maxCreated = MathMax(g_maxCreated, n);

   //--- Línea y etiqueta de precio actual
   double last = r[n - 1].close;
   if(InpShowPriceLine) {
      int y = PriceToY(last);
      RectLabel(PFX + "pl",  ax, y, aw, 1, g_bid, g_bid);
      RectLabel(PFX + "plB", ax + aw + 2, y - lineH / 2, scaleW - 2, lineH, g_bid, g_bid);
      TextLabel(PFX + "plT", ax + aw + 6, y, DoubleToString(last, _Digits), g_bg, ANCHOR_LEFT);
   } else {
      HideObj(PFX + "pl");
      HideObj(PFX + "plB");
      HideObj(PFX + "plT");
   }

   //--- Cuenta atrás para el cierre de la vela en curso
   long secs = (long)(r[n - 1].time + PeriodSeconds(g_tf)) - (long)TimeTradeServer();
   TextLabel(PFX + "cd", px + pw - 8, py + 5, Countdown(secs), g_fg, ANCHOR_RIGHT_UPPER);

   //--- Pie: OHLC de la vela en formación y variación
   if(InpShowInfo) {
      int fy = py + ph - footerH;
      RectLabel(PFX + "sepBot", px + 1, fy, pw - 2, 1, g_grid, g_grid);
      MqlRates c = r[n - 1];
      double chg = (c.open != 0.0) ? (c.close - c.open) / c.open * 100.0 : 0.0;
      color  chgClr = (chg > 0) ? g_up : (chg < 0 ? g_down : g_fg);
      TextLabel(PFX + "i1", px + 8, fy + 5,
                "O " + DoubleToString(c.open, _Digits) + "   H " + DoubleToString(c.high, _Digits), g_fg, ANCHOR_LEFT_UPPER);
      TextLabel(PFX + "i2", px + 8, fy + 5 + lineH,
                "L " + DoubleToString(c.low, _Digits) + "   C " + DoubleToString(c.close, _Digits), g_fg, ANCHOR_LEFT_UPPER);
      TextLabel(PFX + "i3", px + pw - 8, fy + 5 + lineH,
                (chg >= 0 ? "+" : "") + DoubleToString(chg, 2) + "%", chgClr, ANCHOR_RIGHT_UPPER);
   } else {
      HideObj(PFX + "sepBot");
      HideObj(PFX + "i1");
      HideObj(PFX + "i2");
      HideObj(PFX + "i3");
   }

   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Utilidades                                                       |
//+------------------------------------------------------------------+
int PriceToY(double price) {
   double span = g_hi - g_lo;
   if(span <= 0) {
      return g_ay;
   }
   return g_ay + (int)MathRound((g_hi - price) / span * (g_ah - 1));
}

//+------------------------------------------------------------------+
void HideCandlesFrom(int from) {
   for(int i = from; i < g_maxCreated; i++) {
      HideObj(PFX + "w" + IntegerToString(i));
      HideObj(PFX + "b" + IntegerToString(i));
   }
}

//+------------------------------------------------------------------+
void RectLabel(string name, int x, int y, int w, int h, color bg, color border) {
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, MathMax(1, w));
   ObjectSetInteger(0, name, OBJPROP_YSIZE, MathMax(1, h));
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_COLOR, border);
   ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
}

//+------------------------------------------------------------------+
void TextLabel(string name, int x, int y, string text, color clr, ENUM_ANCHOR_POINT anchor) {
   if(ObjectFind(0, name) < 0) {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   }
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, InpFontSize);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
}

//+------------------------------------------------------------------+
void HideObj(string name) {
   if(ObjectFind(0, name) >= 0) {
      ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   }
}

//+------------------------------------------------------------------+
string TFName(ENUM_TIMEFRAMES tf) {
   return StringSubstr(EnumToString(tf), 7);   // "PERIOD_H1" -> "H1"
}

//+------------------------------------------------------------------+
string Countdown(long secs) {
   if(secs < 0) {
      secs = 0;
   }
   long d = secs / 86400;
   long h = (secs % 86400) / 3600;
   long m = (secs % 3600) / 60;
   long s = secs % 60;
   string t = StringFormat("%02d:%02d:%02d", h, m, s);
   return (d > 0) ? IntegerToString(d) + "d " + t : t;
}
//+------------------------------------------------------------------+
