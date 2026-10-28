//+------------------------------------------------------------------+
//|                      Akcel_RS_9_session.mq                       |
//|                      Copyright © 2006, dvyu@mail.ru              |
//|                      http://www..net                             |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, DVYU inc."
#property link      "http://www..net"
//----
#property indicator_chart_window
//----
extern int GOfset=0;//разница времени ДЦ и GMT.
extern int GOfset_m=0;  //0-60 мин.
extern int Visible=0;
extern string Tstart="01:00:00";
extern int period=9;
//extern int t=9;
string TD,TD1;
datetime td,end_time,go_time,ten;
string timeGo,timeEnd,te,tg;
double H,L,C,P;
double R1,R2,R3,S1,S2,S3;
int D,n;
string Tgo,Ten;
//Cчитаем пивот и уровни за предыдущую сессию, для азии- америка, 
//для европы азия, для америки конец азии и европа
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   ObjectDelete("Pivot");
   ObjectDelete("C");
   ObjectDelete("П");
   ObjectDelete("R11");
   ObjectDelete("R12");
   ObjectDelete("R13");
   ObjectDelete("S11");
   ObjectDelete("S12");
   ObjectDelete("S13");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectDelete("P");
   ObjectDelete("C");
   ObjectDelete("П");
   ObjectDelete("Start1");
   ObjectDelete("End1");
   ObjectDelete("R11");
   ObjectDelete("R12");
   ObjectDelete("R13");
   ObjectDelete("S11");
   ObjectDelete("S12");
   ObjectDelete("S13");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {D=DayOfWeek();
   if(D==1)n=3;
   else
      n=1;
   //Print("NN",n);  
   //Print("DAY",D);  
   TD1=TimeToStr(CurTime(),TIME_DATE);
   td=StrToTime(TD1);//-24*60*60;
   TD=TimeToStr(td,TIME_DATE);
   //
   int T_Hour=TimeHour(CurTime());
   //Print(T_Hour);
   if(T_Hour>0&&T_Hour<23)
     {Tgo=Tstart;
      tg=StringConcatenate(TD," ",Tgo);
      ten=StrToTime(TD1)-period*60*60;
      Ten=TimeToStr(ten);
     }
   //Устанавливаем время 
   string timeGo=Tgo;
   tg=StringConcatenate(TD," ",Tgo);
//----
   datetime td1=StrToTime(tg)-GOfset*60*60-GOfset_m*60;
   string t1=TimeToStr(td1,TIME_DATE|TIME_MINUTES);
   go_time=StrToTime(t1);
   end_time=StrToTime(Ten);
   //**********************************************************
   //Находим начальный бар - номер бара от текущего
   int BarGo=iBarShift(NULL,0,go_time,false);
   //Print( "BarGo",BarGo);
   //Находим бар 06:00 GMT
   int BarEnd=iBarShift(NULL,0,end_time,false);
   //Print("BarEnd",BarEnd);
   //**********************************************************
   //Находим бар с высшей ценой 
   int h=Highest(NULL,0,MODE_HIGH,BarEnd-BarGo,BarGo);
   //Находим собственно цену High
   H=iHigh(NULL,0,h);
   //Print("H day",H);
   //Аналогично для низшей цены Low
   int l=Lowest(NULL,0,MODE_LOW,BarEnd-BarGo,BarGo);
   L=iLow(NULL,0,l);
   //Print("L day",L);
   //Находим цену закрытия на 6:00 GMT
   C=iClose(NULL,0,BarGo);
   //Находим координату линии разворота:
   //Print("Close"," ",C);
   P=NormalizeDouble((L+H+C)/3,4);
   //*******************************************************+
   //Вычисляем R & S;
   R1=2*P-L;
   S1=2*P-H;
   R2=P+(H-L);
   R3=2*P-2*L+H;
   S2=P-H+L;
   S3=2*P-2*H+L;
   //Рисуем линии:Eсли Visible=1, разворот, хай и лоу дня,
   //Если Visible==0, рисуем поддержку и сопротивление.
   //Print("Close",C);
   if (Visible==1)
     {
      ObjectCreate("Pivot",OBJ_HLINE,0,0,C);//Close 
      ObjectCreate("П",OBJ_HLINE,0,0,L);//Поддержка
      ObjectCreate("C",OBJ_HLINE,0,0,H);//Сопротивление
      ObjectCreate("Start1",OBJ_VLINE,0,go_time,0);//Начало периода 00:00 GMT
      ObjectCreate("End1",OBJ_VLINE,0,end_time,0);// Конец периода 06:00 GMT
      ObjectSet( "Start1",OBJPROP_COLOR,Blue);
      ObjectSet( "End1",OBJPROP_COLOR,Blue );
      ObjectSet( "Pivot",OBJPROP_COLOR,DarkBlue );
      ObjectSet( "C",OBJPROP_COLOR,Gold );
      ObjectSet( "П",OBJPROP_COLOR,CornflowerBlue);
      ObjectSet("Start1",OBJPROP_WIDTH,1);
      ObjectSet("End1",OBJPROP_WIDTH,1);
      ObjectSet("Pivot",OBJPROP_WIDTH,2);
      ObjectSet("П",OBJPROP_WIDTH,2);
      ObjectSet("C",OBJPROP_WIDTH,2);
      ObjectsRedraw();
     }
   if (Visible==0)
      //*******************************************************************+
      //Рисуем Support & Resistance
     {
      ObjectCreate("Pivot",OBJ_HLINE,0,go_time,P);//Линия разворота
      ObjectCreate("R11",OBJ_HLINE,0,go_time,R1);
      ObjectCreate("R12",OBJ_HLINE,0,go_time,R2);
      ObjectCreate("R13",OBJ_HLINE,0,go_time,R3);
      ObjectCreate("S11",OBJ_HLINE,0,go_time,S1);
      ObjectCreate("S12",OBJ_HLINE,0,go_time,S2);
      ObjectCreate("S13",OBJ_HLINE,0,go_time,S3);
      ObjectCreate("Start1",OBJ_VLINE,0,go_time,0);//Начало периода 00:00 GMT
      ObjectCreate("End1",OBJ_VLINE,0,end_time,0);// Конец периода 06:00 GMT
      ObjectSet( "Start1",OBJPROP_COLOR,Blue);
      ObjectSet( "End1",OBJPROP_COLOR,Blue );
      ObjectSet( "Pivot",OBJPROP_COLOR,DarkBlue );
      ObjectSet( "R11",OBJPROP_COLOR,DarkOrange);
      ObjectSet( "R12",OBJPROP_COLOR,DarkOrange);
      ObjectSet( "R13",OBJPROP_COLOR,DarkOrange);
      ObjectSet( "S11",OBJPROP_COLOR,DarkOrange);
      ObjectSet( "S12",OBJPROP_COLOR,DarkOrange);
      ObjectSet( "S13",OBJPROP_COLOR,DarkOrange);
      ObjectSet("Start1",OBJPROP_WIDTH,1);
      ObjectSet("End1",OBJPROP_WIDTH,1);
      ObjectSet("Pivot",OBJPROP_WIDTH,2);
      ObjectsRedraw();
     }
   return(0);
  }
//+------------------------------------------------------------------+