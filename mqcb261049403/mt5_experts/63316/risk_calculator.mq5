//+------------------------------------------------------------------+
//|                                                RiskCalculator.mq5|
//|                                                  Jhonatan Morais |
//|                      https://www.mql5.com/en/users/jhonatanmorais|
//+------------------------------------------------------------------+
#property copyright "Jhonatan Morais"
#property link      "https://www.mql5.com/en/users/jhonatanmorais"
#property version   "1.00"
#property strict

//--- object names
#define PANEL_BG      "calc_bg"
#define EDIT_LOTE     "edit_lote"
#define EDIT_TAKE     "edit_take"
#define EDIT_STOP     "edit_stop"
#define LABEL_TITLE   "label_title"
#define LABEL_PIP     "label_pip"
#define LABEL_TAKE    "label_take"
#define LABEL_STOP    "label_stop"
#define BTN_CALC      "btn_calc_rect"  
#define BTN_TEXT      "btn_calc_text" 
#define LABEL_LOTE    "label_lote"
#define LABEL_TAKE_PT "label_take_pt"
#define LABEL_STOP_PT "label_stop_pt"

//+------------------------------------------------------------------+
//| Global variables for our user interface                          |
//+------------------------------------------------------------------+
int      panel_width  = 285;
int      panel_height = 230;
int      panel_x      = 330;
int      panel_y      = 5;

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   // Create main background panel (rectangle label)
   CreateRectLabel(PANEL_BG, panel_x, panel_y, panel_width, panel_height, clrDimGray, "");

   // Create edit fields (defaults) and their corresponding labels
   CreateLabel("label_lote", panel_x - 30, panel_y + 50, "Lot Size:", clrWhite, false);
   CreateEdit(EDIT_LOTE, panel_x - 160, panel_y + 50, 100, 22, "0.01");

   CreateLabel("label_take_pt", panel_x - 30, panel_y + 80, "Take (pts):", clrWhite, false);
   CreateEdit(EDIT_TAKE, panel_x - 160, panel_y + 80, 100, 22, "0");

   CreateLabel("label_stop_pt", panel_x - 30, panel_y + 110, "Stop (pts):", clrWhite, false);
   CreateEdit(EDIT_STOP, panel_x - 160, panel_y + 110, 100, 22, "0");

   // Create custom button with rectangle and text label
   CreateCustomButton(BTN_CALC, BTN_TEXT, panel_x - 30, panel_y + 185, 100, 22, "Calculate");

   // Create labels (value per point and results)
   double pipVal = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   if(pipVal == 0)
      pipVal = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   string pip_text = "Point Value: " + DoubleToString(pipVal, 2);
   CreateLabel(LABEL_PIP, panel_x - 30, panel_y + 139, pip_text, clrYellow, false);

   CreateTitleLabel(LABEL_TITLE, panel_x - 30, panel_y + 10, "RISK CALCULATOR", clrWhite, false);

   CreateResultLabel(LABEL_TAKE, panel_x - 145, panel_y + 160, "Take: 0.00", clrLime);
   CreateResultLabel(LABEL_STOP, panel_x - 145, panel_y + 190, "Stop: 0.00", clrOrangeRed);

   ChartRedraw();
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| OnTick (EA must have this to remain active)                      |
//+------------------------------------------------------------------+
void OnTick()
{
   // empty - UI only
}

//+------------------------------------------------------------------+
//| Chart events                                                     |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   // Handle object clicks
   if (id == CHARTEVENT_OBJECT_CLICK)
   {
      // Check if it's one of the edit fields
      if (sparam == EDIT_LOTE || sparam == EDIT_TAKE || sparam == EDIT_STOP)
      {
         ObjectSetString(0, sparam, OBJPROP_TEXT, "");
         ChartRedraw();
      }

      // If the custom button (rectangle) is clicked
      if (sparam == BTN_CALC || sparam == BTN_TEXT)
      {
         // Simulate button press visual effect by darkening the color
         ObjectSetInteger(0, BTN_CALC, OBJPROP_BGCOLOR, clrDarkCyan);
         ChartRedraw();

         // read user inputs and calculate
         string lot_str  = ObjectGetString(0, EDIT_LOTE, OBJPROP_TEXT);
         string take_str = ObjectGetString(0, EDIT_TAKE, OBJPROP_TEXT);
         string stop_str = ObjectGetString(0, EDIT_STOP, OBJPROP_TEXT);

         double lot     = StringToDouble(lot_str);
         double takePts = StringToDouble(take_str);
         double stopPts = StringToDouble(stop_str);

         if (lot <= 0)
            lot = 0.01;
         if (takePts < 0)
            takePts = 0;
         if (stopPts < 0)
            stopPts = 0;

         // obtain value per point (tick)
         double pipVal = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
         if (pipVal == 0)
            pipVal = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

         // calculate money amounts
         double takeAmount = lot * takePts * pipVal;
         double stopAmount = lot * stopPts * pipVal;

         // update result labels
         string sTake = "Take: " + DoubleToString(takeAmount, 2);
         string sStop = "Stop: " + DoubleToString(stopAmount, 2);

         ObjectSetString(0, LABEL_TAKE, OBJPROP_TEXT, sTake);
         ObjectSetString(0, LABEL_STOP, OBJPROP_TEXT, sStop);

         // also update pip label in case symbol changed
         string pip_text = "Point Value: " + DoubleToString(pipVal, 2);
         ObjectSetString(0, LABEL_PIP, OBJPROP_TEXT, pip_text);

         // Immediately revert button color to original
         ObjectSetInteger(0, BTN_CALC, OBJPROP_BGCOLOR, clrDodgerBlue);
         ChartRedraw();
      }
   }
}

