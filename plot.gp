#!/usr/bin/env gnuplot
grid_type = ARG1
func_num = int(ARG2)
a = real(ARG3)
b = real(ARG4)
k0 = (ARGC >= 5) ? int(ARG5) : -1

res_file = "res_" . grid_type . ".dat"
exact_file = "exact_" . grid_type . ".dat"

set terminal pngcairo enhanced size 800,600
set output grid_type . "_func" . func_num . "_plot.png"
set title "Интерполяция полиномом Лагранжа (" . grid_type . " сетка, функция " . func_num . ")"
set xlabel "x"
set ylabel "y"
set grid

set style line 2 lc rgb '#d95319' lt 1 lw 5
set style line 3 lc rgb '#77ac30' lt 2 lw 1

plot res_file using 1:2 with lines ls 2 title "Интерполяция", \
     exact_file using 1:2 with lines ls 3 title "Точная функция"
