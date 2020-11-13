#!/bin/bash
rm -rf /var/lib/apt/lists/*
apt-get autoremove -y
apt-get clean -y