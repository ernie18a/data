//+------------------------------------------------------------------+
//|                                calibration indicator with zigzag |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_plots 0

//--- Paramètres ZigZag
input int    InpDepth     = 12;
input int    InpDeviation = 5;
input int    InpBackstep  = 3;

//--- Apparence
input color  InpZigzagColor = clrGold;
input int    InpZigzagWidth = 2;
input color  InpHighColor = clrRed;
input color  InpLowColor  = clrSpringGreen;
input ENUM_LINE_STYLE InpLineStyle = STYLE_SOLID;
input int    InpLineWidth = 3;

//--- Contrôle du nombre de barres à analyser
input bool   start_from_beginning = false;
input int    InpBarsToCheck = 1000;
input bool   InpShowLabels = true;
input bool   InpShowZigZag = true;

//--- Taille police étiquettes
input int    InpLabelFontSize = 12;

//--- Variables globales
int zigzag_handle;
datetime last_update_time = 0;

//--- Préfixe unique pour tous les objets
#define ZZ_PREFIX "ZZ_"

//--- Fonction utilitaire pour créer les noms
string MakeName(string base, int index1, int index2=-1)
{
   if(index2 >= 0)
      return ZZ_PREFIX + base + "_" + IntegerToString(index1) + "_" + IntegerToString(index2);
   else
      return ZZ_PREFIX + base + "_" + IntegerToString(index1);
}

//+------------------------------------------------------------------+
int OnInit()
{
   zigzag_handle = iCustom(_Symbol, _Period, "Examples\\ZigZag", InpDepth, InpDeviation, InpBackstep);
   if(zigzag_handle == INVALID_HANDLE)
   {
      Print("Erreur création ZigZag : ", GetLastError());
      return(INIT_FAILED);
   }
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(zigzag_handle != INVALID_HANDLE)
      IndicatorRelease(zigzag_handle);

   DeleteAllObjects(); // Supprime tout ce qui commence par ZZ_
}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if(rates_total < 10) return 0;
   if(TimeCurrent() == last_update_time) return rates_total;
   last_update_time = TimeCurrent();

   int bars_to_copy = start_from_beginning ? rates_total : MathMin(InpBarsToCheck, rates_total);

   DeleteAllObjects();

   double zz[];
   ArraySetAsSeries(zz, true);
   int copied = CopyBuffer(zigzag_handle, 0, 0, bars_to_copy, zz);
   if(copied <= 0) return rates_total;

   //--- Stockage des points ZigZag
   struct ZZPoint { int index; double value; };
   ZZPoint points[];
   for(int i = 0; i < copied; i++)
   {
      if(zz[i] != 0.0 && zz[i] != EMPTY_VALUE)
      {
         int sz = ArraySize(points);
         ArrayResize(points, sz + 1);
         points[sz].index = i;
         points[sz].value = zz[i];
      }
   }

   //--- Tracé du ZigZag
   if(InpShowZigZag)
   {
      for(int p = 1; p < ArraySize(points); p++)
      {
         datetime t1 = iTime(_Symbol, _Period, points[p-1].index);
         datetime t2 = iTime(_Symbol, _Period, points[p].index);
         string name = MakeName("Line", points[p-1].index, points[p].index);

         if(ObjectCreate(0, name, OBJ_TREND, 0, t1, points[p-1].value, t2, points[p].value))
         {
            ObjectSetInteger(0, name, OBJPROP_COLOR, InpZigzagColor);
            ObjectSetInteger(0, name, OBJPROP_WIDTH, InpZigzagWidth);
            ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
         }
      }
   }

   //--- Lignes verticales + étiquettes
   for(int p = 2; p < ArraySize(points)-1; p++)
   {
      bool is_high = (points[p].value > points[p-1].value);
      datetime t = iTime(_Symbol, _Period, points[p].index);

      // Ligne verticale
      string vname = MakeName("VLine", points[p].index);
      color vcolor = is_high ? InpHighColor : InpLowColor;
      if(ObjectCreate(0, vname, OBJ_VLINE, 0, t, 0))
      {
         ObjectSetInteger(0, vname, OBJPROP_COLOR, vcolor);
         ObjectSetInteger(0, vname, OBJPROP_STYLE, InpLineStyle);
         ObjectSetInteger(0, vname, OBJPROP_WIDTH, InpLineWidth);
         ObjectSetInteger(0, vname, OBJPROP_BACK, true);
      }

      // Étiquettes
      if(InpShowLabels && p > 0)
      {
         double price = points[p].value;
         double diff_points = MathAbs(price - points[p+1].value) / _Point;
         double offset_price = (is_high ? price + (10 * _Point) : price - (10 * _Point));

         datetime t_label = iTime(_Symbol, _Period, points[p].index);

         string label_name = MakeName("Label", points[p].index);
         if(ObjectCreate(0, label_name, OBJ_TEXT, 0, t_label, offset_price))
         {
            ObjectSetInteger(0, label_name, OBJPROP_FONTSIZE, InpLabelFontSize);
            ObjectSetInteger(0, label_name, OBJPROP_ANCHOR, ANCHOR_CENTER);

            // Prix en noir + symbole coloré
            string price_str = DoubleToString(price, _Digits);
            string symbol = is_high ? StringFormat(" ▲%d", (int)diff_points) : StringFormat(" ▼ %d", (int)diff_points);

            ObjectSetString(0, label_name, OBJPROP_TEXT, price_str + symbol);
            ObjectSetInteger(0, label_name, OBJPROP_COLOR, is_high ? clrSpringGreen : clrRed);
         }
      }
   }

   return rates_total;
}

//+------------------------------------------------------------------+
// Supprime tous les objets commençant par ZZ_
//+------------------------------------------------------------------+
void DeleteAllObjects()
{
   for(int i = ObjectsTotal(0) - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i);
      if(StringFind(name, ZZ_PREFIX) == 0)
         ObjectDelete(0, name);
   }
}
