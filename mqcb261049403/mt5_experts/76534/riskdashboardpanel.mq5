//+------------------------------------------------------------------+
//|                                        RiskDashboardPanel.mq5    |
//|                                                Copyright jojoalb |
//+------------------------------------------------------------------+
#property copyright "jojoalb"
#property link      ""
#property version   "1.00"
#property description "Interactive On-Chart Risk Management & Execution GUI Panel"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>

//--- Parámetros de Entrada
input group "=== Risk Management ==="
input double InpRiskPercent      = 1.0;     // Riesgo por Operación (% Equidad)
input double InpDefaultSLPips    = 20.0;    // Stop Loss por Defecto (Pips)
input double InpDefaultTPPips    = 40.0;    // Take Profit por Defecto (Pips)

input group "=== Automation Logic ==="
input bool   InpUseBreakEven     = true;    // Activar BreakEven Automático
input double InpBETriggerPips    = 15.0;    // Pips a Favor para Mover a BE
input bool   InpUseTrailing      = true;    // Activar Trailing Stop
input double InpTrailingStopPips = 20.0;    // Distancia Trailing Stop (Pips)
input double InpTrailingStepPips = 5.0;     // Paso de Trailing (Pips)

input group "=== Panel Settings ==="
input int    InpPanelX           = 20;      // Posición X en Gráfico
input int    InpPanelY           = 40;      // Posición Y en Gráfico
input ulong  InpMagicNumber      = 882026;  // Magic Number

#define PANEL_PREFIX "RDB_GUI_"

//--- Variables Globales
CTrade        g_trade;
CPositionInfo g_position;

