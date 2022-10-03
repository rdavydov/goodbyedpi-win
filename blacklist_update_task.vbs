Set WshShell = CreateObject("WScript.Shell") 
strCurDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)
WshShell.Run chr(34) & strCurDir & "\blacklist_update_task.cmd" & Chr(34), 0
Set WshShell = Nothing