local mousePos = reaper.BR_PositionAtMouseCursor(false)
local ts_Start, ts_End = reaper.GetSet_LoopTimeRange(false, false, 0,0,false)
reaper.SetEditCurPos(mousePos,true,true) -- moveview and seekplay
if ts_End ~= ts_Start then reaper.GetSet_LoopTimeRange(true,false,ts_Start,ts_End,false) end