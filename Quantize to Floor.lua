local _, _, _, _, _, _, mouse_pos = reaper.get_action_context()
local window, _, _ = reaper.BR_GetMouseCursorContext()

local editor = reaper.MIDIEditor_GetActive() -- Get the active MIDI editor

if editor then
  local take = reaper.MIDIEditor_GetTake(editor) -- Get the MIDI take associated with the editor

  if take then
    local snapValue = reaper.MIDI_GetGrid(take) -- Get the measure grid value

    -- Now you can use the snapValue variable for further processing
    -- For example, you can print the snap value to the Reaper console
    if window == "midi_editor" then
      local take = reaper.MIDIEditor_GetTake(reaper.MIDIEditor_GetActive())
      if take ~= nil then
          local cursor_pos = reaper.GetCursorPosition()
          local measures = reaper.TimeMap2_beatsToTime(0, cursor_pos)
          if measures % (snapValue / 4)  > snapValue / 8 then
            reaper.Main_OnCommandEx(40214, 0, 0)
            reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_RS7d3c_aa939c97b195c6a4ef30b15479e7bca333195acb"), 0, 0)
            reaper.Main_OnCommandEx(40183, 0, 0) -- Edit: Move notes left one grid unit
            
            -- reaper.ShowConsoleMsg("Clicked measure: "  .. measures .. "\n")
          else
            reaper.Main_OnCommandEx(40214, 0, 0)
            reaper.Main_OnCommandEx(reaper.NamedCommandLookup("_RS7d3c_aa939c97b195c6a4ef30b15479e7bca333195acb"), 0, 0)
          end
    
      end
    end
    
  end
end




