//+------------------------------------------------------------------+
//|                                                      TimeBar.mq5 |
//|                                    Copyright 2023, by Ivan Butko |
//|                        https://www.mql5.com/ru/users/capitalplus |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2023, iboot@yandex.ru"
#property link      "https://www.mql5.com/ru/users/capitalplus"
#property version   "1.03"
#property description "TimeBar is a simple information indicator"
#property description "that shows the remaining time until the bar closes,"
#property description "as well as the time elapsed since the bar opened and the current time"



enum SHOW_MODE 
  { 
    Com,                                          // Comment
    Lable,                                        // Lable
    ComLable,                                        // Comment & Lable
  };
input SHOW_MODE Show_mode = Lable;        // Show in chart

bool CurrentTime = true;  // Show current time
bool PassedTime = true;  // Show passed time
bool LeftTime = true;  // Show left time


input string Font = "Arial";  // Font 
input int FontSize = 20;      // Font size
input color CurrentTimeColor = clrGray;  // Current time color
input color PassedTimeColor = clrGray;  // Passed time color
input color LeftTimeColor = clrGray;  // Left time color

input bool  AlertEnable = false;              // End bar alert 
input int   EndTimeleft = 20;                // Seconds left 
input color EndTimeColor = clrOrange;  // End bar color


datetime BarTime=0;
datetime tc;
datetime tf;
datetime tt;
datetime tl;

color c1,c2,c3;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(1);
   
   if (Show_mode == Lable || Show_mode == ComLable)      
     {
       Label_create("Current time", 20, 40, "Current: ", CurrentTimeColor); 
       Label_create("Passed time", 20, 80, "Passed: ", PassedTimeColor);  
       Label_create("Left time", 20, 120, "Left: ", LeftTimeColor); 
     } 
   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- indicator buffers mapping
   Comment("");

   ObjectDelete(0, "Current time");
   ObjectDelete(0, "Passed time");
   ObjectDelete(0, "Left time");
//---
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

  // BarTime=time[rates_total-1];
  // OnTimer();

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| OnTimer event handler                                            |
//+------------------------------------------------------------------+
void OnTimer()
  {
    BarTime=iTime(_Symbol, PERIOD_CURRENT, 0); 
   
   if(Period()==PERIOD_W1 || Period()==PERIOD_MN1)
     {
      return;
     }
   if(BarTime==0)
     {
      Comment("Waiting for the price change...");
      return;
     }
   tc = TimeCurrent();
   tf = tc - BarTime;
   tt = PeriodSeconds(Period()) - tf;
   if (tt < 0)
     {
      Comment("Waiting for the new bar to open...");
      return;
     }

   
    if (Show_mode == Com || Show_mode == ComLable)    
      {        
        Comment("Current: " + TimeToString(tc,TIME_SECONDS)+"\n"+
                 "Passed: " + TimeToString(tf,TIME_SECONDS)+"\n"+
                 "Left: " + TimeToString(tt,TIME_SECONDS)
                 );
      }
    
    c1 = CurrentTimeColor;
    c2 = PassedTimeColor;
    c3 = LeftTimeColor;
    
    // Предупреждение о скором закрытии бара за заданное в настройках количествах секунд
    datetime t1 = iTime(_Symbol, PERIOD_CURRENT, 1);
    datetime t0 = iTime(_Symbol, PERIOD_CURRENT, 0);
    int timesize = (int)t0 - (int)t1;
    int t_future = (int)t0 + timesize;
    int left = t_future - (int)TimeCurrent();
    
        
    if (AlertEnable && tl < t0)       
      if (left <= EndTimeleft)    
        {
          Alert(_Symbol + ": The " + Tf() + "-bar is nearing closure!" );
          tl = t0;
        }
    
    if (Show_mode == Lable || Show_mode == ComLable)    
      {
        if (CurrentTime) ObjectSetString  (0, "Current time", OBJPROP_TEXT,  "Current: " + TimeToString(tc,TIME_SECONDS));
        if (PassedTime) ObjectSetString  (0, "Passed time", OBJPROP_TEXT,  "Passed: " + TimeToString(tf,TIME_SECONDS));          
        if (LeftTime) ObjectSetString  (0, "Left time", OBJPROP_TEXT,  "Left: " + TimeToString(tt,TIME_SECONDS));
        
        ChartRedraw();
          
        if (left <= EndTimeleft)    {      c1 = EndTimeColor;      c2 = EndTimeColor;      c3 = EndTimeColor;      }
          
        ObjectSetInteger (0, "Current time", OBJPROP_COLOR, c1);
        ObjectSetInteger (0, "Passed time", OBJPROP_COLOR, c2);
        ObjectSetInteger (0, "Left time", OBJPROP_COLOR, c3);
          
      }
  }
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//|               Создает текстовую метку                            |
//+------------------------------------------------------------------+
void Label_create(string name, int x, int y, string text, color c)
  {
    if (ObjectFind(0, name) != -1)      ObjectDelete(0, name);
    ObjectCreate     (0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger (0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger (0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
    ObjectSetInteger (0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger (0, name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger (0, name, OBJPROP_COLOR,      c);
    ObjectSetString  (0, name, OBJPROP_TEXT,       text);
    ObjectSetString  (0, name, OBJPROP_FONT,       Font); 
    ObjectSetInteger (0, name, OBJPROP_FONTSIZE,   FontSize);    
    ObjectSetInteger (0, name, OBJPROP_SELECTABLE, true);
    ObjectSetInteger (0, name, OBJPROP_SELECTED,   false);
    ObjectSetInteger (0, name, OBJPROP_HIDDEN,     true);    
  }
  
  
  
  
  
//+---------------------------------------------------------------------+
//| GetTimeFrame function - returns the textual timeframe               |
//+---------------------------------------------------------------------+
string Tf()
  {
    switch(Period())
      {         
        case PERIOD_M1  :  return("M1" );
        case PERIOD_M2  :  return("M2" );  
        case PERIOD_M3  :  return("M3" );  
        case PERIOD_M4  :  return("M4" );            
        case PERIOD_M5  :  return("M5" ); 
        case PERIOD_M6  :  return("M6" );  
        case PERIOD_M10 :  return("M10"); 
        case PERIOD_M12 :  return("M12");     
        case PERIOD_M15 :  return("M15");  
        case PERIOD_M20 :  return("M20");       
        case PERIOD_M30 :  return("M30");         
        case PERIOD_H1  :  return("H1" );  
        case PERIOD_H2  :  return("H2" );
        case PERIOD_H3  :  return("H3" );    
        case PERIOD_H4  :  return("H4" );  
        case PERIOD_H6  :  return("H6" );
        case PERIOD_H8  :  return("H8" );
        case PERIOD_H12 :  return("H12" );
        case PERIOD_D1  :  return("Daily" );         
        case PERIOD_W1  :  return("Weekly" );         
        case PERIOD_MN1 :  return("Monthly");
                  
        default:return("Unable to determine timeframe");         
      }
  }
  