set xlab "Time (s)"
set ylab ""
set palette model RGB defined (0 "black", 1 "red", 2 "green", 3 "blue")
set term qt 0
plot "out.txt" u 2:3:11 w l palette
set term qt 1
plot "out.txt" u 2:4:11 w l palette
