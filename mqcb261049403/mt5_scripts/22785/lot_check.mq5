//+------------------------------------------------------------------+
//|                                                    Lot Check.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property script_show_inputs
//---
#include <Trade\SymbolInfo.mqh>  
CSymbolInfo    m_symbol;         // symbol info object
//--- input parameters
input string   InpSymbol= "";    // Symbol ("", " ", "*/23458vg49" ... -> the current Symbol will be used)
input double   InpLot   = 0.758; // Lot
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(!m_symbol.Name(InpSymbol)) // sets symbol name
      if(!m_symbol.Name(Symbol())) // sets symbol name
         return;
   RefreshRates();
   if(!LabelCreate(0,"Lot Check_"+"lots_min",0,5,15,CORNER_RIGHT_LOWER,"Lots min") || 
      !LabelCreate(0,"Lot Check_"+"lots_step",0,5,30,CORNER_RIGHT_LOWER,"Lots step") || 
      !LabelCreate(0,"Lot Check_"+"lots_max",0,5,45,CORNER_RIGHT_LOWER,"Lots max") || 
      !LabelCreate(0,"Lot Check_"+"lots",0,5,60,CORNER_RIGHT_LOWER,"Lots"))
      return;
//---
   double lots=InpLot,lots_step,lots_max=0.0,lots_min=0.0;
   lots=LotCheck(lots,lots_step,lots_max,lots_min);
   LabelTextChange(0,"Lot Check_"+"lots_min","Lots min: "+DoubleToString(lots_min,2));
   LabelTextChange(0,"Lot Check_"+"lots_step","Lots step: "+DoubleToString(lots_step,2));
   LabelTextChange(0,"Lot Check_"+"lots_max","Lots max: "+DoubleToString(lots_max,2));
   LabelTextChange(0,"Lot Check_"+"lots","Lots input: "+DoubleToString(InpLot,3)+", output: "+DoubleToString(lots,2));
//---
   return;
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots,double &lots_step,double &lots_max,double &lots_min)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   lots_step=m_symbol.LotsStep();
   if(lots_step>0.0)
      volume=lots_step*MathFloor(volume/lots_step);
//---
   lots_min=m_symbol.LotsMin();
   if(volume<lots_min)
      volume=0.0;
//---
   lots_max=m_symbol.LotsMax();
   if(volume>lots_max)
      volume=lots_max;
   return(volume);
  }
//+------------------------------------------------------------------+ 
//| Create a text label                                              | 
//+------------------------------------------------------------------+ 
bool LabelCreate(const long              chart_ID=0,               // chart's ID 
                 const string            name="Label",             // label name 
                 const int               sub_window=0,             // subwindow index 
                 const int               x=0,                      // X coordinate 
                 const int               y=0,                      // Y coordinate 
                 const ENUM_BASE_CORNER  corner=CORNER_RIGHT_LOWER,// chart corner for anchoring 
                 const string            text="Label",             // text 
                 const string            font="Courier New",       // font 
                 const int               font_size=10,             // font size 
                 const color             clr=clrRed,               // color 
                 const double            angle=0.0,                // text slope 
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_RIGHT_LOWER,// anchor type 
                 const bool              back=false,               // in the background 
                 const bool              selection=false,          // highlight to move 
                 const bool              hidden=true,              // hidden in the object list 
                 const long              z_order=0)                // priority for mouse click 
  {
//--- reset the error value 
   ResetLastError();
//--- create a text label 
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text 
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type 
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse 
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
//| Change the label text                                            | 
//+------------------------------------------------------------------+ 
bool LabelTextChange(const long   chart_ID=0,   // chart's ID 
                     const string name="Label", // object name 
                     const string text="Text")  // text 
  {
//--- reset the error value 
   ResetLastError();
//--- change object text 
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Delete a text label                                              | 
//+------------------------------------------------------------------+ 
bool LabelDelete(const long   chart_ID=0,   // chart's ID 
                 const string name="Label") // label name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete the label 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a text label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
