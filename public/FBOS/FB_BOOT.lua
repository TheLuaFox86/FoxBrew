term.open(DOCUMENT.getElementById("Terminal"))
term.writeln("")
term.writeln("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-")
term.writeln("               FoxBrew OS")
term.writeln("      A Linux Inspired Experience")
term.writeln("+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-")
while true do
    Shell.run(RL.read("LFSH> "):await(), Shell.callback)
    if doClear then
        term.clear()
        doClear = false
    end
end