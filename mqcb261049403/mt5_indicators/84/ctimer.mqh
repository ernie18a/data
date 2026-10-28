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
//| The CTimer class                                                 |
//+------------------------------------------------------------------+
class CTimer :public CObject
  {
private:
   ENUM_TIMEFRAMES   _TimePeriod;
   // For the output of value of the timer
   CChartObjectLabel *TimerText;
   // For the output of a substrate of the timer
   CChartObjectLabel *TimerSubstrate;
   // Beep button
   CChartObjectButton *TimerSignalButton;

   color             _Color,_Substrate;
   ENUM_BASE_CORNER  _Corner;
   bool              InitTimer;
   bool              SoundFlag;
   string            SignalName;
public:
                     CTimer();
                    ~CTimer();
   //--- object creation
   bool              Create(long chart_id,string name,int window,int X,int Y);
   //--- change of colour of the text
   bool              Color(color col);
   color             Color(){return(_Color);}
   //--- change of colour of a background
   bool              ColorBackground(color col);
   color             ColorBackground(){return(_Substrate);}
   //--- change the binding corner
   bool              Corner(ENUM_BASE_CORNER corner);
   ENUM_BASE_CORNER  Corner();
   //--- specifying of the sound file
   void              SignalFile(string pach){SignalName=pach;StringTrimLeft(SignalName);StringTrimRight(SignalName);SignalOn();}
   string            SignalFile(){return(SignalName);}
   //--- Signal on
   bool              SignalOn();
   //--- Switching-off signal
   bool              SignalOff();
   //--- OnTimer() event processing method
   void              OnTimer();
   //--- Mouse event processing method
   void              OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Change of the timer period
   void              TimePeriod(ENUM_TIMEFRAMES period){_TimePeriod=period; OnTimer();}
   ENUM_TIMEFRAMES   TimePeriod(){return(_TimePeriod);}
private:
   datetime          TimeEndOfPeriod();
  };
//+------------------------------------------------------------------+
//| Сonstructor                                                      |
//+------------------------------------------------------------------+
CTimer::CTimer()
  {
   TimerSubstrate=NULL;
   TimerText=NULL;
   TimerSignalButton=NULL;
   _TimePeriod=_Period;
   _Color=White;
   _Substrate=Green;
   _Corner=CORNER_RIGHT_LOWER;
   InitTimer=false;
   SoundFlag=false;
   SignalName="";
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTimer::~CTimer()
  {
   InitTimer=false;
   if(TimerSubstrate!=NULL) delete TimerSubstrate;
   if(TimerText!=NULL) delete TimerText;
   if(TimerSignalButton!=NULL) delete TimerSignalButton;
  }
//+------------------------------------------------------------------+
//| Method of the object creation                                    |
//+------------------------------------------------------------------+
bool CTimer::Create(long chart_id,string name,int window,int X,int Y)
  {
   bool result;
   if(_TimePeriod>PERIOD_D1) return(false);
   TimerSubstrate=new CChartObjectLabel();
   if(ObjectFind(0,"Substrate"+name)==-1)
      result=TimerSubstrate.Create(0,"Substrate"+name,0,X,Y);
   else
     {
      result=TimerSubstrate.Attach(0,"Substrate"+name,0,2);
      TimerSubstrate.X_Distance(X);
      TimerSubstrate.Y_Distance(Y);
     }
   result&=TimerSubstrate.Anchor(ANCHOR_CENTER);
   result&=TimerSubstrate.Font("Webdings");
   result&=TimerSubstrate.FontSize(13);
   result&=TimerSubstrate.Color(_Substrate);
   result&=TimerSubstrate.Corner(_Corner);
   result&=TimerSubstrate.Description("gggg");
   result&=TimerSubstrate.Background(true);
   TimerText=new CChartObjectLabel();
   if(ObjectFind(0,name)==-1)
      result&=TimerText.Create(0,name,0,X,Y);
   else
     {
      result&=TimerText.Attach(0,name,0,2);
      TimerText.X_Distance(X);
      TimerText.Y_Distance(Y);
     }
   result&=TimerText.Anchor(ANCHOR_CENTER);
   result&=TimerText.Font("Arial Black");
   result&=TimerText.FontSize(10);
   result&=TimerText.Color(_Color);
   result&=TimerText.Corner(_Corner);
   result&=TimerText.Background(false);
   result&=TimerText.Description(TimeToString(TimeEndOfPeriod(),TIME_SECONDS));
   SignalOn();
   if(result) InitTimer=true;
   return(result);
  }
//+------------------------------------------------------------------+
//| Method of inclusion of a signal                                  |
//+------------------------------------------------------------------+
bool CTimer::SignalOn()
  {
   int      X,Y;
   string   name_obj;

   if(TimerSubstrate==NULL) return(false);
   if(SignalName=="")
     {
      if(TimerSignalButton!=NULL) {delete TimerSignalButton; TimerSignalButton=NULL;}
      return(false);
     }
   X=TimerSubstrate.X_Distance();
   Y=TimerSubstrate.Y_Distance();
   if(TimerSignalButton==NULL)
     {
      TimerSignalButton=new CChartObjectButton();
      name_obj=TimerText.Name()+" Signal";
      if(ObjectFind(0,name_obj)==-1)
         TimerSignalButton.Create(0,name_obj,0,X+52,Y+10,18,18);
      else
        {
         TimerSignalButton.Attach(0,name_obj,0,2);
         TimerSignalButton.X_Distance(X+52);
         TimerSignalButton.Y_Distance(Y+10);
        }
      TimerSignalButton.State(false);
      TimerSignalButton.Font("Webdings");
      TimerSignalButton.FontSize(10);
      TimerSignalButton.Corner(_Corner);
     }
   TimerSignalButton.Color(_Substrate);
   TimerSignalButton.Description("U");
   SoundFlag=true;
   return(true);
  }
//+------------------------------------------------------------------+
//| Method of switching-off a signal                                 |
//+------------------------------------------------------------------+
bool CTimer::SignalOff()
  {
   string   name_obj;
   bool     result=true;

   if(TimerSignalButton==NULL) return(false);
   if(!TimerSignalButton.State()) TimerSignalButton.State(true);
   TimerSignalButton.Color(Red);
   TimerSignalButton.Description("V");
//   TimerSignalButton.State(false);
   SoundFlag=false;
   return(result);
  }
//+-----------------------------------------------------------------------------+
//| Method of processing of event OnTimer()                                     |
//+-----------------------------------------------------------------------------+
void CTimer::OnTimer()
  {
   static bool BlinkFlag=true;
   if(InitTimer)
     {
      if(_TimePeriod>PERIOD_D1) return;
      datetime tmpTime=TimeEndOfPeriod();
      TimerText.Description(TimeToString(tmpTime,TIME_SECONDS));
      if(tmpTime<=10)
        {
         if(SoundFlag && tmpTime<=1)
           {
            if(!PlaySound(SignalName)) Print("Signal error "+SignalName);
           }
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
//+------------------------------------------------------------------------+
//| Method of event processing of the mouse                                |
//+------------------------------------------------------------------------+
void CTimer::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(TimerSignalButton!=NULL)
         if(TimerSignalButton.Name()==sparam)
           {
            if(TimerSignalButton.State())
               SignalOff();
            else
               SignalOn();
           }
     }
  }
//+-------------------------------------------------------------------+
//| Returns the time, remained to the current period complete         |
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
//| Method of change of colour of the text                                 |
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
//| Method of change of colour of a background                              |
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
//| Method of change of a corner of a binding                                 |
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
