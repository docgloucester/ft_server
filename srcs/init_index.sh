#!/bin/bash
test $AUTOINDEX -eq 1 && sed -i "25iautoindex on;" /etc/nginx/sites-available/wp