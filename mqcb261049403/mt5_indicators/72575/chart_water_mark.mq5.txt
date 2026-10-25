//+------------------------------------------------------------------+
//|                                               Water Mark Pro.mq5 |
//|                                Copyright @ 2025, TradingLabs ID. |
//|                           https://www.tiktok.com/@cakndutproject |
//+------------------------------------------------------------------+
#property copyright "Copyright @ 2025, TradingLabs ID."
#property link      "https://www.tiktok.com/@cakndutproject"
#property version   "1.0" 
#property description "Indicator to display a text watermark on the chart"
#property indicator_chart_window
#property indicator_plots 0

//--- Declare helper functions so they can be called from anywhere
string PeriodToString(ENUM_TIMEFRAMES period);
void DeleteObjectsByPrefix(const string prefix);

//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input bool             ShowPairandTimeframe = true;        // Show Pair & Timeframe?
input ENUM_BASE_CORNER paircorner           = CORNER_LEFT_LOWER; // Corner Position
input color            pairtextcolor        = clrGray;           // Text Color
input string           pairfont             = "Eras Bold ITC";   // Font Type
input int              pairtextsize         = 29;                // Font Size
input int              sumbupair_X          = 20;                // X Distance
input int              sumbupair_Y          = 69;                // Y Distance

//--- Settings for Text Label 1 ---
input string           TextLabel1           = "TradingLabs ID";  // Label 1 Text
input ENUM_BASE_CORNER corner1              = CORNER_LEFT_LOWER; // Corner Position
input color            textcolor1           = clrLightGray;      // Text Color
input string           font1                = "Verdana";         // Font Type
input int              textsize1            = 13;                // Font Size
input int              sumbuX1              = 21;                // X Distance
input int              sumbuY1              = 85;                // Y Distance

//--- Settings for Text Label 2 ---
input string           TextLabel2           = "Smart Money Concept Charting Tools"; // Label 2 Text
input ENUM_BASE_CORNER corner2              = CORNER_LEFT_LOWER; // Corner Position
input color            textcolor2           = clrBlack;          // Text Color
input string           font2                = "Ink Free";        // Font Type
input int              textsize2            = 12;                // Font Size
input int              sumbuX2              = 20;                // X Distance
input int              sumbuY2              = 28;                // Y Distance

//--- Unique names for label objects
string pairLabelName = "Watermark_PairTF_";
string label1Name = "Watermark_Label1_";
string label2Name = "Watermark_Label2_";

//+------------------------------------------------------------------+
//| Indicator Initialization Function                                |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Call our custom cleaner function
   DeleteObjectsByPrefix(pairLabelName);
   DeleteObjectsByPrefix(label1Name);
   DeleteObjectsByPrefix(label2Name);

//--- Add unique chart ID to prevent conflicts
   long chartID = ChartID();
   pairLabelName = pairLabelName + (string)chartID;
   label1Name = label1Name + (string)chartID;
   label2Name = label2Name + (string)chartID;

//--- Create Pair & Timeframe Label
   if(ShowPairandTimeframe)
     {
      ObjectCreate(0, pairLabelName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, pairLabelName, OBJPROP_CORNER, paircorner);
      ObjectSetInteger(0, pairLabelName, OBJPROP_XDISTANCE, sumbupair_X);
      ObjectSetInteger(0, pairLabelName, OBJPROP_YDISTANCE, sumbupair_Y);
      ObjectSetInteger(0, pairLabelName, OBJPROP_FONTSIZE, pairtextsize);
      ObjectSetString(0, pairLabelName, OBJPROP_FONT, pairfont);
      ObjectSetInteger(0, pairLabelName, OBJPROP_COLOR, pairtextcolor);
      string pairText = _Symbol + ", " + PeriodToString(_Period);
      ObjectSetString(0, pairLabelName, OBJPROP_TEXT, pairText);
     }

//--- Create Text Label 1
   if(TextLabel1 != "")
     {
      ObjectCreate(0, label1Name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, label1Name, OBJPROP_CORNER, corner1);
      ObjectSetInteger(0, label1Name, OBJPROP_XDISTANCE, sumbuX1);
      ObjectSetInteger(0, label1Name, OBJPROP_YDISTANCE, sumbuY1);
      ObjectSetInteger(0, label1Name, OBJPROP_FONTSIZE, textsize1);
      ObjectSetString(0, label1Name, OBJPROP_FONT, font1);
      ObjectSetInteger(0, label1Name, OBJPROP_COLOR, textcolor1);
      ObjectSetString(0, label1Name, OBJPROP_TEXT, TextLabel1);
     }

//--- Create Text Label 2
   if(TextLabel2 != "")
     {
      ObjectCreate(0, label2Name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, label2Name, OBJPROP_CORNER, corner2);
      ObjectSetInteger(0, label2Name, OBJPROP_XDISTANCE, sumbuX2);
      ObjectSetInteger(0, label2Name, OBJPROP_YDISTANCE, sumbuY2);
      ObjectSetInteger(0, label2Name, OBJPROP_FONTSIZE, textsize2);
      ObjectSetString(0, label2Name, OBJPROP_FONT, font2);
      ObjectSetInteger(0, label2Name, OBJPROP_COLOR, textcolor2);
      ObjectSetString(0, label2Name, OBJPROP_TEXT, TextLabel2);
     }

   ChartRedraw();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Indicator Deinitialization Function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Delete all label objects when the indicator is closed.
   ObjectDelete(0, pairLabelName);
   ObjectDelete(0, label1Name);
   ObjectDelete(0, label2Name);
   
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//| Indicator Calculation Function                                   |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- Update text label if timeframe changes
   if(ShowPairandTimeframe && ObjectFind(0, pairLabelName) != -1)
     {
      string pairText = _Symbol + ", " + PeriodToString(_Period);
      ObjectSetString(0, pairLabelName, OBJPROP_TEXT, pairText);
     }
   return(rates_total);
  }
  
//+------------------------------------------------------------------+
//| Helper function to convert period to string                      |
//+------------------------------------------------------------------+
string PeriodToString(ENUM_TIMEFRAMES period)
  {
   switch(period)
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
      case PERIOD_MN1: return "MN";
      default:         return "XXX";
     }
  }

//+------------------------------------------------------------------+
//|  Function to clean up objects by prefix                          |
//+------------------------------------------------------------------+
void DeleteObjectsByPrefix(const string prefix)
  {
//--- Loop backwards to delete objects safely
   for(int i = (int)ObjectsTotal(0, -1, OBJ_LABEL) - 1; i >= 0; i--)
     {
      //--- Get object name at index i
      string objectName = ObjectName(0, i, -1, OBJ_LABEL);
      
      //---  Check if the object name length is sufficient
      if(StringLen(objectName) >= StringLen(prefix))
        {
         //---  Get the prefix of the object name and compare
         if(StringSubstr(objectName, 0, StringLen(prefix)) == prefix)
           {
            //--- Delete object if the name matches
            ObjectDelete(0, objectName);
           }
        }
     }
  }
//+------------------------------------------------------------------+