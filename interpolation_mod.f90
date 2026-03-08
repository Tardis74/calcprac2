module interpolation_mod
	use precision_mod, only: dp
	implicit none
	private
	public :: lagrange_eval

contains
	pure function lagrange_eval(x, x_nodes, y_nodes) result(val)
		real(dp), intent(in) :: x			!текущая точка
		real(dp), intent(in) :: x_nodes(:)		!узлы (абсциссы)
		real(dp), intent(in) :: y_nodes(:)		!значения функции в узлах
		real(dp) :: val					!результат

		integer :: i, j, n				!счётчики и число узлов
		real(dp) :: term				!временная переменная для произведения

		n = size(x_nodes)          			!количество узлов

		!инициализация результата
		val = 0.0_dp

		!внешний цикл по базисным функциям
		do i = 1, n
			!начинаем с y_i, затем будем домножать
			term = y_nodes(i)

			!внутренний цикл по всем узлам
			do j = 1, n
				! Пропускаем j = i
				if (j == i) cycle
				term = term * (x - x_nodes(j)) / (x_nodes(i) - x_nodes(j))
			end do
			val = val + term
		end do
	end function lagrange_eval

end module interpolation_mod
