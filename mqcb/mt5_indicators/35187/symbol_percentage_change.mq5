//+------------------------------------------------------------------+
//|                                     Symbol_Percentage_Change.mq5 |
//|                            Copyright 2021, Dark Ryd3r @Darkryd3r |
//|                                        https://www.darkryd3r.com |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Descriptors                                                      |
//+------------------------------------------------------------------+
#property copyright   "Copyright © 2021, Dark Ryd3r"
#property link        "http://www.darkryd3r.com"
#property version     "1.0"
#property description "Showing the Symbol Name, Last closing price and percentage change at the chart"
#property indicator_buffers 1
#property indicator_plots   1
//+------------------------------------------------------------------+
//| Indicator Settings                                               |
//+------------------------------------------------------------------+
#property indicator_chart_window

double DPCBuffer[];
double C,O;

//--- variables
int leftTime;
string sTime;
int days;
string sCurrentTime;

//+------------------------------------------------------------------+
// ENUMerations
//+------------------------------------------------------------------+
enum ML_WINPOSITION {
   ML_WINPOSITION_UPPER_LEFT=0,               //Upper Left of the chart
   ML_WINPOSITION_UPPER_CENTER=1,             //Upper Center of the chart
   ML_WINPOSITION_UPPER_RIGHT=2,              //Upper Right of the chart
   ML_WINPOSITION_LOWER_LEFT=3,               //Lower Left of the chart
   ML_WINPOSITION_LOWER_CENTER=4,             //Lower Center of the chart
   ML_WINPOSITION_LOWER_RIGHT=5               //Lower Right of the chart
};
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

input TimeSelect CurrentTime = GMT;
//+------------------------------------------------------------------+
// Inputs from User Interface                                        |
//+------------------------------------------------------------------+
//input color           inpTextColor=clrSnow;                       // Symbol Text color
input color inpTextColorPositive = C'86,211,158';      // Positive Color
input color inpTextColorNegative = clrDeepPink;         // Negative Color
input ML_FONTTYPE     inpFontType=1;                                  // Font Type
int             inpFontSize=14;                                 // Symbol Font size
input ML_WINPOSITION  inpWindowPosition=ML_WINPOSITION_UPPER_RIGHT;  // Symbol position
int             inpXOffSet=-35;                                   // Reposition Symbol Offset on X axis (+/-)
int             inpYOffSet=10;                                   // Reposition Symbol Offset on Y axis (+/-)

