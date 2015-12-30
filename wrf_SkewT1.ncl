
;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.
;   Plot SkewT's at a number of locations
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/skewt_func.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.






a= addfile ("wrfout_d01_2015-12-30_00.nc", "r") 


; We generate plots, but what kind do we prefer?
;  type = "x11"
 type = "pdf"
; type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,"tahmin")

  gsn_define_colormap(wks,"WhViBlGrYeOrReWh")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; What times and how many time steps are in the data set?
  FirstTime = True
  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

; Get some dimension info - so we can later check to make sure 
; the sounding locations are inside the model domain
  mdims = getfilevardimsizes(a,"P")
  nd = dimsizes(mdims)
  dimX = mdims(nd-1)
  dimY = mdims(nd-2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  do it = 0,ntimes-1,3        ; TIME LOOP

    print("Working on time: " + times(it) )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First get the variables we will need        

    tc  = wrf_user_getvar(a,"tc",it)         ; T in C
    td  = wrf_user_getvar(a,"td",it)         ; dew point temperature
    p   = wrf_user_getvar(a, "pressure",it)  ; grid point pressure
    z   = wrf_user_getvar(a, "z",it)         ; grid point height
    uvm = wrf_user_getvar(a,"uvmet",it)      ; umet and vmet averaged to mass points
					     ; This is a 4D array where
					     ; uvm(0,:,:,:) is umet, and
					     ; uvm(1,:,:,:) is vmet, and
					     ; This function rotate winds to earth coord.

    ; extract u and v from uvm array, and turn wind into kts
      u   = uvm(0,:,:,:)*1.94386 
      v   = uvm(1,:,:,:)*1.94386

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 ; Stations, and their lat/lon locations

  ;   ip_locs = (/"Kutahya LTBZ","Kutahya LTBN"/)

 ;    ip_lats = (/39.11,39.43 /)

;    ip_lons = (/30.13,30.02 /) 


   ip_locs = (/ "Istanbul LTBA", "Ankara LTAC", "Istanbul LTFJ", "Adana LTAF", "Antakya LTAK", "Antalya LTAI", "Bodrum LTFE", "Bursa LTBR", "Dalaman LTBS", "Erzurum LTCE", "Eskisehir LTBY", "Gaziantep LTAJ", "Izmir LTBJ", "Kayseri LTAU", "Konya LTAN", "Kutahya LTBZ", "Malatya LTAT", "Nevsehir LTAZ", "Samsun LTFH", "Sanliurfa LTCS", "Trabzon LTCG", "Adiyaman LTCP", "Agri LTCO", "Amasya LTAP", "Antalya LTGP", "Balikesir LTBF", "Balikesir LTFD", "Batman LTCJ", "Bingol LTCU", "Canakkale LTBH", "Denizli LTAY", "Diyarbakir LTCC", "Elazig LTCA", "Erzincan LTCD", "Igdir LTCT", "Isparta LTFC", "Istanbul LTBW", "Kahramanmaras LTCN", "Kars LTCF", "Kastamonu LTAL", "Kocaeli LTBQ", "Mardin LTCR", "Mus LTCK", "Siirt LTCL", "Sinop LTCM", "Sivas LTAR", "Sirnak LTCV", "Tekirdag LTBU", "Tokat LTAW", "Usak LTBO", "Van LTCI", "Zonguldak LTAS", "Ankara LTAB", "Ankara LTAE", "Ankara LTAD", "Balikesir LTBF", "Bandirma LTBG", "Eskisehir LTBI", "Incirlik LTAG", "Istanbul LTBX", "Izmir LTBL", "Izmir LTBK", "Kutahya LTBN" /)

    ip_lats = (/ 40.97, 40.13, 40.90, 36.98, 36.36, 36.90, 37.25, 40.26, 36.71, 39.96, 39.81, 36.95, 38.29, 38.77, 37.98, 39.11, 38.44, 38.77, 41.27, 37.45, 41.00, 37.73, 39.66, 40.83, 36.3, 39.62, 39.56, 37.93, 38.86, 40.14, 37.79, 37.89, 38.60, 39.71, 39.98, 38.86, 41.10, 37.54, 40.56, 41.31, 40.74, 37.23, 38.74, 37.97, 42.02, 39.77, 37.36, 41.14, 40.31, 38.68, 38.47, 41.51, 39.93, 40.08, 39.95, 39.62, 40.32, 39.78, 37.00, 40.99, 38.51, 38.32, 39.43 /)

     ip_lons = (/ 28.81, 32.99, 29.31, 35.28, 36.28, 30.79, 27.66, 29.56, 28.79, 41.17, 30.52, 37.48, 27.16, 35.5, 32.56, 30.13, 38.09, 34.53, 36.55, 38.90, 39.79, 38.47, 43.03, 35.52, 32.3, 27.93, 27.01, 41.12, 40.59, 26.43, 29.70, 40.20, 39.29, 39.52, 43.86, 30.38, 28.55, 36.95, 43.12, 33.79, 30.08, 40.64, 41.66, 41.83, 35.07, 37.02, 42.06, 27.92, 36.37, 29.48, 43.33, 32.09, 32.74, 32.57, 32.69, 27.93, 27.98, 30.58, 35.43, 29.22, 27.01, 27.16, 30.02 /)


   do ip = 0, 62   ; LOOP through above 20 station locations and
                   ; plot a skewT if location is inside model domain


      ; Get ij point in model domain for location "ip"
      ; loc(1) is south-north (y) and loc(0) is west-east (x)
        loc = wrf_user_ll_to_ij(a, ip_lons(ip), ip_lats(ip), True)
        locX = loc(0)
        locY = loc(1)

      if ( locX .lt. 1 .or. locX .gt. dimX .or. locY .lt. 1 .or. locY .gt. dimY )
         if ( FirstTime)
           print("Attempting to plot: " + "Station - " + ip_locs(ip) )
           print("                    " + "at location: "+ ip_lats(ip) +" ; "+ ip_lons(ip) )
           print("                    " + "SKIP: Sounding outside model domain" )
         end if
      else

       ; We need array points in NCL space 
         locX = locX - 1
         locY = locY - 1

  ;      Define a few skew-T plotting options
         skewtOpts          = True
         skewtOpts@DrawHeightScale   = True    ; plot height scale on side
         skewtOpts@DrawHeightScaleFt = False   ; plot height scale in km
         skewtOpts@DrawStandardAtm   = True    ; draw standard atm on plot
         skewtOpts@vpXF              = 0.12    ; controls off-set from left
         skewtOpts@vpYF              = 0.87    ; controls off-set from top
         skewtOpts@vpWidthF          = 0.75    ; controls size of plot
         skewtOpts@vpHeightF         = 0.75    ; controls size of plot
         skewtOpts@DrawFahrenheit    = False   ; use deg C scale
         skewtOpts@tiMainFontHeightF = 0.015   ; change height of main title
        ;skewtOpts@DrawColLine       = False   ; draw lines in black
         skewtOpts@DrawColAreaFill   = True    ; color on background plot
        ;skewtOpts@DrawColAreaColor  = "Green" ; final color may depend on the color table used
         skewtOpts@DrawColAreaColor  = 53      ; Light Green for WhViBlGrYeOrReWh color table
         skewtOpts@PrintOpts         = False   ; do not print options out


  ;      Get the skew-T background
         skewtOpts@tiMainString = ip_locs(ip)  + " at " + times(it)
         skewt_bkgd             = skewT_BackGround (wks, skewtOpts)
         draw (skewt_bkgd)


  ;      Draw the skew-T plot
         dataOpts           = True
         dataOpts@Parcel    = 1
         dataOpts@WspdWdir  = False  ; wind speed and dir [else: u,v]
         dataOpts@HspdHdir  = True   ; wind speed and dir [else: u,v]
         dataOpts@PlotWindH = False  ; plot wind barbs at h lvls [pibal; special]
         skewT_data = skewT_PlotData(wks, skewt_bkgd, p(:,locY,locX), \
                                                     tc(:,locY,locX), \
                                                     td(:,locY,locX), \
                                                      z(:,locY,locX), \
                                                      u(:,locY,locX), \
                                                      v(:,locY,locX), \
                                                     dataOpts)

  ;      Close the frame
         frame(wks)

         delete(skewtOpts)
         delete(dataOpts)
         delete(skewT_data)
         delete(skewt_bkgd)

      end if

   end do     ; END OF LOCATIONS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    FirstTime = False

  end do        ; END OF TIME LOOP

end
