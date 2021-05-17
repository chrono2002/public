#!/usr/bin/ruby

require 'net/ftp'
require 'ftools'

backup_dirs = "/www /var/lib/mysql"
backup_age_days = 7
backup_prefix = "backup_"

# fill to enable ftp backup

ftp_server = ""
ftp_user = ""
ftp_pass = ""
ftp_backup_dir = "."

# fill to enable fs backup

backup_to_fs = "/www/backup"

# init variables

old_files_age = 86400 * backup_age_days
ctime = Time.now
past_due_logs = (ctime - old_files_age)

random = rand(9999)
backup_tmp_dir = '/tmp/backup' + random.to_s
backup_time = ctime.strftime("%Y.%m.%d_%H:%M")
backup_file = backup_tmp_dir + '/' + backup_prefix + backup_time + '.tgz'

# tar

`mkdir #{backup_tmp_dir}`
`nice -n 19 tar -zcpf #{backup_file} #{backup_dirs} --exclude backup --exclude ib_logfile0 --exclude ib_logfile1 > /dev/null 2>&1`

# fs

if backup_to_fs.length >0
    Dir.chdir(backup_to_fs)
    File.copy(backup_file, backup_to_fs);

    Dir.foreach(backup_to_fs) do |file|
	if (/#{backup_prefix}/.match(file))
    	    if File.mtime(file) < past_due_logs
		File.delete(file)
	    end
	end
    end
end

# ftp

if ftp_server.length >0
    ftp = Net::FTP.new
    ftp.passive = true
    ftp.resume = true
    ftp.connect(ftp_server)
    ftp.login(ftp_user, ftp_pass)
    ftp.chdir(ftp_backup_dir)

    ftp.putbinaryfile(backup_file);

    # delete aged backups
    for file in ftp.nlst
	if (/#{backup_prefix}/.match(file))
	    if ftp.mtime(file) < past_due_logs
    		ftp.delete(file)
	    end
	end
    end
    
    ftp.close
end

`rm -rf #{backup_tmp_dir}`
