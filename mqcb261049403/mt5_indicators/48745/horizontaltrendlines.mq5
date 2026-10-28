#property copyright "Scriptong"
#property link      "scriptong@gmail.com"
#property strict

#property indicator_chart_window

input color             i_clrForColor  = clrNONE;                                                  // Lines color for correction
input ENUM_LINE_STYLE   i_eForStyle    = STYLE_SOLID;                                              // Lines type for correction


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
   return(rates_total);
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
   if (id != CHARTEVENT_OBJECT_CHANGE && id != CHARTEVENT_OBJECT_DRAG)   
      return;
      
   if (ObjectGetInteger(0, sparam, OBJPROP_TYPE) != OBJ_TREND)
      return;
      
   if (bool(ObjectGetInteger(0, sparam, OBJPROP_HIDDEN)))
      return;

   if (i_clrForColor != clrNONE && color(ObjectGetInteger(0, sparam, OBJPROP_COLOR)) != i_clrForColor)
      return;

   if (ENUM_LINE_STYLE(ObjectGetInteger(0, sparam, OBJPROP_STYLE)) != i_eForStyle)
      return;

   double fLeftPrice = ObjectGetDouble(0, sparam, OBJPROP_PRICE, 0);
   double fRightPrice = ObjectGetDouble(0, sparam, OBJPROP_PRICE, 1);
   
   if (fabs(fLeftPrice - fRightPrice) < Point() / 10)
      return;
      
   ObjectSetDouble(0, sparam, OBJPROP_PRICE, 1, fLeftPrice);
   ChartRedraw();
}

