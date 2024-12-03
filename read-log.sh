
while true 
do
    adb shell "echo > /storage/emulated/0/Android/data/com.mcpeturk.dilsecici/files/Minetest/debug.txt"
    adb shell "while true; do cat; sleep 1; done < /storage/emulated/0/Android/data/com.mcpeturk.dilsecici/files/Minetest/debug.txt"
done