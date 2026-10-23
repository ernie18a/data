//+------------------------------------------------------------------+
//|                                                  Close panel.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
//--- input parameters
input double   InpLoss     = 30; // Loss (in money)
input double   InpProfit   = 90; // Profit (in money)
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        (150)     // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate
//+------------------------------------------------------------------+
//| Class CControlsDialog                                            |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class CControlsDialog : public CAppDialog
  {
private:
   CButton           m_button_close_all;              // the button object
   CButton           m_button_close_loss;             // the button object
   CButton           m_button_close_profit;           // the fixed button object

public:
                     CControlsDialog(void);
                    ~CControlsDialog(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

protected:
   //--- create dependent controls
   bool              CreateButtonCloseAll(void);
   bool              CreateButtonCloseLoss(void);
   bool              CreateButtonCloseProfit(void);
   //--- handlers of the dependent controls events
   void              OnClickButtonCloseAll(void);
   void              OnClickButtonCloseLoss(void);
   void              OnClickButtonCloseProfit(void);
   //--- close positions
   void              ClosePositions(const int type);
  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CControlsDialog)
ON_EVENT(ON_CLICK,m_button_close_all,OnClickButtonCloseAll)
ON_EVENT(ON_CLICK,m_button_close_loss,OnClickButtonCloseLoss)
ON_EVENT(ON_CLICK,m_button_close_profit,OnClickButtonCloseProfit)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CControlsDialog::CControlsDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CControlsDialog::~CControlsDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CControlsDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//--- create dependent controls
   if(!CreateButtonCloseAll())
      return(false);
   if(!CreateButtonCloseLoss())
      return(false);
   if(!CreateButtonCloseProfit())
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Close all" button                                    |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateButtonCloseAll(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=x1+2*BUTTON_WIDTH+CONTROLS_GAP_X;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button_close_all.Create(m_chart_id,m_name+"ButtonCloseAll",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button_close_all.Text("Close all"))
      return(false);
   if(!Add(m_button_close_all))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Close loss" button                                   |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateButtonCloseLoss(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button_close_loss.Create(m_chart_id,m_name+"ButtonCloseLoss",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button_close_loss.Text("Close loss more "+DoubleToString(InpLoss,0)))
      return(false);
   if(!Add(m_button_close_loss))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Close profit" button                                 |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateButtonCloseProfit(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+BUTTON_WIDTH+CONTROLS_GAP_X;
   int y1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button_close_profit.Create(m_chart_id,m_name+"ButtonCloseProfit",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_button_close_profit.Text("Close profit more "+DoubleToString(InpProfit,0)))
      return(false);
   if(!Add(m_button_close_profit))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButtonCloseAll(void)
  {
   Comment(__FUNCTION__);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButtonCloseLoss(void)
  {
   Comment(__FUNCTION__);
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CControlsDialog::OnClickButtonCloseProfit(void)
  {
   Comment(__FUNCTION__);
  }
//+------------------------------------------------------------------+
//| Close positions                                                  |
//|  type "0" -> close all                                           |
//|  type "1" -> close loss                                          |
//|  type "2" -> close profit                                        |
//+------------------------------------------------------------------+
void CControlsDialog::ClosePositions(const int type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
        {
         m_trade.SetTypeFillingBySymbol(m_position.Symbol());

         if(type==0) // "close all"
           {
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
            continue;
           }
         if(type==1) // "close loss"
           {
            if(m_position.Profit()<=InpLoss)
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
            continue;
           }
         if(type==2) // "close profit"
           {
            if(m_position.Profit()>=InpProfit)
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
            continue;
           }
        }
  }
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CControlsDialog ExtDialog;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   m_trade.SetMarginMode();
//--- create application dialog
   if(!ExtDialog.Create(0,"Close panel (in money)",0,40,90,375,185))
      return(INIT_FAILED);
//--- run application
   ExtDialog.Run();
//--- succeed
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("");
//--- destroy dialog
   ExtDialog.Destroy(reason);
  }
//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
