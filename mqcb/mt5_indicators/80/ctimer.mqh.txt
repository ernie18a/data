//+------------------------------------------------------------------+
//|                                                       CTimer.mqh |
//|                                        Copyright Dmitry Voronkov |
//|                                                 vdv_2001@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Dmitry Voronkov"
#property link      "vdv_2001@mail.ru"

#include <Object.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTimer :public CObject
  {
private:
   ENUM_TIMEFRAMES   _TimePeriod;
   // For an output of the timer value
   CChartObjectLabel *TimerText;
   // For an output of the timer panel
   CChartObjectLabel *TimerSubstrate;
   color             _Color,_Substrate;
   ENUM_BASE_CORNER  _Corner;
   bool              InitTimer;
public:
                     CTimer();
                    ~CTimer();
   //--- method of the object creation
   bool              Create(long chart_id,string name,int window,int X,int Y);
   //--- method to change text colour
   bool              Color(color col);
   color             Color(){return(_Color);}
   //--- method to change background color
   bool              ColorBackground(color col);
   color             ColorBackground(){return(_Substrate);}
   //--- method to change the output corner
   bool              Corner(ENUM_BASE_CORNER corner);
   ENUM_BASE_CORNER  Corner();
   
   //--- OnTimer() event processing method
   void              OnTimer();
   //--- Method to change period of the timer
   void              TimePeriod(ENUM_TIMEFRAMES period){_TimePeriod=period; OnTimer();}
   ENUM_TIMEFRAMES   TimePeriod(){return(_TimePeriod);}
private:
   datetime          TimeEndOfPeriod();
  };
//+------------------------------------------------------------------+
//| Class constructor                                                |
//+------------------------------------------------------------------+
CTimer::CTimer()
  {
   TimerSubstrate=NULL;
   TimerText=NULL;
   _TimePeriod=_Period;
   _Color=White;
   _Substrate=Green;
   _Corner=CORNER_RIGHT_LOWER;
   InitTimer=false;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTimer::~CTimer()
  {
   InitTimer=false;
   if(TimerSubstrate!=NULL) delete TimerSubstrate;
   if(TimerText!=NULL) delete TimerText;
  }
//+------------------------------------------------------------------+
//| Object creation method                                           |
//+------------------------------------------------------------------+
bool CTimer::Create(long chart_id,string name,int window,int X,int Y)
  {
   bool result;
   if(_TimePeriod>PERIOD_D1) return(false);
   TimerSubstrate=new CChartObjectLabel();
   result=TimerSubstrate.Create(0,name+"Substrate",0,X,Y);
   result&=TimerSubstrate.Anchor(ANCHOR_CENTER);
   result&=TimerSubstrate.Font("Webdings");
   result&=TimerSubstrate.FontSize(13);
   result&=TimerSubstrate.Color(_Substrate);
   result&=TimerSubstrate.Corner(_Corner);
   result&=TimerSubstrate.Description("gggg");
   TimerText=new CChartObjectLabel();
   result&=TimerText.Create(0,name,0,X,Y);
   result&=TimerText.Anchor(ANCHOR_CENTER);
   result&=TimerText.Font("Arial Black");
   result&=TimerText.FontSize(10);
   result&=TimerText.Color(_Color);
   result&=TimerText.Corner(_Corner);
   result&=TimerText.Description(TimeToString(TimeEndOfPeriod(),TIME_SECONDS));
   if(result) InitTimer=true;
   return(result);
  }
//+-----------------------------------------------------------------------------+
//| OnTimer() event processing method                                           |
//+-----------------------------------------------------------------------------+
void CTimer::OnTimer()
  {
   static bool BlinkFlag=true;
   if(InitTimer)
     {
      if(_TimePeriod>PERIOD_D1) return;
      datetime tmpTime=TimeEndOfPeriod();
      TimerText.Description(TimeToString(tmpTime,TIME_SECONDS));
      if(tmpTime<=20)
        {
         if(BlinkFlag)
           {
            TimerSubstrate.Color(Red);
            BlinkFlag=false;
           }
         else
           {
            TimerSubstrate.Color(_Substrate);
            BlinkFlag=true;
           }
        }
      else
         TimerSubstrate.Color(_Substrate);
      ChartRedraw();
     }
  }
//+-------------------------------------------------------------------+
//| The function returns remained time to period closing              |
//+-------------------------------------------------------------------+
datetime CTimer::TimeEndOfPeriod()
  {
   datetime tmpDateTime;
   int tmp;
   MqlDateTime last_time;
   TimeToStruct(TimeTradeServer(),last_time);
   last_time.sec=0;
   if(Period()<=PERIOD_H1)
     {
      tmp=(PeriodSeconds(_TimePeriod)/PeriodSeconds(PERIOD_M1));
      tmp=last_time.min/tmp;
      last_time.min=(tmp+1)*PeriodSeconds(_TimePeriod)/PeriodSeconds(PERIOD_M1);
     }
   else
   if(Period()>PERIOD_H1 && Period()<=PERIOD_D1)
     {
      tmp=(PeriodSeconds(_TimePeriod)/PeriodSeconds(PERIOD_H1));
      tmp=last_time.hour/tmp;
      last_time.hour=(tmp+1)*PeriodSeconds(_TimePeriod)/PeriodSeconds(PERIOD_H1);
      last_time.min=0;
     }
   tmpDateTime=StructToTime(last_time);
   tmpDateTime=tmpDateTime-TimeTradeServer();
   return(tmpDateTime);
  }
//+------------------------------------------------------------------------+
//| Method to change text colour                                           |
//+------------------------------------------------------------------------+
bool CTimer::Color(color col)
  {
   _Color=col;
   if(TimerText!=NULL)
      return(TimerText.Color(col));
   else
      return(false);
  }
//+-------------------------------------------------------------------------+
//| Method to change background colour                                      |
//+-------------------------------------------------------------------------+
bool CTimer::ColorBackground(color col)
  {
   _Substrate=col;
   if(TimerSubstrate!=NULL)
      return(TimerSubstrate.Color(col));
   else
      return(false);
  }
//+---------------------------------------------------------------------------+
//| Method to change the output corner                                        |
//+---------------------------------------------------------------------------+
bool CTimer::Corner(ENUM_BASE_CORNER corner)
{
   bool result;
   _Corner=corner;
   result=TimerText.Corner(_Corner);
   result&=TimerSubstrate.Corner(_Corner);
   OnTimer();
   return(result);
}
//+------------------------------------------------------------------+