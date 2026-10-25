//+------------------------------------------------------------------+
//|                                                    PriceLine.mq5 |
//|                                      Rajesh Nait, Copyright 2023 |
//|                  https://www.mql5.com/en/users/rajeshnait/seller |
//+------------------------------------------------------------------+
#property copyright "Rajesh Nait, Copyright 2023"
#property link      "https://www.mql5.com/en/users/rajeshnait/seller"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0


ENUM_TIMEFRAMES tf = PERIOD_M30; //2nd chart PERIOD for sync
string myfont="Orbitron";
bool AllowZoom=true;

string _SymbolName  = "SymbolPriceLine",StringSymbolList[],Value,text,left,gmt;        // Namespacing the Symbol Background...
color inpTextColorPositive = C'86,211,158';      // Positive Color
color inpTextColorNegative = C'242,54,69';         // Negative Color

int             inpFontSize=12;                                 // Symbol Font size
int             inpXOffSet=32;                                   // Reposition Symbol Offset on X axis (+/-)
int             inpYOffSet=20;                                   // Reposition Symbol Offset on Y axis (+/-)

datetime m_prev_bars=0,tm,time_0;
double symID,symTotal,Calc2,last,copen,prevCl;
int _CurWindowWidth,NumSymbols=0,scale=0;
string prefix ="p_";
//--- input parameters of the script
input int               InpFontSize=10;          // Font size
input double            InpAngle=0.0;           // Slope angle in degrees
input ENUM_ANCHOR_POINT InpAnchor=ANCHOR_CENTER;   // Anchor type
input bool              InpBack=false;           // Background object
input bool              InpSelection=false;      // Highlight to move
input bool              InpHidden=true;          // Hidden in the object list
input long              InpZOrder=0;             // Priority for mouse click

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping

   ChartSetInteger(ChartID(),CHART_EVENT_MOUSE_WHEEL,true);

   symID = GlobalVariableGet("SymbolID");
   symTotal = GlobalVariableGet("SymbolTotal");

