//+------------------------------------------------------------------+
//|                                                    Equity_v8.mq4 |
//|                                         Copyright © 2009, Xupypr |
//|                              http://www.mql4.com/ru/users/Xupypr |
//|                                             Версия от 01.08.2009 |
//|                                 http://codebase.mql4.com/ru/4919 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, Xupypr"
#property link      "http://www.mql4.com/ru/users/Xupypr"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 LightSteelBlue
#property indicator_color2 SteelBlue
#property indicator_color3 Black
#property indicator_color4 LightSteelBlue
#property indicator_color5 SteelBlue
#property indicator_color6 Black
#property indicator_color7 SteelBlue
#property indicator_color8 OrangeRed
#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 3
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 3
#property indicator_width7 1
#property indicator_width8 2

extern string Only_Comment="";    // Учитывать ордера только с наличием указанного комментария (например [sl] или [tp])
extern string Only_Magics="";     // Учитывать ордера только с указанными магическими номерами (через любой разделитель)
extern string Only_Symbols="";    // Учитывать только указанные инструменты (через любой разделитель)
extern bool   Only_Current=false; // Учитывать только текущий инструмент
extern bool   Only_Buys=false;    // Учитывать ордера только на покупку
extern bool   Only_Sells=false;   // Учитывать ордера только на продажу
extern bool   Show_Balance=true; // Отображать баланс
extern bool   Show_Info=false;   // Отображать дополнительную информацию (в т.ч. фактор восстановления)
extern int    Bars_History=100;  // Период за который мониторится текущая просадка
extern double Alert_Drawdown=0;  // Предупреждение о просадке в процентах за период (0 - не использовать предупреждение)
extern double Max_Drawdown=25;   // Допустимая просадка в процентах за период
extern bool   File_Write=false;  // Запись данных в файл

int      ANumber,Window;
bool     First;
string   ShortName,Unique;
double   EquityBodyUp[],EquityBodyDown[],MaskBody[],EquityShadeUp[],EquityShadeDown[],MaskShade[],EquityLine[],Balance[];
double   StartBalance,CurrentBalance,MaxPeak,MaxProfit;
double   AbsDrawdown,MaxDrawdown,RelDrawdown,Drawdown,RecoveryFactor;
datetime TimeBar;

datetime OpenTime_Ticket[][2]; // время открытия и номер тикета
datetime CloseTime[];          // время закрытия
int      Type[];               // тип операции
string   Instrument[];         // инструмент
double   Lots[];               // количество лотов
double   OpenPrice[];          // цена открытия
double   ClosePrice[];         // цена закрытия
double   Commission[];         // комиссия
double   Swap[];               // накопленный своп
double   CurSwap[];            // текущий своп
double   DaySwap[];            // дневной своп
double   Profit[];             // чистая прибыль
double   Magic[];              // магический номер

