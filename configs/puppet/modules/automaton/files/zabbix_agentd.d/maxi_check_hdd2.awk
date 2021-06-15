#!/usr/bin/gawk -f

BEGIN {
    if (path !~ /(v|s)da/) {
        while ((getline line < "/etc/fstab") > 0) {
            split(line, arr);
            path_col = arr[2]
            if (path_col == path) {
                dev_col = arr[1]
                sub(/.+\//, "", dev_col);
                device = dev_col;
                break;
            }
        }
    } else {
        device=path
    }
}

{
    if ($3 == device) {
        if (cmd == "read_ms") print $7
        else if (cmd == "write_ms") print $11
        else if (cmd == "read_sectors") print $6
        else if (cmd == "write_sectors") print $10
    }
}
