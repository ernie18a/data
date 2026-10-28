//+------------------------------------------------------------------+
//|                                                         Snow.mq5 |
//|                                       Copyright 2013,Viktor Moss |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013,Viktor Moss"
#property link      "https://www.mql5.com/ru/users/vicmos"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

input int      NSn      =10; // Number of smiles
input int      FontSize =16; // Size

string         Text="J";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSnow
  {
private:
   int               m_Num;
   string            m_Name;
   color             m_Color;
   long              m_X;
   int               m_Size;
   int               m_Speed;
   int               m_SmX;

public:
   void CSnowCreate(int n)
     {
      m_Num   = n;
      m_Color = cl[n%7];
      long xch=ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
      if(xch!=0) m_X=MathRand()%xch;
      else m_X=100;
      m_Size=MathRand()%FontSize+6; // 6 - 10
      m_Speed=MathRand()%7+2; // 2 - 8
      do m_SmX=MathRand()%6-3; while(m_SmX==0); // -3 - +3
      m_Name  = "Snow-"+IntegerToString(GetTickCount(),7,'0')+_Symbol+IntegerToString(n,3,'0');
      if(ObjectFind(0,m_Name)<0)ObjectCreate(0,m_Name,OBJ_LABEL,0,0,0);//--- создадим объект Label
      ObjectSetString(0,m_Name,OBJPROP_TEXT,Text);                     //--- установим текст для объекта Label 
      ObjectSetInteger(0,m_Name,OBJPROP_XDISTANCE,m_X);                //--- установим координату X
      ObjectSetInteger(0,m_Name,OBJPROP_YDISTANCE,0);                  //--- установим координату Y
      ObjectSetString(0,m_Name,OBJPROP_FONT,"Wingdings");              //--- установим шрифт надписи
      ObjectSetInteger(0,m_Name,OBJPROP_FONTSIZE,m_Size);              //--- установим размер шрифта    
      ObjectSetInteger(0,m_Name,OBJPROP_COLOR,m_Color);                //--- зададим цвет текста
      ObjectSetInteger(0,m_Name,OBJPROP_SELECTABLE,false);             //--- запретим выделение объекта мышкой   
     }

                    ~CSnow()
     {
      if(ObjectFind(0,m_Name)>=0) ObjectDelete(0,m_Name);
      ChartRedraw();
     }

   void SnowNext()
     {
      long yp = ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
      long xp = ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
      long y = ObjectGetInteger(0,m_Name,OBJPROP_YDISTANCE);
      long x = ObjectGetInteger(0,m_Name,OBJPROP_XDISTANCE);

      if(x+m_SmX<0) m_SmX=-m_SmX;
      if(x+m_SmX>=xp-ObjectGetInteger(0,m_Name,OBJPROP_XSIZE)) m_SmX=-m_SmX;
      if(x+ObjectGetInteger(0,m_Name,OBJPROP_XSIZE)>xp) x-=ObjectGetInteger(0,m_Name,OBJPROP_XSIZE)+2;
      if(y+m_Speed>yp-ObjectGetInteger(0,m_Name,OBJPROP_YSIZE)+1)
         m_Speed=-m_Speed;
      if(y> yp) y=yp-ObjectGetInteger(0,m_Name,OBJPROP_YSIZE)+1;
      if(y+m_Speed<0)
        {
         m_Speed=Sign(m_Speed)*(MathRand()%8+1); // 1 - 8
         m_Speed=-m_Speed;
         m_Size=MathRand()%FontSize+5; // 7 - 12
         m_Color=cl[MathRand()%7];
         ObjectSetInteger(0,m_Name,OBJPROP_FONTSIZE,m_Size);  //--- установим размер шрифта    
         ObjectSetInteger(0,m_Name,OBJPROP_COLOR,m_Color);    //--- зададим цвет текста
        }

      ObjectSetInteger(0,m_Name,OBJPROP_YDISTANCE,y+m_Speed); //--- установим координату Y
      ObjectSetInteger(0,m_Name,OBJPROP_XDISTANCE,x+m_SmX);   //--- установим координату X
      CoorX[m_Num]=(int)x;
      CoorY[m_Num]=(int)y;
      ChartRedraw();//Sleep(25);
     }
  };

CSnow Sn[];
int   CoorX[],CoorY[];
color cl[]={clrYellow,clrAqua,clrLime,clrRed,clrBlue,clrLawnGreen,clrMagenta};
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetMillisecondTimer(50);
   ArrayResize(Sn,NSn);
   ArrayResize(CoorX,NSn);
   ArrayResize(CoorY,NSn);
   MathSrand(GetTickCount());
   for(int i=0;i<NSn;i++) Sn[i].CSnowCreate(i);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   for(int i=0;i<NSn;i++) Sn[i].SnowNext();
  }
//+------------------------------------------------------------------+

int Sign(double C)
  {
   return C>=0?1:-1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DelAllObjects(string name)
  {
   string vName;
   int tot=ObjectsTotal(0);
   for(int i=tot; i>=0; i--)
     {
      vName=ObjectName(0,i);
      if(StringSubstr(vName,0,StringLen(name))==name) ObjectDelete(0,vName);
     }
  }
//+------------------------------------------------------------------+
