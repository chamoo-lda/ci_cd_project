# Base Image 
FROM nginx:alpine

#Copy the app files to /usr/share/nginx/html/
COPY ./app /usr/share/nginx/html/

#Expose Nginx Port
EXPOSE 80

#Start NginxService 
CMD ["nginx", "-g", "daemon off;"]
