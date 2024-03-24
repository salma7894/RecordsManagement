#! /bin/bash
log_file="$PWD/$1.log"
email="salma.khalaf87@gmail.com"

if_error_exist()
{
  grep -i "Failure" "$PWD/log1.log"
}

#main_script


#mutt -s "Records Management log file" -a "$log_file" -- "$email" <<< "The attached log contains errors"


$ cat $log_file | mail -s "Log file" $email
