set xlab "Time (s)"
set ylab ""
set palette model RGB defined (1 "red", 2 "green", 3 "blue")
plot "out.txt" u 2:3:8 w l palette
