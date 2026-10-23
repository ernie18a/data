//+------------------------------------------------------------------+
//|                                                CreateObjects.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"

void vSetRectangle(string name, int sub_window, int xx, int yy, int width, int height, color bg_color, color border_clr, int border_width)
  {
   ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,sub_window,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,xx);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,yy);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_COLOR,border_clr);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,bg_color);
   ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,border_width);
   ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,0);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
}
void vSetLabel(string sName,int sub_window, int xx, int yy, color cFontColor, int iFontSize, string sText) {
   ObjectCreate(0,sName,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,sName, OBJPROP_YDISTANCE, xx);
   ObjectSetInteger(0,sName, OBJPROP_XDISTANCE, yy);
   ObjectSetInteger(0,sName, OBJPROP_COLOR,cFontColor);
   ObjectSetInteger(0,sName, OBJPROP_WIDTH,FW_BOLD);
   
   ObjectSetInteger(0,sName, OBJPROP_FONTSIZE, iFontSize);
   ObjectSetString(0,sName,OBJPROP_TEXT, 0,sText);
   
}
 //  ObjectSetMQL4("Obj1",OBJPROP_BACK,false);	