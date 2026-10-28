//+------------------------------------------------------------------+
//|                                        Four horizontal lines.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property description ""
#property indicator_chart_window
#property indicator_plots 0
//--- input parameters
input color             InpColorHighLow      = clrRed;            // HighLow: Line color 
input color             InpColorDifference   = clrLimeGreen;      // Difference: Line color 
//---
input ENUM_LINE_STYLE   InpStyle             = STYLE_SOLID;       // Line style 
input int               InpWidth             = 2;                 // Line width 
input bool              InpBack              = false;             // Background line 
input bool              InpSelection         = false;             // Highlight to move 
input bool              InpHidden            = true;              // Hidden in the object list 
input long              InpZOrder            = 0;                 // Priority for mouse click 
//---
input int               InpBarNumber         = 1;                 // Bar number
input int               InpShiftHighLowUP    = 20;                // Shift
//---
string                  ExtNameHighLowUP     = "HighLowUP";       // HighLowUP: Line name 
string                  ExtNameHighLowDOWN   = "HighLowDOWN";     // HighLowDOWN: Line name 
string                  ExtNameDifferenceUP  = "DifferenceUP";    // DifferenceUP: Line name 
string                  ExtNameDifferenceDOWN= "DifferenceDOWN";  // DifferenceDOWN: Line name 
double                  ExtInpShiftHighLowUP = 0.0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   HLineCreate(0,ExtNameHighLowUP,0,0,InpColorHighLow,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
   HLineCreate(0,ExtNameHighLowDOWN,0,0,InpColorHighLow,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);

   HLineCreate(0,ExtNameDifferenceUP,0,0,InpColorDifference,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);
   HLineCreate(0,ExtNameDifferenceDOWN,0,0,InpColorDifference,InpStyle,InpWidth,InpBack,InpSelection,InpHidden,InpZOrder);

   ExtInpShiftHighLowUP=InpShiftHighLowUP*Point();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- 
   HLineDelete(0,ExtNameHighLowUP);
   HLineDelete(0,ExtNameHighLowDOWN);

   HLineDelete(0,ExtNameDifferenceUP);
   HLineDelete(0,ExtNameDifferenceDOWN);
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
                const int &spread[])
  {
//---
   if(prev_calculated==0 || rates_total!=prev_calculated)
     {
      //--- Move horizontal line
      double high_1=high[rates_total-1-InpBarNumber];
      double low_1=low[rates_total-1-InpBarNumber];

      HLineMove(0,ExtNameHighLowUP,high_1+ExtInpShiftHighLowUP);
      HLineMove(0,ExtNameHighLowDOWN,low_1-ExtInpShiftHighLowUP);

      HLineMove(0,ExtNameDifferenceUP,high_1+(high_1-low_1)-ExtInpShiftHighLowUP/2.0);
      HLineMove(0,ExtNameDifferenceDOWN,low_1-(high_1-low_1)+ExtInpShiftHighLowUP/2.0);
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+ 
//| Create the horizontal line                                       | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="HLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  {
//--- if the price is not set, set it at the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- create a horizontal line 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
bool HLineMove(const long   chart_ID=0,   // chart's ID 
               const string name="HLine", // line name 
               double       price=0)      // line price 
  {
//--- if the line price is not set, move it to the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- move a horizontal line 
   if(!ObjectMove(chart_ID,name,0,0,price))
     {
      Print(__FUNCTION__,
            ": failed to move the horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Delete a horizontal line                                         | 
//+------------------------------------------------------------------+ 
bool HLineDelete(const long   chart_ID=0,   // chart's ID 
                 const string name="HLine") // line name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete a horizontal line 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
