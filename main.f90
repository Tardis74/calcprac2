program main
	use interpolation_mod, only: lagrange_eval
	use precision_mod, only: dp
	implicit none

	character(len=100) :: arg
	character(len=:), allocatable :: input_file, output_file
	integer :: n, i, n_prime, q
	real(dp) :: a, b
	real(dp), dimension(:), allocatable :: x_nodes, y_nodes, x_eval, y_eval
	character(len=256) :: line
	integer :: unit_in, unit_out

	q = 100   !коэффициент для числа интервалов вывода

	!получение аргумента командной строки
	call get_command_argument(1, arg)

	select case (trim(arg))
		case ('uniform')
			input_file = 'uniform.dat'
			output_file = 'res_uniform.dat'
		case ('chebyshev')
			input_file = 'chebyshev.dat'
			output_file = 'res_chebyshev.dat'
	end select

	!открытие входного файла
	open(newunit=unit_in, file=input_file, status='old', action='read')

	!чтение первой строки (содержит # и N)
	read(unit_in, '(A)') line
	i = index(line, '#')
	read(line(i+1:), *) n

	!чтение второй строки (границы интервала a и b)
	read(unit_in, *) a, b

	!выделение памяти под узлы и значения
	allocate(x_nodes(n+1), y_nodes(n+1))

	!чтение значений y_k
	do i = 1, n+1
		read(unit_in, *) y_nodes(i)
	end do
	close(unit_in)

	!вычисление узлов x_k
	select case (trim(arg))
		case ('uniform')
			do i = 1, n+1
				x_nodes(i) = a + (b - a) * (i-1) / n
			end do
		case ('chebyshev')
			do i = 1, n+1
				!Чебышевские узлы на [-1, 1]
				x_nodes(i) = cos( (2.0_dp * real(i-1, dp) + 1.0_dp) * acos(-1.0_dp) / (2.0_dp * real(n, dp) + 2.0_dp) )
				!масштабирование на [a, b]
				x_nodes(i) = (a + b) / 2.0_dp + (b - a) / 2.0_dp * x_nodes(i)
			end do
		end select

	!точки для вывода
	n_prime = q * n
	allocate(x_eval(0:n_prime), y_eval(0:n_prime))
	do i = 0, n_prime
		x_eval(i) = a + (b - a) * real(i, dp) / real(n_prime, dp)
	end do

	!распараллеливание вычислений с OpenMP
	!$omp parallel do default(none) shared(x_eval, y_eval, x_nodes, y_nodes, n_prime)
	do i = 0, n_prime
		y_eval(i) = lagrange_eval(x_eval(i), x_nodes, y_nodes)
	end do
	!$omp end parallel do

	!запись результатов в выходной файл
	open(newunit=unit_out, file=output_file, action='write')
	do i = 0, n_prime
		write(unit_out, *) x_eval(i), y_eval(i)
	end do
	close(unit_out)

end program main
