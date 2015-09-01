# Docker_OpenMRS
This image can pe pulled by running:

"docker pull jmbabazi/openmrs"

To run the container use

docker run -it [Container_ID]


OpenMRS credentials:

username: admin 

password: Admin123

Mysql Credentials:

username: root 

password: passw0rd

or

username: openmrs 

password: password

You can also clone this repository and build you own images

git clone https://github.com/PIH/Docker_OpenMRS.git

cd path_to_Docker_OpenMRS.git folder

docker build -t preferred_name/version .

docker run -it Container_ID





