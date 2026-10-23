//+------------------------------------------------+
//| File        | Draw_Vertical_Lines_at_Time.mq4  |
//| Description | Draw vertical lines at time.     |
//| Copyright   | TR4DEX                           |
//| Website     | http://www.tr4dex.com            | 
//+------------------------------------------------+
#property copyright "Copyright © 2017, TR4DEX"
#property link      "http://www.tr4dex.com"
#property indicator_chart_window
#property strict

extern int   HOUR                = 4; //Hour to draw the lines
extern int   MINUTE              = 0; //Minute to draw the lines
extern color Line_Color          = clrBlack; //Color of the lines
input ENUM_LINE_STYLE Line_Style = STYLE_DASH; //Style of the lines

string name = "TimeLine";

int init()
{
   return(0);
}
  
void deinit()
{
   ObjectsDeleteAll();
   Comment("");
}

void start()
{
   int Counted_bars=IndicatorCounted(); 
   int i=Bars-Counted_bars-1;           
   
   while(i>=0)                       
   {  
      if(TimeHour(Time[i]) == HOUR && TimeMinute(Time[i]) == MINUTE)
      {
         if (ObjectFind(name+DoubleToStr(Time[i])) != 0)
         {
            ObjectCreate(name+DoubleToStr(Time[i]), OBJ_VLINE, 0, Time[i], 0);
            ObjectSetInteger(0,name+DoubleToStr(Time[i]),OBJPROP_STYLE,Line_Style);
            ObjectSet(name+DoubleToStr(Time[i]), OBJPROP_COLOR, Line_Color);
         }
      }
      i--;
   }
}

