//+------------------------------------------------------------------+
//|                                            RiskLotCalculator.mq5 |
//|                                   Risk-based position size script |
//+------------------------------------------------------------------+
#property copyright   "trisaussie"
#property link        "https://www.mql5.com/en/users/trisaussie"
#property version     "1.02"
#property description "Calculates the lot size so that a stop loss hit loses exactly the chosen % of your account."
#property description "Works on any symbol (forex, gold, indices, crypto). Uses OrderCalcProfit, so tick value,"
#property description "contract size and account currency are handled by the platform."
#property description "Drop it on a chart, set the inputs, read the result in the panel. Press Close to remove the panel."
#property script_show_inputs

enum ENUM_RISK_BASE
  {
   RISK_EQUITY      = 0, // Equity
   RISK_BALANCE     = 1, // Balance
   RISK_FREE_MARGIN = 2  // Free margin
  };

input double          InpRiskPercent    = 1.0;         // Risk per trade, % of the base below
input ENUM_RISK_BASE  InpRiskBase       = RISK_EQUITY; // Risk base
input bool            InpIsBuy          = true;        // Direction: true = Buy, false = Sell
input double          InpStopLossPoints = 200.0;       // Stop loss distance, in points
input double          InpRewardRatio    = 0.0;         // Take profit as a multiple of risk (0 = not shown)

#define PFX "RLC_"

//+------------------------------------------------------------------+
//| Number of decimals needed to display the volume step              |
//+------------------------------------------------------------------+
int VolumeDigits(const double step)
  {
   int d = 0;
   while(d < 8 && MathAbs(MathRound(step * MathPow(10, d)) - step * MathPow(10, d)) > 1e-7)
      d++;
   return(d);
  }

//+------------------------------------------------------------------+
//| Round the volume DOWN to the volume step and clamp to min/max     |
//+------------------------------------------------------------------+
double NormalizeVolume(const string symbol, const double volume, bool &below_min)
  {
   double vmin = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double vmax = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   if(step <= 0.0)
      step = vmin;

   double v = MathFloor(volume / step + 1e-9) * step;
   below_min = (v < vmin - 1e-12);
   if(v < vmin)
      v = vmin;
   if(v > vmax)
      v = vmax;
   return(NormalizeDouble(v, VolumeDigits(step)));
  }

//+------------------------------------------------------------------+
//| Money lost on 1.0 lot if price moves from entry to the stop       |
//+------------------------------------------------------------------+
bool LossPerLot(const string symbol, const bool is_buy, const double entry, const double sl, double &loss)
  {
   double profit = 0.0;
   ENUM_ORDER_TYPE type = is_buy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
   if(!OrderCalcProfit(type, symbol, 1.0, entry, sl, profit))
      return(false);
   loss = MathAbs(profit);
   return(loss > 0.0);
  }

//+------------------------------------------------------------------+
//| Panel drawing helpers                                             |
//+------------------------------------------------------------------+
void PutRect(const string name, const int x, const int y, const int w, const int h,
             const color bg, const color border)
  {
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_COLOR, border);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

void PutLabel(const string name, const int x, const int y, const string text, const color clr,
              const int size, const string font, const ENUM_ANCHOR_POINT anchor)
  {
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, font);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

void PutButton(const string name, const int x, const int y, const int w, const int h, const string text)
  {
   ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Segoe UI Semibold");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, C'52,60,86');
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, C'52,60,86');
   ObjectSetInteger(0, name, OBJPROP_STATE, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
  }

