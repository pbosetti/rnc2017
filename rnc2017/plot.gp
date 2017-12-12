set xlab "Time (s)"
set ylab ""
set palette defined (0 "black", 1 "red", 2 "green", 3 "blue")
plot "out.txt" u 2:3:11 w l palette
