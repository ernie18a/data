//+------------------------------------------------------------------+
//|                                 SimpleBarTimer_Script.mq5        |
//+------------------------------------------------------------------+
#property copyright "Copyright phade © 2025"
#property version   "1.00"
#property script_show_inputs

int    FontSize    = 12;                 // Font size
color  TextColor   = clrLime;            // Text colour
string LabelPrefix = "BarTimer_";        // Object name prefix

//------------------------------------------------------------------+
//| helper function to convert ENUM_TIMEFRAMES to a readable string |
//------------------------------------------------------------------+
string PeriodToString(ENUM_TIMEFRAMES TF)
  {
   switch(TF)
     {
      case PERIOD_M1:  return "M1";
      case PERIOD_M2:  return "M2";
      case PERIOD_M3:  return "M3";
      case PERIOD_M4:  return "M4";
      case PERIOD_M5:  return "M5";
      case PERIOD_M6:  return "M6";
      case PERIOD_M10: return "M10";
      case PERIOD_M12: return "M12";
      case PERIOD_M15: return "M15";
      case PERIOD_M20: return "M20";
      case PERIOD_M30: return "M30";
      case PERIOD_H1:  return "H1";
      case PERIOD_H2:  return "H2";
      case PERIOD_H3:  return "H3";
      case PERIOD_H4:  return "H4";
      case PERIOD_H6:  return "H6";
      case PERIOD_H8:  return "H8";
      case PERIOD_H12: return "H12";
      case PERIOD_D1:  return "D1";
      case PERIOD_W1:  return "W1";
      case PERIOD_MN1: return "MN1";
      default:         return "Current";
     }
  }

//+------------------------------------------------------------------+
//| Script start function                                            |
//+------------------------------------------------------------------+
void OnStart()
  {
   long chart_id = ChartID();

   //--- create the label
   string obj = LabelPrefix + "Countdown";
   if(!ObjectCreate(chart_id, obj, OBJ_LABEL, 0, 0, 0))
     {
      Print("Failed to create label: ", GetLastError());
      return;
     }

   ObjectSetInteger(chart_id, obj, OBJPROP_CORNER,     CORNER_RIGHT_UPPER);
   ObjectSetInteger(chart_id, obj, OBJPROP_XDISTANCE,  380);   // 380 px from the right edge
   ObjectSetInteger(chart_id, obj, OBJPROP_YDISTANCE,  10);   // 10 px from the top edge

   ObjectSetInteger(chart_id, obj, OBJPROP_FONTSIZE,   FontSize);
   ObjectSetString (chart_id, obj, OBJPROP_FONT,       "Courier New");
   ObjectSetInteger(chart_id, obj, OBJPROP_COLOR,      TextColor);
   ObjectSetInteger(chart_id, obj, OBJPROP_SELECTABLE, false);

   while(!IsStopped())
     {
      datetime srv        = TimeCurrent();                     // server time
      int      period_sec = PeriodSeconds();                  // seconds in current TF
      datetime bar_start  = srv - (srv % period_sec);
      datetime left       = (datetime)(period_sec - (srv - bar_start));

      string txt = StringFormat("%s remaining to new %s bar",
                                TimeToString(left, TIME_SECONDS),
                                PeriodToString(Period()));

      ObjectSetString(chart_id, obj, OBJPROP_TEXT, txt);
      ChartRedraw(chart_id);
      Sleep(1000);
     }

   //--- cleanup
   ObjectDelete(chart_id, obj);
  }