//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   string objs[] = {PANEL_BG, EDIT_LOTE, EDIT_TAKE, EDIT_STOP, LABEL_PIP, LABEL_TAKE, LABEL_STOP, BTN_CALC, BTN_TEXT, LABEL_TITLE, "label_lote", "label_take_pt", "label_stop_pt"};
   for(int i = 0; i < ArraySize(objs); i++)
   {
      if(ObjectFind(0, objs[i]) >= 0)
         ObjectDelete(0, objs[i]);
   }
}

//+------------------------------------------------------------------+
//| Helper: create rectangle label (background panel)                |
//+------------------------------------------------------------------+
void CreateRectLabel(string name, int x, int y, int w, int h, color bg, string text = "")
{
   if(ObjectFind(0, name) >= 0)
      ObjectDelete(0, name);
   
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrSilver);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_RAISED);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 11);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, 0); 
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 0); 
}

//+------------------------------------------------------------------+
//| Helper: create edit field                                        |
//+------------------------------------------------------------------+
void CreateEdit(string name, int x, int y, int w, int h, string text = "")
{
   if(ObjectFind(0, name) >= 0)
      ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_EDIT, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, 0); 
   ObjectSetInteger(0, name, OBJPROP_READONLY, 0);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 1);
       ObjectSetInteger(0, name, OBJPROP_BGCOLOR, C'40,40,40');
    ObjectSetInteger(0, name, OBJPROP_COLOR, clrWhite);
    ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrDodgerBlue);
}

//+------------------------------------------------------------------+
//| Helper: create simple label                                      |
//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, string text, color col, bool withBackground)
{
   if(ObjectFind(0, name) >= 0)
      ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   if(withBackground)
   {
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrWhite);
   }
   else
   {
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrNONE);
   }
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, 0);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 1);
}
//+------------------------------------------------------------------+
//| Helper: create result label (white background, bolder font feel) |
//+------------------------------------------------------------------+
void CreateResultLabel(string name, int x, int y, string text, color col)
{
   if(ObjectFind(0, name) >= 0)
      ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, 0);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, name, OBJPROP_COLOR, col);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrWhite);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial Black");
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, 0);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 1);
}

//+------------------------------------------------------------------+
//| Helper: creates a custom button using a rectangle and a label.   |
//+------------------------------------------------------------------+
void CreateCustomButton(string rect_name, string text_name, int x, int y, int w, int h, string text)
{
   // Create the rectangle for the button's body
   if(ObjectFind(0, rect_name) >= 0)
      ObjectDelete(0, rect_name);
   ObjectCreate(0, rect_name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, rect_name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, rect_name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, rect_name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, rect_name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, rect_name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, rect_name, OBJPROP_BGCOLOR, clrDodgerBlue);
   ObjectSetInteger(0, rect_name, OBJPROP_BORDER_TYPE, BORDER_RAISED);
   ObjectSetInteger(0, rect_name, OBJPROP_SELECTABLE, 0);
   ObjectSetInteger(0, rect_name, OBJPROP_ZORDER, 1);
   
   // Create the label for the button's text, placed on top of the rectangle
   if(ObjectFind(0, text_name) >= 0)
      ObjectDelete(0, text_name);
   ObjectCreate(0, text_name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, text_name, OBJPROP_XDISTANCE, x - 17); // Center horizontally
   ObjectSetInteger(0, text_name, OBJPROP_YDISTANCE, y + h / 2 - 9); // Corrected: Center text vertically
   ObjectSetInteger(0, text_name, OBJPROP_XSIZE, 0);
   ObjectSetInteger(0, text_name, OBJPROP_YSIZE, 0);
   ObjectSetInteger(0, text_name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetString(0, text_name, OBJPROP_TEXT, text);
   ObjectSetString(0, text_name, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, text_name, OBJPROP_FONTSIZE, 10);
   ObjectSetInteger(0, text_name, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, text_name, OBJPROP_BGCOLOR, clrNONE); // Transparent background
   ObjectSetInteger(0, text_name, OBJPROP_SELECTABLE, 0);
   ObjectSetInteger(0, text_name, OBJPROP_ZORDER, 2);
}

//+------------------------------------------------------------------+
//| Helper: create title label (bold, larger font)                   |
//+------------------------------------------------------------------+
void CreateTitleLabel(string name, int x, int y, string text, color col, bool withBackground)
{
   if(ObjectFind(0, name) >= 0)
      ObjectDelete(0, name);

   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);

   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial Black");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 12);
   ObjectSetInteger(0, name, OBJPROP_COLOR, col);

   if(withBackground)
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrWhite);
   else
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clrNONE);

   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, 0);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 1);
}
//+------------------------------------------------------------------+