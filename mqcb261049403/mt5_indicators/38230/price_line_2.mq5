//+------------------------------------------------------------------+
//|                                                 DisplayClose.mq5 |
//|                                       Copyright 2021, Dark Ryd3r |
//|                                   https://twitter.com/DarkrRyd3r |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Dark Ryd3r"
#property link      "https://twitter.com/DarkrRyd3r"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0


enum ML_FONTTYPE {
   ML_FONTTYPE_ARIAL=0,                       //Arial
   ML_FONTTYPE_ARIALBLACK=1,                  //Arial Black
   ML_FONTTYPE_VERDANA=2,                     //Verdana
   ML_FONTTYPE_TAHOMA=3,                      //Tahoma
   ML_FONTTYPE_COURIERNEW=4,                  //Courier New
   ML_FONTTYPE_LUCIDACONSOLE=5                //Lucida Console
};

enum TimeSelect {
   Current,
   GMT,
   Local
};
input TimeSelect CurrentTime = Local;

string _SymbolName  = "SymbolPriceLine";        // Namespacing the Symbol Background...
input color inpTextColorPositive = C'86,211,158';      // Positive Color
input color inpTextColorNegative = clrDeepPink;         // Negative Color
input ML_FONTTYPE     inpFontType=1;                                  // Font Type
int             inpFontSize=12;                                 // Symbol Font size
int             inpXOffSet=-35;                                   // Reposition Symbol Offset on X axis (+/-)
int             inpYOffSet=10;                                   // Reposition Symbol Offset on Y axis (+/-)
string gmt;
int    _CurWindowWidth;                                // holds the current Chart width

double last,copen,prevCl,Calc2;
datetime m_prev_bars= 0,tm;        // "0" -> D'1970.01.01 00:00';
string Value,texxt,left;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//---
   EventSetMillisecondTimer(1);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit( const int reason ) {
   ObjectDelete( 0, _SymbolName );
   ObjectDelete( 0, "PriceTime" );
   ObjectDelete( 0, "ltp" );
   EventKillTimer();
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
   datetime time_0=time[rates_total-1];
   if(time_0==m_prev_bars)
      return(rates_total);
   m_prev_bars=time_0;

//--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
//---
   if(CurrentTime==Current) {
      tm=TimeCurrent();
      gmt = TimeToString(tm,TIME_SECONDS);
   }
   if(CurrentTime==GMT) {
      tm=TimeGMT();
      gmt = TimeToString(tm,TIME_SECONDS);
   }
   if(CurrentTime==Local) {
      tm=TimeLocal();
      gmt = TimeToString(tm,TIME_SECONDS);
   }
   last = iClose(NULL,PERIOD_CURRENT,0);
   copen = iOpen(NULL,PERIOD_CURRENT,0);
   prevCl = iClose(NULL,PERIOD_D1,1);


   if(last>0 && prevCl>0) {
      Calc2 = -(prevCl-last)/(prevCl)*100;
      Value = DoubleToString(Calc2,2);


      if(prevCl < last) {
         ObjectCreate(     0, _SymbolName, OBJ_LABEL, 0, 0, 0);
         ObjectSetString(  0, _SymbolName, OBJPROP_TEXT,  Value +"%\r "  + gmt + "\r\r\r" );
         ObjectSetInteger( 0, _SymbolName, OBJPROP_COLOR, inpTextColorPositive );
         ObjectSetInteger( 0, _SymbolName, OBJPROP_FONTSIZE, inpFontSize );
         ObjectSetInteger( 0, _SymbolName, OBJPROP_BACK,false);
      } else {
         ObjectCreate(     0, _SymbolName, OBJ_LABEL, 0, 0, 0);
         ObjectSetString(  0, _SymbolName, OBJPROP_TEXT,  Value +"%\r "  + gmt + "\r\r\r" );
         ObjectSetInteger( 0, _SymbolName, OBJPROP_COLOR, inpTextColorNegative );
         ObjectSetInteger( 0, _SymbolName, OBJPROP_FONTSIZE, inpFontSize );
         ObjectSetInteger( 0, _SymbolName, OBJPROP_BACK,false);
      }

   }
   if (inpFontType==ML_FONTTYPE_ARIAL)         {
      ObjectSetString(  0, _SymbolName, OBJPROP_FONT, "Arial" );
   }
   if (inpFontType==ML_FONTTYPE_ARIALBLACK)    {
      ObjectSetString(  0, _SymbolName, OBJPROP_FONT, "Arial Black" );
   }
   if (inpFontType==ML_FONTTYPE_VERDANA)       {
      ObjectSetString(  0, _SymbolName, OBJPROP_FONT, "Verdana" );
   }
   if (inpFontType==ML_FONTTYPE_TAHOMA)        {
      ObjectSetString(  0, _SymbolName, OBJPROP_FONT, "Tahoma" );
   }
   if (inpFontType==ML_FONTTYPE_COURIERNEW)    {
      ObjectSetString(  0, _SymbolName, OBJPROP_FONT, "Courier New" );
   }
   if (inpFontType==ML_FONTTYPE_LUCIDACONSOLE) {
      ObjectSetString(  0, _SymbolName, OBJPROP_FONT, "Lucida Console" );
   }

   ObjectSetInteger( 0, _SymbolName, OBJPROP_CORNER, CORNER_RIGHT_UPPER );
   ObjectSetInteger( 0, _SymbolName, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER );
   ObjectSetInteger( 0, _SymbolName, OBJPROP_XDISTANCE, inpXOffSet );
   ObjectSetInteger( 0, _SymbolName, OBJPROP_YDISTANCE, inpYOffSet);


   texxt =  DoubleToString(last,_Digits);
   left=IntegerToString(m_prev_bars+PeriodSeconds(PERIOD_CURRENT)-tm);
   if(copen < last) {
      if(!TextCreate(0,"PriceTime",0,tm,last,"    "+texxt + "  " + _Symbol  + "\r" + "  " + left,"Arial Black",inpFontSize,
                     inpTextColorPositive,0,ANCHOR_LEFT_LOWER,true,false,true,0)) {
         return;
      }


      if(!HLineCreate(0,"ltp",0,last,inpTextColorPositive,STYLE_SOLID,1,true,
                      false,true,0)) {
         return;
      }

   } else {
      if(!TextCreate(0,"PriceTime",0,tm,last,"    "+texxt + "  " +_Symbol + "\r" + "  " + left,"Arial Black",inpFontSize,
                     inpTextColorNegative,0,ANCHOR_LEFT_LOWER,true,false,true,0)) {
         return;
      }
      if(!HLineCreate(0,"ltp",0,last,inpTextColorNegative,STYLE_SOLID,1,true,
                      false,true,0)) {
         return;
      }

   }
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
                const string            text="Text",              // the text itself
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