//+----------------------------------------------------------------------------+
//|  Custom indicator initialization function                                  |
//+----------------------------------------------------------------------------+
int init()
{
 if (Only_Comment=="" && Only_Magics=="" && Only_Symbols=="" && !Only_Current && !Only_Buys && !Only_Sells) ShortName="Total";
 else
 {
  if (Only_Comment!="") ShortName=Only_Comment; else ShortName="";
  if (Only_Magics!="")  ShortName=StringConcatenate(ShortName," ",Only_Magics);
  if (Only_Symbols!="") ShortName=StringConcatenate(ShortName," ",Only_Symbols);
  else if (Only_Current) ShortName=StringConcatenate(ShortName," ",Symbol());
  if (Only_Sells) Only_Buys=false;
  if (Only_Buys)  ShortName=StringConcatenate(ShortName," Buys");
  if (Only_Sells) ShortName=StringConcatenate(ShortName," Sells");
 }
 SetIndexBuffer(0,EquityBodyUp);
 SetIndexLabel(0,ShortName+" Equity");
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(1,EquityBodyDown);
 SetIndexLabel(1,ShortName+" Equity");
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(2,MaskBody);
 SetIndexLabel(2,"Mask");
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(3,EquityShadeUp);
 SetIndexLabel(3,ShortName+" Equity");
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(4,EquityShadeDown);
 SetIndexLabel(4,ShortName+" Equity");
 SetIndexStyle(4,DRAW_HISTOGRAM);
 SetIndexBuffer(5,MaskShade);
 SetIndexLabel(5,"Mask");
 SetIndexStyle(5,DRAW_HISTOGRAM);
 SetIndexBuffer(6,EquityLine);
 SetIndexLabel(6,ShortName+" Equity");
 SetIndexStyle(6,DRAW_LINE);
 SetIndexBuffer(7,Balance);
 SetIndexLabel(7,ShortName+" Balance");
 SetIndexStyle(7,DRAW_LINE);
                   ShortName=StringConcatenate(ShortName," Equity");
 if (Show_Balance) ShortName=StringConcatenate(ShortName," Balance");
 IndicatorDigits(2);
 Unique=DoubleToStr(GetTickCount()+MathRand(),0);
 ANumber=-1;
 return(0);
}
//+----------------------------------------------------------------------------+
//|  Custom indicator deinitialization function                                |
//+----------------------------------------------------------------------------+
int deinit()
{
 if (Window!=-1) ObjectsDeleteAll(Window);
 return(0);
}
//+----------------------------------------------------------------------------+
//|  Custom indicator iteration function                                       |
//+----------------------------------------------------------------------------+
int start()
{
 static bool open;
 string filename,objectname,text,time;
 static string minfosymbols="",m1symbols="";
 static double equityopen,equityhigh,equitylow,equityclose;
 double spread,lotsize;
 int handle=INVALID_HANDLE,beginbar,bar,i,m,j,start,total,historytotal,opentotal;
 //int tick=GetTickCount();

 if (ANumber!=AccountNumber())
 {
  IndicatorShortName(Unique);
  Window=WindowFind(Unique);
  IndicatorShortName(ShortName);
  if (Window!=-1) ObjectsDeleteAll(Window);
  ArrayInitialize(EquityBodyUp,EMPTY_VALUE);
  ArrayInitialize(EquityBodyDown,EMPTY_VALUE);
  ArrayInitialize(MaskBody,EMPTY_VALUE);
  ArrayInitialize(EquityShadeUp,EMPTY_VALUE);
  ArrayInitialize(EquityShadeDown,EMPTY_VALUE);
  ArrayInitialize(MaskShade,EMPTY_VALUE);
  ArrayInitialize(EquityLine,EMPTY_VALUE);
  ArrayInitialize(Balance,EMPTY_VALUE);
  ANumber=AccountNumber();
  minfosymbols="";
  m1symbols="";
  First=true;
  TimeBar=0;
 }
 if (!IsConnected())
 {
  Print("Связь с сервером отсутствует или прервана");
  return(0);
 }
 if (!OrderSelect(0,SELECT_BY_POS,MODE_HISTORY)) return(0);
 if (First)
 {
  First=false;
  MaxProfit=-EMPTY_VALUE;
  AbsDrawdown=0.0;
  MaxDrawdown=0.0;
  RelDrawdown=0.0;
  if (Period()>PERIOD_D1)
  {
   Alert("Период не может быть больше D1"); 
   return(0);
  }
  historytotal=OrdersHistoryTotal();
  opentotal=OrdersTotal();
  total=historytotal+opentotal;
  ArrayResize(OpenTime_Ticket,total);
  for (i=0;i<historytotal;i++) if (OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
  {
   if (Select())
   {
    OpenTime_Ticket[i][0]=OrderOpenTime();
    OpenTime_Ticket[i][1]=OrderTicket();
   }
   else
   {
    OpenTime_Ticket[i][0]=EMPTY_VALUE;
    total--;
   }
  }
  if (opentotal>0)
  {
   for (i=0;i<opentotal;i++) if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
   {
    if (Select())
    {
     OpenTime_Ticket[historytotal+i][0]=OrderOpenTime();
     OpenTime_Ticket[historytotal+i][1]=OrderTicket();
    }
    else
    {
     OpenTime_Ticket[historytotal+i][0]=EMPTY_VALUE;
     total--;
    }
   }
  }
  ArraySort(OpenTime_Ticket);
  ArrayResize(OpenTime_Ticket,total);
  ArrayResize(CloseTime,total);
  ArrayResize(Type,total);
  ArrayResize(Lots,total);
  ArrayResize(Instrument,total);
  ArrayResize(OpenPrice,total);
  ArrayResize(ClosePrice,total);
  ArrayResize(Commission,total);
  ArrayResize(Swap,total);
  ArrayResize(CurSwap,total);
  ArrayResize(DaySwap,total);
  ArrayResize(Profit,total);
  ArrayResize(Magic,total);
  for (i=0;i<total;i++) if (OrderSelect(OpenTime_Ticket[i][1],SELECT_BY_TICKET)) ReadOrder(i);
  if (Type[0]<6)
  {
   Alert("История сделок загружена не полностью");
   return(0);
  }
  if (File_Write)
  {
   filename=StringConcatenate(AccountNumber(),"_",Period(),".csv");
   handle=FileOpen(filename,FILE_CSV|FILE_WRITE);
   if (handle<0)
   {
    Alert("Ошибка #",GetLastError()," при открытии файла");
    return(0);
   }
  }
  start=0;
  CurrentBalance=0.0;
  beginbar=iBarShift(NULL,0,OpenTime_Ticket[0][0]);
  for (i=beginbar;i>=0;i--)
  {
   open=true;
   equityopen=0.0;
   TimeBar=iTime(NULL,0,i);
   for (m=0;m<Period();m++)
   {
    if (TimeBar>TimeCurrent()) break;
    equityclose=0.0;
    for (j=start;j<total;j++)
    {
     if (OpenTime_Ticket[j][0]>TimeBar+60) break;
     if (CloseTime[start]<TimeBar) start++;
     if (CloseTime[j]>=TimeBar && CloseTime[j]<TimeBar+60 && Type[j]>5)
     {
      CurrentBalance+=Profit[j];
      if (i==beginbar)
      {
       StartBalance=Profit[j];
       open=true;
      }
      objectname=StringConcatenate("Balance ",TimeToStr(OpenTime_Ticket[j][0])," ",Unique);
      if (ObjectFind(objectname)==-1) ObjectCreate(objectname,OBJ_VLINE,Window,TimeBar,0);
      ObjectSetText(objectname,StringConcatenate(Instrument[j],": ",DoubleToStr(Profit[j],2)," ",AccountCurrency()));
      ObjectSet(objectname,OBJPROP_TIME1,TimeBar);
      ObjectSet(objectname,OBJPROP_COLOR,OrangeRed);
      ObjectSet(objectname,OBJPROP_WIDTH,2);
      continue;
     }
     if (CloseTime[j]>=TimeBar && CloseTime[j]<TimeBar+60 && ClosePrice[j]!=0) CurrentBalance+=Swap[j]+Commission[j]+Profit[j];
     else if (OpenTime_Ticket[j][0]<=TimeBar && CloseTime[j]>=TimeBar)
     {
      if (MarketInfo(Instrument[j],MODE_POINT)==0)
      {
       if (StringFind(minfosymbols,Instrument[j])==-1)
       {
        Alert("В обзоре рынка не хватает "+Instrument[j]);
        minfosymbols=StringConcatenate(minfosymbols," ",Instrument[j]);
       }
       continue;
      }
      bar=iBarShift(Instrument[j],PERIOD_M1,TimeBar);
      if (iTime(Instrument[j],PERIOD_M1,bar)>TimeBar+300)
      {
       if (StringFind(m1symbols,Instrument[j])==-1)
       {
        Alert("Отсутствует история M1 по "+Instrument[j]+" начиная с "+TimeToStr(iTime(Instrument[j],PERIOD_M1,bar)));
        m1symbols=StringConcatenate(m1symbols," ",Instrument[j]);
       }
       continue;
      }
      if (open)
      {
       if (TimeDayOfWeek(iTime(NULL,0,i))!=TimeDayOfWeek(iTime(NULL,0,i+1)) && OpenTime_Ticket[j][0]<TimeBar)
       {
        switch ((int)MarketInfo(Instrument[j],MODE_PROFITCALCMODE))
        {
         case 0:
         {
          if (TimeDayOfWeek(iTime(NULL,0,i))==4) CurSwap[j]+=3*DaySwap[j];
          else CurSwap[j]+=DaySwap[j];
         } break;
         case 1:
         {
          if (TimeDayOfWeek(iTime(NULL,0,i))==1) CurSwap[j]+=3*DaySwap[j];
          else CurSwap[j]+=DaySwap[j];
         }
        }
       }
       if (Type[j]==OP_BUY)
       {
        lotsize=LotSize(Instrument[j],TimeBar,false);
        equityopen+=Commission[j]+CurSwap[j]+(iOpen(Instrument[j],PERIOD_M1,bar)-OpenPrice[j])*Lots[j]*lotsize;
       }
       else
       {
        spread=MarketInfo(Instrument[j],MODE_POINT)*MarketInfo(Instrument[j],MODE_SPREAD);
        lotsize=LotSize(Instrument[j],TimeBar,false);
        equityopen+=Commission[j]+CurSwap[j]+(OpenPrice[j]-iOpen(Instrument[j],PERIOD_M1,bar)-spread)*Lots[j]*lotsize;
       }
      }
      if (Type[j]==OP_BUY)
      {
       lotsize=LotSize(Instrument[j],TimeBar,true);
       equityclose+=Commission[j]+CurSwap[j]+(iClose(Instrument[j],PERIOD_M1,bar)-OpenPrice[j])*Lots[j]*lotsize;
      }
      else
      {
       spread=MarketInfo(Instrument[j],MODE_POINT)*MarketInfo(Instrument[j],MODE_SPREAD);
       lotsize=LotSize(Instrument[j],TimeBar,true);
       equityclose+=Commission[j]+CurSwap[j]+(OpenPrice[j]-iClose(Instrument[j],PERIOD_M1,bar)-spread)*Lots[j]*lotsize;
      }
     }
    }
    TimeBar+=60;
    if (open)
    {
     equityopen+=CurrentBalance;
     equityhigh=equityopen;
     equitylow=equityopen;
     open=false;
    }
    equityclose+=CurrentBalance;
    if (equityhigh<equityclose) equityhigh=equityclose;
    if (equitylow>equityclose)  equitylow=equityclose;
    if (Show_Info) Drawdown(equityclose);
   }
   if (Show_Balance) Balance[i]=NormalizeDouble(CurrentBalance,2);
   MaskShade[i]=NormalizeDouble(equitylow,2);
   if (equityopen<=equityclose)
   {
    EquityBodyUp[i]=NormalizeDouble(equityclose,2);
    MaskBody[i]=NormalizeDouble(equityopen,2);
    EquityShadeUp[i]=NormalizeDouble(equityhigh,2);
    if (EquityShadeUp[i]==MaskShade[i]) EquityLine[i]=equityhigh;
   }
   else
   {
    EquityBodyDown[i]=NormalizeDouble(equityopen,2);
    MaskBody[i]=NormalizeDouble(equityclose,2);
    EquityShadeDown[i]=NormalizeDouble(equityhigh,2);
    if (EquityShadeDown[i]==MaskShade[i]) EquityLine[i]=equityhigh;
   }
   if (equityclose<0) EquityLine[i]=equityclose;
   if (File_Write)
   {
    time=StringConcatenate(TimeToStr(iTime(NULL,0,i),TIME_DATE),";",TimeToStr(iTime(NULL,0,i),TIME_MINUTES));
    if (FileWrite(handle,time,equityopen,equityhigh,equitylow,equityclose,CurrentBalance)<0) Print("Ошибка #",GetLastError()," при записи в файл");
   }
  }
  TimeBar=Time[0];
  ArrayResize(OpenTime_Ticket,opentotal);
  if (opentotal>0)
  {
   for (i=0;i<opentotal;i++) if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) OpenTime_Ticket[i][1]=OrderTicket();
  }
  if (File_Write) FileClose(handle);
 }
 else
 {
  if (TimeBar!=Time[0])
  {
   TimeBar=Time[0];
   equityopen=0.0;
   equityclose=0.0;
   open=true;
  }
  if (Only_Comment=="" && Only_Magics=="" && Only_Symbols=="" && !Only_Current && !Only_Buys && !Only_Sells)
  {
   if (Show_Balance) Balance[0]=NormalizeDouble(AccountBalance(),2);
   if (open)
   {
    equityopen=AccountEquity();
    equityhigh=equityopen;
    equitylow=equityopen;
    open=false;
   }
   equityclose=AccountEquity();
   if (equityclose<equitylow)  equitylow=equityclose;
   if (equityclose>equityhigh) equityhigh=equityclose;
   if (Show_Info) Drawdown(AccountEquity());
  }
  else
  {
   opentotal=ArraySize(OpenTime_Ticket);
   if (opentotal>0)
   {
    for (i=0;i<opentotal;i++)
    {
     if (!OrderSelect(OpenTime_Ticket[i][1],SELECT_BY_TICKET)) continue;
     if (OrderCloseTime()==0) continue;
     else if (Select()) CurrentBalance+=OrderCommission()+OrderSwap()+OrderProfit();
    }
   }
   equityclose=0.0;
   opentotal=OrdersTotal();
   if (opentotal>0)
   {
    for (i=0;i<opentotal;i++)
    {
     if (!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
     if (Select()) equityclose+=OrderCommission()+OrderSwap()+OrderProfit();
    }
   }
   equityclose+=CurrentBalance;
   if (Show_Balance) Balance[0]=NormalizeDouble(CurrentBalance,2);
   if (open)
   {
    equityopen=equityclose;
    equitylow=equityopen;
    equityhigh=equityopen;
    open=false;
   }
   if (equityclose<equitylow)  equitylow=equityclose;
   if (equityclose>equityhigh) equityhigh=equityclose;
   if (Show_Info) Drawdown(equityclose);
   ArrayResize(OpenTime_Ticket,opentotal);
   if (opentotal>0)
   {
    for (i=0;i<opentotal;i++) if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) OpenTime_Ticket[i][1]=OrderTicket();
   }
  }
  if (equityopen<=equityclose)
  {
   EquityBodyDown[0]=EMPTY_VALUE;
   EquityBodyUp[0]=NormalizeDouble(equityclose,2);
   MaskBody[0]=NormalizeDouble(equityopen,2);
   EquityShadeDown[0]=EMPTY_VALUE;
   EquityShadeUp[0]=NormalizeDouble(equityhigh,2);
  }
  else
  {
   EquityBodyUp[0]=EMPTY_VALUE;
   EquityBodyDown[0]=NormalizeDouble(equityopen,2);
   MaskBody[0]=NormalizeDouble(equityclose,2);
   EquityShadeUp[0]=EMPTY_VALUE;
   EquityShadeDown[0]=NormalizeDouble(equityhigh,2);
  }
  MaskShade[0]=NormalizeDouble(equitylow,2);
  if (equityhigh==equitylow) EquityLine[0]=equityhigh; else EquityLine[0]=EMPTY_VALUE;
 }
 objectname=StringConcatenate("Equity Level ",Unique);
 if (ObjectFind(objectname)==-1)
 {
  ObjectCreate(objectname,OBJ_HLINE,Window,0,NormalizeDouble(equityclose,2));
  ObjectSet(objectname,OBJPROP_STYLE,STYLE_DOT);
  ObjectSet(objectname,OBJPROP_COLOR,Silver);
 }
 ObjectSet(objectname,OBJPROP_PRICE1,NormalizeDouble(equityclose,2));
 if (Show_Info)
 {
  objectname=StringConcatenate("Absolute Drawdown ",Unique);
  text=StringConcatenate("Absolute Drawdown: ",DoubleToStr(AbsDrawdown,2));
  LabelCreate(objectname,text,10);
  if (MaxPeak>0)
  {
   objectname=StringConcatenate("Maximal Drawdown ",Unique);
   text=StringConcatenate("Maximal Drawdown: ",DoubleToStr(MaxDrawdown,2)," (",DoubleToStr(100*MaxDrawdown/MaxPeak,2),"%)");
   LabelCreate(objectname,text,30);
  }
  objectname=StringConcatenate("Relative Drawdown ",Unique);
  text=StringConcatenate("Relative Drawdown: ",DoubleToStr(RelDrawdown,2),"% (",DoubleToStr(Drawdown,2),")");
  LabelCreate(objectname,text,50);
  if (MaxDrawdown>0)
  {
   objectname=StringConcatenate("Recovery Factor ",Unique);
   RecoveryFactor=(equityclose-StartBalance)/MaxDrawdown;
   text=StringConcatenate("Recovery Factor: ",DoubleToStr(RecoveryFactor,2));
   LabelCreate(objectname,text,70);
  }
 }
 if (Alert_Drawdown>0) AlertDrawdown();
 //Print("Calculating - ",GetTickCount()-tick," ms");
 return(0);
}
//+----------------------------------------------------------------------------+
//|  Создание текстовой метки                                                  |
//+----------------------------------------------------------------------------+
void LabelCreate(string name, string str, int y)
{
 if (ObjectFind(name)==-1)
 {
  ObjectCreate(name,OBJ_LABEL,Window,0,0);
  ObjectSet(name,OBJPROP_XDISTANCE,10);
  ObjectSet(name,OBJPROP_YDISTANCE,y);
  ObjectSet(name,OBJPROP_CORNER,1);
  ObjectSet(name,OBJPROP_COLOR,SlateGray);
 }
 ObjectSetText(name,str);
}
//+----------------------------------------------------------------------------+
//|  Чтение данных ордера                                                      |
//+----------------------------------------------------------------------------+
void ReadOrder(int n)
{
 Type[n]=OrderType();
 if (OrderType()>5) Instrument[n]=OrderComment();
 else Instrument[n]=OrderSymbol();
 Lots[n]=OrderLots();
 OpenPrice[n]=OrderOpenPrice();
 int close;
 if (OrderCloseTime()!=0)
 {
  CloseTime[n]=OrderCloseTime();
  ClosePrice[n]=OrderClosePrice();
  close=iBarShift(NULL,0,OrderCloseTime());
 }
 else
 {
  CloseTime[n]=TimeCurrent();
  ClosePrice[n]=0.0;
  close=0;
 }
 Commission[n]=OrderCommission();
 Swap[n]=OrderSwap();
 Profit[n]=OrderProfit();
 CurSwap[n]=0.0;
 int swapdays=0;
 int open=iBarShift(NULL,0,OrderOpenTime());
 for (int b=open-1;b>=close;b--)
 {
  if (TimeDayOfWeek(iTime(NULL,0,b))!=TimeDayOfWeek(iTime(NULL,0,b+1)))
  {
   switch ((int)MarketInfo(Instrument[n],MODE_PROFITCALCMODE))
   {
    case 0:
    {
     if (TimeDayOfWeek(iTime(NULL,0,b))==4) swapdays+=3;
     else swapdays++;
    } break;
    case 1:
    {
     if (TimeDayOfWeek(iTime(NULL,0,b))==1) swapdays+=3;
     else swapdays++;
    }
   }
  }
 }
 if (swapdays>0) DaySwap[n]=Swap[n]/swapdays; else DaySwap[n]=0.0;
 Magic[n]=OrderMagicNumber();
 if (Lots[n]==0)
 {
  string ticket=StringSubstr(OrderComment(),StringFind(OrderComment(),"#")+1);
  if (OrderSelect(StrToInteger(ticket),SELECT_BY_TICKET,MODE_HISTORY)) Lots[n]=OrderLots();
 }
}
//+----------------------------------------------------------------------------+
//|  Расчёт просадки                                                           |
//+----------------------------------------------------------------------------+
void Drawdown(double equity)
{
 double relative;
 if (AbsDrawdown<StartBalance-equity) AbsDrawdown=StartBalance-equity;
 if (equity>MaxProfit) MaxProfit=equity;
 if (MaxDrawdown<MaxProfit-equity)
 {
  MaxDrawdown=MaxProfit-equity;
  MaxPeak=MaxProfit;
  if (MaxPeak>0)
  {
   relative=100*MaxDrawdown/MaxPeak;
   if (RelDrawdown<relative)
   {
    RelDrawdown=relative;
    Drawdown=MaxDrawdown;
   }
  }
 }
}
//+----------------------------------------------------------------------------+
//|  Расчёт просадки для алерта                                                |
//+----------------------------------------------------------------------------+
void AlertDrawdown()
{
 int bar=0;
 double high=0,relative,level;
 static double maxpeak,maxprofit,maxdrawdown,reldrawdown,drawdown,balanceDD,maxDD;
 static datetime time,timemaxprofit;
 datetime timehigh=0,timelow=0;
 string name,drawdownstr,text,symbols="",magics="";
   
 if (time!=Time[0])
 {
  time=Time[0];
  maxprofit=-EMPTY_VALUE;
  maxdrawdown=0.0;
  reldrawdown=0.0;
  balanceDD=0.0;
  bar=Bars_History;
  maxDD=Alert_Drawdown;
 }
 for (int i=bar;i>=0;i--)
 {
  if (EquityShadeUp[i]!=EMPTY_VALUE) high=EquityShadeUp[i];
  else if (EquityShadeDown[i]!=EMPTY_VALUE) high=EquityShadeDown[i];
  if (high>maxprofit)
  {
   maxprofit=high;
   timemaxprofit=Time[i];
  }
  if (balanceDD<Balance[i]-MaskShade[i]) balanceDD=Balance[i]-MaskShade[i];
  if (maxdrawdown<maxprofit-MaskShade[i])
  {
   maxdrawdown=maxprofit-MaskShade[i];
   maxpeak=maxprofit;
   timehigh=timemaxprofit;
   if (maxpeak>0)
   {
    relative=NormalizeDouble(100*maxdrawdown/maxpeak,1);
    if (reldrawdown<relative)
    {
     reldrawdown=relative;
     drawdown=maxdrawdown;
     timelow=Time[i];
    }
   }
  }
 }
 if (reldrawdown>maxDD)
 {
  maxDD=reldrawdown;
  if (Only_Symbols!="") symbols=Only_Symbols;
  else if (Only_Current) symbols=Symbol();
  if (Only_Magics!="") magics=Only_Magics;
  if (maxDD>Max_Drawdown) text=StringConcatenate("Внимание! Превышен уровень допустимой просадки в ",DoubleToStr(Max_Drawdown,1),"%\n");
  else text=StringConcatenate("Предупреждение о высокой просадке более ",DoubleToStr(Alert_Drawdown,1),"%\n");
  if (symbols!="") text=StringConcatenate(text,"Инструмент(ы): ",symbols,"\n");
  if (magics!="") text=StringConcatenate(text,"Магический номер(а): ",magics,"\n");
  drawdownstr=StringConcatenate(DoubleToStr(reldrawdown,1),"% (",DoubleToStr(drawdown,2)," ",AccountCurrency(),")");
  text=StringConcatenate(text,"Просадка по эквити за ",Bars_History," последних баров ",drawdownstr,"\n");
  text=StringConcatenate(text,"Допустимая просадка составляет ",DoubleToStr(Max_Drawdown,1),"%\n");
  if (balanceDD>0) text=StringConcatenate(text,"Просадка от баланса за тот же период составила ",DoubleToStr(balanceDD,2)," ",AccountCurrency());
  Alert(text);
  name=StringConcatenate("Drawdown Line ",Unique);
  if (ObjectFind(name)==-1)
  {
   ObjectCreate(name,OBJ_TREND,Window,timehigh,maxpeak,timelow,maxpeak-drawdown);
   ObjectSetText(name,"          "+drawdownstr);
   ObjectSet(name,OBJPROP_COLOR,Red);
   ObjectSet(name,OBJPROP_RAY,false);
  }
  ObjectSetText(name,"          "+drawdownstr);
  ObjectSet(name,OBJPROP_PRICE1,maxpeak);
  ObjectSet(name,OBJPROP_PRICE2,maxpeak-drawdown);
  ObjectSet(name,OBJPROP_TIME1,timehigh);
  ObjectSet(name,OBJPROP_TIME2,timelow);
 }
 
 name=StringConcatenate("Begin Monitoring ",Unique);
 if (ObjectFind(name)==-1)
 {
  ObjectCreate(name,OBJ_VLINE,Window,Time[Bars_History],0);
  ObjectSet(name,OBJPROP_COLOR,SlateGray);
  ObjectSetText(name,"Begin Monitoring");
 }
 ObjectSet(name,OBJPROP_TIME1,Time[Bars_History]);
 
 name=StringConcatenate("Max Profit ",Unique);
 level=NormalizeDouble(maxprofit,2);
 if (ObjectFind(name)==-1)
 {
  ObjectCreate(name,OBJ_TREND,Window,timemaxprofit,level,Time[0],level);
  ObjectSet(name,OBJPROP_COLOR,DodgerBlue);
  ObjectSet(name,OBJPROP_RAY,false);
  ObjectSetText(name,"Max Profit");
 }
 ObjectSet(name,OBJPROP_PRICE1,level);
 ObjectSet(name,OBJPROP_PRICE2,level);
 ObjectSet(name,OBJPROP_TIME1,timemaxprofit);
 ObjectSet(name,OBJPROP_TIME2,Time[0]);
 
 name=StringConcatenate("Alert Drawdown ",Unique);
 level=NormalizeDouble(maxprofit*(1-Alert_Drawdown/100),2);
 if (ObjectFind(name)==-1)
 {
  ObjectCreate(name,OBJ_TREND,Window,timemaxprofit,level,Time[0],level);
  ObjectSet(name,OBJPROP_COLOR,DarkOrange);
  ObjectSet(name,OBJPROP_RAY,false);
  ObjectSetText(name,"Alert Drawdown "+DoubleToStr(Alert_Drawdown,1)+"%");
 }
 ObjectSet(name,OBJPROP_PRICE1,level);
 ObjectSet(name,OBJPROP_PRICE2,level);
 ObjectSet(name,OBJPROP_TIME1,timemaxprofit);
 ObjectSet(name,OBJPROP_TIME2,Time[0]);
  
 name=StringConcatenate("Max Drawdown ",Unique);
 level=NormalizeDouble(maxprofit*(1-Max_Drawdown/100),2);
 if (ObjectFind(name)==-1)
 {
  ObjectCreate(name,OBJ_TREND,Window,timemaxprofit,level,Time[0],level);
  ObjectSet(name,OBJPROP_COLOR,Red);
  ObjectSet(name,OBJPROP_RAY,false);
  ObjectSetText(name,"Max Drawdown "+DoubleToStr(Max_Drawdown,1)+"%");
 }
 ObjectSet(name,OBJPROP_PRICE1,level);
 ObjectSet(name,OBJPROP_PRICE2,level);
 ObjectSet(name,OBJPROP_TIME1,timemaxprofit);
 ObjectSet(name,OBJPROP_TIME2,Time[0]);
}
//+----------------------------------------------------------------------------+
//|  Определение размера контракта                                             |
//+----------------------------------------------------------------------------+
double LotSize(string symbol, datetime tbar, bool close)
{
 double size=0;
 string BQ,currency=AccountCurrency();
 switch ((int)MarketInfo(symbol,MODE_PROFITCALCMODE))
 {
  case 0:
  {
   int sbar=iBarShift(symbol,PERIOD_M1,tbar);
   size=MarketInfo(symbol,MODE_LOTSIZE);
   if (StringSubstr(symbol,3,3)=="USD") break;
   if (StringSubstr(symbol,0,3)=="USD")
   {
    if (close) size=size/iClose(symbol,PERIOD_M1,sbar);
    else size=size/iOpen(symbol,PERIOD_M1,sbar);
   }
   else
   {
    BQ=StringSubstr(symbol,0,3)+"USD";
    if (iClose(BQ,PERIOD_M1,0)==0) BQ="USD"+StringSubstr(symbol,0,3);
    if (iClose(BQ,PERIOD_M1,0)==0) break;
    int BQbar=iBarShift(BQ,PERIOD_M1,tbar);
    if (StringSubstr(BQ,0,3)=="USD")
    {
     if (close) size=size/iClose(BQ,PERIOD_M1,BQbar)/iClose(symbol,PERIOD_M1,sbar);
     else size=size/iOpen(BQ,PERIOD_M1,BQbar)/iOpen(symbol,PERIOD_M1,sbar);
    }
    else
    {
     if (close) size=size*iClose(BQ,PERIOD_M1,BQbar)/iClose(symbol,PERIOD_M1,sbar);
     else size=size*iOpen(BQ,PERIOD_M1,BQbar)/iOpen(symbol,PERIOD_M1,sbar);
    }
   }
  } break;
  case 1: size=MarketInfo(symbol,MODE_LOTSIZE); break;
  case 2: size=MarketInfo(symbol,MODE_TICKVALUE)/MarketInfo(symbol,MODE_TICKSIZE);
 }
 if (currency!="USD")
 {
  BQ=currency+"USD";
  if (iClose(BQ,PERIOD_M1,0)==0)
  {
   BQ="USD"+currency;
   if (close) size*=iClose(BQ,PERIOD_M1,iBarShift(BQ,PERIOD_M1,tbar));
   else size*=iOpen(BQ,PERIOD_M1,iBarShift(BQ,PERIOD_M1,tbar));
  }
  else
  {
   if (close) size/=iClose(BQ,PERIOD_M1,iBarShift(BQ,PERIOD_M1,tbar));
   else size/=iOpen(BQ,PERIOD_M1,iBarShift(BQ,PERIOD_M1,tbar));
  }
 }
 return(size);
}
//+----------------------------------------------------------------------------+
//|  Выбор ордера по критериям                                                 |
//+----------------------------------------------------------------------------+
bool Select()
{
 if (OrderType()>5) return(true);
 if (OrderType()>1) return(false);
 if (Only_Comment!="")
 {
  if (StringFind(OrderComment(),Only_Comment)==-1) return(false);
 }
 if (Only_Magics!="")
 {
  if (StringFind(Only_Magics,DoubleToStr(OrderMagicNumber(),0))==-1) return(false);
 }
 if (Only_Symbols!="")
 {
  if (StringFind(Only_Symbols,OrderSymbol())==-1) return(false);
 }
 else if (Only_Current && OrderSymbol()!=Symbol()) return(false);
 if (Only_Buys && OrderType()!=OP_BUY) return(false);
 if (Only_Sells && OrderType()!=OP_SELL) return(false);
 return(true);
}
//+----------------------------------------------------------------------------+