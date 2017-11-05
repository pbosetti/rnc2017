# Plot Y cordinates as function of time
set xlab "Time (s)"
set ylab "Y position (mm)"
plot "profiles.txt" u 1:6 w l, "profiles.txt" u 1:9 w l
