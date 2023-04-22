-- Creates animated webp with mpv
-- Requires ffmpeg
-- Usage: "w" to set start frame, "W" to set end frame, "Ctrl+w" to create

require 'mp.options'
local msg = require 'mp.msg'
local utils = require "mp.utils"

local options = {
    ffmpeg_path = "ffmpeg",
    dir = "~/",
    rez = 600,
    fps = 15,
    lossless = 0,
    quality = 90,
    compression_level = 6,
    loop = 0,
}

read_options(options, "webp")

local fps

-- Check for invalid fps values
if options.fps ~= nil and options.fps >= 1 and options.fps < 30 then
    fps = options.fps
else
    fps = 15
end

-- Set this to the filters to pass into ffmpeg's -vf option.
-- filters="fps=24,scale=320:-1:flags=spline"
filters=string.format("fps=%s,zscale='trunc(ih*dar/2)*2:trunc(ih/2)*2':f=spline36,setsar=1/1,zscale=%s:-1:f=spline36", fps, options.rez)

-- Setup output directory
local output_directory = mp.command_native({ "expand-path", options.dir })

--create output_directory if it doesn't exist
if utils.readdir(output_directory) == nil then
    local args = { 'powershell', '-NoProfile', '-Command', 'mkdir', output_directory }
    local res = mp.command_native({name = "subprocess", capture_stdout = true, playback_only = false, args = args})
    if res.status ~= 0 then
        msg.error("Failed to create webp_dir save directory "..output_directory..". Error: "..(res.error or "unknown"))
        return
    end
end

start_time = -1
end_time = -1

function make_webp_with_subtitles()
    make_webp_internal(true)
end

function make_webp()
    make_webp_internal(false)
end

function table_length(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

function make_webp_internal(burn_subtitles)
    local start_time_l = start_time
    local end_time_l = end_time
    if start_time_l == -1 or end_time_l == -1 or start_time_l >= end_time_l then
        mp.osd_message("Invalid start/end time.")
        return
    end

    msg.info("Creating webP...")
    mp.osd_message("Creating webP...")

    -- shell escape
    function esc_for_sub(s)
        s = string.gsub(s, [[\]], [[/]])
        s = string.gsub(s, '"', '"\\""')
        s = string.gsub(s, ":", [[\\:]])
        s = string.gsub(s, "'", [[\\']])
        s = string.gsub(s, "%[", "\\%[")
        s = string.gsub(s, "%]", "\\%]")
        return s
    end

    local pathname = mp.get_property("path", "")
    local trim_filters = filters

    local position = start_time_l
    local duration = end_time_l - start_time_l

    if burn_subtitles then
        -- Determine currently active sub track

        local i = 0
        local tracks_count = mp.get_property_number("track-list/count")
        local subs_array = {}

        -- check for subtitle tracks

        while i < tracks_count do
            local type = mp.get_property(string.format("track-list/%d/type", i))
            local selected = mp.get_property(string.format("track-list/%d/selected", i))
            local external = mp.get_property(string.format("track-list/%d/external", i))

            -- if it's a sub track, save it

            if type == "sub" then
                local length = table_length(subs_array)
                if selected == "yes" and external == "yes" then
                    msg.info("Error: external subtitles have been selected")
                    mp.osd_message("Error: external subtitles have been selected", 2)
                    return
                else
                    subs_array[length] = selected == "yes"
                end
            end
            i = i + 1
        end

        if table_length(subs_array) > 0 then

            local correct_track = 0

            -- iterate through saved subtitle tracks until the correct one is found

            for index, is_selected in pairs(subs_array) do
                if (is_selected) then
                    correct_track = index
                end
            end

            trim_filters = trim_filters .. string.format(",subtitles='%s':si=%s", esc_for_sub(pathname), correct_track)

        end

    end

    -- make the webp
    local filename = mp.get_property("filename/no-ext")
    local file_path = output_directory .. "/" .. filename

    -- increment filename
    for i=0,999 do
        local fn = string.format('%s_%03d.webp', file_path, i)
        if not file_exists(fn) then
            webpname = fn
            break
        end
    end
    if not webpname then
        mp.osd_message('No available filenames!')
        return
    end

    local copyts = ""

    if burn_subtitles then
        copyts = "-copyts"
    end

    -- original command
    -- args = {
    --     options.ffmpeg_path, "-y", "-hide_banner", "-loglevel", "error",
    --     "-ss", tostring(position),
    --     -- copyts,
    --     "-t", tostring(duration),
    --     "-i", pathname,
    --     "-lavfi", trim_filters,
    --     "-lossless", tostring(options.lossless),
    --     "-q:v", tostring(options.quality),
    --     "-compression_level", tostring(options.compression_level),
    --     "-loop", tostring(options.loop),
    --     webpname
    -- }

    -- basic command
    args = {
        "ffmpeg", "-v", "warning",
        "-i", pathname,
        "-vcodec", "libwebp",
        "-lossless", tostring(options.lossless),
        "-loop", tostring(options.loop),
        "-preset", "picture",
        "-vsync", "0",
        "-vf", "fps=".. options.fps .. ",scale=" .. options.rez .. ":-1:flags=lanczos",
        "-ss", tostring(position), "-t", tostring(duration),
        "-an",  -- remove audio
        "-q:v", tostring(options.quality),
        "-compression_level", tostring(options.compression_level),
        "-y", webpname
    }

    local screenx, screeny, aspect = mp.get_osd_size()
    mp.set_osd_ass(screenx, screeny, "{\\an9} creating...")
    local res = mp.command_native({name = "subprocess", capture_stdout = true, playback_only = false, args = args})
    mp.set_osd_ass(screenx, screeny, "")
    if res.status ~= 0 then
        msg.info("Failed to create webP.")
        mp.osd_message("Error creating webP, check console for more info.")
        return
    end

    local success_message = "webP created! " .. output_directory .. "/" .. webpname
    msg.info(success_message)
    mp.osd_message(success_message, 5)
end

function set_webp_start()
    start_time = mp.get_property_number("time-pos", -1)
    mp.osd_message("webP Start: " .. start_time)
end

function set_webp_end()
    end_time = mp.get_property_number("time-pos", -1)
    mp.osd_message("webP End: " .. end_time)
end

function file_exists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end

mp.add_key_binding("F3", "set_webp_start", set_webp_start)
mp.add_key_binding("F4", "set_webp_end", set_webp_end)
mp.add_key_binding("F5", "make_webp", make_webp)
mp.add_key_binding("Ctrl+W", "make_webp_with_subtitles", make_webp_with_subtitles) --only works with srt for now
