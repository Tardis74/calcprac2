program check_nodes
  use precision_mod, only: dp
  implicit none

  character(len=20) :: grid_type
  character(len=256) :: data_file, res_file
  integer :: n, i, j, iostat, unit_data, unit_res, n_res, node_count
  real(dp) :: a, b, tol
  real(dp), allocatable :: x_nodes(:), y_nodes(:), x_res(:), y_res(:)
  character(len=256) :: line
  logical :: ok

  tol = 1.0e-12_dp

  call get_command_argument(1, grid_type)
  data_file = trim(grid_type) // '.dat'
  res_file = 'res_' // trim(grid_type) // '.dat'

  open(newunit=unit_data, file=data_file, status='old', action='read')
  read(unit_data, '(A)') line
  i = index(line, '#')
  read(line(i+1:), *) n
  read(unit_data, *) a, b

  allocate(x_nodes(0:n), y_nodes(0:n))

  select case (grid_type)
  case ('uniform')
     do i = 0, n
        x_nodes(i) = a + (b - a) * real(i, dp) / real(n, dp)
     end do
  case ('chebyshev')
     do i = 0, n
        x_nodes(i) = cos( (2.0_dp * real(i, dp) + 1.0_dp) * acos(-1.0_dp) / (2.0_dp * real(n, dp) + 2.0_dp) )
        x_nodes(i) = (a + b) / 2.0_dp + (b - a) / 2.0_dp * x_nodes(i)
     end do
  end select

  do i = 0, n
     read(unit_data, *) y_nodes(i)
  end do
  close(unit_data)

  open(newunit=unit_res, file=res_file, status='old', action='read')
  n_res = 0
  do
     read(unit_res, *, iostat=iostat)
     if (iostat /= 0) exit
     n_res = n_res + 1
  end do
  rewind(unit_res)

  allocate(x_res(n_res), y_res(n_res))
  do i = 1, n_res
     read(unit_res, *) x_res(i), y_res(i)
  end do
  close(unit_res)

  ok = .true.
  node_count = 0

  do i = 0, n
     do j = 1, n_res
        if (abs(x_res(j) - x_nodes(i)) <= tol) then
           node_count = node_count + 1
           if (abs(y_res(j) - y_nodes(i)) > tol) then
              write(*, '(A, I0, A, F10.6, A, ES23.15, A, ES23.15)') &
                   'Несовпадение в узле ', i, ': x = ', x_nodes(i), &
                   ', y_res = ', y_res(j), ', y_node = ', y_nodes(i)
              ok = .false.
           end if
           exit
        end if
     end do
  end do

  if (ok) then
     write(*, '(A, I0)') 'Все узлы совпадают. Проверено узлов: ', node_count
     stop 0
  else
     stop 1
  end if

end program check_nodes