//+------------------------------------------------------------------+
//| Script program start function                                     |
//+------------------------------------------------------------------+
void OnStart()
  {
   string symbol = _Symbol;

   if(InpRiskPercent <= 0.0 || InpStopLossPoints <= 0.0)
     {
      Alert("RiskLotCalculator: risk % and stop loss points must be greater than 0.");
      return;
     }

   MqlTick tick;
   if(!SymbolInfoTick(symbol, tick) || tick.ask <= 0.0 || tick.bid <= 0.0)
     {
      Alert("RiskLotCalculator: no price for ", symbol, ". Open the chart and try again.");
      return;
     }

   double base_money = 0.0;
   string base_name  = "";
   switch(InpRiskBase)
     {
      case RISK_BALANCE:
         base_money = AccountInfoDouble(ACCOUNT_BALANCE);
         base_name  = "Balance";
         break;
      case RISK_FREE_MARGIN:
         base_money = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
         base_name  = "Free margin";
         break;
      default:
         base_money = AccountInfoDouble(ACCOUNT_EQUITY);
         base_name  = "Equity";
         break;
     }

   int    digits     = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double risk_money = base_money * InpRiskPercent / 100.0;
   double point      = SymbolInfoDouble(symbol, SYMBOL_POINT);
   double entry      = InpIsBuy ? tick.ask : tick.bid;
   double sl         = InpIsBuy ? entry - InpStopLossPoints * point : entry + InpStopLossPoints * point;
   sl = NormalizeDouble(sl, digits);

   double loss_per_lot = 0.0;
   if(!LossPerLot(symbol, InpIsBuy, entry, sl, loss_per_lot))
     {
      Alert("RiskLotCalculator: OrderCalcProfit failed for ", symbol, " (error ", GetLastError(), ").");
      return;
     }

   double raw_lot   = risk_money / loss_per_lot;
   bool   below_min = false;
   double lot       = NormalizeVolume(symbol, raw_lot, below_min);

   double actual_loss = loss_per_lot * lot;
   double actual_pct  = (base_money > 0.0) ? actual_loss / base_money * 100.0 : 0.0;

   double margin    = 0.0;
   bool   margin_ok = OrderCalcMargin(InpIsBuy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, symbol, lot, entry, margin);
   double free_mgn  = AccountInfoDouble(ACCOUNT_MARGIN_FREE);

   string cur     = AccountInfoString(ACCOUNT_CURRENCY);
   string lot_txt = DoubleToString(lot, VolumeDigits(SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP)));
   string dir     = InpIsBuy ? "BUY" : "SELL";
   string base_lower = base_name;
   StringToLower(base_lower);

   // ---- table rows (label / value) --------------------------------
   string lab[8], val[8];
   int    n = 0;
   lab[n] = base_name;
   val[n++] = StringFormat("%.2f %s", base_money, cur);
   lab[n] = "Risk budget";
   val[n++] = StringFormat("%.2f%% = %.2f %s", InpRiskPercent, risk_money, cur);
   lab[n] = "Entry price";
   val[n++] = DoubleToString(entry, digits);
   lab[n] = "Stop loss";
   val[n++] = DoubleToString(sl, digits) + StringFormat("  (%.0f points)", InpStopLossPoints);
   if(InpRewardRatio > 0.0)
     {
      double tp_points = InpStopLossPoints * InpRewardRatio;
      double tp = InpIsBuy ? entry + tp_points * point : entry - tp_points * point;
      lab[n] = StringFormat("Take profit (%.1fR)", InpRewardRatio);
      val[n++] = DoubleToString(NormalizeDouble(tp, digits), digits) + StringFormat("  (%.0f points)", tp_points);
     }
   if(margin_ok)
     {
      lab[n] = "Margin needed";
      val[n++] = StringFormat("%.2f %s  (free %.2f)", margin, cur, free_mgn);
     }

   // ---- warnings ---------------------------------------------------
   string warn[4];
   int    wn = 0;
   if(below_min)
     {
      warn[wn++] = StringFormat("The exact lot (%.4f) is below the broker minimum.", raw_lot);
      warn[wn++] = StringFormat("The minimum lot risks %.2f%%, more than you asked.", actual_pct);
     }
   if(margin_ok && margin > free_mgn)
      warn[wn++] = "Not enough free margin for this lot size.";

   // ---- log -------------------------------------------------------
   Print("RiskLotCalculator ", symbol, " ", dir, ": LOT SIZE ", lot_txt,
         StringFormat(", loss if stop is hit %.2f %s (%.2f%% of %s)", actual_loss, cur, actual_pct, base_name));
   for(int i = 0; i < n; i++)
      Print("  ", lab[i], ": ", val[i]);
   for(int i = 0; i < wn; i++)
      Print("  WARNING: ", warn[i]);

   // ---- panel -----------------------------------------------------
   color c_bg     = C'22,26,38';
   color c_head   = C'34,40,60';
   color c_box    = C'30,36,54';
   color c_line   = C'44,52,76';
   color c_label  = C'138,148,176';
   color c_value  = C'232,236,246';
   color c_ok     = C'46,204,113';
   color c_bad    = C'255,107,87';
   color accent   = (wn > 0) ? c_bad : c_ok;

   double s = MathMax(1.0, TerminalInfoInteger(TERMINAL_SCREEN_DPI) / 96.0);
   int x0 = (int)(24 * s), y0 = (int)(34 * s);
   int w       = (int)(480 * s);
   int pad     = (int)(18 * s);
   int head_h  = (int)(38 * s);
   int box_h   = (int)(88 * s);
   int row_h   = (int)(30 * s);
   int warn_h  = (int)(22 * s);
   int btn_h   = (int)(30 * s);
   int gap     = (int)(14 * s);

   int h = head_h + 3 + gap + box_h + gap + n * row_h;
   if(wn > 0)
      h += gap + (int)(20 * s) + wn * warn_h + (int)(14 * s);
   h += gap + btn_h + gap;

   PutRect(PFX + "bg", x0, y0, w, h, c_bg, c_line);
   PutRect(PFX + "head", x0, y0, w, head_h, c_head, c_head);
   PutLabel(PFX + "title", x0 + pad, y0 + (int)(9 * s), "RISK LOT CALCULATOR", c_label, 10, "Segoe UI Semibold", ANCHOR_LEFT_UPPER);
   PutLabel(PFX + "sym", x0 + w - pad, y0 + (int)(9 * s), symbol + "   " + dir,
            InpIsBuy ? C'96,174,255' : C'255,160,96', 10, "Segoe UI Semibold", ANCHOR_RIGHT_UPPER);
   PutRect(PFX + "accent", x0, y0 + head_h, w, 3, accent, accent);

   int y = y0 + head_h + 3 + gap;
   PutRect(PFX + "box", x0 + pad, y, w - 2 * pad, box_h, c_box, c_line);
   PutLabel(PFX + "lotcap", x0 + pad + (int)(16 * s), y + (int)(12 * s), "LOT SIZE", c_label, 9, "Segoe UI", ANCHOR_LEFT_UPPER);
   PutLabel(PFX + "lot", x0 + pad + (int)(16 * s), y + (int)(30 * s), lot_txt, accent, 26, "Segoe UI Semibold", ANCHOR_LEFT_UPPER);
   PutLabel(PFX + "losscap", x0 + w - pad - (int)(16 * s), y + (int)(12 * s), "LOSS IF STOP IS HIT", c_label, 9, "Segoe UI", ANCHOR_RIGHT_UPPER);
   PutLabel(PFX + "loss", x0 + w - pad - (int)(16 * s), y + (int)(36 * s),
            StringFormat("%.2f %s", actual_loss, cur), c_value, 15, "Segoe UI Semibold", ANCHOR_RIGHT_UPPER);
   PutLabel(PFX + "losspct", x0 + w - pad - (int)(16 * s), y + (int)(62 * s),
            StringFormat("%.2f%% of %s", actual_pct, base_lower), c_label, 9, "Segoe UI", ANCHOR_RIGHT_UPPER);
   y += box_h + gap;

   for(int i = 0; i < n; i++)
     {
      PutRect(PFX + "ln" + IntegerToString(i), x0 + pad, y, w - 2 * pad, 1, c_line, c_line);
      PutLabel(PFX + "lab" + IntegerToString(i), x0 + pad, y + (int)(7 * s), lab[i], c_label, 10, "Segoe UI", ANCHOR_LEFT_UPPER);
      PutLabel(PFX + "val" + IntegerToString(i), x0 + w - pad, y + (int)(7 * s), val[i], c_value, 10, "Segoe UI Semibold", ANCHOR_RIGHT_UPPER);
      y += row_h;
     }

   if(wn > 0)
     {
      y += gap;
      int wh = (int)(20 * s) + wn * warn_h + (int)(14 * s);
      PutRect(PFX + "wbox", x0 + pad, y, w - 2 * pad, wh, C'52,28,34', C'110,50,56');
      y += (int)(8 * s);
      PutLabel(PFX + "wcap", x0 + pad + (int)(12 * s), y, "WARNING", c_bad, 9, "Segoe UI Semibold", ANCHOR_LEFT_UPPER);
      y += (int)(20 * s);
      for(int i = 0; i < wn; i++)
        {
         PutLabel(PFX + "wt" + IntegerToString(i), x0 + pad + (int)(12 * s), y, warn[i], C'255,190,180', 10, "Segoe UI", ANCHOR_LEFT_UPPER);
         y += warn_h;
        }
      y += (int)(6 * s);
     }

   y += gap;
   string btn = PFX + "close";
   PutButton(btn, x0 + w - pad - (int)(96 * s), y, (int)(96 * s), btn_h, "Close");
   ChartRedraw();

   // keep the script alive until the Close button is pressed or the script is stopped
   while(!IsStopped() && !(bool)ObjectGetInteger(0, btn, OBJPROP_STATE))
      Sleep(100);

   ObjectsDeleteAll(0, PFX);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
