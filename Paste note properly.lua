-- reaper.Main_OnCommand(reaper.NamedCommandLookup("_RS741298f2f6317ebf4a178696fa41af53167a10cf"), 0)
-- reaper.Main_OnCommand(reaper.NamedCommandLookup("_RS7d3c_90e9791b8a454ea9410339dd8fe87d6fde0e8934"), 0)

reaper.MIDIEditor_OnCommand( reaper.MIDIEditor_GetActive(), 40443) --locate cursor without snap
reaper.MIDIEditor_OnCommand( reaper.MIDIEditor_GetActive(), reaper.NamedCommandLookup("_RS7d3c_aa939c97b195c6a4ef30b15479e7bca333195acb") ) -- paste note
reaper.MIDIEditor_OnCommand( reaper.MIDIEditor_GetActive(), 40469) --quantize note
reaper.MIDIEditor_OnCommand( reaper.MIDIEditor_GetActive(), 40440) --locate cursor to start of note



reaper.ShowConsoleMsg("hhhh\n")