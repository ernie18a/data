#property strict

#include "ChartObject.mqh"
#include "Resource.mqh"
#include "..\Pointer.mqh"

class CHARTOBJECTRESOURCE : public CHARTOBJECT
{
protected:
  const RESOURCE *Resource;

public:
  CHARTOBJECTRESOURCE( const long chart_id = 0, const int sub_window = 0, const bool Add = FALSE )
                    : CHARTOBJECT(Add, chart_id, (string)::MathRand(), ::OBJ_BITMAP_LABEL, sub_window, 0, 0), Resource(new RESOURCE)
  {
    if (::CheckPointer(this.Resource) == POINTER_DYNAMIC)
      this = this.Resource.Name;

   this.SetProperty(::OBJPROP_HIDDEN, TRUE);
   this.SetProperty(::OBJPROP_SELECTABLE, FALSE);
  }

  ~CHARTOBJECTRESOURCE( void )
  {
    POINTER::DeleteObject(this.Resource);
  }

  virtual void operator =( const string Value ) const
  {
    this.SetProperty(::OBJPROP_BMPFILE, Value);

    return;
  }
};