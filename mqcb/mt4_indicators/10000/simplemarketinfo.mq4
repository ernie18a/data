//+------------------------------------------------------------------+
//|                                             SimpleMarketInfo.mq4 |
//|                                        Copyright © 2010, TamTer. |
//|                                            http://www.tamter.com |
//|                        Contains code from Arif Endro Nugroho.mq4 |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2010, TamTer. <einspired@gmail.com>"
#property link      "http://www.tamter.com"
#property indicator_chart_window

#include <MarketNewsLib.mqh>

//---- input parameters
extern int time_zone_gmt     =0; // London GMT.. adjust to 1 for day light saving
extern int update_interval   = 15; 
extern color session_upcoming_title_color = White;
extern color bar_closing_color = Lime;
extern color session_closing_color = Red;
extern bool show_news_lines  = true;
extern bool show_line_text   = true;        
extern color news_past_color = Gray;            
extern color news_high_color   = Red;         
extern color news_medium_color = Yellow;         
extern color news_low_color    = Orange;  
extern string news_url       = "http://www.dailyfx.com/files/";
extern int news_alert_min    = 3600; //1 hour news will be d
 
datetime lastUpdate = 0;      
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//--- Time zones
// New York = GMT-5, London = GMT+0, Tokyo = GMT+9, Sydney = GMT+10
//string RiskReward_ratio = (TP_price - Open_Price) / (Open_Price - SL_price);

//---- 
   CreateInfoObjects();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   DeleteSessionInfoObjects();
   DeleteNewsObjects(); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   
   DisplaySessionInfo();
   DisplayTodaysNews();
   
   return(0);
  }

//+------------------------------------------------------------------+
void DeleteSessionInfoObjects()
{
   ObjectDelete("OpenSessions");
   ObjectDelete("BarClosing");
   ObjectDelete("SessionClosing");  
}
//+------------------------------------------------------------------+

void CreateInfoObjects()
{
   ObjectCreate("OpenSessions", OBJ_LABEL, 0, 0, 0, 0, 0);
   ObjectSet("OpenSessions", OBJPROP_CORNER, 1);
   ObjectSet("OpenSessions", OBJPROP_XDISTANCE, 4);
   ObjectSet("OpenSessions", OBJPROP_YDISTANCE, 0);
   ObjectSetText("OpenSessions", "",12, "Arial Black", session_upcoming_title_color); 
    
   ObjectCreate("SessionClosing", OBJ_LABEL, 0, 0, 0, 0, 0);
   ObjectSet("SessionClosing", OBJPROP_CORNER, 1);
   ObjectSet("SessionClosing", OBJPROP_XDISTANCE, 4);
   ObjectSet("SessionClosing", OBJPROP_YDISTANCE, 15); 
    
   ObjectCreate("BarClosing", OBJ_LABEL, 0, 0, 0, 0, 0);
   ObjectSet("BarClosing", OBJPROP_CORNER, 1);
   ObjectSet("BarClosing", OBJPROP_XDISTANCE, 4);
   ObjectSet("BarClosing", OBJPROP_YDISTANCE,30); 
   ObjectSetText("BarClosing", "", 10, "Arial Black", bar_closing_color);  
}
//+------------------------------------------------------------------+ 

void DisplaySessionInfo()
{
   string openSessions = "Active sessions: ";
   string closingSession = "";
//----
// London local session...: 08.00 - 17.00
// New York local session.: 08.00 - 17.00
// Tokyo local session....: 09.00 - 18.00
// Sydney local session...: 08.00 - 17.00

    datetime zoneNY   = TimeLocal() + ((- 5 - time_zone_gmt) * 3600);
    datetime zoneLDN  = TimeLocal() + ((  0 - time_zone_gmt) * 3600);
    datetime zoneTKY  = TimeLocal() + ((  9 - time_zone_gmt) * 3600);
    datetime zoneSYD  = TimeLocal() + (( 11 - time_zone_gmt) * 3600);
   if (TimeHour(zoneNY) >= 8 && TimeHour(zoneNY) < 17 && TimeDayOfWeek(zoneNY) > 0 && TimeDayOfWeek(zoneNY) < 6 )
   {
       openSessions = openSessions + "New York";
       if(TimeHour(zoneNY) == 16)
       {
         closingSession = "New York closing in " + (60 - TimeMinute(TimeLocal()))+ " mins";
       } 
   }
   
   if (TimeHour(zoneLDN) >= 8 && TimeHour(zoneLDN) < 17 && TimeDayOfWeek(zoneLDN) > 0 && TimeDayOfWeek(zoneLDN) < 6 )
   {      
         openSessions = openSessions + " London";
          if(TimeHour(zoneLDN) == 16)
       {
         closingSession = "London closing in " + (60 - TimeMinute(TimeLocal()))+ " mins";
       } 
   }
  
   if (TimeHour(zoneTKY) >= 9 && TimeHour(zoneTKY) < 18 && TimeDayOfWeek(zoneTKY) > 0 && TimeDayOfWeek(zoneTKY) < 6 )
   {   
      openSessions = openSessions + " Tokyo";
       if(TimeHour(zoneTKY) == 17)
       {
         closingSession = "Tokyo closing in " + (60 - TimeMinute(TimeLocal()))+ " mins";
       } 
   }
   
   if (TimeHour(zoneSYD) >= 8 && TimeHour(zoneSYD) < 17 && TimeDayOfWeek(zoneSYD) > 0 && TimeDayOfWeek(zoneSYD) < 6 )
   {
      openSessions = openSessions + " Sydney";
       if(TimeHour(zoneSYD) == 16)
       {
         closingSession = "Sydney closing in " + (60 - TimeMinute(TimeLocal()))+ " mins";
       } 
   }
 string TimeLeft =  TimeToStr( (iTime(NULL,Period(),0)+Period()*60-TimeCurrent( )), TIME_MINUTES|TIME_SECONDS) ;
//----
   if(openSessions == "Active sessions: ") openSessions = "Markets Closed";
   ObjectSetText("OpenSessions", openSessions,12, "Arial Black", session_upcoming_title_color);
   ObjectSetText("BarClosing", "Time to bar close " + TimeLeft, 10, "Arial Black", bar_closing_color);
   ObjectSetText("SessionClosing",closingSession ,10, "Arial Black", session_closing_color);

}
//+------------------------------------------------------------------+ 

int DisplayTodaysNews()
{
   string news[1000][10];
   datetime time = TimeCurrent();
   if(time >= lastUpdate+update_interval*60)  
   {   
     DeleteNewsObjects();
     lastUpdate = time;
     string str = "";
     
     InitNews(news,time_zone_gmt,news_url );
     if(show_news_lines) 
     DrawNewsLines(news, show_line_text,news_high_color,news_medium_color,news_low_color);
   } 
   ShowNewsCountDown(news,news_alert_min,1, news_high_color,news_medium_color,news_low_color,news_past_color,session_upcoming_title_color);
   return(0);
}