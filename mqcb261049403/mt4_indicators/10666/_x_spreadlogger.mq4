//+------------------------------------------------------------------+
//|                                                 SpreadLogger.mq4 |
//|                                                           Mr. T. |
//|                                         http://www.codeforex.com |
//+------------------------------------------------------------------+
#property copyright "Mr. T."
#property link      "http://www.codeforex.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow
#property indicator_width1 3
#property indicator_level1 0.5
#property indicator_level2 1
#property indicator_level3 2
#property indicator_level4 3

extern int LastTicks = 500;

double Spread_Value[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

   string short_name;
   IndicatorBuffers(1);
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Spread_Value);
   
   short_name="Spread Logger ("+LastTicks+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0, "SPREAD");
   objectCreate("mrt",10,10,"CopyRight by Mr. T @ www.codeforex.com ");
   
   for (int i=0; i<ArraySize(Spread_Value); i++)
   {
    Spread_Value[i] = EMPTY_VALUE;
   }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectDelete("mrt");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {

   for (int i=ArraySize(Spread_Value)-1;i>0;i--)
   {
      if (Spread_Value[i-1]!=EMPTY_VALUE) Spread_Value[i] = Spread_Value[i-1];      
   }
      
   Spread_Value[0] = MarketInfo(Symbol(),MODE_SPREAD)/10;
   
   return(0);
  }


//+------------------------------------------------------------------+
//    Create an Object -                                             |       
//+------------------------------------------------------------------+   
void objectCreate(string name,int x,int y,string text="",int size=12,
                  string font="Arial",color colour=Red)
  {
   ObjectCreate(name,OBJ_LABEL,1,0,0);
   ObjectSet(name,OBJPROP_CORNER,2);
   ObjectSet(name,OBJPROP_COLOR,colour);
   ObjectSet(name,OBJPROP_XDISTANCE,x);
   ObjectSet(name,OBJPROP_YDISTANCE,y);
   ObjectSetText(name,text,size,font,colour);
  }