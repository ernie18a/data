//+------------------------------------------------------------------+
//|                                                 AfterTesting.mq5 |
//|                                                          Sigma7i |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

#include <Object.mqh>
#include <Arrays\List.mqh>

input bool  DrawArrow     =true; // Рисовать стрелки
input color BuyLineColor  =C'3,95,172'; // Цвет покупки
input int   BuyWidth      =2;                  // Толщина линии
input color SellLineColor =C'225,68,29'; // Цвет продажи
input int   SellWidth     =2; // Толщина линии
input color ClrStartPos=clrYellow;
input color ClrEndPos=clrDarkTurquoise;
//+------------------------------------------------------------------+
//| Класс для сбора информации об операциях                          |
//+------------------------------------------------------------------+
class COperation : public CObject
  {
public:
   string            m_Name;
   bool              m_IsBuy;
   bool              m_IsWinner;
   string            m_StartPosName;
   string            m_EndPosName;
   double            m_StartPosPrice;
   double            m_EndPosPrice;
   datetime          m_StartPosDt;
   datetime          m_EndPosDt;
  };

// global variables
CList *historyList;

// constant variables 
color clrBuy=C'3,95,172',clrSell=C'225,68,29';
color btn_background_color=C'38,118,166';           // Цвет кнопки при наведении курсора
color btn_std_color=clrGray;   // стандартный цвет кнопок

string btnIdShowBuy="ShowBuy";
string btnIdShowSell="ShowSell";
string btnIdShowWinners="ShowWinners";
string btnIdShowLosses="ShowLosses";
string btnIdStartPoint="StartPoint";
string btnIdEndPoint="EndPoint";

//string arr[] = {btnIdShowBuy, btnIdShowSell, btnIdShowWinners, btnIdShowLosses, btnIdStartPoint, btnIdEndPoint};
string buttonsArr[]={"ShowBuy","ShowSell","ShowWinners","ShowLosses","StartPoint","EndPoint"};

bool btnStateShowBuy=true;
bool btnStateShowSell=true;
bool btnStateShowWinners=false;
bool btnStateShowLosses=false;
bool btnStateStartPoint=false;
bool btnStateEndPoint=false;
//+------------------------------------------------------------------+
//| Старт                                                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Включим слежение за событиями мыши
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);
   CreateButtons();
   if(!GetOperationsHistory())
      return INIT_FAILED;

   OnButtonStateChanged();

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Деинициализация                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0);
   Comment("");
//--- Включим обратно прокрутку графика
   ChartSetInteger(0,CHART_MOUSE_SCROLL,true);
//--- Отключим слежение за событиями мыши
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,false);

   SetDefaultLines();

   if(historyList!=NULL)
      delete historyList;
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
//--- return value of prev_calculated for next call
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
//--- проверим событие на нажатие кнопки мышки 
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- если нажатие на объекте с именем btnIdShowBuy 
      if(sparam==btnIdShowBuy)
        {
         //--- состояние кнопки - нажата кнопка или нет 
         btnStateShowBuy=ObjectGetInteger(0,btnIdShowBuy,OBJPROP_STATE);
         OnButtonStateChanged();
        }
      //--- если нажатие на объекте с именем btnIdShowSell
      if(sparam==btnIdShowSell)
        {
         //--- состояние кнопки - нажата кнопка или нет 
         btnStateShowSell=ObjectGetInteger(0,btnIdShowSell,OBJPROP_STATE);
         OnButtonStateChanged();
        }
      //--- если нажатие на объекте с именем btnIdShowSell        
      if(sparam==btnIdShowWinners)
        {
         //--- состояние кнопки - нажата кнопка или нет 
         btnStateShowWinners=ObjectGetInteger(0,btnIdShowWinners,OBJPROP_STATE);
         OnButtonStateChanged();
        }

      if(sparam==btnIdShowLosses)
        {
         //--- состояние кнопки - нажата кнопка или нет 
         btnStateShowLosses=ObjectGetInteger(0,btnIdShowLosses,OBJPROP_STATE);
         OnButtonStateChanged();
        }

      if(sparam==btnIdStartPoint)
        {
         //--- состояние кнопки - нажата кнопка или нет 
         btnStateStartPoint=ObjectGetInteger(0,btnIdStartPoint,OBJPROP_STATE);
         OnButtonStateChanged();
        }

      if(sparam==btnIdEndPoint)
        {
         //--- состояние кнопки - нажата кнопка или нет 
         btnStateEndPoint=ObjectGetInteger(0,btnIdEndPoint,OBJPROP_STATE);
         OnButtonStateChanged();
        }

      ChartRedraw();// принудительно перерисуем все объекты на графике 
      return;
     }

   if(id==CHARTEVENT_MOUSE_MOVE)
     {

      string name="";
      if(ButtonMouseMoveFocus(lparam,dparam,name))
        {
         // отключим скролл графика
         ChartSetInteger(0,CHART_MOUSE_SCROLL,false);
         ObjectSetInteger(0,name,OBJPROP_BGCOLOR,btn_background_color);
        }
      else
        {
         SetButtonColorToDefalult();
         ChartSetInteger(0,CHART_MOUSE_SCROLL,true);
        }
      ChartRedraw();// принудительно перерисуем все объекты на графике 
      return;
     }
  }
