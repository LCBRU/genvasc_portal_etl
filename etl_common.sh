function log_error {
    {
        echo To: $ADMIN_EMAIL_ADDRESS
        echo From: $ADMIN_EMAIL_ADDRESS
        echo Subject: $1 \($0\)
        echo
        echo "$2"
    } | ssmtp $ADMIN_EMAIL_ADDRESS

    echo !!!!
    echo !!!! $0 Error $(date): $1 - $2
    echo !!!!
}  
