set pathToSend=C:\Users\Tiamo\Documents\Programming\Games\Own Goals Not Allowed\deliverables
set butlerName=pandaqi/own-goals-not-allowed

butler push "%pathToSend%\windows" %butlerName%:windows
butler push "%pathToSend%\mac" %butlerName%:mac
butler push "%pathToSend%\linux" %butlerName%:linux

pause