//---
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit( const int reason ) {
//GlobalVariableSet(_Symbol+"_ChartScale",ChartScaleGet(0) );
   ObjectsDeleteAll(0,prefix);
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
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(open,true);

   time_0=time[rates_total-1];
   m_prev_bars=time_0;

   tm=TimeGMT();
   gmt = TimeToString(tm,TIME_SECONDS);


   last = close[0];
   copen = open[0];
   prevCl = iClose(NULL,PERIOD_M1,1440);
//prevCl = iClose(NULL,PERIOD_D1,1);

   if(last>0 && prevCl>0) {

      Calc2 = -(prevCl-last)/(prevCl)*100;
      Value = DoubleToString(Calc2,2);

      if(!LabelCreate(0,prefix+"last",0,inpXOffSet,inpYOffSet,CORNER_RIGHT_LOWER,DoubleToString(last,_Digits),myfont,inpFontSize,
                      clrHoneydew,0,ANCHOR_RIGHT_LOWER,false,false,true,0)) {
         return 0;
      }

      if(prevCl < last) {

         if(!LabelCreate(0,prefix+_SymbolName,0,inpXOffSet,inpYOffSet,CORNER_RIGHT_UPPER,Value +"%\r "  + gmt + " "+ IntegerToString((int)symID) + "/\r\r\r"+ IntegerToString((int)symTotal),myfont,inpFontSize,
                         inpTextColorPositive,0,ANCHOR_RIGHT_UPPER,false,false,true,0)) {
            return 0;
         }




      } else {

         if(!LabelCreate(0,prefix+_SymbolName,0,inpXOffSet,inpYOffSet,CORNER_RIGHT_UPPER,Value +"%\r "  + gmt + " "+ IntegerToString((int)symID) + "/\r\r\r"+ IntegerToString((int)symTotal),myfont,inpFontSize,
                         inpTextColorNegative,0,ANCHOR_RIGHT_UPPER,false,false,true,0)) {
            return 0;
         }

      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam) {

//   switch(int(lparam)) {
//
//   case 68: // D
//      ObjectsDeleteAll(0,-1,-1);
//      break;
//
//   }

   if(id==CHARTEVENT_KEYDOWN) {

      switch(int(lparam)) {
      case 37:
         PrevSymbol();
         break;
      case 39:
         NextSymbol();
         break;
      }

   }

   if(id==CHARTEVENT_MOUSE_WHEEL) {
      //wheel up
      if(dparam>0) {
         scale=(int)ChartGetInteger(ChartID(),CHART_SCALE);
         scale++;
         if(scale>5) {
            scale=5;
         }
         ChartSetInteger(ChartID(),CHART_MOUSE_SCROLL,false);
         ChartSetInteger(ChartID(),CHART_EVENT_MOUSE_MOVE,false);
         if(ChartSetInteger(ChartID(),CHART_SCALE,scale)==false) Print(GetLastError());
         ChartSetInteger(ChartID(),CHART_MOUSE_SCROLL,true);
         ChartSetInteger(ChartID(),CHART_EVENT_MOUSE_MOVE,true);

         ChartRedraw(ChartID());
         //ChartSetInteger(ChartID(),CHART_MOUSE_SCROLL,true);
      }
      //wheel down
      if(dparam<0) {
         scale=(int)ChartGetInteger(ChartID(),CHART_SCALE);
         //Print(scale);
         scale--;
         if(scale<0) {
            scale=0;
         }
         if(ChartSetInteger(ChartID(),CHART_MOUSE_SCROLL,false)==false) Print(GetLastError());
         if(ChartSetInteger(ChartID(),CHART_EVENT_MOUSE_MOVE,false)==false) Print(GetLastError());
         if(ChartSetInteger(ChartID(),CHART_SCALE,scale)==false) Print(GetLastError());
         if(ChartSetInteger(ChartID(),CHART_EVENT_MOUSE_MOVE,true)==false) Print(GetLastError());
         if(ChartSetInteger(ChartID(),CHART_MOUSE_SCROLL,true)==false) Print(GetLastError());


         ChartRedraw(ChartID());
         //ChartSetInteger(ChartID(),CHART_MOUSE_SCROLL,true);
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string  GetTimeFrame( ENUM_TIMEFRAMES  lPeriod) {
   switch (lPeriod) {
   case  PERIOD_M1 :
      return ( "M1" );
   case  PERIOD_M2 :
      return ( "M2" );
   case  PERIOD_M3 :
      return ( "M3" );
   case  PERIOD_M4 :
      return ( "M4" );
   case  PERIOD_M5 :
      return ( "M5" );
   case  PERIOD_M6 :
      return ( "M6" );
   case  PERIOD_M10 :
      return ( "M10" );
   case  PERIOD_M12 :
      return ( "M12" );
   case  PERIOD_M15 :
      return ( "M15" );
   case  PERIOD_M20 :
      return ( "M20" );
   case  PERIOD_M30 :
      return ( "M30" );
   case  PERIOD_H1 :
      return ( "H1" );
   case  PERIOD_H2 :
      return ( "H2" );
   case  PERIOD_H3 :
      return ( "H3" );
   case  PERIOD_H4 :
      return ( "H4" );
   case  PERIOD_H6 :
      return ( "H6" );
   case  PERIOD_H8 :
      return ( "H8" );
   case  PERIOD_H12 :
      return ( "H12" );
   case  PERIOD_D1 :
      return ( "D1" );
   case  PERIOD_W1 :
      return ( "W1" );
   case  PERIOD_MN1 :
      return ( "MN1" );
   }
   return  EnumToString (lPeriod);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PrevSymbol() {
   int currentIndex;
   GetSymbols();
   currentIndex=GetIndex();
   currentIndex--;

   if(currentIndex<0) {
      currentIndex=NumSymbols-1;
      ChartSetSymbolPeriod(0,StringSymbolList[currentIndex],0);
   } else {
      ChartSetSymbolPeriod(0,StringSymbolList[currentIndex],0);
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void NextSymbol() {
   int currentIndex;
   GetSymbols();
   currentIndex=GetIndex();
   currentIndex++;

   if(currentIndex>=NumSymbols) {
      ChartSetSymbolPeriod(0,StringSymbolList[0],0);
   } else {
      ChartSetSymbolPeriod(0,StringSymbolList[currentIndex],0);

   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetSymbols() {
   int numSymbolsMarketWatch=SymbolsTotal(true);
   NumSymbols=numSymbolsMarketWatch;
   ArrayResize(StringSymbolList,numSymbolsMarketWatch);
   for(int i=0; i<numSymbolsMarketWatch; i++) {
      StringSymbolList[i]=SymbolName(i,true);
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndex() {
   int index=0;
   for(int i=0; i<NumSymbols; i++) {
      if(_Symbol==StringSymbolList[i]) {
         index=i;

         break;
      }
   }
   return index;
}

//+------------------------------------------------------------------+
//| Gets chart scale (from 0 to 5)                                   |
//+------------------------------------------------------------------+
int ChartScaleGet(const long chart_ID=0) {
   long result=-1;
   ResetLastError();
   if(!ChartGetInteger(chart_ID,CHART_SCALE,0,result)) {
      Print(__FUNCTION__+", Error Code = ",GetLastError());
   }
   return((int)result);
}
//+------------------------------------------------------------------+
//| Sets chart scale (from 0 to 5)                                   |
//+------------------------------------------------------------------+
bool ChartScaleSet(const long value,const long chart_ID=0) {
   ResetLastError();
   if(!ChartSetInteger(chart_ID,CHART_SCALE,0,value)) {
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
   }
   return(true);
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
                 const long            z_order=0) {       // priority for mouse click
//--- if the price is not set, set it at the current Bid price level
   if(!price)
      price=iClose(NULL,PERIOD_M1,0);


//--- reset the error value
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price)) {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
   }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);

//--- successful execution
   return(true);
}

//+------------------------------------------------------------------+
//| Creating Text object                                             |
//+------------------------------------------------------------------+
bool TextCreate(const long              chart_ID=0,               // chart's ID
                const string            name="Text",              // object name
                const int               sub_window=0,             // subwindow index
                datetime                time=0,                   // anchor point time
                double                  price=0,                  // anchor point price
                const string            text2="Text",              // the text itself
                const string            font="Arial",             // font
                const int               font_size=10,             // font size
                const color             clr=clrRed,               // color
                const double            angle=0.0,                // text slope
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                const bool              back=false,               // in the background
                const bool              selection=false,          // highlight to move
                const bool              hidden=true,              // hidden in the object list
                const long              z_order=0) {              // priority for mouse click
//--- set anchor point coordinates if they are not set
//ChangeTextEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create Text object
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price)) {
      Print(__FUNCTION__,
            ": failed to create \"Text\" object! Error code = ",GetLastError());
      return(false);
   }
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text2);
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
//--- enable (true) or disable (false) the mode of moving the object by mouse
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
//| Create a text label                                              |
//+------------------------------------------------------------------+
bool LabelCreate(const long              chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name
                 const int               sub_window=0,             // subwindow index
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                 const string            text2="Label3",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true,              // hidden in the object list
                 const long              z_order=0) {              // priority for mouse click
//--- reset the error value
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0)) {
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
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text2);
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
