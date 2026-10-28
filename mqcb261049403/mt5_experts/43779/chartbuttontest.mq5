//+------------------------------------------------------------------+
//|                                              ChartButtonTest.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#include <Controls\Button.mqh>
 
 
// the class itself 
 
#define EVENT_DRAG 8010
#define EVENT_END_DRAG 8011
class CChartButton : public CButton
  {
private:
   double            m_price1;
   datetime          m_time1;
   double            m_price2;
   datetime          m_time2;
   static  bool      s_grabbed;
   bool              m_grabbed;
   int               m_Mousex;
   int               m_Mousey;
   bool              m_fixedtime;
   string            m_Text;
public:
   
                     CChartButton();
   double            GetTopPrice()       {  return m_price1;}
   double            GetBottomPrice()    {  return m_price2;}
   datetime          GetTime1()        {  return m_time1; }
   datetime          GetTime2()        {  return m_time2; }

   bool              OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   bool              Create(const long chart,const string name, const double Price, const datetime Time1, const datetime Time2);
   bool              Create(const long chart,const string name, const double price, const datetime time);
   bool              Move(const int x, const int y);
   bool              FixTime()             { return m_fixedtime;}
   void              FixTime(bool flag)    { m_fixedtime = flag;}
   bool              MouseInButton(int x, int y);
   void              SetText(string text);
   void              SetBottomPrice(double price);

   
protected:
   virtual bool      OnMouseDown(int mousex, int mousey);
   virtual bool      OnMouseUp();
   virtual bool      OnScroll();
   virtual bool      OnDrag(int x, int y);
   virtual bool      OnSetColorBackground(void) { ColorBorder(ColorBackground());  return CButton::OnSetColorBackground();}

  };

