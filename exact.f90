program exact
  use precision_mod, only: dp
  use test_functions_mod, only: f_runge, f_almost_constant, f_sin, f_cos, f_exp, f_ln
  implicit none
  integer :: func_num, npoints, i, k0
  real(dp) :: a, b, x
  character(len=256) :: arg

  call get_command_argument(1, arg); read(arg, *) func_num
  call get_command_argument(2, arg); read(arg, *) a
  call get_command_argument(3, arg); read(arg, *) b
  call get_command_argument(4, arg); read(arg, *) npoints

  k0 = -1
  if (command_argument_count() >= 5) then
     call get_command_argument(5, arg); read(arg, *) k0
  end if

  do i = 0, npoints-1
     x = a + (b - a) * real(i, dp) / real(npoints-1, dp)
     select case (func_num)
     case (1)
        write(*, *) x, f_runge(x)
     case (2)
        if (i == k0) then
           write(*, *) x, 1.0_dp
        else
           write(*, *) x, f_almost_constant(x)
        end if
     case (3)
        write(*, *) x, f_sin(x)
     case (4)
        write(*, *) x, f_cos(x)
     case (5)
        write(*, *) x, f_exp(x)
     case (6)
        write(*, *) x, f_ln(x)
     end select
  end do
end program exact
