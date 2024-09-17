
local function to_16_bits_str(number)
        return string.char(bit.band(bit.rshift(number, 8), 255)) ..
                string.char(bit.band(number, 255))
end

-- Returns a number representing the 2 first characters of the argument string
local function to_16_bits_number(str)
        return bit.lshift(string.byte(str, 1), 8) +
                string.byte(str, 2)
end

-- Returns a 4-characters string the bits of which represent the argument
local function to_32_bits_str(number)
        return string.char(bit.band(bit.rshift(number, 24), 255)) ..
                string.char(bit.band(bit.rshift(number, 16), 255)) ..
                string.char(bit.band(bit.rshift(number, 8), 255)) ..
                string.char(bit.band(number, 255))
end

-- Returns a number representing the 4 first characters of the argument string
local function to_32_bits_number(str)
        return bit.lshift(string.byte(str, 1), 24) +
                bit.lshift(string.byte(str, 2), 16) +
                bit.lshift(string.byte(str, 3), 8) +
                string.byte(str, 4)
end

-- Returns a 4-characters string the bits of which represent the argument
-- Returns incorrect results on numbers larger than 2^32
local function to_64_bits_str(number)
        return string.char(0) .. string.char(0) .. string.char(0) .. string.char(0) ..
                to_32_bits_str(number % 0xFFFFFFFF)
end

-- Returns a number representing the 8 first characters of the argument string
-- Returns incorrect results on numbers larger than 2^48
local function to_64_bits_number(str)
        return bit.lshift(string.byte(str, 2), 48) +
                bit.lshift(string.byte(str, 3), 40) +
                bit.lshift(string.byte(str, 4), 32) +
                bit.lshift(string.byte(str, 5), 24) +
                bit.lshift(string.byte(str, 6), 16) +
                bit.lshift(string.byte(str, 7), 8) +
                string.byte(str, 8)
end

local function sha1(val)
    -- Mark message end with bit 1 and pad with bit 0, then add message length
    -- Append original message length in bits as a 64bit number
    -- Note: We don't need to bother with 64 bit lengths so we just add 4 to
    -- number of zeros used for padding and append a 32 bit length instead
    local padded_message = val ..
        string.char(128) ..
        string.rep(string.char(0), 64 - ((string.len(val) + 1 + 8) % 64) + 4) ..
        to_32_bits_str(string.len(val) * 8)

    -- Blindly implement method 1 (section 6.1) of the spec without
    -- understanding a single thing
    local H0 = 0x67452301
    local H1 = 0xEFCDAB89
    local H2 = 0x98BADCFE
    local H3 = 0x10325476
    local H4 = 0xC3D2E1F0

    -- For each block
    for M = 0, string.len(padded_message) - 1, 64 do
        local block = string.sub(padded_message, M + 1)
        local words = {}
        -- Initialize 16 first words
        local i = 0
        for W = 1, 64, 4 do
            words[i] = to_32_bits_number(string.sub(
                block,
                W
            ))
            i = i + 1
        end

        -- Initialize the rest
        for t = 16, 79, 1 do
            words[t] = bit.rol(
                bit.bxor(
                    words[t - 3],
                    words[t - 8],
                    words[t - 14],
                    words[t - 16]
                ),
                1
            )
        end

        local A = H0
        local B = H1
        local C = H2
        local D = H3
        local E = H4

        -- Compute the hash
        for t = 0, 79, 1 do
            local TEMP
            if t <= 19 then
                TEMP = bit.bor(
                        bit.band(B, C),
                        bit.band(
                            bit.bnot(B),
                            D
                        )
                    ) +
                    0x5A827999
            elseif t <= 39 then
                TEMP = bit.bxor(B, C, D) + 0x6ED9EBA1
            elseif t <= 59 then
                TEMP = bit.bor(
                        bit.bor(
                            bit.band(B, C),
                            bit.band(B, D)
                        ),
                        bit.band(C, D)
                    ) +
                    0x8F1BBCDC
            elseif t <= 79 then
                TEMP = bit.bxor(B, C, D) + 0xCA62C1D6
            end
            TEMP = (bit.rol(A, 5) + TEMP + E + words[t])
            E = D
            D = C
            C = bit.rol(B, 30)
            B = A
            A = TEMP
        end

        -- Force values to be on 32 bits
        H0 = (H0 + A) % 0x100000000
        H1 = (H1 + B) % 0x100000000
        H2 = (H2 + C) % 0x100000000
        H3 = (H3 + D) % 0x100000000
        H4 = (H4 + E) % 0x100000000
    end

    return to_32_bits_str(H0) ..
        to_32_bits_str(H1) ..
        to_32_bits_str(H2) ..
        to_32_bits_str(H3) ..
        to_32_bits_str(H4)
end
