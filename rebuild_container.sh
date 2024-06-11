# !/bin/bash
echo down all the containers
docker-compose down
echo remove images
docker image rm -f authenticatorappapi_ubuntu
echo build UI dist folder
cd  ../../../AuthenticatorAppUI/scripts/
sudo bash build_ui_image.sh
echo show present build path
pwd
echo build API image
cd ../../AuthenticatorAppUI
pwd
if [ -d "../AuthenticatorAppAPI/containers/ubuntu/configs/UI_dist/authenticationappui" ]; then
    rm -rf ../AuthenticatorAppAPI/containers/ubuntu/configs/UI_dist/authenticationappui 
    echo removed previous dist folder inside dist folder
fi
echo copying dist folder
cp -rf authenticationappui ../AuthenticatorAppAPI/containers/ubuntu/configs/UI_dist
cd ../AuthenticatorAppAPI/containers/ubuntu/
pwd 
echo api image build
docker-compose build --no-cache
echo deploy container
docker-compose up -d