string gmt;
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
string _SymbolName  = "SymbolBackground";        // Namespacing the Symbol Background...
int    _CurWindowWidth;                                // holds the current Chart width
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()   {

   SetIndexBuffer(0,DPCBuffer,INDICATOR_DATA);
   ArraySetAsSeries(DPCBuffer,true);
}


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit( const int reason ) {
   ObjectDelete( 0, _SymbolName );
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function - DOES NOTHING!              |
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

//--- check for bars count
   if(rates_total<1440/Period())
      return(0); //exit with zero result

//--- prevent total recalculation
   int i=rates_total-1;
   if(prev_calculated>0)
      i=rates_total-prev_calculated -1;
//Print("I:" ,i);

//--- current value should be recalculated
   if(i<0)
      i=0;
//---
   while(i>=0) {
      datetime date=iTime(NULL,0,i);
      int Hour=TimeHourMQL4(date);
      int Minute=TimeMinuteMQL4(date);


      if(Hour==0 && Minute==0) {
         O=iOpen(NULL,0,i);
      }

      C=iClose(NULL,0,i);

      if(O==0)
         DPCBuffer[i]=0;
      else
         DPCBuffer[i]=NormalizeDouble(((C-O)/O*100),2);

      MqlRates BarData[1];
      CopyRates(Symbol(), Period(), 0, 1, BarData);
      double Latest_Close_Price = BarData[0].close;

      if(CurrentTime==Current) {
         datetime tm=TimeCurrent();
         gmt = TimeToString(tm,TIME_SECONDS);
      }
      if(CurrentTime==GMT) {
         datetime tm=TimeGMT();
         gmt = TimeToString(tm,TIME_SECONDS);
      }
      if(CurrentTime==Local) {
         datetime tm=TimeLocal();
         gmt = TimeToString(tm,TIME_SECONDS);
      }


      if(DPCBuffer[i] >0) {
         ObjectCreate(     0, _SymbolName, OBJ_LABEL, 0, 0, 0);
         ObjectSetString(  0, _SymbolName, OBJPROP_TEXT, _Symbol + "\r " + DoubleToString(Latest_Close_Price,_Digits) + " \r+" + DoubleToString(DPCBuffer[i],2) + "\r% " + gmt);
         ObjectSetInteger( 0, _SymbolName, OBJPROP_COLOR, inpTextColorPositive );
         ObjectSetInteger( 0, _SymbolName, OBJPROP_FONTSIZE, inpFontSize );
         ObjectSetInteger( 0, _SymbolName, OBJPROP_BACK,false);
      }

      else {
         ObjectCreate(     0, _SymbolName, OBJ_LABEL, 0, 0, 0);
         ObjectSetString(  0, _SymbolName, OBJPROP_TEXT, _Symbol + "\r " + DoubleToString(Latest_Close_Price,_Digits) + " \r" + DoubleToString(DPCBuffer[i],2) + "\r% " + gmt);
         ObjectSetInteger( 0, _SymbolName, OBJPROP_COLOR, inpTextColorNegative );
         ObjectSetInteger( 0, _SymbolName, OBJPROP_FONTSIZE, inpFontSize );
         ObjectSetInteger( 0, _SymbolName, OBJPROP_BACK,false);
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

      updateXY();
      i--;

      sCurrentTime=TimeToString(TimeCurrent(),TIME_SECONDS);
      ArraySetAsSeries(time,true);

      leftTime=PeriodSeconds(Period())-(int)(TimeCurrent()-time[0]);

   }
   ChartRedraw(0);
   return(rates_total);
}

//+------------------ Functions -----------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeHourMQL4(datetime date) {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.hour);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeMinuteMQL4(datetime date) {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.min);
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| OnChart events
//+------------------------------------------------------------------+
void  OnChartEvent( const int       id,       // event ID
                    const long&     lparam,
                    const double&   dparam,
                    const string&   sparam
                  ) {

   int newWindowsWidth;

// checks if the Chart size has changed...
   if (id==CHARTEVENT_CHART_CHANGE ) {
      newWindowsWidth = (int)ChartGetInteger( 0, CHART_WIDTH_IN_PIXELS, 0 );

      if (_CurWindowWidth != newWindowsWidth) {
         updateXY();                      // repaints the Symbol name into the new coordinate...
         _CurWindowWidth = newWindowsWidth;
      }
   }

}
//+------------------------------------------------------------------+
//| Updates X and Y coordinates of the Symbol Name on Chart
//+------------------------------------------------------------------+
void  updateXY() {
   if (inpWindowPosition==ML_WINPOSITION_UPPER_LEFT) {
      ObjectSetInteger( 0, _SymbolName, OBJPROP_CORNER, CORNER_LEFT_UPPER );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_XDISTANCE, inpXOffSet );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_YDISTANCE, inpYOffSet);

   } else if (inpWindowPosition==ML_WINPOSITION_UPPER_RIGHT) {
      ObjectSetInteger( 0, _SymbolName, OBJPROP_CORNER, CORNER_RIGHT_UPPER );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_XDISTANCE, inpXOffSet );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_YDISTANCE, inpYOffSet);

   } else if (inpWindowPosition==ML_WINPOSITION_UPPER_CENTER) {
      ObjectSetInteger( 0, _SymbolName, OBJPROP_CORNER, CORNER_LEFT_UPPER );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_XDISTANCE, inpXOffSet+ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0)/2 );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_YDISTANCE, inpYOffSet);

   } else if (inpWindowPosition==ML_WINPOSITION_LOWER_LEFT) {
      ObjectSetInteger( 0, _SymbolName, OBJPROP_CORNER, CORNER_LEFT_LOWER );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_XDISTANCE, inpXOffSet );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_YDISTANCE, inpYOffSet);

   } else if (inpWindowPosition==ML_WINPOSITION_LOWER_RIGHT) {
      ObjectSetInteger( 0, _SymbolName, OBJPROP_CORNER, CORNER_RIGHT_LOWER );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_XDISTANCE, inpXOffSet );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_YDISTANCE, inpYOffSet);

   } else if (inpWindowPosition==ML_WINPOSITION_LOWER_CENTER) {
      ObjectSetInteger( 0, _SymbolName, OBJPROP_CORNER, CORNER_LEFT_LOWER );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_XDISTANCE, inpXOffSet+ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0)/2 );
      ObjectSetInteger( 0, _SymbolName, OBJPROP_YDISTANCE, inpYOffSet);
   }
}
//+------------------------------------------------------------------+
