//+------------------------------------------------------------------+
//|                                      Extending the Rectangle.mq5 |
//|                              Copyright © 2022, Vladimir Karputov |
//|                      https://www.mql5.com/en/users/barabashkakvn |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Vladimir Karputov"
#property link      "https://www.mql5.com/en/users/barabashkakvn"
#property version   "1.000"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
//--- input parameters
input group             "Main settings"
input string               InpPrefix            = "Rect_";  // Watch for a rectangle whose name starts with ...
input group             "Up Line"
sinput string              Inp_Up_Prefix        = "Up Line";         // "Up Line": Prefix
sinput color               Inp_Up_Color         = clrMediumOrchid;   // "Up Line": Line color
sinput ENUM_LINE_STYLE     Inp_Up_Style         = STYLE_DASH;        // "Up Line": Line style
sinput int                 Inp_Up_Width         = 2;                 // "Up Line": Line width
sinput bool                Inp_Up_Back          = false;             // "Up Line": Background line
sinput bool                Inp_Up_Selection     = false;             // "Up Line": Highlight to move
sinput bool                Inp_Up_RayLeft       = false;             // "Up Line": Line's continuation to the left
sinput bool                Inp_Up_RayRight      = false;             // "Up Line": Line's continuation to the right
sinput bool                Inp_Up_Hidden        = true;              // "Up Line": Hidden in the object list
sinput long                Inp_Up_ZOrder        = 0;                 // "Up Line": Priority for mouse click
input group             "Down Line"
sinput string              Inp_Down_Prefix      = "Down Line";       // "Down Line": Prefix
sinput color               Inp_Down_Color       = clrMediumOrchid;   // "Down Line": Line color
sinput ENUM_LINE_STYLE     Inp_Down_Style       = STYLE_DASH;        // "Down Line": Line style
sinput int                 Inp_Down_Width       = 2;                 // "Down Line": Line width
sinput bool                Inp_Down_Back        = false;             // "Down Line": Background line
sinput bool                Inp_Down_Selection   = false;             // "Down Line": Highlight to move
sinput bool                Inp_Down_RayLeft     = false;             // "Down Line": Line's continuation to the left
sinput bool                Inp_Down_RayRight    = false;             // "Down Line": Line's continuation to the right
sinput bool                Inp_Down_Hidden      = true;              // "Down Line": Hidden in the object list
sinput long                Inp_Down_ZOrder      = 0;                 // "Down Line": Priority for mouse click
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
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
//--- return value of prev_calculated for next call
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
//--- object created OR changed object
   if(id==CHARTEVENT_OBJECT_CREATE || id==CHARTEVENT_OBJECT_CHANGE || id==CHARTEVENT_OBJECT_DRAG)
     {
      if(StringFind(sparam,InpPrefix,0)!=0)
         return;
      //---
      if(id==CHARTEVENT_OBJECT_CREATE)
         Print("Created object named ",sparam);
      if(id==CHARTEVENT_OBJECT_CHANGE)
         Print("Changed object named ",sparam);
      if(id==CHARTEVENT_OBJECT_DRAG)
         Print("Changing anchor points of object named ",sparam);
      //---
      string postfix=StringSubstr(sparam,StringLen(InpPrefix)-1,-1);
      long chart_id=ChartID();
      //--
      double price_modifier_0=ObjectGetDouble(chart_id,sparam,OBJPROP_PRICE,0);
      double price_modifier_1=ObjectGetDouble(chart_id,sparam,OBJPROP_PRICE,1);
      double price_up=0.0,price_down=0.0;
      if(price_modifier_0>price_modifier_1)
        {
         price_up=price_modifier_0;
         price_down=price_modifier_1;
        }
      else
        {
         price_up=price_modifier_1;
         price_down=price_modifier_0;
        }
      //---
      long time_modifier_0=ObjectGetInteger(chart_id,sparam,OBJPROP_TIME,0);
      long time_modifier_1=ObjectGetInteger(chart_id,sparam,OBJPROP_TIME,1);
      datetime time_left=(time_modifier_0>time_modifier_1)?((datetime)time_modifier_0):((datetime)time_modifier_1);
      datetime time_right=TimeCurrent();
      Print("time_left ",time_left,", time_right ",time_right);
      //---
      if(ObjectFind(chart_id,Inp_Up_Prefix+postfix)!=0)
        {
         if(TrendCreate(chart_id,Inp_Up_Prefix+postfix,0,time_left,price_up,time_right,price_up,
                        Inp_Up_Color,
                        Inp_Up_Style,
                        Inp_Up_Width,
                        Inp_Up_Back,
                        Inp_Up_Selection,
                        Inp_Up_RayLeft,
                        Inp_Up_RayRight,
                        Inp_Up_Hidden,
                        Inp_Up_ZOrder))
           {
            Print("Create '",Inp_Up_Prefix,"' OK");
            ChartRedraw();
           }
         else
            Print("Create '",Inp_Up_Prefix,"' ERROR");
        }
      else
        {
         TrendPointChange(chart_id,Inp_Up_Prefix+postfix,0,time_left,price_up);
         TrendPointChange(chart_id,Inp_Up_Prefix+postfix,1,time_right,price_up);
         ChartRedraw();
        }
      //---
      if(ObjectFind(chart_id,Inp_Down_Prefix+postfix)!=0)
        {
         if(TrendCreate(chart_id,Inp_Down_Prefix+postfix,0,time_left,price_down,time_right,price_down,
                        Inp_Down_Color,
                        Inp_Down_Style,
                        Inp_Down_Width,
                        Inp_Down_Back,
                        Inp_Down_Selection,
                        Inp_Down_RayLeft,
                        Inp_Down_RayRight,
                        Inp_Down_Hidden,
                        Inp_Down_ZOrder))
           {
            Print("Create '",Inp_Down_Prefix,"' OK");
            ChartRedraw();
           }
         else
            Print("Create '",Inp_Down_Prefix,"' ERROR");
        }
      else
        {
         TrendPointChange(chart_id,Inp_Down_Prefix+postfix,0,time_left,price_down);
         TrendPointChange(chart_id,Inp_Down_Prefix+postfix,1,time_right,price_down);
         ChartRedraw();
        }
     }
  }
//+------------------------------------------------------------------+
//| Create a trend line by the given coordinates                     |
//+------------------------------------------------------------------+
bool TrendCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="TrendLine",  // line name
                 const int             sub_window=0,      // subwindow index
                 datetime              time1=0,           // first point time
                 double                price1=0,          // first point price
                 datetime              time2=0,           // second point time
                 double                price2=0,          // second point price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=2,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=false,   // highlight to move
                 const bool            ray_left=false,    // line's continuation to the left
                 const bool            ray_right=false,   // line's continuation to the right
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create a trend line by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": failed to create a trend line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of continuation of the line's display to the left
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_LEFT,ray_left);
//--- enable (true) or disable (false) the mode of continuation of the line's display to the right
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Move trend line anchor point                                     |
//+------------------------------------------------------------------+
bool TrendPointChange(const long   chart_ID=0,       // chart's ID
                      const string name="TrendLine", // line name
                      const int    point_index=0,    // anchor point index
                      datetime     time=0,           // anchor point time coordinate
                      double       price=0)          // anchor point price coordinate
  {
//--- if point position is not set, move it to the current bar having Bid price
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move trend line's anchor point
   if(!ObjectMove(chart_ID,name,point_index,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
