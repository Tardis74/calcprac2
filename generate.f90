program generate
  use precision_mod, only: dp
  use test_functions_mod, only: f_runge, f_almost_constant, f_sin, f_cos, f_exp, f_ln
  implicit none

  character(len=20) :: grid_type
  integer :: n, func_num, k0, i, unit_out
  real(dp) :: a, b
  real(dp), allocatable :: x_nodes(:), y_nodes(:)
  character(len=256) :: arg

  call get_command_argument(1, grid_type)
  call get_command_argument(2, arg); read(arg, *) n
  call get_command_argument(3, arg); read(arg, *) a
  call get_command_argument(4, arg); read(arg, *) b
  call get_command_argument(5, arg); read(arg, *) func_num

  k0 = n / 2
  if (command_argument_count() >= 6) then
     call get_command_argument(6, arg); read(arg, *) k0
  end if

  if (k0 < 0 .or. k0 > n) then
     write(*,*) "Ошибка: k0 должно быть от 0 до", n
     stop
  end if

  allocate(x_nodes(0:n), y_nodes(0:n))

  select case (trim(grid_type))
  case ('uniform')
     do i = 0, n
        x_nodes(i) = a + (b - a) * real(i, dp) / real(n, dp)
     end do
  case ('chebyshev')
	do i = 0, n
		! Вычисляем в порядке возрастания: используем индекс (n - i)
		x_nodes(i) = cos( (2.0_dp * real(n - i, dp) + 1.0_dp) * acos(-1.0_dp) / (2.0_dp * real(n, dp) + 2.0_dp) )
		! Масштабирование на [a, b]
		x_nodes(i) = (a + b) / 2.0_dp + (b - a) / 2.0_dp * x_nodes(i)
   	end do
  case default
     write(*,*) "Ошибка: первый аргумент должен быть 'uniform' или 'chebyshev'"
     stop
  end select

  select case (func_num)
  case (1)
     do i = 0, n
        y_nodes(i) = f_runge(x_nodes(i))
     end do
  case (2)
     do i = 0, n
        if (i == k0) then
           y_nodes(i) = 1.0_dp
        else
           y_nodes(i) = f_almost_constant(x_nodes(i))
        end if
     end do
  case (3)
     do i = 0, n
        y_nodes(i) = f_sin(x_nodes(i))
     end do
  case (4)
     do i = 0, n
        y_nodes(i) = f_cos(x_nodes(i))
     end do
  case (5)
     do i = 0, n
        y_nodes(i) = f_exp(x_nodes(i))
     end do
  case (6)
     do i = 0, n
        y_nodes(i) = f_ln(x_nodes(i))
     end do
  case default
     write(*,*) "Ошибка: func_num должен быть от 1 до 6"
     stop
  end select

  open(newunit=unit_out, file=trim(grid_type)//'.dat', action='write')
  write(unit_out, '(A,1X,I0)') '#', n
  write(unit_out, *) a, b
  do i = 0, n
     write(unit_out, *) y_nodes(i)
  end do
  close(unit_out)

  write(*,*) 'Файл ', trim(grid_type)//'.dat', ' успешно создан.'

end program generate