//+------------------------------------------------------------------+
//| Helper para crear botones de interfaz                            |
//+------------------------------------------------------------------+
void CreateButton(string name, string text, int x, int y, int w, int h, color bg_color, color text_color)
  {
   string obj_name = PANEL_PREFIX + name;
   ObjectCreate(0, obj_name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, obj_name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, obj_name, OBJPROP_YSIZE, h);
   ObjectSetString(0, obj_name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, text_color);
   ObjectSetInteger(0, obj_name, OBJPROP_BGCOLOR, bg_color);
   ObjectSetInteger(0, obj_name, OBJPROP_BORDER_COLOR, clrBlack);
   ObjectSetInteger(0, obj_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, obj_name, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
  }

//+------------------------------------------------------------------+
//| Helper para crear etiquetas informativas                         |
//+------------------------------------------------------------------+
void CreateLabel(string name, string text, int x, int y, color text_color)
  {
   string obj_name = PANEL_PREFIX + name;
   ObjectCreate(0, obj_name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, obj_name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, text_color);
   ObjectSetInteger(0, obj_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, obj_name, OBJPROP_FONT, "Arial");
  }

//+------------------------------------------------------------------+
//| Construcción del Panel GUI                                       |
//+------------------------------------------------------------------+
void BuildDashboardGUI()
  {
   int width = 180;
   int height = 190;
   
   // Fondo del Panel
   string bg_name = PANEL_PREFIX + "BG";
   ObjectCreate(0, bg_name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bg_name, OBJPROP_XDISTANCE, InpPanelX);
   ObjectSetInteger(0, bg_name, OBJPROP_YDISTANCE, InpPanelY);
   ObjectSetInteger(0, bg_name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, bg_name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, bg_name, OBJPROP_BGCOLOR, C'25,28,36');
   ObjectSetInteger(0, bg_name, OBJPROP_BORDER_COLOR, C'50,55,65');
   ObjectSetInteger(0, bg_name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   
   // Encabezado
   CreateLabel("HEADER", "QUANT RISK PANEL", InpPanelX + 22, InpPanelY + 10, clrGold);
   
   // Botones Principales
   CreateButton("BUY", "BUY", InpPanelX + 10, InpPanelY + 35, 75, 30, clrForestGreen, clrWhite);
   CreateButton("SELL", "SELL", InpPanelX + 95, InpPanelY + 35, 75, 30, clrFireBrick, clrWhite);
   
   CreateButton("CLOSE_ALL", "CLOSE ALL", InpPanelX + 10, InpPanelY + 75, 160, 25, C'70,70,70', clrWhite);
   CreateButton("BE", "SET BREAKEVEN", InpPanelX + 10, InpPanelY + 105, 160, 25, C'40,80,120', clrWhite);
   
   // Información Dinámica de Lotes
   CreateLabel("INFO_RISK", "Riesgo: " + DoubleToString(InpRiskPercent, 1) + "%", InpPanelX + 15, InpPanelY + 140, clrLightGray);
   CreateLabel("INFO_LOT", "Lote Calc: 0.00", InpPanelX + 15, InpPanelY + 160, clrCyan);
   
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Eliminar GUI de pantalla                                         |
//+------------------------------------------------------------------+
void DestroyDashboardGUI()
  {
   ObjectsDeleteAll(0, PANEL_PREFIX);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Cálculo Cuantitativo de Lote por Riesgo Exacto                   |
//+------------------------------------------------------------------+
double CalculateLotSize(double sl_pips)
  {
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double risk_money = equity * (InpRiskPercent / 100.0);
   
   double tick_size  = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double point      = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   if(tick_size <= 0 || tick_value <= 0 || point <= 0 || sl_pips <= 0) 
      return SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      
   double sl_points = sl_pips * 10.0;
   double sl_dist   = sl_points * point;
   
   double lot = risk_money / ((sl_dist / tick_size) * tick_value);
   
   double min_lot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   lot = MathFloor(lot / step_lot) * step_lot;
   if(lot < min_lot) lot = min_lot;
   if(lot > max_lot) lot = max_lot;
   
   return lot;
  }

//+------------------------------------------------------------------+
//| Actualizar info de lote en pantalla                              |
//+------------------------------------------------------------------+
void UpdateLotDisplay()
  {
   double lot = CalculateLotSize(InpDefaultSLPips);
   ObjectSetString(0, PANEL_PREFIX + "INFO_LOT", OBJPROP_TEXT, "Lote Calc: " + DoubleToString(lot, 2));
  }

//+------------------------------------------------------------------+
//| Funciones de Ejecución                                           |
//+------------------------------------------------------------------+
void ExecuteOrder(ENUM_ORDER_TYPE type)
  {
   double lot = CalculateLotSize(InpDefaultSLPips);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   if(type == ORDER_TYPE_BUY)
     {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double sl = NormalizeDouble(ask - (InpDefaultSLPips * 10.0 * point), _Digits);
      double tp = NormalizeDouble(ask + (InpDefaultTPPips * 10.0 * point), _Digits);
      g_trade.Buy(lot, _Symbol, ask, sl, tp, "GUI_Buy");
     }
   else if(type == ORDER_TYPE_SELL)
     {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double sl = NormalizeDouble(bid + (InpDefaultSLPips * 10.0 * point), _Digits);
      double tp = NormalizeDouble(bid - (InpDefaultTPPips * 10.0 * point), _Digits);
      g_trade.Sell(lot, _Symbol, bid, sl, tp, "GUI_Sell");
     }
  }

void CloseAllPositions()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(g_position.SelectByIndex(i))
        {
         if(g_position.Symbol() == _Symbol && g_position.Magic() == InpMagicNumber)
            g_trade.PositionClose(g_position.Ticket());
        }
     }
  }

void ApplyBreakEven()
  {
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(g_position.SelectByIndex(i))
        {
         if(g_position.Symbol() == _Symbol && g_position.Magic() == InpMagicNumber)
           {
            double open_price = g_position.PriceOpen();
            if(g_position.PositionType() == POSITION_TYPE_BUY)
              {
               if(g_position.PriceCurrent() - open_price > 0)
                  g_trade.PositionModify(g_position.Ticket(), open_price, g_position.TakeProfit());
              }
            else if(g_position.PositionType() == POSITION_TYPE_SELL)
              {
               if(open_price - g_position.PriceCurrent() > 0)
                  g_trade.PositionModify(g_position.Ticket(), open_price, g_position.TakeProfit());
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Gestión de Eventos de Ratón (Clicks en Botones)                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam == PANEL_PREFIX + "BUY")
        {
         ExecuteOrder(ORDER_TYPE_BUY);
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
        }
      else if(sparam == PANEL_PREFIX + "SELL")
        {
         ExecuteOrder(ORDER_TYPE_SELL);
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
        }
      else if(sparam == PANEL_PREFIX + "CLOSE_ALL")
        {
         CloseAllPositions();
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
        }
      else if(sparam == PANEL_PREFIX + "BE")
        {
         ApplyBreakEven();
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
        }
     }
  }

//+------------------------------------------------------------------+
//| Inicialización                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   BuildDashboardGUI();
   UpdateLotDisplay();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   DestroyDashboardGUI();
  }

//+------------------------------------------------------------------+
//| OnTick - Trailing Stop & BE Automático                           |
//+------------------------------------------------------------------+
void OnTick()
  {
   UpdateLotDisplay();
   
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(g_position.SelectByIndex(i))
        {
         if(g_position.Symbol() == _Symbol && g_position.Magic() == InpMagicNumber)
           {
            double open_price = g_position.PriceOpen();
            double current_sl = g_position.StopLoss();
            
            // Lógica de Trailing Stop
            if(InpUseTrailing)
              {
               double trailing_dist = InpTrailingStopPips * 10.0 * point;
               double trailing_step = InpTrailingStepPips * 10.0 * point;
               
               if(g_position.PositionType() == POSITION_TYPE_BUY)
                 {
                  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
                  if(ask - open_price > trailing_dist)
                    {
                     if(current_sl < ask - trailing_dist - trailing_step)
                        g_trade.PositionModify(g_position.Ticket(), NormalizeDouble(ask - trailing_dist, _Digits), g_position.TakeProfit());
                    }
                 }
               else if(g_position.PositionType() == POSITION_TYPE_SELL)
                 {
                  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
                  if(open_price - bid > trailing_dist)
                    {
                     if(current_sl > bid + trailing_dist + trailing_step || current_sl == 0)
                        g_trade.PositionModify(g_position.Ticket(), NormalizeDouble(bid + trailing_dist, _Digits), g_position.TakeProfit());
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
