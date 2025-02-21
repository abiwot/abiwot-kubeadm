#!/bin/bash

if systemctl is-active --quiet nginx; then
    exit 0  # Success: NGINX is running
else
    exit 1  # Failure: NGINX is down
fi