bool CChartButton::s_grabbed = false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CChartButton::CChartButton()
  {
   m_Mousex = 0;
   m_Mousey = 0;
   m_grabbed = false;
   
   ZOrder(1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CChartButton::Move(const int x,const int y)
{
   int X = x;
   int Y = y;
   CWnd::Move(x,y);
   ChartXYToTimePrice(ChartID(),X,Y,m_subwin,m_time1,m_price1);
   ChartXYToTimePrice(ChartID(),X+Width(),Y+Height(),m_subwin,m_time2,m_price2);
   return true;
}

void CChartButton::SetText(string text)
  {
   m_Text = text;
   Text(text+DoubleToString(GetBottomPrice(),(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS)));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CChartButton::MouseInButton(int x,int y)
  {
   if(x < Left() || x > Right())
      return false;
   if(y < Top() || y > Bottom())
      return false;
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CChartButton::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {   
   if(id == EVENT_DRAG+CHARTEVENT_CUSTOM && sparam == Name())
   {
      OnDrag((int)lparam,(int)dparam);  
      return true;
   }    
   if(id == CHARTEVENT_MOUSE_MOVE && (MouseInButton((int)lparam,(int)dparam) || m_grabbed) && sparam == "1")
   {
      OnMouseDown((int) lparam, (int) dparam);
      return true;
   }    
   if(id == CHARTEVENT_CHART_CHANGE)
   {
      OnScroll();
      return true;
   }
   if(id == CHARTEVENT_MOUSE_MOVE && sparam != "1")
   {
      OnMouseUp();
      return true;
   }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CChartButton::SetBottomPrice(double price)
{  
   int y, x;
   ChartTimePriceToXY(ChartID(),m_subwin,m_time2,price,x,y);  
   Move(Left(),y-20);
}

bool CChartButton::OnScroll()
  {
   int x1,y1;
   ChartTimePriceToXY(ChartID(),0,m_time1,m_price2,x1,y1);
   //PrintFormat("the time : %d the left coordinate : %d", m_time1,x1);
   CWnd::Move(x1,y1-Height());
   SetBottomPrice(m_price2);
   ChartRedraw();
   return true;
  }

bool CChartButton::OnDrag(int x, int y)
{
   if(!m_fixedtime)
      Move(x-m_Mousex,y-m_Mousey);
   else
      Move(Left(),y-m_Mousey);
   if(Right() > ChartGetInteger(ChartID(),CHART_WIDTH_IN_PIXELS))
      Move((int)ChartGetInteger(ChartID(),CHART_WIDTH_IN_PIXELS)-Width()-5,Top());  
   ChartRedraw();
   SetText(m_Text);
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CChartButton::OnMouseDown(int mousex, int mousey)
  {
   if(!m_grabbed && !CChartButton::s_grabbed)
     {
      if(!Pressed())
         Pressed(!Pressed());
      m_grabbed = true;
      CChartButton::s_grabbed = true;
      m_Mousex = mousex-Left();
      m_Mousey = mousey-Top();
      ChartSetInteger(ChartID(),CHART_MOUSE_SCROLL,false);
     }
   else if(m_grabbed)
     {
      EventChartCustom(ChartID(),EVENT_DRAG,mousex,mousey,Name());
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CChartButton::OnMouseUp()
  {
   if(m_grabbed || Pressed())
     {   
      ChartXYToTimePrice(ChartID(),Left(),Top(),m_subwin,m_time1,m_price1);
      ChartXYToTimePrice(ChartID(),Right(),Bottom(),m_subwin,m_time2,m_price2);
      ChartSetInteger(ChartID(),CHART_MOUSE_SCROLL,true);
      Pressed(!Pressed());
      m_grabbed = false;
      CChartButton::s_grabbed = false;
      EventChartCustom(ChartID(),EVENT_END_DRAG,Id(),GetBottomPrice(),Name());    
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CChartButton::Create(const long chart,const string name,const double Price,const datetime Time1,const datetime Time2)
  {
   m_price2 = Price;
   m_time1 = Time1;
   m_time2 = Time2;
   int x1 = 0,y1 = 0,y2 = 0,x2 = 0;
   ChartTimePriceToXY(ChartID(),0,Time1,Price,x1,y1);
   ChartTimePriceToXY(ChartID(),0,Time2,1,x2,y2);
   datetime feles;
   ChartXYToTimePrice(ChartID(),(int)Price,y1-20,m_subwin,feles,m_price1);
   if(x1 > x2)
     {
      m_time1 = Time2;
      m_time2 = Time1;
      int temp = x1;
      x1 = x2;
      x2 = temp;
     }
   ColorBackground(clrGray);
   Color(clrWhite); // Ide kell még azt megcsinálni, hogy ha szarul kreálom, kreálja be vhova és onnan elmoveolom.
   return CButton::Create(chart,name,0,x1,y1-20,x2,y1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CChartButton::Create(const long chart,const string name, const double price, const datetime time)
  {
   m_price2 = price;
   m_time1 = time;
   m_time2 = iTime(_Symbol,PERIOD_CURRENT,0);
   datetime extra;
   int x1 = 0,y1 = 0,y2 = 0,x2 = 0;
   ChartTimePriceToXY(ChartID(),0,m_time1,m_price2,x1,y2);
   ChartTimePriceToXY(ChartID(),0,m_time2,0,x2,y1);
   y1 = y2-20;
   ChartXYToTimePrice(ChartID(),0,y1,m_subwin,extra,m_price1);
   return CButton::Create(chart,name,0,x1,y1,x2,y2);
  }


// end of the class

CChartButton * Butti;


int OnInit()
{
   Butti = new CChartButton();
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   ChartSetInteger(ChartID(),CHART_EVENT_OBJECT_DELETE,1);
   ChartSetInteger(ChartID(),CHART_EVENT_MOUSE_MOVE,1);
   Butti.Create(ChartID(),"Name",ask,iTime(_Symbol,PERIOD_CURRENT,20));
   Butti.SetText("Your Text:");
   return 0;
}


void OnDeinit(const int reason)
  {
   delete Butti;
   EventKillTimer();
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(Butti)
      Butti.OnEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
