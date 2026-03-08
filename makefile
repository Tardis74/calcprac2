# Компилятор и флаги
FC = gfortran
FFLAGS = -Wall -Wextra -O2 -std=f2008 -fopenmp

# Исполняемые файлы
INTERPOL = interpol
GENERATE = generate
EXACT = exact
CHECK = check_nodes

# Модули
MODULES = precision_mod.o test_functions_mod.o interpolation_mod.o

# Параметры тестов
Q = 100

# Тест Рунге
RUNGE_N = 10
RUNGE_A = -6.0
RUNGE_B = 6.0
RUNGE_FUNC = 1

# Тест с выбросом
CONST_N = 5
CONST_A = -1.0
CONST_B = 1.0
CONST_FUNC = 2
CONST_K0 = 2

# Тест синуса
SIN_N = 8
SIN_A = 0.0
SIN_B = 3.14159
SIN_FUNC = 3

# Основная цель по умолчанию
all: $(INTERPOL) $(GENERATE) $(EXACT) $(CHECK)

# Сборка программ
$(INTERPOL): main.o $(MODULES)
	$(FC) $(FFLAGS) -o $@ $^

$(GENERATE): generate.o test_functions_mod.o precision_mod.o
	$(FC) $(FFLAGS) -o $@ $^

$(EXACT): exact.o test_functions_mod.o precision_mod.o
	$(FC) $(FFLAGS) -o $@ $^

$(CHECK): check_nodes.o precision_mod.o
	$(FC) $(FFLAGS) -o $@ $^

# Объектные файлы
main.o: main.f90 precision_mod.o interpolation_mod.o
	$(FC) $(FFLAGS) -c main.f90

interpolation_mod.o: interpolation_mod.f90 precision_mod.o
	$(FC) $(FFLAGS) -c interpolation_mod.f90

test_functions_mod.o: test_functions_mod.f90 precision_mod.o
	$(FC) $(FFLAGS) -c test_functions_mod.f90

precision_mod.o: precision_mod.f90
	$(FC) $(FFLAGS) -c precision_mod.f90

generate.o: generate.f90 test_functions_mod.o precision_mod.o
	$(FC) $(FFLAGS) -c generate.f90

exact.o: exact.f90 test_functions_mod.o precision_mod.o
	$(FC) $(FFLAGS) -c exact.f90

check_nodes.o: check_nodes.f90 precision_mod.o
	$(FC) $(FFLAGS) -c check_nodes.f90

# Цели для тестирования (проверка узлов)
.PHONY: test test_runge test_constant test_sin clean

test: test_runge test_constant test_sin

test_runge: test_runge_uniform test_runge_chebyshev

test_runge_uniform: $(INTERPOL) $(GENERATE) $(CHECK)
	@echo "=== Тест Рунге, равномерная сетка (проверка узлов) ==="
	./$(GENERATE) uniform $(RUNGE_N) $(RUNGE_A) $(RUNGE_B) $(RUNGE_FUNC)
	./$(INTERPOL) uniform
	./$(CHECK) uniform

test_runge_chebyshev: $(INTERPOL) $(GENERATE) $(CHECK)
	@echo "=== Тест Рунге, чебышевская сетка (проверка узлов) ==="
	./$(GENERATE) chebyshev $(RUNGE_N) $(RUNGE_A) $(RUNGE_B) $(RUNGE_FUNC)
	./$(INTERPOL) chebyshev
	./$(CHECK) chebyshev

test_constant: test_constant_uniform test_constant_chebyshev

test_constant_uniform: $(INTERPOL) $(GENERATE) $(CHECK)
	@echo "=== Тест с выбросом, равномерная сетка (проверка узлов) ==="
	./$(GENERATE) uniform $(CONST_N) $(CONST_A) $(CONST_B) $(CONST_FUNC) $(CONST_K0)
	./$(INTERPOL) uniform
	./$(CHECK) uniform

test_constant_chebyshev: $(INTERPOL) $(GENERATE) $(CHECK)
	@echo "=== Тест с выбросом, чебышевская сетка (проверка узлов) ==="
	./$(GENERATE) chebyshev $(CONST_N) $(CONST_A) $(CONST_B) $(CONST_FUNC) $(CONST_K0)
	./$(INTERPOL) chebyshev
	./$(CHECK) chebyshev

test_sin: test_sin_uniform test_sin_chebyshev