//+------------------------------------------------------------------+
//| Создает кнопки управления                                        |
//+------------------------------------------------------------------+
void CreateButtons()
  {
//--- создадим кнопку, Show buy
   ObjectCreate(0,btnIdShowBuy,OBJ_BUTTON,0,100,100);
   ObjectSetInteger(0,btnIdShowBuy,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,btnIdShowBuy,OBJPROP_BGCOLOR,btn_std_color);
   ObjectSetInteger(0,btnIdShowBuy,OBJPROP_XDISTANCE,200);
   ObjectSetInteger(0,btnIdShowBuy,OBJPROP_YDISTANCE,0);
   ObjectSetInteger(0,btnIdShowBuy,OBJPROP_XSIZE,100);
   ObjectSetInteger(0,btnIdShowBuy,OBJPROP_YSIZE,15);
   ObjectSetString(0,btnIdShowBuy,OBJPROP_FONT,"Arial");
   ObjectSetString(0,btnIdShowBuy,OBJPROP_TEXT,"Show buy");
   ObjectSetInteger(0,btnIdShowBuy,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,btnIdShowBuy,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,btnIdShowBuy,OBJPROP_STATE,btnStateShowBuy);

//--- создадим кнопку, Show sell
   ObjectCreate(0,btnIdShowSell,OBJ_BUTTON,0,100,100);
   ObjectSetInteger(0,btnIdShowSell,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,btnIdShowSell,OBJPROP_BGCOLOR,btn_std_color);
   ObjectSetInteger(0,btnIdShowSell,OBJPROP_XDISTANCE,200);
   ObjectSetInteger(0,btnIdShowSell,OBJPROP_YDISTANCE,16);
   ObjectSetInteger(0,btnIdShowSell,OBJPROP_XSIZE,100);
   ObjectSetInteger(0,btnIdShowSell,OBJPROP_YSIZE,15);
   ObjectSetString(0,btnIdShowSell,OBJPROP_FONT,"Arial");
   ObjectSetString(0,btnIdShowSell,OBJPROP_TEXT,"Show sell");
   ObjectSetInteger(0,btnIdShowSell,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,btnIdShowSell,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,btnIdShowSell,OBJPROP_STATE,btnStateShowSell);

//--- создадим кнопку, Show winners
   ObjectCreate(0,btnIdShowWinners,OBJ_BUTTON,0,100,100);
   ObjectSetInteger(0,btnIdShowWinners,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,btnIdShowWinners,OBJPROP_BGCOLOR,btn_std_color);
   ObjectSetInteger(0,btnIdShowWinners,OBJPROP_XDISTANCE,200);
   ObjectSetInteger(0,btnIdShowWinners,OBJPROP_YDISTANCE,31);
   ObjectSetInteger(0,btnIdShowWinners,OBJPROP_XSIZE,100);
   ObjectSetInteger(0,btnIdShowWinners,OBJPROP_YSIZE,15);
   ObjectSetString(0,btnIdShowWinners,OBJPROP_FONT,"Arial");
   ObjectSetString(0,btnIdShowWinners,OBJPROP_TEXT,"Show winners");
   ObjectSetInteger(0,btnIdShowWinners,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,btnIdShowWinners,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,btnIdShowWinners,OBJPROP_STATE,btnStateShowWinners);

//--- создадим кнопку, Show winners
   ObjectCreate(0,btnIdShowLosses,OBJ_BUTTON,0,100,100);
   ObjectSetInteger(0,btnIdShowLosses,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,btnIdShowLosses,OBJPROP_BGCOLOR,btn_std_color);
   ObjectSetInteger(0,btnIdShowLosses,OBJPROP_XDISTANCE,200);
   ObjectSetInteger(0,btnIdShowLosses,OBJPROP_YDISTANCE,46);
   ObjectSetInteger(0,btnIdShowLosses,OBJPROP_XSIZE,100);
   ObjectSetInteger(0,btnIdShowLosses,OBJPROP_YSIZE,15);
   ObjectSetString(0,btnIdShowLosses,OBJPROP_FONT,"Arial");
   ObjectSetString(0,btnIdShowLosses,OBJPROP_TEXT,"Show losses");
   ObjectSetInteger(0,btnIdShowLosses,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,btnIdShowLosses,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,btnIdShowLosses,OBJPROP_STATE,btnStateShowLosses);

//--- создадим кнопку, Show start point
   ObjectCreate(0,btnIdStartPoint,OBJ_BUTTON,0,100,100);
   ObjectSetInteger(0,btnIdStartPoint,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,btnIdStartPoint,OBJPROP_BGCOLOR,btn_std_color);
   ObjectSetInteger(0,btnIdStartPoint,OBJPROP_XDISTANCE,305);
   ObjectSetInteger(0,btnIdStartPoint,OBJPROP_YDISTANCE,16);
   ObjectSetInteger(0,btnIdStartPoint,OBJPROP_XSIZE,100);
   ObjectSetInteger(0,btnIdStartPoint,OBJPROP_YSIZE,15);
   ObjectSetString(0,btnIdStartPoint,OBJPROP_FONT,"Arial");
   ObjectSetString(0,btnIdStartPoint,OBJPROP_TEXT,"Start point");
   ObjectSetInteger(0,btnIdStartPoint,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,btnIdStartPoint,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,btnIdStartPoint,OBJPROP_STATE,btnStateStartPoint);

//--- создадим кнопку, Show end point
   ObjectCreate(0,btnIdEndPoint,OBJ_BUTTON,0,100,100);
   ObjectSetInteger(0,btnIdEndPoint,OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,btnIdEndPoint,OBJPROP_BGCOLOR,btn_std_color);
   ObjectSetInteger(0,btnIdEndPoint,OBJPROP_XDISTANCE,305);
   ObjectSetInteger(0,btnIdEndPoint,OBJPROP_YDISTANCE,31);
   ObjectSetInteger(0,btnIdEndPoint,OBJPROP_XSIZE,100);
   ObjectSetInteger(0,btnIdEndPoint,OBJPROP_YSIZE,15);
   ObjectSetString(0,btnIdEndPoint,OBJPROP_FONT,"Arial");
   ObjectSetString(0,btnIdEndPoint,OBJPROP_TEXT,"End point");
   ObjectSetInteger(0,btnIdEndPoint,OBJPROP_FONTSIZE,10);
   ObjectSetInteger(0,btnIdEndPoint,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,btnIdEndPoint,OBJPROP_STATE,btnStateEndPoint);
  }
