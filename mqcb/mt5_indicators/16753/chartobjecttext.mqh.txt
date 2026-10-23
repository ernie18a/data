#include "ChartObject.mqh"

class CHARTOBJECTTEXT : public CHARTOBJECT
{
public:
  CHARTOBJECTTEXT( const long chart_id = 0, const int sub_window = 0, const bool Add = FALSE )
                    : CHARTOBJECT(Add, chart_id, (string)::MathRand(), ::OBJ_TEXT, sub_window, 0, 0)
  {
  }
};