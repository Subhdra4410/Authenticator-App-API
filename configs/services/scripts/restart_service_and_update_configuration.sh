 #!/bin/bash
exec 1> >(logger -s -t $(basename $0)) 2>&1
cd /opt/scripts/
bash update_configurations.sh
bash setup_database.sh
service php8.1-fpm restart
service nginx restart
service cron restart