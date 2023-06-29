dofile(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua")

-- The Eventcheck-function, that shall return true if the currently active project has been saved.
-- This will trigger running the script that shall output a message, that a project has been saved.


function mouse_is_down(userspace)
  --   get mouse left click state
  local mouse_left_key = reaper.JS_Mouse_GetState(00000001)
  local ctrl_key = reaper.JS_Mouse_GetState(00000100)
  local shift_key = reaper.JS_Mouse_GetState(00001000)
  local alt_key = reaper.JS_Mouse_GetState(00010000)
  local mouse_middle_key = reaper.JS_Mouse_GetState(10000000)
  local only_click_down = 0
  if userspace["oldstate"] == nil then userspace["oldstate"] = 0 end 

  if mouse_left_key > 0 and ctrl_key <= 0 and shift_key <= 0 and alt_key <= 0 and mouse_middle_key <= 0 then
    only_click_down = 1
  end

  if only_click_down == 0 then
    userspace["oldstate"] = 0
  end

  if only_click_down == 1 then
    local editor = reaper.MIDIEditor_GetActive() -- Get the active MIDI editor

    if editor then
      local take = reaper.MIDIEditor_GetTake(editor) -- Get the MIDI take associated with the editor
      local window, segment, details = reaper.BR_GetMouseCursorContext()
      if take then
        if window == "midi_editor" and segment == "notes" then
          local mousePosition = reaper.BR_GetMouseCursorContext_Position()
          local _, noteCount, _, _ = reaper.MIDI_CountEvts(take)
          
          for noteidx = 0, noteCount - 1 do
            local retval, _, _, startppqpos, endppqpos, _, pitch, _ = reaper.MIDI_GetNote(take, noteidx)
            local startPosition = reaper.MIDI_GetProjTimeFromPPQPos(take, startppqpos)
            local endPosition = reaper.MIDI_GetProjTimeFromPPQPos(take, endppqpos)
            local _, _, mousePitch = reaper.BR_GetMouseCursorContext_MIDI()

            if mousePosition >= startPosition and mousePosition <= endPosition and mousePitch == pitch then
              reaper.ShowConsoleMsg("NOTE!! \n")
              userspace["oldstate"] = 1       -- flip flag to indicate we have already returned false during this click
              return false
            end
          end

          if(userspace["oldstate"] == 0) then -- if this is the first time returning true while click is held
            reaper.ShowConsoleMsg("not note \n")
            userspace["oldstate"] = 1         -- flip flag to indicate we have already returned true during this click
            return true
          end

          return false
        end
      end
    end
  end

  return false
end

-- Start the EventManager
retval = ultraschall.EventManager_Start()

-- The action command-id of the script that shall be run when the event is triggered
-- replace the one below with the one saved by your own script
action_command_id = "_RS83ccd953f9c8d4b9eeffc323ecefce2b9c7ee37a" 

-- Add the event with all parameters set usefully
event_identifier = ultraschall.EventManager_AddEvent("mouse_is_down", 0, 0, true, false, mouse_is_down, {action_command_id..",0"})