test_sin_uniform: $(INTERPOL) $(GENERATE) $(CHECK)
	@echo "=== Тест синуса, равномерная сетка (проверка узлов) ==="
	./$(GENERATE) uniform $(SIN_N) $(SIN_A) $(SIN_B) $(SIN_FUNC)
	./$(INTERPOL) uniform
	./$(CHECK) uniform

test_sin_chebyshev: $(INTERPOL) $(GENERATE) $(CHECK)
	@echo "=== Тест синуса, чебышевская сетка (проверка узлов) ==="
	./$(GENERATE) chebyshev $(SIN_N) $(SIN_A) $(SIN_B) $(SIN_FUNC)
	./$(INTERPOL) chebyshev
	./$(CHECK) chebyshev

# Цели для построения графиков
.PHONY: plot plot_runge plot_constant plot_sin

plot: plot_runge plot_constant plot_sin

plot_runge: $(INTERPOL) $(EXACT) $(GENERATE)
	@echo "=== Построение графиков для функции Рунге ==="
	./$(GENERATE) uniform $(RUNGE_N) $(RUNGE_A) $(RUNGE_B) $(RUNGE_FUNC)
	./$(INTERPOL) uniform
	./$(EXACT) $(RUNGE_FUNC) $(RUNGE_A) $(RUNGE_B) $$(($(RUNGE_N)*$(Q)+1)) > exact_uniform.dat
	gnuplot -c plot.gp uniform $(RUNGE_FUNC) $(RUNGE_A) $(RUNGE_B)
	./$(GENERATE) chebyshev $(RUNGE_N) $(RUNGE_A) $(RUNGE_B) $(RUNGE_FUNC)
	./$(INTERPOL) chebyshev
	./$(EXACT) $(RUNGE_FUNC) $(RUNGE_A) $(RUNGE_B) $$(($(RUNGE_N)*$(Q)+1)) > exact_chebyshev.dat
	gnuplot -c plot.gp chebyshev $(RUNGE_FUNC) $(RUNGE_A) $(RUNGE_B)
	@echo "Графики для функции Рунге сохранены"

plot_constant: $(INTERPOL) $(EXACT) $(GENERATE)
	@echo "=== Построение графиков для функции с выбросом ==="
	./$(GENERATE) uniform $(CONST_N) $(CONST_A) $(CONST_B) $(CONST_FUNC) $(CONST_K0)
	./$(INTERPOL) uniform
	./$(EXACT) $(CONST_FUNC) $(CONST_A) $(CONST_B) $$(($(CONST_N)*$(Q)+1)) $(CONST_K0) > exact_uniform.dat
	gnuplot -c plot.gp uniform $(CONST_FUNC) $(CONST_A) $(CONST_B) $(CONST_K0)
	./$(GENERATE) chebyshev $(CONST_N) $(CONST_A) $(CONST_B) $(CONST_FUNC) $(CONST_K0)
	./$(INTERPOL) chebyshev
	./$(EXACT) $(CONST_FUNC) $(CONST_A) $(CONST_B) $$(($(CONST_N)*$(Q)+1)) $(CONST_K0) > exact_chebyshev.dat
	gnuplot -c plot.gp chebyshev $(CONST_FUNC) $(CONST_A) $(CONST_B) $(CONST_K0)
	@echo "Графики для функции с выбросом сохранены"

plot_sin: $(INTERPOL) $(EXACT) $(GENERATE)
	@echo "=== Построение графиков для синуса ==="
	./$(GENERATE) uniform $(SIN_N) $(SIN_A) $(SIN_B) $(SIN_FUNC)
	./$(INTERPOL) uniform
	./$(EXACT) $(SIN_FUNC) $(SIN_A) $(SIN_B) $$(($(SIN_N)*$(Q)+1)) > exact_uniform.dat
	gnuplot -c plot.gp uniform $(SIN_FUNC) $(SIN_A) $(SIN_B)
	./$(GENERATE) chebyshev $(SIN_N) $(SIN_A) $(SIN_B) $(SIN_FUNC)
	./$(INTERPOL) chebyshev
	./$(EXACT) $(SIN_FUNC) $(SIN_A) $(SIN_B) $$(($(SIN_N)*$(Q)+1)) > exact_chebyshev.dat
	gnuplot -c plot.gp chebyshev $(SIN_FUNC) $(SIN_A) $(SIN_B)
	@echo "Графики для синуса сохранены"

# Очистка
clean:
	rm -f *.o *.mod $(INTERPOL) $(GENERATE) $(EXACT) $(CHECK)
	rm -f uniform.dat chebyshev.dat
	rm -f res_uniform.dat res_chebyshev.dat
	rm -f exact_*.dat
	rm -f *_plot.png
