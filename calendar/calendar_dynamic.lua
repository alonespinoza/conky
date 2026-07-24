-- Dynamic calendar generator for Conky
-- Simple and reliable implementation

function get_weekday_headers()
    local today = os.date("*t")
    local first_day = os.time { year = today.year, month = today.month, day = 1 }
    local first_day_info = os.date("*t", first_day)
    local first_weekday = first_day_info.wday

    -- Convert to Monday-based index (Monday=1, Tuesday=2, ..., Sunday=7)
    if first_weekday == 1 then
        first_weekday = 7                 -- Sunday becomes 7
    else
        first_weekday = first_weekday - 1 -- Monday becomes 1
    end

    -- Get days in month
    local days_in_month = os.date("*t", os.time { year = today.year, month = today.month + 1, day = 0 }).day

    -- Build weekday headers (plain text)
    local weekdays = { "Mo", "Tu", "We", "Th", "Fr", "Sa", "Su" }
    local result = ""
    local current_weekday = first_weekday

    for i = 1, days_in_month do
        local day_name = weekdays[current_weekday]
        result = result .. " " .. day_name
        current_weekday = current_weekday + 1
        if current_weekday > 7 then current_weekday = 1 end
    end

    return result
end

function get_calendar_numbers()
    local today = os.date("*t")
    local days_in_month = os.date("*t", os.time { year = today.year, month = today.month + 1, day = 0 }).day

    local result = ""
    for day = 1, days_in_month do
        local day_str
        if day < 10 then
            day_str = " 0" .. day
        else
            day_str = " " .. day
        end

        result = result .. day_str
    end

    return result
end

-- Export functions for Conky to use
conky_weekday_headers = get_weekday_headers
conky_calendar_numbers = get_calendar_numbers
