
while true 
do
    adb shell "echo > /storage/emulated/0/Android/data/me.korata.finecraft/files/Minetest/debug.txt"
    adb shell "while true; do cat; sleep 1; done < /storage/emulated/0/Android/data/me.korata.finecraft/files/Minetest/debug.txt"
done