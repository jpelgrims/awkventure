# String manipulation functions

function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }

function sleep(seconds) {
    system("sleep " seconds)
}

function center(s,   screen_width) {
    half_width = int(screen_width/2)
    printf "%" int(half_width+length(s)/2) "s\n", s
}

function repeat( str, n,    rep, i)
{
    for(i=0; i<n; i++ )
        rep = rep str   
    return rep
}

# List functions
function init(list) {list["length"] = 0}
function len(list) {return list["length"]}
function append(list, item) {
    list[list["length"]] = item
    list["length"]++
}

function remove(list, idx) {
    if (idx == list["length"]-1) {
        del list[idx]
        list["length"]--
    } else if (0 <= idx && idx <= list["length"]-1) {
        del list[idx]

        for(i=idx;i++;i<list["length"]-1) {
            list[idx] = list[idx+1]
        }
        list["length"]--
    }
}

function array_length(array,   l) {l = 0; for (item in array) {l++}; return l}

# Randomness
function randint(min, max) {return int((rand() * (max -  min + 1))) + min}
function randchar(string) {return substr(string, randint(1, length(string)), 1)}
function chance(probability) {return randint(0, 100) > probability}

# Math
function min(x, y) { return x < y ? x : y }
function max(x, y) { return x < y ? y : x }
function abs(v) {return v < 0 ? -v : v}
function round(nr) {
    return int(sprintf("%d\n",nr + 0.5))
}