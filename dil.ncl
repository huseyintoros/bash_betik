#!/bin/bash
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/ut_string.ncl"
exit
cd /home/hava12/Build_WRF/WRFV3/run
rm *.pdf *.ps
# Tarih atamalari
gun_1=$(date +%d -d "-1 day") # dun
gun=$(date +%d)             # bugun
gun1=$(date +%d -d "+1 day") # yarin
gun2=$(date +%d -d "+2 day") # ertesi gun

ay_1=$(date +%m -d "-1 day") # dunku ay
ay=$(date +%m)               # bu ay
ay1=$(date +%m -d "+1 day")  # yarinki ay
ay2=$(date +%m -d "+2 day")  # oburgunku  ay

yil_1=$(date +%y -d "-1 day")    # dunku yil
tamyil_1=$(date +%Y -d "-1 day") # dunku yil
yil=$(date +%y)                  # bul yil
tamyil=$(date +%Y)               # bu yil
yil1=$(date +%y -d "+1 day")   # yarinki yil
tamyil1=$(date +%Y -d "+1 day")  # yarinki yil
tamyil2=$(date +%Y -d "+2 day")  # oburhunku yil



# SkewT 
sed -i '20d' wrf_SkewT1.ncl            
sed -i '19 a a= addfile ("wrfout_d01_'$tamyil'-'$ay'-'$gun'_00.nc", "r") ' wrf_SkewT1.ncl
ncl wrf_SkewT1.ncl
convert -trim -density 100 tahmin.ps ~/public_html/SkewT/tahmin.png
rm tahmin.ps

