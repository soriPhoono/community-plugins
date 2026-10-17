local isVertical = barWidget.isVertical()

local function render(state)
    if not state or not state.sessionPtr then
        barWidget.render(ui.glyph({
            color = "on_surface",
            name = noctalia.getConfig("widget-glyph-main"),
        }))
        return
    end

    local isWork = state.sessionPtr.stage == 1
    local phaseColor = if isWork then "primary" else "tertiary"
    local color =
        if not state.isDirty then "on_surface"
        elseif state.isRunning then phaseColor
        else phaseColor .. "/0.6"
    local name =
        if not state.isDirty then
            noctalia.getConfig("widget-glyph-main")
        else
            if state.sessionPtr.stage == 1 then
                noctalia.getConfig("widget-glyph-work")
            else noctalia.getConfig("widget-glyph-break")

    local content = { ui.glyph ({ color = color, name = name }) }

    local hours = math.floor(state.secondsLeft / 3600)
    local mins = math.floor((state.secondsLeft % 3600) / 60)
    local secs = state.secondsLeft % 60

    local labelTime =
        if not isVertical then
            if hours == 0 then
                string.format("%02d:%02d", mins, secs)
            else
                string.format("%d:%02d:%02d", hours, mins, secs)
        else
            if hours == 0 then
                string.format("%02d\n%02d", mins, secs)
            else
                string.format("%02d\n%02d\n%02d", hours, mins, secs)

    if state.isDirty then
        table.insert(content, ui.label({
            text = labelTime,
            textAlign = "center",
            color = color
        }))

        local sessionData = noctalia.state.get("pomodoro.sessionData")
        local stageTotal = sessionData and sessionData[state.sessionPtr.session][state.sessionPtr.stage]
        if stageTotal and stageTotal > 0 then
            table.insert(content, ui.progress({
                progress = state.secondsLeft / stageTotal,
                fill = color,
                track = "surface_variant/0.4",
                radius = 2,
                width = if isVertical then 24 else 36,
                height = 4,
            }))
        end
    end

    local container = if isVertical then ui.column else ui.row
    barWidget.render(container({ gap = 4, align = "center", justify = "center" }, content))
end

--- main
local function refresh()
    render(noctalia.state.get("pomodoro.state"))
end

render(noctalia.state.get("pomodoro.state"))

noctalia.state.watch("pomodoro.state", function(state)
    refresh()
end)

noctalia.state.watch("pomodoro.sessionData", function(_sessionData)
    refresh()
end)
