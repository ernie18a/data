//+------------------------------------------------------------------+
//|                                          AutoBringChartToTop.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
//MT5 Version: https://www.mql5.com/en/code/18467
//MT4 Version: https://www.mql5.com/en/code/18466
//2021-08-31 14:43:01 Fixed the bug of not working in template.
//2017-05-25 12:42:27 publish to MQL5.COM codebase
//2016-02-18 14:51:31 add input ENUM_BASE_CORNER Corner=3;
/*
Note:
https://www.mql5.com/en/docs/constants/objectconstants/enum_anchorpoint
The OBJ_BUTTON, OBJ_RECTANGLE_LABEL and OBJ_EDIT objects
have a fixed anchor point in the upper left corner (ANCHOR_LEFT_UPPER).
*/

//2014-5-1 22:07 coded

#property copyright "Copyright 2014,fxMeter."
#property link      "https://www.mql5.com/en/users/fxmeter"
#property version   "2.00"
#property strict
#property indicator_chart_window
#include <ChartObjects\ChartObjectsTxtControls.mqh>
//--- input parameters
input ENUM_BASE_CORNER Corner=3;
input int  ShiftX=5;
input int  ShiftY=15;
input int  IntervalSeconds=3;

CChartObjectButton ExtBtn; //object to create button
string btnName="fmtbtnAlt_show";//button name
long chartToTop=-1,nextChart=-1;//chartID to bringh it top, next ChartID to bring to top
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//---

//--- create button
   int width=100,height=30;// width and height of button
   if(!ButtonCreate(ExtBtn,btnName,ShiftX,ShiftY,width,height,Corner))
   {
      Alert("Create buttons failed!");
      return(INIT_FAILED);
   }
   ExtBtn.SetString(OBJPROP_TEXT,"OFF");// init button text to OFF

//---set timer
   if(!EventSetTimer(IntervalSeconds))
      return(INIT_FAILED);
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   ObjectDelete(0,btnName);
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

//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---
   if(chartToTop>0)// or if(ExtBtn.GetString(OBJPROP_TEXT)=="ON")
   {
      ChartSetInteger(chartToTop,CHART_BRING_TO_TOP,true);

      nextChart=ChartNext(chartToTop);// if nextChart==-1,chartToTop=ChartFirst();
      chartToTop=nextChart;
      if(chartToTop==-1)chartToTop=ChartFirst();

   }

}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{

//--- click button to switch ON/OFF
   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if(sparam==btnName)//button is clicked
      {
         if(chartToTop==-1)// or if(ExtBtn.GetString(OBJPROP_TEXT)=="OFF")
         {
            ExtBtn.SetString(OBJPROP_TEXT,"ON");//set the current state to ON
            ExtBtn.BackColor(clrYellowGreen);
            ExtBtn.BorderColor(clrYellowGreen);
            chartToTop=ChartFirst();//work from the first chart.
         }
         else //switch to OFF
         {
            ExtBtn.SetString(OBJPROP_TEXT,"OFF");//set the current state to OFF
            ExtBtn.BackColor(clrTomato);
            ExtBtn.BorderColor(clrTomato);
            chartToTop=-1; // stop
         }
      }
   }

}
//+------------------------------------------------------------------+
bool ButtonCreate(CChartObjectButton &btn,const string name,
                  const int x,const int y,int width,int height,ENUM_BASE_CORNER corner=CORNER_RIGHT_LOWER)
{

//---button coordinate, relative to the corner of chart
   int pointX=0,pointY=0;//Exactly,it is the coordinate of the button's LEFT_UPPER

//---Note:when create buttons,the anchor point is always the button's LEFT_UPPER
//---It means we should use the coordinate of the LEFT_UPPER point to create button.
//---So,calculte the coordinate of the LEFT_UPPER point (anchor point)

   /* this code is ok in MQL4,but it is not correct in MQL5.
      if(corner==0){ pointX=x; pointY=y;} //corner=0,button is at the left upper of chart
      if(corner==1){ pointX= x+width; pointY = y;} //1
      if(corner==2){ pointX = x; pointY = height+y;}//2
      if(corner==3){ pointX=x+width; pointY=y+height;}//3
   */

   if(corner==CORNER_LEFT_UPPER)
   {
      pointX=x;   //corner=0,button is at the left upper of chart
      pointY=y;
   }
   if(corner==CORNER_RIGHT_UPPER)
   {
      pointX= x+width;   //1
      pointY = y;
   }
   if(corner==CORNER_LEFT_LOWER)
   {
      pointX = x;   //2
      pointY = height+y;
   }
   if(corner==CORNER_RIGHT_LOWER)
   {
      pointX=x+width;   //3
      pointY=y+height;
   }
//---
   ObjectDelete(0,name);
//---Create button
   if(!btn.Create(0,name,0,pointX,pointY,width,height)) return(false);
   if(!btn.Corner(corner)) return(false);
   if(!btn.FontSize(10)) return(false);
   if(!btn.Color(clrWhite)) return(false);//OBJPROP_COLOR: the color of text on button
   if(!btn.BackColor(clrTomato)) return(false);//OBJPROP_BGCOLOR
   if(!btn.BorderColor(clrTomato)) return(false);//OBJPROP_BORDER_COLOR,same as backcolor to make button flat.
   if(!btn.SetInteger(OBJPROP_HIDDEN,true))return(false);
   if(!btn.SetInteger(OBJPROP_SELECTABLE,false))return(false);
//--- successful execution
   return(true);
}
//+------------------------------------------------------------------+
