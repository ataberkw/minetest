-- MultiCraft: builtin/common/btn_style.lua
-- luacheck: read_globals PLATFORM
function background(x, y, width, height)
    return ([[
        bgcolor[;neither;]
        background9[%s,%s;%s,%s;%s;false;36]
        ]]):format(x, y, width, height, defaultguitexturedir .. 'bg_test.png')
end

function fill_background(height, width)
    return ([[
        bgcolor[;neither;]
        background9[nil,nil;nil,nil;%s;true;36]
        ]]):format(defaultguitexturedir .. 'bg_test.png')
end

function primary_btn_style(field, color)
    return btn_style("gui_button", field, color, 9)
end

function btn_style(asset_name, field, color, middle)
    local image_name = asset_name .. (color and "_" .. color or "") .. ".png"
    local image = defaulttexturedir .. DIR_DELIM .. "gui" .. DIR_DELIM .. image_name
    local already_pressed = string.find(image_name, "_pressed")

    local image_pressed_name = already_pressed and image_name or asset_name .. (color and "_" .. color or "") ..
                                   "_pressed.png"
    local image_pressed = already_pressed and image or defaulttexturedir .. DIR_DELIM .. "gui" .. DIR_DELIM ..
                              image_pressed_name

    local retval =
        "style[" .. field .. ";border=false]" .. "style[" .. field .. ";bgimg=" .. image .. ";bgimg_middle=" ..
            dump(middle) .. ";bgimg_pressed=" .. image_pressed .. "]"

    return retval
end

function scrollbar_style(name, style_type)
    return "style" .. (style_type and "_type" or "") .. "[" .. name .. ";scrollbar_bgimg=" .. defaultguitexturedir ..
               "scrollbar_bg.png;scrollbar_thumb_top_img=" .. defaultguitexturedir ..
               "scrollbar_slider_top.png;scrollbar_thumb_bottom_img=" .. defaultguitexturedir ..
               "scrollbar_slider_bottom.png;scrollbar_thumb_img=" .. defaultguitexturedir ..
               "scrollbar_slider_middle.png;scrollbar_up_img=" .. defaultguitexturedir ..
               "scrollbar_up.png;scrollbar_down_img=" .. defaultguitexturedir ..
               "scrollbar_down.png;scrollbar_middle=16]"
end
