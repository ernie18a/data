//+------------------------------------------------------------------+
//|                                                        Piano.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.004"
#property description "The state of the bars (bearish or bullish) on all timeframes"
#include <Canvas\Canvas.mqh>
CCanvas m_canvas;
//--- input parameters
input color clr_background    = clrAquamarine;     // background
input uchar alpha_background  = 150;               // background alpha
input color clr_text          = clrRed;            // text color 
input uchar alpha_text        = 255;               // text alpha 
//---
ENUM_TIMEFRAMES timeframes[21]=
  {
   PERIOD_M1,PERIOD_M2,PERIOD_M3,
   PERIOD_M4,PERIOD_M5,PERIOD_M6,
   PERIOD_M10,PERIOD_M12,PERIOD_M15,
   PERIOD_M20,PERIOD_M30,PERIOD_H1,
   PERIOD_H2,PERIOD_H3,PERIOD_H4,
   PERIOD_H6,PERIOD_H8,PERIOD_H12,
   PERIOD_D1,PERIOD_W1,PERIOD_MN1
  };
//---
bool     first_start          = false;
string   canvas_name          = "Piano";
int      canvas_x             = 10;
int      canvas_y             = 15;
int      canvas_width         = 400;
int      canvas_height        = 90;
long     prev_show_one_click  = -1;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   prev_show_one_click=ChartGetInteger(0,CHART_SHOW_ONE_CLICK);
//---
   MqlRates rates[1];
   for(int i=0;i<ArraySize(timeframes);i++)
     {
      CopyRates(Symbol(),timeframes[i],0,1,rates);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   switch(reason)
     {
      case REASON_PROGRAM:
         /*Expert Advisor terminated its operation by calling
         the ExpertRemove() function*/
         m_canvas.Destroy();break;

      case REASON_REMOVE:
         /*Program has been deleted from the chart*/
         m_canvas.Destroy();break;

      case REASON_RECOMPILE:
         /*Program has been recompiled*/
         m_canvas.Destroy();break;

      case REASON_CHARTCHANGE:
         /*Symbol or chart period has been changed*/
         break;

      case REASON_CHARTCLOSE:
         /*Chart has been closed*/
         break;

      case REASON_PARAMETERS:
         /*Input parameters have been changed by a user*/
         break;

      case REASON_ACCOUNT:
         /*Another account has been activated or reconnection
         to the trade server has occurred due to changes
         in the account settings*/
         break;

      case REASON_TEMPLATE:
         /*A new template has been applied*/
         break;

      case REASON_INITFAILED:
         /*This value means that OnInit() handler
         has returned a nonzero value*/
         break;

      case REASON_CLOSE:
         /*Terminal has been closed*/
         m_canvas.Destroy();break;
     }

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!first_start)
     {
      long temp=ChartGetInteger(0,CHART_SHOW_ONE_CLICK);
      prev_show_one_click=temp;
      int temp_y=(prev_show_one_click==0)?canvas_y:canvas_y+72;
      //--- COLOR_FORMAT_ARGB_NORMALIZE
      if(!m_canvas.CreateBitmapLabel(canvas_name,canvas_x,temp_y,canvas_width,canvas_height,COLOR_FORMAT_ARGB_NORMALIZE))
        {
         Print("Error creating canvas: ",GetLastError());
         return;
        }
      m_canvas.FontNameSet("Consolas");
      m_canvas.Erase(ColorToARGB(clr_background,alpha_background));
      m_canvas.Update();
      first_start=true;
     }
//---
   string text1="";
   string text2="";
   string text3="";
   MqlRates rates[3];
   for(int i=0;i<ArraySize(timeframes);i++)
     {
      int copied=CopyRates(Symbol(),timeframes[i],0,3,rates);
      string temp1="";
      string temp2="";
      string temp3="";
      if(rates[0].open<rates[0].close)
         temp1="1";
      else if(rates[0].open>rates[0].close)
         temp1="0";
      else
         temp1="-";
      text1=text1+"*"+temp1;

      if(rates[1].open<rates[1].close)
         temp2="1";
      else if(rates[1].open>rates[1].close)
         temp2="0";
      else
         temp2="-";
      text2=text2+"*"+temp2;

      if(rates[2].open<rates[2].close)
         temp3="1";
      else if(rates[2].open>rates[2].close)
         temp3="0";
      else
         temp3="-";
      text3=text3+"*"+temp3;
     }
   int x=10;
   int y=10;
   int text_height=20;
   int gap_y=5;
   m_canvas.Erase(ColorToARGB(clr_background,alpha_background));
   m_canvas.TextOut(x,y,text1,ColorToARGB(clr_text,alpha_text));
   m_canvas.TextOut(x,y+gap_y+text_height,text2,ColorToARGB(clr_text,alpha_text));
   m_canvas.TextOut(x,y+(gap_y+text_height)*2,text3,ColorToARGB(clr_text,alpha_text));
   m_canvas.Update();
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
   if(id!=CHARTEVENT_CHART_CHANGE)
      return;
   long temp=ChartGetInteger(0,CHART_SHOW_ONE_CLICK);
   if(temp==prev_show_one_click)
      return;
   prev_show_one_click=temp;
   int temp_y=(prev_show_one_click==0)?canvas_y:canvas_y+70;
   string temp_name=m_canvas.ChartObjectName();
//--- reset the error value 
   ResetLastError();
//--- move the object 
   if(!ObjectSetInteger(0,temp_name,OBJPROP_YDISTANCE,temp_y))
     {
      Print(__FUNCTION__,
            ": failed to move X coordinate of the object! Error code = ",GetLastError());
      return;
     }
  }
//+------------------------------------------------------------------+
