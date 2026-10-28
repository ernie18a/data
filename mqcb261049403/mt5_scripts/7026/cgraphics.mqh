/*

*/
#include "CCanvas.mqh"
#include "CProgressBar.mqh"
//---------------------------------------------------------------------
// Класс для управления графическими объектами
//---------------------------------------------------------------------
class CGraphics
{
  public:
          CGraphics(void);
         ~CGraphics(void);
    bool  Init(void);
    bool  IsInit(void) {return(init);}
    void  Deinit(void);
    void  Revise(void);
    void  CreateProgressBar(double num1,double num2,string str=NULL);
    void  DestroyProgressBar(void);
    void  CurrentProgress(double num);

  private:
    bool          init;
    CCanvas      *c;
    CProgressBar *pb;
};
//---------------------------------------------------------------------
// Конструктор по умолчанию
//---------------------------------------------------------------------
void CGraphics::CGraphics(void)
{
  if(!Init()) {Deinit();}
}
//---------------------------------------------------------------------
// Деструктор
//---------------------------------------------------------------------
void CGraphics::~CGraphics(void)
{
  Deinit();
}
//---------------------------------------------------------------------
// Инициализация
//---------------------------------------------------------------------
bool CGraphics::Init(void)
{
  Deinit();
  if((c=new CCanvas)==NULL) {return(false);}
  if((pb=new CProgressBar(c))==NULL) {return(false);}
  if(!c.IsInit()) {return(false);}
  if(!pb.IsInit()) {return(false);}
  init=true;
  return(true);
}
//---------------------------------------------------------------------
// Деинициализация
//---------------------------------------------------------------------
void CGraphics::Deinit(void)
{
  init=false;
  if(pb!=NULL) {delete pb;}
  if(c!=NULL) {delete c;}
}
//---------------------------------------------------------------------
// Ревизия размеров графика
//---------------------------------------------------------------------
void CGraphics::Revise(void)
{
  if(c.X==ChartXSize() && c.Y==ChartYSize()) {return;}
  c.Force();
  pb.Create(0,0,false);
}
//---------------------------------------------------------------------
// Создание шкалы прогресса
//---------------------------------------------------------------------
void CGraphics::CreateProgressBar(double num1,double num2,string str=NULL)
{
  pb.signature=str;
  pb.Create(num1,num2);
}
//---------------------------------------------------------------------
// Уничтожение шкалы прогресса
//---------------------------------------------------------------------
void CGraphics::DestroyProgressBar(void)
{
  pb.Destroy();
}
//---------------------------------------------------------------------
// Создание текущего уровня на шкале прогресса
//---------------------------------------------------------------------
void CGraphics::CurrentProgress(double num)
{
  Revise();
  pb.Current(num);
}
