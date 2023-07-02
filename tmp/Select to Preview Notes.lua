-- much of this is adapted from spk77's Move edit cursor to start of next note + preview.eel
function loop() 
  
  function get_ppqpos_at_mouse()
      time = reaper.BR_GetMouseCursorContext_Position()
      return reaper.MIDI_GetPPQPosFromProjTime(take, time)
  end

  function iterAllMIDINotes(take, idx)
      if not idx then return iterAllMIDINotes, take, 0 end
      note = {}
      note.retval, note.selected, note.muted, note.startppqpos, note.endppqpos, 
      note.chan, note.pitch, note.vel = reaper.MIDI_GetNote(take, idx)
      idx = idx + 1
      if note.retval then return idx, note end
  end

  function get_note_at_mouse()
      for idx, note in iterAllMIDINotes(take) do
          if note.pitch == ({reaper.BR_GetMouseCursorContext_MIDI()})[3] then
              return idx, note
          end
      end
  end

  function select_note(idx, note)
      -- reaper.MIDI_SetNote( take, noteidx, selectedIn, mutedIn, startppqposIn, endppqposIn, chanIn, pitchIn, velIn, noSortIn )
      reaper.MIDI_SetNote(take, idx - 1, true, note.muted, note.startppqpos, note.endppqpos, note.chan, note.pitch, note.vel, false)
  end
  function unselect_note(idx, note)
      -- reaper.MIDI_SetNote( take, noteidx, selectedIn, mutedIn, startppqposIn, endppqposIn, chanIn, pitchIn, velIn, noSortIn )
      reaper.MIDI_SetNote(take, idx - 1, false, note.muted, note.startppqpos, note.endppqpos, note.chan, note.pitch, note.vel, false)
  end

  function can_stuff_midi(take)
    item = reaper.GetMediaItemTake_Item(take)
    track = reaper.GetMediaItem_Track(item)
    recarm = reaper.GetMediaTrackInfo_Value(track, "I_RECARM")
    recmon = reaper.GetMediaTrackInfo_Value(track, "I_RECMON")
    recinput = reaper.GetMediaTrackInfo_Value(track, "I_RECINPUT")
    if recinput & 4096 and recarm > 0 and recmon > 0 then
      return true else return false
    end
  end

  function get_active_take_and_hwnd()
    hwnd = reaper.MIDIEditor_GetActive()
    if not hwnd then return end
    take = reaper.MIDIEditor_GetTake(hwnd)
    if not take then return end
  end

  if reaper.MIDIEditor_GetActive() ~= nil then
    lmb = reaper.JS_Mouse_GetState(1)
    if lmb == 1 and prev_lmb == 0 then
        reaper.MIDIEditor_OnCommand(hwnd, 40214) -- Unselect all notes
      get_active_take_and_hwnd()
      reaper.BR_GetMouseCursorContext()
        idx, note = get_note_at_mouse()

      orig_pitch = ({reaper.BR_GetMouseCursorContext_MIDI()})[3]
      orig_ppq_pos = get_ppqpos_at_mouse()
    end
    if lmb == 1 then
      reaper.BR_GetMouseCursorContext()
        idx, note = get_note_at_mouse()
      cur_pitch = ({reaper.BR_GetMouseCursorContext_MIDI()})[3]
      cur_ppq_pos = get_ppqpos_at_mouse()
      if cur_pitch > orig_pitch then 
        sel_top = cur_pitch
        sel_btm = orig_pitch
      else 
        sel_top = orig_pitch
        sel_btm = cur_pitch
      end

      if cur_ppq_pos > orig_ppq_pos then 
        sel_right = cur_ppq_pos
        sel_left = orig_ppq_pos
      else
        sel_right = orig_ppq_pos
        sel_left = cur_ppq_pos
      end


        for idx, note in iterAllMIDINotes(take) do
          if (note.pitch >= sel_btm and note.pitch <= sel_top) and
          ((note.startppqpos >= sel_left and note.startppqpos <= sel_right) or
        (note.endppqpos >= sel_left and note.endppqpos <= sel_right) or
        (sel_left >= note.startppqpos and sel_right <= note.endppqpos)) then
          if note.selected == false then
            select_note(idx, note)
            if can_stuff_midi(take) == false then
              reaper.Main_OnCommand(40491, 0) -- Track: Unarm all tracks for recording
              prep_track_for_midi_stuffing(take)
            end
            msg1 = 144 + note.chan
            msg2 = note.pitch
            msg3 = note.vel
            reaper.StuffMIDIMessage(0, msg1, msg2, msg3)
            end
          else
          if note.selected == true then
              unselect_note(idx, note)
            msg1 = 144
            msg2 = note.pitch
            reaper.StuffMIDIMessage(0, msg1, msg2, 0)
          end
          end
        end
    end

    -- send all notes-off when lmb is released
    if lmb == 0 and prev_lmb == 1 then
      for note = 0, 127 do
        for chan = 0, 15 do
          reaper.StuffMIDIMessage(0, 144+chan, note, 0)
        end
      end
    end

    prev_lmb = lmb
  end

  _, _, sectionID, cmdID = reaper.get_action_context()
  state = reaper.GetToggleCommandStateEx(sectionID, cmdID)
  if state == 1 or reaper.MIDIEditor_GetActive() == nil then
    reaper.defer(loop)
  end
end


function prep_track_for_midi_stuffing(take)
  item = reaper.GetMediaItemTake_Item(take)
  track = reaper.GetMediaItem_Track(item)
  recarm = reaper.SetMediaTrackInfo_Value(track, "I_RECARM", 1)
  recmon = reaper.SetMediaTrackInfo_Value(track, "I_RECMON", 1)
  recinput = reaper.SetMediaTrackInfo_Value(track, "I_RECINPUT", 4096+tonumber('111111'..'00000',2))
end


prev_lmb = 0
pos = 0

_, _, sectionID, cmdID = reaper.get_action_context()
state = reaper.GetToggleCommandStateEx(sectionID, cmdID)
if state == 0 then state = 1 else state = 0 end
reaper.SetToggleCommandState(sectionID, cmdID, state)
state = reaper.GetToggleCommandStateEx(sectionID, cmdID)
if state == 1 then
  hwnd = reaper.MIDIEditor_GetActive()
  if hwnd ~= nil then
      take = reaper.MIDIEditor_GetTake(hwnd)
      if take ~= nil then
        prep_track_for_midi_stuffing(take)
      loop()
    end
  end
end
