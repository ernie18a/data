//+------------------------------------------------------------------+
//|                                               PipsPercentage.mq5 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Ludovico Mattiuzzo"
#property link      "no-one"
#property version   "1.01"
#property indicator_chart_window
#property indicator_plots   0


int OnInit()
{
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,0,true);
         
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
   pipsPercentage.handleMouseEvent(id, lparam, dparam, sparam);
   
}


class PipsPercentage
{
   public: 
   
   PipsPercentage()
   {
      MY_TEXT = "CROSS_PIPS_PCT";
      MY_TEXT_BKG = "CROSS_PIPS_PCT_RECT";  
      startPrice = -1;
      
      ObjectDelete(0, MY_TEXT);
      ObjectDelete(0, MY_TEXT_BKG);                        
   }
   
   void handleMouseEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
   {
      if(id == CHARTEVENT_MOUSE_MOVE)
      {      
         int      subWindow = 0;
                                        
         if(sparam == "16")
         {
            CrossHairVisible = true;         
         }
         if(sparam == "1" && CrossHairVisible)
         {  
            if(startPrice < 0)
            {
               ChartXYToTimePrice(0, (int) lparam, (int) dparam, subWindow, startTime, startPrice);
            }
                                        
            BeginDrag = true;
         }
            
         if(sparam != "1" && BeginDrag)
         {
            BeginDrag = false;
            CrossHairVisible = false;
            hideLabel();
            startPrice = -1;
         }
            
         if(CrossHairVisible && BeginDrag)
         {
            double currentPrice;
            datetime currentTime;
            
            
            
            ChartXYToTimePrice(0, (int) lparam, (int) dparam, subWindow, currentTime, currentPrice);
            
            string pct = "";
            
            if(currentPrice > startPrice)
               pct = DoubleToString((currentPrice / startPrice - 1) * 100, 2) + "%";
            else
               pct = DoubleToString((1 - startPrice / currentPrice) * 100, 2) + "%";
               
            //pct = DoubleToString((currentPrice / startPrice - 1) * 100, 2) + "%";
            
            int timeSpan = MathAbs( currentTime - startTime);
            string timeSpanStr;
            
            if(timeSpan / 60 < 60)
               timeSpanStr = IntegerToString(timeSpan / 60) + " min";
            else if(timeSpan / 3600 < 24)
               timeSpanStr = IntegerToString(timeSpan / 3600) + " hours";
            else if(timeSpan / 3600 / 24.0 < 100)
               timeSpanStr = DoubleToString(timeSpan / 3600 / 24.0, 1) + " days";
            else if(timeSpan / 3600 / (30 * 24.0) < 19)
               timeSpanStr = DoubleToString(timeSpan / 3600 / (30 * 24.0), 1) + " months";
            else
               timeSpanStr = DoubleToString(timeSpan / 3600 / (365 * 24.0), 1) + " years";
            
            showLabel(StringFormat("%s / %s", pct, timeSpanStr), (int) MathMin(chartWidth - 80, (int) lparam + 5), (int) dparam - 15);
         }                    
         //Comment("X: ", lparam, " Y : ", dparam, " SPARAM: ", sparam);               
      }
      else if(id == CHARTEVENT_CHART_CHANGE)
         setChartWidth();
   }
   
  
   private:
   
   string   MY_TEXT;
   string   MY_TEXT_BKG;
   bool     CrossHairVisible;
   bool     BeginDrag;
   double   startPrice;
   datetime startTime;
   int      chartWidth;
   
   void setChartWidth()
   {
      chartWidth = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);
   }
   
   void showLabel(string text, int x, int y)
   {
      if(ObjectFind(0, MY_TEXT) < 0)
      {                      
         long foregroundColor = clrNONE;
         long backgroundColor = clrNONE;
         ChartGetInteger(0, CHART_COLOR_FOREGROUND, 0, foregroundColor);
         ChartGetInteger(0, CHART_COLOR_BACKGROUND, 0, backgroundColor);
         
         
         RectLabelCreate(0, MY_TEXT_BKG, 0, x - 2, y, 80, 18, backgroundColor, BORDER_FLAT, CORNER_LEFT_UPPER);
         
                  
         ObjectCreate(0, MY_TEXT, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, MY_TEXT, OBJPROP_XDISTANCE, x);
         ObjectSetInteger(0, MY_TEXT, OBJPROP_YDISTANCE, y); 
         ObjectSetString(0, MY_TEXT, OBJPROP_TEXT, text);
         ObjectSetInteger(0,MY_TEXT, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, MY_TEXT, OBJPROP_COLOR, (color) foregroundColor);
         ObjectSetInteger(0 , MY_TEXT, OBJPROP_FONTSIZE, 7);        
         ObjectSetInteger(0, MY_TEXT, OBJPROP_SELECTABLE, false);        
         ObjectSetInteger(0, MY_TEXT, OBJPROP_HIDDEN, true);
         ObjectSetInteger(0, MY_TEXT, OBJPROP_BACK, false);
         //ObjectSetInteger(0, MY_TEXT, OBJPROP_ZORDER, 300);
         //ObjectSetString(0, MY_TEXT, OBJPROP_FONT, "Courier new");
         
      }
      else
      {
         ObjectSetString(0, MY_TEXT, OBJPROP_TEXT, text);
         ObjectSetInteger(0, MY_TEXT, OBJPROP_XDISTANCE, x);
         ObjectSetInteger(0, MY_TEXT, OBJPROP_YDISTANCE, y); 
         ObjectSetInteger(0, MY_TEXT_BKG, OBJPROP_XDISTANCE, x);
         ObjectSetInteger(0, MY_TEXT_BKG, OBJPROP_YDISTANCE, y);                   
      }
  }
  
  void hideLabel()
  {            
      if(ObjectFind(0, MY_TEXT) >= 0)
         ObjectDelete(0, MY_TEXT);
      if(ObjectFind(0, MY_TEXT_BKG) >= 0)
         ObjectDelete(0, MY_TEXT_BKG);
      
      ChartRedraw();      
  }
   

   
   bool RectLabelCreate(const long             chart_ID=0,               // chart's ID
                        const string           name="RectLabel",         // label name
                        const int              sub_window=0,             // subwindow index
                        const int              x=0,                      // X coordinate
                        const int              y=0,                      // Y coordinate
                        const int              width=50,                 // width
                        const int              height=18,                // height
                        const color            back_clr=C'236,233,216',  // background color
                        const ENUM_BORDER_TYPE border=BORDER_SUNKEN,     // border type
                        const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                        const color            clr=clrRed,               // flat border color (Flat)
                        const ENUM_LINE_STYLE  style=STYLE_SOLID,        // flat border style
                        const int              line_width=0,             // flat border width
                        const bool             back=false,               // in the background
                        const bool             selection=false,          // highlight to move
                        const bool             hidden=true,              // hidden in the object list
                        const long             z_order=255)                // priority for mouse click
     {
   //--- reset the error value
      ResetLastError();
   //--- create a rectangle label
      if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE_LABEL,sub_window,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create a rectangle label! Error code = ",GetLastError());
         return(false);
        }
   //--- set label coordinates
      ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   //--- set label size
      ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   //--- set background color
      ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   //--- set border type
      ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_TYPE,border);
   //--- set the chart's corner, relative to which point coordinates are defined
      ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   //--- set flat border color (in Flat mode)
      ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   //--- set flat border line style
      ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   //--- set flat border width
      ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,line_width);
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
};

PipsPercentage pipsPercentage;