//+------------------------------------------------------------------+
//| Получает информацию из графических объектов                      |
//+------------------------------------------------------------------+
bool GetOperationsHistory()
  {
   double Line1,Line2;
   datetime Time1,Time2;
   long getcolor;
   string objName;
   int objectall=ObjectsTotal(0,0,-1);

   if(objectall==0)
     {
      Comment("No object to work. Нет объектов для работы");
      return false;
     }

   historyList=new CList();

   for(int i=0;i<objectall;i++)
     {
      objName=""; // на всякий случай
      objName=ObjectName(0,i,0,OBJ_TREND);
      if(objName!="")
        {
         Line1 = NormalizeDouble(ObjectGetDouble(0,objName,OBJPROP_PRICE,0),Digits());
         Line2 = NormalizeDouble(ObjectGetDouble(0,objName,OBJPROP_PRICE,1),Digits());
         Time1 = (datetime)ObjectGetInteger(0,objName,OBJPROP_TIME,0);
         Time2 = (datetime)ObjectGetInteger(0,objName,OBJPROP_TIME,1);
         getcolor=(color)ObjectGetInteger(0,objName,OBJPROP_COLOR);
         COperation *item=new COperation();
         item.m_Name=objName;
         item.m_StartPosPrice=Line1;
         item.m_EndPosPrice=Line2;
         item.m_StartPosDt = Time1;
         item.m_EndPosDt=Time2;

         if(getcolor==clrBuy)
           {
            item.m_IsBuy=true;
           }

         if(getcolor==clrSell)
           {
            item.m_IsBuy=false;
           }

         item.m_IsWinner=IsWiner(item);
         historyList.Add(item);
        }
     }

   GetOperationsArrows(objectall);

   int operations=historyList.Total();

   if(operations==0)
      return false;
   else
      Comment("loaded "+(string)operations+" operations");

   return true;
  }
