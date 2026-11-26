//+------------------------------------------------------------------+
//|                                      TrainingChartController.mq4 |
//+------------------------------------------------------------------+
#property strict
#property indicator_chart_window

enum LeftToRight { Left, Center, Right };

//--- input parameters
input datetime iStart = D'2019.06.01 00:00:00'; // Start date/time
input string strChartName = "";                 // Name of this Chart
input bool bNameAtBottom = true;                // Name at Bottom (false=top)
input LeftToRight bNameLToR = Center;           // Name at Left/Center/Right
input color iNameColor = clrWhite;              // Color of Chart Name
input int iFontSize = 13;                       // Size of Name

string gvNameStart, gvNameNextBar, gvNameRestart;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   gvNameStart = "TrainingChart-Start-"+Symbol()+"-"+string(Period());
   gvNameNextBar = "TrainingChart-NextBar-"+Symbol()+"-"+string(Period());
   gvNameRestart = "TrainingChart-Restart-"+Symbol()+"-"+string(Period());

   GlobalVariableSet(gvNameStart,iStart);

   EventSetMillisecondTimer(500);
   
   Comment ("'n'-NextBar, 'b'-PrevBar, 'r'-Reset");

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
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
   return(rates_total);
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (id==CHARTEVENT_KEYDOWN)
   {
      if (TranslateKey((int)lparam)=='n')
         GlobalVariableSet(gvNameNextBar,1);
      if (TranslateKey((int)lparam)=='b')
         GlobalVariableSet(gvNameNextBar,-1);
      if (TranslateKey((int)lparam)=='r')
         GlobalVariableSet(gvNameRestart,1);
   }
}

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
   long iCID = ChartID();
   string strChartObj = "ChartObj";
   
   long iXDistance, iYDistance;
   iXDistance = ChartGetInteger(iCID,CHART_WIDTH_IN_PIXELS,0);
   iYDistance = long(ChartGetInteger(iCID,CHART_HEIGHT_IN_PIXELS,0));
   
   if (bNameAtBottom)
   {
      if (iYDistance*0.98>iFontSize/2)
         iYDistance = iYDistance-(iFontSize/2+4);
      else
         iYDistance = long(iYDistance*0.98);
   }
   else
   {
      if (iYDistance*0.02<iFontSize/2)
         iYDistance = iFontSize/2+4;
      else
         iYDistance = long(iYDistance*0.02);
   }
   
   if (ObjectFind(iCID,strChartObj)!=0)
      ObjectCreate(iCID,strChartObj,OBJ_LABEL,0,100,100);
      
   ObjectSetText(strChartObj,strChartName);
   
   if (bNameLToR==Left)
   {
      iXDistance = 4;
      ObjectSetInteger(iCID,strChartObj,OBJPROP_XDISTANCE,iXDistance);
      ObjectSetInteger(iCID,strChartObj,OBJPROP_YDISTANCE,iYDistance);
      ObjectSetInteger(iCID,strChartObj,OBJPROP_ANCHOR,ANCHOR_LEFT);
   }
   else
   if (bNameLToR==Center)
   {
      ObjectSetInteger(iCID,strChartObj,OBJPROP_XDISTANCE,iXDistance/2);
      ObjectSetInteger(iCID,strChartObj,OBJPROP_YDISTANCE,iYDistance);
      ObjectSetInteger(iCID,strChartObj,OBJPROP_ANCHOR,ANCHOR_CENTER);
   }
   else
   if (bNameLToR==Right)
   {
      iXDistance = iXDistance - 4;
      ObjectSetInteger(iCID,strChartObj,OBJPROP_XDISTANCE,iXDistance);
      ObjectSetInteger(iCID,strChartObj,OBJPROP_YDISTANCE,iYDistance);
      ObjectSetInteger(iCID,strChartObj,OBJPROP_ANCHOR,ANCHOR_RIGHT);
   }
   
   ObjectSetInteger(iCID,strChartObj,OBJPROP_FONTSIZE,iFontSize);
   ObjectSetInteger(iCID,strChartObj,OBJPROP_COLOR,iNameColor);
   ObjectSetInteger(iCID,strChartObj,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(iCID,strChartObj,OBJPROP_HIDDEN,true);
}
