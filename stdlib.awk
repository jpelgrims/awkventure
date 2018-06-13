# String manipulation functions

function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s) { return rtrim(ltrim(s)); }

function center(s,   screen_width) {
    half_width = int(screen_width/2)
    printf "%" int(half_width+length(s)/2) "s\n", s
}

function repeat( str, n,    rep, i )
{
    for( ; i<n; i++ )
        rep = rep str   
    return rep
}

# Array help functions

function array_length(array,   l) {l = 0; for (item in array) {l++}; return l}

# Console functions

function putch(char, x, y) {
    printf "\033[%s;%sH%c", y, x, char
}

function cls() {
	printf "\033[2J"
}


# Randomness

function randint(min, max) {return int(((rand()*100) % (max -  min + 1)) + min)}
