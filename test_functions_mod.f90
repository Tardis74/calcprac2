module test_functions_mod
  use precision_mod, only: dp
  implicit none
  private
  public :: f_runge, f_almost_constant, f_sin, f_cos, f_exp, f_ln

contains

  pure function f_runge(x) result(y)
    real(dp), intent(in) :: x
    real(dp) :: y
    y = 1.0_dp / (1.0_dp + x * x)
  end function f_runge

  pure function f_almost_constant(x) result(y)
    real(dp), intent(in) :: x
    real(dp) :: y
    y = 0.0_dp
  end function f_almost_constant

  pure function f_sin(x) result(y)
    real(dp), intent(in) :: x
    real(dp) :: y
    y = sin(x)
  end function f_sin

  pure function f_cos(x) result(y)
    real(dp), intent(in) :: x
    real(dp) :: y
    y = cos(x)
  end function f_cos

  pure function f_exp(x) result(y)
    real(dp), intent(in) :: x
    real(dp) :: y
    y = exp(x)
  end function f_exp

  pure function f_ln(x) result(y)
    real(dp), intent(in) :: x
    real(dp) :: y
    ! Чтобы избежать отрицательных аргументов, сдвигаем
    y = log(x + 10.0_dp)
  end function f_ln

end module test_functions_mod
