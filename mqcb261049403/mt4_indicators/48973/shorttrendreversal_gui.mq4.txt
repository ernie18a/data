//+------------------------------------------------------------------+
//|                                    Short Trend Reverssal GUI.mq4 |
//|                                          Copyright © 2024, bialy |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright     "https://www.mql5.com/en/market/product/Short Trend Reversal"
#property link          "https://www.mql5.com/en/market/product/114909"
#property description   "Short Trend Reversal ChartEvents\n"
#property description   "Created for Short Trend Reversal EA, because external DLL imports are prohibited in Market"
#property version       "1.00"
#property strict
#property indicator_chart_window

//#import "user32.dll"
//   int GetParent(int hWnd);
//   int SetWindowPos(int hWnd,int hWndInsertAfter ,int X,int Y,int cx,int cy,int uFlags);
//#import
//========================================================================================================================================================================================================
int OnInit(void)  {
   SetIndexLabel(0,NULL);
   return(INIT_SUCCEEDED);
}
//========================================================================================================================================================================================================
void OnDeinit(const int reason) {
}
//========================================================================================================================================================================================================
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

   return(rates_total);
}
//========================================================================================================================================================================================================
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {        int _X = 0;
   if(id==CHARTEVENT_OBJECT_CLICK) {
      string clickedObjectName = sparam;
      //int parent = GetParent((int)ChartGetInteger(0,CHART_WINDOW_HANDLE));
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      if(clickedObjectName == "GUI_DETAILS") {
         bool selected = false;
         if(ObjectGetInteger(0,clickedObjectName,OBJPROP_BGCOLOR) == clrLightBlue) selected = true;
         if(ObjectGetInteger(0,clickedObjectName,OBJPROP_FONTSIZE) == 11) _X = 400;
         if(ObjectGetInteger(0,clickedObjectName,OBJPROP_FONTSIZE) == 10) _X = 335;
         //if(selected)   SetWindowPos(parent,0,0,0,_X,465,0x0002);
         //else           SetWindowPos(parent,0,0,0,_X,265,0x0002);
      }
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      if(clickedObjectName == "GUI_SIZE") {
         if(ObjectGetInteger(0,clickedObjectName,OBJPROP_FONTSIZE) == 10) _X = 400;
         if(ObjectGetInteger(0,clickedObjectName,OBJPROP_FONTSIZE) == 9)  _X = 335;
         //SetWindowPos(parent,0,0,0,_X,(int)ObjectGetInteger(0,"GUI_background",OBJPROP_YSIZE)+140,0x0002);
      }
   }
}
//========================================================================================================================================================================================================
