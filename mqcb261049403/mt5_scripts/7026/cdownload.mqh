/*

*/
#include "Common.mqh"
#include "CSymbol.mqh"
#include "CGraphics.mqh"
//---------------------------------------------------------------------
// Класс для загрузки исторических данных по символу с сервера
//---------------------------------------------------------------------
class CDownload: protected CSymbol
{
  public:
          CDownload(CGraphics *g_);
         ~CDownload(void);
    bool  Init(CGraphics *g_);
    bool  IsInit(void) {return(init);}
    void  Deinit(void);
    void  DownloadHistory(datetime time=0,bool flag=true);

  protected:
    bool       init;
    CGraphics *g;
};
//---------------------------------------------------------------------
// Параметрический конструктор
//---------------------------------------------------------------------
void CDownload::CDownload(CGraphics *g_)
{
  if(!Init(g_)) {Deinit();}
}
//---------------------------------------------------------------------
// Деструктор
//---------------------------------------------------------------------
void CDownload::~CDownload(void)
{
  Deinit();
}
//---------------------------------------------------------------------
// Инициализация
//---------------------------------------------------------------------
bool CDownload::Init(CGraphics *g_)
{
  Deinit();
  if(g_==NULL) {return(false);}
  g=g_;
  init=true;
  return(true);
}
//---------------------------------------------------------------------
// Деинициализация
//---------------------------------------------------------------------
void CDownload::Deinit(void)
{
  init=false;
  g=NULL;
}
//---------------------------------------------------------------------
// Загрузка исторических данных по символу с сервера
//---------------------------------------------------------------------
void CDownload::DownloadHistory(datetime time=0,bool flag=true)
{
  datetime start=FirstDateTerminal();
  datetime stop=(time==0)?D'01.01.2007':time;
  if(stop<FirstDateServer()) {stop=FirstDateServer();}
  if(start<=stop) {return;}
  string str=symbol+"  загрузка исторических данных...";
  g.CreateProgressBar(start,stop,str);
  ENUM_TIMEFRAMES period=PERIOD_W1;
  datetime times[2];
  datetime current=0,last=0;
  int attempt_cnt=0;
  while(!IsStopped())
  {
    if(attempt_cnt==0 || attempt_cnt>=1000)
    {
      CopyTime(symbol,period,FirstDateRAM(period),2,times);
      attempt_cnt=1;
    }
    current=FirstDateTerminal();
    g.CurrentProgress(current);
    attempt_cnt++;
    if(last!=current) {last=current;attempt_cnt=1;}
    if(current<=stop) {break;} else {Sleep(10);}
  }
  if(flag) {g.DestroyProgressBar();}
  str="По символу \""+symbol+"\"";
  str+=" была загружена более глубокая история: ";
  str+=t2s(start)+" -> "+t2s(current);
  Print(str);
}
