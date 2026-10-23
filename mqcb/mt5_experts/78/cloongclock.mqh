//+------------------------------------------------------------------+
//|                                    A very simple sample of clock |
//|                                                  CLoongClock.mqh |
//|                             Copyright 2010, Loong@forum.mql4.com |
//|                              https://www.mql5.com/en/users/loong |
//+------------------------------------------------------------------+
#property copyright "2010, Loong@forum.mql4.com"
#property link      "https://www.mql5.com/en/users/loong"
#property version   "1.00"

#include <ChartObjects\ChartObjectsTxtControls.mqh>

enum ENUM_TIME_FUNC
  {
   TIME_FUNC_GMT,
   TIME_FUNC_SERVER,
   TIME_FUNC_LOCAL
  };
//+------------------------------------------------------------------+
//| Class CLoongClock.                                               |
//| Purpose: Class of the toy EA "LoongClock".                       |
//+------------------------------------------------------------------+
class CLoongClock
{
protected:
// for time
   MqlDateTime     m_stime;          // The date type structure contains eight fields of the int type
   datetime        m_dtime;          // storing the date and time as the number of seconds elapsed since January 01, 1970.
   int			    m_year;           // Year
   int			    m_mon;            // Month
   int			    m_day;            // Day
   int			    m_hor;            // Hour
   int			    m_min;            // Minutes
   int			    m_sec;            // Seconds
   int			    m_day_of_week;    // Day of week (0-sunday, 1-monday)
   int			    m_day_of_year;    // Day number of the year (for example, the 1st of February is the 32nd day of the year)

   ENUM_TIME_FUNC  m_time_func;
// for draw
   CChartObjectLabel m_label_cen;    // center label
   CChartObjectLabel m_label_hor;    //   hour label
   CChartObjectLabel m_label_min;    // minute label
   CChartObjectLabel m_label_sec;    // second label
   int             m_center_X;       // coordinate of the center X
   int             m_center_Y;       // coordinate of the center Y
   int             m_radius_hor;     //   hour hand radius in pixels
   int             m_radius_min;     // minute hand radius in pixels
   int             m_radius_sec;     // second hand radius in pixels

   void            InitParam();
   void            Create();

public:
                   CLoongClock();
   void            Now();
   void            Show();
   void            Timer();
   void            SetTimeFunc(ENUM_TIME_FUNC tf);
};

CLoongClock::CLoongClock()
{
   InitParam();
   Create();
   Timer();
}
CLoongClock::InitParam()
{
   int height = int(ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0));
   int width  = int(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS,0));
   //m_center_X = MathFloor( width/2); //MathFloor return 0?
   //m_center_Y = MathFloor(height/2); //MathCeil  return 1?
   m_center_X = int(MathRound( width/2)); //MathRound
   m_center_Y = int(MathRound(height/2));
   int radius = int(MathMin(m_center_X,m_center_Y));
   m_radius_hor = int(MathRound(radius*0.2));
   m_radius_min = int(MathRound(m_radius_hor*1.618));
   m_radius_sec = int(MathRound(m_radius_min*1.618));
   //Print("height="+height+", width="+width+", m_center_X="+m_center_X+", m_center_Y="+m_center_Y);
   //Print("radius="+radius+", m_radius_hor="+m_radius_hor+", m_radius_min="+m_radius_min+", m_radius_sec="+m_center_Y);
}
CLoongClock::Create()
{
   m_label_cen.Create(0,"label_cen",0,0,0);
   m_label_hor.Create(0,"label_hor",0,0,0);
   m_label_min.Create(0,"label_min",0,0,0);
   m_label_sec.Create(0,"label_sec",0,0,0);
   m_label_cen.Corner(CORNER_LEFT_LOWER);
   m_label_hor.Corner(CORNER_LEFT_LOWER);
   m_label_min.Corner(CORNER_LEFT_LOWER);
   m_label_sec.Corner(CORNER_LEFT_LOWER);
   m_label_cen.Color(Yellow);
   m_label_hor.Color(Red);
   m_label_min.Color(Lime);
   m_label_sec.Color(Blue);
   m_label_cen.Description("@");
   m_label_cen.X_Distance(m_center_X);
   m_label_cen.Y_Distance(m_center_Y);
}
CLoongClock::Timer()
{
   Now();
   Show();
}
CLoongClock::SetTimeFunc(ENUM_TIME_FUNC tf)
{
   m_time_func = tf;
}
CLoongClock::Now()
{
   switch(m_time_func)
   {
      case TIME_FUNC_GMT:
         m_dtime = TimeGMT(m_stime); // new function to get GMT time
         break;
      case TIME_FUNC_SERVER:
         m_dtime = TimeCurrent(m_stime); //Returns the last known server time server
         break;
      case TIME_FUNC_LOCAL:
      default:
         m_dtime = TimeLocal(m_stime); //Returns the local time of a computer
   }
   //Print(TimeToString(m_dtime));
   //Print(TimeGMTOffset());
   //Print(TimeDaylightSavings());
   //m_year = m_stime.year;
   //m_mon  = m_stime.mon;
   //m_day  = m_stime.day;
   m_hor  = m_stime.hour;
   m_min  = m_stime.min;
   m_sec  = m_stime.sec;
   //m_day_of_week = m_stime.day_of_week;
   //m_day_of_year = m_stime.day_of_year;
}
CLoongClock::Show()
{
   int x,y;
   //Print("m_hor="+m_hor+", m_min="+m_min+", m_sec="+m_sec);
   NumToDistance(12, m_hor, m_radius_hor, m_center_X, m_center_Y, x, y);
   m_label_hor.X_Distance(x);
   m_label_hor.Y_Distance(y);
   NumToDistance(60, m_min, m_radius_min, m_center_X, m_center_Y, x, y);
   m_label_min.X_Distance(x);
   m_label_min.Y_Distance(y);
   NumToDistance(60, m_sec, m_radius_sec, m_center_X, m_center_Y, x, y);
   m_label_sec.X_Distance(x);
   m_label_sec.Y_Distance(y);

   m_label_hor.Description(IntegerToString(m_hor));
   m_label_min.Description(IntegerToString(m_min));
   m_label_sec.Description(IntegerToString(m_sec));
}
void NumToDistance(int extent, int num, int radius, int cx, int cy, int& x, int& y)
{
   double angle;
   angle = M_PI_2 - 2*M_PI * num/extent;
   x = int(MathRound(cx + radius*MathCos(angle)));
   y = int(MathRound(cy + radius*MathSin(angle)));
}

