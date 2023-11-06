FROM ggmartinez/laravel:php-82-Apache

WORKDIR /app

RUN yum update -y
RUN yum install -y php-redis
