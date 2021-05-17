#!/usr/bin/gawk -f

BEGIN {
    separator = "--------- SEPARATOR ---------"
    cmd = "dmesg"
    count = 0
    while ((cmd | getline result) > 0) {
        buffer[count] = result
        count++
    }
    close(cmd)
    error_count = 0
    breaked = 0
    separator_detected = 0
}

{
    for (i = count; i >= 0; i--) {
        line = buffer[i]
        if (line ~ separator) {
	    separator_detected = 1
            if (error_count > 0) breaked = 1
            break
        }
        if ((line ~ "Out of") || (line ~ "segfault")) {
#	    print line
	    error_count++
	}
    }
}

END {
    print error_count
    command = "/bin/echo '--------- SEPARATOR ---------' | sudo /usr/bin/tee /dev/kmsg &>/dev/null"
    if ((breaked == 1) || (separator_detected == 0))
        command | getline trash
}
