//+------------------------------------------------------------------+
//|                                             SimpleRegression.mq4 |
//|                                                        hairibaba |
//|                              https://www.mql5.com/en/users/hairi |
//+------------------------------------------------------------------+

#property copyright     "Coded by Hairibaba"
#property link          "https://www.mql5.com/en/users/hairi"
#property version       "1.0"
#property description   "Regression"
#property strict
#property indicator_chart_window

//+------------------------------------------------------------------+
//| Input variable                                                   |
//+------------------------------------------------------------------+
input int LookbackPeriod = 30;
input ENUM_TIMEFRAMES AppliedTimeframe = PERIOD_H4;
input ENUM_LINE_STYLE RegressionStyle = STYLE_SOLID;
input color RegressionColor = clrDarkBlue;

//+------------------------------------------------------------------+
//| Global variable                                                  |
//+------------------------------------------------------------------+
string      Objname, ObjIdentifier = "RC_";

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   return (0);
}

//+------------------------------------------------------------------+
//| Deinit                                                           |
//+------------------------------------------------------------------+
int deinit() 
{
   ObjectDeleteAll();
   return (0);
}

//+------------------------------------------------------------------+
//| Indicator Start                                                  |
//+------------------------------------------------------------------+
int start() 
{
   for (int BarMeasure = 0; BarMeasure <= 240; BarMeasure++) 
      DrawRegressionChannel("Regression",AppliedTimeframe,LookbackPeriod,1,RegressionStyle,RegressionColor,2,true);  
   return (0);
}

//+------------------------------------------------------------------+
//| Delete all function                                              |
//+------------------------------------------------------------------+
void ObjectDeleteAll()
{
   Comment("");
   ObjectsDeleteAll(0,ObjIdentifier);
}

//+------------------------------------------------------------------+
//| Draw regression channel function                                 |
//+------------------------------------------------------------------+
void DrawRegressionChannel(string name, int TF, int Bar0, int Bar1, int style, color clr, int width, bool ray)
{   
   double P0 = 0, P1 = 0;
   datetime T0 = iTime(Symbol(),TF,Bar0);
   datetime T1 = iTime(Symbol(),TF,Bar1);
   
   if (ObjectFind(0,ObjIdentifier+name) != 0)
      ObjectCreate(ObjIdentifier+name,OBJ_REGRESSION, 0, T0, P0, T1, P1 );
   else
   {
      ObjectDelete(ObjIdentifier+name);
      ObjectCreate(ObjIdentifier+name,OBJ_REGRESSION, 0, T0, P0, T1, P1 );
   }
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_WIDTH, width);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_RAY, ray);
   ObjectSetInteger(0,ObjIdentifier+name,OBJPROP_BACK,false);
   ObjectSetString(0,ObjIdentifier+name,OBJPROP_TEXT,name+" Channel");
   
   Sleep(50);
   ChartRedraw(); 
}