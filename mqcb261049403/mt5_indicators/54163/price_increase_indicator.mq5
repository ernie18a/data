//+------------------------------------------------------------------+
//|                                     Price increase Indicator.mq5 |
//|                                     Copyright 2024, Igor Widiger |
//|                                                     info@p24m.eu |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Igor Widiger"
#property link      "info@p24m.eu"
#property version   "3.00"
#property indicator_chart_window
#property indicator_plots 1
#property indicator_buffers 1

input int      RangeShowDays         = 10;                      // Range show in days
input int      RangeLineWidht        = 2;                       // Range line width
input color    RangeLineHighColor    = clrDodgerBlue;                // Range High color
input color    RangeLineLowColor     = clrOrangeRed;                  // Range Low color
input string   Text_font_name        = "Trebuchet MS";          // Range text Windows Fonts
input int      TextSize              = 10;                      // Range text size
input const ENUM_LINE_STYLE style_line  = STYLE_SOLID;          // Range Line style

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping

//---
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator delete function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

   ObjectsDeleteAll(0,"HIGH_LINIE_");   // Close Object HIGH_LINIE_
   ObjectsDeleteAll(0,"LOW_LINIE_");    // Close Object LOW_LINIE_
   ObjectsDeleteAll(0,"TEXT_");         // Close Object TEXT_
   ObjectsDeleteAll(0,"TEXT_PROCENT_"); // TEXT_PROCENT_

}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
                const int &spread[]) {
//---

// Range Show line

   for(int i = 0; i < RangeShowDays; i++) {

      double DayHigh       = iHigh(NULL,PERIOD_D1,i);                                   // Day High Period
      double DayLow        = iLow(NULL,PERIOD_D1,i);                                    // Day Low Period
      double DaySpanne     = NormalizeDouble((DayHigh - DayLow)/_Point,_Digits);        // Calculate day span in points
      double SpanneProzent = NormalizeDouble(((DayHigh - DayLow) / DayHigh * 100),2);   // Calculate day span in procent

      double DayCloseI      = iClose(NULL,PERIOD_D1,i+1);                               // Day Close Period
      double DayClose0      = iClose(NULL,PERIOD_D1,i);                                 // Day Open Period
      double PCalculate;

      PCalculate    = NormalizeDouble(((DayClose0 - DayCloseI) /DayClose0 * 100),2);    // Calculate Price change in procent

      int prexix = i;                                                                   // Prexix

      datetime time_start  = iTime(_Symbol,PERIOD_D1,i);                                // Timestart
      datetime time_end    =   iTime(_Symbol,PERIOD_D1,i)+60*60*24;                     // Time end

      if(DayClose0 > 0) {                                                               // If Day close > 0, positiv Day. False, negativ Day
         //+++++++++++++++ Show text on the Chart ++++++++++++++++++++++++++++++++++//

         TEXT_SHOW("TEXT_PROCENT_"+(string)prexix,
                   "Price change: => "+DoubleToString(PCalculate,2)+" % ",
                   time_end,
                   DayLow,
                   DoubleToString(PCalculate,2)>(string)0?RangeLineHighColor:RangeLineLowColor);

         //+++++++++++++++ Show text on the Chart ++++++++++++++++++++++++++++++++++//
      }

      //+++++++++++++++ Show text on the Chart ++++++++++++++++++++++++++++++++++//
      LINIE_SHOW("HIGH_LINIE_"+(string)prexix,
                 time_start,
                 DayHigh,
                 time_end,
                 DayHigh,
                 RangeLineHighColor);

      //+++++++++++++++ Show text on the Chart ++++++++++++++++++++++++++++++++++//

      LINIE_SHOW("LOW_LINIE_"+(string)prexix,
                 time_start,
                 DayLow,
                 time_end,
                 DayLow,
                 RangeLineLowColor);

      //+++++++++++++++ Show text on the Chart ++++++++++++++++++++++++++++++++++//

      TEXT_SHOW("TEXT_"+(string)prexix,
                "Daily range: => "+DoubleToString(SpanneProzent,2)+" % ",
                time_end,
                DayHigh,
                RangeLineHighColor);

      ChartRedraw(0);

   }


//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//Show Line
void LINIE_SHOW(string NAME, datetime TIME1, double PRICE1, datetime TIME2, double PRICE2, color COLOR) {

   bool back = true;                                                     // Display in foreground (false) or background (true)
   const bool            ray_left=false;                                 // Continuation of the line to the left
   const bool            ray_right=false;                                // Continuation of the line to the right

   ObjectDelete(ChartID(),NAME);                                         // Name of the object
   ObjectCreate(ChartID(),NAME,OBJ_TREND,0,TIME1,PRICE1,TIME2,PRICE2);   // Create a trend line at specified coordinates
   ObjectSetInteger(ChartID(),NAME,OBJPROP_COLOR,COLOR);                 // Set the color of the line
   ObjectSetInteger(ChartID(),NAME,OBJPROP_WIDTH,RangeLineWidht);        // Set line width
   ObjectSetInteger(ChartID(),NAME,OBJPROP_SELECTABLE,false);            // true, which allows you to select and move the object
   ObjectSetInteger(ChartID(),NAME,OBJPROP_SELECTED,false);              // true, which allows you to select and move the object
   ObjectSetInteger(ChartID(),NAME,OBJPROP_STYLE,style_line);            // Set line style
   ObjectSetInteger(ChartID(),NAME,OBJPROP_RAY_RIGHT,ray_right);         // ^
   ObjectSetInteger(ChartID(),NAME,OBJPROP_RAY_LEFT,ray_left);           // ^
   ObjectSetInteger(ChartID(),NAME,OBJPROP_BACK,back);                   // ^
}

// Show TExt
void TEXT_SHOW(string TEXTNAME, string TEXT, datetime TIME1, double PRICE, color COLOR) {

   const ENUM_ANCHOR_POINT anchor=ANCHOR_RIGHT_LOWER;                          // binding method
   ObjectDelete(ChartID(),TEXTNAME);                                     // Name of the object
   ObjectCreate(ChartID(),TEXTNAME,OBJ_TEXT,0,TIME1,PRICE);              // Create a text at specified coordinates
//--- set the text
   ObjectSetString(ChartID(),TEXTNAME,OBJPROP_TEXT,TEXT);                // Name of the object
   ObjectSetString(ChartID(),TEXTNAME,OBJPROP_FONT,Text_font_name);      // Text Font Name
   ObjectSetInteger(ChartID(),TEXTNAME,OBJPROP_FONTSIZE,TextSize);       // Text size
   ObjectSetInteger(ChartID(),TEXTNAME,OBJPROP_ANCHOR,anchor);           // ^
   ObjectSetInteger(ChartID(),TEXTNAME,OBJPROP_COLOR,COLOR);             // Text color
   ObjectSetInteger(ChartID(),TEXTNAME,OBJPROP_SELECTABLE,false);        // true, which allows you to select and move the object
   ObjectSetInteger(ChartID(),TEXTNAME,OBJPROP_SELECTED,false);          // true, which allows you to select and move the object
   ObjectSetInteger(ChartID(),TEXTNAME,OBJPROP_BACK,true);               // Display in foreground (false) or background (true)


}
//+------------------------------------------------------------------+
