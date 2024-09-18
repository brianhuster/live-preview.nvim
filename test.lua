local utils = require('live-preview.utils')
local a = utils.sha1('dGhlIHNhbXBsZSBub25jZQ==258EAFA5-E914-47DA-95CA-C5AB0DC85B11')

local function base64(val)
    local b64 = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K",
        "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W",
        "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i",
        "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u",
        "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6",
        "7", "8", "9", "+", "/" }

    local function char1(byte1)
        -- 252: 0b11111100
        return b64[bit.rshift(bit.band(string.byte(byte1), 252), 2) + 1]
    end

    local function char2(byte1, byte2)
        -- 3:   0b00000011
        return b64[bit.lshift(bit.band(string.byte(byte1), 3), 4) +
        -- 240: 0b11110000
        bit.rshift(bit.band(string.byte(byte2), 240), 4) + 1]
    end

    local function char3(byte2, byte3)
        -- 15:  0b00001111
        return b64[bit.lshift(bit.band(string.byte(byte2), 15), 2) +
        -- 192: 0b11000000
        bit.rshift(bit.band(string.byte(byte3), 192), 6) + 1]
    end

    local function char4(byte3)
        -- 63:  0b00111111
        return b64[bit.band(string.byte(byte3), 63) + 1]
    end

    local result = ""
    for byte1, byte2, byte3 in string.gmatch(val, "(.)(.)(.)") do
        result = result ..
            char1(byte1) ..
            char2(byte1, byte2) ..
            char3(byte2, byte3) ..
            char4(byte3)
    end
    -- The last bytes might not fit in a triplet so we need to pad them
    -- with zeroes
    if (string.len(val) % 3) == 1 then
        result = result ..
            char1(string.sub(val, -1)) ..
            char2(string.sub(val, -1), "\0") ..
            "=="
    elseif (string.len(val) % 3) == 2 then
        result = result ..
            char1(string.sub(val, -2, -2)) ..
            char2(string.sub(val, -2, -2), string.sub(val, -1)) ..
            char3(string.sub(val, -1), "\0") ..
            "="
    end

    return result
end


print(a)
print(base64(a))
print(vim.base64.encode(a))
