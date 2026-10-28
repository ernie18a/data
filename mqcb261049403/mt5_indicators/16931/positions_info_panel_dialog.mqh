//+------------------------------------------------------------------+
//|                                         Positions Info Panel.mq5 |
//|                              Copyright © 2016, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.001"
#include <Controls\Dialog.mqh>
#include <Canvas\Canvas.mqh>
#include <Controls\BmpButton.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct pos_info
  {
   string            name;         // наименование символа
   double            volume;       // итоговый объём
   //--- конструктор 
                     pos_info() { name=NULL; volume=0.0; }
  };
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT     (11)        // indent from left (with allowance for border width)
#define INDENT_TOP      (11)        // indent from top (with allowance for border width)
//+------------------------------------------------------------------+
//| Class CControlsDialog                                            |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class CPIPDialog : public CAppDialog
  {
private:
   CCanvas           m_canvas;                        // the canvas object
   CBmpButton        m_bmp_button;                    // the bmp_button object

public:
                     CPIPDialog(void);
                    ~CPIPDialog(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //---
   virtual void      CommentOut();

protected:
   //--- create dependent controls
   bool              CreateCanvas(void);
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CPIPDialog)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPIPDialog::CPIPDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPIPDialog::~CPIPDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CPIPDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//--- create dependent controls
   if(!CreateCanvas())
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the canvas object                                         |
//+------------------------------------------------------------------+
bool CPIPDialog::CreateCanvas(void)
  {
//--- coordinates
   int x1=1;
   int y1=1;
   int x2=ClientAreaWidth()-2;
   int y2=ClientAreaHeight()-2;
//--- create canvas
   if(!m_canvas.Create("Canvas1",x2,y2,COLOR_FORMAT_XRGB_NOALPHA))
     {
      Print("Error creating canvas: ",GetLastError());
      return(false);
     }
   m_canvas.FontSet("Trebuchet MS",-100,FW_THIN);
   m_canvas.Erase(ColorToARGB(C'0xF7,0xF7,0xF7',255));
   m_canvas.Update(true);

//--- create
   if(!m_bmp_button.Create(m_chart_id,m_name+"BmpButton",m_subwin,x1,y1,x1,y1))
      return(false);
//--- sets the name of bmp files of the control CBmpButton
   if(!m_bmp_button.BmpOnName(m_canvas.ResourceName()))
      return(false);
   if(!Add(m_bmp_button))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPIPDialog::CommentOut()
  {
   int pos_total=PositionsTotal();
   if(pos_total==0)
     {
      m_canvas.Erase(ColorToARGB(C'0xF7,0xF7,0xF7',255));
      m_canvas.Update(true);
      return;
     }

   double total_volume=0.0;
   for(int i=0;i<pos_total;i++)
     {
      if(PositionGetSymbol(i)==Symbol())
        {
         double volume=(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) ? PositionGetDouble(POSITION_VOLUME) : -PositionGetDouble(POSITION_VOLUME);
         total_volume+=volume;
         int g=0;
        }
     }
//---
   string text="";
   text=DoubleToString(MathAbs(total_volume),2);
//---
   if(total_volume!=0)
     {
      if(total_volume<0)
        {
         m_canvas.Erase(ColorToARGB(clrRed,255));
         m_canvas.FontSet("Trebuchet MS",-100,FW_THIN);
         m_canvas.TextOut(1,1,text,ColorToARGB(clrWhite,255));
         m_canvas.FontSet("Wingdings",-100,FW_THIN);
         m_canvas.TextOut(30,1,CharToString(226),ColorToARGB(clrWhite,255));
        }
      else
        {
         m_canvas.Erase(ColorToARGB(clrBlue,255));
         m_canvas.FontSet("Trebuchet MS",-100,FW_THIN);
         m_canvas.TextOut(1,1,text,ColorToARGB(clrWhite,255));
         m_canvas.FontSet("Wingdings",-100,FW_THIN);
         m_canvas.TextOut(30,1,CharToString(225),ColorToARGB(clrWhite,255));
        }
     }
   m_canvas.Update(true);
  }
//+------------------------------------------------------------------+
