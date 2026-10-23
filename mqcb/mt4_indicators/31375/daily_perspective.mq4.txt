//+------------------------------------------------------------------+
//|                                            Daily Perspective.mq4 |
//|                                                    Jan Opocensky |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Jan Opocensky"
#property link      ""
#property version   "221.221"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
input ENUM_LINE_STYLE SRLineStyle = STYLE_DASH; // Support/Resistance Line Style
//----
enum ENUM_ALARM_MODE
{
Active      =  1,
Non_active  =  2
};
input ENUM_ALARM_MODE AlarmMode = Active;  
//---
input int MovingAveragePeriod          =  100;
int UPTREND_Counter;
int DOWNTREND_Counter;
int TimeFrame;
int RecreationTimeMinute   =  5;
datetime RecreationTime = 0;
int BodyColor;
int UPBARBodyColor      =  clrPaleGreen;
int DOWNBARBodyColor    =  clrPink;
string InternalBodyRectangle1,InternalBodyRectangle2,InternalBodyRectangle3;
string BorderBodyRectangle1,BorderBodyRectangle2,BorderBodyRectangle3;
string UpperShadow1,UpperShadow2,UpperShadow3;
string LowerShadow1,LowerShadow2,LowerShadow3;
string HighLine1,HighLine2,HighLine3; 
string LowLine1,LowLine2,LowLine3;
string OpenLine1,OpenLine2,OpenLine3;
string CloseLine1,CloseLine2,CloseLine3;
//+------------------------------------------------------------------+
int extern FirstCandleIndex =  1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//
EventSetTimer(RecreationTimeMinute*PeriodSeconds(PERIOD_M1)*60);
DrawDailyCandles(); 
//Comment("FirstCandleIndex = ",FirstCandleIndex);
//
//   
//---
   return(INIT_SUCCEEDED);
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

 // DrawDailyCandles();
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
DrawDailyCandles();
//Comment("FirstCandleIndex = ",FirstCandleIndex);    
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
  
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
//------------------------------------------
//------- OBJECTS DELETE - START -----------
//------------------------------------------
for (int i=0;i<6;i++)
{
ObjectDelete   (  "InternalBodyRectangle" + IntegerToString(i) );
ObjectDelete   (  "BorderBodyRectangle" + IntegerToString(i) );
ObjectDelete   (  "UpperShadow" + IntegerToString(i) );
ObjectDelete   (  "LowerShadow" + IntegerToString(i) );
ObjectDelete   (  "HighLine" + IntegerToString(i) );
ObjectDelete   (  "LowLine" + IntegerToString(i) );
ObjectDelete   (  "OpenLine" + IntegerToString(i) );
ObjectDelete   (  "CloseLine" + IntegerToString(i) );
}
//------------------------------------------
//------- OBJECTS DELETE - END -------------
//------------------------------------------   
  }
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//|     Custom function - START                                      |
//+------------------------------------------------------------------+
void DrawDailyCandles() 
{

//---------------------------------------------------------------------------------------
//----------------------- FIRST CANDLE INDEX SET - START --------------------------------
//---------------------------------------------------------------------------------------
//if ((DayOfWeek()==6) || (DayOfWeek()==0)) {FirstCandleIndex=0;}  // 0-Sunday,1,2,3,4,5,6
//---------------------------------------------------------------------------------------
//if ((DayOfWeek()<6)  && (DayOfWeek()>0))  {FirstCandleIndex=1;}  // 0-Sunday,1,2,3,4,5,6 
//---------------------------------------------------------------------------------------
//----------------------- FIRST CANDLE INDEX SET - END --------------------------------
//---------------------------------------------------------------------------------------

//------------------------------------------
//------- OBJECTS DELETE - START -----------
//------------------------------------------
for (int i=0;i<6;i++)
{
ObjectDelete   (  "InternalBodyRectangle" + IntegerToString(i) );
ObjectDelete   (  "BorderBodyRectangle" + IntegerToString(i) );
ObjectDelete   (  "UpperShadow" + IntegerToString(i) );
ObjectDelete   (  "LowerShadow" + IntegerToString(i) );
ObjectDelete   (  "HighLine" + IntegerToString(i) );
ObjectDelete   (  "LowLine" + IntegerToString(i) );
ObjectDelete   (  "OpenLine" + IntegerToString(i) );
ObjectDelete   (  "CloseLine" + IntegerToString(i) );
}
//------------------------------------------
//------- OBJECTS DELETE - END -------------
//------------------------------------------   


//=================================================================
//========== DAILY BAR CREATION - START ===========================
//=================================================================
for (int n=FirstCandleIndex;n<FirstCandleIndex+3;n++)
{
//=================================================================
if (iOpen(Symbol(),PERIOD_D1,n)>iClose(Symbol(),PERIOD_D1,n)) {BodyColor=DOWNBARBodyColor;} else {BodyColor=UPBARBodyColor;}
//=================================================================
Rectangle
(
"InternalBodyRectangle" + IntegerToString(n),
iTime(Symbol(),PERIOD_D1,n)+(8)*PeriodSeconds(PERIOD_H1),
iOpen(Symbol(),PERIOD_D1,n),
iTime(Symbol(),PERIOD_D1,n)+(16)*PeriodSeconds(PERIOD_H1),
iClose(Symbol(),PERIOD_D1,n),
BodyColor,
1
);
//=================================================================
Rectangle
(
"BorderBodyRectangle" + IntegerToString(n),
iTime(Symbol(),PERIOD_D1,n)+(8)*PeriodSeconds(PERIOD_H1),
iOpen(Symbol(),PERIOD_D1,n),
iTime(Symbol(),PERIOD_D1,n)+(16)*PeriodSeconds(PERIOD_H1),
iClose(Symbol(),PERIOD_D1,n),
clrBlack,
0
);
//=================================================================
}
//=================================================================
//========== DAILY BAR CREATION - END ===========================
//=================================================================




//=================================================================
//========== UPPER SHADOW CREATION - START ========================
//=================================================================
for (int n=FirstCandleIndex;n<FirstCandleIndex+3;n++)
{
//=================================================================
if (iOpen(Symbol(),PERIOD_D1,n)<iClose(Symbol(),PERIOD_D1,n))
{
//---
VerticalLine
(
"UpperShadow" + IntegerToString(n),
iTime(Symbol(),PERIOD_D1,n)+(12)*PeriodSeconds(PERIOD_H1),
iHigh(Symbol(),PERIOD_D1,n),
iClose(Symbol(),PERIOD_D1,n),
clrBlack,
1
);
//---
}
//=================================================================
if (iOpen(Symbol(),PERIOD_D1,n)>iClose(Symbol(),PERIOD_D1,n))
{
//---
VerticalLine
(
"UpperShadow" + IntegerToString(n),
iTime(Symbol(),PERIOD_D1,n)+(12)*PeriodSeconds(PERIOD_H1),
iHigh(Symbol(),PERIOD_D1,n),
iOpen(Symbol(),PERIOD_D1,n),
clrBlack,
1
);
//---
}
//=================================================================
}
//=================================================================
//========== UPPER SHADOW CREATION - END ==========================
//=================================================================

//=================================================================
//========== LOWER SHADOW CREATION - START ========================
//=================================================================
for (int n=FirstCandleIndex;n<FirstCandleIndex+3;n++)
{
//=================================================================
if (iOpen(Symbol(),PERIOD_D1,n)<iClose(Symbol(),PERIOD_D1,n))
{
//---
VerticalLine
(
"LowerShadow" + IntegerToString(n),
iTime(Symbol(),PERIOD_D1,n)+(12)*PeriodSeconds(PERIOD_H1),
iOpen(Symbol(),PERIOD_D1,n),
iLow(Symbol(),PERIOD_D1,n),
clrBlack,
1
);
//---
}
//=================================================================
if (iOpen(Symbol(),PERIOD_D1,n)>iClose(Symbol(),PERIOD_D1,n))
{
//---
VerticalLine
(
"LowerShadow" + IntegerToString(n),
iTime(Symbol(),PERIOD_D1,n)+(12)*PeriodSeconds(PERIOD_H1),
iClose(Symbol(),PERIOD_D1,n),
iLow(Symbol(),PERIOD_D1,n),
clrBlack,
1
);
//---
}
//=================================================================
}
//=================================================================
//========== LOWER SHADOW CREATION - END ==========================
//=================================================================




//=================================================================
//========== 1 SR LINE CREATION - START ========================
//=================================================================
HorizontalLine
(
"HighLine" + IntegerToString(FirstCandleIndex),
iTime(Symbol(),PERIOD_D1,FirstCandleIndex)+(12)*PeriodSeconds(PERIOD_H1),
iTime(Symbol(),PERIOD_D1,0)+PeriodSeconds(PERIOD_D1),
iHigh(Symbol(),PERIOD_D1,FirstCandleIndex),
clrBlack,
1,
SRLineStyle
);
//----
HorizontalLine
(
"LowLine" + IntegerToString(FirstCandleIndex),
iTime(Symbol(),PERIOD_D1,FirstCandleIndex)+(12)*PeriodSeconds(PERIOD_H1),
iTime(Symbol(),PERIOD_D1,0)+PeriodSeconds(PERIOD_D1),
iLow(Symbol(),PERIOD_D1,FirstCandleIndex),
clrBlack,
1,
SRLineStyle
);
//----
HorizontalLine
(
"OpenLine" + IntegerToString(FirstCandleIndex),
iTime(Symbol(),PERIOD_D1,FirstCandleIndex)+(12)*PeriodSeconds(PERIOD_H1),
iTime(Symbol(),PERIOD_D1,0)+PeriodSeconds(PERIOD_D1),
iOpen(Symbol(),PERIOD_D1,FirstCandleIndex),
clrBlack,
1,
SRLineStyle
);
//----
HorizontalLine
(
"CloseLine" + IntegerToString(FirstCandleIndex),
iTime(Symbol(),PERIOD_D1,FirstCandleIndex)+(12)*PeriodSeconds(PERIOD_H1),
iTime(Symbol(),PERIOD_D1,0)+PeriodSeconds(PERIOD_D1),
iClose(Symbol(),PERIOD_D1,FirstCandleIndex),
clrBlack,
1,
SRLineStyle
);
//=================================================================
//========== 1 SR LINE CREATION - END ========================
//=================================================================

//=================================================================
//========== 2 SR LINE CREATION - START ========================
//=================================================================
//********
if ( iHigh(Symbol(),PERIOD_D1,FirstCandleIndex+1) > iHigh(Symbol(),PERIOD_D1,FirstCandleIndex) )
{
HorizontalLine
(
"HighLine" + IntegerToString(FirstCandleIndex+1),
iTime(Symbol(),PERIOD_D1,FirstCandleIndex+1)+(12)*PeriodSeconds(PERIOD_H1),
iTime(Symbol(),PERIOD_D1,0)+PeriodSeconds(PERIOD_D1),
iHigh(Symbol(),PERIOD_D1,FirstCandleIndex+1),
clrBlack,
1,
SRLineStyle
);
//----
}
//***********
if ( iLow(Symbol(),PERIOD_D1,FirstCandleIndex+1) < iLow(Symbol(),PERIOD_D1,FirstCandleIndex) )
{
HorizontalLine
(
"LowLine" + IntegerToString(FirstCandleIndex+1),
iTime(Symbol(),PERIOD_D1,FirstCandleIndex+1)+(12)*PeriodSeconds(PERIOD_H1),
iTime(Symbol(),PERIOD_D1,0)+PeriodSeconds(PERIOD_D1),
iLow(Symbol(),PERIOD_D1,FirstCandleIndex+1),
clrBlack,
1,
SRLineStyle
);
//----
}
//=================================================================
//========== 2 SR LINE CREATION - END ========================
//=================================================================

//=================================================================
//========== 3 SR LINE CREATION - START ========================
//=================================================================
if
(
iHigh(Symbol(),PERIOD_D1,FirstCandleIndex+2) > iHigh(Symbol(),PERIOD_D1,FirstCandleIndex) &&
iHigh(Symbol(),PERIOD_D1,FirstCandleIndex+2) > iHigh(Symbol(),PERIOD_D1,FirstCandleIndex+1)
 )
{
HorizontalLine
(
"HighLine" + IntegerToString(FirstCandleIndex+2),
iTime(Symbol(),PERIOD_D1,FirstCandleIndex+2)+(12)*PeriodSeconds(PERIOD_H1),
iTime(Symbol(),PERIOD_D1,0)+PeriodSeconds(PERIOD_D1),
iHigh(Symbol(),PERIOD_D1,FirstCandleIndex+2),
clrBlack,
1,
SRLineStyle
);
//----
}
//***********
if
(
iLow(Symbol(),PERIOD_D1,FirstCandleIndex+2) < iLow(Symbol(),PERIOD_D1,FirstCandleIndex) &&
iLow(Symbol(),PERIOD_D1,FirstCandleIndex+2) < iLow(Symbol(),PERIOD_D1,FirstCandleIndex+1)
 )
{
HorizontalLine
(
"LowLine" + IntegerToString(FirstCandleIndex+2),
iTime(Symbol(),PERIOD_D1,FirstCandleIndex+2)+(12)*PeriodSeconds(PERIOD_H1),
iTime(Symbol(),PERIOD_D1,0)+PeriodSeconds(PERIOD_D1),
iLow(Symbol(),PERIOD_D1,FirstCandleIndex+2),
clrBlack,
1,
SRLineStyle
);
//----
}
//=================================================================
//========== 3 SR LINE CREATION - END ========================
//=================================================================


//=================================================================
//========== TREND CONTROL - START ========================
//=================================================================
UPTREND_Counter  =   0;
DOWNTREND_Counter  = 0;

for (int n=1;n<6;n++)
{
//---
if (n==1) {TimeFrame=PERIOD_H1;}    
if (n==2) {TimeFrame=PERIOD_H4;}    
if (n==3) {TimeFrame=PERIOD_D1;}    
if (n==4) {TimeFrame=PERIOD_W1;}    
if (n==5) {TimeFrame=PERIOD_MN1;}  
//---
if (iMA (NULL,TimeFrame,MovingAveragePeriod,0,MODE_EMA,PRICE_CLOSE,1) > iMA (NULL,TimeFrame,MovingAveragePeriod,0,MODE_EMA,PRICE_CLOSE,2)) // UpTrend
{UPTREND_Counter    =  UPTREND_Counter + 1;}
//---
if (iMA (NULL,TimeFrame,MovingAveragePeriod,0,MODE_EMA,PRICE_CLOSE,1) < iMA (NULL,TimeFrame,MovingAveragePeriod,0,MODE_EMA,PRICE_CLOSE,2)) // DownTrend
{DOWNTREND_Counter  =  DOWNTREND_Counter + 1;}
//---
}
//=================================================================
//========== TREND CONTROL - END ========================
//=================================================================

//=================================================================
//========== ALARM - START ========================
//=================================================================
if (UPTREND_Counter   == 5 && (Ask > iHigh(NULL,PERIOD_D1,1)) && (AlarmMode == Active))
{ Alert("Daily Perspective Advisor say BUY on  " + Symbol() + " !!!");}
//---
if (DOWNTREND_Counter   == 5 && (Bid < iLow (NULL,PERIOD_D1,1)) && (AlarmMode == Active))
{ Alert("Daily Perspective Advisor say SELL on  " + Symbol() + " !!!");}
//=================================================================
//========== ALARM - END ========================
//=================================================================

//---
string AlarmModeString;
if (AlarmMode == Active) {AlarmModeString = "Alarm : Activated";} else {AlarmModeString = "Alarm : De-Activated";}
//+------------------------------------------------------------------+
   ObjectDelete   (  "AlarmModeText" );
   ObjectCreate   (  "AlarmModeText"   ,OBJ_LABEL,0,0,0,0,0); 
   ObjectSet      (  "AlarmModeText" ,OBJPROP_CORNER,CORNER_LEFT_LOWER); 
   ObjectSet      (  "AlarmModeText" ,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER); 
   ObjectSet      (  "AlarmModeText" ,OBJPROP_XDISTANCE,10);
   ObjectSet      (  "AlarmModeText" ,OBJPROP_YDISTANCE,10);
   ObjectSetText  (  "AlarmModeText" , AlarmModeString ,10,"Arial",clrBlack);
//+------------------------------------------------------------------+ 
//---


}
//+------------------------------------------------------------------+
//|     Custom function - START                                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void Rectangle
(
string RectangleName,
datetime LeftLowerCornerTime,
double LeftLowerCornerPrice,
datetime RightUpperCornerTime,
double RightUpperCornerPrice,
long RectangleColor,
bool Back
)
//-------------------------------------------------------------------
{
//-------------------------------------------------------------------
ObjectCreate
   (RectangleName,
   OBJ_RECTANGLE,
   0, // chart identifier, 0= main chart window
   //*******************
   LeftLowerCornerTime,
   LeftLowerCornerPrice,
   //*******************
   RightUpperCornerTime,
   RightUpperCornerPrice);
//-------------------------------------------------------------------   
ObjectSetInteger(
   0, // chart identifier, 0= main chart window
   RectangleName,
   OBJPROP_COLOR,
   RectangleColor
   ); 
//-------------------------------------------------------------------   
ObjectSetInteger(
   0, // chart identifier, 0= main chart window
   RectangleName,
   OBJPROP_BACK,
   Back
   ); 
//-------------------------------------------------------------------
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
void VerticalLine
(
string VerticalLineName,
datetime VerticalLineTime,
double VerticalLineTopPrice,
double VerticalLineBottomPrice,
long VerticalLineColor,
int LineWidth
)
//-------------------------------------------------------------------
{
//-------------------------------------------------------------------
ObjectDelete (VerticalLineName);
ObjectCreate
   (VerticalLineName,
   OBJ_TREND,
   0, // chart identifier, 0= main chart window
   //*******************
   VerticalLineTime,
   VerticalLineTopPrice,
   //*******************
   VerticalLineTime,
   VerticalLineBottomPrice);
//-------------------------------------------------------------------   
ObjectSetInteger(
   0, // chart identifier, 0= main chart window
   VerticalLineName,
   OBJPROP_COLOR,
   VerticalLineColor
   ); 
//-------------------------------------------------------------------
ObjectSetInteger(
   0, // chart identifier, 0= main chart window
   VerticalLineName,
   OBJPROP_RAY,
   false
   ); 
//-------------------------------------------------------------------
ObjectSetInteger(
   0, // chart identifier, 0= main chart window
   VerticalLineName,
   OBJPROP_WIDTH,
   LineWidth
   );     
//-------------------------------------------------------------------

}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void HorizontalLine
(
string HorizontalLineName,
datetime HorizontalLineLeftTime,
datetime HorizontalLineRightTime,
double HorizontalLinePrice,
long HorizontalLineColor,
int LineWidth,
int LineStyle

)
//-------------------------------------------------------------------
{
//-------------------------------------------------------------------
ObjectDelete (HorizontalLineName);
ObjectCreate
   (HorizontalLineName,
   OBJ_TREND,
   0, // chart identifier, 0= main chart window
   //*******************
   HorizontalLineLeftTime,
   HorizontalLinePrice,
   //*******************
   HorizontalLineRightTime,
   HorizontalLinePrice);
//-------------------------------------------------------------------   
ObjectSetInteger(
   0, // chart identifier, 0= main chart window
   HorizontalLineName,
   OBJPROP_COLOR,
   HorizontalLineColor
   ); 
//-------------------------------------------------------------------
ObjectSetInteger(
   0, // chart identifier, 0= main chart window
   HorizontalLineName,
   OBJPROP_RAY,
   false
   ); 
//-------------------------------------------------------------------
ObjectSetInteger(
   0, // chart identifier, 0= main chart window
   HorizontalLineName,
   OBJPROP_WIDTH,
   LineWidth
   );     
//-------------------------------------------------------------------
ObjectSetInteger(
   0, // chart identifier, 0= main chart window
   HorizontalLineName,
   OBJPROP_STYLE,
   LineStyle
   );     
//-------------------------------------------------------------------
}
//+------------------------------------------------------------------+