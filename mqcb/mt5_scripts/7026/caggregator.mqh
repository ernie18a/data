/*

*/
#include "CDownload.mqh"
//---------------------------------------------------------------------
// 
//---------------------------------------------------------------------
class CAggregator
{
  public:
          CAggregator(void);
         ~CAggregator(void);
    bool  Init(void);
    bool  IsInit(void) {return(init);}
    void  Deinit(void);
    void  Download(datetime time=0);

  private:
    bool        init;
    CGraphics  *g;
    CDownload  *d;
};
//---------------------------------------------------------------------
// Конструктор
//---------------------------------------------------------------------
void CAggregator::CAggregator(void)
{
  if(!Init()) {Deinit();}
}
//---------------------------------------------------------------------
// Деструктор
//---------------------------------------------------------------------
void CAggregator::~CAggregator(void)
{
  Deinit();
}
//---------------------------------------------------------------------
// Инициализация
//---------------------------------------------------------------------
bool CAggregator::Init(void)
{
  Deinit();
  if((g=new CGraphics)==NULL) {return(false);}
  if((d=new CDownload(g))==NULL) {return(false);}
  if(!g.IsInit()) {return(false);}
  if(!d.IsInit()) {return(false);}
  return(true);
}
//---------------------------------------------------------------------
// Деинициализация
//---------------------------------------------------------------------
void CAggregator::Deinit(void)
{
  init=false;
  if(d!=NULL) {delete d;}
  if(g!=NULL) {delete g;}
}
//---------------------------------------------------------------------
// Загрузка исторических данных
//---------------------------------------------------------------------
void CAggregator::Download(datetime time=0)
{
  d.DownloadHistory(time);
}
