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

# Array help functions

function array_length(array,   l) {l = 0; for (item in array) {l++}; return l}

# Randomness

function randint(min, max) {return int((rand() * (max -  min + 1))) + min}
function randchar(string) {return substr(string, randint(1, length(string)), 1)}

# Math

function min(x, y) { return x < y ? x : y }
function max(x, y) { return x < y ? y : x }
function abs(v) {return v < 0 ? -v : v}
function round(nr) {
    return int(sprintf("%d\n",nr + 0.5))
}