//+------------------------------------------------------------------+
//| Чтобы была возможность навигации, нужны имена стрелок, получим их|
//+------------------------------------------------------------------+
void GetOperationsArrows(const int &objectall)
  {
// поиска по координатам у нас нет, поэтому переберем все стрелки и сопоставим с координатами(сложность n^2)
   string objName;
   int arrowType;
   double Line1;
   datetime Time1;

   for(int i=0;i<objectall;i++)
     {
      objName="";
      arrowType=0;
      objName=ObjectName(0,i);
      ENUM_OBJECT type=(ENUM_OBJECT)ObjectGetInteger(0,objName,OBJPROP_TYPE);

      // покупка
      if(type==OBJ_ARROW_BUY)
        {
         Line1 = NormalizeDouble(ObjectGetDouble(0,objName,OBJPROP_PRICE,0),Digits());
         Time1 = (datetime)ObjectGetInteger(0,objName,OBJPROP_TIME,0);
         COperation *node=historyList.GetFirstNode();
         for(; node!=NULL;node=node.Next())
           {
            if(node.m_StartPosPrice== Line1 && node.m_StartPosDt == Time1)
               node.m_StartPosName = objName;

            if(node.m_EndPosPrice== Line1 && node.m_EndPosDt == Time1)
               node.m_EndPosName = objName;
           }
        }
      // продажа
      if(type==OBJ_ARROW_SELL)
        {
         Line1 = NormalizeDouble(ObjectGetDouble(0,objName,OBJPROP_PRICE,0),Digits());
         Time1 = (datetime)ObjectGetInteger(0,objName,OBJPROP_TIME,0);

         COperation *node=historyList.GetFirstNode();
         for(;node!=NULL;node=node.Next())
           {
            if(node.m_StartPosPrice== Line1 && node.m_StartPosDt == Time1)
               node.m_StartPosName = objName;

            if(node.m_EndPosPrice== Line1 && node.m_EndPosDt == Time1)
               node.m_EndPosName = objName;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Определяет, является ли операция прибыльной                      |
//+------------------------------------------------------------------+
bool IsWiner(COperation &item)
  {
   if(item.m_IsBuy && item.m_StartPosPrice<item.m_EndPosPrice)
     {
      return true;
     }
   if(!item.m_IsBuy && item.m_StartPosPrice>item.m_EndPosPrice)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//| Обработчик нажатия на кнопки управления                          |
//+------------------------------------------------------------------+
void OnButtonStateChanged()
  {
   ObjectsDeleteAll(0);
   CreateButtons();

   COperation *node=historyList.GetFirstNode();
   for(; node!=NULL;node=node.Next())
     {
      //если покупка и нажата кнопка показывать покупки
      if(node.m_IsBuy && btnStateShowBuy)
        {
         DrawLinesCondition(node,BuyLineColor,BuyWidth);
        }

      //если продажа и нажата кнопка показывать продажи
      if(!node.m_IsBuy && btnStateShowSell)
        {
         DrawLinesCondition(node,SellLineColor,SellWidth);
        }
     }
  }
//+------------------------------------------------------------------+
//| Рисует линии в соответствии с правилами и параметрами            |
//+------------------------------------------------------------------+
void DrawLinesCondition(COperation &node,const color &clr,const int &lineWidth)
  {
   if(btnStateShowWinners && node.m_IsWinner)
     {
      ObjectCreate(0,node.m_Name,OBJ_TREND,0,node.m_StartPosDt,node.m_StartPosPrice,node.m_EndPosDt,node.m_EndPosPrice);
      ObjectSetInteger(0,node.m_Name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,node.m_Name,OBJPROP_WIDTH,lineWidth);
      DrawArrows(node,DrawArrow);
      DrawVerticalLinePosition(node.m_Name,node.m_StartPosDt,node.m_EndPosDt);
     }
   if(btnStateShowLosses && !node.m_IsWinner)
     {
      ObjectCreate(0,node.m_Name,OBJ_TREND,0,node.m_StartPosDt,node.m_StartPosPrice,node.m_EndPosDt,node.m_EndPosPrice);
      ObjectSetInteger(0,node.m_Name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,node.m_Name,OBJPROP_WIDTH,lineWidth);
      DrawArrows(node,DrawArrow);
      DrawVerticalLinePosition(node.m_Name,node.m_StartPosDt,node.m_EndPosDt);
     }

   if(!btnStateShowWinners && !btnStateShowLosses)
     {
      ObjectCreate(0,node.m_Name,OBJ_TREND,0,node.m_StartPosDt,node.m_StartPosPrice,node.m_EndPosDt,node.m_EndPosPrice);
      ObjectSetInteger(0,node.m_Name,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,node.m_Name,OBJPROP_WIDTH,lineWidth);
      DrawArrows(node,DrawArrow);
      DrawVerticalLinePosition(node.m_Name,node.m_StartPosDt,node.m_EndPosDt);
     }
  }
//+------------------------------------------------------------------+
//| Рисовать стрелки                                                 |
//+------------------------------------------------------------------+
void DrawArrows(COperation &node,bool canDrawArrow=true)
  {
   if(canDrawArrow)
     {
      if(node.m_IsBuy)
        {
         ObjectCreate(0,node.m_StartPosName,OBJ_ARROW_BUY,0,node.m_StartPosDt,node.m_StartPosPrice);
         ObjectCreate(0,node.m_EndPosName, OBJ_ARROW_SELL, 0,node.m_EndPosDt, node.m_EndPosPrice);
        }
      else
        {
         ObjectCreate(0,node.m_StartPosName,OBJ_ARROW_SELL,0,node.m_StartPosDt,node.m_StartPosPrice);
         ObjectCreate(0,node.m_EndPosName,OBJ_ARROW_BUY, 0,node.m_EndPosDt, node.m_EndPosPrice);
        }
     }
  }
//+------------------------------------------------------------------+
//| Рисует линии начала/конца операциии                              |
//+------------------------------------------------------------------+
void DrawVerticalLinePosition(const string &name,const datetime &Sdate,const datetime &Edate)
  {
   if(btnStateStartPoint)
     {
      string objName=name+"VlineS";
      ObjectCreate(0,objName,OBJ_VLINE,0,Sdate,0);
      ObjectSetInteger(0,objName,OBJPROP_COLOR,ClrStartPos);
     }
   if(btnStateEndPoint)
     {
      string objName=name+"VlineE";
      ObjectCreate(0,objName,OBJ_VLINE,0,Edate,0);
      ObjectSetInteger(0,objName,OBJPROP_COLOR,ClrEndPos);
     }
  }
//+------------------------------------------------------------------+
//| Проверка - находится ли кнопка в фокусе мыши                     |
//+------------------------------------------------------------------+
bool ButtonMouseMoveFocus(const long &x,const double &y,string &name)
  {
   int sizeX,sizeY,distX,distY;

   for(int i=ArraySize(buttonsArr)-1; i>=0; i--)
     {
      sizeX = (int)ObjectGetInteger(0,buttonsArr[i], OBJPROP_XSIZE);
      sizeY = (int)ObjectGetInteger(0,buttonsArr[i], OBJPROP_YSIZE);
      distX = (int)ObjectGetInteger(0,buttonsArr[i], OBJPROP_XDISTANCE);
      distY = (int)ObjectGetInteger(0,buttonsArr[i], OBJPROP_YDISTANCE);

      int endPointX = distX + sizeX;
      int endPointY = distY + sizeY;

      if(x>distX && x<endPointX && y>distY && y<endPointY)
        {
         name=buttonsArr[i];
         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Выставляет цвет кнопок обратно в дефолтное состояние             |
//+------------------------------------------------------------------+
void SetButtonColorToDefalult()
  {
   for(int i=ArraySize(buttonsArr)-1; i>=0; i--)
     {
      ObjectSetInteger(0,buttonsArr[i],OBJPROP_BGCOLOR,btn_std_color);
     }
  }
//+------------------------------------------------------------------+
//| Привести к первоначальному состоянию                             |
//+------------------------------------------------------------------+
void SetDefaultLines()
  {
   COperation *node=historyList.GetFirstNode();
   for(; node!=NULL;node=node.Next())
     {
      ObjectCreate(0,node.m_Name,OBJ_TREND,0,node.m_StartPosDt,node.m_StartPosPrice,node.m_EndPosDt,node.m_EndPosPrice);
      ObjectSetInteger(0,node.m_Name,OBJPROP_STYLE,STYLE_DOT);
      ObjectSetInteger(0,node.m_Name,OBJPROP_WIDTH,1);
      if(node.m_IsBuy)
        {
         ObjectSetInteger(0,node.m_Name,OBJPROP_COLOR,clrBuy);
        }
      else
        {
         ObjectSetInteger(0,node.m_Name,OBJPROP_COLOR,clrSell);
        }
      DrawArrows(node);
     }
  }
//+------------------------------------------------------------------+
