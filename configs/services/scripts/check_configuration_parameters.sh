#!/bin/bash

exec 1> >(logger -s -t $(basename $0)) 2>&1
config_array=( GRVA_HOSTNAME= GRVA_CLIENT_HOSTNAME= GRVA_BASIC_AUTH_USERNAME= GRVA_BASIC_AUTH_PASSWORD= GRVA_CLIENT_BASIC_AUTH_USERNAME= GRVA_CLIENT_BASIC_AUTH_PASSWORD= DOMAIN= LARAVEL_ECHO_PORT= GRVA_CLIENT_API_PORT= DB_HOST= DB_PORT= DB_DATABASE= DB_USERNAME= DB_PASSWORD= );
fido2_config_array=( timeout= user_verification= auto_provisioning= );

declare timeout=120;
declare current_time=0;
declare config_array_length=${#config_array[@]};
declare fido2_config_array_length=${#fido2_config_array[@]};

check_config(){
element_count=0;
for key in "${config_array[@]}"
do
    config_flag=1;
    while (( $current_time < $timeout && $config_flag )); do
        config_parameter=`cat /opt/grs/greenradius/grs_fido2_authenticator/config.txt | grep $key`;
        ((current_time++))
        if [ ! -z "$config_parameter" ];then
            config_flag=0;
            ((element_count++))
        else
            config_flag=1;
            sleep 1;
            config_element_not_found=$key
            echo $config_element_not_found " not found from config.txt file. ";
        fi
    done
done

if [ $element_count == $config_array_length ];then
    echo "All elements found from config.txt file."
else
    echo $config_element_not_found " not found from config.txt file. ";
    exit 1;
fi
return
}

check_fido2_config(){
element_count=0;
for key in "${fido2_config_array[@]}"
do
    fido2_config_flag=1;
    while (( $current_time < $timeout && $fido2_config_flag )); do
        fido2_config_parameter=`cat /opt/grs/greenradius/grs_fido2_authenticator/fido2_config.txt | grep $key`;
        ((current_time++))
        if [ ! -z "$fido2_config_parameter" ];then
            fido2_config_flag=0;
            ((element_count++))
        else
            fido2_config_flag=1;
            sleep 1;
            fido2_config_element_not_found=$key
            echo $fido2_config_element_not_found " not found from fido2_config.txt file.";

        fi
    done
done

if [ $element_count == $fido2_config_array_length ];then
    echo "All elements found from fido2_config.txt file."
else
    echo $element_count
    echo $fido2_config_element_not_found " not found from fido2_config.txt file.";
    exit 1;
fi

return
}

check_config
check_fido2_config