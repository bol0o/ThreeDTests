local function update(text)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.setCursorPos(1, 9)
    term.clearLine()
    term.setCursorPos(math.floor(51/2 - string.len(text)/2), 9)
    write(text)
end
 
local function bar(ratio)
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.lime)
    term.setCursorPos(1, 11)
    
    for i = 1, 51 do
        if (i/51 < ratio) then
            write("]")
        else
            write(" ")
        end
    end
end
 
local function download(downloadPath, savePath)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.setCursorPos(1, 13)
    term.clearLine()
    term.setCursorPos(1, 14)
    term.clearLine()
    term.setCursorPos(1, 15)
    term.clearLine()
    term.setCursorPos(1, 16)
    term.clearLine()
    term.setCursorPos(1, 17)
    term.clearLine()
    term.setCursorPos(1, 13)
    
    print("Accessing https://raw.githubusercontent.com/bol0o/ThreeDTests/main"..downloadPath)
    local rawData = http.get("https://raw.githubusercontent.com/bol0o/ThreeDTests/main"..downloadPath)
    local data = rawData.readAll()
    local file = fs.open(savePath, "w")
    file.write(data)
    file.close()
end
 
local function pastebinD(code, savePath)
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.setCursorPos(1, 13)
    term.clearLine()
    term.setCursorPos(1, 14)
    term.clearLine()
    term.setCursorPos(1, 15)
    term.clearLine()
    term.setCursorPos(1, 16)
    term.clearLine()
    term.setCursorPos(1, 17)
    term.clearLine()
    term.setCursorPos(1, 13)
    shell.run("pastebin get "..code.." "..savePath)
end
 
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
 
term.setCursorPos(1, 8)
write("3D Tests installer. Path:")
 
term.setCursorPos(1, 11)
write("Path: ")
local path = read()
 
term.clear()
term.setCursorPos(13, 2)
term.setTextColor(colors.yellow)
write("3D tests installer")
 
local oldpath = shell.dir()
shell.setDir("/")
local installpath = "/"..fs.combine(path, "3DTests")
update("Installing...")
bar(0)

update("Creating directories...")
fs.makeDir(installpath)
bar(0.07)
fs.makeDir(fs.combine(installpath, "models"))
bar(0.14)

update("Downloading test files...")
download("/Demo.lua", "/"..fs.combine(installpath, "Demo"))
bar(0.21)
download("/Demo2.lua", "/"..fs.combine(installpath, "Demo2"))
bar(0.28)
download("/Demo3.lua", "/"..fs.combine(installpath, "Demo3"))
bar(0.35)
download("/Engine.lua", "/"..fs.combine(installpath, "Engine"))
bar(0.42)

update("Downloading APIs...")
download("/ThreeD.lua", "/"..fs.combine(installpath, "ThreeD"))
bar(0.49)
download("/bufferAPI.lua", "/"..fs.combine(installpath, "bufferAPI"))
bar(0.56)
download("/noise.lua", "/"..fs.combine(installpath, "noise"))
bar(0.63)
pastebinD("ujchRSnU", "/"..fs.combine(installpath, "blittle"))
bar(0.70)

update("Downloading models...")
download("/models/box", "/"..fs.combine(fs.combine(installpath, "models"), "box"))
bar(0.77)
download("/models/emerald", "/"..fs.combine(fs.combine(installpath, "models"), "emerald"))
bar(0.84)
download("/models/pineapple", "/"..fs.combine(fs.combine(installpath, "models"), "pineapple"))
bar(0.91)
download("/models/spike", "/"..fs.combine(fs.combine(installpath, "models"), "spike"))
bar(0.98)

update("Finishing installation...")
fs.delete("/.std_list")
fs.delete("/.std_websites")
 
update("Installation finished!")
bar(1)
shell.setDir(oldpath)
 
sleep(1)
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
 
term.clear()
term.setCursorPos(1, 1)
write("Finished installation!\nPress any key to close...")
os.pullEventRaw()
 
term.clear()
term.setCursorPos(1, 1)