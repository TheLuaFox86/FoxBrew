term.writeln("")
term.writeln("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-")
term.writeln("               FoxBrew OS")
term.writeln("      A Linux Inspired Experience")
term.writeln("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-")
terminalContainer.style.display = "flex"
app.style["background-color"] = "#000000"
splash.innerHTML = ""
while true do
    Shell.run(RL.read("LFSH> "):await(), Shell.callback)
    if doClear then
        term.clear()
        doClear = false
    